# Citation Claim Verification — fdic-brc-jfqa-aug2026

**Date**: 2026-08-08
**Manuscript**: `tracks/fdic-brc-jfqa-aug2026/latex/main.tex` (48 pp build) + section files
**Sources**: full-text markdowns in `C:/Users/dimut/OneDrive/github/paper-repo/mds/`
**Method**: every citing sentence extracted; claims verified by parallel read-only agents against located text in the source markdown. Verdicts: CONFIRMED (supporting quote found), CORRECTED (source says something different; manuscript already fixed where noted), NOT FOUND, NO-SOURCE.

**Coverage**: 46 cited keys. `FASB2016` is a regulatory document (ASU 2016-13 / ASC 326) — factual citation, no verification needed. All others verified below.

---

## Summary

| # | Key | Verdict | Note |
|---|-----|---------|------|
| 1 | jordan1999impact | CONFIRMED | all four numbers exact |
| 2 | chen2022bank | CONFIRMED | 26% is per-SD of transparency |
| 3 | huberdeau2025adverse | CONFIRMED | published JFI 2025 (bib fixed) |
| 4 | cipriani2024tracing | CONFIRMED | 7.6%/1.0% exact |
| 5 | gee2022decision | CONFIRMED | recast to equity investors (was miscited as analysts; fixed) |
| 6 | caglio2024depositors | CONFIRMED | restated (was cited backwards; fixed) |
| 7 | jiang2024monetary | CONFIRMED | |
| 8 | blickle2024who | CONFIRMED | RFS 2024; bib lacks vol/pages |
| 9 | meiselman2023judging | CONFIRMED | |
| 10 | morgan2002rating | CONFIRMED | md is 2000 WP draft; AER 2002 metadata external |
| 11 | bendavid2017banks | CONFIRMED | md is 2013 draft; JFQA 2017 metadata external |
| 12 | begenau2023uniform | CONFIRMED | ">90% of branches" per source wording |
| 13 | granja2024market | CONFIRMED | source is a slide deck; qualitative claims only |
| 14 | egan2025sleepy | CONFIRMED | NBER WP 34267 |
| 15 | jacewitz2018deposit | CONFIRMED | insured leg is the $25K MMDA |
| 16 | maechler2006dynamic | CONFIRMED | near-verbatim |
| 17 | martin2026deposit | CONFIRMED | JF (forthcoming per md) |
| 18 | goldberg2002depositor | CONFIRMED | |
| 19 | kim2024insurance | CONFIRMED | title is "Network-Based" (bib fixed) |
| 20 | davila2023optimal | CONFIRMED | monitoring claim removed (their cost is fiscal, not monitoring) |
| 21 | kelly2025rushing | CONFIRMED | "smaller banks faced less pressure" is their statement |
| 22 | flannery2017stress | CONFIRMED | capital-market audience; silent on depositors |
| 23 | chen2022does | CONFIRMED | manuscript fixed (old text said "reduced procyclicality" — opposite) |
| 24 | kim2026current | CONFIRMED | |
| 25 | FASB2016 | N/A | regulatory document |
| 26 | calomiris1991role | CONFIRMED | |
| 27 | diamond2001liquidity | CONFIRMED | |
| 28 | park1995market | CONFIRMED | "slower growth," not literal outflows |
| 29 | martinez2001depositors | CONFIRMED | both insured and uninsured respond |
| 30 | iyer2016tale | CONFIRMED | |
| 31 | egan2017deposit | CONFIRMED | rates leg is a model result |
| 32 | chen2024liquidity | CONFIRMED | |
| 33 | calomiris2019stealing | CONFIRMED | |
| 34 | o1990deposit | CONFIRMED | $10bn threshold is manuscript's own |
| 35 | flannery1996evidence | MIXED | keep for backstop mechanism; REMOVE from outflows list and realized-distress list |
| 36 | bennett2015market | CORRECTED | "liquidity needs" not in source; attenuation belongs to Berger-TA |
| 37 | berger2015depositors | CONFIRMED | small-US-bank exception unused (helps the paper) |
| 38 | nier2006market | CORRECTED | capital-buffer outcome; overreach + wrong list |
| 39 | demirgucc2004market | CONFIRMED | price margin only |
| 40 | bushman2012accounting | CONFIRMED | smoothing channel, not incurred-loss delay |
| 41 | bushman2015delayed | CONFIRMED | |
| 42 | beatty2011delays | CONFIRMED | "probable and estimable" quote not theirs (FAS 5) |
| 43 | granja2025current | CONFIRMED | authors call effect "moderate" |
| 44 | covitz2004market | MIXED | selection logic fine; deposit-sorting fact not theirs |
| 45 | hannan1988bank | NOT FOUND | zero loan-market content; recite or drop |
| 46 | davernas2023deposit | NOT FOUND | operating-accounts premise unsupported, partly inverted |

**Fixes already applied during the 2026-08-08 integration pass**: gee2022decision recast + retitled; caglio2024depositors recited/restated in intro and robustness; chen2022does lending direction corrected; davila2023optimal phrasing avoids the monitoring attribution; flannery2019market dropped entirely (no verifiable source anywhere — NO-SOURCE); greenwald2024monetary cut before citing (sample is 29 stress-tested BHCs; cannot support small-bank claims).

---

## Part A — Papers verified during the literature-integration pass (2026-08-08)

### 1. jordan1999impact — Jordan, Peek & Rosengren (1999), FRB Boston WP 99-1

**Manuscript claim** (intro): "When regulators were forced to disclose formal enforcement actions in 1989--1990, thirty-five large publicly traded holding companies lost roughly 10 percent of large time deposits while small time deposits rose and total deposits fell less than 2 percent."

**Source quotes**:
> "The remaining 35 BHCs were the focus of our empirical work."
> "The three-day and one-month abnormal returns decline on average by about 5 percent and somewhat more than 8 percent, respectively."
> "the mean change in total deposits reflects a decline of less than 2 percent."
> "Transaction deposits and small time deposits actually increase, while savings deposits decline modestly and large time deposits more substantially."
> "Large time deposits are more responsive (an average decline of 10.3 percent)."

Bonus (footnote 10, useful for the no-repricing story): "This is not the result of banks substantially raising deposit rates to retain customers."

**Verdict: CONFIRMED** (every number exact). Caveat: the md itself carries no year/series number; 1999/WP 99-1 sourced externally.

