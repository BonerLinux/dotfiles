{ config, pkgs, lib, ... }: 

{

users.users.admin = {
    isNormalUser = true;
    description = "admin";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [

    ];
    packages = with pkgs; [];
  };

}
