# =============================================================================
# slide_figs_v4_20260915.R — deck v4 figure changes (PDF comment round, v1 pdf)
#
# Three outputs, all written to tracks/fdic-brc-jfqa-aug2026/slides/figures/:
#   1. fig_s_motiv_panels.png   — three raw-means panels as in
#      slide_figs_motiv3_20260813.R, plus a CECL-Adj histogram in the empty
#      top-left slot with the High-CECL (blue) and near-zero (gold) samples
#      highlighted.
#   2. fig_s_placebo_svb.png    — raw-means SVB placebo as in
#      slide_figs_placebo_20260813.R, plus a histogram inset with the
#      zero-charge placebo sample highlighted.
#   3. fig_s_capital_quartiles.png — NEW regression: DiD effect of Post x High
#      CECL on (a) uninsured time deposits/assets and (b) the uninsured -
#      insured time-deposit gap, at below- vs above-median 2022Q4
#      equity/assets. Replaces the linear-gradient figure on the capital slide
#      (fig_s_capital_gradient.png is kept for the backup slide).
#   4. fig_s_capital_maturity_2x2.png — NEW regression: same DiD on uninsured
#      time deposits/assets, in the 2x2 of (thin/thick 2022Q4 capital) x
#      (high/low 2022Q4 share of uninsured time deposits maturing <= 1 year).
#      fig_s_capital_maturity_2x2_total.png repeats it for total uninsured
#      deposits/assets (unins_deps_assets).
#
# Capital-split spec (mirrors capital_het_20260807.qmd):
#   unit      bank-quarter, |qtrs_since| < 12
#   outcomes  unins_time_deps_assets; gap = unins - ins time deposits/assets
#   treatment post x high_cecl_equity x 1[below median], x 1[above median]
#   FE        bank + calendar quarter; controls lagged log assets, equity/assets,
#             int. expense/assets; SEs clustered by bank; 90% CIs
#   expected  negative below median (thin capital), ~zero above
#
# Input: panel_smallbank (post-jmcb 20260612 vintage via _track_common.R fallback)
# =============================================================================
rm(list = ls())

library(data.table)
library(fixest)
library(ggplot2)
library(patchwork)
library(here)

source(here::here("code", "_common.R"))
source(here::here("tracks", "fdic-brc-jfqa-aug2026", "code", "_track_common.R"))

SLIDE_FIG <- file.path(TRACK_DIR, "slides", "figures")
dir.create(SLIDE_FIG, showWarnings = FALSE, recursive = TRUE)

NEAR_ZERO_TOL <- 0.05
ADOPT_DT <- as.Date("2023-01-01")

