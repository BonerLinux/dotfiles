# Dedicated outbound SSH access from `server` to the workstations, used by
# Claude Code Remote Control running on `server` to reach into `desktop` and
# `laptop`. See nixos/secrets/secrets.nix for the key rationale.
{ username, pkgs, ... }:
{
  age.secrets.server-to-desktop-key = {
    file = ../secrets/server-to-desktop-key.age;
    owner = username;
  };
  age.secrets.server-to-laptop-key = {
    file = ../secrets/server-to-laptop-key.age;
    owner = username;
  };
  age.secrets.server-to-router-key = {
    file = ../secrets/server-to-router-key.age;
    owner = username;
  };

  programs.ssh.extraConfig = ''
    Host desktop
      HostName 192.168.1.4
      User rileyboughner
      IdentityFile /run/agenix/server-to-desktop-key

    # The laptop only answers on its home-LAN address (192.168.1.3) when
    # it's actually home. Off home Wi-Fi, NetworkManager auto-brings up
    # the "clownweb" WireGuard tunnel, and the laptop is only reachable
    # at its tunnel address (10.0.0.3) instead - see
    # hosts/laptop/configuration.nix's vpn-autoconnect dispatcher. Probe
    # the LAN address first and fall back to the tunnel address so
    # `ssh laptop` keeps working in both states.
    Host laptop
      HostName 192.168.1.3
      User rileyboughner
      IdentityFile /run/agenix/server-to-laptop-key
      ProxyCommand ${pkgs.netcat}/bin/nc -z -w2 192.168.1.3 22 2>/dev/null && exec ${pkgs.netcat}/bin/nc 192.168.1.3 22 || exec ${pkgs.netcat}/bin/nc 10.0.0.3 22

    Host router
      HostName 192.168.1.1
      User root
      IdentityFile /run/agenix/server-to-router-key
  '';

  # Let the admin user's systemd --user instance (and the
  # claude-remote-control.service defined on it, see users/admin.nix)
  # start at boot and keep running with no login session. Equivalent to
  # `loginctl enable-linger admin`, done declaratively since that command
  # itself needs root.
  systemd.tmpfiles.rules = [ "f /var/lib/systemd/linger/${username} 0644 root root -" ];
}
