{ config, pkgs, lib, ... }: 

{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  programs.ssh = {
    extraConfig = "
      
      Host server
        HostName 192.168.1.2
        User admin
        IdentityFile /run/agenix/server-ssh-key

      Host desktop
        HostName 192.168.1.4
        User rileyboughner
        IdentityFile /run/agenix/desktop-ssh-key

    ";
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
