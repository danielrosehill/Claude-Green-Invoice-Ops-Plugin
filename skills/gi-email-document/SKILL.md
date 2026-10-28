---
name: gi-email-document
description: Email a Green Invoice document (invoice, receipt, quote) to a client from the user's own mailbox, with the PDF attached and a personal note. Use when Green Invoice's automatic emails are off, or alongside them for a personal touch. Triggers on "email the invoice to X myself", "send the receipt with a note", "attach the invoice and write to the client".
---

# Email a Green Invoice document personally

The Green Invoice API has no send call; it emails only at creation, to `client.emails`. This
skill sends from the user's own mailbox instead, so the client gets a normal personal email with
the PDF attached. It works whether automatic emails are on or off; if they're on, mention the
client will also get Green Invoice's own email (or already did).

Uses `{{EMAIL_SEND}}` and `{{FETCH}}`. Read
`${CLAUDE_PLUGIN_ROOT}/references/user-tools-and-memory.md` first.

## Steps

1. **Resolve the document.** By number, ID or description via `document` `action: search` /
   `get`. Confirm number, type, client, amount, date and status.
2. **Recipients.** Default to the client's emails (`client` `action: get`). Add `defaultCc` from
   memory. Confirm.
3. **Language.** If the client is abroad, English-speaking, or listed in memory
   `email.englishClients`, use the English copy and write in English; otherwise Hebrew copy and
   the user's usual language. See `gi-generate-billing-document` for why an English copy may not
   exist.
4. **Get the PDF.** `document` `action: download_links` returns `{he, en, origin}`; `en` only
   when an English copy exists. Download the chosen link with `{{FETCH}}` (e.g.
   `curl -sL -o /tmp/gi/<number>.pdf "<url>"`) and check it is a PDF (`file` says PDF, size > 0).
   Name it like `Invoice-<number>-<BusinessName>.pdf`.
5. **Draft the note.** Short and personal: what the document is, the amount and due date, how to
   pay if relevant, thanks. Use the memory `email.signature` if set. Show the draft unless the
   user said to just send it.
6. **Send** with `{{EMAIL_SEND}}`, attaching the PDF. If the email tool can't attach files,
   include the download link in the body instead and say so.
7. **Report** who it went to and the attachment name. Offer to save new preferences (CC,
   signature, English-client flag) to memory.

## Notes

- Download links are long-lived but not permanent; attach the file rather than linking when you
  can.
- Never send a draft (unclosed preview) as if it were the issued document.
