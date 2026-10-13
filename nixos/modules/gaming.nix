{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    discord-ptb
    heroic
    gamescope
  ];

  # Needed so `gamescope -- steam` can manage its own session/VT.
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraPackages = [ pkgs.gamescope ];
  };

}
