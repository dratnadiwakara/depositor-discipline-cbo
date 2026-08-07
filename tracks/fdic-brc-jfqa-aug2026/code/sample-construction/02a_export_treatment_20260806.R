# =============================================================================
# 02a_export_treatment_20260806.R — Export bank-level treatment file for the
# RateWatch merge, and merge the CECL transition election (RCOAJJ29) from raw.
#
# Output: tracks/fdic-brc-jfqa-aug2026/data/bank_treatment_YYYYMMDD.csv
#   ID_RSSD, adopt_qtr, cecl_equity, high_cecl_equity, cecl_transition_election
# Consumed by: 02b_pull_ratewatch_20260806.py and anticipation_20260806.qmd
# =============================================================================
rm(list = ls())

library(data.table)
library(here)

source(here::here("code", "_common.R"))
source(here::here("tracks", "fdic-brc-jfqa-aug2026", "code", "_track_common.R"))

dat_suffix <- format(Sys.time(), "%Y%m%d")

panel <- readRDS(latest_track_file("panel_smallbank"))
setDT(panel)

bank <- panel[!is.na(cecl_equity) & qtrs_since == 0,
              .(ID_RSSD, adopt_qtr = as.Date(D_DT), cecl_equity, high_cecl_equity)]
bank <- unique(bank, by = "ID_RSSD")

# Election from raw (RCOAJJ29: 0 = no, 1 = 3-year, 2 = 5-year), at adoption qtr
# (panel's own cecl_transition_election column is all-NA; raw is populated).
raw <- rbind(
  readRDS(here::here("data", "raw", "call_report_data_20260401_1.rds")),
  readRDS(here::here("data", "raw", "call_report_data_20260401_2.rds")),
  fill = TRUE
)
setDT(raw)
raw[, D_DT := as.Date(D_DT)]
el <- raw[!is.na(cecl_transition_election),
          .(ID_RSSD, D_DT, cecl_transition_election)]
bank[el, on = c("ID_RSSD", adopt_qtr = "D_DT"),
     cecl_transition_election := i.cecl_transition_election]

out_path <- file.path(TRACK_DATA, paste0("bank_treatment_", dat_suffix, ".csv"))
fwrite(bank, out_path)

cat("\n================ bank_treatment DIAGNOSTICS ================\n")
cat("Rows:", nrow(bank), "| unique banks:", uniqueN(bank$ID_RSSD), "\n")
cat("Adoption span:", format(min(bank$adopt_qtr)), "to", format(max(bank$adopt_qtr)), "\n")
cat("NA: cecl_equity", sum(is.na(bank$cecl_equity)),
    "| election", sum(is.na(bank$cecl_transition_election)), "\n")
cat("Election distribution:\n")
print(bank[, table(cecl_transition_election, useNA = "ifany")])
cat("Election rate by High CECL:\n")
print(bank[, .(share_elect = mean(cecl_transition_election %in% c(1, 2), na.rm = TRUE),
               .N), by = high_cecl_equity])
qs <- function(x) round(quantile(x, c(.01, .5, .99), na.rm = TRUE), 3)
cat("cecl_equity p1/p50/p99:", qs(bank$cecl_equity), "\n")
cat("Wrote:", out_path, "\n")
