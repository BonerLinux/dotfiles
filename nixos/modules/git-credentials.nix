{ username, ... }:
{
  age.secrets.git-credentials-rileyboughner = {
    file = ../secrets/git-credentials-rileyboughner.age;
    owner = username;
  };

  age.secrets.git-credentials-boughnerengineering = {
    file = ../secrets/git-credentials-boughnerengineering.age;
    owner = username;
  };

  age.secrets.git-credentials-bonerlinux = {
    file = ../secrets/git-credentials-bonerlinux.age;
    owner = username;
  };
}
