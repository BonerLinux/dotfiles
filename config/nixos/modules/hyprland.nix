{ pkgs, config, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    pyprland
    pywal16
    wofi
    hyprpaper
    imagemagick
    pywalfox-native
    hyprshot
  ];

  environment.shellInit = ''
    (cat ~/.cache/wal/sequences &)
  '';
}
