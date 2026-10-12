# harness/verify · the ship/verify loop

> The discipline that keeps shipped work from breaking. Tactical tooling at SOTA, gstack-style.
>
> Writing code is cheap now. Knowing it actually works is the bottleneck. This module is the law that
> sits between "the model finished" and "it's live". Nothing ships until it has material proof.

The core rule, stated once:

```
A claim of "done" or "live" is a LIE until proven with material evidence.
No proof -> not done. Untested-assumptions list > 0 -> not done.
```

Everything below is the runbook for producing that proof.

---

## 0. The pipeline (where verify sits)

```
build (single writer)
   -> verify ........... E2E proof-before-done  (§1)
   -> dogfood .......... headless-browser, real running app  (§2)
   -> auto-review ...... CEO / design / eng / DX lenses, one gate  (§3)
   -> guard ............ destructive-command block  (§5)
   -> deploy
   -> canary ........... post-deploy monitoring  (§4)
   -> declare healthy   ONLY after canary is green
```

Verify is read-heavy and parallelizable: fan out scouts to navigate, click, review, and audit
independently, then merge their conclusions. Keep WRITING single-threaded (one writer, many scouts).
This is the one reconciliation of Cognition "Don't Build Multi-Agents" vs Anthropic "Multi-Agent
Research System": **fan out to read and verify, stay single-threaded to write.**

---

## 1. E2E proof-before-done (the law)

You may not say "done", "live", "shipped", or "it works" until you have produced the proof for the
relevant column below. This is not optional and not a vibe check.

| You claim | Material proof required (NOT a substitute) |
|---|---|
| "API endpoint is up" | `curl -i` returns **200** (not 307, not 302, not "it should"). Real payload, real shape. |
| "Page is live" | `curl` the LIVE url -> 200. **Click every internal link** -> each 200. Screenshot of the LIVE url. |
| "Data is saved" | Query the **real DB**. Row exists, columns correct. Not "the insert returned no error". |
| "Auth works" | Logged-out request -> 401/redirect. Logged-in request -> 200. Both observed. |
| "Integration works" | Call the external API with a **real payload**, confirm status + return shape against its docs. |
| "Build is green" | Build/lint/test actually ran and exited 0. Paste nothing, just verify it ran. |

### Redirects are not success

A `307` or `302` is the single most common false "live". Auth middleware bouncing your new public route
to `/login` looks like the page loads in a browser session but is dead to everyone else. **`curl 200` or
it is not live.**

### Links are absolute, always

Reports/pages serve without a trailing slash, so `../sibling/` resolves one level too high and 404s.
Internal links are **absolute** (`/section/slug`), never relative (`../slug/`). Click each one.

### The untested-assumptions list

Before declaring done, write the assumptions you have NOT verified, in 3 to 5 lines:

```
UNTESTED:
- assumed the DB collection is seeded   (NOT checked, could be empty -> fallback path)
- assumed SDK v3 default tool versions  (NOT checked against docs)
- assumed entityId format matches stored connections
```

**If this list is longer than 0 lines, you are not done.** Go verify each item or kill the claim. This
list existing and being empty is the gate. "100% green" declared three times in a row with a different
bug each time is what this rule exists to kill.

### High-risk trigger

Work that touches **external integration + multi-tenant + async pipeline** (3 of those = high risk) does
NOT get a happy-path assumption. Before "done": check real DB state (collections, indexes, sample docs),
smoke-test the SDK/API directly with a real payload, seed one minimal real case, run it end to end, THEN
generalize.

---

## 2. Headless-browser dogfooding

Tests prove the code does what the test says. Dogfooding proves the **running app** does what a human
needs. Drive the real app: navigate, click, screenshot, diff before/after. About 100ms per command, so
there is no excuse to skip it.

Reference tools: **garrytan/gstack `browse`** (the `browse` skill in this harness) and
**vercel-labs/agent-browser**. Both give the agent a fast headless browser as a first-class verb.

### The loop

```
browse navigate <url>
browse screenshot before.png
browse click "Save"
browse wait-for-network-idle
browse screenshot after.png
browse diff before.png after.png        # did the UI actually change as intended?
browse console-errors                    # any thrown errors / failed requests?
```

### Rules

- **Verify behavior, not markup.** "The button exists in the DOM" is not "clicking the button saves".
- **Diff before/after.** A screenshot pair is the cheapest regression proof you will ever take.
- **File bugs WITH evidence.** A bug report is `screenshot + console error + the exact repro steps`, not
  "looks broken". Evidence-free bug reports get bounced.
- **Never open localhost on the human's screen.** Navigate headless, capture, post the screenshot. The
  tab is disposable, the screenshot is the deliverable.
- **No dev-server orphans.** Spun one up to test -> tear it down when done.

---

## 3. Auto-review pipeline (one approval gate)

Run review lenses sequentially against the diff, let each make the obvious call automatically, and
surface only the real taste decisions at **one** gate. Reference: gstack **`autoplan`** (the `autoplan`
skill reads the full review skills from disk and runs them in sequence).

### Lenses (read each skill, run it, collect findings)

| Lens | Asks |
|---|---|
| **CEO / product** | Does this move the business? Is it the thing worth shipping, or polish on the wrong thing? |
| **Design** | Premium and coherent, or AI slop? One accent, real hierarchy. No mechanical find-replace styling. |
| **Eng** | Correct, simple, surgical. Over-engineered? Security holes (injection, XSS, leaked secret)? |
| **DX** | Will a teammate understand this in 3 months? Names, signatures, the one path through. |

