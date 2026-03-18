#!/usr/bin/env node
/**
 * ScienceClaw Channel Manager — bilingual, with token validation
 *
 * Usage:
 *   node channel.mjs add <channel> [token] [token2]
 *   node channel.mjs remove <channel>
 *   node channel.mjs list
 */

import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { createInterface } from "node:readline";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const CONFIG_PATH = resolve(ROOT, "openclaw.config.json");
const ENV_PATH = resolve(ROOT, ".env");

const LANG = process.env.SCIENCECLAW_LANG || "zh";

// ── i18n helper ──────────────────────────────────────────────────────

function _m(key, ...args) {
  const msgs = {
    zh: {
      adding:          (name) => `  添加 ${name} 渠道`,
      hint:            (h) => `  💡 ${h}`,
      already_exists:  (name) => `  ⚠️  ${name} 已配置。`,
      overwrite:       "  覆盖? (y/N): ",
      cancelled:       "  已取消。",
      required:        (p) => `  ❌ ${p} 是必填项。`,
      added:           (name) => `  ✅ ${name} 已添加!`,
      creds_saved:     "  📝 凭证已保存到 .env",
      removed:         (name) => `  ✅ ${name} 已移除。`,
      apply:           "  应用更改: ./scienceclaw restart",
      no_channels:     "  未配置任何渠道。",
      add_one:         "  添加: ./scienceclaw add <渠道>",
      options:         (list) => `  可选: ${list}`,
      active:          "  已配置的渠道:",
      available:       "  可添加的渠道:",
      always:          "  网页面板和终端界面始终可用:",
      run_tui:         "    ./scienceclaw run          # 终端界面",
      run_dash:        "    ./scienceclaw dashboard     # 网页面板",
      unknown:         (id) => `  ❌ 未知渠道: ${id}`,
      supported:       (list) => `  支持: ${list}`,
      usage_add:       "  用法: ./scienceclaw add <渠道> [token...]",
      usage_remove:    "  用法: ./scienceclaw remove <渠道>",
      channels_list:   (list) => `  渠道: ${list}`,
      validating:      "  正在验证...",
      valid:           "  ✅ Token 验证通过",
      invalid:         "  ⚠️  Token 验证失败，请检查是否正确",
      whatsapp_next:   "  下一步: 扫描二维码绑定 WhatsApp:",
      whatsapp_cmd:    "    ./scienceclaw channels login --channel whatsapp",
      config_error:    (p, e) => `  ❌ 无法读取 ${p}: ${e}`,
      config_hint:     "  请运行: bash scripts/setup.sh",
    },
    en: {
      adding:          (name) => `  Adding ${name} channel`,
      hint:            (h) => `  💡 ${h}`,
      already_exists:  (name) => `  ⚠️  ${name} is already configured.`,
      overwrite:       "  Overwrite? (y/N): ",
      cancelled:       "  Cancelled.",
      required:        (p) => `  ❌ ${p} is required.`,
      added:           (name) => `  ✅ ${name} added!`,
      creds_saved:     "  📝 Credentials saved to .env",
      removed:         (name) => `  ✅ ${name} removed.`,
      apply:           "  Apply changes: ./scienceclaw restart",
      no_channels:     "  No channels configured.",
      add_one:         "  Add one: ./scienceclaw add <channel>",
      options:         (list) => `  Options: ${list}`,
      active:          "  Active channels:",
      available:       "  Available to add:",
      always:          "  Web Dashboard and Terminal UI are always available:",
      run_tui:         "    ./scienceclaw run          # Terminal UI",
      run_dash:        "    ./scienceclaw dashboard     # Web browser",
      unknown:         (id) => `  ❌ Unknown channel: ${id}`,
      supported:       (list) => `  Supported: ${list}`,
      usage_add:       "  Usage: ./scienceclaw add <channel> [token...]",
      usage_remove:    "  Usage: ./scienceclaw remove <channel>",
      channels_list:   (list) => `  Channels: ${list}`,
      validating:      "  Validating...",
      valid:           "  ✅ Token validated",
      invalid:         "  ⚠️  Token validation failed, please check",
      whatsapp_next:   "  Next: scan QR code to link WhatsApp:",
      whatsapp_cmd:    "    ./scienceclaw channels login --channel whatsapp",
      config_error:    (p, e) => `  ❌ Cannot read ${p}: ${e}`,
      config_hint:     "  Run: bash scripts/setup.sh",
    },
  };
  const lang = LANG === "zh" ? "zh" : "en";
  const fn = msgs[lang][key];
  if (!fn) return `[i18n:${key}]`;
  return typeof fn === "function" ? fn(...args) : fn;
}

// ── Channel definitions ─────────────────────────────────────────────

