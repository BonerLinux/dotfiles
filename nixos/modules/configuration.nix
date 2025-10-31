{ config, pkgs, ... }: {
	  imports = [];

	  system.stateVersion = "25.05";

	  # Boot
	  boot.loader.systemd-boot.enable = true;
	  boot.initrd.systemd.enable = true;
	  boot.loader.efi.canTouchEfiVariables = true;
	  boot.kernelPackages = pkgs.linuxPackages_zen;
	  boot.kernelParams = [ "8250.nr_uarts=0" ];

	  systemd.extraConfig = ''
	    DefaultTimeoutStartSec=5s
	    DefaultTimeoutStopSec=5s
	  '';
	  
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
	    home-manager

            gemini-cli #for testing
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

}
