# OpenClaw Bunny 🐇

A macOS menu bar app that visualizes OpenClaw workload in real time.

- Idle: bunny resting
- Working: bunny running
- Busy: bunny runs faster

## Features

- Menu bar live status
- Bot list (name, status)
- Current keyword + pending keyword queue
- Local bridge script for OpenClaw sessions + keyseo batch queue

## Quick Start

```bash
cd /Users/doheyonkim/Depot/OpenClawBunny
chmod +x ./scripts/run-bridge.sh ./scripts/update-status.py
./scripts/run-bridge.sh
```

In another terminal:

```bash
cd /Users/doheyonkim/Depot/OpenClawBunny
swift run OpenClawBunny
```

## Status file

Default status file path:

`~/.openclaw/workspace/openclaw-bunny-status.json`

You can override it:

```bash
OPENCLAW_BUNNY_STATUS_FILE=/tmp/openclaw-bunny-status.json ./scripts/run-bridge.sh
```

## Bridge options

```bash
# Poll interval in seconds
OPENCLAW_BUNNY_POLL_SECONDS=2 ./scripts/run-bridge.sh

# keyseo port candidates
KEYSEO_PORTS=3001,3011 ./scripts/run-bridge.sh
```

## Build release artifact

```bash
cd /Users/doheyonkim/Depot/OpenClawBunny
chmod +x ./scripts/build-release.sh
./scripts/build-release.sh
```

Output:

- `.release/OpenClawBunny.app`
- `.release/OpenClawBunny-<version>-macOS.zip`

## Public release checklist

1. Product polish (icon/animation/settings UI)
2. Sign + notarize with Apple Developer account
3. Publish on GitHub Releases (`.zip`/`.dmg`)
4. Add install docs
5. (Optional) Homebrew Cask

## Docs

- `PRIVACY.md`
- `LICENSE` (MIT)
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- `RELEASE.md`
