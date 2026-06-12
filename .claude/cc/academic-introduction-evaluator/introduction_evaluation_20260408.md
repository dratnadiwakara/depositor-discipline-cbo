# Introduction Evaluation: Depositor Discipline in Community Banking: Evidence from the CECL Information Shock

## First-Time Reader Summary

> Cold-reader impressions after a single pass, before the detailed critique.

**Research Question (as understood):** Do uninsured depositors causally discipline community banks — withdrawing deposits or demanding higher rates — when new mandatory accounting disclosures (CECL Day-One adjustments) reveal elevated credit risk?

**Main Findings (as understood):** Community banks with larger CECL adjustments experienced contractions in uninsured time deposits (~0.394 pp of assets for top-decile banks, ~7% of the mean), higher funding costs (8–9 bps of assets annually), compressed net interest margins (~9 bps), and lower return on assets (~15 bps). Effects are amplified at banks in markets with financially sophisticated depositors. A within-bank triple-difference confirms the pattern is a composition shift, not a uniform funding retreat.

**Why This Matters (as understood):** The Main Street Depositor Protection Act (S. 2999, reintroduced March 2026) would extend deposit insurance to $10 million per account. If deposit discipline operates through the uninsured channel, extending coverage would displace a functioning governance mechanism at community banks. The paper tests this channel in a non-crisis setting, which is exactly where theory predicts it should be most cleanly observed.

**Key Contribution vs. Prior Work (as understood):** Prior evidence relies on crisis variation (when government guarantees suppress discipline) or cross-sectional equilibrium comparisons (where simultaneity confounds estimates). This paper uses a predetermined, mandatory information event uncorrelated with concurrent conditions — a design that jointly addresses simultaneity, accounting opacity, and crisis confounding. It also traces the full causal chain from disclosure → depositor behavior → bank financial outcomes, which prior CECL studies do not.

**Identification / Why I Trust the Results (as understood):** The CECL adjustment was determined by loan vintages assembled years before adoption and cannot be influenced by contemporaneous managerial decisions. Pre-trends are flat for ten quarters. A triple-difference absorbs bank-specific time-varying shocks. A signal-validation exercise (2020 large-bank cohort) shows equity and CDS markets reacted sharply at adoption and not before, confirming this is an information event rather than a mechanical accounting change.

---

## Scorecard

| Component             | Present?  | Quality  | Notes                                                                                               |
|-----------------------|-----------|----------|-----------------------------------------------------------------------------------------------------|
| Hook / Motivation     | Yes       | ★★★★☆   | Opens cleanly; policy urgency (the Act) is specific and timely. First sentence leans slightly academic. |
| Research Question     | Yes       | ★★★★☆   | Implicit by end of ¶1. Clean, but no single explicit "We ask whether…" sentence.                    |
| Main Results          | Yes       | ★★★★☆   | Quantitative and specific in ¶4–5. Insured-deposit result vague and inconsistent with the abstract.  |
| Antecedents           | Yes       | ★★★★☆   | 5–7 core papers named per contribution paragraph. Not over-cited.                                   |
| Value-Added           | Yes       | ★★★★★   | All three contribution paragraphs use explicit "unlike" framing against named prior papers. Strong.  |
| Identification/Method | Yes       | ★★★★★   | ¶2 is the best paragraph in the introduction. Three problems named; CECL solution explained crisply. |
| Robustness            | Partial   | ★★★☆☆   | Triple-diff mentioned; signal validation detailed in ¶3. No other robustness checks previewed.      |
| Road Map              | No        | N/A      | Absent. Acceptable at top journals; not penalized.                                                  |

**Overall First-Time Reader Clarity: ★★★★☆**

This is a strong introduction. The identification paragraph is genuinely excellent and will immediately reassure empiricist referees. The main weaknesses are fixable: a vague insured-deposit result that conflicts with the abstract, a signal-validation paragraph that occupies prime narrative real estate before the main results, and one misplaced citation.

---

## Critical Issues (must fix before submission)

