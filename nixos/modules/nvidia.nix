{ config, pkgs, lib, ... }: 

{
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  services.xserver.videoDrivers = [ "nvidia" ];
}
