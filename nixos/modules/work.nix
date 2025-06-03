{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  programs.zsh = {
    shellAliases = {
      work = "sshfs rboughner@74.126.84.249:/home/rboughner/taqweb ~/Taqweb";
      f = "~/.dotfiles/scripts/work/f";
    };
  };
}
