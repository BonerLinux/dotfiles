{ config, pkgs, inputs, username, ... }: {
	  imports = [
            /etc/nixos/hardware-configuration.nix
	    inputs.agenix.nixosModules.default
	    ./modules/shell.nix
	    ./modules/nvim.nix
	    ./modules/ssh.nix
	  ];

	  system.stateVersion = "26.05";

	  # Boot
	  boot.loader.systemd-boot.enable = true;
	  boot.initrd.systemd.enable = true;
	  boot.loader.efi.canTouchEfiVariables = true;
	  boot.kernelPackages = pkgs.linuxPackages;
	  #boot.kernelPackages = pkgs.linuxPackages_zen;
	  #boot.kernelParams = [ "8250.nr_uarts=0" ];

	  
	  systemd.settings = {
	    Manager = {
	      DefaultTimeoutStopSec = "10s";
	      DefaultTimeoutStartSec = "10s";
	    };
	  };

	  # Local
	  time.timeZone = "America/New_York";
	  i18n.defaultLocale = "en_US.UTF-8";
	  i18n.extraLocaleSettings = {
	    LC_ADDRESS = "en_US.UTF-8";
	    LC_IDENTIFICATION = "en_US.UTF-8";
	    LC_MEASUREMENT = "en_US.UTF-8";
	    LC_MONETARY = "en_US.UTF-8";
	    LC_NAME = "en_US.UTF-8";
	    LC_NUMERIC = "en_US.UTF-8";
	    LC_PAPER = "en_US.UTF-8";
	    LC_TELEPHONE = "en_US.UTF-8";
	    LC_TIME = "en_US.UTF-8";
	  };

	  # services
	  # services.fwupd.enable = true;
	  # services.udisks2.enable = true;

	  documentation.nixos.enable = false;
	  nixpkgs.config.allowUnfree = true;


	  environment.systemPackages = with pkgs; [ # These are essential programs
	    stow
      prismlauncher
      claude-code
	  ];

	  # -- nix-ld --
	  # Lets unpatched dynamically-linked binaries run (e.g. Prism Launcher's
	  # auto-downloaded Mojang JVMs), which otherwise fail to execute on NixOS
	  # since it lacks the standard FHS paths they expect.
	  programs.nix-ld.enable = true;
	  programs.nix-ld.libraries = with pkgs; [
	    zlib
	    stdenv.cc.cc.lib
	  ];

	  # -- gnupg --
	  programs.gnupg.agent = {
	    enable = true;
	    pinentryPackage = pkgs.pinentry-tty;
	  };

	  # -- garbage collection --
	  nix.settings.experimental-features = [ "nix-command" "flakes" ]; nix.gc = {
	    automatic = true;
	    dates = "weekly";
	    options = "--delete-older-than 7d";
	  };

	  # Let `boner rebuild` run without a password prompt. Note this is a
	  # much wider grant than the other NOPASSWD rules in this repo (e.g.
	  # wireless-networking.nix's wg-quick toggle): nixos-rebuild switch
	  # activates arbitrary root-owned config, so this is effectively
	  # passwordless root for this user via `boner rebuild`/`boner update`.
	  security.sudo.extraRules = [
	    {
	      users = [ username ];
	      commands = [
	        {
	          command = "/run/current-system/sw/bin/nixos-rebuild switch --flake * --impure";
	          options = [ "NOPASSWD" ];
	        }
	      ];
	    }
	  ];

}
