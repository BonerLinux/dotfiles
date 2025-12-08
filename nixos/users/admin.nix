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
}

