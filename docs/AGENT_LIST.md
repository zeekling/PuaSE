# Agent 列表

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
| **postgresql-dba** | PostgreSQL 数据库管理 — 安装配置、性能调优、备份恢复、高可用 |
| **security-expert** | 安全审计 — 17 个安全维度覆盖 OWASP Top 10、CWE、内存安全等 |
| **documenter** | 文档编写 — README、API 文档、设计文档、使用指南 |
| **quality-inspector** | 质量巡检 — 检查 architect、security-expert、全部开发者（developer/*）、全部 DBA（dba/*）、documenter 交付物，不合格打回重做 |
| **explore** | OpenCode 内置 Agent — 代码库探索与信息收集，用于快速了解项目结构和文件内容 |
| **general** | OpenCode 内置 Agent — 通用任务执行，适用于不需要特定领域专家的一般性工作 |
| **reflector** | 反思总结 — 对 PuaSE 的委派行为进行复盘分析，委派链回顾、分析得失、提炼改进策略 |
