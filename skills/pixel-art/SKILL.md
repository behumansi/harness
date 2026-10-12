---
name: pixel-art
description: Cartoon-flat illustrations no estilo cofounder.co · paisagem digital com paleta céu pastel + grama vibrante + off-white, vetor flat polido sem pixels visíveis. Gera via Replicate google/nano-banana-2. Use quando the user pedir "pixel art", "imagem estilo cofounder", "ilustração landing", "cena cartoon pra hero", "gera hero pra welcome", ou quando precisar de hero/cards visuais com estética cofounder pra landing pages e marketing. (Padrão the user: cartoon-flat, não pixel chunky · vibe polida moderna com paleta paisagem digital.)
---

# pixel-art · Padrão the user (Replicate · nano-banana-2)

Gera ilustrações pixel art 16-bit isométricas no estilo cofounder.co. Visual SNES-like com paleta vibrante de paisagem digital. Roda via Replicate, modelo `google/nano-banana-2` (Gemini 3.1 Flash Image).

## Quando usar

- Hero de landing page com cara retrô/Apple-keynote-meets-game
- Cards ilustrados em grids (4-6 cenas variadas)
- Banners de seção que precisam de personalidade visual sem virar AI slop
- Capa de blog post sobre produto/tecnologia
- Cenas que precisam contar uma história (servidor numa casa, agente trabalhando, cidade ao fundo)

**NÃO usar para:** logos, ícones técnicos, mockups de UI, dataviz, retratos realistas. Pra sketch hand-drawn use `/sketch-illustration`.

## Modelo

| Tipo | Modelo Replicate | Por quê |
|---|---|---|
| **DEFAULT** | `google/nano-banana-2` | Best pixel art coherence + paleta consistente. ~$0.05/img. |
| Fallback | `google/nano-banana-pro` | Se nano-banana-2 falhar ou quiser variação. |

## Uso

```bash
bash ~/.claude/skills/pixel-art/gen.sh <slug> "<scene-body>" [ref_image_url]
```

- `<slug>` · nome do arquivo (ex: `steve-hero`, `dashboard-card-1`)
- `<scene-body>` · descrição da cena em inglês, foco no que está na imagem
- `[ref_image_url]` · opcional, imagem de referência pra style transfer

Env overrides:
- `MODEL=google/nano-banana-pro`
- `OUT_DIR=/path/custom` (default: `~/.claude/assets/pixel-art/`)
- `ASPECT=16:9` (default) | `1:1` | `9:16` | `4:3`
- `TOKEN=r8_...` (override Replicate token)
- `NO_OPEN=1` (pula auto-open da imagem)

## Estética padrão (cofounder.co clone)

**Style prefix aplicado automaticamente:**

- 16-bit pixel art isométrica (estilo SNES / Stardew Valley / Octopath)
- Paleta: céu pastel (#7EC8E3 a #B6E0F2 gradient), grama vibrante (#7AC74F a #5BAA3F), branco off-white (#F5F5F0), cidade roxo-cinza ao fundo (#8A93B5)
- Nuvens chunky cumulus brancas com sombra azul-claro
- Árvores frondosas em primeiro plano (foreground frame)
- Iluminação suave de manhã, sem contraste agressivo
- Pixels chunky (não pixels minúsculos), legível a 1440px width
- Detalhes vivos: flores amarelas, banco de parque, caminho de terra, prédios distantes
- **Sem texto na imagem** (texto vem por overlay HTML/CSS)

## Cenas recomendadas pra Steve OS

```bash
# Hero principal · landing /welcome
bash gen.sh steve-hero "An isometric pixel art landscape: green grassy field foreground with yellow wildflowers and a wooden park bench on the left, a small open laptop sitting on the grass in the right-third of the frame with a tiny pixel-art cloud-shaped icon glowing on its screen, large lush pixel trees framing the right edge, a distant pixel city skyline of soft purple-gray buildings on the horizon center-left, big chunky cumulus clouds in pastel blue sky, dirt path winding through the grass, morning light, no people, no text, atmospheric depth"

# Card 1 · Conversa multi-canal
bash gen.sh card-conversa "Cozy isometric pixel art bedroom interior at dawn, a wooden desk by an open window with a small open laptop showing chat bubbles, sunlight pouring in golden, plant on windowsill, warm wood floor, books stacked, no people, no text, soft palette" 1:1

# Card 2 · Segundo cérebro
bash gen.sh card-cerebro "Isometric pixel art of a small cozy library room with floating glowing icon-orbs above an open book on a desk, warm lamp light, bookshelves on walls, dust particles, no people, no text" 1:1

# Card 3 · Regras conversacionais
bash gen.sh card-regras "Isometric pixel art workshop bench with a tiny robot assembling glowing connection cables between two devices, blueprint papers on wall, gears, evening light through window, no people, no text" 1:1

# Card 4 · VPS própria
bash gen.sh card-vps "Isometric pixel art of a small wooden cabin in a green meadow with a glowing server rack visible through the window, satellite dish on roof, mountains in distance, peaceful daytime scene, no people, no text" 1:1
```

## Workflow

1. Decide a cena → escreve scene-body curto e visual em inglês
2. Roda `gen.sh <slug> "<body>"` com aspect adequado
3. Imagem salva em `OUT_DIR/<slug>.png` e abre auto
4. Se não bater no estilo cofounder, ajusta scene-body e roda de novo (cada call ~$0.05)
5. Quando aprovar, copia PNG pro `public/<algum-path>/` do projeto

## Saída

- PNG salvo em `OUT_DIR/<slug>.png`
- Resposta raw da API em `/tmp/replicate-resp-<slug>.json` (debug)
- Auto-abre no Preview (skip com `NO_OPEN=1`)
- Custo logado: ~$0.05 por imagem com nano-banana-2

## Diferença vs sketch-illustration

| | sketch-illustration | pixel-art |
|---|---|---|
| Estilo | Hand-drawn ink + accent colors | 16-bit isometric pixel SNES |
| Uso | Explicar conceito, whiteboard, pitch | Hero landing, cards, atmosfera |
| Logos | Sim, real brand logos | Não (só cenário) |
| Texto | Sim, hand-lettered | Não (overlay externo) |
| Vibe | Tim Urban / Pixar storyboard | Stardew Valley / cofounder.co |