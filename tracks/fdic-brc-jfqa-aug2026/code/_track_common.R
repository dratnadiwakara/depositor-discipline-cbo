# =============================================================================
# _track_common.R — fdic-brc-jfqa-aug2026 track additions
# Source AFTER code/_common.R.
# Outputs (figures/tables/data) go to this track. Input datasets not yet
# rebuilt here (panel_smallbank, sophistication, spillover, reciprocal) are
# resolved by fallback to the post-jmcb-rejection-june2026 track, which holds
# the 20260612 vintage this revision starts from.
# =============================================================================

TRACK_DIR <- here::here("tracks", "fdic-brc-jfqa-aug2026")
TRACK_DATA <- file.path(TRACK_DIR, "data")
TRACK_FIG <- file.path(TRACK_DIR, "latex", "figures")
TRACK_TBL <- file.path(TRACK_DIR, "latex", "tables")
SOURCE_TRACK_DATA <- here::here("tracks", "post-jmcb-rejection-june2026", "data")

dir.create(TRACK_DATA, showWarnings = FALSE, recursive = TRUE)
dir.create(TRACK_FIG, showWarnings = FALSE, recursive = TRUE)
dir.create(TRACK_TBL, showWarnings = FALSE, recursive = TRUE)

# Latest stamped file; searches this track's data dir first, then the source
# track (so unmodified upstream datasets need not be copied).
latest_track_file <- function(stub, dir = TRACK_DATA) {
  files <- list.files(dir, pattern = paste0("^", stub, "_\\d{8}\\.rds$"), full.names = TRUE)
  if (length(files) == 0L && identical(dir, TRACK_DATA)) {
    files <- list.files(SOURCE_TRACK_DATA, pattern = paste0("^", stub, "_\\d{8}\\.rds$"),
                        full.names = TRUE)
  }
  if (length(files) == 0L) stop("No files matching '", stub, "' in ", dir,
                                " or ", SOURCE_TRACK_DATA)
  files[which.max(file.mtime(files))]
}

# Track-local figure/table export (timestamped, white bg per project standard)
save_track_fig <- function(plot, stub, stamp = format(Sys.time(), "%Y%m%d"),
                           width = 4, height = 2.5) {
  if (!isTRUE(save_figures)) return(invisible(NULL))
  ggsave(
    filename = file.path(TRACK_FIG, paste0(stub, "_", stamp, ".png")),
    plot = plot, width = width, height = height, bg = "white"
  )
}

export_track_tbl <- function(models, stub, dict, order = NULL,
                             stamp = format(Sys.time(), "%Y%m%d"), ...) {
  if (!isTRUE(save_tables)) return(invisible(NULL))
  args <- list(
    models, dict = dict, tex = TRUE,
    file = file.path(TRACK_TBL, paste0(stub, "_", stamp, ".tex")),
    replace = TRUE, ...
  )
  if (!is.null(order)) args$order <- order
  do.call(etable, args)
  invisible(NULL)
}

# -----------------------------------------------------------------------------
# Single source for the CECL-predictor list (expanded Table 2 = first stage for
# cecl_resid). Used by descriptive_stats and 01_build_panel.
# -----------------------------------------------------------------------------
CECL_PREDICTORS_BASE <- c(
  "log_total_assets", "equity_assets", "npl_loans", "cre_loans_share",
  "unreal_loss_assets"
)
CECL_PREDICTORS_EXPANDED <- c(
  CECL_PREDICTORS_BASE,
  "unins_dep_share", "time_dep_share", "brokered_share",
  "roa_trend_8q", "npl_trend_8q"
)

# 2022Q4 frozen characteristics for flexible char-x-time controls
CHARS_22Q4 <- c(
  "unins_dep_share_22q4", "log_ta_22q4", "equity_assets_22q4",
  "npl_loans_22q4", "roa_22q4", "cre_loans_share_22q4",
  "brokered_share_22q4", "unreal_loss_assets_22q4"
)

# -----------------------------------------------------------------------------
# Covariate labels: extend the shared dictionary
# -----------------------------------------------------------------------------
covariate_labels_dict <- c(
  covariate_labels_dict,
  "cecl_assets"                          = "CECL Adj (Assets)",
  "post:cecl_assets"                     = "Post x CECL Adj (Assets)",
  "high_cecl_assets"                     = "High CECL (Assets)",
  "post:high_cecl_assets"                = "Post x High CECL (Assets)",
  "cecl_loans"                           = "CECL Adj (Loans)",
  "post:cecl_loans"                      = "Post x CECL Adj (Loans)",
  "high_cecl_loans"                      = "High CECL (Loans)",
  "post:high_cecl_loans"                 = "Post x High CECL (Loans)",
  "cecl_resid"                           = "CECL Adj (Residual)",
  "post:cecl_resid"                      = "Post x CECL Adj (Residual)",
  "high_cecl_resid"                      = "High CECL (Residual)",
  "post:high_cecl_resid"                 = "Post x High CECL (Residual)",
  "post_early"                           = "Post (0--4 qtrs)",
  "post_late"                            = "Post ($\\geq$5 qtrs)",
  "high_sophistication"                  = "High Sophistication",
  "loan_growth"                          = "Loan Growth (\\%)",
  "ci_growth"                            = "C\\&I Loan Growth (\\%)",
  "cre_growth"                           = "CRE Loan Growth (\\%)",
  "brokered_assets"                      = "Brokered Dep./Assets (\\%)",
  "brokered_ins_assets"                  = "Ins. Brokered Dep./Assets (\\%)",
  "brokered_unins_lt1yr_assets"          = "Unins. Brokered Dep./Assets (\\%)",
  "reciprocal_assets"                    = "Reciprocal Dep./Assets (\\%)",
  "npl_loans"                            = "NPL/Loans (\\%)",
  "cre_loans_share"                      = "CRE/Loans (\\%)",
  "unreal_loss_assets"                   = "Unrealized Sec. Loss/Assets (\\%)",
  "unins_dep_share"                      = "Unins. Dep./Deposits (\\%)",
  "time_dep_share"                       = "Time Dep./Deposits (\\%)",
  "brokered_share"                       = "Brokered Dep./Deposits (\\%)",
  "roa_trend_8q"                         = "ROA Trend (8q)",
  "npl_trend_8q"                         = "NPL Trend (8q)",
  "log_total_assets"                     = "log(Assets)",
  "dep_hhi_county"                       = "County Deposit HHI",
  "expo_high_cecl"                       = "Exposure to High-CECL Competitors",
  "sod_dep_growth"                       = "SOD Deposit Growth (\\%)",
  "post_2023"                            = "Post-2023"
)

cat("[_track_common.R] Loaded. Track:", TRACK_DIR, "\n")
