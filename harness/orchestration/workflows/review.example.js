// review.example.js
//
// Canonical review workflow for be-human-harness. Copy this, swap the DIMENSIONS, run it.
//
// THE SHAPE (one writer, many scouts. See harness/orchestration/README.md):
//
//   DIMENSIONS ─► pipeline:
//                   stage 1: agent() reviews one dimension  -> findings[]
//                   stage 2: parallel() of N skeptics       -> verdict per finding
//                 ─► keep only findings the skeptics could NOT refute
//
//   +------------+   review     +-----------+  adversarial verify  +-----------+
//   | bugs       | ───────────► | findings  | ───────────────────► | confirmed |
//   | security   |   (agent)    | per dim   |   (parallel skeptics)| findings  |
//   | perf       |              +-----------+                      +-----------+
//   +------------+
//
// Review is read-heavy and independent: each dimension is a scout, conclusions
// merge cleanly. This is exactly the "fan out to READ and VERIFY" case. We never
// fan out to WRITE: nothing here edits a file, so no worktree isolation, no merge
// hell. The single writer (you, or a downstream fix script) integrates after.

// ---------------------------------------------------------------------------
// meta: every workflow exports this. The harness reads it to label the run and
// render progress. phases[] are the user-visible stages of THIS script.
// ---------------------------------------------------------------------------
export const meta = {
  name: 'review',
  description:
    'Review a diff across independent dimensions, then adversarially verify ' +
    'each finding before reporting it. Pipeline by default, parallel only for ' +
    'the per-finding skeptic panel.',
  phases: [{ title: 'Review' }, { title: 'Verify' }],
};

// ---------------------------------------------------------------------------
// DIMENSIONS: review axes, not role tags. "bugs", "security", "perf" each catch
// a different defect class. A "senior engineer" reviewer is a blur; a dimension
// reviewer has one lens and one job. Add or drop axes to match what your change
// actually risks (auth, sql, infra, cost, api, frontend, ml, ...). This is the
// dimension-based reviewer idea from wan-huiyan/agent-review-panel, minus the
// full blind-debate-judge ceremony (that is the heavyweight judge-panel pattern,
// overkill for a routine diff. Reach for it only when the stakes justify the
// ~150k-350k token / ~$3-20 burn).
// ---------------------------------------------------------------------------
const DIMENSIONS = [
  {
    id: 'bugs',
    title: 'Correctness',
    brief:
      'logic errors, off-by-one, null/undefined deref, unhandled rejections, ' +
      'race conditions, wrong control flow, broken edge cases.',
  },
  {
    id: 'security',
    title: 'Security',
    brief:
      'injection (sql/command/xss), authz gaps, secrets in code, unsafe ' +
      'deserialization, missing input validation, path traversal.',
  },
  {
    id: 'perf',
    title: 'Performance',
    brief:
      'N+1 queries, work inside hot loops, sync I/O on the request path, ' +
      'unbounded memory growth, missing indexes, needless re-renders.',
  },
];

// Schema for what a reviewer returns. Schemas keep agents honest: the harness
// rejects output that does not match, so a finding is always actionable, never
// a wall of prose. One object per problem found.
const findingSchema = {
  type: 'array',
  items: {
    type: 'object',
    required: ['title', 'location', 'severity', 'evidence', 'claim'],
    properties: {
      dimension: { type: 'string' }, // stamped by us after the review returns
      title: { type: 'string' },
      location: { type: 'string', description: 'file:line or symbol' },
      severity: { type: 'string', enum: ['low', 'medium', 'high', 'critical'] },
      evidence: { type: 'string', description: 'the exact code/path that shows it' },
      claim: { type: 'string', description: 'one sentence: what is wrong and why' },
    },
  },
};

// Schema for a single skeptic's verdict on a single finding.
const verdictSchema = {
  type: 'object',
  required: ['refuted', 'reason'],
  properties: {
    refuted: { type: 'boolean', description: 'true = the finding does NOT hold' },
    reason: { type: 'string', description: 'one line: why it holds or why it does not' },
  },
};

// How many independent skeptics vote on each finding. Odd number so "majority
// refutes" never ties. Each runs in its own fresh context (it sees the finding,
// not the other skeptics, not the reviewer's reasoning), so their refutations
// are genuinely independent rather than three copies of one bias.
const SKEPTICS_PER_FINDING = 3;

