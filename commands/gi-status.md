---
description: Snapshot of the Green Invoice account — business info, sandbox status, and document numbering state.
---

Query the Green Invoice MCP for:

1. `account` → current account info, user email, sandbox flag.
2. `business` → business name, VAT ID, default currency, current document numbering ranges.

Report concisely: business name, VAT ID, sandbox vs. production, and the next invoice / receipt number per series. Flag anything that looks unusual (e.g. sandbox mode when the user expects production).
