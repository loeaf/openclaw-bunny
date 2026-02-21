# Contributing

Thanks for contributing to OpenClaw Bunny 🐇

## Dev setup

```bash
cd /Users/doheyonkim/Depot/OpenClawBunny
swift build
./scripts/run-bridge.sh
swift run OpenClawBunny
```

## PR checklist

- [ ] Build succeeds (`swift build`)
- [ ] App launches (`swift run OpenClawBunny`)
- [ ] README / CHANGELOG updated for user-visible changes
- [ ] No secrets or private paths committed

## Coding notes

- Keep menu bar UI lightweight.
- Avoid blocking calls on main thread.
- Status bridge output format must remain backward compatible.
