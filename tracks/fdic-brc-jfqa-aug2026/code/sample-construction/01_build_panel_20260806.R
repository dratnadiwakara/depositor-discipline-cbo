# =============================================================================
# 01_build_panel_20260612.R — Small-bank CECL panel for post-JMCB revision
#
# Ports the in-memory panel build from
# tracks/jmcb-june2026/code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd
# (lines 107-225) and extends it per docs/implementation-plan-20260612.md §1.1:
#   - alternative treatment scalings (assets, loans)
#   - residualized CECL treatment (first stage = expanded Table 2 predictors)
#   - loan growth, brokered, NPL, unrealized-loss, deposit-mix variables
#   - frozen 2022Q4 characteristics for flexible char-x-time controls
#   - optional reciprocal-deposit merge (produced by 01b script, if present)
#
# Input : data/raw/call_report_data_20260401_{1,2}.rds
#         (optional) tracks/post-jmcb-rejection-june2026/data/reciprocal_deposits_*.rds
# Output: tracks/post-jmcb-rejection-june2026/data/panel_smallbank_<stamp>.rds
# =============================================================================

rm(list = ls())

library(data.table)
library(fixest)
library(ggplot2)
library(here)
library(lubridate)
library(stringr)

source(here::here("code", "_common.R"))
source(here::here("tracks", "post-jmcb-rejection-june2026", "code", "_track_common.R"))

dat_suffix <- format(Sys.time(), "%Y%m%d")
raw_dir <- here::here("data", "raw")

# -----------------------------------------------------------------------------
# 1. Load raw Call Reports (same vintage as JMCB track — replication anchor)
# -----------------------------------------------------------------------------
raw1 <- file.path(raw_dir, "call_report_data_20260401_1.rds")
raw2 <- file.path(raw_dir, "call_report_data_20260401_2.rds")
stopifnot(file.exists(raw1), file.exists(raw2))

dt1 <- readRDS(raw1)
dt2 <- readRDS(raw2)
setDT(dt1); setDT(dt2)
dt <- rbind(dt1, dt2, fill = TRUE)
rm(dt1, dt2); gc()

comm_bank_threshold <- 10e6  # total_assets in $thousands -> $10B

dt[, D_DT := as.Date(D_DT)]
dt[, cal_year := as.integer(format(D_DT, "%Y"))]
dt[, quarter_no := lubridate::quarter(D_DT)]
dt <- unique(dt, by = c("ID_RSSD", "D_DT"))
setorder(dt, ID_RSSD, D_DT)

# -----------------------------------------------------------------------------
# 2. De-cumulate YTD flow variables (identical to JMCB-track logic)
# -----------------------------------------------------------------------------
cumulative_vars <- intersect(c(
  "interest_expense", "interest_income", "net_interest_income", "net_income",
  "nonint_expense", "nonint_income"
), names(dt))

for (v in cumulative_vars) {
  new_v <- paste0(v, "_q")
  dt[, (new_v) := fifelse(quarter_no == 1L, get(v), get(v) - shift(get(v), 1L)),
     by = .(ID_RSSD, cal_year)]
  dt[quarter_no > 1L & is.na(shift(get(v), 1L)), (new_v) := NA, by = .(ID_RSSD, cal_year)]
}

ie_var <- "interest_expense_q"
eq_col <- "equity_bop"

# -----------------------------------------------------------------------------
# 3. Treatment scalings
# -----------------------------------------------------------------------------
dt[, cecl_equity := fifelse(
  !is.na(CECL) & !is.na(get(eq_col)) & get(eq_col) > 0,
  CECL / get(eq_col) * 100, NA_real_
)]
dt[, cecl_assets := fifelse(
  !is.na(CECL) & !is.na(total_assets) & total_assets > 0,
  CECL / total_assets * 100, NA_real_
)]
dt[, cecl_loans := fifelse(
  !is.na(CECL) & !is.na(total_loans) & total_loans > 0,
  CECL / total_loans * 100, NA_real_
)]

# -----------------------------------------------------------------------------
# 4. Outcome / control ratios (baseline set identical to JMCB track; new vars added)
# -----------------------------------------------------------------------------
dt[total_assets > 0, unins_time_deps_assets := (unins_time_deps / total_assets) * 100]
dt[total_assets > 0, ins_time_deps_assets   := (ins_time_deps / total_assets) * 100]
dt[total_assets > 0, int_expense_assets     := (get(ie_var) / total_assets) * 100]
dt[total_assets > 0, unins_deps_assets      := (unins_deps_excl_ret / total_assets) * 100]
dt[total_assets > 0, ins_deps_assets        := (ins_deps_excl_ret / total_assets) * 100]
dt[n_accts_ins_excl_ret > 0 & n_accts_unins_excl_ret > 0,
   n_unins_deps_pct := n_accts_unins_excl_ret /
     (n_accts_unins_excl_ret + n_accts_ins_excl_ret) * 100]
