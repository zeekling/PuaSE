#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PuaSE 一键安装脚本。

将仓库中的 Agent 配置复制到 OpenCode 的 agents 目录，并支持在安装时
为每个 subagent 单独设置模型（不设置则保持现状，不注入任何字段）。

用法：
    python install.py                # 交互式安装（可逐个设置模型）
    python install.py --no-prompt    # 非交互式安装（纯复制，保持现状）
    python install.py --target <目录> # 指定目标安装目录

目标目录（跨平台）：
    Windows   %USERPROFILE%\\.config\\opencode\\agents\\PuaSE
    Linux/macOS  ~/.config/opencode/agents/PuaSE
"""

import argparse
import os
import shutil
import sys
from pathlib import Path

# 需复制的顶层文件与目录（相对仓库根）
TOP_LEVEL_FILES = ["PuaSE.md", "PuaSE-protocol.md"]
SUBAGENT_DIR = "subagent"


def default_target_dir() -> Path:
    """返回跨平台默认安装目录。"""
    if sys.platform == "win32" or os.name == "nt":
        base = os.environ.get("USERPROFILE") or str(Path.home())
        return Path(base) / ".config" / "opencode" / "agents" / "PuaSE"
    return Path.home() / ".config" / "opencode" / "agents" / "PuaSE"


def collect_subagent_files(root: Path) -> list:
    """收集全部 subagent 配置文件（相对仓库根的 Path 列表）。"""
    return sorted(p.relative_to(root) for p in (root / SUBAGENT_DIR).rglob("*.md"))


def copy_configs(root: Path, target: Path) -> None:
    """复制顶层文件与 subagent 目录到目标目录（覆盖旧副本）。"""
    target.mkdir(parents=True, exist_ok=True)
    for name in TOP_LEVEL_FILES:
        shutil.copy2(root / name, target / name)
    dst_sub = target / SUBAGENT_DIR
    if dst_sub.exists():
        shutil.rmtree(dst_sub)
    shutil.copytree(root / SUBAGENT_DIR, dst_sub)


def inject_model(file_path: Path, model: str) -> None:
    """在目标副本 frontmatter 的 temperature: 行后注入 model: <model>。

    若 frontmatter 已存在 model: 行则原地替换；源文件永不修改。
    """
    # 读取时 newline="" 禁用换行翻译，保留原始 \r\n
    with open(file_path, "r", encoding="utf-8", newline="") as fh:
        text = fh.read()
    newline = "\r\n" if "\r\n" in text else "\n"
    lines = text.splitlines()
    in_frontmatter = False
    frontmatter_end = None
    temp_index = -1
    model_index = -1
    for i, line in enumerate(lines):
        stripped = line.lstrip("\ufeff").strip()
        if i == 0 and stripped == "---":
            in_frontmatter = True
            continue
        if in_frontmatter and stripped == "---":
            frontmatter_end = i
            break
        if in_frontmatter and stripped.startswith("temperature:"):
            temp_index = i
        if in_frontmatter and stripped.startswith("model:"):
            model_index = i
    if model_index != -1:
        lines[model_index] = "model: " + model
    elif temp_index != -1:
        lines.insert(temp_index + 1, "model: " + model)
    elif frontmatter_end is not None:
        lines.insert(frontmatter_end, "model: " + model)
    else:
        # 无有效 frontmatter：跳过注入，避免污染正文
        print("  警告：%s 无有效 frontmatter，跳过模型注入" % file_path, file=sys.stderr)
        return
    # 写入时 newline="" 不做翻译，按探测的行尾原样写出
    with open(file_path, "w", encoding="utf-8", newline="") as fh:
        fh.write(newline.join(lines) + newline)


def ask_models(files: list) -> dict:
    """逐个询问模型名，返回 {相对路径: 模型名}。

    回答规则：
        直接输入模型名 → 为该 subagent 设置该模型
        回车（空）     → 跳过（保持现状）
        a             → 剩余全部设置（逐个输入模型名）
        s             → 剩余全部跳过
    """
    all_set_mode = False
    all_skip_mode = False
    result = {}
    for rel in files:
        name = rel.stem
        if all_skip_mode:
            continue
        if all_set_mode:
            prompt = "  [%s] 模型名（回车跳过）：" % name
        else:
            prompt = "  [%s] 模型名（回车跳过，a 剩余全部设置，s 剩余全部跳过）：" % name
        try:
            answer = input(prompt).strip()
        except EOFError:
            break
        if not all_set_mode and answer == "s":
            all_skip_mode = True
            continue
        if not all_set_mode and answer == "a":
            all_set_mode = True
            # 当前文件同样进入设置流程（属于"剩余"范畴）
            try:
                answer = input("  [%s] 模型名（回车跳过）：" % name).strip()
            except EOFError:
                break
        if not all_set_mode and answer == "":
            continue
        if answer:
            result[rel] = answer
    return result


def print_summary(target: Path, files: list, model_map: dict) -> None:
    """输出安装摘要。"""
    print()
    print("安装完成 -> %s" % target)
    print("复制内容：PuaSE.md、PuaSE-protocol.md、subagent/（%d 个配置文件）" % len(files))
    if model_map:
        print("已设置模型：%d 个" % len(model_map))
        for rel, model in model_map.items():
            print("  - %s: %s" % (rel, model))
    else:
        print("模型设置：未设置（全部保持现状）")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="PuaSE 一键安装脚本（支持为 subagent 单独设置模型）"
    )
    parser.add_argument(
        "--target",
        help="目标安装目录（默认：~/.config/opencode/agents/PuaSE）",
    )
    parser.add_argument(
        "--no-prompt",
        action="store_true",
        help="非交互模式：仅复制，不询问模型设置",
    )
    args = parser.parse_args()

    if sys.version_info < (3, 8):
        print("错误：需要 Python 3.8 或更高版本。", file=sys.stderr)
        return 1

    root = Path(__file__).resolve().parent
    if args.target:
        target = Path(args.target).expanduser().resolve()
    else:
        target = default_target_dir()

    if target == root or root in target.parents:
        print("错误：目标目录不能是仓库本身或其子目录：%s" % target, file=sys.stderr)
        return 1

    files = collect_subagent_files(root)
    copy_configs(root, target)

    model_map = {}
    if not args.no_prompt:
        model_map = ask_models(files)
        for rel, model in model_map.items():
            inject_model(target / rel, model)

    print_summary(target, files, model_map)
    return 0


if __name__ == "__main__":
    sys.exit(main())
