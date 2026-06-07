#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "  PuaSE 本地打包脚本 (Unix)"
echo "========================================"
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR"

cd "$PROJECT_DIR"

echo "[1/3] 清理旧包..."
rm -f *.tgz
echo "       完成"
echo

echo "[2/3] 执行 npm pack..."
npm pack
echo "       完成"
echo

echo "[3/3] 查看打包结果..."
TARBALL=$(ls -t *.tgz 2>/dev/null | head -1)
if [ -n "$TARBALL" ]; then
    echo "       生成: $(pwd)/$TARBALL"
    echo "       大小: $(stat -c%s "$TARBALL" 2>/dev/null || stat -f%z "$TARBALL") bytes"
fi
echo

echo "========================================"
echo "  打包完成"
echo "========================================"
echo "使用以下命令安装本地包:"
echo "  npm install ./$TARBALL"
echo
echo "预览包内容(不安装):"
echo "  tar -tzf $TARBALL"
echo
echo "解压到临时目录查看:"
echo "  mkdir -p temp-unpack && tar -xzf $TARBALL -C temp-unpack"
echo "========================================"
