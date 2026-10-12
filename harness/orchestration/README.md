# Orchestration

The fan-out engine of be-human-harness. This is how you scale past one agent in one context window to 200+ agents working a problem without drowning the main thread or melting your token budget. Read this before you reach for a swarm.

---

## The core principle

> **Fan out to READ and VERIFY. Single-thread to WRITE.**
> One writer, many scouts.

Two papers look like they disagree. They don't.

Cognition's **"Don't Build Multi-Agents"** is right that parallel *writers* are a trap. The moment two agents both produce code or make architectural decisions, their contexts fork. Each builds on assumptions the other can't see, they pick conflicting names and abstractions, and you inherit a merge problem no diff tool solves. Context does not reconcile after the fact.

Anthropic's **"Multi-Agent Research System"** is right that parallel *readers* are a force multiplier. Search, review, audit, and research are read-heavy and independent. Each scout returns a clean conclusion ("this finding is real", "this file is fine", "here is the relevant doc"). Conclusions merge trivially because they don't depend on each other.

Reconcile them by what the work *produces*, not by headcount:

```
            +-------------------------------------------+
            |  Does the task PRODUCE shared mutable      |
            |  state (code, schema, one design)?         |
            +-------------------------------------------+
                   |                          |
                  YES                        NO
                   |                          |
          SINGLE-THREAD it.          FAN OUT wide.
          One writer holds the       N scouts read/verify
          context, makes the         in parallel, conclusions
          decisions, owns the diff.  merge into the writer.
```

So: 50 agents auditing a codebase for a bug class, great. 50 agents *fixing* the bug in parallel, merge hell. Scouts find and verify; the single writer integrates. Every pattern below is an application of this one rule.

---

## Primitives

Three tools. Pick by how deep and how parallel the work runs.

| Primitive | What it is | Context model | Scale | Use it for |
|---|---|---|---|---|
| **Subagent** | A Claude Code agent defined in Markdown + YAML frontmatter (own system prompt, tool allowlist, model, permissions). Delegated to from the main thread. | **Fresh context window.** Sees none of the parent's history, only a delegation summary you pass in. Returns a result, not its transcript. | **One level deep.** A subagent cannot spawn subagents. Topology is strictly coordinator + workers. | Bounded read/verify tasks: review a diff, research a question, audit a file, search a corpus. Keeps the main context clean. |
| **Workflow scripts** | Deterministic JS orchestration (`pipeline()`, `parallel()`, `agent()`). The harness, not the model, decides who runs when. | Each `agent()` call is a fresh subagent context. The script holds the wiring; agents hold the work. | **~16 concurrent, ~1000 lifetime** per run (the marc0.dev "ultracode" / dynamic-workflows pattern documented for Claude Opus). | Structured fan-out you can reason about and replay: scrape -> filter -> score -> verify, or N reviewers -> debate -> adjudicate. The backbone of this layer. |
| **Agent Teams** | Sustained deep parallelism (the Feb 2026 feature). Each worker keeps its **own context beyond a single window** for the life of the team. | Per-worker persistent context. Workers are long-lived, not one-shot. | Fewer workers, each running long and deep. | Genuinely parallel deep work where each track needs to *remember* across many turns. Heavier than subagents; reach for it only when one-shot fan-out is not enough. |

Rule of thumb: **subagents for one-shot fan-out, workflow scripts to wire many subagents deterministically, Agent Teams only when each track needs durable memory.** Most of what you want is subagents driven by a workflow script.

### Subagent config

A subagent is a shippable, version-controlled file. Markdown body = its system prompt. YAML frontmatter = its wiring.

```yaml
---
name: sql-reviewer            # required
description: Reviews schema + query changes for correctness and cost   # required
model: opus                   # per-agent model override
tools:                        # explicit allowlist (default: inherit)
  allow: [Read, Grep, Bash]
  deny:  [Write, Edit]        # a reviewer should not write
permission-mode: read-only
skills: [security-review]     # skills this agent may load
maxTurns: 12
isolation: worktree           # ONLY for parallel file edits, see below
---

You are a SQL reviewer. You review one dimension: schema and query
correctness and cost. Refute the change if you find a real problem.
Return: verdict (pass | fail), evidence, one-line reason.
```

