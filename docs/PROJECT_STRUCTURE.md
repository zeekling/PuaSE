# 项目结构

```
├── AGENTS.md                 # 仓库规则与约定（给 Agent 看的）
├── CONTRIBUTING.md            # 贡献指南（目录树过期，勿依赖文件列表）
├── LICENSE                    # MIT 许可证
├── README.md                  # 主 README（安装/设计/架构说明）
├── PuaSE.md                   # 全局编排 Agent 主配置（642 行，含 subagents: 列表）
├── .gitignore                 # 忽略：.logs .idea docs/specs docs/plans docs/superpowers docs/kpi/ node_modules/ dist/ .superpowers/ .PuaSE
├── .PuaSE/
│   └── improvement-track.md   # reflector 复盘时追加的改进跟踪清单（P0/P1/P2）
│
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── workflows/
│       ├── build.yml          # CI 构建检查：任意分支 push/PR 涉及 website/** 时 npm ci + build
│       └── deploy.yml         # CI 部署：push main + website/** → GitHub Pages
│
├── docs/                      # 用户文档
│   ├── AGENT_LIST.md          # 全部 Agent 列表与职责
│   ├── PROJECT_STRUCTURE.md   # 本文件
│   ├── index.md               # PuaSE 使用指南
│   └── blog/                  # 版本发布日志
│       ├── v0.2.4-release.md
│       └── v0.2.5-changelog.md
│
├── subagent/                  # 子 Agent 配置文件（19 个 .md）
│   ├── architect.md           # 架构分析（full 深度设计 / quick 轻量扫描）
│   ├── code-reviewer.md       # 代码审查
│   ├── documenter.md          # 文档编写
│   ├── explore.md             # 代码库探索
│   ├── quality-inspector.md   # 质量巡检
│   ├── reflector.md           # 复盘分析
│   ├── developer/             # 8 个语言开发者
│   │   ├── bigdata-developer.md
│   │   ├── cpp-developer.md
│   │   ├── csharp-developer.md
│   │   ├── go-developer.md
│   │   ├── java-developer.md
│   │   ├── python-developer.md
│   │   ├── rust-developer.md
│   │   └── web-developer.md
│   ├── dba/                   # 3 个数据库专家
│   │   ├── mysql-dba.md
│   │   ├── oracle-dba.md
│   │   └── postgresql-dba.md
│   └── security/
│       └── security-expert.md # 安全审计
│
└── website/                   # Vite 6 静态前端项目（独立构建+CI）
    ├── index.html             # 主页（含 i18n）
    ├── package.json           # dev / build / preview
    ├── vite.config.js         # base /PuaSE/，输出到 dist/
    ├── public/
    │   └── favicon.svg         # 站点图标
    └── src/
        ├── main.js
        ├── style.css
        └── i18n.js            # 国际化翻译
```
