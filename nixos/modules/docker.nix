{ config, pkgs, lib, ... }:

{
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      package = pkgs.docker_25;
    };

    # Optional: only enable if NVIDIA is also enabled
  hardware.nvidia-container-toolkit.enable = lib.mkIf (lib.any (d: d == "nvidia") (config.services.xserver.videoDrivers or [])) true;
}

