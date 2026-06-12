# LaTeX Preflight Report — `latex/main.tex`

**Date:** 2026-04-10  
**Reviewed file:** `latex/main.tex` and all `\input{}` targets  
**Scope checked:** cross-references & labels, bibliography wiring, static build-risk, language & consistency, exhibit captions vs. table/figure outputs

---

## Summary Table

| # | Sev | Category | Location | Description |
|---|-----|----------|----------|-------------|
| 1 | **High** | build-risk | `main.tex:100` | `\autor{}` — undefined command, will fail compilation |
| 2 | **High** | bib | `main.tex:142` + 4 source files | 4 cite keys missing from `.bib`: `ACS2022`, `FASB2016`, `correia2026bank`, `narayanan2026decline` |
| 3 | **High** | figure/table | `abstract_20260408.tex:16` | Abstract says insured deposits are "unaffected" but table shows significant +0.712 increase (p<0.05) |
| 4 | **Med** | figure/table | `intro_section_20260409_v2.tex:91–94` | Triple-diff coefficient −1.252 attributed to "per percentage-point of CECL exposure" (continuous units), but −1.252 is the *binary* High CECL coefficient; continuous triple-diff is −0.177 |
| 5 | **Med** | figure/table | `tables_figures.tex:6` (financial outcomes table header) | Table column header "NIM/Assets (%)" is redundant — NIM is already net interest income / assets |
| 6 | **Med** | language | `data_and_sample_construction_20260406.tex` header | Header still says "New citation needed: IRS_SOI" — IRS SOI data is never formally cited in the text |
| 7 | **Med** | refs | `tables_figures.tex:83, 139` | Table captions for DID and triple-diff describe "post-2023Q1 indicator" but identification section defines `Post` as bank-specific adoption date |
| 8 | **Low** | build-risk | `main.tex:19,24,31,38,40–41,43` | Duplicate `\usepackage{}` declarations: `geometry` ×2, `hyperref` ×2, `graphicx` ×2, `booktabs` ×3, `color` ×2 |
| 9 | **Low** | figure/table | `tables_figures.tex:249` | Panel E label "Net interest margin / assets" is redundant — should be "Net interest margin" |
| 10 | **Low** | bib | `depositor-discipline-references.bib` | Entries never cited in manuscript: `acharya2015crisis`, `jiang2025monetary` (plus several others) |
| 11 | **Low** | language | Section comment headers throughout | Internal comment headers say "Depositor Discipline in *Modern* Banking" but paper title uses "*Community* Banking" |

---

## Detailed Issues

---

### Issue 1 — `\autor{}` undefined command

- **Severity:** High
- **Category:** build-risk
- **Location:** `latex/main.tex:100`
- **Problem:** `\autor{}` is not a standard LaTeX command. This will produce "Undefined control sequence: \autor" and halt or produce garbled output. `\author{}` is already set on line 97; line 100 appears to be a stale stub.
- **Evidence:** `main.tex` line 97: `\author{}`, line 100: `\autor{}`
- **Suggested fix:** Delete line 100 (`\autor{}`).

---

### Issue 2 — Four citation keys missing from `.bib`

- **Severity:** High
- **Category:** bib
- **Location:** See below
- **Problem:** Four keys cited in the manuscript have no entry in `latex/depositor-discipline-references.bib`. They will compile as `[?]` and bibtex will warn on every run.

| Key | Used in | Example location |
|-----|---------|-----------------|
| `FASB2016` | `institutional_background_20260406.tex:37` | `\citep{FASB2016}` after "ASU 2016-13" |
| `narayanan2026decline` | `data_and_sample_construction_20260406.tex:112` | `\citet{narayanan2026decline}` |
| `ACS2022` | `empirical_results_20260407.tex:174` | `\citep{ACS2022}` |
| `correia2026bank` | `conclusion_20260407.tex:60` | `\citet{correia2026bank}` (3,400 bank runs study) |

