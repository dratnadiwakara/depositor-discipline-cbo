# Pre-submission to-do — fdic-brc-jfqa-aug2026 — 2026-09-15

Source: session assessment after deck v4 revisions. Target: JFQA / JBF. Items ordered by expected referee weight. Scratchpad scripts referenced below live in the session scratchpad and must be moved into `code/result-generation/` before any number is cited in the paper.

## A. Interpretation (text changes, no new estimation)

- [ ] **Information shock vs capital shock.** The Day-One charge mechanically lowers book equity. A depositor reacting to a lower equity ratio is not "reacting to news about credit risk." Confront this in the introduction, not the robustness section. Candidate arguments: (i) charge is a reclassification of retained earnings into reserves, no change in tangible loss-absorbing capacity; (ii) regulatory capital phase-in election means the *regulatory* hit is spread over three years, yet the deposit response is immediate; (iii) the capital gradient can be read either way and should be presented as such.
- [ ] **Reframe the cost section (§ on interest expense / ROA / NIM).** Current text: "the cost comes from replacing maturing uninsured CDs with insured wholesale money." Evidence this session: thick-capital banks show the same interest-expense and ROA point estimates as thin-capital banks (+0.020 vs +0.021; −0.034 vs −0.039) with no CD loss; the difference is not significant. The defensible claim is: banks bought insured wholesale funding on their private number, across the capital distribution, and paid for it whether or not depositors then left. The cost is the cost of the insurance purchase, triggered by the *expectation* of discipline. Update slide 21 takeaway and takeaways-slide bullet 3 to match.
- [ ] **State the bank/depositor asymmetry as a result.** Bank response (pre-adoption brokered ramp) is present in every capital quartile and both maturity halves; interactions with capital and maturity all insignificant (High × thin p=.47, High × short p=.55, three-way p=.90; scratchpad `ramp_quartiles.R`, `ramp_maturity.R`). Depositor response sits in one cell (thin capital × short maturity: −0.88***, other three cells zero; `slide_figs_v4_20260915.R` §4). Two agents, two decision rules. Currently only on slide 20; belongs in the paper as its own paragraph or short table.
- [ ] **Magnitude framing.** 0.39pp of assets on a 5%-of-assets funding line, 217 treated banks; total uninsured deposits null under every cut tried (16 specifications, scratchpad `total_unins_search.R`, no p < .19). Pre-empt the "small" objection: express the effect relative to the uninsured CD base (~7.5% of the stock), relative to the composition gap (−1.25pp), and be explicit that operating balances do not move and why.
- [ ] **2023 attention caveat.** Already on slide 24 and in the paper. Keep, but pair it with the pre-SVB bank ramp as evidence that discipline was expected before there was any run to watch.

## B. Estimation to move from scratchpad into the track

- [ ] Move `ramp_quartiles.R` and `ramp_maturity.R` into `code/result-generation/` (dated) and export a small table: ramp by capital quartile and by maturity half, plus interaction tests. Backs the asymmetry paragraph.
- [ ] Move `retention_test.R` into the track. Backs backup slide "Who kept the brokered money?" (44 vs 16 pre-funders; difference +4.33*** in post-adoption brokered change). Keep as descriptive; do not promote to a main result.
- [ ] Move `cost_thin_thick.R` into the track. Backs the reframed cost section (thin vs thick cost estimates).
- [ ] Capital × maturity 2×2 (`slide_figs_v4_20260915.R` §4) is deck-only. Decide whether it enters the paper as a table (recommended: yes, one panel next to the capital-heterogeneity table).
- [ ] Median-split capital figure on slide 19 (`slide_figs_v4_20260915.R` §3) duplicates Table 4's continuous interaction. Paper keeps the continuous version; no action unless a referee asks for the split.

## C. Things checked this session that do NOT go in the paper

- Thin-and-short subsample rate tests: implied uninsured CD rate +0.15**, insured +0.16***, spread 0.00 (`rates_thinshort.R`). Uniform repricing in a 58-bank cell; RateWatch posted rates null there. Removed from deck. Mention only if a referee raises repricing in the responsive cell.
- Total-uninsured 2×2 and triple-diffs: right sign, SE ≈ 1.0–1.4, never significant.
- Q1-vs-Q4 ramp comparison: Q2 has the largest ramp; no monotone capital gradient in the bank response.
- Dropping high-public or high-transaction banks does not recover a total-uninsured effect; point estimate flips positive.

## D. Housekeeping

- [ ] `NOTES.md` entry for 2026-09-15 session (deck v4: 27 PDF comments, new slides 15/16/20-backup, slide 12 callout, slide 17/18 reverted to full sample).
- [ ] Backup slide "Who kept the brokered money?" numbers are hardcoded in `slides/main.tex`; add source comment once `retention_test.R` is in the track.
- [ ] `build/main - v1.pdf` (commented copy) is untracked; archive or delete after the comment round is closed.
