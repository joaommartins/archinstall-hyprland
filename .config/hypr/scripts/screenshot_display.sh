#!/usr/bin/env bash
set -euo pipefail
outdir="$HOME/Pictures/Screenshots"
mkdir -p "$outdir"
outfile="$outdir/screenshot-$(date +%s).png"

if command -v hyprshot >/dev/null 2>&1; then
  hyprshot -f "$outfile" 2>/dev/null || grim "$outfile"
else
  grim "$outfile"
fi

notify-send "Screenshot saved" "$outfile"
