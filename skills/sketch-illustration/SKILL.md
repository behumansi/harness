---
name: sketch-illustration
description: Hand-drawn ink-sketch explainer illustrations with real brand logos and selective color accents (whiteboard / Wait-But-Why / storyboard style). Use when the user asks to "criar ilustração", "desenho explicativo", "sketch pra pitch", "diagrama estilo whiteboard", "imagem hand-drawn", "ilustração estilo Tim Urban", or wants to explain a system/concept visually for a client or post. Generates via Replicate `google/nano-banana-2` (Gemini 3.1 Flash Image) · best model for sketch + real logos + readable text.
---

# Sketch Illustration Skill

Generate hand-drawn explainer illustrations that look like a senior designer sketched them on a whiteboard. Real brand logos. Selective color accents. Hand-lettered typography. Output: 16:9 PNG ~1MB ready for slides, posts, propostas, landing pages.

## When to invoke

- "ilustração estilo whiteboard / Wait But Why / Pixar storyboard"
- "desenho explicativo pra pitch / cliente / landing"
- "sketch pra explicar como X funciona"
- "diagrama hand-drawn"
- "criar imagem com logos e setas"
- Reference image like the [public/ativos/sketch-tests/wrapper-banana-pro-v1.png](../../../code/your-reports-repo/public/ativos/sketch-tests/wrapper-banana-pro-v1.png) ("THE WRAPPER" diagram)

## Model selection (always Replicate)

| Model | Slug | When |
|---|---|---|
| **DEFAULT** | `google/nano-banana-2` | Best text rendering + real logos. Gemini 3.1 Flash Image. ~$0.05/img. Use 99% of time. |
| Fallback A | `google/nano-banana-pro` | If banana-2 fails or wants slightly different aesthetic. ~$0.05/img. |
| Fallback B | `google/nano-banana` | Cheap legacy ($0.039), small/compressed output, only for quick iteration. |

**Replicate token:** set `REPLICATE_API_TOKEN` to your own key (replicate.com, account settings). Never paste a key into a skill file.

## Two prompt formulas (pick by use case)

| Variant | Use | Aspect | Style |
|---|---|---|---|
| **v2 minimal** | Diagrams, propostas técnicas, explainer infra | 16:9 | Black ink + accent colors only, white paper background |
| **v3 editorial** | IG Stories/Reels, posts, self-promo, cliente-facing pitch | 9:16 | Mixed-media: ink + watercolor wash + filled colors + scene context |

Use v3 when the user says "história", "story", "post", "pra postar", "promover", "social". Use v2 when "diagrama", "explicar arquitetura", "técnico".

Both follow: `STYLE_PREFIX + SCENE + STYLE_SUFFIX`

### STYLE_PREFIX · v2 minimal (diagrams)

```
Hand-drawn ink illustration on warm off-white paper background, sketchy line-art with confident black ink strokes, hand-lettered marker typography. Color palette: black ink line-work + bold accent colors used selectively (warm orange #E97A4F as primary accent, plus muted teal #4A9B95 and warm yellow #F5C04A for secondary highlights). Use REAL recognizable brand logos with their official brand colors when shown (Telegram cyan paper-plane, WhatsApp green speech-bubble, Gmail red-white-blue M envelope, Slack four-color hashtag, Discord purple game-controller, Meta blue infinity, Notion black N, Google calendar blue grid, ElevenLabs black wave, Stripe purple, Anthropic orange Claude). Logos must be drawn loose and sketchy but unmistakable. Layout: clean composition, generous white space, hand-drawn arrows in orange connecting elements, casual hand-lettered all-caps labels.
```

### STYLE_PREFIX · v3 editorial (stories/posts)

```
Hand-drawn editorial illustration in mixed-media style: confident black ink line-work + watercolor wash backgrounds + colored marker fills. Style reference: New York Times explainer illustration, Christoph Niemann, modern visual essay. Colors: warm paper texture base #FAF6EE, with VIBRANT filled regions in warm orange #E97A4F, muted teal #4A9B95, warm yellow #F5C04A, soft coral #F0876B, dusty blue #6B9BD2, sage green #8AB97F. Color is APPLIED LIBERALLY across backgrounds, character clothes, object fills · not just accent dots. Real recognizable brand logos with their official brand colors when shown (Telegram cyan paper-plane, WhatsApp green speech-bubble, Gmail red-white-blue M envelope, Slack four-color hashtag, Discord purple, Meta blue infinity, Notion black N, Google calendar blue grid, ElevenLabs black wave, Stripe purple, Anthropic orange Claude orb, GitHub black octocat, Cursor black C). Hand-lettered marker typography. Setting: include scene context (a room, a desk, a city skyline, a workshop, etc) · not floating elements on white. Paper texture visible behind everything. Generous orange marker arrows connecting beats.
```

