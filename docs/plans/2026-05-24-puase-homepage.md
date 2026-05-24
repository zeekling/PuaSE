# PuaSE 官网主页 — 实现计划

> **For agentic workers:** 推荐使用 web-developer 子 Agent 按任务逐项实现。步骤使用复选框（`- [ ]`）追踪进度。

**Goal:** 构建 PuaSE 项目的赛博PUA风格官网主页（单页滚动式），包含 8 个展示区块和交互动效。

**Architecture:** Vite 驱动的纯静态单页应用，原生 HTML/CSS/JS。所有区块在单个 `index.html` 中，样式和交互逻辑分别拆分到 `src/style.css` 和 `src/main.js`。零运行时依赖。

**Tech Stack:** Vite (vanilla-js), 原生 CSS (CSS Variables), 原生 JS (Canvas, IntersectionObserver)

**Spec Reference:** `docs/specs/2026-05-24-puase-homepage-design.md`

---

### Task 1: 项目脚手架搭建

**Files:**
- Create: `website/package.json`
- Create: `website/vite.config.js`
- Create: `website/index.html`（骨架）
- Create: `website/src/style.css`（空文件）
- Create: `website/src/main.js`（空文件）
- Create: `website/public/favicon.svg`

- [ ] **Step 1: 创建目录结构**

```bash
New-Item -ItemType Directory -Path "website\src" -Force
New-Item -ItemType Directory -Path "website\public" -Force
```

- [ ] **Step 2: 创建 package.json**

```json
{
  "name": "puase-homepage",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "devDependencies": {
    "vite": "^6.0.0"
  }
}
```

- [ ] **Step 3: 创建 vite.config.js**

```js
import { defineConfig } from 'vite'

export default defineConfig({
  root: '.',
  base: '/PuaSE/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  }
})
```

注意：`base: '/PuaSE/'` 是因为 GitHub Pages 部署时仓库名为 `PuaSE`，路径包含仓库名。如果部署到自定义域名需要改回 `'/'`。

- [ ] **Step 4: 创建 index.html 骨架**

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>PuaSE — 全局编排 Agent</title>
  <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;700&family=Fira+Code&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="/src/style.css" />
</head>
<body>
  <div id="app"></div>
  <script type="module" src="/src/main.js"></script>
</body>
</html>
```

- [ ] **Step 5: 创建 favicon.svg**

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="8" fill="#0a0a12"/>
  <text x="32" y="44" text-anchor="middle" fill="#00ff41" font-family="monospace" font-size="32" font-weight="bold">P</text>
</svg>
```

- [ ] **Step 6: 安装依赖并验证构建**

```bash
cd website
npm install
npx vite build
```

Expected: `dist/` 目录生成，包含 `index.html` 和 `assets/`。

---

### Task 2: 全局样式系统（CSS 变量 + 基础样式）

**Files:**
- Create: `website/src/style.css`

- [ ] **Step 1: 定义 CSS 变量和全局样式**

```css
/* === CSS Variables === */
:root {
  --bg-primary: #0a0a12;
  --bg-card: #12121f;
  --bg-elevated: #1a1a2e;
  --neon-green: #00ff41;
  --neon-red: #ff1744;
  --neon-blue: #00b0ff;
  --text-primary: #e8eaed;
  --text-secondary: #9aa0a6;
  --text-dim: #5f6368;
  --border-green: rgba(0, 255, 65, 0.2);
  --glow-green: 0 0 20px rgba(0, 255, 65, 0.4);
  --glow-red: 0 0 20px rgba(255, 23, 68, 0.4);
  --font-heading: 'JetBrains Mono', 'Space Grotesk', monospace;
  --font-body: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-code: 'Fira Code', monospace;
  --max-width: 1200px;
  --nav-height: 60px;
}

/* === Reset & Base === */
*, *::before, *::after {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
  scroll-padding-top: var(--nav-height);
}

body {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  font-family: var(--font-body);
  line-height: 1.6;
  overflow-x: hidden;
}

a {
  color: var(--neon-green);
  text-decoration: none;
  transition: color 0.3s;
}
a:hover {
  color: var(--neon-blue);
}

/* === Section Common === */
.section {
  padding: 100px 24px;
  max-width: var(--max-width);
  margin: 0 auto;
  position: relative;
}

.section-title {
  font-family: var(--font-heading);
  font-size: 2rem;
  text-align: center;
  margin-bottom: 60px;
  color: var(--neon-green);
  text-transform: uppercase;
  letter-spacing: 4px;
  position: relative;
}
.section-title::after {
  content: '';
  display: block;
  width: 60px;
  height: 2px;
  background: var(--neon-green);
  margin: 16px auto 0;
  box-shadow: var(--glow-green);
}

/* === Scroll Animation Classes === */
.reveal {
  opacity: 0;
  transform: translateY(40px);
  transition: opacity 0.8s ease, transform 0.8s ease;
}
.reveal.visible {
  opacity: 1;
  transform: translateY(0);
}
.reveal-left {
  opacity: 0;
  transform: translateX(-60px);
  transition: opacity 0.8s ease, transform 0.8s ease;
}
.reveal-left.visible {
  opacity: 1;
  transform: translateX(0);
}
.reveal-right {
  opacity: 0;
  transform: translateX(60px);
  transition: opacity 0.8s ease, transform 0.8s ease;
}
.reveal-right.visible {
  opacity: 1;
  transform: translateX(0);
}
```

- [ ] **Step 2: 验证构建**

