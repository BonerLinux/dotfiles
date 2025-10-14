{ config, pkgs, username, ... }: 
let
 standardUser = username;
in
{
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  environment.systemPackages = with pkgs; [
    bluetuith
  ];

  users.users.${standardUser}.extraGroups = [ "networkManager" ];
}
