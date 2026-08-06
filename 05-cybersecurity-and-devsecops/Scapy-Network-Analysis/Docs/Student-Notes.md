# Mastering Network Packet Crafting with Scapy
## Student Notes & Quick Reference Guide

## Overview

This document contains concise student notes for quick reference during and after the **Mastering Network Packet Crafting with Scapy** series. Use these notes as a study guide, quick reference, and memory aid.

---

## Table of Contents

1. [Scapy Basics](#scapy-basics)
2. [Packet Construction](#packet-construction)
3. [Packet Inspection](#packet-inspection)
4. [Send/Receive Functions](#sendreceive-functions)
5. [PCAP Operations](#pcap-operations)
6. [Sniffing](#sniffing)
7. [BPF Filters](#bpf-filters)
8. [Ethernet & Layer 2](#ethernet--layer-2)
9. [IP & Layer 3](#ip--layer-3)
10. [ARP](#arp)
11. [ICMP](#icmp)
12. [TCP](#tcp)
13. [UDP](#udp)
14. [Port Scanning](#port-scanning)
15. [Custom Protocols](#custom-protocols)
16. [Performance Optimization](#performance-optimization)
17. [Security & Ethics](#security--ethics)
18. [Quick Commands](#quick-commands)
19. [Common Errors](#common-errors)
20. [Useful Snippets](#useful-snippets)

---

## Scapy Basics

### Installation

```bash
# Install Scapy
pip install scapy[complete]

# Virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows
```

### Imports

```python
# Standard import
from scapy.all import *

# Specific imports
from scapy.all import Ether, IP, TCP, UDP, ICMP, Raw
from scapy.all import sr, sr1, srp, send, sendp
from scapy.all import sniff, rdpcap, wrpcap
from scapy.all import get_if_list, get_if_hwaddr, conf

# Layer-specific imports
from scapy.layers.l2 import Ether, ARP, Dot1Q
from scapy.layers.inet import IP, TCP, UDP, ICMP
from scapy.layers.dns import DNS, DNSQR, DNSRR
from scapy.layers.dhcp import DHCP, BOOTP
```

### Configuration

```python
# Set default interface
conf.iface = "eth0"

# Verbose mode
conf.verbose = False

# Promiscuous mode
conf.sniff_promisc = True

# Check configuration
print(conf)
```

---

## Packet Construction

### The `/` Operator

```python
# Build from outside to inside (Ethernet -> IP -> TCP -> Data)
packet = Ether() / IP() / TCP() / Raw()

# Examples
ping = Ether() / IP(dst="8.8.8.8") / ICMP()
http = Ether() / IP(dst="10.0.0.1") / TCP(dport=80) / Raw(b"GET / HTTP/1.1\r\n\r\n")
dns = Ether() / IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"DNS query data")
```

### Layer Fields

```python
# Ethernet
Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff")

# IP
IP(src="192.168.1.100", dst="8.8.8.8", ttl=64, flags=2)  # DF flag

# TCP
TCP(sport=12345, dport=80, flags="S", seq=1000, window=65535)

# UDP
UDP(sport=12345, dport=53)

# ICMP
ICMP(type=8, code=0, id=12345, seq=1)  # Echo Request
ICMP(type=0, code=0, id=12345, seq=1)  # Echo Reply
```

### Building Step by Step

```python
# Layer by layer
eth = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff")
ip = IP(src="192.168.1.100", dst="8.8.8.8")
icmp = ICMP()
packet = eth / ip / icmp

# Copy and modify
original = IP(dst="8.8.8.8") / ICMP()
modified = original.copy()
modified[IP].dst = "1.1.1.1"
```

---

## Packet Inspection

### Basic Methods

```python
# Show packet details
packet.show()
packet.show2()  # With calculated checksums

# One-line summary
packet.summary()

# Hex dump
hexdump(packet)

# Raw bytes
bytes(packet)

# Custom format
packet.sprintf("%IP.src% -> %IP.dst%")
```

### Layer Access

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

# Remove layer
del packet[Raw]

# Recalculate checksums
packet.show2()  # Or send() auto-calculates
```

### Common Checks

```python
# Check layer presence
packet.haslayer(IP)
packet.haslayer(TCP)
packet.haslayer(UDP)
packet.haslayer(ICMP)
packet.haslayer(Raw)

# Get all layers
packet.layers()

# Check payload
if packet.payload:
    print("Has payload")
```

---

## Send/Receive Functions

### send() - Layer 3

```python
# Send without waiting for response
send(IP(dst="8.8.8.8") / ICMP())

# With options
send(packet, iface="eth0", count=10, inter=0.5, verbose=True)

# Loop send
send(packet, loop=1, count=100)
```

### sendp() - Layer 2

```python
# Send Ethernet frame
sendp(Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1"))
```

### sr() - Send and Receive

```python
# Send and receive multiple replies
answers, unanswered = sr(packet, timeout=3, retry=2)

for sent, received in answers:
    print(received.summary())
```

### sr1() - Send and Receive First Reply

```python
# Send and get first response
reply = sr1(IP(dst="8.8.8.8") / ICMP(), timeout=3)

if reply:
    print(reply.summary())
else:
    print("No response")
```

### srp() - Layer 2 Send/Receive

```python
# ARP scan
answers, unanswered = srp(
    Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.0/24"),
    timeout=2,
    verbose=False
)

for sent, received in answers:
    print(f"{received[ARP].psrc} -> {received[ARP].hwsrc}")
```

---

## PCAP Operations

### Reading PCAPs

```python
# Standard load
packets = rdpcap("capture.pcap")

# Memory-efficient (large files)
from scapy.utils import PcapReader
with PcapReader("large.pcap") as reader:
    for packet in reader:
        process(packet)

# PCAPNG format
from scapy.utils import PcapNgReader
with PcapNgReader("capture.pcapng") as reader:
    packets = list(reader)
```

### Writing PCAPs

```python
# Save packets
wrpcap("output.pcap", packets)

# Append
with PcapWriter("output.pcap", append=True) as writer:
    for packet in packets:
        writer.write(packet)
```

### Common PCAP Operations

```python
# Filter packets
tcp_packets = [p for p in packets if p.haslayer(TCP)]
http_packets = [p for p in packets if p.haslayer(TCP) and p[TCP].dport == 80]

# Extract timestamps
times = [p.time for p in packets]

# Get packet lengths
lengths = [len(p) for p in packets]

# Count protocols
tcp_count = sum(1 for p in packets if p.haslayer(TCP))
udp_count = sum(1 for p in packets if p.haslayer(UDP))
```

---

## Sniffing

### Basic Sniffing

```python
# Capture packets
packets = sniff(count=10)

# With callback
def process(packet):
    print(packet.summary())

sniff(prn=process, count=10)

# With filter
sniff(filter="tcp port 80", count=10)

# With timeout
packets = sniff(timeout=10)

# Specify interface
sniff(iface="eth0", count=10)
```

### Sniffing Parameters

| Parameter | Description |
|-----------|-------------|
| `iface` | Interface to sniff on |
| `count` | Number of packets to capture |
| `prn` | Callback function for each packet |
| `filter` | BPF filter |
| `timeout` | Stop after N seconds |
| `store` | Store packets in memory (default: True) |
| `promisc` | Promiscuous mode (default: False) |

### Efficient Sniffing

```python
# Store=False for memory efficiency
sniff(prn=process, store=False)

# Use BPF filter at kernel level
sniff(filter="tcp", prn=process, store=False)

# Batch processing
packets = []
def batch_process(packet):
    packets.append(packet)
    if len(packets) >= 100:
        process_batch(packets)
        packets.clear()
```

---

## BPF Filters

### Protocol Filters

| Filter | Description |
|--------|-------------|
| `tcp` | TCP packets only |
| `udp` | UDP packets only |
| `icmp` | ICMP packets only |
| `arp` | ARP packets only |
| `ip` | IPv4 packets only |
| `ip6` | IPv6 packets only |

### Host Filters

| Filter | Description |
|--------|-------------|
| `host 192.168.1.1` | Traffic to/from IP |
| `src host 192.168.1.1` | Traffic from IP |
| `dst host 192.168.1.1` | Traffic to IP |
| `net 192.168.0.0/16` | Traffic to/from network |

### Port Filters

| Filter | Description |
|--------|-------------|
| `port 80` | TCP or UDP port 80 |
| `tcp port 80` | TCP port 80 |
| `udp port 53` | UDP port 53 |
| `src port 12345` | Source port 12345 |
| `dst port 80` | Destination port 80 |

### TCP Flag Filters

| Filter | Description |
|--------|-------------|
| `tcp[13] & 0x02 != 0` | SYN packets |
| `tcp[13] & 0x10 != 0` | ACK packets |
| `tcp[13] & 0x12 != 0` | SYN-ACK packets |
| `tcp[13] & 0x04 != 0` | RST packets |
| `tcp[13] & 0x01 != 0` | FIN packets |

### Combined Filters

```python
# AND
sniff(filter="tcp and port 80")
sniff(filter="tcp and host 192.168.1.1")

# OR
sniff(filter="tcp or udp")
sniff(filter="port 80 or port 443")

# NOT
sniff(filter="not arp")
sniff(filter="not tcp and not udp")

# Grouping
sniff(filter="(tcp or udp) and port 53")
sniff(filter="(port 80 or port 443) and host 192.168.1.1")
```

---

## Ethernet & Layer 2

### Ethernet Frame Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                      ETHERNET FRAME                            │
├──────────┬──────────┬──────────┬──────────────┬───────────────┤
│ Preamble │ Dest MAC │ Src MAC │ EtherType    │ Payload       │
│ 8 bytes  │ 6 bytes  │ 6 bytes │ 2 bytes      │ 46-1500 bytes │
├──────────┴──────────┴──────────┴──────────────┴───────────────┤
│ FCS (4 bytes)                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### MAC Address Types

| Type | Example | Characteristic |
|------|---------|----------------|
| Unicast | `00:11:22:33:44:55` | First bit = 0 |
| Multicast | `01:00:5e:00:00:01` | First bit = 1 |
| Broadcast | `ff:ff:ff:ff:ff:ff` | All bits = 1 |

### VLAN (802.1Q)

```python
from scapy.layers.l2 import Dot1Q

# VLAN tagging
vlan = Ether() / Dot1Q(vlan=100) / IP(dst="8.8.8.8") / ICMP()

# VLAN with priority
vlan_prio = Ether() / Dot1Q(vlan=100, prio=5) / IP(dst="8.8.8.8")

# Q-in-Q (double VLAN)
qinq = Ether() / Dot1Q(vlan=100) / Dot1Q(vlan=200) / IP(dst="8.8.8.8")
```

### Common EtherTypes

| Value | Protocol |
|-------|----------|
| 0x0800 | IPv4 |
| 0x0806 | ARP |
| 0x86DD | IPv6 |
| 0x8100 | VLAN (802.1Q) |

---

## IP & Layer 3

### IPv4 Header Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                    IPv4 HEADER (20-60 bytes)                   │
├────────┬──────────┬──────────┬──────────┬──────────┬─────────┤
│Version │ IHL      │ ToS      │ Total Length                   │
│4 bits  │ 4 bits   │ 8 bits   │ 16 bits                        │
├────────┴──────────┴──────────┼──────────┬──────────┬─────────┤
│ Identification (16 bits)     │ Flags    │ Fragment Offset     │
│                              │ 3 bits   │ 13 bits             │
├──────────────────────────────┼──────────┼─────────────────────┤
│ TTL (8 bits)                 │ Protocol │ Header Checksum     │
│                              │ 8 bits   │ 16 bits             │
├──────────────────────────────┴──────────┴─────────────────────┤
│ Source IP Address (32 bits)                                   │
├─────────────────────────────────────────────────────────────────┤
│ Destination IP Address (32 bits)                              │
└─────────────────────────────────────────────────────────────────┘
```

### Key IP Fields

| Field | Description |
|-------|-------------|
| `src` | Source IP address |
| `dst` | Destination IP address |
| `ttl` | Time To Live (default: 64) |
| `id` | Identification for fragmentation |
| `flags` | DF (Don't Fragment), MF (More Fragments) |
| `proto` | Protocol (TCP=6, UDP=17, ICMP=1) |

### IP Fragmentation

```python
# Create large packet
packet = IP(dst="8.8.8.8") / ICMP() / Raw(b"X" * 2000)

# Fragment
fragments = packet.fragment()
print(f"Created {len(fragments)} fragments")

# Defragment
reassembled = IP(fragments)

# Send fragments
for frag in fragments:
    send(frag)
```

---

## ARP

### ARP Structure

```python
ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100",
    hwdst="00:00:00:00:00:00", pdst="192.168.1.1")
```

| Field | Description |
|-------|-------------|
| `op` | Operation (1=Request, 2=Reply) |
| `hwsrc` | Sender MAC address |
| `psrc` | Sender IP address |
| `hwdst` | Target MAC address |
| `pdst` | Target IP address |

### ARP Scan

```python
# ARP request
arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.0/24")

# Send and receive
answers, unanswered = srp(arp_request, timeout=2, verbose=False)

# Process responses
for sent, received in answers:
    print(f"{received[ARP].psrc} -> {received[ARP].hwsrc}")
```

---

## ICMP

### ICMP Structure

```python
ICMP(type=8, code=0, id=12345, seq=1)  # Echo Request
ICMP(type=0, code=0, id=12345, seq=1)  # Echo Reply
```

### Common ICMP Types

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Ping response |
| 3 | Destination Unreachable | Network/host unreachable |
| 8 | Echo Request | Ping request |
| 11 | Time Exceeded | TTL expired (traceroute) |

### Ping Implementation

```python
# Build ping
ping = IP(dst="8.8.8.8") / ICMP(type=8, code=0, id=12345, seq=1)

# Send and wait for reply
reply = sr1(ping, timeout=3)

if reply and reply.haslayer(ICMP) and reply[ICMP].type == 0:
    print("Ping response received")
```

### Traceroute Implementation

```python
def traceroute(target, max_hops=30):
    for ttl in range(1, max_hops + 1):
        packet = IP(dst=target, ttl=ttl) / ICMP()
        reply = sr1(packet, timeout=2, verbose=False)
        
        if reply is None:
            print(f"{ttl}. * * *")
            continue
        
        ip = reply[IP].src
        if reply.haslayer(ICMP) and reply[ICMP].type == 0:
            print(f"{ttl}. {ip} - Reached destination!")
            break
        elif reply.haslayer(ICMP) and reply[ICMP].type == 11:
            print(f"{ttl}. {ip}")
```

---

## TCP

### TCP Header Structure

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

### TCP Flags

| Flag | Bit | Name | Description |
|------|-----|------|-------------|
| FIN | 0x01 | Finish | End connection |
| SYN | 0x02 | Synchronize | Establish connection |
| RST | 0x04 | Reset | Abort connection |
| PSH | 0x08 | Push | Immediate delivery |
| ACK | 0x10 | Acknowledgment | ACK valid |
| URG | 0x20 | Urgent | Urgent data |

### TCP Handshake

```python
# SYN
syn = IP(dst="10.0.0.1") / TCP(dport=80, flags="S", seq=1000)

# SYN-ACK
syn_ack = sr1(syn, timeout=3)

# ACK
if syn_ack and syn_ack.haslayer(TCP):
    ack = IP(dst="10.0.0.1") / TCP(
        dport=80,
        flags="A",
        seq=1001,
        ack=syn_ack[TCP].seq + 1
    )
    send(ack)
    print("Handshake complete")
```

### TCP Options

```python
# TCP with options
tcp = TCP(
    dport=80,
    flags="S",
    options=[
        ('MSS', 1460),
        ('SAckOK', b''),
        ('Timestamp', (12345, 0)),
        ('WindowScale', 7)
    ]
)
```

---

## UDP

### UDP Header Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                    UDP HEADER (8 bytes)                        │
├──────────────┬──────────────────┬─────────────────────────────┤
│ Source Port  │ Destination Port │                             │
│ 16 bits      │ 16 bits          │                             │
├──────────────┴──────────────────┼─────────────────────────────┤
│ Length (16 bits)                │ Checksum (16 bits)          │
└─────────────────────────────────┴─────────────────────────────┘
```

### UDP Packet Construction

```python
# Basic UDP
udp = IP(dst="8.8.8.8") / UDP(sport=12345, dport=53)

# UDP with payload
udp = IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"DNS query data")

# DNS query
dns = IP(dst="8.8.8.8") / UDP(dport=53) / DNS(qd=DNSQR(qname="example.com"))
```

---

## Port Scanning

### SYN Scan

```python
class TCPSYNScanner:
    def scan_port(self, port):
        packet = IP(dst=self.target) / TCP(dport=port, flags="S")
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply and reply.haslayer(TCP):
            if reply[TCP].flags & 0x12:  # SYN-ACK
                rst = IP(dst=self.target) / TCP(dport=port, flags="R", seq=reply[TCP].ack)
                send(rst, verbose=False)
                return "open"
            elif reply[TCP].flags & 0x04:  # RST
                return "closed"
        return "filtered"
```

### Connect Scan

```python
def tcp_connect_scan(ip, port, timeout=3):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((ip, port))
        sock.close()
        return result == 0
    except:
        return False
```

### UDP Scan

```python
def udp_scan(ip, port, timeout=3):
    packet = IP(dst=ip) / UDP(dport=port)
    reply = sr1(packet, timeout=timeout, verbose=False)
    
    if reply is None:
        return "open_or_filtered"
    
    if reply.haslayer(ICMP) and reply[ICMP].type == 3 and reply[ICMP].code == 3:
        return "closed"
    return "open"
```

---

## Custom Protocols

### Creating a Protocol

```python
from scapy.packet import Packet
from scapy.fields import *

class MyProtocol(Packet):
    name = "MyProtocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        ShortField("length", 0),
        IntField("sequence", 0),
        IntField("timestamp", 0)
    ]
    
    def mysummary(self):
        return f"MyProtocol v{self.version} type={self.type} seq={self.sequence}"
```

### Field Types

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
| `FlagsField` | Bit flags | Variable |

### Protocol Binding

```python
# Bind to parent protocol
bind_layers(IP, MyProtocol, proto=250)

# Bind based on field value
bind_layers(MyProtocol, MyData, type=0)
bind_layers(MyProtocol, MyResponse, type=1)

# Remove binding
unbind_layers(IP, MyProtocol)
```

---

## Performance Optimization

### Multi-Threading

```python
import threading
import queue

class PacketProcessor:
    def __init__(self, workers=4):
        self.queue = queue.Queue()
        self.workers = workers
    
    def worker(self):
        while True:
            packet = self.queue.get()
            self.process(packet)
            self.queue.task_done()
    
    def process(self, packet):
        # Processing logic
        pass
    
    def start(self):
        for _ in range(self.workers):
            t = threading.Thread(target=self.worker)
            t.daemon = True
            t.start()
```

### Efficient Data Structures

```python
from collections import defaultdict, deque

# Default dictionary
protocol_counts = defaultdict(int)
protocol_counts['TCP'] += 1

# Deque with max length
packet_history = deque(maxlen=1000)

# Bloom filter (simplified)
ip_bloom = bytearray(1024)
def add_to_bloom(ip):
    h1 = hash(ip) % 1024
    h2 = (hash(ip) * 3 + 1) % 1024
    ip_bloom[h1] = 1
    ip_bloom[h2] = 1
```

### Asynchronous Processing

```python
import asyncio

class AsyncProcessor:
    async def process_packet(self, packet):
        await asyncio.sleep(0.001)  # Simulate work
        return packet.summary()
    
    async def process_batch(self, packets):
        tasks = [self.process_packet(p) for p in packets]
        return await asyncio.gather(*tasks)
    
    async def process_pcap(self, pcap_file):
        packets = rdpcap(pcap_file)
        for i in range(0, len(packets), 100):
            batch = packets[i:i+100]
            await self.process_batch(batch)
```

### Producer-Consumer Pattern

```python
class ProducerConsumer:
    def __init__(self, buffer_size=10000):
        self.queue = queue.Queue(maxsize=buffer_size)
        self.running = False
    
    def producer(self):
        sniff(prn=self.queue.put, store=False)
    
    def consumer(self):
        while self.running:
            try:
                packet = self.queue.get(timeout=0.5)
                self.process(packet)
                self.queue.task_done()
            except queue.Empty:
                continue
    
    def start(self):
        self.running = True
        threading.Thread(target=self.producer).start()
        for _ in range(4):
            threading.Thread(target=self.consumer).start()
```

---

## Security & Ethics

### Core Principles

```
┌─────────────────────────────────────────────────────────────────┐
│                    CORE ETHICAL PRINCIPLES                     │
├─────────────────────────────────────────────────────────────────┤
│ 1. Never test without written authorization                    │
│ 2. Practice only in isolated lab environments                  │
│ 3. Build defensive tools, not offensive weapons                │
│ 4. Disclose vulnerabilities responsibly                        │
│ 5. Stay within authorized scope                                │
│ 6. Document all activities                                     │
│ 7. Protect data and privacy                                    │
└─────────────────────────────────────────────────────────────────┘
```

### Safety Controls

```python
class SafeInjector:
    def __init__(self, authorized_targets=None):
        self.authorized_targets = authorized_targets or ['127.0.0.1']
        self.rate_limit = 10  # Packets per second
        self.last_packet = 0
    
    def is_authorized(self, target):
        return target in self.authorized_targets
    
    def rate_limit_wait(self):
        interval = 1.0 / self.rate_limit
        elapsed = time.time() - self.last_packet
        if elapsed < interval:
            time.sleep(interval - elapsed)
        self.last_packet = time.time()
    
    def inject(self, packet):
        target = packet[IP].dst if packet.haslayer(IP) else None
        if not self.is_authorized(target):
            print(f"Unauthorized: {target}")
            return False
        self.rate_limit_wait()
        send(packet)
        return True
```

---

## Quick Commands

### Interface Commands

```bash
# List interfaces
python3 -c "from scapy.all import get_if_list; print(get_if_list())"

# Get MAC address
python3 -c "from scapy.all import get_if_hwaddr; print(get_if_hwaddr('eth0'))"

# Get IP address
python3 -c "from scapy.all import get_if_addr; print(get_if_addr('eth0'))"
```

### Packet Construction

```bash
# Build and show packet
python3 -c "from scapy.all import IP, TCP; p=IP(dst='8.8.8.8')/TCP(dport=80, flags='S'); p.show()"

# Save to PCAP
python3 -c "from scapy.all import IP, ICMP, wrpcap; wrpcap('ping.pcap', [IP(dst='8.8.8.8')/ICMP()])"
```

### Sniffing

```bash
# Capture 10 packets
sudo python3 -c "from scapy.all import sniff; sniff(count=10, prn=lambda x: x.summary())"

# Capture HTTP
sudo python3 -c "from scapy.all import sniff; sniff(filter='tcp port 80', count=10, prn=lambda x: x.summary())"
```

### PCAP Analysis

```bash
# Read and summarize
python3 -c "from scapy.all import rdpcap; packets=rdpcap('capture.pcap'); [print(p.summary()) for p in packets[:10]]"

# Count TCP packets
python3 -c "from scapy.all import rdpcap, TCP; packets=rdpcap('capture.pcap'); print(len([p for p in packets if p.haslayer(TCP)]))"

# Extract source IPs
python3 -c "from scapy.all import rdpcap, IP; packets=rdpcap('capture.pcap'); ips=set([p[IP].src for p in packets if p.haslayer(IP)]); print(ips)"
```

### ARP Scanning

```bash
# Scan network
sudo python3 -c "from scapy.all import Ether, ARP, srp; answers, _=srp(Ether(dst='ff:ff:ff:ff:ff:ff')/ARP(pdst='192.168.1.0/24'), timeout=2, verbose=False); [print(f'{r[1][ARP].psrc} -> {r[1][ARP].hwsrc}') for r in answers]"
```

### Port Scanning

```bash
# SYN scan
sudo python3 -c "from scapy.all import IP, TCP, sr1; for p in range(1, 100): r=sr1(IP(dst='127.0.0.1')/TCP(dport=p,flags='S'), timeout=1, verbose=False); if r and r.haslayer(TCP) and r[TCP].flags & 0x12: print(p, 'open')"
```

---

## Common Errors

### Permission Denied

```
Error: Permission denied
Cause: Need root/sudo for raw sockets
Solution: sudo python3 script.py
```

### Module Not Found

```
Error: ModuleNotFoundError: No module named 'scapy'
Cause: Scapy not installed
Solution: pip install scapy[complete]
```

### No Response

```
Error: No response received
Cause: Timeout or firewall blocking
Solution: Increase timeout, check target reachability
```

### Invalid IP

```
Error: Invalid IP address
Cause: Malformed IP format
Solution: Verify IP format (e.g., 192.168.1.1)
```

### Checksum Error

```
Error: Invalid checksum
Cause: Checksum not recalculated after modification
Solution: Use show2() or send() auto-calculates
```

### Buffer Overflow

```
Error: Queue full / buffer overflow
Cause: Too many packets for processing
Solution: Increase buffer size or use filters
```

### Interface Not Found

```
Error: Interface not found
Cause: Interface doesn't exist or is down
Solution: Verify interface name, bring up interface
```

---

## Useful Snippets

### Packet Validation

```python
def validate_ip(ip):
    """Validate IP address format."""
    import ipaddress
    try:
        ipaddress.ip_address(ip)
        return True
    except:
        return False

def validate_mac(mac):
    """Validate MAC address format."""
    import re
    pattern = r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
    return bool(re.match(pattern, mac))
```

### Protocol Detection

```python
def get_protocol_name(packet):
    """Get protocol name from packet."""
    if packet.haslayer(TCP):
        return "TCP"
    elif packet.haslayer(UDP):
        return "UDP"
    elif packet.haslayer(ICMP):
        return "ICMP"
    elif packet.haslayer(IP):
        return "IP"
    else:
        return "Other"
```

### Service Mapping

```python
SERVICES = {
    20: 'FTP-Data',
    21: 'FTP',
    22: 'SSH',
    23: 'Telnet',
    25: 'SMTP',
    53: 'DNS',
    80: 'HTTP',
    110: 'POP3',
    143: 'IMAP',
    443: 'HTTPS',
    3306: 'MySQL',
    3389: 'RDP',
    5432: 'PostgreSQL',
    8080: 'HTTP-Alt'
}

def get_service(port):
    return SERVICES.get(port, 'Unknown')
```

### Traffic Statistics

```python
def get_traffic_stats(packets):
    """Get traffic statistics from packets."""
    stats = {
        'total': len(packets),
        'tcp': 0,
        'udp': 0,
        'icmp': 0,
        'other': 0,
        'bytes': sum(len(p) for p in packets)
    }
    
    for p in packets:
        if p.haslayer(TCP):
            stats['tcp'] += 1
        elif p.haslayer(UDP):
            stats['udp'] += 1
        elif p.haslayer(ICMP):
            stats['icmp'] += 1
        else:
            stats['other'] += 1
    
    return stats
```

### IP to Bytes

```python
def ip_to_bytes(ip):
    """Convert IP string to bytes."""
    import socket
    return socket.inet_aton(ip)

def bytes_to_ip(b):
    """Convert bytes to IP string."""
    import socket
    return socket.inet_ntoa(b)
```

### MAC to Bytes

```python
def mac_to_bytes(mac):
    """Convert MAC string to bytes."""
    return bytes(int(x, 16) for x in mac.split(':'))

def bytes_to_mac(b):
    """Convert bytes to MAC string."""
    return ':'.join(f'{x:02x}' for x in b)
```

### Packet Summaries

```python
def detailed_summary(packet):
    """Get detailed packet summary."""
    parts = []
    
    if packet.haslayer(Ether):
        parts.append(f"MAC: {packet[Ether].src} -> {packet[Ether].dst}")
    
    if packet.haslayer(IP):
        parts.append(f"IP: {packet[IP].src} -> {packet[IP].dst}")
        if packet.haslayer(TCP):
            parts.append(f"TCP: {packet[TCP].sport} -> {packet[TCP].dport} flags={packet[TCP].flags}")
        elif packet.haslayer(UDP):
            parts.append(f"UDP: {packet[UDP].sport} -> {packet[UDP].dport}")
        elif packet.haslayer(ICMP):
            parts.append(f"ICMP: type={packet[ICMP].type} code={packet[ICMP].code}")
    
    return ' | '.join(parts)
```

---

## Quick Reference Card

### Common Ports

| Port | Service | Protocol |
|------|---------|----------|
| 20/21 | FTP | TCP |
| 22 | SSH | TCP |
| 23 | Telnet | TCP |
| 25 | SMTP | TCP |
| 53 | DNS | TCP/UDP |
| 67/68 | DHCP | UDP |
| 80 | HTTP | TCP |
| 110 | POP3 | TCP |
| 123 | NTP | UDP |
| 143 | IMAP | TCP |
| 161 | SNMP | UDP |
| 443 | HTTPS | TCP |
| 3306 | MySQL | TCP |
| 3389 | RDP | TCP |
| 5432 | PostgreSQL | TCP |
| 5900 | VNC | TCP |
| 8080 | HTTP-Alt | TCP |

### TCP Flags Quick Reference

| Flag | Hex | Dec | Command |
|------|-----|-----|---------|
| FIN | 0x01 | 1 | `flags="F"` |
| SYN | 0x02 | 2 | `flags="S"` |
| RST | 0x04 | 4 | `flags="R"` |
| PSH | 0x08 | 8 | `flags="P"` |
| ACK | 0x10 | 16 | `flags="A"` |
| URG | 0x20 | 32 | `flags="U"` |

### ICMP Types Quick Reference

| Type | Name | Code |
|------|------|------|
| 0 | Echo Reply | 0 |
| 3 | Destination Unreachable | 0-15 |
| 4 | Source Quench | 0 |
| 5 | Redirect | 0-3 |
| 8 | Echo Request | 0 |
| 11 | Time Exceeded | 0-1 |
| 12 | Parameter Problem | 0-2 |

### IP Protocol Numbers

| Number | Protocol |
|--------|----------|
| 1 | ICMP |
| 6 | TCP |
| 17 | UDP |
| 41 | IPv6 |
| 47 | GRE |
| 50 | ESP |
| 51 | AH |

---

## Notes Section

Use this section for your personal notes during the course:

---

### Module 1 Notes

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Module 2 Notes

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Module 3 Notes

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Module 4 Notes

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Module 5 Notes

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Module 6 Notes

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Final Quick Reference

### Most Used Commands

```python
# Packet construction
pkt = Ether() / IP(dst="8.8.8.8") / TCP(dport=80) / Raw(b"data")

# Send
send(pkt)

# Send and receive
reply = sr1(pkt, timeout=3)

# Sniff
packets = sniff(filter="tcp", count=10)

# Read PCAP
packets = rdpcap("file.pcap")

# Write PCAP
wrpcap("output.pcap", packets)

# Show packet
pkt.show()

# Check layer
if pkt.haslayer(TCP):
    print(pkt[TCP].dport)

# ARP scan
answers, _ = srp(Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.0/24"))

# Custom protocol
class MyProtocol(Packet):
    fields_desc = [ByteField("field", 0)]
bind_layers(IP, MyProtocol, proto=250)
```

---

**Happy Packet Crafting!** 🚀
