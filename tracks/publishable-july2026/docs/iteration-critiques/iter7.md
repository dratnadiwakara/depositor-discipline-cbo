# Iteration 7 — Address Identification Referees (1, 2, 3, 7)

Second of the two response iterations. Responds to hostile-referee simulation. No new regressions — frozen inputs; responses add explicit acknowledgment and re-interpretation using existing tables.

## What this iter answers

- **Ref 1 (Day-One exogeneity)**: modeling-choice channel explicitly acknowledged. Residualized-treatment robustness reframed as bounding the forward-looking-macro-forecast component.
- **Ref 2 (triple-diff bad-control)**: add non-deposit-funding sanity check reference; clarify what bank $\times$ quarter FE absorb and what they do not; concede active substitution is present at destination.
- **Ref 3 (SVB confound; placebo damning)**: re-read placebo transparently. Explicit statement that placebo is consistent with two mechanisms (credit-fundamentals proxy and forward-looking depositor anticipation) and that the composition contrast, not the placebo, carries identification.
- **Ref 7 (inference under common shock)**: acknowledge that bank-clustering may understate uncertainty when 92\% of the sample adopts in a single quarter; recommend two-way clustering as future extension; note that qualitative conclusions are unchanged under coarser inference.

## Edits

- `identification/identification_current.tex` §4.2: add modeling-choice paragraph and clarify residualization scope.
- `identification/identification_current.tex` new §4.5 or existing §4.4: add inference footnote.
- `results/empirical_results_current.tex` after triple-diff: add one-paragraph clarification of what bank $\times$ quarter FE do and do not absorb.
- `robustness/robustness_current.tex` §5.2: rewrite placebo paragraph to be transparent about both readings.

## Result
- Pages: 55 (was 53, +2 for added defenses). 0 undefined refs.

## Referee coverage after iter 7

| Referee | Attack | Response | Fully addressed? |
|---|---|---|---|
| R1 | Modeling-choice endogeneity in Day-One | Explicit paragraph in ID §4.2; residualization framed as bound | Partial (still need new regression) |
| R2 | Triple-diff insured arm endogenous | New clarification paragraph in results | Partial (concedes; reframes claim) |
| R3 | SVB confound; placebo damning | Placebo paragraph rewritten transparent | Partial |
| R4 | Magnitude vs 2023 panic | Scope paragraph in results §opening | Fully
| R5 | Narrow outcome (time deposits only) | Scope paragraph in results §opening | Fully
| R6 | Sophistication proxy | Renamed, added limitation | Fully
| R7 | Bank-clustering under common shock | New footnote in ID §4.1 | Partial (acknowledged; not recomputed) |
| R8 | Wrong literature | Rewrote intro contribution ¶ | Fully
| R9 | No headline table | Added Table 1 headline summary | Fully
| R10 | Policy overreach | Rewrote policy paragraph in conclusion | Fully
