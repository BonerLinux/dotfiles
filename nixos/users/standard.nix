{ config, username, pkgs, lib, ... }: 
let
  standardUser = username;
in 
{

users.users.${standardUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "${standardUser}" ];
  };


}
