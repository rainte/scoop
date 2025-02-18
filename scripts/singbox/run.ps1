$urls = @(
    'https://www.gitlabip.xyz/Alvin9999/pac2/master/singbox/1/config.json',
    'https://gitlab.com/free9999/ipupdate/-/raw/master/singbox/config.json',
    'https://www.githubip.xyz/Alvin9999/pac2/master/singbox/config.json',
    'https://fastly.jsdelivr.net/gh/Alvin9999/pac2@latest/singbox/config.json'
)

try {
    $index = Read-Host -Prompt 'Update IP: 1|2|3|4 Continue: 0'
    if ($index -ne 0) {
        $url = $urls[[int]$index - 1]
        Invoke-WebRequest -useb $url -o ('singbox.json');
    }
}
catch {
    Write-Error 'Failed to request' -ErrorAction Stop
}

if (-not (Test-Path -Path singbox.json -PathType Leaf)) { 
    Write-Error 'Failed to load singbox.json' -ErrorAction Stop
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

Start-Process sing-box.exe -ArgumentList 'run -c singbox.json' -WindowStyle Hidden
