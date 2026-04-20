---
description: Produce a monthly summary of Green Invoice activity — income, expenses, VAT, top clients.
---

Given a month (default: last complete month):

1. `document` `action: search` for income document types in `[fromDate, toDate]`.
2. `expense` `action: search` for the same range.
3. Aggregate by currency:
   - Total income (gross and net of VAT)
   - Total expenses (gross and net of VAT)
   - Net VAT position (collected minus paid)
4. Top 5 clients by income, top 5 suppliers by spend.
5. Report as a concise markdown summary. Offer to export to PDF via the `typst-document-generator` plugin if the user wants a formatted version.
