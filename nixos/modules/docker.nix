{ config, pkgs, lib, ... }: 

{
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      package = pkgs.docker_25;
      # Nvidia Docker (deprecated)
      #enableNvidia = true;
  };

  hardware.nvidia-container-toolkit.enable = true;

}
