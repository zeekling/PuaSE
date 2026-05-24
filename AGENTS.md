# PuaSE — OpenCode Agent 配置仓库

**没有源代码**，全是 Agent 配置文件（`.md` + YAML frontmatter）。没有构建系统、没有测试框架、没有 CI、没有可执行脚本。

## Agent 最容易犯的错

- **所有 `.md` 文件是 Agent 配置**（含 YAML frontmatter）。不要当普通文档编辑。frontmatter 字段（name/description/mode/model/temperature）**禁止更改**。
- **全文必须简体中文** — description、注释、说明全部中文。
- **`PuaSE.md` 的 `subagents:` 列表必须与实际文件一一对应** — 新增/删除子 Agent 要同时改列表和建/删文件。
- **`README.md` 必须同步更新** — 项目结构图和 Agent 列表要实时一致。
- **`explore` 和 `general` 是 OpenCode 内置 Agent**，没有 `.md` 配置文件。`subagents:` 列表中内置 Agent 与配置 Agent 混排，按名称区分（无 `.md` 文件的即为内置）。
- **子 Agent 目录不是平的** — 在 `subagent/developer/`、`subagent/dba/`、`subagent/security/` 下按层级组织。

## 数据结构

| 项目 | 数据 |
|------|------|
| 子 Agent 总数 | 18 个（16 个 `.md` 配置 + 2 内置：explore, general） |
| 开发者语言 | 8 种：java, python, cpp, go, rust, csharp, bigdata, web |
| 数据库专家 | 2 种：mysql-dba, oracle-dba |
| 架构流 | **Pre-Code**(architect) → **Execution**(developer/dba) → **Post-Code**(security/code-review/quality) |
| `PuaSE.md` 行数 | 392 行，末尾含 `subagents:` + `experts:` 列表 |
| 使用指南 | `docs/`（OpenCode） |

## 三文件一致性规则

| 操作 | `PuaSE.md` | 对应 `.md` | `README.md` |
|------|-----------|-----------|------------|
| 新增子 Agent | `subagents:` + `experts:` 各加一条 | 创建文件 | 结构图 + Agent 列表 |
| 删除子 Agent | `subagents:` + `experts:` 各删一条 | 删除文件 | 结构图 + Agent 列表 |

## 所有子 Agent 共享的 Frontmatter 模板

```yaml
name: <名称>
description: |
    <职责描述>
mode: subagent
model: inherit
temperature: <0.1-0.3>
```

注意：`permissions: any` **仅出现在** `PuaSE.md`（主编排器），子 Agent 不使用此字段。

## 开发者文件的特殊结构（HARD-GATE）

所有 `subagent/developer/*.md` 文件在前置元数据之后、正文之前必定包含：

```
<HARD-GATE>
禁止在未通过编译/测试验证的情况下声称"已完成"。
每次代码变更后必须运行构建命令和测试套件，并输出验证证据。
任何声称"已修复/已完成"必须附带 build 日志和测试结果。
</HARD-GATE>
```

## 所有子 Agent 的交付后环节

每个子 Agent 文件尾部以 `---\n### 交付后` 结尾，声明交付后的验收流程。以 developer 为例：

```
### 交付后
你的编码完成后，PuaSE 会并行启动以下验收环节：
1. security-expert 🔒：安全审计
2. code-reviewer 👁️：代码审查
3. quality-inspector ✅：质量巡检
任一环节不通过 → 交付打回返工。
```

## 同步规则

- **运行副本**：`~/.config/opencode/agents/PuaSE/`（Windows: `C:\Users\<user>\.config\opencode\agents\PuaSE\`）
- **本仓库**：配置的权威存储。同步方向始终是 **安装版 → 仓库**（安装版是被 OpenCode 实际加载的版本）
- 同步方法：比对 MD5 hash → 复制差异文件 → 提交
- 安装版文件数固定为 17（PuaSE.md + 16 个子 Agent .md）

## 仓库边界

- 无 `opencode.json`（用户侧配置，不跟踪到仓库）
- 无 `.opencode/` 目录、无可执行脚本
- `.github/` 仅含 Issue 模板
- `.gitignore` 仅忽略 `.logs` 和 `.idea`
- `CONTRIBUTING.md` 目录树列 4 个开发者，但实际有 8 个 — 该文件持续过期，不要依赖其目录树
