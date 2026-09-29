Data Cleaning Log

Dataset: Maven Analytics – CRM Sales Opportunities (public domain) Tables: accounts, products, sales_teams, sales_pipeline (8,800 opportunities) Tool: Excel. Raw CSVs kept untouched in data/raw/; all cleaning done on copies in data/clean/.

accounts
Converted to an Excel Table for filtering and validation.
Renamed revenue to Revenue ($m). The data dictionary states it is annual revenue in millions of USD. Applied currency and thousands formatting; added thousands separators to employees.
Fixed: sector typo "technolgy" → "technology" (12 accounts).
Blanks only in subsidiary_of. Kept as-is: a blank means the company is independent.
No duplicates found.
products
Converted to an Excel Table; added thousands separators to sales_price.
No blanks or duplicates.
sales_teams
No blanks, duplicates or whitespace issues.
Every sales agent in the pipeline exists in this table.
sales_pipeline
Converted to an Excel Table. No duplicate opportunity IDs.
Fixed: product name mismatch. The pipeline used "GTXPro" while the products table used "GTX Pro". Standardised to "GTX Pro" so joins don't drop those deals.
Converted close_value from text to numbers with =VALUE().
Stage logic validated:
Won (4,238): all have a close date and a close value.
Lost (2,473): all have a close date and a close value of 0.
Engaging (1,589) and Prospecting (500): no close date or close value. Expected, because these deals are still open, so they were left blank, not set to 0. A 0 would wrongly count as lost revenue and drag down averages.
Prospecting deals also have no engage date. Expected, because they haven't reached the Engaging stage.
Close value units: the data dictionary doesn't say whether close_value is in dollars or millions. Checked by comparing Won deals to product list prices: the median ratio of close_value to sales_price is 0.998. Conclusion: close_value is in US dollars.
Missing accounts: 1,425 opportunities have no account name. All are open deals (1,088 Engaging, 337 Prospecting); none are Won or Lost. Most likely these are early leads not yet linked to a company record.
Decision: kept in pipeline counts and value totals; excluded from account- and sector-level analysis. Not deleted or filled in.
Date range: engage dates Oct 2016 – Dec 2017; close dates Mar 2017 – Dec 2017.
Checks that found no issues
Whitespace: checked with the filter dropdowns (a trailing space would appear as a duplicate value) and with a LEN vs LEN(TRIM()) comparison.
Referential integrity: every product, sales agent and account in the pipeline exists in its reference table.
