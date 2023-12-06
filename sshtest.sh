#!/bin/bash

# Define an array of SSH hosts
SSH_HOSTS=("chinook04.alaska.edu") # Replace with actual hostnames or IPs
SSH_USER="cmunoz9" # Replace with your username
LOGFILE="ssh_connectivity.log"
INTERVAL=1 # Time in seconds between checks
SUCCESSES=0
FAILURES=0

echo "check the logfile $LOGFILE for timestamp of all failures"
echo "succcesses will not be recorded unless you uncomment line 20 in script"

# Function to check SSH connection
check_ssh() {
    local host=$1
    if ssh -o ConnectTimeout=5 $SSH_USER@$host "echo 'SSH connection successful to $host'" &> /dev/null; then
        ((SUCCESSES++))
        #echo "$(date) - SSH connection successful to $host" >> $LOGFILE
        #If you want to log of all successes then uncomment the above
    else
        echo "$(date) - SSH connection failed to $host" >> $LOGFILE
        ((FAILURES++))
    fi
    echo -ne "Successful connection to $host = $SUCCESSES  Unsuccessful connection to $host = $FAILURES"\\r
}

# Infinite loop to continuously check SSH connection for each host
while true; do
    for host in "${SSH_HOSTS[@]}"; do
        check_ssh $host
    done
    sleep $INTERVAL
done

