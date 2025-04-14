{ config, pkgs, lib, ... }: 

{
  musnix.enable = true;
  environment.systemPackages = with pkgs; [
    ardour
    guitarix
    qpwgraph

    x42-avldrums
    tunefish
    helm
    vital
    surge-XT
    distrho-ports
    odin2
    eq10q
    lsp-plugins
  ];

}
