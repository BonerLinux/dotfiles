<img width="1200" height="300" alt="WTF Homelab(2)" src="https://github.com/user-attachments/assets/87c0cbc6-8006-43c0-b1c9-e5bb72574cb9" />

<div align="center">
  <img src="https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS" />
  <img src="https://img.shields.io/badge/Hyprland-33ccff?style=for-the-badge&logo=hyprland&logoColor=white" alt="Hyprland" />
  <img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?style=for-the-badge&logo=neovim&logoColor=white" alt="Neovim" />
  <img src="https://img.shields.io/badge/Zsh-F1502F?style=for-the-badge&logo=zsh&logoColor=white" alt="Zsh" />
  <img src="https://img.shields.io/badge/Scratchpads-FFB13B?style=for-the-badge&logo=window-restore&logoColor=white" alt="Scratchpads" />
</div>

# Riley Boughners' Dotfiles

## About
Welcome to my dotfiles! These contain the configuration and automation I use across my machines. The goal is a balance of functionality and aesthetics.

## Repository layout
- `nixos/`: NixOS flake, system configuration, and Home Manager entry points.
- `scripts/`: Helper scripts for rebuilding, theming, and syncing.
- `dotfiles/`: Additional dotfiles (tracked for future expansion).

## Quick start
> These instructions assume the repo is checked out as `~/.system`.

1. Install Nixos
   - `nixos/flake.nix`
   - `nixos/configuration.nix`
   - `nixos/home-manager.nix`
2. Clone the installer:
   ```bash
   curl -L -o install https://raw.githubusercontent.com/rileyboughner/dotfiles/refs/heads/master/scripts/install
   ```
3. Make the installer executable:
   ```bash
   chmod +x install
   ./install
   ```
4. install:
   ```bash
   ./install
   ```

## Scripts
| Script | Purpose |
| --- | --- |
| `scripts/rebuild` | Runs `nixos-rebuild switch` for the local flake. |
| `scripts/update` | Updates flake inputs and commits `flake.lock` if it changed. |
| `scripts/change-wallpaper` | Picks a wallpaper with Wofi, sets Hyprpaper, and updates the theme. |
| `scripts/set-theme-from-wallpaper` | Runs `pywal` and applies colors to Firefox, Mako, and more. |
| `scripts/backup` | Syncs backups from the `server` host with `rsync`. |
| `scripts/cloud` | Mounts the `server` cloud directory with `sshfs`. |

## Theming workflow
1. Place wallpapers in `~/.wallpapers`.
2. Run:
   ```bash
   change-wallpaper
   ```
3. The script copies the selected image to `~/.wallpaper`, updates Hyprpaper, and calls `set-theme-from-wallpaper`.

## TODO!

- [x] create change-wallpaper command as an alias
