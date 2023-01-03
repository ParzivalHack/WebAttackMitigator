# WebAttackMitigator
This script sends a request to the web server with the IP address specified as the first command line argument and checks the response for indications of various types of attacks, including malicious scripts, SQL injection attacks, cross-site scripting (XSS) attacks, and HTTP response splitting attacks. If any of these attacks are detected, the script prints a message indicating the type of attack that was detected and exits. If none of these attacks are detected, the script checks for other types of attacks, such as DoS/DDoS attacks and MITM/sniffing attacks. If any of these attacks are detected, the script prints a message indicating the type of attack that was detected.