### 2. chen2022bank — Chen, Goldstein, Huang & Vashishtha (2022), JFE 146(2)

**Manuscript claims** (intro ¶2 and contribution 1): "disclosure improvements enable depositors to act on credit-risk signals"; "uninsured deposit flows respond more strongly to performance at more transparent banks, that insured inflows offset the uninsured outflows, and that the offset is costly."

**Source quotes**:
> "a one-standard deviation increase in R2 is associated with a 26% increase in the flow-performance sensitivity."
> "transparent banks act to substitute the outflow of uninsured deposits in times of poor performance by attracting insured deposits with higher rates. The substitution appears to be effective, as the sensitivity of total deposits to bank performance does not significantly vary by transparency."
> "However, the substitution comes at a cost because of the higher deposit rates and insurance premium."
> SOX DiD: "Our final matched sample contains 592 public and 592 private banks."

**Verdict: CONFIRMED.** Precision note: the 26% is per one-SD of the transparency measure, not a transparent-vs-opaque binary; manuscript phrasing ("respond more strongly at more transparent banks") is consistent.

### 3. huberdeau2025adverse — Huberdeau-Reid & Pennacchi (2025), Journal of Financial Intermediation

**Manuscript claims** (intro contribution 3; results destination §): "riskier small and midsize banks expanded reciprocal and sweep deposits while paying higher rates."

**Source quotes**:
> Abstract: "riskier small and midsize banks tended to utilize reciprocal, sweep, and brokered deposits, but not listing service deposits, to attract more insured deposits."
> Abstract: "Riskier banks, particularly small and midsize ones, paid relatively higher interest rates on many types of deposits."
> The risk measure (Balance Sheet Risk, computed as of 2022Q4, ~4,656 banks) "predicts a bank's post-crisis loss of uninsured deposits."

**Verdict: CONFIRMED.** Manuscript deliberately cites reciprocal and sweep (brokered enters "to a lesser extent" in the source). Design is cross-sectional regressions of 2023 outcomes on end-2022 risk — the manuscript's "identifies off... contemporaneous balance-sheet risk" characterization is accurate as a description of the specification. Published JFI article (PII S1042-9573(25)00033-6), not a 2024 WP — bib updated.

### 4. cipriani2024tracing — Cipriani, Eisenbach & Kovner (2024, rev. 2026), FRBNY Staff Report 1104

**Manuscript claims** (intro stress defense; contribution 3; robustness): "intraday payments data identify twenty-two run banks, find no retail run, and put the run probability at 7.6 percent for publicly traded banks against 1.0 percent for private ones"; "the 2023 run banks eventually replaced lost uninsured deposits with higher-cost insured deposits."

**Source quotes**:
> "we identify twenty-two bank runs — ten times the two bank failures."
> "The dollar value of payments sent by run banks on the days they are run is four times larger than normal, whereas the number of payments sent is only about 20% larger. As a result, the average payment size more than triples."
> "we examine other channels through which depositors could run and find no evidence of other runs, including in the retail-oriented FedACH payment system, suggesting no meaningful role for retail depositors in March 2023."
> "Publicly traded banks have a run probability of 7.6% (18 out of 238) compared to only 1.0% for private banks (4 out of 386)."
> "Surviving banks bridge the deposit reallocation by borrowing from Federal Home Loan Banks and the discount window, eventually replacing lost uninsured deposits with insured deposits at higher rates in the medium term."

**Verdict: CONFIRMED.** Note: md in repo is the June 2026 revision; Kovner is at the Richmond Fed.

### 5. gee2022decision — Gee, Neilson, Schmidt & Xie (2026), SSRN 4038479

**Manuscript claims** (intro ¶2; inst_bg; contribution 2): "Day-One adjustments predict future net charge-offs and are reflected in equity prices, and the adjustment is new information precisely for smaller banks, whose information environments are thinnest"; "the information users it studies are equity investors."

**Source quotes**:
> "we identify the amount of expected credit losses incremental to the IL allowance that banks recognized to comply with CECL upon adoption (hereafter, 'the CECL day-1 impact')."
> "CECL day-1 impacts predict future loan losses — measured as future cumulative net charge-offs — and are reflected in equity prices... for both community banks (i.e., those with less than $10 billion in assets) and larger banks."
> "CECL allowances are new information only for smaller banks, consistent with larger banks' richer information environments already reflecting expected credit losses."

**Verdict: CONFIRMED** (after the fix — the previous draft filed this under "analysts", which the paper is not about; analysts appear only as auxiliary data). Current version is titled "When are expected credit losses relevant and new to investors? Evidence from CECL adoption", dated May 2026 — bib updated. Sample precision: 201 banks is the value-relevance sample; 175 for charge-off prediction.

### 6. caglio2024depositors — Caglio, Dlugosz & Rezende (2025), Federal Reserve Board WP

**Manuscript claim** (robustness): "the deposit reallocation of the stress weeks ran toward the largest banks on size and perceived safety rather than on balance-sheet fundamentals."

**Source quotes**:
> "large banks experienced faster deposit growth than small and regional banks without raising deposit rates."
> "Large banks' deposit growth rates exceeded other banks' even after accounting for characteristics associated with failures, including uninsured deposit funding and unrealized mark-to-market losses."
> "estimates of deposit growth rates at large banks remain higher even if we control for these characteristics, implying that fundamentals alone do not justify a perception that these banks are safer."

**Verdict: CONFIRMED** (after the fix — the previous draft cited this paper for "depositors ran on banks with high uninsured shares and unrealized losses," which is the opposite framing; that claim belongs to jiang2024monetary and was recited). Secondary nuance kept out of the manuscript: they do find a modest negative uninsured-share association (−0.36pp per SD in the March 15 week); the null is on unrealized losses/adjusted TCE. Paper dated Feb 25, 2025.

### 7. jiang2024monetary — Jiang, Matvos, Piskorski & Seru (2024), JFE 159

**Manuscript claims** (intro contribution 1; robustness): "Work on the 2023 episode identifies run exposure with the interaction of mark-to-market losses and uninsured funding"; "the characteristics that identified run-prone banks in 2023."

**Source quotes**:
> "revealing an average decline of 10%, totaling about $2 trillion in aggregate." (body: "$2.2 trillion lower than suggested by their book value")
> "Banks with high asset losses, low capital, and, critically, high uninsured leverage are most fragile."
> "SVB was not an extreme outlier from the perspective of asset losses but was an outlier from the perspective of its liabilities... only 1% of banks had higher uninsured leverage... 78% of its assets were funded by uninsured deposits."

