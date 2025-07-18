@echo off

:: setx /m GIT_HOME %~dp0app

call link-file %~dp0 %userprofile% .gitconfig

pause
