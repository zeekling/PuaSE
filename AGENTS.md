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

## 关键文件

| 文件 | 用途 |
|------|------|
| `PuaSE.md` | 主编排器配置 + 工作流定义，包含 `subagents:` 和 `experts:` 列表 |
| `CONTRIBUTING.md` | 新增/删除子 Agent 的详细流程规范 |
| `README.md` | 项目说明，需与 subagents 列表保持同步 |

## 三文件一致性约束

新增或删除子 Agent 时必须同步修改以下三处：
1. `PuaSE.md` — `subagents:` 列表 + `experts:` 列表
2. 对应 `.md` 文件 — 创建或删除
3. `README.md` — 项目结构图和 Agent 列表

详见 `CONTRIBUTING.md` 的完整流程。

## 仓库根目录无可执行文件

- 无 `opencode.json`（用户侧外部配置）
- 无 `.opencode/` 目录
- 无可执行脚本
- `.github/` 仅含 Issue 模板（bug_report、feature_request）
