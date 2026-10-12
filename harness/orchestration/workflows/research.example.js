// research.example.js
//
// A runnable be-human-harness workflow: a multi-modal research/audit fan-out that runs
// loop-until-dry, then hands off to a completeness critic. Copy this file,
// swap the angles and the schemas for your target, and ship.
//
// What it teaches (the four moves you will reuse everywhere):
//   1. FAN OUT TO READ. Spawn finders across different search ANGLES in
//      parallel. Reading and verifying parallelize cleanly (Anthropic
//      "Multi-Agent Research System"). Writing does not, so there is no writer
//      here. One writer, many scouts. This script is all scouts.
//   2. DEDUP IN PLAIN CODE, not in an agent. A Set lives in the harness. The
//      harness is deterministic and free; an agent asked to "remember what we
//      have seen" is neither. Never spend a context window on bookkeeping a
//      `Set` does in one line.
//   3. LOOP UNTIL DRY. Keep spawning rounds until K consecutive rounds add
//      nothing new, then stop. The corpus tells you when it is exhausted. Beats
//      a guessed --top-N that truncates real results or burns runs on an empty
//      tail.
//   4. COMPLETENESS CRITIC. One final agent asks "what MODALITY did we miss?"
//      It does not redo the work. It checks coverage: which lens never ran,
//      which input got skipped, which assumption stayed unverified. The guard
//      against a confident-but-partial result.
//
// THE KEY TRAP (read this twice):
//   Dedup against EVERYTHING SEEN, not just confirmed findings. If you only add
//   a finding to `seen` after a verifier confirms it, every rejected duplicate
//   stays "unseen" and comes back next round. The loop re-finds the same junk
//   forever and the dry counter never advances. It NEVER converges. Mark a
//   candidate seen the instant a finder emits it. Verification decides whether
//   it ships, not whether it counts as seen. Seen is about convergence;
//   confirmed is about quality. Two different jobs, two different sets.
//
// Hooks the harness injects (same surface as pipeline.example.js):
//   agent({ name, prompt, schema, model?, tools?, maxTurns? }) -> Promise<result>
//       Spawns ONE subagent in a fresh context window. Returns the parsed
//       structured result matching `schema`. Subagents are one level deep:
//       a subagent cannot call agent() again (coordinator + workers topology).
//   parallel(tasks) -> Promise<results[]>
//       Runs an array of () => agent(...) thunks concurrently (barrier: waits
//       for ALL before returning). Use it when a stage needs the whole set,
//       which a per-round dedup does. Concurrency is capped by the harness
//       (~16 at once); it queues the rest, it does not silently drop them.
//   log(...args) -> void
//       Structured run log. Use it at every boundary. A fan-out you cannot
//       replay from the log is a fan-out you cannot trust.

export const meta = {
  name: "research-fanout",
  description:
    "Multi-modal research/audit fan-out. Spawns finders across independent " +
    "search angles, dedups in plain code, loops until K dry rounds, then runs " +
    "a completeness critic that asks what modality we missed.",
  // READ side of the split. No agent in this script writes a file or edits
  // code. Conclusions merge into the caller; nothing forks shared state.
  produces: "read-only", // findings, not code. fan out freely.
  concurrency: 16, // harness cap; angles beyond this queue, they are not dropped.
  estimate: {
    // Be honest about the burn before you trigger it. See orchestration/README "Cost reality".
    tokens: "40k to 120k typical (scales with rounds x angles x corpus size)",
    usd: "~$0.50 to $4 on haiku finders + one sonnet critic",
    wallTime: "1 to 4 min",
  },
};

// ---------------------------------------------------------------------------
// Tuning knobs. The only things you normally touch per target.
// ---------------------------------------------------------------------------

// K consecutive empty rounds == the corpus is dry == stop. Higher K = more
// confidence the tail is truly empty, at the cost of extra (likely wasted)
// rounds. 2 is a sane default; bump to 3 for a corpus with sparse clusters.
const DRY_ROUNDS_TO_STOP = 2;

// Hard ceiling so a pathological corpus (or a finder that hallucinates novelty
// every round) cannot loop forever. This is a SILENT CAP, so we log when we hit
// it. A truncated run that looks complete is worse than a slow one.
const MAX_ROUNDS = 8;

