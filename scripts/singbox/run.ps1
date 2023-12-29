$choices = @(
    @{
        Url1 = '';
        Url2 = '';
    },
    @{
        Url1 = 'https://www.gitlabip.xyz/Alvin9999/pac2/master/singbox/1/config.json'
        Url2 = 'https://gitlab.com/free9999/ipupdate/-/raw/master/singbox/config.json'
    },
    @{
        Url1 = 'https://www.githubip.xyz/Alvin9999/pac2/master/singbox/config.json'
        Url2 = 'https://fastly.jsdelivr.net/gh/Alvin9999/pac2@latest/singbox/config.json' 
    }
)

$choice = Read-Host -Prompt '1: IP1 Update 2: IP2 Update 0: Continue'
if ($choice -ne 0) {
    Invoke-WebRequest -useb $choices[$choice].Url1 -o ('singbox.json');
    Invoke-WebRequest -useb $choices[$choice].Url2 -o ('singbox.json');
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

Start-Process sing-box.exe -ArgumentList 'run -c config.json' -WindowStyle Hidden
