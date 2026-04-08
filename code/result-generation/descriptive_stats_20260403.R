## -----------------------------------------------------------------------------
rm(list = ls())

library(data.table)
library(fixest)
library(ggplot2)
library(here)
library(lubridate)
library(stringr)

source(here::here("code", "_common.R"))

dat_suffix <- "20260403"
tbl_dir    <- here::here("docs", "tables")
fig_dir    <- here::here("docs", "figures")

dir.create(tbl_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

## -----------------------------------------------------------------------------
raw_dir <- here::here("data", "raw")

dt1 <- readRDS(file.path(raw_dir, "call_report_data_20260401_1.rds"))
dt2 <- readRDS(file.path(raw_dir, "call_report_data_20260401_2.rds"))
setDT(dt1); setDT(dt2)
dt <- rbind(dt1, dt2, fill = TRUE)
rm(dt1, dt2); gc()

dt[, D_DT      := as.Date(D_DT)]
dt[, cal_year  := as.integer(format(D_DT, "%Y"))]
dt[, quarter_no := lubridate::quarter(D_DT)]
dt <- unique(dt, by = c("ID_RSSD", "D_DT"))
setorder(dt, ID_RSSD, D_DT)

# De-cumulate YTD flows to quarterly
ytd_vars <- intersect(
  c("interest_expense", "interest_income", "net_interest_income",
    "net_income", "nonint_expense", "nonint_income"),
  names(dt)
)
for (v in ytd_vars) {
  nv <- paste0(v, "_q")
  dt[, (nv) := fifelse(quarter_no == 1L, get(v), get(v) - shift(get(v), 1L)),
     by = .(ID_RSSD, cal_year)]
  dt[quarter_no > 1L & is.na(shift(get(v), 1L)), (nv) := NA, by = .(ID_RSSD, cal_year)]
}

# Ratio variables (guard every optional column)
dt[total_assets > 0, equity_assets      := equity_bop / total_assets * 100]
dt[total_assets > 0, int_expense_assets := interest_expense_q / total_assets * 100]
dt[total_assets > 0, roa                := net_income_q / total_assets * 100]
dt[total_assets > 0, nim                := net_interest_income_q / total_assets * 100]
dt[, cecl_equity := fifelse(
  !is.na(CECL) & !is.na(equity_bop) & equity_bop > 0,
  CECL / equity_bop * 100, NA_real_
)]
if (all(c("nonaccrual_loans", "past_due_90plus", "total_loans") %in% names(dt)))
  dt[total_loans > 0, npl_ratio := (nonaccrual_loans + past_due_90plus) / total_loans * 100]
if (all(c("acl_eop", "total_loans") %in% names(dt)))
  dt[total_loans > 0, allowance_ratio := acl_eop / total_loans * 100]
if (all(c("cre_owner_occ", "cre_other", "total_loans") %in% names(dt)))
  dt[total_loans > 0, cre_share := (cre_owner_occ + cre_other) / total_loans * 100]
if (all(c("ci_loans", "total_loans") %in% names(dt)))
  dt[total_loans > 0, ci_share := ci_loans / total_loans * 100]
if (all(c("unins_deps_excl_ret", "total_deposits") %in% names(dt)))
  dt[total_deposits > 0, unins_deps_pct := unins_deps_excl_ret / total_deposits * 100]
if (all(c("unrealized_loss_afs_reg", "unrealized_loss_htm_reg", "equity_bop") %in% names(dt)))
  dt[equity_bop > 0, unreal_loss_equity :=
       (unrealized_loss_afs_reg + unrealized_loss_htm_reg) / equity_bop * 100]
if ("unins_time_deps" %in% names(dt))
  dt[total_assets > 0, unins_time_assets := unins_time_deps / total_assets * 100]
if ("ins_time_deps" %in% names(dt))
  dt[total_assets > 0, ins_time_assets := ins_time_deps / total_assets * 100]

# Winsorise
wvars <- intersect(
  c("equity_assets", "int_expense_assets", "roa", "nim", "cecl_equity",
    "npl_ratio", "allowance_ratio", "cre_share", "ci_share",
    "unins_deps_pct", "unreal_loss_equity",
    "unins_time_assets", "ins_time_assets"),
  names(dt)
)
winsorize_by_date(dt, vars = wvars, date_var = "D_DT", probs = c(0.01, 0.99))

# Community bank universe: assets < $10B at 2022Q4
comm_ids <- unique(dt[D_DT == "2022-12-31" & total_assets < 10e6, ID_RSSD])
dt_cb <- dt[ID_RSSD %in% comm_ids]

# Adoption quarter
adopt_quarters <- as.Date(c(
  "2022-09-30", "2022-12-31", "2023-03-31",
  "2023-06-30", "2023-09-30", "2023-12-31"
))
adopt_map <- dt_cb[D_DT %in% adopt_quarters & !is.na(cecl_equity),
                   .(adopt_dt = min(D_DT)), by = ID_RSSD]
dt_cb <- merge(dt_cb, adopt_map, by = "ID_RSSD")

# Cross-section at adoption quarter
cs <- dt_cb[D_DT == adopt_dt]
if (nrow(cs) == 0L) {
  stop("No observations found at adoption quarter; cannot build descriptive outputs.")
}

cs[, high_cecl := as.integer(cecl_equity >= quantile(cs$cecl_equity, 0.90, na.rm = TRUE))]

cat(sprintf(
  "Community bank cross-section: %d banks  |  High CECL (>=%.1f%%): %d (%.1f%%)  |  Low CECL: %d\n",
  nrow(cs), CECL_THRESHOLD_PCT,
  sum(cs$high_cecl == 1L, na.rm = TRUE),
  mean(cs$high_cecl == 1L, na.rm = TRUE) * 100,
  sum(cs$high_cecl == 0L, na.rm = TRUE)
))
cat("Adoption quarter breakdown:\n")
print(cs[, .N, by = .(quarter = paste0(year(adopt_dt), "Q", quarter(adopt_dt)))][order(quarter)])


## -----------------------------------------------------------------------------
# Variables in display order
sumstat_vars <- c(
  "total_assets",
  "equity_assets",
  "cecl_equity",
  if ("npl_ratio"       %in% names(cs)) "npl_ratio",
  if ("allowance_ratio" %in% names(cs)) "allowance_ratio",
  if ("cre_share"       %in% names(cs)) "cre_share",
  if ("unins_time_assets" %in% names(cs)) "unins_time_assets",
  if ("ins_time_assets"   %in% names(cs)) "ins_time_assets",
  if ("unins_deps_pct"  %in% names(cs)) "unins_deps_pct",
  if ("int_expense_assets" %in% names(cs)) "int_expense_assets",
  if ("roa"                %in% names(cs)) "roa"
)
sumstat_vars <- unique(Filter(Negate(is.null), sumstat_vars))

var_labels <- c(
  total_assets       = "Total Assets (\\$M)",
  equity_assets      = "Equity / Assets (\\%)",
  cecl_equity        = "CECL Adj.\\ / Equity (\\%)",
  npl_ratio          = "NPL / Loans (\\%)",
  allowance_ratio    = "Allowance / Loans (\\%)",
  cre_share          = "CRE / Loans (\\%)",
  unins_time_assets  = "Unins.\\ Time Deps / Assets (\\%)",
  ins_time_assets    = "Ins.\\ Time Deps / Assets (\\%)",
  unins_deps_pct     = "Unins.\\ Deps / Total Deps (\\%)",
  int_expense_assets = "Int.\\ Expense / Assets (\\%)",
  roa                = "ROA (\\%)"
)

# Helper: mean/sd/median for one variable × one subset
stat_row <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0L) return(c(N = 0L, Mean = NA, SD = NA, Median = NA))
  c(N = length(x),
    Mean   = round(mean(x),   3),
    SD     = round(sd(x),     3),
    Median = round(median(x), 3))
}

