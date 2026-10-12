# AGENTS.md

The cross-LLM contract for this repo. Any coding agent working here (Cursor, Copilot, Codex, Gemini, Claude Code, plus humans) honors what follows. It is the portable distillation of `CLAUDE.base.md`. When the two disagree, `CLAUDE.base.md` wins for Claude Code; this file is the lowest common denominator every tool can read.

## What be-human-harness is

A distributable agent OS for Claude Code: a version-controlled harness (curated skills, specialized subagents, a fan-out orchestration layer, a ship/verify loop) plus the working discipline that ties them together. One engine, N private instances: you inherit the method, keep your `brain/` local.

## The Spine

Every non-trivial task runs the same five-beat loop. Skills fire on trigger, never all-at-once.

```
  brainstorm  ->  build  ->  gate  ->  verify  ->  wrapup
  ----------      -----      ----      ------       ------
  intent +        single-    review    E2E proof    learn,
  options         threaded   panel +   on the LIVE  persist,
  before code     writer,    adversar  app: curl    commit,
                  one diff   verify    200, click   push
```

| Beat | What happens | Hard rule |
|---|---|---|
| **brainstorm** | State intent, requirements, options. | No code before the design is stated. Surface the simpler path if one exists. |
| **build** | One writer, one surgical diff. | Single-threaded. Touch only what the task needs. |
| **gate** | Judge panel + adversarial verify. | Dimension-based reviewers (SQL, Auth, Infra, API, Cost), not role tags. |
| **verify** | Headless-browser dogfooding of the real running app. | curl 200 (not 307/302), click each internal link, screenshot the LIVE url. |
| **wrapup** | Learn, persist, commit. | Untested-assumptions list must be 0 before "done". |

## Hard rules (non-negotiable)

1. **E2E before "done".** Never declare "live" or "done" without material proof: curl 200 (not 307/302), each internal link clicked, a screenshot of the LIVE url. If the untested-assumptions list is > 0, it is not done.
2. **Surgical changes.** Touch only what the task requires. Do not "improve" adjacent code, do not refactor what is not broken, follow the existing style. Every changed line traces to the request.
3. **Never commit secrets.** No `.env`, credentials, API keys, tokens, or real client data in git. No command injection, XSS, or SQL injection. `brain/` is gitignored and stays that way.
4. **Confirm before push, deploy, or spend.** Commit freely. Pushing, deploying, force-pushing, any irreversible action, and anything that costs money wait for explicit confirmation. Never force-push.
5. **Destructive commands need confirmation.** `rm -rf`, force push, `DROP TABLE` and equivalents are blocked without an explicit go.

## Orchestration: one writer, many scouts

The single principle that scales this repo past one context window:

> **Fan out to READ and VERIFY. Single-thread to WRITE code.**

- **Fan out** for search, review, research, audit. These are independent, read-heavy, and merge cleanly. One coordinator, many scouts.
- **Single-thread** the writing. Parallel writers fork context, make conflicting decisions, and produce merge hell. One writer, period.

Subagents are the primitive. Each runs in its own fresh context window, custom system prompt, isolated tool allowlist, independent permissions, and sees none of the parent's history (only a delegation summary), so fan-out never floods the main thread. Topology is **one level deep**: a coordinator plus workers. Subagents do not spawn subagents.

Subagents ship as Markdown + YAML frontmatter (`name` and `description` required; optional `model`, `tools`, `permission-mode`, `maxTurns`, `isolation`). Use `isolation: worktree` **only** for parallel file edits that would collide. It is expensive otherwise.

Patterns worth knowing (full method in `harness/orchestration/`):

| Pattern | When |
|---|---|
| **pipeline** (no barrier, item-level streaming) | The default. |
| **parallel** (barrier) | Only when a stage needs ALL prior results: dedup, early-exit, cross-comparison. |
| **adversarial verify** | N skeptics per finding, each prompted to refute. Majority refutes -> kill it. |
| **judge panel** | 4 to 6 blind reviewers, distinct lenses, then debate, then a Supreme Judge adjudicates. Costs real tokens (~150k to 350k per run); use on decisions that matter. |
| **loop-until-dry** | Spawn finders until K consecutive rounds find nothing new. Beats a fixed top-N. |

Avoid: naive massive fan-out for writing code, nested subagents, loading all skills always.

## Where things live

```
be-human-harness/
|- CLAUDE.base.md      the method, inherited (the loop, rules, discipline)
|- AGENTS.md           this file (cross-LLM contract)
|- bin/bh            CLI: init · status · onboard · sync
|- harness/
|  |- orchestration/   fan-out workflow scripts (pipeline · parallel · agent())
|  |- subagents/       Markdown + frontmatter, dimension-based reviewers
|  |- verify/          browse · autoplan · canary · destructive-command guard
|  `- sdlc/            OPTIONAL heavy module (PRD -> epics -> stories -> gates)
|- skills/             curated skill kit, loaded on trigger (never all-at-once)
`- brain/              private, gitignored, per-instance (brain/ME.md = your context, your data)
```

- **`CLAUDE.base.md`** carries the method. Your instance's `CLAUDE.md` extends it; you inherit and override, never fork the base.
- **`harness/sdlc/`** is the optional BMAD-METHOD / AIOX-lineage module: formal PRD -> sharded epics -> stories -> role squad with gates. Use it for formal greenfield with a real PRD and auditable gates. Skip it for solo tactical work, exploration, quick fixes, flow-state building. It is a plug-in, not the backbone.
- **`brain/ME.md`** and the rest of `brain/` are private and per-person. Never read secrets out of it into committed files, never push it.

## Style

No em-dash and no en-dash anywhere. Use commas, parentheses, periods, colons, ", ", "->", or line breaks. Be concrete and opinionated. Markdown, scannable, diagrams in ASCII when showing flow. Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`).

---

The whole method in one line: **fan out to read and verify, stay single-threaded to write, prove before "done".**
