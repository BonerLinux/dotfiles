{ pkgs, ... }:

{
  # Nightly rsync of Immich's photo library and the shared files share from
  # /mnt/tank onto the separate physical drive at /mnt/backup. Runs as root
  # since both /mnt/tank/services/immich and /mnt/backup are root-owned and
  # admin has no write access to either. Intentionally never passes
  # --delete: a mistaken deletion on tank should not also vanish from the
  # backup copy, so the destination only ever grows.
  systemd.services.tank-backup = {
    description = "Backup pictures and files from /mnt/tank to /mnt/backup";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
      ExecStart = pkgs.writeShellScript "tank-backup" ''
        set -euo pipefail
        mkdir -p /mnt/backup/pictures /mnt/backup/files
        ${pkgs.rsync}/bin/rsync -a --human-readable --stats \
          /mnt/tank/services/immich/library/ /mnt/backup/pictures/
        ${pkgs.rsync}/bin/rsync -a --human-readable --stats \
          /mnt/tank/files/ /mnt/backup/files/
      '';
    };
  };

  systemd.timers.tank-backup = {
    description = "Daily timer for tank-backup.service";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
  };
}
