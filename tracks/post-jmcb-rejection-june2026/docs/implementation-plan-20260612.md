# Implementation Plan: Post-JMCB Revision

**Implements:** `docs/revision-plan-20260612.md`
**Track:** `tracks/post-jmcb-rejection-june2026/`
**Baseline code:** `tracks/jmcb-june2026/code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd` (main), `descriptive_stats_20260403.R`, `market_and_cds_large_banks_20260401.qmd`
**Shared utilities:** `code/_common.R` (threshold `CECL_THRESHOLD_PCT = 2.5`, `compute_qtrs_since()`, `winsorize_by_date()`, `extract_es_data()`, `make_es_plot()`, `make_split_es_plot()`, `covariate_labels_dict`, etable globals)
**Date:** June 12, 2026

---

## Phase 0 — Conventions and Setup

- All new code lives in `tracks/post-jmcb-rejection-june2026/code/`; outputs to track-local `latex/figures/`, `latex/tables/`, `data/`.
- Date-stamped filenames (`_YYYYMMDD`). `save_figures` / `save_tables` flags at top of each script. Figures `bg = "white"`.
- Unlike the JMCB track (panel rebuilt in memory inside the qmd), the new track builds the panel **once** in a sample-construction script and saves to `tracks/post-jmcb-rejection-june2026/data/`. Four result qmds consume it. Rationale: five new analysis files would otherwise each duplicate a ~60M raw load and the de-cumulation logic.
- Keep `CECL_THRESHOLD_PCT = 2.5` as the baseline binary cutoff; alternative cutoffs are a robustness dimension (Phase 2d).
- Do not modify `code/_common.R` macros; track-local additions (new covariate labels, helpers) go in a small `tracks/post-jmcb-rejection-june2026/code/_track_common.R` sourced after `_common.R`.

### New covariate labels needed (in `_track_common.R`)

`cecl_assets` ("CECL Adj (Assets)"), `cecl_loans` ("CECL Adj (Loans)"), `cecl_resid` ("CECL Adj (Residual)"), `high_soph` triple-interaction labels, `post_early`/`post_late`, loan-growth outcomes, brokered outcomes, decile-bin labels.

---

## Phase 1 — Sample Construction

### 1.1 `code/sample-construction/01_build_panel_20260612.R`

Port the panel build from `small_bank_multi_outcomes_20260403_v4.qmd` (lines 107–225) into a standalone `.R` script; extend; save `data/panel_smallbank_<stamp>.rds`.

**Keep identical** (do not re-derive — replication anchor):
- Raw load: `data/raw/call_report_data_20260401_{1,2}.rds`; de-duplication; YTD de-cumulation of `interest_expense, interest_income, net_interest_income, net_income, nonint_expense, nonint_income`.
- `cecl_equity = CECL / equity_bop × 100`; small-bank filter (`total_assets < 10e6` thousand at 2022-12-31); adoption assignment = earliest quarter-end in 2022Q3–2023Q4 with non-missing `cecl_equity`; `high_cecl_equity = cecl_equity ≥ 2.5`; treatment frozen at adoption value; lagged controls; within-quarter 1/99 winsorization of ratio variables.

**Add — treatment rescalings (RA5):** at the adoption observation,
- `cecl_assets = CECL / total_assets × 100` (RCON2170)
- `cecl_loans = CECL / total_loans × 100` (RCON2122)
- `high_cecl_assets`, `high_cecl_loans`: binary at the same within-scaling percentile rank as the 2.5%-of-equity cutoff implies for `cecl_equity` (compute the percentile of 2.5 in the `cecl_equity` adoption distribution; apply that percentile to the other scalings — keeps treated-group size comparable). Freeze at adoption as for baseline.

