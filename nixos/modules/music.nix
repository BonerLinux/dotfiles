{ config, pkgs, username, lib, ... }: 
let
  standardUser = username;
in
{
  musnix.enable = true;
  environment.systemPackages = with pkgs; [
    pavucontrol
    alsa-utils
    playerctl

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

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."context.properties" = {
      "default.clock.rate" = 44100;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 1024;
      "default.clock.max-quantum" = 1024;
    };
  };

  users.users.${standardUser}.extraGroups = [ "audio" ];

}
