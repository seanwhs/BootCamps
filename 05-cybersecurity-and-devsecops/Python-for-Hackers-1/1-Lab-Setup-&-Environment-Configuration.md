# Phase 1: Foundations & Network Fundamentals
## Part 1: Lab Setup & Environment Configuration

### The Target: Complete Lab Environment

By the end of this part, you will have a fully operational hacking lab consisting of:
- Kali Linux (attacker machine) with all necessary tools
- Ubuntu Server (target machine) with vulnerable services
- Windows 10 (optional target) for Windows-specific testing
- Isolated host-only network for safe testing

### The Concept: Why a Virtual Lab?

Think of building a hacking lab like setting up a boxing gym. You need:
- A **safe space** to practice (your isolated network)
- **Practice partners** that can take hits (vulnerable target VMs)
- **Your training gear** (Kali Linux with tools)
- **Protective equipment** (snapshots to roll back)

Virtual machines (VMs) provide all of this. They're like virtual computers running inside your real computer. You can:
- Create completely isolated networks
- Take snapshots to roll back to a clean state
- Run multiple operating systems simultaneously
- Practice without affecting your host machine

### The Implementation: Complete Setup Script

Let's create a setup script that will automate the configuration of your Kali environment. This script ensures consistency and saves you from manual setup issues.

#### File: `~/hacking-toolkit/setup_lab.sh`

