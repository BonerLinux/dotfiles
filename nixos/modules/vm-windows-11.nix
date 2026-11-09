# Runs the "windows-11" quickemu VM persistently on the server, with SPICE
# exposed on the network -- same pattern as vm-cyber-defence.nix. Used for
# anything needing a Windows environment (e.g. Valeton pedal firmware
# updates via USB redirection).
{ pkgs, ... }:

{
  systemd.services.vm-windows-11 = {
    description = "windows-11 quickemu VM";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      PIDFile = "/mnt/tank/vms/windows11/windows-11/windows-11.pid";
      User = "admin";
      Group = "admin";
      WorkingDirectory = "/mnt/tank/vms/windows11";
      Environment = "HOME=/home/admin";
      ExecStart = "${pkgs.quickemu}/bin/quickemu --vm windows-11.conf --display spice --access remote --viewer none --spice-port 5931";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
