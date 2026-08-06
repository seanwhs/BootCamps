# Mastering Network Packet Crafting with Scapy
## Comprehensive Slide Deck Outline

## Overview

This document provides a comprehensive, expanded slide deck outline for teaching the **Mastering Network Packet Crafting with Scapy** series. Each section includes detailed slide content, talking points, demonstration scripts, and verification steps.

---

## Part 0: Introduction and Orientation
### Series Kickoff

---

### Slide 0.1: Title Slide

**Title:** Mastering Network Packet Crafting with Scapy
**Subtitle:** From Ethernet Frames to Custom Protocols: Building Professional Network Analysis & Security Tools in Python

**Visual:** Scapy logo + packet stack diagram

**Talking Points:**
- Welcome and introductions
- What you'll accomplish in this series
- The journey from beginner to professional

---

### Slide 0.2: What is Packet Crafting?

**Title:** Understanding Packet Crafting

**Key Concepts:**
- **Definition:** The art and science of constructing network packets from scratch
- **Why it matters:** Understanding packets = understanding networks
- **Difference from passive capture:** Active vs. passive interaction

**Visual:** Diagram showing passive capture vs. active crafting

**Analogy:** 
- Think of packet crafting like being able to write letters instead of just reading them
- You understand the postal system at a much deeper level when you know how to address, stamp, and compose mail

**Talking Points:**
- Packet crafting is the foundation of network programming
- Used in: Security testing, diagnostics, research, automation
- Scapy gives you complete control over every bit

---

### Slide 0.3: Ultimate Architecture Overview

**Title:** What You'll Build: The Network Security Toolkit

**Visual:** Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   NETWORK SECURITY TOOLKIT                     │
│                   (Command-Line Interface)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │  Discovery   │  │  Analysis    │  │   Monitoring       │   │
│  │  Engines     │  │  Engines     │  │   Pipelines        │   │
│  │              │  │              │  │                    │   │
│  │ • ARP Scanner│  │ • PCAP Reader│  │ • Live Sniffer    │   │
│  │ • Ping Suite │  │ • Protocol   │  │ • BPF Filtering   │   │
│  │ • Traceroute │  │   Dissector  │  │ • Flow Reassembly │   │
│  │ • Port Scan  │  │ • Custom     │  │ • Statistics      │   │
│  │   (TCP/UDP)  │  │   Protocol   │  │ • Anomaly         │   │
│  │              │  │   Parser     │  │   Detection       │   │
│  └──────┬───────┘  └──────┬───────┘  └────────┬───────────┘   │
│         │                 │                     │               │
│         └─────────────────┼─────────────────────┘               │
│                           │                                     │
│                ┌──────────▼──────────┐                         │
│                │  Plugin Framework    │                         │
│                │  (Extensible Core)   │                         │
│                └──────────────────────┘                         │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │  Export &    │  │  Reporting   │  │  Visualization     │   │
│  │  Logging     │  │  Engine      │  │  Engine            │   │
│  └──────────────┘  └──────────────┘  └────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Talking Points:**
- Each module builds a piece of this toolkit
- By the end, you'll have a complete, production-ready tool
- All components integrate together

---

### Slide 0.4: Learning Progression Roadmap

**Title:** Your Learning Journey

**Visual:** Gantt Chart / Roadmap

```
MODULE 1: Foundations & Scapy Architecture
    │  • Install Scapy and configure environment
    │  • Understand the "/" stacking operator
    │  • Build and inspect your first packets
    │  • Read/write PCAP files
    │
    ▼
MODULE 2: Layer 2 & Layer 3 Operations
    │  • Ethernet frames, ARP requests/replies
    │  • IPv4 header manipulation
    │  • ICMP echo (ping) from scratch
    │  • Build ARP scanner and custom ping
    │
    ▼
MODULE 3: Transport Layer Protocols
    │  • UDP datagrams and TCP segments
    │  • Three-way handshake analysis
    │  • Professional port scanning engine
    │  • Banner grabbing framework
    │
    ▼
MODULE 4: Packet Sniffing & Traffic Analysis
    │  • Live capture with BPF filters
    │  • Protocol dissection (HTTP, DNS, DHCP)
    │  • Flow reconstruction
    │  • Traffic statistics dashboard
    │
    ▼
MODULE 5: Active Manipulation (Authorized Labs)
    │  • ARP spoofing detection
    │  • DNS monitoring tools
    │  • DHCP analyzer
    │  • Packet replay utilities
    │
    ▼
MODULE 6: Automation, Performance & Custom Protocols
    │  • Multi-threading and asyncio
    │  • Custom protocol creation
    │  • Pandas integration
    │  • Final toolkit assembly
    │
    ▼
CAPSTONE: Enterprise Network Analysis Toolkit
```

**Talking Points:**
- Each module builds on the previous one
- Practical, hands-on at every step
- You'll have working code after each session

---

### Slide 0.5: Target Audience

**Title:** Who This Is For

**Audience Categories:**

| Role | Why They Need This |
|------|-------------------|
| **Cybersecurity Pros** | Build custom tools for authorized testing |
| **Penetration Testers** | Craft packets for security assessments |
| **SOC Analysts** | Detect anomalies and build monitoring |
| **Network Engineers** | Automate diagnostics and analysis |
| **Python Developers** | Expand into networking domain |
| **Students** | Practical protocol understanding |

**Talking Points:**
- No matter your background, you'll learn practical skills
- The common thread: curiosity about what happens at the wire level

---

### Slide 0.6: Prerequisites

**Title:** What You Need to Know

**Technical Prerequisites:**

| Topic | Level | Details |
|-------|-------|---------|
| **Python** | Intermediate | Variables, functions, classes, list comprehensions |
| **Linux** | Basic | Command-line navigation, sudo, package management |
| **TCP/IP** | Working knowledge | IP addressing, ports, routing basics |

**Nice-to-Have:**
- Wireshark experience
- Familiarity with ping/traceroute
- Basic networking tools knowledge

**Talking Points:**
- Don't worry if you're rusty; we'll explain key concepts
- Advanced patterns are explained when introduced
- You can learn as you go

---

### Slide 0.7: Tools & Technologies

**Title:** Our Workshop Toolkit

**Core Technologies:**

| Tool | Purpose | Why |
|------|---------|-----|
| **Python 3.8+** | Programming language | Clean syntax, extensive libraries |
| **Scapy** | Packet crafting | Powerful protocol stack, extensible |
| **Wireshark** | Packet analysis GUI | Visual confirmation, debugging |
| **tcpdump/tshark** | Command-line capture | Scriptable capture |
| **Pandas** | Data analysis | Traffic statistics |
| **Matplotlib** | Visualization | Charts and graphs |

**Talking Points:**
- These are industry-standard tools
- Everything is free and open source
- You'll learn how to use them all

---

### Slide 0.8: Lab Environment Setup

**Title:** Development Environment

**Recommended Setup:**

```bash
# Linux (Ubuntu/Debian) - WSL for Windows
sudo apt update
sudo apt install python3 python3-pip python3-venv wireshark tcpdump

# macOS
brew install python3 wireshark tcpdump

# Windows (via WSL 2)
wsl --install -d Ubuntu
# Then follow Linux instructions inside WSL
```

**Python Environment:**
```bash
# Project directory
mkdir ~/scapy-tutorial
cd ~/scapy-tutorial

# Virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# Install Scapy
pip install scapy[complete]
```

**Talking Points:**
- Use virtual environments to keep dependencies clean
- Root/sudo needed for raw socket operations
- Wireshark is optional but highly recommended

---

### Slide 0.9: Ethics & Responsible Use

**Title:** The Most Important Slide

**Core Principle:**
> **Never test on a system or network without explicit written authorization.**

**Legal Framework:**
- CFAA (US): 18 U.S.C. § 1030 
- Computer Misuse Act (UK)
- GDPR (EU)
- Various national laws

**Consequences of Unauthorized Testing:**
- Criminal charges
- Civil lawsuits
- Job termination
- Permanent career damage

**Lab Environment Requirements:**
- Isolated network
- No connection to production
- Written authorization

**Talking Points:**
- These skills are powerful; use them responsibly
- Always get authorization before testing
- Practice in isolated lab environments only
- This series builds defensive tools, not offensive weapons

---

### Slide 0.10: Series Structure

**Title:** How This Series Works

**Consistent Pattern:**

| Phase | Description | Time |
|-------|-------------|------|
| **1. Target** | What we're building today | 5 min |
| **2. Concept** | Why and how it works | 10 min |
| **3. Implementation** | Complete, unabbreviated code | 30-45 min |
| **4. Verification** | Testing and validation | 10-15 min |
| **5. Hands-on Labs** | Exercises and challenges | 15-20 min |

**Learning Flow:**
1. Read the concept explanation
2. Review the code with inline comments
3. Type the code into your editor (not copy-paste)
4. Run the verification steps
5. Compare with Wireshark captures
6. Challenge yourself with lab extensions

**Talking Points:**
- Everything is code-heavy and unabbreviated
- No placeholders like "// implement the rest here"
- Complete, copy-pasteable file contents

---

### Slide 0.11: Verification Methodology

**Title:** How to Verify Your Work

**Verification Steps:**

1. **Run the code** - Execute the script
2. **Check expected output** - Compare with examples
3. **Use Wireshark** - Visual confirmation
4. **Validate with tshark** - Command-line checks
5. **Write tests** - Automated validation

**Example Verification:**

```bash
# Run the script
python3 src/verify_environment.py

# Expected output
Python version: 3.10.12
Scapy version: 2.5.0
✓ Core Scapy modules imported successfully
✓ Successfully created a test packet

# Wireshark confirmation
wireshark output/sample_packets.pcap
```

**Talking Points:**
- Verification isn't optional; it's how you learn
- Always confirm your code works
- Wireshark is your best debugging friend

---

## Module 1: Foundations of Packet Crafting

---

### Slide 1.0: Module 1 Overview

**Title:** Module 1: Foundations of Packet Crafting

**Learning Objectives:**
- ✅ Install and configure Scapy
- ✅ Understand packet layering and the `/` operator
- ✅ Build multi-layer packets
- ✅ Inspect packets with Scapy methods
- ✅ Read and write PCAP files
- ✅ Build a PCAP analysis tool

