-- Which products win most often, and what are they worth when won?

SELECT p.product,
       pr.sales_price,
       SUM(CASE WHEN p.deal_stage = 'Won' THEN 1 ELSE 0 END)                    AS won,
       COUNT(*)                                                     AS closed_deals,
       ROUND(100.0 * SUM(CASE WHEN p.deal_stage = 'Won' THEN 1 ELSE 0 END)  / COUNT(*), 1)                        AS win_rate_pct,
       ROUND(AVG(CASE WHEN p.deal_stage = 'Won' THEN p.close_value END), 0)          AS avg_won_value,
       SUM(CASE WHEN p.deal_stage = 'Won'  THEN p.close_value ELSE 0 END)             AS total_revenue
FROM sales_pipeline p
JOIN products pr ON p.product = pr.product
WHERE p.deal_stage in ('Won','Lost')
GROUP BY p.product , pr.sales_price
ORDER BY win_rate_pct DESC;


/*
Finding:
- Win rates are tightly clustered (60.0%–64.8%), but total won revenue
  ranges from $43,768 (MG Special) to $3,510,578 (GTX Pro).
- MG Special has the highest win rate (64.8%) but the lowest revenue: at $55 per
  unit, even 793 wins add up to very little. Revenue is driven by price
  x volume, not by win rate.
- GTK 500's 60% is based on only 25 closed deals (vs 745–1,436 for the
  others). One deal either way moves its rate by 4 points, so it can't
  be compared reliably.
So what: win rate is not the right measure for prioritising products.
GTX Pro, GTX Plus Pro and MG Advanced generate ~80% of won revenue.
*/