{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../configuration.nix
      ../../modules/wireless-networking.nix
      ../../modules/nfs-client.nix
      ../../modules/audio.nix
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

  # -- VPN auto-connect --
  # Bring the "clownweb" WireGuard tunnel up whenever we're not on home
  # Wi-Fi, and drop it when we're back home. Runs as root via a
  # NetworkManager dispatcher hook on every "up"/"down" event, so it needs
  # no sudo rule (unlike the manual toggle in the Quickshell bar).
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "vpn-autoconnect" ''
        interface="$1"
        action="$2"
        home_ssid="The-Clown-House"
        vpn_name="clownweb"
        wg_quick="/run/current-system/sw/bin/wg-quick"
        nmcli="/run/current-system/sw/bin/nmcli"

        case "$action" in
          up|down) ;;
          *) exit 0 ;;
        esac
        case "$interface" in
          lo|"$vpn_name") exit 0 ;;
        esac

        current_ssid=$("$nmcli" -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')

        if [ "$current_ssid" = "$home_ssid" ]; then
          "$wg_quick" down "$vpn_name" 2>/dev/null || true
        else
          "$wg_quick" up "$vpn_name" 2>/dev/null || true
        fi
      '';
      type = "basic";
    }
  ];
}

