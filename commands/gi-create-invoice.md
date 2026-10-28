---
description: Walk through creating a new invoice in Green Invoice — resolve client, line items, confirm, then create.
---

Interactive invoice creation. Do NOT create the document until the user has confirmed the final payload.

1. Ask for / infer the **client** (name or ID). Resolve via `client` `action: search`.
2. Ask for / infer the **line items** — description, quantity, unit price, VAT. Resolve catalog items via `item` `action: search` where possible.
3. Ask for **currency** (default ILS), **issue date** (default today), **due date** if relevant, and whether Green Invoice should **email** it: if yes, put the recipient addresses in `client.emails`. This is the only point at which Green Invoice sends a document.
4. Present the full payload back to the user as a summary. Wait for explicit confirmation.
5. On confirmation, call `document` `action: create` with `type: invoice` (or the type the user requested — tax invoice, proforma, receipt, etc.).
6. Report the new document number, ID, total, and who it was emailed to (if anyone). To share it later, use `/gi-send-document`.
