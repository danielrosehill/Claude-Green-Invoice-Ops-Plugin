---
name: gi-generate-billing-document
description: Generate a Green Invoice billing document (invoice, tax invoice, invoice-receipt, receipt, quote) correctly, including an English copy for clients abroad or English-speaking clients, and retrieve the right-language PDF. Use for "invoice client X", "make an English invoice", "get the English version of invoice 1234".
---

# Generate a billing document (with an English copy when needed)

Builds on the `greeninvoice-ops` skill's create flow and safety rules: resolve client and items,
confirm, then create. This skill adds the checks that make the document usable, and the
language handling.

## Document type

| Type | Code | When |
|---|---|---|
| Quote / price offer | 10 | Before work is agreed |
| Order | 100 | Confirmed order |
| Transaction / proforma invoice (חשבון עסקה) | 300 | Request payment without a tax document yet |
| Tax invoice | 305 | Work done, payment later |
| Tax invoice-receipt | 320 | Paid at once (needs `payment` rows) |
| Receipt | 400 | Payment against an earlier invoice (`linkedDocumentIds`) |

If unsure, `document` `action: get_types`. Confirm the type; a 305 vs 320 mistake needs a credit
note to fix.

## Language

- Set `lang: "en"` at creation for clients outside Israel or who don't read Hebrew (memory
  `email.englishClients`, or the client's `country` is not IL). Then `download_links` returns an
  `en` copy. Otherwise `lang: "he"`.
- An English copy exists only if the document was made with it; `download_links` omits `en`
  otherwise (per Morning's OpenAPI spec). An already-closed Hebrew document can't be re-languaged
  through the API; offer to check the Green Invoice app or issue future documents in English.
- English documents need English text: client name/address, line descriptions, `remarks`.
  Translate them before creating and show the user the English wording.
- Foreign clients: usually `currency` USD/EUR/GBP and VAT type for export of services (0%,
  `vatType` per item; confirm with the user or their accountant, don't guess).

## Steps

1. Resolve the client (`client` `action: search`); check name, tax ID, emails, country.
2. Resolve items (`item` `action: search`) or take free-text lines; set price, quantity,
   currency, VAT type.
3. Decide type and language as above. Decide email behaviour: put addresses in `client.emails`
   for Green Invoice's own email, or leave them out and use `gi-email-document` afterwards.
4. `document` `action: preview` with the full payload. Show the user the totals (net, VAT, gross,
   currency) and the language.
5. On explicit confirmation, `document` `action: create`.
6. `document` `action: download_links`; give the user the link in the requested language and the
   document number. Offer `gi-email-document` and `gi-copy-to-drive` as next steps.
