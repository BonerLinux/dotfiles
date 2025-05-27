{ config, pkgs, lib, ... }: 

{
  services.vaultwarden = {
    enable = true;
  };
}
