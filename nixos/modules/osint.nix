{ config, username, pkgs, lib, ... }:
let
  standardUser = username;
in
{

  programs.wireshark.enable = true;
  environment.systemPackages = with pkgs; [
    bind
    sherlock
    wireshark
  ];

  users.users.${standardUser}.extraGroups = [ "wireshark" ];

}
