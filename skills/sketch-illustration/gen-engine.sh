#!/bin/bash
# gen-engine.sh · multi-provider image generator que lê styles.json
#
# Usage:
#   bash gen-engine.sh <slug> "<scene>" [ref_url_OR_people_slugs] [style_name|cycle]
#
# Provider per-style (styles.json `.provider`, default replicate):
#   - replicate:  legacy Replicate API. Token in $REPLICATE_API_TOKEN or credentials/replicate.env
#   - openrouter: OpenRouter chat completions (Nano Banana 2 = google/gemini-3.1-flash-image-preview).
#                 Key in $OPENROUTER_API_KEY or /Users/you/.claude/credentials/openrouter.env
#
# Style "cycle" rotaciona segundo styles.json._rotation_order via .last-style
# Output: ./sketches/<slug>.png
#
# People mode (when style has needs_image_input=true):
#   Arg 3 = comma-separated people slugs (e.g. "subject" or "subject,person-two")
#   Resolves each slug → photo URL + brand-ref.json
#   First slug = HOST (palette dominates), rest = GUESTS (accent only)
#   Auto-injects appearance_anchors + brand merge into the prompt.

set -euo pipefail

OUT_DIR="${OUT_DIR:-./sketches}"
SKILL_DIR="$HOME/.claude/skills/sketch-illustration"
STYLES_JSON="$SKILL_DIR/styles.json"
LAST_STYLE_FILE="$SKILL_DIR/.last-style"
CRED_DIR="$HOME/.claude/credentials"

# Load credentials from disk if env vars not set
[ -z "${REPLICATE_API_TOKEN:-}" ] && [ -f "$CRED_DIR/replicate.env" ] && set -a && source "$CRED_DIR/replicate.env" && set +a
[ -z "${OPENROUTER_API_KEY:-}" ] && [ -f "$CRED_DIR/openrouter.env" ] && set -a && source "$CRED_DIR/openrouter.env" && set +a

mkdir -p "$OUT_DIR"

SLUG="${1:?slug obrigatório}"
SCENE="${2:?scene obrigatória}"
REF_OR_PEOPLE="${3:-}"
STYLE="${4:-infografico}"

# Resolve cycle
if [ "$STYLE" = "cycle" ]; then
  ORDER=$(jq -r '._rotation_order | join(" ")' "$STYLES_JSON")
  LAST=""
  [ -f "$LAST_STYLE_FILE" ] && LAST=$(cat "$LAST_STYLE_FILE")

  NEXT=""
  FOUND_LAST=0
  for s in $ORDER; do
    if [ "$FOUND_LAST" = "1" ]; then NEXT="$s"; break; fi
    if [ "$s" = "$LAST" ]; then FOUND_LAST=1; fi
  done
  [ -z "$NEXT" ] && NEXT=$(echo "$ORDER" | awk '{print $1}')
  STYLE="$NEXT"
  echo "[cycle] last=$LAST → next=$STYLE"
fi

# Validate style exists
if ! jq -e --arg s "$STYLE" '.[$s]' "$STYLES_JSON" >/dev/null 2>&1; then
  echo "[ERR] style '$STYLE' not in styles.json"
  echo "[INFO] available styles:"
  jq -r 'keys[] | select(. | startswith("_") | not)' "$STYLES_JSON"
  exit 1
fi

# Pull style config
PREFIX=$(jq -r --arg s "$STYLE" '.[$s].prefix' "$STYLES_JSON")
SUFFIX=$(jq -r --arg s "$STYLE" '.[$s].suffix' "$STYLES_JSON")
ASPECT=$(jq -r --arg s "$STYLE" '.[$s].aspect_ratio' "$STYLES_JSON")
MODEL=$(jq -r --arg s "$STYLE" '.[$s].model' "$STYLES_JSON")
LABEL=$(jq -r --arg s "$STYLE" '.[$s].label' "$STYLES_JSON")
PROVIDER=$(jq -r --arg s "$STYLE" '.[$s].provider // "replicate"' "$STYLES_JSON")
NEEDS_PEOPLE=$(jq -r --arg s "$STYLE" '.[$s].needs_image_input // false' "$STYLES_JSON")

