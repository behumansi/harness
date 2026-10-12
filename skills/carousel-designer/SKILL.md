---
name: carousel-designer
description: Designer de carrosseis para Instagram e redes sociais. Ativa quando pedir pra criar, melhorar ou reformular templates de carrossel, definir layout visual, escolher paleta de cores, tipografia, ou gerar HTML/CSS para slides. Domina design system, hierarquia visual e principios de UI para conteudo social.
layer: bh
---

# Carousel Designer · Design Visual de Carrosseis

Skill de design para carrosseis de Instagram e conteudo visual para redes sociais.

## Quando Ativar

- "cria um template de carrossel"
- "melhora o visual desse carrossel"
- "design pra slides sobre [tema]"
- "paleta de cores pra [nicho]"
- "reformula os templates de carrossel"
- Etapa 3 da pipeline de conteudo (apos copy)
- Qualquer tarefa visual envolvendo slides 1080x1350

## Specs Tecnicas

### Instagram Carrossel
| Propriedade | Valor |
|-------------|-------|
| **Resolucao** | 1080 x 1350 px (4:5) |
| **Formato** | PNG (qualidade) ou JPEG (otimizado) |
| **Max slides** | 10 (recomendado: 6-8) |
| **Safe zone** | 40px padding all sides |
| **Texto minimo** | 28px (legivel no celular) |
| **Rendering** | Playwright headless (HTML → PNG) |

### Hierarquia de Slides
```
SLIDE 1: COVER
├── Headline grande (48-72px, bold)
├── Subtitulo (24-32px, regular)
├── Visual dominante (pattern/gradient/imagem)
└── @handle discreto (16-20px, bottom)

SLIDES 2-N: CONTEUDO
├── Titulo do slide (36-48px, semibold)
├── Corpo (24-28px, regular, max 5 linhas)
├── Elemento visual (icone, code block, diagram)
├── Numero do slide (indicador de progresso)
└── @handle (bottom bar)

SLIDE FINAL: CTA
├── Headline motivacional (48px)
├── Acao principal (36px, destaque)
├── Elementos sociais (follow, save, share)
└── @handle + logo
```

## Principios de Design

### 1. Consistencia Visual
- Mesma paleta em TODOS os slides
- Tipografia consistente (max 2 fontes)
- Espacamento uniforme (padding, gaps)
- Elementos recorrentes (progress dots, handle bar)

### 2. Hierarquia Clara
```
NIVEL 1: Headline   → 48-72px, bold, cor primaria
NIVEL 2: Subtitulo  → 32-36px, medium, cor secundaria
NIVEL 3: Corpo      → 24-28px, regular, cor de texto
NIVEL 4: Metadata   → 16-20px, light, cor terciaria
```

### 3. Respiracao Visual
- Min 40px padding nas bordas
- Gaps generosos entre blocos (24-32px)
- Nunca encher o slide ate nao caber mais nada
- Espaco vazio e parte do design

### 4. Mobile-First
- Tudo testado em tela pequena (celular)
- Texto legivel sem zoom
- Contraste minimo 4.5:1 (WCAG AA)
- Elementos clicaveis nao precisam ser clicaveis (e imagem)

## Paletas por Nicho

### Tech/Dev
```css
--bg: #0a0a1a;
--surface: #12122a;
--primary: #f59e0b;     /* amber */
--secondary: #3b82f6;   /* blue */
--text: #e2e8f0;
--text-muted: #94a3b8;
--accent: #10b981;      /* green (code) */
--code-bg: #1e1e3a;
```

### Business/SaaS
```css
--bg: #ffffff;
--surface: #f8fafc;
--primary: #1e40af;     /* deep blue */
--secondary: #7c3aed;   /* purple */
--text: #0f172a;
--text-muted: #64748b;
--accent: #059669;      /* success green */
--code-bg: #f1f5f9;
```

### Creative/Lifestyle
```css
--bg: #fef7ed;
--surface: #ffffff;
--primary: #ea580c;     /* warm orange */
--secondary: #be185d;   /* pink */
--text: #1c1917;
--text-muted: #78716c;
--accent: #d97706;
--code-bg: #fff7ed;
```

### Minimal/Clean
```css
--bg: #fafafa;
--surface: #ffffff;
--primary: #18181b;     /* near black */
--secondary: #71717a;   /* zinc */
--text: #18181b;
--text-muted: #a1a1aa;
--accent: #2563eb;      /* blue accent */
--border: #e4e4e7;
```

### Dark Gradient
```css
--bg: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
--surface: rgba(255,255,255,0.05);
--primary: #c084fc;     /* purple */
--secondary: #38bdf8;   /* sky */
--text: #f1f5f9;
--text-muted: #94a3b8;
--accent: #34d399;
--glow: 0 0 40px rgba(192,132,252,0.3);
```

