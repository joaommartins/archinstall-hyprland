# archinstall-hyprland

> **Warning**
> This configuration was generated based on a working EndeavourOS/Hyprland setup and has not been tested as an installer. Use it as a reference or starting point, and expect to debug.

Automated Arch Linux installation with a Hyprland desktop, driven by [archinstall](https://github.com/archlinux/archinstall).

## What gets installed

- **Base system:** GRUB, LUKS-encrypted btrfs root (subvolumes `@`, `@home`, `@log`, `@pkg`), NetworkManager, pipewire
- **Desktop:** Hyprland, hyprlock, hypridle, noctalia-shell, greetd + tuigreet
- **Apps:** ghostty, firefox, helix, thunar, yazi, zed, vlc, and more
- **AUR:** `greetd-tuigreet`, `grub-btrfs`, `hyprlight`, `noctalia-qs`, `noctalia-shell`, `timeshift-autosnap`
- **Configs:** deployed from this repo (`.config/hypr/`, `etc/`)

## Requirements

- UEFI system
- Internet connection on the live ISO
- Arch Linux live ISO (archinstall is pre-installed)

## Usage

Boot the Arch live ISO, then:

```bash
pacman -Sy git
git clone https://github.com/joaommartins/archinstall-hyprland.git
cd archinstall-hyprland
```

**1. Set your disk and preferences** in `user_configuration.json`:

| Field | Default | Notes |
|---|---|---|
| `disk_config.device_modifications[0].device` | `/dev/nvme0n1` | Run `lsblk` to find your disk |
| `hostname` | `archlinux` | |
| `timezone` | `Europe/London` | e.g. `America/New_York` |
| `locale_config.kb_layout` | `us` | |

**2. Set credentials** by copying the example and editing it:

```bash
cp user_credentials.example.json user_credentials.json
```

Generate encrypted password hashes with `mkpasswd` (from the `whois` package, pre-installed on the Arch ISO):

```bash
mkpasswd -m yescrypt
# Enter your password when prompted — copy the $y$... hash into the JSON
```

Or with `openssl` (SHA-512, also accepted by archinstall):

```bash
openssl passwd -6
```

Edit `user_credentials.json` and replace both hash fields with your generated hash:

```json
{
  "root_enc_password": "$y$j9T$...",
  "users": [
    {
      "username": "yourusername",
      "enc_password": "$y$j9T$...",
      "groups": [],
      "sudo": true
    }
  ]
}
```

**3. Run:**

```bash
bash run.sh
```

This calls archinstall, then copies the repo into the new system and runs `post-install.sh` via `arch-chroot`.

**4.** Remove the installation media and reboot.

## Disk layout

| Partition | Size | Format | Mount |
|---|---|---|---|
| EFI | 1 GiB | FAT32 | `/boot` |
| Root | Remaining | btrfs (LUKS) | — |

btrfs subvolumes, all mounted with `compress=zstd`:

| Subvolume | Mount |
|---|---|
| `@` | `/` |
| `@home` | `/home` |
| `@log` | `/var/log` |
| `@pkg` | `/var/cache/pacman/pkg` |

Timeshift (btrfs mode) manages its own snapshot subvolumes directly at the pool root.

## Post-install

`post-install.sh` runs inside the installed system after archinstall exits:

1. Builds and installs `yay`
2. Installs AUR packages (`greetd-tuigreet`, `grub-btrfs`, `hyprlight`, `noctalia-qs`, `noctalia-shell`, `timeshift-autosnap`)
3. Deploys `.config/hypr/` and `etc/` configs from this repo
4. Enables services: `greetd`, `grub-btrfsd`, `bluetooth`, `firewalld`, `avahi-daemon`, `fstrim.timer`, `reflector.timer`
5. Configures mDNS (`nsswitch.conf` + avahi)
6. Configures reflector to rank the 10 fastest HTTPS mirrors
7. Sets `zsh` as the default shell

## Nvidia

Not handled automatically. After booting, install drivers manually:

```bash
sudo pacman -S nvidia-open nvidia-utils nvidia-settings opencl-nvidia libva-nvidia-driver
```

Add to `/etc/mkinitcpio.conf`:
```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Add to `GRUB_CMDLINE_LINUX` in `/etc/default/grub`:
```
nvidia-drm.modeset=1
```

Then regenerate: `sudo mkinitcpio -P && sudo grub-mkconfig -o /boot/grub/grub.cfg`