Only `name` and `description` are required. Everything else narrows scope. Because it is a file, it is reviewable, diffable, and ships with the repo.

### `isolation: worktree`

Gives the agent its own git worktree branched from the default branch, auto-cleaned if it makes no changes. Use it **only** for parallel *file edits* that would otherwise collide on disk. It is expensive (a full worktree per agent), so it is the wrong default. Read/verify agents never need it; they aren't writing. If you find yourself worktree-isolating reviewers, you've mixed up read and write.

---

## Patterns

Each pattern below is a shape plus a trigger. Runnable versions live in `harness/orchestration/workflows/`.

### pipeline (the default)

No barrier between stages. Items stream through one at a time, so stage 2 starts on item 1 while stage 1 is still chewing item 2. Nothing waits for the whole batch.

```
items ─► [stage A] ─► [stage B] ─► [stage C] ─► out
           item1 ───────► item1 ──────► item1 ─► ✓   (streaming, no barrier)
           item2 ──► item2 ...
```

**When:** almost always. Scrape -> filter -> enrich -> verify. Any chain where each item is independent and you want throughput. This is the shape you start with.

### parallel (barrier)

A barrier. Stage N+1 cannot start until it has *all* of stage N's results. You pay the latency of the slowest item to gain a global view.

```
items ─► [worker × N] ══BARRIER══► [stage that needs ALL results]
          a ─┐
          b ─┼──► wait for a,b,c,d ──► dedup / compare / early-exit
          c ─┤
          d ─┘
```

**When:** and only when a stage genuinely needs the whole set. Dedup across results, cross-comparison, early-exit decisions ("if any scout found X, stop"), ranking the full pool. If a stage doesn't need all prior results, don't use a barrier. It just makes you slower.

### adversarial verify

Per finding, spawn N independent skeptics. Each one is prompted to **refute**, not to confirm. Majority refutes -> the finding dies. This kills the confirmation bias of a single agent that wants to agree with itself.

```
finding ─► skeptic1 (refute?) ─┐
        ─► skeptic2 (refute?) ─┼─► majority refutes ─► KILL
        ─► skeptic3 (refute?) ─┘  else ─► keep
```

**When:** any high-stakes finding before you act on it. Security claims, "this is the root cause", a scraped lead before you spend money mailing it, a metric before you report it. The job of each skeptic is to break the claim. Surviving means real.

### judge panel

