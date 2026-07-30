# Appendix B: Complete Lab Setup & Deployment Guide

## Automated Lab Environment Setup

This appendix provides comprehensive instructions for setting up the complete Python for Hackers lab environment, including all dependencies, configurations, and deployment options.

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Automated Setup Script](#automated-setup-script)
3. [Manual Installation Guide](#manual-installation-guide)
4. [Docker Deployment](#docker-deployment)
5. [Virtual Machine Configuration](#virtual-machine-configuration)
6. [Target Environment Setup](#target-environment-setup)
7. [Network Configuration](#network-configuration)
8. [Verification & Testing](#verification--testing)
9. [Common Issues & Solutions](#common-issues--solutions)

---

## System Requirements

### Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| **CPU** | 2+ cores (Intel VT-x/AMD-V supported) |
| **RAM** | 8GB minimum (16GB recommended) |
| **Storage** | 50GB free space (100GB recommended) |
| **Network** | Internet connection for downloads |
| **OS** | Windows 10/11, Linux, or macOS |

### Software Requirements

| Software | Version | Purpose |
|----------|---------|---------|
| Python | 3.10+ | Core language |
| VirtualBox | 7.0+ | Virtualization |
| Vagrant | 2.3+ | VM automation (optional) |
| Docker | 24.0+ | Containerization (optional) |
| Git | 2.40+ | Version control |

---

## Automated Setup Script

### Full Installation Script

#### File: `~/hacking-toolkit/install.sh`

```bash
#!/bin/bash
# install.sh - Complete Lab Environment Installation
# This script installs everything needed for the Python for Hackers series

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${HOME}/hacking-toolkit"
VENV_DIR="${INSTALL_DIR}/venv"
LOG_FILE="${INSTALL_DIR}/install.log"
PYTHON_VERSION="3.10"

# Functions
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

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}"
}

check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 not found. Please install Python 3.10+"
        exit 1
    fi
    
    PYTHON_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if [[ $(echo "$PYTHON_VER < 3.10" | bc) -eq 1 ]]; then
        print_error "Python version $PYTHON_VER found. Need 3.10+"
        exit 1
    fi
    
    print_success "Python $PYTHON_VER found"
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 not found"
        exit 1
    fi
    
    print_success "pip3 found"
    
    # Check git
    if ! command -v git &> /dev/null; then
        print_warning "git not found. Will install dependencies manually"
    else
        print_success "git found"
    fi
}

create_directory_structure() {
    print_status "Creating directory structure..."
    
    mkdir -p "${INSTALL_DIR}"/{recon,web-attack,exploit,post-exploit,framework,payloads,config,modules,utils,templates,logs,data}
    mkdir -p "${INSTALL_DIR}"/{certs,wordlists,reports,backups}
    
    print_success "Directory structure created"
}

setup_virtual_environment() {
    print_status "Setting up Python virtual environment..."
    
    python3 -m venv "${VENV_DIR}"
    source "${VENV_DIR}/bin/activate"
    
    # Upgrade pip
    pip install --upgrade pip
    
    print_success "Virtual environment created at ${VENV_DIR}"
}

install_dependencies() {
    print_status "Installing Python dependencies..."
    
    # Create requirements file
    cat > "${INSTALL_DIR}/requirements.txt" << 'EOF'
# Network & Protocol
scapy==2.5.0
pcapy==0.11.5
dnspython==2.4.2
netifaces==0.11.0
python-nmap==0.7.1

# Web & HTTP
requests==2.31.0
urllib3==2.0.7
beautifulsoup4==4.12.2
lxml==4.9.3
selenium==4.15.0
flask==3.0.0

# Serialization & Data
pyyaml==6.0.1
json5==0.9.14
toml==0.10.2

# Cryptography
cryptography==41.0.7
pycryptodome==3.19.0

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

# System
psutil==5.9.6
pillow==10.1.0

# Windows (optional)
pywin32==306
wmi==1.5.1
EOF

    # Install packages
    pip install -r "${INSTALL_DIR}/requirements.txt"
    
    # Install platform-specific packages
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        pip install netifaces
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        pip install netifaces
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        pip install pywin32 wmi
    fi
    
    print_success "Dependencies installed"
}

create_config_files() {
    print_status "Creating configuration files..."
    
    # Create main config
    cat > "${INSTALL_DIR}/config/config.yaml" << 'EOF'
# Hacking Toolkit Configuration
# Version: 1.0.0

network:
  default_target: "192.168.100.20"
  interfaces:
    attack: "eth0"
    monitor: "eth0"
  timeouts:
    connection: 5
    read: 10
    scan: 30

scanning:
  common_ports:
    - 21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5432,5900,6379,8080,8443
  max_threads: 100
  scan_timeout: 2

web:
  user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  timeout: 10
  max_concurrent: 50
  common_dirs:
    - admin,login,wp-admin,administrator,backup,config,database,phpmyadmin,cpanel,webmail

logging:
  level: "INFO"
  file: "logs/hacking_toolkit.log"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

c2:
  server:
    host: "0.0.0.0"
    port: 8443
    ssl: false
  agent:
    heartbeat_interval: 60
    command_timeout: 30
    max_retries: 3
EOF

    # Create logger utility
    cat > "${INSTALL_DIR}/utils/logger.py" << 'EOF'
import logging
import sys
from datetime import datetime
from pathlib import Path

def setup_logger(name="HackingToolkit", log_file=None):
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    if log_file:
        Path(log_file).parent.mkdir(exist_ok=True)
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    return logger

logger = setup_logger(log_file="logs/toolkit.log")
EOF

    # Create config loader
    cat > "${INSTALL_DIR}/utils/config.py" << 'EOF'
import yaml
from pathlib import Path

class Config:
    _instance = None
    _config = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def load(self, config_path="config/config.yaml"):
        config_file = Path(config_path)
        if not config_file.exists():
            self._create_default_config(config_file)
        
        with open(config_file) as f:
            self._config = yaml.safe_load(f)
        return self._config
    
    def get(self, key, default=None):
        if self._config is None:
            self.load()
        
        keys = key.split('.')
        value = self._config
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
            else:
                return default
        return value if value is not None else default
    
    def _create_default_config(self, path):
        path.parent.mkdir(exist_ok=True)
        default = {
            'network': {'default_target': '192.168.100.20'},
            'logging': {'level': 'INFO', 'file': 'logs/toolkit.log'}
        }
        with open(path, 'w') as f:
            yaml.dump(default, f)

config = Config()
EOF

    print_success "Configuration files created"
}

create_verification_script() {
    print_status "Creating verification script..."
    
    cat > "${INSTALL_DIR}/verify.py" << 'EOF'
#!/usr/bin/env python3
import sys
import importlib
import subprocess
from pathlib import Path

class Verifier:
    def __init__(self):
        self.passed = 0
        self.failed = 0
    
    def check_python(self):
        version = sys.version_info
        ok = version.major >= 3 and version.minor >= 10
        print(f"{'✓' if ok else '✗'} Python 3.10+: {version.major}.{version.minor}")
        return ok
    
    def check_packages(self):
        required = ['requests', 'scapy', 'bs4', 'flask', 'psutil', 'cryptography']
        missing = []
        for pkg in required:
            try:
                importlib.import_module(pkg)
            except ImportError:
                missing.append(pkg)
        
        if missing:
            print(f"✗ Missing packages: {', '.join(missing)}")
            return False
        print("✓ All packages found")
        return True
    
    def check_directories(self):
        required = ['recon', 'web-attack', 'exploit', 'post-exploit', 'config', 'utils', 'logs']
        missing = []
        for d in required:
            if not Path(d).exists():
                missing.append(d)
        
        if missing:
            print(f"✗ Missing directories: {', '.join(missing)}")
            return False
        print("✓ All directories exist")
        return True
    
    def check_config(self):
        ok = Path('config/config.yaml').exists()
        print(f"{'✓' if ok else '✗'} Configuration file")
        return ok
    
    def run(self):
        print("\n=== Verification ===\n")
        self.check_python()
        self.check_packages()
        self.check_directories()
        self.check_config()
        print("\n✅ Verification complete")

if __name__ == "__main__":
    Verifier().run()
EOF

    chmod +x "${INSTALL_DIR}/verify.py"
    print_success "Verification script created"
}

setup_wordlists() {
    print_status "Setting up wordlists..."
    
    # Common wordlists
    cat > "${INSTALL_DIR}/wordlists/common.txt" << 'EOF'
admin
administrator
login
wp-admin
backup
config
database
phpmyadmin
cpanel
webmail
test
dev
stage
api
v1
v2
docs
images
css
js
assets
static
media
downloads
uploads
files
data
logs
EOF

    cat > "${INSTALL_DIR}/wordlists/admin.txt" << 'EOF'
admin
administrator
manage
control
root
sysadmin
webadmin
manager
dashboard
panel
cp
cpanel
plesk
webmin
cacti
nagios
EOF

    cat > "${INSTALL_DIR}/wordlists/backup.txt" << 'EOF'
backup
bak
old
orig
original
save
tmp
temp
test
dev
stage
staging
copy
backup.zip
backup.tar.gz
backup.sql
EOF

    print_success "Wordlists created"
}

setup_aliases() {
    print_status "Setting up aliases..."
    
    SHELL_RC="${HOME}/.bashrc"
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="${HOME}/.zshrc"
    fi
    
    cat >> "${SHELL_RC}" << 'EOF'

# Python for Hackers Aliases
alias hkt="cd ~/hacking-toolkit"
alias hkt-activate="source ~/hacking-toolkit/venv/bin/activate"
alias hkt-scan="python3 ~/hacking-toolkit/recon/port_scanner.py"
alias hkt-brute="python3 ~/hacking-toolkit/web-attack/brute_forcer.py"
alias hkt-c2="python3 ~/hacking-toolkit/post-exploit/c2_server.py"
EOF

    print_success "Aliases added to ${SHELL_RC}"
}

display_completion() {
    print_success "Installation complete!"
    
    echo ""
    echo "========================================="
    echo "  PYTHON FOR HACKERS - LAB ENVIRONMENT"
    echo "========================================="
    echo ""
    echo "📁 Installation Directory: ${INSTALL_DIR}"
    echo "🐍 Virtual Environment: ${VENV_DIR}"
    echo ""
    echo "To get started:"
    echo "  1. cd ~/hacking-toolkit"
    echo "  2. source venv/bin/activate"
    echo "  3. python3 verify.py"
    echo ""
    echo "Available Aliases:"
    echo "  hkt - Go to hacking-toolkit directory"
    echo "  hkt-activate - Activate virtual environment"
    echo "  hkt-scan - Run port scanner"
    echo "  hkt-brute - Run directory brute-forcer"
    echo "  hkt-c2 - Start C2 server"
    echo ""
    echo "📚 Next Steps:"
    echo "  1. Review the configuration in config/config.yaml"
    echo "  2. Set up target VMs for practice"
    echo "  3. Start with Phase 1, Part 1 of the series"
    echo ""
    echo "⚠️  Remember: Only use these tools on systems you own"
    echo "   or have explicit permission to test!"
    echo "========================================="
}

main() {
    echo "========================================="
    echo "  PYTHON FOR HACKERS - INSTALLATION"
    echo "========================================="
    echo ""
    
    check_prerequisites
    create_directory_structure
    setup_virtual_environment
    install_dependencies
    create_config_files
    setup_wordlists
    create_verification_script
    setup_aliases
    
    # Log completion
    log_message "Installation completed successfully"
    
    display_completion
}

# Run main function
main "$@"
```

---

## Manual Installation Guide

### Step-by-Step Installation

#### 1. Clone or Create Project Directory

```bash
# Create directory structure
mkdir -p ~/hacking-toolkit
cd ~/hacking-toolkit

# Create subdirectories
mkdir -p {recon,web-attack,exploit,post-exploit,framework,payloads,config,modules,utils,templates,logs,data,wordlists,certs,reports}
```

#### 2. Setup Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate     # Windows

# Upgrade pip
pip install --upgrade pip
```

#### 3. Install Core Dependencies

```bash
# Install base packages
pip install requests scapy beautifulsoup4 lxml flask psutil cryptography pyyaml

# Install optional packages
pip install pyinstaller pytest black colorama rich

# Install platform-specific packages
# Linux
sudo apt install python3-scapy

# Windows
pip install pywin32 wmi

# macOS
brew install scapy
```

#### 4. Create Configuration

```bash
# Create config directory
mkdir -p config

# Create main config
cat > config/config.yaml << 'EOF'
network:
  default_target: "192.168.100.20"
  timeout: 5

scanning:
  max_threads: 50
  scan_timeout: 2

web:
  user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  timeout: 10

logging:
  level: "INFO"
  file: "logs/toolkit.log"
EOF
```

#### 5. Verify Installation

```bash
# Run verification
python3 -c "
import sys
import requests
import scapy
import bs4
import flask
import psutil

print('✅ All core packages imported successfully')
print(f'Python: {sys.version}')
"
```

---

## Docker Deployment

### Dockerfile

#### File: `~/hacking-toolkit/Dockerfile`

```dockerfile
# Dockerfile for Python for Hackers Toolkit
FROM python:3.10-slim

LABEL maintainer="PythonForHackers"
LABEL description="Complete Hacking Toolkit Environment"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tcpdump \
    nmap \
    net-tools \
    iputils-ping \
    curl \
    wget \
    vim \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Create directory structure
RUN mkdir -p recon web-attack exploit post-exploit framework payloads config modules utils templates logs data

# Copy requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Expose ports
EXPOSE 8443 53 8080

# Default command
CMD ["python3", "-c", "print('Python for Hackers Toolkit ready!')"]
```

### Docker Compose

#### File: `~/hacking-toolkit/docker-compose.yml`

```yaml
version: '3.8'

services:
  toolkit:
    build: .
    container_name: python-hackers-toolkit
    volumes:
      - ./:/app
      - ./logs:/app/logs
      - ./reports:/app/reports
      - ./data:/app/data
    ports:
      - "8443:8443"
      - "8080:8080"
    environment:
      - PYTHONPATH=/app
      - LOG_LEVEL=INFO
    networks:
      - hacking-net
    cap_add:
      - NET_RAW
      - NET_ADMIN
    command: /bin/bash

  target:
    image: vulnerables/web-dvwa
    container_name: dvwa-target
    ports:
      - "80:80"
    networks:
      - hacking-net

  c2-server:
    build: .
    container_name: c2-server
    volumes:
      - ./post-exploit:/app/post-exploit
    ports:
      - "8443:8443"
    environment:
      - C2_HOST=0.0.0.0
      - C2_PORT=8443
    networks:
      - hacking-net
    command: python3 post-exploit/c2_server.py

networks:
  hacking-net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.100.0/24
```

### Build and Run Docker

```bash
# Build the Docker image
docker build -t python-hackers-toolkit .

# Run with Docker Compose
docker-compose up -d

# Enter the container
docker exec -it python-hackers-toolkit /bin/bash

# Run verification
python3 verify.py
```

---

## Virtual Machine Configuration

### Vagrant Setup

#### File: `~/hacking-toolkit/Vagrantfile`

```ruby
# Vagrantfile for Python for Hackers Lab
Vagrant.configure("2") do |config|
  # Attacker VM - Kali Linux
  config.vm.define "attacker" do |attacker|
    attacker.vm.box = "kalilinux/rolling"
    attacker.vm.hostname = "attacker"
    attacker.vm.network "private_network", ip: "192.168.100.10"
    attacker.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
    attacker.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y python3 python3-pip python3-venv git
    SHELL
  end

  # Target VM - Ubuntu
  config.vm.define "target" do |target|
    target.vm.box = "ubuntu/jammy64"
    target.vm.hostname = "target"
    target.vm.network "private_network", ip: "192.168.100.20"
    target.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 1
    end
    target.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y apache2 mysql-server openssh-server phpmyadmin
      systemctl enable apache2 mysql
      systemctl start apache2 mysql
    SHELL
  end

  # Windows Target (optional)
  config.vm.define "windows", autostart: false do |windows|
    windows.vm.box = "gusztavvargadr/windows-10"
    windows.vm.hostname = "windows-target"
    windows.vm.network "private_network", ip: "192.168.100.30"
    windows.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
  end
end
```

### Start VMs with Vagrant

```bash
# Start all VMs
vagrant up

# Start specific VM
vagrant up attacker
vagrant up target

# SSH into VM
vagrant ssh attacker
vagrant ssh target

# Provision the toolkit on attacker
vagrant ssh attacker -c "cd /vagrant && bash install.sh"
```

### Manual VM Setup

#### Kali Linux (Attacker)

```bash
# Download Kali
wget https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-installer-amd64.iso

# Install in VirtualBox
# - RAM: 4GB
# - CPU: 2 cores
# - Storage: 40GB
# - Network: Host-Only + NAT

# After installation, install toolkit
cd /home/kali
git clone https://github.com/your-repo/hacking-toolkit.git
cd hacking-toolkit
bash install.sh
```

#### Ubuntu Server (Target)

```bash
# Download Ubuntu Server
wget https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso

# Install in VirtualBox
# - RAM: 2GB
# - CPU: 1 core
# - Storage: 20GB
# - Network: Host-Only

# Install vulnerable services
sudo apt update
sudo apt install -y apache2 mysql-server openssh-server phpmyadmin vsftpd

# Create test users
sudo useradd -m -s /bin/bash testuser
echo "testuser:password123" | sudo chpasswd

# Start services
sudo systemctl start apache2 mysql ssh vsftpd
sudo systemctl enable apache2 mysql ssh vsftpd

# Install vulnerable web app
sudo apt install -y git
git clone https://github.com/digininja/DVWA.git /var/www/html/dvwa
sudo chown -R www-data:www-data /var/www/html/dvwa
```

---

## Network Configuration

### Host-Only Network Setup

#### VirtualBox

```bash
# Create host-only network
# File -> Tools -> Network Manager -> Host-only Networks -> Create

# Configure network
# Name: vboxnet0
# IPv4 Address: 192.168.100.1
# IPv4 Network Mask: 255.255.255.0
# DHCP Server: Disabled

# Configure VMs
# VM Settings -> Network -> Adapter 2 -> Host-only Adapter -> vboxnet0
```

#### VM Network Configuration

##### Kali Linux

```bash
# Configure static IP
sudo ip addr add 192.168.100.10/24 dev eth1
sudo ip link set eth1 up

# Make persistent
cat >> /etc/network/interfaces << EOF
auto eth1
iface eth1 inet static
    address 192.168.100.10
    netmask 255.255.255.0
EOF

# Test connectivity
ping -c 4 192.168.100.20
```

##### Ubuntu Target

```bash
# Configure static IP
sudo ip addr add 192.168.100.20/24 dev enp0s8
sudo ip link set enp0s8 up

# Make persistent
cat >> /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s8:
      addresses:
        - 192.168.100.20/24
EOF

sudo netplan apply

# Test connectivity
ping -c 4 192.168.100.10
```

### Network Verification

```bash
# From Attacker VM
nmap -sn 192.168.100.0/24
ping -c 4 192.168.100.20

# From Target VM
ping -c 4 192.168.100.10

# Check routing
route -n
ip route show
```

---

## Verification & Testing

### Environment Verification

```bash
# Run the verification script
cd ~/hacking-toolkit
python3 verify.py

# Expected output:
# === Verification ===
# ✓ Python 3.10+: 3.10.12
# ✓ All packages found
# ✓ All directories exist
# ✓ Configuration file
# ✅ Verification complete
```

### Connectivity Test

```python
# Test network connectivity
cat > test_network.py << 'EOF'
import socket
import subprocess

def test_connectivity():
    targets = ['192.168.100.20', '8.8.8.8']
    
    for target in targets:
        try:
            result = subprocess.run(['ping', '-c', '2', target], capture_output=True)
            if result.returncode == 0:
                print(f"✅ {target} is reachable")
            else:
                print(f"❌ {target} is not reachable")
        except:
            print(f"❌ Failed to ping {target}")

if __name__ == "__main__":
    test_connectivity()
EOF

python3 test_network.py
```

### Port Scanner Test

```bash
# Test port scanner
cd recon
python3 port_scanner.py 192.168.100.20 -p 22,80,443,3306

# Expected output:
# [+] Port 22 is OPEN - ssh
# [+] Port 80 is OPEN - http
# [+] Port 3306 is OPEN - mysql
```

### Web Reconnaissance Test

```bash
# Test web reconnaissance
cd web-attack
python3 brute_forcer.py http://192.168.100.20 -w common -t 20
```

---

## Common Issues & Solutions

### Installation Issues

#### Issue: Python Version Too Old

```bash
# Ubuntu/Debian
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.10 python3.10-venv python3.10-dev

# CentOS/RHEL
sudo yum install centos-release-scl
sudo yum install rh-python38
scl enable rh-python38 bash

# macOS
brew install python@3.10
```

#### Issue: Pip Not Found

```bash
# Install pip
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py

# Or via package manager
sudo apt install python3-pip        # Debian/Ubuntu
sudo yum install python3-pip        # CentOS/RHEL
brew install pip                     # macOS
```

#### Issue: Virtual Environment Not Activating

```bash
# Linux/macOS
source venv/bin/activate

# Windows
venv\Scripts\activate

# PowerShell
venv\Scripts\Activate.ps1
```

### Network Issues

#### Issue: VMs Can't Communicate

```bash
# Check network configuration
ip addr show

# Check VM network settings in VirtualBox
# Verify host-only adapter is enabled

# Add static routes if needed
sudo ip route add 192.168.100.0/24 dev eth1

# Disable firewall
sudo ufw disable          # Ubuntu
sudo systemctl stop firewalld  # CentOS
```

#### Issue: Port Scanning Not Working

```bash
# Check if target services are running
sudo systemctl status apache2
sudo systemctl status mysql
sudo systemctl status ssh

# Check firewall on target
sudo iptables -L
sudo ufw status

# Open ports if needed
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
```

### Package Issues

#### Issue: Scapy Not Working

```bash
# Install Scapy dependencies
sudo apt install python3-scapy  # Ubuntu/Debian
pip install scapy  # If not available

# Test Scapy
python3 -c "from scapy.all import *; print('Scapy loaded')"
```

#### Issue: PIL/Pillow Not Installing

```bash
# Install system dependencies
sudo apt install libjpeg-dev zlib1g-dev

# Install Pillow
pip install Pillow --no-cache-dir
```

### Docker Issues

#### Issue: Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again
# Or run with sudo
sudo docker run ...
```

#### Issue: Port Already in Use

```bash
# Check what's using the port
sudo lsof -i :8443
sudo netstat -tulpn | grep 8443

# Stop the process or use different port
```

### Troubleshooting Checklist

- [ ] Verify Python version: `python3 --version`
- [ ] Check virtual environment: `which python3`
- [ ] Test network connectivity: `ping 192.168.100.20`
- [ ] Check services on target: `curl http://192.168.100.20`
- [ ] Verify package installation: `pip list | grep requests`
- [ ] Check configuration: `cat config/config.yaml`
- [ ] Test with verification script: `python3 verify.py`

### Quick Recovery

```bash
# Reset everything
cd ~/hacking-toolkit
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 verify.py
```

---

## Appendix B Complete

*This appendix provides everything needed to set up the complete lab environment, from scratch installation to Docker deployment and troubleshooting. Use these instructions to ensure your environment is properly configured before starting the tutorials.*

---

**[APPENDIX B COMPLETE]**
