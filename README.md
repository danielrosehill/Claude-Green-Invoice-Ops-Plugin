# Greeninvoice-Ops

A Claude Code plugin for conducting operations against the [Green Invoice MCP](https://github.com/danielrosehill/GreenInvoice-MCP) server — the unofficial MCP wrapper around the [Green Invoice](https://www.greeninvoice.co.il/) Israeli invoicing API.

Bundles a skill that teaches Claude how to safely drive the ten consolidated MCP tools (`document`, `client`, `supplier`, `item`, `expense`, `payment`, `account`, `business`, `reference_data`, `webhook`) plus slash commands for the most common day-to-day workflows.

## Prerequisite

The Green Invoice MCP server must be installed and connected. See [GreenInvoice-MCP](https://github.com/danielrosehill/GreenInvoice-MCP) for installation and API-credential setup.

## Skills

- `greeninvoice-ops` — operational guide: tool layout, common workflows (create invoice, log expense, monthly summary), safety rules, Israeli VAT / date / currency conventions.

## Commands

- `/gi-status` — account / business snapshot, sandbox check
- `/gi-find-client` — search clients and report balance + recent documents
- `/gi-recent-documents` — list recent invoices, receipts, quotes with optional filters
- `/gi-create-invoice` — interactive invoice creation with confirmation gate
- `/gi-log-expense` — log a new expense against a supplier
- `/gi-send-document` — send an existing document by email
- `/gi-monthly-summary` — income, expenses, VAT position, top clients / suppliers

## Installation

```bash
claude plugins marketplace add danielrosehill/Claude-Code-Plugins
claude plugins install greeninvoice-ops@danielrosehill
```

## Disclaimer

This plugin and the underlying MCP server are **unofficial** and not affiliated with, endorsed by, or supported by Green Invoice (Optimax Ltd). Always verify consequential operations in the official Green Invoice dashboard.

## License

MIT — see [LICENSE](LICENSE).
