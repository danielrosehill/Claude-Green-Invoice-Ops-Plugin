---
description: Send an existing Green Invoice document to a client by email.
---

1. Resolve the **document** — by number, ID, or description. Use `document` `action: search` if needed.
2. Confirm the document (number, client, amount, status) back to the user.
3. Ask for / infer the **recipient email(s)**. Default to the client's email on file.
4. Call `document` `action: send` with the document ID and recipient list.
5. Report success and the email(s) the document was sent to.
