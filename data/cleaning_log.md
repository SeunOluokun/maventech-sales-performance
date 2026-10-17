# Data Cleaning Log

**Dataset:** Maven Analytics – CRM Sales Opportunities (public domain)
**Tables:** accounts, products, sales_teams, sales_pipeline (8,800 opportunities)
**Tools:** Excel for cleaning; DB Browser for SQLite for loading and verification
**Approach:** raw CSVs kept untouched in `data/raw/`; all cleaning done on copies in `data/clean/`.

---

## 1. Cleaning in Excel

### accounts
- Converted to an Excel Table for filtering and validation.
- Renamed `revenue` to **Revenue ($m)**. The data dictionary states it is annual revenue in millions of USD. Applied currency and thousands formatting; added thousands separators to `employees`.
- **Fixed:** sector typo "technolgy" → "technology" (12 accounts).
- Blanks only in `subsidiary_of`. Kept as-is: a blank means the company is independent.
- No duplicates found.

### products
- Converted to an Excel Table; added thousands separators to `sales_price`.
- No blanks or duplicates.

### sales_teams
- No blanks, duplicates or whitespace issues.
- Every sales agent in the pipeline exists in this table.

### sales_pipeline
- Converted to an Excel Table. No duplicate opportunity IDs.
- **Fixed:** product name mismatch. The pipeline used "GTXPro" while the products table used "GTX Pro". Standardised to "GTX Pro" so joins don't drop those deals.
- Converted `close_value` from text to numbers with `=VALUE()`.
- **Stage logic validated:**
  - **Won (4,238):** all have a close date and a close value.
  - **Lost (2,473):** all have a close date and a close value of 0.
  - **Engaging (1,589) and Prospecting (500):** no close date or close value. Expected, because these deals are still open, so they were left blank, not set to 0. A 0 would wrongly count as lost revenue and drag down averages.
  - Prospecting deals also have no engage date. Expected, because they haven't reached the Engaging stage.
- **Close value units:** the data dictionary doesn't say whether `close_value` is in dollars or millions. Checked by comparing Won deals to product list prices: the median ratio of close_value to sales_price is 0.998. **Conclusion: close_value is in US dollars.**
- **Missing accounts:** 1,425 opportunities have no account name. All are open deals (1,088 Engaging, 337 Prospecting); none are Won or Lost. Most likely these are early leads not yet linked to a company record.
  - **Decision:** kept in pipeline counts; excluded from account- and sector-level analysis. Not deleted or filled in.
- **Date range:** engage dates Oct 2016 – Dec 2017; close dates Mar 2017 – Dec 2017.

### Checks that found no issues
- **Whitespace:** checked with the filter dropdowns (a trailing space would appear as a duplicate value) and with a `LEN` vs `LEN(TRIM())` comparison.
- **Referential integrity:** every product, sales agent and account in the pipeline exists in its reference table.

---

## 2. Loading into SQLite (DB Browser for SQLite)

### Export prep in Excel
CSV files save values as displayed, so before export:
- Number columns reset to plain numbers (no currency symbols or thousands separators).
- Dates reformatted to `yyyy-mm-dd`, the format SQLite date functions require.
- `Revenue ($m)` renamed to `revenue_m`, since spaces and symbols in column names cause errors in SQL.
- Saved as CSV UTF-8 in `data/clean/csv/`; formatted .xlsx files kept unchanged.

### Import and fixes
- Imported all four CSVs into `maventech.db` as tables `accounts`, `products`, `sales_teams` and `sales_pipeline`.
- **Empty text converted to NULL:** the importer reads empty cells as empty text rather than true blanks, so `COUNT()` treats them as values. Converted to NULL in `account`, `engage_date`, `close_date`, `close_value` and `subsidiary_of`.
- **Column types set:** everything imports as TEXT. Changed `close_value` and `sales_price` to INTEGER, `revenue_m` to REAL and `employees` to INTEGER, so calculations and sorting work correctly.
- **Issue found by verification query:** after import, all Engaging and Prospecting deals still counted as having a close value. A diagnostic query showed these were 0s introduced by the `=VALUE()` conversion in Excel.
  - **Fix:** set `close_value` and `close_date` to NULL for all Engaging and Prospecting deals, and `engage_date` to NULL for Prospecting deals. Justified by the stage logic validated during Excel cleaning: open deals cannot have a close value or close date.

### Final verification
Count of non-blank values per stage:

| Stage | Deals | Close value | Close date | Engage date | Account |
|---|---|---|---|---|---|
| Won | 4,238 | 4,238 | 4,238 | 4,238 | 4,238 |
| Lost | 2,473 | 2,473 | 2,473 | 2,473 | 2,473 |
| Engaging | 1,589 | 0 | 0 | 1,589 | 501 |
| Prospecting | 500 | 0 | 0 | 0 | 163 |

All counts match the stage logic validated in Excel.
