# =============================================================================
# slide_figs_motiv_20260812.R — raw-means motivating figure for the FDIC BRC deck
#
# One output: slides/figures/fig_s_motiv_index.png. Cross-sectional means of
# uninsured time deposits / assets, indexed to 2022Q1 = 100 (four quarters before the shock), for High-CECL
# (adjustment >= 2.5% of pre-adoption equity) vs near-zero-CECL
# (|adjustment| <= 0.05%) banks, calendar time 2018Q1-2024Q4.
#
# No controls, no fixed effects — this is the descriptive slide shown before any
# regression result. Sample is balanced (banks observed in all 28 quarters) so
# entry/exit cannot generate the divergence.
#
# Input: panel_smallbank (post-jmcb 20260612 vintage via _track_common.R fallback)
# Slide-figure conventions (theme_slide, save_slide_fig) follow
# slide_figs_20260811.R.
# =============================================================================
rm(list = ls())

library(data.table)
library(ggplot2)
library(here)

source(here::here("code", "_common.R"))
source(here::here("tracks", "fdic-brc-jfqa-aug2026", "code", "_track_common.R"))

SLIDE_FIG <- file.path(TRACK_DIR, "slides", "figures")
dir.create(SLIDE_FIG, showWarnings = FALSE, recursive = TRUE)

BASE_SIZE <- 18

theme_slide <- function(base_size = BASE_SIZE) {
  theme_custom(base_size = base_size) %+replace%
    theme(
      legend.position   = "bottom",
      legend.text       = element_text(size = rel(0.9)),
      plot.margin       = margin(8, 14, 6, 8),
      axis.title        = element_text(size = rel(0.85)),
      panel.grid.major.y = element_line(color = "grey92"),
      complete = FALSE
    )
}

save_slide_fig <- function(plot, stub, width, height) {
  path <- file.path(SLIDE_FIG, paste0(stub, ".png"))
  ggsave(path, plot, width = width, height = height, bg = "white", dpi = 200)
  cat("Wrote:", path, "\n")
}

# Base = four quarters before the shock (k = -4 for the 92% of the sample
# adopting 2023Q1), so any pre-adoption repositioning stays inside the plotted
# path rather than inside the base.
BASE_Q <- as.Date("2022-03-31")
BASE_LAB <- "2022Q1"
NEAR_ZERO_TOL <- 0.05

panel <- readRDS(latest_track_file("panel_smallbank"))
setDT(panel)
panel[, dt := as.Date(D_DT)]

dt <- panel[dt >= as.Date("2018-01-01") & dt <= as.Date("2024-12-31") &
              !is.na(cecl_equity) & !is.na(unins_time_deps_assets)]

dt[, grp := fifelse(cecl_equity >= CECL_THRESHOLD_PCT, "High CECL",
             fifelse(abs(cecl_equity) <= NEAR_ZERO_TOL, "Near-zero CECL", NA_character_))]
dt <- dt[!is.na(grp)]

# Balanced: keep banks observed in every quarter of the window
nq <- dt[, uniqueN(dt), by = ID_RSSD]
dt <- dt[ID_RSSD %in% nq[V1 == max(V1), ID_RSSD]]

g <- dt[, .(m = mean(unins_time_deps_assets), n = .N), by = .(dt, grp)]
g <- merge(g, g[dt == BASE_Q, .(grp, m0 = m)], by = "grp")
g[, idx := 100 * m / m0]
setorder(g, grp, dt)

col_map <- c("High CECL" = primary_blue, "Near-zero CECL" = accent_gray)

p <- ggplot(g, aes(x = dt, y = idx, color = grp)) +
  geom_hline(yintercept = 100, color = "grey70", linewidth = 0.35, linetype = "dashed") +
  geom_vline(xintercept = BASE_Q, color = "grey65", linewidth = 0.6, linetype = "dashed") +
  annotate("text", x = BASE_Q - 25, y = Inf, label = paste0("base: ", BASE_LAB),
           color = "grey40", hjust = 1, vjust = 1.4, size = 4.6) +
  geom_vline(xintercept = as.Date("2023-01-01"), color = negative_red,
             linewidth = 0.9, linetype = "dotted") +
  annotate("text", x = as.Date("2023-02-15"), y = Inf, label = "CECL adoption\n(2023Q1)",
           color = negative_red, hjust = 0, vjust = 1.25, size = 5, lineheight = 0.9) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.1) +
  scale_color_manual(values = col_map) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_slide() +
  theme(legend.title = element_blank()) +
  labs(x = NULL, y = paste0("Uninsured time deposits / assets\n(", BASE_LAB, " = 100)"))

save_slide_fig(p, "fig_s_motiv_index", width = 9, height = 5)

# --- diagnostics -------------------------------------------------------------
cat("Quarters:", uniqueN(dt$dt), " span:", format(min(dt$dt)), "-", format(max(dt$dt)), "\n")
cat("Balanced banks by group:\n"); print(dt[dt == BASE_Q, .N, by = grp])
cat("Mean unins TD/assets at base 2022Q1 (%):\n")
print(dt[dt == BASE_Q, .(mean = round(mean(unins_time_deps_assets), 3)), by = grp])
cat("Index at selected quarters:\n")
print(dcast(g[dt %in% as.Date(c("2022-03-31", "2022-12-31", "2023-06-30", "2023-12-31", "2024-12-31"))],
            dt ~ grp, value.var = "idx"))