```bash
#!/bin/bash
# setup_lab.sh - Automated Lab Environment Setup Script
# This script configures the Kali attacker machine with all necessary tools

# Color codes for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Header
echo "=========================================="
echo "  Python for Hackers - Lab Setup Script"
echo "  Version: 1.0.0"
echo "=========================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Phase 1: System Update
print_status "Phase 1: Updating System Packages"
apt update && apt upgrade -y
if [ $? -eq 0 ]; then
    print_success "System updated successfully"
else
    print_error "System update failed"
    exit 1
fi

# Phase 2: Install Core Dependencies
print_status "Phase 2: Installing Core Dependencies"
apt install -y python3 python3-pip python3-venv \
    git vim curl wget net-tools \
    build-essential libssl-dev libffi-dev \
    python3-dev python3-setuptools \
    nmap masscan hydra john \
    wireshark tcpdump
if [ $? -eq 0 ]; then
    print_success "Core dependencies installed"
else
    print_error "Core dependencies installation failed"
    exit 1
fi

# Phase 3: Create Project Directory Structure
print_status "Phase 3: Creating Project Structure"
mkdir -p /home/kali/hacking-toolkit/{recon,web-attack,exploit,post-exploit,framework,payloads,config,modules,utils,templates,logs,data}
chown -R kali:kali /home/kali/hacking-toolkit
print_success "Project structure created"

# Phase 4: Setup Python Virtual Environment
print_status "Phase 4: Setting up Python Virtual Environment"
cd /home/kali/hacking-toolkit
python3 -m venv hacker-env
source hacker-env/bin/activate
print_success "Virtual environment created and activated"

# Phase 5: Create requirements.txt
print_status "Phase 5: Creating requirements.txt"
cat > requirements.txt << 'EOF'
# Network & Protocol
scapy==2.5.0
pcapy==0.11.5

# Web & HTTP
requests==2.31.0
urllib3==2.0.7
beautifulsoup4==4.12.2
lxml==4.9.3
selenium==4.15.0

# Serialization & Data
pyyaml==6.0.1
json5==0.9.14
toml==0.10.2

# Cryptography
cryptography==41.0.7
pycryptodome==3.19.0

# Networking Utilities
dnspython==2.4.2
netifaces==0.11.0
python-nmap==0.7.1

# GUI & Terminal
colorama==0.4.6
rich==13.7.0
prompt-toolkit==3.0.43

# Development
pyinstaller==6.2.0
pytest==7.4.3
black==23.11.0

# Database
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
EOF
print_success "requirements.txt created"

# Phase 6: Install Python Packages
print_status "Phase 6: Installing Python Packages"
pip install --upgrade pip
pip install -r requirements.txt
if [ $? -eq 0 ]; then
    print_success "Python packages installed successfully"
else
    print_error "Python package installation failed"
    exit 1
fi

# Phase 7: Create Configuration File
print_status "Phase 7: Creating Configuration File"
cat > config/config.yaml << 'EOF'
# Hacking Toolkit Configuration
# Version: 1.0.0

# Network Configuration
network:
  # Default target for scanning operations
  default_target: "192.168.100.20"  # Ubuntu target VM
  
  # Network interfaces to use for different operations
  interfaces:
    attack: "eth0"      # Primary attack interface
    monitor: "eth0"     # Interface for monitoring
    
  # Timeout values in seconds
  timeouts:
    connection: 5
    read: 10
    scan: 30

# Scanning Configuration  
scanning:
  # Common ports to scan
  common_ports:
    - 21    # FTP
    - 22    # SSH
    - 23    # Telnet
    - 25    # SMTP
    - 53    # DNS
    - 80    # HTTP
    - 110   # POP3
    - 111   # RPC
    - 135   # RPC
    - 139   # NetBIOS
    - 143   # IMAP
    - 443   # HTTPS
    - 445   # SMB
    - 993   # IMAPS
    - 995   # POP3S
    - 1723  # PPTP
    - 3306  # MySQL
    - 3389  # RDP
    - 5432  # PostgreSQL
    - 5900  # VNC
    - 6379  # Redis
    - 8080  # HTTP Proxy
    - 8443  # HTTPS Alt
  
  # Maximum threads for scanning
  max_threads: 100
  
  # Port scan timeout in seconds
  scan_timeout: 2

# Web Configuration
web:
  # Default user agent
  user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  
  # Request timeout in seconds
  timeout: 10
  
  # Maximum concurrent requests
  max_concurrent: 50
  
  # Common directory paths for brute force
  common_dirs:
    - "admin"
    - "login"
    - "wp-admin"
    - "administrator"
    - "backup"
    - "config"
    - "database"
    - "phpmyadmin"
    - "cpanel"
    - "webmail"

# Exploit Configuration
exploit:
  # Payload directory
  payload_dir: "payloads"
  
  # Obfuscation techniques to use
  obfuscation:
    - "base64"
    - "hex"
    - "xor"
    - "rot13"
  
  # Maximum payload size in bytes
  max_payload_size: 8192

# Post-Exploitation Configuration
post_exploit:
  # Persistence methods
  persistence:
    - "cron"
    - "systemd"
    - "startup"
    - "registry"  # Windows only
  
  # Logging configuration
  logging:
    level: "INFO"
    file: "logs/hacking_toolkit.log"
    format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# C2 Configuration
c2:
  # Server configuration
  server:
    host: "0.0.0.0"
    port: 8443
    ssl: true
    ssl_cert: "config/certs/server.crt"
    ssl_key: "config/certs/server.key"
  
  # Agent configuration
  agent:
    heartbeat_interval: 60  # Seconds
    command_timeout: 30      # Seconds
    max_retries: 3

# Logging Configuration
logging:
  level: "INFO"
  file: "logs/hacking_toolkit.log"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
EOF
print_success "Configuration file created"

# Phase 8: Create Core Framework Files
print_status "Phase 8: Creating Core Framework Files"

# Create __init__.py files for Python packages
touch framework/__init__.py
touch recon/__init__.py
touch web-attack/__init__.py
touch exploit/__init__.py
touch post-exploit/__init__.py
touch modules/__init__.py
touch utils/__init__.py

# Create basic logger utility
cat > utils/logger.py << 'EOF'
"""
logger.py - Centralized logging utility for the Hacking Toolkit
This module provides consistent logging across all toolkit components
"""

import logging
import sys
from datetime import datetime
from typing import Optional
from pathlib import Path

class ToolkitLogger:
    """
    Centralized logger class that handles all logging operations
    Supports console output, file logging, and different log levels
    """
    
    # Singleton instance
    _instance = None
    
    def __new__(cls):
        """Implement singleton pattern to ensure only one logger instance exists"""
        if cls._instance is None:
            cls._instance = super(ToolkitLogger, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        """Initialize logger configuration"""
        if self._initialized:
            return
        
        self.logger = logging.getLogger("HackingToolkit")
        self.logger.setLevel(logging.DEBUG)
        
        # Create console handler with formatting
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        
        # Create formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        console_handler.setFormatter(formatter)
        
        # Add handler to logger
        self.logger.addHandler(console_handler)
        
        # Ensure logs directory exists
        Path("logs").mkdir(exist_ok=True)
        
        # Create file handler for persistent logs
        file_handler = logging.FileHandler(
            f"logs/hacking_toolkit_{datetime.now().strftime('%Y%m%d')}.log"
        )
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)
        self.logger.addHandler(file_handler)
        
        self._initialized = True
    
    def get_logger(self):
        """Return the configured logger instance"""
        return self.logger

# Convenience functions for direct import
def get_logger():
    """Get the singleton logger instance"""
    return ToolkitLogger().get_logger()

def debug(msg: str):
    """Log debug message"""
    get_logger().debug(msg)

def info(msg: str):
    """Log info message"""
    get_logger().info(msg)

def warning(msg: str):
    """Log warning message"""
    get_logger().warning(msg)

def error(msg: str):
    """Log error message"""
    get_logger().error(msg)

def critical(msg: str):
    """Log critical message"""
    get_logger().critical(msg)

# Example usage when this file is run directly
if __name__ == "__main__":
    # Test the logger
    info("Logger initialized successfully")
    warning("This is a test warning")
    error("This is a test error")
EOF
print_success "Core framework files created"

# Phase 9: Create Basic Utilities
print_status "Phase 9: Creating Basic Utilities"

# Create configuration loader
cat > utils/config.py << 'EOF'
"""
config.py - Configuration management for the Hacking Toolkit
Handles loading and accessing configuration from YAML files
"""

import yaml
from pathlib import Path
from typing import Any, Dict, Optional

class ConfigManager:
    """
    Manages configuration loading and access
    Uses singleton pattern to ensure configuration is loaded once
    """
    
    _instance = None
    _config: Dict[str, Any] = {}
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ConfigManager, cls).__new__(cls)
        return cls._instance
    
    def load_config(self, config_path: str = "config/config.yaml"):
        """
        Load configuration from YAML file
        
        Args:
            config_path: Path to the configuration file
            
        Returns:
            Dict containing configuration values
            
        Raises:
            FileNotFoundError: If config file doesn't exist
            yaml.YAMLError: If config file has invalid YAML
        """
        config_file = Path(config_path)
        
        if not config_file.exists():
            # Create default config if it doesn't exist
            self._create_default_config(config_file)
        
        try:
            with open(config_file, 'r') as f:
                self._config = yaml.safe_load(f)
            return self._config
        except yaml.YAMLError as e:
            raise ValueError(f"Invalid YAML in config file: {e}")
    
    def _create_default_config(self, config_path: Path):
        """Create a default configuration file"""
        config_path.parent.mkdir(parents=True, exist_ok=True)
        
        default_config = {
            'network': {
                'default_target': '192.168.100.20',
                'interfaces': {'attack': 'eth0', 'monitor': 'eth0'},
                'timeouts': {'connection': 5, 'read': 10, 'scan': 30}
            },
            'scanning': {
                'common_ports': [21, 22, 23, 25, 53, 80, 110, 111, 135, 
                               139, 143, 443, 445, 993, 995, 1723, 3306, 
                               3389, 5432, 5900, 6379, 8080, 8443],
                'max_threads': 100,
                'scan_timeout': 2
            },
            'web': {
                'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'timeout': 10,
                'max_concurrent': 50,
                'common_dirs': ['admin', 'login', 'wp-admin', 'administrator', 
                              'backup', 'config', 'database', 'phpmyadmin']
            },
            'logging': {
                'level': 'INFO',
                'file': 'logs/hacking_toolkit.log',
                'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            }
        }
        
        with open(config_path, 'w') as f:
            yaml.dump(default_config, f, default_flow_style=False)
    
    def get(self, key: str, default: Any = None) -> Any:
        """
        Get configuration value by dot-notation key
        
        Example:
            config.get('network.default_target')
            
        Args:
            key: Dot-notation path to configuration value
            default: Default value if key is not found
            
        Returns:
            Configuration value or default
        """
        if not self._config:
            self.load_config()
        
        keys = key.split('.')
        value = self._config
        
        try:
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default
    
    def get_all(self) -> Dict[str, Any]:
        """Get entire configuration dictionary"""
        if not self._config:
            self.load_config()
        return self._config.copy()

# Convenience function
def get_config():
    """Get the configuration manager instance"""
    return ConfigManager()

# Example usage
if __name__ == "__main__":
    config = get_config()
    config.load_config()
    
    # Test retrieving values
    default_target = config.get('network.default_target')
    print(f"Default target: {default_target}")
    
    common_ports = config.get('scanning.common_ports')
    print(f"Common ports: {common_ports[:5]}...")
EOF
print_success "Utilities created"

# Phase 10: Create First Verification Script
print_status "Phase 10: Creating Verification Script"

cat > verify_setup.py << 'EOF'
#!/usr/bin/env python3
"""
verify_setup.py - Verify that your lab environment is properly configured
This script checks all essential components and reports status
"""

import sys
import os
import subprocess
import importlib
from pathlib import Path

class SetupVerifier:
    """Verifies the lab environment setup"""
    
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.warnings = 0
    
    def print_header(self, text):
        """Print a header with formatting"""
        print("\n" + "="*60)
        print(f"  {text}")
        print("="*60)
    
    def print_test(self, name, status, details=""):
        """Print a test result"""
        if status:
            self.passed += 1
            symbol = "✓"
            result = "PASSED"
            color = "\033[92m"  # Green
        elif status is None:
            self.warnings += 1
            symbol = "⚠"
            result = "WARNING"
            color = "\033[93m"  # Yellow
        else:
            self.failed += 1
            symbol = "✗"
            result = "FAILED"
            color = "\033[91m"  # Red
        
        reset = "\033[0m"  # Reset color
        print(f"{color}{symbol} {result}{reset}: {name}")
        if details:
            print(f"   {details}")
    
    def check_python(self):
        """Check Python version"""
        version = sys.version_info
        is_ok = version.major >= 3 and version.minor >= 10
        self.print_test(
            "Python 3.10+",
            is_ok,
            f"Found Python {version.major}.{version.minor}.{version.micro}"
        )
        return is_ok
    
    def check_packages(self):
        """Check required packages"""
        required = [
            'requests', 'scapy', 'beautifulsoup4', 'cryptography',
            'pyyaml', 'rich', 'colorama', 'dnspython'
        ]
        
        missing = []
        for package in required:
            try:
                importlib.import_module(package)
            except ImportError:
                missing.append(package)
        
        if missing:
            self.print_test(
                "Required packages",
                False,
                f"Missing: {', '.join(missing)}"
            )
            return False
        else:
            self.print_test("Required packages", True, "All packages found")
            return True
    
    def check_directory_structure(self):
        """Check if required directories exist"""
        required_dirs = [
            'recon', 'web-attack', 'exploit', 'post-exploit',
            'framework', 'payloads', 'config', 'modules', 
            'utils', 'templates', 'logs', 'data'
        ]
        
        missing = []
        for directory in required_dirs:
            if not Path(directory).exists():
                missing.append(directory)
        
        if missing:
            self.print_test(
                "Directory structure",
                False,
                f"Missing directories: {', '.join(missing)}"
            )
            return False
        else:
            self.print_test("Directory structure", True, "All directories exist")
            return True
    
    def check_virtualenv(self):
        """Check if running in virtual environment"""
        in_venv = hasattr(sys, 'real_prefix') or \
                 (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix)
        
        self.print_test(
            "Virtual environment",
            in_venv,
            "Running in virtual environment" if in_venv else "Not in virtual environment (recommended)"
        )
        return True  # Not critical
    
    def check_config(self):
        """Check if configuration exists"""
        config_exists = Path('config/config.yaml').exists()
        self.print_test(
            "Configuration file",
            config_exists,
            "Found config/config.yaml" if config_exists else "Configuration file missing"
        )
        return config_exists
    
    def run(self):
        """Run all verifications"""
        self.print_header("Lab Environment Verification")
        
        print("\nChecking system configuration...")
        self.check_python()
        
        print("\nChecking Python packages...")
        self.check_packages()
        
        print("\nChecking project structure...")
        self.check_directory_structure()
        
        print("\nChecking environment...")
        self.check_virtualenv()
        
        print("\nChecking configuration...")
        self.check_config()
        
        # Summary
        self.print_header("Verification Summary")
        print(f"Passed: {self.passed}")
        print(f"Warnings: {self.warnings}")
        print(f"Failed: {self.failed}")
        
        if self.failed == 0:
            print("\n\033[92m✓ Setup verification passed!\033[0m")
            print("\nYour lab environment is ready. Proceed to Part 2.")
        else:
            print("\n\033[91m✗ Setup verification failed!\033[0m")
            print("\nPlease fix the issues above before continuing.")
        
        print("\nRecommended next steps:")
        print("1. Review the configuration in config/config.yaml")
        print("2. Start exploring the toolkit structure")
        print("3. Proceed to Phase 1, Part 2: Socket Programming")
        
        return self.failed == 0

if __name__ == "__main__":
    verifier = SetupVerifier()
    success = verifier.run()
    sys.exit(0 if success else 1)
EOF
chmod +x verify_setup.py
print_success "Verification script created"

# Phase 11: Run Verification
print_status "Phase 11: Running Verification"
python3 verify_setup.py

print_success "Setup complete!"
print_status "Your hacking toolkit is ready. Next step: Phase 1, Part 2"

# Create a welcome message
cat > welcome.txt << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🐍 Python for Hackers - Lab Environment                ║
║                                                           ║
║   ✓ Kali Linux configured                                ║
║   ✓ Python 3.10+ installed                              ║
║   ✓ Virtual environment active                          ║
║   ✓ All packages installed                             ║
║   ✓ Project structure created                          ║
║                                                           ║
║   Next: Phase 1, Part 2 - Socket Programming Basics      ║
║                                                           ║
║   To activate environment:                               ║
║   cd ~/hacking-toolkit                                   ║
║   source hacker-env/bin/activate                         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF

cat welcome.txt
```

