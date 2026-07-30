# Python for Hackers: Comprehensive Quiz & Test Bank

## Complete Assessment Suite with Answer Keys

This document contains a comprehensive collection of quizzes, tests, and assessment materials for the Python for Hackers series. Each module includes multiple question types and detailed answer explanations.

---

## Table of Contents

1. [Part 0: Introduction Quiz](#part-0-introduction-quiz)
2. [Phase 1: Network Fundamentals](#phase-1-network-fundamentals)
3. [Phase 2: Web Reconnaissance](#phase-2-web-reconnaissance)
4. [Phase 3: Offensive Tooling](#phase-3-offensive-tooling)
5. [Phase 4: Post-Exploitation](#phase-4-post-exploitation)
6. [Final Comprehensive Exam](#final-comprehensive-exam)
7. [Practical Lab Exam](#practical-lab-exam)
8. [Answer Keys](#answer-keys)

---

## Part 0: Introduction Quiz

### Multiple Choice Questions

**1. What is the primary purpose of using virtual machines in a hacking lab?**

A) To save money on hardware
B) To create an isolated, safe testing environment
C) To increase internet speed
D) To run multiple operating systems simultaneously

**2. Which IP address range is recommended for the host-only network in the lab?**

A) 192.168.0.0/24
B) 10.0.0.0/24
C) 192.168.100.0/24
D) 172.16.0.0/24

**3. What command creates a Python virtual environment?**

A) `python3 -m venv hacker-env`
B) `python3 create venv hacker-env`
C) `virtualenv create hacker-env`
D) `python3 -m virtualenv hacker-env`

**4. Which of the following is NOT a prerequisite for the series?**

A) Basic Python syntax knowledge
B) Command line familiarity
C) Advanced cryptography knowledge
D) Fundamental networking concepts

**5. What is the primary ethical requirement for security testing?**

A) Always use the latest tools
B) Only test systems you own or have permission to test
C) Share findings on social media
D) Use automated tools only

### True/False Questions

**6. True or False: The hacking lab requires an internet connection to function.**

**7. True or False: Snapshots allow you to roll back a VM to a previous state.**

**8. True or False: Python 2.7 is the recommended version for this series.**

**9. True or False: The toolkit should only be used on systems you have explicit permission to test.**

**10. True or False: The virtual environment isolates package installations from the system Python.**

### Fill in the Blank

**11. The attacker VM in the lab runs ________ operating system.**

**12. The target VM in the lab runs ________ Server.**

**13. The host-only network IP range is ________.**

**14. The command to activate the virtual environment is ________.**

**15. The toolkit directory should be created in the user's ________ directory.**

---

## Phase 1: Network Fundamentals

### Module 1.1: Socket Programming Quiz

#### Multiple Choice Questions

**16. What is a socket in networking?**

A) A physical connector on a computer
B) An endpoint for communication between computers
C) A type of network cable
D) A programming language

**17. Which protocol provides reliable, ordered delivery of data?**

A) UDP
B) TCP
C) ICMP
D) ARP

**18. What does `socket.AF_INET` specify?**

A) The socket type (TCP/UDP)
B) The address family (IPv4)
C) The protocol (HTTP)
D) The port number

**19. What is the purpose of `socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)`?**

A) To encrypt the connection
B) To allow reuse of the port after the socket closes
C) To set a timeout
D) To enable IPv6

**20. Which method is used by a server to wait for incoming connections?**

A) `socket.connect()`
B) `socket.bind()`
C) `socket.listen()`
D) `socket.accept()`

**21. What does `connect_ex()` return when a connection is successful?**

A) True
B) 0
C) 1
D) False

**22. Which socket method is used to receive data?**

A) `socket.send()`
B) `socket.recv()`
C) `socket.receive()`
D) `socket.read()`

**23. What is the default maximum buffer size for `recv()` in most examples?**

A) 512 bytes
B) 1024 bytes
C) 2048 bytes
D) 4096 bytes

#### Code Analysis Questions

**24. What does the following code do?**
```python
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('127.0.0.1', 9999))
sock.send(b'Hello')
data = sock.recv(1024)
sock.close()
```

A) Creates a UDP server
B) Creates a TCP client that sends and receives data
C) Creates a TCP server
D) Creates a UDP client

**25. What is the purpose of `threading.Thread(target=self.handle_client, args=(client,))`?**

A) To create a new process
B) To handle multiple clients simultaneously
C) To encrypt data
D) To set a timeout

### Module 1.2: Port Scanner Quiz

**26. What is the primary purpose of port scanning?**

A) To slow down a network
B) To discover open ports and services on a target
C) To install malware
D) To encrypt data

**27. Which scanning technique performs a full TCP handshake?**

A) SYN scan
B) Connect scan
C) UDP scan
D) FIN scan

**28. What does a SYN-ACK response indicate?**

A) Port is closed
B) Port is open
C) Port is filtered
D) Connection refused

