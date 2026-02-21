#!/usr/bin/env bash
set -euo pipefail

# Usage:
#  APP_PATH=.release/OpenClawBunny.app \
#  APPLE_ID="you@example.com" \
#  TEAM_ID="ABCDE12345" \
#  APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
#  ./scripts/notarize.sh

APP_PATH="${APP_PATH:-.release/OpenClawBunny.app}"
ZIP_PATH="${ZIP_PATH:-.release/OpenClawBunny-notarize.zip}"
BUNDLE_ID="${BUNDLE_ID:-ai.openclaw.bunny}"
SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application}"

: "${APPLE_ID:?APPLE_ID is required}"
: "${TEAM_ID:?TEAM_ID is required}"
: "${APP_PASSWORD:?APP_PASSWORD is required}"

if [ ! -d "$APP_PATH" ]; then
  echo "App not found: $APP_PATH"
  exit 1
fi

echo "[1/4] codesign"
codesign --force --deep --timestamp --options runtime --sign "$SIGN_IDENTITY" "$APP_PATH"

echo "[2/4] zip for notarization"
rm -f "$ZIP_PATH"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

echo "[3/4] submit notarization"
xcrun notarytool submit "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_PASSWORD" \
  --wait

echo "[4/4] staple"
xcrun stapler staple "$APP_PATH"

echo "Done: notarized and stapled -> $APP_PATH"
