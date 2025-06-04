{
  description = "My nix flake for managing my computers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    hyprland.url = "github:hyprwm/hyprland?ref=v0.36.0";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    musnix.url = "github:musnix/musnix";
  };

  outputs = { self, nixpkgs, unstable, ... } @inputs: 
  let
    system = "x86_64-linux";
    username = "rileyboughner";

  in
  {
      
    nixosConfigurations.ISO = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [ ( { pkgs, modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
            ./users/standard.nix
            ./modules/shell.nix
            ./modules/fun.nix
          ];
          environment.systemPackages = [ pkgs.cmatrix ];
          networking.hostName = "NixISO";

        } )
      ];
    };

    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hardware/thinkpad.nix
        ./hosts/thinkpad.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/hyprland.nix
        ./modules/gnome.nix
        ./modules/fun.nix
      ];
    };
        
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hardware/desktop.nix
        ./hosts/desktop.nix
        #./hosts/desktop/configuration.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/wireless-networking.nix
        ./modules/shell.nix
        ./modules/kdeconnect.nix
        ./modules/docker.nix
        ./modules/gaming.nix
        ./modules/syncthing.nix
        inputs.musnix.nixosModules.musnix
        ./modules/music.nix
        ./modules/nvidia.nix
        ./modules/ssh.nix
        ./modules/hyprland.nix
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/laptop/configuration.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/wireless-networking.nix
        ./modules/shell.nix
        ./modules/hyprland.nix
        ./modules/syncthing.nix
        ./modules/ssh.nix
        ./modules/work.nix
      ];
    };

    nixosConfigurations.server = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
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
