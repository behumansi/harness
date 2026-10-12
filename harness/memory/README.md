# The memory layer · the four brains

Be Human Harness gives your agent four kinds of memory. Together they turn a fresh Claude Code
into something that remembers you, remembers its own work, and connects the dots across
everything it has seen. Install them with one command:

```bash
bh memory install
```

The base set (1 to 4) needs no API key and runs on a fresh machine. Each is optional and
degrades gracefully: if one is missing, the rest still work.

| # | Brain | Tool | What it does | Key? |
|---|-------|------|--------------|------|
| 1 | **Curated** | native `brain/memory/` | The facts you read. The agent writes durable, interlinked notes here and loads the index every session. | no |
| 2 | **Semantic (work)** | claude-mem | Remembers what was built across sessions, searchable by meaning, not just keywords. | no |
| 3 | **Semantic (code)** | semble | Finds code by intent ("where is the auth flow"), CPU-only. | no |
| 4 | **Graph** | graphify | Connects ideas across docs and code, answers "what links X and Y", persists between sessions. | optional |

**Advanced (opt-in):** `cognee` adds a persistent knowledge graph over your whole corpus.
It needs your own OpenAI or Gemini key, so it is off by default. Wire it when you want the
deepest cross-document memory.

## How they fit together

```
        you talk / you work
               │
     ┌─────────┼──────────┬───────────────┐
     ▼         ▼          ▼               ▼
  curated   claude-mem  semble         graphify
  (facts)   (past work) (your code)    (connections)
     │         │          │               │
     └─────────┴────┬─────┴───────────────┘
                    ▼
         your agent, now with memory
```

Curated is the truth you write. The other three index and connect what the agent sees, so
next session it does not start from zero. Update the whole layer any time with
`bh memory install` again (idempotent, additive).
