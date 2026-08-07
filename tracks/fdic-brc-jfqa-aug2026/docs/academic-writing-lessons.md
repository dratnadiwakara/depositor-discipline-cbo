# Academic Writing Lessons

General rules distilled from the August 2026 strip-to-main-story rewrite of the
CECL depositor-discipline paper, applying Cochrane (2005), "Writing Tips for
Ph.D. Students." Written to be reusable for any future empirical finance paper.

## Organization

1. **One central contribution, stated concretely.** Write it in one paragraph
   before anything else. If the abstract could describe five papers, the paper
   has no anchor. Say what you find ("uninsured time deposits fell 0.39pp of
   assets"), not what you look for ("we examine whether depositors respond").

2. **Triangular ("newspaper") structure, not novelistic.** The most important
   result comes first; background and qualifications come after, for the
   readers who keep going. Readers skim; nothing before the main result should
   be something the reader does not need to understand the main result.

3. **Open the introduction with what the paper does.** Not "X remains one of
   the central open questions in banking" (throat-clearing), but "This paper
   provides causal evidence that..." Motivation, policy stakes, and literature
   follow the contribution, never precede it. Three pages is the ceiling.

4. **Sections must be self-contained.** No forward references to later
   sections outside the introduction. If a claim needs support that lives
   later in the paper, either move the support earlier, state the fact inline
   without a pointer, or cut the claim. The reader should never flip back and
   forth. ("Previews and recalls are a sign of poor organization.")

5. **Do not claim results the paper no longer contains.** When robustness
   sections are cut, sweep the abstract, introduction, and conclusion for
   sentences that lean on them ("survives randomization inference",
   "robust to alternative cutoffs"). A claim without a table behind it is
   worse than no claim.

6. **No headline-summary table.** Walk through results one at a time, each
   subsection opening with its estimate. A table that repeats numbers from
   other tables signals the paper doesn't trust its own organization.

7. **Robustness goes to an appendix or out of the paper entirely.** One best
   specification in the text; verify the checks privately, keep them ready for
   referees, and summarize in a sentence only if essential. Cutting them is
   reversible; drowning the main result is not.

8. **Conclusions are short.** One restatement of the finding (abstract, intro,
   and body already said it), limitations if genuine, no speculation, no
   future-research grant application.

## Ordering results

9. **Present results in the order the argument needs, not the order the work
   was done.** Here: level effect on the treated outcome → mirror effect on
   the control outcome → visual (event studies) → tightly controlled
   specification as internal robustness → mechanism tests (price nulls,
   destination of funds) → consequences (profitability) → timing/anticipation.
   The reader should never see a specification before knowing why it matters.

10. **Tables and figures appear in the exact order first mentioned in the
    text.** Verify mechanically: extract the first-mention sequence of
    `\ref{tab:...}`/`\ref{fig:...}` from the section files in input order and
    diff against the float file's `\label` sequence.

## Writing

11. **"I", not "we", on a solo-authored paper.** Reserve "we" for
    reader-and-author. Active voice throughout; hunt passive "is/are" +
    participle constructions.

12. **Present tense, consistently.** "Table 5 reports", "the coefficient is".

13. **No adjectives on your own work.** Not "striking", "novel", "cleanest".
    If the result deserves adjectives, readers will supply them.

14. **Every sentence must say something.** Kill "It should be noted that",
    "Note that", "In other words" (a sign the first wording failed), and
    throat-clearing topic sentences. Clothe naked "this" ("this estimate",
    not "this shows").

15. **Simple short words.** "Use" not "utilize"; "several" not "diverse".
    Avoid jargon a non-specialist referee would stumble on ("re-intermediate",
    unexplained "Herfindahl"): define it or replace it.

16. **State magnitudes economically, with 2–3 significant digits.** Pair every
    coefficient with its economic translation ("0.021pp per quarter — roughly
    8–9 basis points annualized, 9 percent of the sample mean").

## Empirical craft in prose

17. **Describe identification in economic terms.** What mechanism created
    dispersion in the treatment? What is in the error term? Why are they
    uncorrelated? A predetermined-treatment argument ("magnitude fixed by past
    underwriting") beats a battery of robustness tables.

18. **Show who acted on what information, when.** Timing evidence (private
    knowledge moves bank-controlled margins early; public disclosure moves
    depositor-facing margins later) can convert an embarrassing pre-trend into
    the paper's sharpest identification argument. Before deleting an anomaly,
    ask what behavior would generate it.

19. **Report nulls as mechanism fingerprints, not confessions.** "Posted rates
    never moved — including in the stress window" simultaneously rules out a
    competing channel and defuses a confound. But a null result on a variable
    the paper does not need (total uninsured deposits) is better cut than
    explained.

20. **Table and figure notes must be self-contained**: specification, sample,
    fixed effects, clustering, significance convention — enough for a skimming
    reader who never reads the body, and no references to section numbers.
    No number appears in a table that the text never discusses.

21. **Verify data-item claims against the source, not memory.** Reporting
    thresholds are a recurring trap (e.g., Call Report estimated uninsured
    deposits, RCON5597, is reported only by banks ≥ $1B — a proxy built from
    universally reported items is needed below that). Footnote form-type and
    coverage facts once, precisely.

## Revision workflow (process lessons)

22. **Pointed inline comments beat general instructions.** The `@@@ comment @@@`
    convention inside the .tex files pinned every requested change to its
    exact location; each marker is a checklist item, and a final grep for the
    marker proves completion.

23. **Mechanical verification at the end of every revision pass**: compile with
    zero undefined references; grep for banned phrases (cut concepts, "we",
    forward `\ref{sec:`, leftover comment markers); check float order; read
    the rendered PDF pages, not just the log — a clean compile can still show
    a blank figure.

24. **When cutting a section, chase its tentacles**: cross-references in other
    sections, rows in summary-statistics tables, sentences in float notes,
    data-section paragraphs that only served the cut analysis, and intro/
    abstract claims that cited it.
