---
name: content-researcher
description: Pesquisa aprofundada de temas para conteudo digital. Ativa quando pedir pesquisa de mercado, analise de nicho, tendencias, benchmarking de concorrentes, ou briefing de tema para posts/carrosseis. Usa web search, analise de dados e frameworks estrategicos.
layer: bh
---

# Content Researcher · Pesquisa Estrategica de Conteudo

Skill de pesquisa profunda para alimentar a pipeline de conteudo (posts, carrosseis, videos, threads).

## Quando Ativar

- "pesquisa sobre [tema]" / "pesquisa de conteudo"
- "analisa esse nicho" / "benchmark de concorrentes"
- "o que ta bombando sobre [tema]"
- "tendencias de [area]"
- "briefing pra post sobre [tema]"
- Antes de gerar qualquer carrossel ou post (etapa 1 da pipeline)

## Workflow de Pesquisa

```
1. DEFINIR ESCOPO
   → Tema, nicho, publico-alvo, plataforma (IG, LinkedIn, X, TikTok)

2. PESQUISA MACRO (WebSearch)
   → Tendencias globais do tema (ultimos 30 dias)
   → Top creators/autoridades no assunto
   → Conteudo viral recente (formato, hook, engajamento)

3. ANALISE DE ANGULO
   → 5+ angulos possiveis pro tema
   → Score cada angulo: originalidade, relevancia, viralidade
   → Escolher top 3

4. BENCHMARK DE CONCORRENTES
   → Como top 5 perfis do nicho abordam o tema
   → Formatos que performam (carrossel vs reel vs static)
   → Gaps de conteudo (o que ninguem ta falando)

5. FRAMEWORK DE OUTPUT
   → Briefing estruturado pra copywriter/designer
```

## Output Esperado: Briefing de Pesquisa

```markdown
# Briefing: [Tema]

## Contexto de Mercado
- Tendencia atual: [resumo]
- Volume de busca: [alto/medio/baixo]
- Saturacao no nicho: [alta/media/baixa]

## Publico-Alvo
- Persona: [descricao]
- Dor principal: [problema que resolve]
- Nivel de consciencia: [nao sabe / sabe mas nao resolve / buscando solucao]

## Angulos Recomendados
1. **[Angulo 1]** · Score: 9/10
   - Hook: "[frase que puxa atencao]"
   - Porque funciona: [explicacao]
2. **[Angulo 2]** · Score: 8/10
   ...
3. **[Angulo 3]** · Score: 7/10
   ...

## Benchmark
| Perfil | Formato | Hook | Engajamento | Gap |
|--------|---------|------|-------------|-----|
| @perfil1 | carrossel | "..." | alto | nao fala de X |

## Conteudo Viral Recente
- [Link/Referencia 1] · formato: carrossel, hook: "...", saves: alto
- [Link/Referencia 2] · formato: reel, hook: "...", shares: alto

## Palavras-Chave / Hashtags
- Primarias: #tag1 #tag2 #tag3
- Secundarias: #tag4 #tag5
- Long-tail: #tagEspecifica1 #tagEspecifica2

## Recomendacao Final
- Formato ideal: [carrossel / reel / post / thread]
- Angulo escolhido: [N]
- Tom: [educativo / provocativo / storytelling / tutorial]
- CTA sugerido: "[acao]"
```

## Frameworks de Analise

### Matriz de Angulo (HROV)
| Criterio | Peso | Descricao |
|----------|------|-----------|
| **H**ook Power | 30% | Forca do gancho inicial (para scroll) |
| **R**elevancia | 25% | Conexao com dor/desejo do publico |
| **O**riginalidade | 25% | Diferenciacao do que ja existe |
| **V**iralidade | 20% | Potencial de compartilhamento |

### Nivel de Consciencia (Eugene Schwartz)
1. **Unaware** · nao sabe que tem o problema
2. **Problem Aware** · sabe o problema, nao a solucao
3. **Solution Aware** · sabe que existe solucao, nao qual
4. **Product Aware** · conhece a solucao, nao decidiu
5. **Most Aware** · so precisa do empurrao

→ Ajustar linguagem e CTA conforme o nivel.

### Content Gap Analysis
1. Listar top 10 posts do nicho sobre o tema
2. Mapear angulos cobertos
3. Identificar gaps (o que NINGUEM ta falando)
4. Priorizar gaps com alta demanda

## APIs Disponiveis

### Perplexity Sonar (PREFERIR para pesquisa)
- **Key:** pplx-SUA_CHAVE_AQUI
- **Endpoint:** POST https://api.perplexity.ai/chat/completions
- **Header:** Authorization: Bearer {key}
- **Models:** `sonar` (rapido + web search), `sonar-pro` (profundo)
- **Vantagem:** Retorna fontes, dados atualizados, citations
- **Usar via Bash:**
```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY_CHAVE_AQUI" \
  -H "Content-Type: application/json" \
  -d '{"model":"sonar","messages":[{"role":"user","content":"QUERY"}],"web_search_options":{"search_context_size":"high"}}'
```

### Freepik Mystic (Image Generation)
- **Key:** $FREEPIK_API_KEY
- **Endpoint:** POST https://api.freepik.com/v1/ai/mystic
- **Header:** x-freepik-api-key: {key}
- **Flow:** POST → task_id → poll → download result_url

## Integracoes

- **Perplexity Sonar** → pesquisa profunda com dados atualizados e fontes (PREFERIR)
- **WebSearch** → pesquisa complementar de tendencias
- **SecondBrain** → buscar notas/insights existentes sobre o tema
- **Context7** → docs atualizados se tema for tecnico
- **carousel-ai.ts** → alimentar o prompt com briefing rico

## Anti-Patterns

- Pesquisar generico demais ("marketing digital") → ser especifico ("copywriting para SaaS B2B")
- Copiar angulo de concorrente → encontrar gap e diferenciar
- Ignorar formato → pesquisar qual formato performa pro nicho
- Pular etapa de publico → conteudo sem direcionamento nao converte