- **Evidence:** `grep` of all `\cite` calls across section files vs. `grep "^@"` of `.bib` — none of these four keys appear in the `.bib`.
- **Note:** The data section header comment explicitly flags `narayanan2026decline` and `IRS_SOI` as "New citation needed." `IRS_SOI` is never inserted as a `\cite{}` in the text, so it is a missing citation to add (see Issue 6).
- **Suggested fix:** Add complete BibTeX entries for all four keys.

---

### Issue 3 — Abstract says insured deposits "unaffected"; table shows significant positive effect

- **Severity:** High
- **Category:** figure/table (code/output mismatch)
- **Location:** `abstract_20260408.tex:16`
- **Problem:** The abstract states "The decline is confined to uninsured deposits while insured balances are **unaffected**." However, `small_bank_did_time_deposits_20260403.tex` column (4) shows a coefficient of +0.7117\*\* (SE 0.2905, p<0.05) — insured time deposits *increased significantly* for high-CECL banks after adoption. "Unaffected" is factually incorrect and will be noticed by a referee checking results against the abstract.
- **Evidence:**
  - Abstract: `abstract_20260408.tex` line 16: "insured balances are unaffected"
  - Table: `tables/small_bank_did_time_deposits_20260403.tex` col. 4: `0.7117**`
  - The introduction (para 3) is more accurate: "Insured time deposits, by contrast, show no statistically distinguishable *decline* — and if anything trend slightly upward." Even this is understated since the increase is significant.
- **Suggested fix:** Revise abstract to reflect the actual result, e.g.: "Insured deposits are unaffected or slightly increase, consistent with depositors restructuring balances rather than a uniform funding retreat."

---

### Issue 4 — Intro attributes −1.252 to the continuous specification (wrong units)

- **Severity:** Medium
- **Category:** figure/table (code/output mismatch)
- **Location:** `intro_section_20260409_v2.tex:91–94`
- **Problem:** The introduction describes the triple-difference result as "the triple interaction of **−1.252 percentage points of assets per percentage-point of CECL exposure**." The phrase "per percentage-point of CECL exposure" describes the *continuous* specification, but −1.252 is the coefficient from the *binary* High CECL specification (column 2 of the triple-diff table). The continuous triple-diff coefficient is −0.177 per percentage point of CECL Adj. The intro conflates the binary estimate with continuous-treatment units.
- **Evidence:**
  - `tables/small_bank_triple_diff_time_deposits_20260404.tex`: col. 1 (continuous): `CECL Adj × Post × Uninsured` = −0.1770\*\*\*; col. 2 (binary): `High CECL × Post × Uninsured` = −1.252\*\*\*
  - Empirical results section correctly reports both separately: "binary specification (column~2) is −1.252 … The continuous analog (column~1, −0.177)"
- **Suggested fix:** Change intro sentence to distinguish the two. One option: "a triple-difference specification confirms a within-bank composition shift: in the binary specification, high-CECL banks experienced a 1.252 percentage-point widening of the insured-to-uninsured gap; in the continuous specification, each additional percentage point of CECL exposure widens this gap by 0.177 percentage points."

---

### Issue 5 — Table header "NIM/Assets (%)" is redundant

- **Severity:** Medium
- **Category:** figure/table
- **Location:** `tables/small_bank_did_financial_outcomes_20260403.tex:6`
- **Problem:** The dependent-variable header for columns 5–6 reads "NIM/Assets (%)." NIM (net interest margin) is already defined as net interest income scaled by average assets, so "NIM/Assets" is internally redundant. The caption description and empirical text call this variable "net interest margin" or "NIM" without "/Assets."
- **Evidence:** Table line 6: `\multicolumn{2}{c}{NIM/Assets (\%)}`. Empirical results section: "Net interest margin contracted by 0.024 percentage points per quarter."
- **Suggested fix:** Change header to "NIM (%)" or "Net Interest Margin (%)" to match the standard usage in the text.

