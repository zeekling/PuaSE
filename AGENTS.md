# PuaSE 仓库规则

## 这是什么

本仓库是 OpenCode Agent **PuaSE**（全局编排 Agent）的配置镜像。

**唯一用途**：与 `~/.config/opencode/agents/PuaSE/` 双向同步，作为版本管理的参考副本。

## 目录结构

```
PuaSE.md           — 编排 Agent 主定义（frontmatter + 工作流说明）
subagent/
  architect.md     — 架构映射与分析 Agent
  code-reviewer.md — 代码审查 Agent
  java-developer.md— Java 开发 Agent
```

## 关键约定

- **所有文件均为 OpenCode Agent 配置**，使用 YAML frontmatter + Markdown 正文
- **frontmatter 字段必须保留**：`name`、`description`、`mode`（subagent 用 `mode: subagent`）、`model: inherit`
- **PuaSE.md 特有字段**：`permissions: any`、`run_in_background: true`、`subagents: [architect, code-reviewer, java-developer, explore, general]`
- **语言**：全部使用简体中文
- **无构建系统**：无 `package.json`、无测试、无 lint、无 CI — 不要寻找这些
- **`.gitignore` 忽略**：`.logs` 和 `.idea`

## 同步纪律

- 真实配置路径：`C:\Users\Administrator\.config\opencode\agents\PuaSE\`
- 修改仓库文件后，必须同步到真实配置路径（反之亦然）
- 使用 `git mv` 保留文件历史

## PuaSE 编排流程（核心工作流）

PuaSE 是编排器，处理任务时按以下顺序执行：

1. **隐含需求解析**（5 步法：捕获显式需求 → 推导隐含需求 → 识别约束 → 拆解任务 → 确定优先级）
2. **代码库成熟度评估**（初期/成长/成熟，自适应策略）
3. **架构先映射**（不读通架构不写代码）
4. **专家委派**（短链直接执行，长链委派 general，专业任务委派对应 Agent）
5. **结果综合**（依赖顺序合并 + 冲突检测 + 存在性校验）
6. **异常处理**（超时重试 1 次 → 降级自执行 → 循环委派检测 → 关键路径保护）

## 可用子 Agent

| Agent | 职责 | 触发场景 |
|-------|------|---------|
| architect | 架构映射 | 需理解项目结构/依赖/数据流 |
| code-reviewer | 代码审查 | 需审查代码质量/架构合规 |
| java-developer | Java 开发 | 需编码+编译+测试验证 |
| explore | 代码探索 | 需搜索/查找/理解代码 |
| general | 通用多步 | 独立上下文/long-running/批处理 |

## 权限模型

- PuaSE 及委派的子 Agent **默认拥有任何权限**（`permissions: any`），无需额外授权
- 委派不降权；最小权限仅在委派给第三方 Agent 时适用
