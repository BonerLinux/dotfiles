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
}

