{ config, username, pkgs, lib, ... }:
let
  standardUser = username;
in
{

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  #users.users.${standardUser}.extraGroups = [ "wireshark" ];

}
