# PuaSE 仓库规则

本仓库是 OpenCode Agent **PuaSE** 及其所有子 Agent 的配置文件镜像。

## Agent 不读就会犯错的事

- **所有 `.md` 文件均为 Agent 配置**，含 YAML frontmatter + Markdown 正文。不要当作普通文档编辑。
- **frontmatter 禁止改动**：`name`、`description`、`mode: subagent`、`model: inherit` 不可删除或修改。PuaSE.md 特有 `permissions: any`、`run_in_background: true`、`subagents: [...]`。
- **语言**：全文简体中文（包括所有 description、注释、说明）。
- **无构建系统**：无 `package.json`、无测试、无 lint、无 CI — 不要运行或寻找这些。
- **权限**：`permissions: any` 即全部权限且委派不降权。详见 PuaSE.md 第 7 节。
- **PuaSE.md 的 `subagents:` 列表必须与实际文件一一对应** — 新增子 Agent 要同时改列表和建文件。
- **目录不是平的**：`architect.md`、`code-reviewer.md`、`documenter.md`、`quality-inspector.md` 在 `subagent/` 根；`developer/java-developer.md` 和 `developer/python-developer.md` 在 `developer/`；`security/security-expert.md` 在 `security/`。
