{ pkgs, config, inputs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [

    waybar
    wl-clipboard
    pyprland
    pywal16
    wofi
    hyprpaper
    imagemagick
    pywalfox-native
    hyprshot
    nerdfonts
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  ];

  environment.shellInit = ''
    (cat ~/.cache/wal/sequences &)
  '';
}