**Topics:**
1. Setting Up Your Environment
2. The Packet Stacking Model
3. Working with PCAP Files
4. Building Your First Analysis Tool

**Visual:** Scapy logo + packet diagram

**Talking Points:**
- This is the foundation for everything else
- You'll build working tools in every session
- By the end, you'll be comfortable with Scapy basics

---

### Slide 1.1: Part 1 – Environment Setup

**Title:** Setting Up Your Scapy Environment

**The Target:** Professional Scapy Development Environment

**What We Need:**
- Python 3.8+ installation
- Scapy with [complete] features
- Wireshark for verification
- Project directory structure
- Raw socket permissions

**Directory Structure:**
```
~/scapy-tutorial/
├── venv/               # Virtual environment
├── src/                # All source code
│   └── __init__.py
├── labs/               # Hands-on lab scripts
├── pcap_files/         # PCAP files for analysis
├── output/             # Generated reports
├── config/             # Configuration files
├── tests/              # Unit tests
└── docs/               # Documentation
```

**Talking Points:**
- Virtual environments prevent dependency conflicts
- Root permissions needed for raw sockets
- Wireshark validates your packet construction

---

### Slide 1.2: Environment Verification Script

**Title:** Environment Verification

**Code:** `src/verify_environment.py`

```python
#!/usr/bin/env python3
"""
Module 1, Part 1: Environment Verification Script
"""

import sys
import os

# Check Python version
print(f"Python version: {sys.version}")

# Try importing Scapy
try:
    import scapy
    print(f"Scapy version: {scapy.__version__}")
except ImportError as e:
    print(f"ERROR: Scapy is not installed properly: {e}")
    sys.exit(1)

# Import Scapy's main components
try:
    from scapy.all import Ether, IP, TCP, UDP, Raw, ICMP
    from scapy.sendrecv import sr, sr1, send
    from scapy.utils import rdpcap, wrpcap
    print("✓ Core Scapy modules imported successfully")
except ImportError as e:
    print(f"ERROR: Could not import required Scapy modules: {e}")
    sys.exit(1)

# Check for root/sudo privileges
is_root = os.geteuid() == 0 if hasattr(os, 'geteuid') else False
print(f"Running with root privileges: {is_root}")
print("NOTE: Root privileges are required to send/receive raw packets")

# Quick test: create a sample packet without sending it
try:
    test_packet = Ether() / IP(dst="8.8.8.8") / ICMP()
    print("✓ Successfully created a test packet (Ether/IP/ICMP)")
    print(f"  Packet summary: {test_packet.summary()}")
except Exception as e:
    print(f"ERROR: Could not create test packet: {e}")
    sys.exit(1)

print("\n" + "="*60)
print("✅ Environment verification complete!")
print("="*60)
```

**Talking Points:**
- This script checks all dependencies
- Creates a packet without sending it (safe)
- Verifies root privileges for packet sending

---

### Slide 1.3: Understanding the Stacking Model

**Title:** The Packet Stacking Model

**Analogy:** Russian Nesting Dolls or Onion Layers

```
┌─────────────────────────────────────────────────────────────┐
│                     ETHERNET FRAME                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                    IP HEADER                        │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │                 TCP HEADER                   │   │   │
│  │  │  ┌──────────────────────────────────────┐   │   │   │
│  │  │  │          APPLICATION DATA            │   │   │   │
│  │  │  └──────────────────────────────────────┘   │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**The `/` Operator:**
```python
# Outside layer -> Inside layer
packet = Ether() / IP() / TCP() / Raw()
```

**Talking Points:**
- Think of it as "Ethernet contains IP, which contains TCP, which contains Raw data"
- The `/` operator means "encapsulate" or "layer on top of"
- Build from outside to inside

---

### Slide 1.4: Building Your First Packet

**Title:** Building Multi-Layer Packets

**Code:** `src/packet_building_basics.py`

```python
from scapy.all import Ether, IP, TCP, UDP, ICMP, Raw

# 1. Ethernet + IP + ICMP (Ping packet)
ping_packet = Ether() / IP(dst="8.8.8.8") / ICMP()

# 2. Ethernet + IP + TCP (HTTP request)
http_packet = Ether() / IP(dst="192.168.1.1") / TCP(dport=80) / Raw(b"GET / HTTP/1.1\r\n\r\n")

# 3. Ethernet + IP + UDP + Raw (DNS query)
dns_packet = Ether() / IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
```

**Layer Inspection:**
```python
# Check for specific layer
if packet.haslayer(TCP):
    print(f"TCP dport: {packet[TCP].dport}")

# Access specific layer
src_ip = packet[IP].src
dst_ip = packet[IP].dst

# Show entire packet
packet.show()
packet.show2()  # With calculated checksums
```

**Talking Points:**
- Build packets from outside to inside
- Access layers using `packet[Layer]`
- Use `show2()` to see calculated checksums

---

### Slide 1.5: Packet Inspection Methods

**Title:** Packet Inspection Methods

**Inspection Methods Table:**

| Method | Description | Example |
|--------|-------------|---------|
| `show()` | Detailed hierarchical display | `packet.show()` |
| `summary()` | One-line description | `packet.summary()` |
| `show2()` | With calculated checksums | `packet.show2()` |
| `hexdump()` | Hex and ASCII display | `hexdump(packet)` |
| `sprintf()` | Custom formatted output | `packet.sprintf("%IP.src% -> %IP.dst%")` |
| `command()` | Recreate code | `packet.command()` |
| `bytes()` | Raw bytes | `bytes(packet)` |

**Layer Access:**
```python
# Access by class
packet[IP].src
packet[TCP].dport

# Check presence
if packet.haslayer(TCP):
    print(packet[TCP].flags)

# Get with default
tcp = packet.getlayer(TCP)
if tcp:
    print(tcp.sport)
```

**Talking Points:**
- Use `show()` for detailed debugging
- Use `summary()` for quick overview
- `show2()` shows auto-calculated fields

---

### Slide 1.6: Saving Packets to PCAP

**Title:** Saving Packets to PCAP

**Why PCAP:**
- Industry-standard format
- Compatible with Wireshark
- Verifies your work visually

**Code:** `src/save_to_pcap.py`

```python
from scapy.all import wrpcap, rdpcap
import os

# Create packets
packets = []
packets.append(Ether() / IP(dst="8.8.8.8") / ICMP())
packets.append(Ether() / IP(dst="192.168.1.1") / TCP(dport=80) / Raw(b"GET / HTTP/1.1\r\n\r\n"))

# Save to PCAP
os.makedirs("output", exist_ok=True)
wrpcap("output/sample_packets.pcap", packets)

# Load back
loaded = rdpcap("output/sample_packets.pcap")
for pkt in loaded:
    print(pkt.summary())
```

**Verification:**
```bash
# Open in Wireshark
wireshark output/sample_packets.pcap

# Or use tshark
tshark -r output/sample_packets.pcap -V
```

**Talking Points:**
- PCAP files let you verify your work
- Always compare with Wireshark's interpretation
- This is how you validate your packet construction

---

### Slide 1.7: Working with PCAP Files

**Title:** Loading and Analyzing PCAPs

**rdpcap() vs PcapReader:**

| Method | Best For | Memory Usage |
|--------|----------|--------------|
| `rdpcap()` | Small PCAPs, full analysis | High (loads all) |
| `PcapReader()` | Large PCAPs, streaming | Low (one at a time) |

**Loading PCAPs:**
```python
from scapy.utils import rdpcap, PcapReader

# Standard load (memory intensive)
packets = rdpcap("capture.pcap")
print(f"Loaded {len(packets)} packets")

# Memory-efficient (streaming)
with PcapReader("large_capture.pcap") as reader:
    for packet in reader:
        process(packet)
```

**Basic Analysis:**
```python
# Count protocols
tcp_count = sum(1 for p in packets if p.haslayer(TCP))
udp_count = sum(1 for p in packets if p.haslayer(UDP))

# Filter by IP
to_8_8_8_8 = [p for p in packets if p.haslayer(IP) and p[IP].dst == "8.8.8.8"]

# Extract timestamps
times = [p.time for p in packets]
```

**Talking Points:**
- Use PcapReader for large files to avoid memory issues
- List comprehensions are efficient for filtering
- Scapy's packet objects contain all protocol layers

---

### Slide 1.8: PCAP Filtering

**Title:** Filtering Packets in PCAPs

**Filtering by Protocol:**
```python
def filter_by_protocol(packets, protocol):
    if protocol == "TCP":
        return [p for p in packets if p.haslayer(TCP)]
    elif protocol == "UDP":
        return [p for p in packets if p.haslayer(UDP)]
    elif protocol == "ICMP":
        return [p for p in packets if p.haslayer(ICMP)]
    elif protocol == "IP":
        return [p for p in packets if p.haslayer(IP)]
```

**Filtering by IP:**
```python
def filter_by_ip(packets, ip_addr, direction="both"):
    filtered = []
    for pkt in packets:
        if not pkt.haslayer(IP):
            continue
        ip = pkt[IP]
        if direction == "src":
            if ip.src == ip_addr:
                filtered.append(pkt)
        elif direction == "dst":
            if ip.dst == ip_addr:
                filtered.append(pkt)
        else:  # both
            if ip.src == ip_addr or ip.dst == ip_addr:
                filtered.append(pkt)
    return filtered
```

**Filtering by Port:**
```python
def filter_by_port(packets, port, protocol="TCP", direction="both"):
    filtered = []
    for pkt in packets:
        if not pkt.haslayer(protocol):
            continue
        if protocol == "TCP":
            layer = pkt[TCP]
        elif protocol == "UDP":
            layer = pkt[UDP]
        if direction == "src":
            if layer.sport == port:
                filtered.append(pkt)
        elif direction == "dst":
            if layer.dport == port:
                filtered.append(pkt)
        else:
            if layer.sport == port or layer.dport == port:
                filtered.append(pkt)
    return filtered
