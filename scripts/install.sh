#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git stow

set -euo pipefail

# --- Styling ---
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[1;31m"
RESET="\033[0m"

# --- Paths ---
OLD_DIR="$HOME/system"
DOTFILES_DIR="$HOME/.system"
REPO_URL_DOTFILES="https://github.com/rileyboughner/dotfiles.git"
DOTFILES_SUBDIR="$DOTFILES_DIR"

ZSHRC_SOURCE="$DOTFILES_SUBDIR/.zshrc"

WALLPAPERS_DIR="$HOME/.wallpapers"
REPO_URL_WALLPAPERS="https://github.com/rileyboughner/wallpapers.git"

# --- Helpers ---
log()     { echo -e "${BLUE}🔧 $1${RESET}"; }
success() { echo -e "${GREEN}✅ $1${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${RESET}"; }
error()   { echo -e "${RED}❌ $1${RESET}" >&2; }

# --- Step 1: Ensure .system exists ---
if [ -d "$OLD_DIR" ]; then
  log "Found ~/system. Moving to ~/.system..."
  mv "$OLD_DIR" "$DOTFILES_DIR"
  success "Moved ~/system to ~/.system"
fi

if [ ! -d "$DOTFILES_DIR" ]; then
  log "Cloning dotfiles into ~/.system..."
  git clone "$REPO_URL_DOTFILES" "$DOTFILES_DIR"
  success "Cloned dotfiles"
else
  success "~/.system already exists"
fi

# --- Step 2: Ensure .wallpapers exists ---
if [ ! -d "$WALLPAPERS_DIR" ]; then
  log "Cloning wallpapers into ~/.wallpapers..."
  git clone "$REPO_URL_WALLPAPERS" "$WALLPAPERS_DIR"
  success "Cloned wallpapers"
else
  success "~/.wallpapers already exists"
fi

# --- Step 3: Stow dot_config ---
if [ -d "$DOTFILES_SUBDIR/dot_config" ]; then
  log "Stowing dot_config into ~/.config..."
  cd "$DOTFILES_SUBDIR"
  stow -t "$HOME/.config" dot_config
  success "dot_config stowed"
else
  warn "dot_config directory not found in $DOTFILES_SUBDIR"
fi

# --- Step 4: Symlink .zshrc ---
if [ -f "$ZSHRC_SOURCE" ]; then
  log "Linking .zshrc → ~/.zshrc"
  ln -sf "$ZSHRC_SOURCE" "$HOME/.zshrc"
  success "Linked .zshrc"
else
  warn ".zshrc not found at $ZSHRC_SOURCE"
fi
