{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

    ];

  networking.hostName = "laptop";

  # -- fingerprint --
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;
  systemd.services.fprind = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
}

