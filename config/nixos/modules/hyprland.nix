{ pkgs, config, inputs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
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
