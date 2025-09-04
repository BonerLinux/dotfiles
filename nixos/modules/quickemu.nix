{ config, pkgs, lib, ... }: 

{
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["rileyboughner"];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    quickemu
  ];

}
