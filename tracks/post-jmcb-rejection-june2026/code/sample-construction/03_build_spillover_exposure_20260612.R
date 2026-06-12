# =============================================================================
# 03_build_spillover_exposure_20260612.R — SOD spillover exposure (RB2 SUTVA)
#
# Per implementation plan §1.3:
#  - expo_high_cecl (bank-level): Σ_c w_bc × HighCECLshare_c, where
#      w_bc            = bank b's 2022 deposit share across counties c (STCNTYBR)
#      HighCECLshare_c = leave-out deposit share of high-CECL banks' branches in
#                        county c (2022 SOD weights; treatment = high_cecl_equity
#                        from the adoption map in panel_smallbank)
#  - sod_dep_growth (bank-year, 2018-2025): 100 × Δlog(total SOD deposits)
#  - dep_hhi_county (bank-level): Σ_c w_bc × HHI_c (2022 county deposit HHI,
#    0-10,000 scale) for the expanded Table 2 predictor set
#
# Input : data/raw/fdic_sod_2012_2025_20260328.rds
#         tracks/post-jmcb-rejection-june2026/data/panel_smallbank_<latest>.rds
# Output: tracks/post-jmcb-rejection-june2026/data/spillover_exposure_<stamp>.rds
#         (bank-year; bank-level vars repeated within bank)
# =============================================================================

rm(list = ls())

library(data.table)
library(here)

source(here::here("code", "_common.R"))
source(here::here("tracks", "post-jmcb-rejection-june2026", "code", "_track_common.R"))

dat_suffix <- format(Sys.time(), "%Y%m%d")

sod <- readRDS(here::here("data", "raw", "fdic_sod_2012_2025_20260328.rds"))
setDT(sod)
sod <- sod[YEAR >= 2018L & YEAR <= 2025L]
if (!"deposits_dollars" %in% names(sod)) {
  sod[, deposits_dollars := DEPSUMBR * 1000]
}
sod <- sod[!is.na(deposits_dollars) & !is.na(STCNTYBR)]

panel <- readRDS(latest_track_file("panel_smallbank"))
treat_map <- unique(panel[!is.na(high_cecl_equity),
                          .(RSSDID = ID_RSSD, high_cecl_equity)])
stopifnot(anyDuplicated(treat_map$RSSDID) == 0L)

# -----------------------------------------------------------------------------
# Bank-county deposits, 2022 (weights year)
# -----------------------------------------------------------------------------
bc22 <- sod[YEAR == 2022L,
            .(dep = sum(deposits_dollars)), by = .(RSSDID, STCNTYBR)]
bc22 <- merge(bc22, treat_map, by = "RSSDID", all.x = TRUE)
bc22[is.na(high_cecl_equity), high_cecl_equity := 0L]  # non-sample banks = untreated

# County totals and high-CECL totals (all banks in county)
cnty <- bc22[, .(
  dep_total = sum(dep),
  dep_high  = sum(dep * high_cecl_equity)
), by = STCNTYBR]

# County HHI on 0-10,000 scale (squared percentage shares)
hhi <- bc22[, .(hhi_c = sum((100 * dep / sum(dep))^2)), by = STCNTYBR]
cnty <- merge(cnty, hhi, by = "STCNTYBR")

# Leave-out high-CECL share for each bank-county; bank-level exposure
bc22 <- merge(bc22, cnty, by = "STCNTYBR")
bc22[, dep_total_lo := dep_total - dep]
bc22[, dep_high_lo := dep_high - dep * high_cecl_equity]
bc22[, high_share_lo := fifelse(dep_total_lo > 0, dep_high_lo / dep_total_lo, NA_real_)]

bank_expo <- bc22[, .(
  expo_high_cecl = sum(dep * high_share_lo, na.rm = TRUE) /
    sum(dep * !is.na(high_share_lo)),
  dep_hhi_county = sum(dep * hhi_c) / sum(dep),
  n_counties_2022 = uniqueN(STCNTYBR)
), by = RSSDID]

