# KDE Connect: LAN-paired phone integration (notifications, SMS, call
# alerts, file transfer, media control). Desktop/laptop only - it's a GUI
# feature, nothing for the headless server to pair with.
{ ... }:
{
  programs.kdeconnect.enable = true;
}
