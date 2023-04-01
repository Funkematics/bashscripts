#!/bin/bash

# List of attribute IDs to check
declare -a attribute_ids=("5" "9" "170" "184" "187" "233")

# Iterate through drives from /dev/sda to /dev/sdy
for drive_letter in {a..y}; do
    drive_path="/dev/sd${drive_letter}"
    echo "Checking drive: ${drive_path}"
    
    # Get SMART overall-health self-assessment test result
    overall_health=$(sudo smartctl -H ${drive_path} | grep "SMART overall-health self-assessment test result" | awk '{print $6}')
    echo "SMART overall-health self-assessment test result: ${overall_health}"
    
    # Get selected SMART attributes
    for attribute_id in "${attribute_ids[@]}"; do
        attribute=$(sudo smartctl -A ${drive_path} | awk -v id="${attribute_id}" '$1 == id {printf "%-20s %s %s %s %s\n", $2, $3, $4, $5, $6}')
        if [ -n "$attribute" ]; then
            echo "Attribute ${attribute_id}: ${attribute}"
        fi
    done
    
    echo "---------------------------------------"
done

