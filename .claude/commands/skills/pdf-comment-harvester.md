---
name: pdf-comment-harvester
description: >
  Extract the author's sticky-note annotations from a compiled PDF (typically the track's
  build/main.pdf) into a numbered markdown checklist with page numbers and anchored text,
  before any recompile clobbers them. Only invoked via the /skills/pdf-comment-harvester
  slash command. Do NOT trigger based on intent inference or keywords.
---

# PDF Comment Harvester

The author's revision workflow is to read the compiled paper and leave sticky-note comments in the PDF itself. This skill extracts those annotations into a durable, numbered checklist that a revision session works through.

## Critical timing rule

`build/` is clobbered by every recompile. **Harvest before running any LaTeX compile** in the same session. If the user asks for a revision round and a compile, the order is always: harvest → edit → compile.

## Inputs

- **`$ARGUMENTS`**: `<track-name>` (required) — default PDF is `tracks/<track>/latex/build/main.pdf`. An explicit `.pdf` path may follow to override.

## Extraction method (use exactly this; the alternatives fail)

Use **pypdf**, iterating page objects. Regex over the raw PDF stream misses page numbers because `/Pages` trees nest kids arrays.

```python
# -*- coding: utf-8 -*-
from pypdf import PdfReader

reader = PdfReader(PDF_PATH)
comments = []
for pno, page in enumerate(reader.pages, start=1):
    annots = page.get("/Annots") or []
    for a in annots:
        obj = a.get_object()
        subtype = obj.get("/Subtype")
        if subtype in ("/Text", "/Highlight", "/FreeText", "/Squiggly", "/Underline", "/StrikeOut"):
            comments.append({
                "page": pno,
                "type": str(subtype),
                "text": str(obj.get("/Contents", "")),
                "rect": [float(x) for x in (obj.get("/Rect") or [])],
            })
```

Notes:
- Run with `python -X utf8` on Windows (annotation text triggers cp1252 `UnicodeEncodeError` otherwise).
- `/Text` is the sticky note; markup subtypes (`/Highlight` etc.) may carry `/Contents` too — include any with non-empty text.
- Sort by (page, then vertical position: descending `rect[3]`) so the checklist follows reading order.
- Skip annotations with empty `/Contents` (bare highlights with no note), but count them in the summary.

## Anchoring each comment to the text

For each comment, identify the passage it refers to:

1. Extract the page's text (`page.extract_text()`), and use the annotation `Rect` position (top-of-page vs bottom) plus any quoted words inside the comment to locate the nearest sentence.
2. Grep the located sentence fragment back to its source `.tex` file under `tracks/<track>/latex/sections/` and record `file:line`.
3. If the anchor is ambiguous, record the two best candidates rather than guessing silently.

## Output

Write `tracks/<track>/docs/memos/pdf-comments_YYYYMMDD.md` (create `docs/memos/` if absent):

```markdown
# PDF Comments — <track> — YYYY-MM-DD

Source: build/main.pdf (harvested before recompile; N sticky notes, M markup annotations)

| # | Page | Comment (verbatim) | Anchor (pdf text) | Source file:line | Status |
|---|------|--------------------|-------------------|------------------|--------|
| 1 | 3 | "no results in captions" | caption of Table 2 | tables_figures.tex:41 | open |
| 2 | 5 | "this hurts my case, remove" | aggregate-$ paragraph | sections/results/empirical_results_current.tex:118 | open |
```

- Comments **verbatim** — never paraphrase the author's note.
- `Status` column starts as `open`; the revision session updates rows to `done`/`skipped (reason)` as comments are addressed, making the file the round's checklist and record.

## Then

Report the count and the checklist path, and remind: address comments via surgical edits, recompile only after harvesting is confirmed complete, and re-run the harvest on the next annotated PDF (each round gets a new dated file).

Also check the section `.tex` files for inline `@@@ ... @@@` comment markers (the author's other annotation channel) and append any found to the same checklist table with `Page = tex`.
