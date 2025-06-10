{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sshfs
    rclone
  ];

  programs.zsh = {
    shellAliases = {
      work = "sshfs rboughner@74.126.84.249:/home/rboughner/taqweb ~/Taqweb";
    };
  };
}