```bash
cd website && npx vite build
```

Expected: Build succeeds with no errors.

---

### Task 3: Hero 区块（HTML + CSS）

**Files:**
- Modify: `website/index.html`
- Modify: `website/src/style.css`

- [ ] **Step 1: 在 index.html 的 `<div id="app"></div>` 中添加 Hero 区块的 HTML**

```html
<!-- Hero -->
<section id="hero" class="hero">
  <canvas id="matrix-canvas"></canvas>
  <div class="hero-content">
    <h1 class="hero-title">PuaSE</h1>
    <p class="hero-subtitle" id="hero-subtitle"></p>
    <p class="hero-desc">全局编排 Agent — 解析隐含需求 · 评估成熟度 · 委派专家 · 闭环交付</p>
    <div class="hero-actions">
      <a href="#architecture" class="btn btn-primary">▸ 了解架构</a>
      <a href="https://github.com/your-org/PuaSE" target="_blank" class="btn btn-secondary">★ GitHub</a>
    </div>
    <div class="hero-scroll-indicator">▼ 滚动探索</div>
  </div>
</section>
```

- [ ] **Step 2: 在 style.css 中添加 Hero 样式**

```css
/* === Hero Section === */
.hero {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

#matrix-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  opacity: 0.6;
}

.hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
  padding: 24px;
}

.hero-title {
  font-family: var(--font-heading);
  font-size: clamp(3.5rem, 12vw, 8rem);
  font-weight: 700;
  color: var(--neon-green);
  text-shadow: 0 0 40px rgba(0, 255, 65, 0.6), 0 0 80px rgba(0, 255, 65, 0.3);
  animation: neonPulse 2s ease-in-out infinite alternate;
  letter-spacing: 8px;
  margin-bottom: 20px;
}

@keyframes neonPulse {
  from { text-shadow: 0 0 40px rgba(0, 255, 65, 0.6), 0 0 80px rgba(0, 255, 65, 0.3); }
  to { text-shadow: 0 0 60px rgba(0, 255, 65, 0.8), 0 0 120px rgba(0, 255, 65, 0.4), 0 0 200px rgba(0, 255, 65, 0.2); }
}

.hero-subtitle {
  font-family: var(--font-code);
  font-size: clamp(1rem, 2.5vw, 1.5rem);
  color: var(--text-secondary);
  min-height: 2em;
  margin-bottom: 16px;
}

.hero-subtitle::before {
  content: '$ ';
  color: var(--neon-green);
}

.hero-desc {
  font-size: clamp(0.9rem, 1.8vw, 1.15rem);
  color: var(--text-secondary);
  margin-bottom: 40px;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
  line-height: 1.8;
}

.hero-actions {
  display: flex;
  gap: 20px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 14px 32px;
  border-radius: 4px;
  font-family: var(--font-heading);
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.btn-primary {
  background: var(--neon-green);
  color: var(--bg-primary);
  border-color: var(--neon-green);
  box-shadow: var(--glow-green);
}
.btn-primary:hover {
  background: transparent;
  color: var(--neon-green);
  box-shadow: 0 0 30px rgba(0, 255, 65, 0.6);
}

.btn-secondary {
  background: transparent;
  color: var(--neon-green);
  border-color: var(--border-green);
}
.btn-secondary:hover {
  border-color: var(--neon-green);
  box-shadow: var(--glow-green);
}

.hero-scroll-indicator {
  position: absolute;
  bottom: 30px;
  left: 50%;
  transform: translateX(-50%);
  font-family: var(--font-heading);
  font-size: 0.8rem;
  color: var(--text-dim);
  animation: bounce 2s infinite;
  letter-spacing: 2px;
}

@keyframes bounce {
  0%, 100% { transform: translateX(-50%) translateY(0); }
  50% { transform: translateX(-50%) translateY(8px); }
}
```

- [ ] **Step 3: 验证构建**

```bash
cd website && npx vite build
```

Expected: Build succeeds.

---

### Task 4: Canvas 数字雨动画

**Files:**
- Modify: `website/src/main.js`

- [ ] **Step 1: 在 main.js 中添加数字雨 Canvas 动画**

```js
// === Matrix Digital Rain ===
const canvas = document.getElementById('matrix-canvas');
const ctx = canvas.getContext('2d');

let width, height, columns, drops;

function initMatrix() {
  width = canvas.width = canvas.offsetWidth;
  height = canvas.height = canvas.offsetHeight;
  columns = Math.floor(width / 16);
  drops = Array.from({ length: columns }, () => Math.floor(Math.random() * -100));
}

const chars = 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789ABCDEF<>/{}[]|&^%$#@!';

function drawMatrix() {
  ctx.fillStyle = 'rgba(10, 10, 18, 0.05)';
  ctx.fillRect(0, 0, width, height);

  ctx.font = '14px monospace';

  for (let i = 0; i < drops.length; i++) {
    const char = chars[Math.floor(Math.random() * chars.length)];
    const x = i * 16;
    const y = drops[i] * 16;

    // Bright leading character
    ctx.fillStyle = '#00ff41';
    ctx.fillText(char, x, y);

    // Dim trailing characters
    for (let j = 1; j <= 4; j++) {
      const trailY = y - j * 16;
      if (trailY > 0) {
        ctx.fillStyle = `rgba(0, 255, 65, ${0.2 - j * 0.04})`;
        const trailChar = chars[Math.floor(Math.random() * chars.length)];
        ctx.fillText(trailChar, x, trailY);
      }
    }

    if (drops[i] * 16 > height && Math.random() > 0.975) {
      drops[i] = 0;
    }
    drops[i]++;
  }

  requestAnimationFrame(drawMatrix);
}

initMatrix();
window.addEventListener('resize', initMatrix);
drawMatrix();
```

