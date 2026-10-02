let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/aMYca3Rnyo88VPELL5uYhlxThL0WVlei6uat/95f8";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq8fvD5SXaqWTeGWraEJljtcC3wOOEhiVt5hBQbi0bn";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIQxIs05S+JRN9kgrTT/DF5IED0l73098hxj4V3yLUF";

  # Personal editing key (~/.config/agenix/key.txt), not tied to any host --
  # lets secrets be edited/rekeyed from any machine, including after a host
  # reinstall changes its ssh host key.
  admin = "age1j65nzuknrxv6wqn23ar939hxjdq452jre2tydw3wd0wr7czzk3cse26yrw";

  workstations = [ laptop desktop admin ];

  # Workstations plus `server` -- its admin user also needs to push/pull the
  # dotfiles repo, but has no business decrypting desktop-only secrets like
  # todoist-token or gcalcli-client-secret.
  gitHosts = workstations ++ [ server ];
in
{
  # Shared across every workstation.
  "todoist-token.age".publicKeys = workstations;
  "gcalcli-client-secret.age".publicKeys = workstations;

  # Google OAuth client registered as "TVs and Limited Input devices" --
  # the only client type that supports device-code login, which is what
  # ytmusicapi needs and what the YT Music -> Lidarr sync job on `server`
  # uses. Deliberately separate from gcalcli-client-secret: that one is a
  # Desktop-app client and cannot do device-code login.
  "youtube-client-secret.age".publicKeys = gitHosts;

  "git-credentials-rileyboughner.age".publicKeys = gitHosts;
  "git-credentials-boughnerengineering.age".publicKeys = gitHosts;
  "git-credentials-bonerlinux.age".publicKeys = gitHosts;

  # One SSH identity per machine for logging into `server` -- each host only
  # decrypts its own key, so compromising one laptop doesnt leak the others.
  "server-ssh-key-laptop.age".publicKeys = [ laptop admin ];
  "server-ssh-key-desktop.age".publicKeys = [ desktop admin ];

  # Private key for logging into `desktop` from the other workstations. The
  # matching .pub is trusted in nixos/hosts/desktop/configuration.nix.
  "desktop-ssh-key.age".publicKeys = workstations;
}
