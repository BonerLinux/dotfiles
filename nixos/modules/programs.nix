{ config, pkgs, username, lib, ... }: 
let
  standardUser = username;
in
{
  environment.systemPackages = with pkgs; [
    firefox
    libreoffice
    nautilus
    home-manager
  ];


  #users.users.${standardUser}.extraGroups = [ "hehe" ];

}
