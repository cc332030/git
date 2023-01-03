@echo off

set username=c332030

for /d %%i in (%~dp0\*) do (
  cd %~dp0%%~ni
  git config user.name %username%
rem   git config --unset user.name
  git config user.name
)

pause >nul
