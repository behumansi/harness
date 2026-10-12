# winston-presentation-coach
 
> An installable Claude Skill that turns any topic and audience into a Winston-grade presentation, applying Patrick Winston's MIT "How to Speak" framework end-to-end.
 
![Skill](https://img.shields.io/badge/Claude-Skill-orange) ![Format](https://img.shields.io/badge/format-.skill-blue) ![License](https://img.shields.io/badge/license-MIT-green)
 
## Repo description (one-liner for GitHub's "About" field)
 
`Patrick Winston's MIT "How to Speak" framework, packaged as an installable Claude Skill. Combines Empowerment Promise, Winston Star, Vision/Proof/Contributions, and the 10 Slide Crimes audit into one routed workflow.`
 
## What this is
 
A single Claude Skill that fuses four of Patrick Winston's most-cited presentation frameworks into one coherent coaching workflow:
 
1. **The Opening.** Empowerment Promise plus the first 60 seconds.
2. **Memorability.** The Winston Star: Symbol, Slogan, Surprise, Salient idea, Story.
3. **Structure.** Vision, Proof of Work, Contributions (the job-talk skeleton, generalised to any persuasive talk).
4. **Slides.** The 10 Slide Crimes audit, with a forced redesign of the final slide.
The skill detects which of these four frameworks you actually need from natural language, loads only that framework's reference file, runs a focused intake, and produces a deliverable in a fixed output format. There is also a fifth mode (Full Build) that runs all four in the correct order: Structure, then Memorability, then Opening, then Slides.
 
## Why a Skill, not just a prompt
 
Patrick Winston's framework is large enough that a single mega-prompt either bloats the context window or compresses the rules to the point of losing fidelity. This skill uses progressive disclosure:
 
* `SKILL.md` (about 100 lines) is always loaded. It contains the routing logic and universal rules.
* The five reference files load on demand based on the user's intent.
* The intake question bank is shared across all four frameworks so phrasing stays consistent.
Net result: lower token usage on long conversations, no loss of detail in any individual framework, and clean room to add a sixth framework later without touching the entry point.
 
## Repo layout
 
```
winston-presentation-coach/
├── SKILL.md                              # Router, universal rules, decision tree
├── references/
│   ├── 01-opening.md                     # Empowerment Promise + first 60 seconds
│   ├── 02-memorability.md                # Winston Star
│   ├── 03-structure.md                   # Vision / Proof of Work / Contributions
│   ├── 04-slides.md                      # 10 Slide Crimes audit
│   └── 05-full-build.md                  # End-to-end pipeline
└── assets/
    └── intake-questions.md               # Shared question bank
```
 
## Installation
 
### As a Claude Skill (recommended)
 
1. Download `winston-presentation-coach.skill` from the [latest release](#).
2. Open [claude.ai](https://claude.ai) on the web (mobile does not currently support skill upload).
3. Go to **Settings** > **Capabilities** > **Skills**.
4. Click **Upload skill** and select the `.skill` file.
5. Toggle it on.
Available on Claude Pro, Max, Team, and Enterprise plans.
 
### As a paste-ready prompt (any LLM)
 
If you cannot install the skill, use `winston-master-prompt.md` instead. Copy the prompt block and paste it as the first message in a new chat with Claude, ChatGPT, Gemini, or any other LLM that handles XML-tagged prompts.
 
## Usage
 
Once installed, the skill triggers automatically on natural-language requests. You do not need to mention Winston, MIT, or the skill name.
 
### Examples that trigger Mode A (Opening)
 
* "How should I open my talk on observability?"
* "Write me a hook for a 20-minute conference talk."
* "First slide is weak, fix it."
### Examples that trigger Mode B (Memorability)
 
* "Help me make this idea stick."
* "I need a tagline and a visual handle for our new architecture."
* "What is the one thing they should remember six months from now?"
### Examples that trigger Mode C (Structure)
 
* "Structure my pitch to the CTO."
* "I have a 5-minute slot to convince the board."
* "Build me a talk skeleton."
### Examples that trigger Mode D (Slides)
 
* "Audit my deck."
* "I have 47 slides for a 30-minute talk, fix it."
* "What is wrong with this slide?"
### Examples that trigger Mode E (Full Build)
 
* "Build me a complete presentation from scratch."
* "Apply the entire Winston framework to my talk."
* "I have a topic and an audience, take me to a finished deliverable."
## The non-negotiable rules
 
These come from Winston's actual lecture and override stylistic preferences:
 
* Never open with a joke. The audience is still settling.
* Never open with "thank you for having me."
* Never close with a "Thank You" or "Questions?" slide. The final slide is always a Contributions slide, and it stays up during Q&A.
* The empowerment promise must be specific, outcome-driven, and time-anchored.
* Slides are condiments, not the main event.
* Vision must be established within the first 5 minutes.
* Every minute must advance Vision or Proof, nothing else.
* Font minimum 40pt. No exceptions.
* Cycle the core idea 3 to 5 times. Roughly 20 percent of any audience is mentally elsewhere at any moment, so a single statement of the idea is statistically insufficient.
If your request would violate any of these rules, the skill flags the violation, explains Winston's reasoning, and proposes a compliant alternative rather than silently overriding you.
 
## Output formats
 
Each mode produces a fixed output structure. No improvisation.
 
| Mode | Sections delivered |
|------|--------------------|
| A | Empowerment Promise, First 60 Seconds (script), What to Cut, Delivery Notes |
| B | Symbol, Slogan, Surprise, Salient Idea, Story, Winston Star Summary card |
| C | Vision Statement, Proof of Work, 5-Minute Opening, Contributions Close, Full Talk Structure (time-coded) |
| D | Slide-by-Slide Audit, Global Findings, Final Slide Redesign, Stays/Goes/Changes brief |
| E | Vision and Contributions, Winston Star, Empowerment Promise and First 60 Seconds, Full Talk Structure, Slide Plan or Audit, Coherence Audit, Cut List |
 
## What this skill adds beyond the four source prompts
 
The skill is built on four existing Winston framework prompts, but it adds:
 
* **A routing layer** in `SKILL.md` that detects intent and loads only the relevant framework, instead of running all four every time.
* **A correct-order pipeline** for Mode E (Structure, then Memorability, then Opening, then Slides). Running them out of order produces incoherent output, which the source prompts did not address.
* **A coherence audit** at the end of full builds that verifies the opening promise mirrors the closing contributions, the Slogan survives without the Symbol, and so on.
* **Additional Winston principles** verified against the MIT OCW transcript: cycling the core idea, verbal punctuation for transitions, and the one-language-processor reasoning behind the slide rules.
* **A standardised intake bank** so the four frameworks share consistent question phrasing instead of re-asking the same things in different words.
* **Worked mini-examples** in each reference file so the model has concrete pattern-matching targets, not just abstract rules.
## Source material
 
* Patrick Winston, *How to Speak*, MIT OpenCourseWare ([transcript and video](https://ocw.mit.edu/courses/res-tll-005-how-to-speak-january-iap-2018/pages/how-to-speak/)).
* Memorial page from MIT EECS for Patrick Henry Winston (1943 to 2019).
The four framework prompts that seeded this skill (Opening, Slide Crimes, Star, Structure) are credited where applicable.
 
## Contributing
 
Issues and pull requests welcome. Three things to know before contributing:
 
1. **Do not break the rule list.** The non-negotiable rules section is the spine of the skill. Adding a rule is fine; relaxing one needs a citation from Winston's source material.
2. **Keep `SKILL.md` under 200 lines.** It is always loaded, so it pays the highest token cost. New content goes in a reference file, not the entry point.
3. **Each reference file should stand alone.** A user in Mode B should never need to read Mode C's reference to understand what the skill is asking for.
## License
 
MIT. See `LICENSE`.
 
## Credits
 
Framework: Patrick Henry Winston, MIT.
Skill packaging and routing layer: built using Anthropic's Skill format.
