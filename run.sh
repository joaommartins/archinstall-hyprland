#!/usr/bin/env bash
# Entry point. Run this from the Arch live ISO as root.
# Drives archinstall then runs post-install inside the new system.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
[[ -d /sys/firmware/efi ]] || { echo "UEFI boot required."; exit 1; }
ping -c1 -W3 archlinux.org &>/dev/null || { echo "No internet connection."; exit 1; }

echo "Edit user_configuration.json (disk, hostname, timezone) and"
echo "user_credentials.json (username, passwords) before continuing."
read -rp "Press Enter when ready..."

archinstall --config "$SCRIPT_DIR/user_configuration.json" \
            --creds  "$SCRIPT_DIR/user_credentials.json"

# archinstall leaves /mnt mounted — run post-install inside the new system
cp "$SCRIPT_DIR/post-install.sh" /mnt/root/post-install.sh
arch-chroot /mnt /root/post-install.sh
rm -f /mnt/root/post-install.sh

echo ""
echo "Done. Remove installation media and reboot."
