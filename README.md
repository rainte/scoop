# Scoop Bucket Template

```bash
# 自动更新版本.
.\bin\checkver.ps1 -f
# 更新 Token.
scoop config gh_token "GITHUB_TOKEN"
# 设置代理.
scoop config proxy 127.0.0.1:1080
scoop config rm proxy
# 开始菜单.
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Scoop Apps
# 重启资源管理器.
taskkill /f /im explorer.exe
explorer.exe
# 杀死进程.
taskkill /f /pid 110
```

| 名称        | 类型   |
| ----------- | ------ |
| 360zip      | 压缩   |
| adobe       | 设计   |
| alipan      | 云盘   |
| android     | IDE    |
| chrome      | 浏览器 |
| fdm         | 下载   |
| fiddler     | 抓包   |
| fnm         | Node   |
| idea        | IDE    |
| jdgui       | Java   |
| jdk17       | Java   |
| jdk21       | Java   |
| jdk8        | Java   |
| mobaxterm   | 终端   |
| motrix      | 下载   |
| navicat     | 数据库 |
| office      | 办公   |
| postman     | 接口   |
| pyenv       | Python |
| qq          | 聊天   |
| qqmusic     | 音频   |
| search      | Scoop  |
| sigil       | EPUB   |
| singbox     | 翻墙   |
| sun         | 远程   |
| tortoisesvn | 版本   |
| vagrant     | 虚拟机 |
| virtualbox  | 虚拟机 |
| vscode      | IDE    |
| wechat      | 聊天   |
| wegame      | 游戏   |
| wepe        | 装机   |
| wireshark   | 抓包   |
| ximalaya    | 音频   |

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
