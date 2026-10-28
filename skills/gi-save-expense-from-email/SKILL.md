---
name: gi-save-expense-from-email
description: Find a business expense (receipt, bill, supplier invoice) in the user's email, download the attachment, upload it to Green Invoice and check the details with the user. Use for "save this expense from my inbox", "log the receipt from X's email", "upload my expenses from Gmail to Green Invoice".
---

# Save an expense from email to Green Invoice

Uses tool placeholders `{{EMAIL_SEARCH}}`, `{{EMAIL_ATTACHMENT}}` and the plugin memory. Read
`${CLAUDE_PLUGIN_ROOT}/references/user-tools-and-memory.md` first and resolve them.

## Steps

1. **Find the email.** Search with `{{EMAIL_SEARCH}}` from what the user said (supplier, subject,
   date, "the one I starred"). Useful default query for Gmail: `has:attachment newer_than:30d
   (receipt OR invoice OR חשבונית OR קבלה)`. If several match, list them (date, sender, subject,
   attachment names) and let the user pick. Several expenses at once is fine; handle each in turn.
2. **Pick the attachment.** Prefer the PDF. Skip signature images and logos. If the expense is
   only in the email body (no attachment), say so; offer to log it with `expense` `action: create`
   by hand instead (the `/gi-log-expense` flow).
3. **Download it** with `{{EMAIL_ATTACHMENT}}` as base64, or get a URL the MCP server can fetch.
4. **Check for a duplicate.** `expense` `action: search` and `action: search_drafts` for the
   same supplier and amount around that date. If one exists, show it and ask before continuing.
5. **Upload.** `expense` `action: upload_file` with `{filename, contentType, file}` (or `url`).
   No `expenseId`, so Green Invoice OCRs it into an expense **draft** (5–60 s).
   - To attach the file to an expense that already exists instead, pass its `expenseId`.
6. **Read the draft back.** Poll `expense` `action: search_drafts` until it appears (every ~10 s,
   give up after ~90 s and tell the user it is still processing).
7. **Validate with the user.** Show supplier, supplier tax ID, date, document number, amount,
   currency, VAT and suggested category next to what the email itself says. Flag differences
   (OCR often misreads VAT, foreign currency and dates in DD/MM vs MM/DD).
8. **Fix and approve.** Correct fields the user changes. Drafts are approved by a human in the
   Green Invoice app; if the user wants it fully recorded now, create the expense with
   `expense` `action: create` from the confirmed values and attach the file with
   `upload_file` + `expenseId`. Confirm the payload before any `create`.
9. **Report** the draft or expense ID and what is left for the user to do in the app.

## Notes

- Foreign-currency receipts (SaaS, Amazon): keep the original currency; Green Invoice converts.
- Reported expenses (status 20) cannot take files.
- If the user does this regularly, suggest `gi-setup-expense-mailhook` once so forwarded
  emails upload themselves.
