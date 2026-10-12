# Mode D · The 10 Slide Crimes Audit

> Source: Patrick Winston, *How to Speak*, MIT OCW. Winston's central claim about slides: they are **condiments, not the main event**. The speaker is the meal. Every slide rule below derives from this principle and from a single neuroscience constraint Winston repeatedly invoked: humans have one language processor. If the audience is reading dense text, they cannot listen to you. If they are listening to you, they cannot read dense text. You must choose · and the right choice is almost always *less on the slide*.

---

## Intake required

From `assets/intake-questions.md`: questions 1-4 (universal) + 5-7 (Mode D add-ons).

You cannot audit slides you cannot see or describe. If the user has not provided either the deck or a slide-by-slide description, ask for one before proceeding. A vague "I have 30 slides about our roadmap" is insufficient.

---

## The 10 crimes

For each crime, the audit notes (a) how to detect it, (b) the Winston-grounded rule, and (c) the specific fix.

### Crime 1 · Too many slides
- **Detect:** total slide count divided by talk length in minutes. Anything above ~1 slide/minute is suspicious; above ~1.5 slides/minute is definitionally too many.
- **Rule:** the slide count must serve the talk's structure, not vice versa. Slides are condiments.
- **Fix:** force a merge pass. For every adjacent pair of slides, ask "would the audience lose anything if these became one slide, or one slide became zero slides?" Most often, the answer is no.

### Crime 2 · Too many words per slide
- **Detect:** any slide where you can read more than ~20 words while passing through it. Bullet-list slides almost always violate this.
- **Rule:** dense text forces the audience to choose between reading you and listening to you. They will choose neither.
- **Fix:** strip each slide to one phrase, one image, or one number. If the content cannot survive the strip, it belongs in the speaker's mouth, not on the slide.

### Crime 3 · Font size under 40pt
- **Detect:** ask the user, or eyeball the deck. If a phone screenshot of the slide makes the text unreadable, the text is too small for the back row of the room.
- **Rule:** Winston's stated minimum: **40pt**. No exceptions, including footnotes, axis labels on charts, and citation lines.
- **Fix:** raising the font size forces content reduction (Crime 2 self-corrects). This is intentional. Do not work around the rule by going to 36pt; reduce the content instead.

### Crime 4 · Reading slides aloud
- **Detect:** the speaker's spoken script is the same as the slide text.
- **Rule:** "People in your audience know how to read." (Winston, verbatim.) Reading slides is a productivity loss for everyone in the room and signals the speaker has not internalised the material.
- **Fix:** put one phrase or image on the slide; speak the explanation. If the speaker needs the words for confidence, put them in the speaker notes, not the slide.

### Crime 5 · Laser pointer usage
- **Detect:** the speaker uses a laser pointer to indicate elements on slides.
- **Rule:** Winston rejects laser pointers because (a) the speaker turns away from the audience, breaking eye contact, and (b) the moving red dot competes with the speaker's voice for attention · same single language processor problem.
- **Fix:** if attention must be directed on a slide, build the direction *into the slide itself* · an arrow, a highlight, a box. Or build the slide as a sequence (one element appears at a time). The pointer is unnecessary.

### Crime 6 · Speaker standing far from slides
- **Detect:** speaker plants behind a lectern, slides are on the other side of the stage. Audience eyes ping-pong between the two.
- **Rule:** the speaker and the slide are one visual unit. The audience should be able to see both with one eye movement, not a head turn.
- **Fix:** stand within arm's reach of the screen. Use the slide as backdrop, not as a separate exhibit.

### Crime 7 · No white space
- **Detect:** every slide is full edge-to-edge. There is no breathing room.
- **Rule:** "White space is not wasted space · it is breathing room for the audience's brain." White space is what allows a single element on a slide to *land*.
- **Fix:** for any cluttered slide, ask what the *one* thing is. Centre it. Delete everything else. If multiple things are essential, they belong on multiple slides · or in the speaker's mouth.

### Crime 8 · Background clutter and logos
- **Detect:** company logo on every slide, footer with date and slide number, background pattern, watermark, decorative borders.
- **Rule:** Winston: remove logos. They consume attention without adding information. Repeated chrome is noise the audience must filter every slide.
- **Fix:** logo on the *first* slide is fine; logo on every slide is a crime. Strip footers, page numbers (unless explicitly requested), watermarks, and background patterns. Background should be plain · Winston favoured plain backgrounds because they let content lead.

### Crime 9 · Collaborators list as final slide
- **Detect:** final slide is "Acknowledgements" or "Thanks to the team" with photos of collaborators.
- **Rule:** Winston: collaborators belong at the *start*, not the end. Put them at the end and you signal "I'm wrapping up" rather than "here is what I delivered." It also dilutes credit at the moment the audience is most attentive.
- **Fix:** if collaborators must be acknowledged on a slide, do it on slide 2 (before Vision). The final slide is reserved for Contributions.

