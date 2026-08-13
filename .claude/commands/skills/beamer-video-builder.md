---
name: beamer-video-builder
description: >
  Build a narrated MP4 presentation video from a Beamer deck: scaffold tracks/<track>/slides/,
  write main.tex and a blockquote narration script, compile with pdflatex, then run the
  parse -> edge-tts -> pdftoppm -> ffmpeg -> concat pipeline and verify the result. Only invoked
  via the /skills/beamer-video-builder slash command. Do NOT trigger based on intent inference
  or keywords.
---

# Agent: Beamer Video Builder

## Role

You produce a finished, narrated MP4 of a talk from a Beamer deck. One PDF page becomes one
still-image clip with its own synthesized narration; the clips are concatenated. There is no video
editor in the loop — the deck and the narration markdown are the only source files, and both are
re-runnable.

You do all five of: write the deck, write the narration, write the build script, run it, and verify
it. Do not hand a half-built pipeline back to the user.

## Input

- **`$ARGUMENTS`**: `<track-name> [<label>]` (space-separated).
  - `<track-name>` (required) — folder under `tracks/`, e.g. `fdic-conference-september2026`.
  - `<label>` (optional) — short topic slug used in the deck title and in your report only, never in
    filenames.
- If `<track-name>` is empty, **error out** and ask for one.
- If `tracks/<track>/slides/main.tex` already exists, do **not** overwrite it — treat the invocation
  as an incremental rebuild and jump to Step 3.

## Path resolution

From the repo root (the directory containing `tracks/`):

| Name | Path |
|------|------|
| `<slides>` | `tracks/<track>/slides` |
| `<deck>` | `<slides>/main.tex` |
| `<pdf>` | `<slides>/build/main.pdf` |
| `<script>` | `<slides>/presentation_script_<YYYYMMDD>.md` |
| `<builder>` | `<slides>/build_video_<YYYYMMDD>.py` |
| `<work>` | `<slides>/.video_<YYYYMMDD>` (scratch; never committed) |
| `<out>` | `<slides>/presentation_video_<YYYYMMDD>.mp4` (see **Output** for relocating it) |

`<YYYYMMDD>` is today's date from `date +%Y%m%d`. Every artifact is date-versioned so a re-cut on a
later day never clobbers an approved video.

## Step 0 — Preflight

```bash
date +%Y%m%d
pdflatex --version | head -1
which pdftoppm
source C:/envs/.basic_venv/Scripts/activate && python -c "import edge_tts, imageio_ffmpeg, mutagen; print('deps ok')"
```

- `pdftoppm` is poppler; on Windows it ships with MiKTeX
  (`~/AppData/Local/Programs/MiKTeX/miktex/bin/x64/`). If it is missing, stop and tell the user — do
  not silently substitute another renderer.
- `edge-tts` calls Microsoft's public endpoint: **no API key, but internet is required** and it
  rate-limits. The retry/backoff loop in the build script is not optional.
- `mutagen` is often missing from a fresh venv: `pip install mutagen`.
- Always activate `C:/envs/.basic_venv` before any `python` call (project convention in CLAUDE.md).

## Step 1 — Scaffold

```bash
mkdir -p tracks/<track>/slides/figures tracks/<track>/slides/build
```

Slide-specific figures go in `<slides>/figures/`; paper figures are reached through
`\graphicspath` without copying.

## Step 2 — Write `main.tex`

Write `<deck>` from this template. Everything marked `% EDIT` is per-talk; the preamble is house
style. Pull the palette hex codes from the project's own `code/common.R` so slides match the paper's
figures.