**Add — new outcome variables (all ×100, denominators > 0 guarded, winsorized with the existing ratio list):**
- `loans_assets = total_loans / total_assets`
- `loan_growth = 100 × Δlog(total_loans)` by bank; `ci_growth`, `cre_growth` analogously (CRE = `cre_owner_occ + cre_other`)
- `brokered_assets = brokered_deposits / total_assets`; `brokered_ins_assets = brokered_deps_ins / total_assets`; `brokered_unins_lt1yr_assets = brokered_deps_unins_lt1yr / total_assets`

**Add — predictor / control variables:**
- `npl_loans = nonaccrual_loans / total_loans × 100`; `acl_loans = acl_eop / total_loans × 100`
- `unreal_loss_assets = ((afs_fair_value − afs_amortized_cost) + (htm_fair_value − htm_amortized_cost)) / total_assets × 100`
- `unins_dep_share = unins_deps_excl_ret / total_deposits × 100`; `time_dep_share = (unins_time_deps + ins_time_deps + time_deps_lt100k) / total_deposits × 100`
- `cre_loans_share = (cre_owner_occ + cre_other) / total_loans × 100`

**Add — frozen 2022Q4 characteristics for flexible controls (RA2/RB1):** one column per characteristic, value at `D_DT == 2022-12-31`, broadcast to all bank quarters, suffix `_22q4`: `unins_dep_share_22q4`, `log_ta_22q4`, `equity_assets_22q4`, `npl_loans_22q4`, `roa_22q4`, `cre_loans_share_22q4`, `brokered_share_22q4`, `unreal_loss_assets_22q4`.

**Add — residualized treatment (RA1):** cross-section at adoption: `feols(cecl_equity ~ <expanded Table 2 predictors, see 1.3>)`; `cecl_resid = resid()`; `high_cecl_resid` at same percentile rule. Merge back.

**Add — reciprocal deposits (decided):** RCONJH83 (RC-E Memo 1.g) is not in the existing rds pull; download the series from FFIEC bulk Call Report data (same source as the existing pull) for 2016Q1–2025Q4, merge by `ID_RSSD × D_DT`, construct `reciprocal_assets = reciprocal_deps / total_assets × 100` (winsorized with the ratio list). Keep the download step in a clearly marked block so the rest of the script runs without it if FFIEC access fails.

**Do NOT truncate the event window here.** Keep all quarters 2016Q1–2025Q4 with `qtrs_since`; window choices (`|k| < 12` baseline; extended 2018Q1; COVID in/out) made in result scripts.

**End with the mandatory `cat()` diagnostic block** (CLAUDE.md): N rows, N banks, date span, NA counts for `cecl_equity/cecl_assets/cecl_loans/cecl_resid` and each new outcome, p1/p50/p99 of all treatments and outcomes, treated-group counts under each binary definition, cross-correlations of the four treatment variants.

### 1.2 `code/sample-construction/02_build_sophistication_20260612.R`

Port the SOD/ACS construction (qmd lines 419–479) and produce **two indices**:
- `frac_soph_2022` — existing construction (2022 SOD weights × 2022 ZIP demographics). Replication anchor.
- `frac_soph_2019w` — **2019 SOD branch-deposit weights** (`YEAR == 2019` in `data/raw/fdic_sod_2012_2025_20260328.rds`) merged to the same ZIP sophistication classification (keep 2022 ACS demographics — the endogeneity concern is the deposit *weights*, not the slowly-moving ZIP characteristics; state this in the paper).
- `high_soph_2022`, `high_soph_2019w` at the 75th percentile (current rule, `quantile(.., 0.75)`).
- Save `data/sophistication_<stamp>.rds`. Diagnostic block: match rates to small-bank sample, correlation and cross-tab of the two indices, share of banks switching classification.

### 1.3 `code/sample-construction/03_build_spillover_exposure_20260612.R` (RB2 SUTVA)

