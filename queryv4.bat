@echo off

:: Set variables

set ciphers=HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers
set protocols=HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols
set dotnet="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP"

:: Remove any previously-generated output file

del %computername%-*.txt 2>nul

:: Print message to stdout

echo Please wait while the script queries the server ...

:: Prepare output file

echo ==================================== >>%computername%-info.txt
echo System information for %computername% >>%computername%-info.txt
echo ==================================== >>%computername%-info.txt
echo. >>%computername%-info.txt

:: Ensure WMIC initialization string not generated in output file

wmic cpu get > nul

:: Print OS

wmic os get caption | findstr "2003 2008 2012" >> %computername%-info.txt

:: Find whether 32- or 64-bit

wmic computersystem get systemtype | findstr "PC" >> %computername%-info.txt

:: Get service pack

wmic os get csdversion | findstr [0-2] >>%computername%-info.txt

:: Get free space on C drive

echo C: drive >>%computername%-info.txt
dir c:\ | find /i "bytes free" >>%computername%-info.txt

:: If Windows 2008 or above, skip to COE check

wmic os get caption | findstr "2008 2012" > nul & 
if %errorlevel% equ 0 goto coe

:: Check to see if KB948963 is installed (support for TLS 1.0 and AES 128 & 256 on Windows Server 2003 only)

reg query "HKLM\SOFTWARE\Microsoft\Updates\Windows Server 2003\SP3\KB948963" >nul 2>&1 &
if %errorlevel% equ 0 (
echo KB948963 is installed - supports TLS 1.0, AES 128 and 256 >>%computername%-info.txt
) else (
echo KB948963 is not installed - does not support TLS 1.0, AES 128 or 256 >>%computername%-info.txt
)

:: Check for KB4012598 (SMB patch Windows 2003 only)

reg query "HKLM\SOFTWARE\Microsoft\Updates\Windows Server 2003\SP3\KB4012598" >nul 2>&1 &
if %errorlevel% equ 0 (
echo Crit1 SMB patch KB4012598 is installed >>%computername%-info.txt
) else (
echo Crit1 SMB patch KB4012598 is not installed!!! >>%computername%-info.txt
)

:: Check if there is an RBS "SSPInstalled" Registry key

:coe

reg query "HKLM\SOFTWARE\RBS" /v SSPInstalled >nul 2>&1 &
if %errorlevel% equ 0 (
goto SSPInstalledValue
) else (
echo RBS COE not used on this server >>%computername%-info.txt
goto ciphers
)

:: If it does exist, get the COE version

:SSPInstalledValue

for /F "usebackq tokens=1-5 delims= " %%i in (
`reg query hklm\software\rbs /v "SSPInstalled"`
) do set coe=%%l

echo The patch level is %coe% >>%computername%-info.txt

:ciphers

echo. >>%computername%-info.txt
echo =================================================== >>%computername%-info.txt
echo Configuration of security ciphers on %computername% >>%computername%-info.txt
echo =================================================== >>%computername%-info.txt
echo. >>%computername%-info.txt

:: Get cipher configuration, varies by OS version

wmic os get caption | findstr "2003" > nul & 
if %errorlevel% equ 0 (
goto 2003ciphers
) else (
goto 2008ciphers
)

:2003ciphers

:null

reg query "%ciphers%\NULL" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for NULL cipher in Registry >>%computername%-info.txt
goto DES56
) else (
goto nullvalue
)

:nullvalue

for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\NULL" /v Enabled`
) do set NULL=%%k

if %NULL% equ 0 (
echo Null cipher is disabled >>%computername%-info.txt
) else (
echo Null cipher is not disabled! >>%computername%-info.txt
)

:DES56

reg query "%ciphers%\DES 56/56" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for DES 56/56 cipher in Registry >>%computername%-info.txt
goto RC2128
) else (
goto DES56value
)

:DES56value

for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\DES 56/56" /v Enabled`
) do set DES56=%%k 

if %DES56% equ 0 (
echo DES 56/56 cipher is disabled >>%computername%-info.txt
) else (
echo DES 56/56 cipher is not disabled! >>%computername%-info.txt
)


:RC2128

reg query "%ciphers%\RC2 128/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC2 128/128 cipher in Registry >>%computername%-info.txt
goto RC240
) else (
goto RC2128value
)

:RC2128value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC2 128/128" /v Enabled`
) do set RC2128=%%k 

if %RC2128% equ 0 (
echo RC2 128/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC2 128/128 cipher is not disabled! >>%computername%-info.txt
)


:RC240
reg query "%ciphers%\RC2 40/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC2 40/128 cipher in Registry >> %computername%-info.txt
goto RC256
) else (
goto RC240value
)