// The search ANGLES. Each is an independent lens on the same target. They run
// in parallel every round because reading parallelizes and their conclusions
// merge with a Set. Different lenses catch different defects by construction;
// one lens has blind spots you cannot see from inside it.
//
// These are MODALITIES, not role tags ("senior engineer"). Same lesson as the
// judge panel: dimensions find different things than personas. Add or drop
// angles to match what your target actually risks.
const ANGLES = [
  {
    id: "by-content",
    lens:
      "Search by TEXT/CONTENT. Grep-style: literal strings, log messages, " +
      "error text, magic constants, copy. Catches what is written down.",
  },
  {
    id: "by-structure",
    lens:
      "Search by STRUCTURE. Call graph, imports/exports, module boundaries, " +
      "dependency edges. Catches what connects to what, regardless of wording.",
  },
  {
    id: "by-entity",
    lens:
      "Search by ENTITY. Named symbols, types, schemas, routes, config keys, " +
      "env vars. Catches the things, not the prose around them.",
  },
  // To add a modality, append here. Examples worth wiring for a web target:
  //   { id: "by-runtime", lens: "Runtime behavior / logs / actual responses." }
  //   { id: "by-cost",    lens: "Cost surface: queries, API calls, token spend." }
  // The completeness critic below will literally ask which of these you skipped.
];

// ---------------------------------------------------------------------------
// Schemas. Structured returns, not freeform prose. The harness parses agent
// output against these; a finder that returns shapeless text is unusable in a
// loop because you cannot dedup or count it.
// ---------------------------------------------------------------------------

// One finding from one finder. `key` is the IDENTITY used for dedup. It must be
// stable across angles: if by-content and by-structure surface the SAME thing,
// they MUST produce the same key, or the Set cannot collapse them and the loop
// double-counts. Normalize hard (lowercase, trim, canonical path) when you
// build it. The key is the whole convergence mechanism; treat it as load-bearing.
const findingSchema = {
  type: "object",
  required: ["key", "title", "where", "confidence"],
  properties: {
    key: {
      type: "string",
      description:
        "STABLE dedup identity, normalized. Same real thing -> same key " +
        "across every angle. e.g. 'auth:missing-rate-limit:src/login.ts'.",
    },
    title: { type: "string", description: "One line, human-readable." },
    where: { type: "string", description: "file:line, route, or symbol anchor." },
    evidence: { type: "string", description: "The proof. Quote/anchor, not a vibe." },
    confidence: { type: "number", description: "0..1 self-rated by the finder." },
  },
};

const finderSchema = {
  type: "object",
  required: ["angle", "findings"],
  properties: {
    angle: { type: "string" },
    findings: { type: "array", items: findingSchema },
    // The finder logs its own truncation. No silent caps: if it stopped early,
    // we want it in the record so the merge knows the round is partial on purpose.
    truncated: { type: "boolean", description: "true if the finder capped itself." },
  },
};

const criticSchema = {
  type: "object",
  required: ["complete", "missedModalities", "gaps"],
  properties: {
    complete: {
      type: "boolean",
      description: "true ONLY if no modality and no input was skipped.",
    },
    missedModalities: {
      type: "array",
      items: { type: "string" },
      description: "Lenses we never ran that this target needed.",
    },
    gaps: {
      type: "array",
      items: { type: "string" },
      description: "Specific skipped inputs / unverified assumptions.",
    },
  },
};

// ---------------------------------------------------------------------------
// Finder agent factory. One subagent, one angle, one round. Read-only, cheap
// model, narrow tool allowlist (a scout that can Write is a writer in disguise).
// ---------------------------------------------------------------------------

