{ config, pkgs, lib, ... }: 

{
 
  services.syncthing.enable = true;
  services.syncthing = {
    user = "rileyboughner";
    group = "users";
    dataDir = "/home/rileyboughner";    # Default folder for new synced folders
    configDir = "/home/rileyboughner/.config/syncthing";   # Folder for Syncthing's settings and keys
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true;
    settings = {
    };
  };

   networking.firewall.allowedTCPPorts = [ 8384 22000 ];
   networking.firewall.allowedUDPPorts = [ 22000 21027 ];

}
