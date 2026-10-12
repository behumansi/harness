#!/bin/bash
# Refresh the sketch-tests gallery HTML index (auto-discovers all PNGs sorted newest first).
# Run after generating new images. Or wire into Stop hook.
set -euo pipefail

OUT_DIR="${1:-~/code/your-reports-repo/public/ativos/sketch-tests}"
INDEX="$OUT_DIR/index.html"

# Build list newest first
FILES=$(find "$OUT_DIR" -maxdepth 1 -type f -name "*.png" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | awk '{print $2}')

# Build cards array as JS
CARDS_JS=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  base=$(basename "$f" .png)
  ts=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null)
  CARDS_JS+="    {n:'$base', d:'$ts'},\n"
done <<< "$FILES"

cat > "$INDEX" <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sketch Tests · Galeria</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#0a0a0b;color:#fafafa;font:14px/1.5 -apple-system,system-ui,sans-serif;padding:24px;min-height:100vh}
h1{font-weight:800;font-size:28px;letter-spacing:-0.02em;margin-bottom:6px}
.lede{color:#a1a1aa;margin-bottom:32px;font-size:13px}
code{background:rgba(255,255,255,.06);padding:2px 6px;border-radius:4px;font-size:11px}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px}
.card{background:#111113;border:1px solid rgba(255,255,255,.08);border-radius:12px;overflow:hidden;transition:all .25s;text-decoration:none;color:inherit}
.card:hover{transform:translateY(-2px);border-color:rgba(217,119,87,.3)}
.card img{width:100%;height:auto;display:block;background:#000}
.meta{padding:12px 14px;display:flex;justify-content:space-between;align-items:center;font-size:12px;gap:10px}
.name{font-family:'JetBrains Mono',ui-monospace,monospace;font-weight:600;color:#f5f4ad;letter-spacing:0.02em;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.date{color:#71717a;font-family:'JetBrains Mono',ui-monospace,monospace;font-size:10px;flex-shrink:0}
</style>
</head>
<body>
<h1>Sketch Tests · Galeria</h1>
<div class="lede">Tudo gerado via skill <code>sketch-illustration</code>. Mais novo primeiro. Click pra abrir.</div>
<div id="grid" class="grid"></div>
<script>
const files = [
$(echo -e "$CARDS_JS")
];
const grid = document.getElementById('grid');
files.forEach(f => {
  const card = document.createElement('a');
  card.className = 'card';
  card.href = f.n + '.png';
  card.target = '_blank';
  card.innerHTML = '<img src="' + f.n + '.png" alt="' + f.n + '" loading="lazy"><div class="meta"><span class="name">' + f.n + '</span><span class="date">' + f.d + '</span></div>';
  grid.appendChild(card);
});
</script>
</body>
</html>
EOF

echo "✓ Gallery refreshed → $INDEX ($(echo "$FILES" | grep -c .) images)"

# Auto-open if asked
[ "${OPEN:-0}" = "1" ] && open "$INDEX"
