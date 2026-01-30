#!/bin/bash

# Build and Deploy Script for BlueMap Releases
# Usage: ./build-release.sh [version]

set -e

# Configuration
COASTAL_DIR="../CoastalAutoMapper"
RELEASE_DIR="."
UPDATE_SERVER_DIR="update-server"
VERSION=${1:-"1.0.1"}

echo "🔨 Building BlueMap Release v$VERSION"

# Step 1: Build the application
echo "📦 Building application..."
cd "$COASTAL_DIR/electron"
npm run release

# Step 2: Copy files to release repository
echo "📋 Copying release files..."
INSTALLER="BlueMap-Setup-$VERSION.exe"
SHA512_FILE="$INSTALLER.sha512"

cp "../release/$INSTALLER" "../../coastal-automapper-releases/$UPDATE_SERVER_DIR/updates/"
cp "../release/$SHA512_FILE" "../../coastal-automapper-releases/$UPDATE_SERVER_DIR/updates/"

# Step 3: Update version.json
echo "📝 Updating version.json..."
cd "../../coastal-automapper-releases"
cat > version.json << EOF
{
  "version": "$VERSION",
  "latest": "$VERSION",
  "releaseDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "changelog": "Auto-generated release v$VERSION"
}
EOF

# Step 4: Git operations
echo "🔄 Git operations..."
git add .
git commit -m "Release v$VERSION"
git push origin main

echo "✅ Release v$VERSION completed successfully!"
echo "📦 Download URL: http://your-server.com/updates/$INSTALLER"
echo "🔗 Update API: http://your-server.com/update/win32/previous-version"
