# =============================================================================
# slide_figs_20260811.R — figures for the FDIC BRC 20-minute Beamer deck
#
# Two kinds of output, all written to tracks/fdic-brc-jfqa-aug2026/slides/figures/:
#   1. Slide-optimized re-exports of paper event-study figures (larger fonts,
#      16:9-friendly aspect). Model code replicates figures_rebuild_20260806.qmd
#      §1 (overlay composition) and es_figs_20260808.qmd (insured brokered ES,
#      financial-outcome ES) on panel_smallbank (post-jmcb 20260612 vintage via
#      _track_common.R fallback).
#   2. Coefficient dot-whisker plots, election bar chart, and capital-buffer
#      gradient with point estimates/SEs HARDCODED from the published tables in
#      latex/build/main.pdf (Tables 2-9). No re-estimation; 90% CIs (z = 1.645)
#      to match the paper's event-study figures.
#
# Market-validation (mkt_cap/cds 20260403) and SVB-decile (fig_svb_exposure
# 20260811) figures are reused as-is by the deck; not rebuilt here.
# =============================================================================
rm(list = ls())

library(data.table)
library(fixest)
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

# -----------------------------------------------------------------------------
# Panel + event-study models (replicates figures_rebuild_20260806.qmd §1 and
# es_figs_20260808.qmd specs exactly)
# -----------------------------------------------------------------------------
panel <- readRDS(latest_track_file("panel_smallbank"))
setDT(panel)

dt_w <- panel[abs(qtrs_since) < 12]
dt_w[, D_DT := as.factor(D_DT)]

setFixest_fml(
  ..controls = ~ log_total_assets_l1 + equity_assets_l1,
  ..fe = ~ ID_RSSD + D_DT
)

# -----------------------------------------------------------------------------
# 1. CECL Day-One adjustment histogram (paper Figure 2, slide version)
# -----------------------------------------------------------------------------
treat <- unique(panel[qtrs_since == 0 & !is.na(cecl_equity), .(ID_RSSD, cecl_equity)])
cat("Histogram sample: ", nrow(treat), " banks\n")

p_hist <- ggplot(treat, aes(x = cecl_equity)) +
  geom_histogram(binwidth = 0.4, fill = primary_blue, color = "white",
                 linewidth = 0.2, boundary = 0) +
  geom_vline(xintercept = CECL_THRESHOLD_PCT, color = negative_red,
             linetype = "dashed", linewidth = 1) +
  annotate("text", x = CECL_THRESHOLD_PCT + 0.3, y = Inf,
           label = "High-CECL\nthreshold (2.5%)", color = negative_red,
           vjust = 1.2, hjust = 0, size = 5.5, lineheight = 0.9) +
  coord_cartesian(xlim = c(-4, 10)) +
  theme_slide() +
  labs(x = "CECL Day-One adjustment / pre-adoption equity (%)",
       y = "Number of banks")
save_slide_fig(p_hist, "fig_s_cecl_dist", width = 7.4, height = 4.6)

# -----------------------------------------------------------------------------
# 2. Overlay composition ES: two-frame build with identical axes
# -----------------------------------------------------------------------------
m_u <- feols(unins_time_deps_assets ~ i(qtrs_since, high_cecl_equity, ref = -1) +
               ..controls + int_expense_assets_l1 | ..fe, data = dt_w, vcov = ~ID_RSSD)
m_i <- feols(ins_time_deps_assets ~ i(qtrs_since, high_cecl_equity, ref = -1) +
               ..controls + int_expense_assets_l1 | ..fe, data = dt_w, vcov = ~ID_RSSD)

pd_u <- extract_es_data(m_u)[, group := "Uninsured time deposits"]
pd_i <- extract_es_data(m_i)[, group := "Insured time deposits"]
pd_both <- rbind(pd_u, pd_i)
ylim_overlay <- range(pd_both$lo90, pd_both$hi90)

