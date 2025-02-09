{ config, pkgs, lib, ... }: 

{
 
  environment.etc."nextcloud-admin-pass".text = "password";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "laptop";
    config.adminpassFile = "/home/rileyboughner/nextcloud/admin-pass-file";
    config.dbtype = "sqlite";
  };

  #services.caddy.virtualHosts."nextcloud.clownweb.net".extraConfig = ''
  #  reverse_proxy localhost:2283
  #'';

  networking.firewall.allowedTCPPorts = [ 22 ];
}
