# 简介

全局编排 Agent — 把 AI 编程流程化，阻止 AI 偷奸耍滑、欺骗人类。

解析隐含需求、评估代码库成熟度、委派给专家 Agent。适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。

## 设计理念：流程化编程，防欺诈架构

> **AI 的最大风险不是"做错"，而是"假装做了"。**
>
> 未经验证的"已完成" = 未完成。没有测试通过的"已修复" = 没修。没有审计的"安全" = 裸奔。

PuaSE 的设计围绕一个核心原则：**AI 编程必须可验证、可审计、不可跳过门禁。** 每个环节都有检查点，每一步都有证据输出。

### PuaSE 如何阻止 AI 偷奸耍滑

| AI 常见的"偷懒花招" | PuaSE 的防作弊机制 | 怎么抓到的 |
|---------------------|-------------------|-----------|
| 声称"已完成"但没跑测试 | **HARD-GATE 门禁** — 所有 developer 文件头部强制声明，禁止未经验证声称完成 | 没有测试输出 = 驳回 |
| 跳过架构分析直接写代码 | **先架构后代码原则** — 超过 3 步的任务必须先由 architect 分析 | 架构分析结果缺失 = 不进入编码阶段 |
| 修了 A 但悄悄改了 B | **影响面清单** — 每次变更必须声明改了哪些文件、影响哪些模块 | 未声明的修改 = 代码检视时发现 |
| "可能是环境问题"敷衍了事 | **事实红线** — 所有归因必须经过工具验证 | 未验证的归因 = 按 L4 压力升级处理 |
| 说"没办法了"但其实没穷尽方案 | **穷尽红线** — 放弃前必须证明已穷尽所有方案 | 未穷尽 = 直接 L4 毕业警告 |
| 交付物质量不合格蒙混过关 | **quality-inspector** — 全链路巡检，不合格打回重做 | 被 quality-inspector 拒绝 = 退回 developer |
| 代码有安全漏洞但不说 | **security-expert** — 17 维度安全审计，阻断性报告优先级最高 | security-expert 的阻断报告可否决整个交付 |
| KPI 卡里不写测试和检视结果 | **KPI 验收卡强制字段** — 🧪 测试验证 + 🔍 代码检视必须填写 | 不填 = KPI 卡标记为"⏳ 门禁未过" |
| 用户说"这个很熟我自己改更快" | **反熟悉度偏误钩子** — 必须反问：涉及写文件？有子 Agent？不熟会委派？ | 三问任一为是 → 必须委派 |

### 核心防线（四道门禁）

```
① Pre-Code 门禁      ② Execution 门禁       ③ Post-Code 门禁       ④ KPI 出卡
┌──────────────┐     ┌────────────────┐     ┌──────────────────┐     ┌───────────┐
│ 架构分析通过？ │  →  │ 编译+测试通过？  │  →  │ 安全审计 + 代码   │  →  │ 🧪测试    │
│ 数据流走通了？ │     │ 影响面已确认？   │     │ 审查 + 质量巡检   │     │ 🔍检视    │
│ 依赖关系清晰？ │     │ 验证证据已贴出？ │     │ 三者全部通过？    │     │ 五者齐全  │
└──────────────┘     └────────────────┘     └──────────────────┘     └───────────┘
  不过 → 退回分析      不过 → 退回修改        不过 → 退回重做        不全 → ⏳ 未过
```

### 信任模型：因为验证所以信任

PuaSE 不相信 AI 的任何口头承诺。信任建立的方式是：

> **你说"完成了" → 贴出编译输出 ✅ → 贴出测试结果 ✅ → 贴出检视报告 ✅ → 我确认你确实完成了。**

没有输出 = 没有完成。这是零容忍规则。

## 核心能力

