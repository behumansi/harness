---
name: brand-guidelines
description: "When the user wants to apply, document, or enforce brand guidelines for any product or company. Also use when the user mentions 'brand guidelines,' 'brand colors,' 'typography,' 'logo usage,' 'brand voice,' 'visual identity,' 'tone of voice,' 'brand standards,' 'style guide,' 'brand consistency,' or 'company design standards.' Covers color systems, typography, logo rules, imagery guidelines, and tone matrix for any brand."
license: MIT
metadata:
  version: 1.0.0
  author: Alireza Rezvani
  category: marketing
  updated: 2026-03-06
layer: bh
---

# Brand Guidelines

You are an expert in brand identity and visual design standards. Your goal is to help teams apply brand guidelines consistently across all marketing materials, products, and communications · whether working with an established brand system or building one from scratch.

## How to Use This Skill

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before applying brand standards.

When helping users:
1. Identify whether they need to *apply* existing guidelines or *create* new ones
2. Use the framework sections to assess and document their system
3. Always check for consistency before creativity

---

## Universal Brand Guidelines Framework

### 1. Brand Foundation

Before any visual decisions, the brand foundation must exist:

| Element | Definition |
|---------|-----------|
| **Mission** | Why the company exists beyond making money |
| **Vision** | The future state the brand is working toward |
| **Values** | 3-5 core principles that drive decisions |
| **Positioning** | What you are, for whom, against what alternative |
| **Personality** | How the brand behaves · adjectives that guide tone |

---

### 2. Color System

#### Primary Palette (2-3 colors)
- One dominant neutral (background or text)
- One strong brand color (most recognition, hero elements)
- One supporting color (secondary backgrounds, dividers)

#### Accent Palette (2-4 colors)
- Used sparingly for emphasis, CTAs, states
- Must pass WCAG AA contrast against backgrounds they appear on

#### Color Rules to Document:
- Which color for CTAs vs. informational links
- Background color combinations that are approved
- Colors that should never appear together
- Dark mode equivalents

#### Accessibility Requirements:
- Normal text (< 18pt): minimum 4.5:1 contrast ratio (WCAG AA)
- Large text (>= 18pt): minimum 3:1 contrast ratio
- UI components: minimum 3:1 against adjacent colors

---

### 3. Typography System

#### Type Roles to Define:

| Role | Font | Size Range | Weight | Line Height |
|------|------|-----------|--------|-------------|
| Display | · | 40pt+ | Bold | 1.1 |
| H1 | · | 28-40pt | SemiBold | 1.15 |
| H2 | · | 22-28pt | SemiBold | 1.2 |
| H3 | · | 18-22pt | Medium | 1.25 |
| Body | · | 15-18pt | Regular | 1.5-1.6 |
| Small / Caption | · | 12-14pt | Regular | 1.4 |
| Label / UI | · | 11-13pt | Medium | 1.2 |

#### Font Selection Criteria:
- Max 2 typeface families (one serif or slab, one sans-serif)
- Both must be available in all required weights
- Must render well at small sizes on screen
- Licensing must cover all intended uses (web, print, app)

---

### 4. Logo System

#### Variations Required:
- **Primary**: full color on white/light
- **Inverted**: light version on dark backgrounds
- **Monochrome**: single color for single-color applications
- **Mark only**: icon/symbol without wordmark (for small sizes)
- **Horizontal + Stacked**: where layout demands both

#### Usage Rules to Document:
- Minimum size (px for digital, mm for print)
- Clear space formula
- Approved background colors
- Prohibited modifications (distortion, recoloring, shadows)
- Co-branding rules (partner logo sizing, spacing)

---

### 5. Imagery Guidelines

#### Photography Criteria:
| Dimension | Guideline |
|-----------|-----------|
| **People** | Authentic, diverse, action-oriented · not posed stock |
| **Lighting** | Clean and directional; avoid heavy shadows or blown highlights |
| **Color treatment** | Align to brand palette; desaturate or tint if necessary |
| **Subjects** | Match brand values · avoid anything that conflicts with positioning |

#### Illustration Style:
- Define: flat vs. 3D, line vs. filled, abstract vs. representational
- Set a palette limit: brand colors only, or approved expanded set
- Define stroke weight and corner radius standards

---

### 6. Tone of Voice & Tone Matrix

Brand voice is consistent; tone adapts to context.

#### Voice Attributes (define 4-6):

| Attribute | What It Means | What It's Not |
|-----------|---------------|---------------|
| Example: **Direct** | Say what you mean; no filler | Blunt or dismissive |
| Example: **Curious** | Ask questions, show genuine interest | Condescending or know-it-all |
| Example: **Precise** | Specific language, no vague claims | Technical jargon that excludes |
| Example: **Warm** | Human and approachable | Overly casual or unprofessional |

#### Tone Matrix by Context:

| Context | Tone Dial | Example Shift |
|---------|-----------|--------------|
| Error messages | Calm, helpful, matter-of-fact | Less formal than marketing |
| Marketing headlines | Confident, energetic | More punchy than support |
| Legal / compliance | Precise, neutral | Less personality |
| Support / help content | Patient, empathetic | More warmth than ads |
| Social media | Conversational, light | More informal than web |

#### Words to Use / Avoid:

| Use | Avoid |
|-----|-------|
| "We" (inclusive) | "Leverage" (jargon) |
| Specific numbers | "Best-in-class" (vague) |
| Active voice | Passive constructions |
| Short sentences | Run-on complexity |

---

### 7. Application Examples

#### Digital
- **Web**: Primary palette for backgrounds; accent for CTAs
- **Email**: Inline styles only; web-safe font fallbacks always specified
- **Social**: Platform-specific safe zones; brand colors dominant

#### Print
- Always use CMYK values for print production (never RGB or hex)
- Bleed: 3mm on all sides; keep critical content 5mm from trim

#### Presentations
- Cover slide: brand dark + brand light with single accent
- Body slides: white backgrounds with brand accent headers

---

## Quick Audit Checklist

- [ ] Colors match approved palette (no off-brand variations)
- [ ] Fonts are correct typeface and weight
- [ ] Logo has proper clear space and is an approved variation
- [ ] Body text meets minimum size and contrast requirements
- [ ] Imagery style matches brand guidelines
- [ ] Tone matches brand voice attributes
- [ ] No prohibited uses present

---

## Output Artifacts

| Artifact | Format | Description |
|----------|--------|-------------|
| Brand Audit Report | Markdown doc | Asset-by-asset compliance check |
| Color System Reference | Table | Full palette with hex, RGB, CMYK, and usage rules |
| Tone Matrix | Table | Voice attributes x context combinations |
| Typography Scale | Table | All type roles with font, size, weight specs |
| Brand Guidelines Mini-Doc | Markdown doc | Condensed brand guide covering all 7 dimensions |

---

## Proactive Triggers

Proactively apply brand guidelines when:

1. **Any visual asset requested** · Check if brand guidelines exist first
2. **Copy review touches tone** · Cross-check against voice attributes
3. **New channel launch** · Apply brand guidelines to format requirements
4. **Design feedback session** · Run quick audit checklist first
5. **Partner or co-branded material** · Review logo sizing and color dominance
