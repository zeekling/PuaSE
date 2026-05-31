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
| Agent 列表 | PuaSE 能力描述是否更新 |

### website/index.html — 以下区域需逐项检查

| 区域 | 检查项 |
|------|--------|
| 核心能力卡片 | 卡片数量和描述是否匹配最新核心能力 |
| 架构图（Pre-Code / Execution / Post-Code） | 各列的 Agent 分组和名称是否对齐 |
| Demo 终端区域 | 委派场景描述是否匹配 PuaSE.md 的编排流程 |
| Agent 列表区 | PuaSE 主 Agent 是否列出 |

## 例外

- README.md 纯格式调整（空格、换行、标点）无需 PuaSE.md 变更
- website/index.html 纯样式更新（CSS 换肤、布局调整）无需 PuaSE.md 变更
- 以上例外仅限**不涉及内容同步**的场景

## 违反后果

缺少对应同步的 PuaSE.md 变更提交会被标记为**不完整变更**，需补交同步更新。

## 插件模式说明

PuaSE 以 OpenCode 插件方式运行（`.opencode/plugins/puse.js`），不再作为自定义 Agent 通过 `opencode.json` 手动注册。

### 运行方式

- **symlink 模式（推荐开发）**：`puse.js` 通过 symlink 指向仓库，仓库即运行副本，修改 prompt 即时生效，无需手动同步。
- **npm 模式（版本管理）**：通过 npm 全局安装，通过包管理更新。

### 插件模式下的同步约束

插件模式下，仓库本身就是运行副本（symlink）或版本管理源（npm），不存在"安装版→仓库"的双向同步问题：

- symlink 模式下，修改 prompt 即时生效，无需手动同步。
- npm 模式下，通过 `npm update` 更新。
- 仅注册 PuaSE 主 Agent，不注册子 Agent（subagent/）。子 Agent 由 PuaSE 在运行时动态委派。
