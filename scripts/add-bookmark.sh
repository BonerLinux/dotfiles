#!/bin/sh

BOOKMARK_FILE="$HOME/.bookmarks"
BOOKMARK="$(wl-paste)"

# Ensure the bookmark file exists
if [ ! -f "$BOOKMARK_FILE" ]; then
  touch "$BOOKMARK_FILE"
  if [ $? -ne 0 ]; then
    notify-send "❌ Error" "Failed to create $BOOKMARK_FILE"
    exit 1
  else
    notify-send "📄 Created" "Bookmark file created at $BOOKMARK_FILE"
  fi
fi

# Check for duplicate and append if new
if grep -Fxq "$BOOKMARK" "$BOOKMARK_FILE"; then
  notify-send "⚠️ Already Bookmarked" "$BOOKMARK"
else
  echo "$BOOKMARK" >> "$BOOKMARK_FILE"
  notify-send "✅ Bookmark Saved" "$BOOKMARK"
fi
