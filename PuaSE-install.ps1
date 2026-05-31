<#
.SYNOPSIS
    PuaSE 安装脚本 — 安装到 ~/.config/opencode/puse/ 作为 OpenCode 插件
.DESCRIPTION
    支持符号链接(开发模式，修改即时生效)和复制(独立副本)两种安装模式。
    自动注册插件到 opencode.json。
.PARAMETER Symlink
    符号链接模式(需管理员权限)
.PARAMETER Copy
    复制模式
.PARAMETER NoDefault
    不设为默认 Agent
.PARAMETER ModelConfig
    子 Agent 模型配置文件路径。设为 template 使用内置模板
.PARAMETER Force
    跳过确认提示(非交互模式)
.EXAMPLE
    .\PuaSE-install.ps1 -Symlink -Force
    .\PuaSE-install.ps1 -Copy -NoDefault -ModelConfig template
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Symlink,
    [switch]$Copy,
    [switch]$NoDefault,
    [string]$ModelConfig = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PuseDir = Join-Path $env:USERPROFILE ".config\opencode\puse"
$PluginSrc = Join-Path $RepoDir ".opencode\plugins\puse.js"
$PluginDst = Join-Path $PuseDir "plugin.js"
$PluginEntry = "puse/plugin.js"
$ConfigTemplate = Join-Path $RepoDir "config_template.json"
$OpencodeJson = Join-Path $env:USERPROFILE ".config\opencode\opencode.json"

function LogOK  { param($m) Write-Host "  [OK] $m" -ForegroundColor Green }
function LogWarn{ param($m) Write-Host "  [WARN] $m" -ForegroundColor Yellow }
function LogInfo{ param($m) Write-Host "  [INFO] $m" -ForegroundColor Gray }
function LogErr { param($m) Write-Host "  [ERROR] $m" -ForegroundColor Red }
function Step   { param($m) Write-Host "`n=== $m ===" -ForegroundColor Cyan }

function New-SymlinkItem {
    param([string]$Link, [string]$Target, [string]$Label)
    $parent = Split-Path -Parent $Link
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    if (Test-Path $Link) { Remove-Item -Force -Path $Link }
    New-Item -ItemType SymbolicLink -Force -Path $Link -Target $Target | Out-Null
    LogOK "$Label -> $Target"
}

function Install-Symlink {
    Step "安装模式: 符号链接"
    if (Test-Path $PuseDir) {
        $item = Get-Item $PuseDir
        if ($item.LinkType -ne "SymbolicLink") { LogErr "已存在但不是符号链接，请先卸载"; return $false }
        Remove-Item $PuseDir -Force
    }
    try {
        New-SymlinkItem -Link $PuseDir -Target $RepoDir -Label "主目录"
        New-SymlinkItem -Link $PluginDst -Target $PluginSrc -Label "插件入口"
        return $true
    } catch { LogErr "创建失败: $_"; return $false }
}

function Install-Copy {
    Step "安装模式: 复制"
    if (Test-Path $PuseDir) { Remove-Item -Recurse -Force $PuseDir }
    robocopy $RepoDir $PuseDir /E /XD node_modules .git .idea .superpowers .logs /XF "*.lock" /NFL /NDL /NJH /NJS | Out-Null
    if ($LASTEXITCODE -ge 8) { LogErr "复制失败"; return $false }
    Copy-Item $PluginSrc $PluginDst -Force
    LogOK "插件入口已复制"
    return $true
}

