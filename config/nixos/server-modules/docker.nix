{ config, pkgs, lib, ... }: 

{
 
virtualization.docker.enable = true;

users.extraGroups.docker.members = [ "admin" ];

}
