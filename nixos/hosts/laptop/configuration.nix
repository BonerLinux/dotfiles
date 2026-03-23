{ config, lib, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ../../configuration.nix
      ../../modules/docker.nix
      ../../modules/kubernetes.nix
      ../../modules/wireless-networking.nix
    ];

  networking.hostName = "laptop";

  # -- fingerprint --
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;

  # -- fingerprint --
  #services.fprintd.enable = true;
  #security.pam.services.sudo.fprintAuth = true;
  #systemd.services.fprind = {
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig.Type = "simple";
  #};
}