The heavyweight review pattern (reference repo: `wan-huiyan/agent-review-panel`). 4 to 6 reviewers, each a **dimension**, not a role tag: SQL, Auth, Infra, ML, API, Frontend, Cost. They review **blind** during the parallel phase (no reviewer sees another's notes), then 1 to 3 **debate** rounds where they react to each other, then a single **Supreme Judge** adjudicates the final verdict.

```
        ┌─ reviewer: SQL    ─┐
        ├─ reviewer: Auth   ─┤  blind, parallel
change ─┼─ reviewer: Infra  ─┼──► [debate × 1-3 rounds] ──► [Supreme Judge] ──► verdict
        ├─ reviewer: Cost   ─┤        react to each other      adjudicates
        └─ reviewer: API    ─┘
```

Two rules that matter:
- **Dimensions, not roles.** "Cost reviewer" finds different things than "senior engineer". Pick the axes your change actually risks.
- **Force `model: opus` on the reviewers and the judge.** It crushes cross-run variance. A panel that gives a different verdict each run is a random number generator wearing a lab coat.

**When:** a change big enough to justify the burn (see Cost). Architecture, a risky migration, a release gate. Not for a one-line fix.

### loop-until-dry

Don't pick a fixed top-N. Keep spawning finders until **K consecutive rounds find nothing new**, then stop. The corpus tells you when it's exhausted; you don't guess.

```
round 1 ─► found 7   (reset dry counter)
round 2 ─► found 2   (reset)
round 3 ─► found 0   (dry = 1)
round 4 ─► found 0   (dry = 2 == K) ─► STOP
```

**When:** "find all the X" tasks where you don't know the count up front. All instances of a bug class, every dead link, every untyped export. Beats `--top-50` that either truncates real results or wastes runs on an empty tail.

### multi-modal sweep

Run the same target through several different lenses in parallel, then merge. Static read, runtime behavior, the headless-browser view, the cost view. Different lenses catch different defects; one lens has blind spots by construction.

```
target ─► lens: static-read   ─┐
       ─► lens: runtime/logs   ─┼─► merge ─► union of findings
       ─► lens: browser-diff   ─┤
       ─► lens: cost           ─┘
```

**When:** verifying something with multiple surfaces. A shipped web change (does the code read right, does the app behave, does the screenshot diff clean, did the bill move). One sweep, several angles.

### completeness critic

A final agent whose only job is to ask "what did we miss?" It does not redo the work. It checks coverage: which inputs were skipped, which branch went untested, which assumption never got verified. It is the guard against a confident-but-partial result.

```
[main work done] ─► completeness critic ─► gaps list
                                          (empty = actually done)
```

**When:** before declaring done on anything that fans out. Pairs naturally with the E2E proof rule: the critic's gap list must be empty, and the untested-assumptions list must be **0**, or it isn't finished.

### no silent caps

A cross-cutting rule, not a standalone pattern. If you cap fan-out (top-N, a concurrency limit, a budget cutoff), **log what you dropped.** A truncated run that looks complete is worse than a slow one. Every pattern above that bounds work emits what it skipped, so the merge step and the human both know the result is partial on purpose.

---

## Cost reality

Fan-out spends real money. Quantify it before you trigger it.

| Pattern | Tokens / run | $ / run | Wall time |
|---|---|---|---|
| pipeline (typical batch) | low, scales with item count | cents to low single digits | seconds to minutes |
| adversarial verify (per finding) | moderate, N skeptics × findings | low single digits | minutes |
| **judge panel** | **~150k to 350k** | **~$3 to $20** | **~6 to 15 min** |

The judge panel is the expensive one and it is worth knowing why: 4 to 6 Opus reviewers, blind, plus debate rounds, plus an Opus adjudicator. That is a lot of Opus context. **Don't reach for a panel on a one-liner.** Match the ceremony to the stakes. And never run an unbounded swarm "to be safe" without a cap and a dropped-items log, that is how a $5 review becomes a $200 one.

---

## Anti-patterns

Three ways people light money on fire and corrupt context. Don't.

### Naive massive fan-out to WRITE code

The cardinal sin. Spinning up 50 agents to each write part of a feature in parallel. Their contexts fork, they make conflicting decisions, and you get a merge problem that costs more to untangle than writing it once would have. **Code is shared mutable state: single-thread the writer.** Fan out the *review* of that code, never the authoring.

### Nested subagents

Subagents are **one level deep** by design. A subagent cannot spawn subagents. Plans that assume a tree of agents recursively delegating ("a manager of managers of workers") do not run, full stop. The topology is coordinator + workers. If you need more structure, that is a workflow script orchestrating a flat pool of subagents, not a recursion fantasy.

### All-skills-always

Loading every skill into every agent. It bloats context, slows triage, and makes the model worse at picking the right tool because the menu is enormous. Each agent gets a **narrow, explicit** allowlist (`skills:`, `tools:`) scoped to its job. A reviewer doesn't need Write. A scraper doesn't need the design system. Scope tight, on purpose.

---

## Runnable examples

Working implementations of every pattern above live in:

```
harness/orchestration/workflows/
```

Start there. Copy the pipeline script, swap in your stages, and grow toward parallel / panel / loop-until-dry only when the work actually demands the heavier shape. Default to the lean tactical backbone (verify-and-ship loop) plus a workflow script for fan-out. Heavy SDLC ceremony is an optional plug-in, not the spine.