dt[total_assets > 0, roa := net_income_q * 100 / total_assets]
dt[total_assets > 0, roe := net_income_q * 100 / get(eq_col)]
dt[total_assets > 0, equity_assets := get(eq_col) * 100 / total_assets]
dt[total_assets > 0, nim := net_interest_income_q * 100 / total_assets]

# --- new: lending ---
dt[total_assets > 0, loans_assets := total_loans / total_assets * 100]
dt[, cre_loans := cre_owner_occ + cre_other]
dt[, loan_growth := fifelse(
  shift(total_loans, 1L) > 0 & total_loans > 0,
  100 * (log(total_loans) - log(shift(total_loans, 1L))), NA_real_
), by = ID_RSSD]
dt[, ci_growth := fifelse(
  shift(ci_loans, 1L) > 0 & ci_loans > 0,
  100 * (log(ci_loans) - log(shift(ci_loans, 1L))), NA_real_
), by = ID_RSSD]
dt[, cre_growth := fifelse(
  shift(cre_loans, 1L) > 0 & cre_loans > 0,
  100 * (log(cre_loans) - log(shift(cre_loans, 1L))), NA_real_
), by = ID_RSSD]

# --- new: wholesale / brokered funding ---
dt[total_assets > 0, brokered_assets := brokered_deposits / total_assets * 100]
dt[total_assets > 0, brokered_ins_assets := brokered_deps_ins / total_assets * 100]
dt[total_assets > 0, brokered_unins_lt1yr_assets := brokered_deps_unins_lt1yr / total_assets * 100]

# --- new: credit quality / securities ---
dt[total_loans > 0, npl_loans := nonaccrual_loans / total_loans * 100]
dt[total_loans > 0, acl_loans := acl_eop / total_loans * 100]
dt[total_loans > 0, cre_loans_share := cre_loans / total_loans * 100]
dt[total_assets > 0, unreal_loss_assets :=
     ((afs_fair_value - afs_amortized_cost) +
      (htm_fair_value - htm_amortized_cost)) / total_assets * 100]

# --- new: deposit mix ---
dt[total_deposits > 0, unins_dep_share := unins_deps_excl_ret / total_deposits * 100]
dt[total_deposits > 0, time_dep_share :=
     (unins_time_deps + ins_time_deps + time_deps_lt100k) / total_deposits * 100]
dt[total_deposits > 0, brokered_share := brokered_deposits / total_deposits * 100]
dt[total_assets > 0, log_total_assets := log(total_assets)]

# --- optional: reciprocal deposits (built by 01b_pull_reciprocal_*; guarded) ---
recip_files <- list.files(TRACK_DATA, pattern = "^reciprocal_deposits_\\d{8}\\.rds$",
                          full.names = TRUE)
has_reciprocal <- length(recip_files) > 0L
if (has_reciprocal) {
  recip <- readRDS(recip_files[which.max(file.mtime(recip_files))])
  setDT(recip)
  recip[, D_DT := as.Date(D_DT)]
  dt <- merge(dt, recip[, .(ID_RSSD, D_DT, reciprocal_deps)],
              by = c("ID_RSSD", "D_DT"), all.x = TRUE)
  dt[total_assets > 0, reciprocal_assets := reciprocal_deps / total_assets * 100]
  cat("Reciprocal deposits merged from:", basename(recip_files[which.max(file.mtime(recip_files))]), "\n")
} else {
  cat("NOTE: no reciprocal_deposits_*.rds in", TRACK_DATA, "- reciprocal_assets not built.\n")
}

# -----------------------------------------------------------------------------
# 5. Winsorize ratio variables within quarter (1/99), as in JMCB track
# -----------------------------------------------------------------------------
ratio_vars_panel <- intersect(c(
  "cecl_equity", "cecl_assets", "cecl_loans",
  "unins_time_deps_assets", "ins_time_deps_assets", "int_expense_assets",
  "unins_deps_assets", "ins_deps_assets", "n_unins_deps_pct", "roa", "roe",
  "equity_assets", "nim",
  "loans_assets", "loan_growth", "ci_growth", "cre_growth",
  "brokered_assets", "brokered_ins_assets", "brokered_unins_lt1yr_assets",
  "reciprocal_assets",
  "npl_loans", "acl_loans", "cre_loans_share", "unreal_loss_assets",
  "unins_dep_share", "time_dep_share", "brokered_share"
), names(dt))
winsorize_by_date(dt, vars = ratio_vars_panel, date_var = "D_DT", probs = c(0.01, 0.99))

