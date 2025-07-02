{ config, pkgs, lib, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.1.5"
  ];
  environment.systemPackages = with pkgs; [
    beekeeper-studio
    sshfs
    rclone
  ];

  programs.zsh = {
    shellAliases = {
      work = "sshfs rboughner@74.126.84.249:/home/rboughner/taqweb ~/Taqweb";
    };
  };
}
