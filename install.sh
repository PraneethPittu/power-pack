#!/bin/bash
# Power-Pack (pp) Installation Script
# Works on fresh installs and re-installs

set -e

SKILL_DIR="$HOME/.claude/skills/pp"
COMMANDS_DIR="$HOME/.claude/commands"

echo "Installing Power-Pack (pp)..."

# 1. Create directories
mkdir -p "$HOME/.claude/skills"
mkdir -p "$COMMANDS_DIR"

# 2. Clone or update repo
if [ -d "$SKILL_DIR" ]; then
    echo "Existing installation found. Updating..."
    cd "$SKILL_DIR"
    git pull origin main
else
    echo "Cloning repository..."
    git clone https://github.com/PraneethPittu/power-pack.git "$SKILL_DIR"
fi

# 3. Create symlink (force overwrite if exists)
ln -sf "$SKILL_DIR/commands" "$COMMANDS_DIR/pp"

# 4. Verify
if [ -d "$COMMANDS_DIR/pp" ]; then
    echo ""
    echo "✓ Installation successful!"
    echo ""
    echo "Commands installed:"
    ls -1 "$COMMANDS_DIR/pp/"
    echo ""
    echo "Restart Claude Code, then try: /pp:help"
else
    echo ""
    echo "✗ Installation failed. Symlink not created."
    exit 1
fi
