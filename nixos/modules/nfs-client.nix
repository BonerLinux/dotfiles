{ config, pkgs, hosts, username, ... }:
{

  fileSystems."/home/${username}/.vault" = {
    device = "${hosts.server.ip}:/mnt/tank/files/obsidian";
    fsType = "nfs";
    options = [ "rw" "_netdev" "x-systemd.automount" "noauto" ];
  };

  fileSystems."/home/${username}/Documents" = {
    device = "${hosts.server.ip}:/mnt/tank/files/Documents";
    fsType = "nfs";
    options = [ "rw" "_netdev" "x-systemd.automount" "noauto" "vers=4" ];
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

}
