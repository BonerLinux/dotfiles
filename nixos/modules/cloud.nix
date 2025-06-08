{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  programs.zsh = {
    shellAliases = {
      cloud = "sshfs admin@192.168.1.201:/mnt/tank/cloud ~/Cloud";
    };
  };

}
