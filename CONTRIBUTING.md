# 贡献指南

欢迎为 PuaSE 项目贡献！本文档描述了参与贡献的流程和规范。

## 项目性质

PuaSE 是一个 OpenCode Agent 配置仓库，包含编排器（PuaSE）和多个子 Agent 的配置文件。**不含传统意义上的源代码**，无构建系统、无测试框架、无 CI 配置。

## 贡献流程

1. **Fork 本仓库** 并创建你的特性分支
2. **修改或新增 Agent 配置**（见下文规则）
3. **同步更新 `PuaSE.md` 的 `subagents:` 列表**（如新增或删除子 Agent）
4. **提交 Pull Request**，描述变更内容

## 安装方式更新

PuaSE 支持两种安装方式：

### npm 安装（推荐）

```bash
npm install @zeekling/puse
```

此方式自动将 PuaSE 插件注册到 OpenCode 配置目录，并安装所有必要的脚本和配置文件。安装完成后，重启 OpenCode 即可使用。

### 本地脚本安装（开发模式）

适用于需要在本地修改 Agent 配置并即时生效的场景：

```bash
# Linux/macOS
./PuaSE-install.sh --symlink

# Windows PowerShell
.\PuaSE-install.ps1 --symlink
```

> 本地脚本安装仅用于开发调试，生产环境推荐使用 npm 安装。

## Agent 配置规则

### 文件约定

- 所有 Agent 配置文件（`.md`）**必须包含 YAML frontmatter**
- frontmatter 字段包括：`name`、`description`、`permissions`，可选 `run_in_background`
- 不允许删除或重命名已有 frontmatter 字段
- 文件路径必须与 `PuaSE.md` 的 `subagents:` 列表一一对应

### 目录结构

```
subagent/
├── architect.md              # 架构分析
├── code-reviewer.md          # 代码审查
├── documenter.md             # 文档编写
├── quality-inspector.md      # 质量巡检
├── developer/
│   ├── cpp-developer.md
│   ├── java-developer.md
│   ├── python-developer.md
│   └── web-developer.md
├── dba/
│   ├── mysql-dba.md
│   └── oracle-dba.md
└── security/
    └── security-expert.md
```

> **注意**：`explore` 和 `general` 是 OpenCode 内置 Agent，无需也不应有配置文件。

### 新增子 Agent

1. 按目录层级创建对应的 `.md` 文件（含 YAML frontmatter）
2. 在 `PuaSE.md` 的 `subagents:` 列表中添加名称
3. 在 `PuaSE.md` 的 `experts:` 列表中添加触发规则
4. 更新 `README.md` 的项目结构图和 Agent 列表

### 语言要求

- **全文简体中文** — 所有 `description`、注释、说明都必须是中文
- 保持跨文件术语一致性（如 Agent 名称、职责描述）

### 权限

- `permissions: any` 表示该 Agent 拥有全部权限且委派不降权
- 如无特殊需求，统一使用 `permissions: any`

### 删除子 Agent

1. 删除对应 `.md` 文件
2. 从 `PuaSE.md` 的 `subagents:` 列表中移除
3. 从 `PuaSE.md` 的 `experts:` 列表中移除
4. 更新 `README.md`

## 文档更新

以下文件在变更后需要同步更新：

| 文件 | 更新时机 |
|------|---------|
| `PuaSE.md` | 新增/删除子 Agent、修改工作流 |
| `README.md` | 项目结构、Agent 列表、安装说明变更 |
| `AGENTS.md` | 仓库规则变更 |

## Pull Request 规范

- PR 标题清晰描述变更（如"新增 oracle-dba 子 Agent"）
- PR 描述中说明变更原因和影响范围
- 确保 `subagents:` 列表与实际文件一致
- 确保 `README.md` 中的项目结构图和 Agent 列表已同步更新

## 问题报告

如有问题或建议，请提交 GitHub Issue。
