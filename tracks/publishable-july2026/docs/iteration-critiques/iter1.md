# Iteration 1 — Critique and Rewrite Log

## Editor voice

85 pages is a rejection at any journal short of a book chapter. Half the
manuscript reads as a running commentary on itself: every section opens by
telling the reader what the section will do, closes by telling them what
just happened, and cross-references the same three identification arguments
in three different places. The paper wants to be a JBF submission (~35-40
pages typeset) but reads like an unabridged referee-response memo.

## Referee A voice

The institutional background section devotes an entire subsection ("How
community-bank depositors observe Call Report information") to speculative
plumbing that neither the theory nor the empirical design uses. Cut. The
identification section reprises the 2023-stress confound narrative that
robustness §1 will develop with the actual tables — pick one home. The
introduction's "signal validation" paragraph promises what §4.6 already
labels "suggestive rather than definitive"; delete the paragraph, the
result stays in the paper.

## Concrete cut list (target ~15 pages)

- Strip every `%%============ Structure/Changes/Cross-refs` block comment from all 10 section files. Purely author-facing scaffolding.
- Inst-bg §1.4 (observation channels): delete (28 lines).
- Inst-bg §1.1 opening ILM-historiography paragraph: compress from 15 to 6 lines.
- Inst-bg §1.3 phase-in footnote: fold to one line.
- Identification §4.6 signal-validation: cut to a two-sentence pointer at end of §4.4; drop the Panel A/B recitation.
- Identification §4.3 second half ("What distinguishes CECL Day-One from routine…"): delete — repeats §1.
- Identification §4.4 stress paragraph: keep threat statement, defer three-piece response to robustness (do not preview inline).
- Intro ¶5 signal validation: delete.
- Intro ¶6 dollar magnitudes ("$1.3M for median treated bank"): move to results, not intro.
- Robustness "Extended Pre-Trends" prose: trim explanation of why F-tests reject.
- Conclusion policy paragraph: cut Correia et al. historical excursion; one-sentence policy point.
- Data §2.1 opening ("Our empirical design draws on four sources"): remove — table of sources is the sources.

## Rewrite log

Files touched:
- `abstract/abstract_current.tex` — strip block header only.
- `intro/intro_current.tex` — strip header + delete signal-validation ¶ + trim dollar magnitudes.
- `institutional-background/inst_bg_current.tex` — strip header + delete §1.4 + compress §1.1 opening + one-line phase-in footnote.
- `data/data_current.tex` — strip header + compress §2.1 opening.
- `identification/identification_current.tex` — strip header + delete §4.6 + delete §4.3 back half + collapse §4.4 stress preview.
- `results/desc_stats_current.tex` — strip header only.
- `results/empirical_results_current.tex` — strip header only.
- `heterogeneity/heterogeneity_current.tex` — strip header only.
- `robustness/robustness_current.tex` — strip header + trim extended-pre-trends prose.
- `conclusion/conclusion_current.tex` — strip header + collapse policy paragraph.

## Post-compile stats

Filled after compile.

## Result
- Pages: 76 (was 85, -9)
- Tables: 24, Figures: 36 (unchanged in this iter)
- PDF: build/main_iter1.pdf