:RC240value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC2 40/128" /v Enabled`
) do set RC240=%%k 

if %RC240% equ 0 (
echo RC2 40/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC2 40/128 cipher is not disabled! >>%computername%-info.txt
)

:RC256
reg query "%ciphers%\RC2 56/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC2 56/128 cipher in Registry >> %computername%-info.txt
goto RC4128
) else (
goto RC256value
)

:RC256value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC2 56/128" /v Enabled`
) do set RC256=%%k 

if %RC256% equ 0 (
echo RC2 56/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC2 56/128 cipher is not disabled! >>%computername%-info.txt
)

:RC4128
reg query "%ciphers%\RC4 128/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC4 128/128 cipher in Registry >> %computername%-info.txt
goto RC440
) else (
goto RC4128value
)

:RC4128value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC4 128/128" /v Enabled`
) do set RC4128=%%k

if %RC4128% equ 0 (
echo RC4 128/128 cipher is disabled >>%computername%-info.txt
) else (
echo echo RC4 128/128 cipher is not disabled! >>%computername%-info.txt
)


:RC440
reg query "%ciphers%\RC4 40/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC4 40/128 cipher in Registry >> %computername%-info.txt
goto RC456
) else (
goto RC440value
)

:RC440value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC4 40/128" /v Enabled`
) do set RC440=%%k

if %RC440% equ 0 (
echo RC4 40/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC4 40/128 cipher is not disabled! >>%computername%-info.txt
)


:RC456

reg query "%ciphers%\RC4 56/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC4 56/128 cipher in Registry >> %computername%-info.txt
goto RC464
) else (
goto RC456value
)

:RC456value

for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC4 56/128" /v Enabled`
) do set RC456=%%k

if %RC456% equ 0 (
echo RC4 56/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC4 56/128 cipher is not disabled! >>%computername%-info.txt
)

:RC464

reg query "%ciphers%\RC4 64/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC4 64/128 cipher in Registry >> %computername%-info.txt
goto protocols
) else (
goto RC464value
)

:RC464value

for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC4 64/128" /v Enabled`
) do set RC464=%%k

if %RC464% equ 0 (
echo RC4 64/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC4 64/128 cipher is not disabled! >>%computername%-info.txt
)

goto protocols

:2008ciphers

:null
reg query "%ciphers%\NULL" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for NULL cipher in Registry >>%computername%-info.txt
goto DES56
) else (
goto nullvalue
)

:nullvalue
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\NULL" /v Enabled`
) do set NULL=%%k

if %NULL% equ 0 (
echo Null cipher is disabled >>%computername%-info.txt
) else (
echo Null cipher is not disabled >>%computername%-info.txt
)

:DES56
reg query "%ciphers%\DES 56/56" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for DES 56/56 cipher in Registry >>%computername%-info.txt
goto RC440
) else (
goto DES56value
)

:DES56value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\DES 56/56" /v Enabled`
) do set DES 56/56=%%k

if %DES 56/56% equ 0 (
echo DES 56/56 cipher is disabled >>%computername%-info.txt
) else (
echo DES 56/56 cipher is not disabled! >>%computername%-info.txt
)

:RC440
reg query "%ciphers%\RC4 40/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC4 40/128 cipher in Registry >>%computername%-info.txt
goto RC456
) else (
goto RC440value
)

:RC440value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC4 40/128" /v Enabled`
) do set RC4 40/128=%%k 

if %RC4 40/128% equ 0 (
echo RC4 40/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC4 40/128 cipher is not disabled! >>%computername%-info.txt
)

:RC456
reg query "%ciphers%\RC4 56/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC4 56/128 cipher in Registry >>%computername%-info.txt
goto RC4128
) else (
goto RC456value
)

:RC456value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC4 56/128" /v Enabled`
) do set RC4 56/128=%%k 

if %RC4 56/128% equ 0 (
echo RC4 56/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC4 56/128 cipher is not disabled! >>%computername%-info.txt
)

:RC4128
reg query "%ciphers%\RC4 128/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for RC4 128/128 cipher in Registry >>%computername%-info.txt
goto AES128
) else (
goto RC4128value
)

:RC4128value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\RC4 128/128" /v Enabled`
) do set RC4 128/128=%%k

if %RC4 128/128% equ 0 (
echo RC4 128/128 cipher is disabled >>%computername%-info.txt
) else (
echo RC4 128/128 cipher is not disabled! >>%computername%-info.txt
)

:AES128
reg query "%ciphers%\AES 128/128" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for AES 128/128 cipher in Registry >>%computername%-info.txt
goto AES256
) else (
goto AES128value
)

