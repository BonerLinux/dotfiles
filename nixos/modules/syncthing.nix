{ config, pkgs, lib, ... }: 

{
 
  services.syncthing = {
    enable = true;
    
    user = "rileyboughner";
    group = "users";

    dataDir = "/home/rileyboughner";    # Default folder for new synced folders
    configDir = "/home/rileyboughner/.syncthing";   # Folder for Syncthing's settings and keys

    settings.gui = {
      user = "admin";
      password = "$y$j9T$PBpPY.F5T3LyemyZpllKO0$Nb4frufq7r/Om8gUGodD1vmtfgwdl41g8FwQPKCxlZ1";
    };

    guiAddress = "0.0.0.0:8384";

    overrideDevices = true;
    overrideFolders = true;
    settings = {

      devices = {
        "server" = { id = "OTRRRC6-JCESLF3-VNDPFOY-EVUIUYI-EQDSMIK-QAFUIC4-PHJO33C-QNCBNQN"; };
      };

      folders = {
        "Documents" = {         # Name of folder in Syncthing, also the folder ID
          path = "/home/rileyboughner/Documents";    # Which folder to add to Syncthing
          devices = [ "server" ];      # Which devices to share the folder with
        };
      };

    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

}
