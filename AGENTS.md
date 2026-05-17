# 此仓库是 PuaSE — OpenCode Agent 配置仓库

**没有源代码**，全是 Agent 配置文件（`.md` + YAML frontmatter）。没有构建系统、没有测试框架、没有 CI、没有可执行脚本。

## 代理（Agent）在这个仓库中最容易犯的错

- **所有 `.md` 文件是 Agent 配置**（含 YAML frontmatter）。不要当普通文档编辑。frontmatter 字段（name/description/permissions 等）**禁止更改**。
- **全文必须简体中文** — description、注释、说明全部中文。
- **`PuaSE.md` 的 `subagents:` 列表必须与实际文件一一对应** — 新增/删除子 Agent 要同时改列表和建/删文件。
- **`README.md` 必须同步更新** — 项目结构图和 Agent 列表要实时一致。
- **`explore` 和 `general` 是 OpenCode 内置 Agent**，没有 `.md` 配置文件。不要去找对应的文件。
- **子 Agent 目录不是平的** — 在 `subagent/developer/`、`subagent/dba/`、`subagent/security/` 下按层级组织。

## 全貌

| 项目 | 数据 |
|------|------|
| 子 Agent 总数 | 18 个（16 个 `.md` 配置 + 2 内置：explore, general） |
| 开发者语言 | 8 种：java, python, cpp, go, rust, csharp, bigdata, web |
| 数据库专家 | 2 种：mysql-dba, oracle-dba |
| 架构层级 | Pre-Code → Execution → Post-Code |
| 跨平台指南 | docs/（OpenCode / Claude Code / Copilot CLI / Cursor / Cline） |

## 关键文件

| 文件 | 用途 | 备注 |
|------|------|------|
| `PuaSE.md` | 主编排器配置 + 工作流定义（312 行），含 `subagents:` + `experts:` 列表 | 本文件是 Agent 的 system prompt |
| `CONTRIBUTING.md` | 新增/删除子 Agent 流程 | ⚠️ 目录树仅列 4 个开发者（实际 8 个） |
| `README.md` | 项目说明、三层架构图、跨平台安装指南 | 需与 subagents 列表实时一致 |

## 一致性约束

新增或删除子 Agent 时必须同步修改以下**三处**：
1. `PuaSE.md` — `subagents:` 列表 + `experts:` 列表
2. 对应 `.md` 文件 — 创建或删除
3. `README.md` — 项目结构图和 Agent 列表

## 同步流程

- **运行副本**：`~/.config/opencode/agents/PuaSE/` 是实际被 OpenCode 加载的版本
- **本仓库**：配置的权威存储。同步时比对 MD5 hash，用安装版覆盖仓库版后提交

## 仓库边界

- 无 `opencode.json`（用户侧配置，不跟踪到仓库）
- 无 `.opencode/` 目录
- 无任何可执行脚本
- `.github/` 仅含 Issue 模板
- `.gitignore` 仅忽略 `.logs` 和 `.idea`