## Template HTML Structure

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap');

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      width: 1080px;
      height: 1350px;
      font-family: 'Inter', sans-serif;
      background: var(--bg);
      color: var(--text);
      overflow: hidden;
    }

    .slide {
      width: 100%;
      height: 100%;
      padding: 60px;
      display: flex;
      flex-direction: column;
      position: relative;
    }

    .slide-header { flex: 0 0 auto; }
    .slide-body { flex: 1; display: flex; flex-direction: column; justify-content: center; }
    .slide-footer {
      flex: 0 0 auto;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    h1 { font-size: 64px; font-weight: 800; line-height: 1.1; }
    h2 { font-size: 44px; font-weight: 700; line-height: 1.2; }
    p  { font-size: 28px; font-weight: 400; line-height: 1.6; color: var(--text-muted); }

    .code-block {
      background: var(--code-bg);
      border-radius: 16px;
      padding: 24px 32px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 22px;
      line-height: 1.7;
      margin-top: 24px;
      border: 1px solid rgba(255,255,255,0.1);
    }

    .progress-dots {
      display: flex;
      gap: 8px;
    }
    .dot {
      width: 10px; height: 10px;
      border-radius: 50%;
      background: var(--text-muted);
      opacity: 0.3;
    }
    .dot.active { opacity: 1; background: var(--primary); }

    .handle {
      font-size: 20px;
      color: var(--text-muted);
      font-weight: 500;
    }

    /* Visual elements */
    .badge {
      display: inline-block;
      padding: 8px 20px;
      border-radius: 100px;
      font-size: 18px;
      font-weight: 600;
      background: var(--primary);
      color: var(--bg);
    }

    .divider {
      width: 60px;
      height: 4px;
      background: var(--primary);
      border-radius: 2px;
      margin: 24px 0;
    }
  </style>
</head>
<body>
  <div class="slide">
    <div class="slide-header">
      <!-- badge, numero, etc -->
    </div>
    <div class="slide-body">
      <!-- conteudo principal -->
    </div>
    <div class="slide-footer">
      <div class="progress-dots">
        <div class="dot active"></div>
        <div class="dot"></div>
        <!-- ... -->
      </div>
      <div class="handle">@handle</div>
    </div>
  </div>
</body>
</html>
```

## Elementos Visuais

### Code Blocks (Tech)
- Font: JetBrains Mono 22px
- Syntax highlighting manual via `<span>` com cores
- Max 6-8 linhas
- Border radius 16px
- Background sutilmente diferente

### Icones/Emojis
- 1 emoji grande por slide (48-64px) como elemento visual
- Posicionar como destaque, nao decoracao
- Evitar emojis genericos (🔥💯) → usar especificos (🎯⚡🧩)

### Numeros/Stats
- Numero grande (80-120px) com cor primaria
- Label pequena abaixo (20px)
- Exemplo: "40%" + "menos bugs"

### Diagramas Simples
- Setas (→) com CSS
- Boxes com border
- Flexbox layout
- Nada complexo (lembra: 1080px, nao whiteboard infinito)

## Checklist de Design

- [ ] Resolucao 1080x1350 (4:5)?
- [ ] Safe zone respeitada (40px+ padding)?
- [ ] Texto legivel no celular (min 24px corpo)?
- [ ] Contraste adequado (4.5:1 minimo)?
- [ ] Max 2 fontes?
- [ ] Paleta consistente em todos os slides?
- [ ] Progress dots / indicador de slide?
- [ ] @handle presente em todos os slides?
- [ ] Slide 1 funciona como thumbnail (atrativo)?
- [ ] Ultimo slide tem CTA claro?

## APIs de Imagem Disponiveis

### Freepik Mystic (AI Image Generation)
- **Key:** $FREEPIK_API_KEY
- **Endpoint:** POST https://api.freepik.com/v1/ai/mystic
- **Header:** x-freepik-api-key: $FREEPIK_API_KEY
- **Flow:** POST (prompt + resolution) → task_id → poll GET → result_url → download
- **Uso ideal:** Backgrounds abstratos, texturas, ilustracoes para slides
- **Exemplo de prompt:** "Abstract dark tech background with subtle grid pattern and amber glow, 1080x1350"

### Workflow: Slide com Background AI
1. Gerar background via Freepik Mystic (1080x1350)
2. Download da imagem
3. Usar como `background-image` no CSS do slide
4. Overlay escuro semi-transparente + texto por cima (HTML/CSS)
5. Screenshot via Playwright = PNG final

## Integracoes

- **copywriter** → recebe texto otimizado pra cada slide
- **carousel-renderer.ts** → renderiza HTML → PNG via Playwright
- **carousel-templates.ts** → templates existentes no Hub (tech-dark, gradient-modern, code-focus)
- **content-researcher** → contexto visual do nicho (cores, estetica)
- **Freepik Mystic** → backgrounds AI gerados sob demanda
- **Perplexity Sonar** → referencia visual do nicho (via pesquisa)

## Anti-Patterns

- Texto demais no slide → se tem mais de 5 linhas, dividir em 2 slides
- Fonte pequena → min 24px SEMPRE
- Cores inconsistentes entre slides → usar CSS vars
- Ignorar mobile → carrossel e consumido 99% no celular
- Template generico (Canva-like) → design distinto, com personalidade
- Decoracao sem funcao → cada elemento deve ter proposito
