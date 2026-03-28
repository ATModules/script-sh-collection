#!/bin/bash

set -e

echo "=== Installing Rust and Cargo ==="

# Install Rust via rustup (the official installer)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Source the cargo environment for the current session
source "$HOME/.cargo/env"

# Add to .zshrc if not already present
CARGO_LINE='source "$HOME/.cargo/env"'
ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
    if ! grep -qF '.cargo/env' "$ZSHRC"; then
        echo "" >> "$ZSHRC"
        echo "# Rust/Cargo PATH" >> "$ZSHRC"
        echo "$CARGO_LINE" >> "$ZSHRC"
        echo ">> Added Cargo env to .zshrc"
    else
        echo ">> .zshrc already sources .cargo/env — skipping"
    fi
else
    echo "" >> "$ZSHRC"
    echo "# Rust/Cargo PATH" >> "$ZSHRC"
    echo "$CARGO_LINE" >> "$ZSHRC"
    echo ">> Created .zshrc and added Cargo env"
fi

# Verify installation
echo ""
echo "=== Verifying Installation ==="
rustc --version
cargo --version

echo ""
echo "=== Done! Restart your terminal or run: source ~/.zshrc ==="
