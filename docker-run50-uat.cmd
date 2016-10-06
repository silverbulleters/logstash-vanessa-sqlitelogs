@echo off

set CURPWD=%cd%
set CURPWD=%CURPWD:\=/%

@echo %CURPWD%

sh -c "./docker-run50-uat.sh "%CURPWD%