- [ ] **Step 2: 添加打字机效果脚本**

```js
// === Typewriter Effect ===
const subtitleEl = document.getElementById('hero-subtitle');
const text = '全局编排 Agent — 解析隐含需求 · 评估成熟度 · 委派专家 · 闭环交付';

function typeWriter(el, text, speed = 50) {
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

// Start typewriter after page loads
setTimeout(() => typeWriter(subtitleEl, text, 40), 500);
```

- [ ] **Step 3: 添加 IntersectionObserver 滚动动画**

```js
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
```

- [ ] **Step 4: 验证构建**

```bash
cd website && npx vite build
```

Expected: Build succeeds.

---

### Task 5: 区块 2-3（PuaSE 是什么 + 三层架构）

**Files:**
- Modify: `website/index.html`
- Modify: `website/src/style.css`

- [ ] **Step 1: 在 index.html 中添加区块 2（PuaSE 是什么）**

```html
<!-- What is PuaSE -->
<section id="about" class="section">
  <h2 class="section-title reveal">PuaSE 是什么</h2>
  <div class="flow-cards">
    <div class="flow-card reveal">
      <div class="flow-icon">📋</div>
      <h3>解析需求</h3>
      <p>捕获显式需求 → 推导隐含需求 → 识别约束 → 拆解任务 → 确定优先级</p>
    </div>
    <div class="flow-arrow reveal">→</div>
    <div class="flow-card reveal">
      <div class="flow-icon">🤖</div>
      <h3>委派专家</h3>
      <p>根据任务类型选择最合适的专家 Agent，传递完整上下文，注入行为协议</p>
    </div>
    <div class="flow-arrow reveal">→</div>
    <div class="flow-card reveal">
      <div class="flow-icon">✅</div>
      <h3>闭环交付</h3>
      <p>安全审计 + 代码审查 + 质量巡检并行验收，KPI 卡量化交付标准</p>
    </div>
  </div>
</section>
```

- [ ] **Step 2: 添加区块 2 CSS**

```css
/* === Flow Cards === */
.flow-cards {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  flex-wrap: wrap;
}

.flow-card {
  flex: 1;
  min-width: 220px;
  max-width: 320px;
  background: var(--bg-card);
  border: 1px solid var(--border-green);
  border-radius: 8px;
  padding: 32px 24px;
  text-align: center;
  transition: all 0.3s ease;
}
.flow-card:hover {
  border-color: var(--neon-green);
  box-shadow: var(--glow-green);
  transform: translateY(-4px);
}

.flow-icon {
  font-size: 2.5rem;
  margin-bottom: 16px;
}

.flow-card h3 {
  font-family: var(--font-heading);
  font-size: 1.2rem;
  color: var(--neon-green);
  margin-bottom: 12px;
}

.flow-card p {
  font-size: 0.9rem;
  color: var(--text-secondary);
  line-height: 1.7;
}

.flow-arrow {
  font-size: 2rem;
  color: var(--neon-green);
  font-family: var(--font-heading);
  opacity: 0.6;
  animation: arrowPulse 1.5s ease-in-out infinite;
}

@keyframes arrowPulse {
  0%, 100% { opacity: 0.6; transform: translateX(0); }
  50% { opacity: 1; transform: translateX(4px); }
}
```

- [ ] **Step 3: 添加区块 3 HTML（三层架构）**

```html
<!-- Architecture -->
<section id="architecture" class="section">
  <h2 class="section-title reveal">系统架构</h2>

  <div class="arch-container reveal">
    <!-- Top: PuaSE Orchestrator -->
    <div class="arch-layer arch-orchestrator" data-layer="orchestrator">
      <div class="arch-layer-header">
        <span class="arch-icon">⚙</span>
        <span>PuaSE</span>
        <span class="arch-badge">全局编排器</span>
      </div>
      <div class="arch-layer-desc">解析需求 → 评估成熟度 → 委派专家 → 综合验收</div>
    </div>

    <!-- Arrows down -->
    <div class="arch-connector">│<br/>│ 委派 │<br/>│</div>

    <!-- Three columns -->
    <div class="arch-columns">
      <div class="arch-layer arch-precode" data-layer="precode">
        <div class="arch-layer-header">
          <span class="arch-icon">🔍</span>
          <span>Pre-Code</span>
          <span class="arch-badge">前置分析</span>
        </div>
        <ul class="arch-agents">
          <li>architect</li>
          <li>architect-scan</li>
          <li>explore</li>
        </ul>
      </div>

      <div class="arch-layer arch-exec" data-layer="exec">
        <div class="arch-layer-header">
          <span class="arch-icon">💻</span>
          <span>Execution</span>
          <span class="arch-badge">执行层</span>
        </div>
        <ul class="arch-agents">
          <li>java-developer · python-developer</li>
          <li>go-developer · rust-developer</li>
          <li>csharp-developer · cpp-developer</li>
          <li>bigdata-developer · web-developer</li>
          <li>mysql-dba · oracle-dba</li>
          <li>general · documenter</li>
        </ul>
      </div>

      <div class="arch-layer arch-postcode" data-layer="postcode">
        <div class="arch-layer-header">
          <span class="arch-icon">🛡</span>
          <span>Post-Code</span>
          <span class="arch-badge">质量门禁</span>
        </div>
        <ul class="arch-agents">
          <li>security-expert</li>
          <li>code-reviewer</li>
          <li>quality-inspector</li>
        </ul>
      </div>
    </div>
  </div>
</section>
```

