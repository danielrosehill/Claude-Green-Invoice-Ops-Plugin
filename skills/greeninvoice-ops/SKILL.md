---
name: greeninvoice-ops
description: Conduct operations against the Green Invoice MCP server — create and search documents (invoices, receipts, quotes), manage clients, suppliers, items, expenses, payments, and webhooks. Use when the user wants to query or modify data in their Green Invoice account.
---

# Green Invoice Ops

This skill guides operations against the **Green Invoice MCP** server (unofficial third-party MCP for the Israeli invoicing platform at greeninvoice.co.il).

## Prerequisite

The Green Invoice MCP server must be installed and connected. Tools are exposed under an `*greeninvoice*` namespace with ten consolidated entry points:

- `account` — account info and settings
- `business` — business config, numbering, file uploads
- `client` — client CRUD, search, merge, balance
- `document` — invoices, receipts, quotes (create, search, update, close, reopen, send, preview)
- `expense` — expense tracking, drafts, accounting classifications
- `item` — product/service catalog
- `payment` — payment forms, credit-card tokens, payment links
- `reference_data` — business categories, countries, cities, FX rates
- `supplier` — supplier CRUD, search, merge
- `webhook` — webhook subscriptions

Each tool takes an `action` argument (e.g. `search`, `create`, `get`, `update`, `close`) plus action-specific parameters. If you are unsure which action a tool supports, call it with no arguments or with a deliberately invalid action to get a schema error listing the valid ones.

## Common workflows

### 1. Find a client and create an invoice

1. `client` with `action: search` and a `name` substring to get the client ID.
2. `item` with `action: search` (or list) to get the item IDs you want to bill.
3. `document` with `action: create`, `type: invoice` (or the relevant document type), `client: {id: ...}`, `income: [{...}]`, and any VAT/currency fields required.

Always confirm the resolved client and line items back to the user **before** creating the document. Invoices in Green Invoice, once closed, cannot be deleted — only cancelled via credit note.

### 2. Record an expense

1. `supplier` with `action: search` → supplier ID (create one with `action: create` if not found).
2. `expense` with `action: create`, supplier reference, amount, VAT, category, and date.

### 3. Monthly summary

1. `document` with `action: search`, filter by `fromDate` / `toDate` for the month, income document types.
2. `expense` with `action: search`, same date range.
3. Aggregate totals by currency; report VAT collected vs. VAT paid.

### 4. Send an existing invoice

1. `document` with `action: search` to locate the document ID.
2. `document` with `action: send` and recipient emails.

## Safety rules

- **Never create, close, or cancel documents without explicit user confirmation.** These affect the user's accounting records and (in Israel) tax filings.
- Prefer **search / preview / get** actions when the user is exploring. Only move to mutating actions (`create`, `update`, `close`, `delete`) once the intent is clear.
- If the account is in **sandbox mode**, say so in the response so the user knows the operation did not touch production data.
- Dates: Green Invoice uses ISO `YYYY-MM-DD`. The user types dates as DD/MM/YY — convert silently.
- Currency: default ILS unless the user says otherwise.
- Numbers: Israeli VAT is currently 18% (as of 2025). Confirm if the user asks about a different rate.

## Error handling

- Rate limit (~3 req/s): batch lookups instead of looping one-by-one.
- JWT expiry: the MCP refreshes automatically; if you see an auth error twice in a row, tell the user to check the API credentials.
- Missing required fields: the API error usually names the field — surface it verbatim rather than guessing.

## Fallback resources

If the Green Invoice MCP appears broken, out of date, or missing an endpoint the user needs, do **not** silently give up — fall back to one of these third-party surfaces over the same API. Green Invoice has since rebranded to **Morning** (`greeninvoice.co.il`), and these projects track the current API.

Preference order:

1. **[`morning-cli`](https://github.com/Jango-AI-com/morning-cli)** (JangoAI) — agent-native Python CLI covering all 66 endpoints, with JSON envelopes designed for AI consumption, an interactive REPL, and onboarding wizard. Install: `pip install morning-cli`. Use when the MCP fails on a specific endpoint or when you need a quick one-shot call from the shell.
2. **[`D1DX/morning-skill`](https://github.com/D1DX/morning-skill)** (D1DX) — full API skill for AI agents. Clients/suppliers/items/documents/payments/business/reference-data run through `morning-cli`; expenses, file upload with OCR, and classifications are documented as raw API Python patterns against the official Apiary spec. Use when you need the two-step presigned-S3 expense-upload flow or bulk expense imports — scenarios the MCP does not cover well.

Rules when falling back:

- Tell the user you are switching away from the MCP and why (e.g. "the MCP returned a schema error on `expense.create`, dropping to `morning-cli`").
- Credentials live in the same Green Invoice API ID / Secret pair — do not re-prompt unless the tool fails auth.
- If you use raw API calls (from the `morning-skill` patterns), remember: sandbox vs. production base URL, `requests` library required for multipart uploads, and expense file processing is async (5–15 s) — poll before reporting success.
- Keep mutation safety rules identical to the MCP path: confirm before `create` / `close` / `delete`.

## Disclaimer

The underlying MCP is unofficial and not affiliated with Green Invoice / Morning (Optimax Ltd). The fallback resources above are likewise third-party. Always verify consequential operations (closing invoices, issuing credit notes, bulk edits) in the official Morning dashboard afterward.
