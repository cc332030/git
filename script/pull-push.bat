@echo off

:start

echo.
set /p dir=请输入目录：

echo.
set branch=
set /p branch=请输入分支（master）：

cls

if not defined branch (
  set branch=master
)

echo.
echo branch %branch% of  %dir%

cd /d %dir%

echo.
git pull origin %branch%

echo.
git push origin %branch%

goto start