| 能力 | 说明 |
|------|------|
| **隐含需求解析** | 5 步法：捕获显式需求 → 推导隐含需求 → 识别约束 → 拆解任务 → 确定优先级 |
| **代码库成熟度评估** | 快速判断项目处于初期/成长/成熟阶段，自适应策略 |
| **先架构后代码** | 不读通架构不写代码，不画清依赖不修改 |
| **专家委派** | 将任务委派给 architect、architect-scan、bigdata-developer、code-reviewer、cpp-developer、csharp-developer、documenter、explore、general、go-developer、java-developer、mysql-dba、oracle-dba、python-developer、rust-developer、security-expert、quality-inspector、web-developer、reflector 等专家 Agent |
| **上下文隔离原则** | 所有专家任务在独立子 Agent 会话中执行，主上下文仅保留编排决策所需最小信息，避免专家工作日志污染编排层 |
| **技能编排优化** | 将执行类 Skill（如 brainstorming/TDD/调试）翻译为委派策略委派给对应 Agent，自身不执行技能中的"你来做"指令。编排者不做执行者的事 |
| **结果综合 · KPI 验收** | 多 Agent 结果按依赖顺序合并，冲突检测与仲裁。输出 KPI 验收卡（🧪 测试验证 + 🔍 代码检视）量化交付标准 |
| **Post-Code 默认并行验收** | 开发者返回结果后默认并行启动 code-reviewer + quality-inspector +（如适用）security-expert 三方验收，任一不通过即打回重做（详见 PuaSE.md §4.2） |
| **KPI 卡强制生成钩子** | 子 Agent 返回后、声明完成前必须按序执行：验收 → KPI 卡 → 复盘。无 KPI 卡的完成声明视为 P0 流程违规（详见 PuaSE.md §6.4） |
| **Brainstorming → 实现过渡** | brainstorming 产出 spec 后自动判断是否加载 writing-plans（涉及文件数 ≤ 2 + 无新模块 + 无架构变更 可跳过），输出过渡决策理由，跳过 plan 不跳过验收（详见 PuaSE.md §10.5） |
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
| **Post-Code（质量门禁）** | 执行安全审计、代码审查、质量巡检和复盘总结 | security-expert, code-reviewer, quality-inspector, reflector | 17维度安全审计、计划对齐与代码质量审查、交付物逐项检查（仅通过/打回）。KPI 卡包含 🧪 测试验证 + 🔍 代码检视 两个强制区域 |

**时序流水线（带上下文隔离）：**

```
┌─ PuaSE 主上下文（编排层）─────────────────────────────────────────────┐
│ 隐含需求解析 → 成熟度评估 → 委派专家 → 冲突仲裁 → KPI 验收          │
│  ❌ 不在此执行专家工作任务（仅做编排决策）                            │
└──────────────────────────────────────────────────────────────────────┘
       委派 ↓               子 Agent 独立上下文
┌──────────────────────────────────────────────────────────────────────┐
│ architect    [架构分析]   →   developer/*   [开发+DBA+文档]          │
│                              dba/*         (独立上下文窗口)           │
│                              documenter                              │
│                              ↓                                       │
│ security-expert · code-reviewer · quality-inspector [三方并行验收]    │
└──────────────────────────────────────────────────────────────────────┘
                                           ↓
                                    🧪 测试验证 + 🔍 代码检视
                                    KPI 验收卡（五者缺一不可）
```

**KPI 验收标准（五者缺一不可 + 门禁强制序列）：**
> 1. ✅ 编译/测试/语法验证通过（输出验证证据）
> 2. ✅ code-reviewer 审查代码逻辑、架构合规、设计质量
> 3. ✅ quality-inspector 全链路质量巡检
> 4. ✅ security-expert 安全审计（敏感场景必须）
> 5. ✅ 影响面清单已确认
>
> **门禁执行顺序（§6.4 KPI 卡强制生成钩子）：**
> 子 Agent 返回后 → 按 §4.2 并行启动 code-reviewer + quality-inspector +（如适用）security-expert
> → 全部通过后输出 KPI 验收卡 →（可选）reflector 复盘 → 声明完成。
> **任何声称"完成"但没有 KPI 卡的行为，均视为 P0 级流程违规。**

## 项目结构

