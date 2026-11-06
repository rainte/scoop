# GitHub Token https://github.com/settings/tokens
#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
if (-not (Select-String $PROFILE -Pattern 'SCOOP_UA' -Quiet)) {
    Add-Content $PROFILE '$env:SCOOP_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36"'
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    $token = Read-Host 'GitHub Token'
    if (-not $token) { throw 'Token 不能为空' }
    Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
    scoop config gh_token $token
    scoop config proxy 127.0.0.1:1080
}

scoop install git
if (-not (Test-Path "$env:ProgramFiles\Git")) {
    New-Item -ItemType Junction -Path "$env:ProgramFiles\Git" -Target "$HOME\scoop\apps\git\current" | Out-Null
}
scoop bucket add rainte 'https://github.com/rainte/scoop.git'
$cfg = "$HOME\scoop\buckets\rainte\scripts\git\.gitconfig"
if (Test-Path $cfg) { Copy-Item $cfg "$HOME\.gitconfig" -Force }
