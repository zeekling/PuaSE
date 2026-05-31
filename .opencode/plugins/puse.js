// .opencode/plugins/puse.js
// PuaSE Plugin — auto-register agents via OpenCode config hook
import path from 'path';
import fs from 'fs';
import os from 'os';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
// PUSE_CONFIG_DIR: 用户本地的安装目录 (~/.config/opencode/puse)，与 superpowers 模式一致
// 动态计算，安装后自动指向正确位置，无需手动替换
const PUSE_CONFIG_DIR = path.join(os.homedir(), '.config', 'opencode', 'puse');
const REPO_ROOT = PUSE_CONFIG_DIR;
const SUBAGENT_DIR = path.join(REPO_ROOT, 'subagent');
const PUSE_MD = path.join(REPO_ROOT, 'PuaSE.md');

/**
 * Extract YAML frontmatter from an .md file
 */
function parseFrontmatter(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    // 移除 UTF-8 BOM
    content = content.replace(/^\uFEFF/, '');
    // 兼容 CRLF 和 LF
    const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
    if (!match) return {};
    const fm = {};
    const lines = match[1].split(/\r?\n/);
    let multiKey = null;
    for (const rawLine of lines) {
      const cleanLine = rawLine.trim();
      if (!cleanLine || cleanLine.startsWith('#')) {
        if (multiKey && cleanLine.startsWith('#')) continue;
        multiKey = null;
        continue;
      }
      const colonIdx = cleanLine.indexOf(':');
      if (colonIdx > 0 && !multiKey) {
        const key = cleanLine.slice(0, colonIdx).trim();
        const val = cleanLine.slice(colonIdx + 1).trim();
        if (val === '|' || val === '|-' || val === '>' || val === '>-') {
          multiKey = key;
          fm[key] = '';
        } else {
          fm[key] = val;
        }
      } else if (multiKey) {
        // 缩进的行作为多行值的延续
        if (rawLine.startsWith('  ') || rawLine.startsWith('\t')) {
          fm[multiKey] += (fm[multiKey] ? ' ' : '') + cleanLine;
        } else {
          multiKey = null;
        }
      }
    }
    return fm;
  } catch {
    return {};
  }
}

/**
 * Extract description from agent .md frontmatter
 */
function extractDescription(filePath) {
  const fm = parseFrontmatter(filePath);
  return fm.description || path.basename(filePath, '.md').replace(/-/g, ' ');
}

/**
 * Derive permissions based on agent path within subagent/
 * @param {string} relPath - relative path from subagent/ dir
 */
function derivePermission(relPath) {
  if (relPath.startsWith('developer')) {
    return { read: 'allow', write: 'allow', execute: 'allow', network: 'allow' };
  }
  if (relPath.startsWith('security')) {
    return { read: 'allow', network: 'allow' };
  }
  if (relPath.startsWith('dba')) {
    return { read: 'allow', write: 'allow', execute: 'allow', network: 'allow' };
  }
  // explore / quality-inspector get full access
  if (/^explore\.md$/.test(relPath) || /^quality-inspector\.md$/.test(relPath)) {
    return { '*': 'allow' };
  }
  // default: read + write + network
  return { read: 'allow', write: 'allow', network: 'allow' };
}

/**
 * Recursively register all .md files in subagent/ as agents
 */
function registerSubagents(config, dir) {
  let entries;
  try {
    if (!fs.existsSync(dir)) {
      console.warn(`[PuaSE Plugin] subagent directory not found: ${dir}`);
      return;
    }
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch (err) {
    console.warn(`[PuaSE Plugin] failed to read subagent directory ${dir}: ${err.message}`);
    return;
  }
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      registerSubagents(config, fullPath);
    } else if (entry.name.endsWith('.md') && entry.name !== 'explore.md') {
      const agentName = path.basename(entry.name, '.md');
      const relPath = path.relative(SUBAGENT_DIR, fullPath);
      config.agent[agentName] = {
        description: extractDescription(fullPath),
        prompt: fullPath,
        permission: derivePermission(relPath)
      };
    }
  }
}

export const PusePlugin = async ({ client, directory }) => {
  return {
    config: async (config) => {
      config.agent = config.agent || {};

      // 1. Register PuaSE as the primary agent
      config.agent.PuaSE = {
        description: '全局编排 Agent — 解析隐含需求、评估代码库成熟度、委派给专家 Agent。适用于复杂多步骤任务、跨领域问题、需要多人协作的场景。',
        prompt: PUSE_MD,
        permission: { '*': 'allow' }
      };
    }
  };
};

/**
 * 架构风险与限制说明
 *
 * 1. REPO_ROOT 配置
 *    使用动态路径计算：path.join(os.homedir(), '.config', 'opencode', 'puse')
 *    安装后自动指向 ~/.config/opencode/puse，无需手动替换
 *
 * 2. explore.md 硬编码排除
 *    registerSubagents 中 entry.name !== 'explore.md' 是硬编码逻辑
 *    原因是 explore.md 通过 PusePlugin 中独立的步骤注册（以保持全权限 '*': 'allow'）
 *
 * 3. derivePermission 权限分层
 *    developer/dba 子目录 Agent 有 execute 权限
 *    其他 Agent 默认 read + write + network
 */