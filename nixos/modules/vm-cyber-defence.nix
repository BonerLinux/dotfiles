# Runs the "cyber-defence" quickemu VM (migrated from laptop) persistently on
# the server, with SPICE exposed on the network so it can be viewed with
# remote-viewer from desktop or server alike -- not just a local GTK window.
{ pkgs, ... }:

{
  systemd.services.vm-cyber-defence = {
    description = "cyber-defence quickemu VM";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      PIDFile = "/mnt/tank/vms/cyber-defence/cyber-defence.pid";
      User = "admin";
      Group = "admin";
      WorkingDirectory = "/mnt/tank/vms/cyber-defence";
      Environment = "HOME=/home/admin";
      ExecStart = "${pkgs.quickemu}/bin/quickemu --vm cyber-defence.conf --display spice --access remote --viewer none --spice-port 5930";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
