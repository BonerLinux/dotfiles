{ config, pkgs, lib, ... }: 

{

programs.neovim = {
  enable = true;
  defaultEditor = true;
  vimAlias = true;
  viAlias = true;

};

programs.zsh.shellAliases = {
  n = "nvim";
};

environment.systemPackages = with pkgs; [
    neovim
    gnumake
    gcc
    ueberzugpp
    fzf
    ripgrep
];

}
