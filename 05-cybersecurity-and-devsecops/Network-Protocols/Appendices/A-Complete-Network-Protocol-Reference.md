# Appendix A: Complete Network Protocol Reference

## Comprehensive Reference Guide to All Protocols Covered in the Series

---

## Overview

This appendix serves as a complete reference for all network protocols covered throughout the series. It consolidates protocol structures, field definitions, standard values, and operational details into a single, easy-to-navigate resource.

**Purpose**: Quick lookup for protocol details during implementation, troubleshooting, or study.

**Organization**: Protocols are organized by OSI/TCP/IP layer, mirroring the series structure.

---

## Table of Contents

1. [Physical Layer Standards](#1-physical-layer-standards)
2. [Data Link Layer Protocols](#2-data-link-layer-protocols)
3. [Network Layer Protocols](#3-network-layer-protocols)
4. [Transport Layer Protocols](#4-transport-layer-protocols)
5. [Application Layer Protocols](#5-application-layer-protocols)
6. [Security Protocols](#6-security-protocols)
7. [Modern Protocols](#7-modern-protocols)
8. [IANA Port Numbers](#8-iana-port-numbers)
9. [EtherType Values](#9-ethertype-values)
10. [Protocol Constants](#10-protocol-constants)

---

## 1. Physical Layer Standards

### Ethernet Cable Standards

| Standard | Cable Type | Max Speed | Max Distance | Connector | Year |
|----------|-----------|-----------|--------------|-----------|------|
| 10BASE-T | Cat3/4/5 | 10 Mbps | 100m | RJ45 | 1990 |
| 100BASE-TX | Cat5 | 100 Mbps | 100m | RJ45 | 1995 |
| 1000BASE-T | Cat5e | 1 Gbps | 100m | RJ45 | 1999 |
| 10GBASE-T | Cat6/6a | 10 Gbps | 55m/100m | RJ45 | 2006 |
| 25GBASE-T | Cat8 | 25 Gbps | 30m | RJ45 | 2016 |
| 40GBASE-T | Cat8 | 40 Gbps | 30m | RJ45 | 2016 |

### Fiber Optic Standards

| Standard | Fiber Type | Max Speed | Max Distance | Connector |
|----------|-----------|-----------|--------------|-----------|
| 100BASE-FX | Multi-mode | 100 Mbps | 2km | SC/ST |
| 1000BASE-SX | Multi-mode | 1 Gbps | 220-550m | SC/LC |
| 1000BASE-LX | Single-mode | 1 Gbps | 5km | SC/LC |
| 10GBASE-SR | Multi-mode | 10 Gbps | 26-300m | SC/LC |
| 10GBASE-LR | Single-mode | 10 Gbps | 10km | SC/LC |
| 10GBASE-ER | Single-mode | 10 Gbps | 40km | SC/LC |
| 40GBASE-SR4 | Multi-mode | 40 Gbps | 100-150m | MPO |
| 40GBASE-LR4 | Single-mode | 40 Gbps | 10km | SC/LC |

### WiFi Standards (IEEE 802.11)

| Standard | Band | Max Speed | MIMO | Year |
|----------|------|-----------|------|------|
| 802.11a | 5 GHz | 54 Mbps | No | 1999 |
| 802.11b | 2.4 GHz | 11 Mbps | No | 1999 |
| 802.11g | 2.4 GHz | 54 Mbps | No | 2003 |
| 802.11n (Wi-Fi 4) | 2.4/5 GHz | 600 Mbps | 4x4 | 2009 |
| 802.11ac (Wi-Fi 5) | 5 GHz | 3.5 Gbps | 8x8 | 2013 |
| 802.11ax (Wi-Fi 6) | 2.4/5/6 GHz | 9.6 Gbps | 8x8 | 2019 |

---

## 2. Data Link Layer Protocols

### Ethernet II Frame Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     ETHERNET II FRAME                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Offset 0-7:    Preamble (7 bytes)                            │
│                  = 10101010 repeated 7 times                   │
│                                                                 │
│   Offset 7:      SFD (1 byte)                                  │
│                  = 10101011                                     │
│                                                                 │
│   Offset 8-13:   Destination MAC Address (6 bytes)             │
│                  = e.g., 01:23:45:67:89:AB                    │
│                                                                 │
│   Offset 14-19:  Source MAC Address (6 bytes)                  │
│                  = e.g., CD:EF:01:23:45:67                    │
│                                                                 │
│   Offset 20-21:  EtherType/Length (2 bytes)                    │
│                  >= 0x0600: EtherType                          │
│                  < 0x0600: Frame Length                        │
│                                                                 │
│   Offset 22-...: Payload (46-1500 bytes)                       │
│                  = Encapsulated data                           │
│                                                                 │
│   Last 4 bytes: FCS (Frame Check Sequence)                     │
│                  = CRC-32 checksum                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### IEEE 802.1Q VLAN Frame

```
┌─────────────────────────────────────────────────────────────────┐
│                   IEEE 802.1Q VLAN FRAME                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Ethernet Header:                                              │
│   ├─ Destination MAC (6 bytes)                                 │
│   ├─ Source MAC (6 bytes)                                      │
│   └─ EtherType = 0x8100 (2 bytes) - VLAN tag indicator        │
│                                                                 │
│   VLAN Tag (4 bytes):                                          │
│   ├─ Priority Code Point (3 bits) - QoS priority              │
│   ├─ Drop Eligible Indicator (1 bit)                          │
│   └─ VLAN ID (12 bits) - 0-4095 (0 and 4095 reserved)        │
│                                                                 │
│   EtherType (2 bytes) - Actual protocol type                  │
│                                                                 │
│   Payload (46-1500 bytes)                                      │
│                                                                 │
│   FCS (4 bytes)                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### ARP Packet Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     ARP PACKET (RFC 826)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-15 bits:  Hardware Type (HTYPE)                             │
│              = 1 for Ethernet                                   │
│                                                                 │
│  16-31 bits: Protocol Type (PTYPE)                             │
│              = 0x0800 for IPv4                                 │
│                                                                 │
│  32-39 bits: Hardware Address Length (HLEN)                    │
│              = 6 for Ethernet MAC addresses                    │
│                                                                 │
│  40-47 bits: Protocol Address Length (PLEN)                    │
│              = 4 for IPv4 addresses                            │
│                                                                 │
│  48-63 bits: Operation (OPER)                                  │
│              = 1: Request, 2: Reply                           │
│                                                                 │
│  64-111 bits: Sender Hardware Address (SHA)                    │
│               = Source MAC address                             │
│                                                                 │
│  112-143 bits: Sender Protocol Address (SPA)                   │
│                = Source IP address                             │
│                                                                 │
│  144-191 bits: Target Hardware Address (THA)                   │
│                = Target MAC address (0 for request)            │
│                                                                 │
│  192-223 bits: Target Protocol Address (TPA)                   │
│                = Target IP address                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### DHCP Message Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     DHCP MESSAGE (RFC 2131)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-7 bits:   op (Operation Code)                               │
│              = 1: Request, 2: Reply                           │
│                                                                 │
│  8-15 bits:  htype (Hardware Type)                             │
│              = 1 for Ethernet                                  │
│                                                                 │
│  16-23 bits: hlen (Hardware Address Length)                    │
│              = 6 for Ethernet MAC                              │
│                                                                 │
│  24-31 bits: hops (Hop Count)                                  │
│              = 0 unless relayed                                │
│                                                                 │
│  32-63 bits: xid (Transaction ID) - Random identifier          │
│                                                                 │
│  64-79 bits: secs (Seconds elapsed)                            │
│                                                                 │
│  80-87 bits: flags (Broadcast flag)                            │
│              = 0x8000 for broadcast response                   │
│                                                                 │
│  88-119 bits: ciaddr (Client IP Address)                       │
│                                                                 │
│  120-151 bits: yiaddr (Your IP Address) - Offered IP          │
│                                                                 │
│  152-183 bits: siaddr (Server IP Address)                      │
│                                                                 │
│  184-215 bits: giaddr (Gateway IP Address) - Relay agent      │
│                                                                 │
│  216-247 bits: chaddr (Client Hardware Address) - 16 bytes    │
│                                                                 │
│  248-511 bits: sname (Server Name) - 64 bytes                 │
│                                                                 │
│  512-1023 bits: file (Boot Filename) - 128 bytes              │
│                                                                 │
│  1024+ bits:    options (Variable length)                      │
│                 = DHCP message type, parameters, etc.          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Common DHCP Options

| Option Code | Name | Description |
|-------------|------|-------------|
| 1 | Subnet Mask | Network mask |
| 3 | Router | Default gateway |
| 6 | DNS Server | DNS server addresses |
| 12 | Host Name | Client hostname |
| 15 | Domain Name | DNS domain |
| 50 | Requested IP | IP address client wants |
| 51 | IP Address Lease Time | Lease duration (seconds) |
| 53 | DHCP Message Type | 1=Discover, 2=Offer, 3=Request, 5=ACK |
| 54 | Server Identifier | DHCP server address |
| 55 | Parameter Request List | Options client requests |
| 58 | Renewal (T1) | Time for renewal |
| 59 | Rebinding (T2) | Time for rebinding |
| 66 | TFTP Server Name | PXE boot server |
| 67 | Bootfile Name | PXE boot file |
| 82 | Relay Agent Info | Relay agent information |

---

## 3. Network Layer Protocols

### IPv4 Header Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     IPv4 HEADER (RFC 791)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-3 bits:   Version (4)                                       │
│  4-7 bits:   IHL (Internet Header Length) - 5-15 (20-60 bytes)│
│  8-13 bits:  DSCP (Differentiated Services)                    │
│  14-15 bits: ECN (Explicit Congestion Notification)            │
│  16-31 bits: Total Length - 20-65535 bytes                    │
│  32-47 bits: Identification - 0-65535                         │
│  48-50 bits: Flags - DF (bit 2), MF (bit 3)                   │
│  51-63 bits: Fragment Offset - 0-8191 (8-byte units)          │
│  64-71 bits: TTL (Time To Live) - 0-255                       │
│  72-79 bits: Protocol - 1=ICMP, 6=TCP, 17=UDP, 2=IGMP        │
│  80-95 bits: Header Checksum - 0x0000-0xFFFF                 │
│  96-127 bits: Source IP Address                               │
│  128-159 bits: Destination IP Address                          │
│  160-... bits: Options (Optional)                             │
│  ... bits:    Payload                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### IPv4 Protocol Numbers

| Number | Protocol | Name |
|--------|----------|------|
| 1 | ICMP | Internet Control Message Protocol |
| 2 | IGMP | Internet Group Management Protocol |
| 4 | IPv4 | IPv4 encapsulation |
| 6 | TCP | Transmission Control Protocol |
| 17 | UDP | User Datagram Protocol |
| 41 | IPv6 | IPv6 encapsulation |
| 50 | ESP | Encapsulating Security Payload |
| 51 | AH | Authentication Header |
| 58 | ICMPv6 | ICMP for IPv6 |
| 88 | EIGRP | Enhanced Interior Gateway Routing Protocol |
| 89 | OSPF | Open Shortest Path First |
| 103 | PIM | Protocol Independent Multicast |
| 112 | VRRP | Virtual Router Redundancy Protocol |
| 132 | SCTP | Stream Control Transmission Protocol |

### IPv4 Address Ranges

| Class | Address Range | CIDR | Purpose |
|-------|--------------|------|---------|
| A | 1.0.0.0 - 126.255.255.255 | /8 | Large networks |
| B | 128.0.0.0 - 191.255.255.255 | /16 | Medium networks |
| C | 192.0.0.0 - 223.255.255.255 | /24 | Small networks |
| D | 224.0.0.0 - 239.255.255.255 | /4 | Multicast |
| E | 240.0.0.0 - 255.255.255.255 | /4 | Reserved |

### IPv4 Special Addresses

| Address | Purpose |
|---------|---------|
| 0.0.0.0/8 | "This host" - Used for DHCP, default routes |
| 10.0.0.0/8 | Private (RFC 1918) |
| 127.0.0.0/8 | Loopback (127.0.0.1 is localhost) |
| 169.254.0.0/16 | Link-local (APIPA) |
| 172.16.0.0/12 | Private (RFC 1918) |
| 192.0.0.0/24 | IETF Protocol Assignments |
| 192.0.2.0/24 | Documentation (TEST-NET-1) |
| 192.168.0.0/16 | Private (RFC 1918) |
| 198.51.100.0/24 | Documentation (TEST-NET-2) |
| 203.0.113.0/24 | Documentation (TEST-NET-3) |
| 224.0.0.0/4 | Multicast |
| 240.0.0.0/4 | Reserved |
| 255.255.255.255 | Limited Broadcast |

### IPv6 Header Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     IPv6 HEADER (RFC 2460)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-3 bits:   Version (6)                                       │
│  4-11 bits:  Traffic Class - DSCP + ECN                        │
│  12-31 bits: Flow Label - QoS identifier                       │
│  32-47 bits: Payload Length - 0-65535 bytes                   │
│  48-55 bits: Next Header - protocol number (same as IPv4)     │
│  56-63 bits: Hop Limit - 0-255                               │
│  64-95 bits: Source IPv6 Address (first 32 bits)              │
│  96-127 bits: Source IPv6 Address (next 32 bits)              │
│  128-159 bits: Source IPv6 Address (next 32 bits)             │
│  160-191 bits: Source IPv6 Address (last 32 bits)             │
│  192-223 bits: Destination IPv6 Address (first 32 bits)       │
│  224-255 bits: Destination IPv6 Address (next 32 bits)        │
│  256-287 bits: Destination IPv6 Address (next 32 bits)        │
│  288-319 bits: Destination IPv6 Address (last 32 bits)        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### IPv6 Address Types

| Type | Prefix | Description |
|------|--------|-------------|
| Global Unicast | 2000::/3 | Public IPv6 addresses |
| Link-Local | fe80::/10 | Local network communication |
| Unique Local | fc00::/7 | Private (like RFC 1918) |
| Multicast | ff00::/8 | Group communication |
| Anycast | varies | One-to-nearest communication |
| Loopback | ::1/128 | Local host |
| Unspecified | ::/128 | "This host" |
| IPv4-mapped | ::ffff:0:0/96 | IPv4 address embedded |

### IPv6 Address Compression Examples

```
Full Address: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
Compressed:   2001:db8:85a3::8a2e:370:7334

Full Address: 2001:0db8:0000:0000:0000:0000:0000:0001
Compressed:   2001:db8::1

Full Address: 2001:0db8:85a3:0000:0000:0000:0000:7334
Compressed:   2001:db8:85a3::7334

Rule: Leading zeros in each group can be omitted
Rule: Consecutive zero groups can be compressed to :: (once only)
```

### ICMP Message Types

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Ping response |
| 3 | Destination Unreachable | Network/host/protocol unreachable |
| 4 | Source Quench | Deprecated |
| 5 | Redirect | Better route available |
| 8 | Echo Request | Ping request |
| 9 | Router Advertisement | Router discovery |
| 10 | Router Solicitation | Router discovery |
| 11 | Time Exceeded | TTL expired |
| 12 | Parameter Problem | Bad header |
| 13 | Timestamp Request | Timestamp request |
| 14 | Timestamp Reply | Timestamp response |
| 17 | Address Mask Request | Deprecated |
| 18 | Address Mask Reply | Deprecated |

### ICMP Destination Unreachable Codes

| Code | Name |
|------|------|
| 0 | Network Unreachable |
| 1 | Host Unreachable |
| 2 | Protocol Unreachable |
| 3 | Port Unreachable |
| 4 | Fragmentation Needed (DF set) |
| 5 | Source Route Failed |
| 6 | Destination Network Unknown |
| 7 | Destination Host Unknown |
| 8 | Source Host Isolated |
| 9 | Communication with Destination Network Prohibited |
| 10 | Communication with Destination Host Prohibited |
| 11 | Destination Network Unreachable for Service |
| 12 | Destination Host Unreachable for Service |
| 13 | Communication Administratively Prohibited |
| 14 | Host Precedence Violation |
| 15 | Precedence cutoff in effect |

---

## 4. Transport Layer Protocols

### UDP Header Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     UDP HEADER (RFC 768)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-15 bits:  Source Port - 0-65535                             │
│              (0 if not used)                                   │
│                                                                 │
│  16-31 bits: Destination Port - 0-65535                        │
│                                                                 │
│  32-47 bits: Length - 8-65535 bytes (header + payload)        │
│                                                                 │
│  48-63 bits: Checksum - 0x0000 if not used (IPv4 only)        │
│                                                                 │
│  ... bits:    Payload - Application data                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### UDP Pseudo-Header for Checksum

```
┌─────────────────────────────────────────────────────────────────┐
│                 UDP PSEUDO-HEADER (for checksum)               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-31 bits:  Source IP Address                                 │
│                                                                 │
│  32-63 bits: Destination IP Address                            │
│                                                                 │
│  64-71 bits: Zero (8 bits)                                     │
│                                                                 │
│  72-79 bits: Protocol (17 for UDP)                             │
│                                                                 │
│  80-95 bits: UDP Length (same as UDP header length)            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### TCP Header Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     TCP HEADER (RFC 793)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-15 bits:  Source Port - 0-65535                             │
│  16-31 bits: Destination Port - 0-65535                        │
│  32-63 bits: Sequence Number - 0-2^32-1                       │
│  64-95 bits: Acknowledgment Number - 0-2^32-1                 │
│  96-99 bits: Data Offset - 5-15 (20-60 bytes)                 │
│  100-102 bits: Reserved - must be 0                            │
│  103 bits: NS (Nonce Sum)                                      │
│  104 bits: CWR (Congestion Window Reduced)                     │
│  105 bits: ECE (ECN-Echo)                                      │
│  106 bits: URG (Urgent Pointer valid)                          │
│  107 bits: ACK (Acknowledgment valid)                          │
│  108 bits: PSH (Push data to application)                      │
│  109 bits: RST (Reset connection)                              │
│  110 bits: SYN (Synchronize sequence numbers)                  │
│  111 bits: FIN (Finish connection)                             │
│  112-127 bits: Window Size - 0-65535                          │
│  128-143 bits: Checksum - error check                          │
│  144-159 bits: Urgent Pointer - 0-65535                        │
│  160-... bits: Options - variable                              │
│  ... bits:    Payload - Application data                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### TCP Flags

| Flag | Bit | Name | Purpose |
|------|-----|------|---------|
| FIN | 0 | Finish | No more data from sender |
| SYN | 1 | Synchronize | Synchronize sequence numbers |
| RST | 2 | Reset | Abort connection |
| PSH | 3 | Push | Push data to application |
| ACK | 4 | Acknowledgment | Acknowledgment field valid |
| URG | 5 | Urgent | Urgent pointer valid |
| ECE | 6 | ECN-Echo | Congestion notification |
| CWR | 7 | Congestion Window Reduced | Congestion control |
| NS | 8 | Nonce Sum | Experimental |

### TCP Options

| Kind | Length | Name | Description |
|------|--------|------|-------------|
| 0 | 1 | EOL | End of Option List |
| 1 | 1 | NOP | No Operation (padding) |
| 2 | 4 | MSS | Maximum Segment Size |
| 3 | 3 | WScale | Window Scale (RFC 1323) |
| 4 | 2 | SACK Permitted | Selective ACK permitted |
| 5 | variable | SACK | Selective ACK blocks |
| 8 | 10 | Timestamp | Timestamps (RFC 1323) |
| 14 | variable | TCP Alt Svc | Alternate Service |
| 15 | variable | TCP Fast Open | Fast Open (TFO) |

### TCP State Transitions

```
LISTEN      - Waiting for connection
SYN-SENT    - SYN sent, waiting for SYN-ACK
SYN-RCVD    - SYN received, waiting for ACK
ESTABLISHED - Connection established
FIN-WAIT-1  - FIN sent, waiting for ACK
FIN-WAIT-2  - FIN sent, waiting for FIN
CLOSE-WAIT  - FIN received, waiting for close
CLOSING     - Both FIN sent, waiting for ACK
LAST-ACK    - FIN sent, waiting for ACK
TIME-WAIT   - Wait 2MSL before closing
CLOSED      - Connection closed
```

### TCP Timers

| Timer | Purpose | Typical Value |
|-------|---------|---------------|
| Retransmission | Resend unacknowledged data | RTO (dynamic) |
| Persist | Window probes when zero window | 5-60 seconds |
| Keep-alive | Detect dead connections | 2 hours |
| TIME-WAIT | Wait before closing | 2MSL (60 seconds) |
| 2MSL | Maximum Segment Lifetime | 60 seconds |
| SYN-ACK | Wait for ACK to complete handshake | 75 seconds |
| FIN-WAIT-2 | Wait for FIN from peer | 60 seconds |

---

## 5. Application Layer Protocols

### DNS Message Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     DNS MESSAGE (RFC 1035)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-15 bits:  ID (Identifier) - random ID to match queries     │
│                                                                 │
│  16-16 bits: QR (Query/Response) - 0=Query, 1=Response       │
│  17-19 bits: OPCODE - 0=QUERY, 1=IQUERY, 2=STATUS           │
│  20-20 bits: AA (Authoritative Answer)                        │
│  21-21 bits: TC (Truncated)                                   │
│  22-22 bits: RD (Recursion Desired)                           │
│  23-23 bits: RA (Recursion Available)                         │
│  24-24 bits: Z (Reserved)                                     │
│  25-27 bits: RCODE - 0=No error, 3=Name error, etc.          │
│                                                                 │
│  28-43 bits: QDCOUNT (Number of questions)                    │
│  44-59 bits: ANCOUNT (Number of answers)                      │
│  60-75 bits: NSCOUNT (Number of authority records)            │
│  76-91 bits: ARCOUNT (Number of additional records)           │
│                                                                 │
│  ... bits:    Questions - variable                            │
│  ... bits:    Answers - variable                              │
│  ... bits:    Authority - variable                            │
│  ... bits:    Additional - variable                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### DNS Record Types

| Type | Code | Name | Description |
|------|------|------|-------------|
| A | 1 | Address | IPv4 address |
| NS | 2 | Name Server | Authoritative name server |
| CNAME | 5 | Canonical Name | Alias |
| SOA | 6 | Start of Authority | Zone metadata |
| PTR | 12 | Pointer | Reverse DNS |
| MX | 15 | Mail Exchange | Mail server |
| TXT | 16 | Text | Text information |
| AAAA | 28 | IPv6 Address | IPv6 address |
| SRV | 33 | Service Locator | Service location |
| NAPTR | 35 | NAPTR | Naming Authority Pointer |
| OPT | 41 | EDNS Option | EDNS0 metadata |
| DS | 43 | Delegation Signer | DNSSEC |
| RRSIG | 46 | RRSIG | DNSSEC signature |
| NSEC | 47 | NSEC | DNSSEC proof of non-existence |
| DNSKEY | 48 | DNSKEY | DNSSEC key |
| CAA | 257 | CAA | Certificate Authority Authorization |

### DNS Response Codes

| Code | Name | Description |
|------|------|-------------|
| 0 | NoError | No error |
| 1 | FormErr | Format error |
| 2 | ServFail | Server failure |
| 3 | NXDomain | Non-existent domain |
| 4 | NotImp | Not implemented |
| 5 | Refused | Query refused |
| 6 | YXDomain | Name exists when it shouldn't |
| 7 | YXRRSet | RR Set exists when it shouldn't |
| 8 | NXRRSet | RR Set that should exist doesn't |
| 9 | NotAuth | Server not authoritative for zone |
| 10 | NotZone | Name not in zone |
| 11 | DSOTYP | DSO-TYPE |

### HTTP Request Format

```
┌─────────────────────────────────────────────────────────────────┐
│                     HTTP REQUEST                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Request-Line:                                                  │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ METHOD <SP> Request-URI <SP> HTTP-Version <CRLF>         ││
│  │ GET /index.html HTTP/1.1                                 ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
│  Headers:                                                       │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ Header-Name: Value <CRLF>                                  ││
│  │ Host: www.example.com <CRLF>                              ││
│  │ User-Agent: Mozilla/5.0 <CRLF>                           ││
│  │ Accept: text/html <CRLF>                                 ││
│  │ Accept-Encoding: gzip <CRLF>                             ││
│  │ Cookie: session=abc123 <CRLF>                            ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
│  Empty Line: <CRLF>                                            │
│                                                                 │
│  Body (optional):                                              │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ request-body-data                                         ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### HTTP Response Format

```
┌─────────────────────────────────────────────────────────────────┐
│                     HTTP RESPONSE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Status-Line:                                                   │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ HTTP-Version <SP> Status-Code <SP> Reason-Phrase <CRLF>   ││
│  │ HTTP/1.1 200 OK                                           ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
│  Headers:                                                       │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ Header-Name: Value <CRLF>                                  ││
│  │ Content-Type: text/html <CRLF>                            ││
│  │ Content-Length: 1256 <CRLF>                              ││
│  │ Set-Cookie: session=abc123 <CRLF>                       ││
│  │ Cache-Control: max-age=3600 <CRLF>                      ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
│  Empty Line: <CRLF>                                            │
│                                                                 │
│  Body:                                                          │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ response-body-data                                        ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### HTTP Status Codes (Complete)

| Code | Category | Meaning |
|------|----------|---------|
| **1xx - Informational** | | |
| 100 | Continue | Initial part of request received |
| 101 | Switching Protocols | Switching protocols as requested |
| 102 | Processing | Request is being processed |
| **2xx - Success** | | |
| 200 | OK | Request succeeded |
| 201 | Created | Resource created |
| 202 | Accepted | Request accepted for processing |
| 203 | Non-Authoritative | Information from third party |
| 204 | No Content | Successful with no response body |
| 205 | Reset Content | Reset form |
| 206 | Partial Content | Partial resource delivered |
| **3xx - Redirection** | | |
| 300 | Multiple Choices | Multiple options available |
| 301 | Moved Permanently | Resource moved permanently |
| 302 | Found | Resource moved temporarily |
| 303 | See Other | Redirect to different URL |
| 304 | Not Modified | Resource not modified |
| 305 | Use Proxy | Use proxy for resource |
| 307 | Temporary Redirect | Temporary redirect |
| 308 | Permanent Redirect | Permanent redirect |
| **4xx - Client Error** | | |
| 400 | Bad Request | Malformed request |
| 401 | Unauthorized | Authentication required |
| 402 | Payment Required | Payment required |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource not found |
| 405 | Method Not Allowed | Method not supported |
| 406 | Not Acceptable | Not acceptable content type |
| 407 | Proxy Authentication Required | Proxy auth required |
| 408 | Request Timeout | Request timeout |
| 409 | Conflict | Resource conflict |
| 410 | Gone | Resource permanently removed |
| 411 | Length Required | Content-Length required |
| 412 | Precondition Failed | Precondition failed |
| 413 | Payload Too Large | Request entity too large |
| 414 | URI Too Long | URI too long |
| 415 | Unsupported Media Type | Media type not supported |
| 416 | Range Not Satisfiable | Range not satisfiable |
| 417 | Expectation Failed | Expectation failed |
| 418 | I'm a teapot | Teapot (RFC 2324) |
| 422 | Unprocessable Entity | Semantic error |
| 429 | Too Many Requests | Rate limiting |
| 431 | Request Header Fields Too Large | Headers too large |
| 451 | Unavailable For Legal Reasons | Legal restrictions |
| **5xx - Server Error** | | |
| 500 | Internal Server Error | Generic server error |
| 501 | Not Implemented | Method not supported |
| 502 | Bad Gateway | Invalid upstream response |
| 503 | Service Unavailable | Server overloaded |
| 504 | Gateway Timeout | Upstream timeout |
| 505 | HTTP Version Not Supported | HTTP version not supported |
| 507 | Insufficient Storage | Storage limit exceeded |
| 511 | Network Authentication Required | Network auth required |

### HTTP Methods

| Method | Idempotent | Safe | Body | Purpose |
|--------|------------|------|------|---------|
| GET | ✓ | ✓ | No | Retrieve resource |
| HEAD | ✓ | ✓ | No | Retrieve headers only |
| POST | ✗ | ✗ | Yes | Submit data |
| PUT | ✓ | ✗ | Yes | Replace resource |
| DELETE | ✓ | ✗ | No | Remove resource |
| PATCH | ✗ | ✗ | Yes | Partial update |
| OPTIONS | ✓ | ✓ | No | Check supported methods |
| TRACE | ✓ | ✓ | No | Echo request (debug) |
| CONNECT | ✗ | ✗ | No | Tunnel through proxy |

### SMTP Commands

| Command | Description |
|---------|-------------|
| HELO | Identify sender domain (old) |
| EHLO | Extended HELO (ESMTP) |
| MAIL FROM | Start mail transaction |
| RCPT TO | Recipient address |
| DATA | Start message data |
| VRFY | Verify recipient (optional) |
| EXPN | Expand mailing list (optional) |
| HELP | Display help |
| QUIT | End session |
| RSET | Reset transaction |
| AUTH | Authentication (ESMTP) |
| STARTTLS | Start TLS (ESMTP) |

### SMTP Response Codes

| Code | Meaning | Category |
|------|---------|----------|
| 211 | System status | Information |
| 214 | Help message | Information |
| 220 | Service ready | Success |
| 221 | Service closing | Success |
| 250 | Action completed | Success |
| 251 | Forwarding | Success |
| 252 | Cannot verify recipient | Success |
| 354 | Start mail input | Intermediate |
| 421 | Service unavailable | Transient |
| 450 | Mailbox busy | Transient |
| 451 | Local error | Transient |
| 452 | Insufficient storage | Transient |
| 500 | Syntax error | Permanent |
| 501 | Parameter syntax error | Permanent |
| 502 | Command not implemented | Permanent |
| 503 | Bad command sequence | Permanent |
| 504 | Parameter not implemented | Permanent |
| 550 | Mailbox unavailable | Permanent |
| 551 | User not local | Permanent |
| 552 | Quota exceeded | Permanent |
| 553 | Mailbox name not allowed | Permanent |
| 554 | Transaction failed | Permanent |

### POP3 Commands

| Command | Description |
|---------|-------------|
| USER | Username |
| PASS | Password |
| STAT | Mailbox status |
| LIST | List messages |
| RETR | Retrieve message |
| DELE | Delete message |
| NOOP | No operation |
| RSET | Reset (undelete) |
| QUIT | End session |
| TOP | Retrieve headers + top lines |
| UIDL | Unique identifier listing |

### IMAP Commands

| Command | Description |
|---------|-------------|
| LOGIN | Username and password |
| CAPABILITY | Server capabilities |
| SELECT | Select mailbox |
| CREATE | Create mailbox |
| DELETE | Delete mailbox |
| RENAME | Rename mailbox |
| LIST | List mailboxes |
| STATUS | Mailbox status |
| FETCH | Fetch message data |
| STORE | Store message flags |
| SEARCH | Search messages |
| COPY | Copy messages |
| EXPUNGE | Remove deleted messages |
| APPEND | Append message |
| CHECK | Check mailbox |
| CLOSE | Close mailbox |
| LOGOUT | End session |

---

## 6. Security Protocols

### TLS Record Protocol

```
┌─────────────────────────────────────────────────────────────────┐
│                     TLS RECORD (RFC 8446)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-7 bits:   Type - 20=ChangeCipherSpec, 22=Handshake,        │
│              23=Application Data, 21=Alert                     │
│                                                                 │
│  8-15 bits:  Version (legacy) - 0x0303 for TLS 1.2            │
│              (TLS 1.3 uses 0x0304)                             │
│                                                                 │
│  16-31 bits: Length - 0-16384 bytes                            │
│                                                                 │
│  32-... bits: Fragment - Variable length data                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### TLS Handshake Messages (1.3)

| Message | Value | Sender | Purpose |
|---------|-------|--------|---------|
| ClientHello | 1 | Client | Start handshake |
| ServerHello | 2 | Server | Response to ClientHello |
| NewSessionTicket | 4 | Server | Session resumption token |
| EndOfEarlyData | 5 | Client | End of 0-RTT data |
| EncryptedExtensions | 8 | Server | Additional parameters |
| Certificate | 11 | Both | Server/client certificate |
| CertificateRequest | 13 | Server | Request client certificate |
| CertificateVerify | 15 | Both | Signature over handshake |
| Finished | 20 | Both | Verify handshake messages |
| KeyUpdate | 24 | Both | Update keys |
| MessageHash | 254 | Both | Handshake message hash |

### TLS Cipher Suites (1.3)

| Cipher Suite | Code | AEAD | Hash | Key Exchange |
|--------------|------|------|------|--------------|
| TLS_AES_128_GCM_SHA256 | 0x1301 | AES-128-GCM | SHA-256 | ECDHE |
| TLS_AES_256_GCM_SHA384 | 0x1302 | AES-256-GCM | SHA-384 | ECDHE |
| TLS_CHACHA20_POLY1305_SHA256 | 0x1303 | ChaCha20-Poly1305 | SHA-256 | ECDHE |
| TLS_AES_128_CCM_SHA256 | 0x1304 | AES-128-CCM | SHA-256 | ECDHE |
| TLS_AES_128_CCM_8_SHA256 | 0x1305 | AES-128-CCM-8 | SHA-256 | ECDHE |

### TLS Signature Algorithms

| Code | Algorithm |
|------|-----------|
| 0x0401 | rsa_pkcs1_sha256 |
| 0x0501 | rsa_pkcs1_sha384 |
| 0x0601 | rsa_pkcs1_sha512 |
| 0x0403 | ecdsa_secp256r1_sha256 |
| 0x0503 | ecdsa_secp384r1_sha384 |
| 0x0603 | ecdsa_secp521r1_sha512 |
| 0x0804 | rsa_pss_rsae_sha256 |
| 0x0805 | rsa_pss_rsae_sha384 |
| 0x0806 | rsa_pss_rsae_sha512 |
| 0x0807 | rsa_pss_pss_sha256 |
| 0x0808 | rsa_pss_pss_sha384 |
| 0x0809 | rsa_pss_pss_sha512 |
| 0x080a | ecdsa_secp256r1_sha256 |
| 0x081a | ed25519 |
| 0x081b | ed448 |

### X.509 Certificate Fields

| Field | Description |
|-------|-------------|
| Version | X.509 version (1, 2, or 3) |
| Serial Number | Unique certificate identifier |
| Signature Algorithm | Algorithm used to sign certificate |
| Issuer | Certificate Authority name |
| Validity | Not Before/Not After dates |
| Subject | Certificate owner name |
| Subject Public Key Info | Public key and algorithm |
| Subject Alternative Name | Alternative names (DNS, IP, URI) |
| Key Usage | Digital Signature, Key Encipherment, etc. |
| Extended Key Usage | Server Authentication, Client Authentication |
| Basic Constraints | CA, Path Length |
| CRL Distribution Points | Where to find CRL |
| Authority Information Access | OCSP responder, CA Issuers |
| Certificate Policies | Policy OIDs |

### SNMP OID Tree

```
.iso (1)
 └── .org (3)
      └── .dod (6)
           └── .internet (1)
                ├── .mgmt (2)
                │    └── .mib-2 (1)
                │         ├── .system (1)
                │         │    ├── sysDescr (1) .1.3.6.1.2.1.1.1.0
                │         │    ├── sysObjectID (2) .1.3.6.1.2.1.1.2.0
                │         │    ├── sysUpTime (3) .1.3.6.1.2.1.1.3.0
                │         │    ├── sysContact (4) .1.3.6.1.2.1.1.4.0
                │         │    ├── sysName (5) .1.3.6.1.2.1.1.5.0
                │         │    └── sysLocation (6) .1.3.6.1.2.1.1.6.0
                │         ├── .interfaces (2)
                │         │    ├── ifNumber (1) .1.3.6.1.2.1.2.1.0
                │         │    └── ifTable (2)
                │         │         └── ifEntry (1)
                │         │              ├── ifIndex (1)
                │         │              ├── ifDescr (2)
                │         │              ├── ifType (3)
                │         │              ├── ifMtu (4)
                │         │              ├── ifSpeed (5)
                │         │              ├── ifPhysAddress (6)
                │         │              ├── ifOperStatus (8)
                │         │              └── ifLastChange (9)
                │         ├── .at (3)
                │         ├── .ip (4)
                │         │    ├── ipForwarding (1)
                │         │    ├── ipDefaultTTL (2)
                │         │    ├── ipInReceives (3)
                │         │    ├── ipInHdrErrors (4)
                │         │    ├── ipInAddrErrors (5)
                │         │    ├── ipForwDatagrams (6)
                │         │    ├── ipInUnknownProtos (7)
                │         │    ├── ipInDiscards (8)
                │         │    ├── ipInDelivers (9)
                │         │    └── ipOutRequests (10)
                │         ├── .icmp (5)
                │         ├── .tcp (6)
                │         │    ├── tcpRtoAlgorithm (1)
                │         │    ├── tcpRtoMin (2)
                │         │    ├── tcpRtoMax (3)
                │         │    ├── tcpMaxConn (4)
                │         │    ├── tcpActiveOpens (5)
                │         │    ├── tcpPassiveOpens (6)
                │         │    ├── tcpAttemptFails (7)
                │         │    ├── tcpEstabResets (8)
                │         │    ├── tcpCurrEstab (9)
                │         │    ├── tcpInSegs (10)
                │         │    └── tcpOutSegs (11)
                │         └── .udp (7)
                │              ├── udpInDatagrams (1)
                │              ├── udpNoPorts (2)
                │              ├── udpInErrors (3)
                │              └── udpOutDatagrams (4)
                ├── .private (4)
                │    └── .enterprises (1)
                │         ├── .cisco (9)
                │         ├── .ibm (2)
                │         ├── .microsoft (311)
                │         ├── .huawei (2011)
                │         └── .juniper (2636)
                └── .experimental (3)
```

---

## 7. Modern Protocols

### QUIC Packet Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     QUIC LONG HEADER                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0-0 bits:   Header Form (1 = Long Header)                     │
│  1-2 bits:   Fixed Bit (1)                                     │
│  3-7 bits:   Packet Type - 0x01=Initial, 0x02=Handshake       │
│                                                                 │
│  8-31 bits:  Version - 0x00000001 for QUIC v1                 │
│                                                                 │
│  32-64 bits: Destination Connection ID Length + Value          │
│                                                                 │
│  ... bits:    Source Connection ID Length + Value              │
│                                                                 │
│  ... bits:    Packet Number (variable length)                  │
│                                                                 │
│  ... bits:    Payload (encrypted)                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### QUIC Frame Types

| Frame Type | Name | Description |
|------------|------|-------------|
| 0x00-0x03 | PADDING | Padding frame |
| 0x04-0x06 | RESET_STREAM | Reset stream |
| 0x08-0x0B | STOP_SENDING | Stop sending |
| 0x0C-0x0F | CRYPTO | Crypto data |
| 0x10-0x17 | STREAM | Stream data |
| 0x18 | MAX_DATA | Maximum data |
| 0x19 | MAX_STREAM_DATA | Maximum stream data |
| 0x1A | MAX_STREAMS | Maximum streams (unidirectional) |
| 0x1B | MAX_STREAMS | Maximum streams (bidirectional) |
| 0x1C | DATA_BLOCKED | Data blocked |
| 0x1D | STREAM_DATA_BLOCKED | Stream data blocked |
| 0x1E | STREAMS_BLOCKED | Streams blocked (unidirectional) |
| 0x1F | STREAMS_BLOCKED | Streams blocked (bidirectional) |
| 0x20 | NEW_CONNECTION_ID | New connection ID |
| 0x21 | RETIRE_CONNECTION_ID | Retire connection ID |
| 0x22 | PATH_CHALLENGE | Path challenge |
| 0x23 | PATH_RESPONSE | Path response |
| 0x24 | CONNECTION_CLOSE | Connection close |
| 0x25 | CONNECTION_CLOSE | Connection close (application) |

### HTTP/2 Frame Types

| Frame Type | Code | Description |
|------------|------|-------------|
| DATA | 0x0 | Data for HTTP body |
| HEADERS | 0x1 | Headers for HTTP request/response |
| PRIORITY | 0x2 | Stream priority |
| RST_STREAM | 0x3 | Abort stream |
| SETTINGS | 0x4 | Connection settings |
| PUSH_PROMISE | 0x5 | Server push |
| PING | 0x6 | Round-trip measurement |
| GOAWAY | 0x7 | Graceful shutdown |
| WINDOW_UPDATE | 0x8 | Flow control update |
| CONTINUATION | 0x9 | Continued header block |

### HTTP/2 Settings

| Setting | Code | Default | Description |
|---------|------|---------|-------------|
| HEADER_TABLE_SIZE | 0x1 | 4096 | HPACK table size |
| ENABLE_PUSH | 0x2 | 1 | Server push enable |
| MAX_CONCURRENT_STREAMS | 0x3 | unlimited | Max streams |
| INITIAL_WINDOW_SIZE | 0x4 | 65535 | Initial flow control |
| MAX_FRAME_SIZE | 0x5 | 16384 | Max frame size |
| MAX_HEADER_LIST_SIZE | 0x6 | unlimited | Max header list |

---

## 8. IANA Port Numbers

### Well-Known Ports (0-1023)

| Port | Protocol | Service |
|------|----------|---------|
| 7 | TCP/UDP | Echo |
| 20 | TCP | FTP Data |
| 21 | TCP | FTP Control |
| 22 | TCP | SSH |
| 23 | TCP | Telnet |
| 25 | TCP | SMTP |
| 53 | TCP/UDP | DNS |
| 67 | UDP | DHCP Server |
| 68 | UDP | DHCP Client |
| 69 | UDP | TFTP |
| 80 | TCP | HTTP |
| 110 | TCP | POP3 |
| 123 | UDP | NTP |
| 135 | TCP/UDP | RPC |
| 139 | TCP | NetBIOS |
| 143 | TCP | IMAP |
| 161 | UDP | SNMP |
| 162 | UDP | SNMP Trap |
| 179 | TCP | BGP |
| 389 | TCP/UDP | LDAP |
| 443 | TCP | HTTPS |
| 445 | TCP | SMB |
| 465 | TCP | SMTPS |
| 514 | UDP | Syslog |
| 515 | TCP | LPD |
| 636 | TCP/UDP | LDAPS |
| 989 | TCP | FTPS Data |
| 990 | TCP | FTPS Control |
| 993 | TCP | IMAPS |
| 995 | TCP | POP3S |

### Registered Ports (1024-49151)

| Port | Protocol | Service |
|------|----------|---------|
| 1025 | TCP | RPC |
| 1080 | TCP | SOCKS |
| 1433 | TCP | MSSQL |
| 1521 | TCP | Oracle |
| 1723 | TCP | PPTP |
| 1812 | UDP | RADIUS Auth |
| 1813 | UDP | RADIUS Acct |
| 1900 | UDP | SSDP |
| 2049 | TCP/UDP | NFS |
| 2080 | TCP | NFS |
| 2086 | TCP | Gnome |
| 2087 | TCP | Gnome |
| 2181 | TCP | ZooKeeper |
| 2375 | TCP | Docker |
| 2376 | TCP | Docker TLS |
| 2380 | TCP | etcd |
| 2483 | TCP | Oracle |
| 2484 | TCP | Oracle |
| 2601 | TCP | Zebra |
| 2700 | TCP | Nagios |
| 2701 | TCP | Nagios |
| 2702 | TCP | Nagios |
| 2703 | TCP | Nagios |
| 2809 | TCP | Corbaloc |
| 3000 | TCP | Node.js |
| 3306 | TCP | MySQL |
| 3389 | TCP | RDP |
| 3478 | TCP/UDP | STUN |
| 3544 | UDP | Teredo |
| 3689 | TCP | DAAP |
| 3690 | TCP | SVN |
| 3898 | TCP | Net8 |
| 4000 | TCP | ICQ |
| 4001 | TCP | Docker |
| 4060 | TCP | OpenVPN |
| 4369 | TCP | Erlang |
| 5000 | TCP | Python |
| 5001 | TCP | Python |
| 5044 | TCP | Logstash |
| 5140 | UDP | Syslog |
| 5222 | TCP | XMPP |
| 5223 | TCP | XMPP |
| 5228 | TCP | Android |
| 5229 | TCP | Android |
| 5230 | TCP | Android |
| 5432 | TCP | PostgreSQL |
| 5666 | UDP | Nagios |
| 5667 | TCP | NRPE |
| 5671 | TCP | AMQP |
| 5672 | TCP | AMQP |
| 5900 | TCP | VNC |
| 5984 | TCP | CouchDB |
| 6000 | TCP | X11 |
| 6379 | TCP | Redis |
| 6666 | TCP | IRC |
| 6667 | TCP | IRC |
| 6868 | TCP | Acronis |
| 6888 | TCP | BitTorrent |
| 7000 | TCP | Cassandra |
| 7001 | TCP | Weblogic |
| 7049 | TCP | Informix |
| 7199 | TCP | Cassandra |
| 7500 | TCP | Debian |
| 8000 | TCP | HTTP-alt |
| 8008 | TCP | HTTP-alt |
| 8009 | TCP | AJP |
| 8080 | TCP | HTTP-alt |
| 8081 | TCP | HTTP-alt |
| 8086 | TCP | InfluxDB |
| 8088 | TCP | HTTP-alt |
| 8096 | TCP | Plex |
| 8125 | UDP | StatsD |
| 8140 | TCP | Puppet |
| 8181 | TCP | HTTP-alt |
| 8443 | TCP | HTTPS-alt |
| 8883 | TCP | MQTT |
| 8888 | TCP | HTTP-alt |
| 8983 | TCP | Solr |
| 9000 | TCP | HTTP-alt |
| 9001 | TCP | HTTP-alt |
| 9042 | TCP | Cassandra |
| 9090 | TCP | HTTP-alt |
| 9092 | TCP | Kafka |
| 9093 | TCP | Kafka |
| 9094 | TCP | Kafka |
| 9095 | TCP | Kafka |
| 9100 | TCP | JetDirect |
| 9160 | TCP | Cassandra |
| 9200 | TCP | Elasticsearch |
| 9300 | TCP | Elasticsearch |
| 9418 | TCP | Git |
| 9999 | TCP | HTTP-alt |
| 10000 | TCP | Webmin |
| 10001 | TCP | Webmin |
| 10050 | TCP | Zabbix |
| 10051 | TCP | Zabbix |
| 11211 | TCP/UDP | Memcached |
| 11300 | TCP | Beanstalkd |
| 11301 | TCP | Beanstalkd |
| 11302 | TCP | Beanstalkd |
| 11303 | TCP | Beanstalkd |
| 11304 | TCP | Beanstalkd |
| 11305 | TCP | Beanstalkd |
| 11306 | TCP | Beanstalkd |
| 11307 | TCP | Beanstalkd |
| 11308 | TCP | Beanstalkd |
| 11309 | TCP | Beanstalkd |
| 11310 | TCP | Beanstalkd |
| 11311 | TCP | Beanstalkd |
| 11312 | TCP | Beanstalkd |
| 11313 | TCP | Beanstalkd |
| 11314 | TCP | Beanstalkd |
| 11315 | TCP | Beanstalkd |
| 11316 | TCP | Beanstalkd |
| 11317 | TCP | Beanstalkd |
| 11318 | TCP | Beanstalkd |
| 11319 | TCP | Beanstalkd |
| 11320 | TCP | Beanstalkd |
| 11321 | TCP | Beanstalkd |
| 11322 | TCP | Beanstalkd |
| 11323 | TCP | Beanstalkd |
| 11324 | TCP | Beanstalkd |
| 11325 | TCP | Beanstalkd |
| 11326 | TCP | Beanstalkd |
| 11327 | TCP | Beanstalkd |
| 11328 | TCP | Beanstalkd |
| 11329 | TCP | Beanstalkd |
| 11330 | TCP | Beanstalkd |
| 11331 | TCP | Beanstalkd |
| 11332 | TCP | Beanstalkd |
| 11333 | TCP | Beanstalkd |
| 11334 | TCP | Beanstalkd |
| 11335 | TCP | Beanstalkd |
| 11336 | TCP | Beanstalkd |
| 11337 | TCP | Beanstalkd |
| 11338 | TCP | Beanstalkd |
| 11339 | TCP | Beanstalkd |
| 11340 | TCP | Beanstalkd |
| 11341 | TCP | Beanstalkd |
| 11342 | TCP | Beanstalkd |
| 11343 | TCP | Beanstalkd |
| 11344 | TCP | Beanstalkd |
| 11345 | TCP | Beanstalkd |
| 11346 | TCP | Beanstalkd |
| 11347 | TCP | Beanstalkd |
| 11348 | TCP | Beanstalkd |
| 11349 | TCP | Beanstalkd |
| 11350 | TCP | Beanstalkd |
| 11351 | TCP | Beanstalkd |
| 11352 | TCP | Beanstalkd |
| 11353 | TCP | Beanstalkd |
| 11354 | TCP | Beanstalkd |
| 11355 | TCP | Beanstalkd |
| 11356 | TCP | Beanstalkd |
| 11357 | TCP | Beanstalkd |
| 11358 | TCP | Beanstalkd |
| 11359 | TCP | Beanstalkd |
| 11360 | TCP | Beanstalkd |
| 11361 | TCP | Beanstalkd |
| 11362 | TCP | Beanstalkd |
| 11363 | TCP | Beanstalkd |
| 11364 | TCP | Beanstalkd |
| 11365 | TCP | Beanstalkd |
| 11366 | TCP | Beanstalkd |
| 11367 | TCP | Beanstalkd |
| 11368 | TCP | Beanstalkd |
| 11369 | TCP | Beanstalkd |
| 11370 | TCP | Beanstalkd |
| 11371 | TCP | Beanstalkd |
| 11372 | TCP | Beanstalkd |
| 11373 | TCP | Beanstalkd |
| 11374 | TCP | Beanstalkd |
| 11375 | TCP | Beanstalkd |
| 11376 | TCP | Beanstalkd |
| 11377 | TCP | Beanstalkd |
| 11378 | TCP | Beanstalkd |
| 11379 | TCP | Beanstalkd |
| 11380 | TCP | Beanstalkd |
| 11381 | TCP | Beanstalkd |
| 11382 | TCP | Beanstalkd |
| 11383 | TCP | Beanstalkd |
| 11384 | TCP | Beanstalkd |
| 11385 | TCP | Beanstalkd |
| 11386 | TCP | Beanstalkd |
| 11387 | TCP | Beanstalkd |
| 11388 | TCP | Beanstalkd |
| 11389 | TCP | Beanstalkd |
| 11390 | TCP | Beanstalkd |
| 11391 | TCP | Beanstalkd |
| 11392 | TCP | Beanstalkd |
| 11393 | TCP | Beanstalkd |
| 11394 | TCP | Beanstalkd |
| 11395 | TCP | Beanstalkd |
| 11396 | TCP | Beanstalkd |
| 11397 | TCP | Beanstalkd |
| 11398 | TCP | Beanstalkd |
| 11399 | TCP | Beanstalkd |
| 11400 | TCP | Beanstalkd |

### Dynamic/Private Ports (49152-65535)

These ports are used for dynamic/ephemeral allocation by client applications.

---

## 9. EtherType Values

| EtherType | Protocol |
|-----------|----------|
| 0x0000-0x05DC | IEEE 802.3 Length |
| 0x0600 | XEROX NS IDP |
| 0x0800 | IPv4 |
| 0x0806 | ARP |
| 0x081C | AARP |
| 0x4000 | EtherTalk |
| 0x8035 | RARP |
| 0x809B | AppleTalk |
| 0x80D5 | IBM SNA |
| 0x8100 | IEEE 802.1Q VLAN |
| 0x8137 | Novell IPX |
| 0x8138 | Novell IPX |
| 0x817D | Novell |
| 0x86DD | IPv6 |
| 0x8808 | IEEE 802.3 |
| 0x8809 | IEEE 802.3 |
| 0x880B | PPP |
| 0x8847 | MPLS Unicast |
| 0x8848 | MPLS Multicast |
| 0x8863 | PPPoE Discovery |
| 0x8864 | PPPoE Session |
| 0x887B | HomePlug |
| 0x888E | EAP over LAN |
| 0x8892 | PROFINET |
| 0x88A8 | IEEE 802.1AD (Q-in-Q) |
| 0x88B5 | IEEE 802.1AE |
| 0x88CC | LLDP |
| 0x88CD | SERCOS III |
| 0x88E1 | HomePlug AV |
| 0x88E5 | MAC Security |
| 0x88F7 | PTP |
| 0x88FE | Cisco |
| 0x8906 | FCoE |
| 0x890D | FCoE Initialization |
| 0x8914 | FCoE Discovery |
| 0x8915 | HSRP |
| 0x891D | MPLS |
| 0x892F | PTP |
| 0x9000 | Loopback |
| 0x9100 | VLAN (Q-in-Q) |
| 0xFFFF | Reserved |

---

## 10. Protocol Constants

### Maximum Segment Sizes

| Network Type | MTU | MSS (TCP) |
|--------------|-----|-----------|
| Ethernet | 1500 | 1460 |
| PPPoE | 1492 | 1452 |
| Wi-Fi | 1500 | 1460 |
| Token Ring | 4500 | 4460 |
| Fiber (10GbE) | 1500 | 1460 |
| Jumbo Frame | 9000 | 8960 |
| IPv6 (min) | 1280 | 1220 |

### TTL Default Values

| Operating System | Default TTL |
|------------------|-------------|
| Linux | 64 |
| Windows | 128 |
| macOS | 64 |
| FreeBSD | 64 |
| Solaris | 255 |
| Cisco IOS | 255 |

### TCP Keep-Alive Defaults

| Parameter | Linux | Windows |
|-----------|-------|---------|
| Idle time | 7200s | 7200s |
| Interval | 75s | 1000ms |
| Probes | 9 | 10 |

### ARP Cache Timeouts

| Operating System | Timeout |
|------------------|---------|
| Linux | 60s |
| Windows | 300s |
| macOS | 300s |
| FreeBSD | 1200s |

### DHCP Default Values

| Parameter | Default |
|-----------|---------|
| Lease Time | 86400s (24h) |
| T1 (Renewal) | 50% of lease |
| T2 (Rebinding) | 87.5% of lease |
| Server Port | 67 (UDP) |
| Client Port | 68 (UDP) |

### DNS Default Values

| Parameter | Default |
|-----------|---------|
| UDP Port | 53 |
| TCP Port | 53 |
| Query Timeout | 2-5s |
| Cache TTL | 300s (5min) |

---

**[END OF APPENDIX A]**
