# PuaSE 仓库规则

## 第一会踩的坑

- **所有 `.md` 是 Agent 配置**（含 YAML frontmatter），不要当普通文档编辑。frontmatter 字段禁止更改。
- **全文简体中文** — 所有 description、注释、说明都必须是中文。
- **无构建系统**：无 `package.json`、无测试、无 lint、无 CI — 不要运行或寻找这些。
- **权限**：`permissions: any` 即全部权限且委派不降权。详见 PuaSE.md 第 7 节。
- **PuaSE.md 的 `subagents:` 列表必须与实际文件一一对应** — 新增子 Agent 要同时改列表和建文件。
- **`explore` 和 `general` 是内置 Agent**，没有 `.md` 配置文件，不要寻找对应的文件。
- **目录不是平的**：`architect.md`、`code-reviewer.md`、`documenter.md`、`quality-inspector.md` 在 `subagent/` 根；`developer/` 下有 `cpp-developer.md`、`java-developer.md`、`python-developer.md`；`security/` 下有 `security-expert.md`。
