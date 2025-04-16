{ config, pkgs, lib, ... }:

{
  options.passGit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic git pull for pass.";
    };
  };

  # Define the service
  systemd.services.pass-git-pull = {
    description = "Pull GnuPG passphrase store from GitLab";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.git}/bin/git -C ${config.home.homeDirectory}/.password-store pull git@gitlab.com:jo60robo/password-store.git";
      RemainAfterExit = true;
    };

    # Enable the service only if passGit.enable is true
    wantedBy = if config.passGit.enable then [ "multi-user.target" ] else [];
  };

  # Enable the service if passGit.enable is true
  config.systemd.services.pass-git-pull.enable = config.passGit.enable;
}