# -----------------------------------------------------------------------------
# 6. Small-bank sample and staggered adoption assignment (identical logic)
# -----------------------------------------------------------------------------
small_bank_ids <- unique(dt[D_DT == "2022-12-31" & total_assets < comm_bank_threshold, ID_RSSD])
dt_sb <- dt[ID_RSSD %in% small_bank_ids]

adopt_quarters <- as.Date(c(
  "2022-09-30", "2022-12-31", "2023-03-31", "2023-06-30", "2023-09-30", "2023-12-31"
))
adopt_by_bank <- dt_sb[D_DT %in% adopt_quarters & !is.na(cecl_equity),
                       .(adopt_dt = min(D_DT)), by = ID_RSSD]
dt_sb <- merge(dt_sb, adopt_by_bank, by = "ID_RSSD")  # drops non-adopters (no all.x)

cs_adopt <- dt_sb[!is.na(adopt_dt) & D_DT == adopt_dt & !is.na(cecl_equity)]
stopifnot(nrow(cs_adopt) > 0L)

# Binary treatments: baseline 2.5%-of-equity rule; alternative scalings cut at the
# same percentile of their adoption distribution to keep treated-group size comparable.
pctl_25 <- mean(cs_adopt$cecl_equity < CECL_THRESHOLD_PCT, na.rm = TRUE)
thr_assets <- quantile(cs_adopt$cecl_assets, pctl_25, na.rm = TRUE)
thr_loans  <- quantile(cs_adopt$cecl_loans, pctl_25, na.rm = TRUE)
cat(sprintf("Binary cutoffs: equity %.2f (pctl %.3f) | assets %.4f | loans %.4f\n",
            CECL_THRESHOLD_PCT, pctl_25, thr_assets, thr_loans))

treat_map <- cs_adopt[, .(
  ID_RSSD,
  cecl_equity_adopt = cecl_equity,
  cecl_assets_adopt = cecl_assets,
  cecl_loans_adopt  = cecl_loans,
  high_cecl_equity  = as.integer(cecl_equity >= CECL_THRESHOLD_PCT),
  high_cecl_assets  = as.integer(cecl_assets >= thr_assets),
  high_cecl_loans   = as.integer(cecl_loans >= thr_loans)
)]
dt_sb <- merge(dt_sb, treat_map, by = "ID_RSSD")
dt_sb[is.na(high_cecl_equity), high_cecl_equity := 0L]

# Freeze continuous treatments at adoption value across all quarters (as in JMCB track)
dt_sb[!is.na(cecl_equity_adopt) & (is.na(cecl_equity) | D_DT != adopt_dt),
      cecl_equity := cecl_equity_adopt]
dt_sb[!is.na(cecl_assets_adopt), cecl_assets := cecl_assets_adopt]
dt_sb[!is.na(cecl_loans_adopt),  cecl_loans := cecl_loans_adopt]
dt_sb[, c("cecl_equity_adopt", "cecl_assets_adopt", "cecl_loans_adopt") := NULL]

dt_sb[, qtrs_since := compute_qtrs_since(D_DT, adopt_dt)]
dt_sb[, post := as.integer(qtrs_since >= 0L)]

# -----------------------------------------------------------------------------
# 7. Lagged controls (identical to JMCB track)
# -----------------------------------------------------------------------------
setorder(dt_sb, ID_RSSD, D_DT)
dt_sb[, ta_lag := shift(total_assets, 1L), by = ID_RSSD]
dt_sb[, log_total_assets_l1 := fifelse(ta_lag > 0 & !is.na(ta_lag), log(ta_lag), NA_real_)]
dt_sb[, ta_lag := NULL]
dt_sb[, equity_assets_l1 := shift(equity_assets, 1L), by = ID_RSSD]
dt_sb[, int_expense_assets_l1 := shift(int_expense_assets, 1L), by = ID_RSSD]
dt_sb[, nim_l1 := shift(nim, 1L), by = ID_RSSD]

# -----------------------------------------------------------------------------
# 8. Frozen 2022Q4 characteristics (flexible char-x-time controls)
# -----------------------------------------------------------------------------
chars_22q4 <- dt_sb[D_DT == as.Date("2022-12-31"), .(
  ID_RSSD,
  unins_dep_share_22q4   = unins_dep_share,
  log_ta_22q4            = log_total_assets,
  equity_assets_22q4     = equity_assets,
  npl_loans_22q4         = npl_loans,
  roa_22q4               = roa,
  cre_loans_share_22q4   = cre_loans_share,
  brokered_share_22q4    = brokered_share,
  unreal_loss_assets_22q4 = unreal_loss_assets
)]
dt_sb <- merge(dt_sb, chars_22q4, by = "ID_RSSD", all.x = TRUE)

