{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nvidia.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -- hostname --
  networking.hostName = "laptop";

  # -- services --
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  system.stateVersion = "25.05"; # Did you read the comment?

}

