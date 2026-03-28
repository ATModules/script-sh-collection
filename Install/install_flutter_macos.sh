#!/bin/bash

set -e

# Make this script executable
chmod +x "$0"

echo "==========================================="
echo "  Flutter & Dart Installer for macOS"
echo "==========================================="
echo ""

# ------------------------------------------
# 1. Check & install dependencies
# ------------------------------------------

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo ">> Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo ">> Homebrew already installed. Skipping."
fi

# Install Git if not installed
if ! command -v git &> /dev/null; then
    echo ">> Git not found. Installing via Homebrew..."
    brew install git
else
    echo ">> Git already installed. Skipping."
fi

# ------------------------------------------
# 2. Flutter version selection
# ------------------------------------------

echo ""
echo "Select Flutter channel/version:"
echo "  1) Stable  (recommended)"
echo "  2) Beta"
echo "  3) Dev"
echo "  4) Specific version (e.g. 3.24.0)"
echo ""
read -p "Enter choice [1-4] (default: 1): " FLUTTER_CHOICE
FLUTTER_CHOICE=${FLUTTER_CHOICE:-1}

FLUTTER_DIR="$HOME/flutter"

case $FLUTTER_CHOICE in
    1) FLUTTER_CHANNEL="stable" ;;
    2) FLUTTER_CHANNEL="beta" ;;
    3) FLUTTER_CHANNEL="dev" ;;
    4)
        read -p "Enter Flutter version (e.g. 3.24.0): " FLUTTER_VERSION
        FLUTTER_CHANNEL="stable"
        ;;
    *)
        echo "Invalid choice. Using stable."
        FLUTTER_CHANNEL="stable"
        ;;
esac

# ------------------------------------------
# 3. Install or update Flutter
# ------------------------------------------

if [ -d "$FLUTTER_DIR" ]; then
    echo ""
    echo ">> Flutter found at $FLUTTER_DIR. Updating..."
    cd "$FLUTTER_DIR"
    git fetch --all --tags
    flutter channel $FLUTTER_CHANNEL
    if [ -n "$FLUTTER_VERSION" ]; then
        flutter downgrade $FLUTTER_VERSION || git checkout tags/$FLUTTER_VERSION
    else
        flutter upgrade
    fi
else
    echo ""
    echo ">> Cloning Flutter ($FLUTTER_CHANNEL channel)..."
    git clone https://github.com/flutter/flutter.git -b $FLUTTER_CHANNEL "$FLUTTER_DIR"
    if [ -n "$FLUTTER_VERSION" ]; then
        cd "$FLUTTER_DIR"
        git checkout tags/$FLUTTER_VERSION
    fi
fi

# ------------------------------------------
# 4. Add Flutter to PATH in .zshrc
# ------------------------------------------

FLUTTER_PATH_LINE='export PATH="$HOME/flutter/bin:$PATH"'
DART_PATH_LINE='export PATH="$HOME/flutter/bin/cache/dart-sdk/bin:$PATH"'
PUB_PATH_LINE='export PATH="$HOME/.pub-cache/bin:$PATH"'
ZSHRC="$HOME/.zshrc"

add_to_zshrc() {
    local line="$1"
    local label="$2"
    if [ -f "$ZSHRC" ]; then
        if ! grep -qF "$line" "$ZSHRC"; then
            echo "$line" >> "$ZSHRC"
            echo ">> Added $label to .zshrc"
        else
            echo ">> $label already in .zshrc. Skipping."
        fi
    else
        echo "$line" >> "$ZSHRC"
        echo ">> Created .zshrc and added $label"
    fi
}

echo ""
echo ">> Configuring PATH..."
add_to_zshrc "$FLUTTER_PATH_LINE" "Flutter PATH"
add_to_zshrc "$DART_PATH_LINE" "Dart SDK PATH"
add_to_zshrc "$PUB_PATH_LINE" "Pub cache PATH"

# Source for current session
export PATH="$HOME/flutter/bin:$HOME/flutter/bin/cache/dart-sdk/bin:$HOME/.pub-cache/bin:$PATH"

# ------------------------------------------
# 5. Dart version selection (optional)
# ------------------------------------------

echo ""
echo "Select Dart version:"
echo "  1) Use bundled Dart from Flutter (default)"
echo "  2) Specific Dart version (standalone via Homebrew)"
echo ""
read -p "Enter choice [1-2] (default: 1): " DART_CHOICE
DART_CHOICE=${DART_CHOICE:-1}

if [ "$DART_CHOICE" == "2" ]; then
    read -p "Enter Dart version (e.g. 3.5.0): " DART_VERSION
    echo ">> Installing Dart $DART_VERSION via Homebrew..."
    brew tap dart-lang/dart
    brew install dart@$DART_VERSION || brew install dart
    echo ">> Note: Standalone Dart may differ from Flutter's bundled Dart."
fi

# ------------------------------------------
# 6. Run Flutter doctor
# ------------------------------------------

echo ""
echo ">> Running Flutter precache & doctor..."
flutter precache
flutter doctor

# ------------------------------------------
# 7. Print versions
# ------------------------------------------

echo ""
echo "==========================================="
echo "  Installation Complete!"
echo "==========================================="
echo ""
echo "Flutter version:"
flutter --version
echo ""
echo "Dart version:"
dart --version
echo ""
echo ">> Restart your terminal or run: source ~/.zshrc"
echo "==========================================="
