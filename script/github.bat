@echo off

:start
cd /d %~dp0
echo.
set /p name=请输入项目地址：

cls
echo.
git clone git@github.com:c332030/%name% || ( echo. && git clone git@github.com:cc332030/%name% )

goto start
