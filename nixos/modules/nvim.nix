{ config, pkgs, lib, ... }: 

{

environment.systemPackages = with pkgs; [
    ueberzugpp
    neovim
    fzf
    ripgrep
];

}
