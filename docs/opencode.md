# PuaSE on OpenCode 安装配置指南

OpenCode 是 PuaSE 的**一等公民平台** — PuaSE 本身就是为 OpenCode 设计的，享受最完整的 Agent 功能支持。

## 安装

### 1. 安装 PuaSE Agent

将本仓库的 Agent 配置安装到 OpenCode 的配置目录：

**macOS / Linux**

```bash
# 推荐：创建符号链接（同步更新，自动生效）
ln -sf "$PWD" "$HOME/.config/opencode/agents/PuaSE"

# 或手动复制（如需独立副本）
cp -r . "$HOME/.config/opencode/agents/PuaSE/"
```

**Windows（PowerShell）**

```powershell
# 推荐：创建目录联结（同步更新，自动生效）
New-Item -ItemType Junction -Path "$env:USERPROFILE\.config\opencode\agents\PuaSE" -Target "$pwd"

# 或手动复制（如需独立副本）
Copy-Item -Recurse -Path ".\*" -Destination "$env:USERPROFILE\.config\opencode\agents\PuaSE\"
```

### 2. 配置 opencode.json

在 OpenCode 配置目录（`~/.config/opencode/`）下找到或创建 `opencode.json`，添加 PuaSE Agent 注册信息：

```json
{
  "agent": {
    "PuaSE": {
      "description": "全局编排 Agent，解析隐含需求、评估代码库成熟度、委派给专家 Agent。适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。",
      "prompt": "C:\\Users\\<用户名>\\.config\\opencode\\agents\\PuaSE\\PuaSE.md",
      "permission": {
        "*": "allow"
      }
    }
  }
}
```

> **注意**：`prompt` 路径替换为实际路径。macOS/Linux 示例：`"/home/<用户名>/.config/opencode/agents/PuaSE/PuaSE.md"`。如果使用符号链接或目录联结，路径指向链接目标位置即可。

各字段说明：

| 字段 | 说明 |
|------|------|
| `PuaSE` | Agent 名称，在 OpenCode 中通过 `@PuaSE` 引用 |
| `description` | Agent 描述，OpenCode 用于自动匹配任务 |
| `prompt` | 指向 PuaSE.md 配置文件的路径（含 YAML frontmatter + 工作流定义） |
| `permission` | 权限配置，`"*": "allow"` 表示允许所有操作 |

配置完成后重启 OpenCode 即可生效。

### 3. 验证安装

在任意项目目录启动 OpenCode 会话：

```bash
opencode
```

PuaSE 会自动作为全局编排器可用。输入以下指令验证：

```
帮我分析这个项目的架构
```

如果返回架构分析任务，说明安装成功。

## OpenCode 独有特性

PuaSE 在 OpenCode 上拥有其他平台不具备的独有能力：

| 特性 | 说明 |
|------|------|
| **Agent 委派** | 通过 `subagents:` 列表直接委派任务给子 Agent，后台独立运行 |
| **权限模型** | `permissions: any` 赋予全权限，委派不降权 |
| **后台运行** | `run_in_background: true` 支持长时间后台任务 |
| **YAML frontmatter** | `PuaSE.md` 通过 frontmatter 声明 Agent 元信息 |
| **子 Agent 目录** | `subagent/` 目录组织所有子 Agent 配置，原生支持 |

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

OpenCode 会自动将任务路由到 PuaSE Agent。

## 注意事项

- 确保 `opencode.json` 中 `permission` 字段为 `"*": "allow"`，否则子 Agent 可能没有足够权限执行任务
- 使用符号链接/目录联结可以确保仓库更新同步到安装版
- 如果修改了 subagent 配置，无需重启 OpenCode，但修改 PuaSE.md 后需要重启
