const fs = require('fs');
const path = require('path');

// Mock 文件系统
global.fs = {
    existsSync: jest.fn(() => false),
    mkdirSync: jest.fn(),
    cpSync: jest.fn(),
    readFileSync: jest.fn(),
    writeFileSync: jest.fn(),
    statSync: jest.fn(() => ({ isDirectory: () => false })),
};

global.process = {
    env: { CI: 'false' },
    exit: jest.fn(),
};

global.console = {
    log: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
};

// 引入被测试代码
require('../scripts/puse-postinstall');

describe('puse-postinstall', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe('isCIEnvironment', () => {
        test('detects CI=true', () => {
            process.env.CI = 'true';
            expect(isCIEnvironment()).toBe(true);
            delete process.env.CI;
        });

        test('detects CI=false', () => {
            process.env.CI = 'false';
            expect(isCIEnvironment()).toBe(false);
            delete process.env.CI;
        });

        test('detects npm_config_ci', () => {
            process.env.npm_config_ci = 'true';
            expect(isCIEnvironment()).toBe(true);
            delete process.env.npm_config_ci;
        });
    });

    describe('ensureConfigDir', () => {
        test('creates directory when it does not exist', () => {
            const mockExists = jest.fn(() => false);
            global.fs.existsSync = mockExists;

            const testDir = '/tmp/test-dir';
            ensureConfigDir(testDir);

            expect(mockExists).toHaveBeenCalledWith(testDir);
            expect(global.fs.mkdirSync).toHaveBeenCalledWith(testDir, { recursive: true });
        });
    });

    describe('copyFiles', () => {
        test('copies files from package.json.files', () => {
            const mockStat = jest.fn(() => ({ isDirectory: () => false }));
            global.fs.statSync = mockStat;

            const mockCp = jest.fn();
            global.fs.cpSync = mockCp;

            const mockPackage = { files: ['puse.js', 'PuaSE.md', 'subagent/'] };
            global.require = jest.fn(() => mockPackage);

            const sourceDir = '/tmp/source';
            const targetDir = '/tmp/target';
            copyFiles(sourceDir, targetDir);

            expect(mockCp).toHaveBeenCalledTimes(3);
        });
    });

    describe('readDefaultAgent', () => {
        test('reads defaultAgent from PuaSE.md', () => {
            const content = 'defaultAgent: general\nother: value';
            global.fs.readFileSync.mockReturnValue(content);

            const result = readDefaultAgent('/path/to/PuaSE.md');
            expect(result).toBe('general');
        });

        test('returns null when file does not exist', () => {
            global.fs.existsSync.mockReturnValue(false);
            const result = readDefaultAgent('/path/to/PuaSE.md');
            expect(result).toBeNull();
        });

        test('returns null when defaultAgent not found', () => {
            const content = 'other: value';
            global.fs.readFileSync.mockReturnValue(content);

            const result = readDefaultAgent('/path/to/PuaSE.md');
            expect(result).toBeNull();
        });
    });

    describe('registerPlugin', () => {
        test('creates opencode.json when it does not exist', () => {
            const testJson = '/tmp/test-opencode.json';
            global.fs.existsSync.mockReturnValue(false);
            global.fs.writeFileSync.mockImplementation((path, content) => {
                // 验证写入的内容
                const parsed = JSON.parse(content);
                expect(parsed.name).toBe('opencode-config');
                expect(parsed.plugins.puse).toBeDefined();
                expect(parsed.plugins.puse.path).toBe('./puse.js');
            });

            registerPlugin(testJson, 'puse', 'general');
        });

        test('updates plugin when opencode.json exists', () => {
            const testJson = '/tmp/test-opencode.json';
            const existingConfig = {
                name: 'opencode-config',
                plugins: { other: {} }
            };
            global.fs.existsSync.mockReturnValue(true);
            global.fs.readFileSync.mockReturnValue(JSON.stringify(existingConfig));
            global.fs.writeFileSync.mockImplementation((path, content) => {
                const parsed = JSON.parse(content);
                expect(parsed.plugins.puse).toBeDefined();
                expect(parsed.plugins.puse.defaultAgent).toBe('general');
            });

            registerPlugin(testJson, 'puse', 'general');
        });
    });
});