# Transform total_assets to $M for display
cs2 <- copy(cs)
cs2[, total_assets := total_assets / 1000]

build_col <- function(data, vars) {
  rbindlist(lapply(vars, function(v) {
    r <- stat_row(data[[v]])
    data.table(Variable = var_labels[v], N = r["N"],
               Mean = r["Mean"], SD = r["SD"], Median = r["Median"])
  }))
}

tab_full <- build_col(cs2, sumstat_vars)
tab_high <- build_col(cs2[high_cecl == 1L], sumstat_vars)
tab_low  <- build_col(cs2[high_cecl == 0L], sumstat_vars)

# Difference column with significance stars
diff_col <- rbindlist(lapply(sumstat_vars, function(v) {
  hi <- cs2[high_cecl == 1L, get(v)]; hi <- hi[!is.na(hi)]
  lo <- cs2[high_cecl == 0L, get(v)]; lo <- lo[!is.na(lo)]
  if (length(hi) < 2L || length(lo) < 2L)
    return(data.table(Variable = var_labels[v], Diff = NA_character_))
  tt  <- t.test(hi, lo, var.equal = FALSE)
  dif <- round(mean(hi) - mean(lo), 3)
  stars <- ifelse(tt$p.value < 0.01, "***",
           ifelse(tt$p.value < 0.05, "**",
           ifelse(tt$p.value < 0.10, "*", "")))
  data.table(Variable = var_labels[v],
             Diff = paste0(format(dif, nsmall = 3), stars))
}))

