#!/usr/bin/env nix-shell
#!nix-shell -i bash -p 

USER_HOME=$(eval echo ~"$USER")

echo $USER_HOME;

cd $USER_HOME/.system/nixos

nix flake update

if git diff --quiet flake.lock; then
    echo "No flake.lock changes."
else
    git add flake.lock
    git commit -m "flake: update $(date '+%Y-%m-%d')"
fi

"$HOME/.system/scripts/rebuild.sh"