### SCENE (variable, the user-specific part)

Describe in plain English what's in the picture. Be explicit about:
- **What's where**: "Left side: X. Center: Y. Right side: Z."
- **Labels**: every important element gets a hand-lettered label in quotes
- **Arrows**: name them ("arrow labeled 'steve update' in orange marker")
- **Logos by brand name + colored description**: `"WhatsApp green speech-bubble"`, `"Gmail multicolor envelope"`. Not just `"WhatsApp logo"`.
- **Mascot/character**: describe accessories ("captain hat", "magnifying glass", "coffee cup") so each scene's character looks consistent
- **Caption** at bottom in 1-2 lines, with which words to highlight in orange/teal

### STYLE_SUFFIX · v2 (16:9)

```
Aspect ratio 16:9. Style reference: whiteboard explainer drawn by a senior designer, like a Pixar storyboard or Tim Urban Wait But Why illustration. Crisp readable text, sketchy but professional.
```

### STYLE_SUFFIX · v3 (9:16 story)

```
Aspect ratio 9:16 (vertical Instagram Story / Reels format). Style reference: Christoph Niemann + Maira Kalman + Tim Urban illustrated essay. Crisp readable hand-lettered text. Story format: clear top headline, central illustration, bottom callout/CTA. Designed for social media share · bold enough to read on phone, warm enough to feel human.
```

## Brand logo dictionary

Use these exact descriptions when including logos so model picks the right brand colors:

| Brand | Description |
|---|---|
| Telegram | "cyan paper-plane logo on white" |
| WhatsApp | "green speech-bubble with phone" |
| Gmail | "red-white-blue M envelope" |
| Slack | "four-color hashtag (red, yellow, green, blue petals)" |
| Discord | "purple game-controller mascot" |
| Meta | "blue infinity / mobius loop" |
| Notion | "black-and-white N letter" |
| Google Calendar | "blue grid with red 31" |
| ElevenLabs | "black audio wave on white" |
| Stripe | "purple S monogram" |
| Anthropic / Claude | "warm orange Claude orb" |
| OpenAI / ChatGPT | "black knot / green tile" |
| GitHub | "black octocat" |
| Linear | "purple stylized L" |
| Cursor | "black C cursor" |

## Generation scripts

Two scripts (both support optional reference image as 3rd arg):

```bash
# v2 minimal · 16:9 diagram
bash ~/.claude/skills/sketch-illustration/gen.sh <slug> "<scene>" [ref_url]

# v3 editorial · 9:16 story / post
bash ~/.claude/skills/sketch-illustration/gen-story.sh <slug> "<scene>" [ref_url]

# Output: ~/code/your-reports-repo/public/ativos/sketch-tests/<slug>.png
```

Env overrides: `MODEL=google/nano-banana-pro`, `OUT_DIR=/some/path`, `TOKEN=r8_...`, `ASPECT=1:1` (gen.sh only).

## Reference images (image_input)

Nano Banana 2 accepts up to 14 reference images via `image_input` array. Pass URL(s) as 3rd arg to inject into payload. Use cases:

- **Face consistency** · pass photo of person; model preserves face/features in generated scene
- **Style transfer** · pass moodboard image; model imitates aesthetic
- **Brand consistency** · pass logo/character ref; model includes it accurately

### Canonical reference packs (the user project)

| Path | URL | Purpose |
|---|---|---|
| `public/refs/subject/01-*.jpg` to `10-*.jpg` | `https://your-host.example.com/refs/subject/<file>` | the user face/posture pack (10 photos for personal posts) |
| `public/refs/claude-code/01-canonical-orange.png` | `https://your-host.example.com/refs/claude-code/01-canonical-orange.png` | Claude Code character (terracotta orange outfit, tablet glow) |

Auto-passes middleware whitelist · `.jpg/.png/.webp` extensions go through without auth.

After adding new refs:
```bash
git add public/refs/subject/
git commit -m "feat(refs): add reference photos"
git push
ssh user@your-server "cd /srv/your-app && git pull && pm2 restart your-app"
curl -I https://your-host.example.com/refs/subject/01-portrait-frontal.jpg  # verify 200
```

### Multi-ref example

