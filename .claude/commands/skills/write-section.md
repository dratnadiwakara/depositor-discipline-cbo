# Skill: Empirical Finance Paper Section Writer

## Trigger
This skill is **only** activated when the user explicitly invokes it with the `/write-section` command. Do NOT apply this skill based on context or intent inference. If the user asks about writing, editing, or drafting paper sections without using `/write-section`, treat it as a normal request—do not load or follow this skill's rules.

**Valid triggers**: `/write-section did-april2026 intro`, `/write-section did-april2026 results`, `/write-section iv-april2026 data`, `/write-section intro` (track inferred), `/write-section results` (track inferred), `/write-section did-april2026 intro emphasize the cost-channel story and cite NRS 2026 in the contribution paragraph`, `/write-section results focus on Table 4 columns 3-5`, etc.
**Not a trigger**: "help me write the intro", "draft the results section", "edit my paper".

### Argument Grammar

```
/write-section [<track>] <section-type> [<free-text instructions...>]
```

- Token 1: track name OR section type (see Track Resolution).
- Next token: section type (only if token 1 was track).
- **Everything after the section type** is treated as a single free-text **instructions** string. Optional.

### Free-Text Instructions (optional trailing argument)

After the required tokens are consumed, any remaining text in `$ARGUMENTS` is the user's section-specific instructions. Treat it as **high-priority guidance** layered on top of the default style rules, but never as a license to violate the hard rules (no warmup, only write what code produces, no fictional robustness, etc.).

For section types that emit multiple subsections from a single file (currently: `data`, whose subsection structure is chosen per paper — see the Data block below), the free-text instructions accept a `||` separator. Text before the first `||` is the high-priority guidance for the first subsection; text after the first `||` is for the second; text after a second `||` for the third; and so on. The number of slots equals the number of subsections actually emitted. Empty slots inherit no extra guidance. If no `||` appears, the entire instruction string applies to all subsections equally. The same separator rule applies to other multi-subsection section types if any are added later.

Use the instructions to:
- pick which tables/figures to lead with (`focus on Table 4 columns 3-5`),
- enforce a specific framing (`emphasize the cost-channel story`),
- add or drop citations (`cite NRS 2026 in the contribution paragraph`, `do not cite Smith 2020`),
- constrain length (`keep under 2 pages`, `single paragraph`),
- request a particular tone, hedge, or qualifier,
- pin variable naming or notation.

When instructions conflict with the section-specific style block below (e.g., user asks for a "future research" punch list in the conclusion), follow the **user**, but flag the deviation in one line at the top of your reply before producing the file.

If instructions are ambiguous or unverifiable (refer to a table that does not exist, request a robustness check absent from the code), **stop and ask** rather than fabricating.

### Track Resolution

If `$ARGUMENTS` contains only one token and that token is a valid section type (`intro|inst_bg|data|identification|results|conclusion|appendix`; `desc_stats` is an alias for the `Descriptive Statistics` subsection of `data` --- always the last subsection of `data` when distributional content is emitted --- see the Data block in section-specific conventions), infer the track:

1. List directories under `tracks/`, excluding `.archived/` and any hidden folders.
2. **Single candidate** → use it. Proceed silently.
3. **Multiple candidates** → pick the most-recently-modified track by checking, in order:
   - latest `git log -1 --format=%ct -- tracks/<name>/` timestamp across candidates, OR
   - mtime of `tracks/<name>/NOTES.md` if git history is sparse.
   If one track is clearly more recent (>7 days gap to next), use it and **announce the inference** in one line: `Inferred track: did-april2026 (most recent activity).`
4. **Ambiguous** (multiple tracks active within 7 days, or no clear signal) → **stop and ask** the user which track. Do not guess.
5. **Zero tracks** → stop, report missing.

If the first token of `$ARGUMENTS` is not a recognized section type, treat it as a track name (existing behavior) and the second token as the section type.

## Purpose
Write individual sections of an empirical finance paper in LaTeX, targeting journals in the JF / RFS / JFE / JBF / JMCB range. Output is a `.tex` file saved to the appropriate track-scoped subsection folder. **Never overwrite an existing `.tex` file**—always save as a new file with an incremented version suffix or updated date stamp (e.g., `intro_section_20260406.tex`).

## Inputs Required
Before writing any section, Claude Code should collect or confirm:
0. **`$ARGUMENTS`** (first token): `<track-name>` — the track folder name under `tracks/`, e.g. `did-april2026`. **Optional**: if omitted (only a section type is passed), the skill infers the track per the **Track Resolution** rules above. The skill resolves all reads/writes under `tracks/<track-name>/latex/...`.
1. **Section type**: one of `intro`, `inst_bg`, `data`, `desc_stats`, `identification`, `results`, `conclusion`, `appendix`. Position depends on whether the track was passed (second token) or inferred (first token).
2. **Free-text instructions** (optional): any tokens after the section type are concatenated into a single instructions string. Applied per the **Free-Text Instructions** rules in the Trigger block.
3. **Empirical results files**: `.tex` table files, figure `.png` files, and their descriptions/captions.
4. **Code files** (optional but helpful): R or Stata scripts that generated the results, so variable names, sample filters, and specification details can be described accurately.
5. **Project CLAUDE.md or context file**: for paper-specific terminology, variable definitions, identification strategy, and sample details.
6. **Prior section drafts** (if any): so that cross-references, narrative arc, and notation remain consistent.

