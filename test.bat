@echo off
setlocal enabledelayedexpansion
cd %~dp0
cd ..
set classpath=.
for %%c in (lib\*.jar) do set classpath=!classpath!;%%c
set classpath=%classpath%;
echo %classpath%
pause;