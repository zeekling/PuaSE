# PuaSE — Agent 配置仓库

核心是 Agent 配置文件（`.md` + YAML frontmatter），另有一个 `website/` 子目录是 Vite 6 静态前端项目。

**本质**：这不是传统代码仓库——无测试框架、无 lint 配置、无构建系统（website 除外）。`.md` 文件是运行时可执行的 Agent 配置，**不是文档**。勿将其当作文档阅读或修改。

## 关键约束

- **全文简体中文**——所有 `description`、注释、说明必须中文
- **frontmatter 的 `name`/`description`/`mode`/`model`/`temperature` 禁止更改**
- **`permissions: any` 仅出现在 PuaSE.md**，子 Agent 无 `permissions` 字段
- 子 Agent 使用 `mode: subagent`，`temperature` 通常 0.1-0.2（documenter 例外：0.3）。PuaSE 自身用 `mode: primary` + `permissions: any` + `run_in_background: true`
- 所有 `developer/*.md` 在 frontmatter 后、正文前有 `<HARD-GATE>` 标签
- 所有子 Agent `.md` 以 `### 交付后` 结尾（仅 PuaSE.md、reflector.md 例外）
- **禁止未经用户明确允许执行 git commit/push**

## 文件结构（16 个 `.md` 配置）

```
PuaSE.md              — 全局编排器（646 行，含 16 项 subagents: 列表）
subagent/
├── architect.md       — 架构分析（full 深度 / quick 轻量）
├── code-reviewer.md   — 代码审查
├── documenter.md      — 文档编写
├── quality-inspector.md — 质量巡检
├── reflector.md       — 复盘分析（无 `### 交付后` 尾节）
├── developer/         — 7 个语言开发者（均有 HARD-GATE）
│   ├── go-developer.md
│   ├── rust-developer.md
│   ├── csharp-developer.md
│   ├── java-developer.md
│   ├── python-developer.md
│   ├── cpp-developer.md
│   └── web-developer.md
├── dba/               — 3 个数据库专家
│   ├── mysql-dba.md / oracle-dba.md / postgresql-dba.md
└── security/
    └── security-expert.md
```

> ⚠️ `developer/bigdata` **不存在**。quality-inspector.md 和 README.md 中残留的 `bigdata` 引用是过时的（如 QI-BIG 检查项），注意识别。
> ⚠️ `docs/PROJECT_STRUCTURE.md` 的 ISSUE_TEMPLATE 目录**已不存在**，目录树部分过时。

## 工作流（Pre-Code → Execution → Post-Code）

```
隐含需求解析 → 成熟度评估 → [architect 架构分析]
→ [developer/dba/documenter 执行] → [security + code-review + quality 三方并行验收]
→ [reflector 复盘（条件触发）] → KPI 验收卡
```

完整编排规则在 PuaSE.md 中定义，尤其是 §4.2（验收规则）和 §6.4（KPI 门禁）。

**⚠️ 强制执行规则（已硬化到 PuaSE.md）**：
1. **STEP 铁律**：每次任务的第一条回复必须是 STEP 列表
2. **反熟悉度偏误**：写文件操作前必须委派对应子 Agent（web-developer/文档写入用 documenter 等）
3. **验收闭环**：所有代码变更必须走 P3-P5 三方验收（code-reviewer + quality-inspector + security-expert）
4. **KPI 卡输出**：完成前必须输出 KPI 卡，无 KPI 卡的完成声明 = P0 违规
5. **自检清单**：每次任务开始前必须执行自检（5 项强制检查）

## CI/CD（仅 website 目录触发）

位于 `.github/workflows/`，两个 `.yml` 文件：

| 工作流 | 触发条件 | 操作 |
|--------|---------|------|
| `build.yml` | 任意分支 push / main PR，路径 `website/**` 或 `.github/workflows/build.yml` | `npm ci` → `npm run build`，Node 20 |
| `deploy.yml` | main push + `v*.*.*` tag，路径 `website/**` 或 `.github/workflows/deploy.yml` | 构建后推 `gh-pages`；tag 部署到 `versions/v*.*.*/`，main 推根目录 |

website 命令（均在 `website/` 目录执行）：
```bash
npm run dev       # 开发服务器
npm run build     # 生产构建
npm run preview   # 预览构建结果
```

website 是纯静态 Vite 6 项目（无 React/Vue/Svelte），`base: '/PuaSE/'`。

## 陷坑与提示

- **无 `opencode.json`** —— 该文件是用户侧配置，不跟踪到仓库。勿创建或写入 `opencode/` 目录
- **CONTRIBUTING.md 过时** —— 它仍引用 PuaSE.md 的 `experts:` 列表，但该列表已被删除。增删子 Agent 时以 PuaSE.md frontmatter 的 `subagents:` 为准
- **`docs/` 中 `specs/`, `plans/`, `superpowers/`, `kpi/` 被 `.gitignore`**，但本地可能已创建。`docs/blog/` 存放发布日志
- **`.PuaSE/improvement-track.md`** —— reflector 复盘时追加 P0/P1/P2 改进项。Agent **不得主动据此优化自身行为**（由用户决定）
- **`.gitignore` 忽略项**：`.logs`, `.idea`, `docs/specs`, `docs/plans`, `docs/superpowers`, `docs/kpi/`, `node_modules/`, `dist/`, `.superpowers/`, `.PuaSE`
- **增量变更规则**：增删子 Agent 需同步 PuaSE.md 的 `subagents:` 列表 + README.md + docs/AGENT_LIST.md + docs/PROJECT_STRUCTURE.md，四者一起提交
