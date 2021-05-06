@echo off

:start

echo.
set /p dir=请输入目录：

echo.
set /p branch=请输入分值（master）：

cls

if not defined branch (
  set branch=master
)

echo use branch: %branch%

cd /d %dir%

echo.
git pull origin %branch%

echo.
git push origin %branch%

goto start