theme_slide <- function(base_size = 15) {
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

treat <- unique(panel[qtrs_since == 0 & !is.na(cecl_equity),
                      .(ID_RSSD, cecl_equity, high_cecl_equity)])

# -----------------------------------------------------------------------------
# Shared histogram of the Day-One charge with a highlighted sample
# -----------------------------------------------------------------------------
# `grp_fun` maps cecl_equity to a group label; `cols` names the fill colours.
# The y-axis is capped at `ycap` so the ~2,300-bank spike at zero does not
# flatten the tail; the spike height is annotated instead.
#
# `zero_grp` names the group defined at/near zero. Those banks are drawn as a
# single bar centred on zero rather than binned, so the bar is one colour;
# the 0.4-wide histogram bins straddling zero would otherwise stack that
# group on top of the small-nonzero banks that share the bin.
hist_inset <- function(grp_fun, cols, title, zero_grp, base_size = 12, ycap = 400) {
  h <- copy(treat)
  h[, grp := grp_fun(cecl_equity)]
  h[, grp := factor(grp, levels = names(cols))]
  hz <- h[grp == zero_grp]
  hn <- h[grp != zero_grp]
  n_zero <- nrow(hz)
  ggplot() +
    geom_histogram(data = hn, aes(x = cecl_equity, fill = grp), binwidth = 0.4,
                   boundary = 0, color = "white", linewidth = 0.15) +
    geom_col(data = data.table(x = 0, n = n_zero, grp = factor(zero_grp, levels = names(cols))),
             aes(x = x, y = n, fill = grp), width = 0.4, color = "white", linewidth = 0.15) +
    scale_fill_manual(values = cols, drop = FALSE) +
    annotate("text", x = 0.6, y = ycap, hjust = 0, vjust = 1, size = base_size * 0.28,
             color = "grey30", lineheight = 0.9,
             label = sprintf("bar at 0 truncated:\n%s banks", format(n_zero, big.mark = ","))) +
    coord_cartesian(xlim = c(-3, 10), ylim = c(0, ycap)) +
    theme_slide(base_size) +
    theme(legend.position = "bottom", legend.title = element_blank(),
          legend.key.size = unit(0.35, "cm"),
          legend.text = element_text(size = rel(0.85)),
          legend.margin = margin(t = -4),
          plot.title = element_text(size = rel(0.95))) +
    labs(x = "CECL Day-One charge / equity (%)", y = "Banks", title = title)
}

# -----------------------------------------------------------------------------
# 1. Motivating panels + histogram of the two compared groups
# -----------------------------------------------------------------------------
col_map <- c("High CECL" = primary_blue, "Near-zero CECL" = primary_gold)

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

BASE_TOP <- as.Date("2023-03-31"); LAB_TOP <- "2023Q1"
BASE_BOT <- as.Date("2022-03-31"); LAB_BOT <- "2022Q1"

g_unins    <- series("unins_time_deps_assets", BASE_TOP)
g_ins      <- series("ins_time_deps_assets",   BASE_BOT)
g_brokered <- series("brokered_ins_assets",    BASE_BOT)

p_top <- mk_panel(g_unins, BASE_TOP, LAB_TOP, "Uninsured time deposits",
                  "pp of assets", adopt_label = TRUE, base_is_adopt = TRUE)
p_bl  <- mk_panel(g_ins, BASE_BOT, LAB_BOT, "Insured time deposits", "pp of assets")
p_br  <- mk_panel(g_brokered, BASE_BOT, LAB_BOT, "Insured brokered deposits", "pp of assets")

p_h1 <- hist_inset(
  function(x) fifelse(x >= CECL_THRESHOLD_PCT, "High CECL",
               fifelse(abs(x) <= NEAR_ZERO_TOL, "Near-zero CECL", "Other")),
  c("High CECL" = primary_blue, "Near-zero CECL" = primary_gold, "Other" = "grey80"),
  "Groups compared", zero_grp = "Near-zero CECL") +
  guides(fill = "none")

row2_gap <- theme(plot.margin = margin(22, 10, 4, 6))
row1 <- p_h1 + p_top + plot_spacer() + plot_layout(widths = c(0.3, 0.5, 0.2))
combined <- (row1 / (p_bl + row2_gap | p_br + row2_gap)) +
  plot_layout(heights = c(1, 1), guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(SLIDE_FIG, "fig_s_motiv_panels.png"), combined,
       width = 11, height = 6.2, bg = "white", dpi = 200)
cat("Wrote: fig_s_motiv_panels.png\n")

# -----------------------------------------------------------------------------
# 2. SVB placebo + histogram of the zero-charge sample
# -----------------------------------------------------------------------------
BASE_Q <- as.Date("2022-12-31"); BASE_LAB <- "2022Q4"
SVB_DT <- as.Date("2023-02-01")

zero_ids <- unique(panel[!is.na(cecl_equity) & cecl_equity == 0, ID_RSSD])
d <- panel[ID_RSSD %in% zero_ids &
             dt >= as.Date("2018-01-01") & dt <= as.Date("2024-12-31") &
             !is.na(unins_time_deps_assets) & !is.na(unreal_loss_assets_22q4)]
d[, loss_22q4 := -unreal_loss_assets_22q4]
med_loss <- median(unique(d[, .(ID_RSSD, loss_22q4)])$loss_22q4, na.rm = TRUE)
d[, grp := fifelse(loss_22q4 > med_loss, "High unrealized loss", "Low unrealized loss")]
nq <- d[, uniqueN(dt), by = ID_RSSD]
d <- d[ID_RSSD %in% nq[V1 == max(V1), ID_RSSD]]
g <- d[, .(m = mean(unins_time_deps_assets)), by = .(dt, grp)]
g <- merge(g, g[dt == BASE_Q, .(grp, m0 = m)], by = "grp")
g[, dm := m - m0]
setorder(g, grp, dt)

col_pl <- c("High unrealized loss" = primary_blue, "Low unrealized loss" = primary_gold)
p_pl <- ggplot(g, aes(x = dt, y = dm, color = grp)) +
  geom_hline(yintercept = 0, color = "grey70", linewidth = 0.35, linetype = "dashed") +
  geom_vline(xintercept = SVB_DT, color = negative_red, linewidth = 0.9, linetype = "dotted") +
  annotate("text", x = SVB_DT + 30, y = Inf, label = paste0("base: ", BASE_LAB),
           color = "grey40", hjust = 0, vjust = 1.4, size = 4.2) +
  annotate("text", x = SVB_DT + 30, y = -Inf, label = "SVB failures\n(March 2023)",
           color = negative_red, hjust = 0, vjust = -0.35, size = 4.2, lineheight = 0.9) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.0) +
  scale_color_manual(values = col_pl) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_slide(16) +
  theme(legend.title = element_blank()) +
  labs(x = NULL, y = paste0("Uninsured time deposits / assets\n(pp, relative to ", BASE_LAB, ")"))

