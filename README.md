# 简介

全局编排 Agent — 解析隐含需求、评估代码库成熟度、委派给专家 Agent。

适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。

## 核心能力

| 能力 | 说明 |
|------|------|
| **隐含需求解析** | 5 步法：捕获显式需求 → 推导隐含需求 → 识别约束 → 拆解任务 → 确定优先级 |
| **代码库成熟度评估** | 快速判断项目处于初期/成长/成熟阶段，自适应策略 |
| **先架构后代码** | 不读通架构不写代码，不画清依赖不修改 |
| **专家委派** | 将任务委派给 architect、architect-scan、bigdata-developer、code-reviewer、cpp-developer、csharp-developer、documenter、explore、general、go-developer、java-developer、mysql-dba、oracle-dba、python-developer、rust-developer、security-expert、quality-inspector、web-developer 等专家 Agent |
| **结果综合** | 多 Agent 结果按依赖顺序合并，冲突检测与仲裁 |
| **异常处理** | 模型失败自动重试（指数退避）、Agent超时降级自执行、循环委派检测、关键路径保护 |

### 层级结构

```
                                    ┌──────────────────────────────────┐
                                    │          PuaSE                   │
                                    │     （全局编排器）                │
                                    │     权限: * allow                │
                                    │     模型: inherit                │
                                    └─────────────┬────────────────────┘
                                                  │
                    ┌─────────────────────────────┼──────────────────────────────┐
                    │                             │                              │
           ┌────────┴────────┐          ┌─────────┴──────────┐       ┌──────────┴──────────┐
           │     Pre-Code    │          │     Execution      │       │     Post-Code       │
           │    （前置分析）  │          │    （执行层）       │       │    （质量门禁）      │
           └────────┬────────┘          └─────────┬──────────┘       └──────────┬──────────┘
                    │                             │                             │
           ┌────────┴────────┐          ┌─────────┴──────────┐       ┌──────────┴──────────┐
           │   architect     │          │   developer/*      │       │  security-expert    │
           │   architect-scan│          │       ├─ java      │       │  code-reviewer      │
           │   explore       │          │       ├─ python    │       │  quality-inspector  │
           │                 │          │       ├─ cpp       │       │                     │
           │                 │          │       ├─ go        │       │                     │
           │                 │          │       ├─ rust      │       │                     │
           │                 │          │       ├─ csharp    │       │                     │
           │                 │          │       ├─ bigdata   │       │                     │
           │                 │          │       └─ web       │       │                     │
           │                 │          │                    │       │                     │
           │                 │          │   dba/*            │       │                     │
           │                 │          │       ├─ mysql     │       │                     │
           │                 │          │       └─ oracle    │       │                     │
           │                 │          │                    │       │                     │
           │                 │          │   general          │       │                     │
           │                 │          │                    │       │                     │
           │                 │          │   documenter       │       │                     │
           └─────────────────┘          └────────────────────┘       └─────────────────────┘
```

**三层结构说明：**

