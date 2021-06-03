@echo off

set user=c332030
title user: %user%
goto start

:start
echo.
set /p dir=请选择目录：

cls

cd /d %dir%
call :update_repo %dir%

:update_repo
set dir_name=%~n1

echo.
echo repo: %dir_name%

git remote remove origin
git remote add origin git@github.com:%user%/%dir_name%

call :push master || call :push main
goto start

:push
echo.
echo branch: %1
(git pull origin %1 && git push origin %1) || echo /b 1
