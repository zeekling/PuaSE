# 项目结构

```
├── PuaSE.md                 # 全局编排 Agent（主入口）
├── AGENTS.md                # 仓库规则与约定
├── README.md                # 本文件
├── docs/PROJECT_STRUCTURE.md     # 项目结构说明
├── docs/AGENT_LIST.md       # Agent 列表
├── CONTRIBUTING.md          # 贡献指南（目录树过期，勿依赖）
├── LICENSE                  # MIT 许可证
├── .gitignore
├── .opencode/
│   └── rules/
│       └── puse-sync.md      # PuaSE.md 变更同步约束
├── .github/
│   ├── ISSUE_TEMPLATE/      # Issue 模板
│   └── workflows/
│       └── deploy.yml       # GitHub Pages 自动部署（push main → website/**）
├── docs/                    # 使用指南
│   ├── index.md             # PuaSE 使用指南
│   └── opencode.md          # OpenCode 安装配置指南
├── subagent/                # 子 Agent 定义
│   ├── architect-scan.md    # 轻量级架构扫描
│   ├── architect.md         # 架构分析
│   ├── code-reviewer.md     # 代码审查
│   ├── documenter.md        # 文档编写
│   ├── developer/
│   │   ├── cpp-developer.md     # C/C++ 开发
│   │   ├── csharp-developer.md  # C# 开发
│   │   ├── go-developer.md      # Go 开发
│   │   ├── java-developer.md    # Java 开发
│   │   ├── bigdata-developer.md # 大数据开发
│   │   ├── python-developer.md  # Python 开发
│   │   ├── rust-developer.md    # Rust 开发
│   │   └── web-developer.md     # Web 前端开发
│   ├── dba/
│   │   ├── mysql-dba.md        # MySQL 数据库管理
│   │   ├── oracle-dba.md       # Oracle 数据库管理
│   │   └── postgresql-dba.md   # PostgreSQL 数据库管理
│   ├── quality-inspector.md # 质量巡检
│   ├── reflector.md         # 反思总结
│   └── security/
│       └── security-expert.md # 安全审计
└── website/                 # Vite 静态官网（独立前端项目）
    ├── index.html           # 主页
    ├── src/
    │   ├── main.js          # 入口脚本
    │   └── style.css        # 样式
    ├── public/              # 静态资源
    ├── package.json         # npm dev / build / preview
    └── vite.config.js       # Vite 6 配置，base /PuaSE/
```