Auto-decide the obvious (a missing 200 check, a hardcoded color, a leaked key are not opinions, they are
fixes). Escalate only genuine trade-offs to a single gate, and **lead with a recommendation**:

```
GATE (1 decision):
  Pricing copy: variant A (direct, "$X/mo") vs variant B (anchored, "less than a coffee").
  -> Recommend A: audience is technical, anchoring reads as fluff. Approve A?
```

### Reviewer panel (when the stakes justify it)

For high-stakes diffs, escalate to a **judge panel** instead of a single pass. Reference:
**wan-huiyan/agent-review-panel**.

- 4 to 6 blind reviewers, **dimension-based** (SQL, Auth, Infra, API, Frontend, Cost), not fixed role
  tags. Dimensions catch what role labels miss.
- **Blind during the parallel phase** (reviewers do not see each other), then 1 to 3 debate rounds, then
  a single "Supreme Judge" (pin to `model: opus`) adjudicates to kill cross-run variance.
- **Adversarial verify each finding:** spawn N independent skeptics, each prompted to **refute** the
  finding. Majority refutes -> kill it. This is how you stop the panel inventing problems.
- **Cost is real:** roughly 150k to 350k tokens, a few dollars to ~$20, and 6 to 15 minutes per run.
  Use it on the diff that ships to prod, not on a typo fix.

---

## 4. Canary (post-deploy)

Deploying is not the same as healthy. After deploy, watch the live system before you declare it good.

```
deploy
  -> canary watch <url|service>        # poll health, latency, error rate, key user flow
     ├─ green for the window  -> declare healthy
     └─ red / regression      -> roll back, do NOT declare, debug root-cause first
```

Reference: gstack **`canary`** skill (post-deploy monitoring).

- Watch a **real user flow**, not just `/health` returning 200. A health endpoint can be green while
  login is broken.
- Define the window up front (e.g. N minutes clean, error rate under threshold). Green for the window =
  healthy. Anything else = not deployed yet, it is mid-incident.
- A deploy you "declared live" without a canary window is a claim, not a fact.

---

## 5. Destructive-command guard

Some commands cannot be un-run. The guard blocks them unless explicitly confirmed. Reference:
**nazt/destructive_command_guard** (and the `guard` / `careful` skills in this harness).

| Blocked by default | Why | To proceed |
|---|---|---|
| `rm -rf` (especially `/`, `~`, `*`, unbounded globs) | irreversible data loss | explicit human confirm |
| `git push --force` / `--force-with-lease` to shared branch | rewrites others' history | explicit human confirm |
| `DROP TABLE` / `DROP DATABASE` / `TRUNCATE` | irreversible data loss | explicit human confirm |
| deploy to client/prod | irreversible, costs money, breaks live users | explicit human confirm |
| anything that spends money | obvious | explicit human confirm |

The guard never auto-runs these. It surfaces the exact command, what it will destroy, and waits for a
yes. Everything else stays autonomous (yolo). The guard is the difference between "moves fast" and
"moves fast and one day deletes prod".

---

## 6. The checklist (run before you say "done")

Copy this. Walk every line. A single unchecked box means not done.

```
PROOF-BEFORE-DONE CHECKLIST
───────────────────────────
BUILD
[ ] build / lint / test ran and exited 0  (it RAN, not "should pass")

E2E (§1)
[ ] every new/changed endpoint: curl -i -> 200  (not 307/302)
[ ] every page: live url -> 200, every internal link clicked -> 200
[ ] data path: queried the REAL DB, row/shape correct
[ ] external integration: called with real payload, status + shape confirmed vs docs
[ ] UNTESTED-ASSUMPTIONS list written AND length == 0

DOGFOOD (§2)
[ ] drove the real running app: navigate -> click -> screenshot
[ ] before/after diff confirms the intended change
[ ] zero console errors / failed requests
[ ] screenshot of the LIVE url captured (not the local file)

REVIEW (§3)
[ ] CEO / design / eng / DX lenses run, obvious fixes applied
[ ] no leaked secret / injection / XSS introduced
[ ] taste calls surfaced at one gate, recommendation given

GUARD (§5)
[ ] no destructive command ran without explicit confirm

DEPLOY + CANARY (§4)  (only if shipping)
[ ] confirmed which app/process serves the domain BEFORE publishing
[ ] public route added to allowlist + rebuilt if middleware-gated
[ ] canary watched a real user flow, green for the window

DECLARE
[ ] only now: say "done" / "live", with the proof attached
```

---

## Anti-patterns (do not)

- Declaring "live" from a browser session that has auth cookies. Others get a 307. **`curl` clean.**
- Trusting "the schema suggests X". Read the **real DB**. The collection is empty more often than you think.
- Relative links in a report (`../slug/`). They 404. Absolute or nothing.
- Parallel writers on the same code. Fragmented context, conflicting decisions, merge hell. **One writer.**
- A review panel for a typo. It costs real tokens and minutes. Match the tool to the stakes.
- "Tests pass" as a stand-in for "the app works". Tests prove the test. Dogfood proves the app.
- Saying "deployed and live" before the canary window closed. That is a hope, not a status.

---

## Related

- `harness/orchestrate/` · fan-out scouts to verify, single-threaded to write
- `browse`, `autoplan`, `canary`, `guard`, `careful` skills (gstack lineage)
- garrytan/gstack · vercel-labs/agent-browser · nazt/destructive_command_guard · wan-huiyan/agent-review-panel
