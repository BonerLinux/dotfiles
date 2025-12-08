{ config, pkgs, username, ...}: {

  home.stateVersion = "25.11";
  home.username = username;
  home.homeDirectory = "/home/${username}";
  
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number
      set nowrap
      set ignorecase
    '';
    plugins = with pkgs.vimPlugins; [
      #nvim-treesitter.withAllGrammars
      nvim-lspconfig
    ];
  };

  programs.git = {
    enable = true;
    settings.user.name = "Riley Boughner";
    settings.user.email = "riley@clownweb.net";
    settings = {
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

