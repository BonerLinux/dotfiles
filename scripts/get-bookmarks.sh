#!/bin/sh

BOOKMARK_FILE="$HOME/.bookmarks"
CONFIG="$HOME/.config/wofi/bookmark-picker/bookmark-picker.conf"
STYLE="$HOME/.config/wofi/bookmark-picker/bookmark-picker.css"

# Ensure the bookmarks file exists
[ -f "$BOOKMARK_FILE" ] || touch "$BOOKMARK_FILE"

# Launch wofi and pipe selection directly to clipboard
cat "$BOOKMARK_FILE" | wofi \
    -c "$CONFIG" \
    -s "$STYLE" \
    --show dmenu \
    --prompt "Select Bookmark:" \
    -n | wl-copy
