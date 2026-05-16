#!/bin/bash

set -e

echo "=== SPA Monitor - iOS Setup ==="

flutter clean
flutter pub get

cd ios
pod deintegrate
pod cache clean --all
LANG=en_US.UTF-8 pod install
cd ..

echo "=== Setup complete ==="
