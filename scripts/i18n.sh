#!/bin/bash
# ScienceClaw i18n — bilingual message helper
# Sourced by scienceclaw and setup.sh. Uses SCIENCECLAW_LANG (zh|en).

_msg() {
  local key="$1"; shift
  if [ "${SCIENCECLAW_LANG:-zh}" = "zh" ]; then
    case "$key" in
      # ── Gateway lifecycle ──
      gw_starting)      echo "  🚀 正在启动 ScienceClaw（端口 $GW_PORT）..." ;;
      gw_ready)         echo "  ✅ ScienceClaw 已启动" ;;
      gw_ready_pid)     echo "     进程 PID: ${1:-?}" ;;
      gw_failed)        echo "  ❌ 启动失败" ;;
      gw_failed_log)    echo "     日志文件: $GW_LOG" ;;
      gw_failed_tail)   echo "     最近日志:" ;;
      gw_stopped)       echo "  ✅ 已停止" ;;
      gw_not_running)   echo "  ⬜ 当前没有在运行" ;;
      gw_restarted)     echo "  ✅ 已重启，配置已更新" ;;
      wd_active)        echo "  🛡️  自动守护已开启（每 ${GW_WATCHDOG_INTERVAL}s 检查一次）" ;;
      wd_not_running)   echo "  ⚠️  自动守护未运行" ;;
      engine_missing)   echo "  ❌ 未找到 OpenClaw 引擎，请运行: bash scripts/setup.sh" ;;
      config_missing)   echo "  ❌ 未找到 openclaw.config.json" ;;
      no_log)           echo "  ⬜ 暂无日志: $GW_LOG" ;;

      # ── Status ──
      status_running)   echo "  ✅ ScienceClaw 运行中" ;;
      status_stopped)   echo "  ⬜ ScienceClaw 未运行" ;;
      status_model)     echo "     模型: ${1:-未知}" ;;
      status_channels)  echo "     渠道: ${1:-无}" ;;
      status_project)   echo "     项目: ${1:-无}" ;;
      status_log)       echo "     日志: $GW_LOG" ;;

      # ── Security ──
      sec_default_token)  echo "  ⚠️  警告: 正在使用默认 Gateway Token" ;;
      sec_token_hint)     echo "     请运行 setup 或在 .env 中设置 GATEWAY_AUTH_TOKEN" ;;
      sec_token_block)    echo "  ❌ 已配置外部渠道但仍使用默认 Token，出于安全考虑已阻止启动" ;;
      sec_token_block_h)  echo "     请设置安全的 GATEWAY_AUTH_TOKEN 后再试" ;;
      sec_open_access)    echo "  ⚠️  当前所有人都可以通过 ${1:-消息渠道} 使用 ScienceClaw" ;;
      sec_open_hint)      echo "     如需限制访问，请在 openclaw.config.json 中配置 allowFrom" ;;

      # ── Help ──
      help_title)       echo "  ScienceClaw — 你的 AI 科研同事" ;;
      help_usage)       echo "  用法: ./scienceclaw <命令>" ;;
      help_start)       echo "  快速开始:" ;;
      help_run)         echo "    setup               交互式安装向导" ;;
      help_run2)        echo "    run                 启动服务 + 终端界面" ;;
      help_stop)        echo "    stop                停止服务" ;;
      help_restart)     echo "    restart             重启服务（重新加载配置）" ;;
      help_status)      echo "    status              查看运行状态" ;;
      help_ch)          echo "  渠道:" ;;
      help_add)         echo "    add <渠道>          添加消息渠道" ;;
      help_remove)      echo "    remove <渠道>       移除渠道" ;;
      help_channels)    echo "    channels            查看已配置的渠道" ;;
      help_proj)        echo "  项目:" ;;
      help_proj_new)    echo "    project new \"名称\"  创建研究项目" ;;
      help_proj_list)   echo "    project list        查看所有项目" ;;
      help_proj_open)   echo "    project open <名称> 打开项目目录" ;;
      help_adv)         echo "  更多:" ;;
      help_tui)         echo "    tui                 终端界面（自动启动服务）" ;;
      help_dash)        echo "    dashboard           网页面板" ;;
      help_models)      echo "    models              检测模型状态（哪些能用、哪些挂了）" ;;
      help_doctor)      echo "    doctor              全面健康检查" ;;
      help_skills)      echo "    skills              浏览专业能力（266 项）" ;;
      help_outputs)     echo "    outputs             查看输出文件" ;;
      help_logs)        echo "    logs                查看实时日志" ;;
      help_ask)         echo "    ask \"问题\"          一次性提问" ;;
      help_auto)        echo "    autostart           配置开机自启" ;;
      help_recipes)     echo "    recipes             查看研究模板（一句话启动完整流程）" ;;
      help_supported)   echo "  支持的渠道:" ;;
      help_ch_list)     echo "    telegram  discord  slack  whatsapp  feishu  matrix  wechat" ;;

      # ── Recipes ──
      recipes_title)    echo "  研究模板 (Research Recipes)" ;;
      recipes_desc)     echo "  一句话启动完整研究流程。ScienceClaw 会自动匹配最合适的模板：" ;;
      recipes_gene)     echo "    gene-landscape      分析基因在疾病中的作用（文献+表达谱+生存+免疫+通路+报告）" ;;
      recipes_target)   echo "    target-validation   评估靶点成药性（文献+互作+化合物+药物+临床+专利+报告）" ;;
      recipes_lit)      echo "    literature-review   系统性文献综述（多源检索50+→筛选→全文→趋势→综述）" ;;
      recipes_deg)      echo "    diff-expression     差异表达分析（QC+DESeq2+火山图+热图+GO/KEGG+报告）" ;;
      recipes_clinical) echo "    clinical-query      临床问题快查（试验+指南+药物+汇总）" ;;
      recipes_person)   echo "    person-research     学者画像（论文+引用+合作+代表作+报告）" ;;
      recipes_usage)    echo "  用法示例:" ;;
      recipes_ex1)      echo "    ./scienceclaw ask \"分析 TP53 在肝癌中的作用\"     → 自动匹配 gene-landscape" ;;
      recipes_ex2)      echo "    ./scienceclaw ask \"综述 CRISPR 在基因治疗中的应用\" → 自动匹配 literature-review" ;;

      # ── First run ──
      first_run_welcome) echo "  🔬 欢迎使用 ScienceClaw！" ;;
      first_run_hint)    echo "  试试输入一个研究问题，例如：" ;;
      first_run_ex1)     echo "    \"分析 BRCA1 在乳腺癌中的作用\"" ;;
      first_run_ex2)     echo "    \"综述 CRISPR 在基因治疗中的应用\"" ;;
      first_run_ex3)     echo "    \"KRAS G12C 有哪些已批准的靶向药\"" ;;
      first_run_more)    echo "  输入 /recipes 查看所有研究模板" ;;

      # ── Models ──
      models_no_config) echo "没有运行时配置，请先运行: ./scienceclaw setup" ;;

      # ── Doctor ──
      doc_title)        echo "  ScienceClaw 健康检查" ;;
      doc_ok)           echo "    ✅ ${1}" ;;
      doc_warn)         echo "    ⚠️  ${1}" ;;
      doc_fail)         echo "    ❌ ${1}" ;;
      doc_section)      echo "  ${1}" ;;

      # ── Skills ──
      skills_title)     echo "  ScienceClaw 专业能力" ;;
      skills_count)     echo "  共 ${1:-0} 项 skill，覆盖以下领域:" ;;
      skills_search)    echo "  搜索: ./scienceclaw skills search \"关键词\"" ;;
      skills_none)      echo "  未找到匹配的 skill" ;;

      # ── Outputs ──
      out_title)        echo "  最近的输出文件" ;;
      out_empty)        echo "  暂无输出文件" ;;
      out_hint)         echo "  提示: 向 ScienceClaw 提问后，输出文件会出现在这里" ;;
      out_cleaned)      echo "  ✅ 已清理 ${1:-0} 天前的临时文件" ;;

      # ── Autostart ──
      auto_installed)   echo "  ✅ 开机自启已配置" ;;
      auto_detail_mac)  echo "     macOS LaunchAgent 已安装，登录后自动启动" ;;
      auto_detail_linux) echo "     systemd 用户服务已安装，开机后自动启动" ;;
      auto_keepalive)   echo "     进程崩溃后会在 10 秒内自动恢复" ;;
      auto_removed)     echo "  ✅ 开机自启已移除" ;;
      auto_not_found)   echo "  ⬜ 未配置开机自启" ;;
      auto_status_on)   echo "  🟢 开机自启: 已开启" ;;
      auto_status_off)  echo "  ⚪ 开机自启: 未开启" ;;
      auto_unsupported) echo "  ❌ 当前系统不支持自动配置，请手动设置" ;;
      auto_hint_enable) echo "     开启: ./scienceclaw autostart enable" ;;
      auto_hint_disable) echo "     关闭: ./scienceclaw autostart disable" ;;

      *) echo "  [i18n:$key] $*" ;;
    esac
  else
    case "$key" in
      gw_starting)      echo "  🚀 Starting ScienceClaw (port $GW_PORT)..." ;;
      gw_ready)         echo "  ✅ ScienceClaw is ready" ;;
      gw_ready_pid)     echo "     PID: ${1:-?}" ;;
      gw_failed)        echo "  ❌ Failed to start" ;;
      gw_failed_log)    echo "     Log: $GW_LOG" ;;
      gw_failed_tail)   echo "     Recent log:" ;;
      gw_stopped)       echo "  ✅ Stopped" ;;
      gw_not_running)   echo "  ⬜ Not running" ;;
      gw_restarted)     echo "  ✅ Restarted with fresh config" ;;
      wd_active)        echo "  🛡️  Watchdog active (checks every ${GW_WATCHDOG_INTERVAL}s)" ;;
      wd_not_running)   echo "  ⚠️  Watchdog not running" ;;
      engine_missing)   echo "  ❌ OpenClaw engine not found. Run: bash scripts/setup.sh" ;;
      config_missing)   echo "  ❌ openclaw.config.json not found" ;;
      no_log)           echo "  ⬜ No log file at $GW_LOG" ;;

      status_running)   echo "  ✅ ScienceClaw is running" ;;
      status_stopped)   echo "  ⬜ ScienceClaw is not running" ;;
      status_model)     echo "     Model: ${1:-unknown}" ;;
      status_channels)  echo "     Channels: ${1:-none}" ;;
      status_project)   echo "     Project: ${1:-none}" ;;
      status_log)       echo "     Log: $GW_LOG" ;;

      sec_default_token)  echo "  ⚠️  Warning: using default gateway token" ;;
      sec_token_hint)     echo "     Run setup or set GATEWAY_AUTH_TOKEN in .env" ;;
      sec_token_block)    echo "  ❌ External channels configured with default token — blocked for security" ;;
      sec_token_block_h)  echo "     Set a secure GATEWAY_AUTH_TOKEN first" ;;
      sec_open_access)    echo "  ⚠️  Anyone can use ScienceClaw via ${1:-messaging channel}" ;;
      sec_open_hint)      echo "     Set allowFrom in openclaw.config.json to restrict access" ;;

      help_title)       echo "  ScienceClaw — Your AI Research Colleague" ;;
      help_usage)       echo "  Usage: ./scienceclaw <command>" ;;
      help_start)       echo "  Getting started:" ;;
      help_run)         echo "    setup               Interactive setup wizard" ;;
      help_run2)        echo "    run                 Start gateway + open TUI" ;;
      help_stop)        echo "    stop                Stop gateway + watchdog" ;;
      help_restart)     echo "    restart             Restart gateway (rebuild config)" ;;
      help_status)      echo "    status              Check status" ;;
      help_ch)          echo "  Channels:" ;;
      help_add)         echo "    add <channel>       Add a messaging channel" ;;
      help_remove)      echo "    remove <channel>    Remove a channel" ;;
      help_channels)    echo "    channels            List configured channels" ;;
      help_proj)        echo "  Projects:" ;;
      help_proj_new)    echo "    project new \"name\"  Create a research project" ;;
      help_proj_list)   echo "    project list        List all projects" ;;
      help_proj_open)   echo "    project open <name> Open project directory" ;;
      help_adv)         echo "  Advanced:" ;;
      help_tui)         echo "    tui                 Open TUI (auto-starts gateway)" ;;
      help_dash)        echo "    dashboard           Open web dashboard" ;;
      help_models)      echo "    models              Check model status (which ones work)" ;;
      help_doctor)      echo "    doctor              Full health check" ;;
      help_skills)      echo "    skills              Browse capabilities (266 skills)" ;;
      help_outputs)     echo "    outputs             View output files" ;;
      help_logs)        echo "    logs                Tail gateway logs" ;;
      help_ask)         echo "    ask \"query\"          One-shot query" ;;
      help_auto)        echo "    autostart           Configure auto-start on boot" ;;
      help_recipes)     echo "    recipes             Research templates (one-liner to full workflow)" ;;
      help_supported)   echo "  Supported channels:" ;;
      help_ch_list)     echo "    telegram  discord  slack  whatsapp  feishu  matrix  wechat" ;;

      # ── Recipes ──
      recipes_title)    echo "  Research Recipes" ;;
      recipes_desc)     echo "  One-liner triggers for full research workflows. ScienceClaw auto-matches:" ;;
      recipes_gene)     echo "    gene-landscape      Analyze gene role in disease (lit+expression+survival+immune+pathway+report)" ;;
      recipes_target)   echo "    target-validation   Evaluate druggability (lit+interactions+compounds+drugs+trials+patents+report)" ;;
      recipes_lit)      echo "    literature-review   Systematic review (multi-source 50+→filter→full-text→trend→review)" ;;
      recipes_deg)      echo "    diff-expression     Differential expression (QC+DESeq2+volcano+heatmap+GO/KEGG+report)" ;;
      recipes_clinical) echo "    clinical-query      Clinical quick-query (trials+guidelines+drugs+summary)" ;;
      recipes_person)   echo "    person-research     Researcher profile (papers+citations+collaborations+report)" ;;
      recipes_usage)    echo "  Examples:" ;;
      recipes_ex1)      echo "    ./scienceclaw ask \"investigate TP53 in liver cancer\"  → auto-matches gene-landscape" ;;
      recipes_ex2)      echo "    ./scienceclaw ask \"survey CRISPR in gene therapy\"     → auto-matches literature-review" ;;

      # ── First run ──
      first_run_welcome) echo "  🔬 Welcome to ScienceClaw!" ;;
      first_run_hint)    echo "  Try a research question, for example:" ;;
      first_run_ex1)     echo "    \"Investigate BRCA1 in breast cancer\"" ;;
      first_run_ex2)     echo "    \"Survey CRISPR applications in gene therapy\"" ;;
      first_run_ex3)     echo "    \"What targeted drugs are approved for KRAS G12C?\"" ;;
      first_run_more)    echo "  Type /recipes to see all research templates" ;;

      models_no_config) echo "Runtime config not found. Run: ./scienceclaw setup" ;;

      doc_title)        echo "  ScienceClaw Health Check" ;;
      doc_ok)           echo "    ✅ ${1}" ;;
      doc_warn)         echo "    ⚠️  ${1}" ;;
      doc_fail)         echo "    ❌ ${1}" ;;
      doc_section)      echo "  ${1}" ;;

      skills_title)     echo "  ScienceClaw Skills" ;;
      skills_count)     echo "  ${1:-0} skills across these domains:" ;;
      skills_search)    echo "  Search: ./scienceclaw skills search \"keyword\"" ;;
      skills_none)      echo "  No matching skills found" ;;

      out_title)        echo "  Recent output files" ;;
      out_empty)        echo "  No output files yet" ;;
      out_hint)         echo "  Tip: ask ScienceClaw a research question and outputs will appear here" ;;
      out_cleaned)      echo "  ✅ Cleaned temporary files older than ${1:-0} days" ;;

      auto_installed)   echo "  ✅ Autostart configured" ;;
      auto_detail_mac)  echo "     macOS LaunchAgent installed — starts on login" ;;
      auto_detail_linux) echo "     systemd user service installed — starts on boot" ;;
      auto_keepalive)   echo "     Auto-restarts within 10s if process crashes" ;;
      auto_removed)     echo "  ✅ Autostart removed" ;;
      auto_not_found)   echo "  ⬜ Autostart not configured" ;;
      auto_status_on)   echo "  🟢 Autostart: enabled" ;;
      auto_status_off)  echo "  ⚪ Autostart: not enabled" ;;
      auto_unsupported) echo "  ❌ Auto-configuration not supported on this OS" ;;
      auto_hint_enable) echo "     Enable: ./scienceclaw autostart enable" ;;
      auto_hint_disable) echo "     Disable: ./scienceclaw autostart disable" ;;

      *) echo "  [i18n:$key] $*" ;;
    esac
  fi
}
