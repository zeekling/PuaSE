# PuaSE 使用指南

PuaSE（全局编排 Agent）是为 **OpenCode** 设计的 Agent 编排系统，负责解析用户需求、评估代码库状态，并将任务委派给最合适的专家 Agent。

## PuaSE 架构

```
┌─────────────────────────────────────────────────────────────────┐
│                   你的开发环境（OpenCode）                          │
│                          │                                       │
│                 ┌────────▼──────────┐                            │
│                 │   PuaSE 编排器     │                            │
│                 │  (全局编排 Agent)   │                            │
│                 └────────┬──────────┘                            │
│                          │                                       │
│        ┌─────────────────┬─────────────────┬──────────────────┐   │
│        │                 │                 │                  │   │
│ ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐│
│ │  Pre-Code   │  │  Execution  │  │  Post-Code  │  │    闭环     ││
│ │  前置分析    │  │   执行层     │  │  质量门禁   │  │  交付验收   ││
│ └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘│
│        │                │                │                │       │
│ ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐│
│ │ architect   │  │ developer/* │  │ security    │  │ KPI 卡      ││
│ │ explore     │  │ dba/*       │  │ code-review │  │ reflector   ││
│ │             │  │ documenter  │  │ quality     │  │             ││
│ └─────────────┘  └────────────┘  └─────────────┘  └─────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## 三层架构

| 层级 | Agent | 职责 |
|------|-------|------|
| **Pre-Code（前置分析）** | architect, architect-scan, explore | 写代码前完成架构摸底 |
| **Execution（执行层）** | developer/*, dba/*, general, documenter | 编码、数据库管理、文档编写 |
| **Post-Code（质量门禁）** | security-expert, code-reviewer, quality-inspector | 安全审计 → 代码审查 → 质量巡检 |
| **闭环（交付验收）** | KPI 验收卡, reflector | 验收结果归档 → 复盘总结 → 改进闭环 |

## 核心工作流

```
隐含需求解析 → 成熟度评估 → [架构分析] → [开发/DBA/文档] → [安全审计 | 代码审查 | 质量巡检] → 完成
```

## 使用方式

### 直接对话

```
帮我分析项目架构
开发一个新的 Java 功能
配置 MySQL 数据库
审计代码安全
```

### @ 引用

```
@PuaSE 帮我分析这个项目的架构和风险
```

详细使用指南（含 OpenCode 配置、Agent 定义、最佳实践）详见 [使用指南](opencode.md)。

## 安装指南

详见 [OpenCode 安装配置指南](opencode.md)。

## Agent 列表

| Agent | 职责 |
|-------|------|
| **PuaSE** | 全局编排 — 解析需求、评估成熟度、委派专家 |
| **architect** | 完整架构分析 — C4 模型、ADR、风险评估 |
| **architect-scan** | 轻量级架构扫描 — 3 步快速摸底 |
| **code-reviewer** | 代码审查 — 正确性、安全、性能、可维护性 |
| **go-developer** | Go 开发 — 编码、编译、测试验证 |
| **rust-developer** | Rust 开发 — 编码、编译、测试验证 |
| **csharp-developer** | C# 开发 — 编码、编译、测试验证 |
| **java-developer** | Java 开发 — 编码、编译、测试验证 |
| **python-developer** | Python 开发 — 编码、语法检查、测试验证 |
| **cpp-developer** | C/C++ 开发 — 编码、编译、测试验证 |
| **bigdata-developer** | 大数据开发 — Spark/Flink/Kafka/Hive/Airflow |
| **web-developer** | Web 前端开发 — 编码、构建、测试验证 |
| **mysql-dba** | MySQL 数据库管理 |
| **oracle-dba** | Oracle 数据库管理 |
| **security-expert** | 安全审计 — OWASP Top 10、CWE、内存安全 |
| **documenter** | 文档编写 — README、API 文档、设计文档 |
| **quality-inspector** | 质量巡检 — 所有子 Agent 交付检查 |
