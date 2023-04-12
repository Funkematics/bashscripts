#!/bin/sh

# Output file to store the test results
output_file="smart_test_results.txt"

# Clear the output file before starting the tests
: > "$output_file"

# Function to perform a smart test on a drive
smart_test() {
    device_name="$1"

    # Get the serial number and failure information from smartctl
    serial_number="$(smartctl -i "$device_name" | grep -i 'serial number' | awk '{print $3}')"
    failure_info="$(smartctl -H "$device_name" | grep -i 'test result' | awk -F ': ' '{print $2}')"

    # Perform a short SMART test
    smartctl -t short "$device_name"

    # Wait for the test to complete (usually takes around 2 minutes)
    sleep 120

    # Get the test results
    test_results="$(smartctl -l selftest "$device_name")"

    # Log the results along with the drive's serial number and failure information
    echo "Drive: $device_name | Serial: $serial_number | Failure info: $failure_info" >> "$output_file"
    echo "Test results:" >> "$output_file"
    echo "$test_results" >> "$output_file"
    echo "-----------------------------------------------" >> "$output_file"
}

# Get the list of connected drives
connected_drives=$(smartctl --scan | awk '{print $1}')

# Iterate through the drives and run the smart test simultaneously
for drive in $connected_drives; do
    smart_test "$drive" &
done

# Wait for all tests to finish before proceeding
wait

echo "All SMART tests completed. Check the results in $output_file."