const CHANNELS = {
  telegram: {
    name: LANG === "zh" ? "Telegram" : "Telegram",
    envKeys: ["TELEGRAM_BOT_TOKEN"],
    prompts: [LANG === "zh" ? "Telegram Bot Token (从 @BotFather 获取)" : "Telegram bot token (from @BotFather)"],
    config: {
      enabled: true,
      dmPolicy: "open",
      allowFrom: ["*"],
      botToken: "${TELEGRAM_BOT_TOKEN}",
      groupPolicy: "open",
      groupAllowFrom: ["*"],
      streaming: "partial",
      commands: { native: false },
      timeoutSeconds: 90,
      retry: { attempts: 5, minDelayMs: 500, maxDelayMs: 30000, jitter: 0.2 },
      network: { autoSelectFamily: false, dnsResultOrder: "ipv4first" },
    },
    plugin: true,
    hint: LANG === "zh"
      ? "在 Telegram 中找 @BotFather，创建一个 bot，然后粘贴 token。"
      : "Create a bot at @BotFather on Telegram, then paste the token here.",
    validate: async (token) => {
      try {
        const res = await fetch(`https://api.telegram.org/bot${token}/getMe`, { signal: AbortSignal.timeout(10000) });
        const data = await res.json();
        return data.ok === true;
      } catch { return null; }
    },
    tokenPattern: /^\d+:[A-Za-z0-9_-]{30,}$/,
  },
  discord: {
    name: "Discord",
    envKeys: ["DISCORD_BOT_TOKEN"],
    prompts: [LANG === "zh" ? "Discord Bot Token" : "Discord bot token"],
    config: {
      enabled: true,
      token: "${DISCORD_BOT_TOKEN}",
      dmPolicy: "open",
      allowFrom: ["*"],
      streaming: "partial",
      commands: { native: false },
      retry: { attempts: 3, minDelayMs: 500, maxDelayMs: 30000, jitter: 0.1 },
    },
    plugin: true,
    hint: LANG === "zh"
      ? "在 discord.com/developers/applications 创建应用 → Bot → 复制 Token。\n  开启所有 Privileged Gateway Intents。"
      : "Create a bot at discord.com/developers/applications → Bot → Copy Token.\n  Enable all Privileged Gateway Intents.",
  },
  slack: {
    name: "Slack",
    envKeys: ["SLACK_BOT_TOKEN", "SLACK_APP_TOKEN"],
    prompts: [
      LANG === "zh" ? "Slack Bot Token (xoxb-...)" : "Slack bot token (xoxb-...)",
      LANG === "zh" ? "Slack App Token (xapp-...)" : "Slack app token (xapp-...)",
    ],
    config: {
      enabled: true,
      botToken: "${SLACK_BOT_TOKEN}",
      appToken: "${SLACK_APP_TOKEN}",
      dmPolicy: "open",
      allowFrom: ["*"],
      streaming: "partial",
    },
    plugin: true,
    hint: LANG === "zh"
      ? "在 api.slack.com/apps 创建应用 → Socket Mode → 获取 App Token (xapp-)。\n  安装到工作区 → 获取 Bot Token (xoxb-)。"
      : "Create a Slack app at api.slack.com/apps → Socket Mode → get App Token (xapp-).\n  Install to workspace → get Bot Token (xoxb-).",
  },
  whatsapp: {
    name: "WhatsApp",
    envKeys: [],
    prompts: [],
    config: {
      dmPolicy: "open",
      allowFrom: ["*"],
      sendReadReceipts: true,
      groups: { "*": { requireMention: true } },
    },
    extraConfig: {
      web: {
        enabled: true,
        heartbeatSeconds: 60,
        reconnect: { initialMs: 2000, maxMs: 120000, factor: 1.4, jitter: 0.2, maxAttempts: 0 },
      },
    },
    plugin: false,
    hint: LANG === "zh"
      ? "添加后运行: ./scienceclaw channels login --channel whatsapp\n  然后用手机扫描二维码。"
      : "After adding, run: ./scienceclaw channels login --channel whatsapp\n  Then scan the QR code with WhatsApp on your phone.",
  },
  feishu: {
    name: LANG === "zh" ? "飞书 / Lark" : "Feishu / Lark",
    envKeys: ["FEISHU_APP_ID", "FEISHU_APP_SECRET"],
    prompts: [
      LANG === "zh" ? "飞书 App ID" : "Feishu App ID",
      LANG === "zh" ? "飞书 App Secret" : "Feishu App Secret",
    ],
    config: {
      enabled: true,
      appId: "${FEISHU_APP_ID}",
      appSecret: "${FEISHU_APP_SECRET}",
      dmPolicy: "open",
      allowFrom: ["*"],
    },
    plugin: true,
    hint: LANG === "zh"
      ? "在 open.feishu.cn 创建自建应用 → 添加机器人能力 → 获取 App ID 和 Secret。"
      : "Create a custom app at open.feishu.cn → add Bot capability → get App ID & Secret.",
  },
  matrix: {
    name: "Matrix",
    envKeys: ["MATRIX_HOMESERVER", "MATRIX_USER_ID", "MATRIX_ACCESS_TOKEN"],
    prompts: [
      LANG === "zh" ? "Matrix 服务器 URL (如 https://matrix.org)" : "Matrix homeserver URL (e.g., https://matrix.org)",
      LANG === "zh" ? "Bot 用户 ID (如 @scienceclaw:matrix.org)" : "Bot user ID (e.g., @scienceclaw:matrix.org)",
      LANG === "zh" ? "Access Token" : "Access token",
    ],
    config: {
      enabled: true,
      homeserver: "${MATRIX_HOMESERVER}",
      userId: "${MATRIX_USER_ID}",
      accessToken: "${MATRIX_ACCESS_TOKEN}",
      dmPolicy: "open",
      allowFrom: ["*"],
    },
    plugin: true,
    hint: LANG === "zh"
      ? "在你的服务器上创建 bot 账号，然后通过 Element 或 login API 获取 access token。"
      : "Create a bot account on your homeserver, then get an access token via Element or the login API.",
  },
  wechat: {
    name: LANG === "zh" ? "企业微信 (WeCom)" : "WeCom",
    envKeys: ["WECOM_CORP_ID", "WECOM_AGENT_SECRET", "WECOM_TOKEN", "WECOM_AES_KEY"],
    prompts: [
      LANG === "zh" ? "企业微信 Corp ID" : "WeCom Corp ID",
      LANG === "zh" ? "应用 Secret" : "WeCom Agent Secret",
      LANG === "zh" ? "回调 Token" : "Callback Token",
      LANG === "zh" ? "回调 EncodingAESKey" : "Callback EncodingAESKey",
    ],
    config: {
      enabled: true,
      corpId: "${WECOM_CORP_ID}",
      agentSecret: "${WECOM_AGENT_SECRET}",
      token: "${WECOM_TOKEN}",
      aesKey: "${WECOM_AES_KEY}",
      dmPolicy: "open",
      allowFrom: ["*"],
    },
    plugin: true,
    hint: LANG === "zh"
      ? "在 work.weixin.qq.com → 应用管理 → 创建应用 → 获取凭证。"
      : "Create an app at work.weixin.qq.com → App Management → get credentials.",
  },
};

