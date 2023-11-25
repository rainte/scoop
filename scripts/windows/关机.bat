:::::::定时关机.bat::::::::

@echo off

title 定时关机

echo 举例: 3h 或 3m 或 3s

set /p time=时间: 

if "%time:~-1%"=="s" set time=%time:~0,-1%
if "%time:~-1%"=="S" set time=%time:~0,-1%

if "%time:~-1%"=="m" set /a time=%time:~0,-1%*60
if "%time:~-1%"=="M" set /a time=%time:~0,-1%*60

if "%time:~-1%"=="h" set /a time=%time:~0,-1%*60*60
if "%time:~-1%"=="H" set /a time=%time:~0,-1%*60*60


start shutdown.exe -s -t %time%

::::::::::::::::::::::::::::::::
