# ai-pick · IA escolhe o tema default

Ao gerar um HTML, escolher o `data-theme` inicial pelo contexto. O the user troca depois pelo picker; isto é só o melhor palpite.

## Heurística

| Contexto do documento | Tema default |
|---|---|
| Report de arquitetura, Steve OS, dashboard técnico interno | `dark-hub` |
| Personal material, proposta Be Human, brand, pitch | `brand-v4` |
| Documento sério, leitura longa, relatório formal, contrato | `white-editorial` |
| Conteúdo sobre IA, Claude Code, posicionamento agêntico | `claude-warm` |
| Dashboard de produto, spec de engenharia, changelog, SaaS | `linear-mono` |

## Cliente com marca própria

Se o documento é pra um cliente que tem tema próprio em `themes/<cliente>/`, usar esse. Senão, herdar pela natureza do conteúdo acima. Quando o cliente tiver branding conhecido (cores/fontes), criar `themes/<cliente>/DESIGN.md` a partir do `_corpus` mais próximo ou do brand dele.

## Regra

- Na dúvida entre dois → escolher o mais sóbrio (`white-editorial` ou `linear-mono`).
- Nunca hardcodar cor "porque combina" · escolher um tema existente. Se nenhum serve, criar um tema novo (`DESIGN.md`), não cor solta.
- O default é só o palpite. Os 5 temas vão embutidos sempre; the user tem a palavra final no picker.
