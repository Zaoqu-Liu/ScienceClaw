#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$ROOT/.env"

# ── Language selection ────────────────────────────────────────────────

_select_language() {
  echo ""
  echo "  Language / 语言:"
  echo "    1) 中文 (推荐)"
  echo "    2) English"
  echo ""
  read -p "  Choose / 请选择 [1]: " LANG_CHOICE
  LANG_CHOICE="${LANG_CHOICE:-1}"
  case "$LANG_CHOICE" in
    2) LANG="en" ;;
    *) LANG="zh" ;;
  esac
}

_select_language

# ── Bilingual message helper ─────────────────────────────────────────

_m() {
  local key="$1"; shift
  if [ "$LANG" = "zh" ]; then
    case "$key" in
      title)          echo "  ScienceClaw 安装向导" ;;
      sep)            echo "  =================================" ;;
      step_prereq)    echo "  [1/6] 检查系统环境..." ;;
      step_deps)      echo "  [2/6] 安装依赖..." ;;
      step_apikey)    echo "  [3/6] 配置 API Key..." ;;
      step_env)       echo "  [4/6] 检查运行环境..." ;;
      step_search)    echo "  [5/6] 配置搜索能力（可选）..." ;;
      step_channel)   echo "  [6/6] 配置消息渠道..." ;;
      node_ok)        echo "    ✅ Node.js $(node -v)" ;;
      node_missing)   echo "    ❌ 未检测到 Node.js (需要 >= 22)" ;;
      node_old)       echo "    ❌ Node.js 版本过低 (当前 $(node -v)，需要 >= 22)" ;;
      node_install)   echo "    💡 安装方法:" ;;
      node_brew)      echo "       brew install node          # macOS (Homebrew)" ;;
      node_fnm)       echo "       curl -fsSL https://fnm.vercel.app/install | bash && fnm install 22" ;;
      node_url)       echo "       或访问 https://nodejs.org/ 下载安装" ;;
      pnpm_ok)        echo "    ✅ $PKG_MGR $($PKG_MGR -v)" ;;
      pnpm_missing)   echo "    ❌ 未检测到 pnpm 或 npm" ;;
      pnpm_install)   echo "    💡 安装 pnpm: npm install -g pnpm" ;;
      python_ok)      echo "    ✅ Python $(python3 --version 2>&1 | cut -d' ' -f2)" ;;
      python_missing) echo "    ⚠️  未检测到 Python 3 (代码执行功能需要)" ;;
      python_hint)    echo "    💡 安装: brew install python3 或 https://python.org/" ;;
      r_ok)           echo "    ✅ R $(Rscript --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" ;;
      r_missing)      echo "    ⚠️  未检测到 R (部分统计分析和可视化 skill 需要, 可选)" ;;
      r_hint)         echo "    💡 安装: brew install r 或 https://cran.r-project.org/" ;;
      deps_installing) echo "    正在安装..." ;;
      deps_ok)        echo "    ✅ 依赖安装完成" ;;
      deps_fail)      echo "    ❌ 安装失败，请检查网络后重试" ;;
      apikey_exists)  echo "    .env 已存在且包含 API key，跳过。" ;;
      apikey_prompt)  echo "    ScienceClaw 需要一个 LLM API key 来驱动 AI 能力。" ;;
      apikey_options) echo "    支持: OpenAI / Claude / Gemini / DeepSeek，或中转 yunwu.ai / OpenRouter" ;;
      apikey_provider) echo "    推荐: 国内用户选 DeepSeek (https://platform.deepseek.com/) 无需代理" ;;
      apikey_input)   printf "    API Key: " ;;
      apikey_baseurl) printf "    Base URL [https://yunwu.ai/v1]: " ;;
      apikey_saved)   echo "    ✅ 已保存 (gateway token 已自动生成)" ;;
      apikey_skip)    echo "    跳过。稍后编辑 .env 文件配置。" ;;
      apikey_valid)   echo "    ✅ API Key 验证通过" ;;
      apikey_invalid) echo "    ⚠️  API Key 验证失败 (HTTP $1)，请确认 key 和 URL 是否正确" ;;
      apikey_timeout) echo "    ⚠️  连接超时，可能需要配置代理或检查网络" ;;
      apikey_checking) echo "    正在验证 API Key..." ;;
      search_intro)   echo "    ScienceClaw 使用 Brave Search 进行网页搜索（免费 2000 次/月）。" ;;
      search_url)     echo "    注册地址: https://api-dashboard.search.brave.com/register" ;;
      search_input)   printf "    Brave API Key（可选，回车跳过）: " ;;
      search_saved)   echo "    ✅ 已配置 Brave Search" ;;
      search_skip)    echo "    跳过。ScienceClaw 仍可通过 PubMed/OpenAlex 等学术 API 搜索。" ;;
      channel_intro)  echo "    ScienceClaw 可以连接到消息平台。" ;;
      channel_later)  echo "    你可以之后随时添加: ./scienceclaw add <channel>" ;;
      channel_list)   echo "    可用渠道:" ;;
      channel_tg)     echo "      1) Telegram     (最简单 — 只需一个 bot token)" ;;
      channel_dc)     echo "      2) Discord" ;;
      channel_sl)     echo "      3) Slack" ;;
      channel_wa)     echo "      4) WhatsApp     (扫二维码)" ;;
      channel_fs)     echo "      5) 飞书 / Lark" ;;
      channel_mx)     echo "      6) Matrix" ;;
      channel_wc)     echo "      7) 企业微信" ;;
      channel_skip)   echo "      0) 跳过 — 先用终端界面" ;;
      channel_pick)   printf "    选择渠道 [0]: " ;;
      channel_skipped) echo "    跳过。之后可以随时添加。" ;;
      channel_unknown) echo "    无效选择，已跳过。" ;;
      complete)       echo "  安装完成！" ;;
      next_run)       echo "    ./scienceclaw run              # 启动（终端界面 + 服务）" ;;
      next_dash)      echo "    ./scienceclaw dashboard        # 打开网页面板" ;;
      next_add)       echo "    ./scienceclaw add telegram     # 添加 Telegram" ;;
      next_channels)  echo "    ./scienceclaw channels         # 查看所有渠道" ;;
      next_help)      echo "    ./scienceclaw help             # 查看帮助" ;;
      quickstart)     echo "  快速开始:" ;;
      addchannel)     echo "  随时添加渠道:" ;;
      needhelp)       echo "  需要帮助?" ;;
    esac
  else
    case "$key" in
      title)          echo "  ScienceClaw Setup" ;;
      sep)            echo "  =================================" ;;
      step_prereq)    echo "  [1/6] Checking prerequisites..." ;;
      step_deps)      echo "  [2/6] Installing dependencies..." ;;
      step_apikey)    echo "  [3/6] Configuring API Key..." ;;
      step_env)       echo "  [4/6] Checking runtime environment..." ;;
      step_search)    echo "  [5/6] Web search setup (optional)..." ;;
      step_channel)   echo "  [6/6] Channel setup..." ;;
      node_ok)        echo "    ✅ Node.js $(node -v)" ;;
      node_missing)   echo "    ❌ Node.js not found (>= 22 required)" ;;
      node_old)       echo "    ❌ Node.js too old (found $(node -v), need >= 22)" ;;
      node_install)   echo "    💡 Install options:" ;;
      node_brew)      echo "       brew install node          # macOS (Homebrew)" ;;
      node_fnm)       echo "       curl -fsSL https://fnm.vercel.app/install | bash && fnm install 22" ;;
      node_url)       echo "       Or visit https://nodejs.org/" ;;
      pnpm_ok)        echo "    ✅ $PKG_MGR $($PKG_MGR -v)" ;;
      pnpm_missing)   echo "    ❌ Neither pnpm nor npm found" ;;
      pnpm_install)   echo "    💡 Install pnpm: npm install -g pnpm" ;;
      python_ok)      echo "    ✅ Python $(python3 --version 2>&1 | cut -d' ' -f2)" ;;
      python_missing) echo "    ⚠️  Python 3 not found (needed for code execution)" ;;
      python_hint)    echo "    💡 Install: brew install python3 or https://python.org/" ;;
      r_ok)           echo "    ✅ R $(Rscript --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" ;;
      r_missing)      echo "    ⚠️  R not found (optional, needed for some stats/viz skills)" ;;
      r_hint)         echo "    💡 Install: brew install r or https://cran.r-project.org/" ;;
      deps_installing) echo "    Installing..." ;;
      deps_ok)        echo "    ✅ Dependencies installed" ;;
      deps_fail)      echo "    ❌ Install failed. Check your network and try again." ;;
      apikey_exists)  echo "    .env exists with API key. Skipping." ;;
      apikey_prompt)  echo "    ScienceClaw needs an LLM API key to power AI capabilities." ;;
      apikey_options) echo "    Supports: OpenAI / Claude / Gemini / DeepSeek, or relay (yunwu.ai / OpenRouter)" ;;
      apikey_provider) echo "    Tip: DeepSeek (https://platform.deepseek.com/) is affordable and works in China" ;;
      apikey_input)   printf "    API Key: " ;;
      apikey_baseurl) printf "    Base URL [https://yunwu.ai/v1]: " ;;
      apikey_saved)   echo "    ✅ Saved (gateway token auto-generated)" ;;
      apikey_skip)    echo "    Skipped. Edit .env later." ;;
      apikey_valid)   echo "    ✅ API Key validated successfully" ;;
      apikey_invalid) echo "    ⚠️  API Key validation failed (HTTP $1), check your key and URL" ;;
      apikey_timeout) echo "    ⚠️  Connection timed out, check network or proxy settings" ;;
      apikey_checking) echo "    Validating API Key..." ;;
      search_intro)   echo "    ScienceClaw uses Brave Search for web search (free, 2000 queries/month)." ;;
      search_url)     echo "    Sign up: https://api-dashboard.search.brave.com/register" ;;
      search_input)   printf "    Brave API Key (optional, Enter to skip): " ;;
      search_saved)   echo "    ✅ Brave Search configured" ;;
      search_skip)    echo "    Skipped. ScienceClaw can still search via PubMed/OpenAlex APIs." ;;
      channel_intro)  echo "    ScienceClaw can connect to messaging platforms." ;;
      channel_later)  echo "    You can always add more later: ./scienceclaw add <channel>" ;;
      channel_list)   echo "    Available channels:" ;;
      channel_tg)     echo "      1) Telegram     (easiest — just need a bot token)" ;;
      channel_dc)     echo "      2) Discord" ;;
      channel_sl)     echo "      3) Slack" ;;
      channel_wa)     echo "      4) WhatsApp     (QR code scan)" ;;
      channel_fs)     echo "      5) Feishu / Lark" ;;
      channel_mx)     echo "      6) Matrix" ;;
      channel_wc)     echo "      7) WeCom" ;;
      channel_skip)   echo "      0) Skip — I'll use the Terminal UI for now" ;;
      channel_pick)   printf "    Which channel? [0]: " ;;
      channel_skipped) echo "    Skipped. You can always add channels later." ;;
      channel_unknown) echo "    Invalid choice. Skipped." ;;
      complete)       echo "  Setup complete!" ;;
      next_run)       echo "    ./scienceclaw run              # Terminal UI + gateway" ;;
      next_dash)      echo "    ./scienceclaw dashboard        # Web dashboard" ;;
      next_add)       echo "    ./scienceclaw add telegram     # Add Telegram" ;;
      next_channels)  echo "    ./scienceclaw channels         # See all channels" ;;
      next_help)      echo "    ./scienceclaw help" ;;
      quickstart)     echo "  Quick start:" ;;
      addchannel)     echo "  Add channels anytime:" ;;
      needhelp)       echo "  Need help?" ;;
    esac
  fi
}

