{ pkgs, config, inputs, ... }:

{
  imports = [
    ./programs.nix
  ];

  programs.hyprland.enable = true;

  environment.sessionVariables = {
    HYPRSHOT_DIR  = "$HOME/Pictures/Screenshots";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.noto
  ];

  environment.systemPackages = with pkgs; [

    hyprpwcenter
    hyprlauncher
    hyprpaper
    hyprshot

    quickshell
    kdePackages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects

    libnotify
    mako
    brightnessctl
    swayosd
    gtk3
    brave
    kitty
    swaybg
    wl-clipboard
    pyprland
    pywal16
    imagemagick
    pywalfox-native
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default

    #waybar

  ];

  environment.shellInit = ''
    (cat ~/.cache/wal/sequences &)
  '';
}
