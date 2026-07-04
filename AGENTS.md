# PuaSE — Agent 配置仓库

核心是 Agent 配置文件（`.md` + YAML frontmatter），另有一个 `website/` 子目录是 Vite 6 静态前端项目。

**本质**：这不是传统代码仓库——无测试框架、无 lint 配置、无构建系统（website 除外）。.md 文件是运行时可执行的 Agent 配置，不是文档。

## 配置约束（已验证）

- **`permissions: any` 仅出现在 PuaSE.md 的 frontmatter**，所有子 Agent 均不使用。
- **所有 `.md` 文件是 Agent 配置，不是文档**。frontmatter 的 `name`/`description`/`mode`/`model`/`temperature` **禁止更改**。
- **全文必须简体中文**。
- **`subagent/developer/*.md`** 在 frontmatter 之后、正文之前必定有 `<HARD-GATE>` 标签（验证：7 个 developer 文件均有）。
- **subagent `.md` 以 `### 交付后` 结尾**（验证：除 reflector.md、PuaSE.md 外，其余 15 个均有）。
- 所有子 Agent 均有独立 `.md` 文件。

## Agent 数量（精确计数）

| 位置 | 数量 | 文件 |
|------|------|------|
| 根目录（PuaSE.md） | 1 | PuaSE 自身（编排器） |
| `subagent/` 根 | 5 | architect, code-reviewer, documenter, quality-inspector, reflector |
| `subagent/developer/` | 7 | cpp, csharp, go, java, python, rust, web（无 bigdata） |
| `subagent/dba/` | 3 | mysql-dba, oracle-dba, postgresql-dba |
| `subagent/security/` | 1 | security-expert |
| **合计** | **17** | 17 `.md` |

> ⚠️ CONTRIBUTING.md 的目录树已过期（developer/ 列 4 个实际有 7 个），不要依赖其精确性。

## 增删子 Agent（三文件同步规则）

1. 创建/删除 `.md` 文件
2. 更新 PuaSE.md 的 `subagents:` 列表（~18 行，在文件末尾）
3. 同步更新 README.md + website/index.html
4. 提交时**三者一起提交**

## 架构流

Pre-Code(architect) → Execution(developer/dba) → Post-Code(security/code-review/quality/reflector)

详细编排规则见 PuaSE.md（~650 行），尤其是 §4.2（验收）+ §6.4（KPI 门禁）。

## CI/CD（仅 website 触发）

- **`build.yml`**：所有分支/PR，仅 `website/**` + 自身变更触发。`npm ci` → `npm run build`，Node 20。
- **`deploy.yml`**：main 分支 + v* 标签，自动部署到 gh-pages 分支。tag 推送到版本化子目录（`versions/v*.*.*/`）。
- **website 构建命令**：
  ```bash
  cd website
  npm run dev      # 开发服务器
  npm run build    # 生产构建，base: '/PuaSE/'
  npm run preview  # 预览构建结果
  ```
- **`.gitignore`** 忽略：`.logs`, `.idea`, `docs/specs`, `docs/plans`, `docs/superpowers`, `docs/kpi/`, `node_modules/`, `dist/`, `.superpowers/`, `.PuaSE`。

## 约束与提示

- **无 `opencode.json`**（用户侧配置，不跟踪到仓库）。勿创建或写入 `opencode/` 目录（不存在）。
- **`scripts/` 目录为空**（安装脚本已删除）。
- **`docs/` 中 `specs/`, `plans/`, `superpowers/` 被 gitignore**，但目录可能被本地创建。
- **禁止未经用户明确允许执行 git commit/push**。
- **`.PuaSE/improvement-track.md`**：reflector 复盘时追加 P0/P1/P2 改进项。Agent 不得主动据此优化自身行为（由用户决定）。
- **PuaSE.md 末尾含 `subagents:` 列表**（约 18 行），增删 Agent 时必须同步。