function Update-OpencodeJson {
    param([bool]$SetDefault, [string]$ModelCfg)
    Step "更新 opencode.json"

    if (-not (Test-Path $OpencodeJson)) {
        '{"$schema":"https://opencode.ai/config.json"}' | Set-Content -NoNewline -Encoding UTF8 -Path $OpencodeJson
        LogInfo "已创建 $OpencodeJson"
    }

    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $bak = "$OpencodeJson.bak.$ts"
    Copy-Item $OpencodeJson $bak -Force
    LogInfo "已备份到 $(Split-Path -Leaf $bak)"

    try {
        $json = Get-Content $OpencodeJson -Raw -Encoding UTF8 | ConvertFrom-Json
        $changed = $false

        if ($json.plugin -is [array]) {
            if ($json.plugin -notcontains $PluginEntry) {
                $list = @($PluginEntry) + @($json.plugin | Where-Object { $_ -ne $PluginEntry })
                $json.plugin = $list; $changed = $true; LogOK "插件已注册"
            } else { LogInfo "插件已存在" }
        } else {
            $json | Add-Member -MemberType NoteProperty -Name "plugin" -Value @($PluginEntry) -Force
            $changed = $true; LogOK "插件已注册"
        }

        if ($SetDefault) {
            $hasDefault = $json.PSObject.Properties.Name -contains "default_agent"
            if (-not $hasDefault -or $json.default_agent -ne "PuaSE") {
                $json | Add-Member -MemberType NoteProperty -Name "default_agent" -Value "PuaSE" -Force
                $changed = $true; LogOK "默认 Agent 已设为 PuaSE"
            } else { LogInfo "默认 Agent 已是 PuaSE" }
        } else { LogInfo "跳过默认 Agent" }

        if ($ModelCfg) {
            $cfg = if ($ModelCfg -eq "template") { $ConfigTemplate } else { $ModelCfg }
            if (Test-Path $cfg) {
                $tmpl = Get-Content $cfg -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($tmpl.agent) {
                    foreach ($p in $tmpl.agent.PSObject.Properties) {
                        if (-not $json.agent) { $json | Add-Member -MemberType NoteProperty -Name "agent" -Value @{} -Force }
                        $json.agent.$($p.Name) = $p.Value
                    }
                    $changed = $true; LogOK "子 Agent 配置已合并 ($($tmpl.agent.PSObject.Properties.Count) 个)"
                } else { LogWarn "配置中无 agent 字段" }
            } else { LogWarn "未找到: $cfg" }
        }

        if ($changed) {
            $json | ConvertTo-Json -Depth 10 | Out-File -FilePath $OpencodeJson -Encoding UTF8
            LogOK "opencode.json 已保存"
        } else { LogInfo "无需变更" }
        return $true
    } catch {
        LogErr "更新失败: $_"
        LogWarn "备份位于 $bak"
        return $false
    }
}

