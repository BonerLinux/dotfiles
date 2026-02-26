{ config, pkgs, ...}: 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../configuration.nix
      ../../modules/nvidia.nix
      ../../modules/docker.nix
      ../../modules/kubernetes.nix
      ./nfs_server.nix
    ];

  networking.hostName = "server";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -- ports --
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  # Open necessary ports (already correct)
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  # Add NAT and forwarding rules for WireGuard
  #networking.firewall.extraCommands = ''
  #  iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT
  #  iptables -A FORWARD -i eth0 -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT
  #  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  #'';

  # packages
  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  environment.sessionVariables = {
    SERVICE_DIRECTORY = "/mnt/tank/services";
  };
  
}
