---
description: Log an expense in Green Invoice — resolve supplier, capture amount and VAT, then create.
---

1. Ask for / infer the **supplier**. Resolve via `supplier` `action: search`; offer to `create` if not found.
2. Capture **amount**, **currency** (default ILS), **VAT rate and amount**, **date**, and **category** (use `reference_data` `action` for business categories if the user is unsure).
3. Summarise the payload and wait for explicit confirmation.
4. Call `expense` `action: create`.
5. Report the new expense ID and totals.
