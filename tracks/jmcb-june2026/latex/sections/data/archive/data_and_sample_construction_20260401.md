# Data and Sample Construction

## Data Sources

Our empirical design combines supervisory bank reports, branch-level deposit data, ZIP-level demographics, and market-based risk measures. We build two linked analysis datasets. The first is a quarterly panel of community banks used for the main depositor-discipline tests. The second is a monthly panel of large banks used for market-cap and CDS validation around CECL implementation.

The community-bank panel is built from two raw Call Report files:

- `data/raw/call_report_data_20260401_1.rds`
- `data/raw/call_report_data_20260401_2.rds`

These files contain bank identifiers (`ID_RSSD`), report dates (`D_DT`), CECL adjustment values, balance-sheet items, and deposit account components needed to build both treatment and outcomes.

For large-bank signal validation, we use:

- `data/raw/y9c.rds` (regulatory controls and CECL/equity construction)
- `data/raw/crsp_20220930v2.csv` (time-varying CRSP-FRB identifier mapping)
- `data/raw/bank_mkt_data_cecl.rds` (monthly market capitalization)
- `data/raw/bank_cds_spreads.rds` and `data/raw/ticker_permco_rssd.rds` (monthly CDS spreads and ticker-to-bank crosswalk)

For heterogeneity by depositor sophistication in the community-bank sample, we merge:

- `data/raw/fdic_sod_2012_2025_20260328.rds`
- `data/raw/zip_year_demographics_20260328.rds`

This merge allows construction of a deposit-weighted sophistication measure at the bank level, based on branch-level deposit shares and local demographic composition.

## Community-Bank Panel Construction

We first stack the two Call Report extracts and enforce a unique bank-quarter panel at the (`ID_RSSD`, `D_DT`) level. Dates are standardized, observations are sorted by bank and time, and duplicate bank-date records are removed.

Several accounting items in raw Call Reports are year-to-date cumulative flows. Because our identification is event-time based at quarterly frequency, we convert these cumulative fields into true quarterly flows. For each of the main flow items (`interest_expense`, `interest_income`, `net_interest_income`, `net_income`, `nonint_expense`, `nonint_income`), quarter 1 is retained as reported, and quarters 2-4 are differenced from the previous quarter within bank-year.

This transformation is necessary because cumulative values would blur quarter-to-quarter adjustments around CECL adoption and could mechanically attenuate dynamic treatment effects.

## Main RHS Variable: CECL Day-One Adjustment Relative to Equity

The core treatment intensity variable is `cecl_equity`, defined as:

- `cecl_equity = 100 * CECL / equity_bop`

It is computed only when both numerator and denominator are non-missing and `equity_bop > 0`. Interpreted in percentage points, this variable captures the size of the CECL day-one adjustment relative to the bank's equity base.

At sample-construction stage, CECL adoption is bank-specific. For each community bank, we search the rollout window from 2022Q3 through 2023Q4 and define adoption as the earliest quarter with non-missing `cecl_equity`. Banks with no CECL observation in this window do not receive an adoption date and are excluded from event-time estimation.

We construct both continuous and binary treatment forms:

- Continuous treatment: adoption-quarter `cecl_equity`
- Binary treatment: `high_cecl_equity = 1` if adoption-quarter `cecl_equity` is above the pre-specified threshold (`CECL_THRESHOLD_PCT`), and `0` otherwise

After identifying adoption-quarter CECL intensity, we carry that same value through the bank's event-time panel. This keeps treatment fixed to the initial information shock rather than allowing later accounting movements to redefine treatment strength.

## Sample Definition and Event-Time Structure

The main sample is restricted to community banks based on assets at 2022-12-31. Banks below the project cutoff (`comm_bank_threshold = 10e6` in reported units, corresponding to the $10B community-bank threshold) are included.

Event time is defined in quarters since each bank's CECL adoption date:

- `qtrs_since = quarter(t) - quarter(adopt_i)`

