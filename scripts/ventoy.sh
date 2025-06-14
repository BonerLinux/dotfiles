#!/bin/sh

set -e

VENTOY_UUID="52A4-B5F3"
MOUNT_POINT="$HOME/ventoy"

mount_ventoy() {
  echo "📦 Mounting Ventoy to $MOUNT_POINT..."
  mkdir -p "$MOUNT_POINT"
  sudo mount -t exfat UUID=$VENTOY_UUID "$MOUNT_POINT" \
    -o uid=$UID,gid=$(id -g),umask=0022
  echo "✅ Mounted."
}

install_isos() {
  echo "🧼 Removing old ISOs..."
  find "$MOUNT_POINT" -iname "*.iso" -delete

  echo "🌐 Downloading latest ISOs..."

  curl -Lo "$MOUNT_POINT/ubuntu-desktop.iso" https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso
  curl -Lo "$MOUNT_POINT/ubuntu-server.iso" https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso
  curl -Lo "$MOUNT_POINT/fedora.iso" https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-40-1.14.iso
  curl -Lo "$MOUNT_POINT/arch.iso" https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso
  curl -Lo "$MOUNT_POINT/nixos-minimal.iso" https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso
  curl -Lo "$MOUNT_POINT/nixos-gnome.iso" https://channels.nixos.org/nixos-24.05/latest-nixos-gnome-x86_64-linux.iso

  echo "✅ All ISOs downloaded to $MOUNT_POINT"
}

case "$1" in
  mount)
    mount_ventoy
    ;;

  install)
    mount_ventoy
    install_isos
    ;;

  *)
    echo "Usage: $0 mount | install"
    exit 1
    ;;
esac