# ── Title ─────────────────────────────────────────────────────────────

echo ""
_m title
_m sep
echo ""

# ── 1. Prerequisites ─────────────────────────────────────────────────

_m step_prereq

# Node.js
if command -v node >/dev/null 2>&1; then
  NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
  if [ "$NODE_MAJOR" -lt 22 ]; then
    _m node_old
    echo ""
    _m node_install
    _m node_brew
    _m node_fnm
    _m node_url
    exit 1
  fi
  _m node_ok
else
  _m node_missing
  echo ""
  _m node_install
  _m node_brew
  _m node_fnm
  _m node_url
  exit 1
fi

# Package manager
PKG_MGR=""
if command -v pnpm >/dev/null 2>&1; then
  PKG_MGR="pnpm"
elif command -v npm >/dev/null 2>&1; then
  PKG_MGR="npm"
  if command -v corepack >/dev/null 2>&1; then
    corepack enable 2>/dev/null && PKG_MGR="pnpm" || true
  fi
fi

if [ -z "$PKG_MGR" ]; then
  _m pnpm_missing
  _m pnpm_install
  exit 1
fi
_m pnpm_ok

# ── 2. Install dependencies ──────────────────────────────────────────

echo ""
_m step_deps
_m deps_installing
if cd "$ROOT" && $PKG_MGR install 2>&1 | tail -3; then
  _m deps_ok
