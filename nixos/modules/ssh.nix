{ config, pkgs, lib, ... }: 

{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  programs.ssh = {
    extraConfig = "
      
      Host server
        HostName 192.168.1.2
        User admin
        IdentityFile ~/.secrets/keys/server

    ";
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