```

**Talking Points:**
- Python list comprehensions make filtering clean
- Protocol-specific filters target specific layers
- Filter early to reduce processing load

---

### Slide 1.9: PCAP Modification

**Title:** Modifying PCAP Packets

**Common Modifications:**

| Modification | Purpose | Code |
|--------------|---------|------|
| Anonymize IPs | Privacy | `anonymize_ip(packet)` |
| Change TTL | Test routing | `modify_ttl(packet, 64)` |
| Modify Ports | Service testing | `modify_tcp_port(packet)` |
| Remove Payload | Size reduction | `remove_payload(packet)` |

**Example: Anonymize IPs**
```python
from scapy.all import RandIP

def anonymize_ip(packet):
    if not packet.haslayer(IP):
        return packet
    
    pkt = packet.copy()
    pkt[IP].src = str(RandIP())
    pkt[IP].dst = str(RandIP())
    
    # Recalculate checksums
    if pkt.haslayer(TCP):
        del pkt[TCP].chksum
        del pkt[IP].chksum
    elif pkt.haslayer(UDP):
        del pkt[UDP].chksum
        del pkt[IP].chksum
    
    return pkt
```

**Saving Modified Packets:**
```python
# Modify all packets in a PCAP
modified = [anonymize_ip(p) for p in packets]
wrpcap("output/anonymized.pcap", modified)
```

**Talking Points:**
- Always copy packets before modifying
- Recalculate checksums after modification
- Save to new file to preserve original

---

### Slide 1.10: PCAP Analyzer Tool

**Title:** Building a PCAP Analyzer

**Features:**
- Load and inspect PCAP files
- Protocol distribution analysis
- IP address tracking
- Port analysis
- Payload extraction
- Statistics export (JSON)

**Code Structure:**
```python
class PCAPAnalyzer:
    def __init__(self, pcap_file):
        self.pcap_file = pcap_file
        self.packets = None
        self.stats = {}
    
    def load(self):
        self.packets = rdpcap(self.pcap_file)
        return self
    
    def analyze_protocols(self):
        # Count TCP, UDP, ICMP, etc.
        pass
    
    def analyze_addresses(self):
        # Track source/destination IPs
        pass
    
    def analyze_ports(self):
        # Analyze TCP/UDP ports
        pass
    
    def export_stats(self, output_file):
        # Export to JSON
        pass
```

**Usage:**
```bash
# Analyze PCAP
python3 src/pcap_analyzer.py capture.pcap

# Export statistics
python3 src/pcap_analyzer.py capture.pcap --export stats.json
```

**Talking Points:**
- This tool demonstrates everything you've learned
- You'll use it throughout the series
- Exporting to JSON enables further analysis

---

## Module 2: Layer 2 & Layer 3 Operations

---

### Slide 2.0: Module 2 Overview

**Title:** Module 2: Layer 2 & Layer 3 Operations

**Learning Objectives:**
- ✅ Ethernet frame construction
- ✅ MAC addressing and VLAN tagging
- ✅ ARP request/reply mechanics
- ✅ ARP scanner implementation
- ✅ ICMP echo (ping) from scratch
- ✅ Traceroute implementation
- ✅ IP fragmentation and reassembly

**Topics:**
1. Ethernet Frame Construction
2. ARP Operations
3. IP and ICMP Operations
4. Network Discovery Tools

**Visual:** Ethernet frame diagram + ARP sequence

**Talking Points:**
- Layer 2 and 3 are the foundation of networking
- Understanding Ethernet means understanding local networks
- ARP and ICMP are essential diagnostic tools

---

### Slide 2.1: Ethernet Frame Structure

**Title:** Ethernet Frame Deep Dive

**Frame Structure:**

```
┌─────────────────────────────────────────────────────────────────┐
│                     ETHERNET FRAME                             │
│  ┌─────────┬──────────┬──────────────┬─────────────────┬────┐ │
│  │ Preamble│ Dest MAC │  Src MAC     │ EtherType/Length│Payload│ │
│  │ 8 bytes │ 6 bytes  │  6 bytes     │   2 bytes       │ var  │ │
│  └─────────┴──────────┴──────────────┴─────────────────┴────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**MAC Address Types:**

| Type | Example | Characteristic |
|------|---------|----------------|
| Unicast | `00:11:22:33:44:55` | First bit of first byte = 0 |
| Multicast | `01:00:5e:00:00:01` | First bit of first byte = 1 |
| Broadcast | `ff:ff:ff:ff:ff:ff` | All bits = 1 |

**Common EtherTypes:**

| Value | Protocol |
|-------|----------|
| 0x0800 | IPv4 |
| 0x0806 | ARP |
| 0x86DD | IPv6 |
| 0x8100 | VLAN (802.1Q) |

**Talking Points:**
- The Ethernet frame is the foundation of all local communication
- MAC addresses are unique hardware identifiers
- EtherType tells the receiving device what protocol is inside

---

### Slide 2.2: Building Ethernet Frames

**Title:** Building Ethernet Frames in Scapy

**Code Examples:**

```python
from scapy.all import Ether, IP, ARP, ICMP, TCP, UDP, Raw

# Unicast frame
unicast = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / IP(dst="8.8.8.8") / ICMP()

# Broadcast frame (ARP)
broadcast = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
            ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100",
                hwdst="00:00:00:00:00:00", pdst="192.168.1.1")

# Multicast frame
multicast = Ether(src="00:11:22:33:44:55", dst="01:00:5e:00:00:01") / \
            IP(src="192.168.1.100", dst="224.0.0.1") / ICMP()
```

**MAC Type Detection:**
```python
def get_mac_type(mac):
    if mac == "ff:ff:ff:ff:ff:ff":
        return "Broadcast"
    elif int(mac.split(':')[0], 16) & 0x01:
        return "Multicast"
    else:
        return "Unicast"
```

**Talking Points:**
- Scapy makes Ethernet construction simple
- Different MAC types serve different purposes
- Broadcast frames reach all devices on the network

---

### Slide 2.3: VLAN Tagging (802.1Q)

**Title:** VLAN Tagging with 802.1Q

**VLAN Frame Structure:**

```
┌─────────────────────────────────────────────────────────────────┐
│              VLAN-TAGGED ETHERNET FRAME                       │
├──────────┬──────────┬──────────┬──────────────┬───────────────┤
│ Dest MAC │ Src MAC  │ TPID     │ TCI          │ EtherType     │
│ 6 bytes  │ 6 bytes  │ 0x8100   │ 2 bytes      │ 2 bytes       │
├──────────┴──────────┴──────────┴──────────────┴───────────────┤
│ Payload                                                       │
└─────────────────────────────────────────────────────────────────┘

TCI (Tag Control Information):
┌────────────┬────────────┬────────────────────────────────────┐
│ Priority   │ CFI        │ VLAN ID (VID)                    │
│ 3 bits     │ 1 bit      │ 12 bits                          │
├────────────┼────────────┼────────────────────────────────────┤
│ 0-7        │ 0 or 1     │ 0-4095                           │
└────────────┴────────────┴────────────────────────────────────┘
```

**VLAN in Scapy:**
```python
from scapy.layers.l2 import Dot1Q

# Basic VLAN
vlan = Ether() / Dot1Q(vlan=100) / IP(dst="8.8.8.8") / ICMP()

# VLAN with priority
vlan_prio = Ether() / Dot1Q(vlan=100, prio=5) / IP(dst="8.8.8.8")

# Q-in-Q (double VLAN)
qinq = Ether() / Dot1Q(vlan=100) / Dot1Q(vlan=200) / IP(dst="8.8.8.8")
```

**Talking Points:**
- VLANs segment networks logically
- 802.1Q adds a 4-byte tag after source MAC
- Q-in-Q allows double tagging for provider networks

---

### Slide 2.4: ARP Basics

**Title:** Address Resolution Protocol (ARP)

**Analogy:** A network phonebook

**ARP Request (Broadcast):**
```
┌─────────────────────────────────────────────────────────────────┐
│                   ARP REQUEST                                   │
├─────────────────────────────────────────────────────────────────┤
│ "Who has 192.168.1.1? Tell 192.168.1.100"                     │
│                                                                 │
│ Sender MAC: 00:11:22:33:44:55                                  │
│ Sender IP:  192.168.1.100                                      │
│ Target MAC: 00:00:00:00:00:00                                  │
│ Target IP:  192.168.1.1                                        │
└─────────────────────────────────────────────────────────────────┘
```

**ARP Reply (Unicast):**
```
┌─────────────────────────────────────────────────────────────────┐
│                   ARP REPLY                                    │
├─────────────────────────────────────────────────────────────────┤
│ "I am 192.168.1.1. My MAC is AA:BB:CC:DD:EE:FF"              │
│                                                                 │
│ Sender MAC: AA:BB:CC:DD:EE:FF                                  │
│ Sender IP:  192.168.1.1                                        │
│ Target MAC: 00:11:22:33:44:55                                  │
│ Target IP:  192.168.1.100                                      │
└─────────────────────────────────────────────────────────────────┘
```

**ARP Cache:**
```bash
# View ARP cache (Linux)
arp -n
ip neigh show

# View ARP cache (Windows)
arp -a

# Clear ARP cache (Linux)
ip neigh flush all
```

**Talking Points:**
- ARP maps IP addresses to MAC addresses
- Requests are broadcast; replies are unicast
- The ARP cache stores mappings for efficiency

---

### Slide 2.5: Building ARP Packets

**Title:** Building ARP Packets in Scapy

**ARP Request:**
```python
from scapy.all import Ether, ARP, srp

# Build ARP request
arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
              ARP(op=1,  # Request
                  hwsrc="00:11:22:33:44:55",
                  psrc="192.168.1.100",
                  hwdst="00:00:00:00:00:00",
                  pdst="192.168.1.1")
```

**ARP Reply:**
```python
# Build ARP reply
arp_reply = Ether(dst="00:11:22:33:44:55") / \
            ARP(op=2,  # Reply
                hwsrc="aa:bb:cc:dd:ee:ff",
                psrc="192.168.1.1",
                hwdst="00:11:22:33:44:55",
                pdst="192.168.1.100")
```

**Send and Receive:**
```python
# Send request and wait for reply
reply = srp1(arp_request, timeout=3, verbose=False)

if reply:
    print(f"IP: {reply[ARP].psrc} -> MAC: {reply[ARP].hwsrc}")
```

**Talking Points:**
- ARP operation codes: 1=Request, 2=Reply
- Use `srp()` for Layer 2 send/receive
- Always set a timeout for ARP requests

