# Mode C · Structure (Vision → Proof of Work → Contributions)

> Source: Patrick Winston, *How to Speak*, MIT OCW. This is Winston's "job talk" framework · but it generalises to any presentation that needs to **convince, convert, or close**: investor pitch, product strategy review, thesis defence, conference talk, board update.

The skeleton has three pillars:

| Pillar | What it answers |
|--------|-----------------|
| **Vision** | What problem do you solve, and what is your new approach? Both halves are required. |
| **Proof of Work** | What concrete steps did you take that prove you have done something real? Not credentials · receipts. |
| **Contributions** | What are the discrete, named things you are claiming credit for? |

Winston's hard rule: **Vision must be established within the first 5 minutes.** If the audience does not have a working answer to "what problem and what approach" by minute five, the talk is already lost.

---

## Intake required

From `assets/intake-questions.md`: questions 1-4 (universal) + 5-7 (Mode C add-ons).

Question #5 (inform vs. expose) materially changes the structure:
- **Expose** (job talk, pitch, conference talk) → Vision in 5 minutes is mandatory; talk is structured around Contributions.
- **Inform** (lecture, tutorial) → Vision can unfold more gradually; talk is structured around the *cycle of the core idea*. Mode C still applies, but Step 4's "5-minute opening" relaxes to a "first-act opening."

---

## Steps

### Step 1 · Build the Vision statement

Vision is a two-part construction:
- **Part A: The problem someone cares about.** Specific, concrete, with stakes someone in the room actually feels. Not "AI safety" · "the moment a deployed model starts producing harmful outputs and you can't tell whether to roll back."
- **Part B: Your new approach.** Not the field's approach, not the textbook approach · *yours*. What is the move you make that others don't?

Template:
> "The problem is [specific, stake-laden problem]. The standard approach [does X]. My approach is to [your move], because [the reason your move is different and better]."

If either part is missing, the Vision is not a Vision yet · it is a topic. Push back.

### Step 2 · Design the Proof of Work

Winston's specific framing: list the **steps you took**, not the **credentials you have**. Proof of Work is procedural, not biographical. The audience should be able to mentally check each step off as plausible.

Format: 3-7 concrete steps. Each step is one short sentence in the active voice, naming what you did and (where possible) the artefact it produced.

Examples of good proof steps (note the verbs: *built, ran, measured, shipped, surveyed*):
- "Built a synthetic dataset of 12,000 misclassification cases."
- "Ran the new detector against that dataset and three production traffic samples."
- "Shipped the detector to one product surface for a 6-week shadow test."

Examples of bad proof points (vague, non-procedural):
- "I have deep expertise in machine learning." → credential, not proof.
- "We did a lot of work on this." → no step, no artefact.
- "Industry-leading." → marketing, not proof.

### Step 3 · Define the Contributions

Contributions are the **discrete, named things** the audience should remember you produced. Three to five is typical; more than seven is overload.

