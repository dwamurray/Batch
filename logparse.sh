# From auth.log (/var/log/secure in CentOS/Redhat etc) find all login failures, 
# sort them by username & source IP address and count the number of failures for
# each user

# Sample file: ttps://github.com/dwamurray/repo-depo/blob/master/auth.log

# grep -i "failed password" auth.log | awk -F" " '{print $9}' | uniq -c
# Gives number of times each user name has been used for an unsuccessful logon attempt
# Using blank space as delimiting character, the username is the ninth element

# grep -i "failed password" auth.log | awk -F" " '{print $11}' 
# Gives the source IP address of each failed logon attempt, the source IP being the 11th element

grep -i "failed password" auth.log | awk -F" " '{print $9, "", $11}' | uniq -c
# Prints each unique username and source IP address combination along with a count
