{ config, pkgs, lib, ... }: 

{

users.users.rileyboughner = {
    isNormalUser = true;
    description = "Riley Boughner";
    extraGroups = [ "networkmanager" "wheel" "rileyboughner" ];
    packages = with pkgs; [];
  };

}
