{ username, ... }:
{
  # Google OAuth client registered as "TVs and Limited Input devices" --
  # the only client type that supports device-code login, which is what
  # ytmusicapi needs for the YT Music -> Lidarr sync job running on this
  # host. Deliberately its own module (rather than living in
  # modules/secrets.nix) since that module also defines server-ssh-key,
  # which only makes sense on laptop/desktop, not on server itself.
  age.secrets.youtube-client-secret = {
    file = ../secrets/youtube-client-secret.age;
    owner = username;
  };
}