---

### Slide 2.6: ARP Scanner

**Title:** Building an ARP Scanner

**Features:**
- Network discovery
- Host inventory
- Duplicate IP detection
- Real-time monitoring

**Code Snippet:**
```python
class ARPScanner:
    def __init__(self, interface=None):
        self.interface = interface or conf.iface
        self.local_mac = get_if_hwaddr(self.interface)
        self.discovered_hosts = {}
    
    def scan_network(self, network_cidr, timeout=2):
        # Build ARP request
        arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                      ARP(op=1,
                          hwsrc=self.local_mac,
                          psrc=self.get_local_ip(),
                          pdst=str(network))
        
        # Send and receive
        answered, unanswered = srp(arp_request, timeout=timeout, verbose=False)
        
        # Process responses
        hosts = {}
        for sent, received in answered:
            ip = received[ARP].psrc
            mac = received[ARP].hwsrc
            hosts[ip] = mac
        
        self.discovered_hosts.update(hosts)
        return hosts
```

**Usage:**
```bash
# Scan network
python3 src/arp_scanner.py -n 192.168.1.0/24

# Continuous monitoring
python3 src/arp_scanner.py -n 192.168.1.0/24 -m -d 60
```

**Talking Points:**
- ARP scanning is the most reliable way to find hosts on a local network
- Works even if hosts block ICMP (ping)
- Duplicate IP detection helps identify misconfigurations

---

### Slide 2.7: ICMP Echo (Ping)

**Title:** ICMP Echo Request/Reply (Ping)

**ICMP Header:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    ICMP HEADER                                 │
├──────────┬──────────┬─────────────────────────────────────────┤
│ Type     │ Code     │ Checksum                               │
│ 8 bits   │ 8 bits   │ 16 bits                                │
├──────────┴──────────┴─────────────────────────────────────────┤
│ Payload (depends on type)                                     │
└─────────────────────────────────────────────────────────────────┘
```

**ICMP Types:**

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Ping response |
| 8 | Echo Request | Ping request |
| 3 | Destination Unreachable | Network/host unreachable |
| 11 | Time Exceeded | TTL expired (traceroute) |

**Building a Ping Packet:**
```python
from scapy.all import IP, ICMP, sr1

# Build echo request
ping = IP(dst="8.8.8.8") / ICMP(type=8, code=0, id=12345, seq=1)

# Send and receive reply
reply = sr1(ping, timeout=3)

if reply and reply.haslayer(ICMP) and reply[ICMP].type == 0:
    print("Ping response received!")
    print(f"  Source: {reply[IP].src}")
    print(f"  Time: {reply.time}")
```

**Talking Points:**
- ICMP Echo Request is the ping packet
- Echo Reply is the response
- TTL can be used to discover network path

---

### Slide 2.8: Custom Ping Utility

**Title:** Building a Custom Ping Utility

**Features:**
- ICMP echo request/reply
- Statistics collection
- Timeout handling
- Continuous ping mode
- Custom packet size
- TTL configuration

**Code Snippet:**
```python
class CustomPing:
    def __init__(self, target, count=4, timeout=3, interval=1,
                 packet_size=64, ttl=64, df=True):
        self.target = target
        self.count = count
        self.timeout = timeout
        self.interval = interval
        self.packet_size = packet_size
        self.ttl = ttl
        self.df = df
        
        self.sent = 0
        self.received = 0
        self.times = []
    
    def build_packet(self, seq):
        payload = b"Ping data from Scapy!" + b"X" * (self.packet_size - 18)
        ip = IP(dst=self.target, ttl=self.ttl)
        if self.df:
            ip.flags = 2  # DF flag
        return ip / ICMP(type=8, code=0, id=12345, seq=seq) / Raw(load=payload[:self.packet_size])
    
    def ping_one(self, seq):
        packet = self.build_packet(seq)
        start = time.time()
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        elapsed = (time.time() - start) * 1000  # Milliseconds
        
        if reply and reply.haslayer(ICMP) and reply[ICMP].type == 0:
            self.received += 1
            self.times.append(elapsed)
            return True, elapsed
        return False, elapsed
```

**Usage:**
```bash
# Standard ping
python3 src/custom_ping.py 8.8.8.8

# Continuous ping
python3 src/custom_ping.py 8.8.8.8 -c 0

# Custom packet size
python3 src/custom_ping.py 8.8.8.8 -s 1000 -c 4
```

**Talking Points:**
- You've just built ping from scratch
- Statistics include min, max, avg, and standard deviation
- Continuous mode is useful for monitoring

---

### Slide 2.9: Traceroute Implementation

**Title:** Building Traceroute from Scratch

**How Traceroute Works:**

1. Send packets with increasing TTL values
2. Each router decrements TTL by 1
3. When TTL reaches 0, router returns ICMP Time Exceeded
4. Destination returns ICMP Echo Reply when reached

```
Host A                Router 1              Router 2              Host B
  │                     │                     │                     │
  │  TTL=1 ────────────>│                     │                     │
  │                     │  Time Exceeded      │                     │
  │  <──────────────────│                     │                     │
  │                     │                     │                     │
  │  TTL=2 ──────────────────────────────────>│                     │
  │                     │                     │  Time Exceeded      │
  │  <─────────────────────────────────────────│                     │
  │                     │                     │                     │
  │  TTL=3 ────────────────────────────────────────────────────────>│
  │                     │                     │  Echo Reply         │
  │  <──────────────────────────────────────────────────────────────│
```

**Code Snippet:**
```python
def traceroute(target, max_hops=30):
    for ttl in range(1, max_hops + 1):
        packet = IP(dst=target, ttl=ttl) / ICMP()
        reply = sr1(packet, timeout=2, verbose=False)
        
        if reply is None:
            print(f"{ttl:2}. * * *")
            continue
        
        ip = reply[IP].src
        if reply.haslayer(ICMP):
            if reply[ICMP].type == 0:  # Echo Reply
                print(f"{ttl:2}. {ip} - Reached destination!")
                break
            elif reply[ICMP].type == 11:  # Time Exceeded
                print(f"{ttl:2}. {ip}")
        else:
            print(f"{ttl:2}. {ip}")
```

**Talking Points:**
- Traceroute reveals the network path
- Each hop is a router
- Three probes per hop provide reliability

---

### Slide 2.10: IP Fragmentation

**Title:** Understanding IP Fragmentation

**What is Fragmentation?**
- Breaking a large packet into smaller pieces
- Required when packet exceeds MTU
- Reassembled at destination

**Fragmentation Fields:**

| Field | Description |
|-------|-------------|
| ID | Same for all fragments |
| DF | Don't Fragment flag |
| MF | More Fragments flag |
| Fragment Offset | Position in original packet |

**Scapy Fragmentation:**
```python
# Create large packet
packet = IP(dst="8.8.8.8") / ICMP() / Raw(b"X" * 2000)

# Fragment
fragments = packet.fragment()
print(f"Created {len(fragments)} fragments")

# View fragments
for i, frag in enumerate(fragments):
    print(f"Fragment {i+1}: {len(frag)} bytes")
    print(f"  MF: {bool(frag.flags & 1)}")
    print(f"  Offset: {frag.frag}")

# Defragment
reassembled = IP(fragments)
print(f"Reassembled length: {len(reassembled)}")
```

**Talking Points:**
- Fragmentation is handled at the IP layer
- DF (Don't Fragment) flag prevents fragmentation
- Fragment offset tracks position for reassembly

---

## Module 3: Transport Layer Protocols & Reconnaissance

---

### Slide 3.0: Module 3 Overview

**Title:** Module 3: Transport Layer Protocols & Reconnaissance

**Learning Objectives:**
- ✅ TCP header structure and flags
- ✅ UDP header structure
- ✅ TCP three-way handshake
- ✅ Port scanning techniques
- ✅ Multi-threaded scanning
- ✅ Service detection and banner grabbing

**Topics:**
1. TCP and UDP Deep Dive
2. Port Scanning Techniques
3. Service Detection
4. Banner Grabbing

**Visual:** TCP handshake diagram

**Talking Points:**
- The transport layer is where applications communicate
- TCP provides reliability; UDP provides speed
- Port scanning is the foundation of network reconnaissance

---

### Slide 3.1: TCP vs UDP Comparison

**Title:** TCP vs UDP

**Analogy:** TCP = Phone Call, UDP = Postcard

| Feature | TCP | UDP |
|---------|-----|-----|
| Connection | Connection-oriented | Connectionless |
| Reliability | Reliable (ACKs) | Unreliable |
| Ordering | Ordered delivery | Unordered |
| Flow Control | Yes | No |
| Congestion Control | Yes | No |
| Header Size | 20-60 bytes | 8 bytes |
| Speed | Slower | Faster |

**Use Cases:**
- **TCP:** HTTP, HTTPS, SSH, FTP, SMTP
- **UDP:** DNS, DHCP, VoIP, Gaming, Streaming

**Talking Points:**
- TCP ensures delivery; UDP delivers fast
- Choose TCP for data integrity
- Choose UDP for speed and low latency

---

### Slide 3.2: TCP Header Structure

**Title:** TCP Header Fields

```
┌─────────────────────────────────────────────────────────────────┐
│                    TCP HEADER (20-60 bytes)                    │
├──────────────┬──────────────────┬─────────────────────────────┤
│ Source Port  │ Destination Port │                             │
│ 16 bits      │ 16 bits          │                             │
├──────────────┴──────────────────┴─────────────────────────────┤
│ Sequence Number (32 bits)                                     │
├─────────────────────────────────────────────────────────────────┤
│ Acknowledgment Number (32 bits)                               │
├──────────────┬──────────────────┬─────────────────────────────┤
│ Data Offset  │ Reserved         │ Flags (9 bits)             │
│ 4 bits       │ 3 bits           │                             │
├──────────────┴──────────────────┼─────────────────────────────┤
│ Window Size (16 bits)           │ Checksum (16 bits)         │
├─────────────────────────────────┼─────────────────────────────┤
│ Urgent Pointer (16 bits)        │                             │
├─────────────────────────────────┴─────────────────────────────┤
│ Options (if any)                                               │
└─────────────────────────────────────────────────────────────────┘
```

**TCP Flags:**

| Flag | Bit | Name | Description |
|------|-----|------|-------------|
| FIN | 0x01 | Finish | End connection |
| SYN | 0x02 | Synchronize | Establish connection |
| RST | 0x04 | Reset | Abort connection |
| PSH | 0x08 | Push | Immediate delivery |
| ACK | 0x10 | Acknowledgment | ACK valid |
| URG | 0x20 | Urgent | Urgent data |

**Talking Points:**
- Sequence and ACK numbers enable reliability
- Flags control connection state
- Options allow for extensions like window scaling

---

### Slide 3.3: Three-Way Handshake

**Title:** TCP Three-Way Handshake

**The Process:**

```
Client (192.168.1.100)          Server (10.0.0.1)
    │                                    │
    │        1. SYN (seq=1000)           │
    │        ───────────────────────────>│
    │                                    │
    │        2. SYN-ACK (seq=2000,       │
    │           ack=1001)                │
    │        <───────────────────────────│
    │                                    │
    │        3. ACK (seq=1001,           │
    │           ack=2001)                │
    │        ───────────────────────────>│
    │                                    │
    │         ESTABLISHED               │
