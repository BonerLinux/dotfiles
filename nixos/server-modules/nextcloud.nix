{ config, pkgs, ...}: {

environment.etc."nextcloud-admin-pass".text = "supersecret";
services.nextcloud = {
  enable = true;
  package = pkgs.nextcloud31;
  hostName = "server";
  config.adminpassFile = "/etc/nextcloud-admin-pass";
  config.dbtype = "sqlite";
};

}
