#!/bin/bash
# save-historia.sh · gera sketch + replica nos 3 mirrors + append no entry do dia
#
# Usage:
#   bash save-historia.sh <slug> "<scene>" [ref_url] [v2|v3]
#
# Default mode: v3 (story 9:16 editorial). Use "v2" pra diagrama 16:9 minimal.
#
# Mirrors automáticos:
#   1. public/ativos/contar-minha-historia/YYYY/MM/DD/<slug>.png   (Hub web)
#   2. ~/code/secondBrain/02 Projetos/Ideias/contar-minha-historia/YYYY/MM/DD/<slug>.png   (vault)
#   3. Original gen path em public/ativos/sketch-tests/<slug>.png  (cache de geração)
#
# Append no entry markdown do dia em docs/tasks/contar-minha-historia/entries/YYYY-MM-DD.md

set -euo pipefail

SLUG="${1:?slug obrigatório}"
SCENE="${2:?scene obrigatória}"
REF="${3:-}"
STYLE="${4:-infografico}"
# Backwards compat: v2 → diagrama, v3 → infografico
case "$STYLE" in
  v2) STYLE="diagrama" ;;
  v3) STYLE="infografico" ;;
esac

DATE_YYYY=$(date +%Y)
DATE_MM=$(date +%m)
DATE_DD=$(date +%d)
DATE_FULL="${DATE_YYYY}-${DATE_MM}-${DATE_DD}"
DATE_PATH="${DATE_YYYY}/${DATE_MM}/${DATE_DD}"

REPO=~/code/your-reports-repo
SB_DIR="~/code/secondBrain/02 Projetos/Ideias/contar-minha-historia"
HUB_DIR="$REPO/public/ativos/contar-minha-historia"
TASKS_DIR="$REPO/docs/tasks/contar-minha-historia"
ENTRIES_DIR="$TASKS_DIR/entries"
SKETCH_DIR="$REPO/public/ativos/sketch-tests"

mkdir -p "$HUB_DIR/$DATE_PATH" "$SB_DIR/$DATE_PATH" "$ENTRIES_DIR"

# 1. Generate via gen-engine (style-aware)
echo "[historia] generating $SLUG (style=$STYLE) ..."
NO_OPEN=1 bash "$HOME/.claude/skills/sketch-illustration/gen-engine.sh" "$SLUG" "$SCENE" "$REF" "$STYLE"

SRC="$SKETCH_DIR/$SLUG.png"
if [ ! -f "$SRC" ]; then
  echo "[historia] ERROR: $SRC não foi gerado"
  exit 1
fi

# 2. Mirror
cp "$SRC" "$HUB_DIR/$DATE_PATH/$SLUG.png"
cp "$SRC" "$SB_DIR/$DATE_PATH/$SLUG.png"
SIZE=$(ls -lh "$SRC" | awk '{print $5}')

# 3. Append no entry do dia
ENTRY="$ENTRIES_DIR/$DATE_FULL.md"
if [ ! -f "$ENTRY" ]; then
  cat > "$ENTRY" <<EOF
# $DATE_FULL · entries

**Highlight do dia:** _(preencher)_

---

## Sketches

EOF
fi

cat >> "$ENTRY" <<EOF

### $SLUG

**Estilo:** $STYLE
**Status:** ✅ rendered
**Ref:** ${REF:-none}
**Custo:** ~\$0.05
**Size:** $SIZE

**Paths:**
- Hub: \`public/ativos/contar-minha-historia/$DATE_PATH/$SLUG.png\`
- Hub URL: https://your-host.example.com/ativos/contar-minha-historia/$DATE_PATH/$SLUG.png
- SecondBrain: \`02 Projetos/Ideias/contar-minha-historia/$DATE_PATH/$SLUG.png\`

**Scene:**
> $SCENE

EOF

echo "[historia] ✅ done"
echo "  Hub:         $HUB_DIR/$DATE_PATH/$SLUG.png"
echo "  SecondBrain: $SB_DIR/$DATE_PATH/$SLUG.png"
echo "  Entry:       $ENTRY"
echo "  Hub URL:     https://your-host.example.com/ativos/contar-minha-historia/$DATE_PATH/$SLUG.png"