function finderFor(angle, target, alreadySeenKeys) {
  return () =>
    agent({
      name: `finder:${angle.id}`,
      model: "haiku", // finders are cheap and many. Save opus/sonnet for the critic.
      tools: ["Read", "Grep", "Glob"], // read-only, on purpose. No Write/Edit/Bash.
      maxTurns: 20,
      schema: finderSchema,
      prompt:
        `You are a research finder running the "${angle.id}" angle.\n` +
        `LENS: ${angle.lens}\n\n` +
        `TARGET:\n${target}\n\n` +
        // Tell the finder what is already claimed so it spends its turns on NEW
        // ground, not re-deriving the known. This is an optimization, NOT the
        // dedup itself. The harness Set is the source of truth; never trust an
        // agent to be the dedup authority across rounds (it has no memory of
        // sibling angles). Belt: prompt. Suspenders: the Set below.
        `ALREADY FOUND (do not repeat these keys):\n` +
        (alreadySeenKeys.length
          ? alreadySeenKeys.map((k) => `  - ${k}`).join("\n")
          : "  (nothing yet, this is round 1)") +
        `\n\n` +
        `Return ONLY genuinely NEW findings through your lens. Build each ` +
        `'key' so the SAME real thing gets the SAME key no matter which angle ` +
        `finds it (lowercase, trimmed, canonical path). If you cap your own ` +
        `output, set truncated:true. Findings, not prose.`,
    });
}

// ---------------------------------------------------------------------------
// The workflow.
// ---------------------------------------------------------------------------

export default async function run({ target }) {
  log("research-fanout: start", { angles: ANGLES.map((a) => a.id), target });

  // PLAIN-CODE dedup state. Lives in the harness, not in an agent.
  //
  // `seen` = every key any finder has EVER emitted this run. This is what the
  // loop dedups against and what drives convergence. See THE KEY TRAP at the
  // top: a key enters `seen` the instant it is emitted, BEFORE any quality
  // judgment. If you gate entry on confirmation, the loop never converges.
  const seen = new Set();

  // `findings` = the actual result payload, keyed for O(1) merge. First emitter
  // of a key wins the slot; later duplicates are dropped (already in `seen`).
  const findings = new Map();

  let dryRounds = 0;
  let round = 0;

  // loop-until-dry: stop after K consecutive rounds that add nothing new.
  while (dryRounds < DRY_ROUNDS_TO_STOP && round < MAX_ROUNDS) {
    round += 1;
    const seenSnapshot = [...seen]; // pass the round its starting knowledge.

    log(`round ${round}: spawning ${ANGLES.length} finders`, {
      seenSoFar: seen.size,
      dryRounds,
    });

    // FAN OUT: all angles this round, in parallel. parallel() is a barrier on
    // purpose: dedup is a stage that needs the WHOLE round's results before it
    // can decide novelty. (A pure pipeline with no barrier could not count
    // "new this round" correctly.) This is the textbook case for parallel over
    // pipeline: the next step needs all prior results at once.
    const results = await parallel(
      ANGLES.map((angle) => finderFor(angle, target, seenSnapshot)),
    );

    // MERGE + DEDUP in plain code. Count what is genuinely new THIS round.
    let newThisRound = 0;
    for (const res of results) {
      if (res.truncated) {
        // no silent caps: a capped finder means this angle is partial. Record it.
        log(`  angle ${res.angle} self-truncated (partial coverage)`, {});
      }
      for (const f of res.findings || []) {
        // THE TRAP, enforced in one branch: mark seen on FIRST sight, period.
        // Not "if confidence > X", not "if a verifier confirms". Seen-ness is
        // about convergence and is unconditional. Quality filtering happens
        // later, downstream, and never feeds back into `seen`.
        if (seen.has(f.key)) continue; // already counted in a prior round/angle.
        seen.add(f.key);
        findings.set(f.key, { ...f, foundInRound: round, foundByAngle: res.angle });
        newThisRound += 1;
      }
    }

    if (newThisRound === 0) {
      dryRounds += 1;
      log(`round ${round}: DRY (0 new). dryRounds=${dryRounds}/${DRY_ROUNDS_TO_STOP}`, {});
    } else {
      dryRounds = 0; // any novelty resets the dry counter. The tail must be clean.
      log(`round ${round}: +${newThisRound} new (total ${findings.size}). dry reset`, {});
    }
  }

  if (round >= MAX_ROUNDS && dryRounds < DRY_ROUNDS_TO_STOP) {
    // We hit the ceiling before the corpus went dry. This result is PARTIAL on
    // purpose. Logging it is non-negotiable: a truncated run that looks
    // complete is worse than a slow one.
    log("STOP: hit MAX_ROUNDS before dry. result is PARTIAL.", {
      round,
      total: findings.size,
    });
  } else {
    log(`STOP: corpus dry after ${dryRounds} empty rounds.`, {
      rounds: round,
      total: findings.size,
    });
  }

  // COMPLETENESS CRITIC. One agent, fresh context, single job: not to re-find,
  // but to name the MODALITY we never ran. The finders only know the angles we
  // gave them; the critic's value is seeing the gap in the angle LIST itself.
  // Pairs with the E2E rule: if its gap list is non-empty, this is not done.
  log("spawning completeness critic", {});
  const critique = await agent({
    name: "completeness-critic",
    model: "sonnet", // worth a stronger model: judging coverage is the hard part.
    tools: ["Read", "Grep", "Glob"],
    maxTurns: 15,
    schema: criticSchema,
    prompt:
      `You are a completeness critic. Do NOT redo the search. Judge COVERAGE.\n\n` +
      `TARGET:\n${target}\n\n` +
      `ANGLES THAT RAN:\n${ANGLES.map((a) => `  - ${a.id}: ${a.lens}`).join("\n")}\n\n` +
      `FINDINGS COLLECTED (${findings.size} total):\n` +
      [...findings.values()]
        .map((f) => `  - [${f.foundByAngle}] ${f.title} (${f.where})`)
        .join("\n") +
      `\n\n` +
      `Question: what MODALITY did we miss? Which lens was never run, which ` +
      `input got skipped, which assumption stayed unverified? Set complete:true ` +
      `ONLY if nothing material was skipped. List missed modalities and gaps ` +
      `concretely so the caller can run another sweep if needed.`,
  });

  if (!critique.complete) {
    // Honest, not silent. The caller decides whether to add the missed angles
    // to ANGLES and run again. The critic flags the gap; it does not auto-loop
    // (a critic that re-triggers the whole fan-out is how a $4 run becomes $40).
    log("INCOMPLETE: critic found missed modalities.", {
      missedModalities: critique.missedModalities,
      gaps: critique.gaps,
    });
  } else {
    log("COMPLETE: critic confirmed coverage.", {});
  }

  return {
    findings: [...findings.values()],
    rounds: round,
    converged: dryRounds >= DRY_ROUNDS_TO_STOP, // false == we hit MAX_ROUNDS (partial)
    complete: critique.complete,
    missedModalities: critique.missedModalities,
    gaps: critique.gaps,
  };
}

