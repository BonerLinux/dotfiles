{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../configuration.nix
      ../../modules/wireless-networking.nix
      ../../modules/nfs-client.nix
      ../../modules/quickemu.nix
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
  # Framework's built-in reader (Goodix Moc, USB ID 27c6:609c) is
  # supported directly by libfprint's gxfp driver, no TOD/proprietary
  # driver needed. After rebuilding, enroll a finger with:
  #   fprintd-enroll
  # and verify with:
  #   fprintd-verify
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;
}

