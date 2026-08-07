# =============================================================================
# 01b_convert_reciprocal_20260612.R — Convert reciprocal-deposit CSV (from
# 01b_pull_reciprocal_20260612.py) to rds for the guarded merge block in
# 01_build_panel_20260612.R.
# =============================================================================

rm(list = ls())

library(data.table)
library(here)

csv_path <- here::here("tracks", "post-jmcb-rejection-june2026", "data",
                       "reciprocal_deposits_20260612.csv")
rds_path <- here::here("tracks", "post-jmcb-rejection-june2026", "data",
                       "reciprocal_deposits_20260612.rds")

x <- fread(csv_path, colClasses = list(character = c("ID_RSSD", "D_DT")))
x[, reciprocal_deps := as.numeric(reciprocal_deps)]
x[is.na(reciprocal_deps), reciprocal_deps := 0]

# Dedup: 031 filers can appear in multiple RC-E schedule members per quarter
x <- x[, .(reciprocal_deps = max(reciprocal_deps)), by = .(ID_RSSD, D_DT)]
x[, ID_RSSD := as.integer(ID_RSSD)]
x[, D_DT := as.Date(D_DT)]

saveRDS(x, rds_path)

cat("\n=============== DIAGNOSTICS: reciprocal rds ===============\n")
cat(sprintf("Rows: %d | Banks: %d | Quarters: %d (%s to %s)\n",
            nrow(x), uniqueN(x$ID_RSSD), uniqueN(x$D_DT),
            min(x$D_DT), max(x$D_DT)))
cat(sprintf("Nonzero share: %.1f%%\n", 100 * mean(x$reciprocal_deps > 0)))
q <- quantile(x[reciprocal_deps > 0, reciprocal_deps], c(0.01, 0.5, 0.99))
cat(sprintf("Nonzero $th: p1=%.0f p50=%.0f p99=%.0f\n", q[1], q[2], q[3]))
cat("Saved:", rds_path, "\n")
