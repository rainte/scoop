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

function Set-ProxyFinal {
    param([string]$JsonFile)
    try {
        $json = Get-Content $JsonFile -Raw | ConvertFrom-Json

        # 默认出站改为直连
        $json.route.final = "direct"
        # 默认 DNS 走本地
        $json.dns.final = "local-dns"

        # ---------- 写回文件 ----------
        $jsonText = $json | ConvertTo-Json -Depth 32
        [System.IO.File]::WriteAllText((Resolve-Path $JsonFile).Path, $jsonText, [System.Text.UTF8Encoding]::new($false))
    }
    catch {
        Write-Host "ERROR: $($_.Exception.Message)"
        Write-Host $_.ScriptStackTrace
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
        Set-ProxyFinal -JsonFile 'tun.json'
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