**1. Insured-deposit result is vague and inconsistent with the abstract.**
Paragraph 4 states: "Insured time deposits, by contrast, show a more muted response; to the extent they move in the opposite direction, this may partly reflect depositors restructuring balances to remain within the insurance threshold rather than active substitution by banks." A cold reader cannot tell whether insured deposits go up, down, or stay flat. "To the extent they move in the opposite direction" is agnostic even about the sign. The abstract, however, states "insured balances are unaffected" — a clear, specific result. The introduction should match.
*Suggested fix:* Replace the hedged construction with the signed finding. If insured deposits show no statistically distinguishable change, say so: "Insured time deposits show no statistically distinguishable decline — and if anything trend slightly upward — consistent with some depositors restructuring balances to stay within the insurance threshold rather than a uniform funding retreat."

**2. Signal-validation paragraph (¶3) interrupts the narrative and is over-detailed for an introduction.**
The flow from ¶2 (identification strategy) to ¶4 (main results) is the paper's core argument. Paragraph 3 interrupts it with an extended discussion of the 2020 large-bank cohort — equity cap dynamics, CDS spreads at 191 bps per unit by month four, a nine-month pre-event window — before the reader has seen the main results. Placing validation before results signals to a referee that the author is uncertain whether CECL is truly informative. The main results should appear at ¶3; signal validation belongs after, compressed to 2–3 sentences.
*Suggested fix:* Swap ¶3 and ¶4. Then compress the validation paragraph to: "We first confirm that CECL is an information event rather than a mechanical reclassification: in the large-bank cohort that adopted in 2020Q1, equity prices and CDS spreads reacted sharply at adoption — CDS spreads widened by approximately 191 basis points per unit of CECL exposure — with flat pre-adoption leads across a nine-month window."

**3. Triple-difference coefficient (−1.252) appears without adequate interpretation.**
Paragraph 4 reports "the triple interaction of −1.252 percentage points confirms a within-bank composition shift." A cold reader does not immediately know −1.252 percentage points of what, relative to what baseline, or for what treatment increment. This is the most credible result in the paper and it deserves a brief gloss.
*Suggested fix:* Add units and treatment increment — e.g., "(−1.252 percentage points of assets per percentage-point increase in CECL exposure, net of the insured-deposit response)" — before or after the coefficient.

**4. Misplaced citation at the end of ¶5.**
Paragraph 5 ends: "Event studies reveal that the uninsured deposit decline is concentrated in high-sophistication markets and builds gradually over the post-adoption quarters \citep{egan2017deposit, iyer2016tale}." These citations support prior literature on depositor sophistication; their position at the close of a results sentence makes it appear they support the event-study finding just described. Both papers appear again in ¶6 with correct attribution.
*Suggested fix:* Remove the terminal citation from ¶5. Both papers are cited appropriately in ¶6.

---

## Paragraph-by-Paragraph Notes

**Paragraph 1 (Hook + Research Question):**
Purpose: Motivate the question and state the paper's goal.
Assessment: Strong. The opening sentence avoids the "in recent years the literature has grown" failure pattern and frames the issue as a live empirical question. The policy urgency — naming the Main Street Depositor Protection Act (S. 2999, reintroduced March 2026) rather than a generic "policymakers care about this" — is specific and will help with editors. The research question is stated implicitly ("We provide causal evidence on this question") but never as a standalone sentence. Adding one explicit "We ask whether…" sentence would make the paper immediately citable in referee letters and reviews. Minor: "one of the central open questions in banking" is stock phrasing; consider replacing with a fact or statistic that dramatizes the question.

**Paragraph 2 (Identification Strategy):**
Purpose: Explain what makes causal identification hard and how this paper achieves it.
Assessment: The best paragraph in the introduction. Three problems — simultaneity, accounting opacity, crisis confounding — are named precisely, each in one sentence. The CECL solution is explained clearly, and the predetermination argument ("magnitude reflects loan vintages assembled years earlier") is the key identification claim, stated plainly. Supporting citations are well placed. No changes needed.

**Paragraph 3 (Signal Validation):**
Purpose: Establish that CECL is an information event rather than a mechanical reclassification.
Assessment: Valuable content, wrong position. Placing the validation exercise before the main results implies the identification premise needs to be defended before the findings can be trusted. The level of detail (specific cohort, equity market cap dynamics, CDS basis points per unit, nine-month window) exceeds what a typical introduction validation paragraph requires. This material belongs in the body; the introduction needs a pointer of 2–3 sentences, repositioned after the main results. See Critical Issue #2.

