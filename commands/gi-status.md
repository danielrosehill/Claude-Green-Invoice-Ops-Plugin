---
description: Snapshot of the Green Invoice account — business info, sandbox status, and document numbering state.
---

Query the Green Invoice MCP for:

1. `business` `action: get` → business name, VAT ID, default currency.
2. `business` `action: get_numbering` → current document numbering per series.
3. `sandbox` `action: status` → whether sandbox credentials are configured.

(`account get` answers 403 for API-key auth on the accounts tested, so it is not used here.)

Report concisely: business name, VAT ID, sandbox vs. production, and the next invoice / receipt number per series. Flag anything that looks unusual (e.g. sandbox mode when the user expects production).
