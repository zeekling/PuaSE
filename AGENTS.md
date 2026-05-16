# PuaSE 仓库规则

## 这是什么

本仓库是 OpenCode Agent **PuaSE**（全局编排 Agent）的配置镜像。

**唯一用途**：与 `~/.config/opencode/agents/PuaSE/` 双向同步，作为版本管理的参考副本。

## 关键约定

- **所有 `.md` 文件均为 OpenCode Agent 配置**，包含 YAML frontmatter + Markdown 正文。不要当作普通文档处理。
- **frontmatter 字段必须保留**：`name`、`description`、`mode`（subagent 用 `mode: subagent`）、`model: inherit`
- **PuaSE.md 特有字段**：`permissions: any`、`run_in_background: true`、`subagents: [...]`
- **语言**：全部使用简体中文
- **无构建系统**：无 `package.json`、无测试、无 lint、无 CI — 不要寻找这些
- **`.gitignore` 忽略**：`.logs` 和 `.idea`

## 权限

- PuaSE 及委派的子 Agent 默认拥有**全部权限**（`permissions: any`），委派不降权
