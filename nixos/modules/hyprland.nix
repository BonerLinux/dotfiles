{ pkgs, config, inputs, username, ... }:

{
  imports = [
    ./programs.nix
  ];

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${config.programs.hyprland.package}/bin/start-hyprland";
      user = username;
    };
  };

  environment.sessionVariables = {
    HYPRSHOT_DIR  = "$HOME/Pictures/Screenshots";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [

    (pkgs.runCommand "random-wallpaper" { } ''
      install -Dm755 ${../../scripts/random-wallpaper} $out/bin/random-wallpaper
    '')

    (pkgs.runCommand "set-wallpaper" { } ''
      install -Dm755 ${../../scripts/set-wallpaper} $out/bin/set-wallpaper
    '')

    (pkgs.runCommand "restore-wallpaper" { } ''
      install -Dm755 ${../../scripts/restore-wallpaper} $out/bin/restore-wallpaper
    '')

    hyprpwcenter
    hyprlauncher
    hyprpaper
    hyprshot
    hyprpolkitagent

    papirus-icon-theme
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
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default

    #waybar

  ];

  environment.shellInit = ''
    (cat ~/.cache/wal/sequences &)
  '';
}
