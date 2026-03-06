#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OPENCLAW_DIR="$(cd "$ROOT/../openclaw" 2>/dev/null && pwd || echo "")"

echo ""
echo "  ScienceClaw Setup"
echo "  ================================="
echo ""

# 1. Prerequisites
echo "  [1/3] Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "    Node.js not found. Install from https://nodejs.org/"; exit 1; }
command -v pnpm >/dev/null 2>&1 || { echo "    pnpm not found. Run: npm install -g pnpm"; exit 1; }

NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "    Node.js >= 22 required (found $(node -v))."
  exit 1
fi
echo "    Node.js $(node -v), pnpm $(pnpm -v)"

# 2. Build openclaw engine
echo ""
echo "  [2/3] Engine..."
if [ -z "$OPENCLAW_DIR" ] || [ ! -d "$OPENCLAW_DIR" ]; then
  echo "    ERROR: openclaw not found at ../openclaw"
  exit 1
fi
if [ ! -f "$OPENCLAW_DIR/dist/entry.js" ] && [ ! -f "$OPENCLAW_DIR/dist/entry.mjs" ]; then
  echo "    Building openclaw (first time, ~30s)..."
  cd "$OPENCLAW_DIR" && pnpm install --silent 2>&1 | tail -1 && pnpm build 2>&1 | tail -1
  echo "    Done."
else
  echo "    Already built."
fi
cd "$ROOT" && pnpm install --silent 2>&1 | tail -1

# 3. API key
echo ""
echo "  [3/3] API Key..."
if [ -f "$ROOT/.env" ]; then
  echo "    .env exists. Skipping."
else
  echo ""
  echo "    You need one LLM API key (yunwu.ai, OpenAI, Anthropic, or Google)."
  echo ""
  read -p "    API Key: " API_KEY
  read -p "    Base URL [https://yunwu.ai/v1]: " BASE_URL
  BASE_URL="${BASE_URL:-https://yunwu.ai/v1}"
  if [ -n "$API_KEY" ]; then
    cat > "$ROOT/.env" << EOF
OPENAI_API_KEY=$API_KEY
OPENAI_BASE_URL=$BASE_URL
CLAUDE_API_KEY=$API_KEY
CLAUDE_BASE_URL=$BASE_URL
GEMINI_API_KEY=$API_KEY
GEMINI_BASE_URL=$BASE_URL
EOF
    echo "    Done."
  else
    cp "$ROOT/.env.example" "$ROOT/.env"
    echo "    Created .env from template. Edit it later."
  fi
fi

echo ""
echo "  ================================="
echo "  Setup complete!"
echo ""
echo "    scienceclaw run            # Start gateway + open TUI (one command)"
echo "    scienceclaw ask \"query\"    # One-shot mode (no gateway needed)"
echo "    scienceclaw stop           # Stop background gateway"
echo ""
