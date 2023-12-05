#!/bin/bash

# Define an array of SSH hosts
SSH_HOSTS=("puthosthere") # Replace with actual hostnames or IPs
SSH_USER="putuserhere" # Replace with your username
LOGFILE="ssh_connectivity.log"
INTERVAL=1 # Time in seconds between checks

# Function to check SSH connection
check_ssh() {
    local host=$1
    if ssh -v -o ConnectTimeout=5 $SSH_USER@$host "echo 'SSH connection successful to $host'"; then
        echo "$(date) - SSH connection successful to $host" >> $LOGFILE
    else
        echo "$(date) - SSH connection failed to $host" >> $LOGFILE
    fi
}

# Infinite loop to continuously check SSH connection for each host
while true; do
    for host in "${SSH_HOSTS[@]}"; do
        check_ssh $host
    done
    sleep $INTERVAL
done

