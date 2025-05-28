{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "desktop";

  # -- packages --
  environment.systemPackages = with pkgs; [

  ];
  
  # -- custom --

}
