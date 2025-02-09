{ config, pkgs, lib, ... }: 

{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
}
