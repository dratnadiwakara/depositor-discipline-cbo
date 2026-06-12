# Depositor Discipline in Community Banking: Evidence from the CECL Information Shock

**Date**: 04/10/2026
**Domain**: social_sciences/economics
**Taxonomy**: academic/working_paper
**Filter**: Active comments

---

## Overall Feedback

Here are some overall reactions to the document.

**Outline**

This paper uses the mandatory CECL Day-One retained-earnings adjustment as an information shock to test whether uninsured depositors discipline community banks outside of crisis periods. The design is creative and the institutional setting is well-chosen. That said, several identification threats are inadequately addressed, the validation exercise has a fundamental confound, and the heterogeneity results are internally inconsistent in ways that weaken the paper's central mechanism story.

The paper tackles a genuinely important question with a clever quasi-experimental design, and the triple-difference specification is a real strength. The institutional detail on CECL is thorough and the parallel-trends evidence looks clean. However, the causal interpretation rests on several assumptions that are stated but not adequately tested, and one of the paper's key supporting exercises (the large-bank validation) is undermined by the very confound the paper acknowledges.

**Large-bank validation is invalidated by the COVID confound the paper itself acknowledges**

Section 5.5 uses equity and CDS market reactions at large banks adopting in 2020Q1 to establish that the CECL adjustment contains genuine credit-risk information. The paper explicitly states that 'the 2020Q1 adoption date coincides with the onset of the COVID-19 pandemic, which overwhelmed any deposit-market signal with aggregate liquidity demand and emergency policy interventions' — which is precisely why this cohort is excluded from the main tests. Yet Figure 3 is then offered as evidence that markets revised assessments 'at the moment of disclosure, not before.' Any sharp market movement in early 2020 is trivially confounded by the pandemic shock, making it impossible to attribute the equity drop and CDS widening to CECL information rather than to COVID-driven credit-risk repricing that happened to coincide with the adoption date. The paper cannot simultaneously argue that COVID overwhelms the deposit-market signal and that equity/CDS markets cleanly identify the CECL information event in the same quarter. The validation exercise needs to either be dropped or replaced — for instance, using the subset of large banks that adopted on a non-calendar fiscal year in 2019Q4 or early 2020 before the pandemic onset, or using analyst forecast revisions around the specific filing dates rather than calendar-month aggregates.

**Treatment variable proxies for underlying credit quality, not just information revelation**

The paper's identification claim is that the CECL adjustment is a 'pure accounting event' that reveals information without changing financial condition. But Table 1 shows that high-CECL banks enter adoption with significantly higher NPL ratios, higher allowance ratios, lower equity-to-assets ratios, and higher interest expense — all observable to depositors before 2023Q1. Table 2 confirms that NPL ratios and allowance levels are the primary predictors of CECL Adj, with an adjusted R² of only ~1%, which the paper interprets as evidence of low predictability. But low R² in a cross-sectional regression does not mean the treatment is orthogonal to credit quality; it means the relationship is noisy, not absent. Depositors who monitored NPL trends and allowance levels in 2021–2022 Call Reports may have already been reducing exposure to exactly these banks, and the post-2023Q1 break could reflect the continuation of a pre-existing sorting process that the ten-quarter pre-period window is too short to detect. The paper needs a direct test: regress the CECL adjustment on the pre-adoption trend in uninsured deposits (not just the level), and show that the post-adoption effect is not simply a trend continuation for banks whose credit quality had been visibly deteriorating.

**Staggered adoption heterogeneity is not addressed with modern DiD estimators**

Section 5.1 uses a standard two-way fixed effects DiD estimator (equation 5) and an event-study specification (equation 6). With 92.5% of banks adopting in a single quarter (2023Q1), the staggered-adoption problem is modest but not zero — 323 banks adopt in other quarters, and the paper uses bank-specific event time throughout. More importantly, the paper never mentions Callaway-Sant'Anna, Sun-Abraham, or any other estimator designed to handle heterogeneous treatment effects in staggered designs. If treatment effects grow over time (as the event-study plots suggest they do, with the uninsured deposit gap widening through quarter +10), standard TWFE estimates are a weighted average that can be biased toward zero or even sign-reversed relative to the true average treatment effect on the treated. The paper should at minimum report Callaway-Sant'Anna estimates as a robustness check, or explain why the near-uniform adoption calendar makes this unnecessary — the latter argument has merit given the 92.5% concentration, but it needs to be made explicitly rather than ignored.

**The sophistication heterogeneity results are internally inconsistent and the mechanism story is underdeveloped**

Section 6.3 presents the sophistication split as the key mechanism test, but the results do not hold together. The triple-interaction coefficient for uninsured deposits (Post × High CECL × High Sophistication) is reported as −0.022 with SE = 0.468, which is statistically indistinguishable from zero. The paper explains this away by noting that the event-study plot shows a 'gradual buildup' that averages out over the post-period. But the price channel (interest expense triple interaction = +0.044, p = 0.020) and ROA channel (−0.076, p = 0.010) are statistically significant. This creates an internal tension: the paper argues sophisticated depositors 'extract higher rates immediately upon observing the CECL disclosure, then gradually reduce balances as term instruments mature,' but the quantity effect is insignificant while the price effect is significant. If sophisticated depositors are primarily extracting higher rates rather than withdrawing, that is a different and weaker form of discipline than the paper claims. The paper should either reconcile this by showing the quantity effect becomes significant over a longer horizon, or revise the mechanism narrative to center on price discipline rather than quantity discipline for the sophistication channel.

