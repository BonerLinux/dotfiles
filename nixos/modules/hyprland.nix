{ pkgs, config, lib, inputs, username, ... }:

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
    QT_QPA_PLATFORMTHEME = "qt6ct";
  } // lib.optionalAttrs (lib.elem "nvidia" config.services.xserver.videoDrivers) {
    # Hyprland (wlroots) needs these for Xwayland GLX/glamor + GBM buffer
    # sharing to work with the proprietary NVIDIA driver. Without them,
    # Xwayland clients (e.g. Steam) fail GLX visual selection or crash in
    # Vulkan WSI/present code, and DMA-BUF sharing falls back to slow SHM.
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __NV_DISABLE_EXPLICIT_SYNC = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
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
    qt6Packages.qt6ct
    kdePackages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects

    libnotify
    mako
    brightnessctl
    swayosd
    gcalcli
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
