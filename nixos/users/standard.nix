{ config, specialArgs, pkgs, lib, ... }: 
let
  user = specialArgs.user;
in 
{

users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "${user}" "audio" "docker" ];
  };

}
