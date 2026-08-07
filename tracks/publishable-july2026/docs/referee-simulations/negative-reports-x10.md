# Ten Hostile Referee Reports on `main_iter5.pdf`

Each report is a distinct rejection angle. Same manuscript, ten personalities.

---

## Referee 1 — The Identification Purist

Author claims CECL Day-One adjustment is "an information shock whose magnitude
was fixed by past underwriting." This is the central claim and I do not
believe it. Day-One magnitude reflects three inputs: (i) legacy loan
composition, (ii) macro forecasts finalized at adoption, (iii) modeling
choices under ASC 326. Only (i) is predetermined. (ii) is contemporaneous
with the 2023 macro environment. (iii) is a choice variable — banks with
weaker capital had strong incentives to model optimistically. Table 2
adjusted R-squared of 1.4 percent does not resolve this: it says
2022Q4 observables do not predict the adjustment, not that the adjustment
is exogenous to unobserved forward-looking inputs. Author waves at this
with a residualized-treatment robustness whose coefficient attenuates
by one-third and loses significance. That is the honest test and it
fails. Reject.

---

## Referee 2 — The Bad-Control Skeptic

Author repeatedly retreats from the level DiD to the within-bank
triple-difference, arguing that deposit-composition characteristics
absorb "part of the treatment effect itself." This framing is convenient.
The triple-difference identifies from the differential movement of
uninsured vs insured deposits within bank-quarter. But insured brokered
deposits are actively managed by the bank at adoption (author shows
this in Section 5.6). So the "insured" arm of the triple difference is
itself an endogenous outcome, not a within-bank control group. The design
therefore compares an endogenous outcome to another endogenous outcome
and calls the differential "discipline." I do not find this convincing.
The correct comparison is uninsured deposits vs non-deposit funding at
the same bank, which the paper does not show. Reject.

---

## Referee 3 — The SVB Contamination Hardliner

Section 5.1 shows the level DiD attenuates by roughly one-half when
2022Q4 characteristics are allowed quarter-specific slopes. Author calls
this a "bad-control problem." Alternative reading: the baseline was
picking up 2023-stress heterogeneity, and once you flexibly control for
it, the effect goes away. The characteristics-by-quarter specification
is the correct one; the baseline is misspecified. Author's response is
to move the goalposts to a triple difference. Every referee at every
journal has heard this move. The placebo on not-yet-adopted banks
(Section 5.2) confirms my reading: uninsured deposits fell in
2023Q1 in proportion to *future undisclosed* Day-One adjustments. Author
concedes the placebo is "not clean." It is worse than not clean; it is
directly inconsistent with the disclosure mechanism. Reject.

---

## Referee 4 — The Magnitude Skeptic

Point estimate: uninsured time deposits fall by 0.39 percentage points
of assets at high-CECL banks. For the median bank this is $1.3 million.
The 2023 stress moved billions of uninsured deposits at the failed
institutions in a single week. Author's own numbers imply the CECL
information effect is three orders of magnitude smaller than the panic
effect. If the effect is this small, why should Journal of Banking and
Finance care? The paper needs to make a case for economic importance
that goes beyond statistical significance. Currently it does not.
Reject or major revision demonstrating aggregate relevance.

---

## Referee 5 — The Data Coverage Referee

The primary outcome is time deposits. Time deposits are a shrinking
share of community-bank funding: FDIC data show the industry-wide
uninsured-time-deposit share is under 5 percent of liabilities. Author
uses this narrow slice because it is where the point estimate is
statistically significant. Uninsured demand deposits and money-market
deposit accounts, which represent the bulk of uninsured funding at
community banks, are not reported to show discipline. If the mechanism
were real, we would see it in the aggregate uninsured deposit series
too. Table 1 hints at this — total uninsured deposit share is
*lower* at high-CECL banks in the cross-section. Author dismisses this
in one sentence. It deserves a full analysis. Without it, the paper is
a study of a narrow line item, not depositor discipline. Reject.

---

## Referee 6 — The Sophistication Instrument Critic

The sophistication measure (Section 3.4) is a bank-level average of
ZIP-code education and investment-income filing rates weighted by
2022 branch deposits. This is not depositor sophistication. It is a
noisy proxy for the demographic composition of the bank's branch
footprint. A high-education ZIP code with a small-business banking
branch will look "sophisticated" whether or not the depositors of
record are financially sophisticated. Author's Table 4 shows the
quantity effect is *not* concentrated in high-sophistication markets —
in fact the low-sophistication group carries the significant uninsured
outflow. Author labels this "two different forms of discipline" but the
straightforward reading is that the sophistication proxy does not
identify sophistication, and the "amplification" claim in the abstract
overstates a fragile pattern in interest expense. Cut the sophistication
section or replace the proxy. Reject.