# Print to screen
cat(sprintf("\n%-35s  %8s %8s %8s    %8s %8s %8s    %8s %8s %8s    %12s\n",
            "Variable", "N", "Mean", "Median",
            "N", "Mean", "Median",
            "N", "Mean", "Median", "Hi-Lo Diff"))
cat(sprintf("%-35s  %s    %s    %s    %s\n",
            "", "---Full Sample---", "---High CECL---", "---Low CECL---", "Difference"))
for (i in seq_len(nrow(tab_full))) {
  cat(sprintf("%-35s  %8d %8.3f %8.3f    %8d %8.3f %8.3f    %8d %8.3f %8.3f    %12s\n",
              tab_full$Variable[i],
              tab_full$N[i],      tab_full$Mean[i],   tab_full$Median[i],
              tab_high$N[i],      tab_high$Mean[i],   tab_high$Median[i],
              tab_low$N[i],       tab_low$Mean[i],    tab_low$Median[i],
              diff_col$Diff[i]))
}


## -----------------------------------------------------------------------------
# ── Export Table 1 as LaTeX ───────────────────────────────────────────────────
n_full <- nrow(cs2)
n_high <- sum(cs2$high_cecl == 1L, na.rm = TRUE)
n_low  <- sum(cs2$high_cecl == 0L, na.rm = TRUE)

tex_lines <- c(
  "\\begingroup",
  "\\centering",
  "\\begin{tabular}{lrrr rrr rrr r}",
  "  \\tabularnewline \\midrule \\midrule",
  sprintf("  & \\multicolumn{3}{c}{Full Sample ($N=%d$)} & \\multicolumn{3}{c}{High CECL ($N=%d$)} & \\multicolumn{3}{c}{Low CECL ($N=%d$)} & \\\\",
          n_full, n_high, n_low),
  "  \\cmidrule(lr){2-4}\\cmidrule(lr){5-7}\\cmidrule(lr){8-10}",
  "  Variable & Mean & SD & Median & Mean & SD & Median & Mean & SD & Median & Hi$-$Lo \\\\",
  "  \\midrule"
)

# Variable groups for midrules
groups <- list(
  "Balance sheet"   = c("total_assets", "equity_assets", "cecl_equity"),
  "Loan quality"    = c("npl_ratio", "allowance_ratio", "cre_share"),
  "Deposit structure" = c("unins_time_assets", "ins_time_assets", "unins_deps_pct"),
  "Performance"     = c("int_expense_assets", "roa")
)

for (grp_name in names(groups)) {
  tex_lines <- c(tex_lines,
    sprintf("  \\emph{%s} & & & & & & & & & & \\\\", grp_name))
  for (v in groups[[grp_name]]) {
    if (!v %in% sumstat_vars) next
    i   <- which(sumstat_vars == v)
    lbl <- var_labels[v]
    tex_lines <- c(tex_lines, sprintf(
      "  \\hspace{1em}%s & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f & %s \\\\",
      lbl,
      tab_full$Mean[i], tab_full$SD[i],   tab_full$Median[i],
      tab_high$Mean[i], tab_high$SD[i],   tab_high$Median[i],
      tab_low$Mean[i],  tab_low$SD[i],    tab_low$Median[i],
      diff_col$Diff[i]
    ))
  }
  tex_lines <- c(tex_lines, "  \\midrule")
}

tex_lines <- c(tex_lines,
  "  \\midrule",
  "  \\multicolumn{11}{l}{\\emph{Cross-section at each bank's CECL adoption quarter. Total assets in \\$M.}} \\\\",
  sprintf(
    "  \\multicolumn{11}{l}{\\emph{Winsorized at 1st/99th percentile by quarter. High CECL $\\geq$ %.1f\\%% of pre-adoption equity.}} \\\\",
    CECL_THRESHOLD_PCT
  ),
  "  \\multicolumn{11}{l}{\\emph{Hi$-$Lo: mean difference. Significance: $^{***}$0.01, $^{**}$0.05, $^{*}$0.10 (two-sample $t$-test).}} \\\\",
  "\\end{tabular}",
  "\\par\\endgroup"
)

tbl1_path <- file.path(tbl_dir, paste0("tab01_sumstats_", dat_suffix, ".tex"))
writeLines(tex_lines, tbl1_path)
cat("Table 1 saved:", tbl1_path, "\n")


## -----------------------------------------------------------------------------
fig1 <- ggplot(cs[!is.na(cecl_equity)], aes(x = cecl_equity)) +
  geom_histogram(bins = 40, fill = primary_blue, alpha = 0.75, color = "white") +
  geom_vline(xintercept = CECL_THRESHOLD_PCT, color = "darkred",
             linewidth = 0.9, linetype = "dashed") +
  annotate("text",
           x = CECL_THRESHOLD_PCT + 0.15, y = Inf,
           label = paste0("High-CECL\nthreshold (", CECL_THRESHOLD_PCT, "%)"),
           color = "darkred", hjust = 0, vjust = 1.5, size = 3.0) +
  theme_custom() +
  labs(x = "CECL Day-One Adjustment / Pre-Adoption Equity (%)",
       y = "Number of Banks")

