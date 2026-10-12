# Mode E · Full Presentation Build (End-to-End)

> The end-to-end workflow that runs all four Winston sub-frameworks in the right order to produce a complete, Winston-grade presentation from a topic and an audience.

This mode is for users who say things like:
- "Help me build a presentation from scratch."
- "I have a topic, take me from zero to a full talk."
- "Apply the entire Winston framework to my talk."

If the user's request is narrower (only opening, only slides, etc.), use Modes A-D directly instead. Mode E is heavier · it's appropriate when the user explicitly wants the full pass.

---

## Why this order matters

The four sub-frameworks are not independent. They build on each other in a specific sequence, and running them out of order produces incoherent output:

1. **Structure first** (Mode C) · locks Vision and Contributions, which everything else points at.
2. **Memorability second** (Mode B) · Symbol/Slogan/Surprise/Salient idea/Story are designed to make the *Vision and Contributions* unforgettable. Without locked Vision, the Star points nowhere.
3. **Opening third** (Mode A) · the empowerment promise is the verbal echo of Vision + the opening of the Story. Both must already exist.
4. **Slides last** (Mode D) · slides are condiments. You cannot design condiments before you know the meal.

Running this in any other order means redoing earlier work. Don't.

---

## Intake required

Run the **full** intake from `assets/intake-questions.md` · universal questions plus all four mode add-ons. This is heavier than any single-mode intake; warn the user at the start.

Suggested intake message to send to the user:

> "I'll run all four Winston frameworks in sequence: Structure → Memorability → Opening → Slides. To do that without producing generic output, I need to ask roughly a dozen questions up front. It will take you 2-3 minutes to fill out, but it's the difference between a generic talk and a Winston-grade one. Ready?"

Wait for confirmation before sending the question block. When sending, send all questions in one message (grouped by category) · don't drip them.

---

## Workflow

### Phase 1 · Structure (Mode C)
Read `references/03-structure.md` and execute fully. Produce:
- Vision Statement
- Proof of Work
- 5-Minute Opening (placeholder · will be refined in Phase 3)
- Contributions Close
- Full Talk Structure (the time-coded scaffold)

Store the Vision and Contributions explicitly · they are the inputs to Phase 2.

### Phase 2 · Memorability (Mode B)
Read `references/02-memorability.md` and execute, but with a constraint: the Salient Idea must be aligned with the Vision from Phase 1. If the user has been describing a different Salient Idea than the locked Vision, surface the misalignment now and force a choice · *don't* let the talk carry two competing claims.

Produce:
- Symbol
- Slogan
- Surprise
- Salient Idea (must be consistent with Vision)
- Story
- Winston Star Summary

The Story produced here will become the spine of the body of the talk · it gets woven through the Contributions in Phase 1's structure.

### Phase 3 · Opening (Mode A)
Read `references/01-opening.md` and execute. The empowerment promise is now constrained: it must be the verbal echo of the Vision (Phase 1) and it must set up the Star (Phase 2) without spoiling the Surprise.

This step *replaces* the placeholder opening produced in Phase 1. The new opening is now anchored in real Vision + real Star.

Produce:
- Empowerment Promise
- First 60 Seconds (full script)
- What to Cut
- Delivery Notes

### Phase 4 · Slides (Mode D)
Read `references/04-slides.md`. If the user has an existing deck, audit it against the 10 crimes. If the user does not have a deck yet, produce a slide *plan* instead of a slide *audit*: a slide-by-slide outline that obeys all 10 crime-rules from inception.

Produce:
- Slide-by-Slide Audit (or Plan)
- Global Findings
- Final Slide Redesign (must be the Contributions slide from Phase 1)
- Slide Brief (Stays / Goes / Changes · for an existing deck), or Slide Plan (for a new deck)

### Phase 5 · Coherence audit
After all four phases, run a single integration check. Answer these five yes/no questions:

1. Does the empowerment promise (Phase 3) describe the same outcome as the Contributions slide (Phase 1)? *Promise made, promise kept?*
2. Does the Slogan (Phase 2) survive without the Symbol · could someone repeat it in a meeting? *Slogan portability.*
3. Does the Story (Phase 2) demonstrate the Salient Idea (Phase 2) and provide proof for the Vision (Phase 1)? *Story does double duty.*
4. Is the final slide a Contributions slide that mirrors the empowerment promise? *Closing loop.*
5. Does every body section advance Vision or Proof · nothing else? *Cut anything that fails this test.*

If any answer is no, name the gap and offer the user a one-step fix before final delivery.

---

## Output format

Deliver as a single structured deliverable with seven labelled sections:

### 1. Vision & Contributions
The locked Vision statement and the locked Contributions list. Two paragraphs, total ≤120 words.

### 2. Winston Star
The six-line Star summary card from Mode B.

### 3. Empowerment Promise & First 60 Seconds
One sentence (promise) followed by the ~150-word opening script.

### 4. Full Talk Structure
The time-coded scaffold from Mode C, but with the Phase 3 opening substituted in for the first 5 minutes.

### 5. Slide Plan / Audit
The slide-by-slide layout (or audit), the redesigned final slide, and the Stays/Goes/Changes brief.

### 6. Coherence Audit
The five yes/no answers from Phase 5, with a one-line note on any "no" and the proposed fix.

### 7. Cut List
A consolidated list of every element across the talk · content, slides, sentences in the opening, items on the contributions slide · that the user should cut. This is the most actionable section; lead with it if the user is short on time.

---

## Length and pacing

A full Mode E deliverable is long · typically 800-1,500 words across the seven sections. Do not pad. Tight beats long. If a section can be one sentence, make it one sentence.

If the user requests a Word document or a PDF of the deliverable, confirm and use the appropriate skill (`docx` or `pdf`). The default is in-chat markdown · Winston's whole point is that the *content* is what matters, and a well-structured chat response is sufficient.

---

## When *not* to use Mode E

- The user only needs one of the four frameworks. Use Mode A, B, C, or D directly.
- The user's intake is incomplete and they cannot answer the audience/outcome questions. Push for the answers before running Mode E · running it on bad intake produces high-volume nonsense.
- The user is in a 5-minute time crunch. Mode E takes time to do well; under heavy time pressure, skip to Mode A (Opening) and Mode D (Slides · final slide only). Those two alone will salvage the talk's most-watched 60 seconds and most-stared-at 5-10 minutes.

---

## Hand-off

After Mode E delivery, the natural next step is **rehearsal**, which Winston also covered but which is outside the scope of this skill. Offer the user a short rehearsal protocol if they want it (timed read-through against the time-coded scaffold, with two specific stop-conditions: missing the 5-minute Vision deadline, and missing the empowerment-promise→contributions mirror).
