// PuaSE Homepage — Entry point
console.log('PuaSE — 全局编排 Agent');

import i18n from './i18n.js';

// === Language Switching ===

let currentLang = localStorage.getItem('puase_lang') || 'zh';
let lastClickedAgent = null;

function switchLang(lang) {
  document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';

  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    const text = i18n[lang]?.[key];
    if (text !== undefined) el.textContent = text;
  });

  // 切换语言时直接设置文本，不播放打字机动画
  const subtitleEl = document.getElementById('hero-subtitle');
  const subtitleText = i18n[lang]?.['hero.subtitle'];
  if (subtitleEl && subtitleText) {
    subtitleEl.textContent = subtitleText;
  }

  // Update modal content if open
  if (agentModal.classList.contains('show') && lastClickedAgent) {
    const detail = agentDetails[currentLang]?.[lastClickedAgent] || agentDetails.zh[lastClickedAgent];
    if (detail) {
      modalBody.innerHTML = `<h3>${detail.name}</h3><p>${detail.desc}</p>`;
    }
  }

  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });

  localStorage.setItem('puase_lang', lang);
  currentLang = lang;
}

// Bind language toggle events
document.querySelectorAll('.lang-btn').forEach(btn => {
  btn.addEventListener('click', () => switchLang(btn.dataset.lang));
});

// === Typewriter Effect ===
const subtitleEl = document.getElementById('hero-subtitle');

function typeWriter(el, text, speed = 40) {
  let i = 0;
  el.textContent = '';
  function type() {
    if (i < text.length) {
      el.textContent += text.charAt(i);
      i++;
      setTimeout(type, speed);
    }
  }
  type();
}

// Typewriter is initialized by switchLang() below

// === Scroll Reveal Animation ===
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.15 });

document.querySelectorAll('.reveal, .reveal-left, .reveal-right').forEach(el => {
  revealObserver.observe(el);
});

// === Mobile Nav Toggle ===
const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.querySelector('.nav-links');

navToggle?.addEventListener('click', () => {
  navLinks?.classList.toggle('open');
});

document.querySelectorAll('.nav-links a').forEach(link => {
  link.addEventListener('click', () => {
    navLinks?.classList.remove('open');
  });
});

// === Agent Modal ===
const agentModal = document.getElementById('agent-modal');
const modalBody = document.getElementById('modal-body');
const modalClose = document.querySelector('.modal-close');