- [ ] **Step 4: 添加区块 3 CSS**

```css
/* === Architecture === */
.arch-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.arch-layer {
  border-radius: 8px;
  padding: 24px;
  text-align: center;
  transition: all 0.3s ease;
  cursor: default;
}

.arch-orchestrator {
  background: linear-gradient(135deg, rgba(0, 255, 65, 0.1), rgba(0, 176, 255, 0.05));
  border: 1px solid var(--neon-green);
  min-width: 400px;
  max-width: 600px;
}
.arch-orchestrator:hover {
  box-shadow: var(--glow-green);
}

.arch-layer-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 12px;
}
.arch-layer-header span {
  font-family: var(--font-heading);
  font-size: 1.3rem;
}
.arch-icon { font-size: 1.5rem; }

.arch-badge {
  font-size: 0.7rem !important;
  padding: 2px 10px;
  border-radius: 10px;
  background: rgba(0, 255, 65, 0.15);
  border: 1px solid rgba(0, 255, 65, 0.3);
}

.arch-layer-desc {
  font-size: 0.85rem;
  color: var(--text-secondary);
  font-family: var(--font-code);
}

.arch-connector {
  font-family: var(--font-heading);
  font-size: 0.75rem;
  color: var(--text-dim);
  text-align: center;
  line-height: 1.8;
}

.arch-columns {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: center;
}

.arch-precode {
  background: linear-gradient(135deg, rgba(0, 176, 255, 0.1), rgba(0, 176, 255, 0.02));
  border: 1px solid rgba(0, 176, 255, 0.3);
  min-width: 200px;
}
.arch-precode:hover { box-shadow: 0 0 20px rgba(0, 176, 255, 0.3); }
.arch-precode .arch-badge {
  background: rgba(0, 176, 255, 0.15);
  border-color: rgba(0, 176, 255, 0.3);
}

.arch-exec {
  background: linear-gradient(135deg, rgba(0, 255, 65, 0.08), rgba(0, 255, 65, 0.02));
  border: 1px solid rgba(0, 255, 65, 0.25);
  min-width: 340px;
  flex: 1.5;
}
.arch-exec:hover { box-shadow: var(--glow-green); }

.arch-postcode {
  background: linear-gradient(135deg, rgba(255, 23, 68, 0.1), rgba(255, 23, 68, 0.02));
  border: 1px solid rgba(255, 23, 68, 0.3);
  min-width: 200px;
}
.arch-postcode:hover { box-shadow: var(--glow-red); }
.arch-postcode .arch-badge {
  background: rgba(255, 23, 68, 0.15);
  border-color: rgba(255, 23, 68, 0.3);
}

.arch-agents {
  list-style: none;
  margin-top: 12px;
}
.arch-agents li {
  font-family: var(--font-code);
  font-size: 0.82rem;
  color: var(--text-secondary);
  padding: 4px 0;
  line-height: 1.6;
}
```

- [ ] **Step 5: 验证构建**

```bash
cd website && npx vite build
```

Expected: Build succeeds.

---

### Task 6: 区块 4（Agent 矩阵 + 模态弹窗）

**Files:**
- Modify: `website/index.html`
- Modify: `website/src/style.css`
- Modify: `website/src/main.js`

- [ ] **Step 1: 在 index.html 中添加 Agent 矩阵区块**

