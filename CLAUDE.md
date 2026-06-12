# Depositor Discipline in Community Banking — Project Context

**Paper**: Depositor Discipline in Community Banking: Evidence from the CECL Information Shock
**Slug**: depositor-discipline-cbo
**Description**: Causal evidence that uninsured depositors discipline community banks in response to mandatory credit-risk disclosures (CECL Day-One retained-earnings adjustments), using a difference-in-differences design with staggered adoption dates (primarily 2023Q1).

**Working style**: minimum code that answers the question; surgical edits to existing scripts; state assumptions before coding; verify before moving on.

## Project Layout

Track-based layout (ai-vault convention). Shared assets at root; each analytical attempt isolated in `tracks/<descriptor>-<monthyear>/`.

```
data/raw/                                 ← shared raw data (never modified)
data/constructed/                         ← shared constructed datasets
code/_common.R                            ← shared libraries, paths, ggplot/fixest globals
code/sample-construction/                 ← shared sample-build .R scripts
code/result-generation/                   ← (legacy; new work in tracks)
code/archives/                            ← old shared scripts
tracks/jmcb-june2026/                     ← current active track (JMCB version)
    code/sample-construction/             ← track-local sample scripts
    code/result-generation/               ← track-local analysis .R/.qmd
    code/archives/                        ← retired track scripts
    data/                                 ← track-local intermediates
    latex/main.tex                        ← master LaTeX
    latex/main.bib                        ← BibTeX (was depositor-discipline-references.bib)
    latex/figures/                        ← .png outputs
    latex/tables/                         ← .tex table fragments
    latex/tables_figures.tex              ← aggregator \input'd after \bibliography
    latex/sections/<name>/<name>_current.tex   ← live section text
    latex/sections/<name>/archive/        ← old dated/_v* variants
    latex/build/                          ← pdflatex output (gitignored)
docs/slides/                              ← presentation files
docs/memos/                               ← revision plans, referee responses, todo
related-papers/                           ← downloaded PDFs (gitignored)
correspondence/                           ← agent-generated reports and reviews
scripts/                                  ← new-project initialization scripts
```

**Skill invocation:** Skills that target a paper (latex-compile, write-section, snapshot) take track name as first arg, e.g. `/skills/latex-compile jmcb-june2026`.

**Section folder mapping (sections folded into `results/` per ai-vault template):**
- `desc-stats/` → `tracks/<t>/latex/sections/results/desc_stats_current.tex`
- `empirical-results/` → `tracks/<t>/latex/sections/results/empirical_results_current.tex`
- `inst_bg/` → `institutional-background/inst_bg_current.tex`
- `data-section/` → `data/data_current.tex`

## Paper-Specific Context

### Identification Strategy
Difference-in-differences exploiting the mandatory CECL (Current Expected Credit Loss, ASU 2016-13) Day-One retained-earnings adjustment as a predetermined information shock. Community banks adopted in 2023Q1 (large SEC filers adopted in 2020Q1 and are used only for signal-validation). Treatment intensity is the CECL Day-One charge scaled by pre-adoption equity (`CECL Adj`, continuous) or a binary `High CECL` indicator (above-median adjustment). Identifying assumption: the size of the adjustment was set by prior lending decisions and is uncorrelated with concurrent deposit dynamics. Bank fixed effects absorb time-invariant heterogeneity; calendar-quarter fixed effects absorb aggregate macro shocks (including the 2023 banking stress and the Fed tightening cycle). Event-study pre-trends are used to test parallel trends. A triple-difference specification further confirms a within-bank composition shift (uninsured vs. insured time deposits) rather than a uniform funding retreat.

### Key Variables

**Treatment:**
- `CECL Adj` — Day-One CECL retained-earnings adjustment scaled by pre-adoption equity (continuous; from Schedule RI-A)
- `High CECL` — binary indicator for above-median `CECL Adj`

**Outcomes (all scaled by contemporaneous total assets):**
- `Uninsured time deposits / assets` — primary deposit outcome; from Schedule RC-E
- `Insured time deposits / assets` — control deposit outcome; from Schedule RC-E
- `Interest expense / assets` — quarterly funding cost
- `Net interest margin` — quarterly net interest income / average assets
- `Return on assets` — quarterly net income / average assets

