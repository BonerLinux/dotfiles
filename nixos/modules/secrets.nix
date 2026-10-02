{ username, config, ... }:
{
  imports = [ ./git-credentials.nix ];

  age.secrets.todoist-token = {
    file = ../secrets/todoist-token.age;
    owner = username;
  };

  age.secrets.gcalcli-client-secret = {
    file = ../secrets/gcalcli-client-secret.age;
    owner = username;
  };

  # Each host decrypts its own dedicated server-access key, but consumers
  # (nixos/modules/ssh.nix) always read it from this same stable path.
  age.secrets.server-ssh-key = {
    file = ../secrets/server-ssh-key-${config.networking.hostName}.age;
    owner = username;
  };

  # Key for logging into `desktop` from other workstations (nixos/modules/ssh.nix).
  age.secrets.desktop-ssh-key = {
    file = ../secrets/desktop-ssh-key.age;
    owner = username;
  };
}
