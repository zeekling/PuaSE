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

### 1. 安装 OpenCode

根据你的操作系统选择一种方式：

**YOLO（推荐，macOS / Linux）**

```bash
curl -fsSL https://opencode.ai/install | bash
```

**macOS / Linux（Homebrew，自动更新）**

```bash
brew install anomalyco/tap/opencode
```

**macOS / Linux（Homebrew 官方仓库，更新较慢）**

```bash
brew install opencode
```

**Arch Linux**

```bash
sudo pacman -S opencode   # 稳定版
paru -S opencode-bin      # AUR 最新版
```

**Windows**

```bash
scoop install opencode           # Scoop
choco install opencode           # Chocolatey
```

**任意平台（npm）**

```bash
npm i -g opencode-ai@latest
```

> 安装前请确保已卸载 0.1.x 之前的旧版本。

验证安装：

```bash
opencode --version
```

### 2. 安装 PuaSE Agent

将本仓库的 Agent 配置安装到 OpenCode 的配置目录：

**macOS / Linux**

```bash
# 推荐：创建符号链接（同步更新，自动生效）
ln -sf "$PWD" "$HOME/.config/opencode/agents/PuaSE"

# 或手动复制（如需独立副本）
cp -r . "$HOME/.config/opencode/agents/PuaSE/"
```

**Windows（PowerShell）**

```powershell
# 推荐：创建目录联结（同步更新，自动生效）
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\opencode\agents\PuaSE" -Target "$pwd"

# 或手动复制（如需独立副本）
Copy-Item -Recurse -Path ".\*" -Destination "$env:USERPROFILE\.config\opencode\agents\PuaSE\"
```

### 3. 配置 opencode.json

在 OpenCode 配置目录（`~/.config/opencode/`）下找到或创建 `opencode.json`，添加 PuaSE Agent 注册信息：

```json
{
  "agent": {
    "PuaSE": {
      "description": "全局编排 Agent，解析隐含需求、评估代码库成熟度、委派给专家 Agent。适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。",
      "prompt": "C:\\Users\\<用户名>\\.config\\opencode\\agents\\PuaSE\\PuaSE.md",
      "permission": {
        "*": "allow"
      }
    }
  }
}
```

> **注意**：`prompt` 路径替换为实际路径。macOS/Linux 示例：`"/home/<用户名>/.config/opencode/agents/PuaSE/PuaSE.md"`。如果使用符号链接或目录联结，路径指向链接目标位置即可。

各字段说明：

| 字段 | 说明 |
|------|------|
| `PuaSE` | Agent 名称，在 OpenCode 中通过 `@PuaSE` 引用 |
| `description` | Agent 描述，OpenCode 用于自动匹配任务 |
| `prompt` | 指向 PuaSE.md 配置文件的路径（含 YAML frontmatter + 工作流定义） |
| `permission` | 权限配置，`"*": "allow"` 表示允许所有操作 |

配置完成后重启 OpenCode 即可生效。

### 4. 验证安装

在任意项目目录启动 OpenCode 会话：

```bash
opencode
```

PuaSE 会自动作为全局编排器可用。输入以下指令验证：

```
帮我分析这个项目的架构
```

如果返回架构分析任务，说明安装成功。

## 快速开始

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
