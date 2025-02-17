{ config, pkgs, lib, ... }: 

{

  environment.systemPackages = with pkgs; [
    ardour
    guitarix
    qpwgraph
  ];

}