**The insured deposit increase is treated as confirmation of discipline but could reflect a confound**

A central piece of evidence is that insured deposits rise at high-CECL banks after adoption (Table 3, column 4: +0.712 pp, p<0.05), which the paper interprets as banks substituting toward insurance-protected funding after losing uninsured deposits. But this pattern is also consistent with high-CECL banks — which Table 1 shows had higher pre-adoption reliance on insured time deposits — simply continuing to grow their insured deposit base as part of their normal funding strategy, while uninsured deposits declined for reasons unrelated to CECL. The triple-difference in Table 4 is designed to address this, but the bank×quarter fixed effects absorb only time-varying bank-level shocks, not the possibility that high-CECL banks were on a different trajectory for insured versus uninsured deposits even before adoption. The paper should show event-study plots for the insured deposit series extending further into the pre-period, and verify that the insured-uninsured divergence is not already present in 2021–2022 before the CECL shock arrives.

**The 2023 banking stress confound is dismissed too quickly**

Section 5.4 argues that the SVB/Signature failures are not a confound because they were driven by unrealized securities losses, not credit risk, and because Table 2 shows no correlation between CECL adjustment and unrealized losses. This is a reasonable first-order argument, but it is incomplete. The March 2023 stress raised general awareness of uninsured deposit risk across the banking sector, and depositors at community banks may have become more attentive to any risk signal — including CECL disclosures — precisely because of the contemporaneous stress. This would mean the CECL effect is not a clean test of normal-times discipline but rather a test of discipline in a period of heightened depositor alertness triggered by aggregate stress. The paper's claim to identify discipline 'outside periods of banking stress' is therefore overstated. A direct test would be to examine whether the post-adoption effect is concentrated in the quarters immediately following SVB's failure (2023Q1–Q2) versus later quarters when stress had subsided; if the effect is front-loaded in the stress period, the confound is live.

**Effect sizes are reported without adequate benchmarking against the prior literature**

The paper reports that high-CECL banks experienced a 0.394 pp decline in uninsured time deposits as a share of assets (~7% of the sample mean) and an 8–9 bp annualized increase in funding costs. These are stated as economically meaningful but are never compared to effect sizes in the closest prior studies — Maechler and McDill (2006), Egan et al. (2017), or Iyer et al. (2016) — which also estimate deposit outflows and rate increases in response to risk signals. Without this benchmarking, readers cannot judge whether the CECL shock produces discipline of comparable magnitude to realized distress events or whether it is an order of magnitude smaller. Given that the paper's main contribution is showing discipline operates in normal times, the comparison to crisis-period estimates is essential context. The paper should add a brief table or paragraph translating its estimates into the same units used by the two or three most comparable prior papers.

**Capital channel not separated from information channel via phase-in election test**

The paper argues the CECL adjustment is a pure information event because it involves no cash transfer or change in actual financial condition. Footnote 2 acknowledges that banks could elect a three-year regulatory capital phase-in, which means two banks with identical CECL adjustments and identical disclosed information could differ in their immediate regulatory capital impact. This creates a direct test: if deposit and funding-cost effects are driven by the information channel, they should be similar for phase-in electors and non-electors, since both groups disclose the same adjustment. If instead effects are driven by depositors responding to the capital ratio reduction itself, phase-in electors should show attenuated responses. The paper never runs this test. Without it, the information-versus-capital-channel distinction is asserted rather than demonstrated. The fix is straightforward: add an indicator for phase-in election to Table 3 and Table 5 as a triple interaction, or split the sample by election status and compare coefficients. Call Report Schedule RI-A contains the information needed to identify electors.

**Non-time deposit categories never examined, leaving rollover mechanism story incomplete**

The paper's mechanism rests on the rollover margin: uninsured depositors discipline banks by declining to renew maturing time deposits rather than breaking contracts early. This implies demand deposits and savings accounts, which have no fixed maturity, should show a different pattern. If sophisticated depositors were simply fleeing high-CECL banks through any available channel, demand deposits would also decline. If the effect is truly concentrated in time deposits because of the rollover mechanism, demand and savings balances should be unaffected or show a smaller response. The paper never tests this. Showing a near-zero coefficient on uninsured demand deposits in a specification parallel to Table 3 would directly confirm the rollover mechanism and rule out a general flight-to-quality story. This is a standard falsification test in the depositor discipline literature and its absence leaves the mechanism claim underdeveloped.

**Phase-in election rate unreported, leaving sample composition unclear**

The paper never reports what fraction of community banks elected the regulatory capital phase-in, nor whether election rates differed between high- and low-CECL banks. If high-CECL banks disproportionately elected the phase-in, which is rational given they faced the largest capital hit, then the treatment group in the main regressions mixes banks with and without near-term capital pressure. The composition of this mixture matters for interpreting effect sizes and for understanding whether results generalize to settings where no phase-in is available. A simple addition to Table 1 reporting phase-in election rates by CECL group would clarify the sample composition and directly inform the capital-versus-information channel discussion.

