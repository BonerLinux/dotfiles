{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../configuration.nix
      ../../modules/wireless-networking.nix
    ];

  networking.hostName = "laptop";

  # -- auto vpn --
  networking.wg-quick.interfaces = {
    clownweb = {
      configFile = "/etc/wireguard/clownweb.conf";
      autostart = true;
    };
  };

  # -- fingerprint --
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;
  systemd.services.fprind = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
}

