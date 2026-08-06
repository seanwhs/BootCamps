# Mastering Network Packet Crafting with Scapy
## Lab Book

## Overview

This lab book contains all hands-on laboratory exercises for the **Mastering Network Packet Crafting with Scapy** series. Each lab includes:

- **Objectives**: What you'll learn
- **Prerequisites**: Required knowledge/setup
- **Materials**: Files and tools needed
- **Step-by-Step Instructions**: Detailed procedures
- **Verification**: How to confirm success
- **Lab Report**: Space to document results
- **Challenges**: Extension activities

---

## Table of Contents

1. [Lab 1.1: Environment Setup](#lab-11-environment-setup)
2. [Lab 1.2: Building Your First Packets](#lab-12-building-your-first-packets)
3. [Lab 1.3: PCAP Analysis](#lab-13-pcap-analysis)
4. [Lab 2.1: Ethernet Frame Construction](#lab-21-ethernet-frame-construction)
5. [Lab 2.2: ARP Scanning](#lab-22-arp-scanning)
6. [Lab 2.3: Custom Ping Utility](#lab-23-custom-ping-utility)
7. [Lab 2.4: Traceroute Implementation](#lab-24-traceroute-implementation)
8. [Lab 3.1: TCP SYN Scanner](#lab-31-tcp-syn-scanner)
9. [Lab 3.2: TCP Connect Scanner with Banner Grabbing](#lab-32-tcp-connect-scanner-with-banner-grabbing)
10. [Lab 3.3: UDP Scanner](#lab-33-udp-scanner)
11. [Lab 4.1: Basic Packet Sniffer](#lab-41-basic-packet-sniffer)
12. [Lab 4.2: HTTP Analyzer](#lab-42-http-analyzer)
13. [Lab 4.3: DNS Monitor](#lab-43-dns-monitor)
14. [Lab 5.1: ARP Spoofing Detector](#lab-51-arp-spoofing-detector)
15. [Lab 5.2: Packet Replay Utility](#lab-52-packet-replay-utility)
16. [Lab 6.1: Custom Protocol Development](#lab-61-custom-protocol-development)
17. [Lab 6.2: High-Performance Capture](#lab-62-high-performance-capture)
18. [Lab 6.3: Protocol Fuzzing](#lab-63-protocol-fuzzing)

---

## Lab 1.1: Environment Setup

---

### Objectives

After completing this lab, you will be able to:
- ✅ Install Python 3.8+ on your system
- ✅ Create and activate a virtual environment
- ✅ Install Scapy with complete dependencies
- ✅ Set up a professional project directory structure
- ✅ Verify your Scapy installation works correctly

---

### Prerequisites

- ✅ Basic command-line knowledge
- ✅ Internet connection for downloads
- ✅ Administrator/sudo access (for raw sockets)

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/verify_environment.py`
- `src/test_loopback.py`

---

### Step-by-Step Instructions

#### Step 1: Install Python (If Needed)

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv python3-dev
```

**macOS:**
```bash
brew install python3
```

**Windows:**
1. Download from python.org
2. Check "Add Python to PATH"
3. Verify: `python --version`

#### Step 2: Create Project Directory

```bash
mkdir ~/scapy-tutorial
cd ~/scapy-tutorial
```

#### Step 3: Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate   # Windows
```

#### Step 4: Install Scapy

```bash
pip install --upgrade pip
pip install scapy[complete]
```

#### Step 5: Create Directory Structure

```bash
mkdir -p src labs pcap_files output config tests docs
touch src/__init__.py
```

#### Step 6: Create Environment Verification Script

Create `src/verify_environment.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 1: Environment Verification Script
"""

import sys
import os

print(f"Python version: {sys.version}")
print(f"Python executable: {sys.executable}")

# Verify virtual environment
in_venv = hasattr(sys, 'real_prefix') or (
    hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix
)
print(f"Running in virtual environment: {in_venv}")

# Try importing Scapy
try:
    import scapy
    print(f"Scapy version: {scapy.__version__}")
except ImportError as e:
    print(f"ERROR: Scapy is not installed properly: {e}")
    sys.exit(1)

# Import core modules
try:
    from scapy.all import Ether, IP, TCP, UDP, Raw, ICMP
    from scapy.sendrecv import sr, sr1, send
    from scapy.utils import rdpcap, wrpcap
    print("✓ Core Scapy modules imported successfully")
except ImportError as e:
    print(f"ERROR: Could not import required Scapy modules: {e}")
    sys.exit(1)

# Check for root privileges
is_root = os.geteuid() == 0 if hasattr(os, 'geteuid') else False
print(f"Running with root privileges: {is_root}")

# Test packet creation
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

#### Step 7: Run Verification

```bash
python3 src/verify_environment.py
```

#### Step 8: Test Loopback (Optional)

Create `src/test_loopback.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 1: Loopback Test Script
"""

import sys

try:
    from scapy.all import IP, ICMP, sr1, conf
except ImportError:
    print("ERROR: Scapy not installed")
    sys.exit(1)

def test_loopback():
    conf.iface = "lo"
    print(f"Using interface: {conf.iface}")
    
    packet = IP(dst="127.0.0.1") / ICMP()
    print("\nPacket built:")
    packet.show()
    
    print("\nSending packet to 127.0.0.1...")
    response = sr1(packet, timeout=2, verbose=True)
    
    if response:
        print("\n✅ Received response:")
        response.show()
        return True
    else:
        print("\n❌ No response received (normal on some systems)")
        return False

if __name__ == "__main__":
    test_loopback()
```

---

### Verification Checklist

- [ ] Python 3.8+ installed
- [ ] Virtual environment created and activated
- [ ] Scapy installed successfully
- [ ] Directory structure created
- [ ] `verify_environment.py` runs without errors
- [ ] `test_loopback.py` runs (may fail on some systems)

---

### Lab Report

**1. What Python version are you using?**
```
Answer: ______________________________________________________
```

**2. What Scapy version was installed?**
```
Answer: ______________________________________________________
```

**3. What operating system are you using?**
```
Answer: ______________________________________________________
```

**4. Did you need to use `sudo` for any commands? Why?**
```
Answer: ______________________________________________________
```

**5. What was the output of the verification script?**
```
Answer: ______________________________________________________
```

**6. Did the loopback test succeed? If not, what happened?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Modify the verification script to check for Wireshark installation.

**Challenge 2:** Add a check for the `tshark` command-line tool.

**Challenge 3:** Write a script that displays all available network interfaces.

---

## Lab 1.2: Building Your First Packets

---

### Objectives

After completing this lab, you will be able to:
- ✅ Build multi-layer packets using the `/` operator
- ✅ Inspect packets with `show()`, `summary()`, and `hexdump()`
- ✅ Access and modify packet fields
- ✅ Save packets to PCAP files

---

### Prerequisites

- ✅ Lab 1.1 completed
- ✅ Scapy installed and working
- ✅ Wireshark installed (recommended)

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/first_packets.py`
- `src/save_to_pcap.py`

---

### Step-by-Step Instructions

#### Step 1: Create First Packets Script

Create `src/first_packets.py`:

```python
#!/usr/bin/env python3
"""
Module 1 Lab: First Packets
"""

from scapy.all import Ether, IP, TCP, UDP, ICMP, Raw, wrpcap, hexdump
import os

def build_packets():
    """Build a variety of packets."""
    packets = []
    
    # 1. ICMP Echo Request (Ping)
    ping = IP(dst="8.8.8.8") / ICMP()
    packets.append(ping)
    print("1. ICMP Echo Request")
    ping.show()
    print(f"  Summary: {ping.summary()}")
    print(f"  Length: {len(ping)} bytes\n")
    
    # 2. TCP SYN Packet
    syn = IP(dst="192.168.1.1") / TCP(dport=80, flags="S")
    packets.append(syn)
    print("2. TCP SYN Packet")
    syn.show()
    print(f"  Summary: {syn.summary()}")
    print(f"  Length: {len(syn)} bytes\n")
    
    # 3. UDP DNS Query
    dns_query = b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00"
    dns = IP(dst="8.8.8.8") / UDP(dport=53) / Raw(load=dns_query)
    packets.append(dns)
    print("3. UDP DNS Query")
    dns.show()
    print(f"  Summary: {dns.summary()}")
    print(f"  Length: {len(dns)} bytes\n")
    
    # 4. HTTP GET Request
    http_data = b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n"
    http = IP(dst="10.0.0.1") / TCP(dport=80, flags="PA") / Raw(load=http_data)
    packets.append(http)
    print("4. HTTP GET Request")
    http.show()
    print(f"  Summary: {http.summary()}")
    print(f"  Length: {len(http)} bytes\n")
    
    return packets

def inspect_packets(packets):
    """Inspect each packet in detail."""
    for i, packet in enumerate(packets, 1):
        print(f"\n{'='*60}")
        print(f"Packet {i} - Detailed Inspection")
        print(f"{'='*60}")
        
        # Summary
        print(f"\nSummary: {packet.summary()}")
        
        # Layers
        print(f"\nLayers in this packet:")
        p = packet
        layer_num = 1
        while p:
            print(f"  {layer_num}. {p.name}")
            p = p.payload if hasattr(p, 'payload') else None
            layer_num += 1
        
        # Hexdump
        print(f"\nHexdump (first 32 bytes):")
        print(f"  {bytes(packet)[:32].hex()}")
        
        # Access specific layers
        if packet.haslayer(IP):
            print(f"\nIP Source: {packet[IP].src}")
            print(f"IP Destination: {packet[IP].dst}")
        
        if packet.haslayer(TCP):
            print(f"TCP Source Port: {packet[TCP].sport}")
            print(f"TCP Destination Port: {packet[TCP].dport}")
            print(f"TCP Flags: {packet[TCP].flags}")
        
        if packet.haslayer(UDP):
            print(f"UDP Source Port: {packet[UDP].sport}")
            print(f"UDP Destination Port: {packet[UDP].dport}")
        
        if packet.haslayer(ICMP):
            print(f"ICMP Type: {packet[ICMP].type}")
            print(f"ICMP Code: {packet[ICMP].code}")

def modify_and_save(packets):
    """Modify a packet and save all to PCAP."""
    print("\n" + "="*60)
    print("Modifying Packets")
    print("="*60)
    
    # Copy and modify the HTTP packet
    original = packets[3]  # HTTP packet
    modified = original.copy()
    modified[IP].dst = "8.8.8.8"
    modified[TCP].dport = 8080
    modified[Raw].load = b"GET /modified HTTP/1.1\r\nHost: test.com\r\n\r\n"
    
    print(f"\nOriginal HTTP packet: {original.summary()}")
    print(f"Modified HTTP packet: {modified.summary()}")
    
    # Save all packets
    os.makedirs("output", exist_ok=True)
    wrpcap("output/first_packets.pcap", packets + [modified])
    print(f"\n✅ Saved {len(packets) + 1} packets to output/first_packets.pcap")

if __name__ == "__main__":
    print("="*60)
    print("BUILDING YOUR FIRST PACKETS")
    print("="*60)
    
    packets = build_packets()
    inspect_packets(packets)
    modify_and_save(packets)
    
    print("\n" + "="*60)
    print("✅ LAB COMPLETE")
    print("="*60)
```

#### Step 2: Run the Script

```bash
python3 src/first_packets.py
```

#### Step 3: Save a Single Packet to PCAP (Bonus)

Create `src/save_to_pcap.py`:

```python
#!/usr/bin/env python3
"""
Module 1 Lab: Save a Single Packet to PCAP
"""

from scapy.all import IP, ICMP, wrpcap
import os

# Create a packet
ping = IP(dst="8.8.8.8") / ICMP()

# Save to PCAP
os.makedirs("output", exist_ok=True)
wrpcap("output/single_ping.pcap", [ping])

print("✅ Saved single ping packet to output/single_ping.pcap")
print(f"  Summary: {ping.summary()}")
```

#### Step 4: View in Wireshark

```bash
# Open the PCAP file in Wireshark
wireshark output/first_packets.pcap

# Or use tshark for command-line viewing
tshark -r output/first_packets.pcap -V
```

---

### Verification Checklist

- [ ] Script runs without errors
- [ ] All four packets build correctly
- [ ] Packet summaries display correctly
- [ ] Hexdump shows raw bytes
- [ ] Layer access works (src/dst IPs, ports)
- [ ] Packet modification works
- [ ] PCAP file is created
- [ ] Wireshark can open the PCAP file

---

### Lab Report

**1. What is the default source IP for the ICMP packet?**
```
Answer: ______________________________________________________
```

**2. What TCP flag is set in the SYN packet?**
```
Answer: ______________________________________________________
```

**3. What is the destination port for the DNS query?**
```
Answer: ______________________________________________________
```

**4. How many bytes is the HTTP GET request?**
```
Answer: ______________________________________________________
```

**5. What happened when you modified the HTTP packet?**
```
Answer: ______________________________________________________
```

**6. What did you see when you opened the PCAP in Wireshark?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add a VLAN-tagged frame to the packet list.

**Challenge 2:** Build a DNS response packet.

**Challenge 3:** Create a packet with an IP option (e.g., Timestamp).

---

## Lab 1.3: PCAP Analysis

---

### Objectives

After completing this lab, you will be able to:
- ✅ Download PCAP files from public repositories
- ✅ Load PCAP files with `rdpcap()`
- ✅ Analyze protocol distribution
- ✅ Filter packets by protocol, IP, and port
- ✅ Build a basic PCAP analyzer tool

---

### Prerequisites

- ✅ Lab 1.1 completed
- ✅ Scapy installed
- ✅ Internet connection for downloads

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/download_pcaps.py`
- `src/pcap_analyzer.py`
- `src/pcap_filtering.py`

---

### Step-by-Step Instructions

#### Step 1: Download Sample PCAPs

Create `src/download_pcaps.py`:

```python
#!/usr/bin/env python3
"""
Module 1 Lab: Download Sample PCAPs
"""

import urllib.request
import os
import sys

PCAP_SOURCES = {
    "dns": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap",
    "http": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http.cap",
    "tcp": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/tcp.cap",
    "dhcp": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.cap",
    "arp": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/arp.cap",
}

def download_pcap(url, output_dir="pcap_files"):
    os.makedirs(output_dir, exist_ok=True)
    filename = os.path.basename(url)
    filepath = os.path.join(output_dir, filename)
    
    if os.path.exists(filepath):
        print(f"  ⚠ {filename} already exists")
        return filepath
    
    print(f"  Downloading {filename}...")
    try:
        urllib.request.urlretrieve(url, filepath)
        size = os.path.getsize(filepath)
        print(f"  ✓ Downloaded {filename} ({size} bytes)")
        return filepath
    except Exception as e:
        print(f"  ✗ Failed: {e}")
        return None

def main():
    print("="*60)
    print("DOWNLOADING SAMPLE PCAPS")
    print("="*60)
    
    for name, url in PCAP_SOURCES.items():
        print(f"\n{name.upper()}:")
        download_pcap(url)
    
    print("\n" + "="*60)
    print("✅ DOWNLOAD COMPLETE")
    print("="*60)
    
    print("\nFiles in pcap_files:")
    print("-" * 40)
    for f in sorted(os.listdir("pcap_files")):
        if f.endswith(('.pcap', '.cap')):
            size = os.path.getsize(f"pcap_files/{f}")
            print(f"  {f:<20} {size:>8} bytes")

if __name__ == "__main__":
    main()
```

Run the downloader:

```bash
python3 src/download_pcaps.py
```

#### Step 2: Build PCAP Analyzer

Create `src/pcap_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 1 Lab: PCAP Analyzer
"""

from scapy.all import rdpcap, IP, TCP, UDP, ICMP, Ether
from collections import defaultdict
import os
import sys

class PCAPAnalyzer:
    def __init__(self, pcap_file):
        self.pcap_file = pcap_file
        self.packets = None
        self.stats = {
            'total': 0,
            'protocols': defaultdict(int),
            'src_ips': defaultdict(int),
            'dst_ips': defaultdict(int),
            'tcp_ports': defaultdict(int),
            'udp_ports': defaultdict(int)
        }
    
    def load(self):
        """Load the PCAP file."""
        if not os.path.exists(self.pcap_file):
            raise FileNotFoundError(f"File not found: {self.pcap_file}")
        
        print(f"Loading: {self.pcap_file}")
        self.packets = rdpcap(self.pcap_file)
        self.stats['total'] = len(self.packets)
        print(f"Loaded {self.stats['total']} packets")
        return self
    
    def analyze(self):
        """Analyze all packets."""
        print("\nAnalyzing packets...")
        
        for packet in self.packets:
            # Protocol classification
            if packet.haslayer(TCP):
                self.stats['protocols']['TCP'] += 1
                tcp = packet[TCP]
                self.stats['tcp_ports'][tcp.sport] += 1
                self.stats['tcp_ports'][tcp.dport] += 1
            elif packet.haslayer(UDP):
                self.stats['protocols']['UDP'] += 1
                udp = packet[UDP]
                self.stats['udp_ports'][udp.sport] += 1
                self.stats['udp_ports'][udp.dport] += 1
            elif packet.haslayer(ICMP):
                self.stats['protocols']['ICMP'] += 1
            elif packet.haslayer(IP):
                self.stats['protocols']['Other_IP'] += 1
            else:
                self.stats['protocols']['Other'] += 1
            
            # IP addresses
            if packet.haslayer(IP):
                ip = packet[IP]
                self.stats['src_ips'][ip.src] += 1
                self.stats['dst_ips'][ip.dst] += 1
        
        return self
    
    def display_stats(self):
        """Display statistics."""
        print("\n" + "="*60)
        print("PCAP ANALYSIS RESULTS")
        print("="*60)
        print(f"File: {self.pcap_file}")
        print(f"Total packets: {self.stats['total']}")
        
        print("\nProtocol Distribution:")
        print("-"*40)
        for proto, count in sorted(self.stats['protocols'].items(), 
                                   key=lambda x: x[1], reverse=True):
            pct = (count / self.stats['total']) * 100
            bar = "█" * int(pct / 2)
            print(f"  {proto:<10}: {count:>6} ({pct:>5.1f}%) {bar}")
        
        print("\nTop 5 Source IPs:")
        print("-"*40)
        for ip, count in sorted(self.stats['src_ips'].items(), 
                                key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {ip:<15}: {count:>6}")
        
        print("\nTop 5 Destination IPs:")
        print("-"*40)
        for ip, count in sorted(self.stats['dst_ips'].items(), 
                                key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {ip:<15}: {count:>6}")
        
        if self.stats['tcp_ports']:
            print("\nTop 5 TCP Ports:")
            print("-"*40)
            for port, count in sorted(self.stats['tcp_ports'].items(), 
                                      key=lambda x: x[1], reverse=True)[:5]:
                print(f"  {port:<6}: {count:>6}")
        
        if self.stats['udp_ports']:
            print("\nTop 5 UDP Ports:")
            print("-"*40)
            for port, count in sorted(self.stats['udp_ports'].items(), 
                                      key=lambda x: x[1], reverse=True)[:5]:
                print(f"  {port:<6}: {count:>6}")
    
    def get_packet_counts(self):
        """Return packet counts for further analysis."""
        return self.stats

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 pcap_analyzer.py <pcap_file>")
        sys.exit(1)
    
    analyzer = PCAPAnalyzer(sys.argv[1])
    analyzer.load().analyze().display_stats()

if __name__ == "__main__":
    main()
```

Run the analyzer:

```bash
python3 src/pcap_analyzer.py pcap_files/http.cap
```

#### Step 3: Build PCAP Filtering Tool

Create `src/pcap_filtering.py`:

```python
#!/usr/bin/env python3
"""
Module 1 Lab: PCAP Filtering
"""

from scapy.all import rdpcap, IP, TCP, UDP, ICMP, Raw
import sys

def filter_by_protocol(packets, protocol):
    """Filter packets by protocol."""
    if protocol == "TCP":
        return [p for p in packets if p.haslayer(TCP)]
    elif protocol == "UDP":
        return [p for p in packets if p.haslayer(UDP)]
    elif protocol == "ICMP":
        return [p for p in packets if p.haslayer(ICMP)]
    elif protocol == "IP":
        return [p for p in packets if p.haslayer(IP)]
    else:
        return []

def filter_by_ip(packets, ip, direction="both"):
    """Filter packets by IP address."""
    result = []
    for p in packets:
        if not p.haslayer(IP):
            continue
        ip_layer = p[IP]
        if direction == "src" and ip_layer.src == ip:
            result.append(p)
        elif direction == "dst" and ip_layer.dst == ip:
            result.append(p)
        elif direction == "both" and (ip_layer.src == ip or ip_layer.dst == ip):
            result.append(p)
    return result

def filter_by_port(packets, port, protocol="TCP"):
    """Filter packets by port."""
    result = []
    for p in packets:
        if protocol == "TCP" and p.haslayer(TCP):
            tcp = p[TCP]
            if tcp.sport == port or tcp.dport == port:
                result.append(p)
        elif protocol == "UDP" and p.haslayer(UDP):
            udp = p[UDP]
            if udp.sport == port or udp.dport == port:
                result.append(p)
    return result

def filter_tcp_flags(packets, flags):
    """Filter TCP packets by flags."""
    result = []
    for p in packets:
        if p.haslayer(TCP):
            if (p[TCP].flags & flags) == flags:
                result.append(p)
    return result

def filter_payload(packets, search_string):
    """Filter packets by payload content."""
    result = []
    search_bytes = search_string.encode()
    for p in packets:
        if p.haslayer(Raw):
            if search_bytes in bytes(p[Raw]):
                result.append(p)
    return result

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 pcap_filtering.py <pcap_file>")
        sys.exit(1)
    
    pcap_file = sys.argv[1]
    print(f"Loading: {pcap_file}")
    packets = rdpcap(pcap_file)
    print(f"Loaded {len(packets)} packets\n")
    
    # Protocol filtering
    print("Protocol Filtering:")
    print("-"*40)
    for proto in ["TCP", "UDP", "ICMP", "IP"]:
        filtered = filter_by_protocol(packets, proto)
        print(f"  {proto}: {len(filtered)} packets")
    
    # IP filtering (get top IP)
    ip_packets = filter_by_protocol(packets, "IP")
    if ip_packets:
        # Find most common source IP
        src_ips = {}
        for p in ip_packets:
            src = p[IP].src
            src_ips[src] = src_ips.get(src, 0) + 1
        if src_ips:
            top_ip = max(src_ips.items(), key=lambda x: x[1])[0]
            print(f"\nIP Filtering (top source IP: {top_ip}):")
            print("-"*40)
            filtered = filter_by_ip(packets, top_ip, "src")
            print(f"  Filtered by src {top_ip}: {len(filtered)} packets")
    
    # Port filtering
    tcp_packets = filter_by_protocol(packets, "TCP")
    if tcp_packets:
        # Find most common port
        ports = {}
        for p in tcp_packets:
            tcp = p[TCP]
            ports[tcp.sport] = ports.get(tcp.sport, 0) + 1
            ports[tcp.dport] = ports.get(tcp.dport, 0) + 1
        if ports:
            top_port = max(ports.items(), key=lambda x: x[1])[0]
            print(f"\nPort Filtering (top port: {top_port}):")
            print("-"*40)
            filtered = filter_by_port(packets, top_port, "TCP")
            print(f"  Filtered by port {top_port}: {len(filtered)} packets")
    
    # TCP flag filtering
    print("\nTCP Flag Filtering:")
    print("-"*40)
    flag_map = {
        "SYN": 0x02,
        "ACK": 0x10,
        "RST": 0x04,
        "FIN": 0x01,
    }
    for name, flag in flag_map.items():
        filtered = filter_tcp_flags(packets, flag)
        print(f"  {name}: {len(filtered)} packets")
    
    # Payload filtering
    print("\nPayload Filtering (HTTP):")
    print("-"*40)
    filtered = filter_payload(packets, "HTTP")
    print(f"  Packets containing 'HTTP': {len(filtered)}")

if __name__ == "__main__":
    main()
```

Run the filtering tool:

```bash
python3 src/pcap_filtering.py pcap_files/http.cap
```

---

### Verification Checklist

- [ ] PCAPs downloaded successfully
- [ ] PCAP analyzer runs without errors
- [ ] Protocol distribution displayed
- [ ] Top IPs and ports displayed
- [ ] Filtering tool works for all filter types
- [ ] Filter results are reasonable

---

### Lab Report

**1. How many packets were in the HTTP capture?**
```
Answer: ______________________________________________________
```

**2. What was the most common protocol?**
```
Answer: ______________________________________________________
```

**3. What was the top source IP address?**
```
Answer: ______________________________________________________
```

**4. What was the top destination port?**
```
Answer: ______________________________________________________
```

**5. How many SYN packets were found?**
```
Answer: ______________________________________________________
```

**6. How many packets contained HTTP in the payload?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Modify the analyzer to export statistics to JSON.

**Challenge 2:** Add a function to extract HTTP headers from packets.

**Challenge 3:** Build a visualization of protocol distribution using matplotlib.

---

## Lab 2.1: Ethernet Frame Construction

---

### Objectives

After completing this lab, you will be able to:
- ✅ Construct Ethernet frames with various MAC types
- ✅ Build VLAN-tagged frames (802.1Q)
- ✅ Create Q-in-Q frames
- ✅ Manipulate Ethernet frames

---

### Prerequisites

- ✅ Module 1 completed
- ✅ Understanding of MAC addressing
- ✅ Basic knowledge of Ethernet

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/ethernet_frames.py`
- `src/ethernet_utils.py`

---

### Step-by-Step Instructions

#### Step 1: Build Ethernet Frames

Create `src/ethernet_frames.py`:

```python
#!/usr/bin/env python3
"""
Module 2 Lab: Ethernet Frame Construction
"""

from scapy.all import Ether, IP, ARP, ICMP, Dot1Q, wrpcap
from scapy.layers.l2 import Dot1Q
import os

class EthernetFrameBuilder:
    """Build and analyze Ethernet frames."""
    
    def build_frames(self):
        """Build various Ethernet frames."""
        frames = []
        
        # 1. Unicast frame
        unicast = Ether(
            src="00:11:22:33:44:55",
            dst="66:77:88:99:aa:bb"
        ) / IP(src="192.168.1.100", dst="8.8.8.8") / ICMP()
        frames.append(("Unicast", unicast))
        
        # 2. Broadcast frame (ARP)
        broadcast = Ether(
            src="00:11:22:33:44:55",
            dst="ff:ff:ff:ff:ff:ff"
        ) / ARP(
            op=1,
            hwsrc="00:11:22:33:44:55",
            psrc="192.168.1.100",
            hwdst="00:00:00:00:00:00",
            pdst="192.168.1.1"
        )
        frames.append(("Broadcast", broadcast))
        
        # 3. VLAN frame
        vlan = Ether(
            src="00:11:22:33:44:55",
            dst="66:77:88:99:aa:bb"
        ) / Dot1Q(vlan=100) / IP(
            src="192.168.1.100",
            dst="8.8.8.8"
        ) / ICMP()
        frames.append(("VLAN", vlan))
        
        # 4. VLAN with priority
        vlan_prio = Ether(
            src="00:11:22:33:44:55",
            dst="66:77:88:99:aa:bb"
        ) / Dot1Q(vlan=100, prio=5) / IP(
            src="192.168.1.100",
            dst="8.8.8.8"
        ) / ICMP()
        frames.append(("VLAN Priority", vlan_prio))
        
        # 5. Q-in-Q frame
        qinq = Ether(
            src="00:11:22:33:44:55",
            dst="66:77:88:99:aa:bb"
        ) / Dot1Q(vlan=100) / Dot1Q(vlan=200) / IP(
            src="192.168.1.100",
            dst="8.8.8.8"
        ) / ICMP()
        frames.append(("Q-in-Q", qinq))
        
        return frames
    
    def analyze_frame(self, frame):
        """Analyze an Ethernet frame."""
        print("\n" + "="*60)
        print("FRAME ANALYSIS")
        print("="*60)
        
        print(f"Summary: {frame.summary()}")
        print(f"Length: {len(frame)} bytes")
        print(f"Source MAC: {frame[Ether].src}")
        print(f"Destination MAC: {frame[Ether].dst}")
        
        # Check MAC type
        dst = frame[Ether].dst
        if dst == "ff:ff:ff:ff:ff:ff":
            print("MAC Type: Broadcast")
        elif int(dst.split(':')[0], 16) & 0x01:
            print("MAC Type: Multicast")
        else:
            print("MAC Type: Unicast")
        
        print(f"EtherType: 0x{frame[Ether].type:04x}")
        
        # Check for VLAN
        if frame.haslayer(Dot1Q):
            print(f"VLAN ID: {frame[Dot1Q].vlan}")
            print(f"VLAN Priority: {frame[Dot1Q].prio}")
        
        # List all layers
        print("\nLayers in this frame:")
        p = frame
        layer_num = 1
        while p:
            print(f"  {layer_num}. {p.name}")
            p = p.payload if hasattr(p, 'payload') else None
            layer_num += 1
    
    def display_frames(self, frames):
        """Display all frames."""
        print("\n" + "="*60)
        print("ETHERNET FRAMES")
        print("="*60)
        
        for name, frame in frames:
            print(f"\n{name} Frame:")
            print("-"*40)
            frame.show()
            self.analyze_frame(frame)

def main():
    builder = EthernetFrameBuilder()
    frames = builder.build_frames()
    builder.display_frames(frames)
    
    # Save to PCAP
    os.makedirs("output", exist_ok=True)
    packets = [f for _, f in frames]
    wrpcap("output/ethernet_frames.pcap", packets)
    print("\n✅ Frames saved to output/ethernet_frames.pcap")

if __name__ == "__main__":
    main()
```

#### Step 2: Ethernet Utilities

Create `src/ethernet_utils.py`:

```python
#!/usr/bin/env python3
"""
Module 2 Lab: Ethernet Utilities
"""

import re

class EthernetUtils:
    @staticmethod
    def validate_mac(mac):
        """Validate MAC address format."""
        pattern = r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
        return bool(re.match(pattern, mac))
    
    @staticmethod
    def get_mac_type(mac):
        """Determine MAC address type."""
        if not EthernetUtils.validate_mac(mac):
            return "Invalid"
        
        mac = mac.replace(':', '').lower()
        if mac == 'ffffffffffff':
            return "Broadcast"
        elif int(mac[0:2], 16) & 0x01:
            return "Multicast"
        else:
            return "Unicast"
    
    @staticmethod
    def format_mac(mac):
        """Format MAC address with colons."""
        mac = mac.replace(':', '').replace('-', '')
        if len(mac) == 12:
            return ':'.join([mac[i:i+2] for i in range(0, 12, 2)])
        return mac
    
    @staticmethod
    def get_oui(mac):
        """Extract OUI from MAC address."""
        mac = EthernetUtils.format_mac(mac)
        return mac[:8]  # First 3 bytes

def demo():
    utils = EthernetUtils()
    
    test_macs = [
        "00:11:22:33:44:55",
        "ff:ff:ff:ff:ff:ff",
        "01:00:5e:00:00:01",
        "00-11-22-33-44-55",
        "invalid"
    ]
    
    print("Ethernet Utilities Demo:")
    print("-"*40)
    
    for mac in test_macs:
        valid = utils.validate_mac(mac)
        mac_type = utils.get_mac_type(mac) if valid else "Invalid"
        oui = utils.get_oui(mac) if valid else "N/A"
        print(f"MAC: {mac}")
        print(f"  Valid: {valid}")
        print(f"  Type: {mac_type}")
        print(f"  OUI: {oui}\n")

if __name__ == "__main__":
    demo()
```

---

### Verification Checklist

- [ ] All frame types build correctly
- [ ] MAC addresses properly set
- [ ] VLAN tags correctly applied
- [ ] Q-in-Q has two VLAN tags
- [ ] PCAP file created
- [ ] Wireshark shows all frames correctly

---

### Lab Report

**1. What is the destination MAC of the broadcast frame?**
```
Answer: ______________________________________________________
```

**2. What VLAN ID is used in the VLAN frame?**
```
Answer: ______________________________________________________
```

**3. How many VLAN tags are in the Q-in-Q frame?**
```
Answer: ______________________________________________________
```

**4. What is the EtherType of the VLAN frame?**
```
Answer: ______________________________________________________
```

**5. What did you see when you opened the PCAP in Wireshark?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add a frame with a custom EtherType (0x88B5).

**Challenge 2:** Build an IPv6 over Ethernet frame.

**Challenge 3:** Extract and display the VLAN IDs from a PCAP file.

---

## Lab 2.2: ARP Scanning

---

### Objectives

After completing this lab, you will be able to:
- ✅ Build ARP request packets
- ✅ Perform ARP scanning
- ✅ Discover hosts on a local network
- ✅ Detect duplicate IP addresses

---

### Prerequisites

- ✅ Lab 2.1 completed
- ✅ Understanding of ARP
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/arp_scanner.py`

---

### Step-by-Step Instructions

#### Step 1: Build ARP Scanner

Create `src/arp_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 2 Lab: ARP Scanner
"""

from scapy.all import Ether, ARP, srp, get_if_hwaddr, conf
import ipaddress
import time
import socket

class ARPScanner:
    def __init__(self, interface=None):
        self.interface = interface or conf.iface
        self.local_mac = get_if_hwaddr(self.interface)
        self.hosts = {}
        self.duplicates = {}
    
    def get_local_ip(self):
        """Get local IP address."""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(('8.8.8.8', 1))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return '127.0.0.1'
    
    def scan(self, network_cidr, timeout=2):
        """Scan network for hosts."""
        print(f"\n[SCAN] Scanning {network_cidr}")
        print(f"[SCAN] Interface: {self.interface}")
        print(f"[SCAN] Local MAC: {self.local_mac}")
        print(f"[SCAN] Local IP: {self.get_local_ip()}")
        
        # Parse network
        network = ipaddress.ip_network(network_cidr, strict=False)
        
        # Build ARP request
        arp_request = Ether(
            dst="ff:ff:ff:ff:ff:ff"
        ) / ARP(
            op=1,
            hwsrc=self.local_mac,
            psrc=self.get_local_ip(),
            pdst=str(network)
        )
        
        print(f"[SCAN] Scanning {network.num_addresses} addresses...")
        start = time.time()
        
        # Send and receive
        answered, unanswered = srp(
            arp_request,
            timeout=timeout,
            verbose=False
        )
        
        elapsed = time.time() - start
        
        # Process responses
        for sent, received in answered:
            ip = received[ARP].psrc
            mac = received[ARP].hwsrc
            self.hosts[ip] = mac
        
        print(f"[SCAN] Completed in {elapsed:.2f}s")
        print(f"[SCAN] Found {len(self.hosts)} hosts")
        return self.hosts
    
    def detect_duplicates(self):
        """Detect duplicate IP addresses."""
        ip_to_macs = {}
        for ip, mac in self.hosts.items():
            if ip not in ip_to_macs:
                ip_to_macs[ip] = []
            ip_to_macs[ip].append(mac)
        
        self.duplicates = {
            ip: macs for ip, macs in ip_to_macs.items()
            if len(macs) > 1
        }
        
        return self.duplicates
    
    def display(self):
        """Display discovered hosts."""
        if not self.hosts:
            print("\nNo hosts discovered.")
            return
        
        print("\n" + "="*60)
        print("DISCOVERED HOSTS")
        print("="*60)
        print(f"{'IP Address':<20} {'MAC Address':<20} {'Vendor':<15}")
        print("-"*60)
        
        for ip, mac in sorted(self.hosts.items()):
            vendor = self.get_vendor(mac)
            print(f"{ip:<20} {mac:<20} {vendor:<15}")
        
        print("-"*60)
        print(f"Total: {len(self.hosts)} hosts")
        
        # Check duplicates
        if self.duplicates:
            print("\n⚠️ DUPLICATE IP ADDRESSES:")
            print("-"*40)
            for ip, macs in self.duplicates.items():
                print(f"  {ip}: {', '.join(macs)}")
    
    def get_vendor(self, mac):
        """Get vendor from OUI (simplified)."""
        oui = mac[:8].upper()
        vendors = {
            '00:11:22': 'Test Vendor 1',
            '00:50:56': 'VMware',
            '00:0C:29': 'VMware',
            '08:00:27': 'VirtualBox',
            '00:15:5D': 'Hyper-V',
            '00:1C:42': 'Cisco',
            '00:04:76': 'Apple',
            '00:1B:63': 'Apple',
            '00:24:36': 'Apple',
        }
        return vendors.get(oui, 'Unknown')

def main():
    scanner = ARPScanner()
    
    # Auto-detect network
    local_ip = scanner.get_local_ip()
    if local_ip != '127.0.0.1':
        parts = local_ip.split('.')
        network = f"{parts[0]}.{parts[1]}.{parts[2]}.0/24"
    else:
        network = "192.168.1.0/24"
    
    # Scan
    hosts = scanner.scan(network)
    scanner.detect_duplicates()
    scanner.display()

if __name__ == "__main__":
    # Check for root
    import os
    if os.geteuid() != 0:
        print("⚠️ Running without root privileges (ARP scan may fail)")
    main()
```

#### Step 2: Run the Scanner

```bash
# Run with root (recommended)
sudo python3 src/arp_scanner.py

# Or without root (may fail)
python3 src/arp_scanner.py
```

---

### Verification Checklist

- [ ] Scanner runs without errors
- [ ] Hosts are discovered
- [ ] IP and MAC addresses are displayed
- [ ] Vendor information is shown
- [ ] Duplicate IP detection works

---

### Lab Report

**1. How many hosts were discovered?**
```
Answer: ______________________________________________________
```

**2. What is the MAC address of your gateway?**
```
Answer: ______________________________________________________
```

**3. Were any duplicate IPs found?**
```
Answer: ______________________________________________________
```

**4. What vendor OUI were detected?**
```
Answer: ______________________________________________________
```

**5. How long did the scan take?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Modify the scanner to save results to a file.

**Challenge 2:** Add a continuous monitoring mode.

**Challenge 3:** Build a network topology map from ARP results.

---

## Lab 2.3: Custom Ping Utility

---

### Objectives

After completing this lab, you will be able to:
- ✅ Build ICMP Echo Request packets
- ✅ Send and receive ICMP packets
- ✅ Calculate RTT statistics
- ✅ Implement continuous ping mode

---

### Prerequisites

- ✅ Understanding of ICMP
- ✅ Knowledge of ping operation
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/custom_ping.py`

---

### Step-by-Step Instructions

#### Step 1: Build Custom Ping

Create `src/custom_ping.py`:

```python
#!/usr/bin/env python3
"""
Module 2 Lab: Custom Ping Utility
"""

from scapy.all import IP, ICMP, sr1
import time
import statistics
import sys
import signal

class CustomPing:
    def __init__(self, target, count=4, timeout=2, interval=1,
                 packet_size=64, ttl=64):
        self.target = target
        self.count = count
        self.timeout = timeout
        self.interval = interval
        self.packet_size = packet_size
        self.ttl = ttl
        self.sent = 0
        self.received = 0
        self.times = []
        self.results = []
        self.running = True
    
    def build_packet(self, seq):
        """Build an ICMP Echo Request packet."""
        # Calculate payload
        payload = b"Ping data from Scapy!" + b"X" * max(0, self.packet_size - 20)
        payload = payload[:self.packet_size]
        
        # Build packet
        packet = IP(
            dst=self.target,
            ttl=self.ttl
        ) / ICMP(
            type=8,  # Echo Request
            code=0,
            id=12345,
            seq=seq
        ) / Raw(load=payload)
        
        return packet
    
    def ping_one(self, seq):
        """Send one ping request."""
        packet = self.build_packet(seq)
        start = time.time()
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        elapsed = (time.time() - start) * 1000  # Convert to ms
        
        self.sent += 1
        
        result = {
            'seq': seq,
            'success': False,
            'time': elapsed,
            'ttl': None,
            'error': None
        }
        
        if reply is None:
            result['error'] = 'Timeout'
        elif reply.haslayer(ICMP) and reply[ICMP].type == 0:
            result['success'] = True
            result['time'] = elapsed
            result['ttl'] = reply[IP].ttl
            self.received += 1
            self.times.append(elapsed)
        else:
            result['error'] = f"ICMP type {reply[ICMP].type}"
        
        self.results.append(result)
        return result
    
    def ping(self):
        """Execute ping sequence."""
        print(f"\nPING {self.target}")
        print(f"  Packets: {self.count}")
        print(f"  Packet size: {self.packet_size} bytes")
        print(f"  TTL: {self.ttl}")
        print(f"  Timeout: {self.timeout}s")
        print("-"*60)
        
        if self.count == 0:
            print("Press Ctrl+C to stop")
            print("-"*60)
        
        seq = 1
        start_time = time.time()
        
        while self.running and (self.count == 0 or seq <= self.count):
            result = self.ping_one(seq)
            
            # Display result
            if result['success']:
                print(f"Reply from {self.target}: time={result['time']:.2f}ms TTL={result['ttl']}")
            else:
                print(f"Request timed out ({result.get('error', 'unknown')})")
            
            seq += 1
            
            if self.count == 0:
                # Check every 10 pings for statistics
                if seq % 10 == 0:
                    self.display_stats()
            
            if seq <= self.count or self.count == 0:
                time.sleep(self.interval)
        
        total_time = time.time() - start_time
        self.display_stats(total_time)
    
    def display_stats(self, total_time=None):
        """Display ping statistics."""
        print("-"*60)
        print(f"Packets: Sent={self.sent}, Received={self.received}")
        
        if self.sent > 0:
            loss = ((self.sent - self.received) / self.sent) * 100
            print(f"Packet loss: {loss:.1f}%")
        
        if self.times:
            print(f"RTT Statistics:")
            print(f"  Min: {min(self.times):.2f}ms")
            print(f"  Max: {max(self.times):.2f}ms")
            print(f"  Avg: {statistics.mean(self.times):.2f}ms")
            if len(self.times) > 1:
                print(f"  StdDev: {statistics.stdev(self.times):.2f}ms")
    
    def stop(self):
        """Stop continuous ping."""
        self.running = False

def signal_handler(sig, frame):
    """Handle Ctrl+C."""
    if hasattr(signal_handler, 'pinger'):
        signal_handler.pinger.stop()
    print("\nPing stopped")

def main():
    # Parse arguments
    import argparse
    parser = argparse.ArgumentParser(description='Custom Ping Utility')
    parser.add_argument('target', help='Target IP or hostname')
    parser.add_argument('-c', '--count', type=int, default=4,
                        help='Number of pings (0 for continuous)')
    parser.add_argument('-t', '--timeout', type=int, default=2,
                        help='Timeout in seconds')
    parser.add_argument('-i', '--interval', type=float, default=1,
                        help='Interval between pings')
    parser.add_argument('-s', '--size', type=int, default=64,
                        help='Packet size in bytes')
    parser.add_argument('--ttl', type=int, default=64,
                        help='Time To Live')
    args = parser.parse_args()
    
    pinger = CustomPing(
        target=args.target,
        count=args.count,
        timeout=args.timeout,
        interval=args.interval,
        packet_size=args.size,
        ttl=args.ttl
    )
    
    signal_handler.pinger = pinger
    signal.signal(signal.SIGINT, signal_handler)
    
    try:
        pinger.ping()
    except KeyboardInterrupt:
        pinger.stop()
        print("\nPing stopped")

if __name__ == "__main__":
    # Check for root
    import os
    if os.geteuid() != 0:
        print("⚠️ Running without root privileges (ping may fail)")
    
    if len(sys.argv) == 1:
        target = input("Enter target IP: ").strip()
        count = input("Number of pings (0 for continuous): ").strip()
        count = int(count) if count else 4
        pinger = CustomPing(target=target, count=count)
        pinger.ping()
    else:
        main()
```

---

### Verification Checklist

- [ ] Ping works to 8.8.8.8
- [ ] Statistics are calculated correctly
- [ ] Packet sizes are correct
- [ ] TTL values are honored
- [ ] Continuous mode works
- [ ] Ctrl+C stops gracefully

---

### Lab Report

**1. What is the RTT to 8.8.8.8?**
```
Answer: ______________________________________________________
```

**2. What was the packet loss percentage?**
```
Answer: ______________________________________________________
**

3. How does increasing packet size affect RTT?**
```
Answer: ______________________________________________________
```

**4. What TTL value was returned in the reply?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add timestamp support to the ping utility.

**Challenge 2:** Implement parallel ping (ping multiple hosts).

**Challenge 3:** Build a ping sweep tool that pings all hosts in a subnet.

---

## Lab 2.4: Traceroute Implementation

---

### Objectives

After completing this lab, you will be able to:
- ✅ Understand how traceroute works
- ✅ Implement traceroute using TTL
- ✅ Parse ICMP Time Exceeded messages
- ✅ Display hop-by-hop results

---

### Prerequisites

- ✅ Understanding of TTL
- ✅ Knowledge of ICMP
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/custom_traceroute.py`

---

### Step-by-Step Instructions

#### Step 1: Build Traceroute

Create `src/custom_traceroute.py`:

```python
#!/usr/bin/env python3
"""
Module 2 Lab: Custom Traceroute
"""

from scapy.all import IP, ICMP, sr1
import time
import socket
import sys

class CustomTraceroute:
    def __init__(self, target, max_hops=30, timeout=2, probes=3):
        self.target = target
        self.max_hops = max_hops
        self.timeout = timeout
        self.probes = probes
        self.hops = []
        self.reached = False
    
    def resolve_host(self):
        """Resolve target hostname."""
        try:
            self.target_ip = socket.gethostbyname(self.target)
            print(f"Resolved: {self.target} -> {self.target_ip}")
            return True
        except:
            print(f"Could not resolve: {self.target}")
            return False
    
    def get_hop(self, ttl, probe_num):
        """Probe a single hop."""
        packet = IP(dst=self.target_ip, ttl=ttl) / ICMP(
            type=8, code=0, id=12345, seq=ttl * self.probes + probe_num
        )
        
        start = time.time()
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        elapsed = (time.time() - start) * 1000
        
        return {
            'ttl': ttl,
            'probe': probe_num,
            'reply': reply,
            'time': elapsed,
            'ip': None,
            'hostname': None,
            'reached': False
        }
    
    def trace(self):
        """Execute traceroute."""
        if not self.resolve_host():
            return None
        
        print("\n" + "="*60)
        print(f"TRACEROUTE to {self.target} ({self.target_ip})")
        print("="*60)
        print(f"Max hops: {self.max_hops}")
        print(f"Probes per hop: {self.probes}")
        print("-"*60)
        
        print(f"{'TTL':>4} {'IP Address':<20} {'Hostname':<30} {'Time':<10}")
        print("-"*60)
        
        for ttl in range(1, self.max_hops + 1):
            if self.reached:
                break
            
            hop_results = []
            for probe in range(self.probes):
                result = self.get_hop(ttl, probe)
                hop_results.append(result)
            
            # Find first successful probe
            best = None
            for result in hop_results:
                if result['reply']:
                    best = result
                    break
            
            if best:
                reply = best['reply']
                ip = reply[IP].src
                best['ip'] = ip
                
                # Try to resolve hostname
                try:
                    hostname = socket.gethostbyaddr(ip)[0]
                    best['hostname'] = hostname
                except:
                    best['hostname'] = ip
                
                # Check if reached target
                if reply.haslayer(ICMP):
                    if reply[ICMP].type == 0:  # Echo Reply
                        best['reached'] = True
                        self.reached = True
                    elif reply[ICMP].type == 11:  # Time Exceeded
                        best['reached'] = False
                
                self.hops.append(best)
                
                # Display
                avg_time = sum(r['time'] for r in hop_results if r['reply']) / max(1, sum(1 for r in hop_results if r['reply']))
                time_str = f"{avg_time:.2f}ms"
                hostname = best['hostname'] if best['hostname'] else ip
                status = " ✓" if best['reached'] else ""
                print(f"{ttl:>4} {ip:<20} {hostname:<30} {time_str:<10}{status}")
            else:
                # No response
                print(f"{ttl:>4} {'*':<20} {'*':<30} {'*':<10}")
                self.hops.append(None)
            
            time.sleep(0.1)  # Small delay between hops
        
        # Display summary
        print("-"*60)
        if self.reached:
            print(f"✅ Destination reached in {len(self.hops)} hops")
        else:
            print(f"❌ Destination not reached (max hops: {self.max_hops})")
    
    def export(self, filename=None):
        """Export results to file."""
        if filename is None:
            timestamp = time.strftime('%Y%m%d_%H%M%S')
            filename = f"traceroute_{self.target}_{timestamp}.txt"
        
        with open(filename, 'w') as f:
            f.write(f"Traceroute to {self.target} ({self.target_ip})\n")
            f.write(f"Date: {time.ctime()}\n")
            f.write("-"*60 + "\n")
            f.write(f"{'TTL':>4} {'IP Address':<20} {'Hostname':<30} {'Time':<10}\n")
            f.write("-"*60 + "\n")
            
            for hop in self.hops:
                if hop:
                    time_str = f"{hop['time']:.2f}ms"
                    hostname = hop['hostname'] if hop['hostname'] else hop['ip']
                    status = " ✓" if hop['reached'] else ""
                    f.write(f"{hop['ttl']:>4} {hop['ip']:<20} {hostname:<30} {time_str:<10}{status}\n")
                else:
                    f.write(f"{ttl:>4} {'*':<20} {'*':<30} {'*':<10}\n")
            
            f.write("-"*60 + "\n")
            f.write(f"Total hops: {len(self.hops)}\n")
            f.write(f"Reached: {self.reached}\n")
        
        print(f"\n✅ Results exported to: {filename}")

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Custom Traceroute')
    parser.add_argument('target', help='Target IP or hostname')
    parser.add_argument('-m', '--max-hops', type=int, default=30,
                        help='Maximum hops')
    parser.add_argument('-t', '--timeout', type=int, default=2,
                        help='Timeout in seconds')
    parser.add_argument('-p', '--probes', type=int, default=3,
                        help='Probes per hop')
    parser.add_argument('-e', '--export', help='Export results to file')
    args = parser.parse_args()
    
    tracer = CustomTraceroute(
        target=args.target,
        max_hops=args.max_hops,
        timeout=args.timeout,
        probes=args.probes
    )
    
    tracer.trace()
    if args.export:
        tracer.export(args.export)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        target = input("Enter target IP or hostname: ").strip()
        if target:
            tracer = CustomTraceroute(target)
            tracer.trace()
        else:
            print("No target specified")
    else:
        main()
```

---

### Verification Checklist

- [ ] Traceroute runs without errors
- [ ] Hops are displayed correctly
- [ ] Hostnames are resolved (when possible)
- [ ] Destination is reached (or max hops reached)
- [ ] Export works

---

### Lab Report

**1. How many hops to reach the destination?**
```
Answer: ______________________________________________________
```

**2. What is the first hop's IP address?**
```
Answer: ______________________________________________________
```

**3. What is the first hop's hostname (if resolved)?**
```
Answer: ______________________________________________________
**

4. How long did the traceroute take?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add UDP traceroute support.

**Challenge 2:** Implement a visual traceroute with ASCII art.

**Challenge 3:** Build a parallel traceroute for multiple targets.

---

## Lab 3.1: TCP SYN Scanner

---

### Objectives

After completing this lab, you will be able to:
- ✅ Build TCP SYN packets
- ✅ Perform SYN scanning
- ✅ Implement multi-threading
- ✅ Display scan results

---

### Prerequisites

- ✅ Understanding of TCP handshake
- ✅ Knowledge of SYN scan
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/tcp_syn_scanner.py`

---

### Step-by-Step Instructions

#### Step 1: Build SYN Scanner

Create `src/tcp_syn_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 3 Lab: TCP SYN Scanner
"""

from scapy.all import IP, TCP, sr1, send
import threading
import queue
import time
import sys
from datetime import datetime

class TCPSYNScanner:
    SERVICES = {
        20: 'FTP-Data', 21: 'FTP', 22: 'SSH', 23: 'Telnet',
        25: 'SMTP', 53: 'DNS', 80: 'HTTP', 110: 'POP3',
        111: 'RPC', 135: 'MSRPC', 139: 'NetBIOS', 143: 'IMAP',
        443: 'HTTPS', 445: 'SMB', 993: 'IMAPS', 995: 'POP3S',
        3306: 'MySQL', 3389: 'RDP', 5432: 'PostgreSQL',
        5900: 'VNC', 6379: 'Redis', 8080: 'HTTP-Alt'
    }
    
    def __init__(self, target, ports=None, threads=10, timeout=2,
                 rate_limit=None):
        self.target = target
        self.ports = ports or list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.rate_limit = rate_limit
        self.open_ports = []
        self.filtered_ports = []
        self.closed_ports = []
        self.queue = queue.Queue()
        self.lock = threading.Lock()
        self.total_scanned = 0
        self.last_packet_time = 0
        self.start_time = None
    
    def parse_ports(self, port_spec):
        """Parse port specification (e.g., '1-1000,80,443')."""
        ports = []
        for part in port_spec.split(','):
            if '-' in part:
                start, end = part.split('-')
                ports.extend(range(int(start), int(end) + 1))
            else:
                ports.append(int(part))
        return ports
    
    def scan_port(self, port):
        """Scan a single port using SYN scan."""
        # Apply rate limiting
        if self.rate_limit:
            interval = 1.0 / self.rate_limit
            with self.lock:
                elapsed = time.time() - self.last_packet_time
                if elapsed < interval:
                    time.sleep(interval - elapsed)
                self.last_packet_time = time.time()
        
        # Build SYN packet
        packet = IP(dst=self.target) / TCP(
            dport=port,
            flags="S",
            seq=1000
        )
        
        # Send and receive
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        with self.lock:
            self.total_scanned += 1
        
        # Analyze response
        if reply is None:
            return "filtered"
        
        if reply.haslayer(TCP):
            tcp = reply[TCP]
            if tcp.flags & 0x12:  # SYN-ACK
                # Send RST to close (stealth)
                rst = IP(dst=self.target) / TCP(
                    dport=port,
                    flags="R",
                    seq=tcp.ack
                )
                send(rst, verbose=False)
                return "open"
            elif tcp.flags & 0x04:  # RST
                return "closed"
        
        return "filtered"
    
    def worker(self):
        """Worker thread."""
        while not self.queue.empty():
            try:
                port = self.queue.get_nowait()
                status = self.scan_port(port)
                
                with self.lock:
                    if status == "open":
                        self.open_ports.append(port)
                    elif status == "closed":
                        self.closed_ports.append(port)
                    else:
                        self.filtered_ports.append(port)
                    
                    # Progress
                    if self.total_scanned % 50 == 0:
                        progress = (self.total_scanned / len(self.ports)) * 100
                        print(f"  Progress: {self.total_scanned}/{len(self.ports)} "
                              f"({progress:.1f}%) - {len(self.open_ports)} open")
                
                self.queue.task_done()
            except:
                self.queue.task_done()
    
    def scan(self):
        """Execute scan."""
        print("\n" + "="*60)
        print("TCP SYN PORT SCANNER")
        print("="*60)
        print(f"Target: {self.target}")
        print(f"Ports: {len(self.ports)}")
        print(f"Threads: {self.threads}")
        print(f"Timeout: {self.timeout}s")
        if self.rate_limit:
            print(f"Rate Limit: {self.rate_limit} packets/second")
        print("-"*60)
        
        # Fill queue
        for port in self.ports:
            self.queue.put(port)
        
        self.start_time = time.time()
        
        # Start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for completion
        for t in threads:
            t.join()
        
        elapsed = time.time() - self.start_time
        
        # Display results
        self.display_results(elapsed)
    
    def display_results(self, elapsed):
        """Display scan results."""
        print("\n" + "="*60)
        print("SCAN RESULTS")
        print("="*60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed:.2f}s")
        print(f"Ports scanned: {len(self.ports)}")
        print(f"Open ports: {len(self.open_ports)}")
        print(f"Closed ports: {len(self.closed_ports)}")
        print(f"Filtered ports: {len(self.filtered_ports)}")
        
        if self.open_ports:
            print("\nOPEN PORTS:")
            print("-"*40)
            print(f"{'Port':<10} {'Service':<20}")
            print("-"*40)
            for port in sorted(self.open_ports):
                service = self.SERVICES.get(port, 'Unknown')
                print(f"{port:<10} {service:<20}")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='TCP SYN Port Scanner')
    parser.add_argument('target', help='Target IP address')
    parser.add_argument('-p', '--ports', default='1-1024',
                        help='Port range (e.g., 1-1000,80,443)')
    parser.add_argument('-t', '--threads', type=int, default=10,
                        help='Number of threads')
    parser.add_argument('--timeout', type=float, default=2,
                        help='Timeout in seconds')
    parser.add_argument('-r', '--rate-limit', type=int,
                        help='Rate limit (packets/second)')
    args = parser.parse_args()
    
    scanner = TCPSYNScanner(
        target=args.target,
        ports=scanner.parse_ports(args.ports),
        threads=args.threads,
        timeout=args.timeout,
        rate_limit=args.rate_limit
    )
    
    try:
        scanner.scan()
    except KeyboardInterrupt:
        print("\n\nScan interrupted by user")
        if scanner.open_ports:
            print(f"Partial results: {len(scanner.open_ports)} open ports found")

if __name__ == "__main__":
    import os
    if os.geteuid() != 0:
        print("⚠️ Warning: SYN scan requires root privileges")
        print("Run with: sudo python3 src/tcp_syn_scanner.py")
        sys.exit(1)
    
    if len(sys.argv) == 1:
        target = input("Enter target IP: ").strip()
        threads = input("Threads (default: 10): ").strip()
        threads = int(threads) if threads else 10
        scanner = TCPSYNScanner(target=target, threads=threads)
        scanner.scan()
    else:
        main()
```

---

### Verification Checklist

- [ ] Scanner runs with root privileges
- [ ] Ports are discovered correctly
- [ ] Threads work in parallel
- [ ] Progress is displayed
- [ ] Results are accurate

---

### Lab Report

**1. How many open ports were found?**
```
Answer: ______________________________________________________
```

**2. What was the scan speed (ports/second)?**
```
Answer: ______________________________________________________
```

**3. Which open ports were found?**
```
Answer: ______________________________________________________
```

**4. How did multi-threading affect performance?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add stealth options (randomize source ports, delays).

**Challenge 2:** Implement SYN-ACK detection for port status.

**Challenge 3:** Add IP spoofing support (for educational purposes only).

---

## Lab 3.2: TCP Connect Scanner with Banner Grabbing

---

### Objectives

After completing this lab, you will be able to:
- ✅ Perform TCP Connect scanning
- ✅ Grab banners from services
- ✅ Identify service versions
- ✅ Implement timeouts

---

### Prerequisites

- ✅ Knowledge of socket programming
- ✅ Understanding of services
- ✅ No root required (Connect scan)

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/tcp_connect_scanner.py`

---

### Step-by-Step Instructions

#### Step 1: Build Connect Scanner

Create `src/tcp_connect_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 3 Lab: TCP Connect Scanner with Banner Grabbing
"""

import socket
import threading
import queue
import time
import sys

class TCPConnectScanner:
    SERVICES = {
        20: 'FTP-Data', 21: 'FTP', 22: 'SSH', 23: 'Telnet',
        25: 'SMTP', 53: 'DNS', 80: 'HTTP', 110: 'POP3',
        111: 'RPC', 135: 'MSRPC', 139: 'NetBIOS', 143: 'IMAP',
        443: 'HTTPS', 445: 'SMB', 993: 'IMAPS', 995: 'POP3S',
        3306: 'MySQL', 3389: 'RDP', 5432: 'PostgreSQL',
        5900: 'VNC', 6379: 'Redis', 8080: 'HTTP-Alt'
    }
    
    SERVICE_PROBES = {
        22: b"SSH-2.0-Scapy\r\n",
        80: b"HEAD / HTTP/1.0\r\n\r\n",
        443: b"HEAD / HTTP/1.0\r\n\r\n",
        25: b"EHLO test\r\n",
        21: b"USER anonymous\r\n",
        110: b"USER test\r\n",
        143: b"a001 CAPABILITY\r\n",
        3306: b"\x00\x00\x00\x0b\x04\x00\x00\x00" + b"\x00"*7,
    }
    
    def __init__(self, target, ports=None, threads=10, timeout=3,
                 grab_banner=True, banner_timeout=2):
        self.target = target
        self.ports = ports or list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.grab_banner = grab_banner
        self.banner_timeout = banner_timeout
        self.open_ports = []
        self.banners = {}
        self.queue = queue.Queue()
        self.lock = threading.Lock()
        self.total_scanned = 0
    
    def parse_ports(self, port_spec):
        """Parse port specification."""
        ports = []
        for part in port_spec.split(','):
            if '-' in part:
                start, end = part.split('-')
                ports.extend(range(int(start), int(end) + 1))
            else:
                ports.append(int(part))
        return ports
    
    def grab_banner_thread(self, port):
        """Grab banner from a service."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.banner_timeout)
            sock.connect((self.target, port))
            
            # Send probe if available
            if port in self.SERVICE_PROBES:
                sock.send(self.SERVICE_PROBES[port])
                time.sleep(0.1)  # Wait for response
            
            # Read response
            banner = sock.recv(1024).decode('utf-8', errors='ignore')
            sock.close()
            
            # Clean up banner
            banner = banner.replace('\r\n', ' ').replace('\n', ' ').strip()
            return banner[:200]  # Truncate
            
        except Exception:
            return None
    
    def scan_port(self, port):
        """Scan a port using TCP connect."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            with self.lock:
                self.total_scanned += 1
            
            if result == 0:  # Connection successful
                banner = None
                if self.grab_banner:
                    banner = self.grab_banner_thread(port)
                
                with self.lock:
                    self.open_ports.append(port)
                    if banner:
                        self.banners[port] = banner
                
                return True
            
            return False
            
        except Exception:
            return False
    
    def worker(self):
        """Worker thread."""
        while not self.queue.empty():
            try:
                port = self.queue.get_nowait()
                self.scan_port(port)
                
                with self.lock:
                    if self.total_scanned % 50 == 0:
                        progress = (self.total_scanned / len(self.ports)) * 100
                        print(f"  Progress: {self.total_scanned}/{len(self.ports)} "
                              f"({progress:.1f}%) - {len(self.open_ports)} open")
                
                self.queue.task_done()
            except:
                self.queue.task_done()
    
    def scan(self):
        """Execute the scan."""
        print("\n" + "="*60)
        print("TCP CONNECT PORT SCANNER")
        print("="*60)
        print(f"Target: {self.target}")
        print(f"Ports: {len(self.ports)}")
        print(f"Threads: {self.threads}")
        print(f"Timeout: {self.timeout}s")
        if self.grab_banner:
            print("Banner grabbing: Enabled")
        print("-"*60)
        
        # Fill queue
        for port in self.ports:
            self.queue.put(port)
        
        start_time = time.time()
        
        # Start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for completion
        for t in threads:
            t.join()
        
        elapsed = time.time() - start_time
        
        # Display results
        self.display_results(elapsed)
    
    def display_results(self, elapsed):
        """Display scan results."""
        print("\n" + "="*60)
        print("SCAN RESULTS")
        print("="*60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed:.2f}s")
        print(f"Open ports: {len(self.open_ports)}")
        
        if self.open_ports:
            print("\nOPEN PORTS:")
            print("-"*60)
            print(f"{'Port':<10} {'Service':<15} {'Banner'}")
            print("-"*60)
            for port in sorted(self.open_ports):
                service = self.SERVICES.get(port, 'Unknown')
                banner = self.banners.get(port, '')
                if banner:
                    print(f"{port:<10} {service:<15} {banner[:50]}")
                else:
                    print(f"{port:<10} {service:<15}")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='TCP Connect Scanner')
    parser.add_argument('target', help='Target IP address')
    parser.add_argument('-p', '--ports', default='1-1024',
                        help='Port range (e.g., 1-1000,80,443)')
    parser.add_argument('-t', '--threads', type=int, default=10,
                        help='Number of threads')
    parser.add_argument('--timeout', type=float, default=3,
                        help='Connection timeout')
    parser.add_argument('--no-banner', action='store_true',
                        help='Disable banner grabbing')
    args = parser.parse_args()
    
    scanner = TCPConnectScanner(
        target=args.target,
        ports=scanner.parse_ports(args.ports),
        threads=args.threads,
        timeout=args.timeout,
        grab_banner=not args.no_banner
    )
    
    try:
        scanner.scan()
    except KeyboardInterrupt:
        print("\n\nScan interrupted by user")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        target = input("Enter target IP: ").strip()
        ports = input("Port range (default: 1-1024): ").strip()
        if not ports:
            ports = "1-1024"
        grab = input("Grab banners? (y/n): ").strip().lower() == 'y'
        
        scanner = TCPConnectScanner(
            target=target,
            ports=scanner.parse_ports(ports),
            grab_banner=grab
        )
        scanner.scan()
    else:
        main()
```

---

### Verification Checklist

- [ ] Scanner runs without errors
- [ ] Open ports are discovered
- [ ] Banners are grabbed (if enabled)
- [ ] Service names are displayed
- [ ] Results are accurate

---

### Lab Report

**1. How many open ports were found?**
```
Answer: ______________________________________________________
```

**2. What services were detected?**
```
Answer: ______________________________________________________
```

**3. What banners were grabbed?**
```
Answer: ______________________________________________________
```

**4. What was the scan speed (ports/second)?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add custom service detection rules.

**Challenge 2:** Implement service fingerprinting (vs just banner).

**Challenge 3:** Add SSL/TLS detection for HTTPS.

---

## Lab 3.3: UDP Scanner

---

### Objectives

After completing this lab, you will be able to:
- ✅ Build UDP packets
- ✅ Perform UDP scanning
- ✅ Detect ICMP Port Unreachable
- ✅ Identify UDP services

---

### Prerequisites

- ✅ Understanding of UDP
- ✅ Knowledge of ICMP
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/udp_scanner.py`

---

### Step-by-Step Instructions

#### Step 1: Build UDP Scanner

Create `src/udp_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 3 Lab: UDP Scanner
"""

from scapy.all import IP, UDP, sr1, ICMP
import threading
import queue
import time
import sys

class UDPScanner:
    COMMON_UDP_PORTS = {
        53: 'DNS',
        67: 'DHCP-Server',
        68: 'DHCP-Client',
        69: 'TFTP',
        123: 'NTP',
        161: 'SNMP',
        162: 'SNMP-Trap',
        389: 'LDAP',
        514: 'Syslog',
        520: 'RIP',
        1434: 'SQL-Server',
        1900: 'UPnP',
        4500: 'IPsec',
        5353: 'mDNS'
    }
    
    def __init__(self, target, ports=None, threads=10, timeout=2):
        self.target = target
        self.ports = ports or list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
        self.closed_ports = []
        self.filtered_ports = []
        self.queue = queue.Queue()
        self.lock = threading.Lock()
        self.total_scanned = 0
    
    def parse_ports(self, port_spec):
        """Parse port specification."""
        ports = []
        for part in port_spec.split(','):
            if '-' in part:
                start, end = part.split('-')
                ports.extend(range(int(start), int(end) + 1))
            else:
                ports.append(int(part))
        return ports
    
    def scan_port(self, port):
        """Scan a single UDP port."""
        # Build UDP packet with small payload
        packet = IP(dst=self.target) / UDP(
            sport=12345,
            dport=port
        ) / Raw(b"UDP scan probe")
        
        # Send and receive
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        with self.lock:
            self.total_scanned += 1
        
        # Analyze response
        if reply is None:
            return "open_or_filtered"
        
        if reply.haslayer(ICMP):
            icmp = reply[ICMP]
            if icmp.type == 3:  # Destination Unreachable
                if icmp.code == 3:  # Port Unreachable
                    return "closed"
                else:
                    return "filtered"
            else:
                return "open"
        
        if reply.haslayer(UDP):
            return "open"
        
        return "filtered"
    
    def worker(self):
        """Worker thread."""
        while not self.queue.empty():
            try:
                port = self.queue.get_nowait()
                status = self.scan_port(port)
                
                with self.lock:
                    if status == "open" or status == "open_or_filtered":
                        self.open_ports.append(port)
                    elif status == "closed":
                        self.closed_ports.append(port)
                    else:
                        self.filtered_ports.append(port)
                    
                    if self.total_scanned % 50 == 0:
                        progress = (self.total_scanned / len(self.ports)) * 100
                        print(f"  Progress: {self.total_scanned}/{len(self.ports)} "
                              f"({progress:.1f}%) - {len(self.open_ports)} open")
                
                self.queue.task_done()
            except:
                self.queue.task_done()
    
    def scan(self):
        """Execute the scan."""
        print("\n" + "="*60)
        print("UDP PORT SCANNER")
        print("="*60)
        print(f"Target: {self.target}")
        print(f"Ports: {len(self.ports)}")
        print(f"Threads: {self.threads}")
        print(f"Timeout: {self.timeout}s")
        print("-"*60)
        
        # Fill queue
        for port in self.ports:
            self.queue.put(port)
        
        start_time = time.time()
        
        # Start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for completion
        for t in threads:
            t.join()
        
        elapsed = time.time() - start_time
        
        # Display results
        self.display_results(elapsed)
    
    def display_results(self, elapsed):
        """Display scan results."""
        print("\n" + "="*60)
        print("SCAN RESULTS")
        print("="*60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed:.2f}s")
        print(f"Open ports: {len(self.open_ports)}")
        print(f"Closed ports: {len(self.closed_ports)}")
        print(f"Filtered ports: {len(self.filtered_ports)}")
        
        if self.open_ports:
            print("\nOPEN OR FILTERED PORTS:")
            print("-"*40)
            print(f"{'Port':<10} {'Service':<20}")
            print("-"*40)
            for port in sorted(self.open_ports):
                service = self.COMMON_UDP_PORTS.get(port, 'Unknown')
                print(f"{port:<10} {service:<20}")
            print("\nNote: UDP ports may be open or filtered")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='UDP Port Scanner')
    parser.add_argument('target', help='Target IP address')
    parser.add_argument('-p', '--ports', default='1-1024',
                        help='Port range (e.g., 1-1000,53,123)')
    parser.add_argument('-t', '--threads', type=int, default=5,
                        help='Number of threads')
    parser.add_argument('--timeout', type=float, default=2,
                        help='Timeout in seconds')
    args = parser.parse_args()
    
    scanner = UDPScanner(
        target=args.target,
        ports=scanner.parse_ports(args.ports),
        threads=args.threads,
        timeout=args.timeout
    )
    
    try:
        scanner.scan()
    except KeyboardInterrupt:
        print("\n\nScan interrupted by user")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        target = input("Enter target IP: ").strip()
        ports = input("Port range (default: 1-1024): ").strip()
        if not ports:
            ports = "1-1024"
        
        scanner = UDPScanner(
            target=target,
            ports=scanner.parse_ports(ports)
        )
        scanner.scan()
    else:
        main()
```

---

### Verification Checklist

- [ ] Scanner runs with root privileges
- [ ] UDP ports are scanned
- [ ] ICMP responses are interpreted correctly
- [ ] Results are displayed

---

### Lab Report

**1. How many UDP ports were found open/filtered?**
```
Answer: ______________________________________________________
```

**2. What UDP services were detected?**
```
Answer: ______________________________________________________
```

**3. How does UDP scanning compare to TCP scanning in speed?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Implement UDP service detection with protocol-specific probes.

**Challenge 2:** Add support for UDP packet fragmentation.

**Challenge 3:** Implement UDP port scanning with different payloads.

---

## Lab 4.1: Basic Packet Sniffer

---

### Objectives

After completing this lab, you will be able to:
- ✅ Capture packets with `sniff()`
- ✅ Apply BPF filters
- ✅ Process packets with callbacks
- ✅ Display packet information

---

### Prerequisites

- ✅ Understanding of sniffing
- ✅ Knowledge of BPF filters
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/basic_sniffer.py`

---

### Step-by-Step Instructions

#### Step 1: Build Basic Sniffer

Create `src/basic_sniffer.py`:

```python
#!/usr/bin/env python3
"""
Module 4 Lab: Basic Packet Sniffer
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP, conf
from datetime import datetime
import time
import sys

class BasicSniffer:
    def __init__(self, interface=None, filter_str=None, count=0, timeout=None):
        self.interface = interface or conf.iface
        self.filter_str = filter_str
        self.count = count
        self.timeout = timeout
        self.packet_count = 0
        self.start_time = None
        self.stats = {
            'total': 0,
            'tcp': 0,
            'udp': 0,
            'icmp': 0,
            'other_ip': 0,
            'non_ip': 0,
            'bytes': 0
        }
        self.packets = []
    
    def packet_callback(self, packet):
        """Callback for each captured packet."""
        self.packet_count += 1
        self.stats['total'] += 1
        self.stats['bytes'] += len(packet)
        
        # Classify protocol
        if packet.haslayer(TCP):
            self.stats['tcp'] += 1
            self.handle_tcp(packet)
        elif packet.haslayer(UDP):
            self.stats['udp'] += 1
            self.handle_udp(packet)
        elif packet.haslayer(ICMP):
            self.stats['icmp'] += 1
            self.handle_icmp(packet)
        elif packet.haslayer(IP):
            self.stats['other_ip'] += 1
        else:
            self.stats['non_ip'] += 1
        
        # Display packet
        if self.packet_count <= 20 or self.packet_count % 10 == 0:
            timestamp = datetime.fromtimestamp(packet.time).strftime('%H:%M:%S.%f')[:-3]
            print(f"[{timestamp}] #{self.packet_count}: {packet.summary()}")
        
        # Store limited packets for analysis
        if len(self.packets) < 100:
            self.packets.append(packet)
        
        # Stop if count reached
        if self.count > 0 and self.packet_count >= self.count:
            raise KeyboardInterrupt()
    
    def handle_tcp(self, packet):
        """Handle TCP packets."""
        tcp = packet[TCP]
        ip = packet[IP]
        
        # Detect SYN packets (connection attempts)
        if tcp.flags & 0x02:  # SYN
            if tcp.flags & 0x10:  # SYN-ACK
                print(f"  [!] SYN-ACK from {ip.src}:{tcp.sport} -> {ip.dst}:{tcp.dport}")
            else:
                print(f"  [!] SYN from {ip.src}:{tcp.sport} -> {ip.dst}:{tcp.dport}")
        
        # Detect RST packets (connection resets)
        if tcp.flags & 0x04:  # RST
            print(f"  [!] RST from {ip.src}:{tcp.sport} -> {ip.dst}:{tcp.dport}")
        
        # Detect FIN packets
        if tcp.flags & 0x01:  # FIN
            print(f"  [!] FIN from {ip.src}:{tcp.sport} -> {ip.dst}:{tcp.dport}")
    
    def handle_udp(self, packet):
        """Handle UDP packets."""
        udp = packet[UDP]
        ip = packet[IP]
        
        # Check for DNS (port 53)
        if udp.sport == 53 or udp.dport == 53:
            print(f"  [DNS] {ip.src}:{udp.sport} -> {ip.dst}:{udp.dport}")
    
    def handle_icmp(self, packet):
        """Handle ICMP packets."""
        icmp = packet[ICMP]
        ip = packet[IP]
        
        icmp_types = {
            0: "Echo Reply",
            3: "Destination Unreachable",
            4: "Source Quench",
            5: "Redirect",
            8: "Echo Request",
            11: "Time Exceeded",
            12: "Parameter Problem"
        }
        type_name = icmp_types.get(icmp.type, f"Type {icmp.type}")
        print(f"  [ICMP] {type_name} from {ip.src} -> {ip.dst}")
    
    def start(self):
        """Start sniffing."""
        print("\n" + "="*60)
        print("BASIC PACKET SNIFFER")
        print("="*60)
        print(f"Interface: {self.interface}")
        print(f"Filter: {self.filter_str or 'None'}")
        print(f"Count: {self.count if self.count > 0 else 'Unlimited'}")
        print("Press Ctrl+C to stop")
        print("-"*60)
        
        self.start_time = time.time()
        
        try:
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self.packet_callback,
                count=self.count if self.count > 0 else None,
                timeout=self.timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping sniffer...")
        except Exception as e:
            print(f"\nError: {e}")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display sniffing statistics."""
        elapsed = time.time() - self.start_time if self.start_time else 0
        
        print("\n" + "="*60)
        print("SNIFFER STATISTICS")
        print("="*60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Total packets: {self.stats['total']}")
        print(f"Total bytes: {self.stats['bytes']:,}")
        
        if elapsed > 0:
            print(f"Packets/sec: {self.stats['total'] / elapsed:.2f}")
            print(f"Bytes/sec: {self.stats['bytes'] / elapsed:.2f}")
        
        print("\nProtocol Distribution:")
        print("-"*40)
        total = self.stats['total']
        for proto in ['tcp', 'udp', 'icmp', 'other_ip', 'non_ip']:
            count = self.stats[proto]
            if count > 0:
                pct = (count / total) * 100
                bar = "█" * int(pct / 2)
                print(f"  {proto:>10}: {count:>6} ({pct:>5.1f}%) {bar}")
        
        # TCP flag summary from stored packets
        syn_count = 0
        syn_ack_count = 0
        rst_count = 0
        fin_count = 0
        
        for packet in self.packets:
            if packet.haslayer(TCP):
                tcp = packet[TCP]
                if tcp.flags & 0x02:  # SYN
                    if tcp.flags & 0x10:  # SYN-ACK
                        syn_ack_count += 1
                    else:
                        syn_count += 1
                if tcp.flags & 0x04:  # RST
                    rst_count += 1
                if tcp.flags & 0x01:  # FIN
                    fin_count += 1
        
        print("\nTCP Flags (from stored packets):")
        print("-"*40)
        print(f"  SYN: {syn_count}")
        print(f"  SYN-ACK: {syn_ack_count}")
        print(f"  RST: {rst_count}")
        print(f"  FIN: {fin_count}")
        
        print("\n" + "="*60)
        print("SNIFFER COMPLETE")
        print("="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Basic Packet Sniffer')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-f', '--filter', help='BPF filter')
    parser.add_argument('-c', '--count', type=int, default=0,
                        help='Number of packets to capture')
    parser.add_argument('-t', '--timeout', type=int,
                        help='Stop after N seconds')
    args = parser.parse_args()
    
    sniffer = BasicSniffer(
        interface=args.interface,
        filter_str=args.filter,
        count=args.count,
        timeout=args.timeout
    )
    
    sniffer.start()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("="*60)
        print("BASIC PACKET SNIFFER")
        print("="*60)
        
        from scapy.all import get_if_list
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        filter_str = input("BPF filter (e.g., 'tcp', press Enter for none): ").strip()
        filter_str = filter_str if filter_str else None
        
        sniffer = BasicSniffer(interface=interface, filter_str=filter_str, count=20)
        sniffer.start()
    else:
        main()
```

---

### Verification Checklist

- [ ] Sniffer runs with root privileges
- [ ] Packets are captured
- [ ] BPF filters work
- [ ] TCP flags are detected
- [ ] Statistics are displayed

---

### Lab Report

**1. How many packets were captured?**
```
Answer: ______________________________________________________
```

**2. What was the protocol distribution?**
```
Answer: ______________________________________________________
```

**3. What TCP flags were detected?**
```
Answer: ______________________________________________________
```

**4. What was the packet rate (packets/sec)?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add color-coded output for different protocols.

**Challenge 2:** Add packet filtering based on IP or port.

**Challenge 3:** Implement packet logging to PCAP.

---

## Lab 4.2: HTTP Analyzer

---

### Objectives

After completing this lab, you will be able to:
- ✅ Extract HTTP requests and responses
- ✅ Parse HTTP headers
- ✅ Identify HTTP methods
- ✅ Track HTTP status codes

---

### Prerequisites

- ✅ Understanding of HTTP protocol
- ✅ Knowledge of TCP and ports
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/http_analyzer.py`

---

### Step-by-Step Instructions

#### Step 1: Build HTTP Analyzer

Create `src/http_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 4 Lab: HTTP Analyzer
"""

from scapy.all import sniff, IP, TCP, Raw
import re
from collections import defaultdict
import time

class HTTPAnalyzer:
    def __init__(self, interface=None, count=0):
        self.interface = interface
        self.count = count
        self.requests = []
        self.responses = []
        self.stats = {
            'GET': 0,
            'POST': 0,
            'PUT': 0,
            'DELETE': 0,
            'HEAD': 0,
            'OPTIONS': 0,
            '2xx': 0,
            '3xx': 0,
            '4xx': 0,
            '5xx': 0
        }
        self.hosts = defaultdict(int)
        self.user_agents = defaultdict(int)
        self.packet_count = 0
    
    def process_packet(self, packet):
        """Process a packet for HTTP data."""
        if not packet.haslayer(TCP) or not packet.haslayer(Raw):
            return
        
        tcp = packet[TCP]
        if tcp.sport != 80 and tcp.dport != 80:
            return
        
        self.packet_count += 1
        
        payload = bytes(packet[Raw])
        try:
            data = payload.decode('utf-8', errors='ignore')
        except:
            return
        
        # Parse HTTP request
        if data.startswith(('GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS')):
            self.parse_request(data, packet)
        
        # Parse HTTP response
        elif data.startswith('HTTP/'):
            self.parse_response(data, packet)
        
        # Stop if count reached
        if self.count > 0 and len(self.requests) >= self.count:
            raise KeyboardInterrupt()
    
    def parse_request(self, data, packet):
        """Parse an HTTP request."""
        lines = data.split('\r\n')
        if not lines:
            return
        
        # Parse request line
        parts = lines[0].split(' ')
        if len(parts) < 3:
            return
        
        method = parts[0]
        uri = parts[1]
        version = parts[2]
        
        self.stats[method] += 1
        
        # Parse headers
        headers = {}
        host = None
        user_agent = None
        
        for line in lines[1:]:
            if ': ' in line:
                key, value = line.split(': ', 1)
                headers[key] = value
                if key.lower() == 'host':
                    host = value
                    self.hosts[host] += 1
                elif key.lower() == 'user-agent':
                    user_agent = value
                    self.user_agents[user_agent] += 1
        
        # Check for suspicious patterns
        suspicious = []
        sql_patterns = ['SELECT', 'INSERT', 'DELETE', 'DROP', 'UNION']
        xss_patterns = ['<script', 'javascript:', 'onerror=']
        
        for pattern in sql_patterns:
            if pattern.lower() in data.lower():
                suspicious.append('SQL Injection')
                break
        
        for pattern in xss_patterns:
            if pattern.lower() in data.lower():
                suspicious.append('XSS')
                break
        
        request_info = {
            'timestamp': time.strftime('%H:%M:%S', time.localtime(packet.time)),
            'src': packet[IP].src,
            'dst': packet[IP].dst,
            'method': method,
            'uri': uri,
            'version': version,
            'host': host,
            'user_agent': user_agent,
            'headers': headers,
            'suspicious': suspicious
        }
        
        self.requests.append(request_info)
        
        # Display
        print(f"\n[HTTP] {method} {uri}")
        if host:
            print(f"  Host: {host}")
        if user_agent:
            print(f"  User-Agent: {user_agent[:80]}")
        if suspicious:
            print(f"  ⚠️ Suspicious: {', '.join(suspicious)}")
    
    def parse_response(self, data, packet):
        """Parse an HTTP response."""
        lines = data.split('\r\n')
        if not lines:
            return
        
        # Parse status line
        parts = lines[0].split(' ')
        if len(parts) < 3:
            return
        
        version = parts[0]
        status_code = int(parts[1])
        status_text = ' '.join(parts[2:])
        
        # Categorize status code
        if 200 <= status_code < 300:
            self.stats['2xx'] += 1
        elif 300 <= status_code < 400:
            self.stats['3xx'] += 1
        elif 400 <= status_code < 500:
            self.stats['4xx'] += 1
        elif 500 <= status_code < 600:
            self.stats['5xx'] += 1
        
        # Parse headers
        headers = {}
        content_type = None
        content_length = None
        
        for line in lines[1:]:
            if ': ' in line:
                key, value = line.split(': ', 1)
                headers[key] = value
                if key.lower() == 'content-type':
                    content_type = value
                elif key.lower() == 'content-length':
                    content_length = int(value)
        
        response_info = {
            'timestamp': time.strftime('%H:%M:%S', time.localtime(packet.time)),
            'src': packet[IP].src,
            'dst': packet[IP].dst,
            'version': version,
            'status_code': status_code,
            'status_text': status_text,
            'content_type': content_type,
            'content_length': content_length,
            'headers': headers
        }
        
        self.responses.append(response_info)
        
        # Display
        print(f"\n[HTTP] Response: {status_code} {status_text}")
        if content_type:
            print(f"  Content-Type: {content_type}")
        if content_length:
            print(f"  Content-Length: {content_length}")
    
    def start(self):
        """Start HTTP analysis."""
        print("\n" + "="*60)
        print("HTTP ANALYZER")
        print("="*60)
        print(f"Interface: {self.interface or 'Default'}")
        print(f"Count: {self.count if self.count > 0 else 'Unlimited'}")
        print("Press Ctrl+C to stop")
        print("-"*60)
        
        try:
            sniff(
                iface=self.interface,
                filter="tcp port 80",
                prn=self.process_packet,
                count=self.count if self.count > 0 else None,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping analysis...")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display HTTP statistics."""
        print("\n" + "="*60)
        print("HTTP STATISTICS")
        print("="*60)
        print(f"Packets processed: {self.packet_count}")
        print(f"Requests: {len(self.requests)}")
        print(f"Responses: {len(self.responses)}")
        
        print("\nHTTP Methods:")
        print("-"*40)
        for method in ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS']:
            count = self.stats.get(method, 0)
            if count > 0:
                print(f"  {method:<8}: {count:>6}")
        
        print("\nStatus Codes:")
        print("-"*40)
        for category in ['2xx', '3xx', '4xx', '5xx']:
            count = self.stats.get(category, 0)
            if count > 0:
                print(f"  {category:<8}: {count:>6}")
        
        print("\nTop Hosts:")
        print("-"*40)
        for host, count in sorted(self.hosts.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {host:<40}: {count:>6}")
        
        print("\nTop User Agents:")
        print("-"*40)
        for ua, count in sorted(self.user_agents.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {ua[:50]:<50}: {count:>6}")
        
        # Suspicious requests
        suspicious = [r for r in self.requests if r['suspicious']]
        if suspicious:
            print(f"\n⚠️ Suspicious Requests Detected: {len(suspicious)}")
            print("-"*40)
            for req in suspicious[:10]:
                print(f"  {req['src']} -> {req['uri']}")
                print(f"    Patterns: {', '.join(req['suspicious'])}")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='HTTP Analyzer')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-c', '--count', type=int, default=0,
                        help='Number of requests to capture')
    args = parser.parse_args()
    
    analyzer = HTTPAnalyzer(interface=args.interface, count=args.count)
    analyzer.start()

if __name__ == "__main__":
    from scapy.all import conf
    if len(sys.argv) == 1:
        print("="*60)
        print("HTTP ANALYZER")
        print("="*60)
        
        from scapy.all import get_if_list
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        analyzer = HTTPAnalyzer(interface=interface)
        analyzer.start()
    else:
        main()
```

---

### Verification Checklist

- [ ] Analyzer runs with root privileges
- [ ] HTTP requests are parsed correctly
- [ ] HTTP responses are parsed correctly
- [ ] Statistics are accurate
- [ ] Suspicious patterns are detected

---

### Lab Report

**1. How many HTTP requests were captured?**
```
Answer: ______________________________________________________
```

**2. What was the most common HTTP method?**
```
Answer: ______________________________________________________
```

**3. What was the most common status code category?**
```
Answer: ______________________________________________________
```

**4. What hosts were accessed?**
```
Answer: ______________________________________________________
```

**5. Were any suspicious requests detected?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add support for HTTPS traffic analysis (TLS).

**Challenge 2:** Implement HTTP header extraction for specific headers.

**Challenge 3:** Build a web request flow visualizer.

---

## Lab 4.3: DNS Monitor

---

### Objectives

After completing this lab, you will be able to:
- ✅ Monitor DNS queries and responses
- ✅ Track domain name resolutions
- ✅ Cache DNS responses
- ✅ Detect suspicious domain patterns

---

### Prerequisites

- ✅ Understanding of DNS protocol
- ✅ Knowledge of UDP port 53
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/dns_monitor.py`

---

### Step-by-Step Instructions

#### Step 1: Build DNS Monitor

Create `src/dns_monitor.py`:

```python
#!/usr/bin/env python3
"""
Module 4 Lab: DNS Monitor
"""

from scapy.all import sniff, IP, UDP, DNS, DNSQR, DNSRR
import time
import re
from collections import defaultdict

class DNSMonitor:
    SUSPICIOUS_PATTERNS = {
        'long_domain': re.compile(r'^.{50,}\.'),  # 50+ chars before dot
        'random_subdomain': re.compile(r'^[a-z0-9]{8,}\.'),  # 8+ random chars
        'base64_domain': re.compile(r'^[A-Za-z0-9+/]{20,}\=*\.'),  # Base64-like
        'dynamic_dns': re.compile(r'(dyndns|no-ip|ddns)\.', re.IGNORECASE)
    }
    
    def __init__(self, interface=None, count=0, cache_ttl=300):
        self.interface = interface
        self.count = count
        self.cache_ttl = cache_ttl
        self.cache = {}
        self.queries = defaultdict(int)
        self.responses = {}
        self.suspicious = []
        self.packet_count = 0
    
    def process_packet(self, packet):
        """Process DNS packet."""
        if not packet.haslayer(DNS):
            return
        
        self.packet_count += 1
        dns = packet[DNS]
        
        if dns.qr == 0:  # Query
            self.handle_query(packet, dns)
        else:  # Response
            self.handle_response(packet, dns)
        
        # Stop if count reached
        if self.count > 0 and self.packet_count >= self.count:
            raise KeyboardInterrupt()
    
    def handle_query(self, packet, dns):
        """Handle DNS query."""
        if dns.qd:
            qname = dns.qd.qname.decode('utf-8') if dns.qd.qname else 'Unknown'
            qname = qname.rstrip('.')
            qtype = dns.qd.qtype
            
            self.queries[qname] += 1
            
            # Check cache
            cached = self.check_cache(qname)
            if cached:
                print(f"[DNS] Cache hit: {qname} -> {cached}")
            else:
                print(f"[DNS] Query: {qname} (Type: {qtype}) from {packet[IP].src}")
            
            # Check for suspicious patterns
            suspicious_patterns = []
            for name, pattern in self.SUSPICIOUS_PATTERNS.items():
                if pattern.search(qname):
                    suspicious_patterns.append(name)
            
            if suspicious_patterns:
                alert = f"  ⚠️ Suspicious domain: {qname} (Patterns: {', '.join(suspicious_patterns)})"
                print(alert)
                self.suspicious.append({
                    'domain': qname,
                    'patterns': suspicious_patterns,
                    'src': packet[IP].src,
                    'timestamp': time.time()
                })
    
    def handle_response(self, packet, dns):
        """Handle DNS response."""
        if dns.an:
            for answer in dns.an:
                if isinstance(answer, DNSRR):
                    domain = answer.rrname.decode('utf-8').rstrip('.')
                    rdata = str(answer.rdata)
                    self.responses[domain] = rdata
                    self.cache_domain(domain, rdata)
                    print(f"[DNS] Response: {domain} -> {rdata}")
    
    def cache_domain(self, domain, data):
        """Cache domain resolution."""
        self.cache[domain] = {
            'data': data,
            'timestamp': time.time()
        }
    
    def check_cache(self, domain):
        """Check cache for domain."""
        if domain in self.cache:
            entry = self.cache[domain]
            if time.time() - entry['timestamp'] < self.cache_ttl:
                return entry['data']
            else:
                del self.cache[domain]
        return None
    
    def start(self):
        """Start DNS monitoring."""
        print("\n" + "="*60)
        print("DNS MONITOR")
        print("="*60)
        print(f"Interface: {self.interface or 'Default'}")
        print(f"Count: {self.count if self.count > 0 else 'Unlimited'}")
        print(f"Cache TTL: {self.cache_ttl}s")
        print("Press Ctrl+C to stop")
        print("-"*60)
        
        try:
            sniff(
                iface=self.interface,
                filter="udp port 53",
                prn=self.process_packet,
                count=self.count if self.count > 0 else None,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping monitor...")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display DNS statistics."""
        print("\n" + "="*60)
        print("DNS STATISTICS")
        print("="*60)
        print(f"Packets processed: {self.packet_count}")
        print(f"Queries: {len(self.queries)}")
        print(f"Responses: {len(self.responses)}")
        print(f"Cache entries: {len(self.cache)}")
        
        print("\nTop 10 Domain Queries:")
        print("-"*40)
        for domain, count in sorted(self.queries.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {domain:<50}: {count:>6}")
        
        if self.suspicious:
            print(f"\n⚠️ Suspicious Domains Detected: {len(self.suspicious)}")
            print("-"*40)
            for item in self.suspicious[:10]:
                timestamp = time.strftime('%H:%M:%S', time.localtime(item['timestamp']))
                print(f"  {timestamp} {item['domain']} (from {item['src']})")
                print(f"    Patterns: {', '.join(item['patterns'])}")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='DNS Monitor')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-c', '--count', type=int, default=0,
                        help='Number of packets to capture')
    parser.add_argument('--cache-ttl', type=int, default=300,
                        help='Cache TTL in seconds')
    args = parser.parse_args()
    
    monitor = DNSMonitor(
        interface=args.interface,
        count=args.count,
        cache_ttl=args.cache_ttl
    )
    monitor.start()

if __name__ == "__main__":
    from scapy.all import conf
    if len(sys.argv) == 1:
        print("="*60)
        print("DNS MONITOR")
        print("="*60)
        
        from scapy.all import get_if_list
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        monitor = DNSMonitor(interface=interface)
        monitor.start()
    else:
        main()
```

---

### Verification Checklist

- [ ] Monitor runs with root privileges
- [ ] DNS queries are detected
- [ ] DNS responses are detected
- [ ] Cache works correctly
- [ ] Suspicious domains are identified

---

### Lab Report

**1. How many DNS queries were captured?**
```
Answer: ______________________________________________________
```

**2. What was the most commonly queried domain?**
```
Answer: ______________________________________________________
```

**3. How many cache hits were there?**
```
Answer: ______________________________________________________
```

**4. Were any suspicious domains detected?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add DNS query rate monitoring (detect DNS flooding).

**Challenge 2:** Implement reverse DNS tracking.

**Challenge 3:** Build a domain blocklist.

---

## Lab 5.1: ARP Spoofing Detector

---

### Objectives

After completing this lab, you will be able to:
- ✅ Monitor ARP traffic
- ✅ Detect MAC address changes
- ✅ Identify duplicate IP addresses
- ✅ Detect ARP spoofing attempts

---

### Prerequisites

- ✅ Understanding of ARP
- ✅ Knowledge of ARP spoofing
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/arp_detector.py`

---

### Step-by-Step Instructions

#### Step 1: Build ARP Detector

Create `src/arp_detector.py`:

```python
#!/usr/bin/env python3
"""
Module 5 Lab: ARP Spoofing Detector
"""

from scapy.all import sniff, ARP, Ether
from datetime import datetime
from collections import defaultdict

class ARPSpoofingDetector:
    def __init__(self, interface=None, threshold=10):
        self.interface = interface
        self.threshold = threshold  # Requests per second
        self.ip_mac_mapping = {}
        self.alerts = []
        self.packet_count = 0
        self.arp_requests = []
        self.arp_replies = []
        self.start_time = None
    
    def process_arp(self, packet):
        """Process ARP packet."""
        if not packet.haslayer(ARP):
            return
        
        self.packet_count += 1
        arp = packet[ARP]
        src_ip = arp.psrc
        src_mac = arp.hwsrc
        
        # Skip 0.0.0.0 (used in DHCP)
        if src_ip == '0.0.0.0':
            return
        
        # Track ARP types
        if arp.op == 1:  # Request
            self.arp_requests.append({
                'timestamp': time.time(),
                'src': src_ip,
                'mac': src_mac,
                'target': arp.pdst
            })
        else:  # Reply
            self.arp_replies.append({
                'timestamp': time.time(),
                'src': src_ip,
                'mac': src_mac,
                'target': arp.pdst
            })
        
        # Check for MAC change
        if src_ip in self.ip_mac_mapping:
            if self.ip_mac_mapping[src_ip] != src_mac:
                self.alert({
                    'type': 'MAC_Change',
                    'ip': src_ip,
                    'old_mac': self.ip_mac_mapping[src_ip],
                    'new_mac': src_mac,
                    'timestamp': datetime.now(),
                    'packet': packet
                })
        
        # Update mapping
        self.ip_mac_mapping[src_ip] = src_mac
        
        # Check for duplicate IPs
        for ip, mac in self.ip_mac_mapping.items():
            if ip != src_ip and mac == src_mac:
                self.alert({
                    'type': 'Duplicate_IP',
                    'ip1': ip,
                    'ip2': src_ip,
                    'mac': src_mac,
                    'timestamp': datetime.now(),
                    'packet': packet
                })
        
        # Check for gratuitous ARP
        if arp.op == 1 and arp.psrc == arp.pdst:
            self.alert({
                'type': 'Gratuitous_ARP',
                'ip': src_ip,
                'mac': src_mac,
                'timestamp': datetime.now(),
                'packet': packet
            })
        
        # Check ARP rate
        self.check_arp_rate()
    
    def check_arp_rate(self):
        """Check for abnormal ARP rates."""
        now = time.time()
        
        # Count replies in last second
        recent_replies = [r for r in self.arp_replies if now - r['timestamp'] < 1]
        if len(recent_replies) > self.threshold:
            # Find source of high replies
            sources = defaultdict(int)
            for r in recent_replies:
                sources[r['mac']] += 1
            
            for mac, count in sources.items():
                if count > self.threshold:
                    self.alert({
                        'type': 'High_ARP_Rate',
                        'mac': mac,
                        'count': count,
                        'timestamp': datetime.now()
                    })
    
    def alert(self, alert_data):
        """Handle alert."""
        self.alerts.append(alert_data)
        
        alert_type = alert_data['type']
        
        if alert_type == 'MAC_Change':
            print(f"\n⚠️ ALERT: MAC change for {alert_data['ip']}")
            print(f"   Old MAC: {alert_data['old_mac']}")
            print(f"   New MAC: {alert_data['new_mac']}")
        
        elif alert_type == 'Duplicate_IP':
            print(f"\n⚠️ ALERT: Duplicate IP detected")
            print(f"   IP: {alert_data['ip1']} and {alert_data['ip2']}")
            print(f"   MAC: {alert_data['mac']}")
        
        elif alert_type == 'Gratuitous_ARP':
            print(f"\n⚠️ ALERT: Gratuitous ARP from {alert_data['ip']}")
            print(f"   MAC: {alert_data['mac']}")
        
        elif alert_type == 'High_ARP_Rate':
            print(f"\n⚠️ ALERT: High ARP rate from {alert_data['mac']}")
            print(f"   {alert_data['count']} replies/second")
    
    def start(self, timeout=None):
        """Start monitoring."""
        print("\n" + "="*60)
        print("ARP SPOOFING DETECTOR")
        print("="*60)
        print(f"Interface: {self.interface or 'Default'}")
        print(f"Threshold: {self.threshold} replies/second")
        print("Press Ctrl+C to stop")
        print("-"*60)
        
        self.start_time = time.time()
        
        try:
            sniff(
                iface=self.interface,
                filter="arp",
                prn=self.process_arp,
                timeout=timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping detector...")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display detection statistics."""
        elapsed = time.time() - self.start_time if self.start_time else 0
        
        print("\n" + "="*60)
        print("ARP DETECTION SUMMARY")
        print("="*60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"ARP packets: {self.packet_count}")
        print(f"IP-MAC mappings: {len(self.ip_mac_mapping)}")
        print(f"Alerts: {len(self.alerts)}")
        
        if self.alerts:
            print("\nAlerts Summary:")
            print("-"*40)
            alert_types = defaultdict(int)
            for alert in self.alerts:
                alert_types[alert['type']] += 1
            
            for alert_type, count in alert_types.items():
                print(f"  {alert_type}: {count}")
        
        print("\nCurrent ARP Cache:")
        print("-"*40)
        for ip, mac in sorted(self.ip_mac_mapping.items())[:20]:
            print(f"  {ip:<15} -> {mac}")
        if len(self.ip_mac_mapping) > 20:
            print(f"  ... and {len(self.ip_mac_mapping) - 20} more")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='ARP Spoofing Detector')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-t', '--threshold', type=int, default=10,
                        help='ARP rate threshold (replies/second)')
    parser.add_argument('--timeout', type=int, help='Run for N seconds')
    args = parser.parse_args()
    
    detector = ARPSpoofingDetector(
        interface=args.interface,
        threshold=args.threshold
    )
    detector.start(timeout=args.timeout)

if __name__ == "__main__":
    from scapy.all import conf
    if len(sys.argv) == 1:
        print("="*60)
        print("ARP SPOOFING DETECTOR")
        print("="*60)
        
        from scapy.all import get_if_list
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        detector = ARPSpoofingDetector(interface=interface)
        detector.start()
    else:
        main()
```

---

### Verification Checklist

- [ ] Detector runs with root privileges
- [ ] ARP packets are captured
- [ ] MAC changes are detected
- [ ] Duplicate IPs are detected
- [ ] High ARP rates are detected

---

### Lab Report

**1. How many ARP packets were processed?**
```
Answer: ______________________________________________________
```

**2. How many IP-MAC mappings were found?**
```
Answer: ______________________________________________________
```

**3. What alerts were triggered?**
```
Answer: ______________________________________________________
```

**4. What was the ARP rate?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add IP-MAC binding validation with a whitelist.

**Challenge 2:** Implement active ARP probing to verify mappings.

**Challenge 3:** Build a graphical ARP monitoring dashboard.

---

## Lab 5.2: Packet Replay Utility

---

### Objectives

After completing this lab, you will be able to:
- ✅ Load packets from PCAP files
- ✅ Replay packets on the network
- ✅ Control replay rate
- ✅ Loop packet replay

---

### Prerequisites

- ✅ Knowledge of PCAP files
- ✅ Understanding of packet injection
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/packet_replay.py`

---

### Step-by-Step Instructions

#### Step 1: Build Packet Replay

Create `src/packet_replay.py`:

```python
#!/usr/bin/env python3
"""
Module 5 Lab: Packet Replay Utility
"""

from scapy.all import rdpcap, send, conf
import time
import sys
import os

class PacketReplay:
    def __init__(self, interface=None, rate=100, loop=False, safe=True):
        self.interface = interface or conf.iface
        self.rate = rate
        self.loop = loop
        self.safe = safe
        self.packets = []
        self.sent = 0
        self.start_time = None
        self.running = True
    
    def load_pcap(self, pcap_file):
        """Load packets from PCAP file."""
        if not os.path.exists(pcap_file):
            print(f"❌ File not found: {pcap_file}")
            return False
        
        try:
            self.packets = rdpcap(pcap_file)
            print(f"✅ Loaded {len(self.packets)} packets from {pcap_file}")
            
            # Show packet summary
            print("\nFirst 5 packets:")
            for i, pkt in enumerate(self.packets[:5], 1):
                print(f"  #{i}: {pkt.summary()}")
            if len(self.packets) > 5:
                print(f"  ... and {len(self.packets) - 5} more")
            
            return True
        except Exception as e:
            print(f"❌ Error loading PCAP: {e}")
            return False
    
    def is_safe_packet(self, packet):
        """Check if packet is safe to replay."""
        if not self.safe:
            return True
        
        # Check for packet size
        if len(packet) > 1500:
            print(f"⚠️ Skipping oversized packet ({len(packet)} bytes)")
            return False
        
        # Check destination IP (if present)
        if packet.haslayer(IP):
            dst = packet[IP].dst
            # Skip packets to external networks (safety)
            if not dst.startswith(('192.168.', '10.', '172.16.', '172.17.', '172.18.', '172.19.', '172.20.', '172.21.', '172.22.', '172.23.', '172.24.', '172.25.', '172.26.', '172.27.', '172.28.', '172.29.', '172.30.', '172.31.', '127.')):
                print(f"⚠️ Skipping packet to external IP: {dst}")
                return False
        
        return True
    
    def replay(self):
        """Replay packets."""
        if not self.packets:
            print("❌ No packets loaded.")
            return
        
        print("\n" + "="*60)
        print("PACKET REPLAY")
        print("="*60)
        print(f"Interface: {self.interface}")
        print(f"Rate: {self.rate} packets/second")
        print(f"Loop: {self.loop}")
        print(f"Safe mode: {self.safe}")
        print("Press Ctrl+C to stop")
        print("-"*60)
        
        interval = 1.0 / self.rate if self.rate > 0 else 0
        self.start_time = time.time()
        
        try:
            while self.running:
                for packet in self.packets:
                    if not self.running:
                        break
                    
                    # Check safety
                    if not self.is_safe_packet(packet):
                        continue
                    
                    # Send packet
                    send(packet, iface=self.interface, verbose=False)
                    self.sent += 1
                    
                    # Progress indicator
                    if self.sent % 100 == 0:
                        elapsed = time.time() - self.start_time
                        print(f"  Sent {self.sent} packets ({self.sent/elapsed:.1f}/s)")
                    
                    # Rate limiting
                    if interval > 0:
                        time.sleep(interval)
                
                if not self.loop:
                    break
                
                print(f"\nLoop completed, restarting...")
        
        except KeyboardInterrupt:
            print("\n\nReplay interrupted by user")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display replay statistics."""
        elapsed = time.time() - self.start_time if self.start_time else 0
        
        print("\n" + "="*60)
        print("REPLAY STATISTICS")
        print("="*60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Packets sent: {self.sent}")
        print(f"Packets loaded: {len(self.packets)}")
        
        if elapsed > 0:
            print(f"Rate: {self.sent / elapsed:.1f} packets/second")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Packet Replay Utility')
    parser.add_argument('pcap_file', help='PCAP file to replay')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-r', '--rate', type=int, default=100,
                        help='Packets per second')
    parser.add_argument('-l', '--loop', action='store_true',
                        help='Loop replay')
    parser.add_argument('--no-safe', action='store_true',
                        help='Disable safety checks')
    args = parser.parse_args()
    
    replay = PacketReplay(
        interface=args.interface,
        rate=args.rate,
        loop=args.loop,
        safe=not args.no_safe
    )
    
    if replay.load_pcap(args.pcap_file):
        replay.replay()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("="*60)
        print("PACKET REPLAY UTILITY")
        print("="*60)
        
        pcap_file = input("Enter PCAP file path: ").strip()
        if not pcap_file:
            print("No PCAP file specified.")
            sys.exit(1)
        
        rate = input("Packets per second (default: 100): ").strip()
        rate = int(rate) if rate else 100
        
        loop = input("Loop replay? (y/n): ").strip().lower() == 'y'
        
        replay = PacketReplay(rate=rate, loop=loop)
        if replay.load_pcap(pcap_file):
            replay.replay()
    else:
        main()
```

---

### Verification Checklist

- [ ] Replay runs with root privileges
- [ ] PCAP file loads correctly
- [ ] Packets are replayed
- [ ] Rate control works
- [ ] Loop works correctly

---

### Lab Report

**1. How many packets were loaded?**
```
Answer: ______________________________________________________
```

**2. What was the replay rate?**
```
Answer: ______________________________________________________
```

**3. Were any packets skipped due to safety checks?**
```
Answer: ______________________________________________________
```

**4. How long did the replay take?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add option to modify packets during replay (e.g., change IP addresses).

**Challenge 2:** Implement timed replay based on original packet timestamps.

**Challenge 3:** Add support for multiple PCAP files.

---

## Lab 6.1: Custom Protocol Development

---

### Objectives

After completing this lab, you will be able to:
- ✅ Define custom protocol fields
- ✅ Create a Packet subclass
- ✅ Bind protocols together
- ✅ Dissect custom protocols

---

### Prerequisites

- ✅ Understanding of Scapy packet architecture
- ✅ Knowledge of field types
- ✅ Python class inheritance knowledge

---

### Materials

**Time Required:** 45-60 minutes

**Files to Create:**
- `src/custom_protocol.py`

---

### Step-by-Step Instructions

#### Step 1: Build Custom Protocol

Create `src/custom_protocol.py`:

```python
#!/usr/bin/env python3
"""
Module 6 Lab: Custom Protocol Development
"""

from scapy.packet import Packet
from scapy.fields import *
from scapy.all import bind_layers, IP, wrpcap, rdpcap
import time

class MyProtocol(Packet):
    """
    Custom Protocol
    
    Structure:
    - Version (1 byte): Protocol version
    - Type (1 byte): Message type
    - Flags (1 byte): Control flags
    - Reserved (1 byte): Reserved for future use
    - Length (2 bytes): Payload length
    - Sequence (4 bytes): Sequence number
    - Timestamp (4 bytes): Unix timestamp
    """
    name = "MyProtocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        ByteField("flags", 0),
        ByteField("reserved", 0),
        ShortField("length", 0),
        IntField("sequence", 0),
        IntField("timestamp", 0)
    ]
    
    def mysummary(self):
        """Custom summary."""
        return (f"MyProtocol v{self.version} type={self.type} "
                f"seq={self.sequence} len={self.length}")

class MyData(Packet):
    """
    Custom Data Payload
    
    Structure:
    - Data Type (1 byte): Type of data
    - Data Length (2 bytes): Length of data
    - Data (variable): Actual data
    """
    name = "MyData"
    fields_desc = [
        ByteField("data_type", 0),
        ShortField("data_length", 0),
        StrLenField("data", "", length_from=lambda p: p.data_length)
    ]
    
    def mysummary(self):
        return f"MyData type={self.data_type} len={self.data_length}"

class MyResponse(Packet):
    """
    Custom Response
    
    Structure:
    - Status (1 byte): Response status (0=Success)
    - Error Code (1 byte): Error code
    - Response Length (2 bytes): Response data length
    - Response Data (variable): Response data
    """
    name = "MyResponse"
    fields_desc = [
        ByteField("status", 0),
        ByteField("error_code", 0),
        ShortField("response_length", 0),
        StrLenField("response_data", "", length_from=lambda p: p.response_length)
    ]
    
    def mysummary(self):
        status = "Success" if self.status == 0 else f"Error {self.error_code}"
        return f"MyResponse status={status}"

# Bind protocols
bind_layers(IP, MyProtocol, proto=252)
bind_layers(MyProtocol, MyData, type=0)
bind_layers(MyProtocol, MyResponse, type=1)

def build_packet(msg_type=0, sequence=0, data_type=0, data=b"Hello", version=1):
    """Build a custom protocol packet."""
    proto = MyProtocol(
        version=version,
        type=msg_type,
        length=len(data) + 3,  # Data header size
        sequence=sequence,
        timestamp=int(time.time())
    )
    
    data_pkt = MyData(
        data_type=data_type,
        data_length=len(data),
        data=data
    )
    
    return proto / data_pkt

def build_response(status=0, error_code=0, response_data=b"OK"):
    """Build a response packet."""
    proto = MyProtocol(
        version=1,
        type=1,  # Response
        sequence=0,
        timestamp=int(time.time())
    )
    
    resp = MyResponse(
        status=status,
        error_code=error_code,
        response_length=len(response_data),
        response_data=response_data
    )
    
    return proto / resp

def demonstrate():
    """Demonstrate custom protocol."""
    print("\n" + "="*60)
    print("CUSTOM PROTOCOL DEMONSTRATION")
    print("="*60)
    
    # 1. Build packets
    print("\n1. Building Custom Packets:")
    print("-"*40)
    
    # Data packet
    pkt1 = build_packet(
        msg_type=0,
        sequence=1001,
        data_type=1,
        data=b"Custom protocol data!"
    )
    print(f"  Data Packet: {pkt1.mysummary()}")
    pkt1.show()
    
    # Response packet
    pkt2 = build_response(
        status=0,
        response_data=b"Request processed successfully"
    )
    print(f"\n  Response Packet: {pkt2.mysummary()}")
    pkt2.show()
    
    # 2. Stack with IP
    print("\n2. Stacking with IP:")
    print("-"*40)
    ip_pkt = IP(src="192.168.1.100", dst="192.168.1.1", proto=252) / pkt1
    print(f"  IP Packet: {ip_pkt.summary()}")
    ip_pkt.show()
    
    # 3. Dissection
    print("\n3. Dissection:")
    print("-"*40)
    raw = bytes(ip_pkt)
    dissected = IP(raw)
    print(f"  Dissected: {dissected.summary()}")
    if dissected.haslayer(MyProtocol):
        print(f"  MyProtocol: {dissected[MyProtocol].mysummary()}")
    if dissected.haslayer(MyData):
        print(f"  MyData: {dissected[MyData].mysummary()}")
    
    # 4. Save to PCAP
    print("\n4. Saving to PCAP:")
    print("-"*40)
    packets = [ip_pkt]
    wrpcap("output/custom_protocol.pcap", packets)
    print("  Saved to output/custom_protocol.pcap")
    
    # 5. Load from PCAP
    print("\n5. Loading from PCAP:")
    print("-"*40)
    loaded = rdpcap("output/custom_protocol.pcap")
    for pkt in loaded:
        print(f"  Loaded: {pkt.summary()}")
        if pkt.haslayer(MyProtocol):
            print(f"    MyProtocol: {pkt[MyProtocol].mysummary()}")
        if pkt.haslayer(MyData):
            print(f"    MyData: {pkt[MyData].mysummary()}")
    
    print("\n" + "="*60)
    print("✅ CUSTOM PROTOCOL DEMONSTRATION COMPLETE")
    print("="*60)

if __name__ == "__main__":
    import os
    os.makedirs("output", exist_ok=True)
    demonstrate()
```

---

### Verification Checklist

- [ ] Protocol class defined correctly
- [ ] Fields are correct types
- [ ] Binding works
- [ ] Packets build correctly
- [ ] Dissection works
- [ ] PCAP save/load works

---

### Lab Report

**1. What fields are in MyProtocol?**
```
Answer: ______________________________________________________
```

**2. What protocol number is used for binding?**
```
Answer: ______________________________________________________
```

**3. How does MyData determine its length?**
```
Answer: ______________________________________________________
```

**4. What was the timestamp in the packet?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add a new field type (e.g., MAC address) to the protocol.

**Challenge 2:** Implement protocol version negotiation.

**Challenge 3:** Add error detection (CRC or checksum) to the protocol.

---

## Lab 6.2: High-Performance Capture

---

### Objectives

After completing this lab, you will be able to:
- ✅ Implement producer-consumer pattern
- ✅ Use multi-threading for packet processing
- ✅ Process packets in parallel
- ✅ Monitor performance

---

### Prerequisites

- ✅ Understanding of threading
- ✅ Knowledge of queues
- ✅ Root/sudo privileges

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/high_performance.py`

---

### Step-by-Step Instructions

#### Step 1: Build High-Performance Capture

Create `src/high_performance.py`:

```python
#!/usr/bin/env python3
"""
Module 6 Lab: High-Performance Capture
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP
import threading
import queue
import time
from collections import defaultdict
import psutil
import sys

class HighPerformanceCapture:
    def __init__(self, interface=None, buffer_size=10000, workers=4,
                 filter_str=None):
        self.interface = interface
        self.buffer_size = buffer_size
        self.workers = workers
        self.filter_str = filter_str
        self.packet_queue = queue.Queue(maxsize=buffer_size)
        self.running = False
        self.stats = {
            'captured': 0,
            'processed': 0,
            'dropped': 0,
            'start_time': None,
            'end_time': None,
            'memory_usage': 0,
            'cpu_usage': 0
        }
        self.protocol_counts = defaultdict(int)
        self.lock = threading.Lock()
        self.monitor_thread = None
    
    def packet_callback(self, packet):
        """Callback for captured packets."""
        try:
            self.packet_queue.put_nowait(packet)
            with self.lock:
                self.stats['captured'] += 1
        except queue.Full:
            with self.lock:
                self.stats['dropped'] += 1
    
    def worker(self):
        """Worker thread."""
        while self.running:
            try:
                packet = self.packet_queue.get(timeout=0.5)
                self.process_packet(packet)
                self.packet_queue.task_done()
                with self.lock:
                    self.stats['processed'] += 1
            except queue.Empty:
                continue
            except Exception as e:
                print(f"Worker error: {e}")
                self.packet_queue.task_done()
    
    def process_packet(self, packet):
        """Process a single packet."""
        if packet.haslayer(TCP):
            self.protocol_counts['TCP'] += 1
        elif packet.haslayer(UDP):
            self.protocol_counts['UDP'] += 1
        elif packet.haslayer(ICMP):
            self.protocol_counts['ICMP'] += 1
        elif packet.haslayer(IP):
            self.protocol_counts['Other IP'] += 1
        else:
            self.protocol_counts['Other'] += 1
    
    def monitor_performance(self):
        """Monitor system performance."""
        while self.running:
            time.sleep(2)
            
            # Get system metrics
            memory = psutil.virtual_memory()
            cpu = psutil.cpu_percent()
            
            with self.lock:
                self.stats['memory_usage'] = memory.used / (1024 * 1024)  # MB
                self.stats['cpu_usage'] = cpu
                
                if self.stats['start_time']:
                    elapsed = time.time() - self.stats['start_time']
                    captured_rate = self.stats['captured'] / max(1, elapsed)
                    processed_rate = self.stats['processed'] / max(1, elapsed)
                    
                    print(f"\n[Performance Monitor]")
                    print(f"  Captured: {self.stats['captured']} ({captured_rate:.1f}/s)")
                    print(f"  Processed: {self.stats['processed']} ({processed_rate:.1f}/s)")
                    print(f"  Queue: {self.packet_queue.qsize()}/{self.buffer_size}")
                    print(f"  Memory: {self.stats['memory_usage']:.1f} MB")
                    print(f"  CPU: {self.stats['cpu_usage']:.1f}%")
    
    def start(self, count=None, timeout=None):
        """Start capture."""
        print("\n" + "="*60)
        print("HIGH-PERFORMANCE CAPTURE")
        print("="*60)
        print(f"Interface: {self.interface or 'Default'}")
        print(f"Workers: {self.workers}")
        print(f"Buffer size: {self.buffer_size}")
        print(f"Filter: {self.filter_str or 'None'}")
        print("Press Ctrl+C to stop")
        print("-"*60)
        
        self.running = True
        self.stats['start_time'] = time.time()
        
        # Start workers
        threads = []
        for i in range(self.workers):
            t = threading.Thread(target=self.worker, name=f"Worker-{i+1}")
            t.daemon = True
            t.start()
            threads.append(t)
            print(f"Started Worker-{i+1}")
        
        # Start monitor
        self.monitor_thread = threading.Thread(target=self.monitor_performance)
        self.monitor_thread.daemon = True
        self.monitor_thread.start()
        
        try:
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self.packet_callback,
                count=count if count and count > 0 else None,
                timeout=timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping capture...")
        except Exception as e:
            print(f"Error during capture: {e}")
        finally:
            self.stop()
    
    def stop(self):
        """Stop capture."""
        self.running = False
        self.stats['end_time'] = time.time()
        
        # Wait for queue to empty
        self.packet_queue.join()
        
        # Calculate final stats
        self.display_stats()
    
    def display_stats(self):
        """Display final statistics."""
        elapsed = self.stats['end_time'] - self.stats['start_time'] if self.stats['start_time'] else 0
        
        print("\n" + "="*60)
        print("CAPTURE STATISTICS")
        print("="*60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Packets captured: {self.stats['captured']}")
        print(f"Packets processed: {self.stats['processed']}")
        print(f"Packets dropped: {self.stats['dropped']}")
        
        if elapsed > 0:
            print(f"Capture rate: {self.stats['captured'] / elapsed:.1f} pkts/s")
            print(f"Processing rate: {self.stats['processed'] / elapsed:.1f} pkts/s")
        
        if self.stats['memory_usage']:
            print(f"Memory usage: {self.stats['memory_usage']:.1f} MB")
        if self.stats['cpu_usage']:
            print(f"CPU usage: {self.stats['cpu_usage']:.1f}%")
        
        print("\nProtocol Distribution:")
        print("-"*40)
        total = sum(self.protocol_counts.values())
        for proto, count in sorted(self.protocol_counts.items(), key=lambda x: x[1], reverse=True):
            pct = (count / max(1, total)) * 100
            bar = "█" * int(pct / 2)
            print(f"  {proto:<10}: {count:>6} ({pct:>5.1f}%) {bar}")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='High-Performance Capture')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-w', '--workers', type=int, default=4,
                        help='Number of worker threads')
    parser.add_argument('-b', '--buffer', type=int, default=10000,
                        help='Buffer size')
    parser.add_argument('-f', '--filter', help='BPF filter')
    parser.add_argument('-c', '--count', type=int, help='Number of packets')
    args = parser.parse_args()
    
    capture = HighPerformanceCapture(
        interface=args.interface,
        buffer_size=args.buffer,
        workers=args.workers,
        filter_str=args.filter
    )
    capture.start(count=args.count)

if __name__ == "__main__":
    from scapy.all import conf
    if len(sys.argv) == 1:
        print("="*60)
        print("HIGH-PERFORMANCE CAPTURE")
        print("="*60)
        
        from scapy.all import get_if_list
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        workers = input("Number of workers (default: 4): ").strip()
        workers = int(workers) if workers else 4
        
        capture = HighPerformanceCapture(interface=interface, workers=workers)
        capture.start(count=100)
    else:
        main()
```

---

### Verification Checklist

- [ ] Capture runs with root privileges
- [ ] Workers start correctly
- [ ] Packets are processed in parallel
- [ ] Performance monitoring works
- [ ] Statistics are accurate

---

### Lab Report

**1. How many packets were captured?**
```
Answer: ______________________________________________________
```

**2. What was the capture rate (packets/sec)?**
```
Answer: ______________________________________________________
```

**3. What was the processing rate (packets/sec)?**
```
Answer: ______________________________________________________
```

**4. How many packets were dropped?**
```
Answer: ______________________________________________________
```

**5. What was the protocol distribution?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add asyncio support for asynchronous processing.

**Challenge 2:** Implement a batching mechanism for improved throughput.

**Challenge 3:** Add support for multiple input sources (interfaces, PCAPs).

---

## Lab 6.3: Protocol Fuzzing

---

### Objectives

After completing this lab, you will be able to:
- ✅ Generate malformed packets
- ✅ Fuzz protocol fields
- ✅ Test protocol robustness
- ✅ Identify edge cases

---

### Prerequisites

- ✅ Custom protocol development (Lab 6.1)
- ✅ Understanding of fuzzing concepts
- ✅ Python random module knowledge

---

### Materials

**Time Required:** 30-45 minutes

**Files to Create:**
- `src/protocol_fuzzer.py`

---

### Step-by-Step Instructions

#### Step 1: Build Protocol Fuzzer

Create `src/protocol_fuzzer.py`:

```python
#!/usr/bin/env python3
"""
Module 6 Lab: Protocol Fuzzer
"""

from scapy.all import IP
import random
import time
import os
import sys

# Import custom protocol from Lab 6.1
from custom_protocol import MyProtocol, MyData, build_packet

class ProtocolFuzzer:
    def __init__(self, protocol_class, iterations=100, seed=None):
        self.protocol_class = protocol_class
        self.iterations = iterations
        self.results = {
            'valid': 0,
            'invalid': 0,
            'errors': 0,
            'timeouts': 0
        }
        self.fuzzed_packets = []
        
        if seed is not None:
            random.seed(seed)
    
    def mutate_field(self, field_name, field_value, field_type):
        """
        Mutate a field value.
        
        Args:
            field_name: Name of the field
            field_value: Current value
            field_type: Field type object
        
        Returns:
            Mutated value
        """
        # Randomly choose mutation type
        mutation = random.choice([
            'bit_flip',
            'random_value',
            'boundary_value',
            'increment',
            'decrement'
        ])
        
        # Apply mutation based on field type
        if isinstance(field_type, ByteField):
            if mutation == 'bit_flip':
                return field_value ^ (1 << random.randint(0, 7))
            elif mutation == 'random_value':
                return random.randint(0, 255)
            elif mutation == 'boundary_value':
                return random.choice([0, 1, 254, 255])
            elif mutation == 'increment':
                return (field_value + 1) % 256
            elif mutation == 'decrement':
                return (field_value - 1) % 256
        
        elif isinstance(field_type, ShortField):
            if mutation == 'bit_flip':
                return field_value ^ (1 << random.randint(0, 15))
            elif mutation == 'random_value':
                return random.randint(0, 65535)
            elif mutation == 'boundary_value':
                return random.choice([0, 1, 65534, 65535])
            elif mutation == 'increment':
                return (field_value + 1) % 65536
            elif mutation == 'decrement':
                return (field_value - 1) % 65536
        
        elif isinstance(field_type, IntField):
            if mutation == 'bit_flip':
                return field_value ^ (1 << random.randint(0, 31))
            elif mutation == 'random_value':
                return random.randint(0, 0xFFFFFFFF)
            elif mutation == 'boundary_value':
                return random.choice([0, 1, 0xFFFFFFFE, 0xFFFFFFFF])
            elif mutation == 'increment':
                return (field_value + 1) % (0xFFFFFFFF + 1)
            elif mutation == 'decrement':
                return (field_value - 1) % (0xFFFFFFFF + 1)
        
        elif isinstance(field_type, StrLenField):
            if mutation in ['increment', 'decrement']:
                # Change length of string
                new_len = max(0, len(field_value) + random.randint(-5, 5))
                return bytes(random.getrandbits(8) for _ in range(new_len))
            elif mutation == 'random_value':
                return bytes(random.getrandbits(8) for _ in range(random.randint(0, 20)))
        
        return field_value
    
    def fuzz_packet(self, base_packet):
        """
        Fuzz a single packet by mutating random fields.
        
        Args:
            base_packet: Base packet to fuzz
        
        Returns:
            Fuzzed packet
        """
        pkt = base_packet.copy()
        
        # Get list of fields
        fields = pkt.fields_desc
        
        # Mutate 1-3 random fields
        num_mutations = random.randint(1, 3)
        for _ in range(num_mutations):
            field = random.choice(fields)
            current_value = getattr(pkt, field.name)
            new_value = self.mutate_field(field.name, current_value, field)
            setattr(pkt, field.name, new_value)
        
        return pkt
    
    def fuzz_payload(self, payload):
        """
        Fuzz payload data.
        
        Args:
            payload: Original payload bytes
        
        Returns:
            Fuzzed payload bytes
        """
        # Randomly choose mutation
        mutation = random.choice([
            'truncate',
            'extend',
            'corrupt',
            'replace'
        ])
        
        payload = bytearray(payload)
        
        if mutation == 'truncate':
            if len(payload) > 0:
                return bytes(payload[:random.randint(0, len(payload))])
        
        elif mutation == 'extend':
            extension = bytes(random.getrandbits(8) for _ in range(random.randint(1, 20)))
            return bytes(payload + extension)
        
        elif mutation == 'corrupt':
            if len(payload) > 0:
                pos = random.randint(0, len(payload) - 1)
                payload[pos] = random.randint(0, 255)
                return bytes(payload)
        
        elif mutation == 'replace':
            return bytes(random.getrandbits(8) for _ in range(len(payload)))
        
        return bytes(payload)
    
    def fuzz_packet_complete(self, base_packet):
        """
        Apply multiple fuzzing techniques to a packet.
        
        Args:
            base_packet: Base packet
        
        Returns:
            Fuzzed packet (bytes)
        """
        # Copy packet
        pkt = base_packet.copy()
        
        # Fuzz fields
        pkt = self.fuzz_packet(pkt)
        
        # Fuzz payload if present
        if pkt.haslayer(MyData):
            original_data = pkt[MyData].data
            fuzzed_data = self.fuzz_payload(original_data)
            pkt[MyData].data = fuzzed_data
            pkt[MyData].data_length = len(fuzzed_data)
            pkt[MyProtocol].length = len(fuzzed_data) + 3
        
        return bytes(pkt)
    
    def run(self):
        """Run the fuzzing campaign."""
        print("\n" + "="*60)
        print("PROTOCOL FUZZING CAMPAIGN")
        print("="*60)
        print(f"Protocol: {self.protocol_class.__name__}")
        print(f"Iterations: {self.iterations}")
        print("-"*40)
        
        base_packet = build_packet()
        
        for i in range(self.iterations):
            # Generate fuzzed packet
            fuzzed = self.fuzz_packet_complete(base_packet)
            self.fuzzed_packets.append(fuzzed)
            
            # Try to dissect
            try:
                dissected = self.protocol_class(fuzzed)
                self.results['valid'] += 1
                
                if (i + 1) % 10 == 0:
                    print(f"Iteration {i+1}: Valid dissection")
                    
            except Exception as e:
                self.results['invalid'] += 1
                print(f"Iteration {i+1}: Error - {e}")
        
        self.display_results()
    
    def display_results(self):
        """Display fuzzing results."""
        print("\n" + "="*60)
        print("FUZZING RESULTS")
        print("="*60)
        print(f"Total iterations: {self.iterations}")
        print(f"Valid dissections: {self.results['valid']}")
        print(f"Invalid dissections: {self.results['invalid']}")
        print(f"Success rate: {self.results['valid'] / self.iterations * 100:.1f}%")
        
        # Save sample packets
        os.makedirs("output", exist_ok=True)
        
        # Save valid packets
        valid_file = "output/fuzzed_valid.bin"
        with open(valid_file, 'wb') as f:
            for pkt in self.fuzzed_packets[:50]:
                f.write(pkt)
                f.write(b'\n')
        print(f"\nValid sample packets saved to: {valid_file}")
        
        print("\n" + "="*60)

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Protocol Fuzzer')
    parser.add_argument('-i', '--iterations', type=int, default=100,
                        help='Number of iterations')
    parser.add_argument('-s', '--seed', type=int, help='Random seed')
    args = parser.parse_args()
    
    fuzzer = ProtocolFuzzer(
        protocol_class=MyProtocol,
        iterations=args.iterations,
        seed=args.seed
    )
    fuzzer.run()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("="*60)
        print("PROTOCOL FUZZER")
        print("="*60)
        
        iterations = input("Iterations (default: 100): ").strip()
        iterations = int(iterations) if iterations else 100
        
        fuzzer = ProtocolFuzzer(protocol_class=MyProtocol, iterations=iterations)
        fuzzer.run()
    else:
        main()
```

---

### Verification Checklist

- [ ] Fuzzer runs without errors
- [ ] Packet fields are mutated
- [ ] Payloads are fuzzed
- [ ] Results are displayed
- [ ] Sample packets are saved

---

### Lab Report

**1. How many iterations were run?**
```
Answer: ______________________________________________________
```

**2. What was the success rate (valid dissections)?**
```
Answer: ______________________________________________________
```

**3. What types of mutations were applied?**
```
Answer: ______________________________________________________
```

**4. Were there any interesting edge cases discovered?**
```
Answer: ______________________________________________________
```

---

### Challenges

**Challenge 1:** Add support for multiple protocols.

**Challenge 2:** Implement smart fuzzing based on previous results.

**Challenge 3:** Add logging of interesting edge cases.

---

## Lab Report Template

Use this template for each lab:

---

### Lab [Number]: [Lab Name]

**Date:** ______________________

**Student Name:** ______________________

**Objectives Completed:**
- [ ] Objective 1
- [ ] Objective 2
- [ ] Objective 3

**Key Results:**

1. **What was the most important thing you learned?**
   ```
   _____________________________________________________________
   _____________________________________________________________
   ```

2. **What was the most challenging part?**
   ```
   _____________________________________________________________
   _____________________________________________________________
   ```

3. **What would you do differently next time?**
   ```
   _____________________________________________________________
   _____________________________________________________________
   ```

**Verification Checklist:**
- [ ] All verification steps completed
- [ ] All lab report questions answered
- [ ] All challenges attempted

**Additional Notes:**
```
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________
```

---

**End of Lab Book**
