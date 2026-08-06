# Mastering Network Packet Crafting with Scapy
## Appendix A: Scapy API Reference

## Overview

This appendix provides a comprehensive reference to Scapy's API, covering all major classes, functions, and methods used throughout the series. Use this as a quick reference when building your own packet crafting tools.

---

## Table of Contents

1. [Core Packet Classes](#core-packet-classes)
2. [Packet Construction](#packet-construction)
3. [Send/Receive Functions](#sendreceive-functions)
4. [Packet Inspection](#packet-inspection)
5. [PCAP Operations](#pcap-operations)
6. [Sniffing](#sniffing)
7. [ARP Operations](#arp-operations)
8. [IP Operations](#ip-operations)
9. [TCP Operations](#tcp-operations)
10. [UDP Operations](#udp-operations)
11. [ICMP Operations](#icmp-operations)
12. [Ethernet Operations](#ethernet-operations)
13. [VLAN Operations](#vlan-operations)
14. [Field Types](#field-types)
15. [Utility Functions](#utility-functions)
16. [Configuration](#configuration)
17. [Common Exceptions](#common-exceptions)

---

## 1. Core Packet Classes

### Packet Class

The base class for all protocol layers.

```python
from scapy.packet import Packet

class MyProtocol(Packet):
    name = "MyProtocol"
    fields_desc = [
        # Field definitions
    ]
    
    def mysummary(self):
        """Custom summary for this protocol."""
        return f"MyProtocol field1={self.field1}"
    
    def guess_payload_class(self, payload):
        """Determine next layer based on payload."""
        return Raw
```

**Key Methods:**

| Method | Description |
|--------|-------------|
| `show()` | Display packet fields hierarchically |
| `show2()` | Display with calculated fields (checksums, lengths) |
| `summary()` | One-line summary |
| `mysummary()` | Custom summary (override) |
| `haslayer(cls)` | Check if packet has a specific layer |
| `getlayer(cls)` | Get a specific layer |
| `remove_payload()` | Remove payload from packet |
| `copy()` | Create a deep copy of the packet |
| `build()` | Build raw bytes from packet |
| `fragment()` | Fragment the packet (IP) |
| `defragment()` | Defragment IP packets |
| `command()` | Generate code to recreate the packet |
| `sprintf(fmt)` | Format string with packet fields |
| `hexdump()` | Display hex dump of packet |
| `psdump()` | Display PostScript dump (requires PyX) |
| `pdfdump()` | Generate PDF (requires PyX) |
| `time` | Packet timestamp (when captured) |

---

### Layer Base Classes

**Ether (Ethernet Layer)**

```python
from scapy.layers.l2 import Ether

# Fields
Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff", type=0x0800)
```

| Field | Type | Description |
|-------|------|-------------|
| `dst` | MACField | Destination MAC address |
| `src` | MACField | Source MAC address |
| `type` | ShortEnumField | EtherType (auto-set) |

**Common EtherTypes:**
- `0x0800` - IPv4
- `0x0806` - ARP
- `0x86DD` - IPv6
- `0x8100` - VLAN (802.1Q)

---

**IP (IPv4 Layer)**

```python
from scapy.layers.inet import IP

# Fields
IP(src="192.168.1.100", dst="8.8.8.8", ttl=64, id=12345)
```

| Field | Type | Description |
|-------|------|-------------|
| `version` | BitField | IP version (4) |
| `ihl` | BitField | Internet Header Length |
| `tos` | ByteField | Type of Service |
| `len` | ShortField | Total length |
| `id` | ShortField | Identification |
| `flags` | FlagsField | Flags (DF, MF) |
| `frag` | BitField | Fragment offset |
| `ttl` | ByteField | Time To Live |
| `proto` | ByteEnumField | Protocol |
| `chksum` | XShortField | Header checksum |
| `src` | IPField | Source IP address |
| `dst` | IPField | Destination IP address |
| `options` | PacketListField | IP options |

**Common Protocol Numbers:**
- `1` - ICMP
- `6` - TCP
- `17` - UDP
- `41` - IPv6
- `47` - GRE
- `50` - ESP
- `51` - AH

---

**TCP (TCP Layer)**

```python
from scapy.layers.inet import TCP

# Fields
TCP(sport=12345, dport=80, flags="S", seq=1000, window=65535)
```

| Field | Type | Description |
|-------|------|-------------|
| `sport` | ShortField | Source port |
| `dport` | ShortField | Destination port |
| `seq` | IntField | Sequence number |
| `ack` | IntField | Acknowledgment number |
| `dataofs` | BitField | Data offset |
| `reserved` | BitField | Reserved |
| `flags` | FlagsField | TCP flags (see below) |
| `window` | ShortField | Window size |
| `chksum` | XShortField | Checksum |
| `urgptr` | ShortField | Urgent pointer |
| `options` | TCPOptionsField | TCP options |

**TCP Flags:**

| Flag | Bit | Description |
|------|-----|-------------|
| `F` or `FIN` | 0x01 | Finish |
| `S` or `SYN` | 0x02 | Synchronize |
| `R` or `RST` | 0x04 | Reset |
| `P` or `PSH` | 0x08 | Push |
| `A` or `ACK` | 0x10 | Acknowledgment |
| `U` or `URG` | 0x20 | Urgent |
| `E` or `ECE` | 0x40 | ECN Echo |
| `C` or `CWR` | 0x80 | Congestion Window Reduced |

**Common TCP Options:**

```python
options=[
    ('MSS', 1460),           # Maximum Segment Size
    ('SAckOK', b''),         # Selective ACK permitted
    ('Timestamp', (12345, 0)), # Timestamp
    ('WindowScale', 7),      # Window scaling
    ('NOP', None),           # No Operation
    ('EOL', None)            # End of Options List
]
```

---

**UDP (UDP Layer)**

```python
from scapy.layers.inet import UDP

# Fields
UDP(sport=12345, dport=53)
```

| Field | Type | Description |
|-------|------|-------------|
| `sport` | ShortField | Source port |
| `dport` | ShortField | Destination port |
| `len` | ShortField | Datagram length |
| `chksum` | XShortField | Checksum |

---

**ICMP (ICMP Layer)**

```python
from scapy.layers.inet import ICMP

# Echo Request
ICMP(type=8, code=0, id=12345, seq=1)

# Echo Reply
ICMP(type=0, code=0, id=12345, seq=1)
```

| Field | Type | Description |
|-------|------|-------------|
| `type` | ByteField | ICMP type |
| `code` | ByteField | ICMP code |
| `chksum` | XShortField | Checksum |
| `id` | ShortField | Identifier |
| `seq` | ShortField | Sequence number |

**ICMP Types:**

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Ping response |
| 3 | Destination Unreachable | Network/host unreachable |
| 4 | Source Quench | Congestion control |
| 5 | Redirect | Route change |
| 8 | Echo Request | Ping request |
| 9 | Router Advertisement | Router discovery |
| 10 | Router Solicitation | Router discovery |
| 11 | Time Exceeded | TTL expired |
| 12 | Parameter Problem | Bad IP header |

---

**ICMP Error Types (Type 3):**

| Code | Name | Description |
|------|------|-------------|
| 0 | Net Unreachable | Network unreachable |
| 1 | Host Unreachable | Host unreachable |
| 2 | Protocol Unreachable | Protocol unreachable |
| 3 | Port Unreachable | Port unreachable |
| 4 | Fragmentation Needed | DF set, need fragmentation |
| 5 | Source Route Failed | Source route failed |

---

**ARP (ARP Layer)**

```python
from scapy.layers.l2 import ARP

# ARP Request
ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100", pdst="192.168.1.1")

# ARP Reply
ARP(op=2, hwsrc="aa:bb:cc:dd:ee:ff", psrc="192.168.1.1", pdst="192.168.1.100")
```

| Field | Type | Description |
|-------|------|-------------|
| `hwtype` | ShortField | Hardware type (1=Ethernet) |
| `ptype` | ShortEnumField | Protocol type (0x0800=IPv4) |
| `hwlen` | ByteField | Hardware address length (6) |
| `plen` | ByteField | Protocol address length (4) |
| `op` | ShortEnumField | Operation (1=Request, 2=Reply) |
| `hwsrc` | MACField | Sender MAC address |
| `psrc` | IPField | Sender IP address |
| `hwdst` | MACField | Target MAC address |
| `pdst` | IPField | Target IP address |

---

**DNS (DNS Layer)**

```python
from scapy.layers.dns import DNS, DNSQR, DNSRR

# DNS Query
DNS(qd=DNSQR(qname="example.com", qtype=1, qclass=1))

# DNS Response
DNS(qr=1, an=DNSRR(rrname="example.com", rdata="192.168.1.1"))
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | ShortField | Transaction ID |
| `qr` | BitField | Query/Response (0=Query, 1=Response) |
| `opcode` | BitField | Operation code |
| `aa` | BitField | Authoritative Answer |
| `tc` | BitField | Truncated |
| `rd` | BitField | Recursion Desired |
| `ra` | BitField | Recursion Available |
| `rcode` | BitField | Response code |
| `qd` | DNSQRField | Question section |
| `an` | DNSRRField | Answer section |
| `ns` | DNSRRField | Authority section |
| `ar` | DNSRRField | Additional section |

**DNS Record Types:**

| Type | Name | Description |
|------|------|-------------|
| 1 | A | IPv4 address |
| 28 | AAAA | IPv6 address |
| 5 | CNAME | Canonical name |
| 15 | MX | Mail exchange |
| 2 | NS | Name server |
| 16 | TXT | Text record |

---

**DHCP (DHCP Layer)**

```python
from scapy.layers.dhcp import DHCP, BOOTP

# DHCP Discover
BOOTP(chaddr="00:11:22:33:44:55") / DHCP(options=[("message-type", 1)])
```

**DHCP Message Types:**

| Type | Name | Description |
|------|------|-------------|
| 1 | DISCOVER | Client looking for DHCP server |
| 2 | OFFER | Server offering IP configuration |
| 3 | REQUEST | Client requesting offered config |
| 4 | DECLINE | Client rejecting offered config |
| 5 | ACK | Server confirming configuration |
| 6 | NAK | Server denying request |
| 7 | RELEASE | Client releasing IP address |
| 8 | INFORM | Client requesting local configuration |

---

## 2. Packet Construction

### The `/` Operator

Stack layers from outside to inside:

```python
# Syntax: Outer / Inner
packet = Ether() / IP() / TCP() / Raw()

# Examples
ping = Ether() / IP(dst="8.8.8.8") / ICMP()
http = Ether() / IP(dst="8.8.8.8") / TCP(dport=80) / Raw(b"GET / HTTP/1.0\r\n\r\n")
dns = Ether() / IP(dst="8.8.8.8") / UDP(dport=53) / DNS()
```

### Layer Access

```python
# Access by class
packet[IP].src

# Check presence
if packet.haslayer(TCP):
    print(packet[TCP].dport)

# Get with default
tcp = packet.getlayer(TCP)
if tcp:
    print(tcp.flags)

# Access payload
payload = packet.payload
```

### Packet Building Patterns

```python
# Build layer by layer
eth = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff")
ip = IP(src="192.168.1.100", dst="8.8.8.8")
icmp = ICMP(type=8, code=0)
packet = eth / ip / icmp

# Build from template
template = Ether() / IP()
packet = template / TCP(dport=80)

# Copy and modify
original = Ether() / IP(dst="8.8.8.8") / ICMP()
modified = original.copy()
modified[IP].dst = "1.1.1.1"
```

---

## 3. Send/Receive Functions

### send() - Send packets at Layer 3

```python
from scapy.sendrecv import send

# Send without waiting for response
send(IP(dst="8.8.8.8") / ICMP())

# Send with options
send(packet, iface="eth0", count=10, inter=0.5, verbose=True)

# Send with loop
send(packet, loop=1, count=100)  # Send 100 times
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `x` | Packet(s) to send |
| `iface` | Interface to use |
| `count` | Number of packets to send |
| `inter` | Interval between packets (seconds) |
| `loop` | Loop sending |
| `verbose` | Verbose output |
| `real_time` | Respect inter in real time |

---

### sendp() - Send packets at Layer 2

```python
from scapy.sendrecv import sendp

# Send Ethernet frame
sendp(Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1"))
```

Same parameters as `send()`.

---

### sr() - Send and receive (multiple packets)

```python
from scapy.sendrecv import sr

# Send ARP request to all hosts in network
answer, unanswered = sr(
    Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.0/24"),
    timeout=2,
    verbose=False
)

for sent, received in answer:
    print(received[ARP].psrc, received[ARP].hwsrc)
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `x` | Packet(s) to send |
| `retry` | Number of retries |
| `timeout` | Timeout in seconds |
| `iface` | Interface to use |
| `verbose` | Verbose output |
| `filter` | BPF filter for responses |

---

### sr1() - Send and receive first response

```python
from scapy.sendrecv import sr1

# Send and wait for single response
reply = sr1(IP(dst="8.8.8.8") / ICMP(), timeout=3)

if reply:
    print(reply.summary())
else:
    print("No response")
```

---

### srp() - Send and receive at Layer 2

```python
from scapy.sendrecv import srp

# ARP scan
answer, unanswered = srp(
    Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.0/24"),
    timeout=2,
    verbose=False
)
```

---

### srloop() - Send and receive in loop

```python
from scapy.sendrecv import srloop

# Continuous ping
srloop(IP(dst="8.8.8.8") / ICMP(), inter=1)
```

---

## 4. Packet Inspection

### show() - Display packet details

```python
packet = IP(dst="8.8.8.8") / ICMP()
packet.show()
```

**Output:**
```
###[ IP ]###
  version   = 4
  ihl       = None
  tos       = 0x0
  len       = None
  id        = 1
  flags     =
  frag      = 0
  ttl       = 64
  proto     = icmp
  chksum    = None
  src       = 0.0.0.0
  dst       = 8.8.8.8
  \options   \
###[ ICMP ]###
     type     = echo-request
     code     = 0
     chksum   = None
     id       = 0x0
     seq      = 0x0
```

---

### show2() - Display with calculated fields

```python
packet = IP(dst="8.8.8.8") / ICMP()
packet.show2()  # Shows checksums, lengths calculated
```

---

### summary() - One-line summary

```python
print(packet.summary())
# Output: IP / ICMP 0.0.0.0 > 8.8.8.8 echo-request 0
```

---

### hexdump() - Hexadecimal dump

```python
from scapy.utils import hexdump

hexdump(packet)
```

**Output:**
```
0000  45 00 00 1C 00 01 00 00  40 01 9B 6F 00 00 00 00  E.......@..o....
0010  08 08 08 08 08 00 F7 FF  00 00 00 00              ............
```

---

### raw() - Get raw bytes

```python
raw_bytes = bytes(packet)  # or raw(packet)
```

---

### sprintf() - Custom formatting

```python
# Format string syntax: %layer.field%
print(packet.sprintf("%IP.src% -> %IP.dst%"))
# Output: 0.0.0.0 -> 8.8.8.8

print(packet.sprintf("%TCP.sport%:%TCP.dport%"))
# Output: 20:80 (if TCP layer exists)
```

---

### command() - Generate reconstruction code

```python
print(packet.command())
# Output: IP(dst='8.8.8.8')/ICMP()
```

---

## 5. PCAP Operations

### rdpcap() - Read PCAP file

```python
from scapy.utils import rdpcap

# Load entire PCAP
packets = rdpcap("capture.pcap")
print(f"Loaded {len(packets)} packets")

# Access packets
first_packet = packets[0]
last_packet = packets[-1]
```

---

### wrpcap() - Write PCAP file

```python
from scapy.utils import wrpcap

# Write packets
wrpcap("output.pcap", packets)

# Write single packet
wrpcap("output.pcap", [packet])
```

---

### PcapReader - Memory-efficient reading

```python
from scapy.utils import PcapReader

# Stream packets (memory efficient)
with PcapReader("large_file.pcap") as reader:
    for packet in reader:
        process(packet)
```

---

### PcapWriter - Efficient writing

```python
from scapy.utils import PcapWriter

with PcapWriter("output.pcap", append=True) as writer:
    for packet in packets:
        writer.write(packet)
```

---

### rdpcap() vs PcapReader Comparison

| Feature | rdpcap() | PcapReader |
|---------|----------|------------|
| Memory usage | High (loads all) | Low (streams) |
| Speed | Fast | Slower |
| Random access | Yes | No |
| Suitable for | Small PCAPs | Large PCAPs |

---

## 6. Sniffing

### sniff() - Capture packets

```python
from scapy.sendrecv import sniff

# Basic capture
packets = sniff(count=10)

# With filter
packets = sniff(filter="tcp port 80", count=10)

# With callback
def process_packet(packet):
    print(packet.summary())

sniff(prn=process_packet, count=10)

# Save to PCAP
packets = sniff(count=100)
wrpcap("capture.pcap", packets)

# Timeout
packets = sniff(timeout=10)  # Capture for 10 seconds
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `iface` | Interface to sniff on |
| `count` | Number of packets to capture |
| `prn` | Callback function for each packet |
| `filter` | BPF filter |
| `timeout` | Stop after N seconds |
| `store` | Store packets in memory |
| `promisc` | Promiscuous mode |
| `offline` | Read from PCAP file |

---

### BPF Filter Examples

```python
# Protocol filters
sniff(filter="tcp")           # TCP packets
sniff(filter="udp")           # UDP packets
sniff(filter="icmp")          # ICMP packets
sniff(filter="arp")           # ARP packets
sniff(filter="ip")            # IPv4 packets

# Port filters
sniff(filter="tcp port 80")   # HTTP
sniff(filter="udp port 53")   # DNS
sniff(filter="port 443")      # TCP or UDP port 443

# IP filters
sniff(filter="host 8.8.8.8")  # Traffic to/from IP
sniff(filter="src host 192.168.1.100")  # From source
sniff(filter="dst host 192.168.1.100")  # To destination

# Network filters
sniff(filter="net 192.168.0.0/16")  # Traffic to/from network

# TCP flag filters
sniff(filter="tcp[13] & 0x02 != 0")  # SYN packets
sniff(filter="tcp[13] & 0x10 != 0")  # ACK packets
sniff(filter="tcp[13] & 0x12 != 0")  # SYN-ACK packets

# Combined filters
sniff(filter="tcp port 80 and host 192.168.1.100")
sniff(filter="(tcp or udp) and port 53")
sniff(filter="not arp and not icmp")

# Size filters
sniff(filter="greater 1000")  # Packets > 1000 bytes
sniff(filter="less 64")       # Packets < 64 bytes

# MAC filters
sniff(filter="ether dst ff:ff:ff:ff:ff:ff")  # Broadcast
sniff(filter="ether multicast")               # Multicast
```

---

## 7. ARP Operations

### Basic ARP

```python
# ARP Request
request = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1")
reply = srp1(request, timeout=3)

if reply:
    print(f"MAC: {reply[ARP].hwsrc}")

# ARP Reply
reply = Ether(dst="00:11:22:33:44:55") / ARP(
    op=2,
    hwsrc="aa:bb:cc:dd:ee:ff",
    psrc="192.168.1.1",
    hwdst="00:11:22:33:44:55",
    pdst="192.168.1.100"
)
sendp(reply)

# ARP Scan
answer, unanswered = srp(
    Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.0/24"),
    timeout=2,
    verbose=False
)

for sent, received in answer:
    print(f"{received[ARP].psrc} -> {received[ARP].hwsrc}")
```

---

## 8. IP Operations

### IP Packet Construction

```python
# Basic IP
ip = IP(dst="8.8.8.8")

# With all fields
ip = IP(
    src="192.168.1.100",
    dst="8.8.8.8",
    ttl=128,
    id=12345,
    flags=2,  # DF flag
    tos=0x10  # Low delay
)

# IP with options
from scapy.layers.inet import IPOption_Timestamp
ip = IP(dst="8.8.8.8")
ip.options = [IPOption_Timestamp(flags=1, addr_list=["8.8.8.8"])]
```

### IP Fragmentation

```python
# Create large packet
packet = IP(dst="8.8.8.8") / ICMP() / Raw(b"X" * 2000)

# Fragment
fragments = packet.fragment()
print(f"Created {len(fragments)} fragments")

# Defragment
reassembled = IP(fragments)
print(f"Reassembled length: {len(reassembled)}")

# Send fragments
for frag in fragments:
    send(frag)
```

---

## 9. TCP Operations

### TCP Flags

```python
# Individual flags
TCP(flags="S")    # SYN
TCP(flags="A")    # ACK
TCP(flags="F")    # FIN
TCP(flags="R")    # RST

# Combined flags
TCP(flags="SA")   # SYN-ACK
TCP(flags="FA")   # FIN-ACK
TCP(flags="PA")   # PUSH-ACK
TCP(flags="RA")   # RST-ACK

# Programmatic flags
from scapy.layers.inet import TCP
SYN = 0x02
ACK = 0x10
SYN_ACK = SYN | ACK

TCP(flags=SYN_ACK)
```

### TCP Handshake

```python
# SYN
syn = IP(dst="8.8.8.8") / TCP(dport=80, flags="S", seq=1000)

# Send and wait for SYN-ACK
syn_ack = sr1(syn, timeout=3)

if syn_ack and syn_ack.haslayer(TCP) and syn_ack[TCP].flags & 0x12:
    # SYN-ACK received
    ack = IP(dst="8.8.8.8") / TCP(
        dport=80,
        flags="A",
        seq=1001,
        ack=syn_ack[TCP].seq + 1
    )
    send(ack)
    print("Handshake complete")
```

---

## 10. UDP Operations

### UDP Packet Construction

```python
# Basic UDP
udp = IP(dst="8.8.8.8") / UDP(sport=12345, dport=53)

# With payload
udp = IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"DNS query data")

# DNS query
from scapy.layers.dns import DNS, DNSQR
dns = IP(dst="8.8.8.8") / UDP(dport=53) / DNS(qd=DNSQR(qname="example.com"))

# Send UDP
send(IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"Test"))
```

---

## 11. ICMP Operations

### ICMP Echo

```python
# Ping request
ping = IP(dst="8.8.8.8") / ICMP(type=8, code=0, id=12345, seq=1)
reply = sr1(ping, timeout=3)

if reply and reply.haslayer(ICMP) and reply[ICMP].type == 0:
    print("Ping response received")

# Traceroute (ICMP)
for ttl in range(1, 31):
    packet = IP(dst="8.8.8.8", ttl=ttl) / ICMP()
    reply = sr1(packet, timeout=2, verbose=False)
    
    if reply:
        print(f"TTL {ttl}: {reply[IP].src}")
        if reply[IP].src == "8.8.8.8":
            break
```

---

## 12. Ethernet Operations

### Ethernet Frame Construction

```python
# Basic Ethernet
eth = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff")

# With IP payload
eth = Ether() / IP(dst="8.8.8.8") / ICMP()

# Broadcast
eth = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst="192.168.1.1")

# Multicast
eth = Ether(dst="01:00:5e:00:00:01") / IP(dst="224.0.0.1") / ICMP()

# MAC type detection
def get_mac_type(mac):
    if mac == "ff:ff:ff:ff:ff:ff":
        return "Broadcast"
    elif int(mac.split(':')[0], 16) & 0x01:
        return "Multicast"
    else:
        return "Unicast"
```

---

## 13. VLAN Operations

### VLAN (802.1Q)

```python
from scapy.layers.l2 import Dot1Q

# Basic VLAN
vlan = Ether() / Dot1Q(vlan=100) / IP(dst="8.8.8.8") / ICMP()

# VLAN with priority
vlan = Ether() / Dot1Q(vlan=100, prio=5) / IP(dst="8.8.8.8")

# Q-in-Q (double VLAN)
qinq = Ether() / Dot1Q(vlan=100) / Dot1Q(vlan=200) / IP(dst="8.8.8.8")
```

| Field | Type | Description |
|-------|------|-------------|
| `vlan` | ShortField | VLAN ID (0-4095) |
| `prio` | BitField | Priority (0-7) |
| `cfi` | BitField | Canonical Format Indicator |

---

## 14. Field Types

### Common Field Types

| Field Type | Description | Example |
|------------|-------------|---------|
| `ByteField` | 1-byte integer | `ByteField("val", 0)` |
| `ShortField` | 2-byte integer | `ShortField("val", 0)` |
| `IntField` | 4-byte integer | `IntField("val", 0)` |
| `LongField` | 8-byte integer | `LongField("val", 0)` |
| `SignedByteField` | Signed 1-byte | `SignedByteField("val", 0)` |
| `SignedShortField` | Signed 2-byte | `SignedShortField("val", 0)` |
| `SignedIntField` | Signed 4-byte | `SignedIntField("val", 0)` |
| `BitField` | Bit field | `BitField("bits", 0, 4)` |
| `FlagsField` | Flags field | `FlagsField("flags", 0, 8, ["F1","F2"])` |
| `StrFixedLenField` | Fixed string | `StrFixedLenField("data", "", 10)` |
| `StrLenField` | Length-prefixed string | `StrLenField("data", "", length_from=...)` |
| `IPField` | IP address | `IPField("ip", "0.0.0.0")` |
| `MACField` | MAC address | `MACField("mac", "00:00:00:00:00:00")` |
| `FieldLenField` | Field length | `FieldLenField("len", None, length_of="data")` |

### Custom Field Example

```python
from scapy.fields import Field

class CustomField(Field):
    def __init__(self, name, default):
        Field.__init__(self, name, default, fmt="B")  # fmt: B=byte, H=short, I=int
    
    def i2m(self, pkt, val):
        """Convert internal value to machine value."""
        return val
    
    def m2i(self, pkt, val):
        """Convert machine value to internal value."""
        return val
    
    def addfield(self, pkt, s, val):
        """Add field to packet build."""
        return s + struct.pack(self.fmt, self.i2m(pkt, val))
    
    def getfield(self, pkt, s):
        """Extract field from packet."""
        val = struct.unpack(self.fmt, s[:1])[0]
        return s[1:], self.m2i(pkt, val)
```

---

## 15. Utility Functions

### get_if_list() - List interfaces

```python
from scapy.arch import get_if_list

interfaces = get_if_list()
print(interfaces)
# Output: ['lo', 'eth0', 'wlan0']
```

---

### get_if_hwaddr() - Get MAC address

```python
from scapy.arch import get_if_hwaddr

mac = get_if_hwaddr("eth0")
print(mac)
# Output: 00:11:22:33:44:55
```

---

### get_if_addr() - Get IP address

```python
from scapy.arch import get_if_addr

ip = get_if_addr("eth0")
print(ip)
# Output: 192.168.1.100
```

---

### conf - Configuration

```python
from scapy.config import conf

# Set default interface
conf.iface = "eth0"

# Verbose mode
conf.verbose = False

# Check for IPv6
conf.ipv6_enabled = False

# Sniffing options
conf.sniff_promisc = True
conf.sniff_filter = "tcp"

# L3 socket
conf.L3socket = L3RawSocket
```

---

### RandMAC() - Random MAC address

```python
from scapy.all import RandMAC

mac = RandMAC()
print(mac)
# Output: 00:11:22:33:44:55
```

---

### RandIP() - Random IP address

```python
from scapy.all import RandIP

ip = RandIP()
print(ip)
# Output: 192.168.1.100
```

---

### RandShort() - Random short

```python
from scapy.all import RandShort

port = RandShort()
print(port)
# Output: 12345
```

---

### RandInt() - Random integer

```python
from scapy.all import RandInt

seq = RandInt()
print(seq)
# Output: 1234567890
```

---

## 16. Configuration

### conf - Global Configuration Object

```python
from scapy.config import conf

# Interface
conf.iface = "eth0"
conf.iface = "lo"  # Loopback

# Verbose
conf.verbose = True  # Show progress
conf.verbose = False # Silent mode

# IPv6
conf.ipv6_enabled = True
conf.ipv6_enabled = False

# Promiscuous mode
conf.sniff_promisc = True
conf.sniff_promisc = False

# BPF filter
conf.sniff_filter = "tcp port 80"

# L3 socket
from scapy.layers.inet import L3RawSocket
conf.L3socket = L3RawSocket

# L2 socket
from scapy.layers.l2 import L2RawSocket
conf.L2socket = L2RawSocket

# Debug
conf.debug_dissector = True
conf.debug_match = True

# Timeouts
conf.timeout = 10  # Default timeout in seconds

# Check for updates
conf.checkIPID = True

# Use pcap (if available)
conf.use_pcap = True
```

---

### Default Values

```python
# Default ports
conf.tcp_sport = 20
conf.tcp_dport = 80
conf.udp_sport = 53
conf.udp_dport = 53

# Default TTL
conf.ip_ttl = 64

# Default interface
conf.iface = None  # Automatically detected
```

---

## 17. Common Exceptions

### ImportError

```python
try:
    from scapy.all import *
except ImportError:
    print("Scapy not installed")
    print("Run: pip install scapy[complete]")
    sys.exit(1)
```

---

### PermissionError

```python
try:
    send(packet)
except PermissionError:
    print("Permission denied. Try running with sudo.")
```

---

### ValueError

```python
try:
    ip = IP(src="invalid", dst="8.8.8.8")
except ValueError as e:
    print(f"Invalid IP: {e}")
```

---

### TypeError

```python
try:
    packet[TCP].flags = "invalid"
except TypeError as e:
    print(f"Invalid flags: {e}")
```

---

### AttributeError

```python
try:
    tcp = packet[TCP]
except AttributeError:
    print("Packet has no TCP layer")
```

---

### Exception Handling Pattern

```python
def safe_send(packet):
    try:
        send(packet)
        return True
    except PermissionError:
        print("Permission denied")
    except ValueError as e:
        print(f"Invalid packet: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    return False
```

---

## Appendix A Complete

This appendix provides a comprehensive reference for Scapy's API. For more details, refer to:

- **Official Scapy Documentation:** [https://scapy.readthedocs.io/](https://scapy.readthedocs.io/)
- **Scapy GitHub Repository:** [https://github.com/secdev/scapy](https://github.com/secdev/scapy)
- **Scapy Tutorial:** [https://scapy.readthedocs.io/en/latest/usage.html](https://scapy.readthedocs.io/en/latest/usage.html)

---

```
─────────────────────────────────────────────────────────────────────────
│  APPENDIX A: SCAPY API REFERENCE COMPLETE                          │
│                                                                     │
│  This appendix covers:                                             │
│  ✅ Core packet classes                                            │
│  ✅ Packet construction                                            │
│  ✅ Send/receive functions                                         │
│  ✅ Packet inspection                                              │
│  ✅ PCAP operations                                                │
│  ✅ Sniffing                                                       │
│  ✅ Protocol-specific operations                                   │
│  ✅ Field types                                                    │
│  ✅ Utility functions                                              │
│  ✅ Configuration                                                  │
│  ✅ Exceptions                                                     │
│                                                                     │
│  Next: Appendix B — BPF Filter Reference                          │
└─────────────────────────────────────────────────────────────────────────
```
