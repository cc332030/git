@echo off
title set-upstream

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
git branch --set-upstream-to=origin/%branch% %branch%

goto start
