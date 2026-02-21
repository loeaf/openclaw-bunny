#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="OpenClawBunny"
BUNDLE_NAME="${APP_NAME}.app"
BUNDLE_ID="ai.openclaw.bunny"
VERSION="${VERSION:-0.1.0}"
BUILD_DIR="$ROOT/.release"
APP_DIR="$BUILD_DIR/$BUNDLE_NAME"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RES_DIR="$APP_DIR/Contents/Resources"

rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR" "$RES_DIR"

pushd "$ROOT" >/dev/null
swift build -c release
BIN_PATH="$ROOT/.build/release/$APP_NAME"
cp "$BIN_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"
popd >/dev/null

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
</dict>
</plist>
PLIST

ZIP_PATH="$BUILD_DIR/${APP_NAME}-${VERSION}-macOS.zip"
( cd "$BUILD_DIR" && /usr/bin/zip -qry "$(basename "$ZIP_PATH")" "$BUNDLE_NAME" )

echo "Built app bundle: $APP_DIR"
echo "Built zip: $ZIP_PATH"
echo "Next: codesign + notarize before public release."
