let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/aMYca3Rnyo88VPELL5uYhlxThL0WVlei6uat/95f8";
  # desktop = "ssh-ed25519 ..."; -- on desktop: cat /etc/ssh/ssh_host_ed25519_key.pub
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIQxIs05S+JRN9kgrTT/DF5IED0l73098hxj4V3yLUF";

  # Personal editing key (~/.config/agenix/key.txt), not tied to any host --
  # lets secrets be edited/rekeyed from any machine, including after a host
  # reinstall changes its ssh host key.
  admin = "age1j65nzuknrxv6wqn23ar939hxjdq452jre2tydw3wd0wr7czzk3cse26yrw";

  workstations = [ laptop admin ]; # add desktop once its key is captured

  # Workstations plus `server` -- its admin user also needs to push/pull the
  # dotfiles repo, but has no business decrypting desktop-only secrets like
  # todoist-token or gcalcli-client-secret.
  gitHosts = workstations ++ [ server ];
in
{
  # Shared across every workstation.
  "todoist-token.age".publicKeys = workstations;
  "gcalcli-client-secret.age".publicKeys = workstations;
  "git-credentials-rileyboughner.age".publicKeys = gitHosts;
  "git-credentials-boughnerengineering.age".publicKeys = gitHosts;
  "git-credentials-bonerlinux.age".publicKeys = gitHosts;

  # One SSH identity per machine for logging into `server` -- each host only
  # decrypts its own key, so compromising one laptop doesn't leak the others.
  "server-ssh-key-laptop.age".publicKeys = [ laptop admin ];
  "server-ssh-key-desktop.age".publicKeys = [ admin ]; # add `desktop` once its key is captured, then `agenix -r`

  # Private key for logging into `desktop` from the other workstations.
  # TODO: generate with `ssh-keygen -t ed25519 -f desktop-ssh-key -C desktop-access`,
  # add the matching .pub to desktop's authorized_keys, then
  # `agenix -e desktop-ssh-key.age < desktop-ssh-key` to create this file.
  "desktop-ssh-key.age".publicKeys = workstations;
}