p_h2 <- hist_inset(
  function(x) fifelse(x == 0, "Zero charge (placebo sample)", "Other"),
  c("Zero charge (placebo sample)" = primary_blue, "Other" = "grey80"),
  "Sample: banks with no CECL news", zero_grp = "Zero charge (placebo sample)",
  base_size = 13) +
  theme(legend.position = "bottom")

combined_pl <- (p_pl | p_h2) + plot_layout(widths = c(0.64, 0.36))
ggsave(file.path(SLIDE_FIG, "fig_s_placebo_svb.png"), combined_pl,
       width = 12, height = 5, bg = "white", dpi = 200)
cat("Wrote: fig_s_placebo_svb.png\n")

# -----------------------------------------------------------------------------
# 3. Capital buffer, median split: DiD effect for uninsured time deposits and
#    for the uninsured - insured gap, at below- vs above-median 2022Q4 equity
# -----------------------------------------------------------------------------
dtw <- panel[abs(qtrs_since) < 12]
dtw[, post := as.integer(qtrs_since > 0)]
dtw[, D_DT := as.factor(as.Date(D_DT))]
dtw[, gap := unins_time_deps_assets - ins_time_deps_assets]

eqv <- unique(dtw[!is.na(equity_assets_22q4), .(ID_RSSD, equity_assets_22q4)])
med_eq <- median(eqv$equity_assets_22q4)
eqv[, eq_h := factor(fifelse(equity_assets_22q4 <= med_eq, "Below", "Above"),
                     levels = c("Below", "Above"))]
dtw[eqv, on = "ID_RSSD", eq_h := i.eq_h]
dtw <- dtw[!is.na(eq_h)]
dtw[, post_high := post * high_cecl_equity]

setFixest_fml(
  ..c_full = ~ log_total_assets_l1 + equity_assets_l1 + int_expense_assets_l1,
  ..fe = ~ ID_RSSD + D_DT
)
# post x half and High-CECL x half lower-order terms included; the half main
# effect is absorbed by bank FE.
fit_half <- function(y) {
  m <- feols(.[y] ~ i(eq_h, post_high) + i(eq_h, post) + i(eq_h, high_cecl_equity) +
               ..c_full | ..fe, data = dtw, vcov = ~ID_RSSD)
  ct <- as.data.table(coeftable(m), keep.rownames = "term")[grepl("post_high", term)]
  setnames(ct, c("term", "est", "se", "t", "p"))
  ct[, half := sub("eq_h::(\\w+):post_high", "\\1", term)]
  ct[, y := y]
  ct[]
}
ct <- fit_half("unins_time_deps_assets")   # gap version dropped from the slide (Sep 15)
ct[, `:=`(lo = est - 1.645 * se, hi = est + 1.645 * se)]
ct[, stars := fifelse(p < .01, "***", fifelse(p < .05, "**", fifelse(p < .1, "*", "")))]
ct[, lab := fifelse(p < .1, sprintf("%+.2f%s", est, stars), sprintf("%.2f (ns)", est))]
ct[, ylab := fifelse(y == "gap", "Uninsured \u2212 insured gap", "Uninsured time deposits")]
ct[, hlab := fifelse(half == "Below", "Thin capital", "Thick capital")]
ct[, label := paste0(hlab, "\n(equity/assets ", fifelse(half == "Below", "below", "above"), " median)")]
row_order <- c(
  ct[y == "unins_time_deps_assets" & half == "Below", label],
  ct[y == "unins_time_deps_assets" & half == "Above", label])