## Output Rules
- Save to: `tracks/<track>/latex/sections/[section_subfolder]/[section_name]_current.tex` for the working draft, or to a dated/versioned filename `tracks/<track>/latex/sections/[section_subfolder]/[section_name]_[YYYYMMDD]_v[N].tex` when the user wants to preserve a snapshot.
  - If a dated file with today's date exists, increment version: `v2`, `v3`, etc.
  - Subfolder names: `intro`, `inst_bg`, `data`, `desc_stats`, `identification`, `results`, `conclusion`, `appendix`.
- Pure LaTeX body content only—no `\documentclass`, no `\begin{document}`. The file will be `\input{}`-ed into the track's master document at `tracks/<track>/latex/main.tex`.
- Use `\label{}` for all sections, subsections, tables, and figures so other sections can `\ref{}` them.
- **Floats live in `tables_figures.tex`, not in section files.** Every `\begin{figure}...\end{figure}` and `\begin{table}...\end{table}` block — its caption, its `\label{}`, its `\adddescription{}`, its `\input{tables/...}` of the bare tabular fragment — is hosted in `tracks/<track>/latex/tables_figures.tex`, the unsectioned floats file `\input{}`-ed from `main.tex` *after* the bibliography. Body sections (intro, data, identification, results, heterogeneity, robustness, conclusion) refer to floats by `\ref{tab:...}` / `\ref{fig:...}` only and never inline a `\begin{figure}` or `\begin{table}` environment. Before drafting any section, grep `tracks/<track>/latex/tables_figures.tex` for existing `\label{fig:...}` and `\label{tab:...}`, build a label-map, and use only those labels in the new section. If the section genuinely needs a float that does not yet exist, add it to `tables_figures.tex` via `/skills/latex-table-inserter` or `/skills/latex-figure-inserter` and then `\ref{}` it from your section.

---

## Writing Style Guide

### Voice and Register
- **Third-person, present-tense exposition** for describing methods and results ("We estimate...", "Column 3 shows..."). First-person plural ("we") is standard.
- **Assertive but not overconfident**. State findings directly without excessive hedging ("seems to suggest", "appears to possibly indicate"), but do not overclaim. No empirical paper is airtight—there are always alternative explanations. Acknowledge the most plausible ones honestly rather than burying them. Do not write as though the identification is perfect or the evidence is definitive when it is not. Sophisticated readers will notice overselling; it undermines credibility.
- **No filler or throat-clearing**. Every sentence should either (a) convey information, (b) build the argument, or (c) connect the reader to the next idea. Delete sentences that merely announce what will come next without adding content.
- **Cochrane's "no warmup" rule**. Nothing before the main result of a section that the reader does not need to read in order to understand the main result. No replication of well-known datasets, no preliminary estimates, no descriptive-statistics travelogue placed in front of the main result.
- **No previews or recalls**. Avoid "as we will see in Table 6" and "recall from Section 2." If you find yourself writing one, the order is wrong; fix the order.
- **No adjectives on your own work**. No "striking results," "very significant" coefficients, "interesting findings." Cochrane: "If the work merits adjectives, the world will give them to you."
- **Only write what is actually in the code and results**. Before drafting, read the code files in `tracks/<track>/code/` (and shared `code/common.R` at the project root), the output files in `tracks/<track>/latex/tables/` and `tracks/<track>/latex/figures/`, and `tracks/<track>/latex/tables_figures.tex` (the inventory of floats actually inserted into the paper, with their `\label{}`s). Do not claim a robustness check, alternative specification, placebo test, or mechanism test was run unless there is a corresponding script and output file. Never write sentences like "results are robust to alternative specifications" or "we also find consistent results using X" if that analysis does not exist in the code.
- **Assume a sophisticated reader**. Do not explain what a fixed effect is, what a DiD does in general terms, or how OLS works. Explain *your* specification choices and why they are appropriate for *your* setting.
- **Reader-objective-first, not code-cataloguing.** Empirical-substrate sections (Data, Sample, Measurement, Identification) must open with the empirical objective the section is serving and what the data needs to deliver to answer it; subsequent paragraphs walk the reader through construction in the order that builds toward that objective, not the order the code runs. Each construction step's purpose is justified by what it contributes to the empirical question. Do not structure prose as a list of variables, sources, or pipeline outputs. Open paragraphs with the measurement target ("To measure a bank's local cost-side advantage, we need..."), then describe the construction that hits the target --- never with "Variable X is defined as the ratio of A to B from source C."
- **Skip trivial mechanics knowledgeable readers know.** Omit standard data-construction machinery that finance journal audiences already know: HUD ZIP--county / tract--ZIP allocation crosswalks; HMDA respondent-ID-to-RSSDID linkage via the Avery crosswalk (and LEI--RSSDID post-2018); efficiency-ratio definitions; CRA small-business loan size cutoffs; ACS / IRS forward-fill or back-fill mechanics outside the analysis window; specific Call Report RIAD line numbers unless the line choice is itself the methodological point. Mechanics that are non-obvious or non-standard --- self-exclusion of the focal bank from an incumbent benchmark, sample-period restrictions driven by identifier resets, cycle-period assignment for an imputed panel --- DO need explanation because the reader cannot guess them. If a mechanism is needed for replicability but is too long for the body, banish it to an appendix or a footnote.

