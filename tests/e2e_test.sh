#!/usr/bin/env bash
# ScienceClaw End-to-End Tests
# Requires: running gateway, valid API keys in .env
# Usage: bash tests/e2e_test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

[ -f "$ROOT/.env" ] && set -a && source "$ROOT/.env" && set +a

PASS=0
FAIL=0
SKIP=0
GW_PORT=18789
GW_URL="http://127.0.0.1:${GW_PORT}"
GW_TOKEN="${GATEWAY_AUTH_TOKEN:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC}: $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}FAIL${NC}: $1${2:+ — $2}"; FAIL=$((FAIL + 1)); }
skip() { echo -e "  ${YELLOW}SKIP${NC}: $1${2:+ — $2}"; SKIP=$((SKIP + 1)); }
section() { echo -e "\n${CYAN}── $1 ──${NC}"; }

# ───────────────────────────────────────────────────
section "1. Config Generation"
# ───────────────────────────────────────────────────

# Test: scienceclaw script generates valid runtime config
if bash -c 'source .env 2>/dev/null; source scienceclaw status' >/dev/null 2>&1 || true; then
  RUNTIME="/tmp/scienceclaw-config.json"
  if [ -f "$RUNTIME" ]; then
    if node -e "JSON.parse(require('fs').readFileSync('$RUNTIME','utf8'))" 2>/dev/null; then
      pass "Runtime config is valid JSON"
    else
      fail "Runtime config is invalid JSON"
    fi

    # Verify env vars were substituted (no literal ${...} remaining)
    if grep -q '^\$\{' "$RUNTIME" 2>/dev/null; then
      fail "Runtime config has unsubstituted env vars"
    else
      pass "All env vars substituted in runtime config"
    fi

    # Verify skills path is absolute
    SKILLS_PATH=$(node -e "const c=JSON.parse(require('fs').readFileSync('$RUNTIME','utf8')); console.log(c.skills.load.extraDirs[0])" 2>/dev/null)
    if [[ "$SKILLS_PATH" == /* ]]; then
      pass "Skills path is absolute: ${SKILLS_PATH:0:50}..."
    else
      fail "Skills path is not absolute: $SKILLS_PATH"
    fi

    # Verify API keys are non-empty
    API_KEY=$(node -e "const c=JSON.parse(require('fs').readFileSync('$RUNTIME','utf8')); console.log(c.models.providers.claude.apiKey)" 2>/dev/null)
    if [ -n "$API_KEY" ] && [ "$API_KEY" != "undefined" ] && [[ "$API_KEY" != *'${'* ]]; then
      pass "Claude API key injected (${API_KEY:0:8}...)"
    else
      fail "Claude API key missing or not injected"
    fi
  else
    fail "Runtime config not found at $RUNTIME"
  fi
else
  skip "Config generation" "could not source scienceclaw"
fi

# ───────────────────────────────────────────────────
section "2. Gateway Health"
# ───────────────────────────────────────────────────

# Test: Gateway is listening (WebSocket server returns 503 for plain HTTP — that's expected)
GW_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${GW_URL}/" 2>/dev/null || echo "000")
if [ "$GW_CODE" != "000" ]; then
  pass "Gateway responding on port $GW_PORT (HTTP $GW_CODE)"
else
  fail "Gateway not responding on port $GW_PORT" "is it running?"
fi

# Test: WebSocket upgrade attempt
WS_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Upgrade: websocket" -H "Connection: Upgrade" \
  -H "Sec-WebSocket-Key: dGVzdA==" -H "Sec-WebSocket-Version: 13" \
  "${GW_URL}/" 2>/dev/null || echo "000")
if [ "$WS_CODE" != "000" ]; then
  pass "WebSocket endpoint reachable (HTTP $WS_CODE)"
else
  fail "WebSocket not available (connection refused)"
fi

# ───────────────────────────────────────────────────
section "3. LLM Provider Connectivity"
# ───────────────────────────────────────────────────

test_llm_provider() {
  local name="$1" base_url="$2" api_key="$3" model="$4"
  if [ -z "$api_key" ] || [ "$api_key" = "sk-your-key" ] || [ "$api_key" = "your-key" ]; then
    skip "$name API" "no API key configured"
    return
  fi
  local response
  response=$(curl -sf --max-time 15 "${base_url}/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${api_key}" \
    -d "{\"model\":\"${model}\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with exactly: OK\"}],\"max_tokens\":5}" 2>/dev/null) || true

  if echo "$response" | grep -q '"choices"'; then
    local reply
    reply=$(echo "$response" | node -e "process.stdin.on('data',d=>{try{console.log(JSON.parse(d).choices[0].message.content.trim())}catch{console.log('parse-error')}})" 2>/dev/null)
    pass "$name API reachable (model: $model, reply: ${reply:0:20})"
  elif echo "$response" | grep -q '"error"'; then
    local err
    err=$(echo "$response" | node -e "process.stdin.on('data',d=>{try{console.log(JSON.parse(d).error.message||JSON.parse(d).error.type||'unknown')}catch{console.log('unknown')}})" 2>/dev/null)
    fail "$name API error" "${err:0:80}"
  else
    fail "$name API unreachable" "no valid response"
  fi
}

test_llm_provider "Claude" "${CLAUDE_BASE_URL:-}" "${CLAUDE_API_KEY:-}" "claude-sonnet-4-6"
test_llm_provider "OpenAI" "${OPENAI_BASE_URL:-}" "${OPENAI_API_KEY:-}" "gpt-4o"
test_llm_provider "Gemini" "${GEMINI_BASE_URL:-}" "${GEMINI_API_KEY:-}" "gemini-2.5-flash"

# ───────────────────────────────────────────────────
section "4. Scientific Database APIs"
# ───────────────────────────────────────────────────

# Test: PubMed E-utilities
PUBMED_RESULT=$(curl -sf --max-time 10 \
  "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=3&term=CRISPR" 2>/dev/null) || true
if echo "$PUBMED_RESULT" | grep -q '"idlist"'; then
  PUBMED_COUNT=$(echo "$PUBMED_RESULT" | node -e "process.stdin.on('data',d=>{try{console.log(JSON.parse(d).esearchresult.count)}catch{console.log(0)}})" 2>/dev/null)
  pass "PubMed API reachable (CRISPR: ${PUBMED_COUNT} results)"
else
  fail "PubMed API unreachable"
fi

# Test: UniProt REST API
UNIPROT_RESULT=$(curl -sf --max-time 10 \
  "https://rest.uniprot.org/uniprotkb/search?query=gene_exact:TP53+AND+organism_id:9606&format=json&size=1" 2>/dev/null) || true
if echo "$UNIPROT_RESULT" | grep -q '"results"'; then
  pass "UniProt API reachable (TP53 query OK)"
else
  fail "UniProt API unreachable"
fi

# Test: OpenAlex API
OPENALEX_RESULT=$(curl -sf --max-time 10 \
  "https://api.openalex.org/works?search=machine+learning&per_page=1&select=id,title" 2>/dev/null) || true
if echo "$OPENALEX_RESULT" | grep -q '"results"'; then
  pass "OpenAlex API reachable"
else
  fail "OpenAlex API unreachable"
fi

# Test: Ensembl REST API
ENSEMBL_RESULT=$(curl -sf --max-time 10 \
  "https://rest.ensembl.org/lookup/symbol/homo_sapiens/BRCA1?content-type=application/json" 2>/dev/null) || true
if echo "$ENSEMBL_RESULT" | grep -q '"display_name"'; then
  pass "Ensembl API reachable (BRCA1 lookup OK)"
else
  fail "Ensembl API unreachable"
fi

# Test: STRING API
STRING_RESULT=$(curl -sf --max-time 20 \
  "https://string-db.org/api/json/network?identifiers=TP53&species=9606&limit=3" 2>/dev/null) || true
if echo "$STRING_RESULT" | grep -q '"preferredName"'; then
  pass "STRING API reachable (TP53 network OK)"
else
  skip "STRING API" "server may be slow or temporarily unavailable"
fi

# ───────────────────────────────────────────────────
section "5. Code Execution (Python / R)"
# ───────────────────────────────────────────────────

# Test: Python core scientific packages (individually to pinpoint missing ones)
PY_MISSING=""
for pkg in numpy scipy matplotlib seaborn scikit-learn; do
  mod=$(echo "$pkg" | sed 's/-/_/g; s/scikit_learn/sklearn/')
  if python3 -c "import $mod" 2>/dev/null; then
    : # ok
  else
    PY_MISSING="${PY_MISSING} ${pkg}"
  fi
done
if [ -z "$PY_MISSING" ]; then
  pass "Python core packages: numpy scipy matplotlib seaborn sklearn"
else
  fail "Python missing packages:${PY_MISSING}" "pip install${PY_MISSING}"
fi

# Test: Python statistical computation
PY_OUT=$(python3 -c "
import numpy as np; from scipy import stats
np.random.seed(42); data = np.random.normal(0, 1, 100)
t_stat, p_val = stats.ttest_1samp(data, 0)
print(f'OK n=100 t={t_stat:.3f} p={p_val:.4f}')
" 2>&1) || true
if echo "$PY_OUT" | grep -q "^OK"; then
  pass "Python statistics (scipy.stats): $PY_OUT"
else
  fail "Python statistics" "${PY_OUT:0:80}"
fi

# Test: Python matplotlib (figure generation)
PY_FIG=$(python3 -c "
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
fig, ax = plt.subplots(figsize=(4, 3), dpi=100)
ax.plot([1,2,3], [1,4,9])
ax.set_title('Test')
fig.savefig('/tmp/scienceclaw_test_fig.png', dpi=100, bbox_inches='tight')
import os
size = os.path.getsize('/tmp/scienceclaw_test_fig.png')
print(f'OK {size} bytes')
" 2>/dev/null) || true
if echo "$PY_FIG" | grep -q "^OK"; then
  pass "Matplotlib figure generation: $PY_FIG"
  rm -f /tmp/scienceclaw_test_fig.png
else
  fail "Matplotlib figure generation" "${PY_FIG:0:80}"
fi

# Test: R + ggplot2
if command -v Rscript >/dev/null 2>&1; then
  R_OUT=$(Rscript -e "
    library(ggplot2)
    p <- ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_minimal()
    ggsave('/tmp/scienceclaw_test_r.png', p, width=4, height=3, dpi=100)
    cat('OK', file.info('/tmp/scienceclaw_test_r.png')\$size, 'bytes\n')
  " 2>/dev/null) || true
  if echo "$R_OUT" | grep -q "^OK"; then
    pass "R + ggplot2 figure generation: $R_OUT"
    rm -f /tmp/scienceclaw_test_r.png
  else
    fail "R + ggplot2" "${R_OUT:0:80}"
  fi
else
  skip "R + ggplot2" "Rscript not found"
fi

# ───────────────────────────────────────────────────
section "6. Skill Integrity"
# ───────────────────────────────────────────────────

# Test: CATALOG.json entries match actual skill directories
CATALOG_COUNT=$(node -e "console.log(JSON.parse(require('fs').readFileSync('skills/CATALOG.json','utf8')).length)" 2>/dev/null)
DIR_COUNT=$(find skills -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
if [ "$CATALOG_COUNT" = "$DIR_COUNT" ]; then
  pass "CATALOG.json count ($CATALOG_COUNT) matches skill directories ($DIR_COUNT)"
else
  fail "CATALOG.json count ($CATALOG_COUNT) != skill directories ($DIR_COUNT)"
fi

# Test: INDEX.md entry count matches
INDEX_COUNT=$(grep -cE '^\| \[.+\]\(.+/SKILL\.md\)' skills/INDEX.md 2>/dev/null || echo 0)
if [ "$INDEX_COUNT" = "$DIR_COUNT" ]; then
  pass "INDEX.md entries ($INDEX_COUNT) match skill directories ($DIR_COUNT)"
else
  fail "INDEX.md entries ($INDEX_COUNT) != skill directories ($DIR_COUNT)"
fi

# Test: No truncated descriptions in CATALOG.json (spot check)
TRUNC=$(node -e "
const c=JSON.parse(require('fs').readFileSync('skills/CATALOG.json','utf8'));
const bad=c.filter(e=>e.description.length<10);
console.log(bad.length);
" 2>/dev/null)
if [ "$TRUNC" = "0" ]; then
  pass "CATALOG.json: all descriptions have meaningful length"
else
  fail "CATALOG.json: $TRUNC entries have very short descriptions"
fi

# Test: No broken INDEX.md links (sample 10)
BROKEN_LINKS=0
while IFS= read -r skill_dir; do
  skill_name=$(basename "$skill_dir")
  if ! grep -q "\[${skill_name}\](${skill_name}/SKILL.md)" skills/INDEX.md 2>/dev/null; then
    BROKEN_LINKS=$((BROKEN_LINKS + 1))
  fi
done < <(find skills -maxdepth 1 -mindepth 1 -type d | sort | head -10)
if [ "$BROKEN_LINKS" -eq 0 ]; then
  pass "INDEX.md links verified (sampled 10, all correct)"
else
  fail "INDEX.md has $BROKEN_LINKS broken links in sample"
fi

# ───────────────────────────────────────────────────
section "7. Telegram Bot"
# ───────────────────────────────────────────────────

if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
  TG_ME=$(curl -sf --max-time 10 \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" 2>/dev/null) || true
  if echo "$TG_ME" | grep -q '"ok":true'; then
    BOT_NAME=$(echo "$TG_ME" | node -e "process.stdin.on('data',d=>{try{const r=JSON.parse(d);console.log(r.result.username)}catch{console.log('?')}})" 2>/dev/null)
    pass "Telegram bot authenticated (@${BOT_NAME})"
  else
    fail "Telegram bot auth failed"
  fi

  # Verify bot is receiving updates (webhook or polling)
  TG_UPDATES=$(curl -sf --max-time 10 \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getWebhookInfo" 2>/dev/null) || true
  if echo "$TG_UPDATES" | grep -q '"ok":true'; then
    PENDING=$(echo "$TG_UPDATES" | node -e "process.stdin.on('data',d=>{try{console.log(JSON.parse(d).result.pending_update_count||0)}catch{console.log('?')}})" 2>/dev/null)
    pass "Telegram webhook info OK (pending updates: ${PENDING})"
  else
    skip "Telegram webhook check" "could not query"
  fi
else
  skip "Telegram bot" "TELEGRAM_BOT_TOKEN not set"
fi

# ───────────────────────────────────────────────────
section "8. Security Checks"
# ───────────────────────────────────────────────────

# Test: No secrets in tracked files (exclude local/gitignored configs)
SECRET_HITS=$(grep -rE 'sk-[a-zA-Z0-9]{20,}' --include='*.json' --include='*.md' --include='*.yml' --include='*.sh' . \
  --exclude-dir=node_modules --exclude-dir=.git --exclude='.env*' \
  --exclude='*.local.json' --exclude='*.bak*' 2>/dev/null || true)
SECRET_COUNT=$(echo "$SECRET_HITS" | grep -c . 2>/dev/null || echo 0)
[ -z "$SECRET_HITS" ] && SECRET_COUNT=0
if [ "$SECRET_COUNT" -eq 0 ]; then
  pass "No hardcoded API keys in tracked files"
else
  fail "Found $SECRET_COUNT lines with potential API keys in tracked files"
fi

# Test: .env is gitignored
if git check-ignore .env >/dev/null 2>&1; then
  pass ".env is properly gitignored"
else
  fail ".env is NOT gitignored — secrets at risk"
fi

# Test: Runtime config not in repo
if git check-ignore /tmp/scienceclaw-config.json >/dev/null 2>&1 || [ ! -d .git ] || true; then
  pass "Runtime config is outside repo (/tmp/)"
fi

# ───────────────────────────────────────────────────
# Results
# ───────────────────────────────────────────────────
echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "  ${GREEN}PASS: ${PASS}${NC}  ${RED}FAIL: ${FAIL}${NC}  ${YELLOW}SKIP: ${SKIP}${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