**Controls (lagged one quarter):**
- Log total assets
- Equity-to-assets ratio
- Interest expense-to-assets (excluded from interest expense/NIM/ROA regressions)

**Heterogeneity:**
- `Sophisticated` — deposit-weighted share of bank branches in ZIP codes with above-median bachelor's degree share AND above-median investment-income filing share (constructed from 2022 FDIC SOD, ACS, IRS SOI); `High Sophistication` = top-quartile banks

### Sample
- **Unit of observation:** Bank-quarter
- **Time period:** 2016Q1–2025Q4
- **Main sample:** Federally insured commercial banks and savings institutions with total assets < $10 billion as of 2022Q4 that report a non-missing CECL Day-One adjustment in 2022Q3–2023Q4 (community-bank rollout cohort)
- **Signal-validation sample:** Large publicly traded bank holding companies that adopted CECL in 2020Q1 (SEC filer cohort); used only for equity market cap and CDS spread event studies, not for main deposit tests
- **Exclusions:** Large SEC-filing institutions that adopted in 2020Q1; banks with no observable Day-One adjustment in the eligible window

### Data Sources
- **FFIEC Call Reports (FFIEC 041/051)** — quarterly balance sheet, income statement, deposit breakdowns by insurance status, and CECL Day-One adjustment (Schedule RI-A); `data/raw/` call report files
- **FDIC Summary of Deposits (SOD) 2022** — branch-level deposit balances as of June 30, 2022; used for depositor sophistication index; `data/raw/`
- **ACS 2022 (5-year ZIP-code estimates)** — bachelor's degree share by ZIP code; `data/raw/`
- **IRS Statistics of Income (SOI) ZIP-code tabulations** — investment-income filer share by ZIP code; `data/raw/`
- **FR Y-9C** — consolidated holding-company financial statements; used for large-bank validation sample; `data/raw/`
- **CRSP** — monthly equity market capitalization for large bank holding companies; linked via CRSP–FRB crosswalk; `data/raw/`
- **Bloomberg** — monthly five-year CDS spreads for large bank holding companies; `data/raw/`

---

## R Coding Standards

### Core Principles

- **Never render** `.qmd` or `.Rmd` files during script execution — run regressions and output tables/figures by sourcing `.R` scripts or running Quarto CLI explicitly.
- Place all `library()` calls at the very top of each script.
- Reset the environment with `rm(list = ls())` as the first line of every standalone script.
- Use **relative paths** exclusively. In Quarto/R Markdown documents, construct paths with `here::here()`. In plain `.R` scripts, use paths relative to the project root (e.g., `"data/raw/file.csv"`).
- Append date suffixes (`YYYYMMDD`) to new script filenames (e.g., `01_build_panel_20260406.R`).
- **State assumptions before writing a new regression or sample filter.** In chat, declare the unit of observation, sample window, treatment variable, outcome, fixed effects, and the *expected sign* of the key coefficient. If any of those are not pinned by the existing CLAUDE.md context, stop and ask. This is the regression-side analogue of the existing `/skills/write-section` "stop and ask rather than fabricate" rule.

### Project Organization

| Folder | Contents |
|--------|----------|
| `code/sample-construction/` | Plain `.R` scripts that read from `data/raw/` and write to `data/constructed/` |
| `code/result-generation/` | `.qmd` documents with `type: source` that produce tables and figures |
| `code/common.R` | Shared libraries, paths, ggplot2 theme, fixest globals |

### Surgical Edits to Existing Scripts

When editing an existing `.R` or `.qmd` file under `code/`:

- Touch only the lines required by the request. Do not re-style, re-order, or "tidy" unrelated specifications, even if they violate current conventions.
- Do not delete pre-existing alternative specifications, commented-out blocks, or archived chunks unless the user asks. Those are often referee-response material in waiting.
- If a clean-up looks tempting and unavoidable, raise it in chat first; do not bundle it into the edit.
- When adding a new regression to a `result-generation/` file, add a new `feols()` line; do not refactor the surrounding spec list to share more macros than `..fc` / `..fe` already provide.

### Data Management

