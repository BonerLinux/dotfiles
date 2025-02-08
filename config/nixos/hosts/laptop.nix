{ config, pkgs, ...}: 

{
  # -- hostname --
  networking.hostName = "laptop";

  # -- packages --
  environment.systemPackages = with pkgs; [
  ];
  
  # -- services --
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

# -- services --
  services.logind.lidSwitch = "suspend";

}
