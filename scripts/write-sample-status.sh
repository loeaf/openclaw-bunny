#!/usr/bin/env bash
set -euo pipefail

TARGET="${OPENCLAW_BUNNY_STATUS_FILE:-$HOME/.openclaw/workspace/openclaw-bunny-status.json}"
mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'JSON'
{
  "updatedAt": "2026-02-21T10:00:00+09:00",
  "bots": [
    {
      "name": "main",
      "status": "working",
      "currentKeyword": "키워드 분석",
      "pendingKeywords": ["ai 이미지 편집", "블로그 seo", "키워드 추천"]
    },
    {
      "name": "batch-expand",
      "status": "busy",
      "currentKeyword": "나라장터",
      "pendingKeywords": ["조달청", "입찰 공고", "지원사업", "g2b"]
    }
  ]
}
JSON

echo "Wrote sample status to: $TARGET"
