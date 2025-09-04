{ config, username, pkgs, lib, ... }: 
let
  standardUser = username;
in 
{

services = {
    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "Hyprland";
          user = standardUser;
        };
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --greeting 'Welcome To NixOS' --asterisks --remember --remember-user-session --time -cmd Hyprland";
          user = "greeter";
        };
      };
    };
  };

users.users.${standardUser} = {
    isNormalUser = true;
    extraGroups = [ "wireshark" "networkmanager" "wheel" "${standardUser}" "audio" "docker" ];
  };

}
