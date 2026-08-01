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


## 安装

### 前置条件

- [OpenCode](https://opencode.ai) 已安装并配置

### 手动安装

将仓库中的 Agent 配置拷贝到 OpenCode 的 agents 目录：

```powershell
# Windows PowerShell
git clone https://github.com/zeekling/PuaSE.git
Copy-Item -Recurse -Force .\PuaSE\subagent, .\PuaSE\PuaSE.md, .\PuaSE\PuaSE-protocol.md "$env:USERPROFILE\.config\opencode\agents\PuaSE\"
```

```bash
# Linux/macOS
git clone https://github.com/zeekling/PuaSE.git
cp -r ./PuaSE/subagent ./PuaSE/PuaSE.md ./PuaSE/PuaSE-protocol.md ~/.config/opencode/agents/PuaSE/
```

重启 OpenCode 后即可使用 PuaSE 编排器及全部 16 个子 Agent。

### 配置 opencode.json

在 `opencode.json` 中注册 PuaSE 为主 Agent：

```json
"default_agent": "PuaSE"
```

使用时在对话中通过 `@PuaSE` 引用即可。

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
| KPI 卡里不写测试和检视结果 | **KPI 验收卡强制字段** — 🧪 测试验证 + 🔍 代码检视 + 📋 委派链记录 + 🔄 复盘反思必须填写 | 不填 = KPI 卡标记为"⏳ 门禁未过" |
| KPI 卡里不写委派链和复盘 | **委派链记录 + 复盘（条件触发）** — 委派链缺失原因必须说明，复盘仅当 subagent 被多次打回时触发 | 委派链缺失 = ⏳ 委派链不完整；复盘缺失（已触发但未完成）= P0 违规 |
| 用户说"这个很熟我自己改更快" | **反熟悉度偏误钩子** — 必须反问：涉及写文件？有子 Agent？不熟会委派？ | 三问任一为是 → 必须委派 |

### 核心防线（四道门禁）

```
① Pre-Code 门禁      ② Execution 门禁       ③ Post-Code 门禁       ④ KPI 出卡
┌──────────────┐     ┌────────────────┐     ┌──────────────────┐     ┌───────────┐
│ 架构分析通过？ │  →  │ 编译+测试通过？  │  →  │ 安全审计 + 代码   │  →  │ 🧪测试    │
│ 数据流走通了？ │     │ 影响面已确认？   │     │ 审查 + 质量巡检   │     │ 🔍检视    │
│ 依赖关系清晰？ │     │ 验证证据已贴出？ │     │ 三者全部通过？    │     │ 七者齐全  │
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
| **专家委派** | 将任务委派给 architect、code-reviewer、cpp-developer、csharp-developer、documenter、go-developer、java-developer、mysql-dba、oracle-dba、postgresql-dba、python-developer、rust-developer、security-expert、quality-inspector、web-developer、reflector 等专家 Agent（共 16 个） |
| **上下文隔离原则** | 所有专家任务在独立子 Agent 会话中执行，主上下文仅保留编排决策所需最小信息，避免专家工作日志污染编排层 |
| **技能编排优化** | 将执行类 Skill（如 brainstorming/TDD/调试）翻译为委派策略委派给对应 Agent，自身不执行技能中的"你来做"指令。编排者不做执行者的事 |
| **结果综合 · KPI 验收** | 多 Agent 结果按依赖顺序合并，冲突检测与仲裁。输出 KPI 验收卡（🧪 测试验证 + 🔍 代码检视 + 🛡️ 安全审计 + 📋 委派链记录 + 🔄 复盘反思）量化交付标准 |
| **Post-Code 默认并行验收** | 开发者返回结果后默认并行启动 code-reviewer + quality-inspector +（如适用）security-expert 三方验收，任一不通过即打回重做；全部通过后输出委派链记录 → 复盘（条件触发，多次打回时执行）→ KPI 验收卡（详见 PuaSE.md §4.1） |
| **KPI 卡强制生成钩子** | 子 Agent 返回后、声明完成前必须按序执行：并行验收 → 委派链记录 → 复盘（条件触发，仅多次打回时委派 reflector）→ KPI 卡。无 KPI 卡的完成声明视为 P0 流程违规（详见 PuaSE.md §4.2）；声明完成前必须在最后输出 security-expert 状态行（详见 PuaSE.md §4.2） |
| **Brainstorming → 实现过渡** | brainstorming 产出 spec 后自动判断是否加载 writing-plans（涉及文件数 ≤ 2 + 无新模块 + 无架构变更 可跳过），输出过渡决策理由，跳过 plan 不跳过验收（详见 PuaSE.md §7） |
| **异常处理** | 模型失败自动重试（指数退避）、Agent超时降级自执行、循环委派检测、关键路径保护 |
| **归因透明化** | 7个归因标签覆盖所有阶段，决策来源明确（手动/自动/fallback） |
| **循环委派检测** | 维护委派链（上限10跳），禁止循环模式，防止死循环 |

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
            │ architect       │          │ developer/*        │       │ security-expert     │       │ KPI 验收卡          │
             │                 │          │  ├─ java           │       │ code-reviewer       │       │ reflector           │
             │                 │          │  ├─ cpp            │       │                     │       │                     │
             │                 │          │  ├─ go             │       │                     │       │                     │
             │                 │          │  ├─ rust           │       │                     │       │                     │
             │                 │          │  ├─ csharp         │       │                     │       │                     │
             │                 │          │  └─ web            │       │                     │       │                     │
            │                 │          │                    │       │                     │       │                     │
            │                 │          │  dba/*             │       │                     │       │                     │
            │                 │          │  ├─ mysql          │       │                     │       │                     │
            │                 │          │  ├─ oracle         │       │                     │       │                     │
            │                 │          │  └─ postgresql     │       │                     │       │                     │
             │                 │          │                    │       │                     │       │                     │
             │                 │          │                    │       │                     │       │                     │
             │                 │          │  documenter        │       │                     │       │                     │
             └─────────────────┘          └────────────────────┘       └─────────────────────┘       └─────────────────────┘
```

**三层结构说明：**

| 层级 | 角色 | Agent | 核心职责 |
|------|------|-------|---------|
| **Pre-Code（前置分析）** | 在写任何代码前完成架构摸底 | architect | full 深度分析（C4/ADR/风险评估）或 quick 轻量扫描（3步快速摸底） |
| **Execution（执行层）** | 负责具体的编码、数据管理和文档产出 | developer/*, dba/*, documenter | 代码实现、数据库管理、文档编写，每次变更后立即验证 |
| **Post-Code（质量门禁）** | 执行安全审计、代码审查、质量巡检 | security-expert, code-reviewer, quality-inspector | 17维度安全审计、计划对齐与代码质量审查、交付物逐项检查（仅通过/打回）。KPI 卡包含 🧪 测试验证 + 🔍 代码检视 两个强制区域 |
| **闭环（交付验收）** | 验收结果归档、复盘总结、改进跟踪 | KPI 验收卡, reflector | KPI 卡量化验收（七条件：🧪+🔍+🛡️+📋+🔄+影响面+委派链）；复盘仅当 subagent 被多次打回时触发；委派链记录缺失原因须说明；改进跟踪至闭环 |

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
│ 委派链记录 [应委派的子 Agent 状态一览，跳过须注明原因]                │
│       ↓                                                              │
│ reflector  [复盘条件触发] — 仅当 subagent 被多次打回（≥2 次）时委派          │
│       ↓                                                              │
│ KPI 验收卡 [🧪+🔍+🛡️+📋+🔄+影响面+委派链 — 七条件齐全]               │
└──────────────────────────────────────────────────────────────────────┘
```

**核心机制：**

```
┌─ PuaSE 核心机制 ─────────────────────────────────────────────────┐
│ STEP 生命周期（P0-P6） │ 并行验收组（P3+P4+P5 三方并行）          │
│ 委派宣言 + 自执行归因  │ 反熟悉度偏误检测                        │
│ 循环委派保护（10跳）   │ 压力分级（L0-L4）+ 指数退避重试          │
└──────────────────────────────────────────────────────────────────────┘
```

**异常处理（L0-L4 压力分级，详见 PuaSE-protocol.md）：**
- 指数退避重试：1000ms → 2000ms → 4000ms（±10% jitter），最多 3 次
- 压力升级仅限**技术故障**；质量打回不升级，退回原开发者重做
- L1：同 Agent 同一任务连续 2 次技术故障 → 换 Agent 执行同类任务
- L2：同 Agent 连续 3 次技术故障 → 熔断该 Agent（5 分钟）+ 降级自执行
- L3：累积技术故障率 > 30%（最近 10 次）→ 标记低可靠，通知用户排查
- L4：所有 Agent 均故障 → 用户决策：降级功能 / 换技术栈 / 中止
- 循环委派保护：委派链上限 10 跳，禁止 A→B→A 循环模式，防止死循环

**KPI 验收标准（七者缺一不可 + 门禁强制序列）：**
> 1. ✅ 编译/测试/语法验证通过（输出验证证据）
> 2. ✅ code-reviewer 审查代码逻辑、架构合规、设计质量
> 3. ✅ quality-inspector 全链路质量巡检
> 4. ✅ security-expert 安全审计（敏感场景必须）
> 5. ✅ 影响面清单已确认
> 6. ✅ 委派链记录已输出——所有应委派的子 Agent 均已记录，跳过的有明确原因说明。应委派但跳过且无原因说明 → 标记为"⏳ 委派链不完整"
> 7. ✅ 复盘已完成（如触发）——仅当 subagent 被多次打回（≥2 次）时委派 reflector 完成反思总结并写入 `.PuaSE/improvement-track.md`；未触发则标记"默认跳过"
>
> **门禁执行顺序（§4.2 KPI 卡输出机制）：**
> 子 Agent 返回后 → 按 §4.1 并行启动 code-reviewer + quality-inspector +（如适用）security-expert
> → 全部通过后 → 输出委派链记录 → **reflector 复盘（条件触发，多次打回时执行）** → 输出 KPI 验收卡 → 声明完成。
> **任何声称"完成"但没有 KPI 卡的行为，均视为 P0 级流程违规。**
> **复盘（已触发但未完成）不得输出 KPI 卡。委派链缺失不得标记为通过。**

## 项目结构

项目目录树详见 [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)。

关键目录说明：
- **`.PuaSE/`** — 改进跟踪记录（`improvement-track.md`）

## Agent 列表

全部 16 个 Agent 详见 [docs/AGENT_LIST.md](docs/AGENT_LIST.md)。

## 使用示例

详见[docs/index.md](docs/index.md)


## 许可证

MIT
