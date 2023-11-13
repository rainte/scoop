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

$choice = Read-Host -Prompt '1: IP1更新 2: IP2更新 0: 跳过'
($dir = (Get-Location).Path + '\singbox') | Set-Location
Invoke-WebRequest -useb $choices[$choice].Url1 -o ($dir + '\singbox.json');
Invoke-WebRequest -useb $choices[$choice].Url2 -o ($dir + '\singbox.json');

if (-not (Test-Path -Path singbox.json -PathType Leaf)) {
    Write-Error '无法获取配置文件 singbox.json' -ErrorAction Stop
}
else {
    Copy-Item config.json -Destination config.json_backup
    Copy-Item singbox.json -Destination config.json
    Remove-Item -Force singbox.json
}

if (-not (Test-Path -Path ChromeGo.exe -PathType Leaf)) {
    Copy-Item sing-box.exe -Destination ChromeGo.exe
}

Start-Process ChromeGo.exe -ArgumentList 'run -c config.json' -WindowStyle Hidden
((Get-Location).Path + '\..') | Set-Location
