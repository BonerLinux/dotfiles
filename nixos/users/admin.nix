inputs@{ config, pkgs, lib, ... }: 
{

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "admin" ];
  };
}
