{ config, pkgs, username, lib, ... }: 
let
  standardUser = username;
in
{
  environment.systemPackages = with pkgs; [
    mpv
    firefox
    libreoffice
    nautilus
    home-manager
  ];




}
