{
  description = "My nix flake for managing my computers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/hyprland?ref=v0.36.0";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    musnix.url = "github:musnix/musnix";
  };

  outputs = { self, nixpkgs, home-manager, ... } @inputs: 
  let
    system = "x86_64-linux";
    username = "rileyboughner";
    pkgs = nixpkgs.legacyPackages.${system};

  in
  {
      
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/thinkpad/configuration.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/hyprland.nix
      ];
    };
        
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/desktop/configuration.nix
        ./users/standard.nix
        ./configuration.nix

        ./modules/filesystems.nix
        ./modules/nvim.nix
        ./modules/wireless-networking.nix
        ./modules/hyprland.nix
        ./modules/shell.nix
          #./modules/podman.nix
        ./modules/docker.nix
        ./modules/nvidia.nix
        ./modules/gaming.nix
        inputs.musnix.nixosModules.musnix
        ./modules/music.nix
        ./modules/ssh.nix
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
        ./modules/hyprland.nix

        ./modules/osint.nix
        ./modules/vpn.nix
        ./modules/quickemu.nix
        ./modules/filesystems.nix
        ./modules/nvim.nix
        ./modules/shell.nix
        ./modules/ssh.nix
      ];
    };

    nixosConfigurations.server = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/server/configuration.nix
        ./users/admin.nix
        ./configuration.nix

        ./server-modules/nextcloud.nix

        ./modules/docker.nix
        ./modules/nvidia.nix
        ./modules/nvim.nix
        ./modules/shell.nix
      ];
    };

    homeConfigurations = {
        rileyboughner = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username; };
          modules = [ 
            ./home.nix 
          ];
        };
      };
  };
}