// ── Utilities ────────────────────────────────────────────────────────

function readConfig() {
  try {
    return JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
  } catch (err) {
    console.error(_m("config_error", CONFIG_PATH, err.message));
    console.error(_m("config_hint"));
    process.exit(1);
  }
}

function writeConfig(cfg) {
  writeFileSync(CONFIG_PATH, JSON.stringify(cfg, null, 2) + "\n");
}

function readEnv() {
  if (!existsSync(ENV_PATH)) return {};
  const lines = readFileSync(ENV_PATH, "utf8").split("\n");
  const env = {};
  for (const line of lines) {
    const m = line.match(/^([A-Za-z_][A-Za-z_0-9]*)=(.*)/);
    if (m) env[m[1]] = m[2];
  }
  return env;
}

function setEnvVar(key, value) {
  if (!existsSync(ENV_PATH)) {
    writeFileSync(ENV_PATH, `${key}=${value}\n`);
    return;
  }
  let content = readFileSync(ENV_PATH, "utf8");
  const regex = new RegExp(`^${key}=.*$`, "m");
  if (regex.test(content)) {
    content = content.replace(regex, `${key}=${value}`);
  } else {
    content = content.trimEnd() + `\n${key}=${value}\n`;
  }
  writeFileSync(ENV_PATH, content);
}

function removeEnvVar(key) {
  if (!existsSync(ENV_PATH)) return;
  let content = readFileSync(ENV_PATH, "utf8");
  content = content.replace(new RegExp(`^${key}=.*\n?`, "m"), "");
  writeFileSync(ENV_PATH, content);
}

