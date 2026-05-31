#!/bin/bash
# shellcheck shell=bash disable=SC2016
set -Eeuo pipefail

# PuaSE 安装脚本 (Linux/macOS)
# 用法:
#   bash PuaSE-install.sh                    # 交互模式
#   bash PuaSE-install.sh --symlink          # 符号链接模式
#   bash PuaSE-install.sh --copy --force     # 复制模式，跳过交互
#   bash PuaSE-install.sh --no-default       # 不设为默认 Agent
#   bash PuaSE-install.sh --model-config template --force

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PUSE_DIR="$HOME/.config/opencode/puse"
OPENCODE_JSON="$HOME/.config/opencode/opencode.json"
PLUGIN_ENTRY="puse/plugin.js"
PLUGIN_SRC="$REPO_DIR/.opencode/plugins/puse.js"
PLUGIN_DST="$PUSE_DIR/plugin.js"
CONFIG_TEMPLATE="$REPO_DIR/config_template.json"

# ---- CLI 参数解析 ----
MODE=""
NO_DEFAULT=false
MODEL_CFG=""
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --symlink) MODE="symlink"; shift ;;
    --copy) MODE="copy"; shift ;;
    --no-default) NO_DEFAULT=true; shift ;;
    --model-config) MODEL_CFG="$2"; shift 2 ;;
    --force|-f) FORCE=true; shift ;;
    --help|-h) echo "用法: $0 [--symlink|--copy] [--no-default] [--model-config PATH] [--force]"; exit 0 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

# ---- 辅助函数 ----
log_ok()  { echo "  [OK] $1"; }
log_warn(){ echo "  [WARN] $1"; }
log_info(){ echo "  [INFO] $1"; }
log_err() { echo "  [ERROR] $1" >&2; }

_require_python() {
  command -v python3 &>/dev/null && { echo "python3"; return; }
  command -v python &>/dev/null && { echo "python"; return; }
  echo ""
}

