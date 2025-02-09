{ config, pkgs, lib, ... }: 

{
 
  services.immich.enable = true;
  services.immich.port = 2283;
  
  #services.immich.mediaLocation = "/var/lib/immich" #default

  services.caddy.virtualHosts."pictures.clownweb.net".extraConfig = ''
    reverse_proxy localhost:2283
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];
}