print(fig1)

fig1_path <- file.path(fig_dir, paste0("fig01_cecl_dist_", dat_suffix, ".png"))
ggsave(fig1_path, fig1, width = 5, height = 3, bg = "transparent")
cat("Figure 1 saved:", fig1_path, "\n")


## -----------------------------------------------------------------------------
cs_ols <- copy(cs)
cs_ols[, log_ta := log(total_assets)]

# Build regressor sets from what actually exists
base_vars  <- intersect(c("log_ta", "equity_assets"), names(cs_ols))
loan_vars  <- intersect(c("npl_ratio", "cre_share", "ci_share"), names(cs_ols))
extra_vars <- intersect(c("allowance_ratio", "unreal_loss_equity"), names(cs_ols))

if (length(base_vars) == 0L) {
  stop("No baseline regressors available for CECL predictor models.")
}

fml <- function(rhs) as.formula(paste("cecl_equity ~", paste(rhs, collapse = " + ")))

# Deduplicate RHS when optional blocks are empty (avoids identical columns in etable)
rhs_candidates <- list(
  base_vars,
  unique(c(base_vars, loan_vars)),
  unique(c(base_vars, loan_vars, extra_vars))
)
rhs_key <- function(x) paste(sort(unique(x)), collapse = "|")
seen_rhs <- character()
model_rhs <- list()
for (x in rhs_candidates) {
  if (length(x) == 0L) next
  k <- rhs_key(x)
  if (k %in% seen_rhs) next
  seen_rhs <- c(seen_rhs, k)
  model_rhs <- c(model_rhs, list(x))
}
models <- lapply(model_rhs, function(rhs) feols(fml(rhs), data = cs_ols, vcov = "HC1"))

dict_ols <- c(
  "log_ta"            = "log(Assets)",
  "equity_assets"     = "Equity / Assets (\\%)",
  "npl_ratio"         = "NPL / Loans (\\%)",
  "cre_share"         = "CRE / Loans (\\%)",
  "ci_share"          = "C\\&I / Loans (\\%)",
  "allowance_ratio"   = "Allowance / Loans (\\%)",
  "unreal_loss_equity"= "Unrealized Losses / Equity (\\%)"
)

etable(models, dict = dict_ols,
       title = "CECL Adj./Equity: Cross-Sectional Predictors")

tbl2_path <- file.path(tbl_dir, paste0("tab02_cecl_predictors_", dat_suffix, ".tex"))
etable(models, dict = dict_ols, tex = TRUE, file = tbl2_path, replace = TRUE)
cat("Table 2 saved:", tbl2_path, "\n")


## -----------------------------------------------------------------------------
adopt_counts <- adopt_map[, .N, by = adopt_dt][order(adopt_dt)]
if (nrow(adopt_counts) == 0L) {
  stop("No adoption-quarter counts available; cannot build Figure 2.")
}
adopt_counts[, label := paste0(year(adopt_dt), "Q", quarter(adopt_dt))]
adopt_counts[, primary := label == "2023Q1"]

fig2 <- ggplot(adopt_counts, aes(x = label, y = N, fill = primary)) +
  geom_col(alpha = 0.85, width = 0.7) +
  geom_text(aes(label = N), vjust = -0.4, size = 3.2, color = "grey30") +
  scale_fill_manual(values = c("FALSE" = primary_blue, "TRUE" = negative_red),
                    guide  = "none") +
  annotate("text", x = "2023Q1", y = max(adopt_counts$N) * 0.55,
           label = "Primary\nrollout", color = negative_red,
           size = 2.8, hjust = 0.5) +
  theme_custom() +
  labs(x = "Adoption Quarter", y = "Number of Banks")

print(fig2)

fig2_path <- file.path(fig_dir, paste0("fig02_adoption_dist_", dat_suffix, ".png"))
ggsave(fig2_path, fig2, width = 5, height = 3, bg = "transparent")
cat("Figure 2 saved:", fig2_path, "\n")

cat("\n=== DONE ===\n")
cat("All outputs:\n")
cat("  ", normalizePath(tbl1_path, winslash = "/", mustWork = FALSE), "\n")
cat("  ", normalizePath(fig1_path, winslash = "/", mustWork = FALSE), "\n")
cat("  ", normalizePath(tbl2_path, winslash = "/", mustWork = FALSE), "\n")
cat("  ", normalizePath(fig2_path, winslash = "/", mustWork = FALSE), "\n")