// ---------------------------------------------------------------------------
// Why these choices (the senior-engineer footnotes):
//
// * Two sets, not one. `seen` (convergence) and the confirmed/shipped set
//   (quality) are different jobs. Conflating them is THE bug that kills the
//   loop. If you remember one thing from this file, remember that.
//
// * Dedup is plain code, never an agent. The harness is deterministic, free,
//   and instant. An agent asked to "track what we've seen" forgets across
//   rounds (fresh context each spawn) and costs tokens to do worse what a Set
//   does perfectly. Bookkeeping is the harness's job; thinking is the agent's.
//
// * parallel() (barrier) here, not pipeline(). The default everywhere else is
//   pipeline (no barrier, item streaming). But per-round dedup needs the WHOLE
//   round before it can judge novelty, so this is the legitimate barrier case.
//   Don't cargo-cult parallel() onto stages that don't need all prior results;
//   it just makes you wait for the slowest finder for nothing.
//
// * Finders on haiku, critic on sonnet. Finders are many and cheap and bounded;
//   the critic does the one genuinely hard judgment (coverage of the angle list
//   itself), so it gets the better model. Match model spend to the difficulty
//   of the call, not uniformly.
//
// * Read-only, one level deep. No agent here writes or edits (this is the READ
//   side of the split: fan out to read, single-thread to write). And no finder
//   calls agent() (subagents are one level deep, coordinator + workers). If you
//   want the findings ACTED ON, the single writer is the caller of this run(),
//   not a worker inside it.
// ---------------------------------------------------------------------------
