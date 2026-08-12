# Presentation Script — Depositor Discipline in Community Banking
**25th FDIC Bank Research Conference · 20-minute slot · Discussant: George Pennacchi**

Keyed to `slides/build/main.pdf` (compiled from `slides/main.tex`, 22 talk pages + 6 backup). Times in brackets are *cumulative targets* — glance at the clock when you land on a slide; if you're ahead of the bracket you have room, if behind, compress the next setup slide, not the results. The two build pairs (slides 11–12 and
17–18) are scripted as one continuous beat with an explicit **[ADVANCE]** cue.
Backup slides are reachable through the small pill buttons on the slides; don't visit them unprompted.

Pacing rule of thumb: ~60 seconds per slide. The protected slides — never rush these — are the overlay build (11–12), the two-actor build (17–18), and Takeaways.

Changes from the 8/11 version: the identification-problems slide now states the three problems only; the fixes moved to a new slide 6 that comes *after* CECL is explained. Slide 2 says plainly what "losing uninsured funding" means. Slide 7's predictability fact is boxed. Slide 10 splits the two specifications into labeled blocks.

---

## Slide 1 — Title [0:15]

> Thank you. This paper asks one of the oldest questions in banking — do uninsured depositors actually discipline banks? — and answers it with a disclosure shock that, I'll argue, is about as close to a natural experiment as this literature gets.

*Transition: none — go straight in.*

---

## Slide 2 — Do uninsured depositors actually discipline banks? [1:30]

> Theory is unambiguous: uninsured claimants are supposed to be the private check on bank risk-taking — that's Calomiris and Kahn, Diamond and Rajan. And empirically, riskier banks do pay higher rates, and their uninsured balances do shrink. Let me be concrete about what that shrinkage means, because it's the object of the whole paper: uninsured depositors either withdraw money outright, or, when a certificate of deposit matures, they simply decline to roll it over and take the cash elsewhere. Either way the bank's uninsured funding falls.
>
> The open question is *why* it falls. Is it *discipline* — depositors reacting to news about the bank's risk — or is it *equilibrium sorting*, risky banks and yield-chasing depositors finding each other, which would produce the same correlation with no monitoring at all?
>
> And the question is live policy right now. The Main Street Depositor Protection Act would insure ten million dollars per business account. And even without legislation, reciprocal networks, sweeps, and brokers are converting uninsured money into insured money every day. If we're going to price what that coverage displaces, we need a causal estimate of discipline.
>
> What that takes is a shock to *information* about bank risk that has nothing to do with what's happening to the bank's fundamentals at the same time.

*Transition: "So why has that been so hard to find? Three reasons."*

---

## Slide 3 — Why the causal evidence has been elusive [2:25]

> First, simultaneity. A bank's risk profile, its deposit mix, and its depositors' behavior all evolve together, so a regression of flows on risk measures picks up the sorting, not the response.
>
> Second, accounting opacity. Under the old incurred-loss standard, banks could delay recognition, so disclosed risk was partly a reporting choice rather than a fact about the loan book.
>
> Third, aggregate stress. The episodes with the most variation in bank distress are exactly the ones where governments expand guarantees and where a system-wide shock hits every bank at once — so the depositor response is either muted or contaminated.
>
> I'll argue that the mandatory CECL adoption of 2023 addresses all three. I'll come back to each one specifically, but first — what is CECL?

*Transition: none — go straight in.*

---

## Slide 4 — What is CECL? [3:45]

> CECL is the biggest change to bank loan accounting in decades. Under the old incurred-loss model, a bank recognized a credit loss only when it was probable and estimable — so provisions lagged defaults and disclosures understated risk. Under CECL, the bank must reserve for *lifetime* expected credit losses, at origination and at every reporting date. Credit risk gets forced into a reported number.
>
> The key object for me is what happens on transition day. The entire existing loan book is re-reserved at once, and the difference between the CECL allowance and the old allowance — this delta — is booked as a one-time charge to retained earnings. No cash moves. No loan changes. It is pure news about losses already sitting in the book.
>
> My treatment variable scales that charge by pre-adoption equity. And the point of the whole design is on the bottom of the slide: the size of delta was determined by the composition and seasoning of loans made years earlier — not by anything happening in the deposit market in 2023.

