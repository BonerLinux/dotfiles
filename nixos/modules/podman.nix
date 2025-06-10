{ config, pkgs, lib, ... }: 

{
  virtualisation.podman = {
      enable = true;
      dockerCompat = false; # optional: makes `docker` an alias to `podman`
      defaultNetwork.settings.dns_enabled = true;
    };
  environment.systemPackages = with pkgs; [
    podman-tui
    podman-desktop
    podman-compose
  ];
  hardware.nvidia-container-toolkit.enable = true;
}