**29. What is banner grabbing?**

A) Downloading a website's banner image
B) Reading the initial response from a service to identify it
C) Creating a banner for a website
D) Blocking ads

**30. Which of the following is NOT a common service signature?**

A) `SSH` for SSH service
B) `HTTP` for web servers
C) `MySQL` for databases
D) `Windows` for firewall

### Module 1.3: Packet Crafting Quiz

**31. What is Scapy?**

A) A web framework
B) A packet manipulation library
C) A database system
D) A text editor

**32. How do you combine layers in Scapy?**

A) Using the `+` operator
B) Using the `/` operator
C) Using the `|` operator
D) Using the `&` operator

**33. Which TCP flag is used to initiate a connection?**

A) ACK
B) SYN
C) FIN
D) RST

**34. What does `sr1(packet)` do?**

A) Sends a packet and receives all responses
B) Sends a packet and receives the first response
C) Sends a packet without waiting for response
D) Sniffs packets on the network

**35. What is the purpose of `wrpcap()`?**

A) Read packets from a PCAP file
B) Write packets to a PCAP file
C) Create a new network interface
D) Delete a PCAP file

---

## Phase 2: Web Reconnaissance

### Module 2.1: HTTP Fundamentals Quiz

**36. Which HTTP method is used to retrieve data from a server?**

A) POST
B) GET
C) PUT
D) DELETE

**37. What does a 404 status code indicate?**

A) Server error
B) Page not found
C) Successful request
D) Redirect

**38. Which HTTP header is used for authentication?**

A) User-Agent
B) Content-Type
C) Authorization
D) Cookie

**39. What is the purpose of a session?**

A) To maintain state between requests
B) To encrypt data
C) To compress data
D) To send files

**40. What is the difference between `data` and `json` parameters in requests.post()?**

A) `data` is for URL-encoded form data, `json` is for JSON data
B) `data` is for binary data, `json` is for text
C) There is no difference
D) `data` is for files, `json` is for text

### Module 2.2: Directory Brute-Forcer Quiz

**41. What is directory brute-forcing?**

A) Password cracking
B) Discovering hidden web directories
C) Port scanning
D) Packet sniffing

**42. What is a wordlist in the context of directory brute-forcing?**

A) A list of passwords
B) A list of directory names to test
C) A list of IP addresses
D) A list of ports

**43. What does the `-e` parameter typically specify in a brute-forcer?**

A) Extensions to append
B) Excluded directories
C) Email addresses
D) Encryption type

**44. Why is recursive scanning useful?**

A) It scans faster
B) It discovers deeper directory structures
C) It uses less memory
D) It requires less bandwidth

**45. What is a common WordPress path to discover?**

A) /admin
B) /wp-admin
C) /login
D) /backup

### Module 2.3: HTML Parsing Quiz

**46. What is BeautifulSoup?**

A) A web server
B) An HTML parsing library
C) A database system
D) A networking tool

**47. Which method finds all elements matching a tag?**

A) `soup.find()`
B) `soup.find_all()`
C) `soup.select()`
D) `soup.get()`

**48. What is a CSRF token?**

A) A type of cookie
B) A unique token to prevent cross-site request forgery
C) A password
D) An API key

**49. How do you extract the title of a page with BeautifulSoup?**

A) `soup.title.string`
B) `soup.get_title()`
C) `soup.title()`
D) `soup.find_title()`

**50. Which of the following is a sensitive data pattern?**

A) `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`
B) `\d{3}-\d{2}-\d{4}`
C) `AKIA[0-9A-Z]{16}`
D) All of the above

### Module 2.4: Authentication Quiz

**51. What is the difference between session-based and JWT authentication?**

A) Sessions use cookies, JWTs use tokens
B) Sessions are stateful, JWTs are stateless
C) Sessions are faster
D) There is no difference

**52. What is OAuth?**

A) A type of password
B) An authentication protocol
C) A web framework
D) A database

**53. Why are CSRF tokens important?**

A) They encrypt data
B) They prevent unauthorized requests
C) They speed up login
D) They compress data

**54. What is the purpose of a login automation flow?**

A) To test authentication mechanisms automatically
B) To crack passwords
C) To bypass security
D) To install malware

**55. How do you extract a CSRF token from HTML?**

A) Using regular expressions
B) Parsing the HTML with BeautifulSoup
C) Both A and B
D) Neither A nor B

---

## Phase 3: Offensive Tooling

### Module 3.1: API Intelligence Quiz

**56. What is the difference between REST and GraphQL?**

A) REST uses multiple endpoints, GraphQL uses a single endpoint
B) REST is slower than GraphQL
C) GraphQL is older than REST
D) There is no difference

**57. What does GraphQL introspection reveal?**

A) The schema and available queries
B) The server's IP address
C) The database password
D) The network configuration

**58. Which of the following is a common API endpoint?**

A) /users
B) /admin
C) /api/v1
D) All of the above

