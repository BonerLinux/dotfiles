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
      nt = "ping cloudflare.com";

      mk = "touch";

      sizeof = "du -sh";

      install = "~/.system/scripts/install.sh";
      rebuild = "~/.system/scripts/rebuild";
      update = "~/.system/scripts/update";

      ventoy = "~/.system/scripts/ventoy.sh";

      secrets = "~/.system/scripts/secrets.sh";

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
