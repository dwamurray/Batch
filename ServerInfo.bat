@echo off
REM Could have had less echos but & is supported only for Windows 2000 and above
REM Basic commands piped into a text file
net use U: \\10.16.7.120\results
ipconfig /all > U:\%COMPUTERNAME%.txt

@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo Shares: >> U:\%COMPUTERNAME%.txt
@echo ====== >> U:\%COMPUTERNAME%.txt
net share >> U:\%COMPUTERNAME%.txt

@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo Established Connections: >> U:\%COMPUTERNAME%.txt
@echo ======================= >> %COMPUTERNAME%.txt
netstat -an | findstr -i ESTABLISHED >> U:\%COMPUTERNAME%.txt

@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo Listening on Ports: >> U:\%COMPUTERNAME%.txt
@echo ================== >> U:\%COMPUTERNAME%.txt
netstat -an | findstr -i LISTENING >> U:\%COMPUTERNAME%.txt

@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo Hosts File Contents: >> U:\%COMPUTERNAME%.txt
@echo =================== >> U:\%COMPUTERNAME%.txt
type "%systemroot%\system32\drivers\etc\hosts"  >> U:\%COMPUTERNAME%.txt

@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo LMHosts File Contents: >> U:\%COMPUTERNAME%.txt
@echo ===================== >> U:\%COMPUTERNAME%.txt
type "%systemroot%\system32\drivers\etc\lmhosts"  >> U:\%COMPUTERNAME%.txt

@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo Disk Information: >> U:\%COMPUTERNAME%.txt
@echo ================ >> U:\%COMPUTERNAME%.txt
diskpart -s U:\diskpart.txt >> U:\%COMPUTERNAME%.txt

regedit /e %COMPUTERNAME%.reg HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo Program Information: >> U:\%COMPUTERNAME%.txt
@echo =================== >> U:\%COMPUTERNAME%.txt
type %COMPUTERNAME%.reg | findstr -i "DisplayName" >> U:\%COMPUTERNAME%.txt

@echo =============================================================================== >> U:\%COMPUTERNAME%.txt
@echo Scheduled Tasks: >> U:\%COMPUTERNAME%.txt
@echo =================== >> U:\%COMPUTERNAME%.txt
schtasks /query >> U:\%COMPUTERNAME%.txt

del serverinfo.bat
net use U: /d