else
  _m deps_fail
  exit 1
fi

# ── 3. API key ────────────────────────────────────────────────────────

echo ""
_m step_apikey
if [ -f "$ENV_FILE" ] && grep -q "^OPENAI_API_KEY=" "$ENV_FILE" 2>/dev/null; then
  _m apikey_exists
else
  echo ""
  _m apikey_prompt
  _m apikey_options
  _m apikey_provider
  echo ""

  _m apikey_input
  read API_KEY
  

  _m apikey_baseurl
  read BASE_URL
  BASE_URL="${BASE_URL:-https://yunwu.ai/v1}"

  if [ -n "$API_KEY" ]; then
    # Validate the key
    _m apikey_checking
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 \
      -H "Authorization: Bearer $API_KEY" \
      "${BASE_URL}/models" 2>/dev/null) || HTTP_CODE="timeout"

    if [ "$HTTP_CODE" = "timeout" ] || [ "$HTTP_CODE" = "000" ]; then
      _m apikey_timeout
    elif [ "$HTTP_CODE" = "200" ]; then
      _m apikey_valid
    else
      _m apikey_invalid "$HTTP_CODE"
    fi

    GW_TOKEN=$(openssl rand -hex 24 2>/dev/null || node -e "console.log(require('crypto').randomBytes(24).toString('hex'))" 2>/dev/null || echo "sc-$(date +%s)-$$")

    local is_deepseek=false
    if echo "$BASE_URL" | grep -qi "deepseek"; then
      is_deepseek=true
    fi

    if $is_deepseek; then
      cat > "$ENV_FILE" << EOF
