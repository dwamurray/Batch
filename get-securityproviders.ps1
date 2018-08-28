function querywork {

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

$cipherpath = "\\$server\HKLM\system\currentcontrolset\control\securityproviders\schannel\ciphers"
$ciphers = @(
'NULL',
'DES 56/56',
'RC2 128/128',
'RC2 40/128',
'RC2 56/128',
'RC2 64/128',
'RC4 128/128',
'RC4 40/128',
'RC4 56/128',
'RC4 64/128',
'AES 128/128',
'AES 256/256',
'Triple DES 168/168',
'Triple DES 168'
)

$protocolpath = "\\$server\HKLM\system\currentcontrolset\control\securityproviders\schannel\protocols"
$protocols = @(
'SSL 2.0\Client',
'SSL 2.0\Server',
'SSL 3.0\Client',
'SSL 3.0\Server',
'TLS 1.0\Client',
'TLS 1.0\Server',
'TLS 1.1\Client',
'TLS 1.1\Server',
'TLS 1.2\Client',
'TLS 1.2\Server'
)

$os = get-wmiobject win32_operatingsystem -ComputerName $server | 
select -expand caption

$obj = new-object -typename psobject

$obj | add-member -membertype noteproperty `
-name Server -value $server

$obj | add-member -membertype noteproperty `
-name "Operating system" -value $os

foreach ( $cipher in $ciphers ) {
$value = reg query $cipherpath\$cipher /v Enabled 2>&1
if ( $LASTEXITCODE -eq "1" )
{ $value = "Not configured" }
elseif ( 
( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $value = "Disabled" }
else { $value = "Enabled" }

$obj | add-member -membertype noteproperty `
-name "$cipher cipher" -value $value

}

foreach ( $protocol in $protocols ) {
$value = reg query "$protocolpath\$protocol" /v Enabled 2>&1
if ( $LASTEXITCODE -eq "1" )
{ $value = "Not configured" }
elseif ( 
( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $value = "Disabled" }
else { $value = "Enabled" }

$obj | add-member -membertype noteproperty `
-name "$protocol protocol" -value $value

}

foreach ( $protocol in $protocols ) {
$value = reg query "$protocolpath\$protocol" /v DisabledByDefault 2>&1
if ( $LASTEXITCODE -eq "1" )
{ $value = "Not configured" }
elseif ( 
( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0x0"`
-or ( $value | select-string ".x." | select -expand matches | select -expand value) -eq "0"
)
{ $value = "Yes" }
else { $value = "No" }

$obj | add-member -membertype noteproperty `
-name "$protocol protocol DisabledByDefault" -value $value

}

write-output $obj

}
}
}

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
querywork $server
}

} else {
querywork $_
}
}
END {}
} 

# Run using one of these formats:
#get-content servers.txt | .\get-securityproviders.ps1 | export-csv results.csv -notype

'localhost' | .\get-securityproviders.ps1 | export-csv results.csv -notype
