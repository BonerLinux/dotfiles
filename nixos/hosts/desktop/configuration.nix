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

  # Trust the public half of desktop-ssh-key.age (see nixos/secrets/secrets.nix)
  # so `ssh desktop` from other workstations works.
  users.users.rileyboughner.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICN7zGuQjVZkmeWEyw4k6/wx4IDXp0fsyDPL8UZOFoBw desktop-access" ];
}

