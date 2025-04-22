{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "clownweb";

  # -- packages --
  environment.systemPackages = with pkgs; [];
  
 # -- services --
 virtualisation.docker.enable = true;
 
 services.openssh.enable = true;
 services.openssh.settings = {
   permitRootLogin = "no";         # Safer to disable root login
   passwordAuthentication = true; # Use SSH keys instead
 };



}
