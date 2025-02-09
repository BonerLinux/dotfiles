{ config, pkgs, lib, ... }: 

{
 
  services.syncthing.enable = true;
  services.syncthing = {
    group = "users";
    user = "rileyboughner";
    dataDir = "/home/rileyboughner/syncdata";
    configDir = "/home/rileyboughner/sync-config";

  };

  services.syncthing.settings.gui = {
      user = "admin";
      password = "!JoJo1225!";
  };

  services.caddy.virtualHosts."pictures.clownweb.net".extraConfig = ''
    reverse_proxy localhost:8384
  '';

   networking.firewall.allowedTCPPorts = [ 8384 22000 ];
   networking.firewall.allowedUDPPorts = [ 22000 21027 ];}
