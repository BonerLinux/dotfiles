{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    hyprland.url = "github:hyprwm/hyprland?ref=v0.36.0";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
  };

  outputs = { self, nixpkgs, unstable, ... } @inputs: 
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/thinkpad.nix
        ./configuration.nix
        ./hosts/thinkpad.nix

        ./modules/hyprland.nix
        ./modules/battery.nix
        ./modules/fun.nix
      ];
    };
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/desktop.nix
        ./configuration.nix
        ./hosts/desktop.nix

        ./modules/nvidia.nix
        ./modules/hyprland.nix
      ];
    };
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/laptop.nix
        ./configuration.nix
        ./hosts/laptop.nix

        ./modules/work.nix
        ./modules/nvidia.nix
        ./modules/hyprland.nix
        ./modules/battery.nix
        ./modules/quickemu.nix
      ];
    };
  };
}
