# =============================================================================
# slide_figs_placebo_20260813.R — raw-means placebo figure for the FDIC BRC deck
#
# One output: slides/figures/fig_s_placebo_svb.png. Visual analogue of the
# motivating figure's top panel (slide_figs_motiv3_20260813.R), but for the SVB
# placebo of svb_placebo_20260808.qmd §1:
#   sample     banks with a zero Day-One CECL adjustment (no CECL news)
#   split      2022Q4 unrealized securities losses, loss-signed, median split
#              (loss_22q4 = -unreal_loss_assets_22q4; same construction as the
#              placebo table's high_loss indicator)
#   outcome    uninsured time deposits / assets, pp relative to 2022Q4 (the last
#              Call Report before the March 2023 failures)
#
# If the deposit response were the 2023 stress rather than the CECL disclosure,
# these two lines would separate at the failures. They do not.
#
# Group means, no controls and no fixed effects; balanced panel (banks observed
# in every quarter 2018Q1-2024Q4).
#
# Input: panel_smallbank (post-jmcb 20260612 vintage via _track_common.R fallback)
# =============================================================================
rm(list = ls())

library(data.table)
library(ggplot2)
library(here)

source(here::here("code", "_common.R"))
source(here::here("tracks", "fdic-brc-jfqa-aug2026", "code", "_track_common.R"))

SLIDE_FIG <- file.path(TRACK_DIR, "slides", "figures")
dir.create(SLIDE_FIG, showWarnings = FALSE, recursive = TRUE)

BASE_SIZE <- 16
BASE_Q <- as.Date("2022-12-31")   # last quarter-end before the March 2023 failures
BASE_LAB <- "2022Q4"
SVB_DT <- as.Date("2023-02-01")   # between the 2022Q4 and 2023Q1 report dates

theme_slide <- function(base_size = BASE_SIZE) {
  theme_custom(base_size = base_size) %+replace%
    theme(
      legend.position    = "bottom",
      legend.text        = element_text(size = rel(0.95)),
      plot.margin        = margin(6, 12, 4, 6),
      axis.title         = element_text(size = rel(0.85)),
      panel.grid.major.y = element_line(color = "grey92"),
      complete = FALSE
    )
}

panel <- readRDS(latest_track_file("panel_smallbank"))
setDT(panel)
panel[, dt := as.Date(D_DT)]

# Placebo sample: zero Day-One adjustment only
zero_ids <- unique(panel[!is.na(cecl_equity) & cecl_equity == 0, ID_RSSD])

d <- panel[ID_RSSD %in% zero_ids &
             dt >= as.Date("2018-01-01") & dt <= as.Date("2024-12-31") &
             !is.na(unins_time_deps_assets) & !is.na(unreal_loss_assets_22q4)]

# Loss-signed exposure: positive = larger unrealized securities loss
d[, loss_22q4 := -unreal_loss_assets_22q4]
med_loss <- median(unique(d[, .(ID_RSSD, loss_22q4)])$loss_22q4, na.rm = TRUE)
d[, grp := fifelse(loss_22q4 > med_loss, "High unrealized loss", "Low unrealized loss")]

# Balanced: keep banks observed in every quarter of the window
nq <- d[, uniqueN(dt), by = ID_RSSD]
d <- d[ID_RSSD %in% nq[V1 == max(V1), ID_RSSD]]

g <- d[, .(m = mean(unins_time_deps_assets)), by = .(dt, grp)]
g <- merge(g, g[dt == BASE_Q, .(grp, m0 = m)], by = "grp")
g[, dm := m - m0]
setorder(g, grp, dt)

col_map <- c("High unrealized loss" = primary_blue, "Low unrealized loss" = primary_gold)

p <- ggplot(g, aes(x = dt, y = dm, color = grp)) +
  geom_hline(yintercept = 0, color = "grey70", linewidth = 0.35, linetype = "dashed") +
  geom_vline(xintercept = SVB_DT, color = negative_red,
             linewidth = 0.9, linetype = "dotted") +
  annotate("text", x = SVB_DT + 30, y = Inf, label = paste0("base: ", BASE_LAB),
           color = "grey40", hjust = 0, vjust = 1.4, size = 4.2) +
  annotate("text", x = SVB_DT + 30, y = -Inf, label = "SVB failures\n(March 2023)",
           color = negative_red, hjust = 0, vjust = -0.35, size = 4.2, lineheight = 0.9) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.0) +
  scale_color_manual(values = col_map) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_slide() +
  theme(legend.title = element_blank()) +
  labs(x = NULL, y = paste0("Uninsured time deposits / assets\n(pp, relative to ", BASE_LAB, ")"))

ggsave(file.path(SLIDE_FIG, "fig_s_placebo_svb.png"), p,
       width = 9, height = 5, bg = "white", dpi = 200)
cat("Wrote:", file.path(SLIDE_FIG, "fig_s_placebo_svb.png"), "\n")

# --- diagnostics -------------------------------------------------------------
cat("Zero-CECL banks in window:", uniqueN(d$ID_RSSD), "\n")
cat("Median loss_22q4 (pp of assets):", round(med_loss, 3), "\n")
cat("Balanced banks by group:\n"); print(d[dt == BASE_Q, .N, by = grp])
cat("Level at base (% of assets):\n"); print(g[dt == BASE_Q, .(grp, base = round(m, 3))])
cat("Series at selected quarters (pp vs base):\n")
print(dcast(g[dt %in% as.Date(c("2022-12-31", "2023-03-31", "2023-06-30",
                                "2023-12-31", "2024-12-31"))],
            dt ~ grp, value.var = "dm"))
