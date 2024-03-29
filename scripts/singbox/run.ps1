$choices = @(
    @{Url = '' },
    @{Url = 'https://www.gitlabip.xyz/Alvin9999/pac2/master/singbox/1/config.json' },
    @{Url = 'https://gitlab.com/free9999/ipupdate/-/raw/master/singbox/config.json' },
    @{Url = 'https://www.githubip.xyz/Alvin9999/pac2/master/singbox/config.json' },
    @{Url = 'https://fastly.jsdelivr.net/gh/Alvin9999/pac2@latest/singbox/config.json' }
)

$choice = Read-Host -Prompt 'Update IP: 1|2|3|4 Continue: 0'
if ($choice -ne 0) {
    try {
        Invoke-WebRequest -useb $choices[$choice].Url -o ('singbox.json');
    }
    catch {
    }
}

if (-not (Test-Path -Path singbox.json -PathType Leaf)) { 
    Write-Error 'Failed to load singbox.json' -ErrorAction Stop
}
else {
    if (Test-Path -Path config.json -PathType Leaf) {
        Copy-Item config.json -Destination config.json_backup
    }
    Copy-Item singbox.json -Destination config.json
    Remove-Item -Force singbox.json
}

$processes = netstat -ano | findstr :1080 | findstr LISTENING
foreach ($process in $processes) {
    $ids = $process -split "\s+"  
    $id = $ids[-1]
    try {
        Get-Process -Id $id -ErrorAction Stop
        taskkill /PID $id /F
    }
    catch {
    }
}

Start-Process sing-box.exe -ArgumentList 'run -c config.json' -WindowStyle Hidden
