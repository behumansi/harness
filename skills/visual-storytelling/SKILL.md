---
name: visual-storytelling
description: Build story-driven visual documents that tell a narrative instead of listing facts · onboarding decks, pitch narratives, "where we are and where we're going" presentations, team alignment boards. Signature look is a chalkboard aesthetic with hand-drawn SVG sketches, collage of real screenshots taped on, and a slight hand-drawn tilt. Two output formats · a keyboard slide deck and an infinite vertical scroll canvas. Triggers · "conta a história", "deck de onboarding", "apresentação foda", "timeline visual", "explica isso como história", "colagem", "quadro pra galera".
metadata:
  version: 0.1.0
  status: refining
layer: bh
---

# Visual Storytelling

Build visual documents that **tell a story**, not list facts. The reader scrolls and feels a journey: where we are, what we built, what is on the table, what the prize is, the invite. Artistic, raw, foda. Not corporate, not cute.

Canonical example, study it first: `a short onboarding deck of your own` (`index.html` slide deck + `canvas.html` infinite scroll). Built and approved by the user, May 2026.

## When to use

Onboarding a new person, a pitch, a team alignment, a "state of the operation" recap, any moment where you are showing someone the big picture and need them to *feel* it. If the answer is a flat report or a table, this is the wrong skill · use `design-md`.

## The two formats

| Format | File | When |
|---|---|---|
| **Slide deck** | `index.html` | Presenting live, one beat per screen, keyboard `↑↓`, scroll-snap. |
| **Infinite canvas** | `canvas.html` | A single giant board scrolled top to bottom, continuous chalk spine connecting stations, presenter explains as they scroll. Excalidraw / whiteboard feel. |

Build both when the user wants to both present and share. They share one design system and the same SVG sketches.

## Signature aesthetic · chalkboard

Dark board, chalk drawing, raw and confident. Less polish reads as *more* serious here, like drawing for the crew on a blackboard. Avoid: warm paper panels, pastel, heavy rounded white cards, drop shadows. Those read childish.

### Design tokens

```
--board:#0f0f12;            /* near-black, NEUTRAL · never green-tinted, that reads "verdão" */
--chalk:#E9E5D6;            /* warm chalk white, primary ink + body */
--chalk-2:#9c9d8c; --chalk-3:#5f6157;
--green:#A7DC5B;            /* the ONE brand accent (Be Human). Use sparingly · key words only */
--amber:#E6A06A;            /* warm secondary, peach-amber. Not mustard yellow */
--coral:#DD8F6E; --sky:#86AFC5; --teal:#6FB0A6;   /* extra chalk colors for diagrams */
fonts: Poppins 700/800 (headings + body), Caveat 600/700 (eyebrows, captions, all sketch labels)
```

Lesson learned: keep green for the brand mark and a couple of accent words. Greening every arrow and tinting the board makes it "muito verdão". The board stays neutral.

### Chalk grain + chalk-drawn SVG

- Page grain: a fixed `feTurbulence` noise overlay, `mix-blend-mode:overlay`, opacity ~0.5.
- Sketches are inline SVG drawn directly on the board with `var(--chalk)` strokes (not on white paper). Accent fills are the chalk colors at low opacity (`rgba(...,.2-.3)`).
- One shared displacement filter gives the chalk wobble. Define once, reference from every sketch line-group. Keep `<text>` OUTSIDE the filtered group or it gets illegible:

```html
<filter id="ck" x="-6%" y="-6%" width="112%" height="112%">
  <feTurbulence type="fractalNoise" baseFrequency="0.013 0.014" numOctaves="2" seed="7" result="t"/>
  <feDisplacementMap in="SourceGraphic" in2="t" scale="4.2"/>
</filter>
```

### Hand-drawn tilt

Rotate labels and sketch frames a tiny amount (`rotate(-.7deg)` to `rotate(1.3deg)`), alternating direction. Like Figma's hand-drawn mode. Subtle, and not on everything · eyebrows, sketch frames, small captions. Never tilt big headings or body copy.

### Collage (work in progress · refine)

Tape real screenshots onto the board: product landing page, the live Hub, a real client screen. Treatment = the image slightly rotated, a faint translucent "tape" rectangle over a corner, a soft shadow, like a polaroid pinned to the chalkboard. Ask the user for the real screenshots (logged-in views and live URLs) · do not fake them.

## Narrative arc

A story has beats. Default arc for an operation/onboarding story:

1. **Where we are, where we go** · cover, the whole map in one line.
2. **The moment** · what this operation is, the context.
3. **The product** · what we build and sell.
4. **The method** · how we work.
5. **The system / shared brain** · how knowledge compounds.
6. **Proof · what already runs** · active clients, real revenue (real numbers, never invented).
7. **What is on the table** · open proposals, the pipeline.
8. **The cast** · named projects and people.
9. **The machine** · how the next one arrives.
10. **Distribution** · how work reaches the reader.
11. **What you will master** · the ramp.
12. **The prize** · the upside, equity, ownership.
13. **The invite** · take this place.

Adapt the beats to the subject. Always: real data only, lead with strength (never frame defensively, e.g. "it is not freelance"), no em dashes, end on an invitation.

## Brand marks

Use the real client/company logo, never a guessed one. Your logo lives at `your-assets/public/propostas/_template-proposta/bh-logo.svg` (lime hexagon `#D4FE5E` + wordmark). Render brand marks crisp · do not apply the chalk filter to a real logo.

## Build checklist

- [ ] Gather real data first (numbers, names, status) · spawn an Explore agent if it spans many files.
- [ ] Pick the arc, write the copy in the user's voice, no em dashes.
- [ ] Build sketches as chalk inline SVG, labels in Caveat outside the filter group.
- [ ] Apply tilt subtly. Keep the board neutral.
- [ ] Real logos, real screenshots. Ask for what you cannot access.
- [ ] Output to `public/reports/<slug>/`, run the reports index regen.
- [ ] QA every slide/station with a headless screenshot before declaring done.

## Still to refine

Collage treatment, richer hand-drawn motion, smarter image placement. This skill is v0.1 · evolve it each time it is used.
