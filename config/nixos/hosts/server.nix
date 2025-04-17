{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "clownweb";

  # -- packages --
  environment.systemPackages = with pkgs; [];
  
 # -- services --
 



}
