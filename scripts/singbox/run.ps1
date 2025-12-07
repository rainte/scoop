$urls = @(
    'https://raw.githubusercontent.com/rainte/cdn/refs/heads/main/docs/singbox/pc/config1.json',
    'https://raw.githubusercontent.com/rainte/cdn/refs/heads/main/docs/singbox/pc/config2.json',
    'https://raw.githubusercontent.com/rainte/cdn/refs/heads/main/docs/singbox/pc/config3.json',
    'https://raw.githubusercontent.com/rainte/cdn/refs/heads/main/docs/singbox/pc/config4.json'
)

try {
    $index = Read-Host -Prompt 'Update IP: 1|2|3|4 Continue: 0'
    if ($index -ne 0) {
        $url = $urls[[int]$index - 1]
        ~\scoop\buckets\rainte\scripts\wget\wget.exe -t 2 --no-check-certificate $url -O 'config.json'
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
