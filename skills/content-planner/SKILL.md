---
name: content-planner
description: Planejamento editorial e calendario de conteudo. Ativa quando pedir pra planejar conteudo da semana/mes, criar calendario editorial, definir pilares de conteudo, organizar pipeline de posts, ou estrategia de conteudo para redes sociais.
layer: bh
---

# Content Planner · Planejamento Editorial

Skill de estrategia e organizacao da pipeline de conteudo.

## Quando Ativar

- "planeja conteudo da semana/mes"
- "calendario editorial pra [perfil/projeto]"
- "pilares de conteudo pra [nicho]"
- "o que postar essa semana"
- "estrategia de conteudo pra [plataforma]"
- "pipeline de posts"

## Framework: Pilares de Conteudo

Todo perfil tem 3-5 pilares que se repetem ciclicamente:

```
PILAR 1: Educativo (40%)
→ Ensina algo pratico, acionavel
→ Formato ideal: carrossel, thread
→ Exemplo: "5 patterns de React que todo dev precisa"

PILAR 2: Autoridade (25%)
→ Mostra expertise, resultados, bastidores
→ Formato ideal: post unico, story
→ Exemplo: "Como escalamos de 0 a R$740k em 2024"

PILAR 3: Engajamento (20%)
→ Provoca debate, opiniao, controversia
→ Formato ideal: post texto, enquete
→ Exemplo: "Unpopular opinion: frameworks CSS sao perda de tempo"

PILAR 4: Conexao (15%)
→ Storytelling pessoal, vulnerabilidade, bastidores
→ Formato ideal: stories, carrossel narrativo
→ Exemplo: "O dia que quase desisti da empresa"
```

## Calendario Semanal (Template)

```
SEGUNDA:  🎓 Educativo (carrossel)
TERCA:    · descanso / repost / story
QUARTA:   🏆 Autoridade (post unico)
QUINTA:   · descanso / repost / story
SEXTA:    🔥 Engajamento (post provocativo)
SABADO:   · opcional / story
DOMINGO:  💬 Conexao (storytelling)
```

Frequencia recomendada: 3-4 posts/semana no feed + stories diarios.

## Output: Plano Semanal

```markdown
# Plano de Conteudo · Semana [DD/MM - DD/MM]

## Objetivo da Semana
[1 frase: o que essa semana busca alcançar]

## Posts Programados

### Segunda · 🎓 Educativo
- **Tema:** [tema]
- **Formato:** Carrossel (6 slides)
- **Angulo:** [angulo do research]
- **Hook:** "[frase]"
- **Status:** [ ] Pesquisa → [ ] Copy → [ ] Design → [ ] Aprovacao → [ ] Postado

### Quarta · 🏆 Autoridade
- **Tema:** [tema]
- **Formato:** Post unico com imagem
- **Angulo:** [angulo]
- **Hook:** "[frase]"
- **Status:** [ ] Pesquisa → [ ] Copy → [ ] Design → [ ] Aprovacao → [ ] Postado

### Sexta · 🔥 Engajamento
- **Tema:** [tema]
- **Formato:** Post texto + enquete nos stories
- **Angulo:** [angulo]
- **Hook:** "[frase]"
- **Status:** [ ] Pesquisa → [ ] Copy → [ ] Design → [ ] Aprovacao → [ ] Postado

## Metricas a Acompanhar
- Saves (meta: X por post)
- Shares (meta: X por post)
- Novos followers (meta: +X na semana)
- Engajamento medio (meta: X%)
```

## Pipeline de Producao

```
1. PLANNER define tema + angulo + formato
      ↓
2. RESEARCHER pesquisa profunda do tema
      ↓
3. COPYWRITER escreve copy otimizado
      ↓
4. DESIGNER cria visual / template
      ↓
5. APROVACAO (Telegram ou UI)
      ↓
6. PUBLICACAO (automatica ou agendada)
      ↓
7. METRICAS (48h depois, analisar performance)
```

## Estrategia de Hashtags

```
TIER 1 (3-4): Alto volume, alta competicao
→ #programacao #developer #tech

TIER 2 (4-5): Volume medio, competicao media
→ #reactjs #typescript #webdev

TIER 3 (3-4): Baixo volume, nicho especifico
→ #nextjs14 #drizzleorm #tailwindcss

TOTAL: 10-15 hashtags por post
Rotacionar: nao usar as mesmas em todo post
```

## Regras de Repost

- Post com +500 saves → repostar em 30 dias (reformulado)
- Post com alto share → criar versao 2 aprofundada
- Post com baixo engajamento → analisar porque e ajustar angulo
- Nunca repostar identico · sempre iterar

## Integracoes

- **content-researcher** → pesquisa de cada tema do plano
- **copywriter** → escrita do conteudo
- **carousel-designer** → design visual
- **carousel-manager.ts** → automacao no Hub
- **cron.ts** → agendamento Mon/Wed/Fri
- **Notion** → armazenar plano editorial (opcional)
