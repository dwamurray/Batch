# This is the 'worker function' that does the querying

function query {

# Declare parameter

param($server)

BEGIN {

$ev = "False"

try {
get-wmiobject win32_operatingsystem -ComputerName $server -ea stop | out-null
} catch {
"Cannot contact $server" | out-file errors.txt -append
$ev = "True"
}

}

PROCESS {

if ( $ev -eq "False" ) {

$cipherpath = "HKLM\system\currentcontrolset\control\securityproviders\schannel\ciphers"
$protocolpath = "HKLM\system\currentcontrolset\control\securityproviders\schannel\protocols"

$nullcipher = reg query \\$server\$cipherpath\null /v Enabled 2>&1
if ( $LASTEXITCODE -eq "1" ) 
{ $nullcipher = "Not configured" } 
elseif (
($nullcipher | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($nullcipher | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $nullcipher = "Disabled" }
else { $nullcipher = "Enabled" }

$DES56 = reg query "\\$server\$cipherpath\DES 56/56" /v Enabled 2>&1
if ( $LASTEXITCODE -eq "1" )
{ $DES56 = "Not configured" }
elseif (
($DES56 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($DES56 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $DES56 = "Disabled" }
else { $DES56 = "Enabled" }

$RC4128 = reg query "\\$server\$cipherpath\RC4 128/128" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $RC4128 = "Not configured" }
elseif (
($RC4128 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($RC4128 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $RC4128 = "Disabled" }
else { $RC4128 = "Enabled" }

$RC440 = reg query \\$server\$cipherpath\"RC4 40/128" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $RC440 = "Not configured" }
elseif (
($RC440 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($RC440 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $RC440 = "Disabled" }
else { $RC440 = "Enabled" }

$RC456 = reg query "\\$server\$cipherpath\RC4 56/128" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $RC456 = "Not configured" }
elseif (
($RC456 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($RC456 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $RC456 = "Disabled" }
else { $RC456 = "Enabled" }

$RC464 = reg query "\\$server\$cipherpath\RC4 64/128" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $RC464 = "Not configured" }
elseif (
($RC464 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($RC464 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $RC464 = "Disabled" }
else { $RC464 = "Enabled" }

$AES128 = reg query "\\$server\$cipherpath\AES 128/128" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $AES128 = "Not configured" }
elseif (
($AES128 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($AES128 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $AES128 = "Disabled" }
else { $AES128 = "Enabled" }

$AES256 = reg query "\\$server\$cipherpath\AES 256/256" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $AES256 = "Not configured" }
elseif ( 
($AES256 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($AES256 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $AES256 = "Disabled" }
else { $AES256 = "Enabled" }

$3D  = reg query "\\$server\$cipherpath\Triple DES 168/168" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $3D = "Not configured" }
elseif ( 
($3D | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($3D | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $3D = "Disabled" }
else { $3D = "Enabled" }

$SSL2 = reg query "\\$server\$protocolpath\SSL 2.0\Server" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $SSL2 = "Not configured" }
elseif ( 
($SSL2 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($SSL2 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $SSL2 = "Disabled" }
else { $SSL2 = "Enabled" }

$SSL3 = reg query "\\$server\$protocolpath\SSL 3.0\Server" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" ) 
{ $SSL3 = "Not configured" } 
elseif ( 
($SSL3 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($SSL3 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
) 
{ $SSL3 = "Disabled" } 
else { $SSL3 = "Enabled" }

$TLS10 = reg query "\\$server\$protocolpath\TLS 1.0\Server" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $TLS10 = "Not configured" }
elseif ( 
($TLS10 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($TLS10 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $TLS10 = "Disabled" }
else { $TLS10 = "Enabled" }

$TLS10D = reg query "\\$server\$protocolpath\TLS 1.0\Server" /v DisabledByDefault  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $TLS10D = "DisabledByDefault key not present" }
elseif ( 
($TLS10D | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($TLS10D | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $TLS10D = "Enabled by default" }
else { $TLS10D = "Disabled by default" }

$TLS11 = reg query "\\$server\$protocolpath\TLS 1.1\Server" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $TLS11 = "Not configured" }
elseif ( 
($TLS11 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($TLS11 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $TLS11 = "Disabled" }
else { $TLS11 = "Enabled" }

$TLS11D = reg query "\\$server\$protocolpath\TLS 1.1\Server" /v DisabledByDefault  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $TLS11D = "DisabledByDefault key not present" }
elseif ( 
($TLS11D | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($TLS11D | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $TLS11D = "Enabled by default" }
else { $TLS11D = "Disabled by default" }

$TLS12 = reg query "\\$server\$protocolpath\TLS 1.2\Server" /v Enabled  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $TLS12 = "Not configured" }
elseif ( 
($TLS12 | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($TLS12 | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $TLS12 = "Disabled" }
else { $TLS12 = "Enabled" }

$TLS12D = reg query "\\$server\$protocolpath\TLS 1.2\Server" /v DisabledByDefault  2>&1
if ( $LASTEXITCODE -eq "1" )
{ $TLS12D = "DisabledByDefault key not present" }
elseif ( 
($TLS12D | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ($TLS12D | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $TLS12D = "Enabled by default" }
else { $TLS12D = "Disabled by default" }

$obj = new-object –typename psobject

$obj | add-member –membertype noteproperty `
-name Server –value $server
 
$obj | add-member –membertype noteproperty `
-name "Null cipher" -value $nullcipher

$obj | add-member –membertype noteproperty `
-name "DES 56/56" -value $des56

$obj | add-member –membertype noteproperty `
-name "RC4 128/128" -value $RC4128

$obj | add-member –membertype noteproperty `
-name "RC4 40/128" -value $RC440

$obj | add-member –membertype noteproperty `
-name "RC4 56/128" -value $RC456

$obj | add-member –membertype noteproperty `
-name "RC4 64/128" -value $RC464

$obj | add-member –membertype noteproperty `
-name "AES 128/128" -value $AES128

$obj | add-member –membertype noteproperty `
-name "AES 256/256" -value $AES256

$obj | add-member –membertype noteproperty `
-name "Triple DES 168/168" -value $3D

$obj | add-member -membertype noteproperty `
-name "SSL 2.0" -value $SSL2

$obj | add-member -membertype noteproperty `
-name "SSL 3.0" -value $SSL3

$obj | add-member -membertype noteproperty `
-name "TLS 1.0" -value $TLS10

$obj | add-member -membertype noteproperty `
-name "TLS 1.0 DisabledByDefault" -value $TLS10D

$obj | add-member -membertype noteproperty `
-name "TLS 1.1" -value $TLS11

$obj | add-member -membertype noteproperty `
-name "TLS 1.1 DisabledByDefault" -value $TLS11D

$obj | add-member -membertype noteproperty `
-name "TLS 1.2" -value $TLS12

$obj | add-member -membertype noteproperty `
-name "TLS 1.2 DisabledByDefault" -value $TLS12D

Write-output $obj

}

}

END {}

function get-securityproviders {

[CmdletBinding()]
param (	
[Parameter(Mandatory=$True,
ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True)]
[string[]]$server
)


BEGIN {
$usedParameter = $False
if ($PSBoundParameters.ContainsKey('server')) {
$usedParameter = $True
}

}
PROCESS {
if ($usedParameter) {
foreach ($line in $server) {
query $server
}

} else {
query $_
}
}
END {}
} 

#####################################
# Run using any of these formats:
# get-securityproviders -server david-lap | export-csv results.csv
# 'server1','server2','server3' | get-securityproviders | export-csv results.csv
# get-content servers.txt | get-securityproviders | export-csv results.csv
######################################

'david-lap','booby' | get-securityproviders | export-csv results.csv -NoTypeInformation
