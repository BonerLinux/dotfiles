{ config, pkgs, ... }:

{
  imports = [];

  # Enable NFS server
  services.nfs.server.enable = true;

  # Export /mnt/users to your LAN
  services.nfs.server.exports = ''
    /mnt/tank/users  192.168.1.0/24(rw,sync,no_subtree_check,insecure,no_root_squash)
  '';

  # Firewall: allow NFS traffic (rpcbind + nfs)
  networking.firewall.allowedTCPPorts = [ 111 2049 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 ];

  # Ensure rpcbind is running
  services.rpcbind.enable = true;

  # Optional: force systemd to start the NFS server daemons correctly
  systemd.services.nfs-server.enable = true;
}
