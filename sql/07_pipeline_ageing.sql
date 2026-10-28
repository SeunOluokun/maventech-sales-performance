--Where is the pipeline stuck? T

SELECT MAX(close_date) AS snapshot_date FROM sales_pipeline; -- so today is not 2026, will use the max date in the dataset to simulate this going forward
--julianday('2017-12-31').


    SELECT CASE
           WHEN days_open <= 30  THEN '1: 0-30 days'
           WHEN days_open <= 60  THEN '2: 31-60 days'
           WHEN days_open <= 90  THEN '3: 61-90 days'
           WHEN days_open <= 138 THEN '4: 91-138 days'
           ELSE '5: 139+ days (older than any closed deal)'
       END                                       AS age_band,
       COUNT(*)                                  AS open_deals,
       SUM(sales_price)                             AS potential_value
FROM (SELECT p.opportunity_id,
           pr.sales_price as sales_price,
       julianday('2017-12-31') -     julianday(p.engage_date) AS days_open
    FROM sales_pipeline p
    JOIN products pr ON p.product = pr.product
    WHERE p.deal_stage = 'Engaging' )
GROUP BY age_band
ORDER BY age_band;

/*
Finding:
- 1,291 of 1,589 open (Engaging) deals - 81% - have been open longer
  than 138 days, the longest any closed deal has ever taken.
- These stale deals hold ~$3.2M of the ~$3.9M potential pipeline
  value (82%, estimated at list price).
- The oldest open deal was engaged in October 2016, over a year
  before the snapshot date (31 Dec 2017).
So what: the open pipeline is heavily inflated. A realistic live
pipeline is ~298 deals (~$0.7M), so forecasts based on the full
pipeline would overstate likely revenue several times over.
Recommendation: review and close out stale deals, and flag any deal
open past ~138 days for follow-up.
Caveat: the data cannot show whether these deals are genuinely stuck
or simply were never updated in the CRM - either way, the pipeline
figure cannot be trusted as it stands.
*/
	