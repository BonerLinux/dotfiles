#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git stow pywal16 pywalfox-native asusctl

set -euo pipefail

selected_wallpaper="$HOME/.wallpaper"
wal_colors="$HOME/.cache/wal/colors.css"
base_css="$HOME/.config/homepage/base.css"
colors_txt="$HOME/.cache/wal/colors"
colors_sh="$HOME/.cache/wal/colors.sh"

# Get Firefox profile
get_firefox_profile() {
  awk -F= '/^\[Profile[0-9]+\]/{p=0} /Default=1/{p=1} p && /Path=/{print $2}' "$HOME/.mozilla/firefox/profiles.ini"
}

# Apply pywal (must complete before others)
apply_pywal() {
  wal -i "$selected_wallpaper" -n
}

# Update homepage CSS
update_homepage_css() {
  cp "$wal_colors" "$HOME/.config/homepage/colors.css"
}

# Update Firefox chrome styling
update_firefox_css() {
  local profile_dir="$HOME/.mozilla/firefox/$(get_firefox_profile)/chrome"
  mkdir -p "$profile_dir"
  cat "$wal_colors" "$base_css" > "$profile_dir/userChrome.css"
  cp "$wal_colors" "$HOME/.mozilla/firefox"
}

# Update mako colors
update_mako_config() {
  local bg=$(sed -n 1p "$colors_txt")
  local border=$(sed -n 2p "$colors_txt")
  local text=$(sed -n 8p "$colors_txt")
  sed -i "
    s/^background-color=.*/background-color=$bg/;
    s/^text-color=.*/text-color=$text/;
    s/^border-color=.*/border-color=$border/
  " "$HOME/.config/mako/config"

  pkill mako || true
  mako &
}

# Update pywalfox theme
update_pywalfox() {
  pywalfox update
}

# Update ASUS LED color
update_asus_led() {
  if command -v asusctl &> /dev/null; then
    source "$colors_sh"
    asusctl led-mode static -c "${color0:1}"
  fi
}

# Export a walk-specific color
set_walk_colors() {
  source "$colors_sh"
  export WALK_MAIN_COLOR="$color4"
}

# --- Run All Steps ---
main() {
  apply_pywal

  # Run post-wal tasks concurrently
  update_homepage_css &
  update_firefox_css &
  update_mako_config &
  update_pywalfox &
  update_asus_led &
  set_walk_colors &

  wait
}

main
