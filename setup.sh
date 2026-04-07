#!/usr/bin/env bash
set -euo pipefail

# setup.sh — recreate the mindd development environment on a new Mac.
# Run from the repo root: ./setup.sh

OBSIDIAN_VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/mindd"
WIKI_DIR="$OBSIDIAN_VAULT/wiki"

# --- Prerequisites ---

if ! command -v brew &>/dev/null; then
  echo "ERROR: Homebrew is not installed."
  echo "Install it first: https://brew.sh"
  exit 1
fi

if ! command -v node &>/dev/null; then
  echo "Node.js not found. Installing via Homebrew..."
  brew install node
fi

if ! command -v npm &>/dev/null; then
  echo "ERROR: npm not found even after installing Node.js."
  exit 1
fi

# --- qmd (markdown search engine) ---

if ! command -v qmd &>/dev/null; then
  echo "Installing qmd..."
  npm install -g @tobilu/qmd
fi

# --- Claude Code qmd plugin ---

if command -v claude &>/dev/null; then
  echo "Installing qmd Claude Code plugin..."
  claude plugin marketplace add tobi/qmd 2>/dev/null || true
  claude plugin install qmd@qmd 2>/dev/null || true
else
  echo "NOTE: Claude Code CLI not found. Install the qmd plugin manually:"
  echo "  claude plugin marketplace add tobi/qmd"
  echo "  claude plugin install qmd@qmd"
fi

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

# --- qmd collection ---
# Register the wiki as a qmd search collection and build the index.

echo "Registering wiki as qmd collection..."
qmd collection add wiki/ --name wiki 2>/dev/null || true
echo "Building qmd embeddings (this may take a moment on first run)..."
qmd embed 2>/dev/null || true

echo ""
echo "Setup complete. Open the mindd vault in Obsidian to browse the wiki."
