@echo off

md c:\mig

ipconfig /all > c:\mig\mig_ip_config.txt

net user xtravirtmig Password123! /add 

net localgroup Administrators xtravirtmig /add

exit