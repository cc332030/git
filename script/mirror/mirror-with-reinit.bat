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

git pull

rmdir /s /q .\.git >nul 2>&1

echo.
git init

git add -A

echo.
git commit -m init

git remote add origin %git_remote%

echo.
git push origin master --force

goto start
