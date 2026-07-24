inputs@{ config, pkgs, lib, ... }:
let
  standardUser = inputs.username;
in
{
    users.users.${standardUser}.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      terraform
    ];
}

