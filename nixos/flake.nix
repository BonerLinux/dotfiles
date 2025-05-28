{
  description = "My nix flake for managing my computers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    hyprland.url = "github:hyprwm/hyprland?ref=v0.36.0";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    musnix.url = "github:musnix/musnix";
  };

  outputs = { self, nixpkgs, unstable, ... } @inputs: 
  let
    system = "x86_64-linux";

    user = "rileyboughner";

  in
  {
    nixosConfigurations.hp = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit user; };
      modules = [
        ./hardware/hp.nix
        ./hosts/hp.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/hyprland.nix
        ./modules/syncthing.nix
        ./modules/battery.nix
        ./modules/fun.nix
      ];
    };
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit user; };
      modules = [
        ./hardware/thinkpad.nix
        ./hosts/thinkpad.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/hyprland.nix
        ./modules/gnome.nix
        ./modules/battery.nix
        ./modules/fun.nix
      ];
    };
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit user; };
      modules = [
        ./hardware/desktop.nix
        ./hosts/desktop.nix
        ./users/standard.nix
        ./configuration.nix
        ./modules/gaming.nix
        inputs.musnix.nixosModules.musnix
        ./modules/music.nix
        ./modules/syncthing.nix
        ./modules/nvidia.nix
        ./modules/ssh.nix
        ./modules/gnome.nix
        ./modules/hyprland.nix
      ];
    };
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit user; };
      modules = [
        ./hardware/laptop.nix
        ./hosts/laptop.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/gnome.nix
        ./modules/syncthing.nix
        ./modules/ssh.nix
        ./modules/work.nix
        ./modules/nvidia.nix
        ./modules/hyprland.nix
        ./modules/battery.nix
      ];
    };
    nixosConfigurations.server = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit user; };
      modules = [
        ./hardware/server.nix
        ./hosts/server.nix
        ./users/admin.nix
        ./configuration.nix

        ./modules/nvidia.nix
      ];
    };
  };
}
