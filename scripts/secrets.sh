#!/bin/sh

set -e

DRIVE_UUID="f7459f96-e757-47a7-8b84-d155e03c83cb"
MAPPER_NAME="my_encrypted_drive"
MOUNT_POINT="/mnt/Secrets"
LINK="$HOME/.secrets"

case "$1" in
  open)
    echo "🔐 Opening encrypted volume..."
    sudo cryptsetup open /dev/disk/by-uuid/$DRIVE_UUID $MAPPER_NAME || echo "Already opened?"

    echo "📂 Mounting..."
    sudo mount $MOUNT_POINT

    echo "🔗 Creating symlink..."
    [ -L "$LINK" ] && rm "$LINK"
    ln -s "$MOUNT_POINT" "$LINK"
    echo "✅ Secrets mounted and linked to $LINK"
    ;;

  close)
    echo "📁 Unmounting..."
    sudo umount $MOUNT_POINT || echo "Already unmounted?"

    echo "🔐 Closing encrypted volume..."
    sudo cryptsetup close $MAPPER_NAME || echo "Already closed?"

    echo "❌ Removing symlink..."
    [ -L "$LINK" ] && rm "$LINK"
    echo "✅ Secrets unmounted and link removed"
    ;;

  *)
    echo "Usage: secrets open|close"
    exit 1
    ;;
esac
