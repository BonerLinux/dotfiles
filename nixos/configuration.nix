{ config, pkgs, ... }:

{
  imports = [  
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;


  systemd.extraConfig = ''
    DefaultTimeoutStartSec=5s
    DefaultTimeoutStopSec=5s
  '';
  
  # Local
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # -- packages --
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;

  # services
  services.fwupd.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [

    nautilus
    brightnessctl

    mpv
    newsboat
    wireguard-tools
    rclone #for backups
    git
    oh-my-posh
    stow
    direnv
    gowall
    mako
    libnotify
    (python3.withPackages (ps: with ps; [ pillow ])) # for ranger
    zoxide
    ranger
    tree
    unzip
    tldr
    fastfetch
    htop-vim
    pass

    gum
    qemu

    obsidian 

    firefox
    libreoffice

    home-manager

  ];

  fileSystems."/mnt/Backup" = {
    device = "/dev/disk/by-uuid/bf534c30-89e9-4c71-bb9f-b5b6e56e91c6"; # sdb3
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=5s" "noatime" ];
  };

  # Optional encrypted device (sdb4)
  environment.etc."crypttab".text = ''
    my_encrypted_drive UUID=f7459f96-e757-47a7-8b84-d155e03c83cb none noauto
  '';

  fileSystems."/mnt/Secrets" = {
    device = "/dev/mapper/my_encrypted_drive";
    fsType = "ext4";
    options = [ "noauto" "nofail" "noatime" ];
  };

  # -- gnupg --
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  # -- system stuff -- nix.settings.experimental-features = [ "nix-command" "flakes" ]; nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.05";
}
