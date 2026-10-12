#!/bin/bash
# drain-queue.sh · render N próximos prompts queued no debt queue
#
# Usage:
#   bash drain-queue.sh [N]    # default 10
#
# Lê prompts-queue.jsonl, pega N com status=queued, renderiza um a um (rate-limit safe),
# marca como rendered. Sequential com sleep 12s entre calls (Replicate free tier safe).

set -euo pipefail

N="${1:-10}"
REPO=~/code/your-reports-repo
QUEUE="$REPO/docs/tasks/contar-minha-historia/prompts-queue.jsonl"
SAVE="$HOME/.claude/skills/sketch-illustration/save-historia.sh"

if [ ! -f "$QUEUE" ]; then
  echo "[drain] no queue file at $QUEUE"
  exit 0
fi

QUEUED=$(grep -c '"status":"queued"' "$QUEUE" 2>/dev/null || echo 0)
if [ "$QUEUED" -eq 0 ]; then
  echo "[drain] queue empty"
  exit 0
fi

echo "[drain] queue has $QUEUED queued · processing up to $N"

TMP=$(mktemp)
COUNT=0

while IFS= read -r LINE; do
  STATUS=$(echo "$LINE" | jq -r '.status')
  if [ "$STATUS" != "queued" ] || [ "$COUNT" -ge "$N" ]; then
    echo "$LINE" >> "$TMP"
    continue
  fi

  SLUG=$(echo "$LINE" | jq -r '.slug')
  SCENE=$(echo "$LINE" | jq -r '.scene')
  REF=$(echo "$LINE" | jq -r '.ref')
  STYLE=$(echo "$LINE" | jq -r '.style // .mode // "infografico"')

  echo "[drain] [$((COUNT+1))/$N] $SLUG (style=$STYLE)"
  if bash "$SAVE" "$SLUG" "$SCENE" "$REF" "$STYLE"; then
    echo "$LINE" | jq -c '.status = "rendered" | .rendered_at = (now | todate)' >> "$TMP"
    COUNT=$((COUNT+1))
    sleep 12
  else
    echo "$LINE" | jq -c '.status = "failed" | .failed_at = (now | todate)' >> "$TMP"
  fi
done < "$QUEUE"

mv "$TMP" "$QUEUE"
echo "[drain] ✅ rendered $COUNT prompts"
