# Mastering Network Packet Crafting with Scapy
## Primer 3: Network Protocol Fundamentals

## Overview

This primer provides a crash course in network protocol fundamentals essential for packet crafting with Scapy. If you're already comfortable with networking concepts, you can skip this section. If you need a refresher or are new to networking, this primer will get you up to speed quickly.

---

## Table of Contents

1. [Why Understand Protocols?](#why-understand-protocols)
2. [The OSI Model](#the-osi-model)
3. [The TCP/IP Model](#the-tcpip-model)
4. [Ethernet Fundamentals](#ethernet-fundamentals)
5. [IP Fundamentals](#ip-fundamentals)
6. [ARP Fundamentals](#arp-fundamentals)
7. [ICMP Fundamentals](#icmp-fundamentals)
8. [TCP Fundamentals](#tcp-fundamentals)
9. [UDP Fundamentals](#udp-fundamentals)
10. [Ports and Services](#ports-and-services)
11. [Packet Anatomy](#packet-anatomy)
12. [Common Protocol Interactions](#common-protocol-interactions)

---

## Why Understand Protocols?

Understanding network protocols is essential for packet crafting because:

- **You need to know what you're building**: Every packet is a protocol message
- **You need to know what you're analyzing**: You must recognize protocol patterns
- **You need to know where to look**: Protocols have specific fields and structures
- **You need to know why things work**: Understanding the "why" helps with troubleshooting

**Protocols are like languages**:
- Just as languages have grammar and vocabulary, protocols have fields and values
- Just as you need to understand a language to speak it, you need to understand protocols to craft packets
- Just as languages evolve, protocols have versions and extensions

---

## The OSI Model

### Overview

The OSI (Open Systems Interconnection) model is a conceptual framework that describes how network communication works. It divides networking into seven layers, each with specific responsibilities.

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 7: Application Layer (HTTP, DNS, DHCP, SMTP, FTP)       │
│   - User applications and services                             │
│   - Provides network services to applications                  │
├─────────────────────────────────────────────────────────────────┤
│ Layer 6: Presentation Layer (TLS/SSL, Encryption)             │
│   - Data formatting, encryption, compression                   │
│   - Translates data between application and network            │
├─────────────────────────────────────────────────────────────────┤
│ Layer 5: Session Layer (NetBIOS, RPC)                         │
│   - Session management, authentication, authorization          │
│   - Establishes and maintains connections                      │
├─────────────────────────────────────────────────────────────────┤
│ Layer 4: Transport Layer (TCP, UDP)                           │
│   - End-to-end communication, reliability, flow control        │
│   - Provides data transfer between applications                │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: Network Layer (IP, ICMP)                             │
│   - Logical addressing, routing, packet forwarding             │
│   - Moves data between networks                                │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: Data Link Layer (Ethernet, ARP)                      │
│   - Physical addressing, error detection, framing              │
│   - Moves data within a network segment                        │
├─────────────────────────────────────────────────────────────────┤
│ Layer 1: Physical Layer (Cables, Radio)                       │
│   - Physical transmission of bits                              │
│   - Converts data to electrical/optical signals                │
└─────────────────────────────────────────────────────────────────┘
```

---

### Encapsulation in the OSI Model

When data moves down the OSI model, each layer adds its own header:

```
Application Data (HTTP Request)
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Application Layer: HTTP Request Headers + Data                │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Presentation Layer: Encrypted/Formatted Data                  │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Session Layer: Session Management Data                        │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Transport Layer: TCP Header + Application Data                │
│        (TCP Segment)                                           │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Network Layer: IP Header + TCP Header + Application Data      │
│        (IP Packet)                                             │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Data Link Layer: Ethernet Header + IP Header + TCP Header +  │
│        Application Data + Ethernet Trailer                     │
│        (Ethernet Frame)                                        │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Physical Layer: Bits on the Wire                              │
└─────────────────────────────────────────────────────────────────┘
```

---

### OSI Layer Summary

| Layer | Name | Function | Key Protocols |
|-------|------|----------|---------------|
| 7 | Application | User interface and services | HTTP, DNS, DHCP, SMTP |
| 6 | Presentation | Data formatting and encryption | TLS/SSL, JPEG, MPEG |
| 5 | Session | Connection management | NetBIOS, RPC |
| 4 | Transport | End-to-end communication | TCP, UDP |
| 3 | Network | Routing and addressing | IP, ICMP |
| 2 | Data Link | Local network communication | Ethernet, ARP |
| 1 | Physical | Physical transmission | Cables, Radio |

---

## The TCP/IP Model

### Overview

The TCP/IP (Transmission Control Protocol/Internet Protocol) model is simpler than the OSI model and is the actual model used in practice. It has four layers:

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 4: Application Layer                                     │
│   - HTTP, DNS, DHCP, FTP, SMTP, SSH, TLS/SSL                  │
│   - Contains OSI Layers 5, 6, and 7                           │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: Transport Layer                                       │
│   - TCP (reliable, connection-oriented)                        │
│   - UDP (fast, connectionless)                                 │
│   - Equivalent to OSI Layer 4                                  │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: Internet Layer                                        │
│   - IP (addressing and routing)                                │
│   - ICMP (error reporting and diagnostics)                     │
│   - ARP (address resolution)                                   │
│   - Equivalent to OSI Layer 3                                  │
├─────────────────────────────────────────────────────────────────┤
│ Layer 1: Network Access Layer                                   │
│   - Ethernet (local network communication)                     │
│   - Physical transmission                                       │
│   - Equivalent to OSI Layers 1 and 2                           │
└─────────────────────────────────────────────────────────────────┘
```

### TCP/IP vs OSI Comparison

| TCP/IP Layer | OSI Layers | Function |
|--------------|------------|----------|
| Application | 7, 6, 5 | User applications and services |
| Transport | 4 | End-to-end communication |
| Internet | 3 | Routing and addressing |
| Network Access | 2, 1 | Local network and physical transmission |

---

## Ethernet Fundamentals

### Ethernet Frame Structure

An Ethernet frame is the basic unit of communication at the Data Link Layer:

```
┌─────────────────────────────────────────────────────────────────┐
│                       ETHERNET FRAME                           │
├──────────┬──────────┬──────────┬──────────────┬──────────────┤
│ Preamble │ Dest MAC │ Src MAC │ EtherType    │ Payload      │
│ 8 bytes  │ 6 bytes  │ 6 bytes │ 2 bytes      │ 46-1500 bytes│
├──────────┴──────────┴──────────┴──────────────┴──────────────┤
│                       Ethernet Frame                          │
└─────────────────────────────────────────────────────────────────┘
```

### MAC Addresses

MAC addresses are 48-bit (6-byte) hardware addresses:

```bash
# Format: 6 groups of 2 hexadecimal digits
00:11:22:33:44:55

# Breakdown
00:11:22  - OUI (Organizationally Unique Identifier) - identifies manufacturer
33:44:55  - NIC-specific identifier - unique to device
```

**MAC Address Types:**

| Type | Example | Description |
|------|---------|-------------|
| Unicast | 00:11:22:33:44:55 | Unique to one device |
| Multicast | 01:00:5E:00:00:01 | Group of devices |
| Broadcast | FF:FF:FF:FF:FF:FF | All devices on network |

### EtherTypes

EtherType values identify the protocol in the payload:

| Value | Protocol | Description |
|-------|----------|-------------|
| 0x0800 | IPv4 | Internet Protocol version 4 |
| 0x0806 | ARP | Address Resolution Protocol |
| 0x86DD | IPv6 | Internet Protocol version 6 |
| 0x8100 | VLAN | IEEE 802.1Q VLAN tagging |

---

## IP Fundamentals

### IPv4 Address Structure

An IPv4 address is 32 bits, typically written in dotted-decimal notation:

```bash
# Format: 4 octets separated by dots
192.168.1.100

# Binary representation
11000000.10101000.00000001.01100100
```

**Address Classes:**

| Class | First Octet | Range | Subnet Mask | Use |
|-------|-------------|-------|-------------|-----|
| A | 1-126 | 0.0.0.0 - 127.255.255.255 | /8 | Large networks |
| B | 128-191 | 128.0.0.0 - 191.255.255.255 | /16 | Medium networks |
| C | 192-223 | 192.0.0.0 - 223.255.255.255 | /24 | Small networks |
| D | 224-239 | 224.0.0.0 - 239.255.255.255 | - | Multicast |
| E | 240-255 | 240.0.0.0 - 255.255.255.255 | - | Experimental |

**Private IP Ranges:**

| Range | CIDR | Description |
|-------|------|-------------|
| 10.0.0.0 - 10.255.255.255 | /8 | Class A private |
| 172.16.0.0 - 172.31.255.255 | /12 | Class B private |
| 192.168.0.0 - 192.168.255.255 | /16 | Class C private |
| 169.254.0.0 - 169.254.255.255 | /16 | Link-local (APIPA) |

**Special IP Addresses:**

| Address | Description |
|---------|-------------|
| 0.0.0.0 | "Any" address (default route) |
| 127.0.0.1 | Loopback (localhost) |
| 255.255.255.255 | Limited broadcast |
| <network>.255 | Directed broadcast |

---

### IPv4 Header Structure

The IPv4 header is 20-60 bytes:

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
├─────────────────────────────────────────────────────────────────┤
│ Options (if any)                                              │
└─────────────────────────────────────────────────────────────────┘
```

**Key IPv4 Fields:**

| Field | Size | Description |
|-------|------|-------------|
| Version | 4 bits | IPv4 = 4 |
| IHL | 4 bits | Header length in 32-bit words (5-15) |
| ToS | 8 bits | Type of Service (QoS) |
| Total Length | 16 bits | Total packet length |
| Identification | 16 bits | Fragment identification |
| Flags | 3 bits | DF (Don't Fragment), MF (More Fragments) |
| Fragment Offset | 13 bits | Position in original packet |
| TTL | 8 bits | Time To Live (decremented at each hop) |
| Protocol | 8 bits | Transport protocol (TCP=6, UDP=17, ICMP=1) |
| Checksum | 16 bits | Header checksum |
| Source IP | 32 bits | Source address |
| Destination IP | 32 bits | Destination address |

---

### IPv4 Protocol Numbers

| Protocol Number | Protocol |
|-----------------|----------|
| 1 | ICMP |
| 2 | IGMP |
| 6 | TCP |
| 17 | UDP |
| 41 | IPv6 |
| 47 | GRE |
| 50 | ESP |
| 51 | AH |
| 88 | EIGRP |
| 89 | OSPF |

---

## ARP Fundamentals

### ARP Request

ARP (Address Resolution Protocol) maps IP addresses to MAC addresses:

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

### ARP Reply

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

### ARP Cache

```
# Example ARP cache
IP Address        MAC Address
192.168.1.1       AA:BB:CC:DD:EE:FF
192.168.1.2       11:22:33:44:55:66
192.168.1.3       77:88:99:AA:BB:CC
```

---

## ICMP Fundamentals

### ICMP Types and Codes

ICMP (Internet Control Message Protocol) is used for error reporting and diagnostics:

```
┌─────────────────────────────────────────────────────────────────┐
│                   ICMP HEADER                                  │
├──────────┬──────────┬─────────────────────────────────────────┤
│ Type     │ Code     │ Checksum                               │
│ 8 bits   │ 8 bits   │ 16 bits                                │
├──────────┴──────────┴─────────────────────────────────────────┤
│ Payload (depends on type)                                     │
└─────────────────────────────────────────────────────────────────┘
```

### Common ICMP Types

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Response to Echo Request (ping response) |
| 3 | Destination Unreachable | Network/host/protocol/port unreachable |
| 4 | Source Quench | Congestion control (deprecated) |
| 5 | Redirect | Route change notification |
| 8 | Echo Request | Ping request |
| 9 | Router Advertisement | Router discovery |
| 10 | Router Solicitation | Router discovery |
| 11 | Time Exceeded | TTL expired (traceroute) |
| 12 | Parameter Problem | Bad IP header |

### ICMP Type 3 - Destination Unreachable Codes

| Code | Name | Description |
|------|------|-------------|
| 0 | Net Unreachable | Network unreachable |
| 1 | Host Unreachable | Host unreachable |
| 2 | Protocol Unreachable | Protocol unreachable |
| 3 | Port Unreachable | Port unreachable (UDP) |
| 4 | Fragmentation Needed | Need fragmentation but DF set |
| 5 | Source Route Failed | Source route failed |

---

## TCP Fundamentals

### TCP Header Structure

The TCP header is 20-60 bytes:

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
| ACK | 0x10 | Acknowledgment | Acknowledgment valid |
| URG | 0x20 | Urgent | Urgent data present |
| ECE | 0x40 | ECN Echo | Congestion notification |
| CWR | 0x80 | Congestion Window Reduced | Congestion control |

### TCP Three-Way Handshake

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
    │         ESTABLISHED                │
```

### TCP Connection Termination

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
    │         CLOSED               │
```

---

## UDP Fundamentals

### UDP Header Structure

The UDP header is 8 bytes:

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

### UDP vs TCP Comparison

| Feature | TCP | UDP |
|---------|-----|-----|
| Connection | Connection-oriented | Connectionless |
| Reliability | Reliable (ACKs) | Unreliable (best effort) |
| Ordering | Ordered delivery | Unordered (may arrive out of order) |
| Flow Control | Yes | No |
| Congestion Control | Yes | No |
| Header Size | 20-60 bytes | 8 bytes |
| Speed | Slower | Faster |
| Use Cases | HTTP, SSH, FTP | DNS, DHCP, VoIP, gaming |

---

## Ports and Services

### Well-Known Ports (0-1023)

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 20 | TCP | FTP-Data | File Transfer Protocol data |
| 21 | TCP | FTP | File Transfer Protocol control |
| 22 | TCP | SSH | Secure Shell |
| 23 | TCP | Telnet | Remote terminal |
| 25 | TCP | SMTP | Simple Mail Transfer Protocol |
| 53 | TCP/UDP | DNS | Domain Name System |
| 67 | UDP | DHCP Server | Dynamic Host Configuration Protocol server |
| 68 | UDP | DHCP Client | Dynamic Host Configuration Protocol client |
| 69 | UDP | TFTP | Trivial File Transfer Protocol |
| 80 | TCP | HTTP | Hypertext Transfer Protocol |
| 110 | TCP | POP3 | Post Office Protocol version 3 |
| 123 | UDP | NTP | Network Time Protocol |
| 143 | TCP | IMAP | Internet Message Access Protocol |
| 161 | UDP | SNMP | Simple Network Management Protocol |
| 443 | TCP | HTTPS | HTTP over SSL/TLS |
| 465 | TCP | SMTPS | SMTP over SSL/TLS |
| 993 | TCP | IMAPS | IMAP over SSL/TLS |
| 995 | TCP | POP3S | POP3 over SSL/TLS |

### Registered Ports (1024-49151)

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 3306 | TCP | MySQL | MySQL database |
| 3389 | TCP | RDP | Remote Desktop Protocol |
| 5432 | TCP | PostgreSQL | PostgreSQL database |
| 5900 | TCP | VNC | Virtual Network Computing |
| 6379 | TCP | Redis | Redis database |
| 8080 | TCP | HTTP-Alt | Alternative HTTP port |

---

## Packet Anatomy

### Building a Packet in Scapy

```python
# Scapy builds packets from outside to inside
packet = Ether() / IP() / TCP() / Raw()

# This matches the encapsulation process:
# Ethernet Frame
#   └── IP Packet
#        └── TCP Segment
#             └── Application Data
```

### Packet Example: HTTP Request

```
Ethernet Frame:
  - Destination MAC: AA:BB:CC:DD:EE:FF
  - Source MAC: 00:11:22:33:44:55
  - EtherType: 0x0800 (IPv4)

IP Packet:
  - Source IP: 192.168.1.100
  - Destination IP: 10.0.0.1
  - TTL: 64
  - Protocol: 6 (TCP)

TCP Segment:
  - Source Port: 54321
  - Destination Port: 80 (HTTP)
  - Flags: PSH, ACK
  - Sequence: 1001
  - Acknowledgment: 2001
  - Window: 65535

Raw Data:
  - GET /index.html HTTP/1.1
  - Host: example.com
  - User-Agent: Scapy
```

### Protocol Stack in Scapy

```python
# The / operator stacks protocols
packet = Ether() / IP() / TCP() / Raw()

# Accessing layers
packet[IP].src       # Source IP
packet[TCP].dport    # Destination port

# Checking layers
if packet.haslayer(TCP):
    print("TCP layer present")

# Getting specific layer
tcp = packet.getlayer(TCP)
```

---

## Common Protocol Interactions

### DNS Query-Response

```
Client (192.168.1.100)          DNS Server (8.8.8.8)
    │                                    │
    │        1. DNS Query               │
    │        "What is example.com?"      │
    │        UDP: 54321 -> 53            │
    │        ───────────────────────────>│
    │                                    │
    │        2. DNS Response             │
    │        "example.com is 93.184.216.34"
    │        UDP: 53 -> 54321            │
    │        <───────────────────────────│
```

### DHCP DORA Sequence

```
Client (0.0.0.0)                DHCP Server (192.168.1.1)
    │                                    │
    │        1. DISCOVER                 │
    │        UDP: 68 -> 67               │
    │        Broadcast                   │
    │        ───────────────────────────>│
    │                                    │
    │        2. OFFER                    │
    │        UDP: 67 -> 68               │
    │        "Here's 192.168.1.100"      │
    │        <───────────────────────────│
    │                                    │
    │        3. REQUEST                  │
    │        UDP: 68 -> 67               │
    │        "I want 192.168.1.100"      │
    │        ───────────────────────────>│
    │                                    │
    │        4. ACKNOWLEDGE              │
    │        UDP: 67 -> 68               │
    │        "Confirmed 192.168.1.100"   │
    │        <───────────────────────────│
```

### HTTP Request-Response

```
Client (192.168.1.100)          Web Server (10.0.0.1)
    │                                    │
    │        1. TCP Handshake            │
    │        (SYN, SYN-ACK, ACK)         │
    │        ───────────────────────────>│
    │        <───────────────────────────│
    │                                    │
    │        2. HTTP Request             │
    │        "GET /index.html HTTP/1.1"  │
    │        TCP: 54321 -> 80            │
    │        ───────────────────────────>│
    │                                    │
    │        3. HTTP Response            │
    │        "200 OK"                    │
    │        TCP: 80 -> 54321            │
    │        <───────────────────────────│
    │                                    │
    │        4. TCP Teardown             │
    │        (FIN, ACK, FIN, ACK)        │
    │        ───────────────────────────>│
    │        <───────────────────────────│
```

---

## Primer Complete

This primer covers the essential network protocol fundamentals needed for the series. You should now be comfortable with:

- **The OSI and TCP/IP models** and their layers
- **Ethernet fundamentals** (frames, MAC addresses, EtherTypes)
- **IP fundamentals** (addressing, header structure)
- **ARP fundamentals** (request/reply, caching)
- **ICMP fundamentals** (types, codes, ping and traceroute)
- **TCP fundamentals** (header, flags, handshake, termination)
- **UDP fundamentals** (header, stateless communication)
- **Ports and services** (well-known, registered, dynamic)
- **Packet anatomy** (encapsulation, stacking)
- **Common protocol interactions** (DNS, DHCP, HTTP)

---

```
─────────────────────────────────────────────────────────────────────────
│  PRIMER: NETWORK PROTOCOL FUNDAMENTALS COMPLETE                     │
│                                                                     │
│  This primer covers:                                               │
│  ✅ OSI model                                                      │
│  ✅ TCP/IP model                                                   │
│  ✅ Ethernet fundamentals                                           │
│  ✅ IP fundamentals                                                 │
│  ✅ ARP fundamentals                                                │
│  ✅ ICMP fundamentals                                               │
│  ✅ TCP fundamentals                                                │
│  ✅ UDP fundamentals                                                │
│  ✅ Ports and services                                              │
│  ✅ Packet anatomy                                                  │
│  ✅ Common protocol interactions                                    │
│                                                                     │
│  You are now ready to begin the series!                           │
└─────────────────────────────────────────────────────────────────────────
```

---

**Return to the series introduction** when you're ready, or proceed directly to **Module 1: Foundations of Packet Crafting**.