From SOD (all years 2018–2025) + the adoption-quarter treatment map from 1.1:
- For each bank b and year t: county-level branch deposits. Competitor exposure: `expo_b = Σ_c w_bc × HighCECLshare_c`, where `w_bc` = bank b's 2022 deposit share across counties c, and `HighCECLshare_c` = deposit share of *other* banks' branches in county c belonging to high-CECL banks (2022 SOD weights, treatment from adoption map).
- Bank-year outcome: `sod_dep_growth = 100 × Δlog(total SOD deposits of bank b)`.
- Save `data/spillover_exposure_<stamp>.rds`. Diagnostics: distribution of `expo`, county counts, N banks.

---

## Phase 2 — Result Generation

All qmds: `type: source` front matter, `rm(list = ls())`, source `_common.R` then `_track_common.R`, load the Phase-1 rds files, `setFixest_fml()` macro block mirroring qmd lines 228–242, clustering `vcov = ~ID_RSSD` throughout, 90% CI event-study plots via `make_es_plot()`.

**Declared expectations (per CLAUDE.md regression rule).** Unit: bank-quarter. Sample: small-bank adopter panel. FE: bank + quarter unless stated. Expected signs:

| Test | Key coefficient | Expected |
|---|---|---|
| Flexible controls | Post × CECL, uninsured time deps | negative, attenuated but significant |
| Cohort timing | response aligned with own adoption quarter | effects at own k=0+, not calendar 2023Q1 |
| Not-yet-adopted placebo | future CECL × 2023Q1 | zero |
| Residualized CECL | Post × CECL_resid | negative, similar to baseline |
| Alt scalings | Post × CECL(assets/loans) | negative |
| Loan growth | Post × High CECL | negative or zero |
| Brokered insured | Post × High CECL | positive (substitution) |
| Spillover | expo × post, low-CECL banks | positive |
| Bottom-decile CECL | Post × BottomDecile, uninsured time deps | positive (weak prior) |
| Sophistication 2019w | triple interactions | same pattern as 2022 index |

### 2.1 `code/result-generation/main_results_20260612.qmd` (Tier 1)

**§0 Baseline replication.** Re-run the four core outputs on the new panel with `|qtrs_since| < 12`: DiD time-deposits table, DiD financial-outcomes table, triple-diff table, uninsured/insured event studies. Numbers must match the JMCB versions (same data vintage, same code path) — this is the regression-side verify-before-moving-on gate. Export as the revision's baseline Tables 3–5 / Figure 4 equivalents.

**§1 Flexible characteristics-by-time controls (RA2/RB1 — the key new table).**
Spec: baseline DiD augmented with 2022Q4 characteristics × quarter FE via fixest varying-slopes syntax:
```r
feols(unins_time_deps_assets ~ post * cecl_equity + ..controls + int_expense_assets_l1
      | ID_RSSD + D_DT[unins_dep_share_22q4, log_ta_22q4, equity_assets_22q4,
                       npl_loans_22q4, roa_22q4, cre_loans_share_22q4,
                       brokered_share_22q4, unreal_loss_assets_22q4],
      data = dt_w, vcov = ~ID_RSSD)
```
Columns: (1) baseline, (2) + size/capital × time, (3) + deposit-mix × time, (4) full set — continuous and binary treatment panels. Repeat for the triple-diff. Companion event-study figure under the full set. Export `tbl_flexcontrols_<stamp>.tex`, `fig_es_flexcontrols_<stamp>.png`.

**§2 Adoption-timing tests (RB1).**
- Cohort split on `adopt_dt`: early (2022-09-30, 2022-12-31), main (2023-03-31), late (2023-06-30/09-30/12-31). Event studies by cohort (binary treatment), overlaid with `make_split_es_plot()` in *event time*; companion figure in *calendar time* (coefficients on `i(D_DT, high_cecl_equity)` by cohort) with 2023Q1 marked — the visual argument that responses track own adoption, not March 2023.
- Drop-2023Q1-cohort DiD: baseline table re-run on early+late cohorts only. Report N treated honestly.
- Not-yet-adopted placebo: sample = late-cohort banks, quarters ≤ 2023Q1; outcome = Δ uninsured time deps in 2023Q1; regressor = (future) `cecl_equity`; controls as baseline. Expected zero.
- Exports: `tbl_cohort_timing_<stamp>.tex`, `fig_es_cohorts_<stamp>.png`, `tbl_placebo_notyet_<stamp>.tex`.