```

**In Scapy:**
```python
# SYN
syn = IP(dst="10.0.0.1") / TCP(dport=80, flags="S", seq=1000)

# SYN-ACK
syn_ack = sr1(syn, timeout=3)

# ACK
if syn_ack and syn_ack.haslayer(TCP) and syn_ack[TCP].flags & 0x12:
    ack = IP(dst="10.0.0.1") / TCP(dport=80, flags="A", seq=1001, ack=syn_ack[TCP].seq + 1)
    send(ack)
    print("Handshake complete!")
```

**Talking Points:**
- Each side chooses an initial sequence number (ISN)
- SYN consumes one byte of sequence space
- Handshake establishes connection parameters

---

### Slide 3.4: TCP Connection Termination

**Title:** TCP Connection Termination (Four-Way)

```
Client                          Server
    │                              │
    │        1. FIN (seq=1500)     │
    │        ─────────────────────>│
    │                              │
    │        2. ACK (ack=1501)     │
    │        <─────────────────────│
    │                              │
    │        3. FIN (seq=2500)     │
    │        <─────────────────────│
    │                              │
    │        4. ACK (ack=2501)     │
    │        ─────────────────────>│
    │                              │
    │         CLOSED              │
```

**In Scapy:**
```python
# FIN
fin = IP(dst="10.0.0.1") / TCP(dport=80, flags="F", seq=1500)

# ACK to FIN
ack_fin = IP(dst="10.0.0.1") / TCP(dport=80, flags="A", seq=1501, ack=2501)

# Wait for FIN from server
# ...

# Final ACK
final_ack = IP(dst="10.0.0.1") / TCP(dport=80, flags="A", seq=1501, ack=2501)
```

**Talking Points:**
- Each direction is closed independently
- FIN consumes one byte of sequence space
- TIME-WAIT state ensures all packets are processed

---

### Slide 3.5: UDP Header Structure

**Title:** UDP Header Fields

```
┌─────────────────────────────────────────────────────────────────┐
│                    UDP HEADER (8 bytes)                        │
├──────────────┬──────────────────┬─────────────────────────────┤
│ Source Port  │ Destination Port │                             │
│ 16 bits      │ 16 bits          │                             │
├──────────────┴──────────────────┼─────────────────────────────┤
│ Length (16 bits)                │ Checksum (16 bits)          │
├─────────────────────────────────┴─────────────────────────────┤
│ Payload                                                       │
└─────────────────────────────────────────────────────────────────┘
```

**Key Points:**
- **Connectionless:** No handshake required
- **Unreliable:** No ACKs, no retransmission
- **Simple:** 8-byte header
- **Fast:** Minimal overhead
- **No ordering:** Packets can arrive out of order

**Talking Points:**
- UDP is simple and fast
- Used when speed matters more than reliability
- Applications handle any required reliability

---

### Slide 3.6: Port Scanning Overview

**Title:** Port Scanning Techniques

**Analogy:** Checking doors on a building

**Scan Types:**

| Scan Type | Description | Stealth |
|-----------|-------------|---------|
| **SYN Scan** | Half-open, sends SYN only | High |
| **Connect Scan** | Full TCP handshake | Low |
| **UDP Scan** | UDP datagrams | Medium |
| **FIN Scan** | FIN packets | High |
| **NULL Scan** | No flags set | High |
| **XMAS Scan** | FIN, PSH, URG set | High |

**SYN Scan (Half-Open):**
```
Client                      Target
  │                           │
  │    SYN (port open?)       │
  │   ───────────────────────>│
  │                           │
  │    SYN-ACK (open)         │
  │   <───────────────────────│
  │                           │
  │    RST (abort)            │
  │   ───────────────────────>│
  │                           │
  │    Port is OPEN           │
```

**Talking Points:**
- SYN scan is the most common technique
- Connect scan works without root privileges
- UDP scan is slow and unreliable

---

### Slide 3.7: TCP SYN Scanner

**Title:** Building a TCP SYN Scanner

**Features:**
- SYN scanning (half-open)
- Multi-threaded
- Port range specification
- Timeout handling
- Rate limiting

**Code Snippet:**
```python
class TCPSYNScanner:
    def __init__(self, target, ports=None, threads=10, timeout=2):
        self.target = target
        self.ports = self.parse_ports(ports)
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
    
    def scan_port(self, port):
        packet = IP(dst=self.target) / TCP(dport=port, flags="S")
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply and reply.haslayer(TCP):
            if reply[TCP].flags & 0x12:  # SYN-ACK
                # Send RST to close connection
                rst = IP(dst=self.target) / TCP(dport=port, flags="R", seq=reply[TCP].ack)
                send(rst, verbose=False)
                return port, "open"
            elif reply[TCP].flags & 0x04:  # RST
                return port, "closed"
        return port, "filtered"
```

**Usage:**
```bash
# Scan ports 1-1024
python3 src/tcp_syn_scanner.py 192.168.1.1 -p 1-1024 -t 20

