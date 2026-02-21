#!/usr/bin/env python3
import json
import os
import subprocess
import time
from datetime import datetime, timezone

OUT_PATH = os.environ.get(
    "OPENCLAW_BUNNY_STATUS_FILE",
    os.path.expanduser("~/.openclaw/workspace/openclaw-bunny-status.json"),
)
POLL_SECONDS = float(os.environ.get("OPENCLAW_BUNNY_POLL_SECONDS", "3"))


def run_cmd(cmd):
    try:
        out = subprocess.check_output(cmd, stderr=subprocess.DEVNULL)
        return out.decode("utf-8", errors="ignore")
    except Exception:
        return ""


def get_openclaw_sessions():
    raw = run_cmd(["openclaw", "sessions", "--active", "240", "--json"])
    if not raw.strip():
        return []
    try:
        data = json.loads(raw)
        return data.get("sessions", [])
    except Exception:
        return []


def map_session_to_bot(session):
    key = str(session.get("key") or "main")
    name = key.split(":")[-1] if ":" in key else key
    age_ms = int(session.get("ageMs") or 99999999)
    status = "working" if age_ms <= 120000 else "idle"

    return {
        "name": name,
        "status": status,
        "currentKeyword": None,
        "pendingKeywords": [],
    }


def build_snapshot():
    bots = [map_session_to_bot(s) for s in get_openclaw_sessions()]

    if not bots:
        bots = [
            {
                "name": "main",
                "status": "idle",
                "currentKeyword": "세션 없음",
                "pendingKeywords": [],
            }
        ]

    return {
        "updatedAt": datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds"),
        "bots": bots,
    }


def write_snapshot(snapshot):
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    tmp = OUT_PATH + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, ensure_ascii=False, indent=2)
    os.replace(tmp, OUT_PATH)


def main():
    print(f"[OpenClawBunny] writing status -> {OUT_PATH}")
    while True:
        snap = build_snapshot()
        write_snapshot(snap)
        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    main()
