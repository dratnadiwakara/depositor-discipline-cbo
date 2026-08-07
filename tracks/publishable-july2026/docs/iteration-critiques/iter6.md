# Iteration 6 — Address Framing Referees (4, 5, 6, 8, 9, 10)

Responds to hostile-referee simulation `docs/referee-simulations/negative-reports-x10.md`. Iter 7 (next) handles identification referees (1, 2, 3, 7).

## What this iter answers

- **Ref 9 (presentation)**: add a summary/headline table pulling six main coefficients together before the individual results tables.
- **Ref 5 (narrow outcome)**: explicit scope discussion — why time deposits, what aggregate uninsured trends show, what we do not claim.
- **Ref 4 (magnitude)**: aggregate-level framing of the $0.6B implied reallocation, positioning vs 2023 panic magnitudes.
- **Ref 6 (sophistication)**: rename "depositor sophistication" → "branch-market financial-sophistication proxy" throughout, and add honest limitation.
- **Ref 10 (policy)**: rewrite the policy paragraph to match evidence weight; drop the Correia analogue as a load-bearing citation.
- **Ref 8 (literature)**: extend the disclosure-literature paragraph in the introduction to acknowledge the analyst-reactions and information-sensitivity strands.

## Cut list / additions

- `tables/tab00_headline_summary.tex` — new file, headline coefficients (uninsured DiD, insured DiD, triple, interest expense, ROA, NIM), binary column only, hand-composed from existing tables.
- `tables_figures.tex` — insert tab00 as first empirical float after descriptive stats.
- `results/empirical_results_current.tex` — new opening paragraph pointing at headline table; scope-and-magnitude sub-paragraph before financial-consequences.
- `heterogeneity_current.tex` — rename measure throughout; add limitation sentence.
- `data/data_current.tex` — rename `Sophisticated` label to "branch-market sophistication proxy" in prose.
- `intro/intro_current.tex` — add disclosure-literature engagement; tighten policy claim.
- `conclusion/conclusion_current.tex` — rewrite policy paragraph.

## Post-compile stats

Filled after compile.

## Result
- Pages: 53 (was 51, +2). Added headline table + scope/magnitude prose. 0 undefined refs.
