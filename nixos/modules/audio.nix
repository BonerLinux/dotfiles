{ config, pkgs, username, inputs, lib, ... }:
let
  standardUser = username;

  # ardour/qjackctl/guitarix link real jack2's client lib (libjack2) at
  # build time, which speaks jackd's actual IPC protocol - there is no
  # real jackd here for it to find. PipeWire ships an ABI-compatible
  # libjack.so that talks to PipeWire instead, but its "jack" output
  # has no jack.pc, so overriding libjack2 at build time breaks these
  # packages' pkg-config/meson/waf checks (and a global overlay on
  # libjack2 recurses: pipewire depends on ffmpeg-headless, which links
  # libjack2 for its own JACK muxer support).
  # Fix: build normally against real jack2, then wrap the resulting
  # binaries to prefer pipewire's libjack.so at runtime - these
  # binaries use RUNPATH (not RPATH), so LD_LIBRARY_PATH takes effect.
  withPipewireJack = pkg: pkgs.symlinkJoin {
    name = "${pkg.pname or pkg.name}-pipewire-jack";
    paths = [ pkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in $out/bin/*; do
        wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${pkgs.pipewire.jack}/lib"
      done
    '';
  };
in
{
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  musnix.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol
    alsa-utils
    playerctl

    (withPipewireJack ardour)
    qpwgraph
    (withPipewireJack qjackctl)

    # x42-avldrums
    (withPipewireJack guitarix)
    # hydrogen
    # sfizz
    # helm
    # vital
     surge-XT
    # distrho-ports
    # odin2
    # eq10q
    drumgizmo
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
