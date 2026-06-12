# Editorial Correspondence — Confidential

**Journal:** Top Finance Journal (Journal of Finance / RFS / JFE)
**Date:** 2026-04-08
**Re:** Manuscript — "Depositor Discipline in Community Banking: Evidence from the CECL Information Shock"
**From:** Associate Editor
**To:** Corresponding Author

---

## Opening Statement

This paper presents a difference-in-differences design exploiting the CECL Day-One retained-earnings adjustment as a depositor-discipline instrument. After a complete reading of the manuscript and the analysis code, I find four issues of a severity that independently warrants rejection, and ten additional issues that collectively suggest the paper's quantitative claims cannot be verified as stated. I am not recommending a request for major revision at this time. I am requiring written responses to every concern below before the manuscript returns to active review, and I reserve the right to refer this matter to the editorial board if the responses are unsatisfactory.

---

## Critical Concerns Requiring Immediate Response

These issues strike at the validity of the empirical results. Failure to resolve any one of them constitutes grounds for retraction.

---

### Concern 1 — High-CECL Binary Indicator Defined Differently in Descriptive Statistics and Main Regressions

**Severity:** Fatal  
**Location:** `code/result-generation/descriptive_stats_20260403.R`, line 104 vs. `code/_common.R`, line 19 and `code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd`, line 188  
**Paper claim:** Section 2 states that the binary `High CECL` indicator is defined as banks in "the top decile of the cross-sectional distribution," with threshold τ described as "the top-decile threshold (≈ 2.5 percentage points)." The descriptive statistics section (Section 4.1) repeats: "The 90th percentile of the distribution lies at approximately 2.5 percent of equity, the threshold for our binary High-CECL indicator."

The descriptive statistics script that produces Table 1 (`descriptive_stats_20260403.R`, line 104) correctly computes the threshold as a data-driven 90th percentile:

```r
cs[, high_cecl := as.integer(cecl_equity >= quantile(cs$cecl_equity, 0.90, na.rm = TRUE))]
```

The main regression script (`small_bank_multi_outcomes_20260403_v4.qmd`, line 188) applies a **fixed constant** of 2.5% drawn from `_common.R`:

```r
high_cecl_equity = as.integer(cecl_equity >= CECL_THRESHOLD_PCT)  # CECL_THRESHOLD_PCT = 2.5
```

These are not the same operation. The empirical 90th percentile of the CECL adjustment distribution in the regression sample will not equal exactly 2.5% unless this is true by construction, which it is not. Table 1 describes a population defined by the empirical decile; Tables 3 through 5 and all associated event-study figures describe a population defined by a fixed constant. The two groups have different membership, different means, and different standard deviations of the treatment variable. The paper's coherence across descriptive and inferential sections rests on a false premise.

The authors must: (1) disclose which definition — fixed threshold or data-driven decile — is used in each table and figure, (2) demonstrate that the regression results are robust to both definitions, and (3) reconcile all cross-references in the text that conflate the two.

**Required response:** A replication table using both definitions for all main results, with sample sizes and treatment-group means reported separately for each definition.

---

### Concern 2 — Post Variable Silently Excludes the Adoption Quarter from Treatment

**Severity:** Fatal  
**Location:** `code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd`, lines 198 and 209  
**Paper claim:** Equation (2) in the identification section states: "Post$_{it}$ equals one for all quarters **at or after** bank $i$'s CECL adoption date."

The code defines `post` twice. Line 198:

```r
dt_sb[, post := as.integer(qtrs_since >= 0L)]
```

This correctly implements the paper: k=0 is treated (post=1). Line 209 then silently **overwrites** `post` on the windowed dataset:

```r
dt_w[, post := ifelse(qtrs_since > 0, 1, 0)]
```

This definition excludes the adoption quarter (k=0) from the post period. In the main DiD regressions, the adoption quarter is assigned to the control (pre) regime, not the treatment (post) regime, the opposite of what the paper states. This is not a minor timing convention: the adoption quarter is the moment at which the CECL disclosure is made public. Removing it from "post" attenuates the estimated effect whenever some portion of the disciplinary response occurs in the disclosure quarter itself—precisely the quarter the authors argue is the signal event. The event-study plots will display a coefficient at k=0 (since the event-study specification uses `i(qtrs_since, ...)` directly, not `post`), but the static DiD coefficient is estimated from a sample in which k=0 contributes zero post-treatment observations.

The authors must: (1) acknowledge the discrepancy between the stated and implemented definition, (2) re-estimate all static DiD specifications using the definition in the paper (post=1 for k≥0), and (3) report the change in all main coefficients.

**Required response:** Revised Tables 3, 4, and 5 using `post := as.integer(qtrs_since >= 0)`, with discussion of any changes in magnitude or significance.

