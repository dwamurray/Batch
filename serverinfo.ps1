# Uncomment below for Powershell 2.0 only
#Import-Module ActiveDirectory
#Use this variable to set working folder which contains "list.txt" file with a list of servers
#and will be used to store the output files
$folder = "C:\temp\scanscript\"
$list = Get-Content "$folder\list.txt"
#Sets initial value of i to 0 for counting loop
$i = 0

#Working through list of servers
foreach (
$server in $list
) { 
#Progress Bar
$total = $list.count
$i++
Write-Progress -Activity "Gathering Information" -status "Scanning Server $server - $i / $total"`
-percentComplete ($i / $list.count*100)

#Testing connection to the server, if unable to connect the server name is added to errors.txt file
# Loop then starts again with next server in the list

if ( 
!(Test-Connection -ComputerName $server -count 1 -quiet) 
) {
"$server - not reachable" | out-file "$folder\errors.txt" -Append
continue
} else {
     
#Remove folder if it already exists                              

if (
Test-Path "$folder\$server" -PathType Any
) {
Remove-Item -Path "$folder\$server" -Force -Recurse
}

#Creating folder for the server
New-Item -ItemType directory -Path "$folder\$server"
           
#Creating and populating *-Disk.csv file for the server

"Drive letter,Space Free,Total size,Used space,Name" |
Out-File "$folder\$server\$server-Disk.csv" -Append

#Obtain information about logical drives and add to *-Disk.csv
Get-WmiObject -Class Win32_logicaldisk -ComputerName $server | 
where {$_.DriveType -eq 3} |
foreach {$($_.DeviceID + "," + ($_.FreeSpace/ 1MB -as [int]) + "MB," + ($_.Size/ 1MB -as [int])`
+ "MB," + $(($_.Size/ 1MB -as [int]) - ($_.FreeSpace/ 1MB -as [int])) + "MB," +  $_.VolumeName)} |
Out-File "$folder\$server\$server-Disk.csv" -Append

#Creating and populating *-IIS.csv file for the server

"IIS directory" | out-file "$folder\$server\$server-IIS.csv" -Append

Get-WmiObject -ComputerName localhost -namespace "root/MicrosoftIISv2"`
-Query "SELECT * FROM IIsWebVirtualDirSetting" |
select -expand path |
out-file "$folder\$server\$server-IIS.csv" -Append

"Website, Application Pool ID" | out-file "$folder\$server\$server-IIS.csv" -Append
Get-WmiObject -namespace "root/MicrosoftIISv2" -Class IIsWebServerSetting | 
foreach {$($_.ServerComment + "," + $_.AppPoolID)} |
out-file "$folder\$server\$server-IIS.csv" -Append

#Creating and populating *-Services.csv file for the server
$("Name, DisplayName, StartMode, Started, LogOnAs") | 
Out-File "$folder\$server\$server-Services.csv" -Append

Get-WmiObject win32_service -ComputerName $server | 
foreach {$($_.Name + "," + $_.DisplayName + "," + $_.StartMode + "," + $_.Started + "," + $_.StartName)} | 
Out-File "$folder\$server\$server-Services.csv" -Append
           
#Create and populating *-Applications.csv file for server

"Software\Microsoft\Windows\CurrentVersion\Uninstall",
"SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
          
#Create and populating *-Groups.csv file for server
           
$groups=([ADSI]"WinNT://$Server,computer").psbase.children | 
where { $_.psbase.schemaClassName -eq 'group' } | 
foreach { ($_.name)[0]}
$("Group, Members") | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append -Encoding ascii
foreach (
$Group in $groups
) {
$Group | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append -Encoding ascii
$members=$([ADSI]"WinNT://$Server/$Group,group").psbase.Invoke('Members') | foreach { $_.GetType().InvokeMember('ADspath', 'GetProperty', $null, $_, $null).Replace('WinNT://', '') }
if (
$members -is [system.array]
) {
foreach (
$member in $members
) {
$("," + $member) | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append
}
}
else {
$("," + $member) | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append
}
}
           
#Create and populating *-Users.csv file for server
           
$("Users") | out-File $($folder + $server + "\" +  $server + "-Users.csv") -Append -Encoding ascii
([ADSI]"WinNT://$Server,computer").psbase.children | 
where { $_.psbase.schemaClassName -eq 'user' } | 
foreach { ($_.name)} | 
out-File $($folder + $server + "\" +  $server + "-Users.csv") -Append 
                       
#Create and populating *-IPConfig.csv file for server

$("Description, IPAddress, DefaultGateway, IPSubnet, DNSServer, WINS1, WINS2, NIC Index") | 
out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append
get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server | 
where {$_.IPaddress -ne $Null}  | 
foreach {$($_.Description + "," + $_.IPaddress + "," + $_.DefaultIPGateway + "," + $_.IPSubnet + "," + $_.DNSServerSearchOrder + "," + $_.WINSPrimaryServer + "," + $_.WINSSecondaryServer + "," + $_.index)} | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
           
$routes=get-WmiObject Win32_IP4PersistedRouteTable -ComputerName $server
$("Persistent Static Routes:") | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
$("NetworkAddress, Netmask, GatewayAddress, Metric") | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
foreach (
$route in $routes
) {
$($route.Description) | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append
}

#Creating and populating *-System.csv file for the server
           
$system=Get-WmiObject Win32_Computersystem -ComputerName $server
$os=Get-WmiObject Win32_operatingsystem -ComputerName $server
$("Model, OS_Version, Service_Pack, CPUs, Memory_MB, OU") | out-File $($folder + $server + "\" +  $server + "-System.csv") -Append -Encoding ascii
$($system.Model + "," + $(($os.Caption) -replace ",", "") + $os.CSDVersion + "," + $system.NumberOfProcessors + "," + $([math]::Round($system.TotalPhysicalMemory/ 1MB))) + "," + $(((Get-ADComputer $Env:COMPUTERNAME).DistinguishedName) -replace ",", ".")  | out-File $($folder + $server + "\" +  $server + "-System.csv") -Append -Encoding ascii
           
#Creating and populating *-Shares.csv file for the server
$("Name, Path, Description") | out-File $($folder + $server + "\" +  $server + "-Shares.csv") -Append -Encoding ascii
Get-WmiObject Win32_share -ComputerName $server | foreach $({$_.Name + "," + $_.Path + "," + $_.Description}) | out-File $($folder + $server + "\" +  $server + "-Shares.csv") -Append -Encoding ascii
           
#Copy host file
           
Copy-Item -Path $("\\"+ $Server + "\C$\windows\system32\drivers\etc\hosts") -Destination $($folder + $server)

           
#Get SPN
           
$($([adsisearcher]"(&(objectCategory=Computer)(name=$server))").findall()).properties.serviceprincipalname  | out-File $($folder + $server + "\" +  $server + "-SPN.csv") -Append -Encoding ascii

}
}
