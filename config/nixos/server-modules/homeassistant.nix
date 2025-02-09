{ config, pkgs, lib, ... }: 

{
  services.home-assistant.enable = true;
  services.home-assistant.extraComponents = [
    "esphome"
    "met"
    "radio_browser"
  ];
  services.home-assistant.config = {
    default_config = {};
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
