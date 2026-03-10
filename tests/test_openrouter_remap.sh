#!/bin/bash
# E2E test suite: OpenRouter model ID auto-remapping
# Tests the full _build_runtime_config pipeline with different provider configs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
TOTAL=0

_color() { printf "\033[%sm%s\033[0m" "$1" "$2"; }
_green() { _color "32" "$1"; }
_red()   { _color "31" "$1"; }
_cyan()  { _color "36" "$1"; }
_bold()  { _color "1" "$1"; }

assert_json_eq() {
  local label="$1" jq_path="$2" expected="$3" json="$4"
  TOTAL=$((TOTAL + 1))
  local actual
  actual=$(echo "$json" | node -e "
    const c = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
    const path = process.argv[1].split('.');
    let v = c;
    for (const p of path) {
      if (/^\d+$/.test(p)) v = v[parseInt(p)];
      else v = (v || {})[p];
    }
    process.stdout.write(String(v ?? 'undefined'));
  " "$jq_path" 2>/dev/null) || actual="ERROR"

  if [ "$actual" = "$expected" ]; then
    PASS=$((PASS + 1))
    printf "    ✅ %s  →  %s\n" "$label" "$(_green "$actual")"
  else
    FAIL=$((FAIL + 1))
    printf "    ❌ %s\n" "$label"
    printf "       expected: %s\n" "$(_green "$expected")"
    printf "       actual:   %s\n" "$(_red "$actual")"
  fi
}

# Source the scienceclaw script functions (but don't run the case dispatch)
_load_functions() {
  local tmp_script
  tmp_script=$(mktemp)
  awk '/^case /{exit} {print}' "$ROOT/scienceclaw" > "$tmp_script"
  source "$tmp_script"
  rm -f "$tmp_script"
  # Override ROOT that _resolve set to the temp dir
  ROOT="$SCRIPT_DIR/.."
  ROOT="$(cd "$ROOT" && pwd)"
  export SCIENCECLAW_ROOT="$ROOT"
  RUNTIME_DIR="$HOME/.scienceclaw"
  RUNTIME_CONFIG="$RUNTIME_DIR/runtime-config.json"
}

_load_functions

# ═══════════════════════════════════════════════════════════════════════
echo ""
echo "  $(_bold '═══ OpenRouter Remap E2E Test Suite ═══')"
echo ""

# ── TEST 1: OpenRouter full (all 3 providers) ────────────────────────
echo "  $(_cyan 'TEST 1: OpenRouter — all 3 providers point to openrouter.ai')"

export OPENAI_API_KEY="sk-or-test-key"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
export CLAUDE_API_KEY="sk-or-test-key"
export CLAUDE_BASE_URL="https://openrouter.ai/api/v1"
export GEMINI_API_KEY="sk-or-test-key"
export GEMINI_BASE_URL="https://openrouter.ai/api/v1"
export GATEWAY_AUTH_TOKEN="test-token"

_build_runtime_config 2>/dev/null
T1=$(cat "$RUNTIME_CONFIG")

# Provider model IDs
assert_json_eq "claude model[0] → anthropic/claude-sonnet-4.6" \
  "models.providers.claude.models.0.id" \
  "anthropic/claude-sonnet-4.6" "$T1"

assert_json_eq "claude model[1] → anthropic/claude-opus-4.6" \
  "models.providers.claude.models.1.id" \
  "anthropic/claude-opus-4.6" "$T1"

assert_json_eq "openai model[0] → openai/gpt-4o" \
  "models.providers.openai.models.0.id" \
  "openai/gpt-4o" "$T1"

assert_json_eq "openai model[1] → openai/o4-mini" \
  "models.providers.openai.models.1.id" \
  "openai/o4-mini" "$T1"

assert_json_eq "gemini model[0] → google/gemini-2.5-flash" \
  "models.providers.gemini.models.0.id" \
  "google/gemini-2.5-flash" "$T1"

assert_json_eq "gemini model[1] → google/gemini-2.5-pro" \
  "models.providers.gemini.models.1.id" \
  "google/gemini-2.5-pro" "$T1"

# Agent model references (critical fix!)
assert_json_eq "primary → claude/anthropic/claude-sonnet-4.6" \
  "agents.defaults.model.primary" \
  "claude/anthropic/claude-sonnet-4.6" "$T1"

assert_json_eq "fallback[0] → gemini/google/gemini-2.5-pro" \
  "agents.defaults.model.fallbacks.0" \
  "gemini/google/gemini-2.5-pro" "$T1"

assert_json_eq "fallback[1] → openai/openai/gpt-4o" \
  "agents.defaults.model.fallbacks.1" \
  "openai/openai/gpt-4o" "$T1"

# Tools media
assert_json_eq "audio model → openai/whisper-1" \
  "tools.media.audio.models.0.model" \
  "openai/whisper-1" "$T1"

assert_json_eq "image model → openai/gpt-4o" \
  "tools.media.image.models.0.model" \
  "openai/gpt-4o" "$T1"

# Base URLs preserved
assert_json_eq "claude baseUrl still openrouter" \
  "models.providers.claude.baseUrl" \
  "https://openrouter.ai/api/v1" "$T1"

echo ""

# ── TEST 2: yunwu.ai (should NOT remap) ──────────────────────────────
echo "  $(_cyan 'TEST 2: yunwu.ai — no remapping should occur')"

export OPENAI_BASE_URL="https://yunwu.ai/v1"
export CLAUDE_BASE_URL="https://yunwu.ai/v1"
export GEMINI_BASE_URL="https://yunwu.ai/v1"

_build_runtime_config 2>/dev/null
T2=$(cat "$RUNTIME_CONFIG")

assert_json_eq "claude model[0] stays claude-sonnet-4-6" \
  "models.providers.claude.models.0.id" \
  "claude-sonnet-4-6" "$T2"

assert_json_eq "openai model[0] stays gpt-4o" \
  "models.providers.openai.models.0.id" \
  "gpt-4o" "$T2"

assert_json_eq "gemini model[0] stays gemini-2.5-flash" \
  "models.providers.gemini.models.0.id" \
  "gemini-2.5-flash" "$T2"

assert_json_eq "primary stays claude/claude-sonnet-4-6" \
  "agents.defaults.model.primary" \
  "claude/claude-sonnet-4-6" "$T2"

assert_json_eq "fallback[0] stays gemini/gemini-2.5-pro" \
  "agents.defaults.model.fallbacks.0" \
  "gemini/gemini-2.5-pro" "$T2"

assert_json_eq "audio model stays whisper-1" \
  "tools.media.audio.models.0.model" \
  "whisper-1" "$T2"

echo ""

# ── TEST 3: Mixed (Claude=OpenRouter, OpenAI=yunwu, Gemini=direct) ───
echo "  $(_cyan 'TEST 3: Mixed providers — only OpenRouter providers get remapped')"

export OPENAI_BASE_URL="https://yunwu.ai/v1"
export CLAUDE_BASE_URL="https://openrouter.ai/api/v1"
export GEMINI_BASE_URL="https://generativelanguage.googleapis.com/v1beta"

_build_runtime_config 2>/dev/null
T3=$(cat "$RUNTIME_CONFIG")

assert_json_eq "claude model[0] remapped → anthropic/claude-sonnet-4.6" \
  "models.providers.claude.models.0.id" \
  "anthropic/claude-sonnet-4.6" "$T3"

assert_json_eq "openai model[0] stays gpt-4o (yunwu)" \
  "models.providers.openai.models.0.id" \
  "gpt-4o" "$T3"

assert_json_eq "gemini model[0] stays gemini-2.5-flash (direct)" \
  "models.providers.gemini.models.0.id" \
  "gemini-2.5-flash" "$T3"

assert_json_eq "primary remapped (claude is OpenRouter)" \
  "agents.defaults.model.primary" \
  "claude/anthropic/claude-sonnet-4.6" "$T3"

assert_json_eq "fallback[0] stays (gemini not on OpenRouter)" \
  "agents.defaults.model.fallbacks.0" \
  "gemini/gemini-2.5-pro" "$T3"

assert_json_eq "fallback[1] stays (openai not on OpenRouter)" \
  "agents.defaults.model.fallbacks.1" \
  "openai/gpt-4o" "$T3"

assert_json_eq "audio model stays whisper-1 (yunwu)" \
  "tools.media.audio.models.0.model" \
  "whisper-1" "$T3"

echo ""

# ── TEST 4: Direct API (original endpoints, no remapping) ────────────
echo "  $(_cyan 'TEST 4: Direct API — original endpoints, no remapping')"

export OPENAI_BASE_URL="https://api.openai.com/v1"
export CLAUDE_BASE_URL="https://api.anthropic.com/v1"
export GEMINI_BASE_URL="https://generativelanguage.googleapis.com/v1beta"

_build_runtime_config 2>/dev/null
T4=$(cat "$RUNTIME_CONFIG")

assert_json_eq "claude model[0] stays claude-sonnet-4-6" \
  "models.providers.claude.models.0.id" \
  "claude-sonnet-4-6" "$T4"

assert_json_eq "openai model[0] stays gpt-4o" \
  "models.providers.openai.models.0.id" \
  "gpt-4o" "$T4"

assert_json_eq "gemini model[1] stays gemini-2.5-pro" \
  "models.providers.gemini.models.1.id" \
  "gemini-2.5-pro" "$T4"

assert_json_eq "primary stays claude/claude-sonnet-4-6" \
  "agents.defaults.model.primary" \
  "claude/claude-sonnet-4-6" "$T4"

assert_json_eq "all fallbacks unchanged" \
  "agents.defaults.model.fallbacks.1" \
  "openai/gpt-4o" "$T4"

echo ""

# ── TEST 5: Idempotency — run remap twice, result stays the same ─────
echo "  $(_cyan 'TEST 5: Idempotency — running remap twice should not double-prefix')"

export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
export CLAUDE_BASE_URL="https://openrouter.ai/api/v1"
export GEMINI_BASE_URL="https://openrouter.ai/api/v1"

_build_runtime_config 2>/dev/null
first_pass=$(cat "$RUNTIME_CONFIG")

# Manually run remap again on the already-remapped config
second_pass=$(_remap_for_openrouter "$first_pass" 2>/dev/null)

assert_json_eq "double remap: claude model stays anthropic/claude-sonnet-4.6" \
  "models.providers.claude.models.0.id" \
  "anthropic/claude-sonnet-4.6" "$second_pass"

assert_json_eq "double remap: openai model stays openai/gpt-4o" \
  "models.providers.openai.models.0.id" \
  "openai/gpt-4o" "$second_pass"

assert_json_eq "double remap: primary stays claude/anthropic/claude-sonnet-4.6" \
  "agents.defaults.model.primary" \
  "claude/anthropic/claude-sonnet-4.6" "$second_pass"

echo ""

# ── TEST 6: JSON structural integrity ────────────────────────────────
echo "  $(_cyan 'TEST 6: JSON structural integrity after remap')"

export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
export CLAUDE_BASE_URL="https://openrouter.ai/api/v1"
export GEMINI_BASE_URL="https://openrouter.ai/api/v1"

_build_runtime_config 2>/dev/null

TOTAL=$((TOTAL + 1))
if node -e "JSON.parse(require('fs').readFileSync('$RUNTIME_CONFIG','utf8'))" 2>/dev/null; then
  PASS=$((PASS + 1))
  printf "    ✅ runtime-config.json is valid JSON\n"
else
  FAIL=$((FAIL + 1))
  printf "    ❌ runtime-config.json is NOT valid JSON\n"
fi

TOTAL=$((TOTAL + 1))
PROVIDERS_COUNT=$(node -e "
  const c = JSON.parse(require('fs').readFileSync('$RUNTIME_CONFIG','utf8'));
  console.log(Object.keys(c.models.providers).length);
" 2>/dev/null)
if [ "$PROVIDERS_COUNT" = "3" ]; then
  PASS=$((PASS + 1))
  printf "    ✅ All 3 providers preserved\n"
else
  FAIL=$((FAIL + 1))
  printf "    ❌ Expected 3 providers, got %s\n" "$PROVIDERS_COUNT"
fi

TOTAL=$((TOTAL + 1))
AGENT_COUNT=$(node -e "
  const c = JSON.parse(require('fs').readFileSync('$RUNTIME_CONFIG','utf8'));
  console.log((c.agents.list || []).length);
" 2>/dev/null)
if [ "$AGENT_COUNT" = "1" ]; then
  PASS=$((PASS + 1))
  printf "    ✅ Agent list intact (1 agent)\n"
else
  FAIL=$((FAIL + 1))
  printf "    ❌ Agent list broken, got %s agents\n" "$AGENT_COUNT"
fi

TOTAL=$((TOTAL + 1))
SKILLS_DIR=$(node -e "
  const c = JSON.parse(require('fs').readFileSync('$RUNTIME_CONFIG','utf8'));
  const d = (c.skills.load.extraDirs || [])[0] || '';
  console.log(d.includes('/skills') ? 'ok' : 'bad');
" 2>/dev/null)
if [ "$SKILLS_DIR" = "ok" ]; then
  PASS=$((PASS + 1))
  printf "    ✅ Skills path resolved to absolute\n"
else
  FAIL=$((FAIL + 1))
  printf "    ❌ Skills path not resolved\n"
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════
# Summary
echo "  $(_bold '═══ Results ═══')"
echo ""
if [ "$FAIL" -eq 0 ]; then
  printf "  $(_green "All $TOTAL tests passed! ✅")\n"
else
  printf "  $(_red "$FAIL/$TOTAL tests FAILED ❌")  ($(_green "$PASS passed"))\n"
fi
echo ""

# Cleanup
unset OPENAI_API_KEY OPENAI_BASE_URL CLAUDE_API_KEY CLAUDE_BASE_URL
unset GEMINI_API_KEY GEMINI_BASE_URL GATEWAY_AUTH_TOKEN

exit "$FAIL"