**Recommendation**: major revision

**Key revision targets**:

1. Either drop the large-bank validation exercise entirely or replace it with an identification strategy that is not confounded by COVID-19 — for example, using pre-pandemic filing dates, analyst forecast revisions at the individual filing level, or a placebo test using banks that adopted voluntarily before the mandate.
2. Add a direct test that the CECL adjustment predicts post-adoption deposit changes beyond what is explained by pre-adoption trends in NPL ratios and allowance levels — specifically, include the pre-adoption slope of uninsured deposits as a control or show that results hold when restricting to banks with stable pre-adoption credit quality metrics.
3. Report Callaway-Sant'Anna or Sun-Abraham estimates as a robustness check on the main DiD results, and explicitly address whether the growing post-adoption gap in event-study plots biases the TWFE estimates.
4. Resolve the internal inconsistency in the sophistication heterogeneity results: either demonstrate a statistically significant quantity effect over a longer horizon or reframe the mechanism as primarily price-based discipline, and add an event-study plot for the insured deposit series extending to at least 2020 to rule out pre-existing divergence.
5. Add a temporal decomposition of the post-adoption effect separating the immediate post-SVB quarters (2023Q1–Q2) from later quarters, to assess whether the estimated discipline effect is concentrated in the stress period or persists into calmer conditions.

**Status**: [Pending]

---

## Detailed Comments (23)

### 1. COVID confound invalidates Figure 3 as a clean validation exercise

**Status**: [Pending]

**Quote**:
> We do not use this cohort for our main tests because the 2020Q1 adoption date coincides with the onset of the COVID-19 pandemic, which overwhelmed any deposit-market signal with aggregate liquidity demand and emergency policy interventions.
> 
> Figure 3 reports event-study estimates of the differential market response around CECL adoption, using the continuous CECL Adj ratio as treatment intensity with bank and calendar-month fixed effects. Panel A shows equity market capitalization: the pre-adoption coefficients across nine lead months are flat and statistically indistinguishable from zero, ruling out systematic anticipation by equity investors. At the adoption month, market capitalization drops sharply and persistently for banks with larger CECL adjustments. Panel B shows CDS spreads: the pre-adoption pattern is similarly flat, and spreads widen materially at adoption and remain elevated in subsequent months. Both markets revised assessments sharply at the moment of disclosure, not before, consistent with the CECL adjustment conveying genuine information about credit-risk composition that was not recoverable from prior disclosures.

**Feedback**:
The paper's own logic defeats this validation exercise. The 2020Q1 cohort is excluded from the main tests because COVID 'overwhelmed any deposit-market signal' — yet Figure 3 uses that same cohort and that same quarter to argue that equity and CDS markets moved 'at the moment of disclosure, not before,' attributing the break to CECL information revelation. These two claims cannot coexist. Any bank with a large CECL adjustment (i.e., a riskier loan portfolio) would also have been hit harder by the pandemic credit shock, producing exactly the pattern in Figure 3 regardless of whether CECL conveyed new information. The flat pre-adoption coefficients do not resolve this: COVID arrived simultaneously with the adoption month, so the pre-period is clean by construction and the break at adoption is consistent with either story. Calendar-month fixed effects remove the average market movement but leave intact the differential response that is confounded with differential COVID exposure among high-CECL banks. The concluding sentence — 'Both markets revised assessments sharply at the moment of disclosure, not before, consistent with the CECL adjustment conveying genuine information' — needs to be rewritten to acknowledge that the pandemic shock is an observationally equivalent alternative explanation for the adoption-month break. The validation exercise should either be dropped or replaced — for instance, using analyst forecast revisions tied to specific 10-K filing dates, or restricting to the handful of large banks with non-calendar fiscal years that filed before the pandemic onset.

---

### 2. Interest expense control creates a bad-control problem in deposit quantity regressions

**Status**: [Pending]

**Quote**:
> $\mathbf{X}_{it-1}$ is a vector of lagged controls (log assets, equity-to-assets ratio, interest expense-to-assets). Bank fixed effects absorb all time-invariant differences across institutions, including balance-sheet composition, business model, geographic market, and charter type, so that $\hat{\beta}$ is identified from within-bank changes in outcomes over time.

**Feedback**:
Interest expense-to-assets is one of the paper's own outcome variables in Table 5. Including its lagged value as a control in the deposit-quantity regressions is a bad-control problem: if CECL adoption causes banks to raise deposit rates — the paper's price-discipline result — then lagged interest expense is on the causal path from CECL exposure to deposit quantity. Conditioning on it partially absorbs the treatment effect and biases the quantity coefficient toward zero. The problem is sharpest for the uninsured time deposit specifications, where the paper argues sophisticated depositors first extract higher rates and then reduce balances — exactly the sequence that makes lagged interest expense endogenous to treatment. The paper even acknowledges this possibility ('to the extent that banks anticipated the CECL shock and adjusted deposit rates ahead of formal adoption, absorbs any such anticipatory response') but frames it as a feature rather than a bias. If anticipatory repricing is part of the treatment mechanism, absorbing it attenuates the estimated quantity effect. The fix is to drop interest expense-to-assets from the deposit-quantity regressions and retain it only where it is not the dependent variable. At minimum, report specifications without this control as a robustness check and show the coefficient on the CECL interaction is stable.

