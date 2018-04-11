
$cipherpath = "HKLM\system\currentcontrolset\control\securityproviders\schannel\ciphers"
$ciphers = @(
'null',
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
'Triple DES 168/168'
)


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

$ciphertable = @{
Server = $env:computername
Cipher = $cipher
Status = $value
}

new-object psobject -property $ciphertable

}
