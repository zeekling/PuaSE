# PuaSE — OpenCode Agent 配置仓库

**核心是 Agent 配置文件**（`.md` + YAML frontmatter），这是主体。
另有一个 `website/` 子目录，是 Vite 6 静态前端项目（官网主页），有独立构建系统和 CI 部署。

---

## 两部分工作·不同规则

### Agent 配置（主体）

- **所有 `.md` 文件是 Agent 配置**（含 YAML frontmatter），**不是普通文档**。frontmatter 字段（name/description/mode/model/temperature）**禁止更改**。
- **全文必须简体中文** — description、注释、说明全部中文。
- **`PuaSE.md` 的 `subagents:` 列表必须与实际文件一一对应** — 新增/删除子 Agent 要同时改 PuaSE.md 的 subagents 列表、创建/删除 `.md` 文件、更新 README.md。
- **`general` 是 OpenCode 内置 Agent**（无 `.md` 配置文件）；`explore` 有独立 `.md` 配置。subagents 列表中内置与配置 Agent 混排，按名称区分（无 `.md` 文件的即为内置）。
- **子 Agent 目录分层**：`subagent/developer/`（8 个）、`subagent/dba/`（3 个）、`subagent/security/`（1 个），根目录 7 个。
- **`permissions: any` 仅出现在 PuaSE.md**（主编排器），子 Agent 不使用此字段。
- **所有 `subagent/developer/*.md` 文件**在前置元数据之后、正文之前必定包含 `<HARD-GATE>` 标签（禁止未经验证声称完成）。
- **每个子 Agent 文件尾部**以 `---\n### 交付后` 结尾，声明后续验收流程。
- **CONTRIBUTING.md 的目录树已过期** — developer/ 列了 4 个但实际有 8 个。不要依赖其文件树的精确性。

### 关键数字

| 项目 | 数据 |
|------|------|
| 子 Agent `.md` 文件总数 | 19（7 根目录 + 8 developer/ + 3 dba/ + 1 security/） |
| 子 Agent 总数（含内置 general） | 20（19 `.md` + 1 内置） |
| `PuaSE.md` 行数 | 766，末尾含 `subagents:` 列表 |
| 开发者语言 | 8 种：java, python, cpp, go, rust, csharp, bigdata, web |
| 数据库专家 | 3 种：mysql-dba, oracle-dba, postgresql-dba |
| 架构流 | Pre-Code(architect) → Execution(developer/dba) → Post-Code(security/code-review/quality/reflector) |
| 插件入口 | `.opencode/plugins/puse.js` — 仅注册 PuaSE 主 Agent，子 Agent 指令在 PuaSE.md 中定义 |

### Website（附属前端项目）

`website/` 是一个独立的 Vite 6 项目，与技术文档的主仓库解耦：

| 命令 | 用途 |
|------|------|
| `npm run dev` | 启动开发服务器（`website/` 目录下） |
| `npm run build` | 构建到 `website/dist/` |
| `npm run preview` | 预览构建结果 |

构建配置：Vite 6，base 路径 `/PuaSE/`，产物输出到 `dist/`。

---

## 同步规则（Plugin 模式）

- **PuaSE 以插件方式运行** — 通过 `.opencode/plugins/puse.js` 加载，仅注册 PuaSE 主 Agent。
- **本仓库**：既是源码仓库，也是运行副本（symlink 模式下直接引用）。
- **同步方法**：symlink 直达仓库，无需手动同步。npm 安装时通过包管理更新。
- **PuaSE.md 同步约束**（`.opencode/rules/puse-sync.md`）：PuaSE.md 发生变更后，必须同步更新 README.md 和 website/index.html。提交 PuaSE.md 时必须同时包含对应 README 和 website 的同步修改。
- **提交授权规则**（`.opencode/rules/commit-authorization.md`）：禁止未经用户明确允许提交本地代码（git commit / git push）。任何涉及 git 提交的操作必须先获得用户授权。
- **安装脚本**：`PuaSE-install.ps1`（Windows）/ `PuaSE-install.sh`（Linux/macOS）带 CLI 参数（--symlink/--copy/--no-default/--model-config/--force）；提供卸载机制（见 `PuaSE-uninstall.ps1` / `PuaSE-uninstall.sh`）。
- **模型配置模板**：`config_template.json`，安装时可由脚本合并到 opencode.json。

---

## CI/CD & 仓库边界

- **CI 部署**（`.github/workflows/deploy.yml`）：push 到 main 且变更 `website/**` 或 workflow 文件时，自动构建 website 并部署到 GitHub Pages（peaceiris/actions-gh-pages）。
- **CI 构建检查**（`.github/workflows/build.yml`）：任意分支 push 或 PR 到 main 涉及 `website/**` 时，仅执行 `npm ci + npm run build` 验证。
- **无** `opencode.json`（用户侧配置，不跟踪到仓库）。`.opencode/` 目录包含插件入口、规则、依赖。
- **.gitignore** 忽略：`.logs`、`.idea`、`docs/specs`、`docs/plans`、`docs/superpowers`、`docs/kpi/`、`node_modules/`、`dist/`、`.superpowers/`、`.PuaSE`。
- **`.PuaSE/improvement-track.md`**：reflector 复盘时追加 P0/P1/P2 改进项，不清除历史。Agent 不得主动根据此清单优化自身行为（用户自行决定）。
- **CONTRIBUTING.md 目录树过期** — developer/ 列 4 个但实际有 8 个。不要依赖其文件树的精确性。

---

## 给 Agent 的提示

- 编辑 `.md` 配置时先确认 frontmatter 字段是否受保护（name/description/mode/model/temperature 禁止改）。
- 新增子 Agent 必须：创建 `.md` → 加入 PuaSE.md 的 subagents 列表 → 更新 README.md → 更新 website/ 页面。
- website/ 修改后需在仓库根目录命令行执行构建验证：`cd website; npm run build`。
- 提交 PuaSE.md 时必须同时提交 README.md 和 website/index.html 的同步修改（puse-sync 规则强制）。
- 修改 README.md 或 AGENTS.md 时，检查是否需要同步更新 docs/AGENT_LIST.md 和 docs/PROJECT_STRUCTURE.md。
- `opencode/` 目录当前为空，勿写入仓库文件。