# Scan common ports
python3 src/tcp_syn_scanner.py 192.168.1.1 -p 22,80,443,3306 -t 10
```

**Talking Points:**
- Multi-threading improves speed
- Rate limiting prevents detection
- SYN scan is stealthier than Connect scan

---

### Slide 3.8: TCP Connect Scanner

**Title:** TCP Connect Scanner

**Features:**
- Full TCP handshake (no root required)
- Socket-based scanning
- Service detection
- Multi-threaded

**Code Snippet:**
```python
class TCPConnectScanner:
    def __init__(self, target, ports=None, threads=10, timeout=3):
        self.target = target
        self.ports = self.parse_ports(ports)
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
    
    def scan_port(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            if result == 0:
                return port, "open"
            return port, "closed"
        except:
            return port, "error"
```

**When to Use:**
- When you don't have root privileges
- When you need full connection establishment
- When you want to grab banners

**Talking Points:**
- Slower than SYN scan but more reliable
- Doesn't require raw socket permissions
- Establishes full TCP connections

---

### Slide 3.9: UDP Scanner

**Title:** UDP Scanner

**Why UDP Scanning is Hard:**
- No handshake to confirm open ports
- No response doesn't mean closed (could be filtered)
- ICMP Port Unreachable indicates closed
- Limited UDP services respond

**Code Snippet:**
```python
class UDPScanner:
    def scan_port_icmp(self, port):
        packet = IP(dst=self.target) / UDP(dport=port)
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply is None:
            return "open_or_filtered"
        
        if reply.haslayer(ICMP):
            if reply[ICMP].type == 3 and reply[ICMP].code == 3:
                return "closed"
            else:
                return "filtered"
        
        return "open"
```

**UDP Scan Tips:**
- Probe common UDP services:
  - DNS (53)
  - DHCP (67, 68)
  - NTP (123)
  - SNMP (161)
- Use ICMP unreachable detection
- Multiple probes reduce false positives

**Talking Points:**
- UDP scanning is slower than TCP scanning
- ICMP unreachable indicates closed ports
- No response could mean open or filtered

---

### Slide 3.10: Service Detection & Banner Grabbing

**Title:** Service Detection and Banner Grabbing

**What is Banner Grabbing?**
- Connecting to a service and reading its welcome banner
- Identifies service type and version
- Helps prioritize vulnerabilities

**Common Service Banners:**

| Port | Service | Example Banner |
|------|---------|----------------|
| 22 | SSH | `SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.6` |
| 80 | HTTP | `HTTP/1.1 200 OK\r\nServer: nginx/1.18.0` |
| 443 | HTTPS | TLS handshake information |
| 25 | SMTP | `220 smtp.example.com ESMTP Postfix` |

**Banner Grabbing Code:**
```python
def grab_banner(ip, port, timeout=2):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        sock.connect((ip, port))
        
        # Service-specific probes
        probes = {
            22: b"SSH-2.0-Scapy\r\n",
            80: b"HEAD / HTTP/1.0\r\n\r\n",
            443: b"HEAD / HTTP/1.0\r\n\r\n",
            25: b"EHLO test\r\n",
            21: b"USER anonymous\r\n",
        }
        
        if port in probes:
            sock.send(probes[port])
        
        banner = sock.recv(1024).decode('utf-8', errors='ignore')
        sock.close()
        return banner.strip()
    except:
        return None
```

**Talking Points:**
- Banners identify service versions
- Version information helps assess vulnerabilities
- Some services hide or modify banners

---

## Module 4: Packet Sniffing & Traffic Analysis

---

### Slide 4.0: Module 4 Overview

**Title:** Module 4: Packet Sniffing & Traffic Analysis

**Learning Objectives:**
- ✅ Real-time packet capture with `sniff()`
- ✅ BPF filtering at kernel level
- ✅ Protocol-specific analysis
- ✅ HTTP request/response tracking
- ✅ DNS monitoring with caching
- ✅ Traffic statistics and dashboards

**Topics:**
1. Packet Sniffing and Filtering
2. Protocol-Specific Deep Analysis
3. Traffic Statistics Engine
4. Live Monitoring Dashboard

**Visual:** Sniffing pipeline diagram

**Talking Points:**
- Sniffing is passive observation
- Filtering early is key to performance
- Protocol analysis reveals application behavior

---

### Slide 4.1: The Sniff() Function

**Title:** Packet Sniffing with `sniff()`

**Basic Usage:**
```python
from scapy.all import sniff

# Capture 10 packets
packets = sniff(count=10)

# Capture with filter
packets = sniff(filter="tcp port 80", count=10)

# Capture with callback
def process_packet(packet):
    print(packet.summary())

sniff(prn=process_packet, count=10)

# Capture with timeout
packets = sniff(timeout=10)  # 10 seconds
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `iface` | Interface to sniff on |
| `count` | Number of packets |
| `prn` | Callback function |
| `filter` | BPF filter |
| `timeout` | Stop after N seconds |
| `store` | Store packets in memory |
| `promisc` | Promiscuous mode |

**Talking Points:**
- Sniffing captures packets from the network
- Use `store=False` for memory efficiency
- `prn` callback processes each packet

---

### Slide 4.2: BPF Filter Reference

**Title:** BPF Filter Examples

**Protocol Filters:**
| Filter | Description |
|--------|-------------|
| `tcp` | TCP packets only |
| `udp` | UDP packets only |
| `icmp` | ICMP packets only |
| `arp` | ARP packets only |
| `ip` | IPv4 packets only |

**Host Filters:**
| Filter | Description |
|--------|-------------|
| `host 192.168.1.100` | Traffic to/from IP |
| `src host 192.168.1.100` | Traffic from IP |
| `dst host 192.168.1.100` | Traffic to IP |
| `net 192.168.0.0/16` | Traffic to/from network |

**Port Filters:**
| Filter | Description |
|--------|-------------|
| `port 80` | TCP or UDP port 80 |
| `tcp port 80` | TCP port 80 |
| `udp port 53` | UDP port 53 |
| `src port 12345` | Source port 12345 |

**Combined Filters:**
```python
sniff(filter="tcp port 80 and host 192.168.1.100")
sniff(filter="(tcp or udp) and port 53")
sniff(filter="not arp and not icmp")
```

**Talking Points:**
- BPF filters operate at kernel level
- Reduce captured packet volume dramatically
- Filter as early as possible

---

### Slide 4.3: Protocol Analyzer

**Title:** Building a Protocol Analyzer

**Supported Protocols:**
- HTTP (requests and responses)
- DNS (queries and responses)
- DHCP (DORA sequence)
- ARP (requests and replies)
- TLS (handshakes)

**HTTP Analysis Code:**
```python
def analyze_http(packet):
    if not packet.haslayer(Raw):
        return
    
    payload = bytes(packet[Raw])
    try:
        http_data = payload.decode('utf-8', errors='ignore')
        
        # Check for HTTP request
        if http_data.startswith(('GET', 'POST', 'PUT', 'DELETE')):
            lines = http_data.split('\r\n')
            if lines:
                print(f"[HTTP] Request: {lines[0]}")
                # Extract host
                for line in lines:
                    if line.lower().startswith('host:'):
                        print(f"  Host: {line.split(':', 1)[1].strip()}")
                        break
        
        # Check for HTTP response
        elif http_data.startswith('HTTP/'):
            lines = http_data.split('\r\n')
            if lines:
                print(f"[HTTP] Response: {lines[0]}")
                
    except:
        pass
```

**DNS Analysis Code:**
```python
def analyze_dns(packet):
    if not packet.haslayer(DNS):
        return
    
    dns = packet[DNS]
    
    if dns.qr == 0:  # Query
        if dns.qd:
            query_name = dns.qd.qname.decode('utf-8') if dns.qd.qname else 'Unknown'
            print(f"[DNS] Query: {query_name}")
    
    elif dns.qr == 1:  # Response
        answers = []
        if dns.an:
            for answer in dns.an:
                if isinstance(answer, DNSRR):
                    ans_name = answer.rrname.decode('utf-8') if answer.rrname else 'Unknown'
                    ans_data = answer.rdata
                    answers.append(f"{ans_name} -> {ans_data}")
            if answers:
                print(f"[DNS] Response: {', '.join(answers)}")
```

**Talking Points:**
- Protocol analysis extracts application-level data
- HTTP analysis reveals web requests
- DNS analysis identifies domain lookups

---

### Slide 4.4: Traffic Statistics Engine

**Title:** Building a Traffic Statistics Engine

**Features:**
- Protocol distribution
- Top talkers (IP addresses)
- Top ports
- Flow tracking
- Packet/byte rates
- TCP flag statistics

**Data Structures:**
```python
class TrafficStatsEngine:
    def __init__(self):
        self.protocol_counts = defaultdict(int)
        self.src_ips = defaultdict(int)
        self.dst_ips = defaultdict(int)
        self.tcp_ports = defaultdict(int)
        self.udp_ports = defaultdict(int)
        self.tcp_flags = defaultdict(int)
        self.flows = defaultdict(lambda: {'packets': 0, 'bytes': 0})
    
    def packet_callback(self, packet):
        # Update protocol counts
        if packet.haslayer(TCP):
            self.protocol_counts['TCP'] += 1
        elif packet.haslayer(UDP):
            self.protocol_counts['UDP'] += 1
        
        # Update IP talkers
        if packet.haslayer(IP):
            ip = packet[IP]
            self.src_ips[ip.src] += 1
            self.dst_ips[ip.dst] += 1
        
        # Update flow
        if packet.haslayer(IP) and packet.haslayer(TCP):
            ip = packet[IP]
            tcp = packet[TCP]
            flow_key = f"{ip.src}:{tcp.sport}->{ip.dst}:{tcp.dport}"
            self.flows[flow_key]['packets'] += 1
            self.flows[flow_key]['bytes'] += len(packet)
```

**Talking Points:**
- Efficient data structures are key to performance
- Deques and defaultdicts optimize memory usage
- Flow tracking enables conversation analysis

---

### Slide 4.5: DNS Monitor

**Title:** DNS Monitor with Caching

**Features:**
- Real-time DNS monitoring
- Query/response tracking
- DNS caching
- Query rate monitoring
- Suspicious domain detection
- Domain blocking

**DNS Cache:**
```python
class DNSMonitor:
    def __init__(self, cache_ttl=300):
        self.cache = {}
        self.cache_ttl = cache_ttl
        self.queries = []
        self.responses = []
    
    def cache_lookup(self, domain):
        if domain in self.cache:
            entry = self.cache[domain]
            if time.time() - entry['timestamp'] < self.cache_ttl:
                return entry['data']
            else:
                del self.cache[domain]
        return None
    
    def cache_store(self, domain, data):
        self.cache[domain] = {
            'data': data,
            'timestamp': time.time()
        }
```

**Suspicious Domain Detection:**
```python
suspicious_patterns = {
    'random_subdomain': re.compile(r'^[a-z0-9]{8,}\.', re.IGNORECASE),
    'long_domain': re.compile(r'.{50,}\.'),
    'base64_domain': re.compile(r'^[A-Za-z0-9+/]{20,}\=*\.'),
    'dynamic_dns': re.compile(r'(dyndns|no-ip|ddns)\.', re.IGNORECASE)
}
```

**Talking Points:**
- DNS monitoring reveals what domains are being resolved
- Caching improves performance
- Anomaly detection identifies suspicious patterns

---

### Slide 4.6: DHCP Analyzer

**Title:** DHCP Analyzer (DORA Tracking)

**DORA Sequence:**

```
Client (0.0.0.0)                DHCP Server (192.168.1.1)
    │                                    │
    │        1. DISCOVER                 │
    │        UDP: 68 -> 67               │
    │        ───────────────────────────>│
    │                                    │
    │        2. OFFER                    │
    │        UDP: 67 -> 68               │
    │        <───────────────────────────│
    │                                    │
    │        3. REQUEST                  │
    │        UDP: 68 -> 67               │
    │        ───────────────────────────>│
    │                                    │
    │        4. ACKNOWLEDGE              │
    │        UDP: 67 -> 68               │
    │        <───────────────────────────│
```

**Scapy Analysis:**
```python
def process_dhcp_packet(packet):
    if not packet.haslayer(DHCP):
        return
    
    dhcp = packet[DHCP]
    bootp = packet[BOOTP]
    
    # Get DHCP message type
    msg_type = None
    for option in dhcp.options:
        if isinstance(option, tuple) and option[0] == 'message-type':
            msg_type = option[1]
            break
    
    type_names = {
        1: "DISCOVER",
        2: "OFFER",
        3: "REQUEST",
        5: "ACK",
        6: "NAK"
    }
    
    print(f"[DHCP] {type_names.get(msg_type, 'Unknown')} from {bootp.chaddr}")
```

**Talking Points:**
- DHCP DORA sequence assigns IP addresses
- Tracking DORA reveals network configuration
- Rogue DHCP detection identifies unauthorized servers

---

### Slide 4.7: Live Traffic Dashboard

**Title:** Live Traffic Dashboard

**Components:**
- Real-time packet rate
- Protocol distribution
- Top talkers
- Top ports
- Live updates

**Dashboard Display:**
```
LIVE TRAFFIC DASHBOARD - 2024-01-01 10:00:00
======================================================================
Interface: eth0
Total Packets: 15,234
Total Bytes: 12,456,789
Packet Rate: 1,234 pkts/sec
Byte Rate: 1.2 MB/sec

Protocol Distribution:
---------------------------------------------------------------
  TCP      : 8,456 (55.5%) ████████████████████
  UDP      : 4,234 (27.8%) █████████
  ICMP     : 1,234 (8.1%)  ███
  ARP      : 856 (5.6%)    ██
  Other    : 454 (3.0%)    █

Top Sources (by packets):
---------------------------------------------------------------
  192.168.1.100    : 3,456
  192.168.1.101    : 2,345
  192.168.1.102    : 1,234

Top Destination Ports:
---------------------------------------------------------------
  443 (HTTPS)      : 3,456
  80 (HTTP)        : 2,345
  53 (DNS)         : 1,234
```

**Talking Points:**
- Live dashboards provide real-time visibility
- Protocol distribution shows traffic mix
- Top talkers identify active hosts

---

## Module 5: Active Network Manipulation & Security Testing

---

### Slide 5.0: Module 5 Overview

**Title:** Module 5: Active Network Manipulation & Security Testing

**Learning Objectives:**
- ✅ ARP spoofing detection
- ✅ DNS monitoring and anomaly detection
- ✅ DHCP rogue server detection
- ✅ Packet injection and replay
- ✅ Security assessment tools
- ✅ Defensive monitoring systems

**Topics:**
1. ARP Spoofing Detection
2. Packet Injection and Replay
3. DNS Security Monitoring
4. DHCP Security Monitoring

**Visual:** Attack vs detection diagram

**Talking Points:**
- This module covers both offensive techniques (educational) and defensive tools
- All active techniques are for authorized labs only
- Focus on building detectors, not attacks

---

### Slide 5.1: ARP Spoofing Detection

**Title:** ARP Spoofing Detection

**What is ARP Spoofing?**
- Attacker sends forged ARP replies
- Claims to be the gateway or another host
- Traffic is intercepted (MITM attack)

**Normal ARP:**
```
"Who has 192.168.1.1?" (ARP Request)
"I am 192.168.1.1. My MAC is aa:bb:cc:dd:ee:ff" (ARP Reply)
```

**ARP Spoofing:**
```
"Who has 192.168.1.1?" (ARP Request)
"I am 192.168.1.1. My MAC is 00:11:22:33:44:55" (Fake Reply)
```

**Detection Indicators:**
- IP with changing MAC addresses
- Duplicate IP addresses
- High rate of ARP replies
- Gratuitous ARP from unexpected sources

**Detection Code:**
```python
class ARPSpoofingDetector:
    def __init__(self):
        self.ip_mac_mapping = {}
        self.suspicious_activity = []
    
    def process_arp_packet(self, packet):
        if not packet.haslayer(ARP):
            return
        
        arp = packet[ARP]
        src_ip = arp.psrc
        src_mac = arp.hwsrc
        
        # Check for MAC change
        if src_ip in self.ip_mac_mapping:
            if self.ip_mac_mapping[src_ip] != src_mac:
                self.suspicious_activity.append({
                    'type': 'MAC_Change',
                    'ip': src_ip,
                    'old_mac': self.ip_mac_mapping[src_ip],
                    'new_mac': src_mac
                })
                print(f"⚠️ MAC change for {src_ip}: {old_mac} -> {src_mac}")
        
        self.ip_mac_mapping[src_ip] = src_mac
```

**Talking Points:**
- ARP spoofing enables man-in-the-middle attacks
- Detection focuses on MAC changes and duplicates
- Active probing validates IP-MAC mappings

---

### Slide 5.2: Packet Injection and Replay

**Title:** Packet Injection and Replay

**Safety Controls:**

| Control | Description |
|---------|-------------|
| Authorization | Target whitelisting |
| Rate Limiting | Prevent flooding |
| Size Limits | Prevent oversized packets |
| Logging | Audit trail |
| Confirmation | User verification |

**Injection Framework:**
```python
class PacketInjector:
    def __init__(self, authorized_targets=None):
        self.authorized_targets = authorized_targets or ['127.0.0.1']
        self.rate_limit = 10  # Packets per second
    
    def is_authorized(self, target):
        return target in self.authorized_targets
    
    def inject_packet(self, packet):
        target = None
        if packet.haslayer(IP):
            target = packet[IP].dst
        
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        # Rate limiting
        time.sleep(1.0 / self.rate_limit)
        send(packet)
        return True
```

**Packet Replay:**
```python
class PacketReplay:
    def __init__(self, rate=100, loop=False):
        self.rate = rate
        self.loop = loop
    
    def replay_pcap(self, pcap_file):
        packets = rdpcap(pcap_file)
        for packet in packets:
            send(packet)
            time.sleep(1.0 / self.rate)
```

**Talking Points:**
- Always use authorization and safety controls
- Rate limiting prevents network disruption
- Packet replay is useful for testing

---

### Slide 5.3: DNS Security Monitoring

**Title:** DNS Security Monitoring

**DNS Attack Vectors:**
- DNS tunneling (data exfiltration)
- DNS cache poisoning
- DNS amplification (DDoS)
- Domain generation algorithms (DGAs)

**Detection Indicators:**

| Indicator | Description | Severity |
|-----------|-------------|----------|
| Long Domain | Domain > 50 chars | High |
| Random Subdomain | Random alphanumeric | High |
| Base64 in Domain | Base64 encoded data | High |
| High Query Rate | > 100 queries/sec | Medium |
| Dynamic DNS | dyndns, no-ip domains | Medium |
| Domain Blocklist | Known malicious | High |

**Monitoring Code:**
```python
def analyze_dns_query(domain):
    suspicious = []
    
    if len(domain) > 50:
        suspicious.append('long_domain')
    
    if re.search(r'^[a-z0-9]{8,}\.', domain):
        suspicious.append('random_subdomain')
    
    if re.search(r'^[A-Za-z0-9+/]{20,}\=*\.', domain):
        suspicious.append('base64_domain')
    
    if re.search(r'(dyndns|no-ip|ddns)\.', domain):
        suspicious.append('dynamic_dns')
    
    return suspicious
```

**Talking Points:**
- DNS is often used for covert channels
- Long/random domains are suspicious
- Rate analysis detects DNS floods

---

### Slide 5.4: DHCP Security Monitoring

**Title:** DHCP Security Monitoring

**Rogue DHCP Server Detection:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    ROGUE DHCP DETECTION                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Authorized DHCP Server: 192.168.1.1                           │
│  MAC: aa:bb:cc:dd:ee:ff                                        │
│                                                                 │
│  Rogue DHCP Server Detected: 192.168.1.100                     │
│  MAC: 00:11:22:33:44:55                                        │
│                                                                 │
│  ⚠️ Alert: Rogue DHCP server offering IPs on the network!     │
│                                                                 │
│  Detection Method:                                              │
│  1. Track DHCP servers seen on network                         │
│  2. Compare with authorized list                               │
│  3. Alert if unknown server is offering IPs                    │
└─────────────────────────────────────────────────────────────────┘
```

**Detection Code:**
```python
class DHCPAnalyzer:
    def __init__(self):
        self.authorized_servers = set()
        self.dhcp_servers = {}
        self.potential_rogue = []
    
    def process_dhcp_offer(self, packet):
        server_ip = packet[IP].src
        server_mac = packet[Ether].src
        
        if server_ip not in self.dhcp_servers:
            self.dhcp_servers[server_ip] = {
                'mac': server_mac,
                'offers': 0,
                'first_seen': datetime.now()
            }
        
        self.dhcp_servers[server_ip]['offers'] += 1
        
        # Check if rogue
        if self.authorized_servers and server_ip not in self.authorized_servers:
            self.potential_rogue.append({
                'server_ip': server_ip,
                'server_mac': server_mac
            })
            print(f"⚠️ Potential rogue DHCP server: {server_ip}")
```

**Talking Points:**
- Rogue DHCP servers can disrupt networks
- Detection compares observed servers with authorized list
- Offers indicate active DHCP servers

---

## Module 6: Automation, Performance & Custom Protocols

---

### Slide 6.0: Module 6 Overview

**Title:** Module 6: Automation, Performance & Custom Protocols

**Learning Objectives:**
- ✅ High-performance packet processing
- ✅ Multi-threaded and async tools
- ✅ Custom protocol dissectors
- ✅ Production optimization
- ✅ Plugin architecture

**Topics:**
1. High-Performance Packet Processing
2. Asynchronous Processing
3. Efficient Data Structures
4. Custom Protocol Development

**Visual:** Pipeline diagram

**Talking Points:**
- This module takes you from prototype to production
- Performance matters for real-world tools
- Custom protocols extend Scapy's capabilities

---

### Slide 6.1: High-Performance Capture

**Title:** High-Performance Capture Engine

**Producer-Consumer Pattern:**

```
┌─────────────────────────────────────────────────────────────────┐
│              PACKET PROCESSING PIPELINE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │ Producer │───>│  Queue   │───>│ Consumer │───>│ Output   │ │
│  │ (Sniff)  │    │ (Buffer) │    │ (Process)│    │          │ │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│                                                                 │
│  • Producer: Captures packets                                  │
│  • Queue: Manages flow between stages                          │
│  • Consumer: Processes in parallel                             │
│  • Output: Stores results                                      │
└─────────────────────────────────────────────────────────────────┘
```

**Code:**
```python
class HighPerformanceCapture:
    def __init__(self, buffer_size=10000, max_workers=4):
        self.packet_queue = queue.Queue(maxsize=buffer_size)
        self.max_workers = max_workers
        self.running = False
    
    def packet_callback(self, packet):
        try:
            self.packet_queue.put_nowait(packet)
        except queue.Full:
            self.stats['packets_dropped'] += 1
    
    def worker_thread(self, worker_id):
        while self.running:
            try:
                packet = self.packet_queue.get(timeout=0.5)
                self.process_packet(packet)
                self.packet_queue.task_done()
            except queue.Empty:
                continue
    
    def start_capture(self):
        self.running = True
        for i in range(self.max_workers):
            worker = threading.Thread(target=self.worker_thread, args=(i,))
            worker.start()
        
        sniff(prn=self.packet_callback, store=False)
```

**Talking Points:**
- Separate capture from processing for performance
- Multiple workers process in parallel
- Queue size prevents memory overflow

---

### Slide 6.2: Asynchronous Processing

**Title:** Asynchronous Packet Processing

**asyncio Benefits:**
- Non-blocking operations
- Concurrent processing
- Efficient resource usage
- Scalable performance

**Async Processor:**
```python
import asyncio

class AsyncPacketProcessor:
    def __init__(self, max_concurrent=10, batch_size=100):
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.batch_size = batch_size
    
    async def process_packet(self, packet):
        async with self.semaphore:
            # Asynchronous processing
            await asyncio.sleep(0.001)  # Simulate work
            # Extract information
            return packet.summary()
    
    async def process_batch(self, packets):
        tasks = [self.process_packet(p) for p in packets]
        return await asyncio.gather(*tasks)
    
    async def process_pcap(self, pcap_file):
        packets = rdpcap(pcap_file)
        for i in range(0, len(packets), self.batch_size):
            batch = packets[i:i+self.batch_size]
            await self.process_batch(batch)
```

**Talking Points:**
- asyncio enables concurrent processing
- Semaphores control concurrency
- Batch processing reduces overhead

---

### Slide 6.3: Efficient Data Structures

**Title:** Efficient Data Structures

**Memory Optimization Techniques:**

| Technique | Benefit | Implementation |
|-----------|---------|----------------|
| Packet Summarization | Reduce memory | Store only essential fields |
| Fixed-size Arrays | Predictable memory | `array` module |
| Deque with maxlen | Limited memory | `collections.deque` |
| Bloom Filters | Fast membership | Bit array with hashing |
| Batch Processing | Reduce overhead | Process in chunks |

**Efficient Storage:**
```python
class EfficientPacketStorage:
    def __init__(self, max_packets=1000000):
        self.packet_buffer = deque(maxlen=max_packets)
        self.timestamps = deque(maxlen=max_packets)
        self.packet_lengths = deque(maxlen=max_packets)
        self.ip_pairs = defaultdict(int)
        
        # Bloom filter for IPs
        self.ip_bloom = bytearray(1024)
    
    def add_to_bloom(self, ip):
        # Simple hash functions
        h1 = hash(ip) % len(self.ip_bloom)
        h2 = (hash(ip) * 3 + 1) % len(self.ip_bloom)
        h3 = (hash(ip) * 5 + 2) % len(self.ip_bloom)
        self.ip_bloom[h1] = 1
        self.ip_bloom[h2] = 1
        self.ip_bloom[h3] = 1
    
    def ip_in_bloom(self, ip):
        h1 = hash(ip) % len(self.ip_bloom)
        h2 = (hash(ip) * 3 + 1) % len(self.ip_bloom)
        h3 = (hash(ip) * 5 + 2) % len(self.ip_bloom)
        return (self.ip_bloom[h1] == 1 and 
                self.ip_bloom[h2] == 1 and 
                self.ip_bloom[h3] == 1)
```

**Talking Points:**
- Efficient data structures prevent memory exhaustion
- Bloom filters provide fast membership tests
- Deques with maxlen limit memory usage

---

### Slide 6.4: Custom Protocol Development

**Title:** Building Custom Protocols in Scapy

**The Packet Class:**

```python
from scapy.packet import Packet
from scapy.fields import *

class MyCustomProtocol(Packet):
    name = "MyCustomProtocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        ByteField("flags", 0),
        ShortField("length", 0),
        IntField("sequence", 0),
        IntField("timestamp", 0)
    ]
    
    def mysummary(self):
        return f"MyProtocol v{self.version} type={self.type} seq={self.sequence}"
