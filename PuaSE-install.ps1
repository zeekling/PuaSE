# PuaSE 安装脚本 (Windows PowerShell)
# 用法: .\PuaSE-install.ps1
# 将 PuaSE 安装到 ~/.config/opencode/puse/，作为 OpenCode 插件运行

param(
    [switch]$ForceCopy  # 使用复制模式（无管理员权限时）
)

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PuseDir = Join-Path $env:USERPROFILE ".config\opencode\puse"
$PluginSrc = Join-Path $RepoDir ".opencode\plugins\puse.js"
$OpencodeJson = Join-Path $env:USERPROFILE ".config\opencode\opencode.json"

# 检查源文件
if (-not (Test-Path $PluginSrc)) {
    Write-Host "错误: 未找到 $PluginSrc"
    Write-Host "请确保在 PuaSE 仓库根目录运行此脚本"
    exit 1
}

Write-Host "=== PuaSE 安装脚本 ===" -ForegroundColor Cyan
Write-Host "源码目录: $RepoDir"
Write-Host "安装目录: $PuseDir"
Write-Host ""

function Install-Symlink {
    param($TargetPath)
    $linkPath = $PuseDir
    $linkTarget = $TargetPath

    # 移除已存在的目标
    if (Test-Path $linkPath) {
        if ((Get-Item $linkPath).LinkType -eq "SymbolicLink") {
            Remove-Item $linkPath -Force
        } else {
            Write-Host "错误: $linkPath 已存在且不是 symlink" -ForegroundColor Red
            return $false
        }
    }

    # 创建父目录
    $parentDir = Split-Path -Parent $linkPath
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }

    # 创建 symlink (需要管理员权限)
    try {
        New-Item -ItemType SymbolicLink -Force -Path $linkPath -Target $linkTarget | Out-Null
        Write-Host "[Symlink] $linkPath -> $linkTarget" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Symlink 创建失败 (需要管理员权限): $_" -ForegroundColor Yellow
        return $false
    }
}

function Update-OpencodeJson {
    $pluginEntry = "puse/.opencode/plugins/puse.js"
    $json = Get-Content $OpencodeJson -Raw | ConvertFrom-Json

    # 检查是否已有 puse 插件
    $hasPuse = $json.plugin -contains $pluginEntry

    if ($hasPuse) {
        Write-Host "[Config] opencode.json 已包含 puse 插件" -ForegroundColor Green
    } else {
        # 添加 puse 到 plugins 数组开头
        $json.plugin = @($pluginEntry) + $json.plugin
        $json | ConvertTo-Json -Depth 10 | Set-Content -NoNewline -Encoding UTF8 -Path $OpencodeJson
        Write-Host "[Config] opencode.json 已更新" -ForegroundColor Green
    }

    # 设置默认 agent 为 PuaSE
    if ($json.default_agent -ne "PuaSE") {
        $json.default_agent = "PuaSE"
        $json | ConvertTo-Json -Depth 10 | Set-Content -NoNewline -Encoding UTF8 -Path $OpencodeJson
        Write-Host "[Config] 默认 Agent 已设置为 PuaSE" -ForegroundColor Green
    } else {
        Write-Host "[Config] 默认 Agent 已为 PuaSE" -ForegroundColor Green
    }

    return $true
}

function Install-Copy {
    Write-Host "使用复制模式安装..." -ForegroundColor Cyan

    # 移除已存在的目录
    if (Test-Path $PuseDir) {
        Remove-Item -Recurse -Force $PuseDir
    }

    # 复制文件（排除 node_modules, .git 等）
    Write-Host "复制文件到 $PuseDir ..."
    robocopy $RepoDir $PuseDir /E /XD node_modules .git .idea .superpowers .logs /XF "*.lock" /NFL /NDL /NJH /NJS

    if ($LASTEXITCODE -gt 7) {
        Write-Host "复制失败 (robocopy exit code: $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }

    # 更新 opencode.json
    Update-OpencodeJson

    Write-Host "复制模式安装完成!" -ForegroundColor Green
}

# 主流程
$installMode = $null

if ($ForceCopy) {
    $installMode = "copy"
} else {
    # 尝试 symlink
    Write-Host "尝试使用 Symlink 模式..." -ForegroundColor Cyan
    $symlinkOk = Install-Symlink -TargetPath $RepoDir

    if ($symlinkOk) {
        $installMode = "symlink"
    } else {
        Write-Host ""
        Write-Host "Symlink 需要管理员权限" -ForegroundColor Yellow
        $choice = Read-Host "是否使用复制模式安装? (Y/N)"
        if ($choice -eq "Y" -or $choice -eq "y") {
            $installMode = "copy"
        } else {
            Write-Host "安装取消" -ForegroundColor Yellow
            exit 0
        }
    }
}

if ($installMode -eq "symlink") {
    # puse.js 使用动态路径计算 (os.homedir())，无需安装时替换
    Update-OpencodeJson
    Write-Host "Symlink 模式安装完成!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== 安装完成 ===" -ForegroundColor Cyan
Write-Host "安装目录: $PuseDir"
Write-Host ""

# 验证安装
Write-Host "=== 验证安装 ===" -ForegroundColor Cyan
$verifyPass = $true

# 检查 puse.js 是否存在
$puseJsPath = Join-Path $PuseDir ".opencode\plugins\puse.js"
if (Test-Path $puseJsPath) {
    Write-Host "[OK] puse.js 存在" -ForegroundColor Green
    # 验证使用动态路径
    $content = Get-Content $puseJsPath -Raw
    if ($content -match "os\.homedir\(\)") {
        Write-Host "[OK] 使用动态路径计算 (os.homedir)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] 未使用动态路径计算!" -ForegroundColor Red
        $verifyPass = $false
    }
} else {
    Write-Host "[ERROR] puse.js 不存在" -ForegroundColor Red
    $verifyPass = $false
}

# 检查 subagent 目录
$subagentDir = Join-Path $PuseDir "subagent"
if (Test-Path $subagentDir) {
    $subagentCount = (Get-ChildItem $subagentDir -Recurse -Filter "*.md" | Measure-Object).Count
    Write-Host "[OK] subagent/ 目录存在 ($subagentCount 个 .md 文件)" -ForegroundColor Green
} else {
    Write-Host "[ERROR] subagent/ 目录不存在" -ForegroundColor Red
    $verifyPass = $false
}

# 检查 opencode.json 配置
$json = Get-Content $OpencodeJson -Raw | ConvertFrom-Json
if ($json.plugin -contains "puse/.opencode/plugins/puse.js") {
    Write-Host "[OK] opencode.json 包含 puse 插件" -ForegroundColor Green
} else {
    Write-Host "[ERROR] opencode.json 未包含 puse 插件" -ForegroundColor Red
    $verifyPass = $false
}

if ($json.default_agent -eq "PuaSE") {
    Write-Host "[OK] 默认 Agent 设置为 PuaSE" -ForegroundColor Green
} else {
    Write-Host "[WARN] 默认 Agent 不是 PuaSE (当前: $($json.default_agent))" -ForegroundColor Yellow
}

Write-Host ""
if ($verifyPass) {
    Write-Host "=== 验证通过 ===" -ForegroundColor Green
} else {
    Write-Host "=== 验证失败 ===" -ForegroundColor Red
}
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "  1. 重启 OpenCode"
Write-Host "  2. 验证: @PuaSE 可用"
