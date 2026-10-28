-- How long do deals take to close, 
--and do won deals close faster than lost ones?

SELECT * FROM sales_pipeline;

SELECT deal_stage,  COUNT(*)   AS deals, ROUND(AVG(julianday(close_date) - julianday(engage_date)), 1) AS avg_days,MIN(julianday(close_date) - julianday(engage_date))  AS min_days,MAX(julianday(close_date) - julianday(engage_date))      AS max_days
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost')
GROUP BY deal_stage;

-- Does the time a deal spends in the pipeline relate to whether it's won?

SELECT CASE
           WHEN days <= 7  THEN '1: 0-7 days'
           WHEN days <= 30 THEN '2: 8-30 days'
           WHEN days <= 60 THEN '3: 31-60 days'
           WHEN days <= 90 THEN '4: 61-90 days'
           ELSE '5: 90+ days'
       END                                                              AS time_to_close,
       SUM(CASE WHEN deal_stage = 'Won'  THEN 1 ELSE 0 END)             AS won,
       SUM(CASE WHEN deal_stage = 'Lost' THEN 1 ELSE 0 END)             AS lost,
       ROUND(100.0 * SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END)
             / COUNT(*), 1)                                             AS win_rate_pct,
			 COUNT(*) AS total_deals
FROM (
    SELECT deal_stage,
           julianday(close_date) - julianday(engage_date) AS days
    FROM sales_pipeline
    WHERE deal_stage IN ('Won', 'Lost')
)
GROUP BY time_to_close
ORDER BY time_to_close;