---

### Issue 6 — IRS SOI data not formally cited

- **Severity:** Medium
- **Category:** language / bib
- **Location:** `data_and_sample_construction_20260406.tex:39–41`
- **Problem:** The data section describes IRS Statistics of Income (SOI) ZIP-code tabulations as a data source but does not include a formal `\cite{}` command. The section header explicitly notes "New citation needed: IRS_SOI (bib key placeholder used below)" but the placeholder was never inserted. Published papers typically cite government data sources.
- **Evidence:** Section header comment line 17; text line 39–41 describes IRS SOI without citation; no `\cite{IRS_SOI}` or similar appears in the file.
- **Suggested fix:** Add a bibliographic entry for the IRS SOI tabulation and insert `\citep{IRS_SOI}` (or equivalent key) at the first reference to this data source.

---

### Issue 7 — Table captions say "post-2023Q1 indicator" but design is bank-specific

- **Severity:** Medium
- **Category:** figure/table
- **Location:** `tables_figures.tex:83` (DID table description) and `tables_figures.tex:139` (triple-diff description)
- **Problem:** Both regression table captions describe the treatment timing as a "post-2023Q1 indicator," implying a common date. The identification section (equation `eq:did`) defines `Post_{it}` as equal to one for quarters at or after bank $i$'s own adoption date — a bank-specific indicator. The vast majority adopt in 2023Q1 but the description overstates precision for the off-cycle adopters.
- **Evidence:** Identification section: "$\mathrm{Post}_{it}$ equals one for all quarters at or after bank $i$'s CECL adoption date."
- **Suggested fix:** Change "post-2023Q1 indicator" to "post-adoption indicator" in both table descriptions.

---

### Issue 8 — Duplicate `\usepackage{}` declarations

- **Severity:** Low
- **Category:** build-risk
- **Location:** `latex/main.tex` preamble
- **Problem:** Several packages are loaded multiple times. `\usepackage{hyperref}` declared twice (lines 31 and 38) is the most concerning since hyperref is order-sensitive and a double load can produce link-color or bookmark conflicts. Others are benign warnings.

| Package | Lines |
|---------|-------|
| `hyperref` | 31, 38 |
| `geometry` | 19, 24 |
| `graphicx` | 6, 43 |
| `booktabs` | 21, 40, 41 |
| `color` | 20, 30 |

- **Suggested fix:** Remove the duplicate declarations. Keep the later `hyperref` call (line 38) to preserve ordering relative to other packages. For `geometry`, keep only the one with the `[margin=1in]` option (line 19).

---

### Issue 9 — Panel E label "Net interest margin / assets" in sophistication figure

- **Severity:** Low
- **Category:** figure/table
- **Location:** `tables_figures.tex:249`
- **Problem:** The mini-panel heading reads "Net interest margin / assets." Same redundancy as Issue 5 — NIM is already a rate relative to assets.
- **Suggested fix:** Change to "Net interest margin" to match the text and other exhibit labels.

---

### Issue 10 — Uncited `.bib` entries

- **Severity:** Low
- **Category:** bib
- **Location:** `latex/depositor-discipline-references.bib`
- **Problem:** At minimum two entries in the `.bib` are never cited in the manuscript: `acharya2015crisis` and `jiang2025monetary`. (Note: `jiang2024monetary` IS cited; the 2025 entry appears to be a duplicate or updated version.) Several additional entries may also be unused (`calomiris2003fundamentals`, `cookson2026social`, `cubillas2012banking`, `danisewicz2021debtholder`, `diamond2002bank`, `drechsler2017deposits`, `ellis1992does`, `goldberg2002depositor`, `iyer2012understanding`, `levy2004market`, `pyle2009effect`).
- **Suggested fix:** Low priority — remove unused entries before final submission for a cleaner `.bib`, but this will not affect compilation.

---

### Issue 11 — Stale "Modern Banking" in internal comment headers

