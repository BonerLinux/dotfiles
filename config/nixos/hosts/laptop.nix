{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "laptop";

  # -- packages --
  environment.systemPackages = with pkgs; [
    asusctl
  ];
  
  # -- custom --
  services.logind.lidSwitch = "suspend";

}
