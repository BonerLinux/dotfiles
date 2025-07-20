{ config, pkgs, ... }: 
{

  # for mounting stuff for backup and secret solution
  fileSystems."/mnt/Backup" = {
    device = "/dev/disk/by-uuid/bf534c30-89e9-4c71-bb9f-b5b6e56e91c6"; # sdb3
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=5s" "noatime" ];
  };

  environment.etc."crypttab".text = ''
    my_encrypted_drive UUID=f7459f96-e757-47a7-8b84-d155e03c83cb none noauto
  '';

  fileSystems."/mnt/Secrets" = {
    device = "/dev/mapper/my_encrypted_drive";
    fsType = "ext4";
    options = [ "noauto" "nofail" "noatime" ];
  };


}