---

### 3. Low R² misused as evidence of treatment orthogonality to credit quality

**Status**: [Pending]

**Quote**:
> The cross-sectional regression in Table 2 confirms that the CECL adjustment is predicted by NPL ratios and historical allowance levels, with a maximum adjusted $R^{2}$ of roughly one percent, and shows no meaningful relationship with deposit structure variables. This evidence is consistent with treatment intensity being largely independent of pre-adoption deposit outcomes

**Feedback**:
The inference from low R² to near-orthogonality does not hold. R² measures the fraction of variance explained by the regressors — it does not measure whether the systematic component of the treatment variable is economically negligible. NPL/Loans carries a t-statistic of roughly 2.8 and Allowance/Loans one of roughly 4.3 in column (3); both are highly significant. A regression can have R² near 1% while still showing that the treatment variable is systematically correlated with credit-quality proxies that depositors observe in public Call Reports every quarter. Low R² means the cross-sectional variation in CECL Adj is mostly idiosyncratic noise — it does not mean the explained component is zero or that depositors cannot use NPL and allowance trends to partially anticipate which banks will have large adjustments. The paper's own Table 1 shows that high-CECL banks had significantly higher NPL ratios and allowance ratios before adoption, which are exactly the inputs to the CECL calculation. The correct argument would require showing that the fitted values from Table 2 column (3) — the predictable component of CECL Adj — do not drive the main deposit results. Rewrite 'This evidence is consistent with treatment intensity being largely independent of pre-adoption deposit outcomes' as 'This evidence suggests that a large share of the cross-sectional variation in treatment intensity is idiosyncratic to the accounting measurement rather than driven by observable credit quality proxies' — and add a robustness specification that includes NPL ratios and allowance levels directly as controls in equation (5) to show the CECL coefficient is stable.

---

### 4. Missing lower-order interaction term in triple-difference specification

**Status**: [Pending]

**Quote**:
> where $d\in\{\text{uninsured},\text{insured}\}$ indexes deposit type and $\alpha_{it}$ are bank $\times$ quarter fixed effects. These absorb the full vector of bank-specific time-varying shocks in each period, so identification comes from the differential movement of uninsured relative to insured deposits within the same bank and the same quarter.

**Feedback**:
The written equation omits the CECL_i × Post_t two-way interaction, which is a required lower-order term in any standard triple-difference. The paper's implicit defense is that α_{it} absorbs it — but this is only true if α_{it} is a fully saturated bank × quarter fixed effect (one dummy per bank-quarter cell), not additive bank + quarter effects. With additive fixed effects, CECL_i × Post_t varies across both dimensions and is not absorbed, making its omission a genuine specification error. The paper never states which type of fixed effect is used. The sentence 'These absorb the full vector of bank-specific time-varying shocks' suggests fully saturated fixed effects are intended, but this needs to be stated explicitly. Add a sentence after the equation: 'Because α_{it} is a fully saturated bank × quarter fixed effect — one indicator per bank-quarter cell — it subsumes CECL_i × Post_t, which is why that two-way interaction does not appear separately in the equation.' Without this clarification, the omission reads as a misspecified triple-difference.

---

### 5. Drechsler, Savov, and Schnabl (2017) citation misapplied to loan-market competition claim

**Status**: [Pending]

**Quote**:
> The joint decline in ROA and NIM is consistent with higher liability costs not being passed through to borrowers, in line with community banks facing competitive local loan markets *(Drechsler, Savov, and Schnabl, 2017)*.

**Feedback**:
Drechsler, Savov, and Schnabl (2017) — 'The Deposits Channel of Monetary Policy' — is about deposit market power and how banks with local deposit market concentration pass monetary policy rate changes to depositors slowly. It says nothing about loan-market competition preventing banks from passing higher funding costs to borrowers. The paper's claim is that competitive loan markets prevent rate pass-through on the asset side, which is a different mechanism entirely. Citing DSS (2017) for this claim is backwards: their framework would predict that banks with deposit market power can absorb funding cost shocks precisely because they have pricing power on the liability side, not because loan markets are competitive. Replace this citation with references to the loan-market competition literature — Hannan and Berger (1991), Neumark and Sharpe (1992), or Petersen and Rajan (1994) on relationship lending — which actually speak to asset-side rate stickiness at community banks.

---

### 6. ROA decline substantially exceeds NIM decline, implying an unexplained additional channel

**Status**: [Pending]

**Quote**:
> Return on assets fell by 0.038 percentage points per quarter for high-CECL banks (column 4, $p<0.01$), an annualized drag of about 15 basis points and roughly 13 percent of the sample mean. Net interest margin contracted by 0.024 percentage points per quarter (column 6, $p<0.05$).

