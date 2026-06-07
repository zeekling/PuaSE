// PuaSE 主 Agent 定义（包含所有 19 个子 Agent）
const mainAgent = {
  name: "PuaSE",
  description: "全局编排 Agent，解析隐含需求、评估代码库成熟度。",
  permissions: "any",
  run_in_background: true,
  subagents: [
    "architect",
    "architect-scan",
    "code-reviewer",
    "go-developer",
    "rust-developer",
    "csharp-developer",
    "java-developer",
    "python-developer",
    "cpp-developer",
    "bigdata-developer",
    "web-developer",
    "oracle-dba",
    "mysql-dba",
    "postgresql-dba",
    "security-expert",
    "quality-inspector",
    "documenter",
    "reflector",
    "explore"
  ]
};

module.exports = mainAgent;