**Paragraph 4 (Main Results — Deposit Quantities):**
Purpose: State the primary empirical findings.
Assessment: Strong overall. Quantitative throughout — 0.394 pp, 7% of mean, 0.072 pp dose-response — which is exactly right for a JF-level introduction. The triple-diff coefficient is cited, which is good, but without adequate interpretation (Critical Issue #3). The insured-deposit result is vague and conflicts with the abstract (Critical Issue #1). Parallel pre-trends claim ("ten quarters before adoption") is appropriately brief.

**Paragraph 5 (Financial Consequences + Sophistication):**
Purpose: Extend the results to financial performance and depositor-sophistication heterogeneity.
Assessment: Quantitative and well-structured. The 8–9 bps / 15 bps / 9 bps figures give the reader economic magnitude for the funding-cost channel. The sophistication results (17–18 bps, 30 bps additional drag) are specific and well-placed. Two cosmetic issues: (1) the terminal misplaced citation (Critical Issue #4); (2) the sophistication index is described only as "a deposit-weighted branch-market index" — a brief descriptor noting what the index measures (financial literacy, investment income) would help a referee who skims rather than reads.

**Paragraph 6 (Contribution 1 — Depositor Discipline Literature):**
Purpose: Situate the paper relative to the depositor/market discipline literature.
Assessment: Well-executed. The "unlike prior tests" framing is clean and the specific contrast — crisis variation and cross-sectional equilibrium comparisons vs. a predetermined non-crisis shock — is precise. The three simultaneous identification advantages are re-stated economically. No changes needed.

**Paragraph 7 (Contribution 2 — Accounting/CECL Literature):**
Purpose: Situate the paper in the accounting and CECL-consequences literature.
Assessment: Strong. "We trace the full causal chain from mandatory accounting disclosure to depositor behavior to bank financial consequences" is a compelling and accurate framing. The contrast with Granja, Kim, and Gee is precise — each prior paper stops before the depositor behavior link. This is the most distinctive contribution of the three.

**Paragraph 8 (Contribution 3 — Deposit Insurance Design):**
Purpose: Connect findings to the policy debate over deposit insurance scope.
Assessment: Well-positioned as the concluding contribution. The policy implication — evaluate insurance expansions not only for run-prevention benefits but for the monitoring discipline they displace — is stated clearly without overclaiming. The "unlike prior cross-country or crisis-period studies" framing is consistent with ¶6 and ¶7.

---

## Positive Elements

1. **Identification paragraph (¶2) is a model.** The three-problem / one-solution structure is precise and well-ordered. The predetermination argument is stated plainly without jargon. Few introductions in empirical banking papers achieve this level of identification clarity.

2. **All three contribution paragraphs use explicit "unlike" framing.** Each names specific prior papers, describes what those papers cannot do, and explains what this paper adds. This is the correct structure and avoids the common failure where value-added paragraphs list contributions without comparing them to antecedents.

3. **Results are consistently quantitative.** Every finding in ¶4 and ¶5 carries a magnitude and baseline reference. No p-values appear. This is the correct register for a JF submission.

4. **Policy urgency is specific and timely.** Naming an active bill (S. 2999, reintroduced March 2026) anchors the motivation in a live policy debate and will help with editors evaluating policy relevance.

5. **No overclaiming on mechanisms.** The sophistication heterogeneity result is presented as consistent with a disciplinary response, not proof of the mechanism. The insured-deposit softening (despite being vague) reflects appropriate caution about substitution claims.

---

## Suggested Revision Priorities

1. **Fix the insured-deposit result description (¶4)** — State the signed finding and reconcile with the abstract. One sentence; takes five minutes; a referee will flag this immediately.

2. **Reorder: move main results before signal validation** — Swap ¶3 and ¶4, then compress the validation paragraph to 2–3 sentences. Restores the logical flow: identification strategy → main findings → confirmation that identification premise holds.

3. **Gloss the triple-difference coefficient** — Add units and treatment increment to the −1.252 sentence. The triple-diff is the most credible result; make it immediately comprehensible.

4. **Remove terminal citation from ¶5** — Both papers reappear in ¶6 with correct attribution; the end-of-paragraph placement in ¶5 is confusing.

5. **Consider adding an explicit research question sentence to ¶1** — "We ask whether uninsured depositors at community banks respond to mandatory credit-risk disclosures by withdrawing balances or demanding higher rates." One sentence that referees and readers can quote verbatim.
