{ config, pkgs, lib, ... }: 

{

users.users.admin = {
    isNormalUser = true;
    description = "admin";
    extraGroups = [ "networkmanager" "wheel" "admin" "audio" ];
    packages = with pkgs; [];
  };

}
