#!/bin/bash

# Deep Uninstaller Build Script

set -e

echo "🔨 Building Deep Uninstaller..."
echo ""

# Check Swift version
echo "Swift version:"
swift --version
echo ""

# Clean build artifacts
echo "🧹 Cleaning previous builds..."
rm -rf .build
echo ""

# Build the project
echo "🏗️  Building in release mode..."
swift build -c release
echo ""

# Show build products
echo "✅ Build complete!"
echo ""
echo "Build products:"
ls -lh .build/release/DeepUninstaller 2>/dev/null || echo "Binary not found"
echo ""

echo "To run the application:"
echo "  swift run"
echo ""
echo "Or run directly:"
echo "  .build/release/DeepUninstaller"
