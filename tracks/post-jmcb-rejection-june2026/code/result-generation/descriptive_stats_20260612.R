# =============================================================================
# descriptive_stats_20260612.R — Table 1, expanded Table 2 (RB-m1), Figures 1-2
#
# Ports tracks/jmcb-june2026/code/result-generation/descriptive_stats_20260403.R
# but reads panel_smallbank (01_build_panel_20260612.R) so every variable
# definition matches the regression sample exactly. Table 2 expansion: deposit
# mix, 8-quarter ROA/NPL trends, county deposit HHI — single-source predictor
# lists from _track_common.R; the col-(2) spec is the cecl_resid first stage.
# =============================================================================

rm(list = ls())

library(data.table)
library(fixest)
library(ggplot2)
library(here)
library(lubridate)

source(here::here("code", "_common.R"))
source(here::here("tracks", "post-jmcb-rejection-june2026", "code", "_track_common.R"))

save_figures <- TRUE
save_tables  <- TRUE
dat_suffix <- format(Sys.time(), "%Y%m%d")

panel <- readRDS(latest_track_file("panel_smallbank"))
setDT(panel)

# County HHI (bank-level, from SOD 2022; built by 03_build_spillover_exposure)
sp <- readRDS(latest_track_file("spillover_exposure"))
setDT(sp)
hhi_bank <- unique(sp[!is.na(dep_hhi_county), .(ID_RSSD, dep_hhi_county)])
hhi_bank[, dep_hhi_county := dep_hhi_county / 100]  # 0-100 scale for readability
panel <- merge(panel, hhi_bank, by = "ID_RSSD", all.x = TRUE)

# -----------------------------------------------------------------------------
# Table 1: cross-section at each bank's adoption quarter, high/low CECL split
# -----------------------------------------------------------------------------
cs <- panel[D_DT == adopt_dt]
cs2 <- copy(cs)
cs2[, total_assets := total_assets / 1000]  # $M

sumstat_vars <- c(
  "total_assets", "equity_assets", "cecl_equity",
  "npl_loans", "acl_loans", "cre_loans_share",
  "unins_time_deps_assets", "ins_time_deps_assets", "unins_dep_share",
  "int_expense_assets", "roa"
)
var_labels <- c(
  total_assets           = "Total Assets (\\$M)",
  equity_assets          = "Equity / Assets (\\%)",
  cecl_equity            = "CECL Adj.\\ / Equity (\\%)",
  npl_loans              = "NPL / Loans (\\%)",
  acl_loans              = "Allowance / Loans (\\%)",
  cre_loans_share        = "CRE / Loans (\\%)",
  unins_time_deps_assets = "Unins.\\ Time Deps / Assets (\\%)",
  ins_time_deps_assets   = "Ins.\\ Time Deps / Assets (\\%)",
  unins_dep_share        = "Unins.\\ Deps / Total Deps (\\%)",
  int_expense_assets     = "Int.\\ Expense / Assets (\\%)",
  roa                    = "ROA (\\%)"
)

stat_row <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0L) return(c(N = 0L, Mean = NA, SD = NA, Median = NA))
  c(N = length(x), Mean = round(mean(x), 3), SD = round(sd(x), 3),
    Median = round(median(x), 3))
}
build_col <- function(data, vars) {
  rbindlist(lapply(vars, function(v) {
    r <- stat_row(data[[v]])
    data.table(Variable = var_labels[v], N = r["N"], Mean = r["Mean"],
               SD = r["SD"], Median = r["Median"])
  }))
}

tab_full <- build_col(cs2, sumstat_vars)
tab_high <- build_col(cs2[high_cecl_equity == 1L], sumstat_vars)
tab_low  <- build_col(cs2[high_cecl_equity == 0L], sumstat_vars)
diff_col <- rbindlist(lapply(sumstat_vars, function(v) {
  hi <- na.omit(cs2[high_cecl_equity == 1L, get(v)])
  lo <- na.omit(cs2[high_cecl_equity == 0L, get(v)])
  if (length(hi) < 2L || length(lo) < 2L)
    return(data.table(Variable = var_labels[v], Diff = NA_character_))
  tt <- t.test(hi, lo, var.equal = FALSE)
  stars <- ifelse(tt$p.value < 0.01, "***",
           ifelse(tt$p.value < 0.05, "**",
           ifelse(tt$p.value < 0.10, "*", "")))
  data.table(Variable = var_labels[v],
             Diff = paste0(format(round(mean(hi) - mean(lo), 3), nsmall = 3), stars))
}))