### The Verification

Now let's test that your environment is set up correctly:

```bash
# Make the script executable
chmod +x setup_lab.sh

# Run the setup script (requires sudo)
sudo ./setup_lab.sh

# After setup completes, verify the environment
python3 verify_setup.py
```

**Expected Output:**
```
============================================================
  Lab Environment Verification
============================================================

Checking system configuration...
✓ PASSED: Python 3.10+
   Found Python 3.10.12

Checking Python packages...
✓ PASSED: Required packages
   All packages found

Checking project structure...
✓ PASSED: Directory structure
   All directories exist

Checking environment...
✓ PASSED: Virtual environment
   Running in virtual environment

Checking configuration...
✓ PASSED: Configuration file
   Found config/config.yaml

============================================================
  Verification Summary
============================================================
Passed: 5
Warnings: 0
Failed: 0

✓ Setup verification passed!

Your lab environment is ready. Proceed to Part 2.
```

## Virtual Machine Setup Instructions

If you're using VirtualBox, here's how to set up your VMs:

### Kali Linux Setup

1. **Download Kali Linux**:
   ```bash
   wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-installer-amd64.iso
   ```

2. **Create Virtual Machine**:
   - RAM: 4GB minimum (8GB recommended)
   - CPU: 2 cores minimum (4 recommended)
   - Storage: 40GB minimum
   - Network: Host-Only adapter + NAT

3. **Network Configuration**:
   ```bash
   # In Kali VM, configure host-only network
   sudo ip addr add 192.168.100.10/24 dev eth1
   sudo ip link set eth1 up
   ```

### Ubuntu Target Setup

1. **Create VM**:
   - RAM: 2GB minimum
   - CPU: 1 core minimum
   - Storage: 20GB minimum
   - Network: Host-Only only

2. **Install Vulnerable Services**:
   ```bash
   # Install services
   sudo apt update
   sudo apt install -y apache2 mysql-server openssh-server ftp vsftpd
   
   # Install vulnerable web app
   sudo apt install -y phpmyadmin webmin
   
   # Configure network
   sudo ip addr add 192.168.100.20/24 dev enp0s3
   sudo ip link set enp0s3 up
   ```

### Verify Network Connectivity

From your Kali VM:

```bash
# Test connectivity to target
ping -c 4 192.168.100.20

# Quick port scan
nmap -p 22,80,443,3306 192.168.100.20
```
