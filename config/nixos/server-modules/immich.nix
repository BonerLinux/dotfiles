{ config, pkgs, lib, ... }: 

{
 
services.immich = {
  enable = true;
  port = 2283;
  openFirewall = true;
};

  services.caddy = {
    virtualHosts."pictures.clownweb.net".extraConfig = ''
      reverse_proxy http://localhost:2283
    '';
  };

  }