**59. What is the purpose of API discovery?**

A) To find available API endpoints
B) To discover new programming languages
C) To test network speed
D) To encrypt API calls

**60. What is a Swagger/OpenAPI specification?**

A) A type of authentication
B) A documentation format for APIs
C) A web server
D) A programming language

### Module 3.2: Exploit Development Quiz

**61. What is SQL injection?**

A) Injecting SQL code into a database query
B) A type of password cracking
C) A network scanning technique
D) A packet crafting method

**62. Which of the following is a SQL injection payload?**

A) `; ls`
B) `' OR '1'='1`
C) `<script>alert(1)</script>`
D) `../../etc/passwd`

**63. What is command injection?**

A) Injecting commands into the operating system
B) A type of SQL injection
C) A network attack
D) An encryption method

**64. Which of the following is a command injection payload?**

A) `' OR '1'='1`
B) `; whoami`
C) `../../etc/passwd`
D) `<script>alert(1)</script>`

**65. What is authentication bypass?**

A) Encrypting passwords
B) Circumventing login mechanisms
C) Creating strong passwords
D) Installing new authentication systems

### Module 3.3: Obfuscation Quiz

**66. What is obfuscation?**

A) Making code more readable
B) Making code harder to understand
C) Deleting code
D) Compiling code

**67. Why do attackers obfuscate payloads?**

A) To make them run faster
B) To avoid detection by security tools
C) To make them easier to read
D) To reduce file size

**68. What is Base64 encoding?**

A) A compression algorithm
B) An encryption method
C) A way to represent binary data in ASCII
D) A programming language

**69. Which of the following is a Base64 encoded string?**

A) `whoami`
B) `d2hvYW1p`
C) `77686f616d69`
D) `jubnzv`

**70. What is XOR encoding?**

A) Using the XOR operation to obfuscate data
B) A type of compression
C) A type of encryption
D) A type of hashing

### Module 3.4: Data Exfiltration Quiz

**71. What is data exfiltration?**

A) Encrypting data
B) Copying data from one system to another
C) The unauthorized transfer of data
D) Deleting data

**72. Which of the following is an exfiltration channel?**

A) HTTP
B) DNS
C) ICMP
D) All of the above

**73. How does DNS exfiltration work?**

A) Sending data in DNS queries
B) Encrypting DNS traffic
C) Compressing DNS packets
D) Blocking DNS requests

**74. What is steganography?**

A) Hiding data in other files
B) Encrypting data
C) Compressing data
D) Encoding data

**75. What is the capacity limit of LSB steganography in an image?**

A) 1 byte per pixel
B) 3 bits per pixel
C) 8 bytes per pixel
D) Depends on image size

---

## Phase 4: Post-Exploitation

### Module 4.1: C2 Framework Quiz

**76. What is a C2 framework?**

A) A type of encryption
B) A system for remote command and control
C) A programming language
D) A database system

**77. What is the role of a C2 server?**

A) To manage agents and distribute tasks
B) To scan for open ports
C) To encrypt data
D) To store passwords

**78. What is an agent in the context of C2?**

A) A program on the target that communicates with the server
B) A person who manages the server
C) A type of encryption
D) A network protocol

**79. What is a beacon?**

A) A type of encryption
B) A periodic check-in from an agent
C) A network protocol
D) A programming language

**80. What is the purpose of the heartbeat?**

A) To send large files
B) To maintain a connection
C) To encrypt data
D) To scan for open ports

### Module 4.2: System Enumeration Quiz

**81. What is system enumeration?**

A) Scanning for open ports
B) Gathering information about a system
C) Installing malware
D) Encrypting data

**82. Which Python library is used for system information?**

A) `socket`
B) `requests`
C) `psutil`
D) `scapy`

**83. What information can be gathered from `/etc/passwd`?**

A) User accounts
B) Passwords
C) Network configuration
D) Running processes

**84. What is the purpose of checking `/etc/sudoers`?**

A) To find sudo privileges
B) To find network configuration
C) To find installed software
D) To find users

**85. Which of the following is NOT a system enumeration category?**

A) Users
B) Processes
C) Passwords
D) Services

### Module 4.3: Persistence Quiz

**86. What is persistence in cybersecurity?**

A) Saving data
B) Maintaining access after a reboot
C) Encrypting files
D) Scanning for vulnerabilities

**87. Which is a Windows persistence mechanism?**

A) Cron job
B) Registry Run key
C) Systemd service
D) All of the above

**88. What is the Linux equivalent of the Windows Startup folder?**

A) `~/.config/autostart`
B) `/etc/init.d`
C) `~/.bashrc`
D) `/etc/cron.d`

**89. How do you add a cron job?**

A) `crontab -e`
B) `cron add`
C) `add-cron`
D) `cron-edit`

**90. What is the purpose of cleaning up persistence?**

A) To save disk space
B) To avoid detection
C) To improve performance
D) To update software

