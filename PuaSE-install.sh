#!/bin/bash
set -e

# PuaSE 安装脚本 (Linux/macOS)
# 用法: bash PuaSE-install.sh
# 将 PuaSE 安装到 ~/.config/opencode/puse/，作为 OpenCode 插件运行

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PUSE_DIR="$HOME/.config/opencode/puse"
OPENTCOD_JSON="$HOME/.config/opencode/opencode.json"
PLUGIN_PATH="puse/.opencode/plugins/puse.js"

echo "=== PuaSE 安装脚本 ==="
echo "源码目录: $REPO_DIR"
echo "安装目录: $PUSE_DIR"
echo ""

# 检查源文件
if [ ! -f "$REPO_DIR/.opencode/plugins/puse.js" ]; then
    echo "错误: 未找到 $REPO_DIR/.opencode/plugins/puse.js"
    echo "请确保在 PuaSE 仓库根目录运行此脚本"
    exit 1
fi

update_puse_js() {
    local puse_config_path="$HOME/.config/opencode/puse"
    local puse_js="$PUSE_DIR/.opencode/plugins/puse.js"

    if [ ! -f "$puse_js" ]; then
        echo "错误: 未找到 $puse_js"
        return 1
    fi

    # 替换 REPO_ROOT 标记为本地安装目录（与 superpowers 一致）
    sed -i "s|const REPO_ROOT = '// @REPO_ROOT@';|const REPO_ROOT = '$puse_config_path';|g" "$puse_js"
    echo "[Config] REPO_ROOT = $puse_config_path"
    return 0
}

update_opencode_json() {
    local plugin_entry="$PLUGIN_PATH"
    local opencode_json="$OPENTCOD_JSON"

    # 检查是否已有 puse 插件
    if grep -q "$plugin_entry" "$opencode_json" 2>/dev/null; then
        echo "[Config] opencode.json 已包含 puse 插件"
    else
        # 在 plugins 数组开头添加
        sed -i "s/\"plugin\": \[/\"plugin\": [\"$plugin_entry\",/g" "$opencode_json"
        echo "[Config] opencode.json 已更新"
    fi

    # 设置默认 agent 为 PuaSE
    if ! grep -q '"default_agent": "PuaSE"' "$opencode_json" 2>/dev/null; then
        # 在 provider 后添加 default_agent 配置
        sed -i '/^[[:space:]]*"provider": {/,/^        }/ { /^[[:space:]]*},$/ i\
        "default_agent": "PuaSE",
        }' "$opencode_json" || true
        echo "[Config] 默认 Agent 已设置为 PuaSE"
    else
        echo "[Config] 默认 Agent 已为 PuaSE"
    fi
    return 0
}

install_symlink() {
    echo "使用 Symlink 模式安装..."

    # 移除已存在的目标
    if [ -L "$PUSE_DIR" ]; then
        rm "$PUSE_DIR"
    elif [ -e "$PUSE_DIR" ]; then
        echo "错误: $PUSE_DIR 已存在且不是 symlink"
        return 1
    fi

    # 创建 symlink
    ln -sf "$REPO_DIR" "$PUSE_DIR"
    echo "[Symlink] $PUSE_DIR -> $REPO_DIR"

    # 更新 opencode.json
    update_opencode_json

    echo "Symlink 模式安装完成!"
    return 0
}

install_copy() {
    echo "使用复制模式安装..."

    # 移除已存在的目录
    if [ -e "$PUSE_DIR" ]; then
        rm -rf "$PUSE_DIR"
    fi

    # 创建目录
    mkdir -p "$PUSE_DIR"

    # 复制文件（排除 node_modules, .git 等）
    rsync -av --exclude='node_modules' --exclude='.git' --exclude='.idea' --exclude='.superpowers' --exclude='.logs' --exclude='*.lock' "$REPO_DIR/" "$PUSE_DIR/"

    # 更新 opencode.json
    update_opencode_json

    echo "复制模式安装完成!"
    return 0
}

# 主流程
install_mode=""

if [ -t 1 ]; then
    # 交互模式
    echo "选择安装模式:"
    echo "  [1] Symlink (推荐: 修改源码即时生效)"
    echo "  [2] Copy (复制文件到安装目录)"
    read -p "请选择 [1]: " choice

    case "$choice" in
        2)
            install_mode="copy"
            ;;
        *)
            install_mode="symlink"
            ;;
    esac
else
    # 非交互模式默认使用 symlink
    install_mode="symlink"
fi

if [ "$install_mode" = "symlink" ]; then
    if install_symlink; then
        :
    else
        echo "Symlink 失败，是否使用复制模式?"
        read -p "使用复制模式安装? (Y/n) " choice
        case "$choice" in
            n|N)
                echo "安装取消"
                exit 1
                ;;
            *)
                install_copy
                ;;
        esac
    fi
else
    install_copy
fi

echo ""
echo "=== 安装完成 ==="
echo "安装目录: $PUSE_DIR"
echo ""
echo "下一步:"
echo "  1. 重启 OpenCode"
echo "  2. 验证: @PuaSE 可用"