# ---- JSON 处理（优先 jq，回退 Python） ----
json_set_plugin() {
  local file="$1" entry="$2"
  local py; py="$(_require_python)"
  if command -v jq &>/dev/null; then
    local tmp; tmp=$(jq --arg e "$entry" '
      if .plugin then
        if (.plugin | index($e)) then . else .plugin = [$e] + .plugin end
      else .plugin = [$e] end
    ' "$file") && echo "$tmp" > "$file" && return 0
  fi
  if [ -n "$py" ]; then
    "$py" -c "
import json, sys
with open('$file') as f: c = json.load(f)
e = '$entry'
p = c.setdefault('plugin', [])
if e not in p:
    p.insert(0, e)
with open('$file', 'w') as f: json.dump(c, f, indent=2)
print('ok')
" && return 0
  fi
  return 1
}

json_set_default_agent() {
  local file="$1" val="$2"
  if command -v jq &>/dev/null; then
    local tmp; tmp=$(jq --arg v "$val" '.default_agent = $v' "$file") && echo "$tmp" > "$file" && return 0
  fi
  local py; py="$(_require_python)"
  if [ -n "$py" ]; then
    "$py" -c "
import json
with open('$file') as f: c = json.load(f)
c['default_agent'] = '$val'
with open('$file', 'w') as f: json.dump(c, f, indent=2)
" && return 0
  fi
  return 1
}

json_merge_agents() {
  local file="$1" tmpl="$2"
  local py; py="$(_require_python)"
  if command -v jq &>/dev/null && [ -f "$tmpl" ]; then
    local tmp; tmp=$(jq -s '.[0].agent = (.[0].agent // {}) * (.[1].agent // {}) | .[0]' "$file" "$tmpl") && echo "$tmp" > "$file" && return 0
  fi
  if [ -n "$py" ] && [ -f "$tmpl" ]; then
    "$py" -c "
import json
with open('$file') as f: c = json.load(f)
with open('$tmpl') as f: t = json.load(f)
if 'agent' in t:
    c.setdefault('agent', {}).update(t['agent'])
with open('$file', 'w') as f: json.dump(c, f, indent=2)
" && return 0
  fi
  return 1
}

update_opencode_json() {
  local set_default="$1" model_cfg="$2"
  echo "--- 更新 opencode.json ---"

  if [ ! -f "$OPENCODE_JSON" ]; then
    cat > "$OPENCODE_JSON" <<- 'EOF'
{"$schema": "https://opencode.ai/config.json"}
EOF
    log_info "已创建 $OPENCODE_JSON"
  fi

  local ts; ts=$(date +%Y%m%d-%H%M%S)
  cp "$OPENCODE_JSON" "${OPENCODE_JSON}.bak.${ts}"
  log_info "已备份到 opencode.json.bak.${ts}"

  json_set_plugin "$OPENCODE_JSON" "$PLUGIN_ENTRY" && log_ok "插件已注册" || log_warn "插件注册失败（可手动编辑）"
  if [ "$set_default" = true ]; then
    json_set_default_agent "$OPENCODE_JSON" "PuaSE" && log_ok "默认 Agent 已设为 PuaSE"
  fi
  if [ -n "$model_cfg" ]; then
    local src; src="$model_cfg"
    [ "$model_cfg" = "template" ] && src="$CONFIG_TEMPLATE"
    if [ -f "$src" ]; then
      json_merge_agents "$OPENCODE_JSON" "$src" && log_ok "子 Agent 配置已合并"
    else
      log_warn "未找到: $src"
    fi
  fi
}

install_symlink() {
  echo "--- 安装模式: 符号链接 ---"
  if [ -L "$PUSE_DIR" ]; then rm "$PUSE_DIR"
  elif [ -e "$PUSE_DIR" ]; then log_err "$PUSE_DIR 已存在但不是符号链接"; return 1; fi
  ln -sf "$REPO_DIR" "$PUSE_DIR" && log_ok "主目录: $PUSE_DIR -> $REPO_DIR"
  mkdir -p "$(dirname "$PLUGIN_DST")"
  [ -e "$PLUGIN_DST" ] && rm -f "$PLUGIN_DST"
  ln -sf "$PLUGIN_SRC" "$PLUGIN_DST" && log_ok "插件入口: $PLUGIN_DST -> $PLUGIN_SRC"
}

install_copy() {
  echo "--- 安装模式: 复制 ---"
  [ -e "$PUSE_DIR" ] && rm -rf "$PUSE_DIR"
  mkdir -p "$PUSE_DIR"
  if command -v rsync &>/dev/null; then
    rsync -a --exclude='node_modules' --exclude='.git' --exclude='.idea' --exclude='.superpowers' --exclude='.logs' --exclude='*.lock' "$REPO_DIR/" "$PUSE_DIR/"
  else
    cp -r "$REPO_DIR" "$PUSE_DIR" && rm -rf "$PUSE_DIR"/node_modules "$PUSE_DIR"/.git "$PUSE_DIR"/.idea 2>/dev/null || true
  fi
  cp "$PLUGIN_SRC" "$PLUGIN_DST" && log_ok "插件入口已复制"
}

invoke_model_config_wizard() {
  local result_file
  result_file="$(mktemp 2>/dev/null || mktemp -t 'puse-result.XXXXXX')"

  python3 -c '
import sys, json

categories = [
    ("Developer 开发 Agent", "java · python · cpp · go · rust · csharp · bigdata · web（共8个）", "代码生成首选",
     ["java-developer","python-developer","cpp-developer","go-developer","rust-developer","csharp-developer","bigdata-developer","web-developer"]),
    ("DBA 数据库 Agent", "mysql-dba · oracle-dba · postgresql-dba（共3个）", "SQL 优化需强推理",
     ["mysql-dba","oracle-dba","postgresql-dba"]),
    ("Security 安全审计 Agent", "security-expert（1个）", "安全审计需高精度",
     ["security-expert"]),
    ("Architect 架构分析 Agent", "architect（1个）", "深度架构分析需强推理",
     ["architect"]),
    ("Architect-Scan 轻量架构扫描", "architect-scan（1个）", "快速扫描轻量化即可",
     ["architect-scan"]),
    ("Code Reviewer 代码审查 Agent", "code-reviewer（1个）", "审查需细致",
     ["code-reviewer"]),
    ("Quality Inspector 质量巡检 Agent", "quality-inspector（1个）", "全面检查",
     ["quality-inspector"]),
    ("Reflector 复盘分析 Agent", "reflector（1个）", "分析推理适中即可",
     ["reflector"]),
    ("Documenter 文档编写 Agent", "documenter（1个）", "文档任务可轻量",
     ["documenter"]),
    ("Explore 代码库探索 Agent", "explore（1个）", "探索扫描可轻量",
     ["explore"]),
]

agent_cfg = {}
total = len(categories)

print("  按分类依次设置各子 Agent 使用的模型，留空 = 使用 OpenCode 全局默认模型。", file=sys.stderr)
print("  模型格式：provider/model-id，如 anthropic/claude-sonnet-4-6", file=sys.stderr)
print("", file=sys.stderr)

for i, (name, detail, tip, keys) in enumerate(categories, 1):
    print(f"[{i}/{total}] {name}", file=sys.stderr)
    print(f"  Agent: {detail}", file=sys.stderr)
    print(f"  推荐: {tip}", file=sys.stderr)
    model = input(f"  模型名称（留空=使用默认模型）: ").strip()
    print("", file=sys.stderr)
    if model:
        for key in keys:
            agent_cfg[key] = {"model": model}

if agent_cfg:
    with open(sys.argv[1], "w", encoding="utf-8") as f:
        json.dump({"agent": agent_cfg}, f, ensure_ascii=False, indent=2)
    print(f"  [OK] 已为 {len(agent_cfg)} 个子 Agent 配置模型", file=sys.stderr)
else:
    print("  [INFO] 未配置任何子 Agent 模型，将使用全局默认模型", file=sys.stderr)
' "$result_file"

  if [ -s "$result_file" ]; then
    echo "$result_file"
  else
    rm -f "$result_file"
    echo ""
  fi
}

# ===== 入口 =====
echo "PuaSE 安装脚本"
echo "  源: $REPO_DIR"
echo "  目标: $PUSE_DIR"

[ -f "$PLUGIN_SRC" ] || { log_err "未找到 $PLUGIN_SRC，请在仓库根目录运行"; exit 1; }

# 交互模式
if [ "$FORCE" = false ] && [ -z "$MODE" ] && [ "$NO_DEFAULT" = false ] && [ -z "$MODEL_CFG" ]; then
  echo ""
  echo "安装模式:"
  echo "  [1] 符号链接（修改即时生效）"
  echo "  [2] 复制（独立副本）"
  read -p "请选择 [1]: " ch
  [ "$ch" = "2" ] && MODE="copy" || MODE="symlink"

  read -p "设为默认 Agent? (Y/n) [Y]: " d
  [ "$d" = "n" ] || [ "$d" = "N" ] && NO_DEFAULT=true

  echo "子 Agent 模型配置（按分类依次设置）"
  MODEL_CFG="$(invoke_model_config_wizard)"
fi

# 执行
if [ "$MODE" = "symlink" ] || [ -z "$MODE" ]; then
  install_symlink || { log_warn "符号链接失败，尝试复制..."; install_copy || { log_err "安装失败"; exit 1; }; }
else
  install_copy || { log_err "安装失败"; exit 1; }
fi

update_opencode_json "$([ "$NO_DEFAULT" = false ] && echo true || echo false)" "$MODEL_CFG"

echo ""
echo "=== 安装完成 ==="
echo "目录: $PUSE_DIR"
echo "插件: $PLUGIN_ENTRY"
echo ""
echo "下一步: 重启 OpenCode 后验证 @PuaSE 可用"
