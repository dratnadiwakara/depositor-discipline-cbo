# =============================================================================
# 01e_pull_fhlb_20260809.py — Pull FHLB advances (Schedule RC-M item 5.a) and
# other borrowed money (Schedule RC line 16) from the FFIEC CDR bulk Call Report
# zips already cached by 01b_pull_reciprocal_20260806.py.
#
# Reads only the local cache; no network access.
#   Cache: tracks/post-jmcb-rejection-june2026/data/ffiec_bulk_cache/call_*.zip
#
# Fields (RCON preferred, RCFD fallback for 031 filers):
#   RC-M 5.a : F055 advances, remaining maturity / next repricing date <= 1 yr
#              F056 ... over 1 through 3 yrs
#              F057 ... over 3 through 5 yrs
#              F058 ... over 5 yrs
#              F059 structured advances (memo subset of the above, not summed)
#              2651 advances with a remaining maturity of one year or less
#                   (overlapping concept, carried raw for reference)
#   RC 16    : 3190 other borrowed money
#
# F055-F058 partition total advances; term advances are F056+F057+F058.
#
# Output: tracks/fdic-brc-jfqa-aug2026/data/fhlb_advances_20260809.csv
#         (ID_RSSD, D_DT, one column per item; $ thousands)
# Convert to rds with 01f_convert_fhlb_20260809.R.
# =============================================================================

import csv
import io
import os
import re
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
TRACK_DATA = os.path.abspath(os.path.join(HERE, "..", "..", "data"))
CACHE = os.path.abspath(os.path.join(
    HERE, "..", "..", "..", "post-jmcb-rejection-june2026", "data",
    "ffiec_bulk_cache"))
OUT = os.path.join(TRACK_DATA, "fhlb_advances_20260809.csv")

RCM_ITEMS = ["F055", "F056", "F057", "F058", "F059", "2651"]
RC_ITEMS = ["3190"]


def read_schedule(z, pattern, items):
    """Return {idrssd: {item: value}} for one schedule across its part files."""
    out = {}
    for m in [m for m in z.namelist() if re.search(pattern, m)]:
        with z.open(m) as f:
            r = csv.reader(io.TextIOWrapper(f, encoding="utf-8", errors="replace"),
                           delimiter="\t")
            header = next(r, None)
            if header is None:
                continue
            next(r, None)  # item-description row
            cols = {}
            for item in items:
                for pre in ("RCON", "RCFD"):
                    if pre + item in header:
                        cols.setdefault(item, []).append(header.index(pre + item))
            if not cols:
                continue
            for rec in r:
                if not rec or not rec[0].strip().isdigit():
                    continue
                d = out.setdefault(rec[0].strip(), {})
                for item, idxs in cols.items():
                    for i in idxs:  # RCON first, RCFD fallback
                        if len(rec) > i and rec[i].strip() != "":
                            d[item] = rec[i].strip()
                            break
    return out


def main():
    if not os.path.isdir(CACHE):
        sys.exit(f"Bulk cache not found: {CACHE}\n"
                 f"Run 01b_pull_reciprocal_20260806.py first to populate it.")
    rows = []
    for zf in sorted(f for f in os.listdir(CACHE) if f.endswith(".zip")):
        m = re.search(r"call_(\d{2})(\d{2})(\d{4})\.zip", zf)
        if not m:
            continue
        mm, dd, yyyy = m.groups()
        d_dt = f"{yyyy}-{mm}-{dd}"
        with zipfile.ZipFile(os.path.join(CACHE, zf)) as z:
            rcm = read_schedule(z, r"Schedule RCM ", RCM_ITEMS)
            rc = read_schedule(z, r"Schedule RC \d", RC_ITEMS)
        ids = set(rcm) | set(rc)
        n_adv = sum(1 for i in ids
                    if any(rcm.get(i, {}).get(k, "") not in ("", "0")
                           for k in ("F055", "F056", "F057", "F058")))
        print(f"  {d_dt}: {len(ids):5d} banks | any FHLB advance {n_adv:5d}")
        sys.stdout.flush()
        for i in sorted(ids):
            a, b = rcm.get(i, {}), rc.get(i, {})
            rows.append([i, d_dt] + [a.get(k, "") for k in RCM_ITEMS]
                        + [b.get(k, "") for k in RC_ITEMS])

    with open(OUT, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["ID_RSSD", "D_DT"]
                   + ["RCON" + k for k in RCM_ITEMS + RC_ITEMS])
        w.writerows(rows)
    print(f"Wrote {len(rows)} rows -> {OUT}")


if __name__ == "__main__":
    main()
