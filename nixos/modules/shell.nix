{ config, pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    git
    ranger
    tldr
    tree
    oh-my-posh
    fastfetch

    cowsay
    sl
    asciiquarium
    cmatrix
    cbonsai
  ];


  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Set up shell aliases
    shellAliases = {
      os="qemu-system-x86_64 -m 4G -smp 4 -enable-kvm -cpu host -drive file=$HOME/.vms/ubuntu/ubuntu.img,format=qcow2 -nic user -vga virtio";
      fetch = "clear && fastfetch";
      cd = "z";
      rm = "rm -r";

      install = "~/.system/scripts/install.sh";
      rebuild = "~/.system/scripts/rebuild";
      update = "~/.system/scripts/update";

      #ventoy = "~/.system/scripts/ventoy.sh";
      #secrets = "~/.system/scripts/secrets.sh";
      #backup = "~/.system/scripts/backup";
      #sync = "~/.system/scripts/sync";
      #etch = "~/.system/scripts/etch";
      #build-installer = "~/.system/scripts/build-installer";
      
      fart = "systemctl suspend";
      shart = "reboot";
      shit = "shutdown -h now";    
    };
  };

  environment.variables.EDITOR = "nvim";
}
