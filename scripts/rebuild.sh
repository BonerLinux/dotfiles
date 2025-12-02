#!/bin/sh

USER_HOME=$(eval echo ~"$USER")

echo $USER_HOME;

sudo nixos-rebuild switch --flake "$USER_HOME/.system/nixos#"

