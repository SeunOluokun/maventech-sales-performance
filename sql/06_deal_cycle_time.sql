-- =====================================================================
-- 06_deal_cycle_time.sql
-- Question: How long do deals take to close, and do won deals close
--           faster than lost ones?
-- =====================================================================


-- ---------------------------------------------------------------------
-- Query 1: Average, shortest and longest time to close, Won vs Lost
-- ---------------------------------------------------------------------
SELECT deal_stage,
       COUNT(*)                                                        AS deals,
       ROUND(AVG(julianday(close_date) - julianday(engage_date)), 1)   AS avg_days,
       MIN(julianday(close_date) - julianday(engage_date))             AS min_days,
       MAX(julianday(close_date) - julianday(engage_date))             AS max_days
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost')
GROUP BY deal_stage;


-- ---------------------------------------------------------------------
-- Query 2: Does the time a deal spends in the pipeline relate to
-- whether it's won? (Buckets used because averages hide the spread.)
-- ---------------------------------------------------------------------
SELECT CASE
           WHEN days <= 7  THEN '1: 0-7 days'
           WHEN days <= 30 THEN '2: 8-30 days'
           WHEN days <= 60 THEN '3: 31-60 days'
           WHEN days <= 90 THEN '4: 61-90 days'
           ELSE '5: 90+ days'
       END                                                              AS time_to_close,
       SUM(CASE WHEN deal_stage = 'Won'  THEN 1 ELSE 0 END)             AS won,
       SUM(CASE WHEN deal_stage = 'Lost' THEN 1 ELSE 0 END)             AS lost,
       COUNT(*)                                                         AS total_deals,
       ROUND(100.0 * SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END)
             / COUNT(*), 1)                                             AS win_rate_pct
FROM (
    SELECT deal_stage,
           julianday(close_date) - julianday(engage_date) AS days
    FROM sales_pipeline
    WHERE deal_stage IN ('Won', 'Lost')
)
GROUP BY time_to_close
ORDER BY time_to_close;


-- ---------------------------------------------------------------------
-- Query 3: What share of lost deals are lost within the first 30 days?
-- ---------------------------------------------------------------------
SELECT ROUND(100.0 * SUM(CASE WHEN julianday(close_date) - julianday(engage_date) <= 30
                              THEN 1 ELSE 0 END) / COUNT(*), 1)  AS pct_lost_in_first_30_days
FROM sales_pipeline
WHERE deal_stage = 'Lost';


/*
Finding:
- Won deals take longer to close than lost deals on average
  (51.8 vs 41.5 days), although both range from 1 to 138 days.
- Win rate rises steadily the longer a deal stays in the pipeline:
  53.5% for deals closed within a week, rising to 71.1% for deals
  open more than 90 days.
- 54.4% of all lost deals are lost within the first 30 days.
- The longest any deal has taken to close is 138 days. File 07 uses
  this as the threshold for identifying stale open deals.

So what: weak deals tend to drop out early, while deals that survive
the first month are increasingly likely to close. Better qualification
at the start of the pipeline would cut wasted effort on deals that
were never going to close, and long-running deals should not be
written off.

Caveat: correlation, not causation. Keeping a deal open longer does
not make it more likely to win; deals that were going to be lost
were simply lost sooner.
*/