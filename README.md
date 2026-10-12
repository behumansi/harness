# Be Human Harness

> A complete, working agent harness for Claude Code. Fork it, run one command, and you inherit curated skills, specialized subagents, an orchestration layer, a ship-and-verify loop, and the working discipline that ties it together. Free, MIT, yours to change.

Most people run Claude Code bare. This is the harness around it.

**Paste this into Claude Code and it installs itself, talking you through it:**

```
Install the Be Human Harness for me. Do exactly this:

1. git clone https://github.com/hiivee/be-human-harness ~/be-human-harness
2. cd ~/be-human-harness
3. Open START.md and run it: you become my onboarding guide and take me step by step,
   talking with me, until everything is live (who I am, the method, the memory layer
   and the tools I use).

Talk to me in my language, one step at a time, no jargon. Start now.
```

Portuguese prompt, terminal install and updates: [`INSTALL.md`](INSTALL.md). Page: [be-human.ai/free](https://be-human.ai/free/).

---

## What you get

| Piece | What it does |
|---|---|
| **120 skills** | Packaged instructions for one kind of work each, so the agent follows a method instead of improvising |
| **Subagents** | Specialized workers with their own tools and scope |
| **Orchestration** | Fan out to read and verify, stay single threaded to write |
| **Verify loop** | Refuses to say done without proof: a status code, a receipt, a passing test |
| **Memory layer** | A living context file per project, so the next session resumes the thread |
| **`bh` CLI** | Installs, lists and curates the pieces |

## The skills, by domain

| Domain | Count | Examples |
|---|---|---|
| Agent method | 10 | `writing-plans`, `executing-plans`, `skill-creator`, `subagent-driven-development` |
| Engineering and QA | 23 | `systematic-debugging`, `tdd-workflow`, `security-review`, `verification-before-completion` |
| Content and marketing | 26 | `copywriting`, `content-strategy`, `marketing-psychology`, `seo-audit` |
| Design and frontend | 14 | `ui-ux-pro-max`, `anthropic-frontend-design`, `brand-guidelines`, `design-md` |
| Sales | 14 | `sales-prep`, `sales-proposal`, `sales-objections`, `sales-icp` |
| CRO and product | 11 | `page-cro`, `pricing-strategy`, `churn-prevention`, `onboarding-cro` |
| Executive and docs | 7 | `c-level-advisor`, `finance-advisor`, `contract-review`, `make-pdf` |
| Video and media | 12 | `general-video`, `motion-graphics`, `transcribe-video`, `hyperframes` |

Full index in [`skills/MANIFEST.md`](skills/MANIFEST.md).

## Multi-tenant by design

One engine, N instances. The engine is shared and version controlled. Your instance inherits a base and overrides only what you change.

```
            be-human-harness   (the engine, the method)
                    |
     ---------------+---------------
     |              |              |
 instance: ana  instance: leo  instance: sam
 CLAUDE.md      CLAUDE.md      CLAUDE.md     inherits CLAUDE.base.md
```

## Make it yours

Nothing here is sacred. Add skills, delete what you do not need, rewrite the base instructions. The method is the gift, not the config.

- A skill is a folder with a `SKILL.md`. Delete the folder, the skill is gone.
- `CLAUDE.base.md` is the shared instruction layer. Your `CLAUDE.md` overrides it.
- `bin/bh` is a shell script. Read it, change it.

## Honest notes

- This is a working harness cleaned for public use, not a polished product with a support desk.
- Everything that touched a client, a credential, an internal server or a private sales pipeline was removed on purpose. You get the method, not someone else's customer list.
- Some skills reference tools you may not have. They are folders, delete them.
- It is opinionated, because it was built for real work first. Disagree and change it, that is what a fork is for.

## Why this is free

We are a company called Be Human. We build AI agents that stay human in how they work and how they talk. The harness is not our moat, what we do with clients is. If this saves you a month of trial and error, that is the whole point.

## License

MIT. Use it commercially, rebrand it, sell work built with it. No attribution required, though a star helps other people find it.

## Credits

Some skills are by other authors and keep their own licences. See [`THIRD_PARTY.md`](THIRD_PARTY.md).
