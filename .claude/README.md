# `.claude/settings.json` · config da Be Human (YOLO + tudo habilitado)

Config de instância da Be Human, espelhada do setup que the user roda no dia a dia.
Quem clonar o `be-human-harness` herda a mesma postura: opera ponta-a-ponta, sem prompt a cada passo.

## O que vem ligado

| Bloco | O que faz |
|---|---|
| `permissions.defaultMode: bypassPermissions` | **YOLO total.** Bash, Edit, Write, Read, Task, Skill, Web, MCP rodam sem pedir. |
| `permissions.deny` | Comandos catastróficos (`rm -rf /`, `rm -rf ~`, `mkfs`, `dd`, `chmod -R 777 /`) → bloqueados de vez. |
| `permissions.allow` | Allowlist ampla (Bash/Edit/Write + MCPs comuns: codegraph, lean-ctx, fathom, secondbrain, browser…). |
| `effortLevel: xhigh` | Raciocínio no talo. |
| `autoMode` + `skipDangerousModePermissionPrompt` | Modo autônomo ligado. |
| `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Times de agente (fan-out). |
| `enabledPlugins` | claude-mem, superpowers, code-review, context7, frontend-design, telegram, ralph-loop, caveman. |

**Quando ainda te chamam:** sair do plan mode (`ExitPlanMode`) sempre pede aprovação (nativo do
Claude Code). O `deny` não pede, **bloqueia**.

## Portabilidade

Os `hooks` pessoais (mem0, board, memory-stream, statusline) foram **guardados** com
`command -v` / `[ -x "$HOME/..." ]`: rodam pra quem tiver os scripts, **no-op silencioso** pra quem
não tiver. Nenhum path de máquina (`/Users/...`) nem segredo entra aqui (ver `.gitignore`).

> Pra postura conservadora: troca `defaultMode` pra `"default"` (pede tudo) ou `"acceptEdits"`
> (auto só em edição) e adiciona uma lista `ask` com `Bash(rm:*)` pra confirmar deleção de arquivo.
