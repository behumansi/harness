#!/usr/bin/env bash
# harness/memory/install.sh · installs the Be Human Harness memory layer: the four brains.
#
# Base set (1 to 4 below) needs NO API key and runs on a fresh machine. Each step is
# idempotent and defensive: if a tool is missing it SKIPS with the one manual command,
# it never fails the whole run. The agent onboarding the user reads the skipped lines
# and helps the person finish that one step by hand.
set -uo pipefail

HIVE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
say()  { printf "  %s\n" "$*"; }
head() { printf "\n%s\n" "$*"; }

head "Installing the memory layer (the four brains)"

# 1. CURATED memory · the facts you read. Native to Claude Code: it writes here itself.
#    No install, just structure. This is where remembered facts live, interlinked.
mkdir -p "$HIVE_ROOT/brain/memory"
[ -f "$HIVE_ROOT/brain/memory/MEMORY.md" ] || cat > "$HIVE_ROOT/brain/memory/MEMORY.md" <<'EOF'
# Memory Index

> One line per memory. Facts your agent should remember across sessions.
> Each memory is a file next to this one; this index is loaded every session.
EOF
say "1/4 curated memory   ready (native, the facts you read)"

# 2. SEMANTIC cross-session · claude-mem. Remembers what was built, searchable by meaning.
if command -v claude >/dev/null 2>&1 && claude plugin list 2>/dev/null | grep -qi 'claude-mem'; then
  say "2/4 claude-mem        already installed (remembers past work)"
elif command -v claude >/dev/null 2>&1; then
  claude plugin marketplace add thedotmack/claude-mem >/dev/null 2>&1 || true
  if claude plugin install claude-mem@thedotmack >/dev/null 2>&1; then
    say "2/4 claude-mem        installed (remembers past work)"
  else
    say "2/4 claude-mem        SKIP -> in Claude Code run: /plugin install claude-mem@thedotmack"
  fi
else
  say "2/4 claude-mem        SKIP -> no claude CLI on PATH yet"
fi

# 3. SEMANTIC code search · semble. Finds code by intent, CPU-only, zero key.
if command -v claude >/dev/null 2>&1 && command -v uvx >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -qi 'semble'; then
    say "3/4 semble            already wired (find code by meaning)"
  elif claude mcp add semble -- uvx --from "semble[mcp]" semble >/dev/null 2>&1; then
    say "3/4 semble            wired (find code by meaning)"
  else
    say "3/4 semble            SKIP -> run: claude mcp add semble -- uvx --from 'semble[mcp]' semble"
  fi
else
  say "3/4 semble            SKIP -> needs uv (https://astral.sh/uv) + claude CLI"
fi

# 4. GRAPH memory · graphify. Connects ideas across docs/code, "what links X and Y".
PY="$(command -v python3 || command -v python || true)"
if [ -n "$PY" ]; then
  if "$PY" -c "import graphify" >/dev/null 2>&1; then
    say "4/4 graphify          already installed (connects ideas)"
  else
    "$PY" -m pip install graphifyy -q >/dev/null 2>&1 \
      || "$PY" -m pip install graphifyy -q --break-system-packages >/dev/null 2>&1 || true
    if "$PY" -c "import graphify" >/dev/null 2>&1; then
      say "4/4 graphify          installed (connects ideas)"
    else
      say "4/4 graphify          SKIP -> run: python3 -m pip install graphifyy"
    fi
  fi
else
  say "4/4 graphify          SKIP -> no python3 on PATH"
fi

head "Advanced (optional, needs an LLM key): cognee · a persistent knowledge graph."
say "Skip for the pilot. Wire it later with your own OpenAI or Gemini key."

head "Memory layer done. Next: bh status"