**Feedback**:
The annualized ROA decline is 0.038 × 4 = 15.2 bp, while the annualized NIM decline is 0.024 × 4 = 9.6 bp — ROA falls roughly 58% more than NIM. Since NIM is the primary driver of ROA for community banks, this gap implies either non-interest expense rose, loan-loss provisions increased, or non-interest income fell at high-CECL banks after adoption. The paper attributes the entire ROA decline to the funding cost channel ('higher liability costs not being passed through to borrowers'), but that channel should produce an ROA decline roughly equal to the NIM decline, not 58% larger. The discrepancy is not trivial and could indicate that high-CECL banks also increased provisioning post-adoption as their credit quality deteriorated independently of the CECL shock — which would reintroduce the confound between information revelation and actual financial deterioration. Add a sentence acknowledging the ROA–NIM gap and ruling out the provision channel, or report the provision expense coefficient in Table 5 to show it is near zero.

---

### 7. Negative-adjustment banks receive a positive equity signal, not merely low treatment

**Status**: [Pending]

**Quote**:
> a smaller number recorded negative values where the existing ILM reserve exceeded the CECL estimate. We exploit this cross-sectional variation in $\Delta_{i}$ in the empirical design.

**Feedback**:
The paper describes negative-delta banks as the low end of the treatment distribution, but the economic implication is the opposite of positive-delta banks: when the adjustment is negative, the bank releases reserves into retained earnings, increasing reported book equity on the adoption date. This is a positive credit-quality signal disclosed at the same moment. If these banks are pooled with near-zero banks in the control group, the control group is heterogeneous in a way that could bias the estimated treatment effect — depositors at negative-adjustment banks may increase balances, attenuating the measured contrast with the high-CECL group. The paper should report the fraction of negative-adjustment banks in the sample, verify they are few enough to be inconsequential, and show robustness to excluding them. Table 1 shows the Low CECL group has a mean CECL Adj./Equity of −0.020% with SD of 0.641, confirming a non-trivial share of negative-adjustment banks in the control group. Add a robustness check restricting the Low group to banks with adjustments in [0, 2.5%).

---

### 8. Calendar-quarter fixed effects do not absorb differential SVB-stress amplification at riskier banks

**Status**: [Pending]

**Quote**:
> Calendar-quarter fixed effects absorb the aggregate shock common to all community banks in 2023Q1, and the treatment effect is identified from the differential response at high-CECL relative to low-CECL banks within that quarter.

**Feedback**:
Calendar-quarter fixed effects remove the common mean shift in deposit behavior in 2023Q1, but the threat to identification is not that SVB raised outflows uniformly — it is that SVB heightened depositor sensitivity to any observable risk signal, causing depositors at already-riskier banks (which happen to be the high-CECL group) to respond more strongly. This differential amplification is not absorbed by calendar-quarter fixed effects; it would appear in the data as exactly the interaction the TWFE estimator attributes to the CECL treatment. The three features listed in Section 5.4 do not address this channel: showing that high-CECL banks were not directly exposed to the SVB mechanism (duration risk, securities losses) establishes only that they were not directly contagious, not that depositors did not use the SVB episode as a trigger to re-examine credit risk at community banks generally. A direct test would show that the post-adoption effect is not concentrated in 2023Q1–Q2 (the peak stress period) but persists with similar magnitude in 2023Q3–Q4 and beyond, when aggregate stress had subsided. If the effect is front-loaded in the stress quarters, the differential-sensitivity confound is live.

---

### 9. CECL adjustment magnitude reflects current economic forecasts, not only historical lending decisions

**Status**: [Pending]

**Quote**:
> whose magnitude reflects historical lending decisions rather than current deposit market conditions.

**Feedback**:
CECL is explicitly a forward-looking expected credit loss standard — its defining departure from the incurred-loss model is that banks must incorporate current economic conditions and reasonable forecasts of future conditions when estimating lifetime expected losses. Two banks with identical historical loan origination histories could produce materially different CECL adjustments if they adopt different economic forecasts or if their portfolios have experienced different recent performance trends. The characterization that the adjustment magnitude is insulated from 'current' conditions is therefore inaccurate: the adjustment is mechanically tied to current portfolio quality and current macro forecasts, both of which are observable to depositors through Call Reports prior to adoption. Rewrite as 'whose magnitude reflects the bank's assessment of lifetime expected losses on its existing loan portfolio, incorporating both historical lending decisions and current economic conditions at adoption' and add a sentence acknowledging that the forward-looking component is addressed by the parallel-trends and pre-trend tests in Section 5.1.

---

### 10. Rollover mechanism claim unsupported without a falsification test on demand deposits

**Status**: [Pending]

**Quote**:
> al assets. Time deposits are particularly well suited to detecting depositor discipline since a decline in balances reflects a deliberate choice not to renew rather than routine liquidity manage
> 
> <!-- PAGE BREAK -->
> 
> ment.
> 
> The funding-cost outcome is quarterly interest expense sca

