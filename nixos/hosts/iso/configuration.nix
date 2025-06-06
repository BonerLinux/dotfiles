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

  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  users.users = {
    rileyboughner = {
      isNormalUser = true;
      password = "!!JoJo1225!!";
      extraGroups = [ "wheel" ];
    };
  };

  users.extraUsers.root.password = "root";

  environment.systemPackages = with pkgs; [
    cmatrix
    git
    stow
    gum
    (
      writeShellScriptBin "nix-install"
      ''
        #!/usr/bin/env bash
        set -euo pipefail

        if [ "$(whoami)" != "rileyboughner" ]; then
          echo "Re-running script as rileyboughner..."
          exec sudo -u rileyboughner bash "$0"
        fi

        if [ "$(id -u)" -eq 0 ]; then
        	echo "ERROR! $(basename "$0") should be run as a regular user"
        	exit 1
        fi

        # clone dotfiles
        if [ ! -d "/home/rileyboughner/.system" ]; then
            sudo git clone https://github.com/rileyboughner/dotfiles.git "/home/rileyboughner/.system"
        fi

        # choose host to install
        TARGET_HOST=$(ls -1 /home/rileyboughner/.system/nixos/hosts/*/configuration.nix | cut -d'/' -f7 | grep -v iso | gum choose)

        # 
        if [ ! -e "/home/rileyboughner/.system/nixos/hosts/$TARGET_HOST/disks.nix" ]; then
        	echo "ERROR! $(basename "$0") could not find the required /home/rileyboughner/dotfiles/hosts/$TARGET_HOST/disks.nix"
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
        "/home/rileyboughner/.system/nixos/hosts/$TARGET_HOST/disks.nix"

        sudo nixos-install --flake "/home/rileyboughner/.system/nixos#$TARGET_HOST"

        cd ~/.system/dotfiles/normal
        mkdir ~/.config
        stow -t ~/.config dot_config
      ''
    )
  ];

}