### Paragraph and Sentence Construction
- **Lead with the claim, then supply the evidence**. Topic sentences state the finding or argument; supporting sentences provide the mechanism, coefficient, or citation.
- **Vary sentence length** but favor crisp, declarative sentences for key results. Reserve longer sentences for nuanced qualifications or mechanism discussions.
- **One idea per paragraph**. If a paragraph covers two distinct points, split it.
- **Transitions between paragraphs should be logical, not mechanical**. Mechanical connectors ("Next, we...", "Additionally,...", "Moreover,...") are acceptable sparingly but should not become a crutch—vary them with transitions that emerge naturally from the argument: "The cross-sectional variation in deposit responses suggests a role for information acquisition costs. To test this channel, we exploit..."
- **Do not use paragraph titles or `\paragraph{}` headings.** No bold lead-in labels (`**Main results.**`), no LaTeX `\paragraph{Foo.}` macro, no `\textbf{Foo.}` lead-ins, no `\noindent\textbf{...}` fake headings. Paragraphs must flow from their topic sentences. The topic sentence itself carries the work that a paragraph label would have done.
- **Prefer continuous prose over subsection proliferation.** A section is paragraphs flowing into paragraphs, not a stack of headings. Default to **zero or one** `\subsection{}` per section. Add a `\subsection{}` only when the section spans a genuinely separate content block that a reader will navigate to independently (e.g., a long results section that cleanly splits into "Main Results" and "Heterogeneity"). Do not subsection a topic just because it is a distinct variable, source, or step --- those belong inside the prose, with the topic sentence doing the framing. If you find yourself writing three or more `\subsection{}` calls in the same section, collapse them.
- **Use em dashes sparingly**. Reserve them for a genuine aside or strong parenthetical break. Do not use them as a default connector or substitute for a comma, colon, or semicolon.

### Discussing Results
- **Cite coefficients with economic magnitudes, not just statistical significance**. Bad: "The coefficient is significant at the 1% level." Good: "A one-standard-deviation increase in X is associated with a Y-basis-point decline in uninsured deposit growth (column 3, p < 0.01), roughly 40% of the sample mean."
- **Use tables as evidence, not as the narrative**. The text should tell a story that the tables support. Do not write "Table 3 shows our results" and leave it at that. Walk the reader through the key columns and rows that matter for the argument.
- **Address magnitudes relative to benchmarks**: sample means, prior literature estimates, policy-relevant thresholds.
- **Discuss null results honestly** when they matter for identification (e.g., placebo tests, pre-trends). Frame them affirmatively: "Insured deposits show no statistically significant response to the information shock (Table 5, Panel B), consistent with the moral hazard channel: deposit insurance eliminates the incentive to monitor."

### Section-Specific Conventions

#### Introduction
- **Opening paragraph**: Motivate with a real-world tension, puzzle, or policy question—not a literature survey. The first sentence should make the reader want to keep reading.
- **Research question**: State it clearly within the first two paragraphs.
- **Preview of findings**: One paragraph summarizing main results in plain language with approximate magnitudes. Keep numbers impressionistic—drop p-values entirely, round sample counts, simplify date ranges. Exact figures in prose signal insecurity; the reader will find precision in the tables.
- **Identification pitch**: One paragraph on why the empirical strategy is credible. Highlight the source of exogenous variation and what it rules out. When presenting identification threats, state challenges from both sides (e.g., both supply and demand); an argument that only describes one direction will seem incomplete to a careful referee.
- **Contribution paragraph(s)**: Position relative to 3–5 most closely related papers. Be specific about how this paper differs ("While Smith (2020) studies X in the context of Y, we exploit Z to identify..."). Do not write a mini literature review here. End each contribution paragraph with what you do—not a primacy claim. Avoid "To our knowledge, the first to..."; it invites challenges and sounds defensive. Let the contribution speak for itself.
- **Mechanism claims**: Distinguish between "we find X" and "X proves Y." When the underlying mechanism is observationally ambiguous, use "consistent with" rather than assertive causal language. Reserve strong mechanistic claims for what the design actually identifies.
- **Attribution of known problems**: Do not pin general methodological concerns on a single paper, especially old or unpublished work. State well-known problems as issues the literature faces broadly. Weak attribution invites referees to challenge the premise rather than engage with your solution.
- **Variable naming**: Name variables in the introduction exactly as they appear in the analysis. Do not use a narrower or more specific label than the actual variable—readers will notice the gap when they reach the tables.
- **Secondary findings**: If a result is not central to the paper's claim, state it in one sentence and move on. Playing up secondary findings dilutes the main message and invites referees to treat them as the main contribution.
- **Roadmap**: One sentence at the end. ("Section 2 describes the institutional setting. Section 3 presents the data..."). Keep it perfunctory.
- **Length**: 4–6 pages for a top journal submission.

#### Institutional Background
- **Purpose**: Give the reader enough institutional detail to understand why the empirical design works. This is not a textbook chapter.
- **Focus on features that matter for identification**: regulatory thresholds, timing of policy changes, information environment, relevant agents and their incentives.
- **Use a timeline or sequence** if the institutional setting involves a phased rollout or staggered adoption—readers need to see the variation.
- **End with the link to the empirical strategy**: "This staggered adoption creates cross-sectional and time-series variation in information availability that we exploit in our difference-in-differences design."
- **Length**: 2–4 pages.

#### Data (subsection structure chosen per paper)
The data section emits one to four subsections into `data_current.tex`. The right number of subsections is a function of the paper's content, not of a template. Pick one of the three default architectures below, in order of preference for the paper's structure. In all cases the subsections live in the same `data_current.tex` file (no separate section files), and the cross-cutting conventions in the next block apply regardless of which architecture is chosen.

