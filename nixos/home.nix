{ config, pkgs, username, ...}: {

  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = "/home/${username}";
  
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Riley Boughner";
    userEmail = "riley@clownweb.net";
    extraConfig = {
      credential.helper = "store";
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Everforest-Dark-BL-LB";
      package = pkgs.everforest-gtk-theme;
     };
     iconTheme = {
      name = "Everforest-Dark";
      package = pkgs.everforest-gtk-theme;
     };
     cursorTheme = {
      name = "capitaine-cursors-white";
      package = pkgs.capitaine-cursors;
     };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}

