#!/usr/bin/env bash
set -euo pipefail

# setup.sh — recreate the mindd development environment on a new Mac.
# Run from the repo root: ./setup.sh

OBSIDIAN_VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/mindd"
WIKI_DIR="$OBSIDIAN_VAULT/wiki"

# --- Obsidian vault symlink ---
# The wiki/ directory lives inside the Obsidian vault (synced via iCloud)
# and is symlinked into this repo so Claude can read/write wiki pages
# while Obsidian displays them in real time.

if [ -L wiki ]; then
  echo "wiki/ symlink already exists -> $(readlink wiki)"
elif [ -e wiki ]; then
  echo "ERROR: wiki/ exists but is not a symlink. Remove it first."
  exit 1
else
  if [ ! -d "$WIKI_DIR" ]; then
    echo "Creating wiki directory in Obsidian vault..."
    mkdir -p "$WIKI_DIR"
  fi
  ln -s "$WIKI_DIR" wiki
  echo "Created symlink: wiki/ -> $WIKI_DIR"
fi

# --- raw/ directory ---
mkdir -p raw/assets
echo "Ensured raw/ and raw/assets/ directories exist."

echo ""
echo "Setup complete. Open the mindd vault in Obsidian to browse the wiki."