async function prompt(question) {
  const rl = createInterface({ input: process.stdin, output: process.stderr });
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

// ── Commands ─────────────────────────────────────────────────────────

async function addChannel(channelId, args) {
  const def = CHANNELS[channelId];
  if (!def) {
    const supported = Object.keys(CHANNELS).join(", ");
    console.error(_m("unknown", channelId));
    console.error(_m("supported", supported));
    process.exit(1);
  }

  console.error("");
  console.error(_m("adding", def.name));
  console.error(`  ${"─".repeat(40)}`);
  if (def.hint) {
    console.error(_m("hint", def.hint));
    console.error("");
  }

  const cfg = readConfig();
  if (cfg.channels?.[channelId]?.enabled) {
    console.error(_m("already_exists", def.name));
    const answer = await prompt(_m("overwrite"));
    if (answer.toLowerCase() !== "y") {
      console.error(_m("cancelled"));
      process.exit(0);
    }
  }

  const values = [];
  for (let i = 0; i < def.envKeys.length; i++) {
    let value = args[i] || "";
    if (!value) {
      value = await prompt(`  ${def.prompts[i]}: `);
    }
    if (!value) {
      console.error(_m("required", def.prompts[i]));
      process.exit(1);
    }

    // Format validation
    if (def.tokenPattern && i === 0 && !def.tokenPattern.test(value)) {
      console.error(_m("invalid"));
      process.exit(1);
    }

    values.push(value);
  }

  // API validation for Telegram
  if (def.validate && values.length > 0) {
    console.error(_m("validating"));
    const result = await def.validate(values[0]);
    if (result === true) {
      console.error(_m("valid"));
    } else if (result === false) {
      console.error(_m("invalid"));
    }
    // null = network issue, skip silently
  }

  for (let i = 0; i < def.envKeys.length; i++) {
    setEnvVar(def.envKeys[i], values[i]);
  }

  if (!cfg.channels) cfg.channels = {};
  cfg.channels[channelId] = def.config;

  if (def.extraConfig) {
    for (const [key, val] of Object.entries(def.extraConfig)) {
      cfg[key] = val;
    }
  }

  if (def.plugin) {
    if (!cfg.plugins) cfg.plugins = { entries: {} };
    if (!cfg.plugins.entries) cfg.plugins.entries = {};
    cfg.plugins.entries[channelId] = { enabled: true };
  }

  writeConfig(cfg);

  console.error("");
  console.error(_m("added", def.name));
  if (def.envKeys.length > 0) {
    console.error(_m("creds_saved"));
  }
  if (channelId === "whatsapp") {
    console.error("");
    console.error(_m("whatsapp_next"));
    console.error(_m("whatsapp_cmd"));
  }
  console.error("");
  console.error(_m("apply"));
  console.error("");
}

function removeChannel(channelId) {
  const def = CHANNELS[channelId];
  if (!def) {
    console.error(_m("unknown", channelId));
    process.exit(1);
  }

  const cfg = readConfig();
  if (cfg.channels && cfg.channels[channelId]) {
    delete cfg.channels[channelId];
  }
  if (cfg.plugins?.entries?.[channelId]) {
    delete cfg.plugins.entries[channelId];
  }
  if (channelId === "whatsapp" && cfg.web) {
    delete cfg.web;
  }
  writeConfig(cfg);

  for (const key of def.envKeys) {
    removeEnvVar(key);
  }

  console.error("");
  console.error(_m("removed", def.name));
  console.error(_m("apply"));
  console.error("");
}

function listChannels() {
  const cfg = readConfig();
  const env = readEnv();
  const active = [];
  const inactive = [];

  for (const [id, def] of Object.entries(CHANNELS)) {
    const ch = cfg.channels?.[id];
    if (ch && ch.enabled !== false) {
      const hasCredentials = def.envKeys.length === 0 ||
        def.envKeys.every((k) => env[k]);
      active.push({ id, name: def.name, hasCredentials });
    } else {
      inactive.push({ id, name: def.name });
    }
  }

  console.error("");
  if (active.length === 0) {
    console.error(_m("no_channels"));
    console.error(_m("add_one"));
    console.error(_m("options", Object.keys(CHANNELS).join(", ")));
  } else {
    console.error(_m("active"));
    for (const ch of active) {
      const status = ch.hasCredentials
        ? "✅"
        : LANG === "zh" ? "⚠️  (缺少 .env 中的凭证)" : "⚠️  (missing credentials in .env)";
      console.error(`    ${status} ${ch.name} (${ch.id})`);
    }
    if (inactive.length > 0) {
      console.error("");
      console.error(_m("available"));
      for (const ch of inactive) {
        console.error(`    ○  ${ch.name} — ./scienceclaw add ${ch.id}`);
      }
    }
  }

  console.error("");
  console.error(_m("always"));
  console.error(_m("run_tui"));
  console.error(_m("run_dash"));
  console.error("");
}

// ── Main ─────────────────────────────────────────────────────────────

const [, , command, channelId, ...rest] = process.argv;

switch (command) {
  case "add":
    if (!channelId) {
      console.error(_m("usage_add"));
      console.error(_m("channels_list", Object.keys(CHANNELS).join(", ")));
      process.exit(1);
    }
    await addChannel(channelId, rest);
    break;
  case "remove":
    if (!channelId) {
      console.error(_m("usage_remove"));
      process.exit(1);
    }
    removeChannel(channelId);
    break;
  case "list":
    listChannels();
    break;
  default:
    console.error("  Usage:");
    console.error(_m("usage_add"));
    console.error(_m("usage_remove"));
    console.error("    ./scienceclaw channels");
    process.exit(1);
}
