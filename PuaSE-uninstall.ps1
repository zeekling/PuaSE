<#
.SYNOPSIS
    PuaSE 卸载脚本 — 从 OpenCode 中移除 PuaSE 插件
.DESCRIPTION
    清理 opencode.json 中 PuaSE 相关配置，移除安装目录。
    从 config_template.json 动态读取子 Agent 名称。
.PARAMETER Force
    跳过确认提示(非交互模式)
.PARAMETER CleanBackups
    同时清理残留的 .bak.* 备份文件
.EXAMPLE
    .\PuaSE-uninstall.ps1
    .\PuaSE-uninstall.ps1 -Force
    .\PuaSE-uninstall.ps1 -Force -CleanBackups
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Force,
    [switch]$CleanBackups
)

$ErrorActionPreference = "Stop"

$PuseDir = Join-Path $env:USERPROFILE ".config\opencode\puse"
$OpencodeJson = Join-Path $env:USERPROFILE ".config\opencode\opencode.json"
$ConfigTemplate = Join-Path $PSScriptRoot "config_template.json"

function LogOK  { param($m) Write-Host "  [OK] $m" -ForegroundColor Green }
function LogWarn{ param($m) Write-Host "  [WARN] $m" -ForegroundColor Yellow }
function LogInfo{ param($m) Write-Host "  [INFO] $m" -ForegroundColor Gray }
function LogErr { param($m) Write-Host "  [ERROR] $m" -ForegroundColor Red }

Write-Host "PuaSE 卸载脚本" -ForegroundColor Cyan

if (-not $Force) {
    $r = Read-Host "确定卸载 PuaSE? 将移除配置和安装目录 (y/N)"
    if ($r -ne "y" -and $r -ne "Y") { Write-Host "已取消" -ForegroundColor Yellow; exit 0 }
}

# ---- 1. 清理 opencode.json ----
Write-Host "`n--- 清理 opencode.json ---" -ForegroundColor Cyan

if (-not (Test-Path $OpencodeJson)) {
    LogWarn "未找到 opencode.json，跳过"
} else {
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $bak = "$OpencodeJson.bak.uninstall.$ts"
    Copy-Item $OpencodeJson $bak -Force
    LogInfo "已备份到 $(Split-Path -Leaf $bak)"

    try {
        $json = Get-Content $OpencodeJson -Raw -Encoding UTF8 | ConvertFrom-Json
        $changed = $false

        if ($json.plugin -is [array]) {
            $before = $json.plugin.Count
            $json.plugin = $json.plugin | Where-Object {
                $e = $_.ToString()
                $isExact = "puse/plugin.js", "puse/.opencode/plugins/puse.js", "./puse", "puse" -contains $e
                $isFuzzy = $e -match '(^|[/\\])puse([/\\]|$)'
                -not ($isExact -or $isFuzzy)
            }
            $n = $before - $json.plugin.Count
            if ($n -gt 0) { $changed = $true; LogOK "已移除 $n 个 PuaSE 插件条目" }
            else { LogInfo "未找到 PuaSE 插件条目" }
        }

        if ($json.default_agent -eq "PuaSE") {
            $json.psobject.Properties.Remove("default_agent")
            $changed = $true; LogOK "已移除 default_agent: PuaSE"
        }

        $agentNames = @()
        if (Test-Path $ConfigTemplate) {
            $tmpl = Get-Content $ConfigTemplate -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($tmpl.agent) { $agentNames = @($tmpl.agent.PSObject.Properties.Name) }
        }
        if ($agentNames.Count -eq 0) {
            $agentNames = @("architect","architect-scan","code-reviewer",
                "go-developer","rust-developer","csharp-developer",
                "java-developer","python-developer","cpp-developer",
                "bigdata-developer","web-developer",
                "oracle-dba","mysql-dba","postgresql-dba",
                "security-expert","quality-inspector","documenter",
                "reflector","explore","general")
        }

        if ($json.agent) {
            $removed = @()
            foreach ($name in $agentNames) {
                if ($json.agent.PSObject.Properties.Name -contains $name) {
                    $json.agent.PSObject.Properties.Remove($name)
                    $removed += $name; $changed = $true
                }
            }
            if ($removed.Count -gt 0) {
                LogOK "已移除 $($removed.Count) 个子 Agent 配置"
                if ($json.agent.PSObject.Properties.Count -eq 0) {
                    $json.psobject.Properties.Remove("agent")
                    LogOK "agent 字段已删除(已为空)"
                }
            } else { LogInfo "未找到子 Agent 配置" }
        }

        if ($changed) {
            $json | ConvertTo-Json -Depth 10 | Out-File -FilePath $OpencodeJson -Encoding UTF8
            LogOK "opencode.json 已更新"
        } else { LogInfo "无需变更" }
    } catch {
        LogErr "处理失败: $_"
        LogWarn "备份位于 $bak"
    }
}

# ---- 2. 移除安装目录 ----
Write-Host "`n--- 移除安装目录 ---" -ForegroundColor Cyan
if (Test-Path $PuseDir) {
    Remove-Item -Recurse -Force $PuseDir
    LogOK "已删除: $PuseDir"
} else { LogInfo "目录不存在，跳过" }

# ---- 3. 可选清理备份 ----
if ($CleanBackups) {
    Write-Host "`n--- 清理备份 ---" -ForegroundColor Cyan
    Get-ChildItem -Path "$OpencodeJson.bak*" -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item -Force $_.FullName
        LogOK "已删除: $(Split-Path -Leaf $_.FullName)"
    }
}

Write-Host "`n=== 卸载完成 ===" -ForegroundColor Cyan
Write-Host "下一步: 重启 OpenCode 使配置生效" -ForegroundColor Yellow
