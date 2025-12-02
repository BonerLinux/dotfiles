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

    userModule = { username, extraGroups ? [ ] }: {
      users.users.${username} = {
        isNormalUser = true;
        group = username;
        extraGroups = [ "wheel" ] ++ extraGroups;
      };
      users.groups.${username} = {}; 
    };

    #options
    username = "rileyboughner";
    serverUsername = "admin";

    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in
  {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/desktop/configuration.nix
	(userModule { username = username; })

        ./modules/hyprland.nix
        ./modules/gaming.nix
        ./modules/audio.nix
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/laptop/configuration.nix
	(userModule { username = username; })

        ./modules/hyprland.nix
        ./modules/audio.nix
        ./modules/osint.nix
        ./modules/quickemu.nix
      ];
    };

    nixosConfigurations.server = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; username = serverUsername; };
      modules = [
        ./hosts/server/configuration.nix
	(userModule { username = serverUsername; extraGroups = [ "admin" ]; })
      ];
    };
  };
}
