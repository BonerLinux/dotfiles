{ config, pkgs, ... }: 

{
  # -- hostname --
  networking.hostName = "thinkpad";

  # -- packages -- 
  environment.systemPackages = with pkgs; [
  ];

  # -- custom --
}