---

### Concern 3 — Sample Construction Code Is Entirely Absent; Paper Is Not Reproducible

**Severity:** Fatal  
**Location:** `code/sample-construction/` (contains only `.gitkeep`)  
**Paper claim:** Section 3.2 states: "We construct a bank-quarter panel identified by each institution's RSSD identifier and quarter, spanning 2016Q1–2025Q4 for all institutions." The data section describes the extraction of CECL variables from Schedule RI-A, the de-cumulation of YTD income-statement flows to quarterly rates, and the creation of all ratio variables.

The `code/sample-construction/` directory is empty. There are no scripts that construct `call_report_data_20260401_1.rds` or `call_report_data_20260401_2.rds` from raw Call Report data. Every result in the paper depends on these two files, and the code that produces them does not exist in the repository. No independent reviewer, referee, or data editor can verify how the data were parsed, which schedule fields were mapped to which variable names, whether the YTD de-cumulation was applied consistently, or whether the sample filters described in the paper were implemented as stated.

The analysis scripts (`descriptive_stats_20260403.R` and `small_bank_multi_outcomes_20260403_v4.qmd`) load the pre-constructed `.rds` files with hardcoded file names and no fallback. There is no entry point from which a reader can begin with the raw Call Report data and reproduce Table 1.

This is not a formatting deficiency. A paper that presents itself as providing reproducible causal evidence, and that argues its identifying assumptions are verifiable, cannot conceal the step at which raw data become the analysis sample. Every filter, every variable definition, and every merge is potentially consequential. The absence of sample-construction code removes the possibility of independent verification.

**Required response:** Complete sample-construction scripts, with documentation linking each script output to each analysis script input, submitted alongside the revised manuscript.

---

### Concern 4 — Output Directories in Code Do Not Match LaTeX Input Paths; No Disclosed Transfer Step

**Severity:** Fatal  
**Location:** `code/_common.R`, lines 25–26; `code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd`, `save_doc_fig()` function; `code/result-generation/descriptive_stats_20260403.R`, lines 15–16  
**Paper claim:** The paper is presented as a reproducible empirical project with analysis code that generates the tables and figures appearing in the manuscript.

The code writes all outputs to `docs/tables/` and `docs/figures/` (via `here::here("docs", "figures", ...)` throughout). The LaTeX document reads tables and figures from `latex/tables/` and `latex/figures/` (e.g., `\input{tables/small_bank_did_time_deposits_20260403}` and `\includegraphics{figures/fig01_cecl_dist_20260403.png}` relative to the `latex/` working directory). There is no script in the repository that moves, copies, or symlinks outputs from `docs/` to `latex/`.

The compiled PDF exists and contains all figures and tables. This means the files in `latex/tables/` and `latex/figures/` were placed there by a mechanism that is not disclosed in the repository. Either the paper was compiled against outputs produced by a different version of the analysis pipeline, or there is a file-transfer step that has been omitted from the repository.

This creates a disjunction between the disclosed code and the compiled paper. A reader who runs the disclosed scripts and then compiles `latex/main.tex` will produce a document whose tables and figures may differ from those in the submitted version.

**Required response:** Either (1) revise all analysis code to write outputs directly to `latex/figures/` and `latex/tables/`, or (2) provide and document the transfer script that moves `docs/` outputs to `latex/`, and confirm that the figures and tables currently in `latex/` were produced by the disclosed analysis code without manual editing.

---

## Serious Concerns Requiring Full Resolution

These issues do not individually invalidate the paper but collectively suggest a pattern of undisclosed discretion and methodological inconsistency that raises questions about the reliability of the stated results.

---

### Concern 5 — CDS Event Study Applies Undisclosed Balanced-Panel Restriction; Market Cap Event Study Does Not

**Severity:** Major  
**Location:** `code/result-generation/market_and_cds_large_banks_20260401.qmd`, lines 229–235  
**Paper claim:** Section 4.5 states that Figure 3 presents event-study estimates for large banks using equity market capitalization (Panel A) and CDS spreads (Panel B), with the same regression structure for both.

The market capitalization event study (line 184) applies only `abs(months_since) <= 9 & year(first_cecl_dt) <= 2021` as a filter:

```r
r1 <- feols(
  normalized_market_cap ~ ...,
  data = bnk_mkt[abs(months_since) <= 9 & year(first_cecl_dt) <= 2021],
  ...
)
```

The CDS event study adds a **balanced-panel restriction** not applied to Panel A:

```r
t <- cds[abs(months_since) <= 9 & year(first_cecl_dt) <= 2021]
t <- t[, .N, by = RSSD]
r1 <- feols(
  CDS_spread ~ ...,
  data = cds[abs(months_since) <= 9 & year(first_cecl_dt) <= 2021 & RSSD %in% t[N == 19]$RSSD],
  ...
)
```

