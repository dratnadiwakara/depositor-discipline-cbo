# =============================================================================
# _common.R — Shared utilities for cc_paper_v1 analysis pipeline
#
# Sources: library loads, constants, helpers, ggplot theme, fixest formulas.
# All scripts in code/cc_paper_v1/ source this file first.
# =============================================================================

library(data.table)
library(ggplot2)
library(fixest)
library(here)
library(stringr)

# -----------------------------------------------------------------------------
# GLOBAL CONSTANTS
# -----------------------------------------------------------------------------

# Primary treatment threshold: high_cecl_equity = 1 if cecl_equity >= 2%
CECL_THRESHOLD_PCT <- 2.5

# 90% confidence intervals throughout (z = 1.645)
CI_Z <- 1.645

# Output directories
TBLDIR <- here::here("docs", "tables")
FIGDIR <- here::here("docs", "figures")

# Global export toggles (set TRUE here when running analyses that should write outputs)
save_figures <- FALSE
save_tables <- FALSE

# -----------------------------------------------------------------------------
# COLOUR PALETTE
# -----------------------------------------------------------------------------
primary_blue   <- "#1f4e79"
primary_gold   <- "#c9a000"
negative_red   <- "#c0392b"
positive_green <- "#27ae60"
accent_gray    <- "#7f8c8d"

# -----------------------------------------------------------------------------
# GGPLOT THEME
# -----------------------------------------------------------------------------
theme_custom <- function(base_size = 11) {
  theme_bw(base_size = base_size) %+replace%
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey92"),
      strip.background = element_rect(fill = "grey95", color = "grey80"),
      legend.position  = "bottom",
      legend.key.size  = unit(0.4, "cm"),
      plot.title       = element_text(face = "bold", size = rel(1.0)),
      plot.subtitle    = element_text(size = rel(0.85), color = accent_gray),
      axis.title       = element_text(size = rel(0.9))
    )
}

# -----------------------------------------------------------------------------
# HELPER FUNCTIONS
# -----------------------------------------------------------------------------

# Return path to most recently modified file in dir matching pattern
latest_clean_file <- function(pattern, dir = here::here("data", "clean")) {
  files <- list.files(dir, pattern = pattern, full.names = TRUE)
  if (length(files) == 0L)
    stop("No files matching '", pattern, "' in ", dir)
  files[which.max(file.mtime(files))]
}

# Compute integer quarter distance: date_vec relative to ref_date
# Positive = after ref_date, negative = before
compute_qtrs_since <- function(date_vec, ref_date) {
  date_vec <- as.Date(date_vec)
  ref_date <- as.Date(ref_date)
  yr   <- as.integer(format(date_vec, "%Y"))
  qtr  <- as.integer(ceiling(as.integer(format(date_vec, "%m")) / 3))
  yr_r <- as.integer(format(ref_date, "%Y"))
  qtr_r<- as.integer(ceiling(as.integer(format(ref_date, "%m")) / 3))
  (yr * 4L + qtr) - (yr_r * 4L + qtr_r)
}

# Winsorize a data.table column at p1/p99 within groups of date_var
winsorize_by_date <- function(dt, vars, date_var = "D_DT",
                               probs = c(0.01, 0.99)) {
  for (v in vars) {
    if (!v %in% names(dt)) next
    dt[, (v) := {
      q <- quantile(.SD[[v]], probs = probs, na.rm = TRUE)
      pmin(pmax(.SD[[v]], q[1L]), q[2L])
    }, by = date_var, .SDcols = v]
  }
  invisible(dt)
}

# -----------------------------------------------------------------------------
# EVENT STUDY DATA EXTRACTOR (90% CI)
# Returns a data.table with k, est, se, lo90, hi90
# -----------------------------------------------------------------------------
extract_es_data <- function(model, ref_k = -1L, event_var = "qtrs_since") {
  cf  <- coef(model)
  se  <- se(model)
  nms <- names(cf)

  idx <- grepl(paste0("^", event_var, "::"), nms)
  nms_ev <- nms[idx]
  cf_ev  <- cf[idx]
  se_ev  <- se[idx]

  k_vals <- as.integer(sub(paste0("^", event_var, "::(-?\\d+).*"), "\\1", nms_ev))
  keep <- !is.na(k_vals)
  k_vals <- k_vals[keep]
  cf_ev  <- cf_ev[keep]
  se_ev  <- se_ev[keep]

  k_all  <- sort(c(k_vals, ref_k))
  est_all <- c(cf_ev, 0)[match(k_all, c(k_vals, ref_k))]
  se_all  <- c(se_ev, 0)[match(k_all, c(k_vals, ref_k))]
  pd <- data.table(k = k_all, est = est_all, se = se_all)
  setorder(pd, k)
  pd[, lo90 := est - CI_Z * se]
  pd[, hi90 := est + CI_Z * se]
  pd[]
}

# Single-group event study plot (90% CI)
make_es_plot <- function(model, title_str, ylab_str,
                         col = primary_blue,
                         vline_label = "CECL Adoption",
                         event_var = "qtrs_since",
                         xlab_str = "Quarters Relative to CECL Adoption (k = 0)",
                         vline_x = -0.5) {
  pd <- extract_es_data(model, event_var = event_var)
  ggplot(pd, aes(x = k, y = est)) +
    geom_hline(yintercept = 0, color = accent_gray,
               linewidth = 0.4, linetype = "dashed") +
    geom_vline(xintercept = vline_x, color = "darkred",
               linewidth = 1, linetype = "dotted") +
    annotate("text", x = vline_x + 0.2, y = Inf,
             label = vline_label,
             color = accent_gray, vjust = 1.5, hjust = 0, size = 2.8) +
    geom_ribbon(aes(ymin = lo90, ymax = hi90), fill = col, alpha = 0.15) +
    geom_line(color = col, linewidth = 0.8) +
    geom_point(color = col, size = 2) +
    scale_x_continuous(breaks = seq(min(pd$k), max(pd$k), by = 2)) +
    theme_custom() +
    labs(title = title_str,
         x = xlab_str,
         y = ylab_str)
}

