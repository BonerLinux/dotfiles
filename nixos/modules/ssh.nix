{ config, pkgs, lib, hosts, ... }:

{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  programs.ssh = {
    extraConfig = ''

      Host server
        HostName ${hosts.server.ip}
        User ${hosts.server.user}
        IdentityFile /run/agenix/server-ssh-key

      Host desktop
        HostName ${hosts.desktop.ip}
        User ${hosts.desktop.user}
        IdentityFile /run/agenix/desktop-ssh-key

    '';
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
