{ config, pkgs, lib, ... }:
{
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      # "stable"/"production" currently both resolve to 595.71.05, which has
      # a Vulkan shader-compiler segfault (crashes in libnvidia-gpucomp.so
      # during pipeline compilation - hit by both gamescope and Steam's
      # native UI). legacy_580 is the last driver generation before this
      # regression and fully supports Ampere/RTX 3080.
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # Useful anywhere this GPU is present, including headless hosts doing
  # hardware video transcode (e.g. Immich/Jellyfin on the server).
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
  };
}

