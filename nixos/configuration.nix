{ config, pkgs, ... }:

{
  imports = [  
  ];

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

  # -- sound -- 
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."context.properties" = {
      "default.clock.rate" = 44100;
      "default.clock.quantum" = 1024;     # buffer size in frames
      "default.clock.min-quantum" = 1024;
      "default.clock.max-quantum" = 1024;
    };
  };

  # -- bluetooth --
  hardware.bluetooth.enable = true;

  # -- shell --
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      fetch = "clear && fastfetch";
      r = "ranger";
      n = "nvim";
      sync = "~/.system/scripts/sync";
      rebuild = "~/.system/scripts/rebuild";
      cloud = "sshfs admin@192.168.1.201:/mnt/tank/cloud ~/Cloud";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";
    };
  };

  # -- packages --
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    alsa-utils
    wireguard-tools
    git
    oh-my-posh
    stow
    yq
    direnv
    cider
    playerctl
    fum
    cava
    libnotify
    mako
    bluez
    gowall
    ranger
    ueberzugpp #for image previews in ranger
    discord
    vscode
    gcc
    pass
    sshfs
    tree
    firefox
    gnumake
    neovim
    unzip
    brave
    kitty
    tldr
    ripgrep
    bat
    fd
    fzf
    pavucontrol
    fastfetch
    libreoffice
    bluetuith
  ];

  
  # -- gnupg --
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };


  # -- system stuff --
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.05";
}
