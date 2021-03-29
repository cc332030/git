@echo off

:clone
echo.
set /p project=请输入项目地址：

cls
echo.
git clone git@gitee.com:c332030/%project%

goto clone