```bash
# Edit gen.sh manually for multi-ref OR call API directly
PROMPT="the user in a Lamborghini cinematic 9:16, Claude Code character beside him..."
subject="https://your-host.example.com/refs/subject/01-portrait-frontal.jpg"
CLAUDE="https://your-host.example.com/refs/claude-code/01-canonical-orange.png"
PAYLOAD=$(jq -n --arg p "$PROMPT" --arg j "$subject" --arg c "$CLAUDE" \
  '{input: {prompt: $p, aspect_ratio: "9:16", image_input: [$j, $c]}}')
# ... curl POST as usual
```

## Rate limits (Replicate)

- **<$5 saldo** = 6 req/min, **burst 1** → roda sequencial com `sleep 12` entre calls.
- **$5+ saldo** = 600 req/min, burst 60 → pode paralelizar 5+ simultâneo com `&` + `wait`.
- Quando der "Request was throttled", esperar ~10s e retentar.

## Workflow recommended

1. **Definir conceitos**: liste 3-5 cenas que cobrem a história. Cada cena = 1 sketch.
2. **Escrever SCENE de cada uma**: 4-8 linhas descritivas, com labels e logos explícitos.
3. **Gerar v1 de uma só** (validar estilo). Se bom → seguir.
4. **Gerar restante**: paralelo se saldo $5+, senão sequencial com `sleep 12`.
5. **Inspecionar com Read tool** (PNG renderiza no chat).
6. **Iterar** se label errado / logo errado / composição confusa: ajustar SCENE, regenerar.

## Common pitfalls (from real runs)

| Issue | Fix |
|---|---|
| Logo errado / genérico | Adicionar cor + forma na descrição: `"Gmail red-white-blue M envelope"` em vez de `"Gmail logo"` |
| Label embaralhado | Pôr o texto entre aspas: `labeled "STEVE"` em vez de `labeled STEVE` |
| Composição cheia demais | Cortar elementos. Máx 7-9 itens nomeados por sketch. |
| Tenant names errados em sketch multi-tenant | Modelo às vezes copia primeiro nome em todos. Mitigação: enfatizar diferença `"three different VPS boxes labeled 'subject', 'person-two', 'ADRIANO' (each a different name)"` |
| Cor monocromática (só preto+laranja) | Adicionar 2-3 logos coloridos no SCENE pra forçar paleta |
| Texto muito pequeno / ilegível | Reduzir nº de elementos na cena, dar mais white space |

## Output destination

Default: `~/code/your-reports-repo/public/ativos/sketch-tests/`

For client use:
- Steve OS marketing → `~/code/Steve OS/steve-os-engine/app/public/diagramas/steve-os/sketches/`
- Propostas → `~/code/your-reports-repo/public/propostas/<cliente>/sketches/`
- Posts/social → `~/code/your-reports-repo/public/ativos/sketches/<topic>/`

After save, if for hub URL: middleware whitelist may need update (`PUBLIC_STATIC_PAGES`) and `pm2 restart your-app` after scp pra prod.

## Cost reference

| Volume | Cost (banana-2) |
|---|---|
| 1 image | $0.05 |
| 5-image set (Steve OS pitch) | $0.25 |
| 20-image landing page | $1.00 |
| 100-image campaign | $5.00 |

Cheap. Do batches without worrying.

## Examples (reference outputs)

- [wrapper-v2.png](../../../code/your-reports-repo/public/ativos/sketch-tests/wrapper-v2.png) · recreates "THE WRAPPER" reference 1:1 with real logos
- [steve-01-mascot.png](../../../code/your-reports-repo/public/ativos/sketch-tests/steve-01-mascot.png) · character + flood input + structured output
- [steve-02-engine-soul.png](../../../code/your-reports-repo/public/ativos/sketch-tests/steve-02-engine-soul.png) · two-container compare diagram with arrow
- [steve-04-lifecycle.png](../../../code/your-reports-repo/public/ativos/sketch-tests/steve-04-lifecycle.png) · circular 5-step loop
- [steve-05-resilience.png](../../../code/your-reports-repo/public/ativos/sketch-tests/steve-05-resilience.png) · lighthouse + monitored workers + recovery labels

## Voice triggers

- "criar ilustração estilo whiteboard / sketch / hand-drawn"
- "desenho explicativo"
- "diagrama tipo Tim Urban / Wait But Why / Pixar storyboard"
- "imagem como aquela do wrapper" / referência ao reference image
- "5 sketches pra explicar X"
- "ilustração pra pitch / proposta / landing"

When triggered, follow workflow above. Never call OpenAI image / Imagen / Flux for this style · model already validated, results compound.
