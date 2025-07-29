#!/bin/bash

echo "🚀 Building ExpenseTracker APK..."
echo "=================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build APK
echo "🔨 Building release APK..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo "=================================="
    echo "📱 APK Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APK Size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print "   " $5}'
    echo ""
    echo "🔗 To install on your phone:"
    echo "   1. Copy the APK to your phone"
    echo "   2. Enable 'Install from unknown sources' in Settings"
    echo "   3. Tap the APK file to install"
    echo ""
else
    echo ""
    echo "❌ BUILD FAILED!"
    echo "=================================="
    echo "Check the error messages above for details."
    echo ""
fi
