$servers = get-content servers.txt
foreach ( $server in $servers )
{ $value = if ( get-content \\$server\C$\vlogdir\coe08128.log -erroraction silentlycontinue | 
select-string "9\.9\.0"
) { "9.9.0 installed" 
} else { "9.9.0 not installed"
}
$ciphertable = @{
Server = $server
Value = $value
}

new-object psobject -property $ciphertable
}
