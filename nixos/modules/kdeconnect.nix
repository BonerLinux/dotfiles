{ config, pkgs, lib, ... }: 

{
  environment.systemPackages = with pkgs; [
    plasma5Packages.kdeconnect-kde
    # Optional: GUI frontends if you're using GNOME or a DE without native support
    valent
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 1716 ];
  networking.firewall.allowedUDPPorts = [ 1716 1717 1718 1719 1720 ];
}
