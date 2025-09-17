{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

    ];

  # -- hostname --
  networking.hostName = "laptop";

  # -- syncthing --
  services.syncthing.enable = true;

  # -- fingerprint --
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;
  systemd.services.fprind = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
}

