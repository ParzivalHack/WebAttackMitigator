#!/bin/bash

# Prompt the user for the URL and IP address of the web server
read -p "Enter the URL of the web server: " url
read -p "Enter the IP address of the web server: " ip_address

# Send a request to the web server and log any errors
curl -s -o curl_output.txt "$url"
if [ $? -ne 0 ] || [ ! -s curl_output.txt ]; then
    echo 'Possible attack detected: Error connecting to the web server.'
    exit 1
fi

# Check the response for indications of an attack
response=$(cat curl_output.txt)
if [[ "$response" =~ '<script>' ]]; then
    echo 'Possible attack detected: Malicious script found in the website.'
elif [[ "$response" =~ 'union select' ]]; then
    echo 'Possible attack detected: SQL injection attack detected.'
elif [[ "$response" =~ '<iframe>' ]]; then
    echo 'Possible attack detected: Cross-site scripting (XSS) attack detected.'
elif [[ "$response" =~ '%0D%0A' ]]; then
    echo 'Possible attack detected: HTTP response splitting attack detected.'
else
    # If no attacks were detected, check for other types of attacks
    # Check for a Denial of Service (DoS) or Distributed Denial of Service (DDoS) attack
    if nc -z -w 2 $ip_address 80; then
        echo 'Possible attack detected: DoS/DDoS attack detected.'
    else
        # Check for a Man-in-the-Middle (MITM) or sniffing attack
        mitm_attack=false
        for interface in $(ifconfig | grep -o '^[^ ][^:]*:' | tr -d :); do
            if [[ "$(ethtool $interface 2>/dev/null | grep 'Link detected: yes')" ]]; then
                # Check if the MAC address of the interface is different from the MAC address of the web server
                mac_address=$(arping -I $interface -c 1 $ip_address | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
                if [ "$mac_address" != "$(arping -I $interface -c 1 $ip_address | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')" ]; then
                    mitm_attack=true
                    break
                fi
            fi
        done
        if $mitm_attack; then
            echo 'Possible attack detected: MITM/sniffing attack detected.'
        else
            # Check for a DNS server hijacking or DNS amplification attack
            if ! nslookup "$ip_address" > /dev/null; then
                echo 'Possible attack detected: DNS server hijacking or DNS amplification attack detected.'
            else
                # Check for a directory traversal attack
                if curl -s --path-as-is "$url/../../../etc/passwd" | grep -q 'root'; then
                    echo 'Possible attack detected: Directory traversal attack detected.'
                fi
            fi
        fi
    fi
fi

# Clean up the curl output file
rm curl_output.txt
