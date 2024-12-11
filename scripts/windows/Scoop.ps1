# 允许本地运行 PowerShell 脚本.
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# ========== 变量 Start ==========
# GitHub Token https://github.com/settings/tokens
# 安装的软件.
$apps = @('chrome', 'fdm', 'kugou', 'office', 'qq', 'search', 'singbox', 'vscode', 'wechat', 'ximalaya')
# ========== 变量 End ==========

function Install-Scoop {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Token
    )

    Write-Host 'Install Scoop.'
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    scoop config gh_token $Token
    scoop config proxy 127.0.0.1:1080
    Write-Host 'Install completed.'
}

function Install-Apps {
    param (
        [string[]]$Apps
    )

    Write-Host 'Install Git.'
    scoop install git
    cmd /c 'mklink /j "%PROGRAMFILES%\Git" "~\scoop\apps\git\current"'
    Write-Host 'Scoop add bucket.'
    scoop bucket add extras
    scoop bucket add nonportable
    scoop bucket add rainte 'https://github.com/rainte/scoop.git'
    Write-Host 'Git add .gitconfig.'
    Copy-Item -Path '~\scoop\buckets\rainte\scripts\git\.gitconfig' -Destination '~\.gitconfig'
    Write-Host 'Install software.'
    scoop install (Get-ChildItem '~\scoop\buckets\rainte\bucket' | ForEach-Object { $_.Name.Replace('.json', '') } | Where-Object { $_ -in $Apps } | ForEach-Object { 'rainte/' + $_ })
    Write-Host 'Install completed.'
}

$choice = Read-Host -Prompt '1: Install-Scoop 2: Install-Apps'
$admin = [security.principal.windowsbuiltinrole]::administrator
$user = [security.principal.windowsidentity]::getcurrent()
$isAdmin = ([security.principal.windowsprincipal]($user)).isinrole($admin)

if ($choice -eq 1) {
    $token = Read-Host -Prompt 'Github Token'
    Install-Scoop -Token $token
}
elseif
 ($choice -eq 2) {
    if ($isAdmin) {
        Install-Apps -Apps $apps
    }
    else {
        Write-Error 'To start PowerShell as an administrator.' -ErrorAction Stop
    }
}
