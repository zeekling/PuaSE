# PuaSE 跨平台使用指南

PuaSE（全局编排 Agent）是**平台无关的** — 它的核心是一套编排工作流和子 Agent 配置，可以在多种 AI 编码工具中使用。

选择你的平台：

| 平台 | 类型 | 配置方式 | 适用人群 |
|------|------|---------|---------|
| [OpenCode](opencode.md) | CLI 工具 | `opencode.json` Agent 注册 | OpenCode 用户 |
| [Claude Code](claude-code.md) | CLI 工具 | `CLAUDE.md` / `.claude/` 配置 | Anthropic Claude 用户 |
| [GitHub Copilot CLI](copilot-cli.md) | CLI 工具 | `AGENTS.md` / `.github/copilot-instructions.md` | GitHub 生态用户 |
| [Cursor](cursor.md) | AI IDE | `.cursorrules` / `cursor/rules/` | AI IDE 用户 |
| [Cline](cline.md) | VS Code 扩展 | `CLINE.md` / MCP 配置 | VS Code 用户 |

## PuaSE 跨平台架构图

```
┌─────────────────────────────────────────────────────────┐
│                   你的开发环境                            │
│  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌──────────┐  │
│  │ OpenCode │  │ClaudeCode│  │ Cursor │  │  Cline   │  │
│  └─────┬────┘  └─────┬────┘  └───┬────┘  └─────┬────┘  │
│        │              │           │              │       │
│        └──────────────┼───────────┼──────────────┘       │
│                       │           │                      │
│              ┌────────▼───────────▼──────┐               │
│              │     PuaSE 编排器           │               │
│              │   (通过配置文件加载)        │               │
│              └────────┬──────────────────┘               │
│                       │                                  │
│              ┌────────▼──────────────────┐               │
│              │  subagent/ 子 Agent 池     │               │
│              │  architect/developer/     │               │
│              │  dba/security/...         │               │
│              └───────────────────────────┘               │
└─────────────────────────────────────────────────────────┘
```

## 平台能力对比

| 能力 | OpenCode | Claude Code | Copilot CLI | Cursor | Cline |
|------|----------|-------------|-------------|--------|-------|
| 自定义 Agent 注册 | ✅ `opencode.json` | ✅ `.claude/agents.json` | ⚠️ 指令注入 | ⚠️ Rules 注入 | ⚠️ 指令注入 |
| 子 Agent 配置目录 | ✅ 原生支持 | ✅ 可引用 | ⚠️ 手工合并 | ⚠️ 手工注入 | ✅ CLINE.md |
| 权限模型 | ✅ `permission: * allow` | ❌ 无权限模型 | ❌ 无权限模型 | ❌ 无权限模型 | ✅ MCP 权限 |
| 权限委派不降权 | ✅ 原生 | ✅ 可模拟 | ⚠️ 有限 | ⚠️ 有限 | ⚠️ 有限 |
| 后台运行 | ✅ `run_in_background` | ❌ | ❌ | ❌ | ❌ |

> ✅ = 原生支持 / ⚠️ = 需要额外配置 / ❌ = 不支持

## 选择建议

- **已用 OpenCode** → 直接使用 [OpenCode 指南](opencode.md)，体验最佳
- **已用 Claude Code** → 使用 [Claude Code 指南](claude-code.md)，将 PuaSE 注入为系统指令
- **已用 GitHub Copilot CLI** → 使用 [Copilot CLI 指南](copilot-cli.md)，通过 AGENTS.md 或 copilot-instructions.md 注入
- **已用 Cursor** → 使用 [Cursor 指南](cursor.md)，通过 .cursorrules 注入 PuaSE 核心指令
- **已用 Cline** → 使用 [Cline 指南](cline.md)，通过 CLINE.md 或 MCP 配置注入

## 版本更新

各平台指南会随 PuaSE 版本同步更新。如果发现配置方式有变化，请参考各工具的官方文档。