**Architecture A --- single continuous block** (no `\subsection{}` calls). Use when the paper relies on a single data source or off-the-shelf datasets and the contribution is in the analysis, not the data construction. Greenwald-style: one continuous narrative that walks through the primary source, any enrichments, the sample window, and exclusions, closing with summary stats deferred to an appendix.

**Architecture B --- by data source.** One subsection per data source (e.g., `Summary of Deposits`, `Call Reports`, `Demographic Data`, `Other Data Sources`), ordered by analytical centrality (the outcome-defining source first, controls last). Use when the paper integrates several distinct sources and the reader benefits from per-source navigation. NRS-style.

**Architecture C --- by content block.** One subsection per content block (e.g., `Sample and Panel Construction`, `Variable Construction` or `Channel Variables`, `Controls`, `Descriptive Statistics`). Use when the paper has multiple measurement programs, a multi-channel hypothesis structure, or a non-trivial sample-construction rule (candidate-market set, at-risk subsample, restricted choice set) that deserves its own scaffold.

**Rules common to all architectures:**

- When distributional content is emitted from the data section at all, it lives in a final `\subsection{Descriptive Statistics}\label{sec:data:desc}`. The `Descriptive Statistics` subsection is always the last subsection of the data section when present. Papers that defer all distributional content to a results-section summary-stats table omit this subsection.
- Standard label conventions, where the subsection exists: `\label{sec:data:sample}` for sample/panel construction; `\label{sec:data:channels}` (or `sec:data:variables`) for variable / channel construction; `\label{sec:data:controls}` for controls; `\label{sec:data:desc}` for descriptive statistics. Architecture B may use source-name labels (`sec:data:sod`, `sec:data:hmda`, etc.) instead.
- Both subsections (or all of them) live in the same `data_current.tex` file --- do not split into multiple section files.
- Free-text instructions are split on `||` into one slot per emitted subsection, in order.

##### Cross-cutting data-section conventions (apply to all architectures)

- **Opening style.** Two sentences at most. Sentence 1 names the primary data product the section assembles (e.g., "We build a bank--market--year panel of de novo branch entry over YYYY--YYYY"). Sentence 2 enumerates what the empirical question requires the data to deliver. Do not motivate the research question itself --- that lives in the introduction. Do not preface with a literature reminder.
- **Subsection ordering rule.** Order by *analytical centrality*, not alphabetical and not by data acquisition order. Outcome-defining source / sample first; mechanism or channel variables second; controls third; descriptive moments last. Inside a multi-channel `Variable Construction` subsection, order channels by theoretical centrality to the paper's claim, not by ease of measurement.
- **Subsection length is proportional to centrality, not symmetric.** Standard / boilerplate sources (Call Reports, demographic covariates) get a short paragraph or two. Novel data, non-standard variable construction, and sample-defining sources get more space. Resist padding short subsections to match long ones; NRS-style subsection-length asymmetry is a feature.
- **Forward-reference style: "assert the pattern, then cite the evidence."** Lead the sentence with the substantive claim and append the float reference at the end (`"Branch openings have shifted toward the largest size bucket over the sample period (Figure~\ref{fig:openings_by_size_stacked})"`), not the reverse (`"Figure~X shows that..."`). Never write "as we will see," "we will show in Section Y," or "recall from Section Z." If a forward reference to a results-section finding is genuinely needed, phrase it as "the size-stratified specifications in Section~\ref{sec:results} exploit this pattern" --- the verb is in the present tense, not the future.
- **Formulas: default to deferral.** A formula belongs in the body of the data section only when (a) the variable's name does not convey its construction and (b) the construction is itself the methodological contribution. Otherwise: simple ratios and indicator definitions get an English clause; multi-step constructions (within-cycle first stages, vector-norm cosines, two-stage matches, residualized leave-out averages) go to a footnote, the identification / methods section, or an appendix variable-definitions table. Both NRS and Greenwald defer all formulas from the data section.
- **Footnotes carry non-obvious mechanics, not textbook machinery.** Footnotes are appropriate for: identifier-reset and regulatory-transition exclusions; cycle / window assignment rules for imputed panels; winsorization thresholds and grouping; first-stage covariate lists when only the first stage's *purpose* is in the body; vendor-specific quirks (cf. Begenau's quoted RateWatch email on rate-setter designation). Do not footnote standard data machinery --- HUD ZIP--county crosswalks, Avery / LEI--RSSDID linkage, efficiency-ratio definitions, CRA loan-size cutoffs, ACS / IRS forward-fill, RIAD line numbers (unless the line choice is itself the methodological point). Those are either omitted from the body entirely or sent to an appendix variable-definitions table.
- **Variable / channel paragraph template.** When a paragraph constructs a variable, channel, or instrument, use this four-beat structure: (i) one sentence stating what the measurement must capture and why the empirical question demands it; (ii) one sentence naming the data source(s) and the unit at which the variable varies (bank--year, bank--market--year, market--year, etc.); (iii) one to two sentences on the construction at the level a sophisticated reader needs (non-standard sample restrictions, self-exclusion of the focal unit from a leave-out benchmark, normalization choices); (iv) optional sentence on the binary-vs-continuous choice if the paper uses an indicator in the main specifications and the continuous version is preserved for robustness. Everything beyond these four beats goes to a footnote or appendix.
- **Sample restrictions: justify operationally and contextually.** Operational restrictions (size threshold, the analysis-usable observation window after lag-required loss) get a brief why-clause. Contextual restrictions that the reader cannot guess (excluding 2011 due to OTS / OCC absorption, excluding 2020 due to COVID-19 lending anomalies, restricting to stress-test reporters for a Y-14 measure) get a sentence with the concrete data-history fact behind them. Both Greenwald and NRS justify restrictions by reference to a specific institutional or regulatory event, not by methodological abstraction.
- **Descriptive statistics: lead with the pattern, not the table scaffold.** When a `Descriptive Statistics` subsection is emitted, open it with the cross-group asymmetry, heterogeneity, or stylized fact that motivates the empirical design downstream --- not with `"Table~X reports the sample moments of every variable."` Cite the summary-stats table once (`\ref{tab:descriptive_stats}`). Recite means and standard deviations only for variables whose value is non-obvious or load-bearing for the results section. Close with one sentence forward-referencing the results section that points to which specifications the patterns motivate (in present-tense form, per the forward-reference rule above). Do not preview coefficients or significance from the regression tables.
- **No distributional content outside the descriptive-statistics subsection.** Sample means, standard deviations, frequencies of binary indicators, and cross-bucket / cross-period heterogeneity belong in `Descriptive Statistics`. The other subsections may state structural sample-size facts (total N bank--period observations, number of size buckets, fraction of the universe of openings captured by the candidate set) but not distributional moments.
- **Floats live in `tables_figures.tex`.** The data section never inlines a `\begin{figure}` or `\begin{table}` environment. Before drafting, grep `tables_figures.tex` for existing labels and build a label map; reference floats only by `\ref{tab:...}` / `\ref{fig:...}` against labels that already exist there. If a needed float does not yet exist, add it via `/skills/latex-table-inserter` or `/skills/latex-figure-inserter` and then reference it from the body.
- **Skip standard data machinery from the body.** No HUD crosswalk names, no Avery / LEI--RSSDID linkage sentences, no efficiency-ratio formulas, no CRA loan-size cutoffs, no ACS / IRS forward-fill mechanics, no Call Report RIAD line numbers (unless the line choice is itself the contribution). Source names + variable names suffice; finance readers can fill in the standard recipe.
- **Total length target.** 1,200--1,800 words across all subsections combined. Sections substantially longer almost always carry undeferred mechanics that belong in footnotes, methods, or an appendix variable table.