*Transition: "The timing of who saw this number, and when, is the whole paper — so here's the timeline."*

---

## Slide 5 — The experiment: timeline [4:40]

> The standard was announced in 2016 — everyone knew it was coming. Large SEC filers adopted in 2020; I'll use them in a moment. Community banks ran CECL *in parallel* with the old standard through 2022 — supervisors and auditors expected it — which means *management* knew its number in 2022. Adoption hit in the first quarter of 2023 for more than four thousand community banks. And the public — depositors included — could only see the number when the Call Reports were posted in late April and May of 2023.
>
> So: everyone knew the date; nobody outside the bank knew the number. And yes, SVB fails in March 2023, right in the middle of this window — I will confront that head-on at the end, and the design itself handles most of it.

*Transition: "With CECL on the table, let me go back to the three problems."*

---

## Slide 6 — Back to the three problems: what this shock delivers [5:25]

> Take them in order. Simultaneity: the size of the charge is predetermined. It is set by the composition and seasoning of loans that were underwritten years before anyone was thinking about 2023 deposit markets, and I'll show you in a moment that everything observable about a bank at the end of 2022 explains about one percent of its variation. So it is not a proxy for concurrent bank conditions.
>
> Accounting opacity: the disclosure is mandatory and standardized. One rule, every bank, one date, one line on Schedule RI-A. No bank chose whether to reveal, when to reveal, or how much to reveal.
>
> Aggregate stress: my variation is cross-sectional *within* a single quarter, so calendar-quarter fixed effects absorb the tightening cycle and the 2023 stress in one stroke — and in the triple-difference design, bank-times-quarter fixed effects absorb them bank by bank.
>
> And there's a bonus the setting hands me: a timing wedge. Banks knew their own number in 2022; the public did not see it until April and May of 2023. Two informed parties, two different clocks — I'll use that later as the sharpest test in the paper.

*Transition: "Here's what the disclosed numbers actually look like."*

---

## Slide 7 — Treatment: the disclosed charge [6:15]

> Ninety-two percent of the sample adopts in the same quarter, 2023Q1. About half of community banks disclosed a charge of essentially zero — their old reserves were already adequate. What I'll call High-CECL banks are the 217 banks in the right tail, with charges of at least two and a half percent of equity — roughly the 95th percentile — averaging four percent of equity.
>
> And the boxed fact is the one to hold onto: the charge is almost unpredictable from the outside. Everything observable about a bank in 2022Q4 explains about one percent of its variation. High-CECL banks are not the observably weak banks relabeled.

*Transition: "Is a number like this actually news? The 2020 cohort lets me check."*

---

## Slide 8 — The Day-One number is news [7:10]

> The large banks that adopted in 2020 are publicly traded, so markets grade the disclosure for me. In event time around their adoption, market cap drops about 2.8 percent per percentage point of charge, right at adoption, with flat pre-trends. CDS spreads widen too, with a lag of a few months. So sophisticated investors treat the Day-One number as material information. The question for the rest of the talk is whether *depositors* at community banks do the same.

*Transition: "Quick word on data."*

---

## Slide 9 — Data [7:55]

> Quarterly Call Reports, 2016 through 2025, about ninety-seven thousand bank-quarters for 4,320 banks under ten billion in assets — the median bank is 300 million. Time deposits matter for these banks: about thirteen percent of assets, split five percent uninsured, seven percent insured.
>
> The comparison table: High-CECL banks enter with weaker loan quality and thinner capital — that's what a bigger lifetime-loss reserve means. But on the primary outcome, uninsured time deposits, the two groups are balanced before adoption, and bank fixed effects absorb all the levels anyway.

*Transition: "Two specifications, and they do different jobs."*

---

## Slide 10 — Empirical strategy: two specifications [9:05]

