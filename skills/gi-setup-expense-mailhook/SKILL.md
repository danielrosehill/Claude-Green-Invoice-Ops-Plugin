---
name: gi-setup-expense-mailhook
description: Guide the user through setting up an expense mail hook, so emails they flag or label in Gmail (or any client) are forwarded automatically and land in Green Invoice as expense drafts. Use for "set up expense forwarding", "auto-upload my receipts", "mail hook for Green Invoice".
---

# Set up an expense mail hook

The goal: the user labels or flags a receipt email, a rule forwards it, and the attachment
becomes a Green Invoice expense draft with no agent in the loop. This is a guided setup: most
steps happen in the user's own accounts, so walk them through and verify, don't assume.

Read `${CLAUDE_PLUGIN_ROOT}/references/user-tools-and-memory.md` first. Check memory for an
existing `expenseMailhook` entry; if one is there, offer to test or change it instead.

## 1. Choose the receiving end

Ask which the user wants, recommending A if their plan has it:

- **A. Green Invoice's own expense inbox.** Green Invoice (Morning) can give a business a
  dedicated address that turns emailed receipts into expense drafts. Have the user look in the
  web app under the expenses settings for the mail-in address (availability depends on the plan;
  this skill has not confirmed the exact menu path). If they find it, that address is the hook.
  Nothing to host.
- **B. A custom webhook.** For users without A, or who want filtering or logging. An inbound-mail
  service receives the forward and calls the Green Invoice API's expense upload with the
  attachment. Placeholders for the user's own stack:
  - `{{INBOUND_MAIL}}`: what receives the email and runs code. Examples: Cloudflare Email Routing
    + an Email Worker, Mailgun/SendGrid/Postmark inbound parse → a serverless function, n8n or
    Make with an email trigger.
  - `{{GI_API_CREDENTIALS}}`: the Green Invoice API key ID and secret, stored in that platform's
    secret store, never in code.
  - The handler, per attachment (PDF/PNG/JPG/GIF, ≤ 16 MB): get an OAuth token
    (`POST https://api.morning.co/idp/v1/oauth/token`, client credentials), get a presigned upload
    from `GET https://apigw.greeninvoice.co.il/file-upload/v1/url?context=expense&data={"source":5}`,
    POST the file to it (all returned fields first, file last). Green Invoice OCRs it into a draft.
    This is the same flow the MCP's `expense` `upload_file` uses; the MCP README documents it.
  - Restrict the handler to mail from the user's own address(es) so strangers can't post expenses.

## 2. Create the forwarding rule

Walk the user through it in their client (do it for them only if `{{EMAIL_SEARCH}}`/settings
tools can manage filters):

- **Gmail:** Settings → Forwarding and POP/IMAP → *Add a forwarding address* → enter the hook
  address → confirm the verification code (for A, check whether Green Invoice shows it; for B,
  the handler must surface it, e.g. log it). Then add a filter that forwards matching mail, for
  example *to:you+expense@gmail.com* (the user sends or forwards receipts to that alias) or
  *from:billing@supplier.com* for regular suppliers.
- **Outlook:** Rules → *Forward to* the hook address when a category or flag condition matches
  (Outlook rules can match categories; Gmail filters can't match a label applied later).
- **Apple Mail / others:** a rule on a mailbox or flag colour, or forward manually.

Say plainly: Gmail filters only run on arrival, so "label it later and it forwards" needs either
manual forwarding, an alias, or a script (Apps Script on a timer that forwards messages with the
label and then removes it).

## 3. Test it

1. Have the user forward one real receipt.
2. Poll `expense` `action: search_drafts` for up to ~2 minutes. Confirm the draft's supplier and
   amount match the receipt.
3. If nothing arrives: check the forwarding verification, the filter criteria, and (B) the
   handler logs.

## 4. Save it

Write `expenseMailhook` to memory: method, address, the rule as configured, and today's date.