```html
<!-- Agents -->
<section id="agents" class="section">
  <h2 class="section-title reveal">18 个子 Agent</h2>
  <p class="section-desc reveal">三层架构，各司其职 — 点击卡片查看详情</p>

  <div class="agents-grid">
    <!-- Pre-Code Agents -->
    <div class="agent-group reveal">
      <h3 class="agent-group-label">🔍 Pre-Code <span>前置分析</span></h3>
      <div class="agent-cards" data-category="precode">
        <div class="agent-card" data-agent="architect">
          <div class="agent-emoji">🏗️</div>
          <div class="agent-name">architect</div>
          <div class="agent-desc">完整架构分析</div>
        </div>
        <div class="agent-card" data-agent="architect-scan">
          <div class="agent-emoji">🔎</div>
          <div class="agent-name">architect-scan</div>
          <div class="agent-desc">轻量级架构扫描</div>
        </div>
        <div class="agent-card" data-agent="explore">
          <div class="agent-emoji">📂</div>
          <div class="agent-name">explore</div>
          <div class="agent-desc">代码库探索</div>
        </div>
      </div>
    </div>

    <!-- Execution Agents -->
    <div class="agent-group reveal">
      <h3 class="agent-group-label">💻 Execution <span>执行层</span></h3>
      <div class="agent-cards" data-category="exec">
        <div class="agent-card" data-agent="java-developer"><div class="agent-emoji">☕</div><div class="agent-name">java-developer</div><div class="agent-desc">Java 开发</div></div>
        <div class="agent-card" data-agent="python-developer"><div class="agent-emoji">🐍</div><div class="agent-name">python-developer</div><div class="agent-desc">Python 开发</div></div>
        <div class="agent-card" data-agent="go-developer"><div class="agent-emoji">🔵</div><div class="agent-name">go-developer</div><div class="agent-desc">Go 开发</div></div>
        <div class="agent-card" data-agent="rust-developer"><div class="agent-emoji">🦀</div><div class="agent-name">rust-developer</div><div class="agent-desc">Rust 开发</div></div>
        <div class="agent-card" data-agent="csharp-developer"><div class="agent-emoji">#️⃣</div><div class="agent-name">csharp-developer</div><div class="agent-desc">C# 开发</div></div>
        <div class="agent-card" data-agent="cpp-developer"><div class="agent-emoji">⚡</div><div class="agent-name">cpp-developer</div><div class="agent-desc">C/C++ 开发</div></div>
        <div class="agent-card" data-agent="bigdata-developer"><div class="agent-emoji">📊</div><div class="agent-name">bigdata-developer</div><div class="agent-desc">大数据开发</div></div>
        <div class="agent-card" data-agent="web-developer"><div class="agent-emoji">🌐</div><div class="agent-name">web-developer</div><div class="agent-desc">Web 前端开发</div></div>
        <div class="agent-card" data-agent="mysql-dba"><div class="agent-emoji">🗄️</div><div class="agent-name">mysql-dba</div><div class="agent-desc">MySQL 管理</div></div>
        <div class="agent-card" data-agent="oracle-dba"><div class="agent-emoji">🏛️</div><div class="agent-name">oracle-dba</div><div class="agent-desc">Oracle 管理</div></div>
        <div class="agent-card" data-agent="general"><div class="agent-emoji">🔧</div><div class="agent-name">general</div><div class="agent-desc">通用任务</div></div>
        <div class="agent-card" data-agent="documenter"><div class="agent-emoji">📝</div><div class="agent-name">documenter</div><div class="agent-desc">文档编写</div></div>
      </div>
    </div>

    <!-- Post-Code Agents -->
    <div class="agent-group reveal">
      <h3 class="agent-group-label">🛡️ Post-Code <span>质量门禁</span></h3>
      <div class="agent-cards" data-category="postcode">
        <div class="agent-card" data-agent="security-expert">
          <div class="agent-emoji">🔒</div>
          <div class="agent-name">security-expert</div>
          <div class="agent-desc">安全审计</div>
        </div>
        <div class="agent-card" data-agent="code-reviewer">
          <div class="agent-emoji">👁️</div>
          <div class="agent-name">code-reviewer</div>
          <div class="agent-desc">代码审查</div>
        </div>
        <div class="agent-card" data-agent="quality-inspector">
          <div class="agent-emoji">✅</div>
          <div class="agent-name">quality-inspector</div>
          <div class="agent-desc">质量巡检</div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Agent Detail Modal -->
<div id="agent-modal" class="modal">
  <div class="modal-content">
    <span class="modal-close">&times;</span>
    <div id="modal-body"></div>
  </div>
</div>
```

- [ ] **Step 2: 在 style.css 中添加 Agent 矩阵样式**

```css
/* === Section Desc === */
.section-desc {
  text-align: center;
  color: var(--text-secondary);
  margin-bottom: 40px;
  font-size: 0.95rem;
}

/* === Agent Groups === */
.agent-group {
  margin-bottom: 40px;
}

.agent-group-label {
  font-family: var(--font-heading);
  font-size: 1.1rem;
  color: var(--text-primary);
  margin-bottom: 16px;
  padding-left: 8px;
  border-left: 3px solid var(--neon-green);
}
.agent-group-label span {
  font-size: 0.8rem;
  color: var(--text-dim);
  font-weight: 400;
  margin-left: 8px;
}

.agent-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.agent-card {
  background: var(--bg-card);
  border: 1px solid var(--border-green);
  border-radius: 8px;
  padding: 16px;
  min-width: 140px;
  flex: 1;
  max-width: 180px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
}
.agent-card:hover {
  border-color: var(--neon-green);
  box-shadow: var(--glow-green);
  transform: translateY(-4px);
}

.agent-emoji {
  font-size: 1.8rem;
  margin-bottom: 8px;
}

.agent-name {
  font-family: var(--font-code);
  font-size: 0.85rem;
  color: var(--neon-green);
  margin-bottom: 4px;
  word-break: break-all;
}

.agent-desc {
  font-size: 0.75rem;
  color: var(--text-dim);
}

/* === Modal === */
.modal {
  display: none;
  position: fixed;
  z-index: 1000;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(4px);
  align-items: center;
  justify-content: center;
}
.modal.show {
  display: flex;
}

.modal-content {
  background: var(--bg-card);
  border: 1px solid var(--neon-green);
  border-radius: 12px;
  padding: 40px;
  max-width: 500px;
  width: 90%;
  position: relative;
  box-shadow: var(--glow-green);
}

.modal-close {
  position: absolute;
  top: 12px;
  right: 20px;
  font-size: 1.8rem;
  color: var(--text-dim);
  cursor: pointer;
  transition: color 0.3s;
}
.modal-close:hover {
  color: var(--neon-red);
}

#modal-body h3 {
  font-family: var(--font-heading);
  color: var(--neon-green);
  margin-bottom: 16px;
}
#modal-body p {
  color: var(--text-secondary);
  line-height: 1.8;
  margin-bottom: 8px;
}
```

- [ ] **Step 3: 在 main.js 中添加 Agent 模态弹窗逻辑**

