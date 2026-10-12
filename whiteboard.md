# 🪧 Whiteboard

> Your status board. The agent is a teammate, not a black box: it logs every material move here so you read top-down and know exactly where things stand without asking.
> Sections are ordered for a 10-second scan: what is live right now, what needs your call, what is queued, what shipped, and the decisions behind it all.

---

## 🟢 NOW

What the agent is actively working on this turn. One line per thread. Cleared when it moves to DONE.

- _(example)_ Wiring the judge-panel review skill into the ship pipeline: 5 dimension reviewers (SQL, Auth, Infra, API, Cost) running blind, then a Supreme Judge adjudicates. Single writer applies the verdict.

---

## 💬 FOR YOU (needs your call)

Anything blocked on a human decision: money, a prod deploy, a `git push`, an irreversible action, or a real product/strategy trade-off. The agent stops here and waits. It leads with a recommendation, never a neutral menu.

- _(example)_ Recommend switching the default fan-out from `parallel` (barrier) to `pipeline` (item-level streaming) for the enrichment run. Pipeline is the SOTA default; a barrier only buys us anything when a stage needs ALL prior results (dedup, cross-compare). Give me the go and I flip it.

---

## 🔜 NEXT

Queued work, ordered. Top of the list is what the agent picks up after NOW clears. Not started yet.

- _(example)_ Add `isolation: worktree` to the two subagents that edit overlapping files in `src/`, so parallel edits stop colliding. Worktree only for those two (it is expensive); the read-only scouts stay shared-context.

---

## ✅ DONE (dated)

Shipped and verified, newest first. "Done" means proven: build green, curl 200 (not 307/302), each internal link clicked, screenshot of the live URL. Untested-assumptions list = 0.

- _(example, YYYY-MM-DD)_ Shipped the headless-browser dogfood check (browse-style: navigate -> click -> screenshot -> diff before/after, ~100ms/cmd). Verified against the real running app, not just the test suite. Live URL returned 200, all 4 internal links 200, screenshot attached.

---

## 🧠 KEY DECISIONS (dated)

The "why" log, append-only, newest first. Architecture calls, trade-offs taken, patterns adopted or rejected. This is what a fresh agent (or you, in three months) reads to avoid re-litigating settled ground.

- _(example, YYYY-MM-DD)_ Orchestration rule of the repo: fan out to READ and VERIFY (search, review, audit: independent, read-heavy, conclusions merge clean), stay SINGLE-THREADED to WRITE code (parallel writers = fragmented context plus merge hell). One writer, many scouts. Reconciles Cognition's "Don't Build Multi-Agents" with Anthropic's "Multi-Agent Research System".
- _(example, YYYY-MM-DD)_ Heavy SDLC ceremony (PRD -> sharded epics -> stories -> @dev/@qa/@architect squad, BMAD-METHOD / Synkra-AIOX lineage) ships as an OPTIONAL module, not the default backbone. It earns its keep on formal greenfield with real stakeholders and auditable gates; it kills momentum on solo tactical flow. Default backbone stays lean: gstack-style verify/ship plus a JS workflow layer for fan-out.