**§3 Extended pre-trends (RA1/RA6).**
- Window: all quarters 2018Q1 → 2025Q4 (k from ≈ −20). Event studies (binary and continuous) for uninsured time deps: (a) full window including 2020Q1–Q2 with shaded COVID band annotation; (b) excluding 2020Q1–Q2 (drop rows). Note: `i()` reference stays k = −1.
- Joint F-test on pre-period coefficients (k ≤ −2) reported in figure notes, both variants.
- Exports: `fig_es_long_unins_<stamp>.png`, `fig_es_long_unins_nocovid_<stamp>.png` (+ insured analogues).

**§4 Residualized treatment (RA1).** Baseline DiD + event study with `cecl_resid` / `high_cecl_resid` for uninsured time deps, interest expense, ROA. Side-by-side table with baseline. Export `tbl_resid_cecl_<stamp>.tex`, `fig_es_resid_<stamp>.png`.

**§5 Alternative scalings (RA5).** One table: uninsured time deps + interest expense + ROA, treatments `cecl_assets` and `cecl_loans` (continuous + binary). Export `tbl_alt_scaling_<stamp>.tex`.

**§6 Fully saturated triple-diff (RA-m3).** Current spec uses `bank_qt` FE, which *absorbs* `post`, `cecl`, `post × cecl` — the referee read this as an omission. Add: (a) a column with bank FE + quarter FE (no bank×quarter) reporting all lower-order interactions; (b) table note in the export stating exactly which terms the bank×quarter FE absorbs. Export `tbl_triple_diff_saturated_<stamp>.tex`.

### 2.2 `code/result-generation/destination_spillovers_20260612.qmd` (RB2)

**§1 Substitution into insured wholesale funding.** Baseline DiD (continuous + binary) for `brokered_assets`, `brokered_ins_assets`, `brokered_unins_lt1yr_assets`; event study for `brokered_ins_assets`. Export `tbl_brokered_<stamp>.tex`, `fig_es_brokered_ins_<stamp>.png`.

**§2 Composition shift robustness.** Triple-diff re-run excluding banks in the top quartile of post-adoption insured-brokered growth — does the uninsured→insured shift survive outside reciprocal-style substitutors? Export `tbl_td_excl_brokered_<stamp>.tex`.

**§3 SOD spillover test.** Bank-year panel (2018–2025), low-CECL banks only: `feols(sod_dep_growth ~ expo × post_2023 | ID_RSSD + year, vcov = ~ID_RSSD)` plus county-level version with county FE. Expected positive. Acknowledge annual frequency/power in the table note. Export `tbl_spillover_<stamp>.tex`.

**Reciprocal deposits (decided: pull).** RCONJH83 (total reciprocal deposits, RC-E Memo 1.g) pulled from FFIEC bulk in Phase 1.1; `reciprocal_assets` added as a direct outcome in §1 alongside the brokered set. Kim-Kundu-Purnanandam response becomes direct rather than proxied.

### 2.3 `code/result-generation/heterogeneity_20260612.qmd` (RA4)

**§1 Index robustness.** Replicate the sophistication triple-interaction table and split event studies under (a) `high_soph_2022` (replication anchor) and (b) `high_soph_2019w`. Report index correlation in text output.
**§2 Early/late post split.** `post_early = 1{0 ≤ k ≤ 4}`, `post_late = 1{k ≥ 5}`; triple interactions `post_early × high_cecl × high_soph` and `post_late × high_cecl × high_soph` for all five outcomes. This converts the "visual" quantity result into a statistical one (expect late-window quantity triple-interaction negative and significant).
**§3 Subsample baselines (magnitude reconciliation).** Baseline DiD estimated separately for high- and low-sophistication banks, all outcomes, one table. Text check: weighted average of subsample effects ≈ full-sample baseline.
Exports: `tbl_soph_2019w_<stamp>.tex`, `tbl_soph_earlylate_<stamp>.tex`, `tbl_soph_subsample_<stamp>.tex`, split-ES figures.

