{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sshfs
    rclone
  ];

  programs.zsh = {
    shellAliases = {
      work = "sshfs rboughner@74.126.84.249:/home/rboughner/taqweb ~/Taqweb";
    };
  };

  environment.etc."rclone-mnt.conf".text = ''
    [myremote]
    type = sftp
    host = 74.126.84.29
    user = rboughner
    key_file = /rileyboughner/.ssh/work-server
  '';

  fileSystems."/home/rileyboughner/Taqweb-rclone" = {
    device = "myremote:/home/rileyboughner/taqweb";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone-mnt.conf"
    ];
  };
}