**Verdict: CONFIRMED.**

### 8. blickle2024who — Blickle, Brunnermeier & Luck (2024), Review of Financial Studies

**Manuscript claim** (intro): "Retail depositors in a fully uninsured historical banking system could not tell failing banks from survivors; only interbank depositors could."

**Source quotes**:
> "the German system was lightly regulated with no capital or liquidity requirements and no deposit insurance. Thus, all types of depositors could plausibly expect to realize losses in the case of a bank failure."
> "deposits decline by around 20% over the two months from the start of the run to the end... There is no difference in total deposit outflows between failing and surviving banks."
> "outflows of regular deposits—retail and non-financial wholesale deposits—are the same across failing and surviving banks. In contrast, interbank deposits decline mostly for failing banks."

**Verdict: CONFIRMED.** (Manuscript wisely omits the AUC number, which requires the non-linear specification.) Bib: RFS 2024 without volume/pages — complete via `/skills/bib-validator` before submission.

### 9. meiselman2023judging — Meiselman, Nagel & Purnanandam (2023), NBER WP 31635

**Manuscript claim** (intro): "simple reported profitability predicts crisis tail risk better than model-based risk measures."

**Source quotes**:
> "Pooled across the three crisis episodes in our main analysis, a one standard deviation (s.d.) higher pre-crisis ROE is associated with approximately 0.30 s.d. lower returns on bad days during the crisis."
> "RWA-based risk measures perform worse than simple measures that can be easily obtained from publicly available financial reports."
> "each crisis-specific measure has strong predictive power in the crisis that brought attention to it ex post, but not in the other crises."

**Verdict: CONFIRMED.**

### 10. morgan2002rating — Morgan (2002), American Economic Review 92(4)

**Manuscript claims** (intro contribution 2; inst_bg): "rating agencies disagree over bank bonds more than over almost any other sector, and the disagreement traces to loans and trading assets"; "rating agencies split over bank bonds far more often than over other issuers, and the disagreement traces precisely to loans."

**Source quotes**:
> "we find that raters split substantially more over banks and insurance firms than over other types of firms."
> "Uncertainty over the banks stems from their assets, loans and trading assets in particular, the risks of which are hard to observe or easy to change."
> Table 7 (533 bank bonds, 96 BHCs): loans & leases +0.027 (p = 0.007), trading assets +0.066 (p = 0.000); capital −0.157 (p = 0.030).

**Verdict: CONFIRMED.** "Almost any other sector" is right — insurers split even more (kappa 0.09 vs banks 0.3). Repo md is the April 2000 FRBNY draft; AER 2002 metadata from Crossref.

### 11. bendavid2017banks — Ben-David, Palvia & Spatt (2017), JFQA 52(5)

**Manuscript claim** (rates §): "In the same RateWatch data, posted CD rates show no negative relation to bank risk and instead track the bank's own loan growth."

**Source quotes**:
> "we do not find a negative relation between deposit rates and bank capital before or during/after the financial crisis... During the period after 2008/Q4 we find a consistent positive relation."
> "branch-level deposit rates are correlated with the loan growth rates in the state in which the branches are located, as well as with loan growth in other states in which the bank operates."
> Sample: "an unbalanced panel with 6,582 banks between 2007/Q1 to 2012/Q3... with observations of 12-month CD rate" from RateWatch.

**Verdict: CONFIRMED.** Repo md is the Dec 2013 draft; JFQA 2017 metadata external.

### 12. begenau2023uniform — Begenau & Stafford (2023), SSRN 4136858

**Manuscript claim** (rates §): "Posted deposit rates are set centrally: more than 90 percent of branches follow a rate set elsewhere in the bank."

**Source quotes**:
> "US banks predominately use uniform deposit rate setting policies, particularly the largest banks." Follower branches represent "over 90% of all branches."
> "in 2007, Bank of America operated 5728 branches across 694 counties and 31 states, yet reported using only two different rates for retail money market accounts... across all of its US branches."
> "Uniform rate setting ignores local market concentration."

