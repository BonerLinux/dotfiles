{ config, pkgs, ... }:
{

  fileSystems."/home/rileyboughner/.vault" = {
    device = "192.168.1.2:/mnt/tank/files/obsidian";
    fsType = "nfs";
    options = [ "rw" "_netdev" "x-systemd.automount" "noauto" ];
  };

  fileSystems."/home/rileyboughner/Documents" = {
    device = "192.168.1.2:/mnt/tank/files/Documents";
    fsType = "nfs";
    options = [ "rw" "_netdev" "x-systemd.automount" "noauto" "vers=4" ];
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

}
