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
        ./modules/nvidia.nix
        ./modules/configuration.nix

        ./modules/newsboat.nix
        ./modules/filesystems.nix
        ./modules/nvim.nix
        ./modules/wireless-networking.nix
        ./modules/hyprland.nix
        ./modules/shell.nix
        ./modules/docker.nix
        ./modules/gaming.nix
        ./modules/music.nix
        ./modules/ssh.nix
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem{
      inherit system;
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        ./hosts/laptop/configuration.nix
	(userModule { username = username; })
	./modules/configuration.nix

        ./modules/wireless-networking.nix
        ./modules/hyprland.nix
        inputs.musnix.nixosModules.musnix
        ./modules/music.nix
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
      specialArgs = { inherit inputs; username = serverUsername; };
      modules = [
        ./hosts/server/configuration.nix
	(userModule { username = serverUsername; extraGroups = [ "admin" ]; })
        ./modules/nvidia.nix
        ./modules/configuration.nix

        ./modules/docker.nix
        ./modules/nvim.nix
        ./modules/shell.nix
      ];
    };
  };
}
