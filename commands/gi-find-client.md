---
description: Search Green Invoice clients by name or ID and report their balance and recent documents.
---

Given a client name substring or ID from the user:

1. `client` with `action: search` (by name) or `action: get` (by ID).
2. If multiple matches, list them and ask the user to pick before continuing.
3. For the chosen client, fetch `action: balance` and any recent documents (via `document` `action: search` filtered by `clientId`).

Report: client name, ID, email, phone, current balance, and the last 5 documents with number, date, type, and amount.
