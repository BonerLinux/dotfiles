{
  description = "";

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
  in
  {
    nixosConfigurations.hp = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/hp.nix
        ./configuration.nix
        ./hosts/hp.nix

        ./modules/hyprland.nix
        ./modules/syncthing.nix
        ./modules/battery.nix
        ./modules/fun.nix
      ];
    };
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/thinkpad.nix
        ./users/rileyboughner.nix
        ./configuration.nix
        ./hosts/thinkpad.nix

        ./modules/hyprland.nix
        ./modules/syncthing.nix
        ./modules/battery.nix
        ./modules/fun.nix
      ];
    };
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/desktop.nix
        ./users/rileyboughner.nix
        ./configuration.nix
        ./hosts/desktop.nix

        ./server-modules/vaultwarden.nix
<<<<<<< HEAD
        ./modules/music.nix
        ./modules/gaming.nix
=======
>>>>>>> 080e856 (updated music module and desktop flake for proper music production -> musnix)
        inputs.musnix.nixosModules.musnix
        ./modules/music.nix
        ./modules/syncthing.nix
        ./modules/nvidia.nix
        ./modules/ssh.nix
        ./modules/hyprland.nix
      ];
    };
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/laptop.nix
        ./users/rileyboughner.nix
        ./configuration.nix
        ./hosts/laptop.nix

        inputs.musnix.nixosModules.musnix
        ./modules/music.nix
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
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/server.nix
        ./users/admin.nix
        ./configuration.nix
        ./hosts/server.nix

      ];
    };
  };
}