// ---------------------------------------------------------------------------
// run(): the workflow entrypoint. The harness injects the documented hooks:
//
//   agent(prompt, { label, phase, schema })  one fresh-context subagent.
//                                            schema -> structured, validated output.
//   pipeline(items, stage1, stage2)          stream items through stages with NO
//                                            barrier: stage2 starts on item 1 while
//                                            stage1 is still on item 2.
//   parallel(thunks)                         run thunks concurrently, BARRIER: wait
//                                            for all, return results in order.
//   phase(title)                             mark the active user-visible phase.
//   log(...)                                 structured run log (also where you
//                                            record anything you intentionally drop).
// ---------------------------------------------------------------------------
export async function run({ agent, pipeline, parallel, phase, log }, input) {
  const target = input?.diff ?? input?.target ?? 'the current working diff';
  log(`reviewing ${target} across ${DIMENSIONS.length} dimensions`);

  // -- STAGE 1 (review) ------------------------------------------------------
  // One reviewer per dimension. Read-only scout: it inspects, it does not edit.
  async function review(dim) {
    phase('Review');
    const findings = await agent(
      [
        `You are the ${dim.title} reviewer. You review ONE dimension only: ${dim.brief}`,
        ``,
        `Review ${target}. Report ONLY real, concrete problems in your dimension.`,
        `Do not report style nits, speculation, or anything outside ${dim.id}.`,
        `Every finding needs an exact location and the evidence that proves it.`,
        `If the diff is clean for your dimension, return an empty array.`,
      ].join('\n'),
      { label: `review:${dim.id}`, phase: 'Review', schema: findingSchema },
    );
    // Stamp the dimension so downstream stages know each finding's origin.
    return findings.map((f) => ({ ...f, dimension: dim.id }));
  }

  // -- STAGE 2 (verify) ------------------------------------------------------
  // For each batch of findings from one dimension, adversarially verify every
  // finding. parallel() here is correct (not pipeline): the SKEPTICS for one
  // finding form a barrier on purpose, we need ALL their votes before we can
  // tally "majority refutes". A barrier is right exactly when a step needs the
  // whole set. That is the rule for choosing parallel over pipeline.
  async function verify(findings) {
    if (findings.length === 0) return [];
    phase('Verify');

    const checked = [];
    for (const f of findings) {
      // N independent skeptics, each PROMPTED TO REFUTE. A lone reviewer suffers
      // confirmation bias: it wants to agree with the thing it just wrote.
      // Skeptics whose explicit job is to break the claim cancel that bias.
      // A finding that survives 3 hostile readers is real; one that dies under
      // them was noise we caught before wasting your time (or worse, a wrong fix).
      const skeptics = Array.from({ length: SKEPTICS_PER_FINDING }, (_, i) =>
        () =>
          agent(
            [
              `You are an adversarial verifier. Your ONLY goal is to REFUTE the`,
              `finding below. Assume it is wrong until the evidence forces otherwise.`,
              ``,
              `Finding (${f.dimension}, ${f.severity}): ${f.title}`,
              `Location: ${f.location}`,
              `Claim: ${f.claim}`,
              `Evidence: ${f.evidence}`,
              ``,
              `Check the actual code at that location. Set refuted=true if the`,
              `claim does NOT hold (wrong, already handled, not reachable, false`,
              `positive). Set refuted=false only if you genuinely cannot break it.`,
            ].join('\n'),
            {
              label: `verify:${f.dimension}#${i + 1}`,
              phase: 'Verify',
              schema: verdictSchema,
            },
          ),
      );

      // BARRIER: collect all skeptic votes for THIS finding before tallying.
      const verdicts = await parallel(skeptics);
      const refutes = verdicts.filter((v) => v.refuted).length;
      const confirmed = refutes < Math.ceil(SKEPTICS_PER_FINDING / 2); // majority refutes -> kill

      if (confirmed) {
        checked.push({
          ...f,
          confirmed: true,
          votes: { refutes, total: SKEPTICS_PER_FINDING },
        });
      } else {
        // no silent caps: log every finding we drop and why, so the result is
        // visibly partial-on-purpose, never a quiet truncation.
        log(
          `dropped ${f.dimension} finding "${f.title}": ${refutes}/${SKEPTICS_PER_FINDING} ` +
            `skeptics refuted it (${verdicts.map((v) => v.reason).join(' | ')})`,
        );
      }
    }
    return checked;
  }

  // -- WIRE IT --------------------------------------------------------------
  // pipeline streams each dimension's review STRAIGHT into verification. Why
  // pipeline and not "review all 3, then verify all 3"? No barrier between the
  // stages means the security reviewer's findings get verified WHILE the perf
  // reviewer is still reading. No dimension waits on the slowest one. With a
  // barrier you would pay the latency of the slowest reviewer twice (once to
  // start verifying anything, then again per skeptic batch). Pipeline spends
  // wall-clock only where the work actually is.
  const perDimension = await pipeline(DIMENSIONS, review, verify);

  // pipeline returns one verified batch per item. Flatten into the report.
  const confirmed = perDimension.flat();

  const bySeverity = (s) => confirmed.filter((f) => f.severity === s).length;
  log(
    `confirmed ${confirmed.length} finding(s): ` +
      `${bySeverity('critical')} critical, ${bySeverity('high')} high, ` +
      `${bySeverity('medium')} medium, ${bySeverity('low')} low`,
  );

  // Sorted worst-first so the single writer who fixes these starts at the top.
  const rank = { critical: 0, high: 1, medium: 2, low: 3 };
  confirmed.sort((a, b) => rank[a.severity] - rank[b.severity]);

  return {
    target,
    dimensions: DIMENSIONS.map((d) => d.id),
    confirmed, // each carries its skeptic vote tally, so the verdict is auditable
  };
}

export default run;