```js
// === Agent Modal ===
const agentModal = document.getElementById('agent-modal');
const modalBody = document.getElementById('modal-body');
const modalClose = document.querySelector('.modal-close');

const agentDetails = {
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
  'general': { name: 'general', desc: '通用多步任务 Agent。适用于需独立上下文运行的任务、长时间运行脚本、与当前会话无共享状态的批处理任务。' },
  'documenter': { name: 'documenter', desc: '文档编写与维护专家。负责 README、API 文档、设计文档、使用指南的生成和更新。适用于代码变更后同步更新文档。' },
  'security-expert': { name: 'security-expert', desc: '安全审计专家。开发者完成编码后强制执行安全审计。覆盖 OWASP Top 10、CWE、内存安全等 17 个安全维度。阻断性报告具有最高优先级。' },
  'code-reviewer': { name: 'code-reviewer', desc: '代码审查专家。聚焦代码逻辑正确性、安全性、性能和可维护性审查。适用于需要审查代码质量、设计评审、架构合规的场景。' },
  'quality-inspector': { name: 'quality-inspector', desc: '全链路质量巡检员。检查所有子 Agent 的交付结果：覆盖架构分析完整性、代码质量门禁、安全审计覆盖、DBA 运维合规、文档覆盖率。不合格一律打回重做。' }
};

document.querySelectorAll('.agent-card').forEach(card => {
  card.addEventListener('click', () => {
    const agentName = card.dataset.agent;
    const detail = agentDetails[agentName] || { name: agentName, desc: '暂无详情数据。' };
    modalBody.innerHTML = `
      <h3>${detail.name}</h3>
      <p>${detail.desc}</p>
    `;
    agentModal.classList.add('show');
  });
});

modalClose.addEventListener('click', () => agentModal.classList.remove('show'));
agentModal.addEventListener('click', (e) => {
  if (e.target === agentModal) agentModal.classList.remove('show');
});
```

- [ ] **Step 4: 验证构建**

```bash
cd website && npx vite build
```

Expected: Build succeeds.

---

### Task 7: 区块 5-8（核心能力 · 使用示例 · 安装贡献 · Footer）

**Files:**
- Modify: `website/index.html`
- Modify: `website/src/style.css`
- Modify: `website/src/main.js`

- [ ] **Step 1: 添加区块 5（核心能力）HTML**

```html
<!-- Capabilities -->
<section id="capabilities" class="section">
  <h2 class="section-title reveal">核心能力</h2>
  <div class="caps-grid">
    <div class="cap-card reveal-left">
      <div class="cap-icon">🔍</div>
      <h3>隐含需求解析</h3>
      <p>5 步法：捕获显式需求 → 推导隐含需求 → 识别约束 → 拆解任务 → 确定优先级</p>
    </div>
    <div class="cap-card reveal-right">
      <div class="cap-icon">📊</div>
      <h3>代码库成熟度评估</h3>
      <p>快速判断项目处于初期/成长/成熟阶段，自动适配策略</p>
    </div>
    <div class="cap-card reveal-left">
      <div class="cap-icon">🏗️</div>
      <h3>先架构后代码</h3>
      <p>不读通架构不写代码，不画清依赖不修改。架构分析作为所有决策的上下文基础</p>
    </div>
    <div class="cap-card reveal-right">
      <div class="cap-icon">🔄</div>
      <h3>专家委派体系</h3>
      <p>18 位专家 Agent 覆盖架构、开发、DBA、安全、审查、巡检全链条</p>
    </div>
    <div class="cap-card reveal-left">
      <div class="cap-icon">📋</div>
      <h3>KPI 验收卡</h3>
      <p>没有 KPI 卡的交付叫自嗨。编译通过 + 质量过审 + 影响面确认，三者缺一不可</p>
    </div>
    <div class="cap-card reveal-right">
      <div class="cap-icon">⚡</div>
      <h3>异常处理 · 压力升级</h3>
      <p>指数退避重试、Agent 熔断降级、L0-L4 压力升级、关键路径保护</p>
    </div>
  </div>
</section>
```

- [ ] **Step 2: 添加区块 5 CSS**

```css
/* === Capabilities Grid === */
.caps-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.cap-card {
  background: var(--bg-card);
  border: 1px solid var(--border-green);
  border-radius: 8px;
  padding: 28px 24px;
  transition: all 0.3s ease;
}
.cap-card:hover {
  border-color: var(--neon-green);
  box-shadow: var(--glow-green);
}

.cap-icon {
  font-size: 2rem;
  margin-bottom: 12px;
}

.cap-card h3 {
  font-family: var(--font-heading);
  font-size: 1rem;
  color: var(--neon-green);
  margin-bottom: 8px;
}

.cap-card p {
  font-size: 0.85rem;
  color: var(--text-secondary);
  line-height: 1.7;
}
```

- [ ] **Step 3: 添加区块 6（使用示例 — 终端模拟）**

