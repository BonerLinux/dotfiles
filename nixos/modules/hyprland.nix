{ pkgs, config, inputs, ... }:

{
  programs.hyprland.enable = true;

  environment.sessionVariables = {
    HYPRSHOT_DIR  = "$HOME/Pictures/Screenshots";
  };



  fonts.packages = with pkgs; [
    nerd-fonts.noto
  ];

  environment.systemPackages = with pkgs; [

    swayosd
    gtk3
    everforest-gtk-theme
    brave
    kitty
    hyprlock
    waybar
    swaybg
    wl-clipboard
    pyprland
    pywal16
    wofi
    hyprpaper
    imagemagick
    pywalfox-native
    hyprshot
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default

  ];

  environment.shellInit = ''
    (cat ~/.cache/wal/sequences &)
  '';
}
