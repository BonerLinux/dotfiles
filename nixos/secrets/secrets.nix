let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/aMYca3Rnyo88VPELL5uYhlxThL0WVlei6uat/95f8";
  # desktop = "ssh-ed25519 ..."; -- on desktop: cat /etc/ssh/ssh_host_ed25519_key.pub
  # server  = "ssh-ed25519 ...";  -- on server:  cat /etc/ssh/ssh_host_ed25519_key.pub

  # Personal editing key (~/.config/agenix/key.txt), not tied to any host --
  # lets secrets be edited/rekeyed from any machine, including after a host
  # reinstall changes its ssh host key.
  admin = "age1j65nzuknrxv6wqn23ar939hxjdq452jre2tydw3wd0wr7czzk3cse26yrw";

  workstations = [ laptop admin ]; # add desktop once its key is captured
in
{
  # Shared across every workstation.
  "todoist-token.age".publicKeys = workstations;
  "gcalcli-client-secret.age".publicKeys = workstations;

  # One SSH identity per machine for logging into `server` -- each host only
  # decrypts its own key, so compromising one laptop doesn't leak the others.
  "server-ssh-key-laptop.age".publicKeys = [ laptop admin ];
  "server-ssh-key-desktop.age".publicKeys = [ admin ]; # add `desktop` once its key is captured, then `agenix -r`
}
