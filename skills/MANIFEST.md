# Skills Manifest

A skill is a capability module: a folder with a `SKILL.md` that declares when it
fires and what it does. Skills load **on trigger, on demand**, by description
match, never all-at-once. Loading the whole kit into every turn is noise: it
bloats context, slows triage, and makes the model worse at picking the right tool
because the menu is enormous. The kit can hold hundreds; the agent pulls the two
or three the task earns.

The **Spine** (`CLAUDE.base.md`) is the only always-on layer. Everything below is
a leaf the Spine reaches for when the work matches its trigger.

```
  always-on:  Spine (the loop, the rules, the discipline)
  on-trigger: skills/  (this manifest, pulled by description match, never all)
```

---

## PROCESS · think before you build, debug to root cause, prove before done

The discipline skills. They gate the sloppy defaults: writing code before the
design is stated, patching a symptom instead of the cause, declaring "done"
without proof.

| Skill | What it does | Trigger |
|---|---|---|
| `brainstorming` | Forces intent -> requirements -> design before any code. States assumptions, surfaces options with trade-offs, picks one with a reason. The brainstorm beat of the Spine. | "let's build X", "add a feature", "new component", any creative work before implementation |
| `systematic-debugging` | Root-cause before fix. Measure every boundary, reproduce, isolate, name the cause, then patch the cause not the symptom. No guessing which port or service is at fault. | a bug, a test failure, "it's broken", unexpected behavior, "why is X happening" |
| `writing-plans` | Turns a spec or a multi-step task into a short, checkable plan: `1. [step] -> verify: [check]`. Each step carries its own success criterion. | "plan this out", a multi-step task with a spec, before touching code on anything non-trivial |
| `verification-before-completion` | The proof gate. Builds the untested-assumptions list and refuses "done" until it is **0**. Pairs with the verify beat: curl 200 (not 307/302), every link clicked, screenshot of the LIVE url. | "is it done", "ship it", before declaring complete / live / merged |

---

## BUILD · the writing surfaces

Capability modules for the single-threaded writer. One writer holds the context;
these are the lenses it builds through. (Per the orchestration rule, you do not
fan these out to parallel writers.)

| Skill | What it does | Trigger |
|---|---|---|
| `frontend-design` | Distinctive, production-grade UI. Avoids generic AI-slop aesthetics: one coherent accent, premium dark, real hierarchy. Hand-crafted, never a mechanical find-replace recolor. | "build a page", "design the UI", "landing page", "dashboard", "component", styling any web surface |
| `api-design` | REST design patterns: resource naming, status codes, pagination, filtering, error shapes, versioning, rate limiting. The contract before the handler. | "design the API", "new endpoint", "REST route", "how should this API look" |
| `database-migrations` | Safe, reversible schema change. Forward + rollback, no lock-heavy full-table rewrites, index before you query, seed the minimum to test the real path. | "add a migration", "change the schema", "new table/column", "migrate the DB" |
| `tdd-workflow` | Red -> green -> refactor. Write the failing test for the input you care about first, make it pass, then clean. "Add validation" becomes "write tests for invalid input, make them pass". | "write tests", "TDD this", "test-driven", "cover this with tests" |

---

## REVIEW / SHIP · the gate and the ship loop

The lean tactical backbone, in the lineage of `garrytan/gstack` and
`vercel-labs/agent-browser`. Review fans out (read-heavy, merges clean); shipping
proves on the LIVE app, not just the tests.

| Skill | What it does | Trigger |
|---|---|---|
| `code-review` | The judge panel as a skill: 4 to 6 **dimension-based** reviewers (SQL, Auth, Infra, API, Frontend, Cost), blind in parallel, then debate, then a Supreme Judge adjudicates. Pinned `model: opus` to kill cross-run variance. The burn is real (~150k-350k tokens, ~$3-20, 6-15 min): spend it on diffs that matter. | "review this diff", "code review", before a merge on auth / money / migrations |
| `security-review` | The Auth/secrets/injection lens, focused: authz holes, token handling, command injection, XSS, SQL injection, leaked credentials, unsafe deserialization. Refutes each finding before reporting it (adversarial verify). | "security review", "is this safe", before shipping anything touching auth, payments, user input |
| `browse` | Headless-browser dogfooding (ref `garrytan/gstack`, `vercel-labs/agent-browser`): navigate, click, screenshot, diff before/after, ~100ms per command. Verify the **real running app**, not just the test suite. | "does it actually work", "check the live site", "screenshot it", "dogfood this", the verify beat |
| `ship` | The auto-review pipeline (`gstack autoplan` style): runs CEO / design / eng / DX review skills in sequence and surfaces every taste decision at **one** approval gate. Then the E2E proof gate, then commit + push (push asks first). | "ship it", "deploy", "let's release", "send it" |
| `wrapup` | The single end-of-work button. Learn (persist what the session taught), commit, push, deploy, update the whiteboard/handoff, close clean. The last beat of the Spine, available in every repo. | "wrap up", "close this out", "that's it", "finaliza", end of a work session |