- **Severity:** Low
- **Category:** language
- **Location:** Comment blocks at top of most section `.tex` files
- **Problem:** Internal comment headers (not compiled into the PDF) describe the paper as "Depositor Discipline in **Modern** Banking" but the paper title in `main.tex:94` is "Depositor Discipline in **Community** Banking: Evidence from the CECL Information Shock."
- **Suggested fix:** Update comments for consistency — no reader-facing impact, but helpful to avoid confusion when editing.

---

## Figures and Tables Audit

### Fig 1: `fig:cecl_equity_distribution` (`fig01_cecl_dist_20260403.png`)
- **Status:** File exists. Caption matches description in `tables_figures.tex`. Description text in desc-stats section references this figure accurately (right-skewed distribution, ~2.5% threshold). No mismatch found.

### Fig 2: `fig:cecl_adoption_quarter_distribution` (`fig02_adoption_dist_20260403.png`)
- **Status:** File exists. Caption matches. Text reports "3,997 of the 4,320 sample banks (92.5 percent)" in 2023Q1 — consistent with tab01 showing N=4,320 (4,320 × 0.925 ≈ 3,996 ≈ 3,997). ✓

### Tab 1: `tab:descriptive_sumstats_cecl` (`tab01_sumstats_20260403.tex`)
- **Status:** All in-text cross-checks match the table values:
  - "roughly half… little incremental reserve" → median = 0.000 ✓
  - "90th percentile… approximately 2.5 percent" → High CECL threshold = 2.5%; High N = 432 (exactly 10%) ✓
  - "NPL ratios and allowance ratios are both significantly higher" → Hi−Lo: +0.111\*\*, +0.081\*\*\* ✓
  - "CRE concentration is modestly but significantly greater" → +1.727\*\* ✓
  - "Neither uninsured time deposits… nor the total uninsured deposit share differs significantly" → Hi−Lo: +0.064 (n.s.), −0.523 (n.s.) ✓
  - "High-CECL banks hold somewhat more insured time deposits" → +0.832\*\*\* ✓

### Tab 2: `tab:cecl_predictors_cross_section` (`tab02_cecl_predictors_20260403.tex`)
- **Status:** File exists. Text says "adjusted R² of approximately one percent in the most saturated specification" — cannot verify without reading the table but flagged for awareness.

### Tab 3: `tab:small_bank_did_time_deposits` (`small_bank_did_time_deposits_20260403.tex`)
- **Status:** In-text numbers match the table:
  - "−0.394 pp … SE 0.182, p<0.05" → Table: −0.3935\*\* (0.1815) ✓ (rounds consistently)
  - "0.072 pp … p<0.05" → −0.0724\*\* ✓
  - "+0.712 pp … p<0.05" → +0.7117\*\* ✓
  - "continuous … +0.070 pp … imprecise" → +0.0699 (n.s.) ✓
- **Flag:** Abstract calls insured deposits "unaffected" but col. 4 = +0.7117\*\* (p<0.05). See Issue 3.
- **Flag:** Table description says "high CECL exposure (top decile)" for binary indicator. Summary stats table footnote says "High CECL ≥ 2.5% of pre-adoption equity." These are consistent (2.5% ≈ 90th percentile, N=432/4320=10%). ✓

### Tab 4: `tab:small_bank_triple_diff_time_deposits` (`small_bank_triple_diff_time_deposits_20260404.tex`)
- **Status:** Numbers in empirical-results section match the table:
  - "binary … −1.252, SE 0.340, p<0.01" → Table: −1.252\*\*\* (0.3401) ✓
  - "continuous … −0.177, SE 0.058, p<0.01" → Table: −0.1770\*\*\* (0.0578) ✓
- **Flag:** Introduction attributes −1.252 to "per percentage-point of CECL exposure" — wrong specification. See Issue 4.
- **Note:** This table uses the `20260404` dated file while the DID deposit table uses `20260403`. Both exist on disk. ✓