> Specification one, the top block, is the workhorse difference-in-differences, and it compares *across* banks: outcome on Post times the charge, with bank and calendar-quarter fixed effects. Quarter effects absorb the tightening cycle and any economy-wide reaction to the 2023 stress. Expected sign: negative for uninsured time deposits. Event studies replace Post with event-time dummies.
>
> Specification two, the bottom block, is deliberately extreme, and it compares *within* a bank in a given quarter. I stack the uninsured and insured series for each bank-quarter and put in bank-*times*-quarter fixed effects — that absorbs *every* bank-level shock in every quarter: funding demand, stress exposure, liability strategy, anything. What's left, the triple interaction, is identified purely from the uninsured-versus-insured gap inside the same bank in the same quarter. Inference is bank-clustered throughout, and permutation tests give the triple diff a p-value of 0.001.

*Transition: "Here is the paper in one picture."*

---

## Slides 11–12 — Overlay event study, two-frame build [10:50]
**Protected slide. Slow down.**

> [Frame 1 — blue series only] This is the event study for uninsured time deposits at High-CECL banks, in event time around adoption. Look at the left half first: ten quarters of nothing. The pre-adoption coefficients sit on zero — no drift, no anticipation, nothing for depositors to see. Then the number becomes public — and the series breaks. Down within the first post-adoption quarter, and it stays down through the end of the sample.
>
> **[ADVANCE]**
>
> [Frame 2 — gold series added] Now add insured time deposits, same specification, same axes. The mirror image. As uninsured money leaves, insured money arrives — the gold series rises by about as much as the blue series falls. This is not a funding run; it's a *composition shift* at the insurance threshold. The one wrinkle — the gold series starts moving slightly *before* adoption — is not a violated pre-trend. It's the banks themselves, and I'll show you that directly in a few slides.

*Transition: "Magnitudes."*

---

## Slide 13 — Magnitudes (the one table) [12:05]

> This is the only regression table I'll show you, and I've stripped it to the three columns that matter — stars only, no standard errors; everything is bank-clustered and survives permutation inference.
>
> Column one: High-CECL banks lose 0.39 percentage points of assets in uninsured time deposits — about seven percent of the sample mean. Column two: they gain 0.71 points of insured time deposits. The continuous row underneath shows both scale smoothly with the size of the charge.
>
> Column three is the triple difference, with bank-times-quarter fixed effects: the uninsured-minus-insured gap widens by 1.25 percentage points, significant at the one percent level. I want to dwell on what surviving that specification means: for stress to produce this number, it would have to push uninsured and insured time deposits in *opposite directions inside the same bank in the same quarter, in proportion to the disclosed charge*. That's not what a funding shock looks like; it's what a reaction to the insurance threshold looks like.

*Transition: "That's the last table. Where exactly does the response live?"*

---

## Slide 14 — The rollover margin [13:05]

> Everything from here on is the same specification you just saw — I'm just showing the interaction coefficients graphically, with ninety percent confidence intervals.
>
> The response lives exactly where a depositor holds a scheduled decision. Time deposits reprice only at maturity — the rollover is the depositor's call. Widen the lens to *all* uninsured deposits — mostly operating balances, payroll, business checking — and there is nothing: those balances have no decision point, and moving them means severing a banking relationship.
>
> And within uninsured CDs, split banks by how much of their book was coming due, measured before adoption: banks with the shorter book show minus 0.54 — 2.4 times the minus 0.23 for the longer book. The outflow concentrates where rollover decisions actually occurred. That's quantity discipline at the rollover margin, and nowhere else.

*Transition: "Did they defend that money on price? Two datasets say no."*

---

## Slide 15 — No repricing [14:00]

> Implied rates from Call Report interest expense: high-CECL banks did not pay more on the uninsured CDs they kept. Weekly posted rates from RateWatch: no differential move in the SVB stress window — worth noting on its own, because banks caught in a run bid for deposits — and no move after the disclosure became public either.
>
> Three nulls, and they're the *predicted* nulls: posted rates are set centrally, depositors are mostly inert, and weak banks can't win a price war for uninsured money. The margin depositors control is the rollover quantity — and that's the margin that moved.

