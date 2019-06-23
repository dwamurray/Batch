@echo off
set /a FILE_COUNT=0
:NEXT_FILE
if {%1}=={} (echo %FILE_COUNT% file^(s^) deleted) & (goto :EOF)
del %1
set /a FILE_COUNT+=1
shift /1
goto :NEXT_FILE 