:::::::Auto Shutdown.bat::::::::

@echo off

title "Auto Shutdown"

echo Example: 3h ^| 3m ^| 3s

set /p time=time: 

if "%time:~-1%"=="s" set time=%time:~0,-1%
if "%time:~-1%"=="S" set time=%time:~0,-1%

if "%time:~-1%"=="m" set /a time=%time:~0,-1%*60
if "%time:~-1%"=="M" set /a time=%time:~0,-1%*60

if "%time:~-1%"=="h" set /a time=%time:~0,-1%*60*60
if "%time:~-1%"=="H" set /a time=%time:~0,-1%*60*60


start shutdown.exe -s -t %time%

::::::::::::::::::::::::::::::::
