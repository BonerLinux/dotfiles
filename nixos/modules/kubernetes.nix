inputs@{ config, pkgs, lib, ... }:
let
  standardUser = inputs.username;
in
{
  services.k3s = {
    enable = true;
    role = "server";
  };

  environment.systemPackages = with pkgs; [ # These are essential programs
    helm
  ];


  networking.firewall.allowedTCPPorts = [
    6443
  ];

}

