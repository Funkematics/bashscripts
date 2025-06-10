#!/bin/bash

# Script to loop through a list of usernames from an input file provided as an argument,
# retrieve their accountExpires FILETIME from LDAP, and output username and FILETIME to a new .list file.
# Usage: ./get_user_filetimes.sh <input_file>
# Example: ./get_user_filetimes.sh users.list

# Check if input file is provided
if [[ $# -ne 1 ]]; then
    echo "Error: Please provide exactly one input file." >&2
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

input_file="$1"
output_file="user_filetimes.list"

# Check if input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' not found." >&2
    exit 1
fi

# LDAP command template (with $USER as placeholder)
ldap_command='ldapsearch -w s3arch@ccount! -x -H "ldaps://auth.alaska.edu" -D "cn=rcs-ad-read,ou=RCS,ou=UAF,dc=ua,dc=ad,dc=alaska,dc=edu" -b "ou=userAccounts,dc=ua,dc=ad,dc=alaska,dc=edu" "(&(samAccountName=$USER))" accountExpires | grep accountExpires: | awk "{print \$2}"'

# Clear or create output file
> "$output_file"

# Function to convert FILETIME to human-readable date (for logging, not output file)
filetime_to_readable() {
    local filetime=$1
    if [[ -z "$filetime" || ! "$filetime" =~ ^[0-9]+$ ]]; then
        echo "Invalid FILETIME"
        return
    fi
    seconds_since_1601=$(echo "scale=0; $filetime / 10000000" | bc)
    epoch_offset=11644473600
    unix_seconds=$(echo "$seconds_since_1601 - $epoch_offset" | bc)
    if [[ $unix_seconds =~ ^- ]]; then
        echo "Never expires or invalid"
        return
    fi
    TZ=US/Alaska date -d "@$unix_seconds" 2>/dev/null || echo "Error converting date"
}

# Read usernames from input file and process each
while IFS= read -r user; do
    # Skip empty lines
    [[ -z "$user" ]] && continue

    # Replace $USER in ldap_command and execute
    user_command=${ldap_command//\$USER/$user}
    filetime=$(eval "$user_command" 2>/dev/null)

    # Check if filetime was retrieved
    if [[ -z "$filetime" ]]; then
        echo "Warning: No accountExpires for user '$user' or query failed." >&2
        filetime="N/A"
    elif [[ ! "$filetime" =~ ^[0-9]+$ ]]; then
        echo "Warning: Invalid FILETIME for user '$user': $filetime" >&2
        filetime="Invalid"
    fi



    # Log human-readable date for reference (not written to output file)
    readable_date=$(filetime_to_readable "$filetime")
    echo "User: $user, FILETIME: $filetime, Date: $readable_date" >&2

    # Write to output file (username filetime)
    echo "$user $readable_date" >> "$output_file"

done < "$input_file"

# Check if output file was written
if [[ -s "$output_file" ]]; then
    echo "Output written to '$output_file'" >&2
else
    echo "Error: No data written to '$output_file'. Check input or LDAP connectivity." >&2
    exit 1
fi
