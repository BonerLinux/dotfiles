{ config, pkgs, lib, ... }: 

{

  services.vaultwarden.enable = true;
  services.vaultwarden.config = {
    ROCKET_ADDRESS = "0.0.0.0";
    ROCKET_PORT = 8222;
    SIGNUPS_ALLOWED = true;
  };

  networking.firewall.allowedTCPPorts = [ 8222 443];
  networking.firewall.allowedUDPPorts = [ 80 ];
}
