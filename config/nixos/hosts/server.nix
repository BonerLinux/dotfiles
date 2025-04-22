{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "clownweb";

  # -- packages --
  environment.systemPackages = with pkgs; [];
  
 # -- services --
 virtualization.docker.enable = true;
 
 services.openssh = {
   enable = true;
   permitRootLogin = "no";         # Safer to disable root login
   passwordAuthentication = true; # Use SSH keys instead
 };



}
