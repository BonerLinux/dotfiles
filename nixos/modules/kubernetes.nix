inputs@{ config, pkgs, lib, ... }:
let
  standardUser = inputs.username;
in
{
  services.k3s = {
    enable = true;
    role = "server";
  };

  networking.firewall.allowedTCPPorts = [
    6443
  ];

}

