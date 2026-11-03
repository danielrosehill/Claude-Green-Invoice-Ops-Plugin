#!/usr/bin/env bash
# Report whether the local tools this plugin's scripts need are installed. One JSON line; exit 0 = all present.
gs_v=$(gs --version 2>/dev/null || true)
ok=true; [ -n "$gs_v" ] || ok=false
echo "{\"ok\":$ok,\"ghostscript\":\"${gs_v:-missing}\",\"needed_by\":\"scripts/compress-pdf.sh\"}"
$ok
