{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../configuration.nix
      ../../modules/nvidia.nix
      ../../modules/docker.nix
      ../../modules/wireless-networking.nix
    ];

  networking.hostName = "desktop";
}