cat(sprintf("Cross-section: %d banks | High CECL: %d | Low: %d\n",
            nrow(cs2), sum(cs2$high_cecl_equity == 1L), sum(cs2$high_cecl_equity == 0L)))
print(cbind(tab_full[, .(Variable, Mean, Median)],
            hi_mean = tab_high$Mean, lo_mean = tab_low$Mean, diff = diff_col$Diff))

n_full <- nrow(cs2)
n_high <- sum(cs2$high_cecl_equity == 1L)
n_low  <- sum(cs2$high_cecl_equity == 0L)
tex_lines <- c(
  "\\begingroup", "\\centering",
  "\\begin{tabular}{lrrr rrr rrr r}",
  "  \\tabularnewline \\midrule \\midrule",
  sprintf("  & \\multicolumn{3}{c}{Full Sample ($N=%d$)} & \\multicolumn{3}{c}{High CECL ($N=%d$)} & \\multicolumn{3}{c}{Low CECL ($N=%d$)} & \\\\",
          n_full, n_high, n_low),
  "  \\cmidrule(lr){2-4}\\cmidrule(lr){5-7}\\cmidrule(lr){8-10}",
  "  Variable & Mean & SD & Median & Mean & SD & Median & Mean & SD & Median & Hi$-$Lo \\\\",
  "  \\midrule"
)
groups <- list(
  "Balance sheet"     = c("total_assets", "equity_assets", "cecl_equity"),
  "Loan quality"      = c("npl_loans", "acl_loans", "cre_loans_share"),
  "Deposit structure" = c("unins_time_deps_assets", "ins_time_deps_assets", "unins_dep_share"),
  "Performance"       = c("int_expense_assets", "roa")
)
for (grp_name in names(groups)) {
  tex_lines <- c(tex_lines, sprintf("  \\emph{%s} & & & & & & & & & & \\\\", grp_name))
  for (v in groups[[grp_name]]) {
    i <- which(sumstat_vars == v)
    tex_lines <- c(tex_lines, sprintf(
      "  \\hspace{1em}%s & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %s \\\\",
      var_labels[v],
      tab_full$Mean[i], tab_full$SD[i], tab_full$Median[i],
      tab_high$Mean[i], tab_high$SD[i], tab_high$Median[i],
      tab_low$Mean[i],  tab_low$SD[i],  tab_low$Median[i],
      diff_col$Diff[i]))
  }
  tex_lines <- c(tex_lines, "  \\midrule")
}
tex_lines <- c(tex_lines,
  "  \\midrule",
  "  \\multicolumn{11}{l}{\\emph{Cross-section at each bank's CECL adoption quarter. Total assets in \\$M.}} \\\\",
  sprintf("  \\multicolumn{11}{l}{\\emph{Winsorized at 1st/99th percentile by quarter. High CECL $\\geq$ %.1f\\%% of pre-adoption equity.}} \\\\",
          CECL_THRESHOLD_PCT),
  "  \\multicolumn{11}{l}{\\emph{Hi$-$Lo: mean difference. Significance: $^{***}$0.01, $^{**}$0.05, $^{*}$0.10 (two-sample $t$-test).}} \\\\",
  "\\end{tabular}", "\\par\\endgroup")
if (isTRUE(save_tables)) {
  tbl1_path <- file.path(TRACK_TBL, paste0("tab01_sumstats_", dat_suffix, ".tex"))
  writeLines(tex_lines, tbl1_path)
  cat("Table 1 saved:", tbl1_path, "\n")
}

