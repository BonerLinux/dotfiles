{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "clownweb";

  # -- packages --
  environment.systemPackages = with pkgs; [];
  
 # -- services --
 virtualization.docker.enable = true;
 



}
