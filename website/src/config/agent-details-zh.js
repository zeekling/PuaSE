// Agent details configuration (zh)
// Used by main.js for modal content
export const agentDetailsZh = {
  'architect': { name: 'architect', desc: '架构分析专家。full 模式：C4 模型、ADR、风险评估；quick 模式：3 步快速摸底。适用：新项目架构设计、首次分析、成熟库增量扫描。' },
  'java-developer': { name: 'java-developer', desc: 'Java 软件开发 Agent。负责 Maven/Gradle 项目的功能开发和 Bug 修复，涵盖 Spring Boot / Jakarta EE 应用。每次修改后执行编译+测试验证。' },
  'python-developer': { name: 'python-developer', desc: 'Python 软件开发 Agent。负责 Django/Flask/FastAPI 等 Web 框架应用、数据处理脚本和自动化工具。每次修改后执行语法检查+测试验证。' },
  'go-developer': { name: 'go-developer', desc: 'Go 软件开发 Agent。负责 Go modules 项目的后端服务、CLI 工具和并发系统开发。每次修改后执行编译+测试验证（含 -race 检测）。' },
  'rust-developer': { name: 'rust-developer', desc: 'Rust 软件开发 Agent。负责 Cargo 项目的系统编程、CLI 工具和高性能并发服务。每次修改后执行编译+测试验证（含 clippy 检查）。' },
  'csharp-developer': { name: 'csharp-developer', desc: 'C# 软件开发 Agent。负责 .NET/C# 项目的 Web 应用（ASP.NET Core）、桌面应用和服务端开发。每次修改后执行编译+测试验证。' },
  'cpp-developer': { name: 'cpp-developer', desc: 'C/C++ 软件开发 Agent。负责 CMake/Makefile 项目的系统库、嵌入式软件和高性能计算模块。每次修改后执行编译+测试验证（0 error, 0 warning）。' },
  'web-developer': { name: 'web-developer', desc: 'Web 前端开发 Agent。负责 HTML/CSS/JavaScript/TypeScript/React/Vue 前端代码。适用于 Web 界面开发、组件库构建和前端性能优化。每次修改后执行构建+测试验证。' },
  'mysql-dba': { name: 'mysql-dba', desc: 'MySQL 数据库管理专家。负责安装配置、性能调优、备份恢复、数据库安全审计、高可用/容灾方案设计。' },
  'oracle-dba': { name: 'oracle-dba', desc: 'Oracle 数据库管理专家。负责安装配置、性能调优、备份恢复、数据库安全审计、高可用/容灾（RAC/Data Guard）方案设计。' },
  'postgresql-dba': { name: 'postgresql-dba', desc: 'PostgreSQL 数据库管理专家。负责安装配置、性能调优、备份恢复、数据库安全审计、高可用/容灾（流复制/逻辑复制/Patroni）方案设计。' },
  'documenter': { name: 'documenter', desc: '文档编写与维护专家。负责 README、API 文档、设计文档、使用指南的生成和更新。适用于代码变更后同步更新文档。' },
  'security-expert': { name: 'security-expert', desc: '安全审计专家。开发者完成编码后强制执行安全审计。覆盖 OWASP Top 10、CWE、内存安全等 16 个安全维度。阻断性报告具有最高优先级。' },
  'code-reviewer': { name: 'code-reviewer', desc: '代码审查专家。聚焦代码逻辑正确性、安全性、性能和可维护性审查。适用于需要审查代码质量、设计评审、架构合规的场景。' },
  'quality-inspector': { name: 'quality-inspector', desc: '全链路质量巡检员。检查所有子 Agent 的交付结果：覆盖架构分析完整性、代码质量门禁、安全审计覆盖、DBA 运维合规、文档覆盖率。不合格一律打回重做。' },
  'reflector': { name: 'reflector', desc: '反思总结 Agent。任务完成后对 PuaSE 的委派链进行复盘分析，回顾委派得失、分析委派链效率、提炼改进策略，并将建议写入 .PuaSE/improvement-track.md。' }
};