We define `post = 1` when `qtrs_since >= 0` and `post = 0` otherwise. The primary dynamic window is `|qtrs_since| < 12`, yielding a symmetric lead-lag structure around adoption. For static specifications, post periods are grouped into bins (`0-3`, `4-7`, and `8+` quarters after adoption), with pre-periods as the omitted baseline.

This event-time setup allows for staggered adoption timing while preserving a consistent interpretation of treatment as cross-sectional exposure to a predetermined CECL information shock.

## Other Variables: Outcomes and Controls

After constructing CECL treatment, we create the main outcome variables as ratios (all in percentage points):

- `unins_deps_assets = 100 * unins_deps_excl_ret / total_assets`
- `ins_deps_assets = 100 * ins_deps_excl_ret / total_assets`
- `unins_time_deps_assets = 100 * unins_time_deps / total_assets`
- `ins_time_deps_assets = 100 * ins_time_deps / total_assets`
- `int_expense_assets = 100 * interest_expense_q / total_assets`
- `roa = 100 * net_income_q / total_assets`
- `roe = 100 * net_income_q / equity_bop`
- `equity_assets = 100 * equity_bop / total_assets`
- `nim = 100 * net_interest_income_q / total_assets`

We also construct:

- `n_unins_deps_pct`, the share of uninsured accounts among total (insured + uninsured) non-retirement deposit accounts

To limit sensitivity to outliers, all ratio variables used in estimation are winsorized by report date at the 1st and 99th percentiles. This preserves within-quarter cross-sectional ranking while reducing the influence of extreme observations.

Baseline regressions include lagged balance-sheet controls:

- `log_total_assets_l1 = log(total_assets_{t-1})`
- `equity_assets_l1 = equity_assets_{t-1}`

These controls absorb persistent differences in size and capitalization that may correlate with both CECL exposure and depositor behavior.

## Depositor Sophistication Heterogeneity

To test whether depositor response varies with depositor sophistication, we merge branch-level FDIC Summary of Deposits data (2022) with ZIP-level demographics and sophistication indicators (2022 ACS-based inputs). For each bank, we compute deposit-weighted sophistication:

- `frac_sophisticated = sum(deposits_dollars * sophisticated) / sum(deposits_dollars)`

Banks are classified as high sophistication when `frac_sophisticated` is at or above the 75th percentile of the cross-sectional distribution in the SOD-linked bank sample. Heterogeneity event studies then compare dynamic CECL responses between high- and low-sophistication groups using the same event-time structure and controls as the baseline.

Because this measure is built from pre-treatment branch footprint characteristics, it is intended to capture ex ante depositor information environments rather than post-CECL outcomes.

## Large-Bank Signal-Validation Sample (Market Cap and CDS)

We construct a complementary large-bank panel to verify that CECL day-one adjustments contain market-relevant information.

From `y9c.rds`, we identify each bank's first non-missing CECL observation and compute:

- `cecl_equity = CECL / total_equity_capital`

We keep one CECL anchor per bank (`first_cecl_dt`) and winsorize `cecl_equity` at the 2.5th and 97.5th percentiles.

We then build a time-varying CRSP-FRB mapping that expands each valid (`permco`, `RSSD`) relationship to quarter ends and merge in monthly market-cap observations. Monthly event time is:

- `months_since = 12 * (year_t - year_first_cecl) + (month_t - month_first_cecl)`

For CDS, we merge tickers to bank identifiers, keep liquid observations (`PX_VOLUME > 1,000,000`), and winsorize spreads by month at 2.5/97.5 percentiles. We further restrict to banks with a full 19-month event window (`-9` to `+9`) around CECL adoption.

This validation sample is separate from the community-bank depositor panel, but it uses the same treatment concept (initial CECL/equity shock) and parallel event-time logic. The goal is to show that CECL intensity is priced by equity and credit markets, reinforcing interpretation of the community-bank depositor results as information-driven responses.

## Final Analysis Samples

The final community-bank estimation panel is a bank-quarter event-time dataset with bank and date fixed effects, bank-specific CECL adoption timing, treatment defined from adoption-quarter CECL/equity (continuous and binary forms), outcome ratios scaled by assets, and lagged balance-sheet controls.

