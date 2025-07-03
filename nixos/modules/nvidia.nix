{ config, pkgs, lib, ... }:

let
  cfg = config.features.nvidia;
in
{
  options.features.nvidia.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable NVIDIA drivers and support.";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
    };
  };
}

