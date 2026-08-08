# Track Notes — fdic-brc-jfqa-aug2026

## 2026-08-07

### Done
- v3: strip-to-main-story rewrite per Cochrane 2005 — solo "I" voice, no forward section refs, robustness+heterogeneity cut, floats in mention order (38pp).
- v4: 27 PDF sticky-note comments addressed (extract via pypdf from build/main.pdf, `/Subtype /Text`) — level DiD now central result, triple-diff demoted to conservative check (43pp final).
- New Robustness section: predictors table (moved from background) + SVB-exposure table (tbl_svb_exposure_20260807, 3 cols, log assets+equity/assets in all specs).
- New combined measure: ins brokered + reciprocal DiD = +0.811**/+0.175** (robustness_svb_20260807.qmd, tbl_ins_wholesale_20260807); extensive margin null.
- Maturity corroboration (Option A, prose-only §6.1): 2022Q4 predetermined ≤1yr-maturity split → high −0.544* vs low −0.229, interaction ns, caveats stated. Code: 01d_pull_td_maturity_20260807.py + maturity_split_20260807.qmd.
- Signal validation (equity −2.771 trough / CDS +190.8bp) restored to background; figs were already in track figures/.
- Author block + Fed Richmond disclaimer on title page; davernas2023deposit added to main.bib (operational-deposits footnote).
- academic-writing-lessons.md written to docs/.

### Dead ends
- Quarterly maturity-flow triple (lagged HK12 share × post × HighCECL): wrong-sign ns — survivorship makes post-period maturing share endogenous; design uninformative, do not revive.
- Account-count DiD (RC-O F052, log 1+n accounts >$250k): Post×CECL +0.0076** WRONG SIGN — item counts all products incl. operating accounts; unusable as depositor-exit evidence.
- First pdf-annotation extract via regex missed page numbers (nested /Pages kids); use pypdf.

### Lessons
- User leaves review comments as PDF sticky notes in build/main.pdf — extract with pypdf before each revision round; build/ gets clobbered by recompile, so harvest before compiling.
- RCON5597 (est. uninsured deposits) reported only by banks ≥$1B; paper proxy is RCONF051 (all banks, ~99% coverage). 20 sample banks file FFIEC 031.
- HK12/HK13/K222 (unins TD maturity) live in FFIEC duckdb `schedule_rce` (activity_year/quarter cols, no date col; idrssd is IDRSSD), NOT in call_report_data_20260401 rds.
- bs_panel assets in $thousands — <$10B filter is `assets < 10e6`.
- Style invariants now enforced: no em dashes (---) anywhere; no results in float captions/notes (method only); no forward section refs outside intro; "I" not "we"; floats in exact mention order (verify with diff of \ref vs \label sequences).
- here::here() roots at Rscript cwd — run all track R from project root, not scratchpad.
- Old robustness/heterogeneity text archived: sections/*/archive/*_v3cut_20260807.tex.

### Added later same day
- Capital-buffer heterogeneity IN PAPER as new §6.5 + Table 4 (tbl_capital_het_20260807, capital_het_20260807.qmd): Post×CECL×equity22q4 gap version +0.0665***/binary +0.3074***; effect dies at equity ≈ 12–13 (75th pctile 11.73). Robust to dropping equity_l1 control, winsorized moderator. Only weak cell: level binary interaction (0.0898 ns) — disclosed in text. 44 pp build, float order verified.
- Battery variants that did NOT survive: rank-transformed moderator (interaction ns — monotone transform flattens tails) and demeaned parametrization (same fit, only relabels main effect); winsorized-level moderator is the keeper.
- Consistency check that sells Table 4: implied effect at median equity (9.84) ≈ −0.075 ≈ baseline continuous DiD (−0.072).
- "Info intermediaries" paragraph (DepositAccounts/Bauer/Weiss health ratings republish Call Reports for retail CD shoppers) proposed, NOT yet added — closes the "do depositors read Schedule RI-A" gap; zero regressions.

### Next
- Not done: git commit (never authorized), slides, discussant memo, preflight/figure-table-crosscheck skill runs.
- Pennacchi Q&A backup slide candidate: maturity split numbers (in NOTES + memory, code reproducible).
- 28 of 30 cited papers missing from paper-repo (only iyer2016tale, chen_bank_transparency present) — run literature-downloader if wanted.
