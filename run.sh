#!/usr/bin/env bash
# Entry point. Run this from the Arch live ISO as root.
# Drives archinstall then runs post-install inside the new system.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
[[ -d /sys/firmware/efi ]] || { echo "UEFI boot required."; exit 1; }
ping -c1 -W3 archlinux.org &>/dev/null || { echo "No internet connection."; exit 1; }

pacman -Sy --noconfirm --needed git rsync

echo "Edit user_configuration.json (disk, hostname, timezone) and"
echo "user_credentials.json (username, passwords) before continuing."
read -rp "Press Enter when ready..."

archinstall --config "$SCRIPT_DIR/user_configuration.json" \
            --creds  "$SCRIPT_DIR/user_credentials.json"

# archinstall leaves /mnt mounted — copy repo into the new system and run post-install
cp -r "$SCRIPT_DIR" /mnt/root/arch-setup
arch-chroot /mnt /root/arch-setup/post-install.sh
rm -rf /mnt/root/arch-setup

echo ""
echo "Done. Remove installation media and reboot."
