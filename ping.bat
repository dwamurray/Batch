REM You might get unexpected 'inaccessible' for servers, which might be caused by them returning IPv6 addresses.
REM Use -4 switch to force use of IPv4 e.g. ping %%i -4 -n 1
REM -n 1 simply means only ping each server once.
REM Specify errorlevel 1 as the first condition, otherwise hosts that don't resolve will be considered to be 'up'


@echo off
if exist pingresults.txt (del pingresults.txt)  
for /F %%i in (servers.txt) do ping %%i -n 1 | find "TTL" > nul & 
if errorlevel 1 (echo %%i inaccessible >> pingresults.txt) 
else (echo %%i up >> pingresults.txt) 