**Feedback**:
The paper's stated mechanism is that uninsured depositors discipline banks by declining to renew maturing time deposits rather than breaking contracts early. This implies demand deposits and savings accounts — which have no fixed maturity — should show a different pattern. If the effect were a general flight from high-CECL banks through any available channel, demand deposits would also decline. If the effect is truly concentrated in time deposits because of the rollover mechanism, demand and savings balances should be unaffected or show a smaller response. The paper never tests this. Showing a near-zero coefficient on uninsured demand deposits in a specification parallel to Table 3 would directly confirm the rollover mechanism and rule out a general flight-to-quality story. This is a standard falsification test in the depositor discipline literature and its absence leaves the mechanism claim underdeveloped. Add a sentence here noting that uninsured non-time deposits are examined as a placebo outcome, and report those results alongside the primary findings.

---

### 11. Sophistication amplification conflates price and quantity discipline margins in the conclusion

**Status**: [Pending]

**Quote**:
> The disciplinary response is amplified at banks in markets with financially sophisticated depositor bases, consistent with a mechanism operating through informed monitoring rather than mechanical portfolio adjustment.

**Feedback**:
The triple-interaction coefficient for uninsured deposit quantities (Post × High CECL × High Sophistication = −0.022, SE = 0.468) is statistically indistinguishable from zero, while the significant amplification effects appear on the price channel (interest expense triple interaction = +0.044, p = 0.020) and profitability (ROA triple interaction = −0.076, p = 0.010). Readers of the conclusion will naturally anchor on the paper's headline quantity result and read 'amplified disciplinary response' as amplified quantity withdrawal. The depositor discipline literature does recognize price discipline as a legitimate form of discipline, so the sentence is not formally wrong, but it elides a meaningful distinction between the two margins. The conclusion elsewhere carefully distinguishes 'contractions in uninsured time deposits' from 'higher funding costs' as separate outcomes; the sophistication heterogeneity sentence should maintain that same precision. Rewrite as 'The funding-cost and profitability effects are amplified at banks in markets with financially sophisticated depositor bases, consistent with informed depositors extracting higher rates upon observing the CECL disclosure' to accurately reflect that the detected amplification is on the price margin rather than the quantity margin.

---

### 12. Insured deposit result sign in sophistication channel contradicts the stated mechanism

**Status**: [Pending]

**Quote**:
> Panel B shows that high-sophistication banks also attracted fewer insured deposits than their low-sophistication counterparts after adoption ($-0.965$, SE $=0.677$, $p=0.154$), consistent with sophisticated depositors being more reluctant to serve as replacement insured funding at institutions whose credit quality has deteriorated.

**Feedback**:
The main results in Table 3 show that high-CECL banks gain insured deposits after adoption (+0.712 pp, p < 0.05), interpreted as banks substituting toward insured funding after losing uninsured deposits. The sophistication triple-interaction for insured deposits is −0.965, meaning high-sophistication/high-CECL banks gain fewer insured deposits than low-sophistication/high-CECL banks. The paper's interpretation — that sophisticated depositors are 'reluctant to serve as replacement insured funding' — treats this as a behavioral story about insured depositors. But insured depositors face no credit risk regardless of sophistication; their reluctance to deposit at deteriorating banks is not predicted by any standard depositor discipline model, since they bear no loss. A more natural reading is that high-sophistication markets have a different baseline composition of insured versus uninsured depositors, and the −0.965 coefficient reflects a compositional difference rather than a behavioral response. Remove the causal language and replace it with a descriptive statement that flags the result as requiring further investigation.

---

### 13. High-CECL banks have significantly higher insured time deposits at baseline, complicating the post-adoption insured deposit increase interpretation

**Status**: [Pending]

**Quote**:
> Ins. Time Deps / Assets (%) | 7.367 | 5.846 | 5.926 | 8.116 | 6.342 | 6.529 | 7.284 | 5.783 | 5.846 | 0.832***

**Feedback**:
Table 1 shows that high-CECL banks enter adoption with significantly higher insured time deposits as a share of assets (8.116% vs. 7.284%, difference = 0.832 pp, p < 0.01). The paper's main results in Table 3 report that insured deposits increase at high-CECL banks after adoption and interpret this as banks substituting toward insured funding after losing uninsured deposits. But the pre-adoption baseline already shows high-CECL banks are more reliant on insured time deposits, raising the question of whether the post-adoption increase is a continuation of a pre-existing structural difference rather than a post-CECL substitution response. The paper's event-study plots are the natural place to address this, but the table itself — the first place readers encounter the baseline comparison — should flag this pre-existing difference explicitly. Add a sentence to the table note stating that the pre-adoption difference in insured time deposits is addressed in the event-study specifications in Section 6, which test for pre-adoption trend differences in both series.

---

### 14. Triple-difference coefficient inconsistent with the arithmetic difference of the component DiD estimates

**Status**: [Pending]

**Quote**:
> Table 4 reports the estimates. The triple interaction in the binary specification (column 2) is $-1.252$ (standard error $0.340$, $p<0.01$): relative to their own pre-adoption composition and relative to low-CECL banks, high-CECL banks experienced a 125-basis-point widening of the insured-to-uninsured gap as a share of assets after adoption.

