# Release Guide

## 1) Build

```bash
chmod +x ./scripts/build-release.sh
VERSION=0.1.0 ./scripts/build-release.sh
```

Artifacts:
- `.release/OpenClawBunny.app`
- `.release/OpenClawBunny-0.1.0-macOS.zip`

## 2) Sign + Notarize (Apple Developer)

```bash
chmod +x ./scripts/notarize.sh
APP_PATH=.release/OpenClawBunny.app \
APPLE_ID="you@example.com" \
TEAM_ID="ABCDE12345" \
APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
./scripts/notarize.sh
```

## 3) GitHub Release

- Create tag: `git tag v0.1.0 && git push origin v0.1.0`
- GitHub Actions workflow builds and uploads `.zip` asset automatically.

## 4) Optional: DMG packaging

Use create-dmg or appdmg to make a drag-and-drop installer.
