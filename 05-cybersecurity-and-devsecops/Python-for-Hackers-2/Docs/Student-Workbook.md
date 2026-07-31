# STUDENT WORKBOOK
## Python for Hackers: Advanced Engineering & Defensive Architecture

### A Complete Hands-On Learning Companion

---

```
[STARTING: Student Workbook Generation]
[COMPLETED: Slide Outline]
[GENERATING: Comprehensive Student Workbook]
```

---

## TABLE OF CONTENTS

### Part 0: Introduction & Setup
- [Workbook 0.1: Course Overview & Learning Objectives](#workbook-01-course-overview--learning-objectives)
- [Workbook 0.2: Development Environment Setup](#workbook-02-development-environment-setup)
- [Workbook 0.3: Project Structure Creation](#workbook-03-project-structure-creation)

### Part 1: Infrastructure Automation & Protocol Analysis
- [Workbook 1.1: Configuration Management](#workbook-11-configuration-management)
- [Workbook 1.2: Logging System](#workbook-12-logging-system)
- [Workbook 1.3: Session Manager](#workbook-13-session-manager)
- [Workbook 1.4: Paramiko Wrapper](#workbook-14-paramiko-wrapper)
- [Workbook 1.5: Netmiko Wrapper](#workbook-15-netmiko-wrapper)
- [Workbook 1.6: Scapy Wrapper](#workbook-16-scapy-wrapper)
- [Workbook 1.7: Protocol Abstraction](#workbook-17-protocol-abstraction)

### Part 2: High-Speed Packet Sniffing & Asynchronous Integration
- [Workbook 2.1: Event Loop Manager](#workbook-21-event-loop-manager)
- [Workbook 2.2: Async Packet Sniffer](#workbook-22-async-packet-sniffer)
- [Workbook 2.3: Queue Management](#workbook-23-queue-management)
- [Workbook 2.4: Packet Injection](#workbook-24-packet-injection)

### Part 3: Stealth Reconnaissance & Asynchronous Tooling
- [Workbook 3.1: Async Scanner](#workbook-31-async-scanner)
- [Workbook 3.2: Async Brute-Forcer](#workbook-32-async-brute-forcer)
- [Workbook 3.3: DOM Analyzer](#workbook-33-dom-analyzer)
- [Workbook 3.4: Modular Recon](#workbook-34-modular-recon)

### Part 4: Advanced Tooling Design, Obfuscation & Hardening
- [Workbook 4.1: Plugin Architecture](#workbook-41-plugin-architecture)
- [Workbook 4.2: Code Obfuscation](#workbook-42-code-obfuscation)
- [Workbook 4.3: Security Hardening](#workbook-43-security-hardening)
- [Workbook 4.4: Production CLI](#workbook-44-production-cli)

### Appendices & Primers
- [Appendix A: Scapy Deep Dive Exercises](#appendix-a-scapy-deep-dive-exercises)
- [Appendix B: Asyncio Exercises](#appendix-b-asyncio-exercises)
- [Appendix C: Security Best Practices Exercises](#appendix-c-security-best-practices-exercises)
- [Primer 1: Network Programming Fundamentals](#primer-1-network-programming-fundamentals)
- [Primer 2: Async Programming Fundamentals](#primer-2-async-programming-fundamentals)
- [Primer 3: Scapy Advanced Fundamentals](#primer-3-scapy-advanced-fundamentals)

### Final Project & Assessment
- [Final Project: Complete Reconnaissance Tool](#final-project-complete-reconnaissance-tool)
- [Assessment Rubric](#assessment-rubric)
- [Certificate of Completion Template](#certificate-of-completion-template)

---

## WORKBOOK 0.1: COURSE OVERVIEW & LEARNING OBJECTIVES

### Student Information

**Name:** ______________________________

**Date:** ______________________________

**Cohort:** ______________________________

### Course Objectives

By the end of this course, you will be able to:

| # | Objective | Confidence Level |
|---|-----------|------------------|
| 1 | Build a production-grade Python security framework | ⬜ ⬜ ⬜ |
| 2 | Implement unified connection management for SSH/Netmiko/Scapy | ⬜ ⬜ ⬜ |
| 3 | Create high-performance asynchronous packet sniffers | ⬜ ⬜ ⬜ |
| 4 | Develop stealth reconnaissance tools | ⬜ ⬜ ⬜ |
| 5 | Design plugin-based modular architectures | ⬜ ⬜ ⬜ |
| 6 | Apply code obfuscation techniques | ⬜ ⬜ ⬜ |
| 7 | Implement security hardening practices | ⬜ ⬜ ⬜ |
| 8 | Build professional CLI applications | ⬜ ⬜ ⬜ |

### Pre-Course Self-Assessment

Rate your current knowledge (1-5):

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Python Programming | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Networking Fundamentals | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Asynchronous Programming | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Packet Analysis | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Security Concepts | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

### Learning Goals

What do you hope to achieve in this course?

1. _________________________________________________________________

2. _________________________________________________________________

3. _________________________________________________________________

### Ethical Commitment

I understand that the tools and techniques taught in this course are for ethical and educational purposes only. I agree to use this knowledge responsibly and only on systems I own or have explicit permission to test.

**Signature:** ______________________________

**Date:** ______________________________

---

## WORKBOOK 0.2: DEVELOPMENT ENVIRONMENT SETUP

### System Check

**Operating System:**
- [ ] Linux (Ubuntu/Debian) - Recommended
- [ ] macOS
- [ ] Windows with WSL2
- [ ] Other: _____________

**Python Version:**
```bash
python --version
```
Version: _____________

**Verification:**
```bash
python -c "import sys; print(sys.version)"
```

### Virtual Environment Setup

**Step 1: Create Project Directory**
```bash
mkdir pyhack_suite
cd pyhack_suite
```

**Step 2: Create Virtual Environment**
```bash
python -m venv venv
```

**Step 3: Activate Environment**

| Platform | Command |
|----------|---------|
| Linux/macOS | `source venv/bin/activate` |
| Windows | `venv\Scripts\activate` |

**Step 4: Upgrade Pip**
```bash
pip install --upgrade pip
```

### Dependency Installation

**Core Dependencies:**
```bash
pip install scapy paramiko netmiko
pip install httpx aiohttp asyncio
pip install beautifulsoup4 lxml playwright
pip install python-dotenv pyyaml cryptography
pip install pydantic click rich orjson uvloop
```

**Development Dependencies:**
```bash
pip install pytest pytest-asyncio pytest-cov
pip install black mypy ruff pre-commit
```

**Install Playwright Browsers:**
```bash
playwright install
```

### Verification Script

Create `verify_setup.py`:

```python
#!/usr/bin/env python3
"""Verify development environment setup."""

import sys
import subprocess

def check_package(package):
    """Check if a package is installed."""
    try:
        __import__(package)
        print(f"✅ {package}")
        return True
    except ImportError:
        print(f"❌ {package} - NOT INSTALLED")
        return False

def main():
    print("=" * 50)
    print("PyHack Suite Environment Verification")
    print("=" * 50)
    
    packages = [
        'scapy', 'paramiko', 'netmiko',
        'aiohttp', 'asyncio',
        'bs4', 'lxml', 'playwright',
        'dotenv', 'yaml', 'cryptography',
        'pydantic', 'click', 'rich'
    ]
    
    print("\nChecking packages...")
    for pkg in packages:
        check_package(pkg)
    
    print("\n✅ Environment check complete!")
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

### Troubleshooting Common Issues

| Issue | Solution |
|-------|----------|
| `pip` not found | `python -m ensurepip` |
| Permission errors | Use `sudo` or administrator |
| Playwright browsers | `playwright install` |
| Scapy import errors | `sudo apt-get install python3-scapy` |
| Virtual environment not activating | Check path and permissions |

### Environment Checklist

- [ ] Python 3.9+ installed
- [ ] Virtual environment created and activated
- [ ] All core dependencies installed
- [ ] Playwright browsers installed
- [ ] Verification script runs without errors
- [ ] Git installed (for version control)
- [ ] IDE configured (VS Code/PyCharm recommended)

---

## WORKBOOK 0.3: PROJECT STRUCTURE CREATION

### Create Directory Structure

**Command:**
```bash
mkdir -p pyhack_suite/{core,network,recon,modules,utils,cli}
mkdir -p pyhack_suite/modules/examples
mkdir -p tests
mkdir -p scripts
mkdir -p docs
mkdir -p logs
mkdir -p data
touch pyhack_suite/__init__.py
touch pyhack_suite/core/__init__.py
touch pyhack_suite/network/__init__.py
touch pyhack_suite/recon/__init__.py
touch pyhack_suite/modules/__init__.py
touch pyhack_suite/utils/__init__.py
touch pyhack_suite/cli/__init__.py
```

### Project Structure Exercise

**Draw the complete project structure below:**

```
pyhack_suite/
├── 
├── 
├── 
├── 
├── 
├── 
├── 
├── 
└── 
```

**What does each directory contain?**

| Directory | Purpose |
|-----------|---------|
| `core/` | |
| `network/` | |
| `recon/` | |
| `modules/` | |
| `utils/` | |
| `cli/` | |
| `tests/` | |
| `data/` | |
| `logs/` | |

### Initial Files

**Create `.env.example`:**

```bash
cat > .env.example << 'EOF'
# PyHack Suite Environment Configuration
ENV=development
DEBUG=true

# Network Settings
SCAPY_INTERFACE=eth0
SCAPY_BUFFER_SIZE=65535
SSH_TIMEOUT=10
NETMIKO_TIMEOUT=30

# Reconnaissance Settings
HTTP_TIMEOUT=10.0
HTTP_MAX_CONNECTIONS=100
HTTP_RATE_LIMIT=50

# Security
ENABLE_SANDBOX=true
REDACT_SENSITIVE_DATA=true

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/pyhack.log
EOF
```

**Create `pyproject.toml`:**

```bash
cat > pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "pyhack-suite"
version = "0.1.0"
description = "A modular offensive security framework"
requires-python = ">=3.9"
dependencies = [
    "scapy>=2.5.0",
    "paramiko>=3.0.0",
    "netmiko>=4.0.0",
]
EOF
```

### Verification Steps

1. **Check directory structure:**
   ```bash
   tree pyhack_suite/
   ```

2. **Copy .env.example to .env:**
   ```bash
   cp .env.example .env
   ```

3. **Install in development mode:**
   ```bash
   pip install -e .
   ```

4. **Test import:**
   ```bash
   python -c "import pyhack_suite; print('Success!')"
   ```

### Directory Structure Quiz

1. What is the purpose of `__init__.py` files?

   _______________________________________________________________

2. Why do we use `pip install -e .`?

   _______________________________________________________________

3. What should be stored in the `data/` directory?

   _______________________________________________________________

### Self-Assessment

- [ ] I understand why we create a virtual environment
- [ ] I understand the purpose of each directory
- [ ] I have successfully installed in development mode
- [ ] I can import the pyhack_suite package
- [ ] I have copied `.env.example` to `.env`

---

## WORKBOOK 1.1: CONFIGURATION MANAGEMENT

### Learning Objectives

- Understand environment variable configuration
- Implement dataclass-based configuration
- Create a configuration loader
- Validate configuration values

### Exercise 1.1.1: Configuration Dataclasses

**Fill in the blanks:**

```python
from dataclasses import dataclass, field
from pathlib import Path

@dataclass
class NetworkConfig:
    """Network configuration settings."""
    
    scapy_interface: str = field(default="______")
    """Default network interface for packet operations."""
    
    ssh_timeout: int = field(default=___)
    """SSH connection timeout in seconds."""
    
    max_packet_queue: int = field(default=______)
    """Maximum packet queue size for backpressure handling."""
```

**Your Answer:**

1. Default interface: _______________
2. SSH timeout: _______________
3. Max packet queue: _______________

### Exercise 1.1.2: Configuration Loader

**Implement the missing methods:**

```python
class ConfigLoader:
    _instance = None
    _config = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ConfigLoader, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        # Load environment variables
        env_file = Path(__file__).parent.parent.parent / "___"
        if env_file.exists():
            load_dotenv(env_file)
        
        self._config = self._load_from_environment()
    
    def _load_from_environment(self) -> AppConfig:
        # Network configuration
        network_config = NetworkConfig(
            scapy_interface=os.getenv("SCAPY_INTERFACE", "___"),
            ssh_timeout=int(os.getenv("SSH_TIMEOUT", "___")),
            # Add more fields
        )
        return AppConfig(network=network_config)
    
    def get_config(self) -> AppConfig:
        return self._config
```

### Exercise 1.1.3: Create Your Own Config

**Add a custom configuration section:**

```python
@dataclass
class CustomConfig:
    """Custom configuration settings."""
    
    # Add 3 fields with defaults
    ____: ____ = field(default=____)
    ____: ____ = field(default=____)
    ____: ____ = field(default=____)
```

### Exercise 1.1.4: Configuration Validation

**Write a validation function:**

```python
def validate_config(config: AppConfig) -> bool:
    """Validate configuration values."""
    
    # Check that SSH timeout is positive
    if config.network.ssh_timeout <= 0:
        raise ValueError("SSH timeout must be positive")
    
    # Add more validations
    # 1. Buffer size must be >= 1500
    # 2. Rate limit must be > 0
    # 3. Log level must be valid
    
    return True
```

### Exercise 1.1.5: Environment Variable Practice

**Create a `.env` file with these values:**

```
ENV=development
DEBUG=true
SCAPY_INTERFACE=eth0
SSH_TIMEOUT=15
HTTP_RATE_LIMIT=100
LOG_LEVEL=DEBUG
ENABLE_SANDBOX=true
```

**Then answer:**
1. What is the SSH timeout value? _______________
2. Is debug mode enabled? _______________
3. What is the log level? _______________

### Hands-On Challenge

**Create a test script that:**
1. Loads configuration from environment
2. Validates the configuration
3. Prints all configuration values
4. Handles missing values gracefully

```python
# Your code here

```

---

## WORKBOOK 1.2: LOGGING SYSTEM

### Learning Objectives

- Implement structured logging
- Add log rotation
- Redact sensitive data
- Create contextual logging

### Exercise 1.2.1: Sensitive Data Redaction

**Write a regex pattern to redact:**

| Data Type | Regex Pattern |
|-----------|---------------|
| Email address | |
| Phone number | |
| Credit card | |
| IP address | |

```python
SENSITIVE_PATTERNS = {
    'email': re.compile(r'______'),
    'phone': re.compile(r'______'),
    'credit_card': re.compile(r'______'),
}
```

### Exercise 1.2.2: Log Formatter

**Fill in the missing code:**

```python
class StructuredFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': datetime.fromtimestamp(record.created).isoformat(),
            'level': record.______,
            'logger': record.______,
            'message': record.______,
            'module': record.______,
            'function': record.______,
            'line': record.______,
        }
        
        # Add exception info
        if record.______:
            log_entry['exception'] = {
                'type': record.exc_info[0].______,
                'message': str(record.exc_info[1]),
            }
        
        return json.dumps(log_entry)
```

### Exercise 1.2.3: Log Rotation

**Configure a rotating file handler:**

```python
import logging.handlers

file_handler = logging.handlers.RotatingFileHandler(
    filename="______",
    maxBytes=______,  # 10 MB
    backupCount=______,
    encoding='utf-8'
)
```

### Exercise 1.2.4: Logger Factory

**Create a logger factory:**

```python
class LoggerFactory:
    _loggers = {}
    
    @classmethod
    def get_logger(cls, name: str) -> logging.Logger:
        if name not in cls._loggers:
            logger = logging.______(name)
            cls._loggers[name] = logger
        return cls._loggers[name]
```

### Exercise 1.2.5: Contextual Logging

**Add extra context to a log entry:**

```python
logger.info("User action", extra={
    'user_id': ______,
    'action': ______,
    'ip': ______,
    'duration': ______,
})
```

### Hands-On Challenge

**Create a logging system that:**
1. Logs to both console and file
2. Rotates logs at 1MB
3. Redacts sensitive data
4. Includes timestamps and levels
5. Supports structured JSON format

```python
# Your code here

```

### Verification Exercise

**Write a test that:**
1. Creates a log entry with sensitive data
2. Verifies sensitive data is redacted
3. Checks that rotation works

```python
# Your code here

```

---

## WORKBOOK 1.3: SESSION MANAGER

### Learning Objectives

- Implement connection pooling
- Create session lifecycle management
- Handle authentication with retries
- Manage connection states

### Exercise 1.3.1: Connection States

**Define the connection states:**

```python
class ConnectionStatus(Enum):
    DISCONNECTED = "______"
    CONNECTING = "______"
    CONNECTED = "______"
    AUTHENTICATING = "______"
    AUTHENTICATED = "______"
    ERROR = "______"
    CLOSED = "______"
```

### Exercise 1.3.2: Connection Pool

**Implement a connection pool:**

```python
class ConnectionPool:
    def __init__(self, max_size: int = ___):
        self.max_size = max_size
        self._pool: queue.Queue = queue.Queue(maxsize=max_size)
    
    def get_connection(self, key: str) -> Optional[Any]:
        # Get connection from pool
        try:
            conn = self._pool.______(block=False)
            return conn
        except queue.Empty:
            return None
    
    def return_connection(self, key: str, conn: Any):
        # Return connection to pool
        if self._pool.qsize() < self.______:
            self._pool.put(conn, block=False)
        else:
            self._close_connection(conn)
```

### Exercise 1.3.3: Session ID Generation

**Generate a unique session ID:**

```python
def _generate_session_id(self, config: ConnectionConfig) -> str:
    components = [
        config.connection_type.______,
        config.______,
        str(config.______),
        config.______ or "anonymous",
    ]
    return ":".join(components)
```

### Exercise 1.3.4: Connection Factory

**Create connections based on type:**

```python
def _connect(self, config: ConnectionConfig):
    if config.connection_type == ConnectionType.______:
        return self._connect_ssh(config)
    elif config.connection_type == ConnectionType.______:
        return self._connect_netmiko(config)
    elif config.connection_type == ConnectionType.______:
        return self._connect_raw_socket(config)
    else:
        raise ValueError(f"Unsupported: {config.connection_type}")
```

### Exercise 1.3.5: SSH Authentication

**Add SSH authentication with retries:**

```python
def _connect_ssh(self, config: ConnectionConfig):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.______Policy())
    
    connect_kwargs = {
        'hostname': config.______,
        'port': config.______,
        'username': config.______,
        'timeout': config.______,
    }
    
    # Add authentication
    if config.______:
        connect_kwargs['password'] = config.password
    elif config.______:
        key = paramiko.RSAKey.from_private_key_file(
            config.private_key_path
        )
        connect_kwargs['pkey'] = key
    
    # Retry logic
    for attempt in range(config.______):
        try:
            client.connect(**connect_kwargs)
            return client
        except paramiko.AuthenticationException:
            if attempt == config.auth_retries - 1:
                raise
            time.sleep(2 ** attempt)
```

### Hands-On Challenge

**Create a session manager that:**
1. Supports SSH, Netmiko, and raw socket connections
2. Implements connection pooling
3. Handles authentication with retries
4. Provides session status tracking
5. Includes session cleanup

```python
# Your code here

```

### Verification Exercise

**Test the session manager with:**
1. SSH connection to localhost
2. Netmiko connection (mock)
3. Raw socket connection
4. Pool reuse verification

---

## WORKBOOK 1.4: PARAMIKO WRAPPER

### Learning Objectives

- Implement SSH automation with Paramiko
- Handle file transfers with SFTP
- Execute commands with sudo
- Manage interactive shells

### Exercise 1.4.1: Paramiko Connection

**Fill in the blanks:**

```python
def connect(self) -> bool:
    self.client = paramiko.SSHClient()
    self.client.set_missing_host_key_policy(
        paramiko.______Policy()
    )
    
    self.client.connect(
        hostname=self.config['______'],
        port=self.config.get('port', ___),
        username=self.config['______'],
        password=self.config.get('______'),
        timeout=self.config.get('timeout', ___),
    )
    
    self.transport = self.client.______()
    self.sftp = self.client.______()
    return True
```

### Exercise 1.4.2: Command Execution

**Execute a command with sudo:**

```python
def execute_command(self, command: str, use_sudo: bool = False):
    if use_sudo:
        sudo_password = self.config.get('______')
        if sudo_password:
            command = f"echo '{sudo_password}' | sudo -S {command} 2>&1"
    
    stdin, stdout, stderr = self.client.______(command)
    return stdout.read().decode(), stderr.read().decode()
```

### Exercise 1.4.3: SFTP File Transfer

**Implement file upload with progress:**

```python
def upload_file(self, local_path: str, remote_path: str):
    local_path = Path(local_path)
    file_size = local_path.______()
    
    def progress_callback(transferred: int, total: int):
        progress = (transferred / total) * 100
        print(f"Progress: {progress:.1f}%")
    
    self.sftp.______(
        str(local_path),
        remote_path,
        callback=progress_callback
    )
    
    # Verify upload
    remote_size = self.sftp.______(remote_path).st_size
    return remote_size == file_size
```

### Exercise 1.4.4: Interactive Shell

**Handle interactive commands:**

```python
def interactive_shell(self, commands: List[str]) -> str:
    channel = self.client.______()
    channel.______(10)
    
    output = []
    for command in commands:
        channel.send(f"{command}\n")
        time.sleep(0.5)
        
        while channel.______():
            data = channel.recv(1024).decode()
            output.append(data)
    
    channel.close()
    return ''.join(output)
```

### Exercise 1.4.5: Private Key Authentication

**Load and use private keys:**

```python
def _load_private_key(self, key_path: str):
    key_path = Path(key_path).expanduser()
    
    # Try different key types
    for key_class in [paramiko.RSAKey, paramiko.DSSKey]:
        try:
            if 'password' in self.config:
                key = key_class.from_private_key_file(
                    str(key_path),
                    password=self.config['______']
                )
            else:
                key = key_class.from_private_key_file(str(key_path))
            return key
        except paramiko.SSHException:
            continue
    
    return None
```

### Hands-On Challenge

**Create a Paramiko wrapper that:**
1. Supports password and key authentication
2. Executes commands with sudo
3. Transfers files with SFTP
4. Handles interactive commands
5. Includes error handling and retries

```python
# Your code here

```

### Verification Exercise

**Test your Paramiko wrapper with:**
1. Password authentication
2. Private key authentication
3. Sudo command execution
4. File upload and download
5. Interactive shell commands

---

## WORKBOOK 1.5: NETMIKO WRAPPER

### Learning Objectives

- Automate multi-vendor network devices
- Send configuration commands
- Back up and restore configurations
- Check compliance

### Exercise 1.5.1: Device Connection

**Fill in the blanks:**

```python
def connect(self) -> bool:
    connection_params = self.config.copy()
    
    # Ensure required parameters
    if 'timeout' not in connection_params:
        connection_params['timeout'] = ___
    
    self.connection = ConnectHandler(______)
    self.is_connected = True
    return True
```

### Exercise 1.5.2: Command Execution

**Send commands to device:**

```python
def send_command(self, command: str) -> str:
    if not self.is_connected:
        raise ConnectionError("Not connected")
    
    output = self.connection.send_command(
        command,
        strip_prompt=______,
        strip_command=______,
        read_timeout=___,
    )
    return output

def send_commands(self, commands: List[str]) -> Dict[str, str]:
    results = {}
    for command in commands:
        results[command] = self.______(command)
    return results
```

### Exercise 1.5.3: Configuration Management

**Send configuration commands:**

```python
def send_config(self, config_commands: List[str]) -> str:
    if not self.is_connected:
        raise ConnectionError("Not connected")
    
    if self._device_family == '______':
        # Juniper requires entering config mode
        output = self.connection.send_config_set(
            config_commands,
            read_timeout=___
        )
    else:
        output = self.connection.send_config_set(
            config_commands,
            read_timeout=___
        )
    
    return output
```

### Exercise 1.5.4: Backup Configuration

**Implement configuration backup:**

```python
def backup_config(self, backup_path: Optional[Path] = None) -> Path:
    show_cmd = self._get_show_config_command()
    config_output = self.______(show_cmd)
    
    if backup_path is None:
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        backup_path = Path(f"backups/{self.host}_{timestamp}.cfg")
    
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    backup_path.______(config_output)
    
    return backup_path
```

### Exercise 1.5.5: Device Detection

**Detect device family:**

```python
def _detect_device_family(self) -> str:
    device_type = self.config.get('device_type', '').lower()
    
    if 'cisco' in device_type:
        return '______'
    elif 'juniper' in device_type or 'junos' in device_type:
        return '______'
    elif 'arista' in device_type:
        return '______'
    else:
        return '______'
```

### Hands-On Challenge

**Create a Netmiko wrapper that:**
1. Supports multiple vendor devices
2. Backs up and restores configurations
3. Sends configuration commands
4. Checks device compliance
5. Handles vendor-specific commands

```python
# Your code here

```

### Verification Exercise

**Test your Netmiko wrapper with:**
1. Cisco device connection
2. Show command execution
3. Configuration backup
4. Configuration restoration
5. Compliance checking

---

## WORKBOOK 1.6: SCAPY WRAPPER

### Learning Objectives

- Craft and send custom packets
- Sniff and analyze network traffic
- Perform ARP and TCP scanning
- Save and load PCAP files

### Exercise 1.6.1: Packet Crafting

**Build a TCP SYN packet:**

```python
def send_ip_packet(self, dst_ip: str, src_ip: Optional[str] = None):
    ip_layer = IP(dst=______)
    if src_ip:
        ip_layer.src = ______
    
    tcp_layer = TCP(
        sport=______,
        dport=______,
        flags=______,
        seq=______
    )
    
    packet = ip_layer / tcp_layer
    send(packet, verbose=False)
    return packet
```

### Exercise 1.6.2: Packet Sniffing

**Sniff packets with a filter:**

```python
def sniff_sync(self, count: int = 100, timeout: int = 10, filter_str: Optional[str] = None):
    packets = sniff(
        iface=self.______,
        count=______,
        timeout=______,
        filter=______,
        promisc=self.config.network.______,
        store=______,
    )
    return packets
```

### Exercise 1.6.3: ARP Scanning

**Perform an ARP scan:**

```python
def arp_scan(self, ip_range: str) -> List[Dict[str, str]]:
    arp_request = ARP(pdst=______)
    
    answered, unanswered = srp(
        Ether(dst="______") / arp_request,
        timeout=___,
        verbose=False,
        iface=self.interface
    )
    
    results = []
    for sent, received in answered:
        results.append({
            'ip': received.______,
            'mac': received.______,
        })
    return results
```

### Exercise 1.6.4: TCP Ping

**Perform TCP ping (SYN scan):**

```python
def tcp_ping(self, target: str, port: int = 80, timeout: int = 2) -> bool:
    packet = IP(dst=______) / TCP(dport=______, flags=______)
    response = sr1(packet, timeout=______, verbose=False)
    
    if response and response.haslayer(TCP):
        if response[TCP].flags & 0x12:  # SYN-ACK
            return True
    
    return False
```

### Exercise 1.6.5: PCAP Operations

**Save and load PCAP files:**

```python
def save_pcap(self, packets: List[Packet], filename: str) -> Path:
    filename = Path(filename)
    filename.parent.mkdir(parents=True, exist_ok=True)
    wrpcap(str(filename), ______)
    return filename

def load_pcap(self, filename: str) -> PacketList:
    filename = Path(filename)
    if not filename.exists():
        raise FileNotFoundError(f"PCAP not found: {filename}")
    packets = rdpcap(str(______))
    return packets
```

### Hands-On Challenge

**Create a Scapy wrapper that:**
1. Sends custom IP packets
2. Performs ARP scanning
3. Sniffs packets with filters
4. Saves and loads PCAP files
5. Analyzes packet structures

```python
# Your code here

```

### Verification Exercise

**Test your Scapy wrapper with:**
1. TCP SYN packet sending
2. ARP scan on local network
3. Packet sniffing with filters
4. PCAP save and load
5. Packet analysis

---

## WORKBOOK 1.7: PROTOCOL ABSTRACTION

### Learning Objectives

- Create unified protocol interface
- Implement factory pattern
- Build protocol abstraction layer
- Integrate all protocols

### Exercise 1.7.1: Abstract Interface

**Define the abstract interface:**

```python
class NetworkInterface(ABC):
    @abstractmethod
    def connect(self) -> bool:
        """______"""
        pass
    
    @abstractmethod
    def disconnect(self):
        """______"""
        pass
    
    @abstractmethod
    def execute(self, command: str) -> Tuple[str, str]:
        """______"""
        pass
    
    @abstractmethod
    def is_connected(self) -> bool:
        """______"""
        pass
```

### Exercise 1.7.2: Protocol Factory

**Implement the factory:**

```python
class ProtocolFactory:
    @staticmethod
    def create_interface(config: Dict[str, Any]) -> NetworkInterface:
        protocol = config.get('protocol', '______').lower()
        
        if protocol in ['______', 'paramiko']:
            ssh_config = create_ssh_config(...)
            return SSHInterface(______)
        
        elif protocol in ['______', 'device']:
            netmiko_config = create_netmiko_config(...)
            return NetmikoInterface(______)
        
        elif protocol in ['______', 'packet']:
            return PacketInterface(______)
        
        else:
            raise ValueError(f"Unsupported protocol: {protocol}")
```

### Exercise 1.7.3: Unified Manager

**Implement the unified manager:**

```python
class UnifiedNetworkManager:
    def __init__(self):
        self.interfaces: Dict[str, NetworkInterface] = {}
    
    def connect(self, name: str, config: Dict[str, Any]) -> bool:
        interface = ProtocolFactory.______(config)
        result = interface.______()
        
        if result:
            self.interfaces[name] = interface
        
        return result
    
    def execute(self, name: str, command: str) -> Tuple[str, str]:
        if name not in self.interfaces:
            raise ValueError(f"Unknown connection: {name}")
        
        interface = self.interfaces[name]
        if not interface.______():
            raise ConnectionError(f"Not connected to {name}")
        
        return interface.______(command)
```

### Exercise 1.7.4: Protocol Detection

**Detect protocol from target:**

```python
def detect_protocol(self, target: str) -> str:
    # Check if target is IP
    try:
        ipaddress.______(target)
        # Check if target has port
        if ':' in target:
            return '______'  # SSH
        return '______'  # Packet
    except:
        pass
    
    # Check if target starts with http
    if target.startswith(('http://', 'https://')):
        return '______'
    
    # Default to SSH
    return '______'
```

### Exercise 1.7.5: Convenience Methods

**Add convenience methods:**

```python
def ssh_command(self, host: str, username: str, password: str, command: str):
    config = {'protocol': 'ssh', 'host': host, ...}
    name = f"ssh_{host}"
    
    try:
        if self.______(name, config):
            return self.______(name, command)
    finally:
        self.______(name)

def packet_ping(self, target: str):
    config = {'protocol': 'scapy'}
    name = f"packet_{int(time.time())}"
    
    try:
        if self.connect(name, config):
            stdout, _ = self.______(name, f"ping:{target}")
            return stdout
    finally:
        self.______(name)
```

### Hands-On Challenge

**Create a protocol abstraction layer that:**
1. Unifies SSH, Netmiko, and Scapy interfaces
2. Implements factory pattern for protocol creation
3. Provides convenient methods for common operations
4. Handles protocol detection automatically

```python
# Your code here

```

### Verification Exercise

**Test your abstraction layer with:**
1. SSH command execution
2. Netmiko device commands
3. Packet operations (ping, scan)
4. Automatic protocol detection

---

## WORKBOOK 2.1: EVENT LOOP MANAGER

### Learning Objectives

- Understand async event loops
- Implement task scheduling
- Handle graceful shutdown
- Integrate with synchronous code

### Exercise 2.1.1: Event Loop Initialization

**Initialize the event loop:**

```python
class EventLoopManager:
    def __init__(self):
        self.loop = asyncio.______()
        self.running = False
        self._tasks = []
    
    def _initialize_loop(self):
        try:
            self.loop = asyncio.______()
        except RuntimeError:
            self.loop = asyncio.______()
            asyncio.set_event_loop(self.loop)
```

### Exercise 2.1.2: Coroutine Runner

**Run a coroutine:**

```python
def run_coroutine(self, coroutine: Coroutine, timeout: Optional[float] = None):
    if self.running:
        future = asyncio.run_coroutine_threadsafe(coroutine, self.______)
        return future.result(timeout=______)
    else:
        return self.loop.run_until_complete(______)
```

### Exercise 2.1.3: Task Scheduler

**Schedule a background task:**

```python
def schedule_task(self, coroutine: Coroutine, name: Optional[str] = None):
    if self.running:
        task = asyncio.run_coroutine_threadsafe(coroutine, self.______)
    else:
        task = self.loop.create_task(______)
    
    self._tasks.append(task)
    return task
```

### Exercise 2.1.4: Graceful Shutdown

**Implement graceful shutdown:**

```python
def shutdown(self, timeout: float = 30.0):
    self._shutdown = True
    
    # Wait for tasks to complete
    self.______(timeout=timeout)
    
    # Cancel remaining tasks
    for task in self._tasks:
        if not task.______():
            task.______()
    
    # Stop the loop
    if self.running:
        self.loop.call_soon_threadsafe(self.loop.______)
        self.running = False
    
    self.loop.______()
```

### Exercise 2.1.5: Thread Pool Integration

**Run blocking code in thread pool:**

```python
def run_async(self, func: Callable, *args, **kwargs):
    return self.loop.run_in_executor(
        self._thread_pool,
        functools.partial(______, *args, **kwargs)
    )
```

### Hands-On Challenge

**Create an event loop manager that:**
1. Runs async tasks in background
2. Schedules tasks with names
3. Handles graceful shutdown
4. Integrates with thread pool
5. Provides performance metrics

```python
# Your code here

```

### Verification Exercise

**Test your event loop manager with:**
1. Running a simple async function
2. Scheduling multiple tasks
3. Shutting down gracefully
4. Running blocking functions in thread pool

---

## WORKBOOK 2.2: ASYNC PACKET SNIFFER

### Learning Objectives

- Implement non-blocking packet sniffing
- Integrate with event loop
- Handle packet queues
- Process packets asynchronously

### Exercise 2.2.1: Async Sniffer Initialization

**Initialize the async sniffer:**

```python
class AsyncPacketSniffer:
    def __init__(self, interface: str = None, filter_str: str = None):
        self.interface = interface or "______"
        self.filter_str = filter_str
        self.packet_queue: asyncio.Queue = asyncio.Queue(
            maxsize=self.config.network.______
        )
        self.sniffer: Optional[AsyncSniffer] = None
        self._running = False
```

### Exercise 2.2.2: Start Sniffing

**Start the async sniffer:**

```python
async def start(self):
    self._running = True
    
    def packet_handler(packet):
        self._on_packet_captured(______)
    
    self.sniffer = AsyncSniffer(
        iface=self.______,
        filter=self.______,
        prn=______,
        store=______,
    )
    
    self.sniffer.______()
    self.event_loop.schedule_task(self._process_loop())
```

### Exercise 2.2.3: Packet Handler

**Handle captured packets:**

```python
def _on_packet_captured(self, packet):
    # Update statistics
    self.stats.total_captured += 1
    
    # Add to async queue
    try:
        self.event_loop.loop.call_soon_threadsafe(
            self.packet_queue.______,
            packet
        )
    except asyncio.QueueFull:
        # Backpressure
        self.stats.total_dropped += 1
        self.logger.warning(f"Queue full, dropping packet")
```

### Exercise 2.2.4: Packet Processing Loop

**Process packets from queue:**

```python
async def _process_loop(self):
    while self._running:
        try:
            packet = await asyncio.wait_for(
                self.packet_queue.______,
                timeout=1.0
            )
            await self._process_packet(packet)
        except asyncio.TimeoutError:
            continue
```

### Exercise 2.2.5: Async Stream

**Create async packet stream:**

```python
async def stream(self, timeout: Optional[float] = None):
    start_time = time.time()
    
    while self._running:
        if timeout and time.time() - start_time > timeout:
            break
        
        try:
            packet = await asyncio.wait_for(
                self.packet_queue.______,
                timeout=1.0
            )
            yield packet
        except asyncio.TimeoutError:
            continue
```

### Hands-On Challenge

**Create an async packet sniffer that:**
1. Uses AsyncSniffer for non-blocking capture
2. Implements packet queue with backpressure
3. Processes packets asynchronously
4. Provides streaming interface
5. Includes performance statistics

```python
# Your code here

```

### Verification Exercise

**Test your async sniffer with:**
1. Capturing TCP packets
2. Processing packets in real-time
3. Queue backpressure handling
4. Async streaming

---

## WORKBOOK 2.3: QUEUE MANAGEMENT

### Learning Objectives

- Implement priority queues
- Create ring buffers
- Handle backpressure
- Implement rate limiting

### Exercise 2.3.1: Priority Queue

**Implement async priority queue:**

```python
class AsyncPriorityQueue:
    def __init__(self, maxsize: int = 0):
        self.maxsize = maxsize
        self._queue = []
        self._lock = asyncio.______
        self._not_empty = asyncio.______
        self._not_full = asyncio.______
    
    async def put(self, item: Any, priority: int = 0):
        if self.maxsize > 0 and len(self._queue) >= self.maxsize:
            await self._not_full.______()
        
        heapq.heappush(self._queue, (priority, time.time(), item))
        self._not_empty.______()
```

### Exercise 2.3.2: Ring Buffer

**Implement ring buffer queue:**

```python
class RingBufferQueue:
    def __init__(self, capacity: int = 1024):
        self.capacity = capacity
        self._buffer = [None] * capacity
        self._head = 0  # Write position
        self._tail = 0  # Read position
        self._count = 0
    
    def put(self, item: Any) -> bool:
        if self._count == self.capacity:
            # Overwrite oldest
            self._buffer[self._head] = item
            self._head = (self._head + 1) % self.______
            self._tail = (self._tail + 1) % self.______
        else:
            self._buffer[self._head] = item
            self._head = (self._head + 1) % self.______
            self._count += 1
        return True
```

### Exercise 2.3.3: Backpressure Manager

**Implement backpressure management:**

```python
class BackpressureManager:
    def should_drop(self, name: str) -> bool:
        consumer = self._consumers.get(name)
        if not consumer:
            return False
        
        # Calculate pressure
        ratio = consumer['current_buffer'] / consumer['______']
        min_th = consumer['______']
        max_th = consumer['______']
        
        if ratio < min_th:
            pressure = 0.0
        elif ratio > max_th:
            pressure = 1.0
            consumer['dropped'] += 1
            return True
        else:
            pressure = (ratio - min_th) / (max_th - min_th)
        
        return False
```

### Exercise 2.3.4: Throttled Queue

**Implement rate-limited queue:**

```python
class ThrottledQueue:
    def __init__(self, max_rate: float, per_second: bool = True):
        self.max_rate = max_rate
        self.per_second = per_second
        self._last_processed = time.time()
        self._processed_count = 0
        self._lock = threading.Lock()
    
    def get(self, timeout: Optional[float] = None):
        with self._lock:
            now = time.time()
            if self.per_second:
                rate_window = 1.0
            else:
                rate_window = 60.0
            
            if now - self._last_processed >= rate_window:
                self._processed_count = 0
                self._last_processed = now
            elif self._processed_count >= self.______:
                wait_time = rate_window - (now - self._last_processed)
                time.sleep(wait_time)
```

### Hands-On Challenge

**Create a queue management system that:**
1. Supports priority and ring buffer queues
2. Implements backpressure management
3. Provides rate limiting
4. Includes performance metrics

```python
# Your code here

```

### Verification Exercise

**Test your queue management with:**
1. Priority ordering
2. Ring buffer overflow handling
3. Backpressure detection
4. Rate limiting

---

## WORKBOOK 2.4: PACKET INJECTION

### Learning Objectives

- Implement timed packet injection
- Create trigger-based injection
- Handle injection scheduling
- Support fuzzing injection

### Exercise 2.4.1: Injection Configuration

**Define injection configuration:**

```python
@dataclass
class InjectionConfig:
    delay: float = 0.0      # Initial delay
    interval: float = 0.1   # Between packets
    jitter: float = 0.0     # Random jitter
    count: int = 1          # Number of packets
    infinite: bool = False  # Send indefinitely
    trigger: Optional[str] = None  # BPF filter
    trigger_count: int = 1  # Triggers before sending
```

### Exercise 2.4.2: Scheduled Injection

**Implement scheduled injection:**

```python
async def _injection_loop(self, injection_id: str, packet: Packet, config: InjectionConfig):
    if config.delay > 0:
        await asyncio.sleep(config.delay)
    
    count = 0
    while config.infinite or count < config.______:
        if not self.event_loop.running:
            break
        
        # Add jitter
        if config.jitter > 0:
            jitter = random.uniform(-config.jitter, config.jitter)
        else:
            jitter = 0
        
        # Send packet
        self._send_packet(packet)
        count += 1
        
        # Wait for next interval
        if config.infinite or count < config.count:
            wait_time = max(0, config.interval + jitter)
            if wait_time > 0:
                await asyncio.sleep(wait_time)
```

### Exercise 2.4.3: Trigger-Based Injection

**Implement trigger-based injection:**

```python
async def start_trigger_injection(self, trigger_filter: str, response_builder: Callable):
    def on_trigger(packet):
        response = ______(packet)
        if response:
            send(response, verbose=config.verbose)
            self.stats['total_sent'] += 1
    
    self._sniffer = AsyncPacketSniffer(
        interface=self.interface,
        filter_str=______
    )
    self._sniffer.add_callback(______)
    await self._sniffer.start()
```

### Exercise 2.4.4: Attack Helpers

**Create common attack helpers:**

```python
def create_tcp_syn_flood(target_ip: str, target_port: int, 
                         source_ip: Optional[str] = None,
                         count: int = 1000) -> Tuple[Packet, InjectionConfig]:
    if source_ip:
        ip = IP(src=______, dst=______)
    else:
        ip = IP(dst=______)
    
    tcp = TCP(
        sport=random.randint(1024, 65535),
        dport=______,
        flags=______,
        seq=random.randint(0, 0xFFFFFFFF)
    )
    
    packet = ip / tcp
    config = InjectionConfig(
        interval=0.01,
        count=______,
        randomize=True,
        jitter=0.001
    )
    
    return packet, config
```

### Hands-On Challenge

**Create a packet injector that:**
1. Supports scheduled injection
2. Supports trigger-based injection
3. Implements common attack patterns
4. Handles rate limiting

```python
# Your code here

```

### Verification Exercise

**Test your packet injector with:**
1. Scheduled packet injection
2. Trigger-based response injection
3. TCP SYN flood helper
4. ARP spoofing helper

---

## WORKBOOK 3.1: ASYNC SCANNER

### Learning Objectives

- Implement high-performance port scanning
- Detect services and versions
- Perform OS fingerprinting
- Scan networks concurrently

### Exercise 3.1.1: Port Scanner

**Implement TCP port scanning:**

```python
async def _scan_port(self, ip: str, port: int, timeout: float):
    try:
        reader, writer = await asyncio.wait_for(
            asyncio.______(ip, port),
            timeout=timeout
        )
        writer.close()
        return 'open', None
    except ConnectionRefusedError:
        return '______', None
    except asyncio.TimeoutError:
        return '______', None
```

### Exercise 3.1.2: Service Detection

**Detect service from banner:**

```python
def _detect_version(self, port: int, banner: str) -> Optional[str]:
    patterns = {
        'ssh': r'______',
        'http': r'______',
        'mysql': r'______',
    }
    
    for service, pattern in patterns.items():
        match = re.search(pattern, banner, re.IGNORECASE)
        if match:
            return ______
    
    return None
```

### Exercise 3.1.3: OS Fingerprinting

**Guess OS from open ports:**

```python
def _guess_os(self, open_ports: List[int]) -> Optional[str]:
    port_signatures = {
        'windows': {135, 139, 445, 3389},
        'linux': {22, 80, 443, 3306},
        'cisco': {22, 23, 443, 500},
    }
    
    open_set = set(______)
    best_match = None
    best_score = 0
    
    for os_name, ports in port_signatures.items():
        score = len(open_set & ______)
        if score > best_score:
            best_score = score
            best_match = os_name
    
    return best_match if best_score >= 3 else None
```

### Exercise 3.1.4: Network Scanner

**Scan a network range:**

```python
async def scan_network(self, network: str, ports: List[int] = None):
    net = ipaddress.ip_network(network, strict=False)
    hosts = list(net.______())
    
    semaphore = asyncio.Semaphore(self.max_concurrent)
    
    async def scan_host_with_limit(host):
        async with semaphore:
            return await self.______(str(host), ports=ports)
    
    tasks = [scan_host_with_limit(str(host)) for host in hosts]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    valid_results = [r for r in results if not isinstance(r, Exception)]
    return valid_results
```

### Hands-On Challenge

**Create an async scanner that:**
1. Scans TCP and UDP ports
2. Detects services and versions
3. Performs OS fingerprinting
4. Scans networks concurrently

```python
# Your code here

```

### Verification Exercise

**Test your scanner with:**
1. Single host port scan
2. Network range scan
3. Service detection
4. OS fingerprinting

---

## WORKBOOK 3.2: ASYNC BRUTE-FORCER

### Learning Objectives

- Implement credential brute forcing
- Perform directory enumeration
- Enumerate subdomains
- Apply stealth techniques

### Exercise 3.2.1: HTTP Basic Auth

**Brute force HTTP Basic Authentication:**

```python
async def bruteforce_http_basic(self, url: str, usernames: List[str], passwords: List[str]):
    credentials = []
    for username in usernames:
        for password in passwords:
            credentials.append((username, password))
    
    semaphore = asyncio.Semaphore(self.max_concurrent)
    
    async def try_credential(username: str, password: str):
        async with semaphore:
            result = await self._try_http_basic(
                url, username, password
            )
            return result
    
    tasks = [try_credential(u, p) for u, p in credentials]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    return [r for r in results if r and r.found]
```

### Exercise 3.2.2: Directory Enumeration

**Enumerate directories:**

```python
async def bruteforce_directory(self, base_url: str, wordlist: List[str]):
    resources = []
    for item in wordlist:
        resources.append(item)
        # Add extensions
        for ext in ['.html', '.php', '.txt']:
            resources.append(f"{item}{ext}")
    
    semaphore = asyncio.Semaphore(self.max_concurrent)
    
    async def try_resource(resource: str):
        async with semaphore:
            url = f"{base_url}/{resource}"
            return await self._try_directory(url, resource)
    
    tasks = [try_resource(r) for r in resources]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    return [r for r in results if r and r.found]
```

### Exercise 3.2.3: Subdomain Enumeration

**Enumerate subdomains:**

```python
async def bruteforce_subdomain(self, domain: str, wordlist: List[str]):
    results = []
    semaphore = asyncio.Semaphore(self.max_concurrent)
    
    async def try_subdomain(subdomain: str):
        async with semaphore:
            host = f"{subdomain}.{domain}"
            return await self._try_subdomain(host, subdomain)
    
    tasks = [try_subdomain(s) for s in wordlist]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    return [r for r in results if r and r.found]
```

### Exercise 3.2.4: Stealth Techniques

**Add stealth features:**

```python
async def with_stealth(self, func):
    # Add jitter
    await asyncio.sleep(random.uniform(0, 0.5))
    
    # Randomize user agent
    headers = {'User-Agent': random.choice(self.user_agents)}
    
    # Rate limiting
    if self.rate_limit > 0:
        await asyncio.sleep(1.0 / self.rate_limit)
    
    return await func(headers=headers)
```

### Hands-On Challenge

**Create an async brute-forcer that:**
1. Supports HTTP Basic Auth
2. Enumerates directories
3. Discovers subdomains
4. Implements stealth techniques

```python
# Your code here

```

### Verification Exercise

**Test your brute-forcer with:**
1. HTTP Basic Auth brute force
2. Directory enumeration
3. Subdomain enumeration
4. Rate limiting and jitter

---

## WORKBOOK 3.3: DOM ANALYZER

### Learning Objectives

- Analyze JavaScript-rendered content
- Detect vulnerabilities
- Crawl web applications
- Extract DOM elements

### Exercise 3.3.1: Headless Browser Setup

**Initialize Playwright browser:**

```python
async def _ensure_browser(self):
    if self.browser:
        return
    
    self._playwright = await async_playwright().start()
    self.browser = await self._playwright.chromium.launch(
        headless=self.headless,
        args=[
            '--disable-blink-features=AutomationControlled',
            '--disable-dev-shm-usage',
            '--no-sandbox',
        ]
    )
    self.context = await self.browser.new_context(
        user_agent=random.choice(self.user_agents),
        viewport={'width': 1920, 'height': 1080},
        ignore_https_errors=True,
        java_script_enabled=True,
    )
```

### Exercise 3.3.2: Page Analysis

**Analyze page with JavaScript:**

```python
async def analyze_page(self, url: str, render_js: bool = True):
    if render_js:
        await self._ensure_browser()
        page = await self.context.new_page()
        await page.goto(url)
        await page.wait_for_load_state('networkidle')
        html = await page.______()
        title = await page.______()
        await page.______()
    else:
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                html = await response.______()
                soup = BeautifulSoup(html, 'html.parser')
                title = soup.title.string if soup.title else None
    
    soup = BeautifulSoup(html, 'html.parser')
    result = DOMAnalysisResult(url=url, title=title, html=html)
    
    # Extract elements
    result.forms = self._extract_forms(soup, url)
    result.links = self._extract_links(soup, url)
    result.scripts = self._extract_scripts(soup, url)
    
    return result
```

### Exercise 3.3.3: Vulnerability Detection

**Detect common vulnerabilities:**

```python
def _detect_vulnerabilities(self, soup, url: str, headers: Dict):
    vulns = []
    
    # Missing security headers
    required_headers = ['Strict-Transport-Security', 'X-Frame-Options']
    for header in required_headers:
        if header not in headers:
            vulns.append({
                'type': 'Missing Security Header',
                'header': header,
                'severity': 'medium'
            })
    
    # Forms without CSRF tokens
    for form in soup.find_all('form'):
        if form.get('method', 'get').lower() == 'post':
            csrf = form.find('input', {'name': 'csrf_token'})
            if not csrf:
                vulns.append({
                    'type': 'Missing CSRF Token',
                    'location': form.get('action', ''),
                    'severity': 'medium'
                })
    
    # Inline JavaScript with eval
    for script in soup.find_all('script'):
        if script.string and 'eval(' in script.string.lower():
            vulns.append({
                'type': 'Potential XSS',
                'description': 'eval() detected in inline script',
                'severity': 'high'
            })
    
    return vulns
```

### Exercise 3.3.4: Web Crawler

**Crawl and analyze multiple pages:**

```python
async def crawl(self, start_url: str, max_pages: int = 50, max_depth: int = 3):
    visited = set()
    to_visit = [(start_url, 0)]
    results = []
    
    while to_visit and len(results) < max_pages:
        url, depth = to_visit.pop(0)
        if url in visited:
            continue
        
        visited.add(url)
        result = await self.analyze_page(url, render_js=True)
        results.append(result)
        
        if depth < max_depth:
            for link in result.links:
                link_url = link['url']
                if link_url.startswith(('http://', 'https://')):
                    if link_url not in visited:
                        to_visit.append((link_url, depth + 1))
    
    return results
```

### Hands-On Challenge

**Create a DOM analyzer that:**
1. Renders JavaScript with Playwright
2. Detects vulnerabilities
3. Crawls web applications
4. Extracts all DOM elements

```python
# Your code here

```

### Verification Exercise

**Test your DOM analyzer with:**
1. Static HTML analysis
2. JavaScript-rendered content
3. Vulnerability detection
4. Web crawling

---

## WORKBOOK 3.4: MODULAR RECON

### Learning Objectives

- Design plugin-based architecture
- Implement module registry
- Create module manager
- Build reusable modules

### Exercise 3.4.1: Base Module

**Define the base module interface:**

```python
class ReconModule(ABC):
    def __init__(self):
        self.config = get_config()
        self.logger = get_logger(self.__class__.__name__)
        self.metadata = self.______()
    
    @abstractmethod
    def get_metadata(self) -> ModuleMetadata:
        """______"""
        pass
    
    @abstractmethod
    async def run(self, target: str, **kwargs) -> Dict[str, Any]:
        """______"""
        pass
    
    async def pre_run(self, target: str, **kwargs):
        """Hook before execution."""
        pass
    
    async def post_run(self, target: str, **kwargs):
        """Hook after execution."""
        pass
```

### Exercise 3.4.2: Module Registry

**Implement module registry:**

```python
class ModuleRegistry:
    def __init__(self):
        self.modules: Dict[str, Type[ReconModule]] = {}
        self.metadata: Dict[str, ModuleMetadata] = {}
    
    def register(self, module_class: Type[ReconModule]):
        temp = module_class()
        metadata = temp.______()
        self.modules[metadata.name] = module_class
        self.metadata[metadata.name] = metadata
    
    def get_module(self, name: str) -> Optional[ReconModule]:
        if name not in self.modules:
            return None
        
        # Check dependencies
        metadata = self.metadata.get(name)
        if metadata:
            for dep in metadata.requires:
                if dep not in self.modules:
                    return None
        
        return self.modules[name]()
```

### Exercise 3.4.3: Example Module

**Create a port scanning module:**

```python
class PortScanModule(ReconModule):
    def get_metadata(self) -> ModuleMetadata:
        return ModuleMetadata(
            name="port_scan",
            description="______",
            version="1.0.0",
            tags=["scanning", "network"],
            requires=[],  # No dependencies
        )
    
    async def run(self, target: str, **kwargs) -> Dict[str, Any]:
        scanner = AsyncScanner()
        ports = kwargs.get('ports')
        result = await scanner.______(target, ports=ports)
        
        return {
            'host': result.ip,
            'open_ports': result.get_open_ports(),
            'services': result.get_services(),
            'scan_time': result.scan_time,
        }
```

### Exercise 3.4.4: Module Manager

**Implement module manager:**

```python
class ModuleManager:
    def __init__(self):
        self.registry = ModuleRegistry()
        self.results: Dict[str, Dict] = {}
        self.errors: Dict[str, str] = {}
    
    async def run_module(self, module_name: str, target: str, **kwargs):
        module = self.registry.______(module_name)
        if not module:
            raise ValueError(f"Module not found: {module_name}")
        
        await module.______(target, **kwargs)
        
        try:
            result = await module.______(target, **kwargs)
            self.results[module_name] = result
        except Exception as e:
            self.errors[module_name] = str(e)
            result = {'error': str(e)}
        
        await module.______(target, **kwargs)
        return result
```

### Hands-On Challenge

**Create a modular recon system that:**
1. Defines a base module interface
2. Implements module registry
3. Creates example modules
4. Manages module execution

```python
# Your code here

```

### Verification Exercise

**Test your modular system with:**
1. Module registration
2. Port scan module
3. HTTP enum module
4. Module execution

---

## WORKBOOK 4.1: PLUGIN ARCHITECTURE

### Learning Objectives

- Implement plugin lifecycle
- Create plugin manifests
- Handle dependencies
- Build plugin loader

### Exercise 4.1.1: Plugin Manifest

**Define the plugin manifest:**

```python
@dataclass
class PluginManifest:
    name: str
    version: str = "1.0.0"
    description: str = ""
    author: str = "Unknown"
    license: str = "MIT"
    
    # Dependencies
    requires: List[str] = field(default_factory=list)
    conflicts: List[str] = field(default_factory=list)
    
    # Capabilities
    provides: List[str] = field(default_factory=list)
    consumes: List[str] = field(default_factory=list)
    
    # Security
    permissions: List[str] = field(default_factory=list)
    sandboxed: bool = True
```

### Exercise 4.1.2: Plugin Lifecycle

**Define plugin states:**

```python
class PluginState(Enum):
    UNLOADED = "______"
    LOADING = "______"
    LOADED = "______"
    INITIALIZING = "______"
    INITIALIZED = "______"
    RUNNING = "______"
    STOPPED = "______"
    ERROR = "______"
```

### Exercise 4.1.3: Base Plugin

**Implement base plugin:**

```python
class Plugin(ABC):
    def __init__(self):
        self.manifest = self.______()
        self.state = PluginState.UNLOADED
        self.context: Dict[str, Any] = {}
    
    @abstractmethod
    def get_manifest(self) -> PluginManifest:
        pass
    
    @abstractmethod
    async def on_load(self) -> None:
        pass
    
    @abstractmethod
    async def on_run(self, context: Dict[str, Any]) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    async def on_unload(self) -> None:
        pass
    
    def get_state(self) -> PluginState:
        return self.state
    
    def set_state(self, state: PluginState):
        self.state = state
```

### Exercise 4.1.4: Plugin Loader

**Implement plugin loader:**

```python
class PluginLoader:
    def __init__(self, plugin_dir: Optional[Path] = None):
        self.plugin_dir = plugin_dir or Path("modules")
        self.plugins: Dict[str, Type[Plugin]] = {}
        self.instances: Dict[str, Plugin] = {}
        self.manifests: Dict[str, PluginManifest] = {}
    
    def discover_plugins(self):
        for item in self.plugin_dir.iterdir():
            if item.is_dir():
                plugin_file = item / "plugin.py"
                if plugin_file.exists():
                    module = importlib.import_module(item.name)
                    for attr in dir(module):
                        cls = getattr(module, attr)
                        if is_plugin_class(cls):
                            self.register_plugin(cls)
    
    def load_plugin(self, name: str) -> Optional[Plugin]:
        if name not in self.plugins:
            return None
        
        # Check dependencies
        manifest = self.manifests[name]
        for dep in manifest.requires:
            if dep not in self.plugins:
                return None
        
        plugin = self.plugins[name]()
        plugin.set_state(PluginState.LOADING)
        await plugin.______()
        plugin.set_state(PluginState.LOADED)
        
        self.instances[name] = plugin
        return plugin
```

### Hands-On Challenge

**Create a plugin system that:**
1. Defines plugin lifecycle
2. Loads plugins dynamically
3. Handles dependencies
4. Manages plugin states

```python
# Your code here

```

### Verification Exercise

**Test your plugin system with:**
1. Plugin discovery
2. Plugin loading
3. Dependency resolution
4. Plugin execution

---

## WORKBOOK 4.2: CODE OBFUSCATION

### Learning Objectives

- Implement string encoding
- Apply code obfuscation
- Create payload encoders
- Implement signature evasion

### Exercise 4.2.1: XOR Encoder

**Implement XOR encoding:**

```python
class XOREncoder:
    def __init__(self, key: Union[str, bytes]):
        if isinstance(key, str):
            key = key.______()
        self.key = key
    
    def encode(self, data: Union[str, bytes]) -> bytes:
        if isinstance(data, str):
            data = data.______()
        
        result = bytearray(len(data))
        key_len = len(self.key)
        
        for i, byte in enumerate(data):
            result[i] = byte ^ self.key[i % key_len]
        
        return bytes(result)
    
    def decode(self, data: bytes) -> bytes:
        return self.______(data)  # XOR is symmetric
```

### Exercise 4.2.2: RC4 Encoder

**Implement RC4 encoding:**

```python
class RC4Encoder:
    def __init__(self, key: Union[str, bytes]):
        if isinstance(key, str):
            key = key.encode()
        self.key = key
        self._keystream = self._generate_keystream()
    
    def _generate_keystream(self) -> List[int]:
        S = list(range(256))
        j = 0
        for i in range(256):
            j = (j + S[i] + self.key[i % len(self.key)]) & 0xFF
            S[i], S[j] = S[j], S[i]
        return S
    
    def _generate(self, length: int) -> bytes:
        S = self._keystream[:]
        i = j = 0
        keystream = bytearray()
        for _ in range(length):
            i = (i + 1) & 0xFF
            j = (j + S[i]) & 0xFF
            S[i], S[j] = S[j], S[i]
            keystream.append(S[(S[i] + S[j]) & 0xFF])
        return bytes(keystream)
    
    def encode(self, data: Union[str, bytes]) -> bytes:
        if isinstance(data, str):
            data = data.______()
        keystream = self.______(len(data))
        return bytes([a ^ b for a, b in zip(data, keystream)])
```

### Exercise 4.2.3: String Obfuscation

**Implement string obfuscation:**

```python
class StringObfuscator:
    @staticmethod
    def base64_encoding(string: str) -> str:
        encoded = base64.b64encode(string.______()).decode()
        return f'base64.b64decode("{encoded}").decode()'
    
    @staticmethod
    def xor_encoding(string: str, key: bytes) -> str:
        encoded = XOREncoder(key).______(string)
        hex_str = encoded.hex()
        return f'bytes.fromhex("{hex_str}").decode()'
    
    @staticmethod
    def split_string(string: str, parts: int = 3) -> str:
        part_len = max(1, len(string) // parts)
        fragments = []
        for i in range(parts):
            start = i * part_len
            end = (i + 1) * part_len
            if i == parts - 1:
                end = len(string)
            fragments.append(f'"{string[start:end]}"')
        return " + ".join(fragments)
```

### Exercise 4.2.4: Signature Evasion

**Implement evasion techniques:**

```python
class SignatureEvasion:
    @staticmethod
    def add_dead_code(code: str, ratio: float = 0.2) -> str:
        dead_templates = [
            '# Unused variable',
            'unused = None',
            'if False:',
            '    pass',
        ]
        lines = code.______()
        result = []
        for line in lines:
            result.append(line)
            if random.random() < ratio:
                result.append(random.choice(dead_templates))
        return '\n'.join(result)
    
    @staticmethod
    def rename_variables(code: str) -> str:
        import re
        variables = set()
        for match in re.finditer(r'\b([a-zA-Z_][a-zA-Z0-9_]*)\b', code):
            name = match.group(1)
            if name not in ['if', 'else', 'for', 'while', 'def', 'class']:
                variables.add(name)
        
        new_names = {}
        for var in variables:
            new_name = f'_{random.choice("abcdefghijklmnopqrstuvwxyz")}{random.randint(1000, 9999)}'
            new_names[var] = new_name
        
        result = code
        for old, new in new_names.items():
            result = result.replace(old, new)
        return result
```

### Hands-On Challenge

**Create an obfuscation system that:**
1. Supports XOR and RC4 encoding
2. Obfuscates strings
3. Adds dead code
4. Renames variables

```python
# Your code here

```

### Verification Exercise

**Test your obfuscation with:**
1. String encoding
2. Code obfuscation
3. Dead code insertion
4. Variable renaming

---

## WORKBOOK 4.3: SECURITY HARDENING

### Learning Objectives

- Implement input validation
- Create sandboxed execution
- Manage secrets securely
- Check dependencies

### Exercise 4.3.1: Input Validation

**Implement input validation:**

```python
class InputValidator:
    @staticmethod
    def sanitize_path(path: Union[str, Path]) -> Path:
        path = Path(path).______()
        if not str(path).startswith(str(BASE_DIR.______())):
            raise ValueError("Path traversal detected")
        return path
    
    @staticmethod
    def sanitize_command(command: Union[str, List[str]]) -> List[str]:
        dangerous = set(['&', '|', ';', '<', '>', '`', '$', '(', ')'])
        if isinstance(command, str):
            import shlex
            command = shlex.______(command)
        
        for part in command:
            if any(c in dangerous for c in part):
                raise ValueError(f"Dangerous character: {part}")
        return command
    
    @staticmethod
    def validate_ip(ip: str) -> bool:
        try:
            ipaddress.______(ip)
            return True
        except ValueError:
            return False
```

### Exercise 4.3.2: Sandbox

**Implement sandboxed execution:**

```python
class Sandbox:
    def __init__(self):
        self.workspace = Path(tempfile.mkdtemp())
        self.allowed_imports = {'math', 'json', 're'}
        self.cpu_limit = 60
        self.memory_limit = 256  # MB
    
    def validate_imports(self, code: str) -> bool:
        import ast
        tree = ast.parse(code)
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    if alias.name not in self.allowed_imports:
                        raise ValueError(f"Disallowed import: {alias.name}")
        return True
    
    def execute(self, code: str, timeout: int = 30):
        # Validate imports
        self.validate_imports(______)
        
        # Write code
        script_path = self.workspace / "script.py"
        script_path.write_text(code)
        
        # Set resource limits
        resource.setrlimit(resource.RLIMIT_CPU, (self.cpu_limit, self.cpu_limit + 10))
        resource.setrlimit(resource.RLIMIT_AS, (self.memory_limit * 1024 * 1024, ...))
        
        # Execute
        process = subprocess.Popen([sys.executable, str(script_path)], ...)
        stdout, stderr = process.communicate(timeout=timeout)
        
        return {'output': stdout, 'errors': stderr}
```

### Exercise 4.3.3: Secret Management

**Implement secret management:**

```python
class SecretManager:
    def get_secret(self, key: str, default: Optional[str] = None):
        # Check environment first
        env_key = key.upper().replace('-', '_')
        value = os.environ.______(env_key)
        
        if value is not None:
            self._log_access(key, 'environment')
            return value
        
        # Check stored secrets
        if key in self.secrets:
            self._log_access(key, 'storage')
            return self.secrets[key]
        
        return default
    
    def set_secret(self, key: str, value: str, encrypted: bool = True):
        if encrypted:
            value = self._encrypt_secret(value)
        self.secrets[key] = value
```

### Exercise 4.3.4: Dependency Security

**Check for vulnerabilities:**

```python
def check_dependencies() -> Dict[str, Dict[str, Any]]:
    results = {}
    packages = ['requests', 'paramiko', 'cryptography']
    
    for package in packages:
        try:
            module = importlib.import_module(package)
            version = getattr(module, '__version__', 'unknown')
            results[package] = {
                'version': version,
                'status': 'ok',
            }
        except ImportError:
            continue
    
    return results
```

### Hands-On Challenge

**Create a security hardening system that:**
1. Validates all input
2. Sandboxes code execution
3. Manages secrets securely
4. Checks dependencies

```python
# Your code here

```

### Verification Exercise

**Test your security hardening with:**
1. Path traversal prevention
2. Command injection prevention
3. Sandboxed execution
4. Secret management

---

## WORKBOOK 4.4: PRODUCTION CLI

### Learning Objectives

- Build CLI with Click
- Create rich output
- Implement subcommands
- Handle errors gracefully

### Exercise 4.4.1: CLI Structure

**Define CLI commands:**

```python
@click.group()
@click.option('--config', '-c', help='Configuration file')
@click.option('--verbose', '-v', is_flag=True, help='Verbose output')
@click.pass_context
def cli(ctx, config, verbose):
    """PyHack Suite - Advanced Security Framework"""
    ctx.ensure_object(dict)
    ctx.obj['VERBOSE'] = verbose
    # Load configuration

@cli.command()
@click.argument('target')
@click.option('--ports', '-p', help='Ports to scan')
@click.option('--stealth', '-s', is_flag=True, help='Stealth mode')
@click.pass_context
def scan(ctx, target, ports, stealth):
    """Scan a target host or network."""
    # Implementation

@cli.group()
def module():
    """Plugin module management."""
    pass

@module.command('list')
def module_list():
    """List all available modules."""
    registry = ModuleRegistry()
    modules = registry.get_all_modules()
    # Display modules
```

### Exercise 4.4.2: Rich Output

**Display results with Rich:**

```python
def display_results(results):
    table = Table(title="Scan Results")
    table.add_column("Port", style="______")
    table.add_column("Status", style="______")
    table.add_column("Service", style="______")
    table.add_column("Banner", style="______")
    
    for result in results:
        if result.status == 'open':
            status_style = "green"
        elif result.status == 'closed':
            status_style = "red"
        else:
            status_style = "yellow"
        
        table.add_row(
            str(result.port),
            f"[{status_style}]{result.status}[/{status_style}]",
            result.service or 'unknown',
            (result.banner or '')[:50]
        )
    
    console.______(table)
```

### Exercise 4.4.3: Progress Indicators

**Add progress bars:**

```python
with Progress(
    SpinnerColumn(),
    TextColumn("[progress.description]{task.description}"),
    console=console,
) as progress:
    task = progress.add_task("Scanning...", total=None)
    
    # Perform scan
    results = await scanner.scan_host(target)
    
    progress.______(task, completed=True)

# With total count
with Progress() as progress:
    task = progress.add_task("Scanning ports...", total=len(ports))
    
    for port in ports:
        await scan_port(port)
        progress.______(task, advance=1)
```

### Exercise 4.4.4: Error Handling

**Handle CLI errors gracefully:**

```python
def main():
    try:
        return cli(obj={})
    except KeyboardInterrupt:
        console.______("\n[yellow]Interrupted by user[/yellow]")
        return 130
    except Exception as e:
        console.______(f"[red]Error: {e}[/red]")
        if get_config().debug:
            import traceback
            console.______(traceback.format_exc())
        return 1
```

### Hands-On Challenge

**Create a production CLI that:**
1. Supports subcommands
2. Displays rich output
3. Shows progress
4. Handles errors gracefully

```python
# Your code here

```

### Verification Exercise

**Test your CLI with:**
1. Command help
2. Scan subcommand
3. Module management
4. Error handling

---

## APPENDIX A: SCAPY DEEP DIVE EXERCISES

### Exercise A.1: Packet Crafting

**Build the following packets:**

1. **TCP SYN packet to 192.168.1.1 port 80**

   ```python
   # Your code here
   
   ```

2. **ICMP echo request to 8.8.8.8**

   ```python
   # Your code here
   
   ```

3. **ARP request for 192.168.1.1**

   ```python
   # Your code here
   
   ```

4. **DNS query for example.com**

   ```python
   # Your code here
   
   ```

5. **HTTP GET request to example.com**

   ```python
   # Your code here
   
   ```

### Exercise A.2: Packet Sniffing

**Write code to sniff:**

1. **10 TCP packets on port 80**

   ```python
   # Your code here
   
   ```

2. **All packets from 192.168.1.1 for 5 seconds**

   ```python
   # Your code here
   
   ```

3. **ARP packets and save to PCAP**

   ```python
   # Your code here
   
   ```

### Exercise A.3: Packet Analysis

**Analyze a PCAP and find:**

1. **Top 5 source IPs**

   ```python
   # Your code here
   
   ```

2. **Top 5 destination ports**

   ```python
   # Your code here
   
   ```

3. **HTTP requests**

   ```python
   # Your code here
   
   ```

4. **DNS queries**

   ```python
   # Your code here
   
   ```

### Exercise A.4: Advanced Scapy

**Implement:**

1. **TCP SYN scan (stealth)**

   ```python
   # Your code here
   
   ```

2. **ARP spoofing**

   ```python
   # Your code here
   
   ```

3. **Packet fragmentation**

   ```python
   # Your code here
   
   ```

---

## APPENDIX B: ASYNCIO EXERCISES

### Exercise B.1: Basic Async

**Write async functions for:**

1. **Fetch multiple URLs concurrently**

   ```python
   # Your code here
   
   ```

2. **Producer-consumer pattern with queue**

   ```python
   # Your code here
   
   ```

3. **Rate-limited requests**

   ```python
   # Your code here
   
   ```

### Exercise B.2: Async Patterns

**Implement:**

1. **Fan-out/fan-in pattern**

   ```python
   # Your code here
   
   ```

2. **Retry with exponential backoff**

   ```python
   # Your code here
   
   ```

3. **Circuit breaker**

   ```python
   # Your code here
   
   ```

### Exercise B.3: Async Context Managers

**Create:**

1. **Async timer context manager**

   ```python
   # Your code here
   
   ```

2. **Async connection pool**

   ```python
   # Your code here
   
   ```

3. **Async rate limiter**

   ```python
   # Your code here
   
   ```

---

## APPENDIX C: SECURITY BEST PRACTICES EXERCISES

### Exercise C.1: Input Validation

**Implement validation for:**

1. **SQL injection prevention**

   ```python
   # Your code here
   
   ```

2. **Path traversal prevention**

   ```python
   # Your code here
   
   ```

3. **Command injection prevention**

   ```python
   # Your code here
   
   ```

### Exercise C.2: Authentication

**Implement:**

1. **bcrypt password hashing**

   ```python
   # Your code here
   
   ```

2. **JWT token generation**

   ```python
   # Your code here
   
   ```

3. **Rate-limited login**

   ```python
   # Your code here
   
   ```

### Exercise C.3: Secure Code Patterns

**Implement:**

1. **Secure configuration loading**

   ```python
   # Your code here
   
   ```

2. **Secret rotation**

   ```python
   # Your code here
   
   ```

3. **Audit logging**

   ```python
   # Your code here
   
   ```

---

## PRIMER 1: NETWORK PROGRAMMING FUNDAMENTALS

### Exercise P1.1: Socket Programming

**Create:**

1. **TCP echo server**

   ```python
   # Your code here
   
   ```

2. **TCP echo client**

   ```python
   # Your code here
   
   ```

3. **UDP server**

   ```python
   # Your code here
   
   ```

4. **UDP client**

   ```python
   # Your code here
   
   ```

### Exercise P1.2: HTTP Client

**Implement:**

1. **GET request**

   ```python
   # Your code here
   
   ```

2. **POST request**

   ```python
   # Your code here
   
   ```

3. **Request with headers**

   ```python
   # Your code here
   
   ```

### Exercise P1.3: Network Utilities

**Create:**

1. **Port scanner**

   ```python
   # Your code here
   
   ```

2. **Ping utility**

   ```python
   # Your code here
   
   ```

3. **WHOIS lookup**

   ```python
   # Your code here
   
   ```

---

## PRIMER 2: ASYNC PROGRAMMING FUNDAMENTALS

### Exercise P2.1: Async Basics

**Write:**

1. **Async function with asyncio.sleep**

   ```python
   # Your code here
   
   ```

2. **Multiple concurrent tasks**

   ```python
   # Your code here
   
   ```

3. **Task with timeout**

   ```python
   # Your code here
   
   ```

### Exercise P2.2: Async HTTP

**Implement:**

1. **Concurrent HTTP requests with aiohttp**

   ```python
   # Your code here
   
   ```

2. **Streaming response handler**

   ```python
   # Your code here
   
   ```

3. **Connection pool**

   ```python
   # Your code here
   
   ```

### Exercise P2.3: Async Patterns

**Implement:**

1. **Async queue with workers**

   ```python
   # Your code here
   
   ```

2. **Rate-limited API client**

   ```python
   # Your code here
   
   ```

3. **Async event handler**

   ```python
   # Your code here
   
   ```

---

## PRIMER 3: SCAPY ADVANCED FUNDAMENTALS

### Exercise P3.1: Packet Building

**Create:**

1. **Custom ICMP packet with payload**

   ```python
   # Your code here
   
   ```

2. **TCP packet with options**

   ```python
   # Your code here
   
   ```

3. **Fragmented IP packet**

   ```python
   # Your code here
   
   ```

### Exercise P3.2: Packet Analysis

**Implement:**

1. **HTTP header extractor**

   ```python
   # Your code here
   
   ```

2. **DNS query detector**

   ```python
   # Your code here
   
   ```

3. **TCP flag analyzer**

   ```python
   # Your code here
   
   ```

### Exercise P3.3: Advanced Scapy

**Implement:**

1. **Custom protocol dissector**

   ```python
   # Your code here
   
   ```

2. **Packet fuzzing**

   ```python
   # Your code here
   
   ```

3. **PCAP analyzer**

   ```python
   # Your code here
   
   ```

---

## FINAL PROJECT: COMPLETE RECONNAISSANCE TOOL

### Project Description

Build a complete reconnaissance tool that integrates all the components from this course.

### Requirements

**1. Core Functionality**
- [ ] Asynchronous port scanning
- [ ] Service detection
- [ ] OS fingerprinting
- [ ] Subdomain enumeration
- [ ] Directory brute forcing
- [ ] DOM analysis

**2. Architecture**
- [ ] Modular plugin system
- [ ] Unified configuration
- [ ] Professional logging
- [ ] Error handling

**3. User Interface**
- [ ] Command-line interface
- [ ] Rich output formatting
- [ ] Progress indicators
- [ ] JSON export

**4. Security**
- [ ] Input validation
- [ ] Rate limiting
- [ ] Stealth features
- [ ] Secure logging

### Project Deliverables

1. **Source Code:** Complete, working implementation
2. **Documentation:** README, usage guide
3. **Tests:** Unit and integration tests
4. **Example:** Sample output

### Project Timeline

| Week | Task |
|------|------|
| 1 | Design and planning |
| 2-3 | Core implementation |
| 4 | Testing and documentation |
| 5 | Final review and submission |

### Submission Checklist

- [ ] All code is complete and works
- [ ] Documentation is clear and complete
- [ ] Tests pass successfully
- [ ] Example output is included
- [ ] Security features are implemented

---

## ASSESSMENT RUBRIC

### Project Evaluation Criteria

| Criteria | Excellent (5) | Good (4) | Satisfactory (3) | Needs Improvement (2) | Unsatisfactory (1) |
|----------|---------------|----------|------------------|----------------------|-------------------|
| **Functionality** | All features work perfectly | Most features work | Basic features work | Some features work | Features don't work |
| **Code Quality** | Clean, well-documented, follows patterns | Good structure, mostly documented | Acceptable structure | Inconsistent structure | Poor structure |
| **Architecture** | Excellent design patterns | Good patterns used | Basic patterns | Limited patterns | Poor design |
| **Security** | All security best practices followed | Most security practices | Basic security | Some security issues | Major security issues |
| **Documentation** | Complete, clear, examples | Good documentation | Basic documentation | Limited documentation | No documentation |
| **Testing** | Comprehensive tests | Good test coverage | Some tests | Few tests | No tests |
| **CLI** | Professional, intuitive | Good interface | Basic interface | Limited interface | No interface |

### Total Score: ________/35

### Final Grade: ________

---

## CERTIFICATE OF COMPLETION TEMPLATE

```
═══════════════════════════════════════════════════════════════════
                  CERTIFICATE OF COMPLETION
                         
                  PYTHON FOR HACKERS
     Advanced Engineering & Defensive Architecture
                         
    This certifies that
                         
         [STUDENT NAME]
                         
    has successfully completed all requirements of the
    Python for Hackers course, demonstrating proficiency in:
                         
    • Infrastructure Automation & Protocol Analysis
    • High-Speed Packet Sniffing & Asynchronous Integration
    • Stealth Reconnaissance & Asynchronous Tooling
    • Advanced Tooling Design, Obfuscation & Hardening
                         
    Date: [DATE]
                         
    ─────────────────────────────────────────────────────
    [INSTRUCTOR NAME]
    [TITLE]
    [ORGANIZATION]
═══════════════════════════════════════════════════════════════════
```

---

```
[COMPLETED: Student Workbook Generation]
```

## Workbook Statistics

| Section | Pages | Exercises |
|---------|-------|-----------|
| Part 0: Introduction | 4 | 8 |
| Part 1: Infrastructure | 12 | 35 |
| Part 2: Async Sniffing | 10 | 30 |
| Part 3: Reconnaissance | 10 | 30 |
| Part 4: Hardening | 10 | 30 |
| Appendices | 6 | 20 |
| Primers | 6 | 18 |
| Final Project | 2 | 1 |
| Assessment | 1 | 1 |
| **Total** | **61** | **173** |

---

**[END OF STUDENT WORKBOOK]**
