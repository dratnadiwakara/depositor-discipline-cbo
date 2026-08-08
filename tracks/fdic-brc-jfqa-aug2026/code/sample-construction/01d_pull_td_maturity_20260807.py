# Pull 2022Q4 uninsured time-deposit maturity breakdown (RC-E Memo 4)
# from the FFIEC Call Report duckdb.
#   RCONHK12 = time deposits > $250k, remaining maturity <= 3 months
#   RCONHK13 = time deposits > $250k, remaining maturity 3-12 months
# Output: tracks/fdic-brc-jfqa-aug2026/data/td_maturity_2022q4_20260807.csv
# Consumed by: code/result-generation/maturity_split_20260807.qmd

import duckdb
from pathlib import Path

DB = "C:/empirical-data-construction/call-reports-FFIEC/call-reports-ffiec.duckdb"
OUT = Path(__file__).resolve().parents[2] / "data" / "td_maturity_2022q4_20260807.csv"

con = duckdb.connect(DB, read_only=True)
df = con.execute(
    """
    SELECT idrssd AS IDRSSD,
           RCONHK12 AS mat_lt3m,
           RCONHK13 AS mat_3to12m,
           RCONK222 AS mat_lt1yr
    FROM schedule_rce
    WHERE activity_year = 2022 AND activity_quarter = 4
    """
).fetchdf()
df.to_csv(OUT, index=False)

print(f"rows: {len(df)}")
print(f"non-missing HK12: {df.mat_lt3m.notna().mean():.3f}  HK13: {df.mat_3to12m.notna().mean():.3f}")
print(f"written: {OUT}")