function Invoke-ModelConfigWizard {
    $agentCfg = @{}

    $categories = @(
        @{
            Name   = "Developer 开发 Agent"
            Detail = "java · python · cpp · go · rust · csharp · bigdata · web（共8个）"
            Tip     = "代码生成首选"
            Keys   = @("java-developer","python-developer","cpp-developer","go-developer","rust-developer","csharp-developer","bigdata-developer","web-developer")
        }
        @{
            Name   = "DBA 数据库 Agent"
            Detail = "mysql-dba · oracle-dba · postgresql-dba（共3个）"
            Tip     = "SQL 优化需强推理"
            Keys   = @("mysql-dba","oracle-dba","postgresql-dba")
        }
        @{
            Name   = "Security 安全审计 Agent"
            Detail = "security-expert（1个）"
            Tip     = "安全审计需高精度"
            Keys   = @("security-expert")
        }
        @{
            Name   = "Architect 架构分析 Agent"
            Detail = "architect（1个）"
            Tip     = "深度架构分析需强推理"
            Keys   = @("architect")
        }
        @{
            Name   = "Architect-Scan 轻量架构扫描"
            Detail = "architect-scan（1个）"
            Tip     = "快速扫描轻量化即可"
            Keys   = @("architect-scan")
        }
        @{
            Name   = "Code Reviewer 代码审查 Agent"
            Detail = "code-reviewer（1个）"
            Tip     = "审查需细致"
            Keys   = @("code-reviewer")
        }
        @{
            Name   = "Quality Inspector 质量巡检 Agent"
            Detail = "quality-inspector（1个）"
            Tip     = "全面检查"
            Keys   = @("quality-inspector")
        }
        @{
            Name   = "Reflector 复盘分析 Agent"
            Detail = "reflector（1个）"
            Tip     = "分析推理适中即可"
            Keys   = @("reflector")
        }
        @{
            Name   = "Documenter 文档编写 Agent"
            Detail = "documenter（1个）"
            Tip     = "文档任务可轻量"
            Keys   = @("documenter")
        }
        @{
            Name   = "Explore 代码库探索 Agent"
            Detail = "explore（1个）"
            Tip     = "探索扫描可轻量"
            Keys   = @("explore")
        }
    )

    $total = $categories.Count

    Write-Host "  按分类依次设置各子 Agent 使用的模型，留空 = 使用 OpenCode 全局默认模型。" -ForegroundColor Gray
    Write-Host "  模型格式：provider/model-id，如 anthropic/claude-sonnet-4-6`n" -ForegroundColor Gray

    for ($i = 0; $i -lt $total; $i++) {
        $cat = $categories[$i]
        $num = $i + 1
        Write-Host "[$num/$total] $($cat.Name)" -ForegroundColor Yellow
        Write-Host "  Agent: $($cat.Detail)" -ForegroundColor Gray
        Write-Host "  推荐: $($cat.Tip)" -ForegroundColor Gray
        $model = Read-Host "  模型名称（留空=使用默认模型）"
        Write-Host ""
        if ($model -and $model.Trim() -ne "") {
            $m = $model.Trim()
            foreach ($key in $cat.Keys) {
                $agentCfg[$key] = @{ model = $m }
            }
        }
    }

    if ($agentCfg.Count -eq 0) {
        LogInfo "未配置任何子 Agent 模型，将使用全局默认模型"
        return ""
    }

    # 写入临时文件，交给 Update-OpencodeJson 合并
    $tmpFile = [System.IO.Path]::GetTempFileName() + ".json"
    $configObj = @{ agent = $agentCfg }
    $configObj | ConvertTo-Json -Depth 5 | Out-File -FilePath $tmpFile -Encoding UTF8
    LogOK "已为 $($agentCfg.Count) 个子 Agent 配置模型"

    return $tmpFile
}

# ===== 入口 =====
Write-Host "PuaSE 安装脚本" -ForegroundColor Cyan
Write-Host "  源: $RepoDir" -ForegroundColor Gray
Write-Host "  目标: $PuseDir" -ForegroundColor Gray

if (-not (Test-Path $PluginSrc)) { LogErr "未找到 $PluginSrc，请在仓库根目录运行"; exit 1 }

$useSymlink = $true
$useDefault = $true
$useModel = $ModelConfig

$interactive = -not ($Force -or $Symlink -or $Copy -or $NoDefault -or $ModelConfig)
if ($interactive) {
    Step "安装模式"
    Write-Host "  [1] 符号链接(修改即时生效，需管理员权限)" -ForegroundColor White
    Write-Host "  [2] 复制(独立副本)" -ForegroundColor White
    $useSymlink = (Read-Host "请选择 [1]") -ne "2"

    Step "默认 Agent"
    $r = Read-Host "设为默认 Agent? (Y/n) [Y]"
    $useDefault = $r -ne "n" -and $r -ne "N"

    Step "子 Agent 模型配置（按分类依次设置）"
    $useModel = Invoke-ModelConfigWizard
} else {
    $useSymlink = $Symlink -or (-not $Copy)
    $useDefault = -not $NoDefault
}

if ($useSymlink) {
    if (-not (Install-Symlink)) {
        LogWarn "符号链接失败，尝试复制模式..."
        if (-not (Install-Copy)) { LogErr "安装失败"; exit 1 }
    }
} else {
    if (-not (Install-Copy)) { LogErr "安装失败"; exit 1 }
}

if (-not (Update-OpencodeJson -SetDefault $useDefault -ModelCfg $useModel)) {
    LogErr "配置更新失败，但文件已安装到 $PuseDir"
    LogWarn "请手动编辑 $OpencodeJson"
    exit 1
}

Step "安装完成"
LogOK "目录: $PuseDir"
LogOK "插件: $PluginEntry"
Write-Host "`n下一步: 重启 OpenCode 后验证 @PuaSE 可用" -ForegroundColor Yellow
