{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, unstable }: 
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem{
      inherit system;
      modules = [
        ./configuration.nix
	./hosts/thinkpad.nix

	./modules/hyprland.nix
	./modules/battery.nix
	./modules/fun.nix
      ];
    };
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem{
      inherit system;
      modules = [
        ./configuration.nix
	./hosts/desktop.nix

	./modules/nvidia.nix
	./modules/hyprland.nix
      ];
    };
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem{
      inherit system;
      modules = [
	./hardware/laptop.nix
        ./configuration.nix
	./hosts/laptop.nix

	./modules/nvidia.nix
	./modules/hyprland.nix
	./modules/battery.nix
	./modules/quickemu.nix
      ];
    };
  };
}
