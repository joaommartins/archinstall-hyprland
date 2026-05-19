#!/usr/bin/env bash
set -euo pipefail
outdir="$HOME/Pictures/Screenshots"
mkdir -p "$outdir"
outfile="$outdir/screenshot-$(date +%s).png"

# Capture area selected with slurp (best cross-compositor method)
if command -v hyprshot >/dev/null 2>&1; then
  hyprshot -s "$outfile" 2>/dev/null || grim -g "$(slurp)" "$outfile"
else
  grim -g "$(slurp)" "$outfile"
fi

notify-send "Screenshot saved" "$outfile"
