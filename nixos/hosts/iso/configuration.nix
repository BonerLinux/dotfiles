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

  networking = {
    hostName = "Boner-OS-Installer";
  };

  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  users.extraUsers.root.password = "root";

  environment.systemPackages = with pkgs; [
    git
    stow
    gum
    (
      writeShellScriptBin "nix-install"
      ''
        #!/usr/bin/env bash
        set -euo pipefail
        gsettings set org.gnome.desktop.session idle-delay 0
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

        if [ "$(id -u)" -eq 0 ]; then
        	echo "ERROR! $(basename "$0") should be run as a regular user"
        	exit 1
        fi

        # clone dotfiles
        if [ ! -d "$HOME/.system" ]; then
            git clone https://github.com/rileyboughner/dotfiles.git "$HOME/.system"
        fi

        # choose host to install
        TARGET_HOST=$(ls -1 ~/.system/nixos/hosts/*/configuration.nix | cut -d'/' -f7 | grep -v iso | gum choose)

        # 
        if [ ! -e "$HOME/.system/nixos/hosts/$TARGET_HOST/disks.nix" ]; then
        	echo "ERROR! $(basename "$0") could not find the required $HOME/dotfiles/hosts/$TARGET_HOST/disks.nix"
        	exit 1
        fi

        gum confirm  --default=false \
        "🔥 🔥 🔥 WARNING!!!! This will ERASE ALL DATA on the disk $TARGET_HOST. Are you sure you want to continue?"

        echo "Partitioning Disks"
        sudo nix run github:nix-community/disko \
        --extra-experimental-features "nix-command flakes" \
        --no-write-lock-file \
        -- \
        --mode zap_create_mount \
        "$HOME/.system/nixos/hosts/$TARGET_HOST/disks.nix"

        sudo nixos-install --flake "$HOME/.system/nixos#$TARGET_HOST"
      ''
    )
  ];

}
