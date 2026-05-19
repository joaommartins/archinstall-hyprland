# archinstall-hyprland

Automated Arch Linux installation with a Hyprland desktop, driven by [archinstall](https://github.com/archlinux/archinstall).

## What gets installed

- **Base system:** GRUB, btrfs root (subvolumes `@`, `@home`, `@snapshots`, `@var_log`), NetworkManager, pipewire
- **Desktop:** Hyprland, hyprlock, hypridle, noctalia-shell, greetd + tuigreet
- **Apps:** ghostty, firefox, helix, thunar, yazi, zed, vlc, and more
- **AUR:** `greetd-tuigreet`, `hyprlight`, `noctalia-qs`, `noctalia-shell`
- **Configs:** deployed from [joaommartins/endeavouros-hyprland](https://github.com/joaommartins/endeavouros-hyprland)

## Requirements

- UEFI system
- Internet connection on the live ISO
- Arch Linux live ISO (archinstall is pre-installed)

## Usage

Boot the Arch live ISO, then:

```bash
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

**2. Set credentials** by creating `user_credentials.json` (gitignored):

```json
{
  "root_enc_password": "yourpassword",
  "users": [
    {
      "username": "yourusername",
      "enc_password": "yourpassword",
      "sudo": true
    }
  ]
}
```

**3. Run:**

```bash
bash run.sh
```

This calls archinstall, then runs `post-install.sh` inside the new system via `arch-chroot` to install AUR packages and deploy configs.

**4.** Remove the installation media and reboot.

## Disk layout

| Partition | Size | Format | Mount |
|---|---|---|---|
| EFI | 512 MiB | FAT32 | `/boot/efi` |
| Root | Remaining | btrfs | — |

btrfs subvolumes, all mounted with `noatime,compress=zstd,space_cache=v2`:

| Subvolume | Mount |
|---|---|
| `@` | `/` |
| `@home` | `/home` |
| `@var_log` | `/var/log` |

Timeshift (btrfs mode) manages its own snapshot subvolumes directly at the pool root — no pre-created snapshots subvolume is needed.

## Post-install

`post-install.sh` runs inside the installed system after archinstall exits:

1. Builds and installs `yay` from the AUR
2. Installs AUR packages
3. Clones [joaommartins/endeavouros-hyprland](https://github.com/joaommartins/endeavouros-hyprland) and deploys `.config/hypr/` and `etc/` configs
4. Disables any greeter installed by archinstall, enables `greetd`
5. Sets `zsh` as the default shell

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
