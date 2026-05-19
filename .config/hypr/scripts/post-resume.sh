#!/bin/bash
# Post-resume display handling.
# Workaround for Hyprland leaving external outputs blank after suspend: kick
# them with `dpms on`. If the lid is closed, apply lid-close policy first and
# skip eDP-1 so the internal panel never flashes on.
script_dir=$(dirname "$(readlink -f "$0")")

if grep -q closed /proc/acpi/button/lid/*/state; then
    "$script_dir/lid-close.sh"
    hyprctl monitors -j \
        | jq -r '.[] | select(.name != "eDP-1") | .name' \
        | while read -r m; do
            hyprctl dispatch dpms on "$m"
        done
else
    hyprctl dispatch dpms on
fi

# If still locked 30s after wake, suspend again.
"$script_dir/suspend-if-locked.sh" 30
