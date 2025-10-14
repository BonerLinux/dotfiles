inputs@{ config, pkgs, lib, ... }: 
let
  standardUser = inputs.username;
in 
{

  users.users.${standardUser} = {
    isNormalUser = true;
    group = standardUser;
    extraGroups = [ "wheel" ];
  };
  users.groups.${standardUser} = {};

}
