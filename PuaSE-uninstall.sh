#!/bin/bash
# shellcheck shell=bash disable=SC2016
set -Eeuo pipefail

# PuaSE 卸载脚本 (Linux/macOS)
# 用法:
#   bash PuaSE-uninstall.sh           # 交互模式
#   bash PuaSE-uninstall.sh --force   # 非交互
#   bash PuaSE-uninstall.sh --clean-backups

PUSE_DIR="$HOME/.config/opencode/puse"
OPENCODE_JSON="$HOME/.config/opencode/opencode.json"
CONFIG_TEMPLATE="$(cd "$(dirname "$0")" && pwd)/config_template.json"

FORCE=false
CLEAN_BACKUPS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force|-f) FORCE=true; shift ;;
    --clean-backups) CLEAN_BACKUPS=true; shift ;;
    --help|-h) echo "用法: $0 [--force] [--clean-backups]"; exit 0 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

log_ok()  { echo "  [OK] $1"; }
log_warn(){ echo "  [WARN] $1"; }
log_info(){ echo "  [INFO] $1"; }
log_err() { echo "  [ERROR] $1" >&2; }

_require_python() {
  command -v python3 &>/dev/null && { echo "python3"; return; }
  command -v python &>/dev/null && { echo "python"; return; }
  echo ""
}

# 从 config_template.json 动态读取 Agent 列表
read_agent_names() {
  if [ -f "$CONFIG_TEMPLATE" ]; then
    if command -v jq &>/dev/null; then
      jq -r '.agent | keys[]' "$CONFIG_TEMPLATE" 2>/dev/null || true
      return
    fi
    local py; py="$(_require_python)"
    if [ -n "$py" ]; then
      "$py" -c "
import json, sys
with open('$CONFIG_TEMPLATE') as f:
    t = json.load(f)
agents = t.get('agent', {})
for k in agents:
    print(k)
" 2>/dev/null || true
    fi
  fi
}

echo "PuaSE 卸载脚本"

if [ "$FORCE" = false ]; then
  read -p "确定卸载 PuaSE？将移除配置和安装目录 (y/N) " confirm
  case "$confirm" in
    y|Y) ;;
    *) echo "已取消"; exit 0 ;;
  esac
fi

# ---- 1. 清理 opencode.json ----
echo ""
echo "--- 清理 opencode.json ---"

if [ ! -f "$OPENCODE_JSON" ]; then
  log_warn "未找到 opencode.json，跳过"
else
  local py; py="$(_require_python)"
  if [ -z "$py" ] && ! command -v jq &>/dev/null; then
    log_warn "需要 jq 或 Python 3 来清理 opencode.json"
    echo "请手动编辑 $OPENCODE_JSON:"
    echo "  1. 从 plugin 中移除 puse 相关条目"
    echo "  2. 如 default_agent 为 PuaSE，移除或修改"
    echo "  3. 从 agent 中移除 PuaSE 子 Agent"
  else
    local ts; ts=$(date +%Y%m%d-%H%M%S)
    cp "$OPENCODE_JSON" "${OPENCODE_JSON}.bak.uninstall.${ts}"
    log_info "已备份到 opencode.json.bak.uninstall.${ts}"

    local agents_json; agents_json=$(read_agent_names | paste -sd, - || echo "")
    [ -z "$agents_json" ] && agents_json='["architect","architect-scan","code-reviewer","go-developer","rust-developer","csharp-developer","java-developer","python-developer","cpp-developer","bigdata-developer","web-developer","oracle-dba","mysql-dba","postgresql-dba","security-expert","quality-inspector","documenter","reflector","explore","general"]'

    if command -v jq &>/dev/null; then
      local agents_jq; agents_jq=$(read_agent_names | jq -R . | jq -s . 2>/dev/null || echo '["architect","architect-scan","code-reviewer","go-developer","rust-developer","csharp-developer","java-developer","python-developer","cpp-developer","bigdata-developer","web-developer","oracle-dba","mysql-dba","postgresql-dba","security-expert","quality-inspector","documenter","reflector","explore","general"]')
      local tmp
      tmp=$(jq --argjson agents "$agents_jq" '
        (.plugin // []) |= [.[] | select(
          . != "puse/plugin.js" and
          . != "puse/.opencode/plugins/puse.js" and
          . != "./puse" and
          . != "puse" and
          (. | test("(^|[/\\\\])puse([/\\\\]|$$)") | not)
        )]
        | if .default_agent == "PuaSE" then del(.default_agent) else . end
        | if .agent then
            .agent |= with_entries(select(.key as $k | $agents | index($k) | not))
            | if (.agent | length) == 0 then del(.agent) else . end
          else . end
      ' "$OPENCODE_JSON")
      echo "$tmp" > "$OPENCODE_JSON"
      log_ok "opencode.json 已清理"
    else
      "$py" -c "
import json, sys, re

with open('$OPENCODE_JSON') as f: c = json.load(f)
changed = False

# plugin
plugins = c.get('plugin')
if isinstance(plugins, list):
    matched = lambda e: str(e) in ('puse/plugin.js','puse/.opencode/plugins/puse.js','./puse','puse') or bool(re.search(r'(^|[/\\\\])puse([/\\\\]|\$)', str(e), re.I))
    n = len(plugins)
    c['plugin'] = [p for p in plugins if not matched(p)]
    if len(c['plugin']) < n: changed = True

# default_agent
if c.get('default_agent') == 'PuaSE':
    del c['default_agent']; changed = True

# agent
agents_json_raw = '$agents_json'
agents = {a.strip().strip('\"') for a in agents_json_raw.split(',') if a.strip()}
agt = c.get('agent')
if isinstance(agt, dict):
    rem = [k for k in agt if k in agents]
    for k in rem: del agt[k]
    if rem: changed = True
    if len(agt) == 0: del c['agent']

if changed:
    with open('$OPENCODE_JSON','w') as f: json.dump(c, f, indent=2)
    print('cleaned')
else:
    print('nochange')
" && log_ok "opencode.json 已清理" || log_warn "清理失败，请手动编辑"
    fi
  fi
fi

# ---- 2. 移除安装目录 ----
echo ""
echo "--- 移除安装目录 ---"
if [ -L "$PUSE_DIR" ]; then
  rm "$PUSE_DIR" && log_ok "已移除符号链接: $PUSE_DIR"
elif [ -d "$PUSE_DIR" ]; then
  rm -rf "$PUSE_DIR" && log_ok "已移除目录: $PUSE_DIR"
elif [ -e "$PUSE_DIR" ]; then
  log_warn "$PUSE_DIR 存在但类型未知，请手动删除"
else
  log_info "目录不存在，跳过"
fi

# ---- 3. 可选清理备份 ----
if [ "$CLEAN_BACKUPS" = true ]; then
  echo ""
  echo "--- 清理备份 ---"
  for f in "$OPENCODE_JSON".bak*; do
    [ -f "$f" ] && rm "$f" && log_ok "已删除: $(basename "$f")"
  done
fi

echo ""
echo "=== 卸载完成 ==="
echo "下一步: 重启 OpenCode 使配置生效"