### Tab 5: `tab:small_bank_did_financial_outcomes` (`small_bank_did_financial_outcomes_20260403.tex`)
- **Status:** In-text numbers match:
  - "0.021 pp more per quarter, p<0.01" → 0.0214\*\*\* ✓
  - "0.37 bp, p<0.05" → 0.0037\*\* ✓
  - "−0.038 pp per quarter, p<0.01" → −0.0378\*\*\* ✓
  - "−0.024 pp per quarter, p<0.05" → −0.0235\*\* ✓ (rounds to 0.024)
  - "−0.009 pp ROA, p<0.01" → −0.0088\*\*\* ✓
  - "−0.005 pp NIM, p<0.05" → −0.0047\*\* ✓
  - Annualized interest expense: 0.021×4 = 0.084 pp = 8.4 bp → intro says "8–9 bp" ✓
  - Annualized ROA: 0.038×4 = 0.152 pp ≈ 15 bp ✓
  - Annualized NIM: 0.024×4 = 0.096 pp ≈ 9–10 bp → intro says "9 bp" (borderline, acceptable)
- **Flag:** Table column header "NIM/Assets (%)" is redundant. See Issue 5.

### Fig 3: `fig:es_large_banks_market_cds` (Panel A + Panel B)
- **Status:** Both files exist (`mkt_cap_large_banks_20260403.png`, `cds_spread_large_banks_20260403.png`). Caption and identification section description are consistent. The identification section notes the COVID-19 confound caveat, which is reflected in the description's hedged language. ✓

### Fig 4: `fig:es_time_deps_cecl` (4-panel event study, deposits)
- **Status:** All four PNG files exist (dated `20260403`). Caption accurately describes the 4-panel layout (uninsured/insured × high-CECL/continuous). ✓

### Fig 5: `fig:es_financial_outcomes_cecl` (6-panel event study, financial outcomes)
- **Status:** All six PNG files exist. Caption is accurate.

### Fig 6: `fig:es_sophistication_split` (5-panel sophistication split)
- **Status:** All five PNG files exist. Caption note claims "the note printed below each panel reports the estimated Post × High CECL × High Sophistication coefficient" — this should be confirmed in the actual figure images. Coefficient values cited in the text ($−0.022$, SE $0.468$ for Panel A; $+0.044$ for Panel C; $−0.076$ for Panel D; $−0.031$ for Panel E) cannot be cross-checked against a table and are taken on faith from the figures.
- **Flag:** Panel E label in `tables_figures.tex` says "Net interest margin / assets" — should be "Net interest margin." See Issue 9.

---

## Priority Checklist

### High Priority (fix before submission)
- [ ] **Issue 1:** Delete `\autor{}` on `main.tex:100` (will cause compilation failure)
- [ ] **Issue 2:** Add four missing `.bib` entries: `ACS2022`, `FASB2016`, `correia2026bank`, `narayanan2026decline`
- [ ] **Issue 3:** Revise abstract — insured deposits are not "unaffected" (table shows +0.7117\*\*)

### Medium Priority (should fix; referee may notice)
- [ ] **Issue 4:** Fix intro para 3 — separate the −1.252 (binary) from "per percentage-point" language
- [ ] **Issue 5:** Fix table header "NIM/Assets (%)" → "NIM (%)" in `small_bank_did_financial_outcomes`
- [ ] **Issue 6:** Add formal citation for IRS Statistics of Income data in the data section
- [ ] **Issue 7:** Change "post-2023Q1 indicator" → "post-adoption indicator" in table captions

### Low Priority / Cosmetic
- [ ] **Issue 8:** Remove duplicate package declarations from `main.tex` preamble
- [ ] **Issue 9:** Fix Panel E label "Net interest margin / assets" → "Net interest margin"
- [ ] **Issue 10:** Remove uncited `.bib` entries before final submission
- [ ] **Issue 11:** Update internal comment headers from "Modern Banking" to "Community Banking"