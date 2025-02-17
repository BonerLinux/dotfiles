{ config, pkgs, lib, ... }: 

{
 
  services.syncthing.enable = true;
  services.syncthing = {
    user = "admin";
    group = "users";
    dataDir = "/home/admin";    #set this to the mount point
    configDir = "/home/rileyboughner/.config/syncthing";   # Folder for Syncthing's settings and keys
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true;
    settings = {
      devices = {
      };
    };
  };

   networking.firewall.allowedTCPPorts = [ 8384 22000 ];
   networking.firewall.allowedUDPPorts = [ 22000 21027 ];

}