**Feedback**:
In a triple-difference, the three-way interaction coefficient should approximately equal the difference between the two component DiD estimates: (−0.394) − (+0.712) = −1.106 pp. The reported value is −1.252 pp, a gap of about 15 basis points. This is roughly 0.4 standard errors and is never explained. The most likely source is that the stacked panel in Table 4 uses bank × quarter fixed effects that absorb variation differently than the separate regressions in Table 3, or that the two tables use slightly different samples. Readers will compute this check. Add a footnote to Table 4 noting that the stacked estimate differs from the arithmetic difference of Table 3 columns 2 and 4 because the bank × quarter fixed effects in the stacked specification impose within-bank-quarter identification that the separate regressions do not, and confirm the two tables use the same sample.

---

### 15. Adoption search window may exclude 2022Q1–Q2 adopters, misclassifying them as non-adopters

**Status**: [Pending]

**Quote**:
> CECL adoption is identified by searching the window 2022Q3–2023Q4 for the first quarter in which a bank reports a non-missing value for the cumulative-effect retained-earnings adjustment in Schedule RI-A.

**Feedback**:
The mandatory CECL adoption date for non-SEC-filer community banks was fiscal years beginning after December 15, 2021, which for calendar-year institutions means 2022Q1. The search window begins at 2022Q3, so any bank that adopted in 2022Q1 or 2022Q2 — either mandatorily on a non-calendar fiscal year or voluntarily — would be excluded from the treatment group entirely, or worse, misclassified as a non-adopter and left in the control group. Banks with non-standard fiscal years (e.g., fiscal year beginning April 1) would have had mandatory adoption dates in mid-2022, squarely within the excluded window. The paper should either justify why no community bank could have adopted before 2022Q3, or extend the search window back to at least 2022Q1 and report how many banks are picked up in the earlier quarters. Rewrite 'searching the window 2022Q3–2023Q4' as 'searching the window 2022Q1–2023Q4' (or the appropriate earlier bound) and add a footnote reporting the distribution of adoption quarters among identified adopters.

---

### 16. Exclusion rule for non-adopters conflates true zero-adjustment banks with non-reporters

**Status**: [Pending]

**Quote**:
> Banks with no non-missing adjustment in the eligible window are excluded.

**Feedback**:
A bank could show no non-missing Schedule RI-A adjustment for two distinct reasons: it genuinely had a zero Day-One adjustment (its allowance was already adequate under CECL), or it failed to report the line item correctly — a known data-quality issue in early Call Report filings for new CECL fields. Banks with a true zero adjustment are substantively different from non-adopters: they adopted CECL but experienced no retained-earnings hit, and excluding them removes a potentially informative part of the distribution (the low end of CECL Adj). If these zero-adjustment adopters are excluded, the treatment variable is effectively truncated below, which could bias the estimated dose-response relationship upward. Clarify whether 'non-missing' means strictly positive or simply reported (including zero), and report how many banks fall into each category. Consider retaining confirmed zero-adjustment reporters as a separate robustness group.

---

### 17. Inferential leap from large-bank equity/CDS reactions to community-bank depositor behavior

**Status**: [Pending]

**Quote**:
> This evidence supports the interpretation that community bank uninsured depositors in 2023 were responding to a real, previously unavailable signal, rather than to a mechanical accounting reclassification.

**Feedback**:
Even setting aside the COVID confound, the logical step from large-bank equity and CDS market reactions in 2020 to community-bank depositor behavior in 2023 requires two assumptions that are never stated or defended. First, it assumes the information content of the CECL adjustment is similar across the two cohorts — large publicly traded banks in 2020 and small community banks in 2023 — despite fundamental differences in portfolio composition, disclosure environment, and analyst coverage. Second, it assumes that equity investors and CDS traders process accounting disclosures in the same way as retail and small-business depositors at community banks. The information environment for large banks is far richer (analyst coverage, frequent earnings calls, CDS market participants who specialize in credit analysis), so a signal that moves those markets need not be news to community bank depositors who may rely on simpler heuristics. Rewrite this sentence to say the large-bank evidence is consistent with CECL conveying credit-risk information in a setting where market prices are observable, while acknowledging that this does not directly establish the same for community bank depositors in 2023.

---

### 18. Pre-trend window length asserted without justification

**Status**: [Pending]

**Quote**:
> The event-study pre-period coefficients in Section 6 confirm that deposit trends were parallel across groups in the ten quarters before adoption.

**Feedback**:
Ten quarters (roughly 2.5 years) is stated as sufficient to establish parallel trends, but no justification is given for why this window is adequate. The CECL standard was finalized in 2016 and community banks had years to prepare their loan-loss models before the 2023Q1 adoption date. If depositors or bank managers began adjusting behavior in anticipation of the disclosure as early as 2019–2020, a pre-period starting around 2020Q3 would miss that adjustment entirely. Simply reporting that the ten-quarter window shows parallel trends is not the same as showing that no pre-adjustment occurred before that window opened. Add a sentence explaining why the pre-period begins where it does and whether data availability constrains the window length.

---

### 19. Interest expense scaling uses average assets inconsistently with deposit outcome scaling

**Status**: [Pending]

**Quote**:
> The funding-cost outcome is quarterly interest expense scaled by average total assets; net interest margin is quarterly net interest income scaled by average total assets. Profitability is measured by return on assets, computed as quarterly net income to average total assets.

