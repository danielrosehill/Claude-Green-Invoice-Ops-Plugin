#!/usr/bin/env bash
# Shrink a PDF until it fits Green Invoice's expense upload limit.
# Usage: compress-pdf.sh <in.pdf> [out.pdf] [--max-bytes N]
# Default limit 20971520 (20 MB): the maxFileSize the file-upload service returned on 2026-11-03.
# Tries Ghostscript presets from mildest to strongest (/printer 300 dpi, /ebook 150 dpi, /screen 96 dpi) and
# stops at the first that fits. Prints one JSON line; exit 0 = fits, 2 = still too big, 1 = error.
set -euo pipefail
in="${1:?usage: compress-pdf.sh <in.pdf> [out.pdf] [--max-bytes N]}"; shift
out=""; max=20971520
while [ $# -gt 0 ]; do
  case "$1" in --max-bytes) max="$2"; shift 2;; *) out="$1"; shift;; esac
done
[ -n "$out" ] || out="${in%.pdf}.compressed.pdf"
command -v gs >/dev/null || { echo '{"ok":false,"error":"ghostscript (gs) not installed; run skill gi-setup-environment"}'; exit 1; }
size() { stat -c %s "$1" 2>/dev/null || stat -f %z "$1"; }
orig=$(size "$in")
if [ "$orig" -le "$max" ]; then
  cp "$in" "$out"; echo "{\"ok\":true,\"preset\":\"none\",\"in_bytes\":$orig,\"out_bytes\":$orig,\"out\":\"$out\"}"; exit 0
fi
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
for p in printer ebook screen; do
  gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dPDFSETTINGS=/$p \
     -dDetectDuplicateImages=true -sOutputFile="$tmp/$p.pdf" "$in"
  s=$(size "$tmp/$p.pdf")
  if [ "$s" -le "$max" ]; then
    mv "$tmp/$p.pdf" "$out"; echo "{\"ok\":true,\"preset\":\"$p\",\"in_bytes\":$orig,\"out_bytes\":$s,\"out\":\"$out\"}"; exit 0
  fi
done
mv "$tmp/screen.pdf" "$out"
echo "{\"ok\":false,\"preset\":\"screen\",\"in_bytes\":$orig,\"out_bytes\":$(size "$out"),\"out\":\"$out\",\"error\":\"still over $max bytes; split the PDF or upload the relevant pages\"}"; exit 2