```latex
% =============================================================================
% <VENUE> — <N>-minute presentation                                     % EDIT
% <PAPER TITLE>                                                         % EDIT
% Slide figures: slides/figures/   Paper figures: ../latex/figures/
% Compile: pdflatex -output-directory=build main.tex   (run TWICE, from slides/)
% =============================================================================
\documentclass[aspectratio=169,10pt]{beamer}

\usetheme[progressbar=frametitle,block=fill]{metropolis}
\usepackage{tikz}
\usetikzlibrary{arrows.meta,positioning,shapes.misc}
\usepackage{booktabs}
\usepackage{colortbl}

\graphicspath{{figures/}{../latex/figures/}}

% ---- palette (keep in sync with code/common.R) ------------------------------
\definecolor{pblue}{HTML}{012169}                                     % EDIT
\definecolor{pgold}{HTML}{F2A900}                                     % EDIT
\definecolor{pgolddark}{HTML}{8A6100}
\definecolor{pred}{HTML}{B91C1C}
\definecolor{pgreen}{HTML}{15803D}
\definecolor{pgray}{HTML}{525252}

\setbeamercolor{normal text}{fg=black!85,bg=white}
\setbeamercolor{frametitle}{fg=white,bg=pblue}
\setbeamercolor{progress bar}{fg=pgold,bg=pgray!30}
\setbeamercolor{alerted text}{fg=pred}
\setbeamercolor{example text}{fg=pgolddark}
\setbeamercolor{title separator}{fg=pgold}
\setbeamercolor{itemize item}{fg=pblue}
\setbeamercolor{itemize subitem}{fg=pblue}
\setbeamercolor{button}{bg=pgray!20,fg=pblue}
\setbeamercolor{block title}{bg=pblue,fg=white}
\setbeamercolor{block body}{bg=pblue!7,fg=black!85}

\setbeamerfont{frametitle}{size=\large,series=\bfseries}
\setbeamertemplate{itemize item}{\textcolor{pblue}{$\blacktriangleright$}}
\setbeamertemplate{itemize subitem}{\textcolor{pgray}{--}}

% grey secondary caption line under the claim title
\newcommand{\spec}[1]{{\vspace{-2mm}\textcolor{pgray}{\footnotesize #1}\par\vspace{1mm}}}
% bottom takeaway bar
\newcommand{\takeaway}[1]{%
  \vfill
  {\centering\colorbox{pblue!8}{\parbox{0.94\textwidth}{\centering
    \textcolor{pblue}{$\Rightarrow$ \textbf{#1}}}}\par}}
% small grey inline citation
\newcommand{\gcite}[1]{{\scriptsize\textcolor{pgray}{#1}}}
% hyperlink pill to a backup slide (and back)
\newcommand{\pill}[2]{\hyperlink{#1}{\beamergotobutton{#2}}}

\title{<TITLE>}                                                       % EDIT
\subtitle{<SUBTITLE>}                                                 % EDIT
\author{<AUTHOR>\\{\small <AFFILIATION>}}                             % EDIT
\date{{\small <VENUE>}\\[2mm] {\tiny <DISCLAIMER>}}                   % EDIT

\begin{document}
\maketitle

% ---- claim-title frame: the title states the finding ------------------------
\begin{frame}{<Frame title is the claim, not the topic>}              % EDIT
  \spec{<one grey line: sample, specification, units>}
  \begin{itemize}
    \item <point> \gcite{Author--Author '91}
    \item <point>
  \end{itemize}
  \takeaway{<the one sentence you want remembered>}
\end{frame}

% ---- figure frame -----------------------------------------------------------
\begin{frame}[label=fresult]{<claim>}
  \spec{<estimator, FE, CI level>}
  \centering
  \includegraphics[width=0.9\linewidth,height=0.62\textheight,keepaspectratio]{fig_x.png}
  \takeaway{<claim>}
\end{frame}

% ---- backup slides: after \appendix, reached only via \pill -----------------
\appendix
\begin{frame}[label=appdetail]{Backup: <topic>}
  \spec{<spec line>}
  \begin{itemize}\item <detail>\end{itemize}
  \hfill \pill{fresult}{back}
\end{frame}

\end{document}
```

### Page-count discipline (this is what breaks builds)

`N_PAGES` counts **PDF pages**, not `\begin{frame}` blocks. Therefore:

- Give every `\item` the same overlay spec or none. `\item<1->` throughout renders **one** page;
  a stray `\item<2->` renders an extra page and silently desynchronizes every downstream chunk.
