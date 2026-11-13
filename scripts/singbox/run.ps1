#Requires -Version 5.1

# 切换工作目录到脚本所在目录
$scriptDir = Split-Path -Parent $PSCommandPath
Set-Location $scriptDir

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -WorkingDirectory $scriptDir -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', "`"$PSCommandPath`""
    )
    exit
}

$ErrorActionPreference = 'Stop'

# ---------- 公用函数 ----------

function Download-Config {
    param([string]$Url, [string]$OutFile)
    $tmp = "$OutFile.tmp"
    curl.exe -k --retry 2 -L -o $tmp $Url
    if ($LASTEXITCODE -ne 0) { throw "Download failed: $Url (exit=$LASTEXITCODE)" }
    $null = Get-Content $tmp -Raw | ConvertFrom-Json
    Move-Item -Force $tmp $OutFile
}

function Start-SingBoxWithConfig {
    param([string]$ConfigName)
    if (-not (Test-Path $ConfigName -PathType Leaf)) { throw "$ConfigName not found" }
    Start-Process sing-box.exe -ArgumentList "run -c $ConfigName" -WindowStyle Hidden
}

function Add-GoogleProxyRule {
    param([string]$JsonFile)
    try {
        $json = Get-Content $JsonFile -Raw | ConvertFrom-Json
        if (-not $json.route) {
            $json | Add-Member -NotePropertyName route -NotePropertyValue ([PSCustomObject]@{}) -Force
        }
        if (-not $json.route.rules) {
            $json.route | Add-Member -NotePropertyName rules -NotePropertyValue @() -Force
        }
        $json.route.rules = @($json.route.rules) + [PSCustomObject]@{
            domain_suffix = @("google.com")
            outbound      = "proxy"
        }
        $json | ConvertTo-Json -Depth 32 | Set-Content $JsonFile -Encoding utf8NoBOM
    }
    catch {
        # 加不上就不管
    }
}

# ---------- 主流程 ----------

try {
    $count = 4
    $urlMixed = 'https://cdn.rainte.com/singbox/mixed/config{0}.json'
    $urlTun = 'https://cdn.rainte.com/singbox/tun/config{0}.json'

    $choice = Read-Host "Update IP: 1-$count  (Enter to skip)"
    $i = 0
    $valid = $choice -and [int]::TryParse($choice, [ref]$i) -and $i -in 1..$count

    if ($valid) {
        Download-Config -Url ($urlMixed -f $i) -OutFile 'mixed.json'
        Download-Config -Url ($urlTun -f $i)   -OutFile 'tun.json'
        Add-GoogleProxyRule -JsonFile 'tun.json'
    }

    # 一次性停止所有 sing-box 进程
    Get-Process -Name 'sing-box' -ErrorAction SilentlyContinue | Stop-Process -Force

    Start-SingBoxWithConfig -ConfigName 'mixed.json'
    Start-SingBoxWithConfig -ConfigName 'tun.json'
}
catch {
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
