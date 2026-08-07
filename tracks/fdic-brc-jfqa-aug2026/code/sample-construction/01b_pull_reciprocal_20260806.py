# =============================================================================
# 01b_pull_reciprocal_20260612.py — Pull RCONJH83 (total reciprocal deposits,
# RC-E Memo 1.g) from FFIEC CDR bulk Call Report downloads.
#
# Reciprocal deposits are reported from 2018Q2 onward (EGRRCPA Section 202).
# For each quarter: download the single-period "All Schedules" TSV bulk zip,
# extract the RC-E schedule file(s), keep IDRSSD + RCONJH83.
#
# Output: tracks/post-jmcb-rejection-june2026/data/reciprocal_deposits_20260612.csv
#         (columns: ID_RSSD, D_DT, reciprocal_deps; $ thousands)
# Convert to rds afterwards (see 01b_convert command in header of 01_build_panel).
# =============================================================================

import csv
import io
import os
import re
import sys
import time
import zipfile
import urllib.request
import urllib.parse
import http.cookiejar
from html.parser import HTMLParser

BASE = "https://cdr.ffiec.gov/public/PWS/DownloadBulkData.aspx"
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "data")
OUT_CSV = os.path.abspath(os.path.join(OUT_DIR, "reciprocal_deposits_20260612.csv"))
CACHE_DIR = os.path.abspath(os.path.join(OUT_DIR, "ffiec_bulk_cache"))
os.makedirs(CACHE_DIR, exist_ok=True)

QUARTERS = []
for yr in range(2018, 2026):
    for mmdd in ("03/31", "06/30", "09/30", "12/31"):
        d = f"{mmdd}/{yr}"
        if yr == 2018 and mmdd == "03/31":
            continue  # JH83 starts 2018Q2
        QUARTERS.append(d)

cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
opener.addheaders = [("User-Agent", "Mozilla/5.0 (research data pull)")]


class FormParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.hidden = {}
        self.dates = {}  # label -> value (option value is a numeric id)
        self._in_dates = False
        self._cur_val = None

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "input" and a.get("type") == "hidden" and a.get("name"):
            self.hidden[a["name"]] = a.get("value", "")
        if tag == "select" and a.get("name", "").endswith("DatesDropDownList"):
            self._in_dates = True
        if tag == "option" and self._in_dates and "value" in a:
            self._cur_val = a["value"]

    def handle_data(self, data):
        if self._in_dates and self._cur_val is not None and data.strip():
            self.dates[data.strip()] = self._cur_val
            self._cur_val = None

    def handle_endtag(self, tag):
        if tag == "select":
            self._in_dates = False
            self._cur_val = None


def get_page(url=BASE, data=None):
    if data is not None:
        data = urllib.parse.urlencode(data).encode()
    req = urllib.request.Request(url, data=data)
    with opener.open(req, timeout=300) as r:
        return r.read(), r.headers


def parse_form(html_bytes):
    p = FormParser()
    p.feed(html_bytes.decode("utf-8", errors="replace"))
    return p


def fresh_form_with_dates():
    html, _ = get_page()
    p = parse_form(html)
    form = dict(p.hidden)
    form["__EVENTTARGET"] = "ctl00$MainContentHolder$ListBox1"
    form["__EVENTARGUMENT"] = ""
    form["ctl00$MainContentHolder$ListBox1"] = "ReportingSeriesSinglePeriod"
    html2, _ = get_page(data=form)
    p2 = parse_form(html2)
    return p2


def download_quarter(date_str):
    stamp = date_str.replace("/", "")
    cache_zip = os.path.join(CACHE_DIR, f"call_{stamp}.zip")
    if os.path.exists(cache_zip) and os.path.getsize(cache_zip) > 1_000_000:
        return cache_zip
    p = fresh_form_with_dates()
    if date_str not in p.dates:
        print(f"  [skip] {date_str} not in dates list ({len(p.dates)} dates): "
              f"{list(p.dates)[:4]}...")
        return None
    form = dict(p.hidden)
    form["__EVENTTARGET"] = ""
    form["__EVENTARGUMENT"] = ""
    form["ctl00$MainContentHolder$ListBox1"] = "ReportingSeriesSinglePeriod"
    form["ctl00$MainContentHolder$DatesDropDownList"] = p.dates[date_str]
    form["ctl00$MainContentHolder$FormatType"] = "TSVRadioButton"
    form["ctl00$MainContentHolder$TabStrip1$Download_0"] = "Download"
    body, headers = get_page(data=form)
    ctype = headers.get("Content-Type", "")
    if "zip" not in ctype and not body[:2] == b"PK":
        print(f"  [fail] {date_str}: not a zip (Content-Type={ctype}, {len(body)} bytes)")
        return None
    with open(cache_zip, "wb") as f:
        f.write(body)
    return cache_zip


def extract_jh83(zip_path, date_str):
    """Return list of (idrssd, value) from RC-E schedule files in the zip."""
    rows = []
    with zipfile.ZipFile(zip_path) as z:
        members = [m for m in z.namelist() if re.search(r"Schedule RC-?E", m, re.I)]
        if not members:
            print(f"  [warn] no RC-E member in {os.path.basename(zip_path)}")
            return rows
        for m in members:
            with z.open(m) as f:
                text = io.TextIOWrapper(f, encoding="utf-8", errors="replace")
                reader = csv.reader(text, delimiter="\t")
                header = next(reader, None)
                if header is None or "IDRSSD" not in header[0]:
                    continue
                try:
                    col = header.index("RCONJH83")
                except ValueError:
                    continue
                idcol = 0
                first_data = True
                for rec in reader:
                    if first_data:
                        first_data = False
                        # second row is item descriptions, not data
                        if rec and not rec[idcol].strip().isdigit():
                            continue
                    if len(rec) <= col or not rec[idcol].strip().isdigit():
                        continue
                    v = rec[col].strip()
                    rows.append((rec[idcol].strip(), v if v != "" else ""))
    return rows


def main():
    all_rows = []
    for q in QUARTERS:
        yyyy = q[-4:]
        mm, dd = q[:2], q[3:5]
        d_dt = f"{yyyy}-{mm}-{dd}"
        t0 = time.time()
        zp = download_quarter(q)
        if zp is None:
            continue
        rows = extract_jh83(zp, q)
        n_nonzero = sum(1 for _, v in rows if v not in ("", "0"))
        print(f"  {q}: {len(rows)} banks, {n_nonzero} nonzero JH83 "
              f"({time.time()-t0:.0f}s)")
        for idr, v in rows:
            all_rows.append((idr, d_dt, v))
        sys.stdout.flush()
    with open(OUT_CSV, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["ID_RSSD", "D_DT", "reciprocal_deps"])
        w.writerows(all_rows)
    print(f"Wrote {len(all_rows)} rows -> {OUT_CSV}")


if __name__ == "__main__":
    main()
