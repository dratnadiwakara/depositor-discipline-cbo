# =============================================================================
# 01f_convert_fhlb_20260809.R — Convert the FHLB-advance CSV (from
# 01e_pull_fhlb_20260809.py) to rds and build the analysis items.
#
# Input : tracks/fdic-brc-jfqa-aug2026/data/fhlb_advances_20260809.csv
# Output: tracks/fdic-brc-jfqa-aug2026/data/fhlb_advances_20260809.rds
#         (ID_RSSD, D_DT, fhlb_total, fhlb_term, fhlb_short, oth_borrowings;
#          $ thousands)
#
# F055-F058 partition total advances by remaining maturity / next repricing
# date; term advances (rate-locked beyond one year) are F056+F057+F058.
# F059 (structured advances) is a memo subset and is deliberately not summed.
# =============================================================================

rm(list = ls())

library(data.table)
library(here)

csv_path <- here::here("tracks", "fdic-brc-jfqa-aug2026", "data",
                       "fhlb_advances_20260809.csv")
rds_path <- here::here("tracks", "fdic-brc-jfqa-aug2026", "data",
                       "fhlb_advances_20260809.rds")

x <- fread(csv_path, colClasses = list(character = c("ID_RSSD", "D_DT")))

items <- c("RCONF055", "RCONF056", "RCONF057", "RCONF058", "RCONF059",
           "RCON2651", "RCON3190")
x[, (items) := lapply(.SD, function(v) {
  z <- suppressWarnings(as.numeric(as.character(v)))
  fifelse(is.na(z), 0, z)
}), .SDcols = items]

# Dedup: 031 filers can appear in multiple schedule members per quarter
x <- x[, lapply(.SD, max), by = .(ID_RSSD, D_DT), .SDcols = items]

x[, `:=`(
  fhlb_total     = RCONF055 + RCONF056 + RCONF057 + RCONF058,
  fhlb_term      = RCONF056 + RCONF057 + RCONF058,
  fhlb_short     = RCONF055,
  oth_borrowings = RCON3190
)]
x[, ID_RSSD := as.integer(ID_RSSD)]
x[, D_DT := as.Date(D_DT)]
x <- x[, .(ID_RSSD, D_DT, fhlb_total, fhlb_term, fhlb_short, oth_borrowings)]

saveRDS(x, rds_path)

cat("\n=============== DIAGNOSTICS: FHLB advances rds ===============\n")
cat(sprintf("Rows: %d | Banks: %d | Quarters: %d (%s to %s)\n",
            nrow(x), uniqueN(x$ID_RSSD), uniqueN(x$D_DT),
            min(x$D_DT), max(x$D_DT)))
cat("NA counts:\n")
print(x[, lapply(.SD, function(v) sum(is.na(v))),
        .SDcols = c("fhlb_total", "fhlb_term", "fhlb_short", "oth_borrowings")])
cat(sprintf("Share with any advance: %.1f%% | any term advance: %.1f%%\n",
            100 * mean(x$fhlb_total > 0), 100 * mean(x$fhlb_term > 0)))
for (v in c("fhlb_total", "fhlb_term")) {
  q <- quantile(x[get(v) > 0, get(v)], c(0.01, 0.5, 0.99))
  cat(sprintf("%-12s ($000, positive only): p1=%.0f p50=%.0f p99=%.0f\n",
              v, q[1], q[2], q[3]))
}
cat("Term share of total advances (positive-total banks):",
    round(x[fhlb_total > 0, sum(fhlb_term) / sum(fhlb_total)], 3), "\n")
cat("Saved:", rds_path, "\n")