```

**Field Types:**

| Field Type | Description | Size |
|------------|-------------|------|
| `ByteField` | Single byte | 1 byte |
| `ShortField` | 16-bit integer | 2 bytes |
| `IntField` | 32-bit integer | 4 bytes |
| `LongField` | 64-bit integer | 8 bytes |
| `IPField` | IP address | 4 bytes |
| `MACField` | MAC address | 6 bytes |
| `StrFixedLenField` | Fixed string | Variable |
| `StrLenField` | Length-prefixed | Variable |

**Protocol Binding:**
```python
# Bind to IP protocol
bind_layers(IP, MyCustomProtocol, proto=250)

# Bind based on field value
bind_layers(MyCustomProtocol, CustomData, type=0)
bind_layers(MyCustomProtocol, CustomResponse, type=1)

# Test binding
pkt = IP(proto=250) / MyCustomProtocol()
assert pkt.haslayer(MyCustomProtocol)
```

**Talking Points:**
- Custom protocols extend Scapy's capabilities
- Bindings tell Scapy how to dissect packets
- Field types define protocol structure

---

### Slide 6.5: Protocol Fuzzing

**Title:** Protocol Fuzzing

**What is Fuzzing?**
- Sending malformed or unexpected data
- Testing protocol robustness
- Finding security vulnerabilities

**Fuzzing Strategy:**
```python
class ProtocolFuzzer:
    def __init__(self, protocol_class, iterations=100):
        self.protocol_class = protocol_class
        self.iterations = iterations
    
    def mutate_field(self, field_name, field_value):
        # Random mutations
        if random.random() < 0.3:
            # Bit flip
            return field_value ^ (1 << random.randint(0, 31))
        elif random.random() < 0.3:
            # Random value
            return random.randint(0, 0xFFFFFFFF)
        else:
            # Boundary value
            return field_value + random.randint(-100, 100)
    
    def generate_malformed(self, base_packet):
        pkt = base_packet.copy()
        # Mutate random field
        field = random.choice(pkt.fields_desc)
        current = getattr(pkt, field.name)
        setattr(pkt, field.name, self.mutate_field(field.name, current))
        return pkt
    
    def run_fuzzing(self):
        base_packet = self.protocol_class()
        for i in range(self.iterations):
            fuzzed = self.generate_malformed(base_packet)
            raw = bytes(fuzzed)
            try:
                dissected = self.protocol_class(raw)
                print(f"✓ Iteration {i+1}: Valid dissection")
            except Exception as e:
                print(f"✗ Iteration {i+1}: Error - {e}")
