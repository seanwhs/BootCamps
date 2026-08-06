# Mastering Network Packet Crafting with Scapy
## Trainer Guide

## Overview

This trainer guide provides everything you need to successfully deliver the **Mastering Network Packet Crafting with Scapy** series. It includes:

- **Course Planning**: Scheduling, logistics, and preparation
- **Teaching Strategies**: How to effectively deliver each module
- **Module Breakdowns**: Detailed teaching notes for each section
- **Lab Solutions**: Complete solutions for all lab exercises
- **Assessment Tools**: Quizzes, tests, and evaluation rubrics
- **Troubleshooting Guide**: Common issues and solutions
- **Resources**: Additional materials and references

---

## Table of Contents

1. [Course Overview](#course-overview)
2. [Course Logistics](#course-logistics)
3. [Teaching Strategies](#teaching-strategies)
4. [Module 1: Foundations of Packet Crafting](#module-1-foundations-of-packet-crafting)
5. [Module 2: Layer 2 & Layer 3 Operations](#module-2-layer-2--layer-3-operations)
6. [Module 3: Transport Layer Protocols & Reconnaissance](#module-3-transport-layer-protocols--reconnaissance)
7. [Module 4: Packet Sniffing, Filtering & Traffic Analysis](#module-4-packet-sniffing-filtering--traffic-analysis)
8. [Module 5: Active Network Manipulation & Security Testing](#module-5-active-network-manipulation--security-testing)
9. [Module 6: Automation, Performance & Custom Protocols](#module-6-automation-performance--custom-protocols)
10. [Capstone Project](#capstone-project)
11. [Assessment and Evaluation](#assessment-and-evaluation)
12. [Troubleshooting Guide](#troubleshooting-guide)
13. [Resources and References](#resources-and-references)

---

## Course Overview

### Course Description

This comprehensive course teaches developers, cybersecurity professionals, and network engineers how to create, manipulate, analyze, and automate network packets using Python and Scapy. Participants build working tools for reconnaissance, diagnostics, monitoring, and authorized security testing.

### Target Audience

| Role | Relevance |
|------|-----------|
| **Cybersecurity Professionals** | Build custom tools for authorized testing |
| **Penetration Testers** | Craft packets for security assessments |
| **SOC Analysts** | Detect anomalies and build monitoring |
| **Network Engineers** | Automate diagnostics and analysis |
| **Python Developers** | Expand into networking domain |
| **Students** | Practical protocol understanding |

### Prerequisites

| Topic | Level | Details |
|-------|-------|---------|
| **Python** | Intermediate | Variables, functions, classes, list comprehensions |
| **Linux** | Basic | Command-line navigation, sudo, package management |
| **TCP/IP** | Working knowledge | IP addressing, ports, routing basics |

### Learning Outcomes

Upon completing this course, participants will be able to:

1. Master Scapy's architecture, packet model, and the `/` operator for protocol stacking
2. Craft, modify, transmit, receive, and dissect packets across Layers 2-7
3. Build custom implementations of classic network utilities (ping, traceroute, ARP scanners, port scanners)
4. Perform deep protocol analysis of Ethernet, ARP, IP, ICMP, TCP, UDP, DNS, DHCP, HTTP, and more
5. Capture, filter, and process live and offline traffic with efficient Python pipelines
6. Develop custom protocol dissectors for proprietary or experimental formats
7. Automate network reconnaissance, traffic analysis, and basic security monitoring
8. Construct modular, reusable security assessment and diagnostic tools
9. Apply packet-crafting techniques responsibly within authorized environments only

### Course Structure

```
Module 1: Foundations of Packet Crafting (3-4 hours)
    └── Environment setup, packet stacking, PCAP operations

Module 2: Layer 2 & Layer 3 Operations (4-5 hours)
    └── Ethernet, ARP, IP, ICMP, ping, traceroute

Module 3: Transport Layer Protocols & Reconnaissance (4-5 hours)
    └── TCP, UDP, port scanning, banner grabbing

Module 4: Packet Sniffing, Filtering & Traffic Analysis (4-5 hours)
    └── Sniffing, BPF, HTTP, DNS, DHCP analysis

Module 5: Active Network Manipulation & Security Testing (3-4 hours)
    └── ARP detection, packet injection, replay, payloads

Module 6: Automation, Performance & Custom Protocols (3-4 hours)
    └── High-performance, async, custom protocols

Capstone Project (2-3 hours)
    └── Enterprise Network Analysis Toolkit
```

---

## Course Logistics

### Recommended Schedule

**Full Course (5 days):**

| Day | Morning (3 hours) | Afternoon (3 hours) |
|-----|-------------------|---------------------|
| 1 | Module 1: Foundations | Module 1: Foundations (continued) |
| 2 | Module 2: Layer 2 & 3 | Module 2: Layer 2 & 3 (continued) |
| 3 | Module 3: Transport Layer | Module 3: Transport Layer (continued) |
| 4 | Module 4: Sniffing & Analysis | Module 4: Sniffing & Analysis (continued) |
| 5 | Module 5 & 6: Advanced Topics | Capstone Project |

**Part-Time (10 sessions of 2.5 hours):**

| Session | Topic |
|---------|-------|
| 1 | Module 1.1: Environment Setup |
| 2 | Module 1.2: Packet Stacking Model |
| 3 | Module 1.3: PCAP Operations |
| 4 | Module 2.1: Ethernet & ARP |
| 5 | Module 2.2: IP & ICMP |
| 6 | Module 3.1: TCP & UDP |
| 7 | Module 3.2: Port Scanning |
| 8 | Module 4.1: Sniffing & Analysis |
| 9 | Module 4.2: Protocol Analysis |
| 10 | Module 5-6: Advanced & Capstone |

### Classroom Setup

**Hardware Requirements:**

| Item | Requirement |
|------|-------------|
| **Instructor Machine** | Modern laptop/desktop with 16GB+ RAM |
| **Student Machines** | 8GB+ RAM, 20GB+ free disk |
| **Network** | Isolated lab network (virtual or physical) |
| **Virtualization** | VMware Workstation, VirtualBox, or WSL2 |
| **Display** | Projector for code demonstrations |

**Software Requirements:**

| Software | Version | Purpose |
|----------|---------|---------|
| **Python** | 3.8+ | Programming language |
| **Scapy** | Latest | Packet crafting library |
| **Wireshark** | Latest | Packet analysis |
| **tcpdump/tshark** | Latest | Command-line capture |
| **VirtualBox/VMware** | Latest | Lab isolation |
| **Visual Studio Code** | Latest | Recommended IDE |

### Pre-Course Checklist

**Instructor:**
- [ ] Verify all lab VMs are working
- [ ] Test internet connectivity (for PCAP downloads)
- [ ] Ensure Scapy is installed and working
- [ ] Prepare slide decks and code examples
- [ ] Set up lab network environment
- [ ] Print lab books (or provide digital copies)

**Students:**
- [ ] Complete pre-course survey
- [ ] Install Python 3.8+
- [ ] Install VirtualBox/VMware (if required)
- [ ] Download course materials
- [ ] Review prerequisites (Python, Linux, TCP/IP)
- [ ] Complete primers (provided)

---

## Teaching Strategies

### Effective Delivery Techniques

#### 1. Code-Along Approach

**Description:** Students type code alongside the instructor.

**Benefits:**
- Active learning (not passive listening)
- Immediate error correction
- Muscle memory for syntax
- Ownership of the code

**Implementation:**
- Share code in blocks (not all at once)
- Allow time for typing
- Walk through each line
- Encourage questions
- Watch for common errors

**Example:**
```
1. "Let's import Scapy together..."
   Instructor types: from scapy.all import *
   Students type: from scapy.all import *

2. "Now let's create our first packet..."
   Instructor types: pkt = IP(dst="8.8.8.8")/ICMP()
   Students type: pkt = IP(dst="8.8.8.8")/ICMP()

3. "Let's see what we created..."
   Instructor types: pkt.show()
   Students type: pkt.show()
```

#### 2. The "Two-Pass" Approach

**First Pass:** Walk through code and explain concepts

**Second Pass:** Run the code, show output, verify results

**Example:**
```
Pass 1: "This script builds three types of packets..."
         Explain each section

Pass 2: "Let's run it and see what happens..."
         python3 first_packets.py
         Show packet details in Wireshark
```

#### 3. Live Debugging

**Description:** Deliberately introduce errors and demonstrate debugging.

**Benefits:**
- Students learn error messages
- Build troubleshooting skills
- Normalizes making mistakes

**Implementation:**
1. Write correct code
2. Introduce a common error
3. Run the code
4. Show error message
5. Explain the error and fix it

#### 4. Pair Programming

**Description:** Students work in pairs with one driver and one navigator.

**Benefits:**
- Collaborative learning
- Reduced frustration
- Better code quality
- Peer teaching

**Implementation:**
- Switch roles every 15-20 minutes
- Encourage discussion
- Both should understand the code

#### 5. Concept Before Code

**Description:** Explain the "why" before the "how."

**Example:**
```
WRONG: "Here's how to build a packet..."
RIGHT: "Before we build a packet, let's understand what a packet is...
       Think of it like an onion... Now let's build one with Scapy."
```

### Classroom Management

#### Handling Different Skill Levels

| Student Level | Strategy |
|---------------|----------|
| **Advanced** | Provide challenges, encourage mentoring |
| **Intermediate** | Pair with advanced students, offer tips |
| **Beginner** | Extra support, one-on-one time, additional primers |

#### Common Student Challenges

| Challenge | Solution |
|-----------|----------|
| **Syntax Errors** | Teach error message reading |
| **Import Errors** | Verify environment setup |
| **Permission Denied** | Explain root/sudo requirements |
| **No Response to Packets** | Check interface, filters, target |
| **Checksum Errors** | Explain show2() and auto-calculation |

#### Keeping Students Engaged

- **Break every 45-60 minutes**
- **Mix lecture and hands-on**
- **Show real-world examples**
- **Encourage questions**
- **Celebrate successes**
- **Use humor and analogies**

### Ethical Training Emphasis

**Critical:** Always emphasize ethics throughout the course.

#### Key Messages
1. **Never test without authorization**
2. **Practice only in isolated labs**
3. **Build defensive tools**
4. **Disclose vulnerabilities responsibly**
5. **Stay within authorized scope**

#### How to Reinforce Ethics

| Opportunity | Message |
|-------------|---------|
| **Module 1** | "These skills are powerful. Use them responsibly." |
| **Module 2** | "ARP scanning is for network discovery, not attack." |
| **Module 3** | "Port scanning is reconnaissance. Only do it with permission." |
| **Module 4** | "Sniffing traffic means seeing others' data. Respect privacy." |
| **Module 5** | "Active techniques are for labs only. Never on production." |
| **Module 6** | "Custom protocols can be used for defense, not offense." |

---

## Module 1: Foundations of Packet Crafting

### Module Overview

| Aspect | Details |
|--------|---------|
| **Duration** | 3-4 hours |
| **Key Concepts** | Environment setup, packet stacking, PCAP operations |
| **Key Labs** | Environment setup, building first packets, PCAP analysis |
| **Learning Outcomes** | Install Scapy, build packets, inspect packets, handle PCAPs |

### Detailed Teaching Plan

#### Part 1: Environment Setup (45-60 minutes)

**Topics:**
- Python installation and virtual environments
- Scapy installation
- Project directory structure
- Environment verification
- Raw socket permissions

**Teaching Script:**

```
"Before we can craft packets, we need a proper workshop.
Let's set up our environment step by step..."

[Walk through each installation step]

"Virtual environments are like separate toolboxes.
Each project gets its own tools and dependencies."

[Show directory structure]

"Verification is how we know everything works.
Let's run the verification script together..."

[Run verify_environment.py]

"Root/sudo is needed for raw sockets.
This is like needing the right key to access the network hardware."
```

**Key Points to Emphasize:**
- Virtual environments prevent dependency conflicts
- Root/sudo is required for packet sending
- Wireshark is your best debugging tool
- Project organization matters

**Demo Script:**

```python
# Verify environment
python3 src/verify_environment.py

# Show Scapy is working
python3 -c "from scapy.all import *; print('Scapy works!')"

# Show interfaces
python3 -c "from scapy.all import get_if_list; print(get_if_list())"
```

#### Part 2: Packet Stacking Model (45-60 minutes)

**Topics:**
- The `/` operator (encapsulation)
- Protocol layers
- Building multi-layer packets
- Packet inspection methods

**Teaching Script:**

```
"Think of packets like onions or nesting dolls.
Each layer wraps the one inside it."

[Draw packet diagram]

"The / operator is like saying 'contains' or 'encapsulates.'
Ether() / IP() means 'Ethernet contains IP.'"

[Build example packet]

"Every layer has fields. We can access them with brackets."

[Show field access]

"show() shows everything. summary() gives one line.
show2() calculates checksums and lengths."

[Show each method]
```

**Key Points to Emphasize:**
- Build from outside to inside (Ethernet -> IP -> TCP -> Data)
- The `/` operator stacks layers
- Use `show2()` for checksums
- Access layers with `packet[Layer]`

**Demo Script:**

```python
# Build a packet
pkt = Ether() / IP(dst="8.8.8.8") / ICMP()

# Inspect it
pkt.show()
pkt.summary()
hexdump(pkt)

# Access fields
print(pkt[IP].src)
print(pkt[IP].dst)

# Check for layer
if pkt.haslayer(ICMP):
    print("Has ICMP")

# Calculate checksums
pkt.show2()
```

**Common Student Questions:**

| Question | Answer |
|----------|--------|
| "Why does order matter?" | Outside to inside is how packets are built |
| "What's the difference between show() and show2()?" | show2() auto-calculates checksums and lengths |
| "What does haslayer() do?" | Checks if a packet contains a specific layer |

#### Part 3: PCAP Operations (45-60 minutes)

**Topics:**
- PCAP file format
- Loading PCAPs (`rdpcap()`)
- Saving PCAPs (`wrpcap()`)
- Filtering packets
- Memory-efficient reading (`PcapReader`)

**Teaching Script:**

```
"PCAP files are like video recordings of network traffic.
They capture everything that happened."

[Show PCAP file]

"rdpcap() loads everything into memory.
For large files, use PcapReader to stream."

[Show difference]

"Filtering lets us extract specific packets."

[Show filtering examples]

"Let's build a PCAP analyzer together..."

[Build analyzer step by step]
```

**Key Points to Emphasize:**
- PCAPs are industry-standard
- Use PcapReader for large files
- List comprehensions are efficient for filtering
- Save modified packets to new files

**Demo Script:**

```python
# Load a PCAP
packets = rdpcap("capture.pcap")

# Show info
print(f"Loaded {len(packets)} packets")

# Filter TCP packets
tcp_packets = [p for p in packets if p.haslayer(TCP)]

# Get first packet
first = packets[0]
first.show()

# Save filtered packets
wrpcap("tcp_only.pcap", tcp_packets)

# Memory-efficient reading
from scapy.utils import PcapReader
with PcapReader("large.pcap") as reader:
    for packet in reader:
        process(packet)  # Process one at a time
```

### Lab Solutions

**Lab 1.1: Environment Setup**

```python
#!/usr/bin/env python3
"""
Lab 1.1 Solution: Environment Setup
"""
import sys
import os

print(f"Python version: {sys.version}")
print(f"Current directory: {os.getcwd()}")

try:
    from scapy.all import *
    print(f"✅ Scapy version: {scapy.__version__}")
except ImportError:
    print("❌ Scapy not installed")
    sys.exit(1)

# Test packet creation
try:
    pkt = IP(dst="8.8.8.8") / ICMP()
    print("✅ Packet creation successful")
    print(f"  Summary: {pkt.summary()}")
except Exception as e:
    print(f"❌ Packet creation failed: {e}")
```

**Lab 1.2: Building First Packets**

```python
#!/usr/bin/env python3
"""
Lab 1.2 Solution: First Packets
"""
from scapy.all import *

# Build packets
packets = []

# 1. ICMP Ping
ping = IP(dst="8.8.8.8") / ICMP()
packets.append(ping)

# 2. TCP SYN
syn = IP(dst="192.168.1.1") / TCP(dport=80, flags="S")
packets.append(syn)

# 3. UDP DNS
dns = IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"DNS query")
packets.append(dns)

# 4. HTTP GET
http = IP(dst="10.0.0.1") / TCP(dport=80, flags="PA") / Raw(b"GET / HTTP/1.1\r\n\r\n")
packets.append(http)

# Save and display
wrpcap("output/first_packets.pcap", packets)
for i, pkt in enumerate(packets, 1):
    print(f"Packet {i}: {pkt.summary()}")
```

**Lab 1.3: PCAP Analysis**

```python
#!/usr/bin/env python3
"""
Lab 1.3 Solution: PCAP Analysis
"""
from scapy.all import rdpcap, IP, TCP, UDP, ICMP
from collections import defaultdict

def analyze_pcap(pcap_file):
    packets = rdpcap(pcap_file)
    stats = defaultdict(int)
    ips = defaultdict(int)
    
    for p in packets:
        if p.haslayer(TCP):
            stats['TCP'] += 1
        elif p.haslayer(UDP):
            stats['UDP'] += 1
        elif p.haslayer(ICMP):
            stats['ICMP'] += 1
        elif p.haslayer(IP):
            stats['Other IP'] += 1
        else:
            stats['Other'] += 1
        
        if p.haslayer(IP):
            ips[p[IP].src] += 1
    
    print(f"Total packets: {len(packets)}")
    print("\nProtocol Distribution:")
    for proto, count in sorted(stats.items(), key=lambda x: x[1], reverse=True):
        pct = (count / len(packets)) * 100
        print(f"  {proto}: {count} ({pct:.1f}%)")
    
    print("\nTop 5 Source IPs:")
    for ip, count in sorted(ips.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {ip}: {count}")

analyze_pcap("pcap_files/http.cap")
```

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| ModuleNotFoundError | Scapy not installed | `pip install scapy[complete]` |
| Permission denied | No root privileges | `sudo python3 script.py` |
| Wireshark can't open PCAP | File corruption | Re-save PCAP |
| Python version error | Old Python version | Install Python 3.8+ |

### Teaching Tips for Module 1

1. **Start with why:** Explain why packet crafting matters before diving into syntax
2. **Use analogies:** Onions, nesting dolls, postal envelopes
3. **Code along:** Students learn by doing
4. **Show Wireshark:** Visual confirmation is powerful
5. **Celebrate small wins:** First packet, first PCAP analysis

---

## Module 2: Layer 2 & Layer 3 Operations

### Module Overview

| Aspect | Details |
|--------|---------|
| **Duration** | 4-5 hours |
| **Key Concepts** | Ethernet frames, ARP, IP, ICMP |
| **Key Labs** | Ethernet frames, ARP scanning, ping, traceroute |
| **Learning Outcomes** | Build Ethernet frames, scan with ARP, implement ping and traceroute |

### Detailed Teaching Plan

#### Part 1: Ethernet Frame Construction (60-75 minutes)

**Topics:**
- Ethernet frame structure
- MAC addressing (unicast, broadcast, multicast)
- EtherType
- VLAN tagging (802.1Q)
- Q-in-Q (double VLAN)

**Teaching Script:**

```
"The Ethernet frame is the envelope of network communication.
It has a source address, destination address, and a payload."

[Draw Ethernet frame diagram]

"MAC addresses are like serial numbers for network interfaces.
They're 6 bytes, written in hex with colons."

[Show MAC addressing]

"EtherType tells us what's inside the envelope.
0x0800 means IPv4. 0x0806 means ARP. 0x8100 means VLAN."

[Show EtherType values]

"VLAN tagging adds a 4-byte tag for network segmentation.
Think of it like a colored tag on the envelope."

[Show VLAN frame]
```

**Key Points to Emphasize:**
- MAC addresses identify devices on local networks
- EtherType identifies the protocol in the payload
- VLANs segment networks logically
- Q-in-Q is double tagging for service providers

**Demo Script:**

```python
# Building Ethernet frames
from scapy.all import Ether, IP, ARP, ICMP, Dot1Q

# Unicast frame
unicast = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / IP(dst="8.8.8.8") / ICMP()

# Broadcast frame (ARP)
broadcast = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1")

# VLAN frame
vlan = Ether() / Dot1Q(vlan=100) / IP(dst="8.8.8.8") / ICMP()

# Q-in-Q (double VLAN)
qinq = Ether() / Dot1Q(vlan=100) / Dot1Q(vlan=200) / IP(dst="8.8.8.8") / ICMP()
```

#### Part 2: ARP Operations (60-75 minutes)

**Topics:**
- ARP request/reply process
- ARP cache
- ARP scanning
- Gratuitous ARP
- Duplicate IP detection

**Teaching Script:**

```
"ARP is like asking 'Who has this IP address?'
It's how we find the MAC address for an IP."

[Show ARP request/reply diagram]

"Every computer keeps an ARP cache.
It's like a phonebook of IP-to-MAC mappings."

[Show ARP cache example]

"ARP scanning sends requests to all IPs on a network.
The ones that reply are active hosts."

[Show ARP scan]

"Gratuitous ARP is when a host announces its IP.
It's like saying 'I'm here!' to everyone."

[Show gratuitous ARP]
```

**Key Points to Emphasize:**
- ARP requests are broadcast; replies are unicast
- The ARP cache improves performance
- ARP scanning discovers hosts on local networks
- Duplicate IPs indicate configuration problems

**Demo Script:**

```python
# ARP Request
arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1")
reply = srp1(arp_request, timeout=3)

if reply:
    print(f"MAC: {reply[ARP].hwsrc}")

# ARP Scan
arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.0/24")
answered, unanswered = srp(arp_request, timeout=2, verbose=False)

for sent, received in answered:
    print(f"{received[ARP].psrc} -> {received[ARP].hwsrc}")
```

#### Part 3: IP and ICMP Operations (60-75 minutes)

**Topics:**
- IP header structure
- TTL and fragmentation
- ICMP types and codes
- Ping implementation
- Traceroute implementation

**Teaching Script:**

```
"IP is the global addressing system.
It gets packets from source to destination across the internet."

[Show IP header diagram]

"TTL prevents packets from looping forever.
Each router decrements TTL by 1."

"ICMP is for diagnostics and error reporting.
Ping uses ICMP Echo Request/Reply."

"Traceroute uses TTL to discover the path."

[Show traceroute animation]
```

**Key Points to Emphasize:**
- IP provides addressing and routing
- TTL limits packet lifetime
- ICMP Echo is ping
- Traceroute increments TTL to discover hops

**Demo Script:**

```python
# Ping
ping = IP(dst="8.8.8.8") / ICMP(type=8, code=0)
reply = sr1(ping, timeout=3)

if reply and reply.haslayer(ICMP) and reply[ICMP].type == 0:
    print("Ping response received")

# Traceroute
def traceroute(target):
    for ttl in range(1, 31):
        packet = IP(dst=target, ttl=ttl) / ICMP()
        reply = sr1(packet, timeout=2, verbose=False)
        if reply is None:
            print(f"{ttl}. *")
        elif reply.haslayer(ICMP) and reply[ICMP].type == 0:
            print(f"{ttl}. {reply[IP].src} - Reached!")
            break
        elif reply.haslayer(ICMP) and reply[ICMP].type == 11:
            print(f"{ttl}. {reply[IP].src}")

traceroute("8.8.8.8")
```

### Lab Solutions

**Lab 2.1: Ethernet Frame Construction**

```python
#!/usr/bin/env python3
"""
Lab 2.1 Solution: Ethernet Frame Construction
"""
from scapy.all import Ether, IP, ARP, ICMP, Dot1Q, wrpcap

frames = []

# 1. Unicast frame
unicast = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / IP(dst="8.8.8.8") / ICMP()
frames.append(("Unicast", unicast))

# 2. Broadcast frame (ARP)
broadcast = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1")
frames.append(("Broadcast", broadcast))

# 3. VLAN frame
vlan = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / Dot1Q(vlan=100) / IP(dst="8.8.8.8") / ICMP()
frames.append(("VLAN", vlan))

# 4. Q-in-Q frame
qinq = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / Dot1Q(vlan=100) / Dot1Q(vlan=200) / IP(dst="8.8.8.8") / ICMP()
frames.append(("Q-in-Q", qinq))

# Save to PCAP
packets = [f for _, f in frames]
wrpcap("output/ethernet_frames.pcap", packets)

# Display
for name, frame in frames:
    print(f"{name}: {frame.summary()}")
```

**Lab 2.2: ARP Scanning**

```python
#!/usr/bin/env python3
"""
Lab 2.2 Solution: ARP Scanning
"""
from scapy.all import Ether, ARP, srp, get_if_hwaddr, conf
import ipaddress

def arp_scan(network_cidr, timeout=2):
    local_mac = get_if_hwaddr(conf.iface)
    arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(op=1, hwsrc=local_mac, pdst=network_cidr)
    answered, unanswered = srp(arp_request, timeout=timeout, verbose=False)
    
    hosts = {}
    for sent, received in answered:
        hosts[received[ARP].psrc] = received[ARP].hwsrc
    
    # Check duplicates
    duplicates = {}
    ip_to_macs = {}
    for ip, mac in hosts.items():
        if ip not in ip_to_macs:
            ip_to_macs[ip] = []
        ip_to_macs[ip].append(mac)
    
    for ip, macs in ip_to_macs.items():
        if len(macs) > 1:
            duplicates[ip] = macs
    
    print(f"Found {len(hosts)} hosts")
    for ip, mac in sorted(hosts.items()):
        print(f"  {ip} -> {mac}")
    
    if duplicates:
        print("\n⚠️ Duplicate IPs detected:")
        for ip, macs in duplicates.items():
            print(f"  {ip}: {', '.join(macs)}")
    
    return hosts, duplicates

if __name__ == "__main__":
    arp_scan("192.168.1.0/24")
```

**Lab 2.3: Custom Ping**

```python
#!/usr/bin/env python3
"""
Lab 2.3 Solution: Custom Ping
"""
from scapy.all import IP, ICMP, sr1
import time, statistics

def ping(target, count=4, timeout=2):
    sent = 0
    received = 0
    times = []
    
    print(f"PING {target}")
    
    for i in range(count):
        packet = IP(dst=target) / ICMP(id=12345, seq=i+1)
        start = time.time()
        reply = sr1(packet, timeout=timeout, verbose=False)
        elapsed = (time.time() - start) * 1000
        
        sent += 1
        if reply and reply.haslayer(ICMP) and reply[ICMP].type == 0:
            received += 1
            times.append(elapsed)
            print(f"Reply from {target}: time={elapsed:.2f}ms")
        else:
            print("Request timed out")
        
        if i < count - 1:
            time.sleep(1)
    
    print("-" * 40)
    print(f"Sent: {sent}, Received: {received}")
    if times:
        print(f"Min: {min(times):.2f}ms, Avg: {sum(times)/len(times):.2f}ms, Max: {max(times):.2f}ms")

ping("8.8.8.8", count=4)
```

**Lab 2.4: Traceroute**

```python
#!/usr/bin/env python3
"""
Lab 2.4 Solution: Traceroute
"""
from scapy.all import IP, ICMP, sr1
import socket

def traceroute(target, max_hops=30, timeout=2):
    try:
        target_ip = socket.gethostbyname(target)
    except:
        target_ip = target
    
    print(f"Traceroute to {target} ({target_ip})")
    print("-" * 40)
    
    for ttl in range(1, max_hops + 1):
        packet = IP(dst=target_ip, ttl=ttl) / ICMP()
        reply = sr1(packet, timeout=timeout, verbose=False)
        
        if reply is None:
            print(f"{ttl:>4}. *")
            continue
        
        ip = reply[IP].src
        if reply.haslayer(ICMP):
            if reply[ICMP].type == 0:
                print(f"{ttl:>4}. {ip} - Reached destination!")
                break
            elif reply[ICMP].type == 11:
                print(f"{ttl:>4}. {ip}")
            else:
                print(f"{ttl:>4}. {ip} (type={reply[ICMP].type})")
        else:
            print(f"{ttl:>4}. {ip}")

traceroute("8.8.8.8")
```

### Teaching Tips for Module 2

1. **Use visual diagrams:** Ethernet frame, ARP request/reply, IP header
2. **Show Wireshark:** Capture and inspect Ethernet frames
3. **Demonstrate live:** Run ARP scans on the local network
4. **Compare to ping:** Show how custom ping works vs system ping
5. **Trace routes:** Show traceroute in action

---

## Module 3: Transport Layer Protocols & Reconnaissance

### Module Overview

| Aspect | Details |
|--------|---------|
| **Duration** | 4-5 hours |
| **Key Concepts** | TCP, UDP, port scanning, banner grabbing |
| **Key Labs** | TCP SYN scanner, Connect scanner, UDP scanner |
| **Learning Outcomes** | Build port scanners, identify services, grab banners |

### Detailed Teaching Plan

#### Part 1: TCP and UDP Fundamentals (45-60 minutes)

**Topics:**
- TCP header structure and flags
- Three-way handshake
- Connection termination
- UDP header structure
- TCP vs UDP comparison

**Teaching Script:**

```
"TCP is like a phone call - you establish a connection before talking."

[Show three-way handshake diagram]

"SYN, SYN-ACK, ACK - that's the handshake."

"UDP is like a postcard - you send it and hope it arrives."

[Show UDP header]

"Choose TCP for reliability, UDP for speed."
```

**Key Points to Emphasize:**
- TCP is connection-oriented; UDP is connectionless
- TCP has sequence numbers, ACKs, windowing
- UDP is fast but unreliable

#### Part 2: Port Scanning Techniques (60-75 minutes)

**Topics:**
- SYN scan (half-open)
- Connect scan (full handshake)
- UDP scan
- FIN, NULL, XMAS scans
- Multi-threaded scanning

**Teaching Script:**

```
"Port scanning is checking which doors are open on a building."

[Show scan type comparison]

"SYN scan is stealthy - half-open handshake."

"Connect scan is reliable but detectable."

"UDP scanning is tricky - no response doesn't mean closed."
```

**Key Points to Emphasize:**
- Different scan types have different uses
- Multi-threading improves speed
- Rate limiting prevents detection

#### Part 3: Banner Grabbing (30-45 minutes)

**Topics:**
- What is banner grabbing
- Service identification
- Version detection
- Probes for common services

**Teaching Script:**

```
"Banner grabbing is like reading the nameplate on a door."

[Show banner examples]

"It tells us what service is running and what version."

"Knowing the version helps prioritize vulnerabilities."
```

### Lab Solutions

**Lab 3.1: TCP SYN Scanner**

```python
#!/usr/bin/env python3
"""
Lab 3.1 Solution: TCP SYN Scanner
"""
from scapy.all import IP, TCP, sr1, send
import threading
import queue

class SYNScanner:
    def __init__(self, target, threads=10, timeout=2):
        self.target = target
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
        self.queue = queue.Queue()
        self.lock = threading.Lock()
    
    def scan_port(self, port):
        packet = IP(dst=self.target) / TCP(dport=port, flags="S")
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply and reply.haslayer(TCP):
            if reply[TCP].flags & 0x12:
                rst = IP(dst=self.target) / TCP(dport=port, flags="R", seq=reply[TCP].ack)
                send(rst, verbose=False)
                return True
        return False
    
    def worker(self):
        while not self.queue.empty():
            port = self.queue.get()
            if self.scan_port(port):
                with self.lock:
                    self.open_ports.append(port)
            self.queue.task_done()
    
    def scan(self, ports):
        for port in ports:
            self.queue.put(port)
        
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        for t in threads:
            t.join()
        
        return self.open_ports

# Usage
scanner = SYNScanner("192.168.1.1")
ports = scanner.scan(range(1, 1025))
print(f"Open ports: {ports}")
```

**Lab 3.2: TCP Connect Scanner with Banner Grabbing**

```python
#!/usr/bin/env python3
"""
Lab 3.2 Solution: TCP Connect Scanner with Banner Grabbing
"""
import socket
import threading
import queue

class ConnectScanner:
    SERVICES = {22: 'SSH', 80: 'HTTP', 443: 'HTTPS', 25: 'SMTP', 53: 'DNS'}
    PROBES = {22: b"SSH-2.0-Scapy\r\n", 80: b"HEAD / HTTP/1.0\r\n\r\n"}
    
    def __init__(self, target, threads=10, timeout=3):
        self.target = target
        self.threads = threads
        self.timeout = timeout
        self.open_ports = {}
        self.queue = queue.Queue()
        self.lock = threading.Lock()
    
    def grab_banner(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2)
            sock.connect((self.target, port))
            if port in self.PROBES:
                sock.send(self.PROBES[port])
            banner = sock.recv(1024).decode('utf-8', errors='ignore')
            sock.close()
            return banner[:200]
        except:
            return None
    
    def scan_port(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            if result == 0:
                banner = self.grab_banner(port)
                with self.lock:
                    self.open_ports[port] = banner
        except:
            pass
    
    def worker(self):
        while not self.queue.empty():
            port = self.queue.get()
            self.scan_port(port)
            self.queue.task_done()
    
    def scan(self, ports):
        for port in ports:
            self.queue.put(port)
        
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        for t in threads:
            t.join()
        
        print("Open Ports:")
        for port, banner in sorted(self.open_ports.items()):
            service = self.SERVICES.get(port, 'Unknown')
            print(f"  {port}: {service} - {banner[:50] if banner else ''}")

# Usage
scanner = ConnectScanner("192.168.1.1")
scanner.scan(range(1, 1025))
```

**Lab 3.3: UDP Scanner**

```python
#!/usr/bin/env python3
"""
Lab 3.3 Solution: UDP Scanner
"""
from scapy.all import IP, UDP, sr1, ICMP
import threading
import queue

class UDPScanner:
    def __init__(self, target, threads=5, timeout=2):
        self.target = target
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
        self.queue = queue.Queue()
        self.lock = threading.Lock()
    
    def scan_port(self, port):
        packet = IP(dst=self.target) / UDP(dport=port)
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply is None:
            return "open_or_filtered"
        
        if reply.haslayer(ICMP) and reply[ICMP].type == 3 and reply[ICMP].code == 3:
            return "closed"
        return "open"
    
    def worker(self):
        while not self.queue.empty():
            port = self.queue.get()
            status = self.scan_port(port)
            if status != "closed":
                with self.lock:
                    self.open_ports.append(port)
            self.queue.task_done()
    
    def scan(self, ports):
        for port in ports:
            self.queue.put(port)
        
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        for t in threads:
            t.join()
        
        print(f"Open ports: {self.open_ports}")

# Usage
scanner = UDPScanner("192.168.1.1")
scanner.scan([53, 123, 161, 67, 68])
```

### Teaching Tips for Module 3

1. **Demonstrate handshake:** Show TCP SYN, SYN-ACK, ACK in Wireshark
2. **Compare scans:** Run SYN vs Connect on the same target
3. **Show banners:** Connect to a web server and grab its banner
4. **Discuss ethics:** Emphasize authorization for port scanning

---

## Module 4: Packet Sniffing, Filtering & Traffic Analysis

### Module Overview

| Aspect | Details |
|--------|---------|
| **Duration** | 4-5 hours |
| **Key Concepts** | Sniffing, BPF filters, HTTP, DNS, DHCP analysis |
| **Key Labs** | Basic sniffer, HTTP analyzer, DNS monitor |
| **Learning Outcomes** | Capture packets, apply filters, analyze protocols |

### Detailed Teaching Plan

#### Part 1: Packet Sniffing Basics (45-60 minutes)

**Topics:**
- The `sniff()` function
- BPF filters
- Promiscuous mode
- Callback functions

**Teaching Script:**

```
"Sniffing is like listening to network conversations."

"BPF filters are like tuning to a specific radio frequency."

"Use filters to capture only what you need."

"Callbacks process each captured packet."
```

#### Part 2: Protocol Analysis (60-75 minutes)

**Topics:**
- HTTP analysis (requests, responses, headers)
- DNS monitoring (queries, responses, cache)
- DHCP analysis (DORA sequence)
- TCP flag analysis

**Teaching Script:**

```
"HTTP analysis reveals web requests and responses."

"DNS monitoring shows what domains are being resolved."

"DHCP analysis tracks IP address assignments."

"TCP flags indicate connection states."
```

### Lab Solutions

**Lab 4.1: Basic Sniffer**

```python
#!/usr/bin/env python3
"""
Lab 4.1 Solution: Basic Sniffer
"""
from scapy.all import sniff, IP, TCP, UDP, ICMP

def packet_callback(packet):
    if packet.haslayer(TCP):
        print(f"TCP: {packet[IP].src}:{packet[TCP].sport} -> {packet[IP].dst}:{packet[TCP].dport} flags={packet[TCP].flags}")
    elif packet.haslayer(UDP):
        print(f"UDP: {packet[IP].src}:{packet[UDP].sport} -> {packet[IP].dst}:{packet[UDP].dport}")
    elif packet.haslayer(ICMP):
        print(f"ICMP: {packet[IP].src} -> {packet[IP].dst} type={packet[ICMP].type}")
    else:
        print(f"Other: {packet.summary()}")

sniff(prn=packet_callback, count=10)
```

**Lab 4.2: HTTP Analyzer**

```python
#!/usr/bin/env python3
"""
Lab 4.2 Solution: HTTP Analyzer
"""
from scapy.all import sniff, IP, TCP, Raw
import re

def analyze_http(packet):
    if not packet.haslayer(TCP) or not packet.haslayer(Raw):
        return
    
    tcp = packet[TCP]
    if tcp.sport != 80 and tcp.dport != 80:
        return
    
    data = bytes(packet[Raw]).decode('utf-8', errors='ignore')
    
    # HTTP Request
    request_match = re.match(r'^(GET|POST|PUT|DELETE|HEAD)', data)
    if request_match:
        method = request_match.group(1)
        lines = data.split('\r\n')
        if lines:
            print(f"[HTTP] {method} {lines[0]}")
            for line in lines:
                if line.lower().startswith('host:'):
                    print(f"  Host: {line.split(':', 1)[1].strip()}")
                    break
    
    # HTTP Response
    response_match = re.match(r'^HTTP/\d+\.\d+ (\d+)', data)
    if response_match:
        print(f"[HTTP] Response: {data.split('\r\n')[0]}")

sniff(filter="tcp port 80", prn=analyze_http, count=20)
```

**Lab 4.3: DNS Monitor**

```python
#!/usr/bin/env python3
"""
Lab 4.3 Solution: DNS Monitor
"""
from scapy.all import sniff, DNS

def monitor_dns(packet):
    if not packet.haslayer(DNS):
        return
    
    dns = packet[DNS]
    if dns.qr == 0 and dns.qd:
        qname = dns.qd.qname.decode('utf-8').rstrip('.')
        print(f"[DNS] Query: {qname} from {packet[IP].src}")
    elif dns.qr == 1 and dns.an:
        for answer in dns.an:
            if hasattr(answer, 'rdata'):
                domain = answer.rrname.decode('utf-8').rstrip('.')
                print(f"[DNS] Response: {domain} -> {answer.rdata}")

sniff(filter="udp port 53", prn=monitor_dns, count=20)
```

### Teaching Tips for Module 4

1. **Demonstrate filtering:** Show how BPF filters reduce packets
2. **Live HTTP analysis:** Browse a website and analyze the traffic
3. **DNS monitoring:** Show domain resolution in real-time
4. **Wireshark integration:** Compare Scapy output with Wireshark

---

## Module 5: Active Network Manipulation & Security Testing

### Module Overview

| Aspect | Details |
|--------|---------|
| **Duration** | 3-4 hours |
| **Key Concepts** | ARP spoofing detection, packet injection, replay |
| **Key Labs** | ARP detector, packet replay, payload generation |
| **Learning Outcomes** | Detect ARP spoofing, inject packets, replay traffic |

### Detailed Teaching Plan

#### Part 1: ARP Spoofing Detection (60-75 minutes)

**Topics:**
- What is ARP spoofing
- Detection techniques
- IP-MAC mapping monitoring
- Rate analysis

**Teaching Script:**

```
"ARP spoofing is identity theft on your network."

[Show ARP spoofing diagram]

"Detection: Watch for MAC changes, duplicate IPs, high ARP rates."

"Maintain an IP-MAC mapping and alert on changes."

"Gratuitous ARP can be a sign of spoofing."

[Show detection examples]
```

#### Part 2: Packet Injection and Replay (60-75 minutes)

**Topics:**
- Packet injection concepts
- Safety controls
- Rate limiting
- Packet replay

**Teaching Script:**

```
"Packet injection is sending crafted packets."

"Safety first: authorization, rate limiting, logging."

"Packet replay is replaying captured traffic."

"Useful for testing and validation."
```

### Lab Solutions

**Lab 5.1: ARP Spoofing Detector**

```python
#!/usr/bin/env python3
"""
Lab 5.1 Solution: ARP Spoofing Detector
"""
from scapy.all import sniff, ARP

class ARPDetector:
    def __init__(self):
        self.ip_mac = {}
    
    def process(self, packet):
        if not packet.haslayer(ARP):
            return
        
        arp = packet[ARP]
        ip = arp.psrc
        mac = arp.hwsrc
        
        if ip in self.ip_mac:
            if self.ip_mac[ip] != mac:
                print(f"⚠️ MAC change for {ip}: {self.ip_mac[ip]} -> {mac}")
        self.ip_mac[ip] = mac

detector = ARPDetector()
sniff(filter="arp", prn=detector.process, count=50)
```

**Lab 5.2: Packet Replay**

```python
#!/usr/bin/env python3
"""
Lab 5.2 Solution: Packet Replay
"""
from scapy.all import rdpcap, send
import time

def replay_pcap(pcap_file, rate=100):
    packets = rdpcap(pcap_file)
    interval = 1.0 / rate
    
    print(f"Replaying {len(packets)} packets at {rate}/s")
    
    for i, packet in enumerate(packets, 1):
        send(packet, verbose=False)
        if i % 100 == 0:
            print(f"Sent {i} packets")
        time.sleep(interval)

replay_pcap("output/sample.pcap", rate=10)
```

### Teaching Tips for Module 5

1. **Emphasize ethics:** ARP spoofing is illegal without authorization
2. **Demonstrate in lab only:** Use isolated network
3. **Show detection:** Run ARP detector while spoofing in lab
4. **Safety controls:** Always show rate limiting and authorization

---

## Module 6: Automation, Performance & Custom Protocols

### Module Overview

| Aspect | Details |
|--------|---------|
| **Duration** | 3-4 hours |
| **Key Concepts** | Multi-threading, async, custom protocols |
| **Key Labs** | Custom protocol, high-performance capture, fuzzing |
| **Learning Outcomes** | Build custom protocols, optimize performance, automate |

### Detailed Teaching Plan

#### Part 1: High-Performance Capture (45-60 minutes)

**Topics:**
- Producer-consumer pattern
- Multi-threading
- Queues
- Performance monitoring

**Teaching Script:**

```
"High performance means processing packets quickly."

"Producer-consumer separates capture from processing."

"Multi-threading processes packets in parallel."

"Queues buffer packets between stages."

[Show pipeline diagram]
```

#### Part 2: Custom Protocols (60-75 minutes)

**Topics:**
- Scapy packet class
- Field definitions
- Protocol binding
- Dissection

**Teaching Script:**

```
"Custom protocols extend Scapy to new formats."

"Inherit from Packet and define fields."

"Bind protocols together."

"Scapy automatically dissects bound protocols."

[Show custom protocol code]
```

### Lab Solutions

**Lab 6.1: Custom Protocol**

```python
#!/usr/bin/env python3
"""
Lab 6.1 Solution: Custom Protocol
"""
from scapy.packet import Packet
from scapy.fields import *
from scapy.all import bind_layers, IP

class MyProtocol(Packet):
    name = "MyProtocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        ShortField("length", 0),
        IntField("sequence", 0),
    ]
    
    def mysummary(self):
        return f"MyProtocol v{self.version} type={self.type} seq={self.sequence}"

class MyData(Packet):
    name = "MyData"
    fields_desc = [
        ByteField("data_type", 0),
        ShortField("data_length", 0),
        StrLenField("data", "", length_from=lambda p: p.data_length)
    ]

bind_layers(IP, MyProtocol, proto=252)
bind_layers(MyProtocol, MyData, type=0)

# Create packet
pkt = IP(src="192.168.1.100", dst="192.168.1.1", proto=252) / \
      MyProtocol(version=1, type=0, sequence=1001) / \
      MyData(data_type=1, data_length=5, data=b"Hello")

print(pkt.summary())
print(pkt[MyProtocol].mysummary())
print(pkt[MyData].mysummary())
```

**Lab 6.2: High-Performance Capture**

```python
#!/usr/bin/env python3
"""
Lab 6.2 Solution: High-Performance Capture
"""
from scapy.all import sniff
import threading
import queue
import time

class HighPerfCapture:
    def __init__(self, workers=4):
        self.queue = queue.Queue()
        self.workers = workers
        self.running = False
        self.count = 0
    
    def packet_callback(self, packet):
        self.queue.put(packet)
    
    def worker(self):
        while self.running:
            try:
                packet = self.queue.get(timeout=0.5)
                self.process(packet)
                self.queue.task_done()
            except queue.Empty:
                continue
    
    def process(self, packet):
        self.count += 1
        if self.count % 100 == 0:
            print(f"Processed {self.count} packets")
    
    def start(self, count=1000):
        self.running = True
        for _ in range(self.workers):
            t = threading.Thread(target=self.worker)
            t.start()
        
        start = time.time()
        sniff(prn=self.packet_callback, count=count, store=False)
        self.running = False
        
        elapsed = time.time() - start
        print(f"Captured {count} packets in {elapsed:.2f}s")
        print(f"Rate: {count/elapsed:.1f} pkts/s")

capture = HighPerfCapture(workers=4)
capture.start(count=1000)
```

**Lab 6.3: Protocol Fuzzing**

```python
#!/usr/bin/env python3
"""
Lab 6.3 Solution: Protocol Fuzzing
"""
import random
from custom_protocol import MyProtocol

def fuzz_field(field_name, field_value, field_type):
    # Simple fuzzing: random mutations
    if isinstance(field_type, ByteField):
        return random.randint(0, 255)
    elif isinstance(field_type, ShortField):
        return random.randint(0, 65535)
    elif isinstance(field_type, IntField):
        return random.randint(0, 0xFFFFFFFF)
    return field_value

def fuzz_packet(packet):
    pkt = packet.copy()
    for field in pkt.fields_desc:
        if hasattr(pkt, field.name):
            setattr(pkt, field.name, fuzz_field(field.name, getattr(pkt, field.name), field))
    return pkt

# Test fuzzing
base = MyProtocol()
for i in range(100):
    fuzzed = fuzz_packet(base)
    try:
        bytes(fuzzed)
        print(f"✅ Packet {i+1}: Valid")
    except Exception as e:
        print(f"❌ Packet {i+1}: Error - {e}")
```

### Teaching Tips for Module 6

1. **Show performance:** Compare single-threaded vs multi-threaded
2. **Build custom protocol:** Step through field definitions
3. **Test fuzzing:** Show how fuzzing finds edge cases
4. **Integrate tools:** Show how all modules combine in capstone

---

## Capstone Project

### Project Overview

**Objective:** Build a complete Network Security Toolkit integrating all modules.

**Requirements:**
- Command-line interface
- Modular design
- Plugin architecture
- Configuration management
- Logging and reporting

### Project Phases

**Phase 1: Planning (30 minutes)**
- Define CLI commands
- Design module interfaces
- Plan plugin system

**Phase 2: Core Framework (60-90 minutes)**
- Implement main() function
- Build command parser
- Create module loader

**Phase 3: Module Integration (90-120 minutes)**
- Integrate ARP scanner
- Integrate port scanner
- Integrate packet sniffer
- Integrate PCAP analyzer

**Phase 4: Testing and Documentation (30-60 minutes)**
- Test all commands
- Write usage examples
- Create README

### Project Solution

```python
#!/usr/bin/env python3
"""
Network Security Toolkit - Capstone Solution
"""
import argparse
import sys
import logging
from datetime import datetime

from arp_scanner import ARPScanner
from tcp_syn_scanner import TCPSYNScanner
from basic_sniffer import BasicSniffer
from pcap_analyzer import PCAPAnalyzer

class NSTool:
    def __init__(self):
        self.setup_logging()
        self.modules = {
            'scan': self.cmd_scan,
            'sniff': self.cmd_sniff,
            'analyze': self.cmd_analyze,
            'help': self.cmd_help
        }
    
    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
    
    def cmd_scan(self, args):
        """Scan network for hosts and ports."""
        if args.type == 'arp':
            scanner = ARPScanner()
            hosts = scanner.scan(args.target)
            scanner.display()
        elif args.type == 'syn':
            ports = list(range(1, 1025))
            scanner = TCPSYNScanner(args.target, ports=ports)
            scanner.scan()
        else:
            print(f"Unknown scan type: {args.type}")
    
    def cmd_sniff(self, args):
        """Sniff live traffic."""
        sniffer = BasicSniffer(
            interface=args.interface,
            filter_str=args.filter,
            count=args.count
        )
        sniffer.start()
    
    def cmd_analyze(self, args):
        """Analyze PCAP file."""
        analyzer = PCAPAnalyzer(args.pcap_file)
        analyzer.load().analyze().display_stats()
    
    def cmd_help(self, args):
        """Show help."""
        self.print_help()
    
    def print_help(self):
        print("""
Network Security Toolkit (NSTool)

Commands:
  scan <target> [--type TYPE]     Scan network/hosts
  sniff [--interface IFACE] [--filter FILTER] [--count N]
  analyze <pcap_file>              Analyze PCAP file
  help                             Show this help

Examples:
  nstool scan 192.168.1.0/24 --type arp
  nstool sniff --interface eth0 --filter "tcp" --count 100
  nstool analyze capture.pcap
        """)
    
    def main(self):
        """Main entry point."""
        parser = argparse.ArgumentParser(description='Network Security Toolkit')
        subparsers = parser.add_subparsers(dest='command', help='Command to run')
        
        # Scan command
        scan_parser = subparsers.add_parser('scan', help='Scan network')
        scan_parser.add_argument('target', help='Target IP or network')
        scan_parser.add_argument('--type', default='arp', choices=['arp', 'syn'],
                                help='Scan type')
        
        # Sniff command
        sniff_parser = subparsers.add_parser('sniff', help='Sniff traffic')
        sniff_parser.add_argument('--interface', help='Network interface')
        sniff_parser.add_argument('--filter', help='BPF filter')
        sniff_parser.add_argument('--count', type=int, default=0,
                                help='Number of packets')
        
        # Analyze command
        analyze_parser = subparsers.add_parser('analyze', help='Analyze PCAP')
        analyze_parser.add_argument('pcap_file', help='PCAP file to analyze')
        
        # Help command
        help_parser = subparsers.add_parser('help', help='Show help')
        
        args = parser.parse_args()
        
        if args.command in self.modules:
            self.modules[args.command](args)
        else:
            self.print_help()

if __name__ == "__main__":
    tool = NSTool()
    tool.main()
```

### Capstone Evaluation Rubric

| Criteria | Excellent (4) | Good (3) | Satisfactory (2) | Needs Improvement (1) |
|----------|---------------|----------|------------------|----------------------|
| **Functionality** | All commands work | Most commands work | Some commands work | Few commands work |
| **Code Quality** | Clean, documented | Mostly clean | Some issues | Poor structure |
| **Modularity** | Well-modularized | Some modules | Limited modules | Monolithic |
| **Error Handling** | Comprehensive | Good handling | Basic handling | No handling |
| **Documentation** | Complete | Adequate | Minimal | Missing |

---

## Assessment and Evaluation

### Quiz Answer Keys

See the Quiz and Test Bank document for complete answer keys.

### Practical Exam

**Scenario:** A small company has asked you to assess their network security.

**Tasks:**

1. **Network Discovery** (20 points)
   - Perform an ARP scan of the local network
   - Identify all active hosts
   - Document IP and MAC addresses

2. **Service Discovery** (20 points)
   - Scan for open TCP ports on each host
   - Identify running services
   - Grab banners for each service

3. **Traffic Analysis** (20 points)
   - Capture 5 minutes of network traffic
   - Identify HTTP requests and responses
   - List DNS queries made

4. **Security Assessment** (20 points)
   - Detect any ARP spoofing activity
   - Identify any suspicious domains
   - Document findings

5. **Report** (20 points)
   - Write a professional security assessment report
   - Include methodology, findings, and recommendations
   - Provide evidence (screenshots, logs)

### Evaluation Rubric

| Category | Excellent (5) | Good (4) | Satisfactory (3) | Needs Work (2) | Unsatisfactory (1) |
|----------|---------------|----------|------------------|----------------|-------------------|
| **ARP Scan** | All hosts found | Most hosts found | Some hosts found | Few hosts found | No hosts found |
| **Port Scan** | All ports scanned | Most ports scanned | Some ports scanned | Few ports scanned | No ports scanned |
| **Banner Grab** | Banners complete | Most banners | Some banners | Few banners | No banners |
| **Traffic Analysis** | Complete analysis | Good analysis | Basic analysis | Minimal analysis | No analysis |
| **Security Detection** | All threats found | Most threats | Some threats | Few threats | No threats |
| **Report Quality** | Professional | Good quality | Adequate | Needs work | Unacceptable |

### Final Course Evaluation

**Student Feedback Survey:**

1. **Course Content**
   - How relevant was the content to your goals?
   - Was the difficulty level appropriate?
   - What topics were most/least useful?

2. **Instruction**
   - Was the instructor knowledgeable?
   - Were explanations clear?
   - Was enough time given for labs?

3. **Materials**
   - Were the lab books helpful?
   - Were examples clear?
   - What additional materials would help?

4. **Overall**
   - Would you recommend this course?
   - What was the best part?
   - What could be improved?

---

## Troubleshooting Guide

### Common Setup Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Scapy not found | Not installed | `pip install scapy[complete]` |
| Permission denied | No root | `sudo python3 script.py` |
| Wireshark missing | Not installed | Install from website |
| Virtual env not active | Not sourced | `source venv/bin/activate` |

### Common Runtime Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| No response to packets | Firewall blocking | Check firewall, use localhost |
| Checksum errors | Not recalculated | Use `show2()` or `send()` |
| Interface not found | Wrong name | `get_if_list()` to list |
| PCAP file corrupted | Incomplete download | Re-download PCAP |

### Student Support

**Before Class:**
- Send setup instructions
- Provide primers
- Test lab environment

**During Class:**
- Walk around and help
- Address errors quickly
- Encourage questions

**After Class:**
- Provide office hours
- Share additional resources
- Follow up on progress

---

## Resources and References

### Official Documentation

| Resource | Link | Purpose |
|----------|------|---------|
| **Scapy Documentation** | [scapy.readthedocs.io](https://scapy.readthedocs.io/) | Official reference |
| **Wireshark Samples** | [wiki.wireshark.org](https://wiki.wireshark.org/SampleCaptures) | PCAP files |
| **Python Documentation** | [docs.python.org](https://docs.python.org/) | Python reference |
| **Scapy GitHub** | [github.com/secdev/scapy](https://github.com/secdev/scapy) | Source code |

### Recommended Reading

| Book | Author | Description |
|------|--------|-------------|
| **Practical Packet Analysis** | Chris Sanders | Wireshark and packet analysis |
| **The TCP/IP Guide** | Charles Kozierok | Comprehensive TCP/IP reference |
| **Network Security Assessment** | Chris McNab | Security testing |
| **Python Network Programming** | Eric Chou | Python networking |

### Additional Resources

| Resource | Description |
|----------|-------------|
| **PacketTotal** | Online PCAP analysis |
| **Malware Traffic Analysis** | Security PCAPs |
| **The Ultimate PCAP** | Comprehensive capture |
| **NETRESEC PCAPs** | Public captures |

---

## Trainer Checklist

### Pre-Course
- [ ] Review course materials
- [ ] Set up lab environment
- [ ] Test all code examples
- [ ] Prepare slide decks
- [ ] Print lab books
- [ ] Send student materials

### During Course
- [ ] Start each module with objectives
- [ ] Demonstrate concepts live
- [ ] Guide code-along sessions
- [ ] Monitor student progress
- [ ] Answer questions clearly
- [ ] Emphasize ethics throughout

### Post-Course
- [ ] Collect feedback
- [ ] Review student progress
- [ ] Provide additional resources
- [ ] Offer follow-up support

---

**End of Trainer Guide**
