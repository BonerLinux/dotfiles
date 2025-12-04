#!/usr/bin/env nix-shell
#!nix-shell -i bash -p sshfs

sshfs admin@192.168.1.2:/mnt/tank/cloud/Documents ~/documents
