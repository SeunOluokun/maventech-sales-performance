-- =====================================================================
-- 02_win_rate_by_agent.sql
-- MavenTech Sales Performance Analysis
-- Question: which sales agents convert the highest share of their deals?
--
-- Win rate = Won / (Won + Lost)
-- Open deals (Engaging, Prospecting) are excluded: they have not had a
-- chance to be won yet, so including them would unfairly lower the rate
-- of agents with large open pipelines.
-- =====================================================================

SELECT sales_agent,
       SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END)                 AS won,
       COUNT(*)                                                             AS closed_deals,
       ROUND(100.0 * SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END)
                   / COUNT(*), 1)                                           AS win_rate_pct
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost')
GROUP BY sales_agent
ORDER BY win_rate_pct DESC;

-- Expected: 30 agents, win rates from ~55% to ~70%.
-- Note: top agent by win RATE (Hayden Neloms, 70.4%) is not the top
-- agent by win VOLUME (Darcel Schlecht, 349 wins at 63.1%).
