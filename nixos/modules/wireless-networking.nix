{ config, pkgs, username, ... }: 
let
 standardUser = username;
in
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    bluetuith
  ];

  users.users.${standardUser}.extraGroups = [ "networkManager" ];

  # Let this user toggle WireGuard tunnels from the Quickshell bar without a
  # password prompt each time, scoped to only wg-quick up/down (no other root access)
  security.sudo.extraRules = [
    {
      users = [ standardUser ];
      commands = [
        {
          command = "/run/current-system/sw/bin/wg-quick up *";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/wg-quick down *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
