#!/bin/sh
WALLPAPER_DIR="$HOME/.wallpapers"
WALLPAPER_DEST="$HOME/.wallpaper"

# Generate a list of wallpapers with "img:" prefix (if needed)
menu() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sed 's|^|img:|'
}

# Show Wofi with a custom config and style
choice=$(menu | wofi -c ~/.config/wofi/wallpaper-picker/wallpaper-picker.conf \
		-s ~/.config/wofi/wallpaper-picker/wallpaper-picker.css \
		--show dmenu --prompt "Select Wallpaper:" -n)

# Remove "img:" prefix if present
selected_wallpaper=$(echo "$choice" | sed 's/^img://')

# Validate selection
if [[ -z "$selected_wallpaper" ]]; then
    echo "No wallpaper selected."
    exit 1
fi

# Copy the selected wallpaper to ~/.wallpaper
cp "$selected_wallpaper" "$WALLPAPER_DEST"

# Set the wallpaper with hyprpaper
hyprctl hyprpaper preload "$selected_wallpaper"
hyprctl hyprpaper wallpaper ",$selected_wallpaper"

~/.system/scripts/set-theme-from-wallpaper