Banks missing any month in the 19-month window are silently dropped from the CDS panel but not from the equity panel. The paper makes no disclosure of this filter, nor of the fraction of banks (and bank-months) excluded by it. If banks with incomplete CDS windows differ from those with complete windows in the size or sign of the CECL treatment variable—as is likely, given that larger, more liquid institutions will have more complete CDS records—the CDS event study is estimated on a selected subsample that the paper does not describe. The two panels of Figure 3 are generated from different sets of banks, a fact the figure description does not acknowledge.

**Required response:** (1) Disclose the fraction of banks dropped by the `N == 19` filter. (2) Report the CDS results without this restriction. (3) Confirm whether the two panels of Figure 3 include the same banks, and if not, justify the differential treatment.

---

### Concern 6 — CDS Volume Filter Undisclosed

**Severity:** Major  
**Location:** `code/result-generation/market_and_cds_large_banks_20260401.qmd`, lines 214–218  
**Paper claim:** Section 3.5 states the CDS sample retains "only contracts with observable trading activity." No threshold is given.

The code applies a hard trading-volume filter:

```r
cds <- cds[
  as.numeric(PX_VOLUME) > 1000000,
  ...
]
```

A filter of `PX_VOLUME > 1,000,000` is not disclosed anywhere in the manuscript. The authors do not report how many bank-months are dropped, what fraction of the large-bank sample survives the filter, or whether the threshold is motivated by prior literature or by examination of the data. If this threshold was chosen to produce cleaner event-study patterns, its absence from the paper is not a minor omission.

**Required response:** Disclose the filter threshold, report the fraction of bank-months excluded, and demonstrate robustness to alternative thresholds (e.g., `PX_VOLUME > 500,000` and `PX_VOLUME > 5,000,000`).

---

### Concern 7 — Triple-Difference Controls Are Absorbed by Bank × Quarter Fixed Effects

**Severity:** Major  
**Location:** `code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd`, lines 319–331; `latex/sections/results/tables_figures.tex`, line 139  
**Paper claim:** Table 4's note states the triple-difference specification includes "bank and quarter fixed effects, lagged log assets, lagged equity-to-assets ratio, and lagged interest expense to assets."

The triple-difference dataset stacks insured and uninsured deposit series, creating two rows per bank-quarter. The fixed effects are `bank_qt` (bank × quarter), one dummy per bank-quarter cell. The controls `log_total_assets_l1`, `equity_assets_l1`, and `int_expense_assets_l1` are identical for both rows within each bank-quarter cell because they are bank-level variables. Controls that do not vary within a fixed-effect cell are absorbed by those fixed effects and contribute no identifying variation to the regression. The software (`fixest`) will silently absorb them. The table note's claim that these controls are included in the specification is technically true in the code but descriptively misleading: they have zero identifying power and are not identified separately from the fixed effects.

This matters beyond taxonomy. The controls are included to absorb pre-existing differences in bank size, capitalization, and deposit pricing strategy. In the triple-difference, bank × quarter fixed effects absorb all such differences by construction; the controls are superfluous. Their inclusion in the table note implies they add something they do not add, and their coefficient estimates (if reported) would be meaningless.

**Required response:** Acknowledge that controls are absorbed by the fixed effects in the triple-difference specification and remove them from the table note, or demonstrate that the fixest implementation does not fully absorb them and explain why.

---

### Concern 8 — Depositor Sophistication Split Threshold Computed on SOD Universe, Not on Regression Sample

**Severity:** Major  
**Location:** `code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd`, lines 456–457, 459–474  
**Paper claim:** Section 5.3 states the sample is split "at the 75th percentile of a deposit-weighted branch-market sophistication index."

The 75th percentile used as the classification threshold is computed on `soph_bank`, the universe of all FDIC SOD banks in 2022 that can be matched to ZIP demographics:

```r
med_soph <- quantile(soph_bank$frac_sophisticated, 0.75, na.rm = TRUE)
```

The variable is named `med_soph` despite being the 75th percentile. The regression sample `dt_w_het` is subsequently restricted to banks that (1) are in the community bank Call Report panel, (2) have `|k| < 12`, and (3) can be matched to SOD. The distribution of `frac_sophisticated` in this restricted sample will differ from the full SOD universe on which the threshold is computed. Banks classified as "High Sophistication" based on the SOD-universe 75th percentile may not be in the top quartile of the regression sample.

