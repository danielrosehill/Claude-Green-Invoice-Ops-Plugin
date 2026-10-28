---
description: Share an existing Green Invoice document with a client — get its download link and email it.
---

The Green Invoice API has no "send document" call (removed from the MCP in 0.5.0; the route does not exist). Green Invoice emails a document only at creation, to the addresses in `client.emails`. For an existing document:

1. Resolve the **document** — by number, ID, or description. Use `document` `action: search` if needed.
2. Confirm the document (number, client, amount, status) back to the user.
3. Ask for / infer the **recipient email(s)**. Default to the client's email on file (`client` `action: get`).
4. Call `document` `action: download_links` to get the PDF link(s).
5. Email the link with whatever email tool this environment has (Gmail/Workspace, Resend, …), after confirming the recipients and wording. If no email tool is available, give the user the link to send themselves.
6. Report the email(s) it went to.
