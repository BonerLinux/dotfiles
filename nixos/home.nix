{ config, pkgs, ...}: {

  programgs.git = {
    enable = true;
    userName = "Riley Boughner";
    userEmail = "riley@clownweb.net";

    configExtra = ''
      credential.helper = store
    '';
  };

}
