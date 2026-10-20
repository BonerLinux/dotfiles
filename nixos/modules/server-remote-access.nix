# Dedicated outbound SSH access from `server` to the workstations, used by
# Claude Code Remote Control running on `server` to reach into `desktop` and
# `laptop`. See nixos/secrets/secrets.nix for the key rationale.
{ username, pkgs, hosts, ... }:
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
      HostName ${hosts.desktop.ip}
      User ${hosts.desktop.user}
      IdentityFile /run/agenix/server-to-desktop-key

    # The laptop only answers on its home-LAN address when it's actually
    # home. Off home Wi-Fi, NetworkManager auto-brings up the "clownweb"
    # WireGuard tunnel, and the laptop is only reachable at its tunnel
    # address instead - see hosts/laptop/configuration.nix's
    # vpn-autoconnect dispatcher. Probe the LAN address first and fall
    # back to the tunnel address so `ssh laptop` keeps working in both
    # states.
    Host laptop
      HostName ${hosts.laptop.ip}
      User ${hosts.laptop.user}
      IdentityFile /run/agenix/server-to-laptop-key
      ProxyCommand ${pkgs.netcat}/bin/nc -z -w2 ${hosts.laptop.ip} 22 </dev/null >/dev/null 2>/dev/null && exec ${pkgs.netcat}/bin/nc ${hosts.laptop.ip} 22 || exec ${pkgs.netcat}/bin/nc ${hosts.laptop.tunnelIp} 22

    Host router
      HostName ${hosts.router.ip}
      User ${hosts.router.user}
      IdentityFile /run/agenix/server-to-router-key
  '';

  # Let the admin user's systemd --user instance (and the
  # claude-remote-control.service defined on it, see users/admin.nix)
  # start at boot and keep running with no login session. Equivalent to
  # `loginctl enable-linger admin`, done declaratively since that command
  # itself needs root.
  systemd.tmpfiles.rules = [ "f /var/lib/systemd/linger/${username} 0644 root root -" ];
}
