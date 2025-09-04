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

  programs.wireshark.enable = true;
  services.spice-vdagentd.enable = true;
  environment.systemPackages = with pkgs; [
    wireshark

    immich-cli
    virt-viewer

    wireguard-tools
    rclone #for backups
    oh-my-posh
    stow
    direnv

    mutt

    firefox
    libreoffice
    nautilus

    home-manager

  ];

  # -- gnupg --
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  # -- garbage collection -- 
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.05";
}
