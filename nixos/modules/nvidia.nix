{ config, pkgs, lib, ... }: 
let
  cfg = config.features.nvidia;
in
{
  
  options.features.nvidia.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Nvidia drivers and settings";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;
    };
  };
}
