{ config, pkgs, lib, ... }: 

{
  musnix.enable = true;
  environment.systemPackages = with pkgs; [
    ardour
    guitarix
    qpwgraph
    qjackctl

    hydrogen
    sfizz
    x42-avldrums
    helm
    vital
    surge-XT
    distrho-ports
    odin2
    eq10q
    lsp-plugins
  ];

}