Each contribution is:
- **Named** · give it a short label (a noun phrase, ideally the same one you'll repeat later).
- **Discrete** · it stands on its own; another team could cite it.
- **Bounded** · it is clear what is and isn't part of the contribution.

Example contributions list for an engineering talk:
1. The seam-failure taxonomy (six categories).
2. The detector that catches four of the six in <100ms.
3. The shadow-test protocol that lets any team reproduce the evaluation.

### Step 4 · Structure the 5-minute opening

The opening's job is to deliver Vision and earn enough credibility (via Proof of Work preview) that the audience commits to the rest of the talk.

| Minute | Beat |
|--------|------|
| **0:00 - 1:00** | Empowerment promise (use Mode A output if available). |
| **1:00 - 2:30** | Vision Part A · the problem someone cares about, with stakes. |
| **2:30 - 4:00** | Vision Part B · your new approach, framed against the standard approach. |
| **4:00 - 5:00** | Proof of Work preview · name the 3 strongest steps so the audience knows real work backs the Vision. The full proof unfolds in the body. |

If the talk slot is shorter than 20 minutes, compress proportionally · the relative weights stay the same.

### Step 5 · Build the Contributions Close

The final slide · the *very last* slide · is the Contributions slide. Not "Thank You." Not "Questions?" Not "Conclusions." **Contributions.**

Why: Winston's rule that the contributions slide *stays up during Q&A*. While the audience asks questions, your contributions are visible behind you, reinforcing themselves. Replacing it with "Thank You" wastes the most-stared-at slide of the entire talk.

The Contributions slide layout:
- Title: **Contributions** (or the equivalent in the user's domain · "What I built," "What we shipped," "What I'm claiming.")
- Body: the 3-5 contributions from Step 3, each as a short noun phrase + one-line description.
- No logos, no "Thank you," no questions prompt.

The final spoken sentence should mirror the empowerment promise from minute zero. Promise made, promise kept.

---

## Rules · non-negotiable

- **Vision must be established within 5 minutes.** Never later. If the audience reaches minute 6 without a working answer to "what problem, what approach," the talk has already lost them.
- **Proof of Work must be specific steps, not vague accomplishments.** Verbs and artefacts, not adjectives.
- **Opening and close must mirror.** The empowerment promise made at minute 0 is the contributions claimed at minute N. They are two views of the same commitment.
- **The contributions slide stays up during Q&A.** Never replaced with "Thank you" or "Questions?" or a logo or a smiley face.
- **Every minute must advance Vision or Proof.** Anything that does neither · backstory, throat-clearing, agenda recaps · is cut.
- **Cycle the Vision.** State it cleanly in the opening, restate in the body when you transition between contributions, and re-state once more at the close. Three cycles minimum.

---

## Output format

Deliver exactly these five sections, in this order:

### 1. Vision Statement
Two-part construction (problem + approach), 2-3 sentences, ≤80 words total.

### 2. Proof of Work
A numbered list of 3-7 concrete steps. Each step is one active-voice sentence naming the action and the artefact.

### 3. 5-Minute Opening
A minute-by-minute breakdown matching the table in Step 4, with the actual content for each beat written out · not just placeholders. If the user provided a Mode A opening earlier in the conversation, reuse it for minute 0-1.

### 4. Contributions Close
The exact text of the final Contributions slide (title + 3-5 contributions, each with its one-line description), plus the final spoken sentence that mirrors the opening promise.

### 5. Full Talk Structure
A scaffold of the entire talk, in this format:

```
[0:00-1:00] Empowerment promise
[1:00-2:30] Vision A · problem
[2:30-4:00] Vision B · approach
[4:00-5:00] Proof of Work preview
[5:00-X]    Contribution 1: [name]
            - body, evidence, mechanism
[X:00-Y]    Contribution 2: [name]
            - body, evidence, mechanism
[Y:00-Z]    Contribution 3: [name]
            - body, evidence, mechanism
[Z:00-end]  Contributions close (slide stays up for Q&A)
```

Adjust contribution count to match what the user supplied.

---

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|--------------|--------------|-----|
| Vision arrives at minute 8. | Audience already lost. | Compress backstory; promise + Vision in first 5. |
| Proof of Work = "I have a PhD from X." | Credential, not proof. | Replace with three things you *did*. |
| Contributions are aspirational ("we hope to…"). | Audience can't credit you for an intention. | Restrict to what is already done, even if small. |
| Final slide is "Thank you / Questions?" | Wastes the most-stared-at surface. | Replace with Contributions slide. |
| 12 contributions listed. | Overload · audience remembers zero. | Compress to 3-5. The rest are sub-points. |
| Opening promises X, close delivers Y. | Breaks the implicit contract. | Re-write the close to mirror the promise verbatim. |

---

## Worked mini-example

For a 25-minute internal engineering talk on improving deploy reliability:

**Vision:** "The problem is that one in twelve of our production deploys causes a customer-visible regression we only catch in monitoring 30+ minutes later. The standard approach is to add more pre-deploy tests. My approach is to instrument *post-deploy* · running the regression detector against live traffic in the first 90 seconds · because the failures we miss are the ones tests can't see."

**Proof of Work:**
1. Audited 11 months of regression incidents and tagged each by signal source.
2. Built a 90-second post-deploy detector covering the four most common signal sources.
3. Ran it in shadow mode across two services for six weeks.
4. Measured catch rate vs. our existing monitoring (caught 7 of 9 regressions; existing monitoring caught 4 of 9).

**Contributions Close:**
1. **Regression taxonomy** · six tagged failure modes from 11 months of incidents.
2. **90-second detector** · covers four of the six modes, runs as a deploy hook.
3. **Shadow-test protocol** · any team can adopt the detector with one config flag.

---

## Hand-off

After delivering, offer Mode D (Slides) · the structure now needs visual support that doesn't violate the slide crimes. Or, if the user has not yet locked memorability, offer Mode B (Star) so the Vision and Contributions are anchored to a Symbol and Slogan that survive Q&A.