The final large-bank validation panel is a bank-month event-time dataset centered on first CECL recognition, with matched CRSP and CDS information.

Together, these datasets implement one unified empirical strategy: use predetermined cross-sectional CECL shock intensity to trace depositor, funding-cost, and market-valuation responses around CECL adoption.
\section{Data and Sample Construction}

\subsection{Data Sources}

Our analysis combines supervisory bank reports, branch-level deposit data, demographic information, and market-based risk measures to identify how depositor behavior changes around CECL adoption. We construct two related datasets: (i) a quarterly panel of community banks for our main depositor-discipline tests, and (ii) monthly market and CDS panels for large banks used to validate the informational content of CECL day-one adjustments.

The core bank-level accounting data come from U.S. Call Reports (for community-bank analyses) and FR Y-9C reports (for large-bank validation analyses). For the community-bank panel, we load two raw Call Report extracts and stack them into a unified quarterly panel:
\begin{itemize}
\item \texttt{data/raw/call_report_data\_20260401\_1.rds}
\item \texttt{data/raw/call_report_data\_20260401\_2.rds}
\end{itemize}
These files provide bank identifiers (\texttt{ID\_RSSD}), report dates (\texttt{D\_DT}), CECL day-one adjustment measures, balance-sheet quantities, and deposit account components needed to build our outcomes and controls.

For the large-bank validation exercise, we use:
\begin{itemize}
\item \texttt{data/raw/y9c.rds} for regulatory accounting controls and CECL/equity;
\item \texttt{data/raw/crsp\_20220930v2.csv} to map CRSP market identifiers (\texttt{permco}) to FRB entities (\texttt{RSSD}) over time;
\item \texttt{data/raw/bank\_mkt\_data\_cecl.rds} for monthly market capitalization;
\item \texttt{data/raw/bank\_cds\_spreads.rds} and \texttt{data/raw/ticker\_permco\_rssd.rds} for monthly CDS spreads and ticker-to-bank crosswalks.
\end{itemize}

To study heterogeneity in depositor sophistication within the community-bank sample, we merge branch-level data from FDIC Summary of Deposits and ZIP-level demographics:
\begin{itemize}
\item \texttt{data/raw/fdic\_sod\_2012\_2025\_20260328.rds}
\item \texttt{data/raw/zip\_year\_demographics\_20260328.rds}
\end{itemize}
This merge allows us to construct a deposit-weighted sophistication measure at the bank level.

\subsection{Community-Bank Panel Construction}

We begin by stacking the two Call Report extracts and enforcing a unique bank-quarter panel at the \((ID\_RSSD, D\_DT)\) level. Report dates are converted to calendar dates, and observations are sorted by bank and time. We then transform year-to-date accounting flows into quarterly flows. Specifically, for each cumulative variable (\texttt{interest\_expense}, \texttt{interest\_income}, \texttt{net\_interest\_income}, \texttt{net\_income}, \texttt{nonint\_expense}, \texttt{nonint\_income}), quarter-1 observations are retained as reported and quarters 2--4 are differenced from the prior quarter within bank-year to recover quarterly increments.

This transformation is essential because depositor response and bank pricing behavior are inherently quarter-specific around CECL adoption; using cumulative figures would mechanically smooth or distort timing in both event-study and post-period specifications.

\subsection{Main Right-Hand-Side Variable: CECL Day-One Adjustment Relative to Equity}

Our central treatment intensity variable is CECL day-one adjustment scaled by beginning-of-period equity:
\[
\texttt{cecl\_equity}_{it}
=
\frac{\texttt{CECL}_{it}}{\texttt{equity\_bop}_{it}}\times 100,
\]
defined when both numerator and denominator are non-missing and \(\texttt{equity\_bop}_{it} > 0\). This ratio measures how large the CECL transition shock is relative to each bank's equity base and is interpreted in percentage points.