- Express a deliberate build as **two duplicated frames** (same title, second adds the extra
  element), not `\only`/`\onslide`. Two frames map cleanly onto one `**[ADVANCE]**` cue.
- Put all backup material after `\appendix`. Backup pages are **excluded** from `N_PAGES`.

### Overflow check (do this before writing narration)

Beamer does not error on overfull frames; content simply runs off the bottom of the slide and into
the video. Render a sample and look at it:

```bash
cd tracks/<track>/slides && mkdir -p .check && for p in 3 7 12; do pdftoppm -f $p -l $p -png -scale-to-x 1200 -scale-to-y -1 build/main.pdf .check/p; done
```

Read the PNGs. Check every frame carrying a TikZ diagram, a table over ~6 rows, or a `\takeaway`
under a figure. Fixes, in order of preference: drop the body to `\footnotesize`/`\scriptsize`,
shrink `text width` and `inner sep` on TikZ nodes, cut words. Delete `.check/` when done.

## Step 3 — Compile and read the page count

```bash
cd tracks/<track>/slides && pdflatex -interaction=nonstopmode -output-directory=build main.tex && pdflatex -interaction=nonstopmode -output-directory=build main.tex
```

Twice — the second pass resolves `\pill` hyperlinks and the progress bar. Then:

```bash
pdfinfo tracks/<track>/slides/build/main.pdf | grep Pages
```

Set **`N_PAGES` = total pages − backup pages**. Record both numbers. If `pdflatex` fails, fall back
to `/skills/latex-compile` on `tracks/<track>/slides/main.tex`.

## Step 4 — Write the narration script

Write `<script>`. The parser has a strict grammar; obey it exactly.

| Element | Rule |
|---|---|
| Section heading | `## Slide N — Title [m:ss]` or `## Slides N–M — Title [m:ss]`. Regex is `^##\s+Slides?\s+[\d–—-]+\s*[—-]`. **A colon instead of a dash does not match**, and the section is silently swallowed into the previous slide. |
| Spoken text | **Only** lines beginning with `>`. Everything else is a director's note and is never spoken. |
| Pause | A bare `>` line between blockquote paragraphs. Single newlines inside a paragraph are treated as wrap artifacts and joined. |
| Multi-frame build | `> **[ADVANCE]**` on its own line splits one `## Slides N–M` section into one chunk per PDF page. |
| Transition | `*Transition: "spoken words"*` — **only the double-quoted span is spoken**, appended to the section's last chunk. `*Transition: none — go straight in.*` is correctly silent. An unquoted transition is dropped. |
| Frame tag | `[Frame 1 — blue series only]` inside a blockquote is stripped before TTS; use it to stay oriented. |
| Appendix cut | Everything from a line containing `# Anticipated questions` to EOF is Q&A prep and is **not** narrated. This heading is mandatory if you write Q&A prep at all. |

`clean_spoken` handles only `**`/`*`, `−` → "minus", `×` → "times", `~123` → "about 123".
**Everything else must already be speakable.** Write "minus zero point three nine", "ninety-six
percent", "G S E", "R squared" — never LaTeX, never `$-0.39$`, never a bare symbol. Fix
mispronunciations by respelling phonetically in the narration (`CECL` → "seh-cull"); never add a
pronunciation dictionary to the build script.

### Pacing

Calibrated against `en-US-AndrewNeural` at `+0%`: **155 spoken words per minute**, plus **2.0 s of
padding per page** (0.5 s lead-in + 1.5 s trail).

```
predicted runtime = words / 155 minutes + 2 s x N_PAGES
```

The `--stage parse` output prints this for you. **Two measured builds:** a prose-heavy conference
talk landed at 155 wpm exactly; a numeric briefing deck (many spelled-out figures, dates, and
blockquote pauses) landed at **146 wpm** and ran 6% longer than predicted. For a deck thick with
numbers, plan on 145 and treat the printed estimate as a floor. Budget ~155 words ≈ 60 s for a one-minute slide,
~95 words ≈ 40 s for a brisk briefing deck. **Never exceed ~230 words on one page** — that is 90 s
on a still image. Title slides run ~40 words. Check the prediction against the user's target slot
*before* spending TTS calls, and trim the narration rather than the slides.