```

**Talking Points:**
- Fuzzing finds edge cases and vulnerabilities
- Malformed packets test protocol robustness
- Iterative approach covers many scenarios

---

### Slide 6.6: Capstone: Network Security Toolkit

**Title:** Capstone: Network Security Toolkit

**Complete Architecture:**

```
┌─────────────────────────────────────────────────────────────────┐
│                   NETWORK SECURITY TOOLKIT                     │
│                   (Command-Line Interface)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │  Discovery   │  │  Analysis    │  │   Monitoring       │   │
│  │  Engines     │  │  Engines     │  │   Pipelines        │   │
│  │              │  │              │  │                    │   │
│  │ • ARP Scanner│  │ • PCAP Reader│  │ • Live Sniffer    │   │
│  │ • Ping Suite │  │ • Protocol   │  │ • BPF Filtering   │   │
│  │ • Traceroute │  │   Dissector  │  │ • Flow Reassembly │   │
│  │ • Port Scan  │  │ • Custom     │  │ • Statistics      │   │
│  │   (TCP/UDP)  │  │   Protocol   │  │ • Anomaly         │   │
│  │              │  │   Parser     │  │   Detection       │   │
│  └──────┬───────┘  └──────┬───────┘  └────────┬───────────┘   │
│         │                 │                     │               │
│         └─────────────────┼─────────────────────┘               │
│                           │                                     │
│                ┌──────────▼──────────┐                         │
│                │  Plugin Framework    │                         │
│                │  (Extensible Core)   │                         │
│                └──────────────────────┘                         │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │  Export &    │  │  Reporting   │  │  Visualization     │   │
│  │  Logging     │  │  Engine      │  │  Engine            │   │
│  └──────────────┘  └──────────────┘  └────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Usage Examples:**
```bash
# Discover hosts
nstool scan 192.168.1.0/24

# Capture live traffic
nstool sniff -i eth0 -f "tcp port 80"

# Analyze PCAP
nstool analyze capture.pcap -e stats.json

# Custom protocol detection
nstool protocol -p MyProtocol -f custom.pcap
```

**Talking Points:**
- The toolkit integrates all modules
- Plugin architecture enables extension
- Command-line interface provides usability

---

## Course Conclusion

---

### Slide C.1: What You've Learned

**Title:** What You've Learned

**Technical Skills:**
- ✅ Packet construction and manipulation
- ✅ Network protocol analysis
- ✅ Port scanning and reconnaissance
- ✅ Traffic sniffing and filtering
- ✅ Custom protocol development
- ✅ Security testing (authorized)
- ✅ Performance optimization
- ✅ Production-ready tooling

**Tools Built:**
- ✅ ARP scanner and monitor
- ✅ Custom ping and traceroute
- ✅ Professional port scanner
- ✅ Protocol analyzer
- ✅ Traffic dashboard
- ✅ ARP spoofing detector
- ✅ Packet replay utility
- ✅ Network Security Toolkit

**Talking Points:**
- You've built professional-grade tools
- Each tool is production-ready
- You can extend all tools further

---

### Slide C.2: Next Steps

**Title:** Your Next Steps

**Practice with Real Data:**
- Download PCAPs from public repositories
- Analyze malware traffic (in isolated VMs)
- Build custom tools for your needs
- Test in authorized environments

**Deepen Your Knowledge:**
- Network forensics (SANS FOR572)
- Threat hunting (MITRE ATT&CK)
- Machine learning for anomaly detection
- Custom protocol reverse engineering

**Certification Paths:**
- Cisco CCNA
- CEH (Certified Ethical Hacker)
- OSCP (Offensive Security)
- GIAC GPEN

**Community Involvement:**
- Contribute to Scapy
- Share your tools on GitHub
- Write blog posts and tutorials
- Mentor others

**Talking Points:**
- The learning never stops
- Practice makes perfect
- Share your knowledge with others
- Always stay ethical and legal

---

### Slide C.3: Ethical Reminder

**Title:** Ethical Reminder

**Core Principle:**

> **Never test on a system or network without explicit written authorization.**

**Rules to Remember:**
1. **Permission is everything**
2. **Practice in isolated labs**
3. **Build defensive tools**
4. **Disclose responsibly**
5. **Stay within scope**

**Resources:**
- ISC² Code of Ethics
- SANS Code of Ethics
- OWASP Security Guidelines
- MITRE ATT&CK Framework

**Talking Points:**
- Your skills are powerful
- Use them responsibly
- Be a force for good
- Protect, don't attack

---

### Slide C.4: Thank You

**Title:** Thank You!

**Congratulations!**
You've completed **Mastering Network Packet Crafting with Scapy**

**What You Can Do Now:**
- Build custom network tools
- Analyze network traffic
- Detect security threats
- Extend Scapy with new protocols
- Contribute to the security community

**Resources:**
- Scapy Documentation: [https://scapy.readthedocs.io/](https://scapy.readthedocs.io/)
- Wireshark Samples: [https://wiki.wireshark.org/SampleCaptures](https://wiki.wireshark.org/SampleCaptures)
- Your GitHub repository with all your tools

**Stay Connected:**
- Share your projects
- Contribute to open source
- Help others learn

---
