# Revision Plan: Addressing JMCB Referee Comments

**Paper:** Depositor Discipline in Community Banking: Evidence from the CECL Information Shock
**Decision:** Rejected at JMCB (Editor: Luc Laeven, June 8, 2026; MS#26-156-1)
**Track:** `tracks/post-jmcb-rejection-june2026/`
**Reports:** `docs/jmcb-referee-reports/`
**Date:** June 12, 2026

---

## 1. Overview and Strategy

Both referees like the question and the identification idea; both attack (i) the SVB confound, (ii) the strength of the exogeneity claims, and (iii) loose ends in mechanism and robustness. The revision strategy:

- **No major revamp.** Same design, same sample, same data sources. Add targeted new tests from existing Call Report, SOD, ACS/IRS, Y-9C, CRSP, and Bloomberg data already in `data/raw/`.
- **Reframe the narrative** so the SVB episode is confronted head-on in the identification section rather than discussed defensively on p. 20. Drop the "absent a crisis trigger" framing — it is indefensible given 2023Q1 timing. New framing: the CECL Day-One adjustment provides *bank-specific, predetermined variation in disclosed credit risk*, and the SVB episode is an attention amplifier whose differential effects we explicitly control for and test against.
- **Pre-empt future referees** by tightening overclaiming (signal-validation, "predetermined"), adding a mechanism discussion, and reporting full specifications.

Every comment below is tagged **[New analysis]**, **[Writing]**, or **[Both]**, with the data fields and scripts to be used. Baseline code to extend: `tracks/jmcb-june2026/code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd` (main DiD/event study/triple-diff), `descriptive_stats_20260403.R` (Tables 1–2, Figures 1–2). New scripts go in `tracks/post-jmcb-rejection-june2026/code/`.

---

## 2. Comment-by-Comment Response Plan

### Referee A — Major Comments

#### RA1. Identification: anticipation and truncated pre-trends — [Both]

> CECL finalized 2016; adoption timeline known years in advance; depositors could pre-position. Pre-trends start only 2020Q3. Low R² in Table 2 equally consistent with omitted variables. Show pre-trends back to 2018/2019; show residualized CECL generates similar results.

**New analyses:**

1. **Extended pre-trends.** Raw Call Report data covers 2016Q1–2025Q4 (`data/raw/call_report_data_20260401_*.rds`). Extend the event-study window from `|k| < 12` (set at line ~207 of `small_bank_multi_outcomes_20260403_v4.qmd`) to start in 2018Q1 (k ≈ −20 for the 2023Q1 cohort). Report the long event study for uninsured time deposits / assets in both binary and continuous treatment versions. COVID quarters (2020Q1–Q2) included with shading/caveat — see RA6.
2. **Residualized treatment.** Regress `cecl_equity` on the (expanded — see RB-M1) Table 2 predictors; use the residual as the treatment in the baseline DiD and event study. Report alongside baseline. If coefficients are similar, the result is not driven by the observable component the referee worries about.

**Writing:**
- Soften "predetermined" claims throughout (`identification_current.tex`). New language: the *magnitude* of the Day-One adjustment is fixed by the accumulated loan book and the modeling choices made at adoption; it cannot respond to 2023 deposit flows. Acknowledge anticipation explicitly and point to (a) flat extended pre-trends and (b) the fact that the Day-One number itself was not forecastable by depositors with any precision before disclosure (banks themselves struggled to estimate it — cite implementation-cost literature).
- Reframe the low Table 2 R² honestly: not "evidence of exogeneity" but evidence that the adjustment is hard to predict from standard observables; the residualized-treatment test carries the identification weight.

#### RA2 + RB1. The SVB confound — [Both] — *highest priority*

> RA: Quarter FE remove only the average 2023Q1 effect, not differential SVB-induced scrutiny correlated with CECL exposure. RB: Disclosure period coincides exactly with the panic; "absent a crisis trigger" framing untenable; near-immediate reaction suspicious; cite Caglio et al. (2024). RB suggests (i) 2022Q4 characteristics × quarter FE, (ii) exploit disclosure/adoption timing.

**New analyses:**

1. **Flexible characteristics-by-time controls (RB's suggestion 1).** Add 2022Q4 bank characteristics interacted with calendar-quarter fixed effects to the main DiD and event-study specs: uninsured deposit share, log assets, equity/assets, NPL ratio (RCON1403/RCON2122), ROA, CRE share (RCONF160+F161), brokered deposit share (RCON2365), and unrealized securities losses (already used in Table 2). This absorbs any post-SVB repricing of *pre-existing* fundamentals. Surviving CECL coefficient = response to the disclosure itself. This is the single most important new table in the revision.
2. **Adoption-timing test (RB's suggestion 2).** Adoption is staggered 2022Q3–2023Q4 (assignment at lines ~179–181 of the main qmd). Run cohort-specific event studies: do depositor responses align with each cohort's *own adoption quarter* or with calendar 2023Q1 (SVB)? Three cuts:
   - Event-time event study estimated separately for the 2022Q3–Q4 early cohort, the 2023Q1 cohort, and the 2023Q2–Q4 late cohort.
   - Robustness: drop the 2023Q1 cohort entirely; show the effect survives in off-SVB cohorts (smaller N — report power honestly).
   - Calendar-time placebo: within *not-yet-adopted* banks as of 2023Q1, does the (future) CECL adjustment predict 2023Q1 uninsured deposit outflows? If SVB scrutiny loads on CECL-type fundamentals, it should show up here; if the disclosure is the trigger, it should not.
3. **Timing-of-information discussion (RB's "near-immediate reaction").** Document the disclosure timeline precisely in the institutional background: Call Reports for quarter t are filed ~30 days after quarter-end and publicly posted by FFIEC/FDIC shortly thereafter; the 2023Q1 Day-One adjustment became public end-April/May 2023, i.e., *after* the March panic peak. The event-study k=0 coefficient should be interpreted accordingly; verify and state whether the k=0 effect is small relative to k=1, 2, ... (gradual buildup supports disclosure-driven interpretation over panic-driven).

**Writing:**
- Move the SVB discussion from p. 20 into the identification section (`identification_current.tex`), as a named subsection ("The 2023 banking stress and identification").
- Delete "absent a crisis trigger" everywhere (abstract, intro, conclusion). Replace: discipline operates through *disclosed, bank-specific credit-risk information*, identified within a period of heightened depositor attention; the tests above separate the disclosure response from generalized panic responses.
- Cite Caglio, Dlugosz & Rezende (2024) and engage directly with the flight-to-safety pattern at community banks.

#### RA3. Signal-validation overclaimed — [Writing]

> Abstract/intro present market-cap and CDS results (e.g., "191 bps per unit of CECL exposure") as established findings while Section 5.5 acknowledges the COVID confound. Inconsistent.

- Demote the large-bank exercise to "suggestive background evidence" in abstract and intro; remove point-estimate language from the abstract.
- Re-title the section (e.g., "Suggestive evidence that markets price the Day-One adjustment").
- Align all three discussions (abstract, intro, Section 5.5) at the cautious level. No new analysis: the 2020 cohort cannot be cleaned of COVID with existing data, and we say so plainly.

#### RA4. Sophistication results fragile — [Both]

> Quantity triple-interaction is −0.022 (s.e. 0.468) — visual, not statistical. ROA sophistication interaction (~30 bps) exceeds baseline ROA effect (~15 bps) — needs reconciliation. Index built from 2022 deposit weights → reverse causality.

**New analyses:**

1. **Pre-period weights.** Rebuild the sophistication index using **2019 SOD branch-deposit weights** (SOD file covers 2012–2025: `data/raw/fdic_sod_2012_2025_20260328.rds`) merged to the same ZIP demographics. 2019 weights predate COVID, the adoption window, and any CECL-related depositor response. Show robustness of the heterogeneity results to this index. (Keep 2022 index as baseline or swap — decide on results.)
2. **Early/late post split.** Split post into early (k=0–4) and late (k≥5) windows in the triple-interaction so the gradual quantity buildup gets a statistical test instead of a visual one. Report both coefficients.
3. **Subsample baselines.** Estimate the baseline DiD separately for high- and low-sophistication banks (all four outcomes). This directly answers the magnitude puzzle: if low-sophistication banks show ~zero baseline effect, the 30-vs-15 bps arithmetic is internally consistent — show it rather than assert it.

**Writing:** Add a paragraph reconciling the magnitudes explicitly (weighted average of subsample effects = full-sample baseline). Acknowledge the residual reverse-causality concern and explain why 2019 weights mitigate it.

#### RA5. Equity denominator mechanical — [Both]

> CECL/equity mechanically larger for low-equity banks; Post × low-equity may capture rate-environment adjustment by capital-constrained banks, not information.

**New analyses:** Re-run baseline DiD and event study with the Day-One adjustment scaled by (a) total assets (RCON2170) and (b) total loans (RCON2122). Re-define the binary treatment at the corresponding within-scaling median/threshold. One robustness table, all four outcomes.

**Writing:** Discussion of the denominator choice in the variable-construction part of `data_current.tex`: equity scaling captures the solvency relevance of the charge (what a depositor cares about); asset/loan scalings capture pure portfolio-risk intensity; results robust to all three. Note that the equity-to-assets control and the new characteristics-×-time interactions (RA2 fix) absorb the capital-constraint channel directly.

#### RA6. COVID quarters excluded from pre-trends — [New analysis]

> Pre-period only 10 quarters; excluding 2020Q1–Q2 "too convenient." Show pre-trends with COVID quarters included.

Folded into the RA1 extended event study: window starts 2018Q1 and **includes** 2020Q1–Q2 (shaded in figure, caveat in note). Report both with and without COVID quarters so the reader sees nothing is hidden.

#### RA8. No lending-side analysis — [New analysis]

> Higher funding costs + lower profits ⇒ theory predicts tighter credit supply. Granja-Nagel cited for exactly this. Add loan growth analysis.

Add a "real effects" subsection: DiD and event study with quarterly loan growth as the outcome — total loans (RCON2122), and splits for C&I (RCON1766) and CRE (RCONF160+F161). Same specs, same controls. Whatever the sign, report it: a credit-supply contraction completes the story; a null bounds the real costs of disclosure-induced discipline. This also serves RB-M2 (banks' strategic responses).

### Referee A — Minor Comments

| # | Comment | Response |
|---|---|---|
| RA-m1 | Table 1: High-CECL banks have higher *insured* time deposits at baseline; Section 6.1 discussion ignores asymmetry | [Writing] Add discussion: baseline insured-deposit asymmetry is consistent with high-CECL banks already relying more on insured funding; the triple-diff is identified off *changes*, and the new characteristics-×-time controls (RA2) absorb differential trends loading on baseline deposit mix |
| RA-m2 | Figure 4: insured time deposit pre-adoption coefficients −0.5 to −0.7, uncommented, at odds with parallel trends | [Both] Re-estimate with extended window + flexible controls; if the dip persists, discuss it explicitly in the text (likely rate-environment composition effects); never leave a visible pattern uncommented |
| RA-m3 | Table 4 triple-diff omits level interactions (Post × CECL, CECL) — saturation unverifiable | [Both] Report the fully saturated specification — all lower-order interactions shown or explicitly noted as absorbed by FE (CECL alone absorbed by bank FE; state this in the table note) |
| RA-m4 | No mechanism for how community-bank depositors observe Call Reports | [Writing] New subsection in institutional background: FFIEC/FDIC public posting and BankFind, rate aggregators and bank-rating services (e.g., Bauer, Weiss, DepositAccounts), municipal/public-funds treasurers with statutory monitoring duties, deposit brokers and listing services, local press coverage of bank financials; cite depositor-monitoring literature. Tie to the sophistication heterogeneity: exactly the depositors most plausibly consuming these disclosures react most |
| RA-m5 | Insufficient discussion of economic magnitudes | [Writing] Add a magnitudes paragraph after each main table: translate coefficients into dollars for the median bank, fraction of a within-bank SD, aggregate effect across the high-CECL cohort, and comparisons to estimates in the cited literature |

### Referee B — Major Comments

#### RB1. SVB confound — see RA2 above (combined response).

#### RB2. Where did the deposits go? SUTVA and market-based deposit insurance — [Both]

> If funds moved to low-CECL community banks, effects are mechanically amplified / SUTVA violated. Post-SVB growth of reciprocal-deposit arrangements (Kim, Kundu & Purnanandam 2024) could mechanically convert uninsured to insured deposits, especially for sophisticated depositors. Use branch-level data.

**New analyses:**

1. **Substitution into insured wholesale funding.** DiD with brokered-deposit outcomes: total brokered (RCON2365), insured brokered (RCONHK05), uninsured short-maturity brokered (RCONK220), each scaled by assets. If high-CECL banks replaced fleeing uninsured time deposits with insured brokered funding, this shows up directly — and is itself evidence of costly discipline (price channel), not a confound.
2. **Reciprocal-deposit caveat.** The current Call Report pull does **not** include the reciprocal-deposits field (RCONJH83, RC-E Memo 1.g). Two options, decide at implementation: (a) small re-pull of this one series from the same FFIEC bulk source (same data source, not new data — recommended); (b) if not pulled, use insured-brokered (RCONHK05) as the closest available proxy and say so. Either way, test directly whether High CECL × Post predicts growth in reciprocal/insured-brokered balances, and whether the uninsured→insured composition shift in the triple-diff survives excluding banks with large reciprocal growth.
3. **SUTVA / local spillover test.** Use branch-level SOD (2012–2025, annual): for each bank, compute exposure to high-CECL *competitors* (deposit-weighted share of own-branch counties/ZIPs occupied by high-CECL banks' branches). Test whether low-CECL banks more exposed to high-CECL competitors gained deposits post-adoption. Quantifies reallocation; bounds the SUTVA amplification. (Annual SOD frequency limits power — acknowledge.)

**Writing:** New robustness subsection "Where do the deposits go?"; cite Kim, Kundu & Purnanandam (2024); discuss the interpretation: reallocation toward safer banks **is** market discipline operating, but the estimated coefficient is a relative effect — state this plainly and use the spillover test to size it.

### Referee B — Minor Comments

| # | Comment | Response |
|---|---|---|
| RB-m1 | Table 2 omits deposit composition, non-core funding, local market characteristics, performance/loan-quality trends | [New analysis] Expand Table 2 predictors: uninsured & insured deposit shares, time-deposit share, brokered share, 2-yr trends in ROA and NPL, county deposit HHI from SOD. Doubles as the first stage for the residualized-CECL test (RA1) |
| RB-m2 | Engage literature on banks' strategic responses to CECL — depositors may react to bank behavior, not the disclosure | [Both] Expand literature discussion; the lending analysis (RA8) tests the most obvious strategic margin; check capital/provisioning behavior descriptively (ACL ratio RIAD3123, equity ratio paths by treatment). Argue timing: Day-One adjustment is disclosed simultaneously with any first strategic response — pre-trends + immediate deposit response pattern bound the scope |
| RB-m3 | Explore alternative CECL cutoffs; nonlinearity; symmetric tails (negative adjustments) | [New analysis] (i) Bin the treatment: quartiles or deciles of CECL Adj, plot DiD coefficients across bins — informational interpretation predicts convexity (small adjustments ≈ no effect, large ones disproportionate); (ii) alternative thresholds (top 25%, top 10%) vs. current 2.5%-of-equity rule; (iii) symmetric-tails test: bottom-decile (most negative/favorable Day-One) banks — do they *gain* uninsured deposits? |
| RB-m4 | Figure 1 outlier warrants discussion | [Both] Identify the outlier bank(s) in the CECL distribution; verify not a data error; report robustness to winsorizing/dropping; add a sentence to the figure note |

---

## 3. Prioritized Work Plan

### Tier 1 — Identification (deal-breakers at any journal)
1. Flexible 2022Q4-characteristics × quarter-FE specification (RA2/RB1) — **the key new table**
2. Adoption-timing / cohort tests + drop-2023Q1-cohort robustness + not-yet-adopted placebo (RB1)
3. Extended pre-trends to 2018Q1, with and without COVID quarters (RA1, RA6)
4. Residualized-CECL treatment with expanded Table 2 (RA1, RB-m1)
5. Alternative scalings: CECL/assets, CECL/loans (RA5)

### Tier 2 — Mechanism and completeness
6. Brokered/insured-brokered (± reciprocal re-pull) destination tests + SOD spillover test (RB2)
7. Sophistication: 2019 weights, early/late split, subsample baselines (RA4)
8. Lending-side analysis: loan growth DiD (RA8, RB-m2)
9. Nonlinearity: binned treatment, alternative thresholds, symmetric tails (RB-m3)
10. Figure 1 outlier check (RB-m4)

### Tier 3 — Writing (do last, after results are in)
11. Restructure identification section around SVB; kill "absent a crisis trigger" (RA2/RB1)
12. Demote signal-validation in abstract/intro (RA3)
13. Mechanism subsection: how depositors observe Call Reports (RA-m4)
14. Economic-magnitudes paragraphs (RA-m5)
15. Table 1 asymmetry, Figure 4 insured pre-dip, Table 4 saturation notes (RA-m1–m3)
16. Disclosure-timeline paragraph in institutional background (RB1 timing)
17. Add citations: Caglio-Dlugosz-Rezende (2024), Kim-Kundu-Purnanandam (2024); expand CECL bank-response literature (RB-m2)

### Suggested script layout (new track)
- `code/sample-construction/01_build_panel_<date>.R` — extend panel to 2018Q1+, add loans/NPL/brokered fields, both alternative CECL scalings
- `code/result-generation/main_results_<date>.qmd` — baseline + Tier 1 specs
- `code/result-generation/destination_spillovers_<date>.qmd` — Tier 2 items 6
- `code/result-generation/heterogeneity_<date>.qmd` — sophistication rebuild
- `code/result-generation/lending_nonlinearity_<date>.qmd` — items 8–9

---

## 4. Items Not Fully Addressable with Existing Data (flag honestly in the paper)

| Issue | Limitation | Mitigation |
|---|---|---|
| Reciprocal deposits (RCONJH83) | Not in current pull | Optional one-field re-pull from FFIEC bulk (same source); else insured-brokered proxy |
| Large-bank 2020 COVID confound (RA3) | Cannot be cleaned with existing data | Demote framing; no new claims |
| Depositor-level destination of withdrawn funds | No account-level data | Bank-level brokered/insured substitution + SOD spillovers bound the answer; state limits |
| Disclosure *filing-date* variation within quarter (RB1) | Exact filing timestamps not in pull | Use cohort-level adoption-quarter variation instead; note filing dates as future extension |
