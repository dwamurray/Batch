function get-ciphers {
 
$ciphers = dir HKLM:\system\currentcontrolset\control\securityproviders\schannel\ciphers | select -expand pschildname
 
foreach ( $cipher in $ciphers )
 
{
$result = if ( test-path "HKLM:\system\currentcontrolset\control\securityproviders\schannel\ciphers\$cipher\enabled" )
{ get-itemproperty -path "HKLM:\system\currentcontrolset\control\securityproviders\schannel\ciphers\$cipher" |
select -expand enabled }
else {
"not configured" }
 
$value = if ( $result -eq "0" )
{ echo Disabled }
elseif ( $result -eq "not configured" )
{ echo "not configured" }
else { echo Enabled }
 
$obj = new-object –typename psobject
 
$obj | add-member –membertype noteproperty `
-name Cipher –value $cipher
 
$obj | add-member –membertype noteproperty `
-name value $value
 
Write-output $obj
}
 
                        }
 
get-ciphers | ft -auto | out-file ciphers.txt
