for /F "usebackq delims==" %%i in ("localgroup.txt") do net localgroup %%i >> for.txt

