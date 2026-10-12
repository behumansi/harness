# Install the Be Human Harness

You do not run a terminal. You paste one prompt into Claude Code and Claude does the rest:
it clones the harness, wires the skills and the memory, and walks you through it by talking.

## The prompt (English)

```
Install the Be Human Harness for me. Do exactly this:

1. git clone https://github.com/hiivee/be-human-harness ~/be-human-harness
2. cd ~/be-human-harness
3. Open START.md and run it: you become my onboarding guide and take me step by step,
   talking with me, until everything is live (who I am, the method, the memory layer
   and the tools I use).

Talk to me in my language, one step at a time, no jargon. Start now.
```

## O prompt (Português)

```
Instale o Be Human Harness pra mim. Faça exatamente:

1. git clone https://github.com/hiivee/be-human-harness ~/be-human-harness
2. cd ~/be-human-harness
3. Abra o START.md e execute: você vira o meu guia de onboarding e me conduz passo a
   passo, conversando, até tudo estar no ar (quem eu sou, o método, a camada de memória
   e as ferramentas que eu uso).

Fale comigo na minha língua, um passo de cada vez, sem jargão. Comece agora.
```

That is all. Claude reads `START.md`, asks who you are, links the skills into `~/.claude/skills`,
installs the memory layer, connects the tools you actually use and proves each step works.
At the end it asks what you want to build first.

## Prefer the terminal?

```bash
git clone https://github.com/hiivee/be-human-harness ~/be-human-harness
cd ~/be-human-harness
./bin/bh init "Your Name"
./bin/bh skills link
./bin/bh status
```

## Update later

Tell Claude: "update my Be Human Harness". It runs `./bin/bh sync` (a `git pull` of the engine).
Your private `brain/` (your name, your notes, your memory) is gitignored and never touched.

## Make it yours

Fork it on GitHub if you want to version your own changes, then pull improvements from
upstream with `git pull upstream main`. Delete what you disagree with. The method is the gift.
