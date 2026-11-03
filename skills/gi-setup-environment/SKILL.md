---
name: gi-setup-environment
description: Check and install the local tools this plugin's scripts need on a new machine (Ghostscript, for compressing expense PDFs over the upload limit), then verify. Use for "set up the Green Invoice plugin on this machine", "install what the plugin needs", "compress-pdf says gs is missing", or before the first expense upload on a new system.
---

# Set up the local environment

The plugin ships scripts in `${CLAUDE_PLUGIN_ROOT}/scripts/`. Today one external tool is needed:

| Tool | Used by | Why |
|---|---|---|
| Ghostscript (`gs`) | `scripts/compress-pdf.sh` | Expense uploads are capped (the file-upload service returned `maxFileSize` 20971520 = 20 MB on 2026-11-03). Scanned PDFs over that are recompressed before upload. |

## Steps

1. **Check.** Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh`. It prints one JSON line and exits 0
   when everything is present. If it does, stop here and report the versions.
2. **Install what is missing**, with the system's package manager. Detect it, don't guess:
   - Debian/Ubuntu: `sudo apt-get install -y ghostscript`
   - Fedora/RHEL: `sudo dnf install -y ghostscript`
   - Arch: `sudo pacman -S --noconfirm ghostscript`
   - macOS (Homebrew): `brew install ghostscript`
   - Windows: `winget install ArtifexSoftware.GhostScript` (or use WSL and the Linux line)
   `sudo` may prompt for a password. If it can't run unattended, give the user the exact command
   to run (in Claude Code: `! sudo apt-get install -y ghostscript`).
3. **Verify.** Run `check-env.sh` again; it must exit 0. Then run a smoke test: make a one-page PDF
   (`gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=/tmp/gi-test.pdf -c "showpage"`) and
   `compress-pdf.sh /tmp/gi-test.pdf /tmp/gi-test-out.pdf`. Expect `"ok":true`. Delete both files.
4. **Report** what was installed, the versions and the check result.

## Notes

- Server-side hooks (for example a Cloudflare Email Worker running `gi-setup-expense-mailhook`
  option B) can't run Ghostscript. They should skip an oversize file and log it, and an agent then
  compresses and uploads it with `gi-save-expense-from-email`.
- When a new script adds a tool, add a row to the table above and a check to `check-env.sh`.
