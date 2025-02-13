{ config, pkgs, lib, ... }: 

{

  programs.git = {
    enable = true;
    userName = "Riley Boughner";
    userEmail = "jojo.picktwn@gmail.com";
  };

}