### Module 4.4: Packaging Quiz

**91. What is packaging in Python?**

A) Creating a ZIP file
B) Converting scripts to standalone executables
C) Installing packages
D) Writing documentation

**92. Which tool is commonly used for packaging Python scripts?**

A) `pip`
B) `pyinstaller`
C) `venv`
D) `scapy`

**93. What does the `--onefile` option in PyInstaller do?**

A) Creates a single executable file
B) Creates multiple files
C) Compresses the output
D) Encrypts the output

**94. What is UPX?**

A) A Python library
B) An executable compression tool
C) A programming language
D) A web server

**95. Why might an attacker avoid UPX compression?**

A) It increases file size
B) It can be a detection signature
C) It makes the file run slower
D) It requires a license

---

## Final Comprehensive Exam

### Section A: Multiple Choice (50 questions)

**96. Which of the following best describes ethical hacking?**

A) Hacking with malicious intent
B) Security testing with permission
C) Writing viruses
D) Spreading malware

**97. What is the default port for HTTPS?**

A) 80
B) 443
C) 8080
D) 8443

**98. Which protocol is connectionless?**

A) TCP
B) UDP
C) HTTP
D) SSH

**99. What is the purpose of `scapy`?**

A) Web scraping
B) Packet manipulation
C) Database access
D) GUI development

**100. Which of the following is a SQL injection technique?**

A) UNION-based
B) Error-based
C) Boolean-based
D) All of the above

**101. What is the purpose of `beautifulsoup4`?**

A) Web scraping and HTML parsing
B) Packet crafting
C) Network scanning
D) Password cracking

**102. What is a JWT token?**

A) A type of cookie
B) A JSON-based authentication token
C) A programming language
D) A web framework

**103. Which of the following is NOT a common exfiltration channel?**

A) HTTP
B) DNS
C) Bluetooth
D) ICMP

**104. What is the purpose of the `requests` library?**

A) Making HTTP requests
B) Creating sockets
C) Parsing HTML
D) Crafting packets

**105. Which of the following is a scanning technique?**

A) Connect scan
B) SYN scan
C) UDP scan
D) All of the above

### Section B: Fill in the Blank (20 questions)

**106. The three-way handshake consists of SYN, ______, and ACK.**

**107. An open port indicates that a ________ is listening on that port.**

**108. The HTTP method used to send data is ________.**

**109. A 500 status code indicates a ________ error.**

**110. In Scapy, the ________ operator is used to combine packet layers.**

**111. SQL injection uses ________ characters to break query structure.**

**112. Base64 encoding uses ________ characters plus = for padding.**

**113. A ________ maintains state between HTTP requests.**

**114. The Linux service manager is called ________.**

**115. The Windows Registry Run key is located at ________.**

### Section C: Code Analysis (10 questions)

**116. What does this code do?**
```python
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('192.168.1.1', 80))
sock.send(b'GET / HTTP/1.0\r\n\r\n')
data = sock.recv(1024)
sock.close()
```

**117. What is the vulnerability in this code?**
```python
import subprocess
user_input = input("Enter filename: ")
subprocess.call("ls " + user_input, shell=True)
```

**118. What does this code extract?**
```python
from bs4 import BeautifulSoup
soup = BeautifulSoup(html, 'lxml')
for form in soup.find_all('form'):
    for input_tag in form.find_all('input'):
        if input_tag.get('type') == 'password':
            print(input_tag.get('name'))
```

**119. What is the purpose of this code?**
```python
import base64
data = "secret_data"
encoded = base64.b64encode(data.encode()).decode()
```

**120. What does this code accomplish?**
```python
import requests
session = requests.Session()
session.post('https://example.com/login', data={'user': 'admin', 'pass': 'pass'})
response = session.get('https://example.com/dashboard')
```

### Section D: Short Answer (10 questions)

**121. Explain the difference between TCP and UDP.**

**122. What is the purpose of a port scanner in security testing?**

**123. Describe the process of logging into a web application with a CSRF token.**

**124. What is the difference between SQL injection and command injection?**

**125. Why would an attacker use obfuscation?**

**126. What are the advantages and disadvantages of DNS exfiltration?**

**127. Describe the C2 architecture in a red team engagement.**

**128. What information can be gathered during system enumeration?**

**129. What are the different persistence mechanisms and their risks?**

**130. Why is it important to package Python scripts as executables?**

---

## Practical Lab Exam

### Lab Exam 1: Network Reconnaissance

**Objective:** Perform a complete network reconnaissance of a target system.

**Instructions:**
1. Scan target 192.168.100.20 for open ports
2. Identify running services
3. Capture and analyze network traffic
4. Generate a report of findings

**Deliverables:**
- Port scan results
- Service identification
- Packet capture analysis
- Written report

**Grading Criteria:**
- Correct port identification (25%)
- Service identification accuracy (25%)
- Packet analysis quality (25%)
- Report completeness (25%)

