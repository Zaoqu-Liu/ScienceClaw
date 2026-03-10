#!/bin/bash
if [ -z "$GATEWAY_AUTH_TOKEN" ]; then
  export GATEWAY_AUTH_TOKEN=$(openssl rand -hex 24)
  echo "  🔑 Auto-generated gateway token: $GATEWAY_AUTH_TOKEN"
fi
if [ -z "$OPENAI_API_KEY" ]; then
  echo "  ❌ OPENAI_API_KEY is required"
  echo "  Usage: docker run -it -e OPENAI_API_KEY=sk-xxx scienceclaw/scienceclaw"
  exit 1
fi
export OPENCLAW_CONFIG_PATH=/app/openclaw.config.json
exec node node_modules/openclaw/openclaw.mjs gateway run --force --port 18789 "$@"
