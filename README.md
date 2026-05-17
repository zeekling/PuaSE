# PuaSE

全局编排 Agent — 解析隐含需求、评估代码库成熟度、委派给专家 Agent。

适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。

## 核心能力

| 能力 | 说明 |
|------|------|
| **隐含需求解析** | 5 步法：捕获显式需求 → 推导隐含需求 → 识别约束 → 拆解任务 → 确定优先级 |
| **代码库成熟度评估** | 快速判断项目处于初期/成长/成熟阶段，自适应策略 |
| **先架构后代码** | 不读通架构不写代码，不画清依赖不修改 |
| **专家委派** | 将任务委派给 architect、code-reviewer、documenter、explore、general、java-developer、python-developer、security-expert、quality-inspector 等专家 Agent |
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
│   │   ├── java-developer.md  # Java 开发
│   │   └── python-developer.md # Python 开发
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
| **security-expert** | 安全审计 — OWASP Top 10、依赖漏洞、加密合规 |
| **documenter** | 文档编写 — README、API 文档、设计文档、使用指南 |
| **quality-inspector** | 质量巡检 — 检查 architect、java-developer、documenter 交付物，不合格打回重做 |

## 快速开始

确保已安装 [OpenCode](https://opencode.ai)，然后在项目目录中启动会话：

```bash
opencode
```

PuaSE 会自动作为全局编排器，根据任务类型委派对应专家 Agent。

## 使用示例

- `帮我分析这个项目的架构` → 委派 architect Agent
- `开发一个新的 Java 功能` → 委派 java-developer Agent
- `修复 Java 代码中的 bug` → 委派 java-developer Agent
- `写一个 Python 脚本` → 委派 python-developer Agent
- `重构整个模块` → 架构分析 → 重构 → 代码审查
- `审计代码安全` → 委派 security-expert Agent
- `多步骤质量巡检` → 每步子 Agent 交付后由 quality-inspector 检查
- `给这个项目写文档` → 委派 documenter Agent 编写或更新文档

## 许可证

MIT