### Lab Exam 2: Web Application Assessment

**Objective:** Assess a web application for vulnerabilities.

**Instructions:**
1. Perform directory brute-forcing
2. Analyze HTML for sensitive information
3. Test for SQL injection
4. Attempt authentication bypass

**Deliverables:**
- Discovered directories
- Sensitive data findings
- Vulnerability confirmation
- Exploitation demonstration

**Grading Criteria:**
- Directory discovery (20%)
- Data extraction (20%)
- Vulnerability identification (30%)
- Exploitation success (30%)

### Lab Exam 3: Post-Exploitation

**Objective:** Establish persistence and exfiltrate data.

**Instructions:**
1. Package a payload
2. Install persistence
3. Establish C2 communication
4. Exfiltrate test data

**Deliverables:**
- Packaged executable
- Persistence confirmation
- C2 communication logs
- Exfiltrated data

**Grading Criteria:**
- Successful packaging (25%)
- Persistence verification (25%)
- C2 communication (25%)
- Data exfiltration (25%)

---

## Answer Keys

### Part 0: Introduction Quiz Answers

**Multiple Choice:**
1. B - To create an isolated, safe testing environment
2. C - 192.168.100.0/24
3. A - `python3 -m venv hacker-env`
4. C - Advanced cryptography knowledge
5. B - Only test systems you own or have permission to test

**True/False:**
6. False - The lab can function offline
7. True
8. False - Python 3.10+ is required
9. True
10. True

**Fill in the Blank:**
11. Kali Linux
12. Ubuntu
13. 192.168.100.0/24
14. `source hacker-env/bin/activate`
15. home

### Phase 1: Network Fundamentals Answers

**16. B - An endpoint for communication between computers**
*Explanation: A socket is a software endpoint that enables bidirectional communication between programs over a network.*

**17. B - TCP**
*Explanation: TCP (Transmission Control Protocol) provides reliable, ordered delivery of data with error checking and retransmission.*

**18. B - The address family (IPv4)**
*Explanation: AF_INET specifies IPv4 addressing. Other options include AF_INET6 for IPv6 and AF_UNIX for Unix domain sockets.*

**19. B - To allow reuse of the port after the socket closes**
*Explanation: SO_REUSEADDR allows the port to be reused immediately, preventing "Address already in use" errors when restarting a server.*

**20. C - `socket.listen()`**
*Explanation: listen() puts the socket into server mode, waiting for incoming connections. accept() actually accepts the connection.*

**21. B - 0**
*Explanation: connect_ex() returns 0 on success and a non-zero error code on failure, making it easier to handle connection attempts.*

**22. B - `socket.recv()`**
*Explanation: recv() reads data from the socket. send() is used for sending, and there is no receive() or read() method.*

**23. B - 1024 bytes**
*Explanation: 1024 bytes is a common buffer size for network programming, balancing efficiency with memory usage.*

**24. B - Creates a TCP client that sends and receives data**
*Explanation: The code creates a TCP socket, connects to localhost on port 9999, sends "Hello", receives a response, and closes the connection.*

**25. B - To handle multiple clients simultaneously**
*Explanation: Creating a new thread for each client allows the server to handle multiple connections concurrently.*

**26. B - To discover open ports and services on a target**
*Explanation: Port scanning identifies which services are running on a target, helping assess the attack surface.*

**27. B - Connect scan**
*Explanation: A connect scan performs the full TCP three-way handshake. SYN scans are stealthier as they don't complete the handshake.*

**28. B - Port is open**
*Explanation: A SYN-ACK response indicates the port is open and listening for connections.*

**29. B - Reading the initial response from a service to identify it**
*Explanation: Banner grabbing involves connecting to a service and reading its welcome message, which often reveals service type and version.*

**30. D - `Windows` for firewall**
*Explanation: Firewalls don't typically identify themselves with "Windows". SSH, HTTP, and MySQL have well-known signatures.*

**31. B - A packet manipulation library**
*Explanation: Scapy is a Python library for crafting, sending, sniffing, and analyzing network packets.*

**32. B - Using the `/` operator**
*Explanation: The `/` operator stacks layers in Scapy (e.g., `IP()/TCP()` creates an IP packet with a TCP payload).*

**33. B - SYN**
*Explanation: SYN (Synchronize) is the flag used to initiate a TCP connection in the three-way handshake.*

**34. B - Sends a packet and receives the first response**
*Explanation: sr1() is used for one-shot packet sends where only the first response is needed.*

**35. B - Write packets to a PCAP file**
*Explanation: wrpcap() saves captured packets to a PCAP file for later analysis.*

### Phase 2: Web Reconnaissance Answers

**36. B - GET**
*Explanation: GET is used to retrieve data from a server. POST sends data, PUT updates, DELETE removes.*

**37. B - Page not found**
*Explanation: 404 indicates the requested resource could not be found on the server.*

