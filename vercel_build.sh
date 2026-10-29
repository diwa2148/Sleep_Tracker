#!/bin/bash
set -e

echo "=== Starting Flutter Web Build on Vercel ==="

# Clone Flutter SDK if not present in build cache
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable branch, depth 1)..."
  git clone -b stable --depth 1 https://github.com/flutter/flutter.git
else
  echo "Using cached Flutter SDK..."
fi

# Add Flutter binary to PATH
export PATH="$(pwd)/flutter/bin:$PATH"

echo "Verifying Flutter installation..."
flutter --version

echo "Configuring Flutter..."
flutter config --no-analytics
flutter config --enable-web

echo "Fetching packages..."
flutter pub get

echo "Building Flutter Web in Release mode..."
flutter build web --release

echo "=== Flutter Web Build Finished Successfully ==="

