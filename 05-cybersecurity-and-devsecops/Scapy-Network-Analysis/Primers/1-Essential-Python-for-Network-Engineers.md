# Mastering Network Packet Crafting with Scapy
## Primer 1: Essential Python for Network Engineers

## Overview

This primer provides a crash course in Python programming specifically tailored for network engineers and security professionals. If you're comfortable with Python, you can skip this section, but if you need a refresher or are new to Python, this primer will get you up to speed quickly.

---

## Table of Contents

1. [Why Python for Networking?](#why-python-for-networking)
2. [Python Basics](#python-basics)
3. [Data Structures](#data-structures)
4. [Control Flow](#control-flow)
5. [Functions](#functions)
6. [File I/O](#file-io)
7. [Exception Handling](#exception-handling)
8. [Working with Bytes](#working-with-bytes)
9. [Modules and Imports](#modules-and-imports)
10. [Virtual Environments](#virtual-environments)
11. [Common Libraries](#common-libraries)
12. [Python for Scapy](#python-for-scapy)
13. [Coding Best Practices](#coding-best-practices)

---

## Why Python for Networking?

Python is the language of choice for network automation and security because:

- **Readable syntax**: Easy to write and understand
- **Rich ecosystem**: Extensive libraries for networking (Scapy, netmiko, napalm)
- **Cross-platform**: Works on Windows, Linux, macOS
- **Rapid prototyping**: Quick to develop and iterate
- **Large community**: Extensive documentation and support

```python
# Simple network scanner in Python
import subprocess

def ping_host(ip):
    """Ping a host and return True if reachable."""
    result = subprocess.run(['ping', '-c', '1', ip], capture_output=True)
    return result.returncode == 0

# Scan a /24 network
for i in range(1, 255):
    ip = f"192.168.1.{i}"
    if ping_host(ip):
        print(f"{ip} is alive")
```

---

## Python Basics

### Variables and Data Types

```python
# Integers
port = 80
count = 10

# Floats
timeout = 3.5

# Strings
host = "192.168.1.100"
protocol = 'TCP'

# Booleans
is_open = True
is_closed = False

# None (null)
response = None

# Type checking
print(type(port))    # <class 'int'>
print(type(host))    # <class 'str'>
print(type(is_open)) # <class 'bool'>

# Type conversion
port_str = str(port)                    # "80"
port_int = int("80")                    # 80
ip_parts = "192.168.1.100".split('.')   # ['192', '168', '1', '100']
```

---

### Strings

```python
# String creation
name = "Scapy"
multi_line = """This is a
multi-line string"""

# String concatenation
full = "Hello" + " " + "World"

# String formatting
# Method 1: f-strings (Python 3.6+)
ip = "192.168.1.1"
print(f"Pinging {ip}")

# Method 2: format()
print("Pinging {}".format(ip))

# Method 3: % formatting
print("Pinging %s" % ip)

# String methods
text = " Hello, World! "
print(text.strip())       # "Hello, World!"
print(text.lower())       # " hello, world! "
print(text.upper())       # " HELLO, WORLD! "
print(text.startswith(" "))  # True
print(text.endswith("!"))    # True

# Splitting
ip = "192.168.1.100"
parts = ip.split('.')     # ['192', '168', '1', '100']
print(parts[0])           # "192"

# Joining
mac_parts = ['00', '11', '22', '33', '44', '55']
mac = ':'.join(mac_parts)  # "00:11:22:33:44:55"

# Finding substrings
if "192.168" in ip:
    print("Private IP")
```

---

### Numbers and Math

```python
# Basic arithmetic
a = 10
b = 3
print(a + b)   # 13
print(a - b)   # 7
print(a * b)   # 30
print(a / b)   # 3.333...
print(a // b)  # 3 (floor division)
print(a % b)   # 1 (modulus)
print(a ** b)  # 1000 (exponent)

# Bitwise operations (important for packet flags!)
flags = 0b00000000        # Binary literal
flags |= 0b00000010       # Set bit 1 (SYN)
flags |= 0b00010000       # Set bit 4 (ACK)
print(bin(flags))         # 0b10010

# Check if bit is set
if flags & 0b00000010:
    print("SYN flag is set")

# Hex operations
hex_value = 0x0800        # 2048 decimal
print(hex(port))          # "0x50"

# Random numbers
import random
random_port = random.randint(1024, 65535)
random_ip = f"{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(0,255)}"
```

---

## Data Structures

### Lists

```python
# Creating lists
ports = [80, 443, 22, 53]
empty = []

# Adding elements
ports.append(8080)           # [80, 443, 22, 53, 8080]
ports.insert(0, 21)          # [21, 80, 443, 22, 53, 8080]
ports.extend([25, 110])      # [21, 80, 443, 22, 53, 8080, 25, 110]

# Accessing elements
first = ports[0]             # 21
last = ports[-1]             # 110
slice = ports[1:4]           # [80, 443, 22]

# Removing elements
ports.remove(22)             # Remove by value
last = ports.pop()           # Remove and return last
first = ports.pop(0)         # Remove and return first

# List comprehension
squared = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]
even_numbers = [x for x in range(10) if x % 2 == 0]

# Iteration
for port in ports:
    print(port)

# Check membership
if 80 in ports:
    print("HTTP port found")
```

---

### Tuples

Tuples are immutable (cannot be changed after creation):

```python
# Creating tuples
endpoint = ("192.168.1.100", 80)  # (IP, port)
protocols = ("TCP", "UDP", "ICMP")

# Accessing elements
ip = endpoint[0]  # "192.168.1.100"
port = endpoint[1]  # 80

# Tuple unpacking
ip, port = endpoint

# When to use tuples:
# - Fixed collections
# - Dictionary keys
# - Return multiple values from functions
def get_interface_info():
    return ("eth0", "192.168.1.100", "00:11:22:33:44:55")

iface, ip, mac = get_interface_info()
```

---

### Dictionaries

Dictionaries store key-value pairs:

```python
# Creating dictionaries
host = {
    "ip": "192.168.1.100",
    "mac": "00:11:22:33:44:55",
    "ports": [22, 80, 443],
    "alive": True
}

# Accessing values
ip = host["ip"]
mac = host.get("mac")

# Adding/updating
host["hostname"] = "webserver"
host["alive"] = False

# Removing
del host["hostname"]
host.pop("alive", None)  # Remove with default

# Iteration
for key, value in host.items():
    print(f"{key}: {value}")

for key in host.keys():
    print(key)

for value in host.values():
    print(value)

# Dictionary comprehension
squares = {x: x**2 for x in range(5)}
# {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# Default dictionary (handy for counting)
from collections import defaultdict
protocol_counts = defaultdict(int)
protocol_counts["TCP"] += 1
protocol_counts["TCP"] += 1
protocol_counts["UDP"] += 1
print(protocol_counts)  # {'TCP': 2, 'UDP': 1}
```

---

### Sets

Sets store unique elements:

```python
# Creating sets
open_ports = {80, 443, 22}
filtered_ports = {80, 53}

# Adding/removing
open_ports.add(8080)
open_ports.remove(22)

# Set operations
all_ports = open_ports | filtered_ports           # Union
common_ports = open_ports & filtered_ports        # Intersection
unique_ports = open_ports - filtered_ports        # Difference

# Check membership
if 80 in open_ports:
    print("Port 80 is open")

# Set comprehension
even = {x for x in range(10) if x % 2 == 0}
```

---

## Control Flow

### If/Elif/Else

```python
# Basic if
port = 80
if port == 80:
    print("HTTP")
elif port == 443:
    print("HTTPS")
elif port == 22:
    print("SSH")
else:
    print(f"Unknown port: {port}")

# Multiple conditions
if port >= 1 and port <= 1024:
    print("Well-known port")
elif port >= 1025 and port <= 49151:
    print("Registered port")
else:
    print("Dynamic port")

# Truthy values
if []:      # Empty list = False
    print("This won't print")

if [1, 2]:  # Non-empty list = True
    print("This will print")

if "":      # Empty string = False
    print("This won't print")

if "hello": # Non-empty string = True
    print("This will print")

if 0:       # 0 = False
    print("This won't print")

if 1:       # Non-zero = True
    print("This will print")
```

---

### Loops

```python
# For loop - iterate over sequence
ports = [80, 443, 22, 53]
for port in ports:
    print(f"Port: {port}")

# For loop with range
for i in range(5):
    print(i)  # 0, 1, 2, 3, 4

for i in range(1, 10, 2):
    print(i)  # 1, 3, 5, 7, 9

# While loop
count = 0
while count < 5:
    print(count)
    count += 1

# Break and continue
for port in ports:
    if port == 22:
        continue  # Skip SSH
    if port == 53:
        break     # Stop at DNS
    print(port)

# Loop with enumerate (get index)
for i, port in enumerate(ports):
    print(f"{i}: {port}")

# Loop with zip (iterate multiple lists)
ips = ["192.168.1.1", "192.168.1.2", "192.168.1.3"]
ports = [80, 443, 22]
for ip, port in zip(ips, ports):
    print(f"{ip}:{port}")
```

---

## Functions

### Basic Functions

```python
# Simple function
def ping_ip(ip):
    """Ping an IP address."""
    print(f"Pinging {ip}")

# Function with parameters and return
def add(a, b):
    return a + b

result = add(5, 3)  # 8

# Default parameters
def connect(host, port=80):
    print(f"Connecting to {host}:{port}")

connect("192.168.1.1")          # Uses default port 80
connect("192.168.1.1", 443)     # Uses port 443

# Keyword arguments
connect(port=443, host="192.168.1.1")

# Variable number of arguments
def scan_ports(*ports):
    for port in ports:
        print(f"Scanning port {port}")

scan_ports(80, 443, 22, 53)

# Variable keyword arguments
def configure_interface(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

configure_interface(ip="192.168.1.100", netmask="255.255.255.0")

# Type hints (Python 3.5+)
def is_port_open(ip: str, port: int) -> bool:
    """Check if a port is open."""
    # Implementation would go here
    return True

# Docstrings (documentation)
def scan_network(network):
    """
    Scan a network for active hosts.
    
    Args:
        network (str): Network in CIDR notation (e.g., "192.168.1.0/24")
    
    Returns:
        list: List of active IP addresses
    """
    # Implementation...
    return []
```

---

### Lambda Functions

```python
# Simple lambda
square = lambda x: x ** 2
print(square(5))  # 25

# Lambda with map
numbers = [1, 2, 3, 4, 5]
squared = list(map(lambda x: x ** 2, numbers))
# [1, 4, 9, 16, 25]

# Lambda with filter
even = list(filter(lambda x: x % 2 == 0, numbers))
# [2, 4]

# Lambda with sorted
hosts = [
    {"ip": "192.168.1.2", "latency": 5},
    {"ip": "192.168.1.1", "latency": 2},
    {"ip": "192.168.1.3", "latency": 8}
]
sorted_hosts = sorted(hosts, key=lambda x: x["latency"])
```

---

## File I/O

### Reading Files

```python
# Read entire file
with open("hosts.txt", "r") as f:
    content = f.read()
    print(content)

# Read line by line
with open("hosts.txt", "r") as f:
    for line in f:
        line = line.strip()
        print(line)

# Read into list
with open("hosts.txt", "r") as f:
    hosts = f.readlines()
    hosts = [h.strip() for h in hosts]

# Handling PCAP files (with Scapy)
from scapy.all import rdpcap
packets = rdpcap("capture.pcap")
```

---

### Writing Files

```python
# Write entire content
with open("output.txt", "w") as f:
    f.write("Hello World\n")

# Write multiple lines
lines = ["192.168.1.1", "192.168.1.2", "192.168.1.3"]
with open("hosts.txt", "w") as f:
    for line in lines:
        f.write(line + "\n")

# Append to file
with open("hosts.txt", "a") as f:
    f.write("192.168.1.4\n")

# Write PCAP files (with Scapy)
from scapy.all import wrpcap
wrpcap("output.pcap", packets)
```

---

### JSON Files

```python
import json

# Write JSON
data = {
    "host": "192.168.1.100",
    "ports": [80, 443, 22],
    "services": {"HTTP": 80, "HTTPS": 443}
}

with open("scan_results.json", "w") as f:
    json.dump(data, f, indent=2)

# Read JSON
with open("scan_results.json", "r") as f:
    data = json.load(f)
    print(data["host"])
    print(data["ports"])
```

---

### CSV Files

```python
import csv

# Write CSV
rows = [
    ["IP", "MAC", "Status"],
    ["192.168.1.1", "00:11:22:33:44:55", "Active"],
    ["192.168.1.2", "66:77:88:99:aa:bb", "Active"]
]

with open("hosts.csv", "w", newline='') as f:
    writer = csv.writer(f)
    writer.writerows(rows)

# Read CSV
with open("hosts.csv", "r") as f:
    reader = csv.reader(f)
    for row in reader:
        print(row)

# CSV with headers (DictReader)
with open("hosts.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row["IP"], row["MAC"])
```

---

## Exception Handling

### Basic Exceptions

```python
# Try/Except
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")

# Multiple exceptions
try:
    port = int("abc")
    hosts = ["192.168.1.1", "192.168.1.2"]
    print(hosts[10])
except ValueError:
    print("Invalid port number")
except IndexError:
    print("Invalid index")
except Exception as e:
    print(f"Unknown error: {e}")

# Else (runs if no exception)
try:
    result = 10 / 2
except ZeroDivisionError:
    print("Cannot divide by zero")
else:
    print(f"Result: {result}")

# Finally (always runs)
try:
    file = open("data.txt", "r")
    data = file.read()
except FileNotFoundError:
    print("File not found")
finally:
    file.close()  # Always close the file
```

---

### Raising Exceptions

```python
def validate_ip(ip):
    """Validate IP address format."""
    parts = ip.split('.')
    if len(parts) != 4:
        raise ValueError(f"Invalid IP: {ip}")
    
    for part in parts:
        if not part.isdigit() or int(part) < 0 or int(part) > 255:
            raise ValueError(f"Invalid IP: {ip}")
    
    return True

# Using the function
try:
    validate_ip("192.168.1.100")
    validate_ip("256.256.256.256")
except ValueError as e:
    print(f"Error: {e}")
```

---

### Common Network Exceptions

```python
import socket

try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("8.8.8.8", 80))
except socket.timeout:
    print("Connection timeout")
except socket.error as e:
    print(f"Socket error: {e}")
except KeyboardInterrupt:
    print("Interrupted by user")
finally:
    sock.close()

# Scapy-specific exception handling
from scapy.all import sr1, IP, ICMP

try:
    reply = sr1(IP(dst="8.8.8.8")/ICMP(), timeout=3)
    if reply is None:
        print("No response")
except PermissionError:
    print("Permission denied - try running with sudo")
except Exception as e:
    print(f"Scapy error: {e}")
```

---

## Working with Bytes

### Bytes vs Strings

```python
# String (Unicode)
text = "Hello World"
print(text.encode('utf-8'))  # b'Hello World'

# Bytes (raw binary data)
binary = b"Hello World"
print(binary.decode('utf-8'))  # "Hello World"

# Bytes from hex
hex_bytes = bytes.fromhex("48656c6c6f")  # b'Hello'
hex_string = "48656c6c6f".encode()       # b'48656c6c6f'

# Bytes to hex
data = b"Hello"
print(data.hex())  # "48656c6c6f"

# Working with network data
ip_bytes = b'\xc0\xa8\x01\x64'  # 192.168.1.100
ip = '.'.join(str(b) for b in ip_bytes)
print(ip)  # "192.168.1.100"

import struct
# Pack/unpack binary data
port = 80
port_bytes = struct.pack('!H', port)  # b'\x00P'
port_back = struct.unpack('!H', port_bytes)[0]  # 80
```

---

### Manipulating Bytes in Scapy

```python
from scapy.all import IP, ICMP

# Raw payload
payload = b"Ping data from Scapy!"
packet = IP(dst="8.8.8.8") / ICMP() / Raw(load=payload)

# Access payload
raw_data = bytes(packet[Raw])

# Modify payload
packet[Raw].load = b"Modified payload"

# Extract payload from packet
if packet.haslayer(Raw):
    data = bytes(packet[Raw])
    print(data)

# Convert payload to hex
print(data.hex())

# Search for patterns in payload
if b"Ping" in data:
    print("Found pattern")
```

---

## Modules and Imports

### Importing Modules

```python
# Standard import
import scapy
from scapy.all import *

# Specific imports
from scapy.all import IP, ICMP, sr1

# Import with alias
import scapy.all as sp

# Import from submodules
from scapy.layers.inet import IP

# Check if module exists
try:
    import scapy
except ImportError:
    print("Scapy not installed")

# Reload module (useful during development)
import importlib
import scapy.all
importlib.reload(scapy.all)
```

---

### Creating Your Own Modules

```python
# file: network_tools.py
"""
Network Tools Module
"""

def ping(ip):
    """Ping an IP address."""
    # Implementation...
    pass

def scan_ports(ip, ports):
    """Scan ports on a host."""
    # Implementation...
    pass

# Using the module
import network_tools
network_tools.ping("192.168.1.1")

# Or
from network_tools import ping, scan_ports
ping("192.168.1.1")
```

---

### __name__ == "__main__"

```python
# This allows the file to be both imported and run directly
# file: my_script.py

def main():
    """Main function."""
    print("Running main function")

if __name__ == "__main__":
    main()

# When imported, main() won't run automatically
# When run directly, main() executes
```

---

## Virtual Environments

### Creating and Using Virtual Environments

```bash
# Create virtual environment
python3 -m venv scapy_env

# Activate (Linux/macOS)
source scapy_env/bin/activate

# Activate (Windows)
scapy_env\Scripts\activate

# Install packages in virtual environment
pip install scapy[complete]

# Deactivate
deactivate

# Export requirements
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt
```

---

### requirements.txt Example

```text
scapy==2.5.0
matplotlib==3.5.0
numpy==1.24.0
pandas==1.5.0
```

---

## Common Libraries

### Essential Python Libraries for Networking

```python
# Standard Library
import socket          # Low-level networking
import subprocess      # Run system commands
import re              # Regular expressions
import os              # Operating system interface
import sys             # System-specific parameters
import time            # Time functions
import datetime        # Date and time
import json            # JSON encoding/decoding
import csv             # CSV file reading/writing
import threading       # Threading support
import queue           # Queue data structure
import argparse        # Command-line argument parsing

# Third-party libraries
import scapy           # Packet manipulation
import requests        # HTTP library
import netifaces       # Network interface info
import ipaddress       # IP address manipulation
import psutil          # Process and system information
import paramiko        # SSH client
import netmiko         # Network device automation
```

---

### Useful Network Functions

```python
import socket
import ipaddress

def get_local_ip():
    """Get local IP address."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 1))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

def resolve_host(hostname):
    """Resolve hostname to IP address."""
    try:
        return socket.gethostbyname(hostname)
    except socket.gaierror:
        return None

def is_private_ip(ip):
    """Check if IP is private."""
    try:
        return ipaddress.ip_address(ip).is_private
    except ValueError:
        return False

def ip_to_bytes(ip):
    """Convert IP string to bytes."""
    return socket.inet_aton(ip)

def bytes_to_ip(b):
    """Convert bytes to IP string."""
    return socket.inet_ntoa(b)
```

---

## Python for Scapy

### Common Scapy Patterns in Python

```python
# Basic Scapy imports
from scapy.all import *

# Packet construction (outside to inside)
packet = Ether() / IP() / TCP() / Raw()

# Setting fields
packet = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
          IP(src="192.168.1.100", dst="8.8.8.8") / \
          ICMP(type=8, code=0)

# Accessing fields
src_ip = packet[IP].src
dst_ip = packet[IP].dst
tcp_flags = packet[TCP].flags

# Modifying fields
packet[IP].ttl = 64
packet[TCP].flags = "SA"

# Checking layers
if packet.haslayer(TCP):
    print("TCP packet")

# Getting layers
tcp = packet.getlayer(TCP)
if tcp:
    print(tcp.sport)

# Packet inspection
packet.show()
packet.show2()  # With calculated checksums
packet.summary()
hexdump(packet)
bytes(packet)

# Multiple packets
packets = []
for i in range(10):
    pkt = IP(dst="8.8.8.8") / ICMP(seq=i)
    packets.append(pkt)

# Send/Receive
send(packet)                     # Send at Layer 3
sendp(packet)                    # Send at Layer 2
reply = sr1(packet, timeout=3)   # Send and get first reply
answers, unans = sr(packet)      # Send and get all replies

# Sniffing
packets = sniff(count=10)
sniff(filter="tcp", prn=lambda x: x.summary(), count=5)

# PCAP operations
packets = rdpcap("capture.pcap")
wrpcap("output.pcap", packets)
```

---

## Coding Best Practices

### Style Guide (PEP 8)

```python
# ✓ Good practice
def scan_network(network, timeout=2):
    """Scan a network for active hosts."""
    active_hosts = []
    for ip in network.hosts():
        if ping_host(str(ip), timeout):
            active_hosts.append(str(ip))
    return active_hosts

# ✗ Bad practice
def scanNetwork(network, timeout=2):
    activeHosts=[]
    for ip in network.hosts():
        if pingHost(str(ip), timeout):
            activeHosts.append(str(ip))
    return activeHosts
```

---

### Naming Conventions

```python
# Variables: lowercase with underscores
ip_address = "192.168.1.100"
hostname = "webserver"

# Constants: UPPERCASE with underscores
MAX_TIMEOUT = 10
DEFAULT_PORT = 80

# Functions: lowercase with underscores
def ping_host(ip):
    pass

# Classes: CamelCase
class NetworkScanner:
    pass

# Private variables: underscore prefix
_internal_counter = 0
```

---

### Comments

```python
# Single-line comment

"""
Multi-line comment
or docstring
"""

def scan_host(ip):
    """
    Scan a single host for open ports.
    
    Args:
        ip (str): IP address to scan
    
    Returns:
        list: List of open ports
    """
    # Implementation...
```

---

### Code Organization

```python
#!/usr/bin/env python3
"""
Module docstring describing the script.
"""

# Standard library imports
import sys
import os
import time

# Third-party imports
import scapy.all as sp

# Local imports
import network_tools

# Constants
DEFAULT_TIMEOUT = 3
DEFAULT_PORTS = [80, 443, 22]

# Functions
def main():
    pass

# Main guard
if __name__ == "__main__":
    main()
```

---

### Debugging and Logging

```python
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Use logging instead of print
logging.info("Scanning network...")
logging.warning("Timeout occurred")
logging.error("Connection failed")
logging.debug("Detailed debug info")

# Different levels
logging.debug("Debug information")
logging.info("General information")
logging.warning("Warning message")
logging.error("Error message")
logging.critical("Critical error")
```

---

### Command-Line Arguments

```python
import argparse

def main():
    parser = argparse.ArgumentParser(description="Network Scanner")
    parser.add_argument("host", help="Target IP address or hostname")
    parser.add_argument("-p", "--ports", help="Ports to scan (e.g., 80,443 or 1-1024)")
    parser.add_argument("-t", "--timeout", type=int, default=3,
                        help="Timeout in seconds")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Verbose output")
    
    args = parser.parse_args()
    
    print(f"Scanning: {args.host}")
    if args.ports:
        print(f"Ports: {args.ports}")
    print(f"Timeout: {args.timeout}s")
    if args.verbose:
        print("Verbose mode enabled")

if __name__ == "__main__":
    main()
```

---

## Primer Complete

This primer covers the essential Python concepts needed for the series. You should now be comfortable with:

- Basic Python syntax and data types
- Data structures (lists, dictionaries, tuples, sets)
- Control flow and functions
- File I/O and exception handling
- Working with bytes and binary data
- Modules, imports, and virtual environments
- Common Python libraries for networking
- Scapy-specific Python patterns
- Coding best practices

---

```
─────────────────────────────────────────────────────────────────────────
│  PRIMER: ESSENTIAL PYTHON FOR NETWORK ENGINEERS COMPLETE            │
│                                                                     │
│  This primer covers:                                               │
│  ✅ Python basics                                                  │
│  ✅ Data structures                                                │
│  ✅ Control flow                                                   │
│  ✅ Functions                                                      │
│  ✅ File I/O                                                       │
│  ✅ Exception handling                                             │
│  ✅ Working with bytes                                             │
│  ✅ Modules and imports                                            │
│  ✅ Virtual environments                                           │
│  ✅ Common libraries                                               │
│  ✅ Python for Scapy                                               │
│  ✅ Coding best practices                                          │
│                                                                     │
│  You are now ready to begin the series!                           │
└─────────────────────────────────────────────────────────────────────────
```

---

**Return to the series introduction** when you're ready, or proceed directly to **Module 1: Foundations of Packet Crafting**.
