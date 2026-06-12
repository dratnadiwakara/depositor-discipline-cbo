# =============================================================================
# 02_build_sophistication_20260612.R — Depositor sophistication indices
#
# Ports the SOD/ACS construction from
# tracks/jmcb-june2026/code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd
# (lines 419-479) and produces TWO indices per implementation plan §1.2:
#   - frac_soph_2022 : 2022 SOD branch-deposit weights (baseline, replication anchor)
#   - frac_soph_2019w: 2019 SOD branch-deposit weights (pre-period weights; addresses
#     RA4 reverse-causality concern). ZIP classification held at 2022 ACS in both.
#
# Input : data/raw/fdic_sod_2012_2025_20260328.rds
#         data/raw/zip_year_demographics_20260328.rds
# Output: tracks/post-jmcb-rejection-june2026/data/sophistication_<stamp>.rds
# =============================================================================

rm(list = ls())

library(data.table)
library(here)
library(stringr)

source(here::here("code", "_common.R"))
source(here::here("tracks", "post-jmcb-rejection-june2026", "code", "_track_common.R"))

dat_suffix <- format(Sys.time(), "%Y%m%d")
raw_dir <- here::here("data", "raw")

sod_raw <- readRDS(file.path(raw_dir, "fdic_sod_2012_2025_20260328.rds"))
setDT(sod_raw)

zip_demo <- readRDS(file.path(raw_dir, "zip_year_demographics_20260328.rds"))
setDT(zip_demo)
zip_2022 <- zip_demo[acs_year == 2022L]

build_soph <- function(sod_year) {
  sod <- sod_raw[YEAR == sod_year]
  if (!"deposits_dollars" %in% names(sod)) {
    sod[, deposits_dollars := DEPSUMBR * 1000]
  }
  sod[, zip5 := str_pad(as.character(ZIPBR), 5L, side = "left", pad = "0")]
  sod_merged <- merge(
    sod,
    zip_2022[, .(zip5, sophisticated)],
    by = "zip5", all.x = TRUE
  )
  sod_merged[, .(
    frac_sophisticated = fifelse(
      sum(deposits_dollars, na.rm = TRUE) > 0,
      sum(deposits_dollars * sophisticated, na.rm = TRUE) /
        sum(deposits_dollars, na.rm = TRUE),
      NA_real_
    ),
    n_branches = .N,
    total_sod_deposits = sum(deposits_dollars, na.rm = TRUE)
  ), by = RSSDID]
}

soph_2022 <- build_soph(2022L)
soph_2019 <- build_soph(2019L)

# Binary split: top quartile within each index's bank distribution (same rule as
# JMCB track: quantile 0.75)
q75_2022 <- quantile(soph_2022$frac_sophisticated, 0.75, na.rm = TRUE)
q75_2019 <- quantile(soph_2019$frac_sophisticated, 0.75, na.rm = TRUE)
soph_2022[, high_soph_2022 := as.integer(frac_sophisticated >= q75_2022)]
soph_2019[, high_soph_2019w := as.integer(frac_sophisticated >= q75_2019)]

out <- merge(
  soph_2022[, .(ID_RSSD = RSSDID, frac_soph_2022 = frac_sophisticated,
                high_soph_2022, n_branches_2022 = n_branches)],
  soph_2019[, .(ID_RSSD = RSSDID, frac_soph_2019w = frac_sophisticated,
                high_soph_2019w, n_branches_2019 = n_branches)],
  by = "ID_RSSD", all = TRUE
)

out_path <- file.path(TRACK_DATA, paste0("sophistication_", dat_suffix, ".rds"))
saveRDS(out, out_path)
cat("Saved:", out_path, "\n")

# -----------------------------------------------------------------------------
# Diagnostics
# -----------------------------------------------------------------------------
cat("\n=============== DIAGNOSTICS: sophistication ===============\n")
cat(sprintf("Banks with 2022 index: %d | 2019 index: %d | both: %d\n",
            sum(!is.na(out$frac_soph_2022)), sum(!is.na(out$frac_soph_2019w)),
            sum(!is.na(out$frac_soph_2022) & !is.na(out$frac_soph_2019w))))
both <- out[!is.na(frac_soph_2022) & !is.na(frac_soph_2019w)]
cat(sprintf("Correlation (continuous): %.3f\n",
            cor(both$frac_soph_2022, both$frac_soph_2019w)))
cat("Cross-tab high_soph_2022 x high_soph_2019w:\n")
print(table(both$high_soph_2022, both$high_soph_2019w, dnn = c("2022", "2019w")))
cat(sprintf("Classification switchers: %.1f%%\n",
            100 * mean(both$high_soph_2022 != both$high_soph_2019w)))
for (v in c("frac_soph_2022", "frac_soph_2019w")) {
  q <- quantile(out[[v]], c(0.01, 0.50, 0.99), na.rm = TRUE)
  cat(sprintf("  %-18s NA=%5d  p1=%.3f  p50=%.3f  p99=%.3f\n",
              v, sum(is.na(out[[v]])), q[1], q[2], q[3]))
}

# Match rate to the small-bank panel
panel <- readRDS(latest_track_file("panel_smallbank"))
ids <- unique(panel$ID_RSSD)
cat(sprintf("\nMatch to small-bank panel (%d banks): 2022 %.1f%% | 2019w %.1f%%\n",
            length(ids),
            100 * mean(ids %in% out[!is.na(frac_soph_2022), ID_RSSD]),
            100 * mean(ids %in% out[!is.na(frac_soph_2019w), ID_RSSD])))
cat("=============================================================\n")
