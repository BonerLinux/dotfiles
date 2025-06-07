{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  programs.zsh = {
    shellAliases = {
      cloud = "sshfs admin@74.126.84.249:/mnt/tank/cloud ~/Cloud";
    };
  };

}
