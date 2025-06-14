{ pkgs, lib, ... }:
{

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    extraOptions = "experimental-features = nix-command flakes";
  };

  services = {
    qemuGuest.enable = true;
    openssh.settings.PermitRootLogin = lib.mkForce "yes";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  };

  networking.hostName = "BonerOS";

  users.users = {
    rileyboughner = {
      isNormalUser = true;
      initialPassword = "rileyboughner";
      extraGroups = [ "wheel" ];
    };
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = lib.mkForce "rileyboughner";

  users.users.nixos.enable = false;

  #users.extraUsers.root.password = "root";

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-initial-setup
  ];

  environment.systemPackages = with pkgs; [
    cmatrix
    git
    stow
    neovim
    gum
    (
      writeShellScriptBin "nix-install"
      ''
      #!/usr/bin/env bash
      set -euo pipefail

      # 💡 Ensure script is not run as root
      if [ "$(id -u)" -eq 0 ]; then
        echo "❌ Do not run this script as root."
        exit 1
      fi

      # 🔄 Re-run script as user 'rileyboughner' if not already
      if [ "$(whoami)" != "rileyboughner" ]; then
        echo "⏩ Re-running script as rileyboughner..."
        exec sudo -u rileyboughner -E bash "$0"
      fi

      # 🌐 Check for internet connectivity
      if ! ping -q -c 1 -W 2 1.1.1.1 >/dev/null; then
        echo "❌ No internet connection detected. Please check your network and try again."
        exit 1
      fi

      # 🛠 Clone dotfiles repo if needed
      if [ ! -d "/home/rileyboughner/.system" ]; then
        echo "📥 Cloning dotfiles..."
        git clone https://github.com/rileyboughner/dotfiles.git "/home/rileyboughner/.system"
      fi

      # 🎯 Choose target host
      TARGET_HOST=$(ls -1 /home/rileyboughner/.system/nixos/hosts/*/configuration.nix \
        | cut -d'/' -f7 \
        | grep -v iso \
        | gum choose)

      # 🔍 Validate required disk layout file exists
      DISK_FILE="/home/rileyboughner/.system/nixos/hosts/$TARGET_HOST/disks.nix"
      if [ ! -e "$DISK_FILE" ]; then
        echo "❌ ERROR! Could not find required: $DISK_FILE"
        exit 1
      fi

      # ⚠️ Confirm destructive operation
      gum confirm --default=false \
        "🔥🔥🔥 WARNING: This will ERASE ALL DATA for host $TARGET_HOST. Continue?" || {
        echo "❌ Installation aborted by user."
        exit 1
      }

      # 🧨 Remove all existing EFI boot entries
      echo "🧨 Removing all existing EFI boot entries..."
      for entry in $(efibootmgr | awk '/^Boot[0-9A-Fa-f]{4}/ {print substr($1,5,4)}'); do
        echo "Deleting Boot$entry"
        sudo efibootmgr -b "$entry" -B
      done

      # 💽 Partition disks with disko
      echo "💿 Partitioning disks for $TARGET_HOST..."
      sudo nix run github:nix-community/disko \
        --extra-experimental-features "nix-command flakes" \
        --no-write-lock-file \
        -- --mode zap_create_mount "$DISK_FILE"

      # Generate hardware config in flake host directory
      echo "🧱 Generating hardware-configuration.nix..."
      sudo nixos-generate-config \
        --root /mnt \
        --dir "/home/rileyboughner"

      mv "/home/rileyboughner/hardware-configuration.nix" "/home/rileyboughner/.system/nixos/hosts/$TARGET_HOST"

      # 🚀 Install NixOS from flake
      echo "🚀 Installing NixOS for host $TARGET_HOST..."
      sudo nixos-install --flake "/home/rileyboughner/.system/nixos#$TARGET_HOST"

      # 🎁 installing config files
      echo "🎯 installing config files..."
      mv "/home/rileyboughner/.system" "/mnt/home/rileyboughner/"
      mkdir "/mnt/home/rileyboughner/.config"

      cd "/mnt/home/rileyboughner/.system/dotfiles/normal"
      stow -t "/mnt/home/rileyboughner/.config" "dot_config"

      # 🎁 installing wallpapers
      echo "🎯 installing wallpapers"
      
      git clone https://github.com/rileyboughner/wallpapers.git /mnt/home/rileyboughner/.wallpapers
      
      echo "✅ Installation complete! You may now reboot."      
      ''
    )
  ];

}
