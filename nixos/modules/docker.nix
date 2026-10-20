inputs@{ config, pkgs, lib, ... }:
let
  standardUser = inputs.username;
in
{
    users.users.${standardUser}.extraGroups = [ "docker" ];

    virtualisation.docker = {
      enable = true;
      # Socket-activated instead of eagerly started: docker.service sat
      # directly in the critical path to graphical.target, adding ~2.5s to
      # every login for a daemon that isn't needed until something actually
      # runs `docker`. The daemon now starts on first use instead. Trade-off:
      # containers with a restart policy no longer auto-start at boot - they
      # come back once docker is first touched in a session.
      enableOnBoot = false;
      package = pkgs.docker_25;
    };

    # Optional: only enable if NVIDIA is also enabled
    hardware.nvidia-container-toolkit.enable = lib.mkIf (lib.any (d: d == "nvidia") (config.services.xserver.videoDrivers or [])) true;
}