# Resolve refs: people-mode vs single-url-mode
REFS_JSON="[]"
PEOPLE_BLOCK=""

if [ -n "$REF_OR_PEOPLE" ] && [[ ! "$REF_OR_PEOPLE" =~ ^https?:// ]]; then
  PEOPLE_ROOT=$(jq -r '._people_root' "$STYLES_JSON")
  PEOPLE_URL_BASE=$(jq -r '._people_url_base' "$STYLES_JSON")

  IFS=',' read -ra SLUGS <<< "$REF_OR_PEOPLE"
  HOST_SLUG="${SLUGS[0]}"

  # Build URLs array + per-person blocks
  URLS_ARR=()
  IDX=0
  for s in "${SLUGS[@]}"; do
    s=$(echo "$s" | xargs) # trim
    PERSON_DIR="$PEOPLE_ROOT/$s"
    BREF="$PERSON_DIR/brand-ref.json"

    if [ ! -d "$PERSON_DIR" ]; then
      echo "[ERR] person not found: $PERSON_DIR"
      echo "[INFO] available people:"
      ls "$PEOPLE_ROOT" 2>/dev/null
      exit 1
    fi

    # Find photo file (jpg/jpeg/png)
    PHOTO=""
    for ext in jpeg jpg png; do
      if [ -f "$PERSON_DIR/photo.$ext" ]; then
        PHOTO="$PERSON_DIR/photo.$ext"
        PHOTO_EXT="$ext"
        break
      fi
    done
    [ -z "$PHOTO" ] && { echo "[ERR] no photo.{jpg,jpeg,png} in $PERSON_DIR"; exit 1; }

    PHOTO_URL="$PEOPLE_URL_BASE/$s/photo.$PHOTO_EXT"
    URLS_ARR+=("$PHOTO_URL")

    # Build appearance + brand block
    NAME=$(jq -r '.person.full_name' "$BREF")
    ANCHORS=$(jq -r '.person.appearance_anchors | map("- " + .) | join("\n")' "$BREF")
    PALETTE=$(jq -r '.brand.palette | to_entries | map(.key + "=" + .value) | join(", ")' "$BREF")
    VIBE=$(jq -r '.brand.vibe_keywords | join(", ")' "$BREF")
    HOOKS=$(jq -r '.brand.guest_accent_hooks | join("; ")' "$BREF")

    if [ "$IDX" = "0" ]; then
      ROLE="HOST (palette dominates ~80% of the frame)"
    else
      ROLE="GUEST (accents only ~10-20%, near this subject)"
    fi

    PEOPLE_BLOCK+="

SUBJECT $((IDX+1)) · $NAME · $ROLE
APPEARANCE (lock these · face must match reference photo $((IDX+1)) exactly):
$ANCHORS
BRAND PALETTE: $PALETTE
BRAND VIBE: $VIBE
ACCENT HOOKS (use when guest): $HOOKS
"
    IDX=$((IDX+1))
  done

  # Build JSON array of URLs
  REFS_JSON=$(printf '%s\n' "${URLS_ARR[@]}" | jq -R . | jq -s .)
  REF_DISPLAY="people=$REF_OR_PEOPLE host=$HOST_SLUG urls=${URLS_ARR[*]}"

elif [ -n "$REF_OR_PEOPLE" ]; then
  # Legacy single-url mode
  REFS_JSON=$(jq -n --arg u "$REF_OR_PEOPLE" '[$u]')
  REF_DISPLAY="single=$REF_OR_PEOPLE"
else
  REF_DISPLAY="none"
fi

# Compose final prompt
if [ -n "$PEOPLE_BLOCK" ]; then
  PROMPT="${PREFIX}

PEOPLE IN FRAME:
${PEOPLE_BLOCK}

SCENE: ${SCENE}

${SUFFIX}"
else
  PROMPT="${PREFIX} SCENE: ${SCENE} ${SUFFIX}"
fi

echo "[gen] slug=$SLUG style=$STYLE ($LABEL) aspect=$ASPECT provider=$PROVIDER model=$MODEL ref=$REF_DISPLAY"

RESP_FILE="/tmp/genengine-resp-$SLUG.json"
OUT_FILE="$OUT_DIR/$SLUG.png"

case "$PROVIDER" in
  replicate)
    : "${REPLICATE_API_TOKEN:?REPLICATE_API_TOKEN not set (provider=replicate)}"

    if [ "$REFS_JSON" != "[]" ]; then
      PAYLOAD=$(jq -n --arg p "$PROMPT" --argjson imgs "$REFS_JSON" --arg ar "$ASPECT" \
        '{input: {prompt: $p, aspect_ratio: $ar, output_format: "png", image_input: $imgs}}')
    else
      PAYLOAD=$(jq -n --arg p "$PROMPT" --arg ar "$ASPECT" \
        '{input: {prompt: $p, aspect_ratio: $ar, output_format: "png"}}')
    fi

    curl -s -X POST "https://api.replicate.com/v1/models/$MODEL/predictions" \
      -H "Authorization: Bearer $REPLICATE_API_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Prefer: wait" \
      -d "$PAYLOAD" > "$RESP_FILE"

    URL=$(grep -oE '"output":"https://replicate\.delivery[^"]+"' "$RESP_FILE" | sed 's/"output":"//;s/"$//')
    [ -z "$URL" ] && URL=$(grep -oE 'https://replicate\.delivery/[^"]+\.png' "$RESP_FILE" | head -1)

    if [ -z "$URL" ]; then
      echo "[ERR] no output URL · response head:"
      head -c 800 "$RESP_FILE"; echo
      exit 1
    fi

    curl -s -L "$URL" -o "$OUT_FILE"
    ;;

  openrouter)
    : "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY not set (provider=openrouter)}"

    # Build content array: image_url parts (refs) + text part (prompt with explicit aspect ratio)
    PROMPT_WITH_AR="${PROMPT}

