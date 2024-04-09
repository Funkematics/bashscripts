

















#!/bin/bash


 
#unique list of all groups
groups=$(getent group | cut -d: -f1)

# Loop through each group and get the members
for group in $groups; do
     echo "# ${group^^} project"
     echo -n "accounts = ["
     members=($(getent group "$group" | cut -d: -f4 | tr ',' '\n'))
     num_members=${#members[@]}
     gid=$(getent group "$group" | cut -d: -f3)  # Get the group ID
     first_member_uid=""  # Initialize the variable for the first member's UID
     for ((i = 0; i < num_members; i++)); do
         member=${members[i]}
         uid=$(getent passwd "$member" | cut -d: -f3)
         gecos=$(getent passwd "$member" | cut -d: -f5 | cut -d, -f1)
         shell=$(getent passwd "$member" | cut -d: -f7)
         if [ $i -eq 0 ]; then
         first_member_uid=$uid  # Set the first member's UID
         echo "['$member', $uid, '$gecos', '$shell'],"
         elif [ $i -eq $((num_members - 1)) ]; then
         echo -n "            ['$member', $uid, '$gecos', '$shell']"
         else
         echo "            ['$member', $uid, '$gecos', '$shell'],"
         fi
     done
     echo "]"
     echo "do_accountscreation('$group', $gid, $first_member_uid, accounts)"
     echo
 done  





echo "Non-default group memberships:"
for user in $(getent passwd | cut -d: -f1); do
    user_groups=$(id -nG "$user")
    primary_group=$(id -gn "$user")
    non_default_groups=$(echo "$user_groups" | tr ' ' '\n' | grep -v "^$primary_group$" | tr '\n' ' ')
    if [ ! -z "$non_default_groups" ]; then
        echo "User: $user, Non-default Groups: $non_default_groups"
    fi
done