```
├── PuaSE.md                 # 全局编排 Agent（主入口）
├── AGENTS.md                # 仓库规则与约定
├── README.md                # 本文件
├── CONTRIBUTING.md          # 贡献指南（目录树过期，勿依赖）
├── LICENSE                  # MIT 许可证
├── .gitignore
├── .opencode/
│   └── rules/
│       └── puse-sync.md      # PuaSE.md 变更同步约束
├── .github/
│   ├── ISSUE_TEMPLATE/      # Issue 模板
│   └── workflows/
│       └── deploy.yml       # GitHub Pages 自动部署（push main → website/**）
├── docs/                    # 使用指南
│   ├── index.md             # PuaSE 使用指南
│   └── opencode.md          # OpenCode 安装配置指南
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
│   ├── reflector.md         # 反思总结
│   └── security/
│       └── security-expert.md # 安全审计
└── website/                 # Vite 静态官网（独立前端项目）
    ├── index.html           # 主页
    ├── src/
    │   ├── main.js          # 入口脚本
    │   └── style.css        # 样式
    ├── public/              # 静态资源
    ├── package.json         # npm dev / build / preview
    └── vite.config.js       # Vite 6 配置，base /PuaSE/

## 同步规则

- **运行副本**：`~/.config/opencode/agents/PuaSE/`（Windows: `C:\Users\<user>\.config\opencode\agents\PuaSE\`）
- **本仓库**：配置的权威存储。同步方向始终是 **安装版 → 仓库**（安装版是被 OpenCode 实际加载的版本）
- **同步方法**：比对 MD5 hash → 复制差异文件 → 提交
- **安装版文件数**：固定为 18（PuaSE.md + 17 个子 Agent .md）
- **PuaSE.md 同步约束**：PuaSE.md 发生任何变更后，必须同步更新 README.md 和 website/index.html。提交 PuaSE.md 时必须同时包含对应 README 和 website 的同步修改。详见 [.opencode/rules/puse-sync.md](.opencode/rules/puse-sync.md)。

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
| **reflector** | 反思总结 — 对 PuaSE 的委派行为进行复盘分析，委派链回顾、分析得失、提炼改进策略 |

## 安装

PuaSE 基于 OpenCode Agent 机制运行，[查看 OpenCode 安装配置指南](docs/opencode.md)。

## 使用示例

> 所有委派均在**独立子 Agent 会话**中运行，主上下文仅做编排决策，详见 PuaSE.md 的"上下文隔离原则"。

### 架构分析

- `帮我分析这个项目的架构`（**成熟代码库**）→ 委派 **architect-scan**（子 Agent）快速摸底，如需深度再升级为 architect
- `帮我分析这个项目的架构`（**初期/成长代码库**）→ 委派 **architect**（子 Agent）完整分析（含 C4/ADR/风险评估）
- `我想改这个模块但不太了解结构` → 已有架构分析文档委派 **architect-scan**，否则委派 **architect**
- `给这个函数加个参数` → 短链任务，PuaSE 在主上下文直接执行（纯搜索/读取，不涉及文件编辑时）

### 编码开发

- `开发一个新的 Java/Go/Rust/C# 功能` → 先委派 **architect** 架构设计 → 再委派对应语言 **developer** 实现编码 → **security-expert 安全审计**、**code-reviewer 代码审查** 与 **quality-inspector 质量巡检** 三者并行，全部通过才算完成
- `编写 Go 程序` → 委派 **go-developer** 编码+编译+测试验证
- `编写 Rust 程序` → 委派 **rust-developer** 编码+编译+测试验证（含 clippy）
- `编写 C# 程序` → 委派 **csharp-developer** 编码+编译+测试验证
- `修复 Java 代码中的 bug` → 委派 **java-developer** 修复+验证
- `写一个 Python 脚本` → 委派 **python-developer** 编码+语法检查+测试验证
- `编写 C/C++ 程序` → 委派 **cpp-developer** 编码+编译+测试验证
- `开发前端页面` → 委派 **web-developer** 编码+构建+测试验证
- `写一个 Spark/Flink/Kafka 数据处理任务` → 委派 **bigdata-developer** 编码+编译+测试验证

### 数据库管理

- `配置和优化 MySQL 数据库` → 委派 **mysql-dba** 数据库专家管理
- `配置和优化 Oracle 数据库` → 委派 **oracle-dba** 数据库专家管理
- `写一个数据库优化脚本` → 直接委派 **oracle-dba** 或 **mysql-dba** 处理

### 质量门禁

- `审计代码安全` → 委派 **security-expert** 执行 17 维度安全审计
- `多步骤质量巡检` → 每步子 Agent 交付后由 **quality-inspector** 全链路检查，不合格打回重做
- `审查代码质量` → 委派 **code-reviewer** 聚焦代码正确性、安全、性能、可维护性
- `Post-Code 默认并行验收` → 开发者返回后默认并行启动 code-reviewer + quality-inspector +（如适用）security-expert，任一不通过打回重做（详见 PuaSE.md §4.2）
- `KPI 卡强制生成` → 子 Agent 返回后、声明完成前必须按序执行：验收 → KPI 卡 → 复盘。无 KPI 卡的完成声明视为 P0 流程违规（详见 PuaSE.md §6.4）
- `KPI 验收输出` → 编译/测试验证 + code-reviewer 审查 + quality-inspector 巡检 + security-expert 审计 + 影响面确认，五者缺一不可

### Brainstorming → 实现过渡

- `新功能设计开发` → 先委派 **architect** 或加载 brainstorming 产出 spec → 判断是否需加载 writing-plans（默认加载，涉及文件数 ≤ 2 + 无新模块 + 无架构变更 可跳过）→ 输出过渡决策理由 → 委派对应 **developer** 实现 → 继续走 Post-Code 验收 + KPI 卡强制生成（详见 PuaSE.md §10.5）

### 其他

- `重构整个模块` → 先委派 **architect** 分析现有架构 → 再委派对应语言 **developer** 实施重构 → 委派 **code-reviewer** 审查结果
- `给这个项目写文档` → 委派 **documenter** 编写或更新文档
- `多步骤任务中有可并行环节` → 安全审计/代码审查/质量巡检委派给不同 Agent 并行执行
- \`更新 README 和 website\` → 分别委派 **documenter**（README 更新）和 **web-developer**（website 更新），两个子 Agent 在独立上下文中**并行执行**，PuaSE 主上下文只做合并+验收
- \`任务完成后复盘\` → 委派 **reflector** 分析委派链得失，产出改进建议，在下一次委派中落地

## 许可证

MIT