OUTPUT ASPECT RATIO: ${ASPECT} (strictly enforce this aspect ratio in the generated image)."

    CONTENT_PARTS="[]"
    if [ "$REFS_JSON" != "[]" ]; then
      CONTENT_PARTS=$(echo "$REFS_JSON" | jq '[.[] | {type: "image_url", image_url: {url: .}}]')
    fi
    CONTENT_PARTS=$(echo "$CONTENT_PARTS" | jq --arg t "$PROMPT_WITH_AR" '. + [{type: "text", text: $t}]')

    PAYLOAD=$(jq -n --arg model "$MODEL" --argjson content "$CONTENT_PARTS" \
      '{model: $model, modalities: ["image","text"], messages: [{role: "user", content: $content}]}')

    curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" \
      -H "Authorization: Bearer $OPENROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      -H "HTTP-Referer: https://your-host.example.com" \
      -H "X-Title: sketch-illustration" \
      -d "$PAYLOAD" > "$RESP_FILE"

    # Parse base64 image from choices[0].message.images[0].image_url.url
    DATA_URL=$(jq -r '.choices[0].message.images[0].image_url.url // empty' "$RESP_FILE")

    if [ -z "$DATA_URL" ]; then
      echo "[ERR] no image in OpenRouter response · head:"
      head -c 1200 "$RESP_FILE"; echo
      exit 1
    fi

    # Strip "data:image/png;base64," prefix and decode
    BASE64=$(echo "$DATA_URL" | sed 's/^data:image\/[a-z]*;base64,//')
    echo "$BASE64" | base64 -d > "$OUT_FILE"
    ;;

  *)
    echo "[ERR] unknown provider: $PROVIDER (expected replicate|openrouter)"
    exit 1
    ;;
esac

echo "$STYLE" > "$LAST_STYLE_FILE"
echo "[gen] saved → $OUT_FILE ($(ls -lh "$OUT_FILE" | awk '{print $5}'))"

[ "${NO_OPEN:-}" != "1" ] && open "$OUT_DIR/$SLUG.png" 2>/dev/null || true

bash "$SKILL_DIR/refresh-gallery.sh" "$OUT_DIR" >/dev/null 2>&1 || true