const agentDetails = {
  zh: {
    'architect': { name: 'architect', desc: '完整架构分析专家。负责 C4 模型建模、ADR 架构决策记录、风险评估、适应度函数分析。适用于新项目架构设计、大型模块首次分析、架构变更评审。' },
    'architect-scan': { name: 'architect-scan', desc: '轻量级架构扫描 Agent。3 步快速摸底：读目录结构、辨识模块依赖、标注核心数据流。适用于成熟代码库常规维护、小范围变更前的快速摸底。' },
    'explore': { name: 'explore', desc: '代码库探索与搜索专家。快速查找文件、搜索代码模式、理解代码结构。适用于需要理解不熟悉代码库时的快速摸底。' },
    'java-developer': { name: 'java-developer', desc: 'Java 软件开发 Agent。负责 Maven/Gradle 项目的功能开发和 Bug 修复，涵盖 Spring Boot / Jakarta EE 应用。每次修改后执行编译+测试验证。' },
    'python-developer': { name: 'python-developer', desc: 'Python 软件开发 Agent。负责 Django/Flask/FastAPI 等 Web 框架应用、数据处理脚本和自动化工具。每次修改后执行语法检查+测试验证。' },
    'go-developer': { name: 'go-developer', desc: 'Go 软件开发 Agent。负责 Go modules 项目的后端服务、CLI 工具和并发系统开发。每次修改后执行编译+测试验证（含 -race 检测）。' },
    'rust-developer': { name: 'rust-developer', desc: 'Rust 软件开发 Agent。负责 Cargo 项目的系统编程、CLI 工具和高性能并发服务。每次修改后执行编译+测试验证（含 clippy 检查）。' },
    'csharp-developer': { name: 'csharp-developer', desc: 'C# 软件开发 Agent。负责 .NET/C# 项目的 Web 应用（ASP.NET Core）、桌面应用和服务端开发。每次修改后执行编译+测试验证。' },
    'cpp-developer': { name: 'cpp-developer', desc: 'C/C++ 软件开发 Agent。负责 CMake/Makefile 项目的系统库、嵌入式软件和高性能计算模块。每次修改后执行编译+测试验证（0 error, 0 warning）。' },
    'bigdata-developer': { name: 'bigdata-developer', desc: '大数据开发 Agent。负责 Spark/Flink/Kafka/Hive/Airflow 等大数据处理代码。适用于数据管道、实时/离线计算、数据仓库 ETL。每次修改后执行编译+测试验证。' },
    'web-developer': { name: 'web-developer', desc: 'Web 前端开发 Agent。负责 HTML/CSS/JavaScript/TypeScript/React/Vue 前端代码。适用于 Web 界面开发、组件库构建和前端性能优化。每次修改后执行构建+测试验证。' },
    'mysql-dba': { name: 'mysql-dba', desc: 'MySQL 数据库管理专家。负责安装配置、性能调优、备份恢复、数据库安全审计、高可用/容灾方案设计。' },
    'oracle-dba': { name: 'oracle-dba', desc: 'Oracle 数据库管理专家。负责安装配置、性能调优、备份恢复、数据库安全审计、高可用/容灾（RAC/Data Guard）方案设计。' },
    'postgresql-dba': { name: 'postgresql-dba', desc: 'PostgreSQL 数据库管理专家。负责安装配置、性能调优、备份恢复、数据库安全审计、高可用/容灾（流复制/逻辑复制/Patroni）方案设计。' },
    'general': { name: 'general', desc: '通用多步任务 Agent。适用于需独立上下文运行的任务、长时间运行脚本、与当前会话无共享状态的批处理任务。' },
    'documenter': { name: 'documenter', desc: '文档编写与维护专家。负责 README、API 文档、设计文档、使用指南的生成和更新。适用于代码变更后同步更新文档。' },
    'security-expert': { name: 'security-expert', desc: '安全审计专家。开发者完成编码后强制执行安全审计。覆盖 OWASP Top 10、CWE、内存安全等 17 个安全维度。阻断性报告具有最高优先级。' },
    'code-reviewer': { name: 'code-reviewer', desc: '代码审查专家。聚焦代码逻辑正确性、安全性、性能和可维护性审查。适用于需要审查代码质量、设计评审、架构合规的场景。' },
    'quality-inspector': { name: 'quality-inspector', desc: '全链路质量巡检员。检查所有子 Agent 的交付结果：覆盖架构分析完整性、代码质量门禁、安全审计覆盖、DBA 运维合规、文档覆盖率。不合格一律打回重做。' },
    'reflector': { name: 'reflector', desc: '反思总结 Agent。任务完成后对 PuaSE 的委派链进行复盘分析，回顾委派得失、分析委派链效率、提炼改进策略，并将建议写入 .PuaSE/improvement-track.md。' }
  },
  en: {
    'architect': { name: 'architect', desc: 'Complete architecture analysis expert. Responsible for C4 modeling, ADR (Architecture Decision Records), risk assessment, and fitness function analysis. Ideal for new project architecture design, first-time large module analysis, and architecture change review.' },
    'architect-scan': { name: 'architect-scan', desc: 'Lightweight architecture scanning Agent. 3-step quick assessment: read directory structure, identify module dependencies, map core data flow. Suitable for routine maintenance of mature codebases and quick pre-change assessment.' },
    'explore': { name: 'explore', desc: 'Codebase exploration and search expert. Quickly find files, search code patterns, understand code structure. Ideal for rapid orientation when working with unfamiliar codebases.' },
    'java-developer': { name: 'java-developer', desc: 'Java software development Agent. Responsible for feature development and bug fixes in Maven/Gradle projects including Spring Boot / Jakarta EE apps. Runs compilation + tests after every change.' },
    'python-developer': { name: 'python-developer', desc: 'Python software development Agent. Handles Django/Flask/FastAPI web frameworks, data processing scripts, and automation tools. Runs syntax checks + tests after every change.' },
    'go-developer': { name: 'go-developer', desc: 'Go software development Agent. Handles backend services, CLI tools, and concurrent systems for Go module projects. Runs compilation + tests (with -race detection) after every change.' },
    'rust-developer': { name: 'rust-developer', desc: 'Rust software development Agent. Handles systems programming, CLI tools, and high-performance concurrent services for Cargo projects. Runs compilation + tests (with clippy checks) after every change.' },
    'csharp-developer': { name: 'csharp-developer', desc: 'C# software development Agent. Handles .NET/C# web apps (ASP.NET Core), desktop apps, and server development. Runs compilation + tests after every change.' },
    'cpp-developer': { name: 'cpp-developer', desc: 'C/C++ software development Agent. Handles system libraries, embedded software, and high-performance computing modules for CMake/Makefile projects. Runs compilation + tests (0 error, 0 warning) after every change.' },
    'bigdata-developer': { name: 'bigdata-developer', desc: 'Big data development Agent. Handles Spark/Flink/Kafka/Hive/Airflow data processing code. Suitable for data pipelines, real-time/batch processing, and data warehouse ETL. Runs compilation + tests after every change.' },
    'web-developer': { name: 'web-developer', desc: 'Web frontend development Agent. Handles HTML/CSS/JavaScript/TypeScript/React/Vue code. Suitable for web UI development, component library construction, and frontend performance optimization. Runs build + tests after every change.' },
    'mysql-dba': { name: 'mysql-dba', desc: 'MySQL database administration expert. Responsible for installation & configuration, performance tuning, backup & recovery, database security auditing, and high-availability/disaster recovery design.' },
    'oracle-dba': { name: 'oracle-dba', desc: 'Oracle database administration expert. Responsible for installation & configuration, performance tuning, backup & recovery, database security auditing, and high-availability/disaster recovery (RAC/Data Guard) design.' },
    'postgresql-dba': { name: 'postgresql-dba', desc: 'PostgreSQL database administration expert. Responsible for installation & configuration, performance tuning, backup & recovery, database security auditing, and high-availability/disaster recovery (streaming replication/logical replication/Patroni) design.' },
    'general': { name: 'general', desc: 'General-purpose multi-step task Agent. Suitable for tasks requiring isolated context, long-running scripts, and batch processing tasks with no shared state with the current session.' },
    'documenter': { name: 'documenter', desc: 'Documentation writing and maintenance expert. Responsible for generating and updating README, API docs, design docs, and usage guides. Ideal for syncing documentation after code changes.' },
    'security-expert': { name: 'security-expert', desc: 'Security audit expert. Enforces security audit after code completion. Covers OWASP Top 10, CWE, memory safety, and 17 security dimensions. Blocking reports have the highest priority.' },
    'code-reviewer': { name: 'code-reviewer', desc: 'Code review expert. Focuses on code correctness, security, performance, and maintainability. Suitable for code quality review, design review, and architecture compliance checks.' },
    'quality-inspector': { name: 'quality-inspector', desc: 'Full-chain quality inspector. Checks all sub-agent deliverables: architecture analysis completeness, code quality gates, security audit coverage, DBA compliance, and documentation coverage. Rejects any non-conforming delivery.' },
    'reflector': { name: 'reflector', desc: 'Retrospective analysis Agent. After task completion, reviews PuaSE\'s delegation chain — analyzing delegation decisions, identifying efficiency gaps, extracting improvement strategies, and writing recommendations to .PuaSE/improvement-track.md.' }
  }
};

