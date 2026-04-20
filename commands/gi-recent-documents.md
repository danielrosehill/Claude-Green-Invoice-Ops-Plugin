---
description: List recent Green Invoice documents — invoices, receipts, quotes — with optional filters.
---

Default: the last 20 documents across all types, newest first.

Support optional filters from the user:
- document type (invoice, tax invoice, receipt, quote, credit note, proforma)
- client name or ID
- date range
- status (open, closed, cancelled)

Call `document` `action: search` with the relevant filters. Report in a compact table: number, date, type, client, amount, status.
