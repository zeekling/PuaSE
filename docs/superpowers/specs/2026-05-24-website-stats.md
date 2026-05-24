# 网站统计功能设计

## 需求
在 PuaSE 官网 Hero 区域下方展示 GitHub Star 数和页面访问量。

## 数据源

| 数据 | API | 实现方式 |
|------|-----|---------|
| ⭐ GitHub Stars | `GET https://api.github.com/repos/zeekling/PuaSE` → `stargazers_count` | 前端 fetch + localStorage 缓存 5 分钟 |
| 👁 访问量 | `GET https://api.countapi.xyz/hit/zeekling/PuaSE-visits` → `value` | 每次页面加载自动 +1，返回累计值 |

## 显示格式
```
⭐ 128 Stars  ·  👁 2.4k Visits
```
- 简约文字风格，一行显示
- 数字大于 1000 时缩写为 `k`（如 2400 → 2.4k）
- 位于 `.hero-actions` 按钮下方，居中

## 实现文件

### website/index.html
- 在 `<div class="hero-actions">` 之后添加 `<div class="hero-stats" id="hero-stats">`

### website/src/main.js
- 新增 `loadStats()` 函数：
  - `loadStarCount()` — fetch GitHub API → `stargazers_count`
  - `loadVisitCount()` — fetch countapi.xyz → `value`（同时做递增）
  - 缓存策略：localStorage 缓存 5 分钟，避免 GitHub API rate limit
  - 异常降级：API 失败时显示 `—`，不阻挡页面渲染

### website/src/style.css
- 新增 `.hero-stats` 样式：居中、小字、灰色调

## 异常处理
- API 超时或 429 → 读取缓存或显示 `—`
- 所有异常静默处理，不报错到用户
- Visit API 不可用时仅显示 Star 数

## 不做的
- 不使用第三方 SDK/库
- 不做实时 WebSocket
- 不记录用户身份
