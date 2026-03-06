#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0

check() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== ScienceClaw Smoke Tests ==="
echo ""

check "scienceclaw script exists" test -f scienceclaw
check "scienceclaw script is executable" test -x scienceclaw
check "SCIENCE.md exists" test -f SCIENCE.md
check "SCIENCE.md is non-empty" test -s SCIENCE.md
check "openclaw.config.json exists" test -f openclaw.config.json
check "openclaw.config.json is valid JSON" node -e "JSON.parse(require('fs').readFileSync('openclaw.config.json','utf8'))"
check ".env.example exists" test -f .env.example

SKILL_COUNT=$(find skills -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -ge 200 ]; then
  echo "  PASS: skills/ has ${SKILL_COUNT} SKILL.md files (>= 200)"
  PASS=$((PASS + 1))
else
  echo "  FAIL: skills/ has ${SKILL_COUNT} SKILL.md files (expected >= 200)"
  FAIL=$((FAIL + 1))
fi

PKG_NAME=$(node -e "console.log(JSON.parse(require('fs').readFileSync('package.json','utf8')).name)" 2>/dev/null)
if [ "$PKG_NAME" = "scienceclaw" ]; then
  echo "  PASS: package.json name is 'scienceclaw'"
  PASS=$((PASS + 1))
else
  echo "  FAIL: package.json name is '${PKG_NAME}' (expected 'scienceclaw')"
  FAIL=$((FAIL + 1))
fi

check "node_modules/openclaw exists" test -d node_modules/openclaw

echo ""
echo "=== Results: ${PASS} passed, ${FAIL} failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
