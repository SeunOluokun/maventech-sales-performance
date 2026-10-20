-- =====================================================================
-- 01_cleaning_and_verification.sql
-- MavenTech Sales Performance Analysis
-- Purpose: fixes applied after importing the cleaned CSVs into SQLite,
--          plus the queries used to check the data was correct.
-- Safe to re-run: every UPDATE gives the same result if run again.
-- =====================================================================


-- ---------------------------------------------------------------------
-- STEP 1: Convert empty text to true NULLs
-- DB Browser imports empty cells as '' (empty text), which COUNT()
-- treats as a value. NULL is a real blank and is skipped by COUNT().
-- ---------------------------------------------------------------------
UPDATE sales_pipeline SET account     = NULL WHERE account     = '';
UPDATE sales_pipeline SET engage_date = NULL WHERE engage_date = '';
UPDATE sales_pipeline SET close_date  = NULL WHERE close_date  = '';
UPDATE sales_pipeline SET close_value = NULL WHERE close_value = '';
UPDATE accounts       SET subsidiary_of = NULL WHERE subsidiary_of = '';


-- ---------------------------------------------------------------------
-- STEP 2: Column types (done in DB Browser: Database Structure > Modify Table)
--   sales_pipeline.close_value -> INTEGER
--   products.sales_price       -> INTEGER
--   accounts.revenue_m         -> REAL
--   accounts.employees         -> INTEGER
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- STEP 3: First verification - non-blank values per deal stage
-- Expected: open deals (Engaging, Prospecting) have NO close value.
-- Result: they showed 1,589 and 500 values, so something was wrong.
-- ---------------------------------------------------------------------
SELECT deal_stage,
       COUNT(*)           AS deals,
       COUNT(close_value) AS with_value,
       COUNT(account)     AS with_account
FROM sales_pipeline
GROUP BY deal_stage;


-- ---------------------------------------------------------------------
-- STEP 4: Diagnose what was stored in close_value for open deals
-- Finding: 0s introduced by the =VALUE() conversion in Excel.
-- ---------------------------------------------------------------------
SELECT deal_stage,
       close_value,
       typeof(close_value) AS stored_as,
       COUNT(*)            AS deals
FROM sales_pipeline
WHERE deal_stage IN ('Engaging', 'Prospecting')
GROUP BY deal_stage, close_value, stored_as;


-- ---------------------------------------------------------------------
-- STEP 5: Fix - open deals cannot have a close value or close date,
-- and Prospecting deals have not reached the Engaging stage yet.
-- ---------------------------------------------------------------------
UPDATE sales_pipeline
SET close_value = NULL,
    close_date  = NULL
WHERE deal_stage IN ('Engaging', 'Prospecting');

UPDATE sales_pipeline
SET engage_date = NULL
WHERE deal_stage = 'Prospecting';


-- ---------------------------------------------------------------------
-- STEP 6: Final verification
-- Expected:
--   Won          4238 | 4238 | 4238 | 4238 | 4238
--   Lost         2473 | 2473 | 2473 | 2473 | 2473
--   Engaging     1589 |    0 |    0 | 1589 |  501
--   Prospecting   500 |    0 |    0 |    0 |  163
-- ---------------------------------------------------------------------
SELECT deal_stage,
       COUNT(*)           AS deals,
       COUNT(close_value) AS with_value,
       COUNT(close_date)  AS with_close_date,
       COUNT(engage_date) AS with_engage_date,
       COUNT(account)     AS with_account
FROM sales_pipeline
GROUP BY deal_stage;