> **Destructive-command guard** runs under `ship` and `wrapup` (in the spirit of
> `nazt/destructive_command_guard`): `rm -rf`, force push, and `DROP TABLE`
> require explicit confirmation. It is a guardrail, not a skill you trigger.

---

## ORCHESTRATION · fan out to read, the deep harnesses

The fan-out layer as triggerable skills. These spawn the coordinator + workers
topology described in `harness/orchestration/`. They fan out to **read and
verify**, never to write code in parallel.

| Skill | What it does | Trigger |
|---|---|---|
| `deep-research` | The fan-out research harness: spreads web searches and source fetches across scouts, adversarially verifies each claim (N skeptics prompted to refute, majority refutes -> kill), then synthesizes a cited report. Loop-until-dry, no silent caps. One coordinator, many scouts. | "research X deeply", "multi-source report", "fact-check this", "what's the SOTA on Y" |
| `autoplan` | The sequential review pipeline (CEO / design / eng / DX lenses) that backs `ship`. Runs the workflow scripts in `harness/orchestration/workflows/`, collects every taste decision, presents them at one gate. | "run the full review", "auto-plan this", before a meaningful release |
| *(workflow examples)* | Runnable pipeline / parallel / judge-panel / loop-until-dry scripts in `harness/orchestration/workflows/`. Copy one, swap your stages. Pipeline is the default; reach for a barrier or a panel only when the stage genuinely needs all prior results. | invoked by `deep-research`, `code-review`, `autoplan`; or copied directly when wiring a custom fan-out |

> **Heavy SDLC** (PRD -> sharded epics -> stories -> `@dev @qa @architect @pm @po
> @sm` squad -> gates + constitution, BMAD-METHOD / AIOX lineage) ships in
> `harness/sdlc/` as an **optional plug-in**, not a default skill. Use it for
> formal greenfield with a real PRD and auditable gates. Skip it for solo
> tactical work: the ceremony kills momentum.

---

## Add your own skill

A skill is just a folder. Drop it in `skills/` and it is live on its next
trigger:

```
skills/
└── your-skill/
    └── SKILL.md      # name + description + triggers in the frontmatter
```

The `SKILL.md` frontmatter is the whole contract. `name` and `description` are
required; the description is what gets matched, so write it like a trigger list,
not a tagline.

```markdown
---
name: changelog-writer
description: >
  Generate or update a CHANGELOG entry from the current diff. Use when the user
  says "update the changelog", "add a changelog entry", "what changed", or after
  a release is cut. Groups commits by type (feat / fix / chore), links PRs.
triggers:
  - "update the changelog"
  - "changelog entry"
  - "what changed in this release"
---

You write changelog entries. Read the diff or the commit range, group by
Conventional Commit type, write one line per change in plain language...
```

Rules that keep the kit sharp:

- **Trigger-first descriptions.** The model picks a skill by matching its
  description. List the phrases that should fire it. A vague description never
  triggers (or triggers on everything, which is worse).
- **One job per skill.** A skill that does five things triggers on none of them
  cleanly. Split it.
- **Scope the tools.** If the skill body grants tools, grant the narrow set the
  job needs. A reviewer skill does not need `Write`.
- **Generic and reusable.** This kit is the foda, broadly-useful set. Keep
  client-specific or one-off logic out of `skills/`; put it in your private
  `brain/`, which is gitignored per instance.

That is the whole extension model. One folder, one `SKILL.md`, on trigger.

---

## Departamentos empacotados (kit da Be Human · 2026-06-16)

Além do core de processo/eng acima, o kit agora traz as skills de operação da Be Human
(Tier 1 + Tier 2), carregadas on-trigger por descrição como qualquer outra:

- **Vendas:** `sales-prep · sales-proposal · sales-icp · sales-objections · sales-outreach · sales-qualify · sales-followup · sales-research · sales-enablement · sales · sales-report · sales-report-pdf · sales-competitors · sales-contacts · cold-email · email-sequence`
- **Marketing/conteúdo:** `copywriting · copywriter · copy-editing · content-strategy · content-planner · content-researcher · post-writer · social-content · marketing-psychology · marketing-ideas · launch-strategy`
- **CRO:** `page-cro · form-cro · popup-cro · onboarding-cro · signup-flow-cro · paywall-upgrade-cro`
- **SEO:** `seo-audit · ai-seo · schema-markup · programmatic-seo · site-architecture`
- **Design/visual:** `design-md · deck · anthropic-frontend-design · ui-ux-pro-max · logo-designer · visual-storytelling · carousel-designer · brand-guidelines`
- **Biz/pricing:** `pricing-strategy · business-growth · revops · c-level-advisor · cso · finance-advisor · competitor-alternatives`
- **Eng disciplina:** `skill-creator · writing-skills · executing-plans · using-git-worktrees · subagent-driven-development · mcp-builder · eval-harness · devex-review`
- **Ferramentas (Tier 2):** `composio-cli · slack-messaging · mcp-cli · generate-image · transcribe-video · make-pdf · hyperframes · hyperframes-cli · hyperframes-media · contract-review · document-generate · architecture-diagram`

