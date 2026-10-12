#!/usr/bin/env bash
# harness/stack/install.sh · the open-source stack the Be Human Harness stands on.
#
# Installs, from each project's OFFICIAL repo and with that project's own installer, the
# best open tools for Claude Code. Always the latest version, always credited, never forked.
#
#   bh stack                 install the recommended set (gstack, superpowers, agents)
#   bh stack list            what each piece is, who made it, licence
#   bh stack <piece> ...     install only some pieces: gstack superpowers agents agents-all workflows
#
# Each step is idempotent. A missing tool SKIPs with the one command to fix it; it never
# fails the whole run. The onboarding agent reads the SKIP lines and helps the person.
set -uo pipefail

say()  { printf "  %s\n" "$*"; }
head() { printf "\n%s\n" "$*"; }
has()  { command -v "$1" >/dev/null 2>&1; }
claude_ok() { has claude && claude plugin --help >/dev/null 2>&1; }
plugin_has() { claude plugin list 2>/dev/null | grep -qi "$1"; }

piece_list() {
  cat <<'EOF'
  gstack       Garry Tan (garrytan/gstack, MIT). 50+ skills that act like a software team:
               office hours, CEO and design review, QA in a real browser, ship, retro.
  superpowers  Jesse Vincent (obra/superpowers, MIT). The method skills: brainstorm, plan,
               TDD, systematic debugging, subagent-driven development.
  agents       VoltAgent (awesome-claude-code-subagents, MIT). 160+ specialist subagents;
               the recommended set installs core-dev, qa-sec, meta, research and biz.
  agents-all   every VoltAgent category (lang, infra, data-ai, dev-exp, domains too).
  workflows    Seth Hobson (wshobson/agents, MIT). 94 plugins, 200+ agents; adds the
               marketplace plus full-stack orchestration, comprehensive review, debugging.
  memory       claude-mem, semble, graphify: run `bh memory install` (the four brains).
EOF
}

do_gstack() {
  if [ -x "$HOME/.claude/skills/gstack/setup" ]; then
    say "gstack        already installed (updating)"
    git -C "$HOME/.claude/skills/gstack" pull --ff-only -q 2>/dev/null && (cd "$HOME/.claude/skills/gstack" && ./setup >/dev/null 2>&1) \
      && say "gstack        up to date" || say "gstack        update skipped (local changes?)"
    return
  fi
  if ! has bun; then say "gstack        SKIP -> needs Bun: curl -fsSL https://bun.sh/install | bash"; return; fi
  if git clone -q --single-branch --depth 1 https://github.com/garrytan/gstack.git "$HOME/.claude/skills/gstack" \
     && (cd "$HOME/.claude/skills/gstack" && ./setup >/dev/null 2>&1); then
    say "gstack        installed (a software team: /office-hours, /review, /qa, /ship)"
  else
    say "gstack        SKIP -> run: cd ~/.claude/skills/gstack && ./setup   (see its README)"
  fi
}

do_superpowers() {
  if ! claude_ok; then say "superpowers   SKIP -> install Claude Code first, then: claude plugin install superpowers@claude-plugins-official"; return; fi
  if plugin_has superpowers; then say "superpowers   already installed"; return; fi
  claude plugin install superpowers@claude-plugins-official >/dev/null 2>&1 \
    || { claude plugin marketplace add obra/superpowers-marketplace >/dev/null 2>&1 && claude plugin install superpowers@superpowers-marketplace >/dev/null 2>&1; } \
    && say "superpowers   installed (brainstorm, plan, TDD, debugging)" \
    || say "superpowers   SKIP -> inside Claude Code run: /plugin install superpowers@claude-plugins-official"
}

do_agents() {
  local set="${1:-recommended}" cats
  if ! claude_ok; then say "agents        SKIP -> install Claude Code first, then: claude plugin marketplace add VoltAgent/awesome-claude-code-subagents"; return; fi
  claude plugin marketplace add VoltAgent/awesome-claude-code-subagents >/dev/null 2>&1 || true
  if [ "$set" = all ]; then
    cats="core-dev lang infra qa-sec data-ai dev-exp domains biz meta research"
  else
    cats="core-dev qa-sec meta research biz"
  fi
  local okc=0 c
  for c in $cats; do
    plugin_has "voltagent-$c" && { okc=$((okc+1)); continue; }
    claude plugin install "voltagent-$c" >/dev/null 2>&1 && okc=$((okc+1))
  done
  say "agents        $okc categories of specialist subagents ready (VoltAgent)"
}

do_workflows() {
  if ! claude_ok; then say "workflows     SKIP -> install Claude Code first, then: claude plugin marketplace add wshobson/agents"; return; fi
  claude plugin marketplace add wshobson/agents >/dev/null 2>&1 || true
  local okc=0 p
  for p in full-stack-orchestration comprehensive-review debugging-toolkit; do
    plugin_has "$p" && { okc=$((okc+1)); continue; }
    claude plugin install "$p@claude-code-workflows" >/dev/null 2>&1 && okc=$((okc+1))
  done
  say "workflows     $okc workflow plugins ready; 90+ more in the marketplace (wshobson)"
}

case "${1:-}" in
  list) head "The stack"; piece_list; exit 0;;
  ""|recommended) set -- gstack superpowers agents;;
esac

head "Installing the stack (from each project's official repo)"
for piece in "$@"; do
  case "$piece" in
    gstack) do_gstack;;
    superpowers) do_superpowers;;
    agents) do_agents recommended;;
    agents-all) do_agents all;;
    workflows) do_workflows;;
    memory) bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/memory/install.sh";;
    *) say "unknown piece: $piece (try: bh stack list)";;
  esac
done
printf "\nStack done. Credits and licences: THIRD_PARTY.md. Next: bh status\n"
