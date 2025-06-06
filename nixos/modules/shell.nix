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
      r = "ranger";
      n = "nvim";
      rebuild = "~/.system/scripts/rebuild";

      sync = "~/.system/scripts/sync";
      etch = "~/.system/scripts/etch";

      cloud = "sshfs admin@192.168.1.201:/mnt/tank/cloud ~/Cloud";

      build-installer = "~/.system/scripts/build-installer";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";    
    };
  };

  environment.variables.EDITOR = "nvim";
}
