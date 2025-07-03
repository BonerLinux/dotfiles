{ config, pkgs, lib, ... }: 
let
  cfg = config.features.docker;
in
{
  options.features.docker.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Docker with optional NVIDIA runtime.";
  };

  config = lib.mkIf cfg.enable {
    #enable docker
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      package = pkgs.docker_25;
    };

    #add the user to the docker group
    #users.users.${config.user.username}.extraGroups = [ "docker" ];

    #enable the nvidia tooklit if nvidia is enabled
    hardware.nvidia-container-toolkit.enable = lib.mkIf config.features.nvidia.enable true;
    #hardware.nvidia-container-toolkit.enable = true;
  };
}
