{ config, pkgs, lib, ... }: 

{
  musnix.enable = true;
  environment.systemPackages = with pkgs; [
    ardour
    guitarix
    qpwgraph
  ];

}
