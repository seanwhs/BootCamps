# Appendix D: Complete File Index & Code Reference

## Comprehensive Directory Structure and Code Index

This appendix provides a complete listing of all files created throughout the Python for Hackers series, organized by module, with descriptions and key features.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Phase 1: Network Foundation](#phase-1-network-foundation)
3. [Phase 2: Web Reconnaissance](#phase-2-web-reconnaissance)
4. [Phase 3: Offensive Tooling](#phase-3-offensive-tooling)
5. [Phase 4: Post-Exploitation](#phase-4-post-exploitation)
6. [Core Framework Files](#core-framework-files)
7. [Configuration Files](#configuration-files)
8. [Utility Files](#utility-files)
9. [Wordlists](#wordlists)
10. [File Size & Complexity Metrics](#file-size--complexity-metrics)

---

## Project Overview

### Complete Directory Tree

```
~/hacking-toolkit/
│
├── README.md
├── requirements.txt
├── setup_lab.sh
├── verify_setup.py
├── install.sh
├── Dockerfile
├── docker-compose.yml
├── Vagrantfile
│
├── config/
│   └── config.yaml
│
├── framework/
│   └── __init__.py
│
├── utils/
│   ├── __init__.py
│   ├── logger.py
│   └── config.py
│
├── recon/
│   ├── __init__.py
│   ├── tcp_server.py
│   ├── tcp_client.py
│   ├── udp_server.py
│   ├── udp_client.py
│   ├── sniffer.py
│   ├── port_scanner.py
│   ├── quick_scan.py
│   ├── packet_crafter.py
│   └── network_relay.py
│
├── web-attack/
│   ├── __init__.py
│   ├── http_client.py
│   ├── brute_forcer.py
│   ├── wordlist_generator.py
│   ├── html_analyzer.py
│   └── auth_automation.py
│
├── exploit/
│   ├── __init__.py
│   ├── api_client.py
│   ├── exploit_framework.py
│   ├── obfuscator.py
│   └── exfiltration.py
│
├── post-exploit/
│   ├── __init__.py
│   ├── c2_server.py
│   ├── c2_agent.py
│   ├── enumerator.py
│   ├── persistence.py
│   └── packager.py
│
├── payloads/
│   └── (generated payloads)
│
├── modules/
│   └── __init__.py
│
├── templates/
│   └── (report templates)
│
├── wordlists/
│   ├── common.txt
│   ├── admin.txt
│   └── backup.txt
│
├── logs/
│   └── toolkit.log
│
├── data/
│   └── (generated data)
│
└── certs/
    └── (SSL certificates)
```

---

## Phase 1: Network Foundation

### recon/tcp_server.py - TCP Echo Server

**Purpose:** Multi-threaded TCP echo server for testing socket programming

**Key Features:**
- Multi-threaded client handling
- TCP connection management
- Echo functionality
- Connection logging

**Key Classes:**
```python
class TCPEchoServer:
    - start()
    - handle_client()
    - stop()
```

**Dependencies:** socket, threading

---

### recon/tcp_client.py - TCP Client

**Purpose:** Interactive TCP client for testing the echo server

**Key Features:**
- Interactive mode
- Automated test mode
- Connection management
- Message sending/receiving

**Key Classes:**
```python
class TCPEchoClient:
    - connect()
    - send_message()
    - disconnect()
```

---

### recon/udp_server.py - UDP Echo Server

**Purpose:** UDP echo server for connectionless communication

**Key Features:**
- UDP datagram handling
- Connectionless communication
- Echo functionality

**Key Classes:**
```python
class UDPEchoServer:
    - start()
    - stop()
```

---

### recon/udp_client.py - UDP Client

**Purpose:** UDP client with stress testing capabilities

**Key Features:**
- Interactive mode
- Stress testing
- Packet loss detection

**Key Classes:**
```python
class UDPEchoClient:
    - send_datagram()
    - close()
```

---

### recon/sniffer.py - Packet Sniffer

**Purpose:** Raw packet sniffer for network analysis

**Key Features:**
- Raw socket capture
- Packet parsing (Ethernet, IP, TCP, UDP)
- Protocol identification
- Real-time display

**Key Classes:**
```python
class PacketSniffer:
    - start()
    - parse_packet()
    - parse_tcp()
    - parse_udp()
```

**Requirements:** Root privileges

---

### recon/port_scanner.py - TCP Port Scanner

**Purpose:** Multi-threaded TCP port scanner with banner grabbing

**Key Features:**
- Multi-threaded scanning
- Banner grabbing
- Service identification
- Progress tracking
- Result filtering
- JSON/CSV output

**Key Classes:**
```python
class PortScanner:
    - scan_port()
    - _grab_banner()
    - _identify_service()
    - _worker()
    - scan()
    - print_results()
    - save_results()
```

**Dependencies:** socket, threading, queue, ipaddress, colorama

**Command Line Usage:**
```bash
python3 port_scanner.py 192.168.1.1 -p 22,80,443 -t 50 -T 2.0
```

---

### recon/quick_scan.py - Quick Scan Wrapper

**Purpose:** Preset scanning for common service groups

**Key Features:**
- Predefined port groups
- Quick execution
- Wrapper for port_scanner.py

**Presets:**
- web: 80,443,8080,8443,3000,5000,8000
- database: 3306,5432,6379,27017,1433,1521,9200
- common: 21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5432,5900,6379,8080,8443
- all: 1-65535

---

### recon/packet_crafter.py - Packet Crafting Framework

**Purpose:** Advanced packet crafting with Scapy

**Key Features:**
- IP/TCP/UDP/ICMP packet creation
- Packet sniffing and analysis
- TCP connect scanning
- Traceroute
- Port knocking
- Packet saving/loading

**Key Classes:**
```python
class PacketCrafter:
    - create_ip_packet()
    - create_tcp_packet()
    - create_udp_packet()
    - create_icmp_packet()
    - craft_packet()
    - send_packet()
    - send_and_receive()
    - sniff_packets()
    - analyze_packet()
    - save_packets()
    - load_packets()

class AdvancedPacketTools(PacketCrafter):
    - arp_spoof()
    - dns_spoof()
    - tcp_connect_scan()
    - traceroute()
    - port_knocking()
```

**Dependencies:** scapy

---

### recon/network_relay.py - Network Relay/Proxy

**Purpose:** TCP/UDP relay for traffic interception

**Key Features:**
- Bidirectional traffic forwarding
- Request/response modification
- HTTP traffic logging
- Custom callback support

**Key Classes:**
```python
class NetworkRelay:
    - start()
    - _handle_connection()
    - _forward_data()
    - set_modify_callback()
    - set_log_callback()
    - stop()
```

**HTTP Modification Example:**
```python
def http_modify(data):
    # Add X-Forwarded-For header
    return modified_data
```

---

## Phase 2: Web Reconnaissance

### web-attack/http_client.py - HTTP Client Framework

**Purpose:** Advanced HTTP client with session management

**Key Features:**
- Session management
- Authentication (Basic, Bearer, API Key)
- Retry logic
- Request/response logging
- Redirect following
- Request history

**Key Classes:**
```python
class HTTPClient:
    - set_header()
    - set_cookie()
    - set_auth_basic()
    - set_auth_bearer()
    - set_auth_api_key()
    - request()
    - get()
    - post()
    - put()
    - delete()
    - head()
    - options()
    - patch()
    - follow_redirects()
    - parse_response()
    - get_stats()

class WebRecon(HTTPClient):
    - analyze_headers()
    - discover_parameters()
    - discover_links()
    - check_common_paths()
    - spider()
```

**Dependencies:** requests

---

### web-attack/brute_forcer.py - Directory Brute-Forcer

**Purpose:** Concurrent directory and file enumeration

**Key Features:**
- Multi-threading
- Wordlist management
- File extension testing
- Recursive scanning
- Status code filtering
- Result sorting
- Banner grabbing

**Key Classes:**
```python
class DirectoryBruteForcer:
    - _generate_paths()
    - _check_path()
    - _process_results()
    - _worker()
    - scan()
    - print_results()
    - save_results()

class WordlistManager:
    - get_wordlist()
    - list_wordlists()
    - load_from_file()
    - create_wordlist()
```

**Dependencies:** http_client, requests

**Command Line Usage:**
```bash
python3 brute_forcer.py https://example.com -w common -e .php,.html -t 50 -r
```

---

### web-attack/wordlist_generator.py - Wordlist Generator

**Purpose:** Generate custom wordlists for brute forcing

**Key Features:**
- Permutations
- Year variations
- Technology-specific paths
- Common backup patterns
- API path generation

**Key Classes:**
```python
class WordlistGenerator:
    - add_base_words()
    - generate_permutations()
    - generate_year_variations()
    - generate_number_variations()
    - generate_common_names()
    - generate_technology_specific()
    - generate_common_backups()
    - generate_api_paths()
    - generate_all()
    - save_wordlist()
```

**Command Line Usage:**
```bash
python3 wordlist_generator.py
```

---

### web-attack/html_analyzer.py - HTML Analysis Framework

**Purpose:** Parse and analyze HTML for security reconnaissance

**Key Features:**
- Meta data extraction
- Form analysis
- Link discovery
- Script/stylesheet analysis
- Comment extraction
- Email/phone extraction
- Sensitive data detection
- Vulnerability indicators
- Website crawling

**Key Classes:**
```python
class HTMLAnalyzer:
    - analyze_url()
    - analyze_html()
    - _extract_meta()
    - _extract_forms()
    - _extract_links()
    - _extract_scripts()
    - _extract_styles()
    - _extract_images()
    - _extract_comments()
    - _extract_iframes()
    - _extract_csp()
    - _extract_endpoints()
    - _find_emails()
    - _find_phone_numbers()
    - _find_sensitive()
    - _find_vulnerabilities()

class WebContentScanner(HTMLAnalyzer):
    - scan_site()
    - generate_report()
```

**Dependencies:** beautifulsoup4, lxml, http_client

---

### web-attack/auth_automation.py - Authentication Framework

**Purpose:** Automated authentication and session management

**Key Features:**
- CSRF token extraction
- Form login
- JWT token login
- API key authentication
- OAuth 2.0 login
- Session persistence
- Credential testing
- Brute force

**Key Classes:**
```python
class AuthAutomation:
    - extract_csrf_token()
    - extract_login_form()
    - login_basic()
    - login_jwt()
    - login_api_key()
    - login_oauth()
    - apply_session()
    - logout()
    - test_credentials()
    - load_credentials_from_file()

class LoginBruteforcer(AuthAutomation):
    - brute_force()
    - intelligent_bruteforce()
```

**Dependencies:** http_client, html_analyzer

**Command Line Usage:**
```bash
python3 auth_automation.py --login https://example.com/login -u admin -p password123
```

---

## Phase 3: Offensive Tooling

### exploit/api_client.py - API Interaction Framework

**Purpose:** REST and GraphQL API interaction with intelligence gathering

**Key Features:**
- REST API support (GET, POST, PUT, DELETE, PATCH)
- GraphQL queries and introspection
- Rate limit handling
- Response analysis
- Endpoint discovery (Swagger/OpenAPI)
- Resource brute forcing
- Data parsing

**Key Classes:**
```python
class APIClient:
    - rest_request()
    - get()
    - post()
    - put()
    - delete()
    - patch()
    - graphql_query()
    - graphql_introspection()
    - discover_endpoints_from_swagger()
    - discover_resources()
    - analyze_response()

class APIIntelligence(APIClient):
    - gather_intelligence()
    - test_auth_requirements()
    - analyze_exposed_data()

class DataParser:
    - parse_json()
    - parse_xml()
    - flatten_dict()
    - extract_ips()
    - extract_urls()
    - extract_emails()
```

**Dependencies:** http_client, requests

---

### exploit/exploit_framework.py - Exploit Development Framework

**Purpose:** Modular exploit development and testing framework

**Key Features:**
- SQL Injection testing
- Command Injection testing
- Remote File Inclusion testing
- Authentication bypass testing
- Exploit chaining
- Result tracking

**Key Classes:**
```python
class Exploit:
    - exploit()
    - test()
    - get_info()

class SQLInjectionExploit(Exploit):
    - exploit()
    - _build_request()
    - _is_vulnerable()

class CommandInjectionExploit(Exploit):
    - exploit()
    - _build_request()
    - _is_vulnerable()

class RemoteFileInclusionExploit(Exploit):
    - exploit()

class AuthenticationBypassExploit(Exploit):
    - exploit()

class ExploitManager:
    - add_exploit()
    - run_all()
    - get_vulnerabilities()
    - get_report()
```

**Dependencies:** http_client

---

### exploit/obfuscator.py - Obfuscation Engine

**Purpose:** Payload obfuscation and evasion techniques

**Key Features:**
- Base64 encoding
- Hex encoding
- XOR encoding
- ROT13/Caesar cipher
- URL/HTML/Unicode encoding
- String reversal
- Zlib compression
- Multi-layer encoding
- Payload generation

**Key Classes:**
```python
class ObfuscationEngine:
    - encode_base64()
    - encode_hex()
    - encode_xor()
    - encode_rot13()
    - encode_url()
    - encode_html()
    - encode_unicode()
    - encode_reverse()
    - encode_compress()
    - encode_caesar()
    - multi_encode()
    - multi_decode()

class PayloadGenerator(ObfuscationEngine):
    - generate_payload()
    - generate_sql_payloads()
    - generate_xss_payloads()
    - generate_file_inclusion_payloads()
    - generate_reverse_shell_payloads()
```

**Dependencies:** None (standard library)

---

### exploit/exfiltration.py - Data Exfiltration Framework

**Purpose:** Covert data extraction over multiple channels

**Key Features:**
- HTTP exfiltration (GET/POST)
- DNS exfiltration
- ICMP exfiltration
- Steganography (LSB image hiding)
- Multi-channel support
- File exfiltration
- Tunneling protocols

**Key Classes:**
```python
class ExfiltrationBase:
    - start()
    - stop()
    - send_data()

class HTTPExfiltration(ExfiltrationBase):
    - _send()

class DNSExfiltration(ExfiltrationBase):
    - _send()

class ICMPExfiltration(ExfiltrationBase):
    - _send()
    - _create_icmp_packet()

class SteganographyExfiltration(ExfiltrationBase):
    - _send()
    - _bytes_to_bits()

class ExfiltrationManager:
    - add_channel()
    - start_channel()
    - stop_channel()
    - send_data()
    - send_data_all()
    - exfiltrate_file()
    - get_status()

class TunnelProtocol:
    - http_tunnel()
    - dns_tunnel()
    - icmp_tunnel()
```

**Dependencies:** requests, Pillow (optional)

---

## Phase 4: Post-Exploitation

### post-exploit/c2_server.py - C2 Server

**Purpose:** Command and Control server framework

**Key Features:**
- HTTP REST API
- SQLite database persistence
- Agent registration
- Task management
- Result collection
- Multi-agent support

**Key Classes:**
```python
class C2Server:
    - register_agent()
    - add_task()
    - get_tasks()
    - submit_result()
    - get_agent_info()
    - list_agents()
    - start_http_server()
    - start()
    - stop()
```

**Dependencies:** flask, sqlite3

**API Endpoints:**
- POST /c2/register
- GET /c2/tasks/<agent_id>
- POST /c2/result
- GET /c2/agents
- GET /c2/agent/<agent_id>
- POST /c2/task
- GET /c2/results/<agent_id>

---

### post-exploit/c2_agent.py - C2 Agent

**Purpose:** C2 agent that communicates with server

**Key Features:**
- Registration
- Task execution
- Result submission
- Beacon/heartbeat
- Command execution

**Key Classes:**
```python
class C2Agent:
    - register()
    - get_tasks()
    - submit_result()
    - execute_task()
    - beacon()
    - heartbeat()
    - start()
```

**Built-in Commands:**
- whoami, hostname, platform, ip, info
- ls, who, system, download
- sleep, beacon, exit

---

### post-exploit/enumerator.py - System Enumeration

**Purpose:** Automated system information gathering

**Key Features:**
- System information (OS, CPU, memory, disk)
- Network interfaces
- User enumeration
- Process analysis
- Service discovery
- Cron/scheduled tasks
- Environment variables
- File system scanning
- Security information
- Cross-platform support

**Key Classes:**
```python
class SystemEnumerator:
    - get_system_info()
    - get_network_info()
    - get_users()
    - get_processes()
    - get_services()
    - get_cron_jobs()
    - get_environment()
    - get_file_system_info()
    - get_security_info()
    - enumerate_all()
    - save_report()
```

**Dependencies:** psutil, platform, subprocess

---

### post-exploit/persistence.py - Persistence Management

**Purpose:** Automated persistence installation and cleanup

**Key Features:**
- Startup scripts (Windows/Linux)
- Cron jobs (Linux)
- Scheduled tasks (Windows)
- Registry entries (Windows)
- System services (Windows/Linux)
- Installation/cleanup

**Key Classes:**
```python
class PersistenceManager:
    - install_payload()
    - add_startup_script()
    - add_cron_job()
    - add_scheduled_task()
    - add_registry_entry()
    - add_service()
    - add_all_persistence()
    - cleanup()
    - get_status()

class ReportGenerator:
    - log_event()
    - add_data()
    - generate_report()
```

**Dependencies:** os, platform, subprocess

---

### post-exploit/packager.py - Packaging Framework

**Purpose:** Build standalone executables from Python scripts

**Key Features:**
- PyInstaller integration
- cx_Freeze integration
- Nuitka integration
- UPX compression
- Windows signing
- Cross-platform support

**Key Classes:**
```python
class PackageBuilder:
    - build_pyinstaller()
    - build_cx_freeze()
    - build_nuitka()
    - build_all()
    - sign_executable()
    - compress_executable()
    - cleanup()
```

**Dependencies:** PyInstaller (optional), cx_Freeze (optional), Nuitka (optional)

---

## Core Framework Files

### framework/__init__.py

```python
# Core framework initialization
__version__ = '1.0.0'
__author__ = 'Python for Hackers'
```

---

## Configuration Files

### config/config.yaml

```yaml
# Main configuration file
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
```

---

## Utility Files

### utils/logger.py

```python
# Centralized logging utility
class ToolkitLogger:
    - get_logger()
    - debug(), info(), warning(), error(), critical()
```

### utils/config.py

```python
# Configuration management
class Config:
    - load()
    - get()
    - _create_default_config()
```

---

## Wordlists

### wordlists/common.txt

```
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
```

### wordlists/admin.txt

```
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
```

### wordlists/backup.txt

```
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
```

---

## File Size & Complexity Metrics

### Module Comparison

| Module | Files | Lines of Code | Dependencies |
|--------|-------|---------------|--------------|
| **Network Foundation** | 9 | 2,500+ | socket, threading, scapy |
| **Web Reconnaissance** | 5 | 2,800+ | requests, bs4, lxml |
| **Offensive Tooling** | 4 | 3,200+ | requests, pillow, flask |
| **Post-Exploitation** | 5 | 3,000+ | psutil, flask, pyinstaller |
| **Utilities** | 2 | 500+ | yaml, logging |
| **Configuration** | 1 | 100+ | yaml |
| **TOTAL** | **26** | **12,100+** | **15+ packages** |

### Complexity Breakdown

```
Complexity Categories:
├── High Complexity: >500 lines
│   ├── exploit_framework.py (800+)
│   ├── obfuscator.py (700+)
│   ├── c2_server.py (650+)
│   ├── exfiltration.py (600+)
│   └── port_scanner.py (550+)
│
├── Medium Complexity: 200-500 lines
│   ├── http_client.py (450+)
│   ├── brute_forcer.py (420+)
│   ├── html_analyzer.py (400+)
│   ├── api_client.py (380+)
│   ├── enumerator.py (360+)
│   ├── auth_automation.py (340+)
│   ├── persistence.py (320+)
│   ├── packager.py (300+)
│   └── packet_crafter.py (280+)
│
└── Low Complexity: <200 lines
    ├── tcp_server.py (180+)
    ├── tcp_client.py (160+)
    ├── udp_server.py (120+)
    ├── udp_client.py (140+)
    ├── sniffer.py (150+)
    ├── quick_scan.py (100+)
    ├── network_relay.py (180+)
    ├── c2_agent.py (190+)
    ├── wordlist_generator.py (160+)
    └── utils/*.py (250+)
```

### Dependency Graph

```
┌─────────────────────────────────────────────────────────┐
│                    Core Dependencies                    │
├─────────────────────────────────────────────────────────┤
│ socket → TCP/UDP networking                            │
│ threading → Concurrent operations                      │
│ requests → HTTP client                                 │
│ scapy → Packet manipulation                            │
│ beautifulsoup4 → HTML parsing                          │
│ lxml → Fast XML/HTML parsing                           │
│ flask → HTTP C2 server                                 │
│ psutil → System information                            │
│ cryptography → Encryption/decryption                   │
│ pyyaml → Configuration parsing                         │
├─────────────────────────────────────────────────────────┤
│                  Optional Dependencies                  │
├─────────────────────────────────────────────────────────┤
│ pillow → Image steganography                           │
│ pywin32 → Windows API access                           │
│ wmi → Windows Management Instrumentation               │
│ pyinstaller → Executable packaging                     │
│ cx_freeze → Executable packaging                       │
│ nuitka → Executable packaging                          │
│ selenium → Browser automation                          │
└─────────────────────────────────────────────────────────┘
```

### Module Dependencies

```
recon/
├── tcp_server.py → socket, threading
├── tcp_client.py → socket
├── udp_server.py → socket
├── udp_client.py → socket
├── sniffer.py → socket, struct
├── port_scanner.py → socket, threading, queue
├── quick_scan.py → subprocess
├── packet_crafter.py → scapy, socket
└── network_relay.py → socket, threading

web-attack/
├── http_client.py → requests
├── brute_forcer.py → http_client, threading
├── wordlist_generator.py → None
├── html_analyzer.py → bs4, lxml, http_client
└── auth_automation.py → http_client, html_analyzer

exploit/
├── api_client.py → http_client
├── exploit_framework.py → http_client
├── obfuscator.py → base64, binascii, zlib
└── exfiltration.py → requests, PIL(optional)

post-exploit/
├── c2_server.py → flask, sqlite3
├── c2_agent.py → requests
├── enumerator.py → psutil, platform
├── persistence.py → os, platform, subprocess
└── packager.py → pyinstaller(optional), cx_freeze(optional)
```

---

## Quick Reference: Common Import Patterns

### Core Imports

```python
# Network
import socket
import threading
from scapy.all import *

# HTTP
import requests
from flask import Flask, request, jsonify

# Parsing
from bs4 import BeautifulSoup
import json
import yaml

# System
import os
import sys
import platform
import subprocess

# Utilities
import time
import re
import base64
import hashlib
from datetime import datetime

# Concurrency
import threading
import queue
from concurrent.futures import ThreadPoolExecutor
```

### Common Class Inheritance Patterns

```python
# HTTP Client Inheritance
class WebRecon(HTTPClient):
    pass

# Exploit Inheritance
class CustomExploit(Exploit):
    def exploit(self):
        pass

# Channel Inheritance
class CustomChannel(ExfiltrationBase):
    def _send(self, data):
        pass
```

---

## Appendix D Complete

*This appendix provides a complete reference to all files in the Python for Hackers series, including their purposes, dependencies, and complexity metrics. Use this as a quick reference for finding specific modules and understanding the overall structure.*

---

**[APPENDIX D COMPLETE]**
