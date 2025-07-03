{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    
  };}

