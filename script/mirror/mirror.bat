@echo off

:start

echo.
set /p work_path=请输入目录：

echo.
set /p git_remote=请输入远程路径：

cls

echo.
xcopy /y %~dp0mirror.yml %work_path%\.github\workflows\

cd %work_path%

git pull origin master

git add -A

echo.
git commit -m mirror

git branch -M main

git remote remove origin
git remote add origin %git_remote%

echo.
git push origin main --force

goto start
