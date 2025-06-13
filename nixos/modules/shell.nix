{ config, pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Set up shell aliases
    shellAliases = {
      fetch = "clear && fastfetch";
      rm = "rm -r";
      r = "ranger";
      b = "nvim ~/.bookmarks";

      rebuild = "~/.system/scripts/rebuild";
      update = "~/.system/scripts/update";

      backup = "~/.system/scripts/backup";

      sync = "~/.system/scripts/sync";
      etch = "~/.system/scripts/etch";

      build-installer = "~/.system/scripts/build-installer";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";    
    };
  };

  environment.variables.EDITOR = "nvim";
}
