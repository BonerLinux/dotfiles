{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../configuration.nix
      ../../modules/wireless-networking.nix
      ../../modules/nfs-client.nix
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

