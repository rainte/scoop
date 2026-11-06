#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$urls = @(
    'https://cdn.rainte.com/singbox/pc/config1.json'
    'https://cdn.rainte.com/singbox/pc/config2.json'
    'https://cdn.rainte.com/singbox/pc/config3.json'
    'https://cdn.rainte.com/singbox/pc/config4.json'
)

$i = 0
$choice = Read-Host 'Update IP: 1|2|3|4  (Enter to skip)'
if ($choice -and [int]::TryParse($choice, [ref]$i) -and $i -in 1..$urls.Count) {
    curl.exe -k --retry 2 -L -o config.json.tmp $urls[$i - 1]
    if ($LASTEXITCODE -ne 0) { throw "Download failed (exit=$LASTEXITCODE)" }
    $null = Get-Content config.json.tmp -Raw | ConvertFrom-Json
    Move-Item -Force config.json.tmp config.json
}

Get-Process -Name 'sing-box' -ErrorAction SilentlyContinue | Stop-Process -Force

if (-not (Test-Path config.json -PathType Leaf)) { throw 'config.json not found' }
Start-Process sing-box.exe -ArgumentList 'run -c config.json' -WindowStyle Hidden
