# Subagents

A subagent is a worker you spawn from the main agent to do one bounded job in
its own context, then hand back a conclusion. This doc is the method: what
separates a subagent setup that multiplies your output from one that just burns
tokens and floods context. Shippable examples live in `templates/`.

---

## 1. What a subagent actually is

A Claude Code subagent is not a function call and not a thread. It is a fresh
agent instance with hard walls around it:

- **Own context window.** It starts empty. It does not see the parent's
  conversation history, only the delegation summary you pass in.
- **Custom system prompt.** You define its role and rules in the agent file.
- **Isolated tool allowlist.** It gets only the tools you grant. A reviewer can
  be read-only; a fixer can write.
- **Independent permissions.** Permission mode is per-agent. One subagent can be
  locked down while another runs looser.
- **Returns a summary, not a transcript.** The parent receives the subagent's
  final conclusion, not its scratch work.

This is the primitive for **fan-out without flooding** the main context. You
push exploration, review, and verification into throwaway windows and keep the
orchestrator's context clean for decisions.

### One level deep

Subagents **cannot spawn subagents**. The topology is flat:

```
  main agent (orchestrator)
    ├── subagent A   (worker, terminal)
    ├── subagent B   (worker, terminal)
    └── subagent C   (worker, terminal)
```

Coordinator plus workers. That is the whole shape. If you need sustained deep
parallelism where each worker carries its own long-lived context beyond a single
window, that is the separate **Agent Teams** feature (Feb 2026), not subagents.
Do not design around nested subagents. They do not exist.

### The one rule that decides everything: fan out to read, single-thread to write

