---
name: architecture-diagram
description: Build editable architecture diagrams for client/product explanations. Use when the user asks to create a diagram of "how X works", explain a product to a client, show system architecture, or visualize how Hub/agents/integrations connect. Output: tldraw editor with custom shapes (real Iconify icons + Poppins + dark canvas) · visual editing for the user + JSON config for programmatic edits. Hosted at your-host.example.com/diagramas/<client>/<slug> (live, shareable URL).
layer: bh
---

# Architecture Diagram · editable, hybrid (visual + AI)

> Padrão validado em 05/05/2026 após múltiplas iterações. the user rejeitou: emojis, HTML estático puro, Excalidraw nativo (sketchy), tldraw default (geo retângulo feio), Mermaid→Excalidraw (bugs de layout). Aprovou: **tldraw com custom shapes renderizando HTML real**.

---

## Filosofia

Diagramas pra **explicar produto pra cliente** ou **mostrar em reunião**. Precisam de:

1. **Visual editável** · the user arrasta caixas, edita texto inline, conecta setas no canvas
2. **Programaticamente editável** · Claude lê/edita o JSON (`.tldr`) entre sessões
3. **Estética Stripe/Linear** · dark, polido, ícones reais, não sketchy
4. **Reutilizável** · mesmo template, swap de cliente via config
5. **URL pública compartilhável** · `your-host.example.com/diagramas/<cliente>/<slug>`

**Não use:** emojis, HTML estático sem editor, ASCII art, Mermaid puro renderizado.

---

## REGRA INEGOCIÁVEL · preservar edits of the user

the user edita o canvas visualmente (drag, texto inline, setas). Esses edits são **sagrados**.

1. **Nunca bumpa `persistenceKey`**. Bump = wipe IndexedDB = perde tudo.
2. **Seed sempre additivo**. Use helper `make()` que checa `editor.getShape(id)` antes de criar. Skip se existe.
3. **Arrows com ID determinístico**: `createShapeId(\`arrow-${from}-${to}\`)`. Nunca random · duplicam a cada re-seed.
4. **Mudanças visuais grandes** = edita o JSON snapshot direto, não o seed. Seed é fallback inicial apenas.
5. **Só deleta shape quando the user pedir explícito**. Adiciona à vontade.

Validado 2026-05-06 após eu wipar edits dele bumpando key. Não repete.

---

## Stack

