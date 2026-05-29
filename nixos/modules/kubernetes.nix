inputs@{ config, pkgs, lib, ... }:
let
  standardUser = inputs.username;
in
{
  services.k3s = {
    enable = true;
    role = "server";


    extraFlags = toString [
      "--write-kubeconfig-mode=0644"
    ];
  };

  environment.systemPackages = with pkgs; [ # These are essential programs
    kubernetes-helm
  ];


  networking.firewall.allowedTCPPorts = [
    6443
  ];

}

