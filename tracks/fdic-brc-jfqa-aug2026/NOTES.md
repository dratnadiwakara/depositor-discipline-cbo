# Track Notes — fdic-brc-jfqa-aug2026

## 2026-08-11 (PDF comment round)

### Done
- Harvested 23 sticky notes from build/main.pdf → docs/memos/pdf-comments_20260811.md (numbered checklist, all 23 addressed, all marked done). Harvest BEFORE any compile; build/ is clobbered.
- Table 11 (tbl_svb_exposure_bsr) DELETED, replaced by Figure 7 fig:svb_exposure: 3 panels (2 top, 1 below) of binned means with 95% CIs vs Day-One decile — unrealized sec. loss, weighted avg maturity, HRP Balance Sheet Risk. New: svb_exposure_figs_20260811.qmd + 01g_pull_maturity_20260811.py → data/maturity_2022q4_20260811.csv.
- §7.2 rewritten around the figure; the four table coefficients (0.016, −0.003, −0.406, R²<1%) survive as prose only.
- Table 2 split across two floats via \ContinuedFloat so Panel B gets its own page and still numbers as "Table 2 (continued)"; Panel B gained a Sample header row (Full / High maturity / Low maturity / Full) via etable `headers=` in maturity_split_20260807.qmd → tbl_maturity_split_20260811.tex.
- 2020 SEC-filer cohort corrected: "roughly one hundred" → 192 holding companies (217 have a 2019–21 Day-One number; 192 CRSP-linked, 162 adopting in 2020). Verified in scratchpad check_cohort_n*.R.
- Intro para 1 split in two; huberdeau2025adverse now cited there for the reciprocal/sweep/brokered → weaker discipline + moral hazard point. "Six pieces of evidence" → five (posted-rate stress-week null dropped from the list). SEC-filer validation broken into its own paragraph.
- jordan1999impact (FRB Boston WP) → jordan2000market (JFI 9(3) 298–319), per author's supplied BibTeX. Old entry left in main.bib, now unused.

### Lessons
- `cecl_equity` in market_and_cds_large_banks_20260401.qmd is CECL/equity as a FRACTION, so the −2.771 mktcap coefficient is per 100pp: one pp → 2.8% lower market cap. Do not read those coefficients as per-percentage-point.
- The 2022Q4 bulk file mislabels RCONA568 as "OVR 15 Y". It is over 5 through 15 years (A569 is >15y) — confirmed by the parallel A553/A554 and A574/A575 descriptions. Midpoints 10/20 are right.
- Full-sample deciles of the Day-One adjustment are useless: 53% exactly zero, 15% negative. Any decile plot of this treatment must restrict to strictly positive adjustments (N=1,383).
- `etable(..., headers = list("Sample" = c(...)))` passes through export_track_tbl's `...` and is the way to label split-sample columns.

### Next
- Re-harvest on the next annotated PDF (new dated file in docs/memos/).
- Still unrun: /skills/bib-validator (jordan2000market page range unverified; blickle2024who lacks RFS vol/pages), /skills/latex-preflight-check, figure-table-crosscheck.

## 2026-08-11

### Done
- Gap-check of main.bib vs Huberdeau-Reid (Pennacchi) reference list; 6 Tier A refs added + cited: bischof2021accounting, blankespoor2013fair, pennacchi2006deposit, lambert2017insured, ioannidou2010deposit, park1998market (Tier B reciprocal/brokered + Tier C sweep/FHLB/BTFP identified, NOT added).
- NEW FHLB pipeline: 01e_pull_fhlb_20260809.py (reads existing ffiec_bulk_cache in post-jmcb track, no network) + 01f_convert_fhlb_20260809.R → fhlb_advances_20260809.rds (152,264 rows, 2018Q2–2025Q4, 52.9% any advance).
- FHLB is a clean NULL both pre-adoption (0.10, SE 0.12, k=−4→−1) and post (0.034, SE 0.182); contrast with HRP, who find FHLB draws in 2023Q1 AFTER the failures.
- Table 7 restructured twice, final = THREE SEPARATE INSTRUMENTS, no aggregation: ins brokered 0.086*/0.521**, reciprocal 0.089*/0.290 ns, term FHLB 0.017/0.034 ns; combined 0.811** now one TEXT clause only.
- fig:es_ins_wholesale REPLACED by fig:es_brokered_ins (fig_es_brokered_ins_20260809, es_figs_20260808.qmd §1); shows the k=−4..−1 pre-funding ramp, defended in caption as anticipation not pre-trend violation.
- Reciprocal demoted out of abstract/intro/conclusion; swap mechanism now written into Table 7 note + §6.7 prose so it is defensible cold to Pennacchi.
- TIMING FIX (author caught it): phase-in election is measured AT adoption (first CECL Call Report), not "quarters before" — abstract + conclusion reworded; intro was already correct.
- NotebookLM podcast-instruction block (2,502 chars) written to scratchpad for the HRP paper.