ct[, label := factor(label, levels = rev(row_order))]
ct[, col := fifelse(p < 0.1, primary_blue, accent_gray)]

# Horizontal dot-whisker, same style as ci_plot() in slide_figs_20260811.R
# (fig_s_coef_margin): significant rows in blue, insignificant in grey.
p_cq <- ggplot(ct, aes(x = est, y = label)) +
  geom_vline(xintercept = 0, color = negative_red, linetype = "dashed",
             linewidth = 0.7) +
  geom_errorbar(aes(xmin = lo, xmax = hi), width = 0.16, orientation = "y",
                color = ct$col, linewidth = 1) +
  geom_point(color = ct$col, size = 4) +
  geom_text(aes(label = lab), vjust = -1.3, size = 5.6, color = ct$col,
            fontface = "bold") +
  scale_y_discrete(expand = expansion(add = 0.55)) +
  theme_slide(18) +
  theme(plot.margin = margin(8, 14, 6, 8),
        panel.grid.major.y = element_blank(),
        axis.text.y = element_text(size = rel(1.0), hjust = 1)) +
  labs(x = "DiD estimate on uninsured time deposits (pp of assets), High-CECL banks", y = NULL)
ggsave(file.path(SLIDE_FIG, "fig_s_capital_quartiles.png"), p_cq,
       width = 10.4, height = 4.2, bg = "white", dpi = 200)
cat("Wrote: fig_s_capital_quartiles.png\n")

# -----------------------------------------------------------------------------
# 4. Capital x maturity 2x2: DiD effect on uninsured time deposits by
#    (below/above-median 2022Q4 equity) x (high/low share of uninsured time
#    deposits maturing within one year at 2022Q4; maturity_split_20260807.qmd)
# -----------------------------------------------------------------------------
# Input: td_maturity_2022q4_20260807.csv (01d_pull_td_maturity_20260807.py)
mat <- fread(file.path(TRACK_DATA, "td_maturity_2022q4_20260807.csv"))
setnames(mat, "IDRSSD", "ID_RSSD")
q4 <- panel[as.Date(D_DT) == as.Date("2022-12-31"), .(ID_RSSD, unins_td_22q4 = unins_time_deps)]
mat <- mat[q4, on = "ID_RSSD", nomatch = NULL]
mat[, short_share := fifelse(unins_td_22q4 > 0,
                             pmin((mat_lt3m + mat_3to12m) / unins_td_22q4, 1), NA_real_)]
med_short <- median(mat$short_share, na.rm = TRUE)
mat[, high_short := as.integer(short_share >= med_short)]
dtw[mat, on = "ID_RSSD", high_short := i.high_short]
dtw[, cell := fifelse(is.na(high_short), NA_character_,
              paste0(fifelse(eq_h == "Below", "thin", "thick"), "_",
                     fifelse(high_short == 1, "short", "long")))]
dt2 <- dtw[!is.na(cell)]
dt2[, cell := factor(cell, levels = c("thin_short", "thin_long", "thick_short", "thick_long"))]

