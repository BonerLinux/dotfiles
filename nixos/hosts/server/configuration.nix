{ config, pkgs, ...}: 

{
  imports =
    [ # Include the results of the hardware scan.
      ../../configuration.nix
      ../../modules/nvidia.nix
      ../../modules/docker.nix
      ../../modules/kubernetes.nix
      ../../modules/nfs-server.nix
      ../../modules/samba-server.nix
      ../../modules/tank-backup.nix
      ../../modules/quickemu.nix
      # ../../modules/vm-cyber-defence.nix  # temporarily disabled to free RAM for windows-11 install
      ../../modules/vm-windows-11.nix
    ];

  networking.hostName = "server";
  # Data volume: 2-disk BTRFS RAID ("tank"). Never declared here, so the
  # 2026-11-09 crash left it unmounted and every service broke (530s).
  fileSystems."/mnt/tank" = {
    device = "/dev/disk/by-label/tank";
    fsType = "btrfs";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -- ports --
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  # Open necessary ports (already correct)
  networking.firewall.allowedTCPPorts = [ 80 443 5930 5931 ];
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
    MEDIA_DIRECTORY = "/mnt/tank/media";
    SERVICE_DIRECTORY = "/mnt/tank/services";
  };
  
}
