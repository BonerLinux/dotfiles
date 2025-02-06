{ config, pkgs, lib, ... }: 

{

  environment.systemPackages = with pkgs; [
    upower
  ];

  programs.zsh.shellAliases = {
    battery = "upower -i $(upower -e | grep 'BAT') | grep -E 'percentage'";
  }

}
