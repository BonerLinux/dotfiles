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
  # so `ssh desktop` from other workstations works. Also trusts
  # server-to-desktop-key.age's public half, used by Claude Code Remote
  # Control running on `server` to reach this machine.
  users.users.rileyboughner.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICN7zGuQjVZkmeWEyw4k6/wx4IDXp0fsyDPL8UZOFoBw desktop-access"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINP7sYNqVuwl1zj+4uNFoGBNIxnoO62SoZwyDOnpwhw3 server-to-desktop"
  ];
}