# Split event study plot for two groups (90% CI)
make_split_es_plot <- function(pd_list, group_names, colors, title_str,
                                ylab_str, vline_label = "CECL Adoption") {
  pd_all <- rbindlist(
    mapply(function(pd, nm) { pd[, group := nm]; pd },
           pd_list, group_names, SIMPLIFY = FALSE)
  )
  col_map  <- setNames(colors, group_names)
  fill_map <- col_map
  ggplot(pd_all, aes(x = k, y = est, color = group, fill = group)) +
    geom_hline(yintercept = 0, color = accent_gray,
               linewidth = 0.4, linetype = "dashed") +
    geom_vline(xintercept = -1, color = "darkred",
               linewidth = 1, linetype = "dotted") +
    annotate("text", x = -0.3, y = Inf, label = vline_label,
             color = accent_gray, vjust = 1.5, hjust = 0, size = 2.8) +
    geom_ribbon(aes(ymin = lo90, ymax = hi90), alpha = 0.12, color = NA) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 2.2) +
    scale_color_manual(values = col_map) +
    scale_fill_manual(values  = fill_map) +
    scale_x_continuous(breaks = seq(min(pd_all$k), max(pd_all$k), by = 2)) +
    theme_custom() +
    labs(title    = title_str,
         subtitle = "90% confidence intervals shaded. Reference period k = \u22121.",
         x = "Quarters Relative to CECL Adoption (k = 0)",
         y = ylab_str,
         color = NULL, fill = NULL)
}

# Save figure helper
save_fig <- function(fig, name, width = 8, height = 5) {
  dir.create(FIGDIR, showWarnings = FALSE, recursive = TRUE)
  path <- file.path(FIGDIR, paste0(name, ".pdf"))
  ggsave(path, fig, width = width, height = height, bg = "transparent")
  cat("Figure saved:", path, "\n")
  invisible(path)
}

# Save etable as .tex helper
save_tbl <- function(..., name, dict, order = NULL, title = NULL) {
  dir.create(TBLDIR, showWarnings = FALSE, recursive = TRUE)
  path <- file.path(TBLDIR, paste0(name, ".tex"))
  args <- list(...)
  etable(args[[1L]],
         dict  = dict,
         order = order,
         title = title,
         file  = path)
  cat("Table saved:", path, "\n")
  invisible(path)
}

# -----------------------------------------------------------------------------
# COVARIATE LABELS (for etable())
# -----------------------------------------------------------------------------
covariate_labels_dict <- c(
  "post"                                = "Post",
  "high_cecl_equity"                    = "High CECL",
  "post:high_cecl_equity"               = "Post x High CECL",
  "cecl_equity"                         = "CECL Adj",
  "post:cecl_equity"                    = "Post x CECL Adj",
  "phase_in"                            = "Phase-In Elected",
  "post:phase_in"                       = "Post $\\times$ Phase-In",
  "high_cecl_equity:phase_in"           = "High CECL $\\times$ Phase-In",
  "post:high_cecl_equity:phase_in"      = "Post $\\times$ High CECL $\\times$ Phase-In",
  "log(total_assets)"                   = "log(Assets)",
  "log_total_assets_l1"                 = "log(Assets), $t{-}1$",
  "equity_assets"                       = "Equity/Assets (\\%)",
  "equity_assets_l1"                    = "Equity/Assets (\\%), $t{-}1$",
  "nim"                                 = "NIM/Assets (\\%)",
  "nim_l1"                              = "NIM/Assets (\\%), $t{-}1$",
  "leverage_ratio"                      = "Leverage Ratio (\\%)",
  "loans_assets"                        = "Loans/Assets (\\%)",
  "nii_pct_of_assets"                   = "NII/Assets (\\%)",
  "int_expense_assets"  = "Int. Exp/Assets (\\%)",
  "int_expense_assets_l1" = "Int. Exp/Assets (\\%), $t{-}1$",
  "dep_assets" = "Deposits/Assets (\\%)",
  "ins_time_deps_assets" = "Ins. Time Dep./Assets (\\%)",
  "unins_time_deps_assets" = "Unins. Time Dep./Assets (\\%)",
  "roa" = "ROA (\\%)",
  # "post_factor1" = "One year after",
  # "post_factor2" = "Two years after",
  # "post_factor3" = "Three years after",
  # "post_factor1:cecl_equity" = "CECL Adj x One year after",
  # "post_factor2:cecl_equity" = "CECL Adj x Two years after",
  # "post_factor3:cecl_equity" = "CECL Adj x Three years after",
  # "post_factor1:high_cecl_equity" = "High CECL x One year after",
  # "post_factor2:high_cecl_equity" = "High CECL x Two years after",
  # "post_factor3:high_cecl_equity" = "High CECL x Three years after",
  "ID_RSSD" = "Bank",
  "D_DT" = "Quarter"
)

# -----------------------------------------------------------------------------
# FIXEST FORMULA SHORTCUTS
# (sourced once; available globally after source(_common.R))
# -----------------------------------------------------------------------------
setFixest_etable(
  fitstat = ~ n + ar2,
  signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  se.below = TRUE
)

cat("[_common.R] Loaded. Threshold =", CECL_THRESHOLD_PCT, "%. CI z =", CI_Z, "\n")
