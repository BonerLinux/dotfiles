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
  hardware.pulseaudio.enable = false;
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

  # -- shell --
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      battery = "upower -i $(upower -e | grep 'BAT') | grep -E 'percentage'";
      fetch = "clear && fastfetch";
      dots = "cd ~/.system/config";
      r = "ranger";
      n = "nvim";
      sync = "~/.system/scripts/sync";
      rebuild = "~/.system/scripts/rebuild";
      link = "~/.system/scripts/set-symlinks";
      
      vpn-up = "sudo wg-quick up ~/.vpns/clownweb.conf";
      vpn-down = "sudo wg-quick down ~/.vpns/clownweb.conf";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";
    };
  };

  # -- services --
  virtualisation.docker.enable = true;

  # -- packages --
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    wireguard-tools
    git
    oh-my-posh
    stow
    yq
    ranger
    ueberzugpp #for image previews in ranger
    discord
    vscode
    gcc
    pass
    tree
    firefox
    nodejs
    create-react-app
    neovim
    unzip
    brave
    kitty
    tldr
    ripgrep
    create-react-app
    nodejs
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

  system.stateVersion = "24.11";
}
