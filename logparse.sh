# From auth.log (/var/log/secure in CentOS/Redhat etc) find all login failures, 
# sort them by username & source IP address and count the number of failures for
# each user

# grep -i "failed password" auth.log | awk -F" " '{print $9}' | uniq -c
# Gives number of times each user name has been used for an unsuccessful logon attempt
# grep -i "failed password" auth.log | awk -F" " '{print $11}' 
# Gives the source IP address of each failed logon attempt

grep -i "failed password" auth.log | awk -F" " '{print $9, "", $11}' | uniq -c