# -----------------------------------------------------------------------------
# Bank-year SOD deposit growth, 2018-2025
# -----------------------------------------------------------------------------
by_dep <- sod[, .(sod_deposits = sum(deposits_dollars)), by = .(RSSDID, YEAR)]
setorder(by_dep, RSSDID, YEAR)
by_dep[, sod_dep_growth := fifelse(
  YEAR - shift(YEAR) == 1L,
  100 * (log(sod_deposits) - log(shift(sod_deposits))),
  NA_real_
), by = RSSDID]

out <- merge(by_dep, bank_expo, by = "RSSDID", all.x = TRUE)
out <- merge(out, treat_map, by = "RSSDID", all.x = TRUE)
setnames(out, "RSSDID", "ID_RSSD")
out[, post_2023 := as.integer(YEAR >= 2023L)]

out_path <- file.path(TRACK_DATA, paste0("spillover_exposure_", dat_suffix, ".rds"))
saveRDS(out, out_path)
cat("Saved:", out_path, "\n")

# -----------------------------------------------------------------------------
# County-year panel: deposit growth of low-CECL banks' branches by county,
# regressor = county high-CECL deposit share (2022). For the county-FE version
# of the spillover test.
# -----------------------------------------------------------------------------
sod_t <- merge(sod, treat_map, by = "RSSDID", all.x = TRUE)
sod_t[is.na(high_cecl_equity), high_cecl_equity := 0L]
cy <- sod_t[high_cecl_equity == 0L,
            .(dep_lowcecl = sum(deposits_dollars)), by = .(STCNTYBR, YEAR)]
setorder(cy, STCNTYBR, YEAR)
cy[, cnty_dep_growth_lowcecl := fifelse(
  YEAR - shift(YEAR) == 1L,
  100 * (log(dep_lowcecl) - log(shift(dep_lowcecl))),
  NA_real_
), by = STCNTYBR]
cy <- merge(cy, cnty[, .(STCNTYBR, high_share_2022 = dep_high / dep_total, hhi_c)],
            by = "STCNTYBR", all.x = TRUE)
cy[, post_2023 := as.integer(YEAR >= 2023L)]

cy_path <- file.path(TRACK_DATA, paste0("spillover_county_", dat_suffix, ".rds"))
saveRDS(cy, cy_path)
cat("Saved:", cy_path, "\n")

# -----------------------------------------------------------------------------
# Diagnostics
# -----------------------------------------------------------------------------
cat("\n=============== DIAGNOSTICS: spillover_exposure ===============\n")
cat(sprintf("Rows (bank-year): %d | Banks: %d | Years: %d-%d\n",
            nrow(out), uniqueN(out$ID_RSSD), min(out$YEAR), max(out$YEAR)))
cat(sprintf("Counties (2022): %d | Banks with 2022 weights: %d\n",
            uniqueN(bc22$STCNTYBR), nrow(bank_expo)))
in_panel <- out[!is.na(high_cecl_equity)]
cat(sprintf("Banks matched to small-bank panel: %d (high-CECL: %d)\n",
            uniqueN(in_panel$ID_RSSD),
            uniqueN(in_panel[high_cecl_equity == 1, ID_RSSD])))
for (v in c("expo_high_cecl", "dep_hhi_county", "sod_dep_growth")) {
  x <- out[[v]]
  q <- quantile(x, c(0.01, 0.25, 0.50, 0.75, 0.99), na.rm = TRUE)
  cat(sprintf("  %-16s NA=%6d  p1=%8.2f  p25=%8.2f  p50=%8.2f  p75=%8.2f  p99=%8.2f\n",
              v, sum(is.na(x)), q[1], q[2], q[3], q[4], q[5]))
}
lowc <- in_panel[high_cecl_equity == 0 & !is.na(expo_high_cecl)]
cat(sprintf("Low-CECL banks with exposure (spillover sample): %d banks, %d bank-years\n",
            uniqueN(lowc$ID_RSSD), nrow(lowc)))
cat(sprintf("  expo among low-CECL: p50=%.4f p75=%.4f p99=%.4f | share expo>0: %.1f%%\n",
            quantile(lowc$expo_high_cecl, 0.5), quantile(lowc$expo_high_cecl, 0.75),
            quantile(lowc$expo_high_cecl, 0.99), 100 * mean(lowc$expo_high_cecl > 0)))
cat("================================================================\n")
