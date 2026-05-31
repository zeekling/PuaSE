---
description: >-
  禁止未经用户允许提交本地代码（git commit / git push）。
  任何涉及 git commit 或 git push 的操作必须先获得用户明确授权。
globs: "*"
---

# 提交授权规则

## 核心约束

**AI Agent 不得未经用户明确允许，执行任何 git commit 或 git push 操作。**

## 规则详情

### 禁止行为

- 不得自行执行 `git commit`
- 不得自行执行 `git push`
- 不得自行执行 `git commit -a`
- 不得将 `git add` 和 `git commit` 串联执行

### 允许行为

以下操作无需用户额外授权：

- `git status` — 查看状态
- `git diff` — 查看变更
- `git log` — 查看历史
- `git add`（仅暂存，不提交）
- `git stash` — 暂存变更

### 授权方式

用户必须通过以下方式之一明确授权：

1. 直接说"提交代码"、"commit"、"推送"等明确指令
2. 在任务描述中明确要求提交
3. 对 AI 的提交意图确认"可以"、"同意"、"确认"

### 违反后果

未经授权的提交属于**P0 级流程违规**，等同于绕过用户控制，严重损害用户信任。
