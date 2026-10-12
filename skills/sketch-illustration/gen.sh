#!/bin/bash
# sketch-illustration generator · Replicate nano-banana-2
# Usage: bash gen.sh <slug> "<scene-body>" [ref_image_url]
# Env overrides: MODEL=, OUT_DIR=, TOKEN=, ASPECT= (16:9|9:16|1:1)

set -euo pipefail

TOKEN="${TOKEN:-${REPLICATE_API_TOKEN:?Set REPLICATE_API_TOKEN to your own Replicate key}}"
MODEL="${MODEL:-google/nano-banana-2}"
OUT_DIR="${OUT_DIR:-~/code/your-reports-repo/public/ativos/sketch-tests}"
ASPECT="${ASPECT:-16:9}"
mkdir -p "$OUT_DIR"

SLUG="${1:?usage: gen.sh <slug> <scene-body> [ref_image_url]}"
BODY="${2:?usage: gen.sh <slug> <scene-body> [ref_image_url]}"
REF_IMG="${3:-}"

STYLE_PREFIX='Hand-drawn ink illustration on warm off-white paper background, sketchy line-art with confident black ink strokes, hand-lettered marker typography. Color palette: black ink line-work + bold accent colors used selectively (warm orange #E97A4F as primary accent, plus muted teal #4A9B95 and warm yellow #F5C04A for secondary highlights). Use REAL recognizable brand logos with their official brand colors when shown (Telegram cyan paper-plane, WhatsApp green speech-bubble, Gmail red-white-blue M envelope, Slack four-color hashtag, Discord purple game-controller, Meta blue infinity, Notion black N, Google calendar blue grid, ElevenLabs black wave, Stripe purple, Anthropic orange Claude). Logos must be drawn loose and sketchy but unmistakable. Layout: clean composition, generous white space, hand-drawn arrows in orange connecting elements, casual hand-lettered all-caps labels.'

STYLE_SUFFIX='Aspect ratio 16:9. Style reference: whiteboard explainer drawn by a senior designer, like a Pixar storyboard or Tim Urban Wait But Why illustration. Crisp readable text, sketchy but professional.'

PROMPT="${STYLE_PREFIX} SCENE: ${BODY} ${STYLE_SUFFIX}"

echo "[$SLUG] generating via $MODEL (aspect $ASPECT, ref: ${REF_IMG:-none}) ..."

# Build payload with optional image_input
if [ -n "$REF_IMG" ]; then
  PAYLOAD=$(jq -n --arg p "$PROMPT" --arg a "$ASPECT" --arg img "$REF_IMG" \
    '{input: {prompt: $p, aspect_ratio: $a, output_format: "png", image_input: [$img]}}')
else
  PAYLOAD=$(jq -n --arg p "$PROMPT" --arg a "$ASPECT" \
    '{input: {prompt: $p, aspect_ratio: $a, output_format: "png"}}')
fi

RESP=$(curl -s -X POST "https://api.replicate.com/v1/models/$MODEL/predictions" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: wait" \
  -d "$PAYLOAD")

echo "$RESP" > "/tmp/replicate-resp-$SLUG.json"

# Output URL extraction · grep instead of jq because Replicate can return embedded
# unescaped control chars in echoed prompt field, breaking jq parsing.
URL=$(grep -oE '"output":"https://replicate\.delivery[^"]+"' "/tmp/replicate-resp-$SLUG.json" | sed 's/"output":"//;s/"$//')
if [ -z "$URL" ]; then
  URL=$(grep -oE 'https://replicate\.delivery/[^"]+\.png' "/tmp/replicate-resp-$SLUG.json" | head -1)
fi
if [ -z "$URL" ]; then
  echo "[$SLUG] ERROR · no output URL. Response head:"
  head -c 800 "/tmp/replicate-resp-$SLUG.json"
  exit 1
fi

curl -s -L "$URL" -o "$OUT_DIR/$SLUG.png"
SIZE=$(ls -lh "$OUT_DIR/$SLUG.png" | awk '{print $5}')
echo "[$SLUG] saved → $OUT_DIR/$SLUG.png ($SIZE)"

# Auto-open the saved image (skip with NO_OPEN=1)
if [ "${NO_OPEN:-}" != "1" ]; then
  open "$OUT_DIR/$SLUG.png" 2>/dev/null || true
fi

# Refresh gallery index
bash "$(dirname "$0")/refresh-gallery.sh" "$OUT_DIR" >/dev/null 2>&1 || true
