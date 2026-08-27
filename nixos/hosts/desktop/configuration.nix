{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../configuration.nix
      ../../modules/nvidia.nix
      ../../modules/nfs-client.nix
      #../../modules/kubernetes.nix
      #../../modules/docker.nix
      ../../modules/wireless-networking.nix
    ];

  networking.hostName = "desktop";
}