| Camada | Tecnologia | Por quê |
|--------|------------|---------|
| **Editor** | [tldraw](https://tldraw.dev) v3+ | Drag-edit visual, store API, persistência built-in |
| **Custom shapes** | `ShapeUtil` + `HTMLContainer` | Renderiza HTML real dentro do canvas (não geo simples) |
| **Ícones** | [Iconify](https://icon-sets.iconify.design) (`iconify-icon` web component) | 200k+ ícones reais, logos de marca |
| **Fonte** | Poppins (300-700) + JetBrains Mono | Padrão the user (Bricolage/Instrument Serif são banidas) |
| **Cores** | Dark canvas `#0a0a0a`, brand accents por categoria | Match HTML reports of the user |

---

## Estrutura de Dados (Config JSON)

```ts
// configs.ts
export type ArchConfig = {
  meta: { eyebrow, title, subtitle, footer };
  layout?: 'single-channel' | 'dual-channel';
  frame: { label, icon, color };  // o "servidor" container
  nodes: Record<string, {
    title: string;     // "Layer 1 · Intent Filter"
    sub?: string;      // "classifica intenção do pedido"
    meta?: string;     // "Anthropic · Haiku 4.5" · provider · modelo
    icon: string;      // Iconify name: "logos:whatsapp-icon", "simple-icons:anthropic"
    color: string;     // hex · controla borda + ícone + meta line
  }>;
  edges: Record<string, { label: string }>;
};
```

### Slots padrão de node (topologia fixa)
- `user` · quem inicia (cliente, the user, etc)
- `channel1` · canal de entrada esquerdo (WhatsApp, ou hidden em single-channel)
- `channel2` · canal de entrada direito (Telegram, Email, Form)
- `app` · aplicação central (Hub, Studio App, etc)
- `filter` · Layer 1 (LLM filtro de intenção)
- `agent` · Layer 2 (Claude Code / agent que executa)
- `repo` · destino (GitHub, DB, S3)

### Layer 1 / Layer 2 (regra inegociável)
Sempre que tiver pipeline LLM, **deixa explícito**:
- `title`: "Layer N · <nome do role>" (ex: "Layer 1 · Intent Filter")
- `sub`: o que ele FAZ em linguagem humana
- `meta`: **provider · modelo** (ex: "Anthropic · Haiku 4.5", "OpenRouter · Sonnet 4.6")

Cliente precisa saber: qual LLM, qual modelo, o que ele faz. Pra se situar.

---

## Custom Shape Pattern

```tsx
// ArchNodeShape.tsx
export class ArchNodeShapeUtil extends ShapeUtil<ArchNodeShape> {
  static type = 'arch-node'
  static props = { w, h, title, subtitle, meta, icon, color, variant }

  component(shape) {
    return (
      <HTMLContainer style={{
        background: '#1a1a1a',
        border: `1.5px solid ${color}`,
        borderRadius: 14,
        padding: '16px 20px',
        fontFamily: "'Poppins', sans-serif",
        // ... ver src/ArchNodeShape.tsx no tldraw-diagrams
      }}>
        <iconify-icon icon={icon} width="22" style={{ color }} />
        <div>
          <div className="title">{title}</div>
          <div className="sub">{subtitle}</div>
          {meta && <div className="meta" style={{ color }}>{meta}</div>}
        </div>
      </HTMLContainer>
    )
  }
}
```

Variantes:
- `default` · node normal, fundo `#1a1a1a`, borda colorida sólida
- `deep` · usado pra camadas internas do agente, gradient `#1a1428 → #14101f` pra dar peso
- `frame` · container do servidor, borda tracejada amarela, label superior em mono uppercase

---

## Topologia (Single vs Dual Channel)

**Dual** (default · the user usa Whats + Telegram):
```
        Eu
       ╱   ╲
   Whats   Telegram
       ╲   ╱
       App
        ↓
    L1 Filter
        ↓
    L2 Agent
        ↓
     GitHub
```

**Single** (cliente usa só 1 canal · the client com só Telegram):
- Esconde `channel1`
- Centraliza `channel2` direto abaixo do user
- Setas user→channel2 e channel2→app ficam verticais retas

---

## Ícones Iconify recomendados

| Categoria | Coleção | Exemplos |
|-----------|---------|----------|
| Logos de marca | `logos:` | `logos:whatsapp-icon`, `logos:telegram`, `logos:google-gmail` |
| Anthropic / OpenAI | `simple-icons:` | `simple-icons:anthropic`, `simple-icons:openai` |
| Genérico duotone | `solar:` | `solar:user-rounded-bold-duotone`, `solar:bolt-bold-duotone`, `solar:filter-bold-duotone` |
| Material Design | `mdi:` | `mdi:server`, `mdi:github`, `mdi:database` |

Lista completa: https://icon-sets.iconify.design/

---

## Hosting + Save/Push workflow (DEFAULT)

**Standalone (dev/atual):** `./tldraw-diagrams/` · Vite + React, `npm run dev` em :5173.
URL: `http://localhost:5173/?c=<cliente>`

### Workflow oficial · Save/Push

Overlay top-right tem 3 botões:

- **💾 Save** · POST `/api/save-snapshot` → escreve `public/snapshots/<key>.tldr.json` no filesystem (local)
- **🚀 Save + Push** · Save + `git add + commit + push` (sync automático pra VPS via cron `repo-autosync pull` 5min ou imediato se VPS já é remote)
- **📂 Load** · carrega `.tldr.json` arbitrário do disco

**Mount auto-load:** ao abrir página, app tenta `fetch('/snapshots/<key>.tldr.json')` antes de seedar. Se existir, carrega snapshot. Se não, seed additivo.

### Vite plugin que faz isso

`vite-plugins/snapshot.ts` · middleware Vite que aceita POST e:
1. Sanitiza key (`/[a-z0-9_-]/i`)
2. Escreve em `public/snapshots/<key>.tldr.json`
3. Mirror em `dist/snapshots/<key>.tldr.json` se `dist/` existe (preview server)
4. Se `commit: true`, roda `git add + commit -m "diagram: update <key>" --no-verify + push`
5. Retorna `{ ok, file, info }` pra UI exibir status

Plugin registrado tanto em `configureServer` (dev) quanto `configurePreviewServer` (prod via `vite preview`).

### Sem rebuild necessário

Snapshot é arquivo estático servido por `/public/`. Atualiza JSON → próxima carregamento da página loads novo snapshot. Não precisa rebuildar React app · só rebuildar quando mexer em código (shapes, layout, configs.ts).

**Produção (futuro):** `your-host.example.com/diagramas/<cliente>/<slug>` · embed no your hub, persistência SQLite, auto-save real-time, URL pública compartilhável.

---

## Quando usar HTML estático vs Editor

| Caso | Solução |
|------|---------|
| Relatório / report estático com diagrama | HTML config-based (`public/ativos/arquitetura-template/`) |
| Cliente vai ver diagrama 1x e the user não precisa editar ao vivo | HTML config-based |
| Co-criação com cliente em call (ele aponta, the user move caixa) | tldraw editor |
| the user quer ajustar entre sessões + Claude também ajusta | tldraw editor |
| Diagrama que evolui com o produto | tldraw editor com persistência |

---

## Anti-padrões (não fazer)

❌ Emojis nos nodes (the user rejeitou explicitamente · usar Iconify)
❌ Bricolage Grotesque / Instrument Serif italic / Manrope (banidas globalmente · Poppins sempre)
❌ HTML puro sem editor pra diagramas que vão evoluir
❌ Excalidraw default (sketchy aesthetic não combina com Stripe-style)
❌ tldraw com `geo: 'rectangle'` (feio · usar custom shape)
❌ Mermaid→Excalidraw conversor (layout bugado, subgraphs sobrepõem)
❌ Esconder qual LLM/modelo está sendo usado em pipelines AI (cliente precisa saber)

---

## Workflow recomendado

1. **Cliente novo** → adiciona entrada em `configs.ts` (ou config JSON no Hub)
2. **Acessa URL** com `?c=<cliente>` → editor pré-populado
3. **the user ajusta visualmente** · drag, edit text, conecta setas
4. **Auto-save** persiste no DB (real-time)
5. **Compartilha URL** com cliente · read-only ou edit
6. **Claude edita JSON** entre sessões via DB ou file

---

## Referência de arquivos

- Skill: `~/.claude/skills/architecture-diagram/SKILL.md` (este arquivo)
- Editor standalone: `./tldraw-diagrams/`
- Custom shape: `./tldraw-diagrams/src/ArchNodeShape.tsx`
- Configs: `./tldraw-diagrams/src/configs.ts`
- HTML template (alternativa estática): `./diagrams/template/`
- Hub embed (futuro): `your app's diagrams page`