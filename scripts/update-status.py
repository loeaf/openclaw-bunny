#!/usr/bin/env python3
import json
import os
import subprocess
import time
import urllib.request
from datetime import datetime, timezone

OUT_PATH = os.environ.get(
    "OPENCLAW_BUNNY_STATUS_FILE",
    os.path.expanduser("~/.openclaw/workspace/openclaw-bunny-status.json"),
)
POLL_SECONDS = float(os.environ.get("OPENCLAW_BUNNY_POLL_SECONDS", "3"))
KEYSEO_PORTS = os.environ.get("KEYSEO_PORTS", "3000,3001,3011").split(",")


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


def fetch_json(url, timeout=1.2):
    try:
        with urllib.request.urlopen(url, timeout=timeout) as res:
            return json.loads(res.read().decode("utf-8", errors="ignore"))
    except Exception:
        return None


def get_keyseo_batch_state():
    for port in KEYSEO_PORTS:
        port = port.strip()
        if not port:
            continue
        url = f"http://127.0.0.1:{port}/api/keywords/expand/batch?limit=5"
        data = fetch_json(url)
        if not data or not data.get("ok"):
            continue

        rows = data.get("rows", [])
        running = []
        pending = []
        for row in rows:
            items = row.get("items") or []
            for it in items:
                seed = str(it.get("seed") or "").strip()
                status = str(it.get("status") or "")
                if not seed:
                    continue
                if status == "running":
                    running.append(seed)
                elif status == "pending":
                    pending.append(seed)

        return {
            "port": port,
            "running": running,
            "pending": pending,
        }

    return None


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

    keyseo = get_keyseo_batch_state()
    if keyseo:
        status = "busy" if len(keyseo["pending"]) >= 4 else ("working" if keyseo["running"] else "idle")
        bots.append(
            {
                "name": f"keyseo-batch:{keyseo['port']}",
                "status": status,
                "currentKeyword": keyseo["running"][0] if keyseo["running"] else None,
                "pendingKeywords": keyseo["pending"][:40],
            }
        )

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
