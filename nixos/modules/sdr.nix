{ config, username, pkgs, lib, ... }:
let
  standardUser = username;
in
{

  environment.systemPackages = with pkgs; [
    gnuradio
    gqrx
  ];

  hardware.rtl-sdr.enable = true;

  users.users.${standardUser}.extraGroups = [ "plugdev" ];

}
