#!/bin/bash
# pixel-art generator · Replicate nano-banana-2 · estética cofounder.co
# Usage: bash gen.sh <slug> "<scene-body>" [ref_image_url]
# Env: MODEL= OUT_DIR= TOKEN= ASPECT= NO_OPEN=

set -euo pipefail

TOKEN="${TOKEN:-${REPLICATE_API_TOKEN:?Set REPLICATE_API_TOKEN to your own Replicate key}}"
MODEL="${MODEL:-google/nano-banana-2}"
OUT_DIR="${OUT_DIR:-$HOME/.claude/assets/pixel-art}"
ASPECT="${ASPECT:-16:9}"
mkdir -p "$OUT_DIR"

SLUG="${1:?usage: gen.sh <slug> <scene-body> [ref_image_url]}"
BODY="${2:?usage: gen.sh <slug> <scene-body> [ref_image_url]}"
REF_IMG="${3:-}"

STYLE_PREFIX='Cartoon-flat illustration in the style of cofounder.co landing page hero, polished modern vector aesthetic with soft clean lines, lush peaceful scenery, no visible pixel grid, smooth gradients allowed but flat color blocks dominate. Color palette: pastel sky blue gradient (#7EC8E3 top to #B6E0F2 bottom), vibrant grass green (#7AC74F highlights, #5BAA3F shadows), warm off-white (#F5F5F0), distant city in soft muted purple-gray (#8A93B5 to #6B7299), wildflower yellow accents (#F5C04A), warm brown wood (#8B5A3C). Chunky cumulus clouds in white with soft pastel-blue underside shadows. Frame composition: lush detailed trees framing the foreground edges, yellow wildflowers and grass tufts in the immediate foreground, distant city skyline of soft purple-gray buildings on the horizon, dirt path or stone elements winding through grass, atmospheric depth with hazy distance. Lighting: soft morning golden-hour light, no harsh contrast, dreamy peaceful mood. Render: clean vector cartoon style, smooth edges, modern illustrated landing page hero quality, evocative of cofounder.co or modern animated film backgrounds. NO TEXT, NO LOGOS, NO PEOPLE, NO UI ELEMENTS · pure scenery only.'

STYLE_SUFFIX='Wide cinematic composition. Style reference: cofounder.co landing page hero illustration, polished cartoon-flat with pastel pixel-adjacent palette. Atmospheric, peaceful, inviting. Modern vector cartoon · clean lines, flat colors, soft shading, no visible pixels.'

PROMPT="${STYLE_PREFIX} SCENE: ${BODY} ${STYLE_SUFFIX}"

echo "[$SLUG] generating via $MODEL (aspect $ASPECT, ref: ${REF_IMG:-none}) ..."

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

if [ "${NO_OPEN:-}" != "1" ]; then
  open "$OUT_DIR/$SLUG.png" 2>/dev/null || true
fi