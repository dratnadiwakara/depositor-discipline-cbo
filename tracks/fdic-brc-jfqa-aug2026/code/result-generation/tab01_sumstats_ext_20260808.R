# =============================================================================
# tab01_sumstats_ext_20260808.R — Table 1 regenerated with brokered and
# reciprocal deposit rows (PDF comment round, 2026-08-08).
# Port of the Table-1 block of tracks/post-jmcb-rejection-june2026/
# code/result-generation/descriptive_stats_20260612.R; only change: three
# added rows in the Deposit structure group (total brokered, insured
# brokered, reciprocal, each / assets). Figures and Table 2 not regenerated.
# Input: panel_smallbank (post-jmcb 20260612 vintage via fallback).
# Output: latex/tables/tab01_sumstats_<stamp>.tex
# =============================================================================

rm(list = ls())

library(data.table)
library(here)

source(here::here("code", "_common.R"))
source(here::here("tracks", "fdic-brc-jfqa-aug2026", "code", "_track_common.R"))

save_tables <- TRUE
dat_suffix <- format(Sys.time(), "%Y%m%d")

panel <- readRDS(latest_track_file("panel_smallbank"))
setDT(panel)

cs <- panel[D_DT == adopt_dt]
cs2 <- copy(cs)
cs2[, total_assets := total_assets / 1000]  # $M

sumstat_vars <- c(
  "total_assets", "equity_assets", "cecl_equity",
  "npl_loans", "acl_loans", "cre_loans_share",
  "unins_time_deps_assets", "ins_time_deps_assets", "unins_dep_share",
  "brokered_assets", "brokered_ins_assets", "reciprocal_assets",
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
  brokered_assets        = "Brokered Deps / Assets (\\%)",
  brokered_ins_assets    = "Ins.\\ Brokered Deps / Assets (\\%)",
  reciprocal_assets      = "Reciprocal Deps / Assets (\\%)",
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
  "Deposit structure" = c("unins_time_deps_assets", "ins_time_deps_assets", "unins_dep_share",
                          "brokered_assets", "brokered_ins_assets", "reciprocal_assets"),
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

cat("\n=============== DIAGNOSTICS ===============\n")
cat("Time deposits / assets, full-sample means: unins",
    tab_full$Mean[7], "+ ins", tab_full$Mean[8], "=",
    round(tab_full$Mean[7] + tab_full$Mean[8], 2), "\n")
