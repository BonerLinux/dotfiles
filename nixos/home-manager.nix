{ config, pkgs, lib, username, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {
    inherit username inputs;
  };

  home-manager.sharedModules = [
    inputs.nixvim.homeModules.nixvim
  ];

  home-manager.users = {
    ${username} = import ./users/${username}.nix;
  };
}
