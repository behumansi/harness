---
name: copywriter
description: Copywriter profissional para conteudo digital. Ativa quando pedir pra escrever copy, legenda, headline, hook, CTA, caption de post, texto de carrossel, thread, ou qualquer texto persuasivo. Domina frameworks de copy (AIDA, PAS, BAB) e adapta tom por plataforma.
layer: bh
---

# Copywriter · Texto Persuasivo para Conteudo Digital

Skill de escrita estrategica para posts, carrosseis, legendas, threads e qualquer conteudo textual.

## Quando Ativar

- "escreve copy pra [tema]"
- "faz a legenda desse post"
- "headline pra carrossel sobre [tema]"
- "hook forte pra [tema]"
- "texto pro slide [N]"
- "thread sobre [tema]"
- Etapa 2 da pipeline de conteudo (apos research)

## Principios de Copy

### 1. Hook First (2 segundos pra parar o scroll)
```
RUIM: "Hoje vou falar sobre TypeScript"
BOM:  "Voce ta escrevendo TypeScript errado. E eu vou provar."
OTIMO: "90% dos devs nao sabem que TypeScript tem isso. Slide 3 vai te chocar."
```

### 2. Clareza > Criatividade
- Frase curta, vocabulario simples
- 1 ideia por frase, 1 conceito por slide
- Se precisa reler pra entender, reescrever

### 3. Especificidade Vende
```
VAGO:   "Melhore seu codigo"
ESPECIFICO: "3 patterns que cortam 40% dos bugs em React"
```

### 4. Emocao + Logica
- Hook com emocao (medo, curiosidade, ambicao)
- Corpo com logica (dados, exemplos, provas)
- CTA com urgencia (escassez, FOMO, beneficio imediato)

## Frameworks de Copy

### AIDA (Awareness → Interest → Desire → Action)
```
[A] Hook: Chama atencao com algo inesperado
[I] Problema: Aprofunda a dor/curiosidade
[D] Solucao: Mostra o caminho + prova social
[A] CTA: Acao clara e especifica
```

### PAS (Problem → Agitate → Solve)
```
[P] "Voce perde 2h/dia debugando TypeScript."
[A] "Enquanto isso, devs seniors escrevem codigo que roda de primeira."
[S] "Esses 5 patterns mudam o jogo. Salva esse post."
```

### BAB (Before → After → Bridge)
```
[B] Antes: "Codigo cheio de any, builds quebrando toda hora"
[A] Depois: "TypeScript strict, zero bugs em producao, deploy confiante"
[B] Ponte: "A diferenca sao esses 7 patterns que apliquei em 2 semanas"
```

### 4U (Useful, Urgent, Unique, Ultra-specific)
Pra headlines e hooks:
```
"7 atalhos de VS Code que economizam 1h por dia (e ninguem fala do #5)"
 ^Useful          ^Ultra-specific        ^Unique      ^Urgent(curiosidade)
```

## Formatos por Plataforma

### Instagram Carrossel
```
SLIDE 1 (COVER):
- Headline curta (max 8 palavras)
- Subtitulo opcional (1 linha)
- Visual > texto

SLIDES 2-6 (CONTEUDO):
- Titulo do slide (max 5 palavras)
- Corpo: 3-5 linhas max
- 1 emoji por slide (relevante, nao decorativo)
- Codigo: max 6 linhas, syntaxado

SLIDE FINAL (CTA):
- Acao clara: "Salva", "Compartilha", "Comenta"
- Reforco de valor: "Mais conteudo assim? Segue."
- @handle visivel

CAPTION:
- 1a linha = hook forte (aparece no feed)
- 2-3 paragrafos curtos
- Emojis estrategicos (nao spam)
- CTA no final
- 10-15 hashtags (mix de volume)
- Linha separadora antes das hashtags
```

### LinkedIn Post
```
HOOK (1a linha, aparece no feed):
- Frase provocativa ou dado surpreendente
- Max 150 caracteres

CORPO:
- Paragrafos de 1-2 linhas (respiro visual)
- Bullet points pra listas
- Storytelling > listicle
- 800-1200 caracteres ideal

CTA:
- Pergunta aberta (gera comentarios)
- "Concorda? Comenta sua experiencia"
```

### Twitter/X Thread
```
TWEET 1 (HOOK):
- Auto-suficiente (faz sentido sozinho)
- "Thread:" no final ou emoji 🧵

TWEETS 2-8 (CONTEUDO):
- 1 ponto por tweet
- Numeracao: "2/ Ponto X..."
- Dados + exemplos concretos

TWEET FINAL:
- Resumo em 1 frase
- CTA: "RT se curtiu" / "Segue pra mais"
- Link se relevante
```

## Tom de Voz por Contexto

| Contexto | Tom | Exemplo |
|----------|-----|---------|
| Tech/Dev | Direto, pratico | "Isso aqui resolve. Sem enrolacao." |
| Business | Confiante, autoritario | "O mercado mudou. Quem nao adaptar, fica pra tras." |
| Educativo | Didatico, paciente | "Vou explicar passo a passo. Comeca aqui:" |
| Storytelling | Pessoal, vulneravel | "Eu errei feio. E foi a melhor coisa que aconteceu." |
| Provocativo | Controverso, direto | "Unpopular opinion: voce nao precisa de faculdade pra isso." |

## Checklist de Qualidade

- [ ] Hook para o scroll em 2 segundos?
- [ ] Especifico (numeros, dados, exemplos)?
- [ ] 1 ideia por frase?
- [ ] Tom consistente do inicio ao fim?
- [ ] CTA claro e acionavel?
- [ ] Sem jargao desnecessario?
- [ ] Leu em voz alta e fluiu natural?
- [ ] Adaptado pra plataforma (IG vs LinkedIn vs X)?

## Integracoes

- **content-researcher** → recebe briefing com angulo, publico, tom
- **carousel-designer** → alimenta slides com texto otimizado
- **carousel-ai.ts** → prompt enriquecido com copy profissional
- **post-writer** → delegacao direta pra formatos especificos

## Regras de Formatação

- **NUNCA usar travessão (·)** em nenhum texto. Substituir por ponto final, vírgula, ou reticências. Ninguém usa travessão em redes sociais.
- Frases curtas e diretas. Quebrar frases longas em duas.

## Anti-Patterns

- Escrever generico ("conteudo de valor") → ser especifico e acionavel
- Hook fraco ("Hoje vou falar sobre...") → provocar, surpreender, chocar
- Texto longo demais no slide → max 5 linhas, editar ate doer
- CTA vago ("deixa seu like") → CTA com razao ("salva pra consultar depois")
- Emoji spam (🔥💯🚀 em cada frase) → 1 emoji estrategico por slide
- Copiar formato sem adaptar → cada plataforma tem regras proprias
