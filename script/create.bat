@echo off

:start
cd %~dp0
echo.
set /p name=请输入名称：

cls

mkdir %name%

cd %name%

echo.
git init

git remote add gitee git@gitee.com:c332030/%name%.git
git remote add github git@github.com:c332030/%name%.git

echo.
git remote -v

goto start
