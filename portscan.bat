REM Need to put portqry.exe into same directory as script OR provide full path to portqry.exe
REM This checks to see if port 3389 (for RDP) is open on the servers
REM Good alternative to ping scan, but obviously no match for nmap
REM -q switch makes the output of portqry.exe quiet unless an error is generated

@echo off
if exist portresults.txt (del portresults.txt)
for /F "delims==" %%i in (servers.txt) do portqry.exe -n %%i -e 3389 -q & if errorlevel 99
( 
echo "cannot resolve %%i" >> portresults.txt) else ( 
if errorlevel 1 ( 
echo "%%i not listening" >> portresults.txt) else 
 (if errorlevel 2 
 (echo "%%i filtered or offline" >>portresults.txt) 
  else (echo "%%i accessible" >> portresults.txt) 
 )
)
