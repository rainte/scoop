@echo off
%1 start "" mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d %~dp0
cd singbox

choice /C 123 /T 15 /D 3 /M "1: ip1更新 2: ip2更新 3: 跳过"

if errorlevel 1 goto ip1
if errorlevel 2 goto ip2
if errorlevel 3 goto run

:ip1
..\..\wget -t 2 --no-check-certificate https://www.gitlabip.xyz/Alvin9999/pac2/master/singbox/1/config.json
..\..\wget -t 2 --no-check-certificate https://gitlab.com/free9999/ipupdate/-/raw/master/singbox/config.json
if exist config.json goto copy

:ip2
..\..\wget -t 2 --no-check-certificate https://www.githubip.xyz/Alvin9999/pac2/master/singbox/config.json
..\..\wget -t 2 --no-check-certificate https://fastly.jsdelivr.net/gh/Alvin9999/pac2@latest/singbox/config.json
if exist config.json goto copy

:copy
del "..\config.json_backup"
ren "..\config.json"  config.json_backup
copy /y "%~dp0config.json" ..\config.json
del "%~dp0config.json"
goto run

:run
start "" "sing-box.exe" run -c config.json

cd ..
start chrome
