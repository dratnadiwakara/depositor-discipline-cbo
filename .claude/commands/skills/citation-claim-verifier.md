---
name: citation-claim-verifier
description: >
  Verify every citing sentence in a track's manuscript against the cited papers' full-text
  markdowns in the shared paper repository, and validate the .bib metadata against the source
  documents. Only invoked via the /skills/citation-claim-verifier slash command. Do NOT trigger
  based on intent inference or keywords.
---

# Citation Claim Verifier

You verify that what the manuscript says about each cited paper is what that paper actually says, and that the `.bib` entry describes the document that exists. Every verdict must rest on text located in the source markdown — never on general knowledge of the paper.

## Inputs

- **`$ARGUMENTS`**: `<track-name>` (required) — resolves the manuscript to `tracks/<track>/latex/main.tex` and its `\input{}`-ed section files, and the bibliography to `tracks/<track>/latex/main.bib`. Optionally followed by a space-separated list of cite keys to restrict the check (default: all keys cited in the manuscript).
- **Paper full texts**: markdown conversions in the shared repository, `C:/Users/dimut/OneDrive/github/paper-repo/mds/<slug>.md`.
- **Key mapping**: manuscript keys (`authorYEARword`) rarely match repo slugs (`author-year-keywords`). Resolve each cited key to a slug via, in order: `related-papers/key-map.csv` (written by `/agents/literature-downloader`), fuzzy match on author surname + year + title words against `paper-repo/paper_index.csv`, then `Glob` over `mds/`. Record unresolvable keys as `NO-SOURCE` — do not guess.

## Read/write rules

Read-only for the repository except one report file:
`.claude/cc/citation-claim-verifier/YYYY-MM-DD_<track>.md` (create the directory if needed).
Do not edit the manuscript or the `.bib` — the report lists the fixes; the user (or a follow-up session) applies them.

## Procedure

### 1. Harvest claims

For every `\cite`, `\citep`, `\citet` in the section files (in `main.tex` `\input{}` order), extract the **full sentence** containing the citation (plus the preceding sentence when the citation's claim spans both). One claim record per (sentence, key) pair — a sentence citing three papers yields three records, each verified against its own source.

### 2. Verify claims (parallel subagents)

Group claim records by theme or by source paper (4–8 papers per group) and fan out parallel read-only subagents. Each agent receives the exact claim sentences and md paths, and must return per claim:

- **Verdict**: `CONFIRMED` (supporting text located; quote it with approximate location), `CORRECTED` (the md says something different; state precisely what), `NOT-FOUND` (no support located after searching the full document), or `NO-SOURCE` (no usable md; see Data-quality below).
- **Exact supporting numbers/phrases** for CONFIRMED, and the accurate replacement fact for CORRECTED.
- **Citation metadata as the md itself states it**: full title, authors, date/version, journal or working-paper series and number.

Instruct agents explicitly: verdicts rest on located text only; long files are searched with Grep inside the file; a paraphrase that flips population, direction, mechanism, or audience (e.g., "analysts" when the paper studies equity prices; "ran on banks with X" when the paper shows flight *toward* other banks) is `CORRECTED`, not confirmed.

### 3. Validate .bib metadata

For every checked key, compare the `main.bib` entry against the metadata the agent extracted from the md:

- Title changed between versions (working papers get retitled), year stale, wrong venue (working paper vs published article), author list or affiliations changed.
- **The document wins over the filename and over the existing entry.** A slug year is not evidence; the md's own title block is.
- Note entries whose md is a slide deck or an old vintage: quantitative magnitudes from those sources are not citable; only qualitative claims are.

### 4. Report

Write the report with these sections:

1. **Summary table**: key | verdict counts | bib status | action needed.
2. **CORRECTED and NOT-FOUND claims** (most important, first): the sentence as written, what the source actually says (with quoted support), and a suggested rewrite. A claim that cannot be supported is to be **cut or rewritten, never softened** — hedging an unsupported claim still misattributes it.
3. **Bib fixes**: entry-by-entry field corrections.
4. **Data-quality flags**: image-only mds, slide decks, stale vintages, unresolvable keys. For `NO-SOURCE` keys the recommendation is: verify externally before submission or drop the citation — a citation nobody can check is a liability (this is how `flannery2019market` was cut from the depositor-discipline paper).
5. **Confirmed claims**: one line each (key, location, supporting quote fragment) for the record.

## Standards

- Precision beats coverage: "26% per one-standard-deviation increase in transparency" and "26% more sensitive at transparent banks" are different claims; flag the difference.
- Keep the paper's own phrasing available: when a manuscript sentence compresses a nuanced finding, quote the source's phrasing so the user can choose the compression level.
- Distinguish what the authors state from what their design implies. "The design is cross-sectional correlation" may be an accurate description of a specification without being a caveat the authors wrote; report it as your inference, labeled as such.
- Never mark CONFIRMED from memory of the paper. If the md lacks the text, the verdict is NOT-FOUND even if you believe the claim is true.

## When to run

- After integrating a literature review into a manuscript.
- Before submission (alongside `/skills/latex-preflight-check` and `/skills/bib-validator`).
- After any revision round that adds or rewrites citing sentences.
