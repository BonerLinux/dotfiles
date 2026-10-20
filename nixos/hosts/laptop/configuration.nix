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

  # Trust the public half of server-to-laptop-key.age (see
  # nixos/secrets/secrets.nix), used by Claude Code Remote Control running
  # on `server` to reach this machine.
  users.users.rileyboughner.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHk8gh3PFQisND9c+yno1y837kTbP/CHm9KurwQV7fn server-to-laptop"
  ];

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
  # NetworkManager dispatcher hook, so it needs no sudo rule (unlike the
  # manual toggle in the Quickshell bar).
  #
  # Also reacts to "connectivity-change", not just "up"/"down": captive-
  # portal networks (college Wi-Fi) report the interface "up" the moment
  # you associate, well before you've passed the portal and have real
  # internet - an attempt at that point fails and nothing used to retry
  # once real connectivity actually arrived. "connectivity-change" fires
  # when NetworkManager confirms full internet access, giving us that
  # retry. Logs outcomes via `logger` (journalctl -t vpn-autoconnect) so
  # failures are debuggable instead of silently swallowed.
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "vpn-autoconnect" ''
        interface="$1"
        action="$2"
        home_ssid="The-Clown-House"
        vpn_name="vpn"
        wg_quick="/run/current-system/sw/bin/wg-quick"
        nmcli="/run/current-system/sw/bin/nmcli"
        ip="/run/current-system/sw/bin/ip"
        logger="/run/current-system/sw/bin/logger -t vpn-autoconnect"

        case "$action" in
          up|down|connectivity-change) ;;
          *) exit 0 ;;
        esac
        case "$interface" in
          lo|"$vpn_name") exit 0 ;;
        esac

        current_ssid=$("$nmcli" -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
        vpn_up=0
        "$ip" link show "$vpn_name" >/dev/null 2>&1 && vpn_up=1

        if [ "$current_ssid" = "$home_ssid" ]; then
          if [ "$vpn_up" = 1 ]; then
            "$wg_quick" down "$vpn_name" 2>&1 | $logger
            $logger "took down $vpn_name (home: $current_ssid)"
          fi
        elif [ "$vpn_up" = 0 ]; then
          if "$wg_quick" up "$vpn_name" 2>&1 | $logger; then
            $logger "brought up $vpn_name (ssid: $current_ssid, trigger: $action)"
          else
            $logger "failed to bring up $vpn_name (ssid: $current_ssid, trigger: $action), will retry on next event"
          fi
        fi
      '';
      type = "basic";
    }
  ];
}