**Verdict: CONFIRMED** (manuscript uses the >90%-of-branches formulation, which is the source's own quantification).

### 13. granja2024market — Granja & Paixão (2024), working paper

**Manuscript claim** (rates §): "after mergers, target-branch rates converge to the acquirer's rate with little regard for local market concentration."

**Source quotes** (from the May 2021 conference slide deck — the only available artifact):
> "Strong Convergence between Rate of Target Branch and Median Rate of Acquirer after a bank merger."
> "Pre-merger difference in deposit and loan rates more important than predicted changes in local market concentration indices in explaining post-merger evolution of rates." (`Post-Acq. × ΔHHI` coefficients ≈ 0 and insignificant.)

**Verdict: CONFIRMED** — but the source in the repo is a slide deck, so the manuscript cites only the qualitative claims (correct as written). Do not add magnitudes from this source.

### 14. egan2025sleepy — Egan, Hortaçsu, Kaplan, Sunderam & Yao (2025), NBER WP 34267

**Manuscript claim** (rates §): "roughly 94 percent of depositors are inactive in a given year, and only about 15 percent of account closures involve switching for better terms."

**Source quotes**:
> "We estimate that approximately 94% of depositors are inactive each year."
> "depositors report switching to a bank offering better rates, services, or fees in only about 15% of cases." / "Only about 15% of account closures result from depositors shopping for better terms; the majority are driven by account inactivity, moving, and death."
> Data: Fiserv core account processing, "more than 900 banks and credit unions, covering more than 58 million deposit accounts."

**Verdict: CONFIRMED.**

### 15. jacewitz2018deposit — Jacewitz & Pogach (2018), J. Financial Services Research 53

**Manuscript claims** (rates §; intro guarantees list): "When a posted-rate risk premium is detectable at all, it appears as a within-branch spread between partially insured and fully insured products, and mainly in acute crisis quarters"; cited among "government guarantees attenuate estimates."

**Source quotes**:
> "branch level data to evaluate the differences in interest rates offered on partially insured $100K money market deposit account (MMDAs) versus the fully insured $25K MMDA accounts. Using the within-branch differences to obtain a bank risk premium measure allows us to account for non-risk factors specific to that branch."
> "Between 2007 and 2008, the risk premium paid by the largest banks was 35 bps lower than the risk premium at other banks."
> "before 2007, risk at large banks was not priced much differently from risk at other banks in the data." (Premium significant mainly in the quarters around Lehman.)
> "This difference vanishes following a regulatory change in the deposit limit."

**Verdict: CONFIRMED** on both uses (the 35bp large-bank discount is TBTF-perception evidence, fitting the guarantees-attenuate list).

### 16. maechler2006dynamic — Maechler & McDill (2006), JBF 30(7), 1871–1898

**Manuscript claims** (intro riskier-banks list; rates §): "healthy banks can attract uninsured deposits by paying more, but weak banks cannot."

**Source quote**:
> "We find that good banks can raise uninsured deposits by raising their price, while weak banks cannot." (Coefficient on the uninsured interest margin: 1.29 for always-CAMEL-1/2 banks; insignificant for CAMEL worse than 2.)
> "at very high levels of risk, depositor discipline may effectively limit banks' options."

**Verdict: CONFIRMED** (near-verbatim). 1,863 FDIC-insured institutions, 1987–2000, Arellano-Bond GMM with the uninsured deposit rate instrumented.

### 17. martin2026deposit — Martin, Puri & Ufier (2026), Journal of Finance

**Manuscript claims** (intro contribution 3; results destination §): "failing banks replace fleeing uninsured money with insured term deposits structured just under the limit."

**Source quotes**:
> "We observe an outflow of uninsured depositors from the bank following bad regulatory news... Outflows of uninsured deposits were largely offset with inflows of new insured deposits as the bank approached failure."
> "the failed bank we study was able to replace about a third of its deposit base in the last year of its life."
> "The new deposits were almost all term deposits paying above-market interest rates and structured to fall just under the FDIC insurance limit."
> "inflows into insured deposits are an important mechanism that weakens depositor discipline."

**Verdict: CONFIRMED.** (Md is FDIC CFR WP 2018-02, marked "Forthcoming in Journal of Finance"; bib carries the JF DOI.)

### 18. goldberg2002depositor — Goldberg & Hudgins (2002), JFE 63(2), 263–274

**Manuscript claims** (intro contribution 3; results destination §): "distressed thrifts offset uninsured outflows by attracting insured and brokered deposits."

**Source quote**:
> "Financial institutions in distress have tried to mitigate the reduction in uninsured deposits by paying higher risk premiums... and by offsetting contractionary effects of withdrawals on the balance sheet by attracting more insured deposits including brokered deposits (large certificates of deposit split into segments less than $100,000 to obtain full insurance coverage)."
> Uninsured/total deposits at failing FSLIC thrifts: 0.051 eight quarters before failure → 0.024 one quarter before.

**Verdict: CONFIRMED.**

### 19. kim2024insurance — Kim, Kundu & Purnanandam (2025), SSRN 4813996

**Manuscript claims** (intro contribution 3; results destination §): "reciprocal-network banks raised insured deposits sharply"; "the network-based insurance margin."

**Source quote**:
> "network banks increased their insured deposits by 5.67 percentage points between 2022Q4 and 2023Q4, compared to non-network banks."

**Verdict: CONFIRMED.** Current title is "The Economics of Network-Based Deposit Insurance" (earlier vintage circulated as "Market-Based") — bib and the manuscript's "network-based insurance margin" phrasing updated accordingly.

### 20. davila2023optimal — Dávila & Goldstein (2023), JPE 131(7), 1676–1730

**Manuscript claim** (intro contribution 3): "the optimal coverage limit trades run prevention against the costs of broader coverage."

**Source quotes**:
> "the welfare impact of changes in the level of deposit insurance coverage can be generally expressed in terms of a small number of sufficient statistics, which include the level of losses in specific scenarios and the probability of bank failure."
> "the optimal level of coverage given our calibration is δ* = $381,000."
> Trade-off: coverage increases are optimal "when a marginal change in δ substantially reduces the likelihood of bank failure... On the other hand, when bank failures are frequent and when the social cost of ex-post intervention... is substantial, it is optimal to decrease the level of coverage."

**Verdict: CONFIRMED** as phrased. Important negative finding from verification: the paper does NOT model a depositor-monitoring cost of coverage (the word "monitor" does not appear); the cost side is fiscal/intervention cost with bank moral hazard subsumed into the sufficient statistics. The manuscript deliberately attributes only the run-prevention-vs-cost trade-off to this paper and leaves the monitoring claim to demirgucc2004market.

### 21. kelly2025rushing — Kelly & Rose (2025), FRB Chicago WP 2025-04

**Manuscript claim** (robustness): "The runs were concentrated in crypto- and venture-focused business models at a handful of mostly West Coast banks, and smaller banks faced less pressure."

**Source quotes**:
> "These six most-affected banks built their business models around the crypto and venture capital (VC) sectors."
> "five of the six most-affected banks were headquartered on the technology-heavy West Coast."
> "smaller banks faced less pressure, and larger banks even benefited in some ways."
> On screening variables: "These metrics would have flagged only some of the banks that did experience runs in 2023, while also implicating several that did not."

**Verdict: CONFIRMED** (manuscript uses their own "smaller banks faced less pressure" formulation rather than a stronger community-bank claim the paper does not make).

### 22. flannery2017stress — Flannery, Hirtle & Kovner (2017), J. Financial Intermediation 29

**Manuscript claim** (inst_bg): "Mandated supervisory disclosure demonstrably closes part of that gap, but the demonstrations are for capital-market audiences: stress-test results move stock prices and trading volume, most strongly at levered and risky banks."

**Source quotes**:
> "stress test disclosures are associated with significantly higher absolute abnormal returns, as well as higher abnormal trading volume."
> "More levered and riskier holding companies seem to be more affected by the stress test information."
> The word "depositor" appears zero times in the paper; all outcomes are equity/CDS/analyst measures — supporting the manuscript's "capital-market audiences" framing by construction.

**Verdict: CONFIRMED.**

### 23. chen2022does — Chen, Dou, Ryan & Zou (2024), The Accounting Review

**Manuscript claims** (inst_bg; intro contribution 2): "tightened lending in the COVID-19 recession"; "Prior CECL work studies the supply side, lending."

**Source quote**:
> "We hypothesize and find that banks that adopted CECL prior to the COVID-19 pandemic increased loan loss provisions and reduced loan growth during the accompanying recession more than other banks. The lending contraction is stronger for adopting banks with low regulatory capital..."

**Verdict: CONFIRMED** (after the fix — the prior draft said CECL "reduced procyclicality of bank lending," which is the opposite of the finding; an earlier vintage's title asked that question, the answer was no).

### 24. kim2026current — Kim, Kim, Kleymenova & Li (2025 version), SSRN

**Manuscript claims** (inst_bg; intro contribution 2): "made provisions timelier and more reflective of future local economic conditions"; "provisioning."

**Source quote**:
> "First, CECL banks' LLPs become timelier and better reflect future local economic conditions. Second, CECL banks experience lower rates of loan defaults."

**Verdict: CONFIRMED.** (Repo md is the October 2025 version.)

---

## Part B — Legacy citations (verified this pass)

### 26. calomiris1991role — Calomiris & Kahn (1991), AER 81(3), 497–513

**Manuscript claim** (intro): "Whether such discipline exists is a central question in banking. Theory predicts it should."

**Source quotes**:
> "Demandable debt attracts funds by giving depositors an option to force liquidation."
> "In effect, demandable debt permits depositors to 'vote with their feet'; withdrawal of funds is a vote of no-confidence in the activities of the banker. Without the ability to make early withdrawals, depositors would have little incentive to monitor the bank."
> "The so-called 'sequential service constraint,' by which payments were made to demanders on a first-come, first-served basis, becomes intelligible as a way to make monitoring depositors interested in registering their no-confidence votes at the first opportunity."

**Verdict: CONFIRMED.**

### 27. diamond2001liquidity — Diamond & Rajan (2001), JPE 109(2), 287–327

**Manuscript claim**: same "Theory predicts it should" sentence.

**Source quotes**:
> "Fragility commits banks to creating liquidity, enabling depositors to withdraw when needed, while buffering borrowers from depositors' liquidity needs."
> "One way to commit is for the relationship lender to borrow using demand deposits: a fragile capital structure that is subject to a 'run.' If the relationship lender threatens to withdraw her specific collection skills as a ploy to get more rents, she will precipitate a run by depositors, which will drive her rents to zero."

**Verdict: CONFIRMED.** (Mechanism is commitment via run threat rather than signal-based monitoring — compatible with the manuscript's use.)

### 28. park1995market — Park (1995), QREF

**Manuscript claims** (intro, twice): "riskier banks pay higher deposit rates and experience larger uninsured outflows"; "prior evidence documents higher rates and larger outflows at riskier banks."

**Source quote**:
> "During the period, riskier banks paid higher interest rates but experienced slower growth of large time deposits. These results indicate that risky banks faced unfavorable supply schedules of large time deposits and, hence, support the presence of market discipline b[y] large tim[e] depositors."

**Verdict: CONFIRMED**, with a precision note: Park's quantity result is *slower growth* of large time deposits, not literal outflows — "larger outflows" is a slightly stronger paraphrase. Data-quality flag: the md (a NY Fed version) carries no journal/year metadata; QREF 1995 attribution is external.

### 29. martinez2001depositors — Martinez Peria & Schmukler (2001), JF 56(3)

**Manuscript claims**: the "higher rates and larger uninsured outflows" list; and (inst_bg) "prior depositor-discipline tests typically exploit realized distress."

**Source quotes**:
> "We focus on the experiences of Argentina, Chile, and Mexico during the 1980s and 1990s. We find that depositors discipline banks by withdrawing deposits and by requiring higher interest rates."
> "Aggregate shocks affect deposits and interest rates during crises, regardless of bank fundamentals."
> "We could reject the null hypothesis that insured and uninsured depositors do not respond to bank risk taking. This result suggests that none of the deposit insurance schemes is fully credible."

**Verdict: CONFIRMED**, two nuances: (i) discipline is by *both* insured and uninsured depositors (insurance schemes not credible), so the paper sits loosely in a specifically-uninsured list; (ii) the design compares before/during/after crises rather than identifying purely off distress — though the crisis-window emphasis makes the inst_bg grouping fair.

### 30. iyer2016tale — Iyer, Puri & Ryan (2016), JF 71(6)

**Manuscript claims**: the "riskier banks... larger uninsured outflows" list; the "realized distress" sentence.

**Source quotes**:
> "We find that there is a large run by depositors immediately following the public news of the high-solvency-risk shock. Uninsured depositors are far more likely to run than insured depositors."
> "The bank we study experienced a high-solvency-risk shock and was subject to runs in early 2009, during and after a regulatory intervention that ultimately placed the bank in receivership."

**Verdict: CONFIRMED** on both uses (Indian cooperative bank, realized-distress setting).

### 31. egan2017deposit — Egan, Hortaçsu & Matvos (2017), AER 107(1), 169–216

**Manuscript claims**: the "higher rates and larger uninsured outflows" list (twice).

**Source quotes**:
> "The estimated demand for uninsured deposits declines with banks' financial distress, which is not the case for insured deposits."
> "As distress of Citibank increases relative to JPMorgan, Citi's market share of uninsured deposits decreases and JPMorgan's market share increases (panel A). Note that the market shares of insured deposits, which should be insensitive to distress, show no such relationship (panel B)."
> "Financial distress decreases demand for Bank of America's uninsured deposits and increases demand for competitors, all else equal. On the other hand, Bank of America also offers higher deposit rates."

**Verdict: CONFIRMED.** Precision note: the quantity result is the reduced-form/estimated-demand finding; the higher-rates-at-distressed-banks element is a model/equilibrium result (risk-shifting in rate setting), not a reduced-form estimate.

### 32. chen2024liquidity — Chen, Goldstein, Huang & Vashishtha (2024), JF 79(6)

**Manuscript claim**: cited in the "riskier banks... larger uninsured outflows" list.

**Source quotes**:
> "Banks that engage in more liquidity transformation exhibit higher fragility, as captured by stronger sensitivities of uninsured deposit flows to bank performance and greater levels of uninsured deposit outflows when performance is poor."
> "We find that banks start losing uninsured deposits in response to performance declines only when ROA realizations are sufficiently poor; this region seems to lie well below the median ROA."
> On the insured offset: "we empirically explore this issue in our sample and find evidence that the substitution between uninsured and insured deposits is not perfect."

**Verdict: CONFIRMED** for the manuscript's use (uninsured outflows at poorly performing banks).

### 33. calomiris2019stealing — Calomiris & Jaremski (2019), JF 74(2)

**Manuscript claim** (intro): "early state deposit insurance programs that eliminated market discipline enabled excessive risk-taking."

**Source quotes**:
> "We show that deposit insurance removed market discipline constraining uninsured banks. Taking advantage of World War I's rise in world agricultural prices, insured banks increased their insolvency risk and competed aggressively for deposits. When prices fell after the war, the insurance systems collapsed and suffered high losses."
> "Depositors applied strict market discipline on uninsured banks when evaluating whether to place deposits in those banks, but put relatively little weight on the financial soundness of insured banks."

**Verdict: CONFIRMED.**

### 34. o1990deposit — O'Hara & Shaw (1990), JF 45(5), 1587–1600

**Manuscript claim** (intro): "institutions below $10 billion in assets carry no credible government backstop, so the monitoring incentive is intact."

**Source quotes**:
> "we find positive wealth effects accruing to TBTF banks, with corresponding negative effects accruing to non-included banks."
> "The TBTF banks experienced a significantly positive average residual return of approximately 1.3% on September 20. Conversely, the non-covered (other) banks displayed on average negative abnormal returns." (Event: September 1984 Comptroller testimony naming the eleven largest banks.)
> Non-included banks were "implicitly considered 'too small to save'."

**Verdict: CONFIRMED as a fair supporting cite.** Caveats: the paper shows the backstop is a large-bank phenomenon via equity wealth effects; the $10 billion threshold and the monitoring-incentive inference are the manuscript's own, and the control group is 53 publicly traded banks in 1984, not community banks.

### 35. flannery1996evidence — Flannery & Sorescu (1996), JF 51(4), 1347–1377

**Manuscript claims**: (a) the "no credible backstop / monitoring incentive intact" sentence; (b) the "higher rates and larger outflows at riskier banks" list; (c) the inst_bg "realized distress" list.

**Source quotes**:
> "In short, the 1989-1991 regression clearly indicates that bank investors responded strongly to accounting risk measures once conjectural guarantees of SND principal had been effectively eliminated."
> "During the earliest subperiod (1983-1985), the TBTF doctrine was most credible and we expect the weakest correlation between SPREAD and bank risk measures... During the most recent period (1989-1991), bank investors should have understood that their debentures were indeed subject to default risk."

**Verdicts**: (a) **CONFIRMED** — the guarantee-erosion → risk-pricing mechanism is exactly the paper's identifying logic (though its subjects are large BHCs' sub-debt holders). (b) **CORRECTED** — the paper measures subordinated debenture *yield spreads*; it contains no deposit rates and *no quantity/outflow analysis at all*; the "outflows" half is unsupported by this cite. (c) **CORRECTED** — the design exploits a regulatory-guarantee regime change across subperiods, not realized distress; grouping it with martinez2001depositors and iyer2016tale mischaracterizes it. **Fix: remove flannery1996evidence from lists (b) and (c); keep it in (a).**

### 36. bennett2015market — Bennett, Hwa & Kwast (2015), J. Financial Stability 20

**Manuscript claims**: (a) intro problem 3: "periods with the greatest variation in bank distress are precisely those in which government interventions and depositors' own liquidity needs contaminate the response"; (b) "government guarantees attenuate estimates in the crisis episodes."

**Source quotes**:
> "Our results show that quantity market discipline tends to begin far enough in advance to signal to both banks and supervisors that corrective actions can and should be taken. Furthermore, creditors are able to distinguish between banks of different risk levels."
> "these patterns are observed despite several reasons to believe that we might not find evidence of QD, not least because of the substantial increases in deposit insurance limits and other guarantees that were implemented at the height of the crisis."
> Fn. 41: "We note that all these actions [2008 limit increase to $250k, TAG] should bias us toward not finding evidence of either quantity or price market discipline."
> Actual measurement confound named by the paper: "movements in the shares of secured claims complicate the interpretation of results for the shares of insured deposits, uninsured deposits, and general creditor claims."

**Verdict: CORRECTED on both uses.** The paper *asserts* guarantees bias against detection (supporting the direction of the manuscript's point) but its headline is that discipline was detectable anyway; "depositors' own liquidity needs" appears nowhere — the paper's confound is secured-claim shares. The attenuation *finding* the manuscript wants belongs to berger2015depositors (Bennett et al. themselves attribute it there). **Fix: recite the attenuation claim to berger2015depositors; reword the intro problem-3 sentence so the liquidity-needs clause is either unattributed general reasoning or backed by a source that says it.**

### 37. berger2015depositors — Berger & Turk-Ariss (2015), JFSR 48

**Manuscript claim**: in the "government guarantees attenuate estimates" list.

**Source quotes**:
> "We find significant depositor discipline prior to the crisis in both the US and EU... We also find that depositor discipline mostly decreased during the crisis, except for the case of small US banks."
> "Depositor discipline effects were in most cases reduced during the crisis, consistent with the hypothesis that government actions taken at the beginning of the crisis reduce such discipline. An exception is small US banks, where depositor discipline held or was increased."

**Verdict: CONFIRMED** for the attenuation claim — with an unused gift: the explicit exception is **small U.S. banks, where discipline held or increased**. That is the manuscript's own population; citing the exception would *strengthen* the "community banks are the right laboratory" paragraph. (Md front matter is © 2014, published online Aug 2014; 2015 is the print-issue year.)

### 38. nier2006market — Nier & Baumann (2006), JFI 15(3), 332–361

**Manuscript claims**: (a) intro ¶2: "establish that disclosure improvements enable depositors to act on credit-risk signals"; (b) in the "higher rates and larger outflows at riskier banks" list.

**Source quotes**:
> "Our results suggest that government safety nets result in lower capital buffers and that stronger market discipline resulting from uninsured liabilities and disclosure results in larger capital buffers, all else equal."
> "more disclosure leads banks to hold larger capital buffers, all else equal."

**Verdict**: (a) **CORRECTED (overreach)** — the outcome is bank capital buffers; the paper never observes depositors acting on signals and explicitly positions itself away from the price-reaction literature. Defensible paraphrase: disclosure combined with uninsured funding strengthens the *incentive* channel of market discipline (banks self-insure with bigger buffers). (b) **NOT FOUND** — the paper has no deposit-rate or flow outcome; remove from that list. **Fix: reword (a); drop from (b).**

### 39. demirgucc2004market — Demirgüç-Kunt & Huizinga (2004), JME 51(2), 375–399

**Manuscript claim** (intro contribution 3): "explicit insurance weakens the deposit market's sensitivity to bank risk."

**Source quotes**:
> "Our results show that the existence of an explicit insurance lowers banks' interest expenses and makes interest payments less sensitive to bank risk. Thus explicit deposit insurance is found to reduce market discipline on banks by their creditors."
> Scope: "we examine whether market discipline in terms of the growth rate of bank deposits is affected by explicit deposit insurance for a larger set of 51 countries. For this hypothesis we do not find consistent evidence."

**Verdict: CONFIRMED** on the price/interest-expense margin (which is what the manuscript sentence says). Note: no consistent evidence on the deposit-*growth* margin — do not extend this cite to quantities.

### 40. bushman2012accounting — Bushman & Williams (2012), JAE 54(1)

**Manuscript claims**: (a) "banks could delay recognition and systematically understate risk in disclosures"; (b) "delayed loss recognition under the incurred-loss model attenuated the informativeness of bank statements and... the market's ability to price bank risk"; (c) inst_bg "reduced the informativeness of bank disclosures."

**Source quotes**:
> "We document that forward-looking provisioning designed to smooth earnings dampens discipline over risk-taking, consistent with diminished transparency inhibiting outside monitoring. In contrast, forward-looking provisioning reflecting timely recognition of expected future loan losses is associated with enhanced risk-taking discipline."
> Scope: "ideally we would directly compare the incurred loss model with specific alternatives. However, this is not possible as such alternatives have not yet been implemented. Instead, we use a large sample of banks from 27 countries to exploit cross-country variation in allowable discretion."

**Verdict: CONFIRMED** for the discipline-dampening channel, with a scope caveat: BW2012's channel is provisioning *discretion/smoothing* in 27 countries, not the U.S. incurred-loss model's *delay*. The "delayed... under the incurred-loss model" attribution properly belongs to bushman2015delayed and beatty2011delays. **Suggested fix: let bushman2015delayed + beatty2011delays carry "delay"; cite bushman2012accounting for smoothing-dampens-discipline.**

### 41. bushman2015delayed — Bushman & Williams (2015), JAR 53(3)

**Manuscript claims**: same sentences as above.

**Source quotes**:
> "We hypothesize that DELR [delayed expected loss recognition] increases vulnerability to downside risk by creating expected loss overhangs that threaten future capital adequacy and by degrading bank transparency, which increases financing frictions and opportunities for risk-shifting."
> "DELR-induced reductions in transparency can dampen discipline of risk-taking for high DELR banks and result in these banks as a group exploiting opacity to engage in risk-shifting behavior during crisis periods."

**Verdict: CONFIRMED.**

### 42. beatty2011delays — Beatty & Liao (2011), JAE 52(1)

**Manuscript claim** (inst_bg): "U.S. banks recognized credit losses only when a loss became 'probable and estimable,' producing loan-loss provisions that lagged realized defaults."

**Source quotes**:
> "Exploiting variation in the delay in expected loss recognition under the current incurred loss model, we find that reductions in lending during recessionary relative to expansionary periods are lower for banks that delay less."
> "less timely banks may recognize loan loss provision after loans become nonperforming."
> "banks with greater delays in recognition of expected loss reduce their lending by more than 2% on average during recessions."

**Verdict: CONFIRMED** for the lag fact, with one wording fix: the quoted phrase "probable and estimable" does not appear in Beatty–Liao (it is FAS 5 standard language; Granja–Nagel render it "incurred, were probable, and could be estimated with sufficient accuracy"). **Fix: drop the quotation marks (or attribute the phrase to FAS 5/ASC 450, not to this paper).**

### 43. granja2025current — Granja & Nagel (2025), JAE

**Manuscript claims**: "raised rates on longer-maturity consumer credit"; "supply side, lending."

**Source quotes**:
> "We find that greater reserve requirements following the adoption of CECL induce a statistically significant but economically moderate increase in loan interest rates. The effects are more pronounced for weakly-capitalized banks."
> "A one-standard deviation increase in our measure of CECL intensity corresponds to a 24 basis points increase in the interest rate of a loan with an average interest rate of 9.33%."
> Maturity gradient: "after the passage of CECL, long-term loans became relatively more expensive in terms of loss reserves and regulatory capital"; "30% of lifetime losses for three-year auto loans emerge after the initial twelve months. For five-year auto loans, however, approximately 60% of lifetime losses occur beyond the first year."

**Verdict: CONFIRMED.** Precision: the authors call the effect "economically moderate"; personal-unsecured effect is insignificant — the manuscript's one-clause use does not overstate.

### 44. covitz2004market — Covitz, Hancock & Kwast (2004), FEDS 2004-53

**Manuscript claims**: (a) identification: "Cross-sectional comparisons of deposit flows and bank risk conflate information responses with pre-existing sorting [cite]: riskier banks carry fewer uninsured deposits in equilibrium"; (b) results triple-diff caution: "the comparison is between two potentially endogenous outcomes rather than between the treated outcome and an unaffected control liability."

**Source quotes**:
> "This example clearly demonstrates why it is important to consider not only the risk-sensitivity of debt holders (i.e., the demand-side of the debt market), but also the risk-sensitivity of funding decisions (i.e., the supply-side of the debt market) to gauge the effects of conjectural government guarantees."
> "Our sample selection model indicates that investors were able to rationally differentiate among the risks undertaken by major U.S. banking organizations."
> "the risk-sensitivity of these spreads for banking organizations was sufficiently strong to ensure that the riskiest banks were less likely to issue subordinated debt."

**Verdict**: (b) **CONFIRMED** — the endogenous-funding-choice/selection logic is exactly the paper's contribution. (a) **CORRECTED** — the paper analyzes subordinated debt at large BHCs, not deposit flows or uninsured shares; it cannot carry the "riskier banks carry fewer uninsured deposits in equilibrium" fact. That fact is carried by chen2022bank/egan2017deposit-type evidence. **Fix: in the identification sentence, keep covitz2004market for the selection *logic* but anchor the deposit-sorting fact on chen2022bank (already co-cited) — a light rewording, or accept as-is since chen2022bank is in the same bracket.**

### 45. hannan1988bank — Hannan & Hanweck (1988), JMCB 20(2), 203–211

**Manuscript claim** (profitability §): "The joint decline in ROA and NIM is consistent with higher liability costs not being passed through to borrowers, in line with community banks facing competitive local loan markets [cite]."

**Source search**: full-text searches for loan market, loan rate, competition, pass-through, borrower return **zero matches**. The paper has no asset-side content. What it shows:
> "We find evidence consistent with this hypothesis [that the jumbo-CD market prices bank risk]. Measures of the likelihood of bank insolvency, the variability of bank returns on assets, and bank capitalization are all found to influence observed jumbo CD rates."

**Verdict: NOT FOUND.** The citation supports nothing in that sentence. **Fix: either drop the citation (the sentence stands as the manuscript's own economic reasoning) or replace with a loan-market-competition reference; hannan1988bank could instead be cited, if desired, in the rate-discipline discussion (jumbo-CD rates rise with insolvency risk) where it actually belongs.**

### 46. davernas2023deposit — d'Avernas, Eisfeldt, Huang, Stanton & Wallace (2023, rev. 2026), NBER WP 31865

**Manuscript claim** (data § footnote): "Uninsured balances outside the time-deposit category at community banks are dominated by business operating accounts held for liquidity services such as payroll and cash management. Deposits held for services rather than yield have no natural renewal decision and are unlikely to respond to risk news [cite]."

**Source search**: no mention of operating accounts, payroll, or cash management at small banks anywhere in the paper. What it says about small banks points the other way:
> "time deposits are relatively more important for small banks. Note also that large banks have a higher share of uninsured deposits than small banks."
> Citing prior work: "small banks' liabilities composed mainly of FDIC-insured retail deposits, while larger banks have larger quantities of uninsured deposits."
> The service-vs-yield distinction exists but is assigned to *large* banks: "Large banks offer superior liquidity services but lower deposit rates"; "in equilibrium, a small bank has no incentives to invest in liquidity services."

**Verdict: NOT FOUND (and partly inverted).** The paper supports only the narrower proposition that deposits differ in service-vs-yield motive and rate-sensitive depositors sort toward small banks. The footnote's factual premise (community banks' non-time uninsured balances = business operating accounts) is unsupported by this source. **Fix: rewrite the footnote to claim only what the source supports — e.g., that non-maturity deposits lack a natural renewal decision and that deposits held for liquidity services rather than yield are less rate/risk-sensitive [cite davernas2023deposit for the service-vs-yield distinction] — and drop the "dominated by business operating accounts" assertion unless a Call Report composition fact is added to carry it.**

---

## Issues Requiring Manuscript Fixes (ranked)

> **STATUS (2026-08-08, later same day): ALL FIXES APPLIED** and recompiled clean (48 pp, 0 undefined refs). Ranks 1–9 executed as suggested; rank 10 (covitz) accepted as-is per recommendation. `hannan1988bank` was additionally re-homed to the intro's price-discipline list (jumbo-CD rates rise with insolvency risk — its actual finding), so it remains cited. `bennett2015market` now appears in the reworded problem-3 sentence ("guarantees weaken or obscure the response", supported by Berger-TA's finding plus Bennett et al.'s stated bias direction) and was removed from the attenuation-estimates list. Berger-TA small-U.S.-bank exception added to the laboratory paragraph.

| Rank | Location | Problem | Suggested fix |
|------|----------|---------|---------------|
| 1 | results §profitability (hannan1988bank) | Citation supports nothing in the sentence (paper is jumbo-CD rates vs insolvency risk; zero loan-market content) | Drop the cite or find a loan-market-competition reference |
| 2 | data § footnote (davernas2023deposit) | "Business operating accounts" premise not in source; source partly inverts it (small banks mostly insured-retail funded; liquidity services are the large-bank product) | Rewrite footnote to the service-vs-yield claim the source supports |
| 3 | intro riskier-banks list (flannery1996evidence, nier2006market) | Flannery-Sorescu has no outflow analysis (sub-debt yields only); Nier-Baumann has no rate or flow outcome at all | Remove both keys from that list (park1995market, egan2017deposit, martinez2001depositors, maechler2006dynamic, iyer2016tale, chen2024liquidity carry it) |
| 4 | intro ¶2 (nier2006market) | "Enable depositors to act on credit-risk signals" overreach — outcome is capital buffers | Reword: disclosure plus uninsured funding strengthens the incentive channel of discipline (larger buffers) |
| 5 | intro problem 3 (bennett2015market) | "Depositors' own liquidity needs" not in source; paper's spirit is discipline detectable despite guarantees; attenuation finding belongs to Berger-Turk-Ariss | Recite attenuation to berger2015depositors; reword or unattribute the liquidity-needs clause |
| 6 | inst_bg realized-distress list (flannery1996evidence) | Design is a guarantee-regime change, not realized distress | Remove from that list |
| 7 | intro laboratory ¶ (berger2015depositors, unused) | Small-US-bank exception (discipline held or increased) directly supports "community banks are the right laboratory" and goes uncited | Optional: add one clause citing the exception |
| 8 | inst_bg (beatty2011delays) | Quoted phrase "probable and estimable" not in the cited paper (FAS 5 language) | Drop the quotation marks or attribute to FAS 5 / ASC 450 |
| 9 | inst_bg / intro (bushman2012accounting) | Channel is smoothing/discretion (27 countries), not incurred-loss delay | Let bushman2015delayed + beatty2011delays carry "delay"; keep BW2012 for smoothing-dampens-discipline |
| 10 | identification (covitz2004market) | Paper is sub-debt issuance; cannot carry the deposit-sorting fact (selection logic fine) | Minor: rely on chen2022bank (co-cited) for the deposit fact — or accept as-is |

## Data-Quality Flags

- `park1995market`: md has no journal/year metadata (NY Fed version); QREF 1995 external.
- `morgan2002rating`, `bendavid2017banks`, `flannery2017stress`, `davila2023optimal`, `martin2026deposit`, `jordan1999impact`: mds are working-paper vintages; published metadata sourced externally (all consistent with the bib).
- `granja2024market`: slide deck — qualitative claims only (manuscript complies).
- `blickle2024who`: bib lacks RFS volume/pages — run `/skills/bib-validator` before submission.
- `berger2015depositors`: md front matter is © 2014 (online Aug 2014); 2015 = print-issue year (bib fine).
- `flannery2019market`: NO SOURCE anywhere — already dropped from the manuscript.

