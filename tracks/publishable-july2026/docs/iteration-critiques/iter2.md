# Iteration 2 — Critique and Rewrite Log

## Editor voice

Robustness runs 8 subsections and 12 tables. That is a technical appendix, not a paper. Consolidate. Every referee-response paper post-rejection over-includes; the corresponding acceptance-track paper leaves the reader with one convincing table per objection.

## Referee A voice

- The paired continuous+binary event-study subfigures in §4 (Time Deposits, Financial Outcomes) tell the same story twice. Kill the continuous panels; report a footnote number.
- The alternative-scaling result has two tables (assets, loans) with identical inference. One suffices.
- The saturated triple-diff table (Table \ref{tab:triple_diff_saturated}) exists to show "identical coefficients." Two sentences in the flexcontrols_td paragraph does the same job.
- Not-yet-adopted placebo, subsample-baseline, and early/late tables are three different views of the same evidentiary asymmetry. Consolidate to prose citations of a single number each.

## Cut list

Tables removed (24 → 16):
- `tbl_flexcontrols_binary_20260612` (subsumed by continuous)
- `tbl_triple_diff_saturated_20260612` (cite in prose only)
- `tbl_alt_scaling_loans_20260612` (assets suffices)
- `tbl_placebo_notyet_20260612` (single-number prose citation)
- `tbl_soph_earlylate_20260612` (single-number prose citation)
- `tbl_soph_subsample_20260612` (single-number prose citation)
- `tbl_td_excl_brokered_20260612` (single-number prose citation)
- `tbl_outlier_20260612` (single-number prose citation)

Figures removed (36 → ~20):
- All 5 `_cecl_cont` continuous event-study subfigures (uninsured TD, insured TD, int expense, ROA, NIM)
- All 5 `es_soph_split_*_2019w_20260612.png` (robustness — table only)
- `fig_es_cohorts_calendar_20260612` (event-time version suffices)
- `fig_es_long_ins_20260612`, `fig_es_long_unins_nocovid_20260612`, `fig_es_long_ins_nocovid_20260612` (keep 1 of 4)
- `fig_es_resid_20260612` (cite in prose only)
- `fig_es_reciprocal_20260612` (fold into brokered figure)

Prose:
- Robustness §5.5 (scaling): compress to one paragraph, drop loans reference.
- Robustness §5.6 (nonlinearity): drop outlier subparagraph, fold into cutoffs.
- Robustness §5.7 (destination): drop `tbl_td_excl_brokered` paragraph, one-line reference.
- Heterogeneity §6.3–6.4: fold both into a single "robustness of the sophistication split" paragraph.
- Identification §4.3 (info content): trim to first paragraph only.

## Rewrite log

Files touched:
- `tables_figures.tex` — table/figure removals.
- `robustness_current.tex` — consolidate §5.5, §5.6, §5.7, §5.2 placebo.
- `heterogeneity_current.tex` — merge §6.2–§6.4.
- `identification_current.tex` — compress §4.3.
- `results/empirical_results_current.tex` — remove `_cecl_cont` subfigure references if any.

## Result
- Pages: 61 (was 76, -15)
- Tables: 15, Figures: 12
- 0 undefined refs after fixup of sec:robustness:nonlinearity → sec:robustness:scaling