# -----------------------------------------------------------------------------
# Figure 1: distribution of the Day-One adjustment
# -----------------------------------------------------------------------------
fig1 <- ggplot(cs[!is.na(cecl_equity)], aes(x = cecl_equity)) +
  geom_histogram(bins = 40, fill = primary_blue, alpha = 0.75, color = "white") +
  geom_vline(xintercept = CECL_THRESHOLD_PCT, color = "darkred",
             linewidth = 0.9, linetype = "dashed") +
  annotate("text", x = CECL_THRESHOLD_PCT + 0.15, y = Inf,
           label = paste0("High-CECL\nthreshold (", CECL_THRESHOLD_PCT, "%)"),
           color = "darkred", hjust = 0, vjust = 1.5, size = 3.0) +
  theme_custom() +
  labs(x = "CECL Day-One Adjustment / Pre-Adoption Equity (%)",
       y = "Number of Banks")
print(fig1)
save_track_fig(fig1, "fig01_cecl_dist", width = 5, height = 3)

# -----------------------------------------------------------------------------
# Figure 2: adoption-quarter distribution
# -----------------------------------------------------------------------------
adopt_counts <- unique(panel[, .(ID_RSSD, adopt_dt)])[, .N, by = adopt_dt][order(adopt_dt)]
adopt_counts[, label := paste0(year(adopt_dt), "Q", quarter(adopt_dt))]
adopt_counts[, primary := label == "2023Q1"]
fig2 <- ggplot(adopt_counts, aes(x = label, y = N, fill = primary)) +
  geom_col(alpha = 0.85, width = 0.7) +
  geom_text(aes(label = N), vjust = -0.4, size = 3.2, color = "grey30") +
  scale_fill_manual(values = c("FALSE" = primary_blue, "TRUE" = negative_red), guide = "none") +
  annotate("text", x = "2023Q1", y = max(adopt_counts$N) * 0.55,
           label = "Primary\nrollout", color = negative_red, size = 2.8, hjust = 0.5) +
  theme_custom() +
  labs(x = "Adoption Quarter", y = "Number of Banks")
print(fig2)
save_track_fig(fig2, "fig02_adoption_dist", width = 5, height = 3)

# -----------------------------------------------------------------------------
# Table 2 (expanded): CECL predictors, 2022Q4 cross-section (= first stage for
# cecl_resid; predictor lists single-sourced in _track_common.R)
# -----------------------------------------------------------------------------
cs_fs <- panel[D_DT == as.Date("2022-12-31")]

rhs_sets <- list(
  CECL_PREDICTORS_BASE,                       # (1) original-style predictors
  CECL_PREDICTORS_EXPANDED,                   # (2) + deposit mix + trends (first stage)
  c(CECL_PREDICTORS_EXPANDED, "dep_hhi_county")  # (3) + local market structure
)
fml2 <- function(rhs) as.formula(paste("cecl_equity ~", paste(rhs, collapse = " + ")))
models2 <- lapply(rhs_sets, function(rhs) feols(fml2(rhs), data = cs_fs, vcov = "hetero"))

print(etable(models2, dict = covariate_labels_dict))
export_track_tbl(
  models2, "tab02_cecl_predictors", covariate_labels_dict,
  notes = paste("Cross-section at 2022Q4 (pre-adoption). Column (2) is the first stage",
                "for the residualized treatment. ROA and NPL trends are bank-level",
                "8-quarter slope coefficients (2021Q1--2022Q4). County deposit HHI is the",
                "bank's 2022 deposit-weighted average county HHI (0--100 scale).")
)

# -----------------------------------------------------------------------------
# Diagnostics
# -----------------------------------------------------------------------------
cat("\n=============== DIAGNOSTICS: descriptive_stats ===============\n")
cat(sprintf("Adoption cross-section: %d banks | 2022Q4 first-stage rows: %d\n",
            nrow(cs), nrow(cs_fs)))
for (i in seq_along(models2)) {
  cat(sprintf("  Table 2 col (%d): N=%d  AdjR2=%.4f\n", i,
              models2[[i]]$nobs, fitstat(models2[[i]], "ar2")$ar2))
}
cat(sprintf("dep_hhi_county: NA banks=%d p50=%.1f\n",
            sum(is.na(cs_fs$dep_hhi_county)), median(cs_fs$dep_hhi_county, na.rm = TRUE)))
cat("===============================================================\n")
