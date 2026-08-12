"""Build MP4 presentation video from presentation_script_20260812.md +
build/main.pdf (Beamer deck).

Adapted from FINN6213/week1/build_video_v5.py. Differences:
  - Slides come from a Beamer PDF, rendered to PNG with pdftoppm (MiKTeX),
    not PowerPoint COM.
  - Narration lives in markdown BLOCKQUOTES (> ...); the FINN pipeline
    stripped blockquotes, this one extracts them.
  - Combined build sections ("## Slides 10-11 ...") are split at the
    **[ADVANCE]** cue into one narration chunk per PDF page.
  - Italic transition lines (*Transition: "..."*) are spoken at the end of
    each section's final chunk.
  - Only the 22 talk pages are rendered; backup slides (pages 23-28) and the
    Q&A appendix in the script are excluded.

Pipeline (idempotent; cached artifacts reused):
  1. Parse script -> 22 narration chunks (one per PDF page 1..22).
  2. TTS each chunk -> .video/audio/slide_NN.mp3 (edge-tts, Andrew voice).
  3. pdftoppm build/main.pdf -> .video/png/slide_NN.png at 1920x1080.
  4. ffmpeg still PNG + narration -> per-slide MP4 with lead-in/trail silence.
  5. Concat -> presentation_video_20260812.mp4.

Usage:
  python build_video_20260812.py                # full build
  python build_video_20260812.py --stage tts|png|mp4|concat
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
SCRIPT = HERE / "presentation_script_20260812.md"
PDF = HERE / "build" / "main.pdf"
WORK = HERE / ".video2"
AUDIO_DIR = WORK / "audio"
PNG_DIR = WORK / "png"
CLIP_DIR = WORK / "clips"
OUTPUT = HERE / "presentation_video_20260812.mp4"

VOICE = "en-US-AndrewNeural"
RATE = "+0%"
IMG_W, IMG_H = 1920, 1080
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

N_PAGES = 22          # talk pages only; 23-28 are backup slides
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
    # single newlines are wrap artifacts, not pauses — join them
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
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    for i, text in enumerate(page_texts, start=1):
        out = AUDIO_DIR / f"slide_{i:02d}.mp3"
        if out.exists() and out.stat().st_size > 0:
            continue
        print(f"  [tts] page {i:02d}  ({len(text)} chars)", flush=True)
        await tts_one(text, out)
        await asyncio.sleep(2.0)


def export_pngs() -> None:
    PNG_DIR.mkdir(parents=True, exist_ok=True)
    have = sorted(PNG_DIR.glob("slide_*.png"))
    if len(have) >= N_PAGES:
        print(f"  [png] {len(have)} pages already exported, skipping")
        return
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
    playlist = WORK / "concat.txt"
    lines = [f"file '{(CLIP_DIR / f'slide_{i:02d}.mp4').as_posix()}'"
             for i in range(1, n_pages + 1)]
    playlist.write_text("\n".join(lines), encoding="utf-8")
    print(f"  [concat] merging {len(lines)} clips -> {OUTPUT.name}")
    cmd = [
        FFMPEG, "-y", "-loglevel", "error",
        "-f", "concat", "-safe", "0",
        "-i", str(playlist),
        "-c", "copy",
        "-movflags", "+faststart",
        str(OUTPUT),
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("  [concat] copy-mode failed, re-encoding...")
        print(r.stderr)
        cmd = [
            FFMPEG, "-y", "-loglevel", "error",
            "-f", "concat", "-safe", "0",
            "-i", str(playlist),
            "-c:v", "libx264", "-preset", "fast", "-pix_fmt", "yuv420p",
            "-c:a", "aac", "-b:a", "192k",
            "-movflags", "+faststart",
            str(OUTPUT),
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
    print(f"        {len(page_texts)} narration chunks (expect {N_PAGES})")
    if len(page_texts) != N_PAGES:
        print("        WARNING: chunk count != page count — check [ADVANCE] cues")

    if args.stage == "parse":
        for i, t in enumerate(page_texts, 1):
            print(f"\n--- page {i:02d} ({len(t)} chars) ---\n{t[:300]}")
        return

    if args.stage in ("tts", "all"):
        print("[tts]")
        asyncio.run(run_tts(page_texts))

    if args.stage in ("png", "all"):
        print("[png]")
        export_pngs()

    if args.stage in ("mp4", "all"):
        print("[mp4] per-page clips")
        build_clips(len(page_texts))

    if args.stage in ("concat", "all"):
        print("[concat]")
        concat_final(len(page_texts))

    if OUTPUT.exists():
        size_mb = OUTPUT.stat().st_size / (1024 * 1024)
        print(f"\n[done] {OUTPUT.name}  ({size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