| 层级 | 角色 | Agent | 核心职责 |
|------|------|-------|---------|
| **Pre-Code（前置分析）** | 在写任何代码前完成架构摸底 | architect, architect-scan, explore | 完整分析（C4/ADR/风险评估）或轻量扫描（3步快速摸底） |
| **Execution（执行层）** | 负责具体的编码、数据管理和文档产出 | developer/*, dba/*, general, documenter | 代码实现、数据库管理、文档编写，每次变更后立即验证 |
| **Post-Code（质量门禁）** | 执行安全审计、代码审查和质量巡检 | security-expert, code-reviewer, quality-inspector | 17维度安全审计、计划对齐与代码质量审查、交付物逐项检查（仅通过/打回） |

**时序流水线：**

```
隐含需求解析 → 成熟度评估 → [架构分析] → [开发/DBA/文档] → [安全审计 | 代码审查 | 质量巡检] → 完成
    PuaSE           PuaSE          architect    developer/*     三者可并行                    🟢/🔴
                                                    dba/*
                                                documenter
```

## 项目结构

```
├── PuaSE.md                 # 全局编排 Agent（主入口）
├── AGENTS.md                # 仓库规则与约定
├── docs/                    # 跨平台使用指南
│   ├── index.md             # 跨平台入口与能力对比
│   ├── opencode.md          # OpenCode 安装配置指南
│   ├── claude-code.md       # Claude Code 使用指南
│   ├── copilot-cli.md       # GitHub Copilot CLI 使用指南
│   ├── cursor.md            # Cursor IDE 使用指南
│   └── cline.md             # Cline VS Code 扩展使用指南
├── subagent/                # 子 Agent 定义
│   ├── architect-scan.md    # 轻量级架构扫描
│   ├── architect.md         # 架构分析
│   ├── code-reviewer.md     # 代码审查
│   ├── documenter.md        # 文档编写
│   ├── developer/
│   │   ├── cpp-developer.md     # C/C++ 开发
│   │   ├── csharp-developer.md  # C# 开发
│   │   ├── go-developer.md      # Go 开发
│   │   ├── java-developer.md    # Java 开发
│   │   ├── bigdata-developer.md # 大数据开发
│   │   ├── python-developer.md  # Python 开发
│   │   ├── rust-developer.md    # Rust 开发
│   │   └── web-developer.md     # Web 前端开发
│   ├── dba/
│   │   ├── mysql-dba.md        # MySQL 数据库管理
│   │   └── oracle-dba.md       # Oracle 数据库管理
│   ├── quality-inspector.md # 质量巡检
│   └── security/
│       └── security-expert.md # 安全审计
├── .gitignore
└── README.md
```

## Agent 列表

| Agent | 职责 |
|-------|------|
| **PuaSE** | 全局编排 — 解析需求、评估成熟度、委派专家 |
| **architect** | 架构分析 — 目录结构、模块依赖、数据流、C4 模型、ADR、风险评估 |
| **architect-scan** | 轻量级架构扫描 — 3步快速摸底，不产出 C4 图/ADR |
| **code-reviewer** | 代码审查 — 聚焦代码质量（正确性、安全、性能、可维护性） |
| **go-developer** | Go 开发 — 编码、编译、测试验证 |
| **rust-developer** | Rust 开发 — 编码、编译、测试验证 |
| **csharp-developer** | C# 开发 — 编码、编译、测试验证 |
| **java-developer** | Java 开发 — 编码、编译、测试验证 |
| **python-developer** | Python 开发 — 编码、语法检查、测试验证 |
| **cpp-developer** | C/C++ 开发 — 编码、编译、测试验证 |
| **bigdata-developer** | 大数据开发 — Spark/Flink/Kafka/Hive/Airflow 编码、编译、测试验证 |
| **web-developer** | Web 前端开发 — 编码、构建、测试验证 |
| **mysql-dba** | MySQL 数据库管理 — 安装配置、性能调优、备份恢复、高可用 |
| **oracle-dba** | Oracle 数据库管理 — 安装配置、性能调优、备份恢复、高可用 |
| **security-expert** | 安全审计 — 17 个安全维度覆盖 OWASP Top 10、CWE、内存安全等 |
| **documenter** | 文档编写 — README、API 文档、设计文档、使用指南 |
| **quality-inspector** | 质量巡检 — 检查 architect、security-expert、全部开发者（developer/*）、全部 DBA（dba/*）、documenter 交付物，不合格打回重做 |

## 安装

PuaSE 支持多种 AI 编码工具，选择你的平台查看详细安装指南：

| 平台 | 安装方式 | 指南 |
|------|---------|------|
| **OpenCode** | Agent 注册，原生支持 | [📖 OpenCode 安装指南](docs/opencode.md) |
| **Claude Code** | CLAUDE.md 指令注入 | [📖 Claude Code 安装指南](docs/claude-code.md) |
| **GitHub Copilot CLI** | AGENTS.md 指令注入 | [📖 Copilot CLI 安装指南](docs/copilot-cli.md) |
| **Cursor** | .cursorrules 规则注入 | [📖 Cursor 安装指南](docs/cursor.md) |
| **Cline** | CLINE.md 指令注入 | [📖 Cline 安装指南](docs/cline.md) |

> 各平台能力对比详见[跨平台使用指南](docs/index.md)。

## 跨平台使用

PuaSE 的核心设计是**平台无关的** — 通过不同的配置方式（AGENTS.md / CLAUDE.md / .cursorrules / CLINE.md），可以在主流 AI 编码工具中使用相同的编排逻辑。

各平台配置方式对比：

| 平台 | 配置文件 | 配置方式 | 功能完整度 |
|------|---------|---------|-----------|
| **OpenCode** | `opencode.json` | Agent 注册 | ⭐⭐⭐⭐⭐ |
| **Claude Code** | `CLAUDE.md` | 指令注入 | ⭐⭐⭐ |
| **Copilot CLI** | `AGENTS.md` | 指令注入 | ⭐⭐⭐ |
| **Cursor** | `.cursorrules` | 规则注入 | ⭐⭐⭐ |
| **Cline** | `CLINE.md` | 指令注入 | ⭐⭐⭐ |

> **最佳体验**：OpenCode 提供完整的 Agent 委派、权限模型、后台运行等高级功能。其他平台通过指令注入模拟 PuaSE 的编排逻辑，适合轻量使用。

## 使用示例

- `帮我分析这个项目的架构`（成熟代码库）→ 委派 architect-scan Agent 快速摸底
- `帮我分析这个项目的架构`（初期/成长代码库）→ 委派 architect Agent 完整分析
- `开发一个新的 Java 功能` → 委派 java-developer Agent
- `编写 Go 程序` → 委派 go-developer Agent
- `编写 Rust 程序` → 委派 rust-developer Agent
- `编写 C# 程序` → 委派 csharp-developer Agent
- `修复 Java 代码中的 bug` → 委派 java-developer Agent
- `写一个 Python 脚本` → 委派 python-developer Agent
- `编写 C/C++ 程序` → 委派 cpp-developer Agent
- `开发前端页面` → 委派 web-developer Agent
- `写一个 Spark/Flink/Kafka 数据处理任务` → 委派 bigdata-developer Agent
- `配置和优化 MySQL 数据库` → 委派 mysql-dba Agent
- `配置和优化 Oracle 数据库` → 委派 oracle-dba Agent
- `重构整个模块` → 架构分析 → 重构 → 代码审查
- `审计代码安全` → 委派 security-expert Agent
- `多步骤质量巡检` → 每步子 Agent 交付后由 quality-inspector 检查
- `给这个项目写文档` → 委派 documenter Agent 编写或更新文档

## 许可证

MIT