- Raw data lives in `data/raw/` and is **never modified**.
- Processed/constructed datasets go to `data/constructed/`.
- Define `data_path <- "data/constructed/"` near the top of each analysis script.
- Generate timestamped output filenames: `format(Sys.time(), "%Y%m%d_%H%M%S")`.
- Include a comment in each script indicating which upstream script generated any imported dataset.
- **Every sample-construction script ends with a `cat()` diagnostic block.** Print N rows, N unique units, the time-span coverage, count of NA in each key variable, and the 1st/50th/99th percentiles of the treatment and outcome. The user reads this block before any downstream regression script consumes the dataset. This is the verify-before-moving-on rule for data prep — the standing analogue of `/skills/sanity-check` for newly built samples.

### Figure & Table Export

- Figures → `latex/figures/` as timestamped `.png` files with `bg = "white"`.
- Tables → `latex/tables/` as `.tex` files with matching timestamps.
- Control exports with logical flags at the top of each script:
  ```r
  save_figures <- TRUE
  save_tables  <- TRUE
  ```

### Visualization Standards

Apply `theme_custom()` (defined in `code/common.R`) to all ggplot2 plots. Use these brand colors:

| Name | Hex |
|------|-----|
| Primary blue | `"#012169"` |
| Primary gold | `"#f2a900"` |
| Accent gray | `"#525252"` |
| Positive green | `"#15803d"` |
| Negative red | `"#b91c1c"` |

### Econometric Modeling

- Use the `fixest` package for all panel regressions.
- Define global formula macros with `setFixest_fml()` and global output options with `setFixest_etable()` **once** in `code/common.R`. Reuse them across analysis files — do not redefine per script.
- Store model results in named lists (e.g., `r <- list(); r$baseline <- feols(...)`).

### Quarto Documents

- Use `type: source` in the Quarto YAML front matter so the document runs as a script without rendering to HTML/PDF.
- Suppress warnings and messages by default in chunk options.
- Do not knit/render `.qmd` files to check results — source them or run them via `quarto run`.

---

## Skills & Agents

Skills and agents live in `.claude/commands/` (symlinked from ai-vault in project repositories).
Invoke via slash commands in Claude Code:

**Skills:**
- `/skills/latex-compile` — compile LaTeX to PDF (pdflatex, no latexmk)
- `/skills/write-section` — write a paper section as a LaTeX file
- `/skills/latex-preflight-check` — pre-submission QA checklist
- `/skills/latex-figure-inserter` — insert a figure environment into a .tex file
- `/skills/latex-table-inserter` — insert a table environment into a .tex file
- `/skills/academic-paragraph-inserter` — insert a prose paragraph at a line number
- `/skills/academic-introduction-evaluator` — evaluate introduction against JF/RFS standards
- `/skills/table-figure-descriptions` — generate table/figure notes (Journal of Finance style)
- `/skills/figure-table-crosscheck` — audit in-text numbers against table values
- `/skills/bib-validator` — validate BibTeX entries against Google Scholar
- `/skills/sanity-check` — generate R data sanity-check script and report

**Agents:**
- `/agents/finance-paper-reviewer` — full pre-submission review (6 sub-agents in parallel)
- `/agents/literature-reviewer` — search, download PDFs, build .bib, write literature review
- `/agents/ai-detector` — detect LLM fingerprints and robotic prose
- `/agents/harsh-editor` — adversarial editorial review of paper vs. code
- `/agents/professor-robustness-check` — quick robustness replication from raw data
- `/agents/referee2-audit` — systematic 5-audit replication and code review
- `/agents/referee-response-evaluator` — evaluate and improve referee response letters
- `/agents/academic-paper-writer` — draft paper sections with IMRAD structure

---

## LaTeX Conventions

- Output directory for pdflatex: `latex/build/`
- Figures referenced as `\includegraphics{figures/filename}` (graphicspath set in `latex/main.tex`)
- Tables `\input{}`-ed from `latex/tables/` or inline in section files
- Section files: `latex/sections/<section>/<section>_current.tex` (`\input{}`-ed from `main.tex`)
- Never edit `latex/build/` contents directly
- Compile sequence: `pdflatex → bibtex → pdflatex → pdflatex` (all run from `latex/` directory)
