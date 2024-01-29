# 允许本地运行 PowerShell 脚本.
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# ========== 变量 Start ==========
# GitHub Token https://github.com/settings/tokens
# scoop config gh_token GITHUB_TOKEN
# 过滤的软件.
$filters = @('jdk8', 'sogou', 'wegame')
# ========== 变量 End ==========

function Install-Scoop {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Token
    )

    $install = iwr -useb 'https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1'
    $pattern = "(https?://github\.com/)([\w-]+)/([\w-]+)(\.git)"
    $install = $install -replace $pattern, 'git@github.com:$2/$3$4' | Out-String
    $install | iex

    # 配置仓库源.
    scoop config scoop_repo "git@github.com:ScoopInstaller/Scoop.git"
    # 配置 Token.
    scoop config gh_token $Token
    # 配置 GitHub 端口.
    $sshConfig = "~\.ssh\config"
    if (!(Test-Path $sshConfig)) {
        New-Item $sshConfig -ItemType File -Force
    }
    Add-Content -Path $sshConfig -Value @'

Host github.com
Hostname ssh.github.com
Port 443
'@
    # 安装 Git.
    scoop install git
    cmd /c 'mklink /j "%PROGRAMFILES%\Git" "~\scoop\apps\git\current"'
    # 添加仓库.
    scoop bucket rm main
    scoop bucket add main "git@github.com:ScoopInstaller/Main.git"
    scoop bucket add rainte "git@github.com:rainte/scoop.git"
    # 添加配置.
    Copy-Item -Path '~\scoop\buckets\rainte\scripts\git\.gitconfig' -Destination '~\.gitconfig'
}

function Install-Apps {
    param (
        [string[]]$Filters
    )

    # 安装软件.
    scoop install (Get-ChildItem "~\scoop\buckets\rainte\bucket" | ForEach-Object { $_.Name.Replace('.json', '') } | Where-Object { $_ -notin $Filters } | ForEach-Object { 'rainte/' + $_ })
}

$choice = Read-Host -Prompt '1: Install-Scoop 2: Install-Apps'
$admin = [security.principal.windowsbuiltinrole]::administrator
$user = [security.principal.windowsidentity]::getcurrent()
$isAdmin = ([security.principal.windowsprincipal]($user)).isinrole($admin)

if ($choice -eq 1) {
    if ($isAdmin) {
        Write-Error 'Do not start PowerShell as an administrator.' -ErrorAction Stop
    }
    else {
        $token = Read-Host -Prompt 'Github Token'
        Install-Scoop -Token $token
    }
}

if ($choice -eq 2) {
    if ($isAdmin) {
        Install-Apps -Filters $filters
    }
    else {
        Write-Error 'To start PowerShell as an administrator.' -ErrorAction Stop
    }
}
