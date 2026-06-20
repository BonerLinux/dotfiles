{ config, pkgs, username, ... }: 
let
 standardUser = username;
in
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    bluetuith
  ];

  users.users.${standardUser}.extraGroups = [ "networkManager" ];
}