```html
<!-- Demo -->
<section id="demo" class="section">
  <h2 class="section-title reveal">快速上手</h2>
  <div class="terminal reveal">
    <div class="terminal-header">
      <span class="terminal-dot dot-red"></span>
      <span class="terminal-dot dot-yellow"></span>
      <span class="terminal-dot dot-green"></span>
      <span class="terminal-title">PuaSE — 终端</span>
    </div>
    <div class="terminal-body" id="terminal-body">
      <div class="terminal-line"><span class="prompt">$</span> <span class="cmd">@PuaSE 帮我分析项目架构</span></div>
      <div class="terminal-line output">→ 委派 architect 进行完整架构分析...</div>
      <div class="terminal-line output">  ├─ 目录结构 · 模块依赖 · 数据流</div>
      <div class="terminal-line output">  └─ C4 模型 · ADR · 风险评估 ✅</div>
      <div class="terminal-line"><span class="prompt">$</span> <span class="cmd">@PuaSE 开发一个新的 Java 功能</span></div>
      <div class="terminal-line output">→ 架构分析 → java-developer 编码</div>
      <div class="terminal-line output">→ security-expert 审计 ✅</div>
      <div class="terminal-line output">→ quality-inspector 巡检 ✅</div>
      <div class="terminal-line"><span class="prompt">$</span> <span class="cmd">@PuaSE 审计代码安全</span></div>
      <div class="terminal-line output">→ 委派 security-expert...</div>
      <div class="terminal-line output">  17 维度安全审计 · OWASP Top 10 · CWE</div>
      <div class="terminal-line output">  🟢 全部通过</div>
    </div>
  </div>
</section>
```

- [ ] **Step 4: 添加区块 6 CSS**

```css
/* === Terminal === */
.terminal {
  background: #0d0d1a;
  border: 1px solid var(--border-green);
  border-radius: 8px;
  overflow: hidden;
  max-width: 700px;
  margin: 0 auto;
  box-shadow: 0 0 30px rgba(0, 255, 65, 0.1);
}

.terminal-header {
  background: #1a1a2e;
  padding: 10px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid var(--border-green);
}

.terminal-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}
.dot-red { background: #ff5f56; }
.dot-yellow { background: #ffbd2e; }
.dot-green { background: #27c93f; }

.terminal-title {
  font-family: var(--font-code);
  font-size: 0.75rem;
  color: var(--text-dim);
  margin-left: 8px;
}

.terminal-body {
  padding: 20px;
  font-family: var(--font-code);
  font-size: 0.85rem;
  line-height: 1.9;
}

.terminal-line {
  white-space: pre-wrap;
  word-break: break-all;
}

.prompt {
  color: var(--neon-green);
}

.cmd {
  color: var(--text-primary);
}

.output {
  color: var(--text-secondary);
  padding-left: 12px;
}

.typing-cursor::after {
  content: '▊';
  color: var(--neon-green);
  animation: blink 0.8s step-end infinite;
}

@keyframes blink {
  50% { opacity: 0; }
}
```

- [ ] **Step 5: 添加区块 7（安装 & 贡献）HTML**

```html
<!-- Get Started -->
<section id="get-started" class="section">
  <h2 class="section-title reveal">快速开始</h2>
  <div class="started-grid">
    <div class="started-card reveal-left">
      <h3>📦 安装</h3>
      <p>PuaSE 基于 OpenCode Agent 机制运行。</p>
      <div class="code-block">git clone https://github.com/your-org/PuaSE.git</div>
      <p class="text-dim">克隆到 OpenCode agents 目录后重启即可使用</p>
      <a href="https://github.com/your-org/PuaSE" class="btn btn-secondary btn-sm">查看完整指南 →</a>
    </div>
    <div class="started-card reveal-right">
      <h3>🤝 贡献</h3>
      <p>欢迎为 PuaSE 贡献！流程简单透明：</p>
      <ol class="contrib-list">
        <li>Fork 本仓库</li>
        <li>修改或新增 Agent 配置</li>
        <li>同步更新 subagents: 列表</li>
        <li>提交 Pull Request</li>
      </ol>
      <a href="https://github.com/your-org/PuaSE/blob/main/CONTRIBUTING.md" class="btn btn-secondary btn-sm">查看贡献指南 →</a>
    </div>
  </div>
</section>
```

- [ ] **Step 6: 添加区块 7 CSS**

```css
/* === Get Started === */
.started-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.started-card {
  background: var(--bg-card);
  border: 1px solid var(--border-green);
  border-radius: 8px;
  padding: 32px;
}
.started-card:hover {
  border-color: var(--neon-green);
  box-shadow: var(--glow-green);
}

.started-card h3 {
  font-family: var(--font-heading);
  font-size: 1.2rem;
  color: var(--neon-green);
  margin-bottom: 16px;
}

.started-card p {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 16px;
}

.code-block {
  background: #0d0d1a;
  border: 1px solid var(--border-green);
  border-radius: 4px;
  padding: 12px 16px;
  font-family: var(--font-code);
  font-size: 0.85rem;
  color: var(--neon-green);
  margin-bottom: 12px;
  overflow-x: auto;
}

.text-dim {
  font-size: 0.8rem !important;
  color: var(--text-dim) !important;
}

.btn-sm {
  padding: 8px 20px;
  font-size: 0.85rem;
}

.contrib-list {
  padding-left: 20px;
  margin-bottom: 20px;
}
.contrib-list li {
  font-size: 0.9rem;
  color: var(--text-secondary);
  line-height: 2;
}
```

- [ ] **Step 7: 添加 Footer HTML 和 CSS**

```html
<!-- Footer -->
<footer class="footer">
  <div class="footer-quote">"没有验证的交付叫自嗨"</div>
  <div class="footer-links">
    <a href="https://github.com/your-org/PuaSE" target="_blank">GitHub</a>
    <a href="https://opencode.org" target="_blank">OpenCode</a>
    <a href="https://github.com/your-org/PuaSE/blob/main/AGENTS.md" target="_blank">AGENTS.md</a>
    <a href="https://github.com/your-org/PuaSE/blob/main/LICENSE" target="_blank">License</a>
  </div>
  <div class="footer-copy">PuaSE · MIT License</div>
  <div class="footer-pua">Built with ❤️ and PUA</div>
</footer>
```

