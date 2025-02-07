{ config, pkgs, ... }:

{
  imports = [];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # -- locale -- 
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

  # -- desktop -- 
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # -- sound -- 
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

  };

  # -- users --
  users.users.rileyboughner = {
    isNormalUser = true;
    description = "Riley Boughner";
    extraGroups = [ "networkmanager" "wheel" "rileyboughner" ];
    packages = with pkgs; [];
  };

  # -- shell --
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      battery = "upower -i $(upower -e | grep 'BAT') | grep -E 'percentage'";
      n = "nvim";
      link = "~/.dotfiles/scripts/set-symlinks";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";
    };
  };

  # -- packages --
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gcc
    firefox
    neovim
    brave
    kitty
    starship
    tldr
    ripgrep
    bat
    fd
    fzf
    pavucontrol
    fastfetch
    newsboat
    git
    python3 #needed for pywalfox
  ];
  
  # -- services --
  services.printing.enable = true; #CUPS printing

  # -- system stuff --
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  system.stateVersion = "24.11";
}