At the sample-construction stage, CECL adoption is treated as a bank-specific event. For each community bank, we search a rollout window from 2022Q3 through 2023Q4 and define the adoption quarter as the earliest quarter with non-missing \texttt{cecl\_equity}. Banks with no observed CECL value in this rollout window are not assigned an adoption date and are excluded from the event-time sample.

We also define a binary treatment split:
\[
\texttt{high\_cecl\_equity}_i = \mathbb{1}\{\texttt{cecl\_equity}_{i,\text{adopt}} \geq \tau\},
\]
where \(\tau\) is the pre-specified threshold in the shared project macros (\texttt{CECL\_THRESHOLD\_PCT}, corresponding to the top-decile cutoff in the baseline design). After determining each bank's adoption-quarter CECL/equity value, we carry that adoption intensity across all bank-quarters used in the dynamic specifications. This construction keeps treatment status fixed to the initial CECL shock, consistent with the interpretation of CECL as an information event rather than a continuously updated treatment.

\subsection{Sample Definition and Event-Time Structure}

The main sample consists of community banks defined using 2022Q4 size. We classify a bank as community if total assets at 2022-12-31 are below the project threshold (\texttt{comm\_bank\_threshold = 10e6} in reported units, corresponding to the \$10 billion regulatory cutoff). We retain all bank-quarters for banks meeting this baseline size criterion.

Event time is measured in quarters relative to each bank's CECL adoption date:
\[
\texttt{qtrs\_since}_{it}
= \text{quarter}(t) - \text{quarter}(\text{adopt}_i).
\]
We define \texttt{post} as an indicator for \(\texttt{qtrs\_since} \ge 0\), and we estimate dynamic models over a symmetric event window around adoption (\(|\texttt{qtrs\_since}| < 12\), yielding 11 leads and 11 lags). For static specifications, we additionally group event time into post bins (\(0\text{--}3\), \(4\text{--}7\), \(8+\) quarters after adoption), with all pre periods as baseline.

This bank-specific event-time structure is designed to account for staggered operational timing in CECL reporting while preserving a common interpretation: cross-sectional differences in depositor response as a function of ex ante CECL shock intensity.

\subsection{Outcome Variables and Additional Covariates}

After constructing CECL/equity, we build the dependent variables that capture depositor flows, funding cost adjustments, and bank performance:
\begin{align*}
\texttt{unins\_deps\_assets}_{it} &= 100\times \frac{\texttt{unins\_deps\_excl\_ret}_{it}}{\texttt{total\_assets}_{it}},\\
\texttt{ins\_deps\_assets}_{it} &= 100\times \frac{\texttt{ins\_deps\_excl\_ret}_{it}}{\texttt{total\_assets}_{it}},\\
\texttt{unins\_time\_deps\_assets}_{it} &= 100\times \frac{\texttt{unins\_time\_deps}_{it}}{\texttt{total\_assets}_{it}},\\
\texttt{ins\_time\_deps\_assets}_{it} &= 100\times \frac{\texttt{ins\_time\_deps}_{it}}{\texttt{total\_assets}_{it}},\\
\texttt{int\_expense\_assets}_{it} &= 100\times \frac{\texttt{interest\_expense\_q}_{it}}{\texttt{total\_assets}_{it}},\\
\texttt{roa}_{it} &= 100\times \frac{\texttt{net\_income\_q}_{it}}{\texttt{total\_assets}_{it}},\\
\texttt{roe}_{it} &= 100\times \frac{\texttt{net\_income\_q}_{it}}{\texttt{equity\_bop}_{it}},\\
\texttt{equity\_assets}_{it} &= 100\times \frac{\texttt{equity\_bop}_{it}}{\texttt{total\_assets}_{it}},\\
\texttt{nim}_{it} &= 100\times \frac{\texttt{net\_interest\_income\_q}_{it}}{\texttt{total\_assets}_{it}}.
\end{align*}

