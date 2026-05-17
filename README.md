# PuaSE

全局编排 Agent — 解析隐含需求、评估代码库成熟度、委派给专家 Agent。

适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。

## 核心能力

| 能力 | 说明 |
|------|------|
| **隐含需求解析** | 5 步法：捕获显式需求 → 推导隐含需求 → 识别约束 → 拆解任务 → 确定优先级 |
| **代码库成熟度评估** | 快速判断项目处于初期/成长/成熟阶段，自适应策略 |
| **先架构后代码** | 不读通架构不写代码，不画清依赖不修改 |
| **专家委派** | 将任务委派给 architect、code-reviewer、cpp-developer、documenter、explore、general、java-developer、mysql-dba、oracle-dba、python-developer、security-expert、quality-inspector 等专家 Agent |
| **结果综合** | 多 Agent 结果按依赖顺序合并，冲突检测与仲裁 |
| **异常处理** | 模型失败自动重试（指数退避）、Agent超时降级自执行、循环委派检测、关键路径保护 |

## 项目结构

```
├── PuaSE.md                 # 全局编排 Agent（主入口）
├── AGENTS.md                # 仓库规则与约定
├── subagent/                # 子 Agent 定义
│   ├── architect.md         # 架构分析
│   ├── code-reviewer.md     # 代码审查
│   ├── documenter.md        # 文档编写
│   ├── developer/
│   │   ├── cpp-developer.md     # C/C++ 开发
│   │   ├── java-developer.md    # Java 开发
│   │   └── python-developer.md  # Python 开发
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
| **architect** | 架构分析 — 目录结构、模块依赖、数据流、设计模式 |
| **code-reviewer** | 代码审查 — 计划对齐、代码质量、架构合规 |
| **java-developer** | Java 开发 — 编码、编译、测试验证 |
| **python-developer** | Python 开发 — 编码、语法检查、测试验证 |
| **cpp-developer** | C/C++ 开发 — 编码、编译、测试验证 |
| **mysql-dba** | MySQL 数据库管理 — 安装配置、性能调优、备份恢复、高可用 |
| **oracle-dba** | Oracle 数据库管理 — 安装配置、性能调优、备份恢复、高可用 |
| **security-expert** | 安全审计 — 17 个安全维度覆盖 OWASP Top 10、CWE、内存安全等 |
| **documenter** | 文档编写 — README、API 文档、设计文档、使用指南 |
| **quality-inspector** | 质量巡检 — 检查 architect、全部开发者（developer/*）、全部 DBA（dba/*）、documenter 交付物，不合格打回重做 |

## 安装

### 1. 安装 OpenCode

根据你的操作系统选择一种方式：

**macOS / Linux（推荐）**

```bash
curl -fsSL https://opencode.ai/install | bash
```

**macOS（Homebrew）**

```bash
brew install opencode
```

**Windows**

```bash
winget install OpenCode.OpenCode
```

**任意平台（npm）**

```bash
npm install -g opencode-ai
```

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

### 3. 验证安装

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

- `帮我分析这个项目的架构` → 委派 architect Agent
- `开发一个新的 Java 功能` → 委派 java-developer Agent
- `修复 Java 代码中的 bug` → 委派 java-developer Agent
- `写一个 Python 脚本` → 委派 python-developer Agent
- `编写 C/C++ 程序` → 委派 cpp-developer Agent
- `配置和优化 MySQL 数据库` → 委派 mysql-dba Agent
- `配置和优化 Oracle 数据库` → 委派 oracle-dba Agent
- `重构整个模块` → 架构分析 → 重构 → 代码审查
- `审计代码安全` → 委派 security-expert Agent
- `多步骤质量巡检` → 每步子 Agent 交付后由 quality-inspector 检查
- `给这个项目写文档` → 委派 documenter Agent 编写或更新文档

## 许可证

MIT