overlay_plot <- function(pd) {
  col_map <- c("Uninsured time deposits" = primary_blue,
               "Insured time deposits"   = primary_gold)
  ggplot(pd, aes(x = k, y = est, color = group, fill = group)) +
    geom_hline(yintercept = 0, color = accent_gray, linewidth = 0.4,
               linetype = "dashed") +
    geom_vline(xintercept = -0.5, color = "darkred", linewidth = 1,
               linetype = "dotted") +
    annotate("text", x = -0.3, y = Inf, label = "CECL adoption",
             color = accent_gray, vjust = 1.5, hjust = 0, size = 5) +
    geom_ribbon(aes(ymin = lo90, ymax = hi90), alpha = 0.12, color = NA) +
    geom_line(linewidth = 1.1) +
    geom_point(size = 2.6) +
    scale_color_manual(values = col_map, breaks = names(col_map)) +
    scale_fill_manual(values = col_map, breaks = names(col_map)) +
    scale_x_continuous(breaks = seq(-11, 11, by = 2)) +
    coord_cartesian(ylim = ylim_overlay) +
    theme_slide() +
    labs(x = "Quarters relative to CECL adoption (k = 0)",
         y = "Coefficient (pp of assets)", color = NULL, fill = NULL)
}

save_slide_fig(overlay_plot(pd_u),    "fig_s_overlay_build1", width = 10, height = 4.9)
save_slide_fig(overlay_plot(pd_both), "fig_s_overlay_build2", width = 10, height = 4.9)

# -----------------------------------------------------------------------------
# 3. Insured brokered ES: plain + ramp-highlighted build
# -----------------------------------------------------------------------------
m_b <- feols(brokered_ins_assets ~ i(qtrs_since, high_cecl_equity, ref = -1) +
               ..controls + int_expense_assets_l1 | ..fe, data = dt_w, vcov = ~ID_RSSD)
pd_b <- extract_es_data(m_b)

brokered_plot <- function(highlight_ramp = FALSE) {
  p <- ggplot(pd_b, aes(x = k, y = est))
  if (highlight_ramp) {
    p <- p +
      annotate("rect", xmin = -4.5, xmax = -0.5, ymin = -Inf, ymax = Inf,
               fill = primary_gold, alpha = 0.18) +
      annotate("text", x = -2.5, y = max(pd_b$hi90),
               label = "banks pre-fund\nbefore disclosure", color = "#8a6d00",
               size = 5, lineheight = 0.9, vjust = 1)
  }
  p +
    geom_hline(yintercept = 0, color = accent_gray, linewidth = 0.4,
               linetype = "dashed") +
    geom_vline(xintercept = -0.5, color = "darkred", linewidth = 1,
               linetype = "dotted") +
    annotate("text", x = -0.3, y = Inf, label = "CECL adoption",
             color = accent_gray, vjust = 1.5, hjust = 0, size = 5) +
    geom_ribbon(aes(ymin = lo90, ymax = hi90), fill = primary_blue, alpha = 0.15) +
    geom_line(color = primary_blue, linewidth = 1.1) +
    geom_point(color = primary_blue, size = 2.6) +
    scale_x_continuous(breaks = seq(-11, 11, by = 2)) +
    theme_slide() +
    labs(x = "Quarters relative to CECL adoption (k = 0)",
         y = "Coefficient (pp of assets)")
}

save_slide_fig(brokered_plot(FALSE), "fig_s_brokered_build1", width = 10, height = 4.6)
save_slide_fig(brokered_plot(TRUE),  "fig_s_brokered_build2", width = 10, height = 4.6)

# -----------------------------------------------------------------------------
# 4. Financial-outcome ES panels (interest expense, ROA, NIM), one PNG each
# -----------------------------------------------------------------------------
fin_specs <- list(
  list(dv = "int_expense_assets", stub = "fig_s_es_intexp", lab = "Interest expense"),
  list(dv = "roa",                stub = "fig_s_es_roa",    lab = "ROA"),
  list(dv = "nim",                stub = "fig_s_es_nim",    lab = "NIM")
)
for (s in fin_specs) {
  m <- feols(.[s$dv] ~ i(qtrs_since, high_cecl_equity, ref = -1) +
               ..controls | ..fe, data = dt_w, vcov = ~ID_RSSD)
  pd <- extract_es_data(m)
  p <- ggplot(pd, aes(x = k, y = est)) +
    geom_hline(yintercept = 0, color = accent_gray, linewidth = 0.4,
               linetype = "dashed") +
    geom_vline(xintercept = -0.5, color = "darkred", linewidth = 0.9,
               linetype = "dotted") +
    geom_ribbon(aes(ymin = lo90, ymax = hi90), fill = primary_blue, alpha = 0.15) +
    geom_line(color = primary_blue, linewidth = 1) +
    geom_point(color = primary_blue, size = 2) +
    scale_x_continuous(breaks = seq(-10, 10, by = 5)) +
    theme_slide(base_size = 17) +
    labs(x = "Quarters since adoption", y = "Coefficient (pp)")
  save_slide_fig(p, s$stub, width = 4.4, height = 3.9)
}

