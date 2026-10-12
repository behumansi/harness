---
name: post-writer
description: Escritor de posts completos para redes sociais. Ativa quando pedir pra escrever um post, criar conteudo pronto pra publicar, gerar carrossel completo (texto + estrutura), ou produzir thread. Orquestra research + copy + estrutura em um output final publicavel.
layer: bh
---

# Post Writer · Producao de Conteudo Final

Skill orquestrador que produz conteudo pronto pra publicar. Combina pesquisa, copy e estrutura.

## Quando Ativar

- "escreve um post sobre [tema]"
- "cria um carrossel sobre [tema]"
- "faz uma thread sobre [tema]"
- "conteudo pronto pra postar sobre [tema]"
- "post pra Instagram/LinkedIn/X sobre [tema]"
- Quando o usuario quer output final, nao etapas intermediarias

## Workflow Automatico

```
INPUT: Tema + Plataforma (opcional)
         ↓
STEP 1: Pesquisa rapida (angulo + publico + gap)
         ↓
STEP 2: Copy (hook + corpo + CTA)
         ↓
STEP 3: Estrutura (slides / paragrafos / tweets)
         ↓
OUTPUT: Conteudo pronto + caption + hashtags
```

## Output por Formato

### Carrossel Instagram (6-8 slides)

```markdown
# Carrossel: [Titulo]

## Slide 1 (Cover)
**Titulo:** [max 8 palavras, impactante]
**Subtitulo:** [1 linha complementar]

## Slide 2
**Titulo:** [conceito 1]
**Corpo:** [3-5 linhas]
**Emoji:** [1 relevante]
**Codigo:** (se aplicavel)
```typescript
// exemplo de codigo
```

## Slide 3
**Titulo:** [conceito 2]
**Corpo:** [3-5 linhas]
**Emoji:** [1 relevante]

## Slide 4
**Titulo:** [conceito 3]
**Corpo:** [3-5 linhas]
**Emoji:** [1 relevante]

## Slide 5
**Titulo:** [conceito 4]
**Corpo:** [3-5 linhas]
**Emoji:** [1 relevante]

## Slide 6 (CTA)
**Titulo:** [frase motivacional]
**CTA:** [acao clara: salva, compartilha, segue]
**Handle:** @[handle]

---

## Caption
[Hook forte · 1a linha que aparece no feed]

[Paragrafo 1 · expande o hook, gera curiosidade]

[Paragrafo 2 · entrega valor, contexto]

[CTA · acao clara]

.
.
.
#hashtag1 #hashtag2 #hashtag3 #hashtag4 #hashtag5
#hashtag6 #hashtag7 #hashtag8 #hashtag9 #hashtag10
```

### Post LinkedIn

```markdown
# Post LinkedIn: [Tema]

[Hook · 1a linha visivel no feed, max 150 chars]

[Corpo · 3-5 paragrafos curtos, 1-2 linhas cada]

[Dado ou exemplo concreto]

[Reflexao ou provocacao]

[CTA · pergunta aberta que gera comentarios]

---
Hashtags: #tag1 #tag2 #tag3 (max 5 no LinkedIn)
```

### Thread X/Twitter

```markdown
# Thread: [Tema]

## Tweet 1 (Hook)
[Frase impactante, auto-suficiente]

🧵 Thread:

## Tweet 2
2/ [Ponto 1 com dado/exemplo]

## Tweet 3
3/ [Ponto 2 com dado/exemplo]

## Tweet 4
4/ [Ponto 3 com dado/exemplo]

## Tweet 5
5/ [Ponto 4 com dado/exemplo]

## Tweet 6 (CTA)
6/ Resumindo:
- [bullet 1]
- [bullet 2]
- [bullet 3]

Se curtiu, RT o tweet 1 🔄
Segue pra mais threads assim 🔔
```

## Regras de Formatação

- **NUNCA usar travessão (·)** em nenhum texto, slide, caption ou thread. Substituir por ponto final, vírgula, ou reticências. Ninguém usa travessão em redes sociais.
- Frases curtas e diretas. Quebrar frases longas em duas.

## Regras de Qualidade

### Hook (Slide 1 / 1a linha)
- Para o scroll em 2 segundos
- Especifico (numeros, dados)
- Emocao (curiosidade, medo, ambicao)
- Max 8 palavras no titulo do carrossel

### Corpo (Slides 2-5 / Paragrafos)
- 1 ideia por slide/paragrafo
- Linguagem simples, sem jargao
- Exemplos concretos > teoria abstrata
- Codigo curto e funcional (se tech)

### CTA (Ultimo slide / Final)
- Acao unica e clara
- Razao pra agir ("salva pra consultar depois")
- Sem pedir like/follow genericamente

### Caption
- 1a linha = hook (aparece no feed)
- Corpo complementa, nao repete os slides
- Hashtags separadas por linha em branco
- 10-15 hashtags (mix de volumes)

## Adaptacao por Tom

O tom vem do briefing ou do contexto:

| Tom | Quando usar | Exemplo de hook |
|-----|-------------|-----------------|
| **Educativo** | Tutorial, dica pratica | "3 patterns que cortam 40% dos bugs" |
| **Provocativo** | Opiniao controversa | "Voce ta usando TypeScript errado" |
| **Storytelling** | Experiencia pessoal | "O dia que perdi R$50k por um bug" |
| **Autoritario** | Resultado, case | "Escalamos de 0 a 740k. Foi assim:" |
| **Curioso** | Descoberta, novidade | "Achei isso escondido no React 19" |

## APIs Disponiveis

- **Perplexity Sonar** (pesquisa): `pplx-SUA_CHAVE_AQUI` · POST https://api.perplexity.ai/chat/completions
- **Freepik Mystic** (imagens): `$FREEPIK_API_KEY` · POST https://api.freepik.com/v1/ai/mystic

## Integracoes

- **Perplexity Sonar** → pesquisa com dados atualizados antes de escrever
- **content-researcher** → pesquisa automatica antes de escrever
- **copywriter** → frameworks de copy (AIDA, PAS, BAB)
- **carousel-designer** → visual dos slides
- **content-planner** → respeitar o calendario editorial
- **carousel-ai.ts** → pode alimentar o prompt do Hub
- **instagram_create_carousel** → tool do AI Router pra gerar direto
- **Freepik Mystic** → backgrounds AI para slides (via --ai-bg)

## Uso com Hub (carousel-ai.ts)

Quando gerar carrossel via Hub, o output desse skill pode ser passado como contexto:

```
"Gera um carrossel com esse briefing:
[output do post-writer colado aqui]"
```

Isso enriquece o prompt do carousel-ai.ts com copy profissional em vez de depender so da IA generica.
