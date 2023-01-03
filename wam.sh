#!/bin/bash
$1 = echo -ne "Insert a website to test: "
# Send a request to the web server
response=$(curl -s http://$1)

# Check the response status code
if [ "$?" -ne 0 ]; then
    echo 'Error connecting to the web server.'
    exit 1
fi

# Check the response for indications of an attack
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
    if nc -z -w 2 $1 80; then
        echo 'Possible attack detected: DoS/DDoS attack detected.'
    else
        # Check for a Man-in-the-Middle (MITM) or sniffing attack
        mitm_attack=false
        for interface in $(ifconfig | grep -o '^[^ ][^:]*:' | tr -d :); do
            if [[ "$(ethtool $interface 2>/dev/null | grep 'Link detected: yes')" ]]; then
                # Check if the MAC address of the interface is different from the MAC address of the web server
                mac_address=$(arping -I $interface -c 1 $1 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
                if [ "$mac_address" != "$(arping -I $interface -c 1 $1 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')" ]; then
                    mitm_attack=true
                    break
                fi
            fi
        done
        if $mitm_attack; then
            echo 'Possible attack detected: MITM/sniffing attack detected.'
        else
            echo 'No attacks detected.'
        fi
    fi
fi