# =============================================================================
# HARDCODED coefficient plots (point estimates/SEs from latex/build/main.pdf)
# =============================================================================
ci_plot <- function(dd, xlab = "DiD estimate (pp of assets), High-CECL banks",
                    colors = NULL, xbreaks = waiver()) {
  dd[, `:=`(lo = est - CI_Z * se, hi = est + CI_Z * se)]
  dd[, label := factor(label, levels = rev(dd$label))]
  if (is.null(colors)) colors <- rep(primary_blue, nrow(dd))
  dd[, col := rev(colors)[as.integer(label)]]
  ggplot(dd, aes(x = est, y = label)) +
    geom_vline(xintercept = 0, color = negative_red, linetype = "dashed",
               linewidth = 0.7) +
    geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.16,
                   color = dd$col, linewidth = 1) +
    geom_point(color = dd$col, size = 4) +
    geom_text(aes(label = txt), vjust = -1.3, size = 5.6, color = dd$col,
              fontface = "bold") +
    scale_x_continuous(breaks = xbreaks) +
    scale_y_discrete(expand = expansion(add = 0.55)) +
    theme_slide() +
    theme(panel.grid.major.y = element_blank(),
          axis.text.y = element_text(size = rel(1.0), hjust = 1)) +
    labs(x = xlab, y = NULL)
}

# --- 5. Magnitudes: Table 2 Panel A cols (2),(4) + Table 3 col (2) ------------
dd_mag <- data.table(
  label = c("Uninsured time deposits", "Insured time deposits",
            "Uninsured − insured gap\n(within bank × quarter)"),
  est = c(-0.3935, 0.7117, -1.252),
  se  = c(0.1815, 0.2905, 0.3401),
  txt = c("−0.39**", "+0.71**", "−1.25***")
)
save_slide_fig(
  ci_plot(dd_mag, colors = c(primary_blue, primary_gold, "#444444")),
  "fig_s_coef_magnitudes", width = 9.6, height = 4.6
)

# --- 6. Rollover margin: T2 cols (2),(6); T2 Panel B cols (2),(3) -------------
dd_margin <- data.table(
  label = c("Uninsured time deposits\n(scheduled rollover decision)",
            "All uninsured deposits\n(mostly operating balances)",
            "Uninsured CDs: short-maturity book\n(more CDs coming due)",
            "Uninsured CDs: long-maturity book"),
  est = c(-0.3935, -0.1767, -0.5438, -0.2291),
  se  = c(0.1815, 0.4576, 0.2799, 0.2362),
  txt = c("−0.39**", "−0.18 (ns)", "−0.54*", "−0.23 (ns)")
)
save_slide_fig(
  ci_plot(dd_margin,
          colors = c(primary_blue, accent_gray, primary_blue, accent_gray)),
  "fig_s_coef_margin", width = 10.4, height = 5.2
)

# --- 7. Rate nulls: Table 5 col (2); Table 6 col (1) --------------------------
# Row 2 (2026-09-15): implied rate on INSURED CDs, Table 5 col (4), replaces
# the RateWatch stress-window row (-0.0263, SE 0.0484) on the deck slide.
dd_rates <- data.table(
  label = c("Implied rate paid on uninsured CDs\n(Call Report, quarterly)",
            "Implied rate paid on insured CDs\n(Call Report, quarterly)",
            "Posted 12-mo CD rate, after disclosure\n(RateWatch, weekly)"),
  est = c(-0.0819, 0.0240, -0.0582),
  se  = c(0.0518, 0.0384, 0.0737),
  txt = c("−0.08 (ns)", "+0.02 (ns)", "−0.06 (ns)")
)
save_slide_fig(
  ci_plot(dd_rates, xlab = "DiD estimate (pp), High-CECL banks",
          colors = rep(accent_gray, 3)),
  "fig_s_coef_rates", width = 10.4, height = 4.8
)