```css
/* === Footer === */
.footer {
  text-align: center;
  padding: 60px 24px;
  border-top: 1px solid var(--border-green);
  margin-top: 40px;
}

.footer-quote {
  font-family: var(--font-heading);
  font-size: 1rem;
  color: var(--neon-green);
  margin-bottom: 24px;
  opacity: 0.8;
  font-style: italic;
}

.footer-links {
  display: flex;
  justify-content: center;
  gap: 24px;
  flex-wrap: wrap;
  margin-bottom: 24px;
}

.footer-links a {
  font-size: 0.85rem;
  color: var(--text-secondary);
  transition: color 0.3s;
}
.footer-links a:hover {
  color: var(--neon-green);
}

.footer-copy {
  font-size: 0.8rem;
  color: var(--text-dim);
  margin-bottom: 8px;
}

.footer-pua {
  font-family: var(--font-heading);
  font-size: 0.75rem;
  color: var(--neon-red);
  opacity: 0.5;
}
```

- [ ] **Step 8: 添加导航栏 HTML 和 CSS**

```html
<!-- Navigation -->
<nav class="nav">
  <div class="nav-inner">
    <a href="#hero" class="nav-logo">PuaSE</a>
    <div class="nav-links">
      <a href="#about">About</a>
      <a href="#architecture">Arch</a>
      <a href="#agents">Agents</a>
      <a href="#capabilities">能力</a>
      <a href="#demo">Demo</a>
      <a href="#get-started">开始</a>
    </div>
    <button class="nav-toggle" aria-label="Menu">☰</button>
  </div>
</nav>
```

```css
/* === Navigation === */
.nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(10, 10, 18, 0.9);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border-green);
  height: var(--nav-height);
}

.nav-inner {
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 24px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.nav-logo {
  font-family: var(--font-heading);
  font-size: 1.2rem;
  color: var(--neon-green) !important;
  text-shadow: 0 0 10px rgba(0, 255, 65, 0.3);
}

.nav-links {
  display: flex;
  gap: 20px;
}

.nav-links a {
  font-size: 0.85rem;
  color: var(--text-secondary) !important;
  transition: color 0.3s;
}
.nav-links a:hover {
  color: var(--neon-green) !important;
}

.nav-toggle {
  display: none;
  background: none;
  border: none;
  color: var(--text-primary);
  font-size: 1.5rem;
  cursor: pointer;
}

@media (max-width: 768px) {
  .nav-links {
    display: none;
    position: absolute;
    top: var(--nav-height);
    left: 0;
    right: 0;
    background: rgba(10, 10, 18, 0.98);
    flex-direction: column;
    padding: 20px 24px;
    border-bottom: 1px solid var(--border-green);
  }
  .nav-links.open {
    display: flex;
  }
  .nav-toggle {
    display: block;
  }
}
```

- [ ] **Step 9: 添加导航汉堡菜单 JS**

```js
// === Mobile Nav Toggle ===
const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.querySelector('.nav-links');

navToggle?.addEventListener('click', () => {
  navLinks.classList.toggle('open');
});

// Close nav on link click
document.querySelectorAll('.nav-links a').forEach(link => {
  link.addEventListener('click', () => {
    navLinks.classList.remove('open');
  });
});
```

- [ ] **Step 10: 验证构建**

```bash
cd website && npx vite build
```

Expected: Build succeeds with no errors.

---

### Task 8: 最终完善

**Files:**
- Modify: `website/src/style.css`
- Modify: `website/src/main.js`

- [ ] **Step 1: 添加全局响应式 CSS**

```css
/* === Responsive === */
@media (max-width: 768px) {
  .section {
    padding: 60px 16px;
  }
  .section-title {
    font-size: 1.5rem;
    margin-bottom: 40px;
  }
  .flow-cards {
    flex-direction: column;
  }
  .flow-arrow {
    transform: rotate(90deg);
  }
  .arch-columns {
    flex-direction: column;
    align-items: center;
  }
  .arch-orchestrator {
    min-width: unset;
    width: 100%;
  }
  .arch-precode, .arch-postcode {
    min-width: unset;
    width: 100%;
  }
  .arch-exec {
    min-width: unset;
    width: 100%;
  }
  .caps-grid {
    grid-template-columns: 1fr;
  }
  .agent-card {
    max-width: none;
    flex: 1 1 calc(50% - 12px);
    min-width: 100px;
  }
  .started-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .agent-card {
    flex: 1 1 100%;
  }
  .hero-actions {
    flex-direction: column;
    align-items: center;
  }
  .btn {
    width: 100%;
    justify-content: center;
  }
}
```

- [ ] **Step 2: 最终构建验证**

```bash
cd website && npx vite build
```

Expected: Build succeeds. `dist/` 目录包含完整可部署的静态文件。

---

### 部署说明

部署到 GitHub Pages（在项目根目录执行）：

```bash
# 方法一：使用 gh-pages 分支
cd website
npx vite build
git add dist/ -f
git commit -m "chore: build website"
git subtree push --prefix website/dist origin gh-pages

# 方法二：使用 GitHub Actions 自动部署到 pages
# 在 .github/workflows/ 下配置 deploy.yml
```

部署后访问：`https://<your-org>.github.io/PuaSE/`
