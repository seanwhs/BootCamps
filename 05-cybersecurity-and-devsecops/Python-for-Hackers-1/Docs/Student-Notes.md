# Python for Hackers: Complete Student Notes

## Comprehensive Lecture Notes & Key Concepts

These notes are designed to accompany the Python for Hackers series. They provide concise explanations, key definitions, and important concepts for each module.

---

## Table of Contents

1. [Part 0: Introduction](#part-0-introduction)
2. [Phase 1: Network Fundamentals](#phase-1-network-fundamentals)
3. [Phase 2: Web Reconnaissance](#phase-2-web-reconnaissance)
4. [Phase 3: Offensive Tooling](#phase-3-offensive-tooling)
5. [Phase 4: Post-Exploitation](#phase-4-post-exploitation)
6. [Appendix: Quick Reference](#appendix-quick-reference)

---

## Part 0: Introduction

### Key Concepts

#### What is Offensive Security?
The practice of identifying and exploiting vulnerabilities in systems to understand and improve security.

**Key Principles:**
- Only test systems you own or have permission to test
- Always stay within agreed scope
- Report vulnerabilities responsibly
- Protect all data encountered

#### The Hacking Lab

**Why Virtual Machines?**
- Safe, isolated environment
- Can roll back to clean state
- No risk to host system
- Simulates real-world networks

**Lab Architecture:**
```
Host Machine
    ├── Kali Linux (Attacker) - 192.168.100.10
    ├── Ubuntu Server (Target) - 192.168.100.20
    └── Windows (Optional Target) - 192.168.100.30
```

#### Python Environment

**Virtual Environment Benefits:**
- Isolated package management
- No system-wide conflicts
- Reproducible environment
- Easy to delete and recreate

**Core Commands:**
```bash
python3 -m venv hacker-env    # Create virtual environment
source hacker-env/bin/activate # Activate it
pip install -r requirements.txt # Install dependencies
deactivate                    # Exit virtual environment
```

---

## Phase 1: Network Fundamentals

### Module 1.1: Socket Programming

#### What are Sockets?

**Analogy:** A socket is like a telephone line between computers.

**Key Terms:**
- **IP Address:** Computer's address on the network
- **Port:** Specific door/program on the computer
- **Socket:** Endpoint for communication

#### TCP vs UDP

| Feature | TCP | UDP |
|---------|-----|-----|
| Connection | Connection-oriented | Connectionless |
| Reliability | Guaranteed delivery | Best effort |
| Ordering | Preserves order | No ordering |
| Speed | Slower | Faster |
| Use Case | HTTP, SSH, FTP | DNS, DHCP, VoIP |

#### Socket Lifecycle

**Server Side:**
1. `socket()` → Create socket
2. `bind()` → Assign address and port
3. `listen()` → Wait for connections
4. `accept()` → Accept incoming connection
5. `recv()`/`send()` → Communicate
6. `close()` → Close connection

**Client Side:**
1. `socket()` → Create socket
2. `connect()` → Connect to server
3. `send()`/`recv()` → Communicate
4. `close()` → Close connection

#### Important Socket Methods

```python
# Create socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind to address
sock.bind(('0.0.0.0', 9999))

# Listen for connections
sock.listen(5)

# Accept connection
client, addr = sock.accept()

# Connect to server
sock.connect(('127.0.0.1', 9999))

# Send data
sock.send(b'Hello')

# Receive data
data = sock.recv(1024)

# Set timeout
sock.settimeout(5.0)

# Close socket
sock.close()
```

#### Common Port Numbers

| Port | Service | Port | Service |
|------|---------|------|---------|
| 20 | FTP Data | 443 | HTTPS |
| 21 | FTP | 445 | SMB |
| 22 | SSH | 993 | IMAPS |
| 23 | Telnet | 995 | POP3S |
| 25 | SMTP | 1723 | PPTP |
| 53 | DNS | 3306 | MySQL |
| 80 | HTTP | 3389 | RDP |
| 110 | POP3 | 5432 | PostgreSQL |
| 111 | RPC | 5900 | VNC |
| 135 | MSRPC | 6379 | Redis |
| 139 | NetBIOS | 8080 | HTTP Proxy |
| 143 | IMAP | 8443 | HTTPS Alt |

### Module 1.2: TCP Port Scanner

#### Why Port Scanning?

**Analogy:** Checking all doors in a building to see which are unlocked.

**What We Learn:**
- What services are running
- What operating system might be present
- Potential attack vectors

#### Scanning Techniques

| Technique | Method | Root Required | Stealth |
|-----------|--------|---------------|---------|
| Connect Scan | Full TCP handshake | No | Low |
| SYN Scan | SYN packet only | Yes | High |
| UDP Scan | UDP packets | Yes | Medium |

#### Multi-threading

**Why Use Threads:**
- Scans multiple ports simultaneously
- Much faster than sequential scanning
- Efficient use of system resources

**Threading Pattern:**
```python
from threading import Thread
from queue import Queue

q = Queue()
results = []
lock = threading.Lock()

def worker():
    while True:
        port = q.get()
        result = scan_port(port)
        with lock:
            results.append(result)
        q.task_done()

# Create and start threads
threads = []
for i in range(max_threads):
    t = Thread(target=worker)
    t.daemon = True
    t.start()
    threads.append(t)

# Wait for completion
q.join()
```

#### Banner Grabbing

**What is Banner Grabbing?**
- Connecting to a service and reading its initial response
- Reveals service type and version
- Useful for vulnerability identification

**Common Probes:**
```python
# HTTP
sock.send(b'HEAD / HTTP/1.0\r\n\r\n')

# SMTP
sock.send(b'HELO localhost\r\n')

# FTP
sock.send(b'USER anonymous\r\n')
```

#### Service Identification

**Common Service Signatures:**
- SSH: `SSH`, `OpenSSH`
- HTTP: `HTTP`, `Apache`, `nginx`, `IIS`
- FTP: `FTP`, `220`, `vsFTPd`
- SMTP: `SMTP`, `220`, `ESMTP`
- MySQL: `MySQL`, `MariaDB`

### Module 1.3: Packet Crafting with Scapy

#### What is Scapy?

**Analogy:** Packet crafting is like being a mail sorter who can create, modify, and read any mail.

**Capabilities:**
- Create packets from scratch
- Modify existing packets
- Sniff network traffic
- Analyze packet contents
- Implement custom protocols

#### Packet Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Ethernet Frame                           │
├─────────────────────────────────────────────────────────────┤
│                    IP Packet                                │
├─────────────────────────────────────────────────────────────┤
│                    TCP/UDP/ICMP Segment                    │
├─────────────────────────────────────────────────────────────┤
│                    Payload                                  │
└─────────────────────────────────────────────────────────────┘
```

#### Common Scapy Layers

| Layer | Class | Purpose |
|-------|-------|---------|
| Ethernet | `Ether()` | MAC addresses |
| IP | `IP()` | Source/destination IP |
| TCP | `TCP()` | Ports, flags |
| UDP | `UDP()` | Ports |
| ICMP | `ICMP()` | Ping/traceroute |
| ARP | `ARP()` | MAC/IP resolution |

#### TCP Flags

| Flag | Symbol | Purpose |
|------|--------|---------|
| SYN | S | Start connection |
| ACK | A | Acknowledge |
| FIN | F | End connection |
| RST | R | Reset connection |
| PSH | P | Push data |
| URG | U | Urgent data |

#### Creating Packets

```python
# Basic TCP packet
ip = IP(src="192.168.1.1", dst="8.8.8.8")
tcp = TCP(sport=12345, dport=80, flags="S")
packet = ip / tcp

# Send and receive
response = sr1(packet, timeout=2)

# Check response
if response and response.haslayer(TCP):
    if response[TCP].flags & 0x12:  # SYN-ACK
        print("Port is open")
```

---

## Phase 2: Web Reconnaissance

### Module 2.1: HTTP Fundamentals

#### HTTP Methods

| Method | Purpose | Analogy |
|--------|---------|---------|
| GET | Retrieve data | "Show me the menu" |
| POST | Send data | "I want to order" |
| PUT | Update data | "Change my order" |
| DELETE | Remove data | "Cancel my order" |
| HEAD | Get headers only | "What's on the menu?" |
| OPTIONS | Get available methods | "What can I order?" |

#### HTTP Status Codes

**2xx - Success**
- 200 OK
- 201 Created
- 204 No Content

**3xx - Redirection**
- 301 Moved Permanently
- 302 Found
- 304 Not Modified

**4xx - Client Error**
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found

**5xx - Server Error**
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable

#### Headers

| Header | Purpose |
|--------|---------|
| User-Agent | Identify client |
| Authorization | Authentication |
| Content-Type | Data format |
| Cookie | Session data |
| Referer | Referring page |

#### Session Management

```python
# Create session
session = requests.Session()

# Login (cookies saved automatically)
session.post('https://example.com/login', data={
    'user': 'admin',
    'pass': 'password'
})

# Session persists
response = session.get('https://example.com/dashboard')

# Clear session
session.cookies.clear()
```

### Module 2.2: Directory Brute-Forcing

#### What is Directory Brute-Forcing?

**Analogy:** Trying all keys in a key ring to find one that opens a door.

**Why We Do It:**
- Find hidden admin panels
- Discover backup files
- Uncover configuration files
- Identify development artifacts

#### Wordlists

**Common Entries:**
```
admin, login, wp-admin, backup, config, database,
phpmyadmin, cpanel, webmail, test, dev, stage,
api, v1, v2, docs, images, css, js, assets,
static, media, downloads, uploads, files, data, logs
```

#### Technology-Specific Paths

**WordPress:**
```
wp-admin, wp-content, wp-includes, wp-config.php,
wp-login.php, wp-signup.php, xmlrpc.php
```

**PHP Applications:**
```
index.php, admin.php, login.php, config.php,
settings.php, install.php, setup.php
```

**Python/Django:**
```
manage.py, wsgi.py, settings.py, urls.py,
views.py, models.py, admin.py, static/, templates/
```

#### Recursive Scanning

**Why Go Recursive:**
- Discover deeper directory structures
- Find nested applications
- Uncover hidden paths

**Depth Control:**
- Too shallow: Miss deep files
- Too deep: Slow, may cause issues
- Typical max depth: 2-3 levels

### Module 2.3: HTML Parsing

#### Why Parse HTML?

**Analogy:** Examining a crime scene to find hidden evidence.

**What We Extract:**
- Meta data (page information)
- Forms (input points)
- Links (navigation paths)
- Comments (developer notes)
- Scripts (JavaScript)
- Emails (contact info)
- Sensitive data (API keys, credentials)

#### BeautifulSoup Basics

```python
from bs4 import BeautifulSoup

# Parse HTML
soup = BeautifulSoup(html_content, 'lxml')

# Find elements
title = soup.title.string
all_links = soup.find_all('a', href=True)
all_forms = soup.find_all('form')

# Find by attribute
meta_desc = soup.find('meta', {'name': 'description'})

# Extract form data
for form in soup.find_all('form'):
    action = form.get('action')
    method = form.get('method', 'GET')
    inputs = form.find_all('input')
```

#### CSRF Token Detection

**Common Token Names:**
- `csrf_token`
- `_token`
- `authenticity_token`
- `__RequestVerificationToken`
- `xsrf-token`

**Detection Pattern:**
```python
csrf_patterns = [
    'csrf_token', '_token', 'authenticity_token',
    '__RequestVerificationToken', 'xsrf-token'
]

for pattern in csrf_patterns:
    token = soup.find('input', {'name': pattern})
    if token:
        print(f"CSRF token found: {pattern}")
```

### Module 2.4: Authentication

#### Authentication Types

| Type | How It Works | Detection |
|------|--------------|-----------|
| Basic Auth | Credentials in headers | `Authorization: Basic` |
| Session-based | Cookie after login | `Set-Cookie` header |
| JWT | Self-contained token | `Authorization: Bearer` |
| OAuth | Third-party auth | Redirect flow |
| API Key | Token in header | `X-API-Key` header |

#### CSRF Tokens

**What They Are:**
- Unique tokens per request
- Prevent cross-site request forgery
- Must be extracted and submitted

**Extraction Methods:**
1. HTML input field
2. Meta tag
3. JavaScript variable

#### Login Automation Flow

```
1. GET login page
2. Extract CSRF token
3. Build login data
4. POST credentials
5. Check response (redirect/success)
6. Store session for future requests
```

---

## Phase 3: Offensive Tooling

### Module 3.1: API Intelligence

#### API Types

**REST API:**
- HTTP methods (GET, POST, PUT, DELETE)
- Stateless
- Resource-based
- JSON/XML responses

**GraphQL:**
- Single endpoint
- Query language
- Request exactly what you need
- Strong typing

**SOAP:**
- XML-based
- Strict standards
- Complex
- Enterprise use

#### API Discovery

**Common Endpoints:**
```
/api, /api/v1, /api/v2, /api/v3
/graphql, /graphiql
/swagger, /docs
/users, /admin, /login, /auth
/status, /health, /ping, /info
```

#### GraphQL Introspection

**Why It's Dangerous:**
- Reveals entire schema
- Exposes all queries and mutations
- Shows available data

**Prevention:**
- Disable introspection in production
- Use allowlists
- Implement rate limiting

### Module 3.2: Exploit Development

#### SQL Injection

**How It Works:**
- Attacker input becomes part of SQL query
- Query structure is altered
- Database executes malicious code

**Types:**
- Union-based: Combine queries
- Error-based: Use error messages
- Boolean-based: True/false tests
- Time-based: Sleep delays

**Common Payloads:**
```sql
' OR '1'='1
' UNION SELECT NULL--
1' AND 1=1--
1' ORDER BY 1--
' OR 1=1--
admin'--
```

#### Command Injection

**How It Works:**
- Input passed to system shell
- Command is executed
- Output returned to attacker

**Common Operators:**
- `;` - Command separator
- `|` - Pipe
- `||` - OR operator
- `&&` - AND operator
- `` ` `` - Command substitution
- `$()` - Command substitution

#### Authentication Bypass

**Common Techniques:**
- SQL injection in login fields
- Default credentials
- Weak password policies
- Session fixation
- Cookie manipulation

### Module 3.3: Obfuscation

#### Why Obfuscate?

**Reasons:**
- AV Evasion: Signature detection
- IDS/IPS Bypass: Pattern matching
- Filter Bypass: Input validation
- Stealth: Hide true purpose

#### Common Techniques

| Technique | Example | Output |
|-----------|---------|--------|
| Base64 | `whoami` | `d2hvYW1p` |
| Hex | `whoami` | `77686f616d69` |
| XOR | `whoami` XOR `secret` | `1a2b3c4d` |
| ROT13 | `whoami` | `jubnzv` |
| URL | `whoami` | `%77%68%6f%61%6d%69` |
| Unicode | `whoami` | `\u0077\u0068...` |

#### Multi-Layer Obfuscation

**Why Multiple Layers:**
- Harder to detect
- More difficult to reverse
- Bypasses multiple filters

**Process:**
```
Original: whoami
→ ROT13: jubnzv
→ Base64: anVibnp2
→ Hex: 616e5649626e7032
```

### Module 3.4: Data Exfiltration

#### Exfiltration Channels

| Channel | Pros | Cons |
|---------|------|------|
| HTTP | Common, easy | Logged, suspicious |
| DNS | Often allowed | Size limits |
| ICMP | Simple, not logged | Requires root |
| Steganography | Very stealthy | Limited capacity |

#### DNS Exfiltration

**How It Works:**
1. Encode data in subdomain
2. Send DNS query
3. Attacker captures query
4. Decode data from subdomain

**Limitations:**
- Max subdomain length: 63 chars
- Usually only 20 chars available
- Best for small data

#### Steganography

**How It Works:**
1. Convert data to bits
2. Modify least significant bits
3. Image appears unchanged
4. Data extracted from LSB

**Capacity:**
- Each pixel has 3 channels (RGB)
- Each channel has 1 LSB
- 8 pixels = 3 bytes of data
- Example: 100x100 image ≈ 3.7KB capacity

---

## Phase 4: Post-Exploitation

### Module 4.1: C2 Framework

#### C2 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    C2 SERVER                               │
│  - Manages agents                                          │
│  - Distributes tasks                                       │
│  - Collects results                                        │
│  - Provides interface                                      │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ Communication
                   │ (HTTP, DNS, ICMP)
                   │
┌──────────────────▼──────────────────────────────────────────┐
│                    C2 AGENT                                │
│  - Registers with server                                   │
│  - Receives tasks                                          │
│  - Executes commands                                       │
│  - Sends results                                           │
│  - Beacons/Heartbeats                                      │
└─────────────────────────────────────────────────────────────┘
```

#### Communication Patterns

**Beacon:**
- Periodic check-ins
- Stealthy
- Low bandwidth

**Polling:**
- Continuous connection
- Faster response
- More detectable

**Heartbeat:**
- Keep-alive signals
- Low data usage
- Maintains connection

#### Agent Commands

| Command | Purpose |
|---------|---------|
| `whoami` | Get current user |
| `hostname` | Get system name |
| `platform` | Get OS platform |
| `ip` | Get IP address |
| `info` | Full agent info |
| `ls` | List directory |
| `who` | Logged-in users |
| `system [cmd]` | Execute shell command |
| `download [file]` | Download file |
| `sleep [sec]` | Sleep for seconds |
| `beacon [sec]` | Set beacon interval |
| `exit` | Stop agent |

### Module 4.2: System Enumeration

#### Why Enumerate?

**Analogy:** Detective gathering evidence at a crime scene.

**What We Learn:**
- System configuration
- User accounts
- Running processes
- Network layout
- Installed software
- Security posture

#### Enumeration Categories

| Category | What to Look For | Why Important |
|----------|------------------|---------------|
| System | OS, version, architecture | Identify exploits |
| Users | User list, groups, privileges | Privilege escalation |
| Processes | Running services, connections | Services to attack |
| Network | Interfaces, routes, ARP | Lateral movement |
| Services | Installed services, versions | Vulnerability matching |
| Cron/Scheduled | Automated tasks | Persistence, escalation |
| Security | Firewall, AV, SELinux | Detect defense mechanisms |
| Files | Config files, logs, creds | Data discovery |

#### Key Commands

**Linux:**
```bash
uname -a          # OS info
cat /etc/os-release  # Distribution
whoami            # Current user
id                # User info
ifconfig -a       # Network interfaces
ps aux            # Processes
netstat -tulpn    # Listening ports
crontab -l        # Cron jobs
env               # Environment variables
sudo -l           # Sudo permissions
```

**Windows:**
```cmd
systeminfo        # OS info
whoami            # Current user
net user          # User list
ipconfig /all     # Network config
tasklist          # Processes
netstat -ano      # Listening ports
schtasks /query   # Scheduled tasks
set               # Environment variables
```

### Module 4.3: Persistence

#### What is Persistence?

**Analogy:** Leaving hidden doors in a building you've broken into.

**Why We Need It:**
- Maintain access
- Survive reboots
- Avoid detection
- Enable long-term operations

#### Persistence Methods

| Method | Platform | Detection Risk |
|--------|----------|---------------|
| Startup Script | All | Medium |
| Cron/Scheduled | Linux/Windows | Low |
| Registry | Windows | Medium |
| Service | All | Low |
| Autostart | Linux/Windows | Medium |
| Launch Agent | macOS | Low |

#### Windows Persistence

**Startup Folder:**
```
C:\Users\[user]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
```

**Registry Run Keys:**
```
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
```

**Scheduled Tasks:**
```cmd
schtasks /create /tn "TaskName" /tr "C:\path\to\payload.exe" /sc onlogon /f
```

**Windows Service:**
```cmd
sc create "ServiceName" binPath= "C:\path\to\payload.exe" start= auto
```

#### Linux Persistence

**Cron Jobs:**
```bash
# Add to crontab
@reboot /path/to/payload

# Or add to system cron
/etc/cron.d/
```

**Systemd Service:**
```bash
# Create service file
/etc/systemd/system/service-name.service

# Enable and start
systemctl enable service-name
systemctl start service-name
```

**Autostart (.desktop):**
```bash
# User autostart
~/.config/autostart/app.desktop

# System autostart
/etc/xdg/autostart/app.desktop
```

### Module 4.4: Packaging

#### Why Package?

**Reasons:**
- No Python required on target
- Code protection
- Single file deployment
- Stealth (appears as legitimate binary)

#### Packaging Tools

| Tool | Pros | Cons |
|------|------|------|
| PyInstaller | Fast, popular | Large file size |
| cx_Freeze | Good cross-platform | Slower |
| Nuitka | More optimized | Slower, larger |

#### PyInstaller Usage

**Basic:**
```bash
pyinstaller --onefile script.py
```

**Advanced:**
```bash
pyinstaller --onefile \
            --windowed \
            --name AppName \
            --icon app.ico \
            --exclude tkinter \
            --hidden-import requests \
            script.py
```

#### Optimization

**Reduce File Size:**
- Exclude unused modules
- Use UPX compression
- Optimize imports

**UPX Compression:**
```bash
upx --best --brute output.exe
```

#### Detection Considerations

**Stealth Tips:**
- Use common binary names
- Add version information
- Use legitimate-looking icons
- Sign with real certificate (if possible)
- Avoid UPX (can be a signature)

---

## Appendix: Quick Reference

### Common Python Snippets

#### Socket Programming
```python
# TCP Server
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(('0.0.0.0', 9999))
server.listen(5)
client, addr = server.accept()
data = client.recv(1024)
client.send(data)
client.close()

# TCP Client
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(('127.0.0.1', 9999))
client.send(b'Hello')
data = client.recv(1024)
client.close()
```

#### HTTP Client
```python
# GET
response = requests.get('https://api.example.com/users', params={'id': 1})

# POST
response = requests.post('https://api.example.com/login', 
                        json={'username': 'admin', 'password': 'pass'})

# Session
session = requests.Session()
session.post('https://example.com/login', data={'user': 'admin', 'pass': 'pass'})
response = session.get('https://example.com/dashboard')
```

#### Scapy
```python
# Create packet
packet = IP(dst="8.8.8.8") / TCP(dport=80, flags="S")

# Send/receive
response = sr1(packet, timeout=2)

# Sniff
packets = sniff(filter="tcp", count=10)

# Show
packet.show()
```

#### Web Recon
```python
# Directory brute force
brute = DirectoryBruteForcer(url, wordlist)
results = brute.scan()

# HTML analysis
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url(url)

# Login automation
auth = AuthAutomation()
session = auth.login_basic(url, username, password)
```

#### Exploitation
```python
# SQL Injection
exploit = SQLInjectionExploit(target, parameter)
result = exploit.exploit()

# Command Injection
exploit = CommandInjectionExploit(target, parameter)
result = exploit.exploit()

# Obfuscation
obf = ObfuscationEngine()
encoded = obf.encode_base64(payload)
```

#### Post-Exploitation
```python
# Enumeration
enumerator = SystemEnumerator()
results = enumerator.enumerate_all()

# Persistence
manager = PersistenceManager()
manager.install_payload(payload_path)
manager.add_startup_script()
manager.add_cron_job()

# Packaging
builder = PackageBuilder()
builder.build_pyinstaller(script_path, config)
```

---

## Notes Complete

### Important Reminders

1. **Always get permission** before testing
2. **Stay within scope** of the engagement
3. **Protect sensitive data** you find
4. **Report responsibly** when finding vulnerabilities
5. **Keep learning** - security is always changing

---

**[STUDENT NOTES COMPLETE]**
