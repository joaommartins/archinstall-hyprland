#!/usr/bin/env bash
# Runs inside arch-chroot after archinstall completes.
# Installs AUR packages, deploys Hyprland configs, and configures services.
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'
step() { echo -e "\n${GREEN}${BOLD}==> $*${RESET}"; }

# Resolve the UID 1000 user created by archinstall
USERNAME=$(getent passwd 1000 | cut -d: -f1)
[[ -n "$USERNAME" ]] || { echo -e "${RED}No UID 1000 user found.${RESET}"; exit 1; }

step "Installing yay (AUR helper)"
sudo -u "$USERNAME" bash -c "
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  cd /tmp/yay-bin
  makepkg -si --noconfirm
  rm -rf /tmp/yay-bin
"

step "Installing AUR packages"
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/pacman" > /etc/sudoers.d/yay-temp
sudo -u "$USERNAME" yay -S --noconfirm --needed \
    greetd-tuigreet \
    grub-btrfs \
    hyprlight \
    noctalia-qs \
    noctalia-shell \
    timeshift-autosnap
rm -f /etc/sudoers.d/yay-temp

step "Deploying Hyprland configs"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
rsync -a "$SCRIPT_DIR/.config/" "/home/$USERNAME/.config/"
rsync -a --chown=root:root "$SCRIPT_DIR/etc/" /etc/
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

step "Configuring display manager (greetd)"
systemctl disable sddm lightdm gdm 2>/dev/null || true
systemctl enable greetd

step "Enabling grub-btrfsd snapshot watcher"
systemctl enable grub-btrfsd

step "Enabling services"
systemctl enable bluetooth
systemctl enable firewalld
systemctl enable avahi-daemon
systemctl enable fstrim.timer

step "Configuring mDNS (avahi + nss-mdns)"
sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf

step "Configuring reflector"
cat > /etc/xdg/reflector/reflector.conf <<EOF
--save /etc/pacman.d/mirrorlist
--protocol https
--latest 10
--sort rate
EOF
systemctl enable reflector.timer

step "Setting zsh as default shell"
chsh -s /usr/bin/zsh "$USERNAME"

echo -e "\n${GREEN}${BOLD}Post-install complete.${RESET}\n"