This reconciles the two famous and seemingly opposed essays (Cognition's "Don't
Build Multi-Agents" and Anthropic's "Multi-Agent Research System"):

```
  READ / VERIFY  ->  fan out.   search, review, research, audit.
                                 independent, read-heavy, conclusions merge clean.

  WRITE CODE     ->  single thread.   parallel writers fragment context,
                                      make conflicting decisions, create merge hell.
```

**One writer, many scouts.** Spawn ten subagents to audit a diff from ten
angles, then let one agent (or the human) apply the fix. Never spawn ten
subagents to each edit part of the same change.

---

## 2. The frontmatter contract

A subagent is a Markdown file with YAML frontmatter. The body is the system
prompt. The frontmatter is the config. It is version-controlled and shippable:
drop the file in, the agent exists.

Only `name` and `description` are required. Everything else is opt-in and scoped
per agent:

| Field | What it does |
|---|---|
| `name` | **Required.** Stable id used to invoke the agent. |
| `description` | **Required.** When to use it. Drives auto-selection. |
| `model` | Pin a model. `opus` for judgment-heavy review, a cheaper model for mechanical sweeps. |
| `tools` | Allow/deny list. The isolation lever: read-only reviewer vs. write-capable fixer. |
| `permission-mode` | Per-agent permissions, independent of the parent. |
| `skills` | Skills this agent may load. Do not grant all skills always. |
| `hooks` | Pre/post hooks scoped to this agent (e.g. a guard before any write). |
| `maxTurns` | Hard ceiling so a runaway worker cannot loop forever. |
| `isolation: worktree` | Give the agent its own git worktree. See section 4. |

### Real frontmatter example

```markdown
---
name: sql-reviewer
description: >
  Reviews a diff for SQL correctness, injection risk, N+1 queries,
  missing indexes, and unsafe migrations. Read-only. Returns validated
  JSON, never prose.
model: opus
tools:
  - Read
  - Grep
  - Glob
permission-mode: read-only
maxTurns: 12
---

You are a SQL reviewer. You receive a diff and the schema context.

Inspect ONLY for: injection, N+1 access patterns, missing or wrong
indexes, lock-heavy or non-reversible migrations, accidental full-table
scans.

Do not comment on style, naming, or anything outside SQL.

Return your verdict as JSON matching the output schema. One finding per
issue. If you find nothing, return an empty findings array. Never invent
issues to look thorough.
```

Note what this agent **cannot** do: no Write, no Bash, no network. It physically
cannot break anything. That is the point.

---

## 3. Role-based vs. task-based vs. dimension-based

Three ways to slice your agents. They are not interchangeable.

| Slicing | Example agents | Best for |
|---|---|---|
| **Role-based** | `@dev`, `@qa`, `@architect`, `@pm`, `@po`, `@sm` | **Generation.** Building a feature through an SDLC squad. |
| **Task-based** | `summarize-file`, `extract-endpoints`, `rename-symbol` | Mechanical one-shot transforms. |
| **Dimension-based** | `sql`, `auth`, `infra`, `frontend`, `cost`, `ml`, `api` | **Critique.** Reviewing and auditing. |

### For review, dimensions beat roles

A fixed `@qa` tag reviews "quality" in general and produces vague, overlapping
notes. Five dimension-based reviewers each own one lens and miss nothing in it:

```
  diff
   ├── sql       -> injection, N+1, indexes, migrations
   ├── auth      -> authz holes, token handling, session fixation
   ├── infra     -> blast radius, rollback, resource limits
   ├── frontend  -> a11y, render cost, state leaks
   └── cost      -> token spend, paid API calls, egress, compute
```

Each agent is blind to the others' concerns, so coverage is partitioned instead
of duplicated, and the merge is clean because two reviewers rarely flag the same
line for the same reason. This is the **judge-panel** pattern (see
`wan-huiyan/agent-review-panel`): 4 to 6 blind reviewers with distinct
dimension personas run in parallel, then 1 to 3 debate rounds, then a "Supreme
Judge" (pinned to `model: opus`) adjudicates and kills cross-run variance.

**The burn is real.** A full panel run is roughly 150k to 350k tokens, on the
order of a few dollars to ~$20, and 6 to 15 minutes. Use it on diffs that matter
(auth, money, migrations), not on every typo.

**Rule of thumb:** role tags for **generation**, dimensions for **critique**.

---

## 4. worktree isolation

`isolation: worktree` gives a subagent its own git worktree, branched from the
default branch and auto-cleaned if it ends up unchanged. It exists for exactly
one scenario:

```
  USE worktree   ->  multiple subagents editing files that would
                     collide on the same working tree. (rare)

  SKIP worktree  ->  everything read-only: review, audit, research,
                     verification. (the common case)
```

Worktree isolation is **expensive**: each one is a checkout. Most fan-out is
read-heavy and read-only, so most fan-out needs no worktree at all. Reach for it
only when you have genuinely parallel **writers** touching overlapping files,
which, per section 1, you are usually avoiding anyway. If your subagents only
read, never set this flag.

---

## 5. Schema-validated structured output

The orchestrator should never parse prose. Free-text findings force the parent
to re-read and re-interpret, which reintroduces exactly the context bloat
subagents exist to prevent. Force every worker to return **validated JSON**
against a schema:

```json
{
  "agent": "sql-reviewer",
  "verdict": "changes_requested",
  "findings": [
    {
      "dimension": "sql",
      "severity": "high",
      "file": "src/db/orders.ts",
      "line": 88,
      "issue": "User input concatenated into raw query",
      "fix": "Use parameterized query"
    }
  ],
  "dropped": []
}
```

Why it matters:

- The orchestrator routes on `verdict` and `severity`, no NLP needed.
- Findings merge across N agents by appending arrays.
- `dropped` enforces **no silent caps**: if a worker truncated or skipped
  anything, it must say so, not quietly omit it.
- Invalid JSON is a hard failure the harness can retry, not a guess.

Make the schema part of the agent file's contract and reject anything that does
not match.

---

## 6. Context isolation discipline

The walls only pay off if you respect them in both directions.

**Going in: pass the minimum.** Send the delegation summary plus the exact slice
the worker needs (the diff, the relevant paths, the schema). Do not dump the
whole conversation or the whole repo. The subagent starts fresh on purpose; a
fat prompt throws that away.

**Coming out: return the conclusion, not the file dump.** A reviewer returns
findings, not the 800 lines it read. A researcher returns the answer with
citations, not every page it fetched. The whole reason to fan out is to compress
N windows of reading into one window of conclusions. If a worker echoes back its
raw inputs, you have paid for isolation and gotten none of it.

```
  BAD:   subagent reads 12 files -> returns all 12 files -> parent context explodes
  GOOD:  subagent reads 12 files -> returns 3 findings as JSON -> parent stays lean
```

### Patterns that produce better output (not just more tokens)

- **pipeline by default.** No barrier between stages, stream item by item. Use a
  **parallel** (barriered) stage only when it genuinely needs all prior results:
  dedup, early-exit, cross-comparison.
- **adversarial verify.** For each finding, spawn N independent skeptics each
  prompted to *refute* it. If the majority refutes, kill the finding. Survivors
  are real.
- **loop-until-dry.** Keep spawning finders until K consecutive rounds turn up
  nothing new. Beats a fixed top-N that stops early or pads late.
- **completeness critic + no silent caps.** A final pass checks for gaps, and
  every worker logs what it dropped (see `dropped` above) instead of silently
  capping.

---

## 7. Templates

Shippable, copy-pasteable agent files live in `templates/`:

- dimension-based reviewer (read-only, JSON output) for the judge panel.
- a worktree-isolated fixer for the rare parallel-write case.
- a research scout with adversarial verification.

Start from a template, edit the frontmatter, ship the file. Do not hand-roll an
agent from scratch when one of these already encodes the method.

---

## TL;DR

- Subagent = fresh context, own system prompt, isolated tools, returns a summary.
  **One level deep.** Need deeper parallelism -> Agent Teams.
- **Fan out to read and verify. Single-thread to write.** One writer, many scouts.
- Frontmatter contract: only `name` + `description` required; scope `model`,
  `tools`, `permission-mode`, `skills`, `hooks`, `maxTurns`, `isolation` per agent.
- **Dimensions for critique** (sql, auth, infra, frontend, cost), role tags for
  generation. Judge panel kills variance; the panel burn is real, spend it on
  diffs that matter.
- `isolation: worktree` only for parallel writers. Read-only fan-out needs none.
- Force validated JSON out. Pass the minimum in, return the conclusion out.
