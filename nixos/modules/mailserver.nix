{ config, pkgs, lib, ... }: {

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
      sha256 = "16kanlk74xnj7xgmjsj7pahy31hlxqcbv76xnsg8qbh54b0hwxgq";
    })
  ];

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.clownweb.net";
    domains = [ "clownweb.net" ];

    loginAccounts = {
      "admin@clownweb.net" = {
        hashedPasswordFile = "/etc/nixos/secrets/admin.hash";
        aliases = ["admin@clownweb.net"];
      };
    };

    certificateScheme = "acme-nginx";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@clownweb.net";

  services.roundcube = {
    enable = true;
    hostName = "mail.clownweb.net";
    extraConfig = ''
      $config['imap_host'] = "ssl://mail.clownweb.net";
      $config['smtp_host'] = "ssl://mail.clownweb.net";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

