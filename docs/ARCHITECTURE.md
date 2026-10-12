# be-human-harness · Architecture

> The system map. Read this once and you understand the whole thing: what the layers are, how they
> compose, how one engine becomes N tenant instances, and how a single task flows through the Spine.
>
> be-human-harness is a distributable agent OS for Claude Code. The method lives in `CLAUDE.base.md`. The
> machinery that runs the method lives in `harness/`. Capabilities load on trigger from `skills/`.
> The CLI is `bin/bh`. Private identity lives in `brain/` and overrides everything.

---

## 1. The layers, composed

The center is a method, not a model. Everything else wraps it and makes it executable.

```
                         ┌───────────────────────────────────────────┐
                         │                  brain/ME.md               │  PRIVATE, gitignored
                         │   identity · voice · stakes · overrides    │  overrides the base
                         └───────────────────────┬───────────────────┘
                                                 │ overlays (last word)
                                                 ▼
          ┌───────────────────────────────────────────────────────────────────┐
          │                          bin/bh  (CLI surface)                    │
          │     init · onboard · sync · status · agents · deploy · open · help  │
          │   the operator's verbs. wraps the harness, drives the instances.    │
          └───────────────────────────────────┬───────────────────────────────┘
                                              │ invokes / orchestrates
                                              ▼
          ┌───────────────────────────────────────────────────────────────────┐
          │                              harness/                               │
          │   ┌───────────────┐ ┌───────────────┐ ┌───────────────┐            │
          │   │ orchestration │ │   subagents   │ │    verify     │            │
          │   │  fan-out eng. │ │ shippable     │ │  ship/verify  │            │
          │   │ pipeline, panel│ │ MD+frontmatter│ │  E2E, dogfood  │            │
          │   └───────────────┘ └───────────────┘ └───────────────┘            │
          │   ┌───────────────────────────────────────────────────┐            │
          │   │ sdlc  (OPTIONAL plug-in: PRD, epics, stories, gates)  │            │
          │   └───────────────────────────────────────────────────┘            │
          │                                                                     │
          │            ┌───────────────────────────────────────┐               │
          │            │           CLAUDE.base.md              │  ◄── the core  │
          │            │   method · discipline · the law       │   everything   │
          │            │   (Karpathy loop · E2E · one writer)  │   wraps this   │
          │            └───────────────────────────────────────┘               │
          └───────────────────────────────────┬───────────────────────────────┘
                                              │ loads on trigger
                                              ▼
          ┌───────────────────────────────────────────────────────────────────┐
          │                              skills/                                │
          │   on-trigger capability modules. one job each, narrow allowlist.    │
          │   browse · review · ship · guard · design · ... (load when matched) │
          └───────────────────────────────────────────────────────────────────┘
```

Read the layers from the inside out:

| Layer | File / dir | Job | Lifecycle |
|---|---|---|---|
| **Core** | `CLAUDE.base.md` | The method and the discipline. Think-before-code (Karpathy loop), one-writer-many-scouts, E2E proof-before-done. Every agent in every instance obeys this. | Always loaded. The constant. |
| **Harness** | `harness/` | The machinery that executes the method: how to fan out, how to spawn workers, how to verify, how to (optionally) run heavy SDLC. | Invoked by the CLI and by the running agent. |
| **Skills** | `skills/` | Capabilities that load **only when their trigger matches**. A skill is a tool the agent reaches for, not standing context. | On-trigger. Off otherwise. |
| **CLI** | `bin/bh` | The operator surface. Turns intent into harness calls: scaffold, onboard a tenant, sync, inspect agents, deploy. | Run by a human or a parent agent. |
| **Identity** | `brain/ME.md` | The private overlay. Who this instance is, its voice, its stakes, its non-negotiables. **Overrides the base** where they conflict. Gitignored, never shipped. | Loaded last, wins ties. |

**Why identity overrides the base:** the base is the shared method, deliberately generic so it ships to
everyone. `brain/ME.md` is the part that must NOT ship: the specific voice, the real stakes, the
opinions. It is the last file read and the last word. The base says *how to work*; the brain says
*who is working and what they will not compromise*. That ordering is the whole multi-tenant trick: one
shared method, N private identities.

---

## 2. Multi-tenant: one engine, N instances

be-human-harness ships as an **engine** (base + harness + skills + CLI). Each tenant is an **instance**: the
same engine with its own `brain/ME.md` overlay and its own state. `bh onboard` is the fan-out that
turns one engine into many instances without forking the method.

