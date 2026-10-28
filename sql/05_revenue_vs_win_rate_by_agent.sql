-- Is the agent with the best win rate also the biggest revenue earner?

WITH agent_stats AS (
    SELECT sales_agent,
           SUM(CASE WHEN deal_stage = 'Won'  THEN 1 ELSE 0 END)              AS won,
           COUNT(*)                                               AS closed_deals,
           ROUND(100.0 * SUM(CASE WHEN deal_stage = 'Won'  THEN 1 ELSE 0 END) / COUNT(*) , 1)                  AS win_rate_pct,
           SUM(CASE WHEN deal_stage = 'Won'  THEN close_value ELSE 0 END)       AS total_revenue
    FROM sales_pipeline
    WHERE deal_stage IN ('Won','Lost')
    GROUP BY sales_agent
)
SELECT sales_agent,
       won,
       closed_deals,
       win_rate_pct,
       total_revenue,
	   ROUND(total_revenue * 1.0 / won, 0) AS avg_won_value,
       RANK() OVER (ORDER BY total_revenue DESC)   AS revenue_rank,
       RANK() OVER (ORDER BY win_rate_pct DESC)   AS win_rate_rank
FROM agent_stats
ORDER BY revenue_rank;
/*
Finding:
- Agent win rates range from 55.0% to 70.4% (15.4 points), far wider
  than across teams (2.3) or products (4.8): individual performance
  is where win rate genuinely differs.
- Win rate and revenue rank do not line up. Darcel Schlecht is #1 on
  revenue ($1.15M) but #18 on win rate (63.1%); Hayden Neloms is #1 on
  win rate (70.4%) but #19 on revenue.
- Revenue is driven by volume and price, not win rate. Darcel closed
  553 deals (avg ~224) at ~$3,300 per win (avg ~$2,360). Versie
  Hillebrand wins 66.7% of deals but ranks 27th on revenue at
  ~$1,070 per win.
- Wilburn Farren's 69.6% is based on only 79 closed deals; treat
  with caution.
So what: high-win-rate, low-revenue agents (e.g. Hayden, Versie) are
the biggest opportunity. Coaching them toward higher-value products
or more pipeline would grow revenue without hurting their conversion.
*/
