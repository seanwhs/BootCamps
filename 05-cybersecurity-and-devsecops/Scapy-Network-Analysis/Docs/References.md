# Mastering Network Packet Crafting with Scapy
## References and Resources

## Overview

This document provides a comprehensive collection of references, resources, and further learning materials for the **Mastering Network Packet Crafting with Scapy** series. Use this as your ongoing reference guide for continued learning and professional development.

---

## Table of Contents

1. [Official Scapy Resources](#official-scapy-resources)
2. [Core Documentation](#core-documentation)
3. [Community and Support](#community-and-support)
4. [Learning Resources](#learning-resources)
5. [PCAP Repositories](#pcap-repositories)
6. [Related Tools and Libraries](#related-tools-and-libraries)
7. [Network Protocol References](#network-protocol-references)
8. [Security and Ethics Resources](#security-and-ethics-resources)
9. [Certifications and Career Paths](#certifications-and-career-paths)
10. [Python for Networking](#python-for-networking)

---

## Official Scapy Resources

### Primary Sources

| Resource | URL | Description |
|----------|-----|-------------|
| **Scapy Website** | [scapy.net](https://scapy.net/) | Official project homepage |
| **GitHub Repository** | [github.com/secdev/scapy](https://github.com/secdev/scapy) | Source code and issue tracking |
| **Official Documentation** | [scapy.readthedocs.io](https://scapy.readthedocs.io/) | Comprehensive API and user guides |
| **PyPI Package** | [pypi.org/project/scapy](https://pypi.org/project/scapy/) | Package distribution page |

### Key Documentation Sections

| Section | URL | Content |
|---------|-----|---------|
| **Getting Started** | [scapy.readthedocs.io/en/latest/introduction.html](https://scapy.readthedocs.io/en/latest/introduction.html) | Installation and first steps |
| **Interactive Tutorial** | [scapy.readthedocs.io/en/latest/usage.html](https://scapy.readthedocs.io/en/latest/usage.html) | Command-line usage |
| **Building Packets** | [scapy.readthedocs.io/en/latest/usage.html#building-packets](https://scapy.readthedocs.io/en/latest/usage.html#building-packets) | Packet construction guide |
| **Sending/Receiving** | [scapy.readthedocs.io/en/latest/usage.html#sending-packets](https://scapy.readthedocs.io/en/latest/usage.html#sending-packets) | Send/receive functions |
| **Sniffing** | [scapy.readthedocs.io/en/latest/usage.html#sniffing](https://scapy.readthedocs.io/en/latest/usage.html#sniffing) | Packet capture |
| **Custom Layers** | [scapy.readthedocs.io/en/latest/usage.html#adding-protocols](https://scapy.readthedocs.io/en/latest/usage.html#adding-protocols) | Protocol development |
| **API Reference** | [scapy.readthedocs.io/en/latest/api/index.html](https://scapy.readthedocs.io/en/latest/api/index.html) | Complete API documentation |
| **Examples** | [scapy.readthedocs.io/en/latest/usage.html#examples](https://scapy.readthedocs.io/en/latest/usage.html#examples) | Example scripts and use cases |

### Scapy Command Reference

**Basic Commands:**
- `ls()` - Lists supported protocol layers 
- `lsc()` - Lists Scapy's main user commands 
- `conf` - Configuration object 
- `help()` - Built-in help

**Interactive Shell Features:**
- Tab completion for commands and fields
- Python interpreter integration
- Session saving/restoring

**Configuration Files:**
- `$HOME/.config/scapy/prestart.py` - Run before Scapy core loads 
- `$HOME/.config/scapy/startup.py` - Run after Scapy is loaded 

---

## Core Documentation

### Packet Construction Reference

| Topic | Description | Example |
|-------|-------------|---------|
| **Layer Stacking** | `/` operator for encapsulation | `Ether() / IP() / TCP()` |
| **Field Access** | Access layers and fields | `packet[IP].src` |
| **Layer Detection** | Check for layer presence | `packet.haslayer(TCP)` |
| **Packet Display** | Inspect packet structure | `packet.show()`, `packet.show2()` |
| **Packet Summaries** | Quick overview | `packet.summary()` |
| **Hex Dump** | Raw bytes display | `hexdump(packet)` |

### Send/Receive Functions

| Function | Layer | Description |
|----------|-------|-------------|
| `send()` | Layer 3 | Send packets without waiting  |
| `sendp()` | Layer 2 | Send packets at Ethernet level  |
| `sr()` | Layer 3 | Send and receive responses  |
| `srp()` | Layer 2 | Send and receive at Ethernet level  |
| `sr1()` | Layer 3 | Send and receive first response |
| `srloop()` | Layer 3 | Continuous send/receive loop |

### Key Protocol Layers

| Protocol | Class | Fields |
|----------|-------|--------|
| Ethernet | `Ether()` | src, dst, type |
| IP | `IP()` | src, dst, ttl, proto, flags |
| TCP | `TCP()` | sport, dport, flags, seq, ack |
| UDP | `UDP()` | sport, dport, len |
| ICMP | `ICMP()` | type, code, id, seq |
| ARP | `ARP()` | op, psrc, pdst, hwsrc, hwdst |
| DNS | `DNS()` | qr, qd, an, ns, ar |
| DHCP | `DHCP()` | options |

### BPF Filter Reference 

| Filter Type | Syntax | Example |
|-------------|--------|---------|
| Protocol | `<protocol>` | `tcp`, `udp`, `icmp` |
| Port | `port <number>` | `port 80` |
| Host | `host <ip>` | `host 192.168.1.1` |
| Network | `net <network>` | `net 192.168.0.0/24` |
| Source/Dest | `src`/`dst` | `src host 8.8.8.8` |
| TCP Flags | `tcp[tcpflags]` | `tcp[tcpflags] & tcp-syn != 0`  |

---

## Community and Support

### Official Channels

| Channel | URL | Purpose |
|---------|-----|---------|
| **Mailing List** | [groups.google.com/g/scapy](https://groups.google.com/g/scapy) | Discussion and support |
| **GitHub Issues** | [github.com/secdev/scapy/issues](https://github.com/secdev/scapy/issues) | Bug reports and feature requests |
| **Gitter** | [gitter.im/secdev/scapy](https://gitter.im/secdev/scapy) | Real-time chat  |
| **Stack Overflow** | [stackoverflow.com/questions/tagged/scapy](https://stackoverflow.com/questions/tagged/scapy) | Q&A community |

### Community Resources

| Resource | Description |
|----------|-------------|
| **Awesome Scapy** | Curated list of Scapy projects |
| **Packet Samples** | Upload and share packet samples |
| **Regression Tests** | Protocol testing suite |
| **Contributing Guide** | How to contribute to Scapy |

### Contributing to Scapy

**How to Contribute:**
1. Found a bug? Add a ticket to the issue tracker 
2. Improve documentation
3. Program a new protocol layer and share on the mailing list 
4. Contribute regression tests 
5. Upload packet samples for new protocols 

**Development Resources:**
- Project organization and management
- Mercurial version control
- Trac project management

---

## Learning Resources

### Official Tutorials

| Resource | URL | Content |
|----------|-----|---------|
| **Scapy in 20 Minutes** | [scapy.readthedocs.io/en/latest/introduction.html](https://scapy.readthedocs.io/en/latest/introduction.html) | Quick introduction |
| **Interactive Tutorial** | [scapy.readthedocs.io/en/latest/usage.html](https://scapy.readthedocs.io/en/latest/usage.html) | Step-by-step guide |
| **Quick Demo** | [scapy.readthedocs.io/en/latest/introduction.html#quick-demo](https://scapy.readthedocs.io/en/latest/introduction.html#quick-demo) | Interactive session examples |

### Online Courses and Articles

| Resource | Description |
|----------|-------------|
| **freeCodeCamp Article** | "How to Use Scapy – Python Networking Tool Explained"  |
| **ECSC Interview** | In-depth Scapy library interview  |
| **ScanSearch Guide** | "Scapy Guide: Python Packet Manipulation & Network Analysis"  |
| **Firefox Add-on** | Scapy Ref - 85+ commands quick reference  |

### Code Examples

**Basic Packet Creation:**
```python
from scapy.all import IP, ICMP, sr1

# Create IP packet with TCP layer
packet = IP() / TCP()
packet[TCP].sport = 12345
packet.dport = 54321
packet.show()
```


**Packet Stacking:**
```python
from scapy.all import Ether, IP, ARP, ICMP, DNS

# Create an Ethernet frame with a broadcast destination address
ether = Ether(dst="ff:ff:ff:ff:ff:ff")

# Create an ARP request packet to resolve MAC of 192.168.1.1
arp = ARP(pdst="192.168.1.1")

# Create a basic ICMP packet
icmp = ICMP()

# Create a DNS query packet for "example.com"
dns = DNS(rd=1, qd=DNSQR(qname="example.com"))
```


**SYN Scanner Example:**
```python
def syn_scan(target_ip, port):
    syn_packet = IP(dst=target_ip) / TCP(dport=port, flags="S")
    response = sr1(syn_packet, timeout=2, verbose=0)
    
    if response:
        if response.haslayer(TCP) and response.getlayer(TCP).flags == 0x12:
            print(f"Port {port} is OPEN")
            send(IP(dst=target_ip) / TCP(dport=port, flags="R"), verbose=0)
        elif response.haslayer(TCP) and response.getlayer(TCP).flags == 0x14:
            print(f"Port {port} is CLOSED")
    else:
        print(f"Port {port} is FILTERED")
```


**DNS Monitor:**
```python
def dns_monitor(pkt):
    if pkt.haslayer(DNSQR):
        print(f"DNS Query: {pkt[DNSQR].qname.decode()}")

sniff(filter="udp port 53", prn=dns_monitor, store=0)
```


---

## PCAP Repositories

### Official Sources

| Repository | URL | Description |
|------------|-----|-------------|
| **Wireshark Samples** | [wiki.wireshark.org/SampleCaptures](https://wiki.wireshark.org/SampleCaptures) | Official protocol captures |
| **The Ultimate PCAP** | [theultimatespcap.com](https://www.theultimatespcap.com/) | 80+ protocols in one file |
| **NETRESEC PCAPs** | [netresec.com/?page=PcapFiles](https://www.netresec.com/?page=PcapFiles) | Curated enterprise captures |
| **Malware Traffic** | [malware-traffic-analysis.net](https://www.malware-traffic-analysis.net/) | Security research captures |
| **ICS-pcap** | [github.com/automayt/ICS-pcap](https://github.com/automayt/ICS-pcap) | Industrial control captures |

### Protocol-Specific PCAPs

| Protocol | Best Source | Use Case |
|----------|-------------|----------|
| ARP | Wireshark Samples | Local discovery |
| DNS | Wireshark Samples | Domain resolution |
| HTTP | Wireshark Samples | Web traffic analysis |
| DHCP | Wireshark Samples | IP assignment |
| TCP | Wireshark Samples | Connection analysis |
| VLAN | Wireshark Samples | Network segmentation |
| Industrial | ICS-pcap | OT/SCADA analysis |
| Malware | Malware Traffic | Security research |

---

## Related Tools and Libraries

### Network Analysis Tools

| Tool | Purpose | Relationship to Scapy |
|------|---------|----------------------|
| **Wireshark** | Packet analysis GUI | Visual verification |
| **tshark/tcpdump** | Command-line capture | PCAP capture and filtering |
| **Nmap** | Network scanning | Complementary scanning tool |
| **Zeek (Bro)** | Network monitoring | Enterprise monitoring |
| **Tcpdump** | Packet capture | Lightweight capture |

### Python Libraries

| Library | Purpose | Use with Scapy |
|---------|---------|----------------|
| **netifaces** | Network interface info | Interface detection |
| **ipaddress** | IP address manipulation | Address handling |
| **socket** | Low-level networking | Socket operations |
| **asyncio** | Async I/O | Performance optimization |
| **threading** | Parallel processing | Multi-threaded scanning |
| **multiprocessing** | Process parallelism | High-performance processing |
| **pandas** | Data analysis | Traffic statistics |
| **matplotlib** | Visualization | Traffic charts |
| **cryptography** | Crypto operations | TLS/SSL analysis |

### Installation Dependencies 

**Optional Dependencies:**
- `py-crypto` / `py3-cryptography` - Encryption support
- `py-gnuplot` / `matplotlib` - Visualization
- `pyx` - Packet diagrams
- `tcpdump` - Packet capture
- `graphviz` - Graph visualization
- `ebtables` - Ethernet filtering
- `sox` - Audio processing

---

## Network Protocol References

### Protocol Standards (RFCs)

| Protocol | RFC | Description |
|----------|-----|-------------|
| **Ethernet** | IEEE 802.3 | Ethernet frames |
| **ARP** | RFC 826 | Address Resolution Protocol |
| **IPv4** | RFC 791 | Internet Protocol version 4 |
| **ICMP** | RFC 792 | Internet Control Message Protocol |
| **TCP** | RFC 793 | Transmission Control Protocol |
| **UDP** | RFC 768 | User Datagram Protocol |
| **DNS** | RFC 1035 | Domain Name System |
| **DHCP** | RFC 2131 | Dynamic Host Configuration Protocol |
| **HTTP** | RFC 2616 | Hypertext Transfer Protocol |
| **VLAN** | IEEE 802.1Q | VLAN tagging |

### Protocol Quick Reference

**TCP Flags:**
| Flag | Value | Meaning |
|------|-------|---------|
| SYN | 0x02 | Synchronize  |
| SA (SYN-ACK) | 0x12 | Synchronize-Acknowledgment  |
| ACK | 0x10 | Acknowledgment  |
| FIN | 0x01 | Finish  |
| RST | 0x04 | Reset  |
| PSH | 0x08 | Push  |

**ICMP Types:**
| Type | Meaning |
|------|---------|
| 0 | Echo Reply  |
| 3 | Destination Unreachable  |
| 8 | Echo Request  |
| 11 | Time Exceeded  |

**Common Ports:**
| Port | Service |
|------|---------|
| 20/21 | FTP |
| 22 | SSH |
| 23 | Telnet |
| 25 | SMTP |
| 53 | DNS |
| 80 | HTTP |
| 443 | HTTPS |

---

## Security and Ethics Resources

### Legal Frameworks

| Resource | Description |
|----------|-------------|
| **CFAA** (US) | Computer Fraud and Abuse Act |
| **Computer Misuse Act** (UK) | Unauthorized access law |
| **GDPR** (EU) | Data protection regulation |
| **Budapest Convention** | International cybercrime treaty |

### Professional Ethics

| Organization | Code of Ethics |
|--------------|----------------|
| **(ISC)²** | Information security ethics |
| **ISACA** | Professional ethics |
| **SANS** | Security ethics |
| **IACRB** | Ethical hacking certification |

### Responsible Disclosure

| Resource | Description |
|----------|-------------|
| **CERT/CC** | Vulnerability reporting |
| **OWASP** | Security guidelines |
| **Bug Bounty Platforms** | Authorized testing programs |

---

## Certifications and Career Paths

### Recommended Certifications

| Certification | Organization | Focus |
|---------------|--------------|-------|
| **CCNA** | Cisco | Networking fundamentals |
| **Network+** | CompTIA | Network concepts |
| **CEH** | EC-Council | Ethical hacking |
| **OSCP** | Offensive Security | Penetration testing |
| **GPEN** | GIAC | Network penetration testing |
| **CISSP** | (ISC)² | Information security management |

### Career Paths

| Role | Skills | Certifications |
|------|--------|----------------|
| **Penetration Tester** | Packet crafting, exploitation | OSCP, GPEN, CEH |
| **Network Security Engineer** | Network analysis, firewalls | CCNA Security, CISSP |
| **Security Researcher** | Protocol analysis, reverse engineering | OSCP, GREM |
| **SOC Analyst** | Traffic analysis, detection | Security+, CySA+ |
| **Network Engineer** | Network protocols, routing | CCNA, CCNP |

---

## Python for Networking

### Essential Python Libraries

| Library | Purpose | Documentation |
|---------|---------|---------------|
| **socket** | Low-level networking | docs.python.org |
| **ipaddress** | IP address handling | docs.python.org |
| **subprocess** | System commands | docs.python.org |
| **argparse** | CLI parsing | docs.python.org |
| **logging** | Debugging | docs.python.org |
| **threading** | Concurrency | docs.python.org |
| **queue** | Thread-safe queues | docs.python.org |
| **asyncio** | Async I/O | docs.python.org |

### Python Best Practices

**Code Organization:**
- Use virtual environments
- Follow PEP 8 style guide
- Write docstrings for functions
- Use type hints (Python 3.5+)
- Implement proper error handling

**Networking Specific:**
- Always use timeouts
- Implement rate limiting
- Log all activities
- Validate inputs
- Handle exceptions gracefully

---

## Quick Reference Card

### Scapy Most Used Commands

```python
# Import
from scapy.all import *

# Packet Construction
pkt = Ether() / IP(dst="8.8.8.8") / TCP(dport=80) / Raw(b"GET / HTTP/1.1\r\n\r\n")

# Packet Inspection
pkt.show()
pkt.summary()
pkt.haslayer(IP)
pkt[IP].src
pkt[TCP].dport

# Send/Receive
send(pkt)                          # Send at layer 3
sendp(pkt)                         # Send at layer 2
reply = sr1(pkt, timeout=3)        # Send and get first reply
answers, unans = sr(pkt)           # Send and get all replies

# Sniffing
packets = sniff(count=10)
sniff(filter="tcp", prn=lambda x: x.summary(), count=5)

# PCAP Operations
packets = rdpcap("capture.pcap")
wrpcap("output.pcap", packets)

# Custom Protocols
class MyProtocol(Packet):
    fields_desc = [ByteField("field", 0)]
bind_layers(IP, MyProtocol, proto=250)

# Field Access
pkt[Ether].src          # Source MAC
pkt[IP].dst             # Destination IP
pkt[TCP].flags          # TCP flags
pkt[DNS].qd.qname       # DNS query name 

# TCP Flags Values 
# S  = SYN (0x02)
# SA = SYN-ACK (0x12)
# A  = ACK (0x10)
# F  = FIN (0x01)
# R  = RST (0x04)
# P  = PSH (0x08)

# ICMP Types 
# 8 = Echo Request
# 0 = Echo Reply
# 3 = Destination Unreachable
# 11 = Time Exceeded
```

### References

**Scapy Documentation:** [scapy.readthedocs.io](https://scapy.readthedocs.io/)
**Official Website:** [scapy.net](https://scapy.net/)
**GitHub Repository:** [github.com/secdev/scapy](https://github.com/secdev/scapy)
**Community Support:** [gitter.im/secdev/scapy](https://gitter.im/secdev/scapy)

---