document.querySelectorAll('.agent-card').forEach(card => {
  card.addEventListener('click', () => {
    const agentName = card.dataset.agent;
    lastClickedAgent = agentName;
    const detail = agentDetails[currentLang]?.[agentName] || agentDetails.zh[agentName] || { name: agentName, desc: 'No details available.' };
    modalBody.innerHTML = `<h3>${detail.name}</h3><p>${detail.desc}</p>`;
    agentModal.classList.add('show');
  });
});

modalClose.addEventListener('click', () => agentModal.classList.remove('show'));
agentModal.addEventListener('click', (e) => {
  if (e.target === agentModal) agentModal.classList.remove('show');
});

// === Hero Stats (Stars + Visits) ===
const STAR_CACHE_KEY = 'puase_star_cache';
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

function formatCount(num) {
  if (num >= 1000) return (num / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
  return String(num);
}

async function loadStarCount() {
  const starEl = document.getElementById('star-count');
  if (!starEl) return;

  // Check cache first
  try {
    const cached = localStorage.getItem(STAR_CACHE_KEY);
    if (cached) {
      const { count, timestamp } = JSON.parse(cached);
      if (Date.now() - timestamp < CACHE_TTL) {
        starEl.textContent = formatCount(count);
        return;
      }
    }
  } catch (_) {}

  try {
    const res = await fetch('https://api.github.com/repos/zeekling/PuaSE');
    if (!res.ok) throw new Error('GitHub API error');
    const data = await res.json();
    const count = data.stargazers_count || 0;
    starEl.textContent = formatCount(count);
    localStorage.setItem(STAR_CACHE_KEY, JSON.stringify({ count, timestamp: Date.now() }));
  } catch (_) {
    // Silent fallback — keep showing —
  }
}

async function loadVisitCount() {
  const visitEl = document.getElementById('visit-count');
  if (!visitEl) return;

  try {
    const res = await fetch('https://countapi.mileshilliard.com/api/v1/hit/PuaSE-visits');
    if (!res.ok) throw new Error('CountAPI error');
    const data = await res.json();
    if (data && data.value !== undefined) {
      visitEl.textContent = formatCount(data.value);
    }
  } catch (_) {
    // Silent fallback — keep showing —
  }
}

async function loadStats() {
  await Promise.allSettled([loadStarCount(), loadVisitCount()]);
}

loadStats();

// === Initialize language ===
switchLang(currentLang);
