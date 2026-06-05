#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * 检测是否为 CI 环境
 * @returns {boolean}
 */
function isCIEnvironment() {
    return process.env.CI === 'true' || process.env.npm_config_ci === 'true';
}

/**
 * 创建配置目录
 * @param {string} targetPath
 */
function ensureConfigDir(targetPath) {
    if (!fs.existsSync(targetPath)) {
        fs.mkdirSync(targetPath, { recursive: true });
    }
}

/**
 * 复制文件到配置目录
 * @param {string} sourceDir - node_modules 中的源目录
 * @param {string} targetDir - ~/.config/opencode/puse/
 */
function copyFiles(sourceDir, targetDir) {
    const files = require('../package.json').files;

    files.forEach(file => {
        const sourcePath = path.join(sourceDir, file);
        const targetPath = path.join(targetDir, file);

        if (fs.statSync(sourcePath).isDirectory()) {
            fs.cpSync(sourcePath, targetPath, { recursive: true });
        } else {
            fs.cpSync(sourcePath, targetPath);
        }
    });
}

/**
 * 读取 PuaSE.md 中的默认 Agent
 * @param {string} configPath - ~/.config/opencode/puse/PuaSE.md
 * @returns {string|null}
 */
function readDefaultAgent(configPath) {
    if (!fs.existsSync(configPath)) return null;

    const content = fs.readFileSync(configPath, 'utf-8');
    const match = content.match(/defaultAgent:\s*([a-zA-Z-]+)/);
    return match ? match[1] : null;
}

/**
 * 注册插件到 opencode.json
 * @param {string} configPath - ~/.config/opencode/opencode.json
 * @param {string} pluginName
 * @param {string} defaultAgent
 */
function registerPlugin(configPath, pluginName, defaultAgent) {
    let config;

    if (!fs.existsSync(configPath)) {
        config = {
            name: 'opencode-config',
            plugins: {
                [pluginName]: { path: './puse.js', defaultAgent: defaultAgent }
            }
        };
    } else {
        config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

        if (!config.plugins) {
            config.plugins = {};
        }

        config.plugins[pluginName] = {
            path: './puse.js',
            defaultAgent: defaultAgent
        };
    }

    fs.writeFileSync(configPath, JSON.stringify(config, null, 2), 'utf-8');
}

/**
 * 输出错误信息
 * @param {string} message
 * @param {number} code
 */
function showError(message, code = 1) {
    console.error(message);
    process.exit(code);
}

/**
 * 输出成功信息
 * @param {string} configDir
 * @param {string|null} defaultAgent
 */
function showSuccess(configDir, defaultAgent) {
    console.log('✓ PuaSE installed successfully!');
    console.log(`  Config dir: ${configDir}`);
    console.log(`  Default agent: ${defaultAgent || 'not set'}`);
}

// 主函数（待实现）
async function main() {
    // TODO: 实现主逻辑
}