### Skeleton

```markdown
# Presentation Script — <TITLE>
**<VENUE> · <N>-minute slot**

Keyed to `slides/build/main.pdf` (<N_PAGES> talk pages + <K> backup). Bracketed times are
*cumulative targets*; the build script ignores them. Only blockquote lines are spoken.

---

## Slide 1 — Title [0:15]

> Thank you. <one or two sentences: the question and the answer>

*Transition: none — go straight in.*

---

## Slide 2 — <claim-shaped title> [1:30]

> <first beat>
>
> <second beat, after a pause>

*Transition: "<the sentence that hands off to the next slide>"*

---

## Slides 3–4 — <build, two frames> [2:40]
**Protected slide. Slow down.**

> [Frame 1 — first series only] <narration for page 3>
>
> **[ADVANCE]**
>
> [Frame 2 — second series added] <narration for page 4>

*Transition: "<handoff>"*

---

# Anticipated questions

**Q: <question>**
One breath: <the answer you would actually say>. Pill *detail* on slide <n>.
```

Write exactly `N_PAGES` chunks: one `## Slide` section per page, plus one extra chunk per
`**[ADVANCE]**`.

## Step 5 — Write `build_video_<YYYYMMDD>.py`

Write `<builder>` verbatim from this template, editing only the four constants in the
`PER-BUILD EDITS` block.

