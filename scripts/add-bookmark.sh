#!/bin/sh

BOOKMARK_DIR="$HOME/.bookmarks"
BOOKMARK="$(wl-paste --primary)"

# Check if bookmark folder exists
if [ ! -d "$BOOKMARK_DIR" ]; then
  mkdir -p "$BOOKMARK_DIR"
  if [ $? -ne 0 ]; then
    notify-send "❌ Error" "Failed to create $BOOKMARK_DIR"
    exit 1
  else
    notify-send "📂 Created" "Bookmark folder created at $BOOKMARK_DIR"
  fi
fi

# Bookmark file path
BOOKMARK_FILE="$BOOKMARK_DIR/bookmarks.txt"
touch "$BOOKMARK_FILE"

# Check for duplicate and append if new
if grep -Fxq "$BOOKMARK" "$BOOKMARK_FILE"; then
  notify-send "⚠️ Already Bookmarked" "$BOOKMARK"
else
  echo "$BOOKMARK" >> "$BOOKMARK_FILE"
  notify-send "✅ Bookmark Saved" "$BOOKMARK"
fi
