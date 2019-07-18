REM Used to chain together multiple installations
REM Waits until current installation completed before moving to next

@echo off

net use S: \\gbmacengfs2\OfflineSUG
S:

start /wait SUP_2016_WindowsServerAll_GoldSource\ExecuteMSPath.exe
start /wait SUP_201701_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201703_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201704_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201705_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201706_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201707_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201708_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201709_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201710_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201711_WindowsServerAll_CritAll\ExecuteMSPath.exe
start /wait SUP_201712_WindowsServerAll_CritAll\ExecuteMSPath.exe

net use S: /delete