**38. C - Authorization**
*Explanation: The Authorization header carries credentials for authentication.*

**39. A - To maintain state between requests**
*Explanation: Sessions store user state across multiple HTTP requests using cookies or tokens.*

**40. A - `data` is for URL-encoded form data, `json` is for JSON data**
*Explanation: `data` sends form-encoded data; `json` automatically serializes the data to JSON and sets the content-type header.*

**41. B - Discovering hidden web directories**
*Explanation: Directory brute-forcing systematically tests for hidden or unlinked directories on a web server.*

**42. B - A list of directory names to test**
*Explanation: Wordlists contain common directory names that are tested to discover hidden paths.*

**43. A - Extensions to append**
*Explanation: The `-e` parameter typically appends file extensions like .php, .html, .txt to the wordlist entries.*

**44. B - It discovers deeper directory structures**
*Explanation: Recursive scanning follows discovered directories to find nested content.*

**45. B - /wp-admin**
*Explanation: /wp-admin is the WordPress admin panel, a common target for attackers.*

**46. B - An HTML parsing library**
*Explanation: BeautifulSoup is a library for parsing HTML and XML documents, extracting data from web pages.*

**47. B - `soup.find_all()`**
*Explanation: find_all() returns all matching elements, while find() returns only the first.*

**48. B - A unique token to prevent cross-site request forgery**
*Explanation: CSRF tokens are unique per session and per request, verifying that the request came from the legitimate user.*

**49. A - `soup.title.string`**
*Explanation: soup.title returns the title tag, and .string extracts its text content.*

**50. D - All of the above**
*Explanation: All patterns identify sensitive data: emails, SSNs, and AWS keys.*

**51. B - Sessions are stateful, JWTs are stateless**
*Explanation: Sessions store state on the server; JWTs contain all necessary information in the token itself.*

**52. B - An authentication protocol**
*Explanation: OAuth is an open standard for access delegation, commonly used for token-based authentication.*

**53. B - They prevent unauthorized requests**
*Explanation: CSRF tokens ensure that requests originate from the legitimate user's session.*

**54. A - To test authentication mechanisms automatically**
*Explanation: Login automation tests authentication mechanisms and credential validity without manual intervention.*

**55. C - Both A and B**
*Explanation: CSRF tokens can be extracted using regex pattern matching or HTML parsing with BeautifulSoup.*

### Phase 3: Offensive Tooling Answers

**56. A - REST uses multiple endpoints, GraphQL uses a single endpoint**
*Explanation: REST uses multiple endpoints for different resources; GraphQL uses a single endpoint where queries specify what data to retrieve.*

**57. A - The schema and available queries**
*Explanation: GraphQL introspection exposes the entire API schema, including all available queries, mutations, types, and fields.*

**58. D - All of the above**
*Explanation: All are common API endpoints that are often exposed.*

**59. A - To find available API endpoints**
*Explanation: API discovery identifies what endpoints are available and potentially accessible.*

**60. B - A documentation format for APIs**
*Explanation: Swagger/OpenAPI provides a standard way to document REST APIs in a machine-readable format.*

**61. A - Injecting SQL code into a database query**
*Explanation: SQL injection involves inserting malicious SQL code into queries to manipulate database operations.*

**62. B - `' OR '1'='1`**
*Explanation: This is a classic SQL injection payload that always evaluates to true.*

**63. A - Injecting commands into the operating system**
*Explanation: Command injection allows execution of arbitrary OS commands through vulnerable applications.*

**64. B - `; whoami`**
*Explanation: This payload injects a command to show the current user.*

**65. B - Circumventing login mechanisms**
*Explanation: Authentication bypass attacks attempt to gain access without valid credentials.*

**66. B - Making code harder to understand**
*Explanation: Obfuscation transforms code into a form that is difficult for humans to read and analyze while still functioning as intended.*

**67. B - To avoid detection by security tools**
*Explanation: Obfuscation helps evade signature-based detection by changing the appearance of known malicious code.*

**68. C - A way to represent binary data in ASCII**
*Explanation: Base64 encodes binary data into ASCII characters for safe transmission over text-based protocols.*

**69. B - `d2hvYW1p`**
*Explanation: This is the Base64 encoding of "whoami".*

**70. A - Using the XOR operation to obfuscate data**
*Explanation: XOR encoding applies the XOR operation with a key to transform data into an obfuscated form.*

**71. C - The unauthorized transfer of data**
*Explanation: Data exfiltration is the unauthorized transfer of data from a system, often using covert channels.*

**72. D - All of the above**
*Explanation: HTTP, DNS, and ICMP can all be used as exfiltration channels.*

**73. A - Sending data in DNS queries**
*Explanation: DNS exfiltration encodes data in subdomains of DNS queries to exfiltrate information.*

**74. A - Hiding data in other files**
*Explanation: Steganography conceals data within ordinary files like images, audio, or video.*

