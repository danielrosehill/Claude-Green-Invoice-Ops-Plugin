---
name: gi-copy-to-drive
description: Copy Green Invoice documents and expense files (invoices, receipts, quotes, expenses) into the user's Google Drive folders, remembering which folder each type goes in. Use after generating something in Green Invoice, or for "save this month's invoices to Drive", "file the receipt in my accounts folder", "set up my Drive folders for Green Invoice".
---

# Copy Green Invoice documents to Drive

Uses `{{FILE_STORE}}` and `{{FETCH}}` and relies on the plugin memory's `drive` section. Read
`${CLAUDE_PLUGIN_ROOT}/references/user-tools-and-memory.md` first.

## First run: learn the folders

If memory has no `drive.folders` entry for the document type at hand:

1. Ask where that type should go. Accept a folder name, path or Drive URL. Look it up with
   `{{FILE_STORE}}` (search by name, or take the ID from the URL) and confirm the match.
2. Ask whether to sort into subfolders (`year`, `year-month`, or none) and the filename pattern
   (default `{date}_{type}_{number}_{client}.pdf`, date as `YYYY-MM-DD`).
3. Save to memory. Next time, go straight to copying and say which folder you're using.

## Copying

1. **Pick the documents.** One just created, a number, or a range (`document` `action: search`
   with `fromDate`/`toDate` and types; `expense` `action: search` for expenses).
2. **Get the file.**
   - Documents: `document` `action: download_links`. Use `origin` unless the user wants the
     Hebrew or English copy (`he`/`en`); they can ask for both.
   - Expenses: `expense` `action: get`; `url` is the attached file's download link, present
     only when a file is attached. No `url` means no file: list it as skipped.
   Download each with `{{FETCH}}` and check it is a non-empty PDF/image.
3. **Skip what's already there.** List the target folder and skip files whose name already
   exists, unless the user says to overwrite.
4. **Upload** with `{{FILE_STORE}}` to the folder (create the year/month subfolder if missing).
5. **Report** a short list: file name → folder, plus anything skipped and why.

## Notes

- For a whole month, fetch in batches (the API allows ~3 requests/s).
- If a remembered folder ID fails, ask again and overwrite the memory entry.
- If `{{FILE_STORE}}` is a local synced folder (Drive for Desktop, rclone mount), copy the file
  there with the shell instead.
