# =============================================================================
# 01g_pull_maturity_20260811.py — 2022Q4 remaining-maturity / next-repricing
# buckets for debt securities (Schedule RC-B Memorandum 2) and loans (Schedule
# RC-C Part I Memorandum 2), from the cached FFIEC bulk zip. Feeds the weighted
# average maturity panel of Figure "svb_exposure" (robustness Sec. 7.2).
#
# Buckets (RCON, RCFD fallback), all "remaining maturity or next repricing date":
#   securities  A549-A554  US Treasury/agency and other debt securities:
#                          <=3m, 3-12m, 1-3y, 3-5y, 5-15y, >15y
#               A555-A560  mortgage pass-throughs, same six buckets
#               A561-A562  other MBS: <=3y, >3y  (only two buckets exist)
#   loans       A564-A569  closed-end loans secured by first liens on 1-4 family
#                          residential properties, same six buckets
#               A570-A575  all other loans and leases, same six buckets
#
# NOTE ON A568: the bulk file's own description string reads "CLSD-END LNS SECD
# 1ST LIENS OVR 15 Y", which is a truncation artifact. The RC-C Part I Memo 2
# ladder is identical to the RC-B and "other loans" ladders (compare A553/A554
# and A574/A575, which read "OV 5-15 YRS" / "OVER 15 YR"), so A568 is over five
# through fifteen years and A569 is over fifteen years. Verified 2026-08-11.
#
# Reads the zip cached by the post-jmcb track; no network access.
# Output: tracks/fdic-brc-jfqa-aug2026/data/maturity_2022q4_20260811.csv
# =============================================================================

import csv
import io
import os
import re
import sys
import zipfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                    "..", "..", "..", ".."))
CACHE = os.path.join(ROOT, "tracks", "post-jmcb-rejection-june2026", "data",
                     "ffiec_bulk_cache")
ZIP = os.path.join(CACHE, "call_12312022.zip")
OUT = os.path.join(ROOT, "tracks", "fdic-brc-jfqa-aug2026", "data",
                   "maturity_2022q4_20260811.csv")

ITEMS = (["A%d" % i for i in range(549, 563)] +
         ["A%d" % i for i in range(564, 576)])


def read(z, pattern, items):
    """RCON preferred, RCFD fallback, first non-blank wins."""
    out = {}
    for member in [m for m in z.namelist() if re.search(pattern, m)]:
        with z.open(member) as f:
            r = csv.reader(io.TextIOWrapper(f, encoding="utf-8", errors="replace"),
                           delimiter="\t")
            header = next(r, None)
            if header is None:
                continue
            next(r, None)                       # description row
            cols = {}
            for it in items:
                for pre in ("RCON", "RCFD"):
                    if pre + it in header:
                        cols.setdefault(it, []).append(header.index(pre + it))
            if not cols:
                continue
            for rec in r:
                if not rec or not rec[0].strip().isdigit():
                    continue
                d = out.setdefault(rec[0].strip(), {})
                for it, idxs in cols.items():
                    for i in idxs:
                        if len(rec) > i and rec[i].strip() != "":
                            d[it] = rec[i].strip()
                            break
    return out


def main():
    if not os.path.exists(ZIP):
        sys.exit("missing " + ZIP)
    with zipfile.ZipFile(ZIP) as z:
        b = read(z, r"Schedule RCB ", ITEMS)
        c = read(z, r"Schedule RCCI ", ITEMS)

    ids = sorted(set(b) | set(c), key=int)
    with open(OUT, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["ID_RSSD"] + ITEMS)
        for i in ids:
            row = {}
            row.update(b.get(i, {}))
            row.update(c.get(i, {}))
            w.writerow([i] + [row.get(k, "") for k in ITEMS])

    nz = sum(1 for i in ids if any(
        (b.get(i, {}).get(k) or c.get(i, {}).get(k) or "") not in ("", "0")
        for k in ITEMS))
    print("=" * 60)
    print("banks in 2022Q4 file : %d" % len(ids))
    print("with any nonzero bucket: %d (%.1f%%)" % (nz, 100.0 * nz / max(len(ids), 1)))
    print("wrote: %s" % OUT)


if __name__ == "__main__":
    main()
