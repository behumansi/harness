#!/bin/bash
# queue-historia.sh · append prompt no debt queue (sem renderizar agora)
#
# Usage:
#   bash queue-historia.sh <slug> "<scene>" [ref_url] [style_name]
#
# style_name: infografico|diagrama|historia|cycle (ver styles.json)
# Backwards compat: v2→diagrama, v3→infografico
#
# Output: linha JSONL em docs/tasks/contar-minha-historia/prompts-queue.jsonl

set -euo pipefail

SLUG="${1:?slug obrigatório}"
SCENE="${2:?scene obrigatória}"
REF="${3:-}"
STYLE="${4:-infografico}"

case "$STYLE" in
  v2) STYLE="diagrama" ;;
  v3) STYLE="infografico" ;;
esac

REPO=~/code/your-reports-repo
QUEUE="$REPO/docs/tasks/contar-minha-historia/prompts-queue.jsonl"

mkdir -p "$(dirname "$QUEUE")"
touch "$QUEUE"

CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

LINE=$(jq -c -n \
  --arg slug "$SLUG" \
  --arg scene "$SCENE" \
  --arg ref "$REF" \
  --arg style "$STYLE" \
  --arg created_at "$CREATED_AT" \
  '{slug:$slug, scene:$scene, ref:$ref, style:$style, created_at:$created_at, status:"queued"}')

echo "$LINE" >> "$QUEUE"

QUEUED=$(grep -c '"status":"queued"' "$QUEUE" 2>/dev/null || echo 0)
echo "[queue] ✅ enqueued: $SLUG (style=$STYLE)"
echo "[queue] $QUEUED prompts pendentes em $QUEUE"
