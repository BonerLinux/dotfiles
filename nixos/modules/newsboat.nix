{ config, username, pkgs, lib, ... }:
let
  standardUser = username;
in
{

  environment.systemPackages = with pkgs; [
    newsboat
    mpv
  ];

}
