{ config, pkgs, lib, ... }: 

{
 
services.vaultwarden = {
  enable = true;
  dbBackend = "postgresql";
  environmentFile = "/home/admin/vaultwarden/.env";
  config = {
    ROCET_PORT = 8222;
    SIGNUPS_ALLOWED = false;
    DOMAIN = "https://passwords.clownweb.net";
  };
};

  services.caddy = {
    virtualHosts."passwords.clownweb.net".extraConfig = ''
      reverse_proxy http://localhost:8222
    '';
  };

  }
