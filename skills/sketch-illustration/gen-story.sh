#!/bin/bash
# v3 · Story format (9:16) + filled colors + scene background + optional ref image
# Usage: bash gen-story.sh <slug> "<scene>" [ref_image_url]
set -euo pipefail

TOKEN="${TOKEN:-${REPLICATE_API_TOKEN:?Set REPLICATE_API_TOKEN to your own Replicate key}}"
MODEL="${MODEL:-google/nano-banana-2}"
OUT_DIR="${OUT_DIR:-~/code/your-reports-repo/public/ativos/sketch-tests}"
mkdir -p "$OUT_DIR"

SLUG="$1"
BODY="$2"
REF_IMG="${3:-}"

STYLE_PREFIX='Hand-drawn editorial illustration in mixed-media style: confident black ink line-work + watercolor wash backgrounds + colored marker fills. Style reference: New York Times explainer illustration, Christoph Niemann, modern visual essay. Colors: warm paper texture base #FAF6EE, with VIBRANT filled regions in warm orange #E97A4F, muted teal #4A9B95, warm yellow #F5C04A, soft coral #F0876B, dusty blue #6B9BD2, sage green #8AB97F. Color is APPLIED LIBERALLY across backgrounds, character clothes, object fills, not just accent dots. Real recognizable brand logos with their official brand colors when shown (Telegram cyan paper-plane, WhatsApp green speech-bubble, Gmail red-white-blue M envelope, Slack four-color hashtag, Discord purple, Meta blue infinity, Notion black N, Google calendar blue grid, ElevenLabs black wave, Stripe purple, Anthropic orange Claude orb, GitHub black octocat, Cursor black C). Hand-lettered marker typography. Setting: include scene context (a room, a desk, a city skyline, a workshop), not floating elements on white. Paper texture visible behind everything. Generous orange marker arrows connecting beats.'

STYLE_SUFFIX='Aspect ratio 9:16 (vertical Instagram Story / Reels format). Style reference: Christoph Niemann + Maira Kalman + Tim Urban illustrated essay. Crisp readable hand-lettered text. Story format: clear top headline, central illustration, bottom callout/CTA. Designed for social media share, bold enough to read on phone, warm enough to feel human.'

PROMPT="${STYLE_PREFIX} SCENE: ${BODY} ${STYLE_SUFFIX}"

echo "[$SLUG] generating v3 story format via $MODEL (ref: ${REF_IMG:-none}) ..."

if [ -n "$REF_IMG" ]; then
  PAYLOAD=$(jq -n --arg p "$PROMPT" --arg img "$REF_IMG" \
    '{input: {prompt: $p, aspect_ratio: "9:16", output_format: "png", image_input: [$img]}}')
else
  PAYLOAD=$(jq -n --arg p "$PROMPT" \
    '{input: {prompt: $p, aspect_ratio: "9:16", output_format: "png"}}')
fi

RESP=$(curl -s -X POST "https://api.replicate.com/v1/models/$MODEL/predictions" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: wait" \
  -d "$PAYLOAD")

echo "$RESP" > "/tmp/replicate-resp-$SLUG.json"

# Output URL via grep (jq breaks on echoed prompt with control chars)
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
echo "[$SLUG] saved → $OUT_DIR/$SLUG.png ($(ls -lh "$OUT_DIR/$SLUG.png" | awk '{print $5}'))"

# Auto-open
[ "${NO_OPEN:-}" != "1" ] && open "$OUT_DIR/$SLUG.png" 2>/dev/null || true

# Refresh gallery index
bash "$(dirname "$0")/refresh-gallery.sh" "$OUT_DIR" >/dev/null 2>&1 || true
