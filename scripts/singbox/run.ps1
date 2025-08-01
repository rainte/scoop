$urls = @(
    'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ipp/singbox/1/config.json',
    'https://gitlab.com/free9999/ipupdate/-/raw/master/backup/img/1/2/ipp/singbox/1/config.json',
    'https://www.gitlabip.xyz/Alvin9999/PAC/master/backup/img/1/2/ip/singbox/2/config.json',
    'https://fastly.jsdelivr.net/gh/Alvin9999/PAC@latest/backup/img/1/2/ip/singbox/2/config.json'
)

try {
    $index = Read-Host -Prompt 'Update IP: 1|2|3|4 Continue: 0'
    if ($index -ne 0) {
        $url = $urls[[int]$index - 1]
        Invoke-WebRequest -useb $url -o ('config.json');
    }
}
catch {
    Write-Error 'Failed to request' -ErrorAction Stop
}

if (-not (Test-Path -Path config.json -PathType Leaf)) {
    Write-Error 'Failed to load config.json' -ErrorAction Stop
}

$tasks = netstat -ano | findstr :1080 | findstr LISTENING
foreach ($task in $tasks) {
    $ids = $task -split '\s+'
    $id = $ids[-1]
    try {
        Get-Process -Id $id -ErrorAction Stop
        taskkill /F /PID $id
    }
    catch {
    }
}

Start-Process sing-box.exe -ArgumentList 'run -c config.json' -WindowStyle Hidden
