# =============================================================================
# 02b_pull_ratewatch_20260806.py — Bank-week posted deposit rates for the
# community-bank sample from the RateWatch duckdb build
# (C:/empirical-data-construction/ratewatch/ratewatch.duckdb).
#
# Products: 12MCD10K (retail 12-mo CD), 12MCD100K (jumbo-tier 12-mo CD),
#           SAV2.5K (savings placebo).
# Window: 2021-01-01 .. vendor cutoff (2024-05-02).
# Grain out: (ID_RSSD, week_date, product) mean APY across ratesetters.
#
# Input:  tracks/fdic-brc-jfqa-aug2026/data/bank_treatment_*.csv (02a)
# Output: tracks/fdic-brc-jfqa-aug2026/data/ratewatch_bankweek_20260806.csv
# Run:    C:/envs/.basic_venv/Scripts/python.exe 02b_pull_ratewatch_20260806.py
# =============================================================================
import glob
import os

import duckdb

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.abspath(os.path.join(HERE, "..", "..", "data"))
OUT = os.path.join(DATA, "ratewatch_bankweek_20260806.csv")

treat_files = sorted(glob.glob(os.path.join(DATA, "bank_treatment_*.csv")))
if not treat_files:
    raise SystemExit("Run 02a_export_treatment first (bank_treatment_*.csv missing)")
TREAT = treat_files[-1].replace("\\", "/")

db = duckdb.connect("C:/empirical-data-construction/ratewatch/ratewatch.duckdb",
                    read_only=True)

db.execute(f"CREATE TEMP TABLE sample AS SELECT * FROM read_csv_auto('{TREAT}')")
n_sample = db.execute("SELECT COUNT(*) FROM sample").fetchone()[0]

db.execute("""
    CREATE TEMP TABLE bw AS
    SELECT r.rssd_id                    AS ID_RSSD,
           r.week_date,
           r.productdescription         AS product,
           AVG(r.apy)                   AS apy,
           COUNT(*)                     AS n_setters
    FROM ratewatch r
    JOIN sample s ON r.rssd_id = s.ID_RSSD
    WHERE r.year >= 2021
      AND r.week_date >= DATE '2021-01-01'
      AND (
            (r.prd_typ_join = 'CD'  AND r.productdescription IN ('12MCD10K','12MCD100K'))
         OR (r.prd_typ_join = 'SAV' AND r.productdescription = 'SAV2.5K')
      )
      AND r.apy IS NOT NULL
    GROUP BY 1, 2, 3
""")

db.execute(f"COPY bw TO '{OUT.replace(chr(92), '/')}' (HEADER, DELIMITER ',')")

# Diagnostics
print("Sample banks in treatment file:", n_sample)
for row in db.execute("""
    SELECT product, COUNT(*) n_rows, COUNT(DISTINCT ID_RSSD) banks,
           MIN(week_date) first_wk, MAX(week_date) last_wk,
           ROUND(AVG(apy), 3) mean_apy
    FROM bw GROUP BY 1 ORDER BY 1
""").fetchall():
    print(row)
matched = db.execute("SELECT COUNT(DISTINCT ID_RSSD) FROM bw").fetchone()[0]
print(f"Matched banks: {matched} / {n_sample}")
print("Wrote:", OUT)
