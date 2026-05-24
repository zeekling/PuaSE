---
description: >-
  PuaSE.md 变更时必须同步更新 README.md 和 website/index.html。
  每次提交含 PuaSE.md 修改时，必须同时包含对应 README 和 website 的同步更新。
globs: "PuaSE.md"
---

# PuaSE.md 同步约束

## 规则

**PuaSE.md 发生任何变更后，必须同步更新 README.md 和 website/index.html。**

不允许"只改 PuaSE.md"的提交。每次提交 PuaSE.md 时，必须同时包含对应 README.md 和 website/index.html 的同步修改。

## 同步检查清单

### README.md — 以下区域需逐项检查

| 区域 | 检查项 |
|------|--------|
| 核心能力表 | PuaSE 能力描述是否更新？新增/删除能力后表格行数是否对齐 |
| 时序流水线图 | 流水线步骤、角色、上下文隔离模型是否匹配新版 PuaSE.md |
| 使用示例 | 委派示例是否匹配新版 experts 列表和触发规则 |
| 防作弊表 | 是否存在 PuaSE.md 新增的"反熟悉度偏误"、"自执行归因宣言"等约束未收录 |
| Agent 列表 | subagents/experts 数量、名称、分组是否与 PuaSE.md 一致 |

### website/index.html — 以下区域需逐项检查

| 区域 | 检查项 |
|------|--------|
| 核心能力卡片 | 卡片数量和描述是否匹配最新核心能力 |
| 架构图（Pre-Code / Execution / Post-Code） | 各列的 Agent 分组和名称是否对齐 |
| Demo 终端区域 | 委派场景描述是否匹配 PuaSE.md 的编排流程 |
| Agent 列表区 | 全部 18 个 Agent（16 配置 + 2 内置）是否列出，分组是否正确 |

## 例外

- README.md 纯格式调整（空格、换行、标点）无需 PuaSE.md 变更
- website/index.html 纯样式更新（CSS 换肤、布局调整）无需 PuaSE.md 变更
- 以上例外仅限**不涉及内容同步**的场景

## 违反后果

缺少对应同步的 PuaSE.md 变更提交会被标记为**不完整变更**，需补交同步更新。

## 运行副本同步规范

### 运行副本

安装后的运行副本位于：
- **Linux/macOS**：`~/.config/opencode/agents/PuaSE/`
- **Windows**：`C:\Users\<user>\.config\opencode\agents\PuaSE\`

### 同步方向

**安装版 → 仓库**：安装版是被 OpenCode 实际加载的版本，仓库是配置的权威存储。

### 同步方法

比对 MD5 hash → 复制差异文件 → 提交。

### 安装版文件数

固定为 18（PuaSE.md + 17 个子 Agent .md）。
