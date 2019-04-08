# Uncomment below for Powershell 2.0 only
#Import-Module ActiveDirectory
#Use this varilable to set working folder which contains "list.txt" file with a list of servers
#and will be used to store the output files
$folder="C:\temp\scanscript\"
$list=Get-Content  $($folder + "list.txt")
#Makes the value of the result into a table
$result=@()
#Sets initial value of i to 0 for counting loop
$i = 0

#Working through list of servers
foreach ($server in $list)
{
 
#Progress Bar
$total=$list.count
$i++
Write-Progress -Activity "Gathering Information" -status "Scanning Server $server - $i / $total"`
-percentComplete ($i / $list.count*100)
 
#Testing connection to the server, if unable to connect the server is added to error_connecting.txt file
If(!(Test-Connection -ComputerName $server -count 1 -quiet))
            {
            "$server - not reachable" | out-file $($folder + "error_connecting.txt") -Append
            }
                                   
else
            {
           
            #Testing if server folder already exists and deleting it                                
            if (Test-Path $($folder + $server) -PathType Any)
                        {
                        Remove-Item -Path $($folder + $server) -Confirm:$false -Recurse
                        }
           
            #Creating folder for the server
            New-Item -ItemType directory -Path $($folder + $server)
           
            #Creating and populating *-Disk.csv file for the server
            $("Type, Size, Index") | Out-File $($folder + $server + "\" +  $server + "-Disk.csv") -Append
            Get-WmiObject -Class Win32_DiskDrive -ComputerName $server | 
            foreach {$($_.Caption + "," + ([math]::Round($_.Size/ 1Gb)) + "," + $_.Index)} | 
            Out-File $($folder + $server + "\" +  $server + "-Disk.csv") -Append
            $("Drive Letter, Free, Total, Used, Name") |  
            Out-File $($folder + $server + "\" +  $server + "-Disk.csv") -Append
            Get-WmiObject -Class Win32_logicaldisk -ComputerName $server | 
            where {$_.DriveType -eq 3} |  
            foreach {$($_.DeviceID + "," + ($_.FreeSpace/ 1Gb) + "Gb," + ([math]::Round($_.Size/ 1Gb)) + "Gb," + $(([math]::Round($_.Size/ 1Gb))-([math]::Round($_.FreeSpace/ 1Gb))) + "Gb," +  $_.VolumeName)} | 
            Out-File $($folder + $server + "\" +  $server + "-Disk.csv") -Append -Encoding ascii
           
            #Creating and populating *-IIS.csv file for the server
            $sites=Get-WmiObject -Authentication PacketPrivacy -Impersonation Impersonate -ComputerName $server -namespace "root/MicrosoftIISv2"  -Class IIsWebServerSetting
            $("Site, Virtual Directory") | Out-File $($folder + $server + "\" +  $server + "-IIS.csv") -Append -Encoding ascii
            foreach ($site in $sites)
                        {
                        $iis=""
                        $sitename=""
                        $site.ServerComment | Out-File $($folder + $server + "\" +  $server + "-IIS.csv") -Append -Encoding ascii
                        Get-WmiObject -Authentication PacketPrivacy -Impersonation Impersonate -ComputerName $server -namespace "root/MicrosoftIISv2"  -Query "SELECT * FROM IIsWebVirtualDirSetting" | where {$_.Name -match $site.name} | foreach {$($site.ServerComment + "," + $_.path)} | Out-File $($folder + $server + "\" +  $server + "-IIS.csv") -Append -Encoding ascii
                        }
            #Creating and populating *-Services.csv file for the server
            $("Name, DisplayName, StartMode, Started, LogOnAs") | Out-File $($folder + $server + "\" +  $server + "-Services.csv") -Append -Encoding ascii
            Get-WmiObject win32_service -ComputerName $server | foreach {$($_.Name + "," + $_.DisplayName + "," + $_.StartMode + "," + $_.Started + "," + $_.StartName)} | Out-File $($folder + $server + "\" +  $server + "-Services.csv") -Append -Encoding ascii
           
            #Create and populating *-Applications.csv file for server
            $MasterKeys = @()
            $LMkeys = "Software\Microsoft\Windows\CurrentVersion\Uninstall","SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
            $LMtype = [Microsoft.Win32.RegistryHive]::LocalMachine
            $LMRegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($LMtype,$server)
            ForEach($Key in $LMkeys)
                        {
                                    $RegKey = $LMRegKey.OpenSubkey($key)
                                    ForEach($subName in $RegKey.getsubkeynames())
                                    {
                                                foreach($sub in $RegKey.opensubkey($subName))
                                                {
                                                            $MasterKeys += (New-Object PSObject -Property @{
                                                            "ComputerName" = $server
                                                            "Name" = $sub.getvalue("displayname")
                                                            "SystemComponent" = $sub.getvalue("systemcomponent")
                                                            "ParentKeyName" = $sub.getvalue("parentkeyname")
                                                            "Version" = $sub.getvalue("DisplayVersion")
                                                            "UninstallCommand" = $sub.getvalue("UninstallString")
                                                            })
                                                }
                                    }
                        }
                        $("Name, Version")  | Out-File $($folder + $server + "\" +  $server + "-Applications.csv") -Append -Encoding ascii
                        $MasterKeys = ($MasterKeys | Where {$_.Name -ne $Null -AND $_.SystemComponent -ne "1" -AND $_.ParentKeyName -eq $Null} | select Name,Version,ComputerName,UninstallCommand | sort Name)
                        foreach ($key in $masterkeys)
                                    {
                                                $($key.Name + "," + $key.Version)  | Out-File $($folder + $server + "\" +  $server + "-Applications.csv") -Append -Encoding ascii
                                    }
           
            #Create and populating *-Groups.csv file for server
           
            $groups=([ADSI]"WinNT://$Server,computer").psbase.children | where { $_.psbase.schemaClassName -eq 'group' } | foreach { ($_.name)[0]}
            $("Group, Members") | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append -Encoding ascii
            foreach ($Group in $groups)
                        {
                                    $Group | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append -Encoding ascii
                                    $members=$([ADSI]"WinNT://$Server/$Group,group").psbase.Invoke('Members') | foreach { $_.GetType().InvokeMember('ADspath', 'GetProperty', $null, $_, $null).Replace('WinNT://', '') }
                                    if ($members -is [system.array])
                                    {
                                                foreach ($member in $members)
                                                {
                                                            $("," + $member) | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append -Encoding ascii
                                                }
                                    }
                                    else
                                    {
                                                $("," + $member) | out-File $($folder + $server + "\" +  $server + "-Groups.csv") -Append -Encoding ascii
                                    }
                       
           
                        }
           
            #Create and populating *-Users.csv file for server
           
            $("Users") | out-File $($folder + $server + "\" +  $server + "-Users.csv") -Append -Encoding ascii
            ([ADSI]"WinNT://$Server,computer").psbase.children | where { $_.psbase.schemaClassName -eq 'user' } | foreach { ($_.name)}       | out-File $($folder + $server + "\" +  $server + "-Users.csv") -Append -Encoding ascii
                       
            #Create and populating *-IPConfig.csv file for server
           
           
            $("Description, IPAddress, DefaultGateway, IPSubnet, DNSServer, WINS1, WINS2, NIC Index") | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
            get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server | where {$_.IPaddress -ne $Null}  | foreach {$($_.Description + "," + $_.IPaddress + "," + $_.DefaultIPGateway + "," + $_.IPSubnet + "," + $_.DNSServerSearchOrder + "," + $_.WINSPrimaryServer + "," + $_.WINSSecondaryServer + "," + $_.index)} | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
           
                                   
           
            $routes=get-WmiObject Win32_IP4PersistedRouteTable -ComputerName $server
            $("Persistent Static Routes:") | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
            $("NetworkAddress, Netmask, GatewayAddress, Metric") | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
            foreach ($route in $routes)
                        {
 
                        $($route.Description) | out-File $($folder + $server + "\" +  $server + "-IPConfig.csv") -Append -Encoding ascii
    
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
            }
           
            #Get SPN
           
            $($([adsisearcher]"(&(objectCategory=Computer)(name=$server))").findall()).properties.serviceprincipalname  | out-File $($folder + $server + "\" +  $server + "-SPN.csv") -Append -Encoding ascii
 
            #Get Ciphers
            Import-Module psremoteregistry
            get-regvalue -computername $server -key system\currentcontrolset\control\securityproviders\schannel\ciphers -recurse |
            format-table -auto |
            out-File $($folder + $server + "\" +  $server + "-cipher.csv") -Append -Encoding ascii
}
