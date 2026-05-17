# PuaSE 仓库规则

## 第一会踩的坑

- **所有 `.md` 是 Agent 配置**（含 YAML frontmatter），不要当普通文档编辑。frontmatter 字段禁止更改。
- **全文简体中文** — 所有 description、注释、说明都必须是中文。
- **无构建系统**：无 `package.json`、无测试、无 lint、无 CI — 不要运行或寻找这些。
- **权限**：`permissions: any` 即全部权限且委派不降权。详见 PuaSE.md 第 8 节（权限模型）。
- **PuaSE.md 的 `subagents:` 列表必须与实际文件一一对应** — 新增/删除子 Agent 要同时改列表和建/删文件。
- **README.md 必须同步更新** — 新增/删除子 Agent 后需更新项目结构图和 Agent 列表。
- **`explore` 和 `general` 是内置 Agent**，没有 `.md` 配置文件，不要寻找对应的文件。
- **目录不是平的**：详见 `subagent/` 下的层级结构。

## 全貌速览

| 维度 | 数据 |
|------|------|
| 子 Agent 总数 | 18 个（16 个 `.md` 配置 + 2 个内置：explore, general） |
| 架构层级 | Pre-Code（架构分析）→ Execution（开发/DB/文档）→ Post-Code（安全/审查/质量） |
| 开发者语言 | 8 种：java, python, cpp, go, rust, csharp, bigdata, web |
| 数据库专家 | 2 种：mysql-dba, oracle-dba |

## 关键文件

| 文件 | 用途 | 备注 |
|------|------|------|
| `PuaSE.md` | 主编排器配置 + 工作流定义（305 行），含 `subagents:` + `experts:` 列表 | 本文件是 Agent 的 system prompt |
| `CONTRIBUTING.md` | 新增/删除子 Agent 流程规范 | ⚠️ 目录树示例已过时（见下文） |
| `README.md` | 项目说明、三层架构图、安装指南 | 需与 subagents 列表实时一致 |

> ⚠️ CONTRIBUTING.md 中的目录树只列出了 4 个开发者（cpp/java/python/web），实际已有 8 个（go/rust/csharp/bigdata 未体现）。以 PuaSE.md 的 `subagents:` 列表和实际文件为权威来源。

## 三文件一致性约束

新增或删除子 Agent 时必须同步修改以下三处：
1. `PuaSE.md` — `subagents:` 列表 + `experts:` 列表
2. 对应 `.md` 文件 — 创建或删除
3. `README.md` — 项目结构图和 Agent 列表

详见 `CONTRIBUTING.md` 的完整流程（注意其目录树已过时）。

## 同步操作

- **运行副本**：安装版在 `~/.config/opencode/agents/PuaSE/`，是实际被 OpenCode 加载的版本
- **本仓库**：配置的权威存储。同步时比对 MD5 hash，用安装版覆盖仓库版后提交

## 仓库根目录无可执行文件

- 无 `opencode.json`（用户侧外部配置，不跟踪到仓库）
- 无 `.opencode/` 目录
- 无任何可执行脚本
- `.github/` 仅含 Issue 模板（bug_report、feature_request）
- `.gitignore` 仅忽略 `.logs` 和 `.idea`
