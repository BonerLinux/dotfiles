{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../configuration.nix
      ../../modules/wireless-networking.nix
      ../../modules/nfs-client.nix
    ];

  networking.hostName = "laptop";

  # -- lid switch --
  # Shut down on lid close (undocked/battery); ignored when docked
  # so an external monitor can still be used in clamshell mode.
  services.logind.settings.Login = {
    HandleLidSwitch = "poweroff";
    HandleLidSwitchExternalPower = "poweroff";
    HandleLidSwitchDocked = "ignore";
  };

  # -- fingerprint --
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;

  # -- fingerprint --
  #services.fprintd.enable = true;
  #security.pam.services.sudo.fprintAuth = true;
  #systemd.services.fprind = {
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig.Type = "simple";
  #};
}