**Feedback**:
The deposit outcomes (uninsured and insured time deposits) are scaled by contemporaneous total assets, but interest expense, net interest margin, and ROA are all scaled by average total assets. In a DiD setting where the treatment group may be shrinking its balance sheet post-adoption — precisely because it is losing deposits — the choice of denominator matters for interpretation. Scaling deposit quantities by end-of-period assets while scaling income-statement items by average assets means the two sets of outcomes are not directly comparable, and the funding-cost effect could be mechanically amplified if high-CECL banks' average assets fall faster than their interest expense adjusts. Either standardize all outcomes to the same denominator or explicitly justify why the mixed scaling is appropriate and show it does not drive the funding-cost results.

---

### 20. Claim that deposit structure is 'broadly similar' contradicts the reported baseline difference in insured time deposits

**Status**: [Pending]

**Quote**:
> The pre-adoption deposit structure of the two groups is broadly similar on dimensions central to our outcome variables. Neither uninsured time deposits as a share of assets nor the total uninsured deposit share differs significantly between the groups. One exception: High-CECL banks hold somewhat more insured time deposits at baseline, reflecting greater reliance on retail interest-bearing funding.

**Feedback**:
The paper characterizes the deposit structures as 'broadly similar' and then immediately notes a significant difference in insured time deposits — the very category that appears as a dependent variable in Table 3 (column 4) and is central to the triple-difference design in Table 4. Calling this an 'exception' while asserting broad similarity is internally inconsistent: if insured time deposits differ at baseline, the claim of similarity on 'dimensions central to our outcome variables' is weakened, since insured time deposits are one of those dimensions. The paper's defense — that bank fixed effects absorb the level difference — is correct for the DiD estimator but does not address whether the growth rate of insured time deposits also differed pre-adoption. Rewrite to acknowledge the baseline difference directly and explain why the fixed-effects design handles it, rather than burying it as an afterthought exception.

---

### 21. Mandatory/audited framing does not distinguish CECL from routine Call Report disclosures

**Status**: [Pending]

**Quote**:
> The disclosure is also mandatory, quantified, and audited, which distinguishes it from voluntary disclosure events where the decision to disclose is itself endogenous to management strategy, and from supervisory rating changes where the information event is confounded by the behavioral constraints regulators impose directly.

**Feedback**:
Every quarterly Call Report filing is also mandatory, quantified, and audited — NPL ratios, allowance levels, and capital ratios are all reported under the same regulatory framework. If those properties alone were sufficient to generate a clean information shock, prior work using Call Report NPL data would already have the identification advantage the paper claims is unique to CECL. The actual distinguishing feature of the CECL Day-One adjustment is not that it is mandatory and audited, but that it is a one-time, forward-looking restatement that forces banks to reveal their expected loss estimates in a single number at a predetermined calendar date, regardless of whether management would have chosen to signal that information voluntarily. Reframe the argument around the predetermined adoption date and the forced aggregation of forward-looking credit-risk estimates into a single disclosed figure, dropping the mandatory/audited framing that does not differentiate CECL from routine Call Report items.

---

### 22. Pre-trend test description overstates the pre-period covered

**Status**: [Pending]

**Quote**:
> Coefficients $\{\hat{\beta}_{k}\}_{k<0}$ test for pre-adoption differential trends between high- and low-CECL banks; coefficients $\{\hat{\beta}_{k}\}_{k\geq 0}$ trace the cumulative post-adoption effect. A pattern of flat pre-trends followed by a post-adoption break supports the interpretation that observed differences are caused by the CECL disclosure rather than pre-existing divergence.

**Feedback**:
With k = −1 as the omitted reference period, the pre-trend coefficients that are actually estimated run from k = −10 through k = −2, not the full set k < 0. The k = −1 period is normalized to zero by construction and contributes no information to the pre-trend test. Describing the pre-trend test as covering 'k < 0' is imprecise and could cause confusion when readers look for a coefficient at k = −1 in the event-study figures. Rewrite as 'Coefficients for k from −10 through −2 test for pre-adoption differential trends between high- and low-CECL banks, with k = −1 normalized to zero as the reference period.'

---

### 23. Log(Assets) is the strongest predictor in Table 2 but its implications for identification are never discussed

**Status**: [Pending]

**Quote**:
> log(Assets) | 0.0457*** | 0.0621*** | 0.0695***  |
> |   |  (0.0159) | (0.0180) | (0.0185)  |

**Feedback**:
Log(Assets) is the only significant predictor in column (1) and remains significant across all three columns, with a t-statistic above 3.7 in every specification. Larger banks have systematically larger CECL adjustments scaled by equity. The paper never discusses this. One natural explanation is that larger community banks hold more complex or longer-duration loan portfolios requiring larger lifetime-loss estimates under CECL; another is that larger banks historically under-provisioned relative to smaller ones. Either way, if size predicts the treatment variable, and if size also independently predicts deposit dynamics, then size is a potential omitted variable in the main deposit regressions. Add a sentence in the Table 2 discussion explaining the positive size coefficient and confirming that bank fixed effects in the main regressions absorb any time-invariant size effect.

---