```python
"""Build a narrated MP4 from a Beamer deck + a blockquote narration script.

Pipeline (idempotent; every stage caches, and every cache self-invalidates):
  1. parse  script markdown           -> N narration chunks, one per PDF page
  2. tts    each chunk (edge-tts)     -> .video_<DATE>/audio/slide_NN.mp3
  3. png    pdftoppm build/main.pdf   -> .video_<DATE>/png/slide_NN.png @1920x1080
  4. mp4    ffmpeg still + narration  -> .video_<DATE>/clips/slide_NN.mp4
  5. concat                           -> the final mp4

Cache invalidation:
  - each mp3 carries a slide_NN.txt sidecar with the exact narration text; a
    slide is re-synthesized iff its text changed, and its clip is dropped then.
  - the png stage compares PNG mtimes against build/main.pdf and re-renders the
    whole deck when the PDF is newer, dropping every clip.

Usage (activate C:/envs/.basic_venv first):
  python build_video_<DATE>.py                  # full build
  python build_video_<DATE>.py --stage parse    # dry run: print the chunks
  python build_video_<DATE>.py --stage tts|png|mp4|concat
"""

from __future__ import annotations

import argparse
import asyncio
import re
import subprocess
import sys
from pathlib import Path

import edge_tts
import imageio_ffmpeg
from mutagen.mp3 import MP3

HERE = Path(__file__).parent

# ==== PER-BUILD EDITS ========================================================
DATE    = "YYYYMMDD"                                       # (1) build date
N_PAGES = 22                                               # (2) TALK pages only
WORK    = HERE / f".video_{DATE}"                          # (3) scratch dir
OUTPUT  = HERE / f"presentation_video_{DATE}.mp4"          # (4) final mp4
# =============================================================================

SCRIPT    = HERE / f"presentation_script_{DATE}.md"
PDF       = HERE / "build" / "main.pdf"
AUDIO_DIR = WORK / "audio"
PNG_DIR   = WORK / "png"
CLIP_DIR  = WORK / "clips"

VOICE = "en-US-AndrewNeural"
RATE = "+0%"
IMG_W, IMG_H = 1920, 1080
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

LEAD_IN_SEC = 0.5
TRAIL_SEC = 1.5

# Everything from this heading to EOF is Q&A prep, not narration.
APPENDIX_HEADING = "# Anticipated questions"

SECTION_RE = re.compile(r"^##\s+Slides?\s+[\d–—-]+\s*[—-]", re.MULTILINE)
TRANSITION_RE = re.compile(r"\*Transition:\s*(.*?)\*", re.DOTALL)
QUOTED_RE = re.compile(r"[\"“](.*?)[\"”]", re.DOTALL)
FRAME_TAG_RE = re.compile(r"\[Frame\s+\d+[^\]]*\]")
ADVANCE_RE = re.compile(r"^>?\s*\*{0,2}\[ADVANCE\]\*{0,2}\s*$", re.MULTILINE)


def clean_spoken(text: str) -> str:
    """Markdown + symbols -> plain speakable text."""
    text = FRAME_TAG_RE.sub("", text)
    text = text.replace("**", "").replace("*", "")
    text = text.replace("−", "minus ")      # U+2212 minus sign
    text = text.replace("×", " times ")
    text = re.sub(r"(?<=\s)~(?=\d)", "about ", text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{2,}", "\n\n", text)
    # single newlines are wrap artifacts, not pauses -- join them
    text = re.sub(r"(?<!\n)\n(?!\n)", " ", text)
    return text.strip()


def parse_sections(path: Path) -> list[str]:
    """Return one narration string per PDF page, in page order."""
    raw = path.read_text(encoding="utf-8")
    cut = raw.find(APPENDIX_HEADING)
    if cut != -1:
        raw = raw[:cut]

    matches = list(SECTION_RE.finditer(raw))
    page_texts: list[str] = []
    for i, m in enumerate(matches):
        start = m.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(raw)
        section = raw[start:end]

        # transition sentence: speak the quoted part at the end of the section
        trans_speech = ""
        tm = TRANSITION_RE.search(section)
        if tm:
            qm = QUOTED_RE.search(tm.group(1))
            if qm:
                trans_speech = qm.group(1).strip()
            section = section[: tm.start()] + section[tm.end():]

        # narration = blockquote lines only
        quote_lines = [
            ln.lstrip()[1:].lstrip() if ln.lstrip().startswith(">") else None
            for ln in section.split("\n")
        ]
        body = "\n".join(ln if ln is not None else "\x00" for ln in quote_lines)
        body = re.sub(r"\x00+", "\n\n", body)

        # split multi-frame sections at [ADVANCE]
        parts = ADVANCE_RE.split(body)
        parts = [clean_spoken(p) for p in parts]
        parts = [p for p in parts if p]
        if not parts:
            continue
        if trans_speech:
            parts[-1] = parts[-1] + " " + clean_spoken(trans_speech)
        page_texts.extend(parts)
    return page_texts


async def tts_one(text: str, out_path: Path, attempts: int = 20) -> None:
    delay = 3.0
    last = None
    for k in range(attempts):
        try:
            communicate = edge_tts.Communicate(text, VOICE, rate=RATE)
            await communicate.save(str(out_path))
            if out_path.exists() and out_path.stat().st_size > 0:
                return
        except Exception as e:
            last = e
            if k < 3 or k % 5 == 0:
                print(f"    retry {k+1}/{attempts}: {type(e).__name__}", flush=True)
        if out_path.exists() and out_path.stat().st_size == 0:
            try:
                out_path.unlink()
            except OSError:
                pass
        await asyncio.sleep(delay)
        delay = min(delay * 1.5, 45.0)
    raise RuntimeError(f"tts failed after {attempts} attempts: {last}")


async def run_tts(page_texts: list[str]) -> None:
    """Re-TTS only pages whose narration text changed (sidecar .txt is the key)."""
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    CLIP_DIR.mkdir(parents=True, exist_ok=True)
    for i, text in enumerate(page_texts, start=1):
        out = AUDIO_DIR / f"slide_{i:02d}.mp3"
        sidecar = AUDIO_DIR / f"slide_{i:02d}.txt"
        fresh = (out.exists() and out.stat().st_size > 0 and sidecar.exists()
                 and sidecar.read_text(encoding="utf-8") == text)
        if fresh:
            continue
        print(f"  [tts] page {i:02d}  ({len(text.split())} words)", flush=True)
        await tts_one(text, out)
        sidecar.write_text(text, encoding="utf-8")
        # narration changed -> the clip built from it is stale
        (CLIP_DIR / f"slide_{i:02d}.mp4").unlink(missing_ok=True)
        await asyncio.sleep(2.0)


def export_pngs() -> bool:
    """Render pages 1..N_PAGES to PNG. Returns True if anything was re-rendered."""
    PNG_DIR.mkdir(parents=True, exist_ok=True)
    have = sorted(PNG_DIR.glob("slide_*.png"))
    if (have and len(have) >= N_PAGES
            and min(p.stat().st_mtime for p in have) >= PDF.stat().st_mtime):
        print(f"  [png] {len(have)} pages already exported and newer than the PDF, skipping")
        return False
    for p in PNG_DIR.glob("*.png"):
        p.unlink()
    print(f"  [png] pdftoppm rendering pages 1-{N_PAGES}...")
    cmd = [
        "pdftoppm", "-f", "1", "-l", str(N_PAGES), "-png",
        "-scale-to-x", str(IMG_W), "-scale-to-y", str(IMG_H),
        str(PDF), str(PNG_DIR / "page"),
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stderr)
        raise RuntimeError("pdftoppm failed")
    # pdftoppm names page-01.png ... normalize to slide_NN.png
    for p in sorted(PNG_DIR.glob("page-*.png")):
        num = int(re.search(r"page-0*(\d+)\.png$", p.name).group(1))
        p.rename(PNG_DIR / f"slide_{num:02d}.png")
    print(f"  [png] exported {len(list(PNG_DIR.glob('slide_*.png')))} pages")
    return True


def build_clips(n_pages: int) -> None:
    CLIP_DIR.mkdir(parents=True, exist_ok=True)
    for i in range(1, n_pages + 1):
        png = PNG_DIR / f"slide_{i:02d}.png"
        mp3 = AUDIO_DIR / f"slide_{i:02d}.mp3"
        out = CLIP_DIR / f"slide_{i:02d}.mp4"
        if not png.exists() or not mp3.exists():
            raise FileNotFoundError(
                f"Missing input for page {i}: png={png.exists()} mp3={mp3.exists()}")
        if out.exists():
            continue
        dur = MP3(mp3).info.length
        total = dur + LEAD_IN_SEC + TRAIL_SEC
        print(f"  [mp4] page {i:02d}  ({dur:5.1f}s speech, {total:5.1f}s on screen)")
        cmd = [
            FFMPEG, "-y", "-loglevel", "error",
            "-loop", "1", "-i", str(png),
            "-i", str(mp3),
            "-c:v", "libx264", "-tune", "stillimage", "-preset", "fast",
            "-pix_fmt", "yuv420p",
            "-vf", f"scale={IMG_W}:{IMG_H}:force_original_aspect_ratio=decrease,"
                   f"pad={IMG_W}:{IMG_H}:(ow-iw)/2:(oh-ih)/2:color=white,fps=25",
            "-af", f"adelay={int(LEAD_IN_SEC * 1000)}|{int(LEAD_IN_SEC * 1000)},apad",
            "-c:a", "aac", "-b:a", "192k", "-ar", "44100",
            "-t", f"{total:.3f}",
            "-movflags", "+faststart",
            str(out),
        ]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            print(r.stderr)
            raise RuntimeError(f"ffmpeg failed on page {i}")


def concat_final(n_pages: int) -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    playlist = WORK / "concat.txt"
    lines = [f"file '{(CLIP_DIR / f'slide_{i:02d}.mp4').resolve().as_posix()}'"
             for i in range(1, n_pages + 1)]
    playlist.write_text("\n".join(lines), encoding="utf-8")
    print(f"  [concat] merging {len(lines)} clips -> {OUTPUT.name}")
    cmd = [
        FFMPEG, "-y", "-loglevel", "error",
        "-f", "concat", "-safe", "0", "-i", str(playlist),
        "-c", "copy", "-movflags", "+faststart", str(OUTPUT),
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("  [concat] copy-mode failed, re-encoding...")
        print(r.stderr)
        cmd = [
            FFMPEG, "-y", "-loglevel", "error",
            "-f", "concat", "-safe", "0", "-i", str(playlist),
            "-c:v", "libx264", "-preset", "fast", "-pix_fmt", "yuv420p",
            "-c:a", "aac", "-b:a", "192k",
            "-movflags", "+faststart", str(OUTPUT),
        ]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            print(r.stderr)
            raise RuntimeError("ffmpeg concat re-encode failed")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", choices=["parse", "tts", "png", "mp4", "concat", "all"],
                    default="all")
    args = ap.parse_args()

    if not SCRIPT.exists():
        sys.exit(f"missing {SCRIPT}")
    if not PDF.exists():
        sys.exit(f"missing {PDF}")

    print(f"[parse] {SCRIPT.name}")
    page_texts = parse_sections(SCRIPT)
    words = sum(len(t.split()) for t in page_texts)
    est = words / 155.0 * 60.0 + 2.0 * len(page_texts)
    print(f"        {len(page_texts)} narration chunks (expect {N_PAGES}), "
          f"{words} words, est. {int(est // 60)}:{int(est % 60):02d}")
    if len(page_texts) != N_PAGES:
        print("        WARNING: chunk count != page count — check the ## headings "
              "and the [ADVANCE] cues")

    if args.stage == "parse":
        for i, t in enumerate(page_texts, 1):
            print(f"\n--- page {i:02d} ({len(t.split())} words) ---\n{t[:300]}")
        return

    if args.stage in ("tts", "all"):
        print("[tts]")
        asyncio.run(run_tts(page_texts))

    if args.stage in ("png", "all"):
        print("[png]")
        if export_pngs():
            for p in CLIP_DIR.glob("slide_*.mp4"):
                p.unlink()

    if args.stage in ("mp4", "all"):
        print("[mp4] per-page clips")
        build_clips(len(page_texts))

    if args.stage in ("concat", "all"):
        print("[concat]")
        concat_final(len(page_texts))

    if OUTPUT.exists():
        size_mb = OUTPUT.stat().st_size / (1024 * 1024)
        print(f"\n[done] {OUTPUT.resolve()}  ({size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
```

