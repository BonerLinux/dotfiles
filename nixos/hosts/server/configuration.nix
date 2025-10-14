{ config, pkgs, ...}: 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # -- hostname --
  networking.hostName = "server";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -- ports --
  # Enable IP forwarding (already correct)
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  # Open necessary ports (already correct)
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  # Add NAT and forwarding rules for WireGuard
  networking.firewall.extraCommands = ''
    iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT
    iptables -A FORWARD -i eth0 -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  '';

  # -- mounts --
  fileSystems."/mnt/tank" = {
    device = "/dev/disk/by-label/tank";
    fsType = "btrfs";
    options = [ "compress=zstd" "nofail" "degraded" "autodefrag" ];
  };

  # -- packages --
  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];
  
}
