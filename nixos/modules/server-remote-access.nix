# Dedicated outbound SSH access from `server` to the workstations, used by
# Claude Code Remote Control running on `server` to reach into `desktop` and
# `laptop`. See nixos/secrets/secrets.nix for the key rationale.
{ username, ... }:
{
  age.secrets.server-to-desktop-key = {
    file = ../secrets/server-to-desktop-key.age;
    owner = username;
  };
  age.secrets.server-to-laptop-key = {
    file = ../secrets/server-to-laptop-key.age;
    owner = username;
  };

  programs.ssh.extraConfig = ''
    Host desktop
      HostName 192.168.1.4
      User rileyboughner
      IdentityFile /run/agenix/server-to-desktop-key

    Host laptop
      HostName 192.168.1.5
      User rileyboughner
      IdentityFile /run/agenix/server-to-laptop-key
  '';
}