```
                       ┌──────────────────────────────┐
                       │        be-human-harness ENGINE         │
                       │   CLAUDE.base.md  (method)    │
                       │   harness/        (machinery) │
                       │   skills/         (caps)      │
                       │   bin/bh        (CLI)       │
                       └───────────────┬──────────────┘
                                       │
                              `bh onboard <name>`
                                       │   (clone engine, drop a fresh brain/, scaffold state)
            ┌──────────────────────────┼──────────────────────────┐
            ▼                          ▼                          ▼
   ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
   │  instance: A    │       │  instance: B    │       │  instance: N    │
   │  engine (shared)│       │  engine (shared)│       │  engine (shared)│
   │  brain/ME.md  ◄─┼─ own  │  brain/ME.md  ◄─┼─ own  │  brain/ME.md  ◄─┼─ own
   │  state/       ◄─┼─ own  │  state/       ◄─┼─ own  │  state/       ◄─┼─ own
   └─────────────────┘       └─────────────────┘       └─────────────────┘
```

The contract:

- **Engine is shared and updateable.** Improve the method or the harness once; every instance pulls it.
  Identity and state never live in the engine, so an update can never clobber a tenant.
- **Brain is private and per-instance.** It is the only file that differs between two instances by
  default. It is gitignored in the engine so it cannot leak between tenants.
- **State is per-instance.** Each instance owns its own working dirs, its own deploy targets, its own
  history. `bh sync` pulls engine updates; it does not touch state.
- **One method, N voices.** This is the same "one writer, many scouts" rule applied to deployment: the
  method is the single source of truth (the writer); instances are the readers that specialize it.

---

## 3. Harness modules · one job each

Grounded in the SOTA research the harness is built on. Each module's full runbook is its own README.

### orchestration/ · the fan-out engine

