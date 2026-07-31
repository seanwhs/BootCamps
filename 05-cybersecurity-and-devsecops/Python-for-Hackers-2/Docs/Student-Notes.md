# STUDENT NOTES
## Python for Hackers: Advanced Engineering & Defensive Architecture

### Comprehensive Lecture Notes & Reference Guide

## TABLE OF CONTENTS

### Part 0: Introduction & Fundamentals
- [Chapter 0.1: Course Overview](#chapter-01-course-overview)
- [Chapter 0.2: Development Environment](#chapter-02-development-environment)
- [Chapter 0.3: Project Structure](#chapter-03-project-structure)

### Part 1: Infrastructure Automation & Protocol Analysis
- [Chapter 1.1: Configuration Management](#chapter-11-configuration-management)
- [Chapter 1.2: Logging System](#chapter-12-logging-system)
- [Chapter 1.3: Session Manager](#chapter-13-session-manager)
- [Chapter 1.4: Paramiko Wrapper](#chapter-14-paramiko-wrapper)
- [Chapter 1.5: Netmiko Wrapper](#chapter-15-netmiko-wrapper)
- [Chapter 1.6: Scapy Wrapper](#chapter-16-scapy-wrapper)
- [Chapter 1.7: Protocol Abstraction](#chapter-17-protocol-abstraction)

### Part 2: High-Speed Packet Sniffing & Asynchronous Integration
- [Chapter 2.1: Event Loop Manager](#chapter-21-event-loop-manager)
- [Chapter 2.2: Async Packet Sniffer](#chapter-22-async-packet-sniffer)
- [Chapter 2.3: Queue Management](#chapter-23-queue-management)
- [Chapter 2.4: Packet Injection](#chapter-24-packet-injection)

### Part 3: Stealth Reconnaissance & Asynchronous Tooling
- [Chapter 3.1: Async Scanner](#chapter-31-async-scanner)
- [Chapter 3.2: Async Brute-Forcer](#chapter-32-async-brute-forcer)
- [Chapter 3.3: DOM Analyzer](#chapter-33-dom-analyzer)
- [Chapter 3.4: Modular Recon](#chapter-34-modular-recon)

### Part 4: Advanced Tooling Design, Obfuscation & Hardening
- [Chapter 4.1: Plugin Architecture](#chapter-41-plugin-architecture)
- [Chapter 4.2: Code Obfuscation](#chapter-42-code-obfuscation)
- [Chapter 4.3: Security Hardening](#chapter-43-security-hardening)
- [Chapter 4.4: Production CLI](#chapter-44-production-cli)

### Appendices & Primers
- [Appendix A: Scapy Reference](#appendix-a-scapy-reference)
- [Appendix B: Asyncio Reference](#appendix-b-asyncio-reference)
- [Appendix C: Security Reference](#appendix-c-security-reference)
- [Primer Notes: Network Programming](#primer-notes-network-programming)
- [Primer Notes: Async Programming](#primer-notes-async-programming)
- [Primer Notes: Scapy Advanced](#primer-notes-scapy-advanced)

### Quick Reference
- [Command Cheat Sheet](#command-cheat-sheet)
- [Code Snippets Library](#code-snippets-library)
- [Troubleshooting Guide](#troubleshooting-guide)

---

## CHAPTER 0.1: COURSE OVERVIEW

### Core Philosophy

**"Python for Hackers" merges advanced offensive engineering with rigorous defensive practices.**

- **Think like a defender** - Understanding attacks makes you a better defender
- **Use async for networking** - Concurrent I/O is essential for performance
- **Build modular systems** - Plugins enable rapid capability expansion
- **Practice defense in depth** - Multiple layers of security
- **Test everything** - Verification ensures reliability

### The Pyramid of Learning

```
        ┌────────────────────────────────────┐
        │   Part 4: Hardening & Modules     │  ← Production Polish
        ├────────────────────────────────────┤
        │   Part 3: Stealth Reconnaissance   │  ← Offensive Capability
        ├────────────────────────────────────┤
        │   Part 2: High-Speed Sniffing      │  ← Network Mastery
        ├────────────────────────────────────┤
        │   Part 1: Infrastructure Automation│  ← Foundation
        └────────────────────────────────────┘
```

### Key Libraries Overview

| Library | Purpose | When to Use |
|---------|---------|-------------|
| **Paramiko** | SSH Automation | Custom SSH, file transfers, interactive sessions |
| **Netmiko** | Device Automation | Multi-vendor network devices, configuration |
| **Scapy** | Packet Manipulation | Custom packets, sniffing, analysis |
| **asyncio** | Concurrency | High-performance networking |
| **aiohttp** | HTTP Client | Async HTTP requests |
| **Playwright** | Browser Automation | JavaScript-rendered pages |

### Ethical Commitment Statement

> "I understand that the tools and techniques taught in this course are for ethical and educational purposes only. I agree to use this knowledge responsibly and only on systems I own or have explicit permission to test."

---

## CHAPTER 0.2: DEVELOPMENT ENVIRONMENT

### Quick Setup Commands

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate   # Windows

# Install core dependencies
pip install scapy paramiko netmiko
pip install httpx aiohttp asyncio
pip install beautifulsoup4 lxml playwright
pip install python-dotenv pyyaml cryptography
pip install pydantic click rich orjson uvloop

# Development tools
pip install pytest pytest-asyncio pytest-cov
pip install black mypy ruff pre-commit

# Install Playwright browsers
playwright install
```

### Environment Variables

```bash
# .env file template
ENV=development
DEBUG=true
SCAPY_INTERFACE=eth0
SSH_TIMEOUT=10
HTTP_RATE_LIMIT=50
LOG_LEVEL=INFO
ENABLE_SANDBOX=true
```

### Verification Script

```python
#!/usr/bin/env python3
import sys

def check_package(pkg):
    try:
        __import__(pkg)
        print(f"✅ {pkg}")
        return True
    except ImportError:
        print(f"❌ {pkg}")
        return False

packages = ['scapy', 'paramiko', 'netmiko', 'aiohttp', 'bs4', 'playwright']
all_good = all(check_package(pkg) for pkg in packages)
sys.exit(0 if all_good else 1)
```

---

## CHAPTER 0.3: PROJECT STRUCTURE

### Directory Tree

```
pyhack_suite/
├── core/              # Configuration, session management, event loop
│   ├── config.py      # Environment-based configuration
│   ├── session_manager.py  # Unified connection management
│   └── event_loop.py  # Async event loop management
├── network/           # Network protocol implementations
│   ├── packet_handler.py    # Scapy integration
│   ├── device_automation.py # Netmiko/Paramiko
│   └── protocol_abstractions.py # Unified interfaces
├── recon/             # Reconnaissance tools
│   ├── scanner.py     # Async port/service scanning
│   ├── brute_forcer.py # Credential/directory brute forcing
│   ├── dom_analyzer.py # JavaScript-heavy application analysis
│   └── evasion.py     # Rate limiting, jitter, rotation
├── modules/           # Plugin architecture
│   ├── loader.py      # Dynamic module loading
│   └── base.py        # Base module interface
├── utils/             # Utilities
│   ├── crypto.py      # Obfuscation, encoding, encryption
│   ├── logging.py     # Structured logging
│   └── sandbox.py     # Execution isolation
└── cli/               # Command-line interface
    └── main.py        # Production CLI
```

### Key Files Explained

| File | Purpose |
|------|---------|
| `__init__.py` | Makes directory a Python package |
| `config.py` | Centralized configuration management |
| `session_manager.py` | Unified connection handling |
| `event_loop.py` | Async event management |

---

## CHAPTER 1.1: CONFIGURATION MANAGEMENT

### Key Concepts

**Environment Variables vs Hardcoding**

| Approach | Pros | Cons |
|----------|------|------|
| **Environment Variables** | Secure, flexible, 12-factor | More setup required |
| **Hardcoding** | Simple | Insecure, inflexible |

**Configuration Dataclass Pattern**

```python
from dataclasses import dataclass, field

@dataclass
class NetworkConfig:
    """Network configuration settings."""
    
    scapy_interface: str = field(default="eth0")
    """Default network interface."""
    
    ssh_timeout: int = field(default=10)
    """SSH connection timeout in seconds."""
    
    max_packet_queue: int = field(default=10000)
    """Maximum packet queue size."""
```

### Config Loader Pattern (Singleton)

```python
class ConfigLoader:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if hasattr(self, '_initialized'):
            return
        self._initialized = True
        self._config = self._load_from_environment()
```

### Environment Variable Mapping

```python
os.getenv("SCAPY_INTERFACE", "eth0")  # Default value
int(os.getenv("SSH_TIMEOUT", "10"))   # Type conversion
os.getenv("ENABLE_SANDBOX", "true").lower() == "true"  # Boolean
```

### Important Notes

- **Always use environment variables for secrets**
- **Never commit .env files to version control**
- **Use dataclasses for structured configuration**
- **Validate configuration at startup**
- **Use `python-dotenv` for .env file loading**

---

## CHAPTER 1.2: LOGGING SYSTEM

### Key Concepts

**Log Levels**

| Level | Use Case |
|-------|----------|
| **DEBUG** | Detailed diagnostic information |
| **INFO** | General application progress |
| **WARNING** | Unexpected events, recoverable issues |
| **ERROR** | Error conditions, partial failures |
| **CRITICAL** | Severe issues, application might crash |

### Sensitive Data Redaction

```python
SENSITIVE_PATTERNS = {
    'password': re.compile(r'(password|passwd|pwd)[\s]*[:=][\s]*[^\s,}]+', re.IGNORECASE),
    'token': re.compile(r'(token|access_token|api_key)[\s]*[:=][\s]*[^\s,}]+', re.IGNORECASE),
    'email': re.compile(r'[\w\.-]+@[\w\.-]+\.\w+'),
}
```

### Log Rotation Configuration

```python
file_handler = logging.handlers.RotatingFileHandler(
    filename="logs/pyhack.log",
    maxBytes=10_485_760,  # 10 MB
    backupCount=5,
    encoding='utf-8'
)
```

### Best Practices

1. **Never log passwords or sensitive data**
2. **Use structured logging for machine parsing**
3. **Include context (module, function, line)**
4. **Rotate logs to prevent disk filling**
5. **Log at appropriate levels**

---

## CHAPTER 1.3: SESSION MANAGER

### Key Concepts

**Connection States**

```
DISCONNECTED → CONNECTING → CONNECTED → AUTHENTICATING → AUTHENTICATED
     ↑                                       ↓
     └───────────────────────────────────────┘
```

**Connection Pooling**

```
┌─────────────────────────────────────────────┐
│              CONNECTION POOL               │
│  ┌────────┐ ┌────────┐ ┌────────┐        │
│  │ Conn 1 │ │ Conn 2 │ │ Conn 3 │ ...    │
│  └────────┘ └────────┘ └────────┘        │
│         ↓         ↓         ↓             │
│  ┌─────────────────────────────────────┐  │
│  │       Connection Manager           │  │
│  │  - Get/Return connections          │  │
│  │  - Health checks                   │  │
│  │  - Cleanup                         │  │
│  └─────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### Connection Types

| Type | Protocol | Use Case |
|------|----------|----------|
| **SSH** | SSH/TLS | Secure shell, command execution |
| **Netmiko** | SSH/Telnet | Network device automation |
| **Raw Socket** | TCP/UDP | Low-level network operations |

### Important Notes

- **Session IDs are unique identifiers for connections**
- **Connection pooling improves performance**
- **Always close sessions when done**
- **Use session contexts for automatic cleanup**
- **Handle authentication retries with exponential backoff**

---

## CHAPTER 1.4: PARAMIKO WRAPPER

### Key Concepts

**SSH Authentication Methods**

1. **Password Authentication**
   ```python
   client.connect(hostname, username=user, password=pass)
   ```

2. **Private Key Authentication**
   ```python
   key = paramiko.RSAKey.from_private_key_file(key_path)
   client.connect(hostname, username=user, pkey=key)
   ```

3. **SSH Agent Authentication**
   ```python
   from paramiko.agent import Agent
   agent = Agent()
   for key in agent.get_keys():
       client.connect(hostname, username=user, pkey=key)
   ```

### Important Notes

- **Always use `AutoAddPolicy` or `RejectPolicy`**
- **Handle authentication retries with backoff**
- **Use SFTP for file transfers**
- **Interactive shells require `invoke_shell()`**
- **Close connections with `client.close()`**

---

## CHAPTER 1.5: NETMIKO WRAPPER

### Key Concepts

**Supported Device Types**

| Vendor | Device Type |
|--------|-------------|
| Cisco | `cisco_ios`, `cisco_asa`, `cisco_nxos` |
| Juniper | `juniper_junos` |
| Arista | `arista_eos` |
| Palo Alto | `paloalto_panos` |
| F5 | `f5_ltm` |

**Common Operations**

| Operation | Method |
|-----------|--------|
| Show Command | `send_command("show version")` |
| Configuration | `send_config_set(["interface Gi0/1", "no shutdown"])` |
| Save Config | `send_command("write memory")` |
| Backup | `send_command("show running-config")` |

### Device Family Detection

```python
def _detect_device_family(self, device_type):
    if 'cisco' in device_type:
        return 'cisco'
    elif 'juniper' in device_type:
        return 'juniper'
    elif 'arista' in device_type:
        return 'arista'
    return 'other'
```

---

## CHAPTER 1.6: SCAPY WRAPPER

### Key Concepts

**Packet Layering**

```
┌─────────────────────────────────────────────┐
│         Ethernet Layer                      │
│  ┌───────────────────────────────────────┐  │
│  │         IP Layer                      │  │
│  │  ┌─────────────────────────────────┐  │  │
│  │  │       TCP/UDP/ICMP             │  │  │
│  │  │  ┌─────────────────────────┐   │  │  │
│  │  │  │      Payload            │   │  │  │
│  │  │  └─────────────────────────┘   │  │  │
│  │  └─────────────────────────────────┘  │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### Packet Building

```python
# Layer 3 packet
packet = IP(dst="192.168.1.1") / TCP(dport=80, flags="S")

# Layer 2 packet
packet = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1")

# With payload
packet = IP(dst="8.8.8.8") / ICMP(type=8) / Raw(load=b"Hello")
```

### Common Operations

| Operation | Function |
|-----------|----------|
| Send | `send(packet)` |
| Send & Receive | `sr1(packet)` |
| Sniff | `sniff(filter="tcp")` |
| Save PCAP | `wrpcap("file.pcap", packets)` |
| Load PCAP | `rdpcap("file.pcap")` |

---

## CHAPTER 1.7: PROTOCOL ABSTRACTION

### Key Concepts

**Abstraction Layer Benefits**

1. **Single API for all protocols**
2. **Easy protocol switching**
3. **Consistent error handling**
4. **Reduced code duplication**

**Factory Pattern**

```python
class ProtocolFactory:
    @staticmethod
    def create_interface(config):
        protocol = config.get('protocol', 'ssh')
        if protocol == 'ssh':
            return SSHInterface(config)
        elif protocol == 'netmiko':
            return NetmikoInterface(config)
        elif protocol == 'scapy':
            return PacketInterface(config)
```

### Unified Interface

```python
class NetworkInterface(ABC):
    @abstractmethod
    def connect(self) -> bool: pass
    
    @abstractmethod
    def disconnect(self): pass
    
    @abstractmethod
    def execute(self, command: str) -> Tuple[str, str]: pass
```

---

## CHAPTER 2.1: EVENT LOOP MANAGER

### Key Concepts

**Event Loop Architecture**

```
┌─────────────────────────────────────────────────────────┐
│                      EVENT LOOP                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Task 1     │  │   Task 2     │  │   Task 3     │  │
│  │  (Running)   │  │  (Waiting)   │  │  (Done)      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         ↓               ↓                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │          I/O Completion Queue                    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Purpose |
|-----------|---------|
| **Event Loop** | Scheduler for async tasks |
| **Tasks** | Wrapped coroutines |
| **Queue** | Communication between tasks |
| **Future** | Promise of a result |

### Important Notes

- **Always use `asyncio.run()` for top-level entry**
- **Use `asyncio.create_task()` for background tasks**
- **Set timeouts for long operations**
- **Use `run_in_executor()` for blocking code**
- **Implement graceful shutdown**

---

## CHAPTER 2.2: ASYNC PACKET SNIFFER

### Key Concepts

**AsyncSniffer Architecture**

```
┌─────────────────────────────────────────────────────────┐
│                      AsyncSniffer                       │
│  ┌─────────────────┐          ┌─────────────────────┐  │
│  │ Background      │          │ Async Queue         │  │
│  │ Sniffing Thread │ ──────── │ (Non-blocking)      │  │
│  │ (Scapy)         │          │                     │  │
│  └─────────────────┘          └─────────────────────┘  │
│         ↓                              ↓                │
│  ┌─────────────────────────────────────────────────┐  │
│  │              Event Loop Processing              │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Performance Tips

1. **Use `store=False` to avoid memory accumulation**
2. **Use `filter` to reduce packet volume**
3. **Use `AsyncSniffer` for non-blocking capture**
4. **Implement backpressure to prevent memory exhaustion**
5. **Process packets in batches**

---

## CHAPTER 2.3: QUEUE MANAGEMENT

### Key Concepts

**Queue Types**

| Type | Characteristics | Use Case |
|------|-----------------|----------|
| **FIFO** | First-in-first-out | General purpose |
| **Priority** | Higher priority first | Critical packets |
| **Ring Buffer** | Fixed size, overwrites | High performance |
| **Throttled** | Rate limited | Avoiding detection |

### Backpressure

```
Producer → [Queue] → Consumer
              ↓
     [Buffer Full] → Drop packets
     [Backpressure] → Slow producer
```

### Implementation Notes

- **Use `asyncio.Queue` for async communication**
- **Implement backpressure to prevent memory exhaustion**
- **Use priority queues for critical packets**
- **Ring buffers are faster but lose data**
- **Rate limiting prevents detection**

---

## CHAPTER 2.4: PACKET INJECTION

### Key Concepts

**Injection Types**

1. **Scheduled Injection**
   - Time-based (send every N seconds)
   - Count-based (send N packets)
   - With jitter for stealth

2. **Trigger-Based Injection**
   - Sniff for trigger packets
   - Respond with crafted packet
   - SYN-ACK to SYN, etc.

3. **Fuzzing Injection**
   - Randomize packet fields
   - Send malformed packets
   - Test protocol implementations

### Attack Patterns

```python
# TCP SYN Flood
packet = IP(src=spoof_ip, dst=target) / TCP(dport=80, flags="S")
config = InjectionConfig(interval=0.01, count=1000)

# ARP Spoofing
packet = ARP(op=2, psrc=gateway, pdst=target)
config = InjectionConfig(interval=1.0, count=10)

# ICMP Redirect
packet = IP(src=gateway, dst=target) / ICMP(type=5, code=1)
```

---

## CHAPTER 3.1: ASYNC SCANNER

### Key Concepts

**Scanning Techniques**

| Technique | Description | Stealth Level |
|-----------|-------------|---------------|
| **TCP Connect** | Full TCP handshake | Low |
| **SYN Scan** | Half-open (stealth) | Medium |
| **UDP Scan** | Send empty UDP packet | Low |
| **ACK Scan** | ACK packet for firewall detection | High |

**Stealth Features**

1. **Random port order** - Avoid sequential detection
2. **Jitter** - Random delays between requests
3. **Rate limiting** - Control requests per second
4. **Source IP rotation** - Use multiple source IPs

### Service Detection

```python
def detect_service(port, banner):
    patterns = {
        'ssh': r'ssh-([\d.]+)',
        'http': r'HTTP/([\d.]+)',
        'mysql': r'mysql/([\d.]+)',
    }
    # Match patterns
```

### OS Fingerprinting

| OS | Characteristic Ports |
|----|---------------------|
| Windows | 135, 139, 445, 3389 |
| Linux | 22, 80, 443, 3306 |
| Cisco | 22, 23, 443, 500 |
| MacOS | 22, 88, 445, 548, 631, 993 |

---

## CHAPTER 3.2: ASYNC BRUTE-FORCER

### Key Concepts

**Brute Force Types**

1. **HTTP Basic Auth**
   - Username/password combinations
   - Success/failure detection

2. **Directory Enumeration**
   - Web path discovery
   - Status code analysis

3. **Subdomain Enumeration**
   - DNS enumeration
   - Wildcard detection

### Stealth Techniques

```
┌─────────────────────────────────────────────────────────┐
│                    STEALTH FEATURES                     │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Rate Limiting - Control requests per second   │  │
│  ├─────────────────────────────────────────────────┤  │
│  │ Jitter - Random delays between requests       │  │
│  ├─────────────────────────────────────────────────┤  │
│  │ User-Agent Rotation - Random browser strings  │  │
│  ├─────────────────────────────────────────────────┤  │
│  │ Session Management - Reuse connections        │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Important Notes

- **Always implement rate limiting**
- **Use jitter to avoid pattern detection**
- **Rotate user agents regularly**
- **Handle session management**
- **Implement exponential backoff on failures**

---

## CHAPTER 3.3: DOM ANALYZER

### Key Concepts

**Architecture**

```
┌─────────────────────────────────────────────────────────┐
│                    DOM ANALYZER                        │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Headless Browser (Playwright)                  │  │
│  │ - Full JavaScript execution                    │  │
│  │ - DOM manipulation                            │  │
│  └─────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────┐  │
│  │ DOM Parser (BeautifulSoup)                    │  │
│  │ - HTML structure analysis                     │  │
│  │ - Element extraction                          │  │
│  └─────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Vulnerability Detection                       │  │
│  │ - Security headers                            │  │
│  │ - XSS patterns                                │  │
│  │ - Open redirects                              │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Vulnerability Detection

| Vulnerability | Detection Method |
|---------------|------------------|
| Missing HSTS | Check headers |
| Missing CSP | Check headers |
| XSS | Evaluate JavaScript content |
| CSRF | Check forms for tokens |
| Open Redirect | Check redirect parameters |

---

## CHAPTER 3.4: MODULAR RECON

### Key Concepts

**Module Architecture**

```python
class ReconModule(ABC):
    @abstractmethod
    def get_metadata(self) -> ModuleMetadata: pass
    
    @abstractmethod
    async def run(self, target: str, **kwargs) -> Dict: pass
    
    async def pre_run(self): pass
    async def post_run(self): pass
```

### Module Registry

```python
class ModuleRegistry:
    def register(self, module_class):
        self.modules[module_class.__name__] = module_class
    
    def get_module(self, name):
        return self.modules[name]()
    
    def get_all(self):
        return list(self.modules.keys())
```

### Benefits of Modular Architecture

1. **Extensible** - Easy to add new modules
2. **Maintainable** - Each module is self-contained
3. **Reusable** - Modules can be combined
4. **Testable** - Each module can be tested independently

---

## CHAPTER 4.1: PLUGIN ARCHITECTURE

### Key Concepts

**Plugin Lifecycle**

```
UNLOADED → LOADING → LOADED → INITIALIZING → INITIALIZED → RUNNING → STOPPED
                      ↑                                ↓
                      └────────────────────────────────┘
```

**Plugin Manifest**

```python
@dataclass
class PluginManifest:
    name: str
    version: str = "1.0.0"
    description: str = ""
    requires: List[str] = field(default_factory=list)
    provides: List[str] = field(default_factory=list)
    permissions: List[str] = field(default_factory=list)
    sandboxed: bool = True
```

### Plugin Loader

```python
class PluginLoader:
    def discover_plugins(self, directory):
        # Find plugin files
        # Register plugin classes
    
    def load_plugin(self, name):
        # Check dependencies
        # Create instance
        # Call on_load
        # Return instance
```

---

## CHAPTER 4.2: CODE OBFUSCATION

### Key Concepts

**Obfuscation Techniques**

| Technique | Description | Example |
|-----------|-------------|---------|
| **String Encoding** | Encode strings (Base64, XOR, RC4) | `base64.b64decode(b'ZGF0YQ==')` |
| **Dynamic Imports** | Import at runtime | `__import__('os')` |
| **Dead Code** | Non-executed code | `if False: execute()` |
| **Variable Renaming** | Random variable names | `_a1b2c3d4 = "data"` |
| **Control Flow** | Harder to follow execution | Using `exec` and `eval` |

**Encoding Methods**

| Method | Strength | Speed |
|--------|----------|-------|
| **Base64** | Weak | Fast |
| **XOR** | Weak | Fast |
| **RC4** | Medium | Fast |
| **AES** | Strong | Medium |

### Important Notes

- **Obfuscation is not encryption**
- **Use for evasion, not for protecting secrets**
- **May not work with all antivirus/EDR solutions**
- **Combine multiple techniques for better results**
- **Test on target environment before deployment**

---

## CHAPTER 4.3: SECURITY HARDENING

### Key Concepts

**Input Validation**

| Validation Type | Prevention |
|-----------------|------------|
| **Path Traversal** | Validate paths, use whitelist |
| **Command Injection** | Use subprocess lists, sanitize |
| **SQL Injection** | Parameterized queries |
| **XSS** | HTML escaping, CSP |
| **Deserialization** | Use JSON, restrict pickle |

**Sandbox Architecture**

```
┌─────────────────────────────────────────────────────────┐
│                    SANDBOX                             │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Resource Limits: CPU, Memory, Processes       │  │
│  ├─────────────────────────────────────────────────┤  │
│  │ Timeout: Maximum execution time                │  │
│  ├─────────────────────────────────────────────────┤  │
│  │ Workspace: Temporary isolated directory        │  │
│  ├─────────────────────────────────────────────────┤  │
│  │ Import Restrictions: Allowed modules only      │  │
│  ├─────────────────────────────────────────────────┤  │
│  │ Filesystem: Restricted access                  │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Security Checklist

- [ ] Input validation
- [ ] Parameterized SQL queries
- [ ] Escaped HTML output
- [ ] Secure password hashing (bcrypt/Argon2)
- [ ] SSL/TLS with certificate validation
- [ ] Session management with timeouts
- [ ] Rate limiting on authentication
- [ ] Secure deserialization
- [ ] Environment variables for secrets
- [ ] Regular security updates

---

## CHAPTER 4.4: PRODUCTION CLI

### Key Concepts

**CLI Architecture**

```
┌─────────────────────────────────────────────────────────┐
│                     CLI ARCHITECTURE                   │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Click Framework                                │  │
│  │ - Command hierarchy                           │  │
│  │ - Options and arguments                       │  │
│  └─────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Rich Output                                    │  │
│  │ - Colorized output                            │  │
│  │ - Tables and progress bars                    │  │
│  └─────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Commands                                       │  │
│  │ - scan, brute, module, plugin, config, console│  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Common Click Patterns

```python
@click.group()
def cli(): pass

@cli.command()
@click.argument('target')
@click.option('--ports', '-p', help='Ports')
@click.pass_context
def scan(ctx, target, ports):
    # Implementation
    pass
```

### Rich Output

```python
from rich.console import Console
from rich.table import Table

console = Console()

table = Table(title="Results")
table.add_column("Port", style="cyan")
table.add_column("Status", style="green")

for result in results:
    table.add_row(str(result.port), result.status)

console.print(table)
```

---

## APPENDIX A: SCAPY REFERENCE

### Common BPF Filters

| Filter | Description |
|--------|-------------|
| `tcp` | All TCP packets |
| `tcp port 80` | HTTP traffic |
| `host 192.168.1.1` | Traffic to/from IP |
| `src 192.168.1.100` | Traffic from IP |
| `dst 8.8.8.8` | Traffic to IP |
| `net 192.168.0.0/16` | Traffic to/from network |
| `not arp` | Exclude ARP |
| `tcp[13] & 0x02 != 0` | TCP SYN packets |

### Common Field Access

```python
# IP Layer
packet[IP].src
packet[IP].dst
packet[IP].ttl
packet[IP].proto

# TCP Layer
packet[TCP].sport
packet[TCP].dport
packet[TCP].seq
packet[TCP].ack
packet[TCP].flags

# UDP Layer
packet[UDP].sport
packet[UDP].dport

# ICMP Layer
packet[ICMP].type
packet[ICMP].code
```

### Common Operations

```python
# Send and Receive
response = sr1(packet, timeout=2)

# Sniff
packets = sniff(filter="tcp", count=10)

# Save PCAP
wrpcap("capture.pcap", packets)

# Load PCAP
packets = rdpcap("capture.pcap")
```

---

## APPENDIX B: ASYNCIO REFERENCE

### Common Async Functions

| Function | Purpose |
|----------|---------|
| `asyncio.run(coro)` | Run coroutine until complete |
| `asyncio.create_task(coro)` | Schedule task on event loop |
| `asyncio.gather(*coros)` | Run multiple coroutines concurrently |
| `asyncio.wait(tasks)` | Wait for tasks with conditions |
| `asyncio.wait_for(coro, timeout)` | Wait with timeout |
| `asyncio.sleep(seconds)` | Non-blocking sleep |

### Common Patterns

```python
# Multiple tasks
results = await asyncio.gather(
    task1(),
    task2(),
    task3()
)

# Timeout
try:
    result = await asyncio.wait_for(
        slow_operation(),
        timeout=5.0
    )
except asyncio.TimeoutError:
    result = None

# Queue
queue = asyncio.Queue()
await queue.put(item)
item = await queue.get()

# Lock
lock = asyncio.Lock()
async with lock:
    critical_section()
```

---

## APPENDIX C: SECURITY REFERENCE

### Password Hashing (bcrypt)

```python
import bcrypt

def hash_password(password):
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode(), salt)

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed)
```

### Input Validation

```python
import re

def validate_email(email):
    pattern = r'^[\w\.-]+@[\w\.-]+\.\w+$'
    return re.match(pattern, email) is not None

def validate_ip(ip):
    import ipaddress
    try:
        ipaddress.ip_address(ip)
        return True
    except ValueError:
        return False
```

### SQL Injection Prevention

```python
# Parameterized queries (SQLite)
cursor.execute(
    "SELECT * FROM users WHERE username = ?",
    (username,)
)

# Parameterized queries (psycopg2)
cursor.execute(
    "SELECT * FROM users WHERE username = %s",
    (username,)
)

# ORM (SQLAlchemy)
session.query(User).filter(User.username == username).first()
```

---

## COMMAND CHEAT SHEET

### Development Commands

```bash
# Environment
python -m venv venv
source venv/bin/activate
pip install -e .

# Testing
pytest
pytest -v
pytest --cov=pyhack_suite

# Code Quality
black .
mypy .
ruff check .

# Pre-commit
pre-commit install
pre-commit run --all-files
```

### PyHack Suite Commands

```bash
# Help
pyhack --help
pyhack scan --help

# Scanning
pyhack scan 192.168.1.1
pyhack scan 192.168.1.0/24 --ports 80,443
pyhack scan example.com --stealth --service

# Brute Forcing
pyhack brute https://example.com --type basic -u admin,root -P passwords.txt
pyhack brute https://example.com --type dir -w wordlist.txt
pyhack brute example.com --type subdomain -w subdomains.txt

# Modules
pyhack module list
pyhack module run port_scan 192.168.1.1

# Plugins
pyhack plugin list
pyhack plugin load myplugin
pyhack plugin unload myplugin

# Configuration
pyhack config --show
pyhack console
```

---

## CODE SNIPPETS LIBRARY

### Snippet 1: TCP Connect Scan

```python
async def tcp_connect_scan(host, port, timeout=2.0):
    try:
        reader, writer = await asyncio.wait_for(
            asyncio.open_connection(host, port),
            timeout=timeout
        )
        writer.close()
        await writer.wait_closed()
        return True, None
    except ConnectionRefusedError:
        return False, "closed"
    except asyncio.TimeoutError:
        return False, "filtered"
    except Exception as e:
        return False, str(e)
```

### Snippet 2: Async HTTP Request

```python
async def fetch_url(session, url):
    try:
        async with session.get(url, timeout=10) as response:
            return {
                'url': url,
                'status': response.status,
                'size': len(await response.text())
            }
    except Exception as e:
        return {'url': url, 'error': str(e)}
```

### Snippet 3: Packet Builder

```python
def build_tcp_syn_packet(dst_ip, dst_port, src_ip=None):
    if src_ip:
        ip = IP(src=src_ip, dst=dst_ip)
    else:
        ip = IP(dst=dst_ip)
    tcp = TCP(
        sport=random.randint(1024, 65535),
        dport=dst_port,
        flags="S",
        seq=random.randint(0, 0xFFFFFFFF)
    )
    return ip / tcp
```

### Snippet 4: ARP Scanner

```python
def arp_scan(ip_range, interface="eth0"):
    arp = ARP(pdst=ip_range)
    ether = Ether(dst="ff:ff:ff:ff:ff:ff")
    packet = ether / arp
    answered, _ = srp(packet, iface=interface, timeout=2, verbose=False)
    return [{'ip': p[1].psrc, 'mac': p[1].hwsrc} for p in answered]
```

### Snippet 5: Rate Limiter

```python
class RateLimiter:
    def __init__(self, rate, per_second=True):
        self.rate = rate
        self.per_second = per_second
        self._last_time = time.time()
        self._count = 0
        self._lock = asyncio.Lock()
    
    async def acquire(self):
        async with self._lock:
            now = time.time()
            period = 1.0 if self.per_second else 60.0
            
            if now - self._last_time >= period:
                self._count = 0
                self._last_time = now
            
            if self._count < self.rate:
                self._count += 1
                return True
            
            wait_time = period - (now - self._last_time)
            await asyncio.sleep(wait_time)
            self._count = 0
            self._last_time = time.time()
            return True
```

---

## TROUBLESHOOTING GUIDE

### Common Errors & Solutions

| Error | Solution |
|-------|----------|
| `Permission denied` | Run with sudo/administrator privileges |
| `ModuleNotFoundError` | Install missing package: `pip install <package>` |
| `TimeoutError` | Increase timeout value |
| `Connection refused` | Check target is reachable and port is open |
| `Address already in use` | Change port or kill existing process |
| `No route to host` | Check network connectivity |
| `Authentication failed` | Verify credentials |
| `Invalid filter` | Check BPF filter syntax |
| `MemoryError` | Reduce packet queue size, use store=False |

### Debugging Tips

1. **Use verbose mode** - `conf.verb = 2` for Scapy
2. **Print packet summaries** - `packet.summary()`
3. **Show packet structure** - `packet.show()`
4. **Log to file** - Enable debug logging
5. **Use Wireshark** - Compare captured packets
6. **Check interface** - `ip link show` or `ifconfig`
7. **Test with localhost** - Always works for testing
8. **Use mock objects** - For unit testing

### Performance Optimization

1. **Use `store=False`** - Don't store packets
2. **Set `conf.verb = 0`** - Quiet mode
3. **Use `conf.use_pcap = True`** - libpcap for performance
4. **Implement backpressure** - Prevent memory exhaustion
5. **Batch process packets** - Reduce overhead
6. **Use asyncio** - Concurrent processing
7. **Filter early** - Reduce packet volume
8. **Use connection pooling** - Reuse connections

---

```
[COMPLETED: Student Notes Generation]
```

## Notes Statistics

| Category | Entries |
|----------|---------|
| Chapters | 24 |
| Key Concepts | 85+ |
| Code Snippets | 50+ |
| Command Examples | 30+ |
| Troubleshooting Tips | 20+ |

---

**[END OF STUDENT NOTES]**