---

## Referee 7 — The Standard-Errors Referee

Standard errors are clustered at the bank level throughout. This is
inadequate given the design. CECL adoption is a common shock in 2023Q1
for 92 percent of the sample. Under a common shock, bank clustering
understates true uncertainty because the residuals are cross-sectionally
correlated through the shared post-shock period. The correct inference
is either two-way clustering (bank and quarter) with a small-cluster
correction, or Adão-Kolesár-Morales / a design-based inference under
staggered adoption. Author reports neither. Standard errors probably
double under proper inference, and I would guess several of the
"significant at 5 percent" results become insignificant. Recompute all
inference and report. Reject pending recomputation.

---

## Referee 8 — The Literature Positioning Referee

Author positions the paper against Bennett and Unal (2015), Berger and
Bouwman (2015), Jacewitz and Pogach (2018), and Caglio et al. (2024).
This is exactly the wrong reference set. The closer literature is
event-study evidence on Call Report disclosures (Barth, Beaver, Landsman;
Nichols, Wahlen, Wieland) and analyst reactions to CECL disclosures
(Gee, Neilson, Stomberg — cited only in passing). The paper reads as if
these literatures do not exist. On the theory side, the depositor-
discipline claim rests on a static Diamond-Dybvig framing rather than
the more recent monitoring-vs-runs literature (Rochet-Vives, Dang-Gorton-
Holmström). Author's contribution vis-à-vis these literatures is
therefore not properly articulated. This is not a minor complaint: I
cannot tell what is new. Reject.

---

## Referee 9 — The Presentation Referee

Fifteen tables, ten figures, 51 pages. This is not a paper; it is a
technical appendix. The reader is asked to remember six coefficients
(uninsured DiD, insured DiD, triple-diff, interest expense, ROA, NIM)
in two variants (continuous, binary) plus five heterogeneity triples plus
robustness cascades. No summary table pulls this together. No figure
telegraphs the paper's punchline. The abstract promises a within-bank
composition shift; the paper's headline figure (Figure 2) plots
uninsured and insured event studies in separate panels rather than
overlaying them to *show* the composition shift. Editorial choices
make the manuscript harder to read than it needs to be. Even readers
sympathetic to the empirical strategy will not persevere. Major
presentation revision required.

---

## Referee 10 — The Policy-Framing Critic

Author closes with a policy argument against the Main Street Depositor
Protection Act, invoking Correia et al. on 19th-century runs. This is
a dramatic overreach. The paper documents a small, temporary
composition shift after a one-time disclosure at 217 banks. It does
not document that depositor discipline reduces bank failure risk, that
it improves capital allocation, or that its removal would harm
welfare. The policy claim requires a welfare model that the paper does
not have. Historical runs at 19th-century banks operating under
suspension-of-convertibility clauses are not a valid analogue to modern
FDIC-insured institutions. The policy paragraph should be deleted;
alternatively, the paper should engage a proper policy-evaluation
framework (Egan-Hortacsu-Matvos style structural model, or an explicit
counterfactual). Current framing damages the paper's credibility.
Reject or delete the policy content.

---

## Common Themes Across Rejections

1. **Identification skepticism** (Referees 1, 2, 3): Day-One magnitude is
   not as exogenous as claimed; the shift to triple-difference is
   evasive; placebo failure is unresolved.
2. **Economic-importance skepticism** (Referees 4, 5, 10): effect size is
   small; primary outcome is a narrow line item; policy claim overreaches.
3. **Design/inference concerns** (Referees 6, 7): sophistication proxy
   is weak; clustering is inadequate.
4. **Framing/exposition** (Referees 8, 9): literature positioning is
   wrong; presentation is hard to follow.

## Author's Priority Response Set (Hypothetical)

If forced to prioritize responses for a revision at another journal:
- (a) Report two-way clustering standard errors (defuses Ref 7).
- (b) Show the design on aggregate uninsured deposits and other
      liability categories (defuses Ref 5).
- (c) Add a summary table pulling the headline six coefficients together
      and overlay Figure 2 panels (defuses Ref 9).
- (d) Rewrite policy paragraph to match evidence weight (defuses Ref 10).
- (e) Acknowledge the modeling-choice channel in Day-One magnitude and
      test cohort-timing more aggressively (partial defense against Refs 1, 3).

Refs 2, 6, 8 are harder: they attack framing choices that are
constitutive of the paper's argument, and answering them requires
either a new empirical exercise or a rewrite of the introduction and
conclusion.
