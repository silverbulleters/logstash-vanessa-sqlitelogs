@echo off

set CURPWD=%cd%
set CURPWD=%CURPWD:\=/%

@echo %CURPWD%

sh -c "./docker-logstash-only.sh "%CURPWD%