:AES128value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\AES 128/128" /v Enabled`
) do set AES 128/128=%%k 

if %AES 128/128% equ 0 (
echo AES 128 cipher is disabled! >>%computername%-info.txt
) else (
echo AES 128 cipher is enabled >>%computername%-info.txt
)

:AES256
reg query "%ciphers%\AES 256/256" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for AES 256/256 cipher in Registry >>%computername%-info.txt
goto 3DES
) else (
goto AES256value
)

:AES256value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\AES 256/256" /v Enabled`
) do set AES 256/256=%%k 

if %AES 256/256% equ 0 (
echo AES 256 cipher is disabled! >>%computername%-info.txt
) else (
echo AES 256 cipher is enabled >>%computername%-info.txt
)

:3DES
reg query "%ciphers%\Triple DES 168/168" /v Enabled >nul 2>&1 &
if %errorlevel% equ 1 (
echo No entry for Triple DES 168/168 cipher in Registry >>%computername%-info.txt
goto protocols
) else (
goto 3DESvalue
)

:3DESvalue
for /F "usebackq tokens=1-5" %%i in (
`reg query "%CIPHERS%\Triple DES 168/168" /v Enabled`
) do set Triple DES 168/168=%%k 

if %Triple DES 168/168% equ 0 (
echo Triple DES 168 cipher is disabled! >>%computername%-info.txt
) else (
echo Triple DES 168 cipher is enabled >>%computername%-info.txt
)

:protocols

echo. >>%computername%-info.txt
echo ===================================================== >>%computername%-info.txt
echo Configuration of security protocols on %computername% >>%computername%-info.txt
echo ===================================================== >>%computername%-info.txt
echo. >>%computername%-info.txt

:: Also need to check 2003 and 2008 / 2012 protocol suites separately

wmic os get caption | findstr "2003" > nul & 
if %errorlevel% equ 0 goto 2003protocols

:: If server is 2008 or above

wmic os get caption | findstr "2008 2012" > nul & 
if %errorlevel% equ 0 goto 2008protocols

:2003protocols

:SSL2
reg query "%protocols%\SSL 2.0\Server" /v Enabled >nul 2>&1 & 
if %errorlevel% equ 1 (
echo No entry for SSL 2.0 in Registry >> %computername%-info.txt
goto SSL3
) else (
goto SSL2VALUE
)

:SSL2VALUE
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\SSL 2.0\Server" /v Enabled`
) do set SSL2=%%k 

if %SSL2% equ 0 (
echo SSL 2.0 is disabled >>%computername%-info.txt
) else (
echo SSL 2.0 is not disabled! >>%computername%-info.txt
)

:SSL3
reg query "%protocols%\SSL 3.0\Server" /v Enabled >nul 2>&1 & 
if %errorlevel% equ 1 (
echo No entry for SSL 3.0 in Registry >> %computername%-info.txt
goto NET
) else (
goto SSL3VALUE
)

:SSL3VALUE
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\SSL 3.0\Server" /v Enabled`
) do set SSL3=%%k 

if %SSL3% equ 0 (
echo SSL 3.0 is disabled >>%computername%-info.txt
) else (
echo SSL 3.0 is not disabled! >>%computername%-info.txt
)

goto NET

:2008protocols

:SSL2
reg query "%protocols%\SSL 2.0\Server" /v Enabled >nul 2>&1 & 
if %errorlevel% equ 1 (
echo No entry for SSL 2.0 in Registry >> %computername%-info.txt
goto SSL3
) else (
goto SSL2VALUE
)

:SSL2VALUE
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\SSL 2.0\Server" /v Enabled`
) do set SSL2=%%k 


if %SSL2% equ 0 (
echo SSL 2.0 is disabled >>%computername%-info.txt
) else (
echo SSL 2.0 is not disabled! >>%computername%-info.txt
)

:SSL3
reg query "%protocols%\SSL 3.0\Server" /v Enabled >nul 2>&1 & 
if %errorlevel% equ 1 (
echo No entry for SSL 3.0 in Registry >> %computername%-info.txt
goto NET
) else (
goto SSL3VALUE
)

:SSL3VALUE
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\SSL 3.0\Server" /v Enabled`
) do set SSL3=%%k 

if %SSL3% equ 0 (
echo SSL 3.0 is disabled >>%computername%-info.txt
) else (
echo SSL 3.0 is not disabled! >>%computername%-info.txt
)

:TLS10

reg query "%protocols%\TLS 1.0\Server" /v Enabled >nul 2>&1 & 
if %errorlevel% equ 1 (
echo No entry for TLS 1.0 in Registry >> %computername%-info.txt
goto TLS11
) else (
goto TLS10value
)

