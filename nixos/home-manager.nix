# add home manager config to users/username.nix
{ config, pkgs, lib, username, inputs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit username; };

  home-manager.users = {
    ${username} = import ./users/${username}.nix;
  };
}

