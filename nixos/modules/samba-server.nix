{ config, pkgs, ... }:

{
  imports = [];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "server";
        security = "user";
        "map to guest" = "never";
      };

      files = {
        path = "/mnt/tank/files";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "admin";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  # Firewall: allow SMB traffic (also handled by openFirewall above,
  # kept explicit to mirror the NFS module's style)
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  # /mnt/tank/files is owned by uid 1000 / group kubectl (matches the uid
  # of NFS clients' local users). Put admin in that group and setgid the
  # tree so SMB writes as admin land with the same group and stay writable.
  users.users.admin.extraGroups = [ "kubectl" ];

  systemd.tmpfiles.rules = [
    "Z /mnt/tank/files 2775 1000 kubectl - -"
  ];
}