Scales past one agent in one context window to 200+ agents without drowning the main thread.
Its one governing rule reconciles the two famous essays: **fan out to READ and VERIFY, stay
single-threaded to WRITE** (Cognition "Don't Build Multi-Agents" vs Anthropic "Multi-Agent Research
System", one writer, many scouts). Three primitives: **subagents** (one-shot fan-out, one level deep),
**workflow scripts** (deterministic JS wiring of many subagents, the marc0.dev "ultracode" /
dynamic-workflows pattern, ~16 concurrent / ~1000 lifetime per run), and **Agent Teams** (the Feb 2026
feature for sustained deep parallelism where each worker keeps its own context beyond a window). Default
pattern is **pipeline** (no barrier, item-level streaming); reach for **parallel** (barrier) only when a
stage needs ALL prior results (dedup, cross-comparison, early-exit). Heavier shapes: **adversarial
verify** (N skeptics per finding, each prompted to refute, majority refutes kills it), **judge panel**
(4 to 6 blind dimension-based Opus reviewers, then debate, then adjudication, ~$3 to $20 and 6 to 15 min
per run, quantified because the burn is real), and **loop-until-dry** (spawn finders until K rounds find
nothing new). Anti-patterns it bans: naive massive fan-out to write code, nested subagents, all-skills-always.

### subagents/ · shippable workers

The method for defining a worker that multiplies output instead of just burning tokens. A subagent is a
**Markdown file with YAML frontmatter**: the body is its system prompt, the frontmatter is its wiring
(`name` and `description` required; `model`, `tools` allow/deny, `permission-mode`, `skills`, `maxTurns`,
`isolation: worktree` optional). It runs in a **fresh context window**, sees none of the parent's history
(only a delegation summary), holds an **isolated tool allowlist** and **independent permissions**, and
returns a conclusion, not a transcript. It is **one level deep**: subagents cannot spawn subagents, so
the topology is strictly coordinator + workers. `isolation: worktree` gives an agent its own git
worktree (branched from default, auto-cleaned if unchanged) and is used **only** for parallel file edits
that would collide. Templates ship in `templates/`: dimension-based reviewers (not fixed role tags),
adversarial judges, and read-only explorers.

### verify/ · the ship/verify loop

The law that sits between "the model finished" and "it's live". Writing code is cheap now; knowing it
works is the bottleneck. The core rule: **a claim of "done" or "live" is a lie until proven with material
evidence**, and the **untested-assumptions list must be 0**. E2E proof-before-done means `curl` returns
**200, not 307/302** (a redirect is the most common false "live"), every internal link clicked and
absolute (never relative `../`), the real DB queried, a screenshot of the LIVE url. Then **headless-browser
dogfooding** (gstack `browse`, vercel-labs/agent-browser): drive the real running app, navigate, click,
screenshot, diff before/after at ~100ms per command. Then an **auto-review** pass (gstack `autoplan`:
CEO/design/eng/DX lenses surfaced at one approval gate). A **guard** blocks destructive commands
(`rm -rf`, force push, `DROP TABLE`) without confirmation (nazt/destructive_command_guard). Post-deploy,
a **canary** monitors before anything is declared healthy. Verify is read-heavy and parallelizable: fan
out scouts to navigate and audit, merge their conclusions, keep the writer single-threaded.

### sdlc/ · heavy lifecycle (OPTIONAL plug-in)

The BMAD-METHOD / Synkra-AIOX lineage: `PRD -> sharded epics -> stories -> role squad (@pm @po @sm
@architect @dev @qa @devops) -> quality gates + a constitution`. The value is the structure itself
(nothing advances without a story, no story closes without its gate). That structure is also the cost:
every arrow is a handoff. It **helps** formal, shared, long-lived builds with a real PRD, multiple
stakeholders, and auditable gates ("show me the gate that approved this"). It is **overhead** for solo
tactical work, exploration, quick fixes, and flow-state building, where every handoff is a tax with no
payer. **Verdict: ship it as an opt-in plug-in, never the default backbone.** You opt INTO ceremony per
project; you never inherit it.

---

## 4. Data flow · a task through the Spine

The Spine is the path a real task takes from intent to "live". The shape is constant: a single writer
holds the thread, fans out scouts to read and verify, and never declares done without material proof.

```
   intent ("build X / fix Y / research Z")
      │
      ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │ 1. LOAD CONTEXT                                                    │
 │    CLAUDE.base.md (method)  +  brain/ME.md (identity, wins ties)   │
 │    -> the writer now knows HOW to work and WHO it is              │
 └───────────────────────────────┬──────────────────────────────────┘
                                 ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │ 2. CLASSIFY  (is this READ-heavy or does it WRITE shared state?)   │
 └───────────────┬──────────────────────────────────┬───────────────┘
        READ / VERIFY                          WRITE CODE
                 │                                  │
                 ▼                                  │ (stays single-threaded)
 ┌───────────────────────────────┐                 │
 │ 3R. FAN OUT (orchestration)   │                 │
 │   pipeline by default ──────► │                 │
 │   scout ─┐                    │                 │
 │   scout ─┼─► conclusions      │                 │
 │   scout ─┘   merge clean      │                 │
 │   (parallel/panel/loop-dry    │                 │
 │    only when the work needs   │                 │
 │    a barrier or a verdict)    │                 │
 └───────────────┬───────────────┘                 │
                 │ merged findings                 │
                 └───────────────┬─────────────────┘
                                 ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │ 4. WRITE  (ONE writer integrates everything · single thread)      │
 │    skills load on trigger (design, refactor, ...)                 │
 │    worktree isolation ONLY if parallel edits would collide        │
 └───────────────────────────────┬──────────────────────────────────┘
                                 ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │ 5. VERIFY  (verify/ · read-heavy, fan out scouts, merge)          │
 │    E2E proof: curl 200 (not 307/302) · click every link          │
 │    dogfood:  drive the real app headless · screenshot · diff      │
 │    review:   dimension-based panel / adversarial refute           │
 │    untested-assumptions list  ==  0   ◄── the gate                │
 └───────────────┬──────────────────────────────┬───────────────────┘
          proof FAILS                       proof PASSES
                 │                                │
        back to step 4 (fix)                      ▼
                                  ┌──────────────────────────────────┐
                                  │ 6. GUARD + DEPLOY + CANARY        │
                                  │   block destructive cmds          │
                                  │   ship · monitor post-deploy      │
                                  │   declare healthy ONLY when       │
                                  │   canary is green                 │
                                  └──────────────────────────────────┘
```

The invariants the Spine enforces on every task:

1. **Identity overlays method.** Step 1 loads the base, then the brain, then runs. The brain has the
   last word.
2. **Classify before you parallelize.** Step 2 is the one decision that prevents merge hell. Read/verify
   fans out; writing does not.
3. **One writer.** Step 4 is always single-threaded, no matter how wide step 3 fanned out.
4. **No proof, no done.** Step 5's untested-assumptions list must be empty. A `307` is not "live".
5. **Healthy is earned post-deploy.** Step 6 declares health only after a green canary, never at merge.

That is the whole system. The core is a method, the harness runs it, skills extend it on trigger, the
CLI drives it, the brain owns who you are, and `bh onboard` turns one of these into N. Contributors:
start in `harness/orchestration/README.md`, then `harness/verify/README.md`. Those two modules are the
backbone; everything else composes around them.