*Transition: "So if the money left and the bank didn't reprice — where did the funding come from?"*

---

## Slide 16 — Where the money went [15:10]

> Banks repurchased the insurance. Insured *brokered* deposits rise by half a percentage point of assets. Reciprocal network deposits point the same way — significant in the continuous specification. And the borrowing margin, term FHLB advances, does nothing at all — this is a deposit-market substitution, not a dash for wholesale credit.
>
> The schematic is the whole mechanism: an uninsured CD matures and isn't rolled over; the bank replaces it through a broker or a network with insured money. The balance sheet keeps its size — only the *insurance status* of the funding changes. Note the contrast with the same broker's uninsured product, which doesn't move: banks were buying insurance, not liquidity.

*Transition: "Now the timing evidence — for me, the sharpest identification in the paper."*

---

## Slides 17–18 — Two actors, two clocks [16:50]
**Protected slide. This is the signature argument.**

> [Frame 1 — brokered ES] Here's the event study for those insured brokered deposits. Flat and low through the distant pre-period — and then it turns up *three quarters before adoption*, before any public disclosure exists.
>
> **[ADVANCE]**
>
> [Frame 2 — ramp highlighted, election bars] That highlighted ramp is not a pre-trend problem — it's the anticipation itself. Remember the timing wedge: banks ran CECL in parallel in 2022, so management knew the number. And the pre-adoption ramp *scales with the still-undisclosed future charge* — a coefficient of 0.53. A second, cleaner tell: on their first CECL filing, banks could elect to phase the capital hit in over three years — an irrevocable option that only makes sense if you expect a material charge. Thirty-four percent of high-CECL banks elected, against six percent of everyone else, and the electors are precisely the banks that pre-funded.
>
> So each margin moves exactly when its decision-maker's information arrives: bank-controlled margins in 2022, on private estimates; depositor-facing margins only at public disclosure. A common stress shock cannot generate two clocks.

*Transition: "This reshuffling is not free."*

---

## Slide 19 — The substitution is costly [17:35]

> Interest expense steps up at adoption and stays up — about eight to nine basis points annualized. ROA falls roughly fifteen basis points, NIM about nine. Combined with the rate nulls: the cost is not a premium paid to stayers — it *is* the substitution. Maturing uninsured CDs were replaced with insured brokered money raised at wholesale rates. Depositors leave rather than negotiate, and the bank pays for their departure.

*Transition: "One more prediction of monitoring theory."*

---

## Slide 20 — Distance to default [18:20]

> The same disclosed charge should be worse news at a thinner bank, because the charge consumes equity. And that's the gradient in the data: interact the treatment with pre-adoption capital, and the response is strongest at thin buffers — minus 0.40 at six percent equity — fading to nothing at around twelve percent, roughly the 75th percentile. The best-capitalized quartile draws essentially no response. Monitoring intensity tracks distance to default — exactly what the theory says it should do.

*Transition: "And the elephant: 2023."*

---

## Slide 21 — This is not the SVB stress [19:10]

> Adoption coincided with the SVB episode, so let me close identification. The disclosed charge is essentially orthogonal to everything that defined run exposure in 2023 — unrealized securities losses, asset maturity, the Huberdeau-Reid–Pennacchi balance-sheet-risk measure — all flat across charge deciles, under one percent of variation explained. The placebo: at banks with a *zero* charge, uninsured CDs did not fall with unrealized losses after March — the sign is actually positive. A horse race leaves my estimates unchanged. And the 2023 runs themselves were wholesale runs at publicly traded banks — my sample is private, retail-funded community banks. On top of all of that, the triple difference nets out any bank-level stress exposure by construction.

*Transition: "Let me close."*

---

## Slide 22 — Takeaways [20:00]

