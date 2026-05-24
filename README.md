# 简介

全局编排 Agent — 把 AI 编程流程化，阻止 AI 偷奸耍滑、欺骗人类。

解析隐含需求、评估代码库成熟度、委派给专家 Agent。适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。

<p align="center">
  <img src="https://img.shields.io/github/stars/zeekling/PuaSE?style=social" alt="GitHub stars" />
  <img src="https://img.shields.io/github/forks/zeekling/PuaSE?style=social" alt="GitHub forks" />
  <img src="https://img.shields.io/github/watchers/zeekling/PuaSE?style=social" alt="GitHub watchers" />
  <img src="https://github.com/zeekling/PuaSE/actions/workflows/build.yml/badge.svg" alt="Build Status" />
  <img src="https://img.shields.io/github/commit-activity/m/zeekling/PuaSE" alt="Commit Activity" />
  <img src="https://img.shields.io/github/last-commit/zeekling/PuaSE" alt="Last Commit" />
  <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fcountapi.mileshilliard.com%2Fapi%2Fv1%2Fget%2FPuaSE-visits&query=%24.value&label=visits&color=brightgreen" alt="Visits" />
  <img src="https://img.shields.io/github/release/zeekling/PuaSE" alt="Release" />
  <img src="https://img.shields.io/github/license/zeekling/PuaSE" alt="License" />
</p>

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
| **结果综合 · KPI 验收** | 多 Agent 结果按依赖顺序合并，冲突检测与仲裁。输出 KPI 验收卡（🧪 测试验证 + 🔍 代码检视 + 🛡️ 安全审计）量化交付标准 |
| **Post-Code 默认并行验收** | 开发者返回结果后默认并行启动 code-reviewer + quality-inspector +（如适用）security-expert 三方验收，任一不通过即打回重做；全部通过后由 reflector 复盘总结（详见 PuaSE.md §4.2） |
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
                    ┌─────────────────────────────┬──────────────────────────────┬──────────────────────────────┐
                    │                             │                              │                             │
           ┌────────┴────────┐          ┌─────────┴──────────┐       ┌──────────┴──────────┐       ┌──────────┴──────────┐
           │     Pre-Code    │          │     Execution      │       │     Post-Code       │       │       闭环          │
           │    （前置分析）  │          │    （执行层）       │       │    （质量门禁）      │       │     （交付验收）     │
           └────────┬────────┘          └─────────┬──────────┘       └──────────┬──────────┘       └──────────┬──────────┘
                    │                             │                             │                             │
           ┌────────┴────────┐          ┌─────────┴──────────┐       ┌──────────┴──────────┐       ┌──────────┴──────────┐
           │   architect     │          │   developer/*      │       │  security-expert    │       │  KPI 验收卡          │
           │   architect-scan│          │       ├─ java      │       │  code-reviewer      │       │  reflector           │
           │   explore       │          │       ├─ python    │       │  quality-inspector  │       │                     │
           │                 │          │       ├─ cpp       │       │                     │       │                     │
           │                 │          │       ├─ go        │       │                     │       │                     │
           │                 │          │       ├─ rust      │       │                     │       │                     │
           │                 │          │       ├─ csharp    │       │                     │       │                     │
           │                 │          │       ├─ bigdata   │       │                     │       │                     │
           │                 │          │       └─ web       │       │                     │       │                     │
           │                 │          │                    │       │                     │       │                     │
           │                 │          │   dba/*            │       │                     │       │                     │
           │                 │          │       ├─ mysql     │       │                     │       │                     │
           │                 │          │       └─ oracle    │       │                     │       │                     │
           │                 │          │                    │       │                     │       │                     │
           │                 │          │   general          │       │                     │       │                     │
           │                 │          │                    │       │                     │       │                     │
           │                 │          │   documenter       │       │                     │       │                     │
           └─────────────────┘          └────────────────────┘       └─────────────────────┘       └─────────────────────┘
```

**三层结构说明：**

| 层级 | 角色 | Agent | 核心职责 |
|------|------|-------|---------|
| **Pre-Code（前置分析）** | 在写任何代码前完成架构摸底 | architect, architect-scan, explore | 完整分析（C4/ADR/风险评估）或轻量扫描（3步快速摸底） |
| **Execution（执行层）** | 负责具体的编码、数据管理和文档产出 | developer/*, dba/*, general, documenter | 代码实现、数据库管理、文档编写，每次变更后立即验证 |
| **Post-Code（质量门禁）** | 执行安全审计、代码审查、质量巡检 | security-expert, code-reviewer, quality-inspector | 17维度安全审计、计划对齐与代码质量审查、交付物逐项检查（仅通过/打回）。KPI 卡包含 🧪 测试验证 + 🔍 代码检视 两个强制区域 |
| **闭环（交付验收）** | 验收结果归档、复盘总结、改进跟踪 | KPI 验收卡, reflector | KPI 卡量化验收；委派链 ≥ 2 跳或连续 3 次同类型任务后强制复盘；改进跟踪至闭环 |

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
│       ↓ 全部通过                                                      │
│ reflector [复盘总结] — 改进跟踪至闭环                                 │
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
> 6. ✅ reflector 复盘总结 — 委派链 ≥ 2 跳 或 连续 3 次同类任务后强制
>
> **门禁执行顺序（§6.4 KPI 卡强制生成钩子）：**
> 子 Agent 返回后 → 按 §4.2 并行启动 code-reviewer + quality-inspector +（如适用）security-expert
> → 全部通过后输出 KPI 验收卡 →（可选）reflector 复盘 → 声明完成。
> **任何声称"完成"但没有 KPI 卡的行为，均视为 P0 级流程违规。**

## 项目结构

项目目录树详见 [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)。

## Agent 列表

全部 20 个 Agent 详见 [docs/AGENT_LIST.md](docs/AGENT_LIST.md)。

## 安装

PuaSE 基于 OpenCode Agent 机制运行，[查看 OpenCode 安装配置指南](docs/opencode.md)。

## 使用示例

详见[docs/index.md](docs/index.md)

## 项目趋势

<p align="center">
  <a href="https://star-history.com/#zeekling/PuaSE&Date">
    <img src="https://api.star-history.com/svg?repos=zeekling/PuaSE&type=Date" alt="Star History Chart" width="600" />
  </a>
</p>

## 许可证

MIT
