{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -- hostname --
  networking.hostName = "laptop";

  # -- fingerprint --
  systemd.services.fprind = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

  security.pam.services.sudo.fprintAuth = true;
  
  system.stateVersion = "25.05"; # Did you read the comment?

}

