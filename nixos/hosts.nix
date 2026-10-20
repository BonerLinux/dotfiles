# Single source of truth for this LAN's machines, used by any module that
# needs to reach another host by address (ssh.nix, nfs-client.nix,
# nfs-server.nix, server-remote-access.nix) instead of hand-typing IPs/users.
{
  lan = "192.168.1.0/24";
  tunnel = "10.0.0.0/24";

  desktop = {
    ip = "192.168.1.4";
    user = "rileyboughner";
  };

  laptop = {
    ip = "192.168.1.3";
    # Only reachable here when the laptop is on the home LAN. Off home
    # Wi-Fi, NetworkManager auto-brings up the "clownweb" WireGuard tunnel
    # and the laptop answers at this address instead - see
    # hosts/laptop/configuration.nix's vpn-autoconnect dispatcher.
    tunnelIp = "10.0.0.3";
    user = "rileyboughner";
  };

  server = {
    ip = "192.168.1.2";
    user = "admin";
  };

  router = {
    ip = "192.168.1.1";
    user = "root";
  };
}
