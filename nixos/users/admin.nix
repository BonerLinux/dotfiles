{ config, pkgs, username, ...}:
let
  # git-credential-store matches by exact path when credential.useHttpPath is
  # on, so a stored entry without a path (one PAT covering a whole org) never
  # matches a real repo query. Config-section selection already picked the
  # right org by path prefix before this helper runs, so it can just hand
  # back that secret's username/password unconditionally instead of
  # re-matching path itself.
  gitCredentialAgenix = pkgs.writeShellScript "git-credential-agenix" ''
    set -euo pipefail
    secret_file="$1"
    op="$2"

    if [ "$op" != "get" ]; then
      cat >/dev/null
      exit 0
    fi

    line=$(cat "$secret_file")
    rest=''${line#https://}
    userpass=''${rest%%@*}
    user=''${userpass%%:*}
    pass=''${userpass#*:}

    echo "username=$user"
    echo "password=$pass"
  '';
in
{

  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user.name = "Riley Boughner";
    settings.user.email = "riley@clownweb.net";
    settings = {
      credential."https://github.com".useHttpPath = true;
      credential."https://github.com/rileyboughner".helper = "!${gitCredentialAgenix} /run/agenix/git-credentials-rileyboughner";
      credential."https://github.com/boughnerengineering".helper = "!${gitCredentialAgenix} /run/agenix/git-credentials-boughnerengineering";
      credential."https://github.com/BonerLinux".helper = "!${gitCredentialAgenix} /run/agenix/git-credentials-bonerlinux";
    };
  };

  # Persistent Claude Code Remote Control, running from the admin home
  # directory so it's reachable from claude.ai/code without a login
  # session kept open. Needs the admin user's systemd instance to linger
  # at boot -- see systemd.tmpfiles.rules in
  # nixos/modules/server-remote-access.nix.
  systemd.user.services.claude-remote-control = {
    Unit = {
      Description = "Claude Code Remote Control (persistent)";
      After = [ "network-online.target" ];
    };
    Service = {
      # `claude remote-control` (not the --remote-control flag on a normal
      # session) is the persistent broker that actually registers as a
      # device in claude.ai/code's device list and can spawn sessions
      # on demand. It also checks isatty(stdout) to decide whether to run
      # interactively; under systemd stdout is the journal, not a tty, so
      # `script` allocates a real pty so it starts normally.
      ExecStart = "${pkgs.util-linux}/bin/script -qefc '${pkgs.claude-code}/bin/claude remote-control --name server' /dev/null";
      WorkingDirectory = config.home.homeDirectory;
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}

