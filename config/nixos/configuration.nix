{ config, pkgs, ... }:

{
  imports = [ ../hardware-configuration.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.allowedUDPPorts = [ 51820 ];


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
    extraGroups = [ "networkmanager" "wheel" "rileyboughner" "audio" ];
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
      fetch = "clear && ~/.myfetch/myfetch -d -c 8 -C ' NixOS '";
      n = "nvim";
      rebuild = "sudo nixos-rebuild switch --flake .#";
      link = "~/.dotfiles/scripts/set-symlinks";
      
      vpn-up = "sudo wg-quick up ~/.vpns/clownweb.conf";
      vpn-down = "sudo wg-quick down ~/.vpns/clownweb.conf";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";
    };
  };

  # -- packages --
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    git
    anki
    camtrix
    firefox
    neovim
    brave
    kitty
    tldr
    ripgrep
    bat
    fd
    fzf
    pavucontrol
    fastfetch
    newsboat
    libreoffice
    python3 #needed for pywalfox
    bluetuith
  ];
  
  # -- virtualisation --
  virtualisation.docker.enable = true;

  # -- system stuff --
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  system.stateVersion = "24.11";
}
