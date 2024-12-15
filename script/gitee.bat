@echo off

:clone
cd /d %~dp0
echo.
set /p project=请输入项目地址：

cls
echo.
git clone git@gitee.com:c332030/%project%

goto clone
