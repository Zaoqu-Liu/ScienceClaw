#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo ""
echo "  ScienceClaw Setup"
echo "  ================================="
echo ""

# 1. Prerequisites
echo "  [1/4] Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "    Node.js not found. Install from https://nodejs.org/"; exit 1; }

NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "    Node.js >= 22 required (found $(node -v))."
  exit 1
fi

if command -v pnpm >/dev/null 2>&1; then
  PKG_MGR="pnpm"
elif command -v npm >/dev/null 2>&1; then
  PKG_MGR="npm"
else
  echo "    Neither pnpm nor npm found."
  exit 1
fi
echo "    Node.js $(node -v), $PKG_MGR $($PKG_MGR -v)"

# 2. Install dependencies (openclaw comes from npm)
echo ""
echo "  [2/4] Installing dependencies..."
if cd "$ROOT" && $PKG_MGR install 2>&1 | tail -5; then
  echo "    Done."
else
  echo "    ❌ Install failed. Check your network and try again."
  exit 1
fi

# 3. API key
echo ""
echo "  [3/4] API Key..."
if [ -f "$ROOT/.env" ] && grep -q "^OPENAI_API_KEY=" "$ROOT/.env" 2>/dev/null; then
  echo "    .env exists with API key. Skipping."
else
  echo ""
  echo "    You need one LLM API key to power ScienceClaw."
  echo "    (OpenAI, Anthropic, Google, or a relay like yunwu.ai)"
  echo ""
  read -p "    API Key: " API_KEY
  read -p "    Base URL [https://yunwu.ai/v1]: " BASE_URL
  BASE_URL="${BASE_URL:-https://yunwu.ai/v1}"
  if [ -n "$API_KEY" ]; then
    GW_TOKEN=$(openssl rand -hex 24 2>/dev/null || node -e "console.log(require('crypto').randomBytes(24).toString('hex'))" 2>/dev/null || echo "sc-$(date +%s)-$$")
    cat > "$ROOT/.env" << EOF
OPENAI_API_KEY=$API_KEY
OPENAI_BASE_URL=$BASE_URL
CLAUDE_API_KEY=$API_KEY
CLAUDE_BASE_URL=$BASE_URL
GEMINI_API_KEY=$API_KEY
GEMINI_BASE_URL=$BASE_URL

GATEWAY_AUTH_TOKEN=$GW_TOKEN
EOF
    echo "    Saved (gateway token auto-generated)."
  else
    if [ -f "$ROOT/.env.example" ]; then
      cp "$ROOT/.env.example" "$ROOT/.env"
    fi
    echo "    Skipped. Edit .env later."
  fi
fi

# 4. Channel setup
echo ""
echo "  [4/4] Channels..."
echo ""
echo "    ScienceClaw can connect to messaging platforms."
echo "    You can always add more later with: ./scienceclaw add <channel>"
echo ""
echo "    Available channels:"
echo "      1) Telegram     (easiest — just need a bot token)"
echo "      2) Discord"
echo "      3) Slack"
echo "      4) WhatsApp     (QR code scan)"
echo "      5) Feishu / Lark"
echo "      6) Matrix"
echo "      7) WeCom"
echo "      0) Skip — I'll use the Terminal UI for now"
echo ""
read -p "    Which channel? [0]: " CHANNEL_CHOICE
CHANNEL_CHOICE="${CHANNEL_CHOICE:-0}"

case "$CHANNEL_CHOICE" in
  1) node "$ROOT/scripts/channel.mjs" add telegram || true ;;
  2) node "$ROOT/scripts/channel.mjs" add discord || true ;;
  3) node "$ROOT/scripts/channel.mjs" add slack || true ;;
  4) node "$ROOT/scripts/channel.mjs" add whatsapp || true ;;
  5) node "$ROOT/scripts/channel.mjs" add feishu || true ;;
  6) node "$ROOT/scripts/channel.mjs" add matrix || true ;;
  7) node "$ROOT/scripts/channel.mjs" add wechat || true ;;
  0|"") echo "    Skipped. You can always add channels later." ;;
  *) echo "    Unknown choice. Skipped." ;;
esac

echo ""
echo "  ================================="
echo "  Setup complete!"
echo ""
echo "  Quick start:"
echo "    ./scienceclaw run              # Terminal UI + gateway"
echo "    ./scienceclaw dashboard        # Web dashboard"
echo ""
echo "  Add channels anytime:"
echo "    ./scienceclaw add telegram     # Add Telegram"
echo "    ./scienceclaw add discord      # Add Discord"
echo "    ./scienceclaw channels         # See all channels"
echo ""
echo "  Need help?"
echo "    ./scienceclaw help"
echo ""
