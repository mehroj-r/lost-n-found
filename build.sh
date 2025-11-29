#!/bin/bash

# Findly APK Build Script
# This script builds the Android APK for Findly app

set -e

echo "=========================================="
echo "  Building Findly APK"
echo "=========================================="
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build APK (release mode)
echo "🔨 Building release APK..."
flutter build apk --release

# Build APK (debug mode - optional)
# echo "🔨 Building debug APK..."
# flutter build apk --debug

echo ""
echo "=========================================="
echo "  ✅ Build Complete!"
echo "=========================================="
echo ""
echo "Release APK location:"
echo "  build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Install command:"
echo "  flutter install --release"
echo "  or"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