#### Empirical Strategy / Identification

The identification section is an *argument*, not a checklist of equations, fixed effects, and clustering choices. A reader finishing the section should be able to state, in their own words, (i) what marginal decision the regression is modeling, (ii) where the identifying variation comes from, (iii) what assumption gives the coefficient of interest a causal reading, (iv) which threats would break that reading and how the design defends against each, and (v) why the cluster level and the choice of estimator are the right ones for this design rather than a generic default. The conventions below operationalize that argument.

##### Section opening

- **Open with the marginal decision and the source of identifying variation, not with the equation.** One paragraph: name the unit of observation (e.g., bank--ZIP--year), describe the marginal decision being modeled (e.g., the bank's choice of which ZIPs to open in within its candidate set), and name the variation the design exploits (e.g., cross-sectional variation across candidate ZIPs within each bank--year and state--year cell). Close the paragraph with a one-sentence preview of the central comparison the coefficients read. This is the identification analog of the data section's "primary product + what the question requires" opening.
- **Do not redefine the sample.** Forward-reference `\ref{sec:data:sample}` for sample construction and candidate-set definition. State only what is needed for the causal argument (e.g., what the candidate-set restriction conditions on and why that matters for interpretation), not how the sample was built.

##### Estimating equation and what each piece does

- **Lead with a numbered estimating equation.** Display it in a numbered `equation` environment with the label `\label{eq:main}` (or a paper-specific name). The equation is presented *after* the opening paragraph that sets up the marginal decision, so the reader sees the equation already framed.
- **Define every symbol in the immediately following paragraph,** in the same order they appear in the equation. Sample-defining objects (the dependent variable, the unit of observation, the timing of measurement) are forward-referenced to the data section rather than redefined.
- **Treat each fixed effect as part of the identification argument, not as boilerplate.** For every fixed-effect term, write a sentence (or one short clause within a sentence) that names (a) what it absorbs in the bank's / market's / firm's behavior and (b) the specific threat it neutralizes. "Bank--year fixed effects absorb the bank's overall expansion intensity and balance-sheet posture in year $t$, so the channel coefficients are read off how the bank chooses between ZIPs inside its candidate set rather than off how aggressive a branch builder it is in the aggregate." NRS, Nguyen, and DiMaggio all use this construction; silence on what FE absorb is read as carelessness.
- **Justify control vectors by what they strip out, not by what they include.** State the demand-side / supply-side / mechanical confound the controls neutralize; do not list variables one by one in this section (the data section does that).

##### Identifying assumption

- **Name the assumption by type.** Conditional exogeneity, parallel trends, exclusion restriction, monotonicity, no anticipation, SUTVA, no spillovers --- pick the one(s) the design actually requires and name them. Vague language ("we control for confounding") is a flag for a missing argument.
- **State the assumption once formally, then defend it twice in plain English.** A top-journal identification section restates the core assumption two to three times across the section, each time in a different framing: as a moment condition, as a counterfactual statement about behavior, as a description of where residual variation comes from. This is good practice, not redundancy --- each restatement covers a slightly different threat.
- **Defend the assumption in the paper's institutional context, not generically.** The defense should refer to a feature of the data, the institutional setting, or the construction of the regressor that makes the assumption plausible *for this paper*. Nguyen (2019) defends as-good-as-random merger exposure by appealing to the size of the merging banks relative to local conditions; NRS (2026) appeals to the leave-out usage measure breaking the feedback loop between the focal branch and its predicted closure probability. The argument should be specific enough that swapping it into another paper would not work.

##### First stage / source of variation (when the key regressor is imputed or instrumented)

- **If the key regressor is imputed, predicted, or instrumented, devote one paragraph to where its variation comes from.** Three pieces: (a) the data and the unit at which the imputation / first stage is run; (b) whether the first stage is allowed to vary across cycles, cohorts, or sub-samples and the substantive reason for that choice; (c) the direction in which classical measurement error would bias the second-stage coefficient (almost always attenuation toward zero), making the second-stage estimate a conservative test of the hypothesis.
- **Preview first-stage strength.** If a first-stage table or figure exists in `tables_figures.tex`, forward-reference it here (`\ref{tab:first_stage}`); do not defer the entire first-stage discussion to the results section. Sarto--Wang and Nguyen both lead with first-stage strength before reduced-form / IV estimates.

##### Stratification, interaction structure, and specification progression

- **If the paper estimates the model on stratified subsamples (size bucket, regulatory regime, cohort), justify the stratification in the identification section, not in passing.** State the cross-stratum heterogeneity that motivates separation (forward-reference the data-section descriptive moments if they document it), and explain why pooled estimation would average across heterogeneous response surfaces and obscure the channel of interest.
- **If the hypothesis is conditional (X has an effect only when Y), explain why the interaction is the test.** Top journals expect the identification section to make clear that additive specifications cannot reject the joint null and that the interaction coefficient is the direct test of the conditional channel. Tie the interaction structure to the economic story the paper tells.
- **Label specifications progressively.** When the section walks through a sequence of regressions (baseline / with controls / with richer FE / interactive), introduce the labels here and state what each adds. Avoid presenting fifteen columns in the results section without a guide established upstream.

##### Modern-estimator and clustering notes

- **State whether staggered adoption is a feature of the design,** even when it is not. Modern referees read TWFE specifications carefully for heterogeneous-treatment-effect biases (Sun \& Abraham, Callaway \& Sant'Anna, de Chaisemartin \& D'Haultf\oe{}uille, Borusyak--Jaravel--Spiess). One sentence settles the question: if the design is cross-sectional within bank--year and state--year cells (no staggered treatment cohort), say so and note that the heterogeneous-treatment-effect concern does not bite. If the design *is* staggered, name the estimator chosen and the reason.
- **Tie clustering to the threat model.** State the cluster levels and justify each one by the dimension along which residual correlation is plausibly arbitrary (Abadie, Athey, Imbens, Wooldridge, 2023; Cameron \& Miller, 2015). "Cluster at the bank level because bank-specific strategic shocks correlate residuals across all ZIPs and years for a given bank. Cluster at the ZIP level because ZIP-specific shocks (zoning, demographic shifts) correlate residuals across all banks evaluating the same ZIP." Rules-of-thumb ("clustering at the level of treatment assignment") are not enough on their own.

##### Threats paragraph template

When constructing a threats discussion, use this three-beat structure for each threat (mirrors the data-section variable / channel template):

- **(i) Name the threat in one phrase.** "Reverse causality at the bank--market level." "Selection on the candidate-set restriction." "Classical measurement error in the imputed first stage."
- **(ii) State the direction of bias on the key coefficient if the threat is left uncorrected.** Up, down, attenuated, or ambiguous; state the sign explicitly. Referees notice when the direction is missing. If the direction is genuinely ambiguous, say so and explain why.
- **(iii) State the design feature, control, or test that addresses it,** and cite a `\ref{tab:...}` or `\ref{fig:...}` where applicable. If the mitigation is partial, acknowledge that --- claiming an open threat is fully closed is a credibility loss.

Order the threats by severity, not by the order they occurred to the writer. Stop at three or four; an identification section that names eight threats is signaling that the design has too many.

##### Style and length

- **Active voice:** "We estimate...", "Our identifying variation comes from...", "The bank--year fixed effect absorbs..." --- not passive constructions.
- **Acknowledge the limits of the design.** Name the LATE / compliers / candidate-set scope explicitly. "Our coefficients identify the bank's within-CBSA marginal-market choice, not the CBSA-level choice." This builds credibility; silence on scope reads as evasion.
- **Do not host floats.** The identification section is prose-only --- no `\begin{table}` or `\begin{figure}`. Reference floats from `tables_figures.tex` via `\ref{}`.
- **Length target:** 3--5 pages, roughly 1,200--2,000 words. Concise but complete; do not pad.

#### Empirical Results

The results section is the paper's argument made on the data. A reader finishing the section should know (i) the headline finding stated in plain economic terms, (ii) how each subsequent test deepens, qualifies, or rules out alternatives to the headline, (iii) how the coefficients translate into magnitudes a non-econometrician can interpret, and (iv) what the central pattern rules in and rules out. The conventions below operationalize that argument.

##### Section opening

- **Open with the headline finding, not with a table reference.** First sentence states the main result in plain prose, with the dominant economic magnitude (one-standard-deviation effect on the outcome, percent of baseline mean, or dollar amount --- whichever the paper conventions support). "A one-standard-deviation increase in deposit beta raises the probability of branch entry by between one third and one half of the within-bucket mean opening rate" is a usable opening sentence; "Table 4 reports our main regression results" is not. References to prior literature go in the second sentence or later, never the first.
- **Anchor the headline to a visual when one exists.** If `tables_figures.tex` contains a binned scatter, event-study figure, or raw-pattern visualization that previews the headline regression, forward-reference it before the regression table. Skip this rule when no such figure exists --- do not invent one to satisfy the convention.
- **State the puzzle the section resolves.** One sentence: what would a profit-maximizing / risk-averse / informed agent be expected to do, and how does the headline finding contradict that expectation? The puzzle frame organizes the subsections that follow.

##### Reporting coefficients and magnitudes

- **Pick one magnitude convention and apply it consistently across the section.** Default for cross-sectional bank / market regressions: *a one-standard-deviation increase in $X$ is associated with a $Y$-percentage-point change in the outcome, roughly $Z$ percent of the within-group mean*. State the units once at first use and rely on the reader to carry them forward. Switching mid-section between marginal-effect arithmetic, SD-scaled effects, and dollar amounts reads as carelessness.
- **Raw coefficients and standard errors stay in tables; prose carries the magnitude.** Do not paste `0.0301**` or `(0.0085)` into prose. Write "raises entry probability by 0.13 percentage points," not "the coefficient is 0.0301 (significant at the ten percent level)." Reserve raw-coefficient reporting in prose for cases where the coefficient is itself the economic quantity of interest (e.g., an elasticity).
- **Report effects in both raw and scaled units when the raw unit is substantively meaningful.** "Closings reduce annual lending by \$871{,}000, roughly nineteen percent of the baseline mean" is canonical: the raw unit conveys absolute size, the scaled unit conveys relative importance. For probability-of-event outcomes (entry, default, refinance), the within-group mean event rate is the right denominator.
- **Significance language replaces stars in prose.** Use "resolved at the ten / five / one percent level" or "indistinguishable from zero" rather than asterisks. The stars belong in tables.

##### Walking the reader through tables

- **Name Panel and Column when citing a table.** Canonical form: `Table~\ref{tab:foo}, Panel B, Column 3`. The reader should not have to scan a dense panel to find the cited coefficient. Free-form table references are reserved for cases where a single coefficient anchors the discussion and the table has no panels.
- **One table per claim block.** A paragraph that discusses a finding should reference one main table; if it needs to reference a second, the second is a comparison anchor (`Table~\ref{tab:deposit_beta_main}` cited from a later interaction-table discussion), not a parallel finding. Parallel findings get their own paragraph.
- **Walk through columns in the order the argument needs them, not in the order they appear in the table.** If Column 3 is the cleanest specification and Column 1 the unconditional benchmark, lead with Column 3 and circle back to Column 1 to make the contrast. The table's column order is not the section's argument order.

##### Null results

When an additive or otherwise-tested specification returns a null, use this three-beat template:

- **(i) State the null in plain prose.** "The additive coefficient on the cost-side indicator is indistinguishable from zero in every bucket." Do not bury the null in a parenthetical.
- **(ii) State what the null rules out.** "The cost-side gap does not enter the entry decision as a separate inducement." The reader needs to know what the null forecloses, otherwise the null reads as a missing result.
- **(iii) State what the null does not rule out and link forward.** "The conditional reading --- that the edge activates the contestability response rather than entering additively --- is the test in Panel B." A null without a forward link reads as the end of an argument; with a forward link it becomes the setup for the next test.

##### Interaction coefficients

When the headline result is an interaction $A \times B$ (the paper tests a conditional channel rather than an average effect):

- **(i) Translate the interaction into marginal effects.** Report the effect of $A$ when $B = 1$ versus $B = 0$ (or one-SD up versus zero) rather than the raw interaction coefficient. The reader should see two comparable numbers, not a derivative of a derivative.
- **(ii) State what happens to the main effect of $A$.** If the main effect of $A$ loses standalone significance once the interaction enters, say so explicitly and state what that implies for the conditional-channel reading: the headline relationship loads on the subset of units holding the complementary edge, not on the average unit.
- **(iii) Close with the one-sentence comparison.** "The contestability response is concentrated in edge-positive banks; in edge-negative banks it is indistinguishable from zero." This sentence is the substantive content the reader will remember.

##### Robustness, heterogeneity, mechanisms

- **Robustness placement: pick one of three locations and stay with it.** Either (a) sequential columns of the main table with controls / sample restrictions added progressively; (b) a dedicated short subsection at the end of the section, one paragraph per check; or (c) the appendix, referenced by `\ref{tab:...}`. Do not scatter robustness through the main discussion --- it dilutes the headline argument and signals defensiveness.
- **Main result before heterogeneity before mechanism.** Pooled / full-sample first; then heterogeneity by a theoretically motivated dimension; then mechanism tests that interpret the heterogeneity. The exception: when the paper's central claim *is* a heterogeneity statement (e.g., "the channel activates only for banks with a complementary edge"), elevate the heterogeneity to the headline and frame it that way in the opening.
- **Frame heterogeneity as a sharp prediction, not as a fishing expedition.** "If the effect operates through liquidity constraints, we expect a larger response among low-income households" is the canonical phrasing; "we also split the sample by income" is not.

##### Closing synthesis

- **The results section ends with a standalone synthesis paragraph that sits outside any subsection.** 60--120 words. It (a) restates the headline finding as the answer to the puzzle posed in the opening, (b) compares magnitudes across the subsections or buckets to build the reader's confidence, (c) names what the central pattern rules in and rules out. No new results, no new tables, no "future research."
- **A synthesis nested inside the last subsection is invisible to a reader who stopped earlier.** Move it out.

##### Confidence language

- **High-confidence verbs --- "loads on," "activates," "raises," "is concentrated in" --- belong to results that are statistically resolved and robust across columns.** Do not hedge a robust result; doing so reads as defensive.
- **Hedged verbs --- "consistent with," "suggests," "is in line with" --- belong to causal interpretation, to results sensitive to specification, and to mechanism claims the data cannot directly identify.** Pair the verb with the data's reach: "the interaction pattern is consistent with the conditional-edge mechanism, though the design does not directly observe the bank's internal profitability calculus."

##### Style and length

- **Active voice and short declarative sentences.** "The cost-side gap does not enter as a separate inducement" beats "It is found that the cost-side gap does not enter as a separate inducement."
- **No paragraph titles.** No `\paragraph{Main result.}`, no `\textbf{Main result.}`. The topic sentence does the work the heading would have done.
- **Floats stay in `tables_figures.tex`.** The results section is prose only --- no `\begin{table}` or `\begin{figure}`. Reference floats from `tables_figures.tex` via `\ref{}`.
- **Length target:** 1,200--2,000 words for a paper with three to four mechanism subsections. Concise but complete; do not pad.

#### Conclusion
- **One page maximum**. One short restate of the result, then the broadest implication that the design supports. Cochrane (2005): "We're less interested in your plans and excuses than we are in your memoirs."
- **Do not introduce new results or arguments.**
- **Do not repeat the introduction**. The conclusion should feel like a coda, not a remix.
- **No "future research" punch list**. Drop sentences of the form "We leave X for future research," "Future research could explore Y," "This opens several avenues for future work." If a thread is genuinely open, name it in one clause and move on; do not draft a grant proposal here.
- **End with the broadest implication**: why should anyone outside the sub-field care?

#### Appendix
- **Variable definitions table**: every variable used in the paper, its definition, and its source.
- **Robustness tables** that are referenced in the text but too granular for the main body.
- **Sample construction details**, alternative specifications, data cleaning steps.

---

## LaTeX Conventions
- Use `\section{}`, `\subsection{}`, `\subsubsection{}` hierarchy consistently.
- Tables: `\begin{table}[!htbp]` with `\centering`, a `\caption{}` above the tabular, and a `\label{tab:...}` immediately after the caption.
- Figures: `\begin{figure}[!htbp]` with `\centering`, `\includegraphics[width=\textwidth]{...}`, `\caption{}`, `\label{fig:...}`.
- Equations: `\begin{equation}` for referenced equations, `\begin{align}` for multi-line.
- Citations: `\cite{}`, `\citet{}`, `\citep{}` (natbib style).
- Common packages assumed available: `booktabs`, `graphicx`, `amsmath`, `natbib`, `hyperref`, `threeparttable`, `tabularx`, `float`, `caption`, `subcaption`.

---

## Session Notes Log
*This section is updated by Claude Code at the end of each editing session. It records substantive decisions, phrasing patterns, and project-specific conventions discovered during revision so that future sessions can maintain consistency.*

### Session Log Template
```
### Session: [DATE]
**Files edited**: [list]
**Key decisions**:
- [decision 1]
- [decision 2]
**Phrasing patterns adopted**:
- [pattern]
**Variable naming / definitions confirmed**:
- [variable: definition]
**Cross-reference map** (labels created/used):
- [label: what it refers to]
**Open items for next session**:
- [item]
```

### Session: 2026-05-15
**Files edited**: `.claude/commands/skills/write-section.md` (Data block rewritten)
**Key decisions**:
- Dropped the fixed "two subsections" mandate for the data section. Replaced with three default architectures (A: single block, B: by source, C: by content block) and a cross-cutting conventions block that applies to all three.
- Standardized data-section labels: `sec:data:sample`, `sec:data:channels` (or `sec:data:variables`), `sec:data:controls`, `sec:data:desc`. Architecture B may use source-name labels.
- `Descriptive Statistics` subsection, when emitted, is always the last subsection.
- Generalized `||` slot count to equal the number of subsections actually emitted.
**Phrasing patterns adopted**:
- Forward-reference style: "assert the pattern, then cite the evidence" --- claim leads, `\ref{}` appended at end.
- Variable / channel paragraph template: (i) measurement target, (ii) source + unit of variation, (iii) construction details, (iv) optional binary-vs-continuous note.
- Two-sentence opening: primary data product, then enumeration of pieces the question requires.
**Reference papers whose data sections informed the conventions**:
- Greenwald (Y14 securities, 2024) --- single continuous block; formulas deferred; appendix-deferred stats.
- NRS 2026 (branch closure) --- by-source subsections; subsection length proportional to centrality; forward-ref with key fact extracted.
- Begenau et al. (uniform rate, 2025) --- narrative-led table refs; quoted vendor note in footnote for non-obvious mechanics.
**Open items for next session**:
- After the next data-section draft, verify the four-beat variable-paragraph template is actually applied and surface any drift back to wall-of-text paragraphs.
