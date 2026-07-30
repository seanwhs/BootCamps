# Appendix C: Security Best Practices & Operational Security (OPSEC)

## Comprehensive Security Guide for Ethical Hackers

This appendix provides essential security best practices and operational security (OPSEC) guidelines for conducting ethical hacking activities safely and responsibly.

---

## Table of Contents

1. [Legal & Ethical Framework](#legal--ethical-framework)
2. [Operational Security (OPSEC)](#operational-security-opsec)
3. [Safe Testing Practices](#safe-testing-practices)
4. [Data Protection & Handling](#data-protection--handling)
5. [Tool Security](#tool-security)
6. [Logging & Documentation](#logging--documentation)
7. [Cleanup & Remediation](#cleanup--remediation)
8. [Incident Response](#incident-response)
9. [Professional Conduct](#professional-conduct)
10. [Checklists & Templates](#checklists--templates)

---

## Legal & Ethical Framework

### The Ethical Hacker's Creed

```
I will:
- Only test systems I own or have explicit written permission to test
- Always stay within the scope defined in the engagement agreement
- Report vulnerabilities responsibly and confidentially
- Protect all data I access during testing
- Never use my skills for personal gain or malicious purposes
- Continuously improve my knowledge and skills
- Share knowledge responsibly and ethically
```

### Legal Requirements

#### Authorization Documentation

```python
# Template for authorization tracking
class AuthorizationTracker:
    def __init__(self):
        self.authorizations = {}
    
    def add_authorization(self, target, scope, start_date, end_date, 
                         authorized_by, contact_info, scope_document):
        """Track authorization for a target"""
        self.authorizations[target] = {
            'scope': scope,
            'start_date': start_date,
            'end_date': end_date,
            'authorized_by': authorized_by,
            'contact_info': contact_info,
            'scope_document': scope_document,
            'timestamp': datetime.now().isoformat()
        }
    
    def check_authorization(self, target, action):
        """Check if an action is authorized"""
        if target in self.authorizations:
            auth = self.authorizations[target]
            # Check scope and dates
            return True
        return False
```

#### Scope Definition Template

```yaml
# scope_template.yaml
engagement:
  name: "Security Assessment"
  client: "Client Name"
  date: "2024-01-01"
  
scope:
  targets:
    - "192.168.1.0/24"
    - "example.com"
    - "api.example.com"
  
  excluded:
    - "192.168.1.1"
    - "internal.example.com"
  
  allowed_methods:
    - "port scanning"
    - "vulnerability scanning"
    - "manual testing"
  
  prohibited:
    - "Denial of Service"
    - "Social Engineering"
    - "Physical Access"
  
testing_hours:
  - "09:00-17:00 EST"
  - "Weekdays only"

contacts:
  primary: "John Doe (johndoe@client.com)"
  secondary: "Jane Smith (janesmith@client.com)"
```

### Consent & Permission

```python
# Permission verification
class PermissionVerifier:
    def __init__(self):
        self.verified_targets = set()
    
    def verify_permission(self, target):
        """Verify you have permission to test a target"""
        if target.startswith('192.168.'):
            # Check if in scope
            return self._check_scope(target)
        elif target.endswith('.local'):
            # Internal network
            return self._check_scope(target)
        else:
            # External target
            return self._check_external_permission(target)
    
    def _check_scope(self, target):
        # Implement scope checking
        return True  # Only if in scope
    
    def _check_external_permission(self, target):
        # Verify external targets
        return False  # Always verify
```

---

## Operational Security (OPSEC)

### Personal OPSEC Checklist

#### Before Any Operation

```markdown
## Pre-Operation Checklist

### Environment Security
- [ ] Use VPN/VPS for all testing
- [ ] Use isolated testing machine/virtual machine
- [ ] Ensure no personal information in testing environment
- [ ] Use disposable email addresses if needed
- [ ] Clear browser history and cookies
- [ ] Disable automatic updates
- [ ] Check for malware/backdoors in your system

### Communication Security
- [ ] Use encrypted communications (Signal, ProtonMail, etc.)
- [ ] Use burner phone numbers for engagement
- [ ] Use encrypted messaging for team communication
- [ ] Never discuss engagements in public or on unencrypted channels
- [ ] Use code names for clients in communications

### Tool Security
- [ ] Use clean tools (from official sources)
- [ ] Verify tool hashes (SHA256)
- [ ] Use temporary/lab-specific tool installations
- [ ] Configure tools to use proxies/VPN
- [ ] Enable logging for all actions
- [ ] Use separate user accounts for testing

### Documentation
- [ ] Document all actions with timestamps
- [ ] Save all output from tools
- [ ] Screenshot key findings
- [ ] Record IP addresses and timestamps
- [ ] Maintain chain of custody for evidence
```

### OPSEC Scripts

```python
# OPSEC Helper Class
class OPSECHelper:
    def __init__(self):
        self.operations_log = []
        self.secure_temp_dir = "/tmp/opsec"
        os.makedirs(self.secure_temp_dir, exist_ok=True)
    
    def sanitize_data(self, data):
        """Remove personally identifiable information"""
        # Remove IPs
        ip_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
        data = re.sub(ip_pattern, '[REDACTED_IP]', data)
        
        # Remove emails
        email_pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
        data = re.sub(email_pattern, '[REDACTED_EMAIL]', data)
        
        # Remove usernames
        # Add custom patterns as needed
        
        return data
    
    def secure_delete(self, filepath):
        """Securely delete a file"""
        if os.path.exists(filepath):
            # Overwrite with random data
            size = os.path.getsize(filepath)
            with open(filepath, 'wb') as f:
                f.write(os.urandom(size))
            
            # Delete
            os.remove(filepath)
    
    def log_operation(self, action, details):
        """Log operation with timestamp"""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'action': action,
            'details': details
        }
        self.operations_log.append(entry)
        
        # Save to encrypted log
        self._save_encrypted_log()
    
    def _save_encrypted_log(self):
        """Save encrypted log"""
        # Implement encryption
        pass
```

### Network OPSEC

```python
# VPN/Proxy Configuration
class OPSECNetwork:
    def __init__(self):
        self.proxies = {
            'http': 'socks5://127.0.0.1:1080',
            'https': 'socks5://127.0.0.1:1080'
        }
        self.vpn_interface = 'tun0'
    
    def check_vpn_status(self):
        """Check if VPN is active"""
        import subprocess
        try:
            result = subprocess.run(['ip', 'addr', 'show', self.vpn_interface],
                                   capture_output=True)
            return result.returncode == 0
        except:
            return False
    
    def route_traffic_through_proxy(self, session):
        """Route HTTP traffic through proxy"""
        session.proxies.update(self.proxies)
        return session
    
    def get_external_ip(self):
        """Get current external IP address"""
        import requests
        try:
            response = requests.get('https://api.ipify.org?format=json')
            return response.json().get('ip')
        except:
            return None
```

### Tor Integration

```python
class TorOPSEC:
    def __init__(self):
        self.tor_proxy = {
            'http': 'socks5://127.0.0.1:9050',
            'https': 'socks5://127.0.0.1:9050'
        }
        self.tor_control_port = 9051
        self.tor_password = 'password'
    
    def renew_tor_circuit(self):
        """Renew Tor circuit for new identity"""
        import stem
        try:
            from stem import Signal
            from stem.control import Controller
            
            with Controller.from_port(port=self.tor_control_port) as controller:
                controller.authenticate(password=self.tor_password)
                controller.signal(Signal.NEWNYM)
                return True
        except:
            return False
    
    def get_tor_session(self):
        """Get HTTP session with Tor proxy"""
        import requests
        session = requests.Session()
        session.proxies.update(self.tor_proxy)
        return session
```

---

## Safe Testing Practices

### Testing Methodology

```python
class SafeTester:
    def __init__(self):
        self.engagement_scope = {}
        self.results = []
    
    def pre_scan_check(self, target):
        """Validate target before scanning"""
        # Check if target is in scope
        if target not in self.engagement_scope.get('targets', []):
            raise ValueError(f"Target {target} not in scope")
        
        # Check time window
        if not self._within_time_window():
            raise ValueError("Testing outside authorized hours")
        
        # Check for exclusion
        if target in self.engagement_scope.get('excluded', []):
            raise ValueError(f"Target {target} is excluded from testing")
        
        return True
    
    def rate_limit_requests(self, requests_per_minute):
        """Rate limit requests to avoid overwhelming target"""
        import time
        delay = 60.0 / requests_per_minute
        
        def decorator(func):
            def wrapper(*args, **kwargs):
                time.sleep(delay)
                return func(*args, **kwargs)
            return wrapper
        return decorator
    
    def _within_time_window(self):
        """Check if current time is within authorized window"""
        from datetime import datetime, time
        now = datetime.now().time()
        
        start = time(9, 0)  # 9 AM
        end = time(17, 0)   # 5 PM
        
        if now >= start and now <= end:
            return True
        return False
```

### Denial of Service Prevention

```python
class DoSPrevention:
    def __init__(self):
        self.max_requests_per_second = 10
        self.max_concurrent_connections = 10
        self.request_timestamps = []
    
    def check_rate_limit(self):
        """Check if rate limit is exceeded"""
        from datetime import datetime, timedelta
        
        now = datetime.now()
        one_second_ago = now - timedelta(seconds=1)
        
        # Clean old timestamps
        self.request_timestamps = [t for t in self.request_timestamps 
                                  if t > one_second_ago]
        
        # Check rate
        if len(self.request_timestamps) >= self.max_requests_per_second:
            return False
        
        self.request_timestamps.append(now)
        return True
    
    def scan_safely(self, target, ports):
        """Scan ports safely with delays"""
        import time
        
        for port in ports:
            # Check rate limit
            if not self.check_rate_limit():
                print(f"Rate limit reached, waiting...")
                time.sleep(1)
                continue
            
            # Perform scan
            self._scan_port(target, port)
            
            # Small delay between scans
            time.sleep(0.1)
    
    def _scan_port(self, target, port):
        """Single port scan with safety checks"""
        # Implement scanning logic
        pass
```

### Safe Payload Testing

```python
class SafePayloadTesting:
    def __init__(self):
        self.allow_destructive = False
        self.test_environment = True
    
    def validate_payload(self, payload):
        """Validate payload safety"""
        # Check for destructive commands
        destructive_patterns = [
            'rm -rf',
            'drop table',
            'delete from',
            'format',
            'shutdown',
            'reboot'
        ]
        
        for pattern in destructive_patterns:
            if pattern in payload.lower():
                if not self.allow_destructive:
                    raise ValueError(f"Destructive payload detected: {pattern}")
        
        # Check for data exfiltration
        exfil_patterns = [
            'curl.*http',
            'wget.*http',
            'nc.*-e',
            'python.*socket'
        ]
        
        # Implement validation
        return True
```

---

## Data Protection & Handling

### Data Classification

```python
class DataClassifier:
    """Classify data based on sensitivity"""
    
    SENSITIVITY_LEVELS = {
        'PUBLIC': 0,
        'INTERNAL': 1,
        'CONFIDENTIAL': 2,
        'RESTRICTED': 3,
        'SECRET': 4
    }
    
    def classify_data(self, data):
        """Classify data based on content"""
        # Check for sensitive patterns
        sensitive_patterns = {
            'PII': r'\d{3}-\d{2}-\d{4}',  # SSN
            'EMAIL': r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            'PASSWORD': r'password\s*[:=]\s*[\w]+',
            'CREDIT_CARD': r'\b(?:\d[ -]*?){13,16}\b',
            'API_KEY': r'[A-Za-z0-9]{32,}'
        }
        
        highest_level = 0
        
        for pattern_type, pattern in sensitive_patterns.items():
            if re.search(pattern, str(data)):
                level = self.SENSITIVITY_LEVELS.get(pattern_type, 2)
                highest_level = max(highest_level, level)
        
        return highest_level
```

### Data Encryption

```python
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64

class DataEncryption:
    """Handle encryption of sensitive data"""
    
    def __init__(self, password=None):
        if password:
            self.key = self._derive_key(password)
        else:
            self.key = Fernet.generate_key()
        
        self.cipher = Fernet(self.key)
    
    def _derive_key(self, password):
        """Derive encryption key from password"""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=b'toolkit_salt',
            iterations=100000,
        )
        return base64.urlsafe_b64encode(kdf.derive(password.encode()))
    
    def encrypt(self, data):
        """Encrypt data"""
        if isinstance(data, str):
            data = data.encode()
        return self.cipher.encrypt(data)
    
    def decrypt(self, encrypted_data):
        """Decrypt data"""
        return self.cipher.decrypt(encrypted_data)
    
    def encrypt_file(self, input_path, output_path):
        """Encrypt a file"""
        with open(input_path, 'rb') as f:
            data = f.read()
        
        encrypted = self.encrypt(data)
        
        with open(output_path, 'wb') as f:
            f.write(encrypted)
    
    def decrypt_file(self, input_path, output_path):
        """Decrypt a file"""
        with open(input_path, 'rb') as f:
            encrypted = f.read()
        
        decrypted = self.decrypt(encrypted)
        
        with open(output_path, 'wb') as f:
            f.write(decrypted)
```

### Secure Storage

```python
import json
import os
from datetime import datetime

class SecureStorage:
    """Secure storage for test results"""
    
    def __init__(self, storage_dir='./secure_data'):
        self.storage_dir = storage_dir
        os.makedirs(storage_dir, exist_ok=True)
        
        # Create encryption
        self.encryption = DataEncryption()
    
    def store_result(self, target, data):
        """Store encrypted result"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"{target}_{timestamp}.enc"
        filepath = os.path.join(self.storage_dir, filename)
        
        # Convert to JSON
        json_data = json.dumps(data)
        
        # Encrypt and save
        self.encryption.encrypt_file_from_string(json_data, filepath)
        
        return filepath
    
    def retrieve_result(self, filepath):
        """Retrieve encrypted result"""
        # Decrypt and load
        json_data = self.encryption.decrypt_file_to_string(filepath)
        return json.loads(json_data)
    
    def cleanup(self, retention_days=30):
        """Cleanup old results"""
        from datetime import datetime, timedelta
        
        cutoff = datetime.now() - timedelta(days=retention_days)
        
        for file in os.listdir(self.storage_dir):
            filepath = os.path.join(self.storage_dir, file)
            mtime = datetime.fromtimestamp(os.path.getmtime(filepath))
            
            if mtime < cutoff:
                # Securely delete
                self.secure_delete(filepath)
    
    def secure_delete(self, filepath):
        """Securely delete a file"""
        if os.path.exists(filepath):
            # Overwrite with random data multiple times
            size = os.path.getsize(filepath)
            for _ in range(3):
                with open(filepath, 'wb') as f:
                    f.write(os.urandom(size))
            
            os.remove(filepath)
```

---

## Logging & Documentation

### Comprehensive Logging

```python
import logging
from logging.handlers import RotatingFileHandler
import json
from datetime import datetime

class EngagementLogger:
    """Professional logging for security engagements"""
    
    def __init__(self, engagement_name, log_dir='./logs'):
        self.engagement_name = engagement_name
        self.log_dir = log_dir
        os.makedirs(log_dir, exist_ok=True)
        
        # Setup file logging
        log_file = os.path.join(log_dir, f"{engagement_name}.log")
        handler = RotatingFileHandler(
            log_file, maxBytes=10*1024*1024, backupCount=5
        )
        handler.setFormatter(
            logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        )
        
        self.logger = logging.getLogger(engagement_name)
        self.logger.setLevel(logging.DEBUG)
        self.logger.addHandler(handler)
        
        # JSON log file
        self.json_log = os.path.join(log_dir, f"{engagement_name}.json")
        self.entries = []
        
    def log_action(self, action, details, severity='INFO'):
        """Log an action"""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'action': action,
            'details': details,
            'severity': severity,
            'engagement': self.engagement_name
        }
        
        # Write to text log
        self.logger.log(getattr(logging, severity), f"{action}: {details}")
        
        # Write to JSON log
        self.entries.append(entry)
        self._save_json_log()
        
        # Print to console for important events
        if severity in ['WARNING', 'ERROR', 'CRITICAL']:
            print(f"[{severity}] {action}: {details}")
    
    def _save_json_log(self):
        """Save JSON log"""
        with open(self.json_log, 'w') as f:
            json.dump(self.entries, f, indent=2)
    
    def export_report(self, format='json'):
        """Export log as report"""
        if format == 'json':
            return json.dumps(self.entries, indent=2)
        elif format == 'html':
            return self._export_html()
        elif format == 'txt':
            return self._export_text()
    
    def _export_html(self):
        """Export as HTML report"""
        html = "<html><body><h1>Engagement Log</h1>"
        html += f"<p>Engagement: {self.engagement_name}</p>"
        html += "<table border='1'>"
        html += "<tr><th>Timestamp</th><th>Action</th><th>Details</th></tr>"
        
        for entry in self.entries:
            html += f"<tr><td>{entry['timestamp']}</td>"
            html += f"<td>{entry['action']}</td>"
            html += f"<td>{entry['details']}</td></tr>"
        
        html += "</table></body></html>"
        return html
    
    def _export_text(self):
        """Export as text report"""
        text = f"Engagement Log: {self.engagement_name}\n"
        text += "="*60 + "\n"
        
        for entry in self.entries:
            text += f"[{entry['timestamp']}] {entry['action']}\n"
            text += f"  {entry['details']}\n\n"
        
        return text
```

### Evidence Collection

```python
class EvidenceCollector:
    """Collect and preserve evidence"""
    
    def __init__(self, evidence_dir='./evidence'):
        self.evidence_dir = evidence_dir
        os.makedirs(evidence_dir, exist_ok=True)
        self.encryption = DataEncryption()
    
    def capture_screenshot(self, url, output_name=None):
        """Capture screenshot of web page"""
        try:
            from selenium import webdriver
            from selenium.webdriver.chrome.options import Options
            
            options = Options()
            options.add_argument('--headless')
            driver = webdriver.Chrome(options=options)
            
            driver.get(url)
            
            if output_name is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                output_name = f"screenshot_{timestamp}.png"
            
            output_path = os.path.join(self.evidence_dir, output_name)
            driver.save_screenshot(output_path)
            driver.quit()
            
            # Encrypt evidence
            encrypted_path = output_path + '.enc'
            self.encryption.encrypt_file(output_path, encrypted_path)
            os.remove(output_path)
            
            return encrypted_path
            
        except Exception as e:
            print(f"Error capturing screenshot: {e}")
            return None
    
    def save_packet_capture(self, packets, output_name=None):
        """Save packet capture"""
        try:
            from scapy.all import wrpcap
            
            if output_name is None:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                output_name = f"capture_{timestamp}.pcap"
            
            output_path = os.path.join(self.evidence_dir, output_name)
            wrpcap(output_path, packets)
            
            # Encrypt evidence
            encrypted_path = output_path + '.enc'
            self.encryption.encrypt_file(output_path, encrypted_path)
            os.remove(output_path)
            
            return encrypted_path
            
        except Exception as e:
            print(f"Error saving packet capture: {e}")
            return None
    
    def save_tool_output(self, output, output_name=None):
        """Save tool output"""
        if output_name is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            output_name = f"output_{timestamp}.txt"
        
        output_path = os.path.join(self.evidence_dir, output_name)
        
        with open(output_path, 'w') as f:
            f.write(output)
        
        # Encrypt evidence
        encrypted_path = output_path + '.enc'
        self.encryption.encrypt_file(output_path, encrypted_path)
        os.remove(output_path)
        
        return encrypted_path
```

---

## Cleanup & Remediation

### Cleanup Script

```python
class CleanupManager:
    """Manage cleanup of testing artifacts"""
    
    def __init__(self):
        self.cleanup_actions = []
        self.original_state = {}
    
    def record_original_state(self, filepath):
        """Record original state of a file"""
        if os.path.exists(filepath):
            with open(filepath, 'rb') as f:
                self.original_state[filepath] = f.read()
    
    def add_cleanup_action(self, action, *args, **kwargs):
        """Add a cleanup action"""
        self.cleanup_actions.append((action, args, kwargs))
    
    def execute_cleanup(self):
        """Execute all cleanup actions"""
        for action, args, kwargs in self.cleanup_actions:
            try:
                action(*args, **kwargs)
            except Exception as e:
                print(f"Cleanup error: {e}")
        
        self.cleanup_actions = []
    
    def restore_file(self, filepath):
        """Restore file to original state"""
        if filepath in self.original_state:
            with open(filepath, 'wb') as f:
                f.write(self.original_state[filepath])
    
    def remove_persistence(self):
        """Remove all persistence mechanisms"""
        # Remove cron jobs
        os.system('crontab -r 2>/dev/null')
        
        # Remove startup scripts
        startup_dir = os.path.expanduser('~/.config/autostart')
        if os.path.exists(startup_dir):
            for file in os.listdir(startup_dir):
                if 'system-helper' in file:
                    os.remove(os.path.join(startup_dir, file))
        
        # Remove services
        os.system('systemctl stop SystemHelper 2>/dev/null')
        os.system('systemctl disable SystemHelper 2>/dev/null')
        os.rm('/etc/systemd/system/SystemHelper.service')
        
        # Remove registry entries (Windows)
        if os.name == 'nt':
            import winreg
            try:
                key = winreg.HKEY_CURRENT_USER
                subkey = r'Software\Microsoft\Windows\CurrentVersion\Run'
                with winreg.OpenKey(key, subkey, 0, winreg.KEY_SET_VALUE) as reg_key:
                    winreg.DeleteValue(reg_key, 'SystemHelper')
            except:
                pass
```

### Evidence Handling

```python
class EvidenceHandler:
    """Handle evidence collection and preservation"""
    
    def __init__(self, case_id):
        self.case_id = case_id
        self.chain_of_custody = []
    
    def collect_evidence(self, evidence_path, description):
        """Collect evidence and add to chain of custody"""
        import hashlib
        
        # Calculate hash
        with open(evidence_path, 'rb') as f:
            data = f.read()
            hash_value = hashlib.sha256(data).hexdigest()
        
        entry = {
            'timestamp': datetime.now().isoformat(),
            'evidence_path': evidence_path,
            'description': description,
            'sha256_hash': hash_value,
            'collected_by': os.getlogin(),
            'case_id': self.case_id
        }
        
        self.chain_of_custody.append(entry)
        
        # Write to chain of custody file
        self._save_chain_of_custody()
        
        return entry
    
    def _save_chain_of_custody(self):
        """Save chain of custody to file"""
        filename = f"chain_of_custody_{self.case_id}.json"
        with open(filename, 'w') as f:
            json.dump(self.chain_of_custody, f, indent=2)
```

---

## Incident Response

### Incident Response Plan

```python
class IncidentResponse:
    """Handle security incidents during testing"""
    
    def __init__(self):
        self.incident_log = []
        self.contact_list = {}
    
    def detect_incident(self, event):
        """Detect potential incident"""
        indicators = [
            'system_crash',
            'data_loss',
            'unauthorized_access',
            'malware_detection',
            'suspicious_activity'
        ]
        
        for indicator in indicators:
            if indicator in event.lower():
                self.respond_to_incident(event)
                return True
        
        return False
    
    def respond_to_incident(self, incident):
        """Respond to an incident"""
        self.log_incident(incident)
        self.contact_emergency(incident)
        self.preserve_evidence(incident)
        self.initiate_cleanup()
    
    def log_incident(self, incident):
        """Log the incident"""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'incident': incident,
            'status': 'detected',
            'response_initiated': True
        }
        self.incident_log.append(entry)
    
    def contact_emergency(self, incident):
        """Contact emergency contacts"""
        for contact, info in self.contact_list.items():
            if info['role'] == 'emergency':
                print(f"Contacting {contact}: {incident}")
                # Send notification
    
    def preserve_evidence(self, incident):
        """Preserve evidence of incident"""
        # Collect relevant logs
        # Save system state
        # Capture memory dump
        pass
    
    def initiate_cleanup(self):
        """Initiate cleanup procedures"""
        cleanup = CleanupManager()
        cleanup.execute_cleanup()
    
    def escalate_incident(self, incident, severity='high'):
        """Escalate incident to management"""
        if severity == 'high':
            print(f"ALERT: Escalating incident - {incident}")
            # Send urgent notifications
        elif severity == 'medium':
            print(f"WARNING: Incident requires attention - {incident}")
            # Send notifications
        else:
            print(f"INFO: Incident logged - {incident}")
```

---

## Professional Conduct

### Code of Conduct

```python
class ProfessionalConduct:
    """Guidelines for professional conduct"""
    
    def __init__(self):
        self.principles = [
            "Act with integrity at all times",
            "Respect client confidentiality",
            "Maintain professional competence",
            "Protect the security community",
            "Report vulnerabilities responsibly",
            "Never misuse your skills",
            "Stay within authorized scope",
            "Document all actions",
            "Protect sensitive data",
            "Be transparent about limitations"
        ]
    
    def check_conduct(self, action):
        """Check if action meets professional standards"""
        # Check legality
        if not self.is_legal(action):
            return False, "Action may be illegal"
        
        # Check ethics
        if not self.is_ethical(action):
            return False, "Action is unethical"
        
        # Check scope
        if not self.in_scope(action):
            return False, "Action outside authorized scope"
        
        return True, "Action meets professional standards"
    
    def is_legal(self, action):
        """Check if action is legal"""
        # Implement legality checks
        return True
    
    def is_ethical(self, action):
        """Check if action is ethical"""
        # Implement ethics checks
        return True
    
    def in_scope(self, action):
        """Check if action is in scope"""
        # Implement scope checks
        return True
```

### Reporting Vulnerabilities

```python
class VulnerabilityReporter:
    """Responsible vulnerability reporting"""
    
    def __init__(self):
        self.report_template = """
        ========================================
        VULNERABILITY DISCLOSURE
        ========================================
        
        Date: {date}
        Reporter: {reporter}
        Organization: {organization}
        
        VULNERABILITY SUMMARY
        ----------------------
        Title: {title}
        Severity: {severity}
        CVE: {cve}
        
        DESCRIPTION
        ------------
        {description}
        
        IMPACT
        -------
        {impact}
        
        REPRODUCTION STEPS
        ------------------
        {reproduction_steps}
        
        AFFECTED SYSTEMS
        ----------------
        {affected_systems}
        
        RECOMMENDED MITIGATION
        ----------------------
        {mitigation}
        
        ========================================
        """
    
    def create_report(self, vulnerability):
        """Create vulnerability report"""
        return self.report_template.format(
            date=datetime.now().strftime('%Y-%m-%d'),
            reporter=vulnerability.get('reporter', 'Anonymous'),
            organization=vulnerability.get('organization', ''),
            title=vulnerability.get('title', 'Unknown Vulnerability'),
            severity=vulnerability.get('severity', 'Medium'),
            cve=vulnerability.get('cve', 'None'),
            description=vulnerability.get('description', ''),
            impact=vulnerability.get('impact', ''),
            reproduction_steps=vulnerability.get('steps', ''),
            affected_systems=vulnerability.get('systems', ''),
            mitigation=vulnerability.get('mitigation', '')
        )
```

---

## Checklists & Templates

### Engagement Checklist

```markdown
## Pre-Engagement
- [ ] Signed NDA in place
- [ ] Signed Rules of Engagement
- [ ] Scope defined and approved
- [ ] Contact information confirmed
- [ ] Testing window scheduled
- [ ] Emergency procedures defined
- [ ] IP addresses/domains confirmed
- [ ] Test accounts created
- [ ] VPN/proxy configured
- [ ] VPN/proxy tested

## During Engagement
- [ ] All actions logged
- [ ] Evidence collected
- [ ] Scope boundaries respected
- [ ] Testing hours observed
- [ ] Critical systems avoided
- [ ] Production data protected
- [ ] Weekly status reports
- [ ] Issues escalated as needed

## Post-Engagement
- [ ] All test data securely deleted
- [ ] All persistence removed
- [ ] All access revoked
- [ ] Logs preserved
- [ ] Report drafted
- [ ] Report reviewed
- [ ] Report delivered
- [ ] Debriefing conducted
- [ ] Feedback collected
- [ ] Lessons learned documented
```

### Daily OpSec Checklist

```markdown
## Daily OPSEC Checklist

### Morning
- [ ] Verify VPN connection
- [ ] Check proxy configuration
- [ ] Clear browser history
- [ ] Check for updates
- [ ] Verify tool hashes
- [ ] Confirm scope for day
- [ ] Review testing plan

### Throughout Day
- [ ] Use encrypted communications
- [ ] Avoid personal accounts
- [ ] Don't post to social media
- [ ] Stay within scope
- [ ] Log all actions
- [ ] Secure all data
- [ ] Protect credentials

### Evening
- [ ] Encrypt all data
- [ ] Secure transfer of findings
- [ ] Clear clipboard
- [ ] Clear temporary files
- [ ] Close all connections
- [ ] Log out of all systems
- [ ] Power off VM if needed
```

### Incident Response Template

```markdown
## Incident Response Template

### Incident Details
- **Date/Time:** ____________________
- **Type of Incident:** ____________________
- **Severity:** [ ] Low [ ] Medium [ ] High [ ] Critical
- **Reported By:** ____________________

### Description
_____________________________________________________
_____________________________________________________
_____________________________________________________

### Impact Assessment
- Systems Affected: ____________________
- Data Affected: ____________________
- Business Impact: ____________________

### Response Actions
| Time | Action | By |
|------|--------|-----|
|      |        |     |
|      |        |     |
|      |        |     |

### Evidence Collected
| Evidence | Location | Hash |
|----------|----------|------|
|          |          |      |
|          |          |      |

### Resolution
- [ ] Incident contained
- [ ] Root cause identified
- [ ] Remediation applied
- [ ] Evidence preserved
- [ ] Report completed
- [ ] Lessons learned

### Lessons Learned
_____________________________________________________
_____________________________________________________
_____________________________________________________
```

---

## Appendix C Complete

*This appendix provides essential security practices for conducting ethical hacking operations safely and professionally. Always prioritize security, legality, and ethics in all your activities.*

---

**[APPENDIX C COMPLETE]**
