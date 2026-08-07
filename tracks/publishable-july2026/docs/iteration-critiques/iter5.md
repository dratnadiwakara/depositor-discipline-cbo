# Iteration 5 — Final Coherence Pass

## Editor voice

Prose is tight; float overhead now dominates length. Drop two figures whose evidence is already table-summarized. Verify every remaining table/figure is referenced and every reference resolves. Prune bibliography to only cited entries. One final prose sweep on transitions between sections.

## Cuts

- Drop `fig:es_large_banks_market_cds`: cited only in a footnote in Section~\ref{sec:identification:stress}. The footnote already characterizes the pattern; the figure adds a page for no independent evidentiary value in a paper whose identification does not rely on this cohort.
- Drop `fig:es_flexcontrols`: `tab:flexcontrols` already delivers the level-DiD attenuation and `tab:flexcontrols_td` delivers the composition-shift persistence. The figure repeats the shape at compressed magnitude.
- Move signal-validation footnote to reference the two large-bank fig files in-line as a citation rather than a figure environment — the underlying result is retained; only the standalone float is removed.
- Bibliography: verify all cite keys resolve.

## Post-cut coherence check

- `\ref{fig:es_large_banks_market_cds}` — remove from identification footnote.
- `\ref{fig:es_flexcontrols}` — remove from robustness §5.1 (prose reads fine without).

## Verification

- All `\ref{}` and `\cite{}` resolve (bibtex log clean).
- Every `\label{}` under `sections/**` referenced somewhere.
- Cold-read: abstract, intro ¶3, conclusion ¶1 all telegraph the same one-sentence claim.

## Result

Filled after compile.

## Result
- Pages: 51 (was 53, -2). 0 undefined refs. Final.

## Progression
- iter0 (baseline): 85 pp, 24 tables, 36 figures
- iter1: 76 pp — killed section-header comment blocks; trimmed intro, inst-bg, id
- iter2: 61 pp — consolidated robustness; -8 tables (24→15), -13 figures (36→13)
- iter3: 55 pp — restructured results around triple-diff; tightened het & id
- iter4: 53 pp — prose polish; conclusion + intro compressed
- iter5: 51 pp — dropped 2 low-value figures (large-bank ES, flexcontrols ES)