## Step 6 — Parse dry run (do this before spending TTS calls)

```bash
cd tracks/<track>/slides && source C:/envs/.basic_venv/Scripts/activate && python build_video_<YYYYMMDD>.py --stage parse
```

Check three things, and fix the **script** rather than the count:

1. **`chunks == N_PAGES`.** A mismatch is almost always (a) a `## Slide` heading with a colon
   instead of an em dash, (b) a missing `**[ADVANCE]**` in a two-frame section, or (c) an overlay
   spec in the deck generating an unplanned page — re-check with `pdfinfo`.
2. **Estimated runtime** is inside the user's slot. Trim narration now, not after synthesis.
3. **Chunk text is speakable** — scan the excerpts for leaked `$`, `\`, bare `%`, or director notes
   that accidentally began with `>`.

## Step 7 — Build

```bash
cd tracks/<track>/slides && source C:/envs/.basic_venv/Scripts/activate && python build_video_<YYYYMMDD>.py
```

Budget ~8–10 s per page for TTS (network-bound, with a deliberate 2 s pause between calls) and 1–3 s
per page for ffmpeg — roughly 4 minutes for a 20-page deck from cold, longer if edge-tts throttles.
**Run it in the background** rather than blocking on a foreground timeout. If `[tts]` prints repeated
retries, let the backoff work; do not kill and restart.

## Step 8 — Verify

```bash
cd tracks/<track>/slides && source C:/envs/.basic_venv/Scripts/activate && python -c "
import subprocess, imageio_ffmpeg
from pathlib import Path
from mutagen.mp3 import MP3
DATE='<YYYYMMDD>'; W=Path(f'.video_{DATE}'); OUT=Path('<relative path to the mp4>')
mp3=sorted((W/'audio').glob('slide_*.mp3')); png=sorted((W/'png').glob('slide_*.png'))
clip=sorted((W/'clips').glob('slide_*.mp4'))
print(f'mp3={len(mp3)} png={len(png)} clips={len(clip)}')
tot=0.0
for p in mp3:
    d=MP3(p).info.length; tot+=d+2.0
    flag='  <-- LONG' if d>90 else ('  <-- SHORT' if d<8 else '')
    print(f'{p.stem}  {d:6.1f}s{flag}')
