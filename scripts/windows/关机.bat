:::::::Auto Shutdown.bat::::::::

@echo off

title "Auto Shutdown"

echo Example: 1h ^| 1m ^| 1s

set /p time=time[1h]: 

if "%time%"=="" set "time=1h"

if "%time:~-1%"=="s" set time=%time:~0,-1%
if "%time:~-1%"=="S" set time=%time:~0,-1%

if "%time:~-1%"=="m" set /a time=%time:~0,-1%*60
if "%time:~-1%"=="M" set /a time=%time:~0,-1%*60

if "%time:~-1%"=="h" set /a time=%time:~0,-1%*60*60
if "%time:~-1%"=="H" set /a time=%time:~0,-1%*60*60


start shutdown.exe -s -t %time%

::::::::::::::::::::::::::::::::
