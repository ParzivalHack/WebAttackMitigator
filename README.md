# WebAttackMitigator (work in progress)
This is a bash script that helps to identify various types of web attacks against a web server. Here's a brief summary of what the script does:

The user is prompted to input the URL and IP address of the web server.

The script then sends a request to the web server using the 'curl' command and logs any errors encountered during the connection.

The response from the web server is checked for signs of various types of attacks such as a SQL injection attack, cross-site scripting attack, HTTP response splitting attack, etc.

If no attacks are detected, the script checks for other types of attacks like a DoS/DDoS attack, MITM/sniffing attack, DNS server hijacking or DNS amplification attack, and directory traversal attack.

If any attack is detected, the script prints a warning message to the user.
