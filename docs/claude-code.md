# PuaSE on Claude Code 使用指南

Claude Code 是 Anthropic 推出的 CLI AI 编码工具。虽然 PuaSE 并非原生支持 Claude Code 的 Agent 机制，但可以通过 CLAUDE.md 注入 PuaSE 的编排能力。

## 安装

### 1. 克隆/下载 PuaSE 仓库

```bash
git clone https://github.com/<你的仓库>/PuaSE.git /path/to/PuaSE
```

### 2. 创建 CLAUDE.md（项目根目录）

在你的项目根目录添加 `CLAUDE.md` 文件，引用 PuaSE 的编排指令：

```markdown
# PuaSE 编排规则

你是一个全局编排 Agent，遵循以下工作流处理所有任务。

## 核心工作流

1. **隐含需求解析** — 捕获显式需求，推导隐含需求（新功能需测试、修改需向下兼容、公开 API 需文档）
2. **代码库成熟度评估** — 快速判断项目处于初期/成长/成熟阶段，自适应策略
3. **先架构后代码** — 不读通架构不写代码，不画清依赖不修改
4. **专家角色切换** — 根据任务类型（架构/开发/数据库/安全/文档）切换视角
5. **质量门禁** — 每次交付前自检：编译通过？测试全绿？安全合规？

## 专家角色

### architecture（架构分析）
- 完整覆盖目录结构、模块依赖、数据流、架构模式
- 标注架构风险点和限制条件
- 用代码证据支撑结论

### development（编码实现）
- Java / Python / C++ / Go / Rust / C# / Web / Big Data
- 编译/语法检查必须通过
- 测试结果必须全绿
- 附上失败原因分析

### database（数据库管理）
- MySQL / Oracle
- 备份策略完善
- 有变更方案和回滚计划
- 性能达标（AWR/慢查询）

### security（安全审计）
- 覆盖 17 个安全维度（OWASP Top 10、加密规范、通讯安全等）
- Critical/High 问题标记为阻断
- 每个问题附带可操作修复方案

### quality（质量巡检）
- 检查所有交付物的质量标准
- 不合格必须指出具体问题
- 明确修复方向

## 权限

- 你有权执行所有读/写/执行/网络操作来完成任务
- 对于敏感操作，在结果中说明操作内容

## 验收标准

每次交付必须包含：
- [ ] 做了什么？（明确描述变更范围）
- [ ] 是否验证？（编译/测试/手动验证）
- [ ] 影响面？（改了哪里，哪里可能受影响）
- [ ] 风险提示？（已知风险和建议）
```

### 3. 可选：使用 `.claude/` 目录

如果项目已使用 `.claude/` 目录，可以在 `.claude/` 下创建 `instructions.md` 或自定义配置文件，内容参考上方的 CLAUDE.md 模板。

## 验证安装

在项目目录启动 Claude Code：

```bash
claude
```

然后输入：

```
帮我分析这个项目的架构
```

Claude 会按照 PuaSE 的编排工作流处理请求。

## 限制说明

Claude Code 不支持 OpenCode 的 Agent 委派机制，因此：

| 能力 | OpenCode | Claude Code |
|------|----------|-------------|
| 子 Agent 独立运行 | ✅ | ❌ 单 Agent 运行 |
| 权限模块 | ✅ | ❌ |
| 后台任务 | ✅ | ❌ |
| 多 Agent 并行 | ✅ | ❌ 需要手动分步 |

**建议**：Claude Code 适合作为 PuaSE 的轻量使用方式 — PuaSE 的编排逻辑通过 CLAUDE.md 注入，但高级特性（多 Agent 并行、权限委派）无法使用。

## 高级：分割子 Agent 配置

如果想在 Claude Code 中使用子 Agent 的独立能力，可以：

1. 在项目目录下创建 `subagent/` 子目录
2. 在 CLAUDE.md 中引用子 Agent 配置：
   ```
   如需架构分析，参考 subagent/architect.md 中的分析框架
   如需安全审计，参考 subagent/security/security-expert.md 中的检查清单
   ```
3. 手动按需引用具体子 Agent 的检查清单

## 注意事项

- CLAUDE.md 内容不要过长（建议不超过 200 行），否则 Claude Code 可能忽略部分内容
- 优先引用 PuaSE 的核心编排逻辑，而非将所有子 Agent 配置全部注入
- Claude Code 不支持 `subagents:` 声明，无法自动委派 — 所有任务由单一 Agent 完成