> Four things. Depositors read a mandatory accounting disclosure and acted on it — flat for five years, breaking only when the number became public. Discipline took the form of quantity exit at the rollover margin — no repricing, no move in operating balances. Banks repurchased the lost insurance in wholesale markets, and paid for it in funding costs and profitability — the bite of discipline is a price. And the policy point: proposals like the ten-million-dollar Main Street coverage convert exactly the funding that monitors into funding that doesn't. Those proposals should be assessed for the discipline they displace, not only the stability they deliver. Thank you.

---
---

# Anticipated questions → backup slides

**Q: Isn't the charge just proxying for observable weakness?**
→ pill *detail* on slide 7 (Backup: the charge is hard to predict).
One breath: 2022Q4 fundamentals, deposit mix, performance trends, and local HHI together explain ~1.4% of the variation; directions are sensible (NPLs, ROA trend) but almost all variation is orthogonal to anything a depositor could observe.

**Q: Rate results in more detail?**
→ pill *detail* on slide 15 (Backup: rate tests in detail).
Implied uninsured-CD rate DiD −0.082 (SE 0.052); within-bank large–small spread if anything narrows (−0.110*); RateWatch weekly nulls in stress window and post-publication; >90% of branches follow centrally set rates.

**Q: How does the phase-in election work exactly?**
→ pill *phase-in mechanics* on slide 17 (Backup: the capital phase-in
election). Elected on the first CECL Call Report, irrevocable; adds back 75/50/25% of the regulatory-capital hit over three years; election probability rises 0.072 per pp of charge; electors' brokered ramp 0.41 pp larger. Election is measured *at* filing — only the brokered ramp is genuinely quarters early.

**Q: Capital-buffer interaction — full specification?**
→ pill *full spec* on slide 20 (Backup: capital-buffer interaction).
Gap-design triple +0.0665 (0.019); main effect at zero equity −0.80; robust to dropping the time-varying equity control; one imprecise cell (binary treatment in levels) which the gap design recovers.

**Q: More on the SVB placebo?**
→ pill *placebo detail* on slide 21 (Backup: SVB placebo and horse race).
Zero-charge banks: Post-SVB × unrealized loss +0.073** — wrong sign for a run, and insured CDs move the same way: rate-cycle funding mix, not flight. Horse race: CECL coefficients −0.078/−0.406, essentially unchanged.

**Q: Pre-trends over a longer window?**
→ last backup (Backup: five-year pre-period, balanced endpoints).
2018Q1 onward with pooled endpoint bins: joint pre-trend tests pass (uninsured p = 0.18, insured p = 0.37); the late insured drift is the banks' own pre-funding, absorbed into the k = −1 baseline, so post coefficients *understate* the total shift.

## Pennacchi-specific

**Q (likely): The reciprocal mechanism — what exactly moves?** A: In a reciprocal network the bank's *balance sheet does not change* — the network slices a large account into sub-$250k pieces at member banks and the bank receives offsetting balances from other members. Only the insurance status of the money moves. That's why I treat it as "repurchasing insurance" and why the intensive margin moves while the probability of holding any reciprocal balance does not. It's the network-based insurance margin of Kim–Kundu–Purnanandam; his own 2025 JFI paper with Huberdeau-Reid shows riskier banks expanded exactly these instruments after the 2023 failures — my point is the same behavior shows up in response to a *predetermined disclosure at solvent banks*.

**Q (possible): Why book equity/assets as the buffer moderator and not a regulatory ratio?** A: The depositor's claim in a failure is on book equity — the charge mechanically consumes it — so book equity is the economically relevant buffer for an uninsured creditor. Regulatory ratios add risk-weighting choices that aren't the depositor's object.

**Q (possible): Is the funding-cost increase just the rate cycle?** A: The rate cycle is common to all banks and absorbed by quarter fixed effects; the estimates are cross-sectional in the charge. And the FHLB margin — where the 2022–23 cycle showed up for everyone — is flat in the charge.

---

*Pacing fallbacks: if behind at slide 10 [9:05], compress slides 19–21 to one sentence each — their takeaway bars carry the content. If ahead at slide 16, give the two-actor build the extra minute; it's the slide the discussion will center on.*