print(f'expected total {int(tot//60)}:{int(tot%60):02d}')
r=subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-i',str(OUT)],capture_output=True,text=True)
print([l.strip() for l in r.stderr.splitlines() if 'Duration' in l or 'Stream' in l])
print(f'{OUT.name}: {OUT.stat().st_size/1e6:.1f} MB')
"
```

Pass criteria:

- `mp3 == png == clips == N_PAGES`.
- mp4 duration matches the expected total to within ~1 s.
- One video stream `1920x1080 ... 25 fps` and one `aac 44100 Hz stereo`.
- No slide over 90 s or under 8 s (a short one is usually a truncated blockquote).
- Open the mp4 and spot-check the first page, one build pair, and the last page for alignment.

## Rebuild rules

| You changed | What to do |
|---|---|
| Narration text for a slide | Nothing — the sidecar detects it, re-synthesizes that page, and drops its clip. Re-run the build. |
| `main.tex` (any frame) | Recompile **twice**, then re-run the build. The PNG stage sees the newer PDF, re-renders, and drops all clips. |
| Number of PDF pages | Update `N_PAGES` **and** the chunk count, then `rm -rf .video_<DATE>` — page indices have shifted, so every cached artifact is misaligned. |
| Voice, rate, or an ffmpeg constant | `rm -rf .video_<DATE>/audio` (voice/rate) or `.video_<DATE>/clips` (encode settings). Sidecars do not track these. |
| Nothing, but the output looks wrong | `rm -rf .video_<DATE>` and rebuild. Costs one full TTS pass. |

Force one slide only:

```bash
cd tracks/<track>/slides
rm .video_<YYYYMMDD>/audio/slide_07.mp3 .video_<YYYYMMDD>/audio/slide_07.txt .video_<YYYYMMDD>/clips/slide_07.mp4
source C:/envs/.basic_venv/Scripts/activate && python build_video_<YYYYMMDD>.py
```

Concat always re-runs, so the final mp4 picks up the new clip.

## Output

| Path | Committed? |
|---|---|
| `tracks/<track>/slides/main.tex` | yes |
| `tracks/<track>/slides/presentation_script_<YYYYMMDD>.md` | yes |
| `tracks/<track>/slides/build_video_<YYYYMMDD>.py` | yes |
| `tracks/<track>/slides/build/main.pdf` | per repo convention |
| the final `.mp4` | **ask first** |
| `tracks/<track>/slides/.video_<YYYYMMDD>/` | never — scratch |

The mp4 lands in `tracks/<track>/slides/` by default. If the user wants it elsewhere — commonly
`tracks/<track>/docs/` — set the `OUTPUT` constant to that path and re-run `--stage concat` (cheap,
no TTS). Do not move the file afterwards; keep the script's declared output and the file on disk in
agreement.

A 20-minute deck is ~35 MB. Before committing, check `.gitignore` and whether the repo uses Git LFS,
and tell the user the size rather than committing a large binary silently. Add
`tracks/*/slides/.video*/` to `.gitignore`.

## Then

Report:

1. Final mp4 path, duration (`m:ss`), and size.
2. `N_PAGES`, chunk count, total spoken words, predicted vs actual runtime.
3. The per-slide duration table, flagging anything over 90 s or under 8 s.
4. Any slide where the narration and the frame content drifted apart while you were writing — you
   are the only reader who sees both.
5. The one-line re-run command for a single slide, so the user can fix a pronunciation without
   asking you.

Do not claim the video is correct unless you have run Step 8 and it passed.