All ratio variables are winsorized by report date at the 1st and 99th percentiles to reduce the influence of quarter-specific outliers while preserving cross-sectional ranking in each period. In regression specifications, we include lagged controls for log assets and equity-to-assets:
\begin{itemize}
\item \(\log(\texttt{total\_assets}_{i,t-1})\)
\item \(\texttt{equity\_assets}_{i,t-1}\)
\end{itemize}
These controls absorb slow-moving size and capitalization differences that may correlate with both CECL intensity and deposit composition.

\subsection{Depositor Sophistication Heterogeneity}

To test whether depositor response varies with the information-processing capacity of a bank's depositor base, we build a bank-level sophistication index using branch-level deposit weights. We first isolate 2022 FDIC Summary of Deposits observations, convert branch ZIPs to five-digit strings, and merge branches to 2022 ZIP demographic attributes. We then compute:
\[
\texttt{frac\_sophisticated}_i
=
\frac{\sum_{b \in i}\left(\texttt{deposits\_dollars}_{b}\times \texttt{sophisticated}_{b}\right)}
{\sum_{b \in i}\texttt{deposits\_dollars}_{b}},
\]
where \(b\) indexes branches of bank \(i\). Banks are classified as high sophistication when \(\texttt{frac\_sophisticated}\) is at or above the 75th percentile of the cross-sectional distribution in the SOD-linked bank sample. We then merge this bank-level measure back into the community-bank event-time panel and run subgroup event studies separately for high- and low-sophistication banks.

This design ensures heterogeneity is measured using pre-CECL branch footprint characteristics rather than post-treatment depositor outcomes.

\subsection{Large-Bank Signal-Validation Sample (Market Cap and CDS)}

To validate that CECL day-one adjustments carry meaningful information for outside investors, we construct a complementary large-bank panel using Y-9C, CRSP, and CDS data.

First, from Y-9C we calculate \(\texttt{cecl\_equity} = \texttt{CECL}/\texttt{total\_equity\_capital}\) at each bank's first non-missing CECL observation and winsorize this ratio at the 2.5th and 97.5th percentiles. We retain one CECL anchor observation per bank (\texttt{first\_cecl\_dt}).

Second, we build a time-varying CRSP-FRB crosswalk panel that expands each \((\texttt{permco}, \texttt{RSSD})\) relationship over valid quarter-end dates, then merge monthly market-cap data to the corresponding bank-quarter mapping. This allows us to calculate normalized market capitalization by bank and month and align each observation to months since CECL adoption:
\[
\texttt{months\_since}_{it}
=
12\cdot(\text{year}_t-\text{year}_{\texttt{first\_cecl}_i})
+(\text{month}_t-\text{month}_{\texttt{first\_cecl}_i}).
\]

Third, for CDS validation, we merge bank tickers to RSSD identifiers, keep liquid observations (\texttt{PX\_VOLUME} \(> 1{,}000{,}000\)), and winsorize CDS spreads by month at 2.5/97.5 percentiles. We then restrict to banks with a complete 19-month event window (\(-9\) to \(+9\) months) around CECL adoption.

While these market-based panels are distinct from the community-bank depositor panel, they use the same core treatment concept (CECL/equity at first adoption) and event-time logic. This parallel construction allows us to test whether the CECL signal is priced in equity and credit markets, supporting the interpretation of depositor responses in the main analysis as reactions to informative balance-sheet news rather than unrelated contemporaneous shocks.

\subsection{Final Analysis Samples}

The final community-bank estimation dataset is an event-time panel at bank-quarter frequency with:
\begin{itemize}
\item bank fixed effects and calendar-quarter fixed effects;
\item bank-specific CECL adoption timing;
\item treatment measured by adoption-quarter CECL/equity (continuous and binary high-CECL forms);
\item deposit-composition, pricing, and profitability outcomes scaled by assets; and
\item lagged balance-sheet controls.
\end{itemize}

The large-bank validation dataset is a bank-month panel centered on CECL adoption month with matched CRSP and CDS information. Together, these two datasets implement a common empirical logic: use predetermined cross-sectional CECL shock intensity to trace funding and valuation responses around adoption.
