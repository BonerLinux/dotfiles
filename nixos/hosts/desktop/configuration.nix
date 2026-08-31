{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../configuration.nix
      ../../modules/nvidia.nix
      ../../modules/audio.nix
      ../../modules/nfs-client.nix
      ../../modules/wireless-networking.nix
    ];

  networking.hostName = "desktop";
}