# -----------------------------------------------------------------------------
# 9. Pre-adoption trends (8 quarters 2021Q1-2022Q4) and residualized treatment
# -----------------------------------------------------------------------------
trend_window <- dt_sb[D_DT >= as.Date("2021-03-31") & D_DT <= as.Date("2022-12-31")]
trend_window[, t_idx := as.integer(factor(D_DT))]
slope_dt <- trend_window[, {
  roa_tr <- if (sum(!is.na(roa)) >= 6L) coef(lm(roa ~ t_idx))[2L] else NA_real_
  npl_tr <- if (sum(!is.na(npl_loans)) >= 6L) coef(lm(npl_loans ~ t_idx))[2L] else NA_real_
  .(roa_trend_8q = roa_tr, npl_trend_8q = npl_tr)
}, by = ID_RSSD]
dt_sb <- merge(dt_sb, slope_dt, by = "ID_RSSD", all.x = TRUE)

# First stage: cross-section, predictors measured at 2022Q4 (pre-adoption), expanded set.
fs_cs <- dt_sb[D_DT == as.Date("2022-12-31"),
               c("ID_RSSD", "cecl_equity", CECL_PREDICTORS_EXPANDED), with = FALSE]
fs_cs <- fs_cs[complete.cases(fs_cs)]
fs_fml <- as.formula(paste("cecl_equity ~", paste(CECL_PREDICTORS_EXPANDED, collapse = " + ")))
fs_mod <- feols(fs_fml, data = fs_cs, vcov = "hetero")
cat("\n--- First stage (cecl_equity on expanded predictors, 2022Q4 cross-section) ---\n")
print(summary(fs_mod))

fs_cs[, cecl_resid := resid(fs_mod)]
thr_resid <- quantile(fs_cs$cecl_resid, pctl_25, na.rm = TRUE)
fs_cs[, high_cecl_resid := as.integer(cecl_resid >= thr_resid)]
dt_sb <- merge(dt_sb, fs_cs[, .(ID_RSSD, cecl_resid, high_cecl_resid)],
               by = "ID_RSSD", all.x = TRUE)

# -----------------------------------------------------------------------------
# 10. Save
# -----------------------------------------------------------------------------
out_path <- file.path(TRACK_DATA, paste0("panel_smallbank_", dat_suffix, ".rds"))
saveRDS(dt_sb, out_path)
cat("\nSaved:", out_path, "\n")

# -----------------------------------------------------------------------------
# 11. Diagnostic block (read before any downstream regression)
# -----------------------------------------------------------------------------
cat("\n=============== DIAGNOSTICS: panel_smallbank ===============\n")
cat(sprintf("Rows: %s | Banks: %s | Span: %s to %s\n",
            format(nrow(dt_sb), big.mark = ","), uniqueN(dt_sb$ID_RSSD),
            min(dt_sb$D_DT), max(dt_sb$D_DT)))
cat("\nAdoption cohorts:\n")
print(dt_sb[D_DT == adopt_dt, .N, by = adopt_dt][order(adopt_dt)])
cat(sprintf("\nTreated (binary): equity %d | assets %d | loans %d | resid %d (of %d banks)\n",
            sum(treat_map$high_cecl_equity, na.rm = TRUE),
            sum(treat_map$high_cecl_assets, na.rm = TRUE),
            sum(treat_map$high_cecl_loans, na.rm = TRUE),
            sum(fs_cs$high_cecl_resid, na.rm = TRUE),
            uniqueN(dt_sb$ID_RSSD)))

key_vars <- intersect(c(
  "cecl_equity", "cecl_assets", "cecl_loans", "cecl_resid",
  "unins_time_deps_assets", "ins_time_deps_assets", "int_expense_assets",
  "roa", "nim", "loan_growth", "ci_growth", "cre_growth",
  "brokered_assets", "brokered_ins_assets", "reciprocal_assets",
  "npl_loans", "unreal_loss_assets", "unins_dep_share"
), names(dt_sb))

cat("\nNA counts and p1/p50/p99:\n")
for (v in key_vars) {
  x <- dt_sb[[v]]
  q <- quantile(x, c(0.01, 0.50, 0.99), na.rm = TRUE)
  cat(sprintf("  %-28s NA=%6d  p1=%9.3f  p50=%9.3f  p99=%9.3f\n",
              v, sum(is.na(x)), q[1], q[2], q[3]))
}

cat("\nTreatment cross-correlations (adoption cross-section):\n")
cc <- dt_sb[D_DT == adopt_dt, .(cecl_equity, cecl_assets, cecl_loans, cecl_resid)]
print(round(cor(cc, use = "pairwise.complete.obs"), 3))

cat("\nFrozen 2022Q4 characteristics NA counts (banks):\n")
for (v in CHARS_22Q4) {
  cat(sprintf("  %-28s NA banks = %d\n", v,
              uniqueN(dt_sb[is.na(get(v)), ID_RSSD])))
}
cat("=============================================================\n")