### Dead ends
- Bank-level subordinated debt (RCON3200): nonzero for only 0.37% of banks — issued at the holding company; needs FR Y-9C/Y-9SP. Do not retry at bank level.
- IV of Δ uninsured TDs on the Day-One charge (cross-section): first-stage F = 2.3, p = 0.13. Do not revive.
- Tier 1 leverage ratio as the Table 4 moderator: triple 0.0264 (0.0175) p=0.13, binary 0.0122 — heterogeneity dies. Explored, NOT adopted; author left Table 4 unchanged.
- AOCI explanation for the equity-vs-leverage wedge: WRONG, corr(equity/assets, unrealized loss 22Q4) = −0.001.
- `knitr::knit()` and purl-inside-`-e` segfault on robustness_svb qmd (R 4.4.3 and 4.5.3); purl to a file then `Rscript` that file works.
- `etable(..., keep=)` silently printed nothing — extract coefficients directly instead.

### Lessons
- `leverage_ratio` in the raw rds is a FRACTION (median 0.10); `equity_assets_22q4` is in pp. Multiply by 100 before comparing or thresholding.
- RC-M 5.a F055–F058 partition FHLB advances by remaining maturity / next repricing date; term = F056+F057+F058; F059 (structured) is a memo subset — never add it in.
- Buffer framing (moderator − T) is an AFFINE SHIFT: triple identical for every T, only the main effect moves. Worth doing anyway — SE falls 0.210→0.072 at T=8 because T=0 extrapolates to a zero-equity bank. equity/assets has NO statutory minimum (real thresholds exist only for the leverage ratio: PCA 4/5%, CBLR 9%).
- Marginal-effect profile of Table 4 (gap cont): −0.402*** at 6% equity, −0.269*** at 8, −0.136** at 10, −0.003 at 12 — dies at 12, matches the 12–13 in the text.
- UNUSED DEFENCE: horse race of equity/assets vs 2022Q4 unrealized losses leaves eq triple STRONGER (0.0745***) and unrealized-loss triple −0.0570**, i.e. discipline is stronger where securities marks were SMALLER — opposite of the SVB-vulnerability story.
- pdflatex exits 1 with "I can't write on file `main.pdf'" whenever the PDF is open in a viewer; a `&&` chain hides this and the error grep never runs. ALWAYS check exit code + build/main.pdf timestamp before claiming a clean build.
- Bank-level substitution (scratchpad): Δ ins wholesale on Δ unins TDs = −0.24 pooled, −0.48 High-CECL, −0.83** interaction among reciprocal users. Descriptive only, no identification — cannot replace Table 7.
- Known overstatement left in place by author's decision: "brokered certificates are booked as time deposits" — true definitionally, but pass-through is only 0.18 and ins brokered exceeds ins time deposits in 22% of user bank-quarters.

### Next
- Optional additions never applied: FHLB null as explicit robustness columns, bank-level substitution sentence, unrealized-loss horse race as a seventh stress defence.
- Still not done: git commit (never authorized), slides, discussant memo, /skills/bib-validator, preflight + figure-table-crosscheck runs.

## 2026-08-08

