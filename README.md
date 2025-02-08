# Scoop Bucket Template

```bash
# 自动更新版本.
.\bin\checkver.ps1 -f
# 更新 Token.
scoop config gh_token "GITHUB_TOKEN"
# 设置代理.
scoop config proxy 127.0.0.1:1080
scoop config rm proxy
# 去掉 Referer.
(Get-Content "$(Convert-Path (scoop prefix scoop))\lib\core.ps1") -replace '\$path -replace \[regex\]::escape\(\(fname \$path\)\)', 'return ""' | Set-Content "$(Convert-Path (scoop prefix scoop))\lib\core.ps1"
# 恢复 Referer.
(Get-Content "$(Convert-Path (scoop prefix scoop))\lib\core.ps1") -replace 'return \"\"', '$path -replace [regex]::escape((fname $path))' | Set-Content "$(Convert-Path (scoop prefix scoop))\lib\core.ps1"
```

- extras/fiddler `抓包`
- extras/freedownloadmanager `下载`
- extras/idea `编辑器`
- extras/mobaxterm `远程终端`
- extras/motrix `下载`
- extras/postman `接口`
- extras/qq-nt `聊天`
- extras/tortoisesvn `版本控制`
- extras/vscode `编辑器`
- extras/wechat `聊天`
- extras/wireshark `抓包`
- main/fnm `Node版本`
- main/pyenv `Python版本`
- rainte/360zip `压缩`
- rainte/alipan `云盘`
- rainte/android `编辑器`
- rainte/chrome `浏览器`
- rainte/jdk17 `JDK`
- rainte/jdk21 `JDK`
- rainte/jdk8 `JDK`
- rainte/kugou `音频`
- rainte/navicat `数据库`
- rainte/office `办公`
- rainte/qqmusic `音频`
- rainte/search `scoop`
- rainte/singbox `翻墙`
- rainte/sun `远程控制`
- rainte/vagrant `虚拟环境构建`
- rainte/virtualbox `虚拟机`
- rainte/wegame `游戏`
- rainte/ximalaya `音频`

```json
{
  "version": "",
  "description": "",
  "homepage": "",
  "license": "",
  "url": "",
  "hash": "",
  "extract_dir": "",
  "extract_to": "",
  "innosetup": "",
  "pre_install": "",
  "installer": "",
  "bin": "",
  "shortcuts": "",
  "psmodule": "",
  "env_add_path": "",
  "env_set": "",
  "persist": "",
  "post_install": "",
  "suggest": "",
  "notes": "",
  "pre_uninstall": "",
  "depends": "",
  "uninstaller": "",
  "post_uninstall": "",
  "checkver": "",
  "autoupdate": ""
}
```

<!-- Uncomment the following line after replacing placeholders -->
<!-- [![Tests](https://github.com/<username>/<bucketname>/actions/workflows/ci.yml/badge.svg)](https://github.com/<username>/<bucketname>/actions/workflows/ci.yml) [![Excavator](https://github.com/<username>/<bucketname>/actions/workflows/excavator.yml/badge.svg)](https://github.com/<username>/<bucketname>/actions/workflows/excavator.yml) -->

Template bucket for [Scoop](https://scoop.sh), the Windows command-line installer.

## How do I use this template?

1. Generate your own copy of this repository with the "Use this template"
   button.
2. Allow all GitHub Actions:
   - Navigate to `Settings` - `Actions` - `General` - `Actions permissions`.
   - Select `Allow all actions and reusable workflows`.
   - Then `Save`.
3. Allow writing to the repository from within GitHub Actions:
   - Navigate to `Settings` - `Actions` - `General` - `Workflow permissions`.
   - Select `Read and write permissions`.
   - Then `Save`.
4. Document the bucket in `README.md`.
5. Replace the placeholder repository string in `bin/auto-pr.ps1`.
6. Create new manifests by copying `bucket/app-name.json.template` to
   `bucket/<app-name>.json`.
7. Commit and push changes.
8. If you'd like your bucket to be indexed on `https://scoop.sh`, add the
   topic `scoop-bucket` to your repository.

## How do I install these manifests?

After manifests have been committed and pushed, run the following:

```pwsh
scoop bucket add <bucketname> https://github.com/<username>/<bucketname>
scoop install <bucketname>/<manifestname>
```

## How do I contribute new manifests?

To make a new manifest contribution, please read the [Contributing
Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md)
and [App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)
wiki page.