Additionally, the paper does not disclose the SOD match rate. The code prints the match rate at runtime (`n_matched / n_sb`), but this number does not appear anywhere in the manuscript. Banks dropped in the sophistication merge (`dt_w_het <- dt_w_het[!is.na(high_sophistication)]`) are silently excluded from the heterogeneity analysis without disclosure. If unmatched banks differ systematically in deposit structure or CECL exposure, the heterogeneity results describe a selected subset.

**Required response:** (1) Report the sophistication match rate. (2) Recompute the 75th percentile threshold on the regression sample, not the SOD universe. (3) Demonstrate robustness of the sophistication results to the alternative threshold.

---

### Concern 9 — Large-Bank CECL Treatment Variable Not Expressed in Percentage Points

**Severity:** Major  
**Location:** `code/result-generation/market_and_cds_large_banks_20260401.qmd`, line 129 vs. `code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd`, lines 143–147  
**Paper claim:** Section 2 defines `CECL Adj` as "expressed in percentage points to facilitate comparison across banks of different sizes." The community bank analysis constructs `cecl_equity` as `CECL / equity_bop * 100`, correctly scaled to percentage points.

The large-bank analysis constructs the treatment variable as:

```r
cecl_df[, cecl_equity := CECL / total_equity_capital]
```

No multiplication by 100. The large-bank `cecl_equity` is in decimal form (e.g., 0.03 for a 3% adjustment). The event-study coefficients in the large-bank analysis therefore measure the response to a one-unit increase in `cecl_equity`, which is a 100-percentage-point change—a value outside the support of the data. Although the paper does not report specific coefficient magnitudes from the large-bank event study, the inconsistent scaling makes the large-bank results incomparable to any metric described in percentage points, and any reader who attempts to compare magnitudes across the community bank and large bank analyses will be misled.

**Required response:** Rescale the large-bank `cecl_equity` to percentage points and confirm that the sign and direction of the event-study plots are unchanged.

---

## Additional Deficiencies

These are not grounds for retraction on their own but are inconsistent with publication standards at this journal.

- **Event-study window mismatch.** The paper (equation 2 and the introduction) describes a "ten-quarter window on either side of CECL adoption." The code at `small_bank_multi_outcomes_20260403_v4.qmd` line 207 uses `abs(qtrs_since) < 12`, which produces an 11-quarter window (k ∈ [−11, +11]). The paper's stated and implemented event windows do not match.

- **Year filter in large-bank event study not disclosed.** Both market cap and CDS regressions include the filter `year(first_cecl_dt) <= 2021` (lines 184 and 230), which is not disclosed in the paper. If any large-bank CECL adopter has a first CECL date after 2021 (non-calendar fiscal year filer, restatement, or late filing), it is silently excluded. The paper does not acknowledge this possibility or report the number of banks excluded.

- **YTD annualization in large-bank Y-9C analysis.** The community bank analysis correctly de-cumulates YTD income flows by differencing within bank-year. The large-bank analysis in `market_and_cds_large_banks_20260401.qmd` (lines 96–104) multiplies Q1 values by 4, Q2 by 2, Q3 by 4/3, and Q4 by 1—an annualization, not a quarterization. The resulting variables are annual rates, not quarterly flows. While these specific variables do not appear in the paper's reported regressions, the inconsistent treatment of YTD data is a methodological error in one branch of the pipeline that warrants explanation.

- **Hardcoded raw data file names.** Both `descriptive_stats_20260403.R` (line 23) and `small_bank_multi_outcomes_20260403_v4.qmd` (lines 109–110) load raw data by hardcoded file name (`call_report_data_20260401_1.rds`, `call_report_data_20260401_2.rds`) with `stopifnot()` guards that abort execution if the files are missing. There is no mechanism for a reviewer to regenerate these files. Combined with the absence of sample-construction code (Concern 3), this makes the pipeline unreproducible end-to-end.

- **Triple-difference table note describes fixed effects ambiguously.** The table note for Table 4 describes "bank and quarter fixed effects." The specification uses `bank_qt` (bank × quarter) fixed effects, which is strictly more restrictive than additive bank plus quarter effects. The paper body correctly states "bank × quarter fixed effects" in Section 5.1. The table note should match.

- **Sophistication variable misnaming.** `code/result-generation/small_bank_multi_outcomes_20260403_v4.qmd` line 456 assigns the 75th percentile to a variable named `med_soph`. This name implies the median (50th percentile). The inconsistency between the variable name and its content is symptomatic of code that has not been reviewed for internal consistency.

---

## Closing Statement

The paper addresses a worthwhile question with a plausible design, but as submitted, the manuscript's empirical claims cannot be verified from the disclosed code, and four of the issues documented above are sufficiently severe that the paper should not enter a revision cycle until they are resolved in writing. The authors are requested to respond to all concerns in a point-by-point letter within 60 days.

---

*This correspondence is confidential and intended solely for the corresponding author and the editorial board.*
