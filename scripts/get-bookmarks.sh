#!/bin/sh

BOOKMARK_FILE="$HOME/.bookmarks"
CONFIG="$HOME/.config/wofi/bookmark-picker/bookmark-picker.conf"
STYLE="$HOME/.config/wofi/bookmark-picker/bookmark-picker.css"

# Ensure the bookmarks file exists
[ -f "$BOOKMARK_FILE" ] || touch "$BOOKMARK_FILE"

# Prompt user to select a bookmark
choice=$(wofi \
    -c "$CONFIG" \
    -s "$STYLE" \
    --show dmenu \
    --prompt "Select Bookmark:" \
    -n < "$BOOKMARK_FILE")

# Copy to clipboard if a choice was made
if [ -n "$choice" ]; then
    echo "$choice" | wl-copy
fi
