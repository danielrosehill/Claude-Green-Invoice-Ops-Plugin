# Greeninvoice-Ops

A Claude Code plugin for conducting operations against the [Green Invoice MCP](https://github.com/danielrosehill/GreenInvoice-MCP) server — the unofficial MCP wrapper around the [Green Invoice](https://www.greeninvoice.co.il/) Israeli invoicing API.

Bundles a skill that teaches Claude how to safely drive the eleven consolidated MCP tools (`document`, `client`, `supplier`, `item`, `expense`, `payment`, `account`, `business`, `reference_data`, `webhook`, `sandbox`) plus slash commands for the most common day-to-day workflows.

## Prerequisite

The Green Invoice MCP server must be installed and connected. See [GreenInvoice-MCP](https://github.com/danielrosehill/GreenInvoice-MCP) for installation and API-credential setup. It is published on npm as [`greeninvoice-mcp`](https://www.npmjs.com/package/greeninvoice-mcp) (`npx -y greeninvoice-mcp`); this plugin is written against 0.5.1.

## Skills

- `greeninvoice-ops` — operational guide: tool layout, common workflows (create invoice, log expense, monthly summary), safety rules, Israeli VAT / date / currency conventions.
- `gi-save-expense-from-email` — find a receipt in the inbox, download the attachment, upload it to Green Invoice (OCR draft), validate the details with the user.
- `gi-setup-expense-mailhook` — guided setup so flagged or forwarded receipt emails land in Green Invoice automatically (Green Invoice's own mail-in address, or a custom inbound-mail webhook).
- `gi-email-document` — email an issued document from the user's own mailbox with the PDF attached and a personal note, with or without Green Invoice's automatic emails.
- `gi-generate-billing-document` — create invoices, receipts and quotes with the right type, and an English copy for clients abroad or English-speaking clients.
- `gi-copy-to-drive` — copy generated documents and expense files into Google Drive folders, remembering which folder each type goes in.

### Your tools and memory

The workflow skills need an email tool and a file store that this plugin doesn't ship. They refer to them by role (`{{EMAIL_SEARCH}}`, `{{EMAIL_ATTACHMENT}}`, `{{EMAIL_SEND}}`, `{{FILE_STORE}}`, `{{FETCH}}`) and resolve them to whatever is connected, such as a Google Workspace MCP. Choices, Drive folder IDs and the mail-hook address are kept in a local JSON memory file whose location you choose on first run (default `~/.config/greeninvoice-ops/memory.json`, or set `$GREENINVOICE_OPS_MEMORY`). Details: [references/user-tools-and-memory.md](references/user-tools-and-memory.md).

## Commands

- `/gi-status` — account / business snapshot, sandbox check
- `/gi-find-client` — search clients and report balance + recent documents
- `/gi-recent-documents` — list recent invoices, receipts, quotes with optional filters
- `/gi-create-invoice` — interactive invoice creation with confirmation gate
- `/gi-log-expense` — log a new expense against a supplier
- `/gi-send-document` — email an existing document's download link
- `/gi-monthly-summary` — income, expenses, VAT position, top clients / suppliers

## Installation

```bash
claude plugins marketplace add danielrosehill/Claude-Code-Plugins
claude plugins install greeninvoice-ops@danielrosehill
```

## Fallback resources

If the Green Invoice MCP is out of date or missing an endpoint, the skill falls back to these third-party surfaces for the same API (Green Invoice → Morning):

- [`morning-cli`](https://github.com/Jango-AI-com/morning-cli) — agent-native Python CLI covering all 66 endpoints (`pip install morning-cli`). First fallback.
- [`D1DX/morning-skill`](https://github.com/D1DX/morning-skill) — AI-agent skill documenting raw API patterns for expenses, OCR file upload, and classifications where the MCP is thin.

## Disclaimer

This plugin and the underlying MCP server are **unofficial** and not affiliated with, endorsed by, or supported by Green Invoice (Optimax Ltd). Always verify consequential operations in the official Green Invoice dashboard.

## License

MIT — see [LICENSE](LICENSE).
