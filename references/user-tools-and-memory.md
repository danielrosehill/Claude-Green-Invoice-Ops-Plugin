# Your tools and the plugin's memory

The workflow skills in this plugin (`gi-save-expense-from-email`, `gi-setup-expense-mailhook`,
`gi-email-document`, `gi-generate-billing-document`, `gi-copy-to-drive`) need tools this plugin
does not ship: an email client and a file store. They name them by **role**, not by tool name,
because every user's setup differs. Read this file before running any of them.

## Tool roles (placeholders)

| Placeholder | What it must do | Common examples |
|---|---|---|
| `{{EMAIL_SEARCH}}` | Search the user's inbox, read a message, list its attachments | Google Workspace MCP `search_gmail_messages` / `get_gmail_message_content`; an Outlook/Graph MCP; IMAP CLI |
| `{{EMAIL_ATTACHMENT}}` | Download an attachment's bytes (base64) or give a fetchable URL | Google Workspace MCP `get_gmail_attachment_content` |
| `{{EMAIL_SEND}}` | Send a message, ideally with a file attachment | Google Workspace MCP `send_gmail_message`; Resend; Outlook MCP |
| `{{FILE_STORE}}` | List folders and upload a file into a chosen folder | Google Drive MCP `search_drive_files` / `list_drive_items` / `create_drive_file`; rclone; a synced local folder |
| `{{FETCH}}` | Download a file from an HTTPS URL to bytes | Built-in WebFetch is text-only, so prefer `curl -sL -o` in the shell |

Resolving a placeholder:

1. If the memory file (below) has a `tools` entry for the role, use it.
2. Otherwise look at the tools actually connected in this session and pick the obvious match.
   If two fit (e.g. a personal and a business Gmail server), ask which one and save the answer.
3. If nothing fits, say which role is missing and stop at the step that needs it. Give the user
   what they need to finish by hand (a download link, a file path). Do not pretend the step ran.

## Persistent memory

The skills keep a small JSON memory of things that should not be asked twice: which tool fills
each role, the Drive folder for each document type, the expense mail-in address, the user's
default email wording.

### Where it lives

1. If `$GREENINVOICE_OPS_MEMORY` is set, that path is the memory file.
2. Else, if `~/.config/greeninvoice-ops/location` exists, its single line is the path.
3. Else this is the first run. Ask the user once: *"Where should I keep greeninvoice-ops memory?
   (default `~/.config/greeninvoice-ops/memory.json`)"*. Write their answer (or the default) to
   `~/.config/greeninvoice-ops/location`, create the file with `{}` if missing, and continue.

The user can point the location at a synced folder (Dropbox, a repo, Drive for Desktop) to share
it across machines. Never store API keys, passwords or tokens in it.

### Shape

```json
{
  "tools": {
    "EMAIL_SEARCH": "mcp__google-workspace__search_gmail_messages",
    "EMAIL_ATTACHMENT": "mcp__google-workspace__get_gmail_attachment_content",
    "EMAIL_SEND": "mcp__google-workspace__send_gmail_message",
    "FILE_STORE": "mcp__google-workspace__create_drive_file",
    "account": "me@example.com"
  },
  "drive": {
    "root": {"id": "1AbC...", "name": "Accounts"},
    "folders": {
      "invoice":  {"id": "1DeF...", "name": "Accounts/Invoices",  "subfolderBy": "year"},
      "receipt":  {"id": "1GhI...", "name": "Accounts/Receipts",  "subfolderBy": "year"},
      "expense":  {"id": "1JkL...", "name": "Accounts/Expenses",  "subfolderBy": "year-month"}
    },
    "filename": "{date}_{type}_{number}_{client}.pdf"
  },
  "expenseMailhook": {
    "method": "greeninvoice-inbox | custom-webhook",
    "address": "…",
    "configuredOn": "2026-10-28",
    "emailRule": "Gmail filter: label 'expense' → forward to address"
  },
  "email": {
    "signature": "…",
    "defaultCc": [],
    "englishClients": ["client-id-1", "client-id-2"]
  },
  "updated": "2026-10-28"
}
```

All keys are optional; add only what a run actually learned.

### Rules

- Read the file at the start of a skill run. Write back only keys that changed, keep the rest,
  and update `updated` with an absolute date.
- Tell the user in one line when you save something new ("Saved Invoices folder to memory").
- If a remembered ID fails (folder deleted, tool renamed), say so, ask again, and overwrite.
