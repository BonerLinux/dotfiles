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
    
    flags = [ " --cmd cd " ];
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
      shell = "nix-shell";

      clownweb = "sudo wg-quick up clownweb";
      cloud = "~/.system/scripts/cloud.sh";

      install = "~/.system/scripts/install.sh";
      rebuild = "~/.system/scripts/rebuild";
      update = "~/.system/scripts/update";

    };
  };

  environment.variables.EDITOR = "nvim";
}
