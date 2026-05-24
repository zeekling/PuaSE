# PuaSE — OpenCode Agent 配置仓库

**核心是 Agent 配置文件**（`.md` + YAML frontmatter），这是主体。但还有一个 `website/` 子目录，是 Vite 静态前端项目（官网主页），有独立构建系统和 CI 部署。

## 两部分工作·不同规则

### Agent 配置（主体）

- **所有 `.md` 文件是 Agent 配置**（含 YAML frontmatter）。不要当普通文档编辑。frontmatter 字段（name/description/mode/model/temperature）**禁止更改**。
- **全文必须简体中文** — description、注释、说明全部中文。
- **`PuaSE.md` 的 `subagents:` 列表必须与实际文件一一对应** — 新增/删除子 Agent 要同时改 PuaSE.md 的 subagents/experts 列表、创建/删除 `.md` 文件、更新 README.md。
- **`explore` 和 `general` 是 OpenCode 内置 Agent**，没有 `.md` 配置文件。`subagents:` 列表中内置与配置 Agent 混排，按名称区分（无 `.md` 文件的即为内置）。
- **子 Agent 目录分层**：`subagent/developer/`、`subagent/dba/`、`subagent/security/`。
- **`permissions: any` 仅出现在 PuaSE.md**（主编排器），子 Agent 不使用此字段。
- **所有 `subagent/developer/*.md` 文件** 在前置元数据之后、正文之前必定包含 `<HARD-GATE>` 标签（禁止未经验证声称完成）。
- **每个子 Agent 文件尾部** 以 `---\n### 交付后` 结尾，声明后续验收流程。
- **CONTRIBUTING.md 的目录树已过期** — developer/ 列了 4 个但实际有 8 个。不要依赖其文件树。

### Website（附属前端项目）

`website/` 是一个独立的 Vite 项目，与技术文档的主仓库解耦：

| 命令 | 用途 |
|------|------|
| `npm run dev` | 启动开发服务器（`website/` 目录下） |
| `npm run build` | 构建到 `website/dist/` |
| `npm run preview` | 预览构建结果 |

构建配置：Vite 6，base 路径 `/PuaSE/`，产物输出到 `dist/`。

## 数据结构

| 项目 | 数据 |
|------|------|
| 子 Agent 总数 | 19 个（17 个 `.md` 配置 + 2 内置：explore, general） |
| 开发者语言 | 8 种：java, python, cpp, go, rust, csharp, bigdata, web |
| 数据库专家 | 2 种：mysql-dba, oracle-dba |
| 架构流 | **Pre-Code**(architect) → **Execution**(developer/dba) → **Post-Code**(security/code-review/quality) |
| `PuaSE.md` 行数 | 624 行，末尾含 `subagents:` + `experts:` 列表 |
| 使用指南 | `docs/`（OpenCode） |

## 同步规则

- **运行副本**：`~/.config/opencode/agents/PuaSE/`（Windows: `C:\Users\<user>\.config\opencode\agents\PuaSE\`）
- **本仓库**：配置的权威存储。同步方向始终是 **安装版 → 仓库**（安装版是被 OpenCode 实际加载的版本）
- 同步方法：比对 MD5 hash → 复制差异文件 → 提交
- 安装版文件数固定为 18（PuaSE.md + 17 个子 Agent .md）
- **PuaSE.md 同步约束**（`.opencode/rules/puse-sync.md`）：PuaSE.md 发生变更后，必须同步更新 README.md 和 website/index.html。提交 PuaSE.md 时必须同时包含对应 README 和 website 的同步修改。

## CI/CD & 仓库边界

- **CI 部署**：`.github/workflows/deploy.yml` — push 到 main 且变更 `website/**` 或 workflow 文件时，自动构建 website 并部署到 GitHub Pages（通过 peaceiris/actions-gh-pages）。
- **无** `opencode.json`（用户侧配置，不跟踪到仓库）、无 `.opencode/` 目录。
- **.gitignore** 忽略 `.logs`、`.idea`、`docs/specs`、`docs/plans`、`node_modules/`、`dist/`、`.superpowers/`。
- **CONTRIBUTING.md 目录树过期** — developer/ 列 4 个但实际有 8 个。不要依赖其文件树的精确性。