# Same 2x2 for a chosen outcome; returns the coefficient table.
plot_2x2 <- function(y, stub, xlab) {
  m_2x2 <- feols(.[y] ~ i(cell, post_high) + i(cell, post) +
                   i(cell, high_cecl_equity) + ..c_full | ..fe, data = dt2, vcov = ~ID_RSSD)
  c2 <- as.data.table(coeftable(m_2x2), keep.rownames = "term")[grepl("post_high", term)]
  setnames(c2, c("term", "est", "se", "t", "p"))
  c2[, cell := sub("cell::(\\w+):post_high", "\\1", term)]
  c2[, `:=`(lo = est - 1.645 * se, hi = est + 1.645 * se)]
  c2[, stars := fifelse(p < .01, "***", fifelse(p < .05, "**", fifelse(p < .1, "*", "")))]
  c2[, lab := fifelse(p < .1, sprintf("%+.2f%s", est, stars), sprintf("%.2f (ns)", est))]
  cell_lab <- c(
    thin_short  = "Thin capital, short-maturity book\n(both margins bind)",
    thin_long   = "Thin capital, long-maturity book",
    thick_short = "Thick capital, short-maturity book",
    thick_long  = "Thick capital, long-maturity book\n(neither margin binds)")
  c2[, label := factor(cell_lab[cell], levels = rev(cell_lab))]
  c2[, col := fifelse(p < 0.1, primary_blue, accent_gray)]

  p_2x2 <- ggplot(c2, aes(x = est, y = label)) +
    geom_vline(xintercept = 0, color = negative_red, linetype = "dashed", linewidth = 0.7) +
    geom_errorbar(aes(xmin = lo, xmax = hi), width = 0.16, orientation = "y",
                  color = c2$col, linewidth = 1) +
    geom_point(color = c2$col, size = 4) +
    geom_text(aes(label = lab), vjust = -1.3, size = 5.6, color = c2$col, fontface = "bold") +
    scale_y_discrete(expand = expansion(add = 0.55)) +
    theme_slide(18) +
    theme(plot.margin = margin(8, 14, 6, 8),
          panel.grid.major.y = element_blank(),
          axis.text.y = element_text(size = rel(1.0), hjust = 1)) +
    labs(x = paste0("DiD estimate on ", xlab, " (pp of assets), High-CECL banks"), y = NULL)
  ggsave(file.path(SLIDE_FIG, paste0(stub, ".png")), p_2x2,
         width = 10.4, height = 5.2, bg = "white", dpi = 200)
  cat("Wrote:", stub, "\n")
    c2[]
}
c2       <- plot_2x2("unins_time_deps_assets", "fig_s_capital_maturity_2x2", "uninsured time deposits")
c2_total <- plot_2x2("unins_deps_assets", "fig_s_capital_maturity_2x2_total", "total uninsured deposits")

# --- diagnostics -------------------------------------------------------------
cat("\n================ DIAGNOSTICS ================\n")
cat("Histogram banks:", nrow(treat), "| High:", sum(treat$cecl_equity >= CECL_THRESHOLD_PCT),
    "| near-zero:", sum(abs(treat$cecl_equity) <= NEAR_ZERO_TOL),
    "| exactly zero:", sum(treat$cecl_equity == 0), "\n")
cat("Placebo balanced banks by group:\n"); print(d[dt == BASE_Q, .N, by = grp])
cat("Capital median (2022Q4 equity/assets):", round(med_eq, 2), "\n")
cat("Capital-split DiD rows:", nrow(dtw), "| banks:", uniqueN(dtw$ID_RSSD), "\n")
cat("High-CECL banks per half:\n")
print(unique(dtw[high_cecl_equity == 1, .(ID_RSSD, eq_h)])[, .N, by = eq_h][order(eq_h)])
print(ct[, .(y, half, est = round(est, 3), se = round(se, 3), p = round(p, 3))])
cat("2x2: median short share:", round(med_short, 3), "| rows:", nrow(dt2),
    "| banks:", uniqueN(dt2$ID_RSSD), "\n")
cat("High-CECL banks per cell:\n")
print(unique(dt2[high_cecl_equity == 1, .(ID_RSSD, cell)])[, .N, by = cell][order(cell)])
print(c2[, .(cell, est = round(est, 3), se = round(se, 3), p = round(p, 3))])
cat("2x2, total uninsured deposits:\n")
print(c2_total[, .(cell, est = round(est, 3), se = round(se, 3), p = round(p, 3))])
