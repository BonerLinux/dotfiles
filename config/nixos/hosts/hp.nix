{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "laptop";

  # -- packages --
  environment.systemPackages = with pkgs; [
  ];
  
  # -- services --
  services.logind.lidSwitch = "suspend";

}
