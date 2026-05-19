#!/bin/bash
# Sleep $1 seconds (default 30), then `systemctl suspend` if hyprlock is still
# running. Replaces any prior watcher so chained lock-without-unlock cycles
# don't accumulate. Used after manual lock (Super+L) and after wake from sleep.
delay="${1:-30}"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
pid_file="$runtime_dir/suspend-if-locked.pid"

if [ -f "$pid_file" ]; then
    kill "$(cat "$pid_file")" 2>/dev/null
    rm -f "$pid_file"
fi

(
    sleep "$delay"
    if pgrep -x hyprlock >/dev/null; then
        systemctl suspend
    fi
    rm -f "$pid_file"
) &
echo $! > "$pid_file"
disown
