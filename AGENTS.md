# PuaSE — Agent 配置仓库

核心是 Agent 配置文件（`.md` + YAML frontmatter），另有一个 `website/` 子目录是 Vite 6 静态前端项目。

## 配置约束

- **所有 `.md` 文件是 Agent 配置，不是文档**。frontmatter 的 name/description/mode/model/temperature **禁止更改**。
- **全文必须简体中文**。
- **`permissions: any` 仅出现在 PuaSE.md**（主编排器），子 Agent 不使用。
- **`subagent/developer/*.md`** 在 frontmatter 之后、正文之前必定有 `<HARD-GATE>` 标签。
- **每个子 Agent `.md`** 以 `---\n### 交付后` 结尾。
- **`general` 是内置 Agent**（无 `.md`）；`explore` 有独立 `.md`。subagents 列表混排，无 `.md` 的即为内置。

## 增删子 Agent

PuaSE.md 的 `subagents:` 列表必须与实际 `.md` 文件一一对应。操作流程：
1. 创建/删除 `.md` 文件
2. 更新 PuaSE.md 的 subagents 列表
3. 同步更新 README.md 和 website/index.html
4. 提交时三者一起提交

## 目录结构

| 位置 | 数量 | 说明 |
|------|------|------|
| 根目录 | 7 | 架构师、安全专家、代码审查、质量检查、复盘、explore、PuaSE 自身 |
| `subagent/developer/` | 8 | java, python, cpp, go, rust, csharp, bigdata, web |
| `subagent/dba/` | 3 | mysql-dba, oracle-dba, postgresql-dba |
| `subagent/security/` | 1 | security-expert 独立文件 |
| **合计** | **19 `.md` + 1 内置** | = 20 个 Agent |

架构流：Pre-Code(architect) → Execution(developer/dba) → Post-Code(security/code-review/quality/reflector)

## CI/CD

- 仅 `build.yml`（构建检查）+ `deploy.yml`（GitHub Pages 部署），均只对 `website/**` 变更触发。
- 构建命令：`cd website; npm run build`。
- **无** `publish.yml`（已删除）。
- `.gitignore` 忽略：`.logs`, `.idea`, `docs/specs`, `docs/plans`, `docs/superpowers`, `docs/kpi/`, `node_modules/`, `dist/`, `.superpowers/`, `.PuaSE`。

## 约束与提示

- **无 opencode.json**（用户侧配置，不跟踪到仓库）。
- **`opencode/` 目录不存在**，勿创建或写入。
- **`scripts/` 目录为空**（安装/打包脚本已删除）。
- **禁止未经用户明确允许执行 git commit/push**。
- **CONTRIBUTING.md 的目录树过期**（developer/ 列 4 个实际有 8 个），不要依赖其文件树精确性。
- **`.PuaSE/improvement-track.md`**：reflector 复盘时追加 P0/P1/P2 改进项。Agent 不得主动据此优化自身行为（由用户决定）。
- **PuaSE.md ~562 行**，末尾含 subagents 列表。