**75. D - Depends on image size**
*Explanation: The capacity depends on image dimensions, as LSB steganography uses 3 bits per pixel.*

### Phase 4: Post-Exploitation Answers

**76. B - A system for remote command and control**
*Explanation: C2 frameworks provide infrastructure for managing compromised systems.*

**77. A - To manage agents and distribute tasks**
*Explanation: The C2 server coordinates operations, manages agents, and distributes tasks.*

**78. A - A program on the target that communicates with the server**
*Explanation: The agent is the deployed component that receives instructions and executes tasks.*

**79. B - A periodic check-in from an agent**
*Explanation: A beacon is a periodic communication from the agent to the server to check for tasks.*

**80. B - To maintain a connection**
*Explanation: Heartbeat signals keep the connection alive and verify the agent is still operational.*

**81. B - Gathering information about a system**
*Explanation: System enumeration collects detailed information about a target system's configuration.*

**82. C - `psutil`**
*Explanation: psutil is a cross-platform library for retrieving system information like CPU, memory, processes, and network.*

**83. A - User accounts**
*Explanation: /etc/passwd contains user account information, though passwords are stored elsewhere.*

**84. A - To find sudo privileges**
*Explanation: /etc/sudoers defines which users can run commands with elevated privileges.*

**85. C - Passwords**
*Explanation: Passwords are not a separate enumeration category; they're found during data discovery.*

**86. B - Maintaining access after a reboot**
*Explanation: Persistence ensures access to the system survives reboots and other interruptions.*

**87. B - Registry Run key**
*Explanation: The Registry Run key is a Windows persistence mechanism that runs programs at startup.*

**88. A - `~/.config/autostart`**
*Explanation: This directory contains autostart entries for Linux desktop environments.*

**89. A - `crontab -e`**
*Explanation: `crontab -e` opens the user's crontab file for editing, where cron jobs can be added.*

**90. B - To avoid detection**
*Explanation: Cleaning up persistence removes traces of the compromise to avoid detection.*

**91. B - Converting scripts to standalone executables**
*Explanation: Packaging creates standalone executables that can run without requiring Python installed.*

**92. B - `pyinstaller`**
*Explanation: PyInstaller is the most popular tool for packaging Python applications as executables.*

**93. A - Creates a single executable file**
*Explanation: `--onefile` bundles all dependencies into a single executable file.*

**94. B - An executable compression tool**
*Explanation: UPX (Ultimate Packer for eXecutables) compresses executable files to reduce size.*

**95. B - It can be a detection signature**
*Explanation: UPX compression is a common indicator of malicious executables and can trigger detection.*

### Final Comprehensive Exam Answers

**96. B - Security testing with permission**
*Explanation: Ethical hacking involves security testing conducted with proper authorization.*

**97. B - 443**
*Explanation: HTTPS uses port 443 by default.*

**98. B - UDP**
*Explanation: UDP is connectionless, unlike TCP which requires a connection.*

**99. B - Packet manipulation**
*Explanation: Scapy is primarily used for packet crafting, sending, sniffing, and analysis.*

**100. D - All of the above**
*Explanation: All listed types are SQL injection techniques.*

**101. A - Web scraping and HTML parsing**
*Explanation: BeautifulSoup is a library for parsing HTML and XML documents.*

**102. B - A JSON-based authentication token**
*Explanation: JWT (JSON Web Token) is a compact, URL-safe token for secure authentication.*

**103. C - Bluetooth**
*Explanation: Bluetooth is not a common exfiltration channel for typical network-based attacks.*

**104. A - Making HTTP requests**
*Explanation: The requests library simplifies making HTTP requests in Python.*

**105. D - All of the above**
*Explanation: Connect, SYN, and UDP scans are all valid scanning techniques.*

### Fill in the Blank Answers

**106. SYN-ACK**
*Explanation: The three-way handshake: SYN, SYN-ACK, ACK.*

**107. service**
*Explanation: An open port indicates a service or application is listening.*

**108. POST**
*Explanation: POST sends data to the server.*

**109. server**
*Explanation: 500 status codes indicate server-side errors.*

**110. `/`**
*Explanation: The `/` operator stacks packet layers in Scapy.*

**111. quote**
*Explanation: SQL injection uses quote characters like `'` or `"` to break query structure.*

**112. 64**
*Explanation: Base64 uses 64 characters plus `=` for padding.*

**113. cookie**
*Explanation: Cookies maintain session state between HTTP requests.*

**114. systemd**
*Explanation: systemd is the Linux service manager and init system.*

**115. HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run**
*Explanation: This is the Windows Registry Run key location.*

### Code Analysis Answers

**116. The code connects to a web server on port 80, sends an HTTP GET request, receives the response, and closes the connection.**

**117. This code is vulnerable to command injection because user input is used directly in a shell command without sanitization.**

**118. This code extracts the names of password fields from HTML forms, useful for identifying login forms.**

