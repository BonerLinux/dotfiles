{ config, pkgs, ...}: 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -- hostname --
  networking.hostName = "clownweb";

  # -- ports --
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # -- mounts --
    fileSystems."/mnt/tank" = {
      device = "UUID=76b26a47-20a0-483e-a02d-3154c16779aa";
      fsType = "btrfs";
      options = [ "degraded" "nofail" "compress=zstd" ];
    };

  # -- packages --
  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];
  
 # -- services --
 virtualisation.docker.enable = true;
 services.openssh.enable = true;

}
