#!/bin/bash

source /path/to/.env

# Log file
LOG_FILE="/path/to/logfile.txt"

# Function to check internet connectivity
check_internet_connectivity() {
    if ping -q -c 1 -W 1 google.com &>/dev/null; then
        return 0  # Internet is reachable
    else
        return 1  # No internet connectivity
    fi
}

# Function to get your current public IP address
get_current_ip() {
    curl -s ifconfig.io
}

# Function to read the last recorded IP address
get_last_ip() {
    curl -s --request GET \
        --url "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
        --header "Content-Type: application/json" \
        --header "X-Auth-Email: $CF_API_EMAIL" \
        --header "X-Auth-Key: $CF_API_KEY"
}

# Get the current timestamp
get_timestamp() {
    TZ="America/New_York" date +"%Y-%m-%d %H:%M:%S %Z"
}

# Check internet connectivity
if check_internet_connectivity; then
    # Internet is reachable
    current_ip=$(get_current_ip)
    last_ip=$(get_last_ip | jq -r '.result.content')

    if [ "$current_ip" != "$last_ip" ]; then
        # IP address has changed
        timestamp=$(get_timestamp)
        echo "$timestamp: IP address has changed. Updating Cloudflare..." >> "$LOG_FILE"
        
        # Update Cloudflare DNS record
        response=$(curl -s --request PATCH \
            --url "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
            --header "Content-Type: application/json" \
            --header "X-Auth-Email: $CF_API_EMAIL" \
            --header "X-Auth-Key: $CF_API_KEY" \
            --data '{
            "content": "'"$current_ip"'",
            "comment": "Last updated '"$timestamp"'"
            }')

        if echo "$response" | jq -e '.success == true' &> /dev/null; then
            timestamp=$(get_timestamp)
            echo "$timestamp: Cloudflare DNS record updated successfully to $current_ip" >> "$LOG_FILE"

        else
            timestamp=$(get_timestamp)
            echo "$timestamp: Failed to update Cloudflare DNS record." >> "$LOG_FILE"
        fi

    else
        timestamp=$(get_timestamp)
        echo "$timestamp: IP address has not changed." >> "$LOG_FILE"
    fi
else
    # No internet connectivity
    timestamp=$(get_timestamp)
    echo "$timestamp: No internet connectivity. Skipping update." >> "$LOG_FILE"
fi