### Done
- Literature integration: 14 new refs (jordan1999impact, huberdeau2025adverse, cipriani2024tracing, morgan2002rating, davila2023optimal, rate-null set, challenge papers); intro novelty narrowed to conjunction, positioned by name vs Jordan-Peek-Rosengren + Chen et al. 2022.
- Full citation verification: all 46 keys checked against paper-repo/mds with quotes; report at `.claude/cc/citation-claim-verifier/2026-08-08_fdic-brc-jfqa-aug2026.md`; 6 miscites fixed (gee=equity investors, caglio=flight TO large, chen2022does=tightened, davernas footnote, hannan re-homed, Dávila-Goldstein fiscal cost).
- SVB placebo IN PAPER (svb_placebo_20260808.qmd → tbl_svb_placebo_20260808): zero-CECL banks (n=2,278; |CECL| median = 0!), Post-SVB × 2022Q4 unrealized loss on unins TDs = +0.073** WRONG SIGN for run; horse race leaves CECL coefs at −0.078**/−0.406**; sixth stress defense in intro.
- HRP (Pennacchi) alignment: BSR approx = (unins deps + fed funds purch)/(TA − sec unreal losses); corr with CECL Adj −0.013, conditional coef −0.406*** NEGATIVE; now col (4) of tab:svb_exposure (tbl_svb_exposure_bsr_20260808).
- Table 2 now 6 cols + Panel B: cols 5-6 TOTAL uninsured deps NULL (+0.073/−0.177 ns), framed as scope (operating balances, no rollover decision), banned after §6.2; Panel B = maturity split (tbl_maturity_split_20260808, exported from maturity_split_20260807.qmd).
- Two PDF comment rounds (6 + 8 notes): magnitudes out of abstract+intro ¶1; huberdeau cite in costs ¶; fifth defense trimmed; "pure noise" sentence simplified; S&P dropped; ES-pooling → footnote; TD share 12.7% + brokered/reciprocal rows in Table 1 (tab01_sumstats_ext_20260808.R); §6.2 "changed insurance status" recast (buckets can't distinguish trimming-below-cap from new money); §6.5 opening simplified; Table 7 component table CUT, §6.7 argues from combined table only.
- New ES figures (es_figs_20260808.qmd): single-panel combined ins-wholesale ES (replaces 2-panel fig) + 3-panel financial ES (int exp/ROA/NIM) as new fig:es_financial.
- Scratchpad-only HRP results (NOT in paper): listing-service DiD null; sweep cross-section null on CECL, BSR +2.72*** (replicates HRP sweep finding); scripts scratchpad/hrp_alignment.R.
- Build: 50 pp, 0 undefined. ai-vault gained citation-claim-verifier + pdf-comment-harvester skills, Cochrane sentence-level style blocks, mention-order float insertion.

### Dead ends
- SVB placebo binary split: full-sample median (2.176) vs zero-CECL-subsample median (2.227) give 0.239* vs 0.173 ns — paper prose quotes continuous only; don't mix split bases.
- etable `extra_lines` arg not supported by installed fixest — sample-split labels go in float notes instead.
- Rscript -e with multi-line data.table code segfaults intermittently — write script file to scratchpad and run that.

### Lessons
- CECL treatment numerator = RIADJJ28 (RI-E item 4, allowance effect; 47247: 4,850); RIADJJ26/B507 = retained-earnings effect (−5,135, after-tax). cecl_adj_raw=JJ26, CECL=JJ28 in raw rds.
- build/main.pdf LOCKED while user has it open — latexmk fails at final write ("I can't write on file"); user's sticky notes may be UNSAVED in viewer when harvest returns 0 — ask user to save+close, then harvest BEFORE compiling.
- Unrealized loss vars are gain-signed ((fair−amortized), losses negative) — flip sign for loss-intensity treatments.
- HRP deposit quantity object = TOTAL uninsured (never unins TDs); their rate object = insured/uninsured TD implicit rates (same as ours); scale = Δ/2022Q4 total liabilities; small = <$5B.
- FFIEC duckdb: listing service = RCONK223, fully insured sweeps = MT87+MT91 (schedule_rce/rcei); sweeps only from 2021H2, semiannual for small banks — no pre-period for DiD.
- Table 2 col 1-4 replication gate when regenerating: −0.0724/−0.3935/0.0699/0.7117.

### Next
- User to eyeball: Table 2 two-panel page fit; Figure 5 (combined ES drifts from deep pre-period — check it reads OK vs anticipation story).
- Still not done: commit (never authorized), slides, discussant-prep memo, /skills/bib-validator (blickle2024who lacks RFS vol/pages), preflight + figure-table-crosscheck runs.
- Remaining HRP alignment options not done: sub-$5B robustness, HRP-style Δ/liabilities column for magnitude comparability.

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