DEEPSEEK_API_KEY=$API_KEY
DEEPSEEK_BASE_URL=$BASE_URL

GATEWAY_AUTH_TOKEN=$GW_TOKEN
SCIENCECLAW_LANG=$LANG
EOF
    else
      cat > "$ENV_FILE" << EOF
OPENAI_API_KEY=$API_KEY
OPENAI_BASE_URL=$BASE_URL
CLAUDE_API_KEY=$API_KEY
CLAUDE_BASE_URL=$BASE_URL
GEMINI_API_KEY=$API_KEY
GEMINI_BASE_URL=$BASE_URL

GATEWAY_AUTH_TOKEN=$GW_TOKEN
SCIENCECLAW_LANG=$LANG
EOF
    fi
    chmod 600 "$ENV_FILE"
    _m apikey_saved
  else
    if [ -f "$ROOT/.env.example" ]; then
      cp "$ROOT/.env.example" "$ENV_FILE"
      chmod 600 "$ENV_FILE"
    fi
    _m apikey_skip
  fi
fi

# Persist language choice if .env exists but SCIENCECLAW_LANG is not set
if [ -f "$ENV_FILE" ] && ! grep -q "^SCIENCECLAW_LANG=" "$ENV_FILE" 2>/dev/null; then
  echo "SCIENCECLAW_LANG=$LANG" >> "$ENV_FILE"
fi

# ── 4. Runtime environment check ─────────────────────────────────────

echo ""
_m step_env

# Python
if command -v python3 >/dev/null 2>&1; then
  _m python_ok
else
  _m python_missing
  _m python_hint
fi

# R
if command -v Rscript >/dev/null 2>&1; then
  _m r_ok
else
  _m r_missing
  _m r_hint
fi

# ── 5. Web search setup ───────────────────────────────────────────────

echo ""
_m step_search
if [ -f "$ENV_FILE" ] && grep -q "^BRAVE_API_KEY=" "$ENV_FILE" 2>/dev/null; then
  _m search_saved
else
  echo ""
  _m search_intro
  _m search_url
  echo ""
  _m search_input
  read BRAVE_KEY
  if [ -n "$BRAVE_KEY" ]; then
    if [ -f "$ENV_FILE" ]; then
      echo "BRAVE_API_KEY=$BRAVE_KEY" >> "$ENV_FILE"
    fi
    _m search_saved
  else
    _m search_skip
  fi
fi

# ── 6. Channel setup ─────────────────────────────────────────────────

echo ""
_m step_channel
echo ""
_m channel_intro
_m channel_later
echo ""
_m channel_list
_m channel_tg
_m channel_dc
_m channel_sl
_m channel_wa
_m channel_fs
_m channel_mx
_m channel_wc
_m channel_skip
echo ""
_m channel_pick
read CHANNEL_CHOICE
CHANNEL_CHOICE="${CHANNEL_CHOICE:-0}"

case "$CHANNEL_CHOICE" in
  1) node "$ROOT/scripts/channel.mjs" add telegram || true ;;
  2) node "$ROOT/scripts/channel.mjs" add discord || true ;;
  3) node "$ROOT/scripts/channel.mjs" add slack || true ;;
  4) node "$ROOT/scripts/channel.mjs" add whatsapp || true ;;
  5) node "$ROOT/scripts/channel.mjs" add feishu || true ;;
  6) node "$ROOT/scripts/channel.mjs" add matrix || true ;;
  7) node "$ROOT/scripts/channel.mjs" add wechat || true ;;
  0|"") _m channel_skipped ;;
  *) _m channel_unknown ;;
esac

# ── Done ──────────────────────────────────────────────────────────────

echo ""
_m sep
_m complete
echo ""
_m quickstart
_m next_run
_m next_dash
echo ""
_m addchannel
_m next_add
_m next_channels
echo ""
_m needhelp
_m next_help
echo ""
