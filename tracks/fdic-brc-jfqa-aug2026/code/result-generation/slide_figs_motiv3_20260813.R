# =============================================================================
# slide_figs_motiv3_20260813.R — three-panel raw-means motivating figure
#
# One output: slides/figures/fig_s_motiv_panels.png. Replaces the single-panel
# fig_s_motiv_index.png (slide_figs_motiv_20260812.R, kept as backup).
#
# Layout: uninsured time deposits across the top (base 2023Q1, the adoption
# quarter), insured time deposits and insured brokered deposits side by side
# below (base 2022Q1, four quarters before the shock, so the pre-adoption
# repositioning stays inside the plotted path).
#
# All panels: cross-sectional group means, in percentage points of assets
# relative to the panel's own base quarter. Balanced panel (banks observed in
# every quarter 2018Q1-2024Q4). No controls, no fixed effects — descriptive
# slide shown before any regression result.
#
# Input: panel_smallbank (post-jmcb 20260612 vintage via _track_common.R fallback)
# Slide conventions (theme_slide, save_slide_fig) follow slide_figs_20260811.R.
# =============================================================================
rm(list = ls())

library(data.table)
library(ggplot2)
library(patchwork)
library(here)

source(here::here("code", "_common.R"))
source(here::here("tracks", "fdic-brc-jfqa-aug2026", "code", "_track_common.R"))

SLIDE_FIG <- file.path(TRACK_DIR, "slides", "figures")
dir.create(SLIDE_FIG, showWarnings = FALSE, recursive = TRUE)

BASE_SIZE <- 15
NEAR_ZERO_TOL <- 0.05
ADOPT_DT <- as.Date("2023-01-01")

theme_slide <- function(base_size = BASE_SIZE) {
  theme_custom(base_size = base_size) %+replace%
    theme(
      legend.position    = "bottom",
      legend.text        = element_text(size = rel(0.95)),
      plot.margin        = margin(4, 10, 4, 6),
      plot.title         = element_text(size = rel(1.0), face = "bold", hjust = 0,
                                        margin = margin(b = 4)),
      axis.title         = element_text(size = rel(0.8)),
      panel.grid.major.y = element_line(color = "grey92"),
      complete = FALSE
    )
}

panel <- readRDS(latest_track_file("panel_smallbank"))
setDT(panel)
panel[, dt := as.Date(D_DT)]

# Blue/gold, matching the overlay event-study figures in the deck; grey read as
# too close to the blue when projected.
col_map <- c("High CECL" = primary_blue, "Near-zero CECL" = primary_gold)

# Group means in pp relative to `base_q`, balanced within the outcome's sample
series <- function(var, base_q) {
  d <- panel[dt >= as.Date("2018-01-01") & dt <= as.Date("2024-12-31") &
               !is.na(cecl_equity) & !is.na(get(var))]
  d[, grp := fifelse(cecl_equity >= CECL_THRESHOLD_PCT, "High CECL",
              fifelse(abs(cecl_equity) <= NEAR_ZERO_TOL, "Near-zero CECL", NA_character_))]
  d <- d[!is.na(grp)]
  nq <- d[, uniqueN(dt), by = ID_RSSD]
  d <- d[ID_RSSD %in% nq[V1 == max(V1), ID_RSSD]]

  g <- d[, .(m = mean(get(var))), by = .(dt, grp)]
  g <- merge(g, g[dt == base_q, .(grp, m0 = m)], by = "grp")
  g[, dm := m - m0]
  setorder(g, grp, dt)
  g[]
}

mk_panel <- function(g, base_q, base_lab, title, ylab, adopt_label = FALSE,
                     base_is_adopt = FALSE) {
  p <- ggplot(g, aes(x = dt, y = dm, color = grp)) +
    geom_hline(yintercept = 0, color = "grey70", linewidth = 0.35, linetype = "dashed")

  # When the base IS the adoption quarter, the red adoption line already marks
  # it — a second grey rule three months away only reads as clutter.
  if (!base_is_adopt) {
    p <- p +
      geom_vline(xintercept = base_q, color = "grey60", linewidth = 0.5, linetype = "dashed") +
      annotate("text", x = base_q - 25, y = Inf, label = paste0("base: ", base_lab),
               color = "grey40", hjust = 1, vjust = 1.4, size = 3.6)
  } else {
    p <- p +
      annotate("text", x = ADOPT_DT + 30, y = Inf, label = paste0("base: ", base_lab),
               color = "grey40", hjust = 0, vjust = 1.4, size = 3.6)
  }

  p <- p +
    geom_vline(xintercept = ADOPT_DT, color = negative_red,
               linewidth = 0.8, linetype = "dotted") +
    geom_line(linewidth = 1.0) +
    geom_point(size = 1.5) +
    scale_color_manual(values = col_map) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    theme_slide() +
    theme(legend.title = element_blank()) +
    labs(x = NULL, y = ylab, title = title)

  if (adopt_label) {
    p <- p + annotate("text", x = ADOPT_DT + 30, y = -Inf, label = "CECL adoption",
                      color = negative_red, hjust = 0, vjust = -0.8, size = 3.6)
  }
  p
}

# -----------------------------------------------------------------------------
# Panels
# -----------------------------------------------------------------------------
BASE_TOP <- as.Date("2023-03-31"); LAB_TOP <- "2023Q1"
BASE_BOT <- as.Date("2022-03-31"); LAB_BOT <- "2022Q1"

g_unins    <- series("unins_time_deps_assets", BASE_TOP)
g_ins      <- series("ins_time_deps_assets",   BASE_BOT)
g_brokered <- series("brokered_ins_assets",    BASE_BOT)

p_top <- mk_panel(g_unins, BASE_TOP, LAB_TOP,
                  "Uninsured time deposits",
                  "pp of assets", adopt_label = TRUE, base_is_adopt = TRUE)
p_bl  <- mk_panel(g_ins, BASE_BOT, LAB_BOT,
                  "Insured time deposits", "pp of assets")
p_br  <- mk_panel(g_brokered, BASE_BOT, LAB_BOT,
                  "Insured brokered deposits", "pp of assets")

# Extra top margin on the second row separates it from the top panel
row2_gap <- theme(plot.margin = margin(22, 10, 4, 6))

# Top panel gets the same width as one bottom panel, centred over the pair
row1 <- plot_spacer() + p_top + plot_spacer() +
  plot_layout(widths = c(0.25, 0.5, 0.25))

combined <- (row1 / (p_bl + row2_gap | p_br + row2_gap)) +
  plot_layout(heights = c(1, 1), guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(SLIDE_FIG, "fig_s_motiv_panels.png"), combined,
       width = 11, height = 6.2, bg = "white", dpi = 200)
cat("Wrote:", file.path(SLIDE_FIG, "fig_s_motiv_panels.png"), "\n")

# --- diagnostics -------------------------------------------------------------
report <- function(g, lab, base_q) {
  cat("\n---", lab, "| base", format(base_q), "---\n")
  cat("Level at base (% of assets):\n"); print(g[dt == base_q, .(grp, base = round(m, 3))])
  print(dcast(g[dt %in% as.Date(c("2022-03-31", "2022-12-31", "2023-03-31",
                                  "2023-12-31", "2024-12-31"))],
              dt ~ grp, value.var = "dm"))
}
report(g_unins,    "Uninsured time deposits", BASE_TOP)
report(g_ins,      "Insured time deposits",   BASE_BOT)
report(g_brokered, "Insured brokered",        BASE_BOT)