### 2.4 `code/result-generation/lending_nonlinearity_20260612.qmd` (RA8, RB-m3, RB-m4)

**§1 Lending.** DiD + event study for `loan_growth`, `ci_growth`, `cre_growth` (controls: `..controls` only; no interest-expense lag). Export `tbl_lending_<stamp>.tex`, `fig_es_loan_growth_<stamp>.png`.
**§2 Nonlinearity.** Quintile/decile bins of adoption `cecl_equity`: `feols(y ~ i(cecl_bin, post, ref = <middle bin>) + ..controls | ..fe)`; coefficient-by-bin plot (informational interpretation predicts convexity). Alternative binary cutoffs: top quartile, top decile. Export `fig_cecl_bins_<stamp>.png`, `tbl_alt_cutoffs_<stamp>.tex`.
**§3 Symmetric tails.** Indicator for bottom decile (most negative/favorable Day-One adjustment) vs middle 80%; uninsured time deps outcome. Expected positive, weak prior — report either way. Same table as §2.
**§4 Figure 1 outlier.** Identify max-`cecl_equity` bank(s); print identity/size/values; baseline DiD dropping them; one-line robustness note. (Winsorization is already within-quarter 1/99 — verify the outlier survives it and say so.)

### 2.5 `code/result-generation/descriptive_stats_20260612.R` (RB-m1)

Port `descriptive_stats_20260403.R`; expand Table 2 (CECL predictors) with: `unins_dep_share`, `time_dep_share`, `brokered_share`, 8-quarter pre-adoption trends in ROA and NPL (bank-level slope coefficients), county deposit HHI (from SOD 2022). Keep original columns as column (1); expanded as (2)–(3). This regression is also the first stage for `cecl_resid` (keep the spec in 1.1 in sync — single source: define the predictor list once in `_track_common.R`). Re-export Table 1, Figures 1–2 to track folders.

### 2.6 Large-bank file

`market_and_cds_large_banks_20260401.qmd` — no analytical change (RA3 is writing-only). Copy to new track, re-export with track paths, only if figure regeneration is needed for the new build.

---

## Phase 3 — LaTeX / Writing (after results are in)

Style: JF/RFS register throughout — active voice, claims sized to evidence, every coefficient translated into economic magnitude, no bullet lists in prose, table/figure notes self-contained (Journal of Finance style via `/skills/table-figure-descriptions`).

Per-file edits in `tracks/post-jmcb-rejection-june2026/latex/sections/`:

