# SDLC Module (optional)

> Heavy, story-driven SDLC frameworks. Ship them as a plug-in, not as the spine.

This module exists for one reason: sometimes a project genuinely needs PRDs, role
gates, and an auditable paper trail. Most of the time it does not. This doc tells
you which case you are in, plainly, so you do not bolt ceremony onto work that
wanted flow.

The be-human-harness default is the opposite of this module: a lean spine plus on-demand
fan-out. You opt INTO heavy SDLC per project. You never inherit it.

---

## 1. What these frameworks are

Lineage: BMAD-METHOD and Synkra-AIOX. Both encode the classic software lifecycle
into an agent squad with formal handoffs. CLI-first, version-controlled, repeatable.

The shape:

```
PRD (the source of truth)
  -> sharded epics            (PRD split into shippable slices)
       -> stories             (one unit of work, acceptance criteria attached)
            -> role squad      executes the story:
                 @pm      owns scope and priorities
                 @po      owns backlog and acceptance
                 @sm      runs the cadence, unblocks
                 @architect  owns the technical design
                 @dev     writes the code
                 @qa      writes/runs tests, signs off
                 @devops  ships and operates
            -> quality gates   (each story passes defined checks before "done")
  + a constitution            (the rules every agent obeys: standards, definitions of done, non-negotiables)
```

The value is the structure itself: nothing advances without a story, no story
closes without passing its gate, and the constitution keeps every agent honest.
That structure is also the cost. Every arrow above is a handoff, and every handoff
is overhead you pay whether or not the work needed it.

---

## 2. When it HELPS

Use heavy SDLC when the work is formal, shared, and long-lived. The ceremony pays
for itself because the project has real stakeholders who need to trust the gates.

| Signal | Why the framework earns its keep |
|---|---|
| Real PRD exists (or must exist) | Stories shard cleanly from a written spec; no spec, no point |
| Greenfield with a defined scope | Epics/stories map a fresh build; less friction than retrofitting onto a live codebase |
| Multiple stakeholders | @pm/@po roles give scope and acceptance an explicit owner each |
| Long-lived product (months/years) | The story trail and constitution stay valuable long after the original author leaves |
| Auditable gates required | Compliance, client sign-off, regulated domains: you need to PROVE each gate passed |
| Team of agents/people in parallel | Roles and gates prevent two contributors from making conflicting calls |

Rule of thumb: if a stakeholder will later ask "show me the gate that approved
this", you want this module. If nobody will ever ask, you do not.

---

## 3. When it is OVERHEAD

The same structure that protects a formal build strangles tactical work. If you are
one person moving fast, every handoff is a tax with no payer.

| Situation | What the ceremony does to it |
|---|---|
| Solo tactical work | You write the story, assign it to yourself, gate it yourself. Pure theater. |
| Exploration / spike | You do not have a PRD yet because you are figuring out IF there is one. Stories presuppose an answer you are still hunting. |
| Quick fix / one-liner | Drafting a story to change three lines costs 10x the fix. |
| Flow-state building | The handoffs break the loop. Momentum dies in the gate queue. |
| Rapidly shifting scope | Sharded epics assume scope holds still. When it moves daily, you spend the day re-sharding. |

The failure mode is real and common: a solo builder adopts the full squad, spends
more time feeding the process than shipping, and mistakes the paperwork for progress.
Ceremony does not make tactical work safer. It makes it slower and calls the slowness
rigor.

---

## 4. The verdict

**Ship heavy SDLC as an OPTIONAL plug-in module. Never as the default backbone.**

The be-human-harness backbone is lean and tactical:

```
DEFAULT (always on)
  lean spine            small, sharp instruction set; no mandatory roles or gates
  on-demand fan-out     spin up scouts to read/verify when a task needs breadth
  verify/ship loop      headless-browser dogfooding + E2E proof-before-done
                        (curl 200 not 307, click every link, screenshot the LIVE url,
                         untested-assumptions list must be 0)

OPTIONAL (opt in per project)
  SDLC module           BMAD/AIOX squad, PRD -> stories -> gates + constitution
                        loaded ONLY for the project that needs the paper trail
```

Why this split, stated plainly:

- The backbone has to be fast, because most work is tactical and most tactical work
  dies under ceremony.
- The fan-out is read-heavy by design. Scout out to READ and VERIFY (search, review,
  audit) where many independent passes merge cleanly. Stay single-threaded to WRITE
  code, because parallel writers fragment context and produce merge hell. One writer,
  many scouts.
- Heavy SDLC is the exception you reach for, not the floor you stand on. Making it the
  default would tax every quick fix to protect the rare formal build. Wrong trade.

The honest tradeoff in one line: **structure buys auditability and multi-stakeholder
safety; it sells momentum and speed.** Pick the side the project is actually on.

---

## 5. How to opt in

Conceptually, three steps. No framework lock-in, no global switch.

1. **Drop the framework into the repo.** Vendor the BMAD-METHOD or Synkra-AIOX squad
   (agents, constitution, story templates) into the project that needs it, for example
   under `.bmad/` or `.aiox/`. It lives with that project, version-controlled, scoped.

2. **Point the agent at it for that project.** Reference the squad and constitution
   from the project's own context file (`AGENTS.md` / `CLAUDE.md`), so the heavy
   process loads only when you are working inside that repo. Other projects never see
   it.

3. **Start the lifecycle.** Write or import the PRD, shard it into epics and stories,
   and let the role squad run the gates. From here the framework drives; the lean spine
   steps aside for this project only.

To back out: remove the reference from the project context file. The squad goes dormant
and you are back on the lean default. Opt-in stays opt-in.

---

## TL;DR

- Heavy SDLC (BMAD-METHOD / Synkra-AIOX) = PRD -> epics -> stories -> role squad -> gates + constitution.
- It HELPS formal, greenfield, multi-stakeholder, long-lived, audit-required work.
- It is OVERHEAD on solo, exploratory, quick, flow-state work. Ceremony kills momentum.
- be-human-harness default = lean spine + on-demand fan-out. SDLC is an OPTIONAL plug-in.
- Opt in by vendoring the squad into one repo and pointing that repo's context at it. Opt out by removing the pointer.