# --- 8. Destination margins: Table 7 cols (2),(4),(6) -------------------------
dd_dest <- data.table(
  label = c("Insured brokered deposits", "Reciprocal deposits",
            "Term FHLB advances"),
  est = c(0.5209, 0.2899, 0.0341),
  se  = c(0.2644, 0.2525, 0.1819),
  txt = c("+0.52**", "+0.29 (ns)", "+0.03 (ns)")
)
save_slide_fig(
  ci_plot(dd_dest, colors = c(primary_gold, primary_gold, accent_gray)),
  "fig_s_coef_destination", width = 7.2, height = 4.8
)

# --- 9. Phase-in election bar chart (Table 9 / Sec 6.9: 34% vs 6%) ------------
dd_el <- data.table(
  group = factor(c("High-CECL banks", "All other banks"),
                 levels = c("High-CECL banks", "All other banks")),
  share = c(34, 6)
)
p_el <- ggplot(dd_el, aes(x = group, y = share, fill = group)) +
  geom_col(width = 0.55) +
  geom_text(aes(label = paste0(share, "%")), vjust = -0.45, size = 7,
            fontface = "bold", color = c(primary_blue, accent_gray)) +
  scale_fill_manual(values = c(primary_blue, accent_gray), guide = "none") +
  scale_y_continuous(limits = c(0, 40), expand = expansion(mult = c(0, 0.08))) +
  theme_slide() +
  theme(panel.grid.major.x = element_blank()) +
  labs(x = NULL, y = "Share electing capital phase-in (%)")
save_slide_fig(p_el, "fig_s_election_bar", width = 5.4, height = 4.4)

# --- 10. Capital-buffer gradient: Table 4 col (4) -----------------------------
# effect(e) = -0.8009 + 0.0665 * e (gap design, continuous CECL Adj);
# stars at e = 6/8/10/12/14 from the marginal-effect profile in the text.
grad <- data.table(e = seq(4, 16, by = 0.1))
grad[, eff := -0.8009 + 0.0665 * e]
pts <- data.table(
  e = c(6, 8, 10, 12, 14),
  txt = c("−0.40***", "−0.27***", "−0.14**", "−0.00", "+0.13")
)
pts[, eff := -0.8009 + 0.0665 * e]
zero_e <- 0.8009 / 0.0665

p_grad <- ggplot(grad, aes(x = e, y = eff)) +
  annotate("rect", xmin = -Inf, xmax = zero_e, ymin = -Inf, ymax = Inf,
           fill = primary_blue, alpha = 0.06) +
  geom_hline(yintercept = 0, color = accent_gray, linetype = "dashed",
             linewidth = 0.5) +
  geom_vline(xintercept = zero_e, color = negative_red, linetype = "dotted",
             linewidth = 0.9) +
  annotate("text", x = zero_e + 0.25, y = -0.42,
           label = "effect dies at ~12% equity\n(75th percentile)",
           color = negative_red, hjust = 0, size = 5, lineheight = 0.95) +
  geom_line(color = primary_blue, linewidth = 1.3) +
  geom_point(data = pts, color = primary_blue, size = 3.6) +
  geom_text(data = pts, aes(label = txt), vjust = 1.9, size = 5.2,
            color = primary_blue, fontface = "bold") +
  scale_x_continuous(breaks = seq(4, 16, by = 2)) +
  theme_slide() +
  labs(x = "Pre-adoption equity / assets (%, 2022Q4)",
       y = "Effect of CECL exposure on\nuninsured − insured gap (pp per pp)")
save_slide_fig(p_grad, "fig_s_capital_gradient", width = 9.6, height = 4.9)

# -----------------------------------------------------------------------------
cat("\n================ DIAGNOSTICS ================\n")
cat("dt_w rows:", nrow(dt_w), "| banks:", uniqueN(dt_w$ID_RSSD), "\n")
cat("Overlay unins k=1..11 mean est:",
    round(pd_u[k >= 1, mean(est)], 3), "(paper: negative, ~-0.4 to -0.7)\n")
cat("Overlay ins k=1..11 mean est:",
    round(pd_i[k >= 1, mean(est)], 3), "(paper: positive)\n")
cat("Brokered ramp k=-4..-1 ests:",
    paste(round(pd_b[k %in% -4:-1, est], 3), collapse = ", "), "\n")
cat("All slide figures written to:", SLIDE_FIG, "\n")
