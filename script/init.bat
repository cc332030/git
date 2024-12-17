@echo off

setx /m GIT_HOME %~dp0app

call link-file %~dp0data %userprofile% .gitconfig
call link-file %~dp0data %userprofile% .git-credentials

pause