### Crime 10 · "Thank you" or "Questions?" as final slide
- **Detect:** final slide reads "Thank You" or "Questions?" or "The End" or "[smiley face]" or "[company logo]".
- **Rule:** the final slide stays up the entire Q&A. It is the most-stared-at slide of the talk. Wasting it on "Thank You" is the single most common · and most damaging · slide crime in professional presentations.
- **Fix:** replace with a **Contributions** slide listing the 3-5 named contributions from Mode C. Audience members ask questions while *staring at your contributions*. This is exactly the reinforcement loop Winston designed.

---

## Steps

### Step 1 · Walk the deck slide by slide
For each slide, score it against the 10 crimes. Note the slide number, the crimes detected, and the proposed fix.

### Step 2 · Calculate the global metrics
- Total slide count vs. minutes (Crime 1)
- Average words per slide (Crime 2 estimator)
- Whether the final slide is a Contributions slide (Crime 10)

### Step 3 · Triage
Group the findings into three buckets:
- **Stays** · slides that pass all 10 checks. Note any small refinements but do not over-edit.
- **Goes** · slides that violate so many crimes that rebuilding from scratch is cheaper than fixing.
- **Changes** · slides that violate one or two crimes and can be repaired in place.

### Step 4 · Redesign the final slide
Always rebuild the final slide as a Contributions slide. This is non-negotiable; if the user resists, explain Winston's reasoning (it stays up during Q&A) and offer to do the redesign anyway so they can compare.

### Step 5 · Deliver the slide brief

---

## Rules · non-negotiable

- **Every crime gets a specific fix, not just a flag.** "Too wordy" is not useful; "cut to the phrase 'detector catches 7 of 9 regressions' and delete the rest" is.
- **Font minimum 40pt · no exceptions.**
- **Final slide is Contributions · never Thank You, Questions, or a logo.**
- **White space is not wasted space.**
- **Slides are condiments, not the main event.** This is the meta-rule. If a fix breaks any of the above, fix the fix.

---

## Output format

Deliver exactly these four sections, in this order:

### 1. Slide-by-Slide Audit
A table or numbered list. For each slide:
- Slide number and current title (or one-line description)
- Crimes detected (by number · e.g. "2, 3, 8")
- Specific fix

### 2. Global Findings
Three to five bullets summarising the deck-level issues · total slide count vs. time, recurring patterns (e.g. "every slide has the company logo · Crime 8 across the deck"), and any structural problems.

### 3. Final Slide Redesign
The exact content of the new Contributions slide · title, 3-5 contributions, each with a one-line description. If the user provided a Mode C output earlier, reuse those contributions verbatim.

### 4. Slide Brief · Stays / Goes / Changes
The triage from Step 3, presented as three short lists. This is the user's action plan.

---

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|--------------|--------------|-----|
| "Reduce font slightly to fit." | The fix is not less font, it is less content. | Cut the content. Keep 40pt. |
| "Add a 'Thank you' slide before the Contributions slide." | Winston's rule is unambiguous: no Thank You slide. | One final slide. Contributions. |
| "Keep collaborator photos on slide 2." | Photos consume attention. | Names only, small, slide 2. |
| "Use a darker background for visual interest." | Background should disappear. | Plain. White or near-white. |
| "Build animations on every slide for engagement." | Animation competes with the speaker. | Animate only when sequencing genuinely clarifies. |
| Replacing one wordy slide with two equally wordy slides. | Crime 2 is now Crime 1 + Crime 2. | Cut the words. Don't multiply slides. |

---

## Worked mini-example

**User's current final slide:** Big "Thank You!" text in 96pt, company logo, smiley emoji, the user's email address, the user's LinkedIn QR code, and a stock photo of a sunset.

**Audit:** Crime 10 (Thank You as final slide), Crime 8 (logo + decorative photo), Crime 7 (no white space · five elements competing).

**Redesigned final slide ("Contributions"):**

> **Contributions**
>
> 1. **Regression taxonomy** · six tagged failure modes from 11 months of incidents
> 2. **90-second detector** · covers four of six modes, runs as a deploy hook
> 3. **Shadow-test protocol** · any team can adopt with one config flag
>
> *(Single contact line in 40pt at the bottom: "[name] · [email]". No logo, no QR code, no sunset.)*

---

## Hand-off

After delivering, offer Mode A (Opening) if the deck does not yet have a strong empowerment promise, or wrap if the deck is now Winston-clean. Do not offer further work just for the sake of more work · Winston's whole framework rewards restraint.