**119. This code Base64 encodes the string "secret_data", converting it to an obfuscated format.**

**120. This code logs into a web application using a session, storing cookies for subsequent authenticated requests.**

### Short Answer Sample Answers

**121. TCP vs UDP:**
TCP is connection-oriented, reliable, ordered, and includes error checking. UDP is connectionless, unreliable, unordered, and faster. TCP is used for applications requiring reliability (HTTP, SSH), UDP for speed (DNS, VoIP).

**122. Port scanner purpose:**
A port scanner identifies open ports on a target system, discovering which services are running. This helps assess the attack surface and potential vulnerabilities.

**123. Login with CSRF token:**
1. GET login page
2. Extract CSRF token from HTML
3. POST credentials + CSRF token
4. Server validates token
5. If valid, session is created

**124. SQL Injection vs Command Injection:**
SQL injection manipulates database queries; command injection executes OS commands. SQL injection targets databases; command injection targets the operating system.

**125. Why use obfuscation:**
Obfuscation evades detection by antivirus, bypasses IDS/IPS signatures, circumvents input filters, and hides the true purpose of payloads.

**126. DNS exfiltration:**
Advantages: Often allowed through firewalls, blends with normal traffic. Disadvantages: Limited data size per query, requires DNS server for capture.

**127. C2 architecture:**
C2 consists of a server that manages agents and distributes tasks, and agents on targets that execute tasks and send results. Communication uses covert channels like HTTP, DNS, or ICMP.

**128. System enumeration gathers:**
- System information (OS, version, architecture)
- Users and groups
- Running processes and services
- Network configuration
- Scheduled tasks
- Security settings (firewall, AV)
- File system and sensitive files

**129. Persistence mechanisms:**
- Startup scripts (medium risk, easy to detect)
- Cron/Scheduled tasks (low risk, often overlooked)
- Registry (Windows only, medium risk)
- Services (low risk, legitimate appearance)
- Detection risk varies by method and monitoring level

**130. Why package Python scripts:**
- No Python required on target
- Code protection
- Single file deployment
- Looks legitimate (blends in)
- Easier execution on target systems

---

## Assessment Scoring Guide

### Quiz Scoring

| Quiz | Questions | Points | Passing Score |
|------|-----------|--------|---------------|
| Part 0 | 15 | 15 | 12 (80%) |
| Phase 1.1 | 10 | 10 | 8 (80%) |
| Phase 1.2 | 10 | 10 | 8 (80%) |
| Phase 1.3 | 10 | 10 | 8 (80%) |
| Phase 2.1 | 10 | 10 | 8 (80%) |
| Phase 2.2 | 10 | 10 | 8 (80%) |
| Phase 2.3 | 10 | 10 | 8 (80%) |
| Phase 2.4 | 10 | 10 | 8 (80%) |
| Phase 3.1 | 10 | 10 | 8 (80%) |
| Phase 3.2 | 10 | 10 | 8 (80%) |
| Phase 3.3 | 10 | 10 | 8 (80%) |
| Phase 3.4 | 10 | 10 | 8 (80%) |
| Phase 4.1 | 10 | 10 | 8 (80%) |
| Phase 4.2 | 10 | 10 | 8 (80%) |
| Phase 4.3 | 10 | 10 | 8 (80%) |
| Phase 4.4 | 10 | 10 | 8 (80%) |

### Final Exam Scoring

| Section | Questions | Points |
|---------|-----------|--------|
| Multiple Choice | 10 | 20 |
| Fill in the Blank | 10 | 20 |
| Code Analysis | 5 | 25 |
| Short Answer | 5 | 35 |
| Total | 30 | 100 |

### Lab Exam Scoring

| Lab Exam | Points | Passing Score |
|----------|--------|---------------|
| Lab 1: Network Recon | 100 | 70 (70%) |
| Lab 2: Web Assessment | 100 | 70 (70%) |
| Lab 3: Post-Exploit | 100 | 70 (70%) |

---

## Instructor Notes

### Quiz Administration

1. **Time Allotment:**
   - Module quizzes: 15-20 minutes
   - Phase quizzes: 30-45 minutes
   - Final exam: 60-90 minutes
   - Lab exams: 2-3 hours each

2. **Delivery Methods:**
   - Paper-based for classroom
   - Learning management system (Moodle, Canvas)
   - Interactive code challenges

3. **Grading Considerations:**
   - Multiple choice: Automated grading
   - Code analysis: Manual review recommended
   - Short answer: Evaluate understanding, not just memorization
   - Lab exams: Hands-on demonstration preferred

4. **Retake Policy:**
   - Quizzes: Unlimited retakes
   - Final exam: 2 attempts
   - Lab exams: 3 attempts

5. **Cheating Prevention:**
   - Unique lab environments for each student
   - Code changes in assignments
   - Oral examination for lab work

---

**[QUIZ & TEST BANK COMPLETE]**
