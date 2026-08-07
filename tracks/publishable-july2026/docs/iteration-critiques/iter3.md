# Iteration 3 — Critique and Rewrite Log

## Editor voice

Results section still narrates twice: once as a level DiD, again as a triple-difference "anchor result." Pick one. The composition shift is the identified result — lead with it, keep levels as a supporting one-line reference. Sophistication section is too long for a channel that the paper honestly says is "statistically imprecise in pooled interactions." Cut in half.

## Referee A voice

- Descriptive statistics runs three subsections and repeats what the tables already show. Compress to one page.
- Financial consequences section reports six coefficients twice (continuous and binary, each times three outcomes). Two sentences, one table reference, done.
- Identification §4.3 ("Information Content, Not Cash Flows") is a manifesto restated three ways. One paragraph.
- Signal-validation subsection is retained because it is our only market-price evidence — but it need not be a subsection; a footnote pointer to the figure suffices.
- Data section could lose two subsections' worth of connective tissue.

## Cut list

- `results/empirical_results_current.tex`: rewrite around triple-diff as headline. Levels get one paragraph pointing at Table \ref{tab:small_bank_did_time_deposits}. "Why time deposits" ¶ shrinks to one sentence.
- `results/desc_stats_current.tex`: three subsections → one, tighter.
- `heterogeneity_current.tex`: drop the group-specific DiD reconciliation prose (still present in prose after iter 2 merge).
- `robustness_current.tex`: shorten stress, timing, pre-trends, resid, scaling, destination, lending — each trimmed by ~25%.
- `identification_current.tex`: §4.3 collapsed to one paragraph; §4.6 signal validation becomes a footnote.
- `data/data_current.tex`: fold §2.1 into §2.2; remove §2.6 (validation sample — one-sentence pointer inside signal-validation footnote).
- `institutional-background/inst_bg_current.tex`: remove §1.3 timing prose that is repeated in ID §4.4.

## Post-compile stats

Filled after compile.

## Result
- Pages: 55 (was 61, -6). 0 undefined refs.
