#!/bin/bash
INTERNAL=$(hyprctl monitors -j | jq '[.[] | select(.name == "eDP-1")] | length')
EXTERNAL=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')

if [ "$INTERNAL" -gt 0 ] && [ "$EXTERNAL" -gt 0 ]; then
    kanshictl switch WFH
else
    hyprctl dispatch dpms off eDP-1
fi