| File | Edits |
|---|---|
| `intro/intro_current.tex` | Remove "absent a crisis trigger" framing; reframe contribution: bank-specific, predetermined disclosure variation *within* a high-attention period, with the SVB confound addressed by design (preview flexible controls + timing tests). Demote signal-validation sentence: drop the 191 bps point estimate, call it suggestive. Add one magnitudes sentence per headline result. |
| `institutional-background/inst_bg_current.tex` | New ¶: disclosure timeline — Call Report filing deadline (~30 days after quarter-end), FFIEC/FDIC public posting, so 2023Q1 Day-One figures became public late April–May 2023, after the March panic peak. New subsection: how community-bank depositors observe Call Reports (FDIC BankFind, rating services, rate aggregators/listing services, deposit brokers, municipal/public-funds treasurers with statutory monitoring duties — note `dep_govt_nontrans` share as factual support; local press). Tie to sophistication heterogeneity. |
| `identification/identification_current.tex` | New subsection "The 2023 banking stress and identification" (moved from p. 20): the indirect-channel concern stated in the referees' own terms, then the three answers (flexible controls, cohort timing, placebo). Anticipation discussion: standard known since 2016 but Day-One *magnitude* not forecastable; extended pre-trends. Honest reframe of low Table-2 R²; residualized-treatment logic. Denominator discussion (equity = solvency relevance; robustness to assets/loans). |
| `data/data_current.tex` | New variables (loan growth, brokered splits, alternative scalings, 2022Q4 frozen characteristics); sophistication 2019-weight construction + rationale. |
| `results/results_current.tex` | Magnitudes ¶ after each main table (dollars for median bank, fraction of within-bank SD, aggregate across high-CECL cohort, comparison to literature). Insured-deposit baseline asymmetry discussion (Table 1). Comment on insured-deposit pre-adoption dip in the event study — re-examine under extended window/flexible controls; explain or report it, never leave it silent. Saturated triple-diff note. |
| `heterogeneity/heterogeneity_current.tex` | 2019-weight robustness; early/late split as the statistical version of the visual claim; subsample-baseline reconciliation arithmetic spelled out. |
| `robustness/robustness_current.tex` | New section organizing: flexible controls; cohort timing + placebo; extended pre-trends (±COVID); residualized CECL; alternative scalings; nonlinearity + symmetric tails; deposit destination (brokered, spillover, SUTVA discussion "Where do the deposits go?"); lending; outlier. |
| `conclusion/conclusion_current.tex` | Reframe headline claim consistently with intro; add real-effects (lending) sentence. |
| `main.bib` | Add: Caglio, Dlugosz & Rezende (2024); Kim, Kundu & Purnanandam (2024); 2–3 CECL bank-response papers (RB-m2; identify via `/agents/literature-downloader` if not already cited). Validate via `/skills/bib-validator`. |
| `tables_figures.tex` | Register all new exports via `/skills/latex-table-inserter` and `/skills/latex-figure-inserter`. |

Literature engagement (RB-m2): expand the CECL-response paragraph — banks' provisioning/capital/lending adjustments as an alternative channel; argue timing (Day-One disclosure simultaneous with first possible strategic response; flat pre-trends + immediate-quarter deposit pattern bound its scope); point to the lending analysis as the direct test.

---

## Phase 4 — Sequencing, Gates, Verification

**Order (dependencies):**
1. Phase 1 scripts (1.1 → 1.2/1.3 parallel). **Gate:** user reviews `cat()` diagnostic blocks before any regression runs.
2. 2.1 §0 replication. **Gate:** baseline matches JMCB-track numbers; if not, stop and reconcile before new specs.
3. 2.1 §1–§6, then 2.2–2.5 (independent of each other; any order). Run via `Rscript`/`quarto run` — never render.
4. Phase 3 writing, section by section, after the relevant results exist.
5. QA: `/skills/latex-compile post-jmcb-rejection-june2026`; `/skills/figure-table-crosscheck` (in-text numbers vs tables); `/skills/latex-preflight-check`; optionally `/agents/harsh-editor` for an adversarial pass before circulation.

**Per-result verification:** every new regression preceded by an in-chat assumptions declaration (unit, window, treatment, outcome, FE, expected sign — table above); every sample script ends in the diagnostic block; event-study figures inspected for the pre-period before tables are exported.

**Decisions (resolved 2026-06-12):**
1. Reciprocal-deposit re-pull (RCONJH83/JH84, RC-E Memo 1.g) — **yes**. Add to Phase 1.1 raw pull and to 2.2 §1 as a direct outcome (`reciprocal_assets = reciprocal_deps / total_assets × 100`); insured-brokered remains a companion outcome, not a proxy.
2. Sophistication index: **2022 baseline, 2019-weight as robustness** (current plan unchanged).
3. Target journal: **Journal of Banking and Finance**. JF/RFS prose register retained; JBF has no hard length constraint pressure, so the full robustness section ships in the main text rather than an internet appendix; format `main.tex` to JBF submission guidelines (Elsevier class acceptable at submission; keep current class until acceptance).

**Estimated scope:** ~3 sample-construction scripts, 4 result qmds + 1 descriptive R script, ~12 new tables, ~10 new figures, 9 section-file rewrites.