:TLS10value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\TLS 1.0\Server" /v Enabled`
) do set TLS10=%%k 


if %TLS10% equ 0 (
echo TLS 1.0 is disabled! >>%computername%-info.txt
) else (
echo TLS 1.0 is enabled >>%computername%-info.txt
)


:TLS11

:: Check to see if DisabledByDefault is present and set to 0
reg query "%protocols%\TLS 1.1\Server" /v DisabledByDefault >nul 2>&1 & 
if %errorlevel% equ 1 (
echo DisabledByDefault is not set for TLS 1.1, please create it and set the value to 0 >> %computername%-info.txt
goto TLS11enabled) else (
goto TLS11default
)

:TLS11default
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\TLS 1.2\Server" /v DisabledByDefault`
) do set TLS11enable=%%k

if %TLS11enable% equ 0 (
echo TLS 1.1 is enabled by default >>%computername%-info.txt
) else (
echo TLS 1.1 is disabled by default >>%computername%-info.txt
)

:: Now check to see TLS 1.1 is explicitly enabled

:TLS11enabled
reg query "%protocols%\TLS 1.1\Server" /v Enabled >nul 2>&1 & 
if %errorlevel% equ 1 (
echo No entry for TLS 1.1 in Registry >> %computername%-info.txt
goto TLS12
) else (
goto TLS11value
)

:TLS11value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\TLS 1.1\Server" /v Enabled`
) do set TLS11=%%k 

if %TLS11% equ 0 (
echo TLS 1.1 is disabled! >>%computername%-info.txt
) else (
echo TLS 1.1 is enabled >>%computername%-info.txt
)


:TLS12

:: Check to see if DisabledByDefault is present and set to 0
reg query "%protocols%\TLS 1.2\Server" /v DisabledByDefault >nul 2>&1 & 
if %errorlevel% equ 1 (
echo DisabledByDefault is not set for TLS 1.2, please create it and set the value to 0 >> %computername%-info.txt
goto TLS12enabled
) else (
goto TLS12default
)

:TLS12default
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\TLS 1.2\Server" /v DisabledByDefault`
) do set TLS12default=%%k

if %TLS12default% equ 0x0 (
echo TLS 1.2 is enabled by default >>%computername%-info.txt
) else (
echo TLS 1.2 is disabled by default >>%computername%-info.txt
)

:: Now check to see TLS 1.2 is explicitly enabled

:TLS12enabled
reg query "%protocols%\TLS 1.2\Server" /v Enabled >nul 2>&1 & 
if %errorlevel% equ 1 (
echo No Enabled entry for TLS 1.2 in Registry >> %computername%-info.txt
goto NET
) else (
goto TLS12value
)

:TLS12value
for /F "usebackq tokens=1-5" %%i in (
`reg query "%PROTOCOLS%\TLS 1.2\Server" /v Enabled`
) do set TLS12=%%k 

if %TLS12% equ 0 (
echo TLS 1.2 is disabled! >>%computername%-info.txt
) else (
echo TLS 1.2 is enabled >>%computername%-info.txt
)

:: Query for the versions of .NET installed

:NET
echo. >>%computername%-info.txt
echo ============================================ >>%computername%-info.txt
echo Versions of .NET installed on %computername% >>%computername%-info.txt
echo ============================================ >>%computername%-info.txt
echo. >>%computername%-info.txt

:: .NET 1

reg query %dotnet% /f 1. >nul 2>&1 &
if %errorlevel% equ 0 (
echo .NET 1 installed >>%computername%-info.txt
) else (
echo .NET 1 not installed >>%computername%-info.txt
)

:: .NET 2

reg query %dotnet% /f 2. >nul 2>&1 &
if %errorlevel% equ 0 (
echo .NET 2 installed >>%computername%-info.txt
) else (
echo .NET 2 not installed >>%computername%-info.txt
)

:: .NET 3.5

reg query %dotnet% /f 3.5 >nul 2>&1 &
if %errorlevel% equ 0 (
echo .NET 3.5 installed >>%computername%-info.txt
) else (
echo .NET 3.5 not installed >>%computername%-info.txt
)

:: .NET 4

reg query %dotnet% /f 4. >nul 2>&1 &
if %errorlevel% equ 0 (
echo .NET 4 installed >>%computername%-info.txt
) else (
echo .NET 4 not installed >>%computername%-info.txt
)

:: Obtain list of KBs installed

echo. >>%computername%-info.txt
echo ===================================== >>%computername%-info.txt
echo Patches installed on %computername% >>%computername%-info.txt
echo ===================================== >>%computername%-info.txt
echo. >>%computername%-info.txt

wmic qfe get hotfixid /format:table | findstr KB* >>%computername%-info.txt