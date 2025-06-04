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
      sync = "~/.system/scripts/sync";
      rebuild = "~/.system/scripts/rebuild";
      cloud = "sshfs admin@192.168.1.201:/mnt/tank/cloud ~/Cloud";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";    
    };
  };

  environment.variables.EDITOR = "nvim";
}
