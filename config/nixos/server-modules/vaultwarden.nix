{ config, pkgs, lib, ... }: 

{

  services.vaultwarden.enable = true;
  services.vaultwarden.config = {
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = 8222;
    SIGNUPS_ALLOWED = true;
  };

  networking.firewall.allowedTCPPorts = [ 8222 ];
}
