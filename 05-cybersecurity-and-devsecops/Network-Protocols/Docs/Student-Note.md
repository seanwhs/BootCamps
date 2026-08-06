# Comprehensive Student Notes

## Demystifying Network Protocols: From Ethernet Frames to HTTP/3

### Complete Lecture Notes for Every Protocol and Concept

---

## Overview

These student notes are designed to accompany the "Demystifying Network Protocols" tutorial series. They provide concise, well-organized reference material covering every protocol, concept, and technical detail discussed throughout the series.

**Purpose:** Serve as a comprehensive study aid, reference guide, and lecture companion that captures the essential information from each part.

**How to Use These Notes:**
1. Review before watching/reading each part
2. Take additional notes in the margins
3. Use as a quick reference during labs
4. Review before assessments
5. Keep as a permanent reference

**Organization:** Each part is organized by topic with clear headings, bullet points, tables, and diagrams.

---

# PART 1: FOUNDATIONS & THE LOCAL LINK

## Networking Foundations

### What Are Network Protocols?

- **Definition:** Set of rules and standards that define how devices communicate
- **Purpose:** Ensure interoperability between different systems
- **Key Characteristics:**
  - **Syntax:** Format and structure of messages
  - **Semantics:** Meaning of messages
  - **Timing:** When messages are sent and sequenced

### The OSI Seven-Layer Model

| Layer | Name | Function | Examples |
|-------|------|----------|----------|
| 7 | Application | User-facing services | HTTP, SMTP, DNS |
| 6 | Presentation | Data formatting, encryption | TLS, JPEG, MPEG |
| 5 | Session | Managing conversations | NetBIOS, RPC |
| 4 | Transport | Reliable/unreliable delivery | TCP, UDP |
| 3 | Network | Routing and addressing | IPv4, IPv6 |
| 2 | Data Link | Local delivery | Ethernet, ARP |
| 1 | Physical | Raw bits over wire | Copper, Fiber, WiFi |

### The TCP/IP Protocol Suite

| Layer | OSI Equivalent | Protocols |
|-------|---------------|-----------|
| Application | 5-7 | DNS, HTTP, SMTP, FTP, SSH, TLS |
| Transport | 4 | TCP, UDP |
| Internet | 3 | IPv4, IPv6, ICMP, IGMP |
| Link | 1-2 | Ethernet, Wi-Fi, ARP |

**Key Insight:** The TCP/IP model is what the Internet actually uses—simpler and more practical than OSI.

### Encapsulation

**Definition:** Process of wrapping data with protocol headers at each layer as it moves down the stack.

**Encapsulation Flow:**

```
Application Data
    │
    ▼
┌───────────────┬──────────────────────┐
│  TCP Header   │   Application Data   │
└───────────────┴──────────────────────┘
    │
    ▼
┌───────────────┬───────────────┬──────┐
│  IP Header    │  TCP Header   │ Data │
└───────────────┴───────────────┴──────┘
    │
    ▼
┌───────────────┬───────────────┬──────┬─────┐
│  Ethernet     │  IP Header    │ Data │ FCS │
│  Header       │               │      │     │
└───────────────┴───────────────┴──────┴─────┘
```

### Network Interface Cards (NICs)

- **Hardware connection** to the network
- **MAC Address:** 48-bit unique identifier (e.g., 00:1A:2B:3C:4D:5E)
- **Promiscuous Mode:** Passes all frames to the OS (for packet capture)
- **Full Duplex:** Send and receive simultaneously
- **Half Duplex:** Send or receive, not both

### Physical Transmission Media

| Medium | Speed | Distance | Characteristics |
|--------|-------|----------|-----------------|
| Copper (Cat5e/6) | 1-10 Gbps | 100m | Electrical, interference-prone |
| Fiber Optic | 40-100 Gbps | 100+ km | Light, immune to interference |
| WiFi | 1-10 Gbps | 50-100m | Radio, affected by obstacles |
| Coaxial | 1 Gbps | 500m | Electrical, cable internet |

---

## Ethernet

### Ethernet Evolution

| Standard | Year | Speed | Innovation |
|----------|------|-------|------------|
| 10BASE5 | 1980 | 10 Mbps | Original Ethernet |
| 10BASE2 | 1985 | 10 Mbps | Cheaper cables |
| 10BASE-T | 1990 | 10 Mbps | Star topology, hubs |
| 100BASE-TX | 1995 | 100 Mbps | Fast Ethernet |
| 1000BASE-T | 1999 | 1 Gbps | Gigabit Ethernet |
| 10GBASE-T | 2006 | 10 Gbps | 10-Gigabit Ethernet |

### Ethernet Frame Structure

```
┌─────────────────────────────────────────────────────────────┐
│                   ETHERNET II FRAME                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Preamble (7 bytes) - Synchronization                   │
│  2. SFD (1 byte) - Start Frame Delimiter                   │
│  3. Destination MAC (6 bytes) - Recipient address          │
│  4. Source MAC (6 bytes) - Sender address                  │
│  5. EtherType (2 bytes) - Protocol type                    │
│  6. Payload (46-1500 bytes) - Data                         │
│  7. FCS (4 bytes) - CRC-32 checksum                       │
│                                                             │
│  Total: 64-1518 bytes (excluding preamble)                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Key Fields:**
- **Destination MAC:** FF:FF:FF:FF:FF:FF = Broadcast
- **EtherType:** 0x0800 = IPv4, 0x0806 = ARP, 0x86DD = IPv6
- **Minimum Frame Size:** 64 bytes (for collision detection)

### MAC Addressing

- **48 bits** (6 bytes)
- **First 24 bits:** OUI (Organizationally Unique Identifier - manufacturer)
- **Last 24 bits:** NIC-specific identifier
- **Special Addresses:**
  - **Broadcast:** FF:FF:FF:FF:FF:FF
  - **Multicast:** First byte LSB = 1 (01:00:5E:xx:xx:xx)
  - **Unicast:** First byte LSB = 0

### Unicast vs. Broadcast vs. Multicast

| Type | MAC | Behavior | Use |
|------|-----|----------|-----|
| Unicast | Specific | One device | Normal communication |
| Broadcast | FF:FF:FF:FF:FF:FF | All devices | ARP, DHCP |
| Multicast | 01:00:5E... | Group | Video streaming, routing |

### VLAN Fundamentals

**Definition:** VLANs partition a physical switch into multiple logical switches.

**Benefits:**
- Broadcast isolation
- Security separation
- Traffic optimization
- Logical grouping

**VLAN Tag (802.1Q):**
- 4 bytes inserted after MAC addresses
- **Priority (3 bits):** QoS (0-7)
- **VLAN ID (12 bits):** 0-4095

### Switching and MAC Tables

- **Learning:** Switch records source MAC and port
- **Forwarding:** Frames sent only to destination port (or flooded if unknown)
- **Aging:** Entries expire after 300-600 seconds

---

## ARP (Address Resolution Protocol)

### Why ARP Exists

**Problem:** Need to map IP addresses to MAC addresses for local delivery.

**Analogy:** IP address = apartment number, MAC address = actual person's name.

### ARP Request and Reply

**ARP Request (Broadcast):**
```
"Who has 192.168.1.20? Tell 192.168.1.10"
- Ethernet Dest: FF:FF:FF:FF:FF:FF
- ARP Opcode: 1 (Request)
- Target MAC: 00:00:00:00:00:00
```

**ARP Reply (Unicast):**
```
"192.168.1.20 is at 11:22:33:44:55:66"
- Ethernet Dest: 00:1A:2B:3C:4D:5E
- ARP Opcode: 2 (Reply)
```

### ARP Cache

**Purpose:** Avoid repeated ARP requests for the same IP.

**Commands:**
```bash
arp -a              # View cache
arp -d <ip>         # Delete entry
ip neigh flush all  # Clear cache
```

### Gratuitous ARP

**Definition:** ARP request sent for the device's own IP.

**Purposes:**
- Detect IP conflicts
- Update other devices' caches
- Announce MAC address changes

### Proxy ARP

- Router responds to ARP requests on behalf of remote hosts
- Makes remote devices appear local

### ARP Spoofing

**Attack:** Attacker sends forged ARP replies.

**Effects:**
- Man-in-the-middle
- Traffic interception
- Denial of service

**Mitigations:**
- Static ARP entries
- Dynamic ARP Inspection (DAI)
- Packet filtering

---

## DHCP (Dynamic Host Configuration Protocol)

### Why DHCP Exists

**Problems with Static Addressing:**
- Manual configuration required
- IP conflicts possible
- Devices can't move between networks
- Doesn't scale

### DHCP Architecture

- **DHCP Server:** Manages IP address pool
- **DHCP Client:** Requests IP address
- **DHCP Relay Agent:** Forwards DHCP across subnets

### DORA Process

```
1. DISCOVER (Client → Server, Broadcast)
   "Does anyone have an IP?"

2. OFFER (Server → Client, Unicast)
   "Here's IP 192.168.1.10"

3. REQUEST (Client → Server, Broadcast)
   "I'll take 192.168.1.10"

4. ACKNOWLEDGE (Server → Client, Unicast)
   "Confirmed! Use 192.168.1.10"
```

### DHCP Lease Renewal

- **T1 (50%):** Client tries to renew with same server
- **T2 (87.5%):** Client broadcasts to any server
- **Expiration:** Must release IP and start over

### Common DHCP Options

| Option | Name | Example |
|--------|------|---------|
| 1 | Subnet Mask | 255.255.255.0 |
| 3 | Router | 192.168.1.1 |
| 6 | DNS Server | 8.8.8.8 |
| 15 | Domain Name | example.com |
| 51 | Lease Time | 86400 |
| 53 | Message Type | 1=Discover, 2=Offer |

---

# PART 2: THE NETWORK LAYER & DIAGNOSTICS

## IPv4 Fundamentals

### IPv4 Addressing

**Size:** 32 bits (4 bytes)
**Format:** Dotted decimal (192.168.1.10)
**Number:** ~4.3 billion addresses

### IPv4 Packet Structure

```
┌─────────────────────────────────────────────────────┐
│                  IPv4 HEADER                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Version (4 bits) - IPv4 = 4                       │
│  IHL (4 bits) - Header length (5-15)               │
│  DSCP (6 bits) - Quality of Service                │
│  ECN (2 bits) - Congestion notification            │
│  Total Length (16 bits) - 20-65535 bytes           │
│  Identification (16 bits) - Fragment identifier    │
│  Flags (3 bits) - DF, MF                           │
│  Fragment Offset (13 bits) - Position             │
│  TTL (8 bits) - Time to Live (0-255)              │
│  Protocol (8 bits) - 6=TCP, 17=UDP, 1=ICMP        │
│  Header Checksum (16 bits) - Error check          │
│  Source IP (32 bits)                              │
│  Destination IP (32 bits)                         │
│  Options (variable) - Rarely used                 │
│  Payload (variable)                               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### IPv4 Protocol Numbers

| Number | Protocol |
|--------|----------|
| 1 | ICMP |
| 6 | TCP |
| 17 | UDP |
| 41 | IPv6 |
| 50 | ESP |
| 89 | OSPF |

### Fragmentation and MTU

**MTU (Maximum Transmission Unit):**
- Ethernet: 1500 bytes
- Jumbo Frames: 9000 bytes
- IPv6 Minimum: 1280 bytes

**Fragmentation:** Splitting large packets to fit network links
**Reassembly:** Done at destination
**DF Flag (Don't Fragment):** Prevents fragmentation

### CIDR Notation

**Definition:** Classless Inter-Domain Routing specifies network prefix length.

**Example:** 192.168.1.10/24
- First 24 bits = network
- Last 8 bits = host

### Private vs. Public Addressing

**RFC 1918 Private Addresses:**
| Range | CIDR | Size |
|-------|------|------|
| 10.0.0.0 - 10.255.255.255 | 10.0.0.0/8 | 16.7M |
| 172.16.0.0 - 172.31.255.255 | 172.16.0.0/12 | 1.0M |
| 192.168.0.0 - 192.168.255.255 | 192.168.0.0/16 | 65K |

### NAT (Network Address Translation)

**Definition:** Maps private IPs to public IPs for Internet access.

**Types:**
- **SNAT (Source NAT):** Changes source IP
- **DNAT (Destination NAT):** Changes destination IP
- **PAT (Port Address Translation):** Many-to-one mapping

### Subnetting

**Definition:** Dividing a network into smaller segments.

**Formula:**
- Number of subnets = 2^n (where n = bits borrowed)
- Number of hosts = 2^m - 2 (where m = host bits)

**Example:** 192.168.1.0/24 into 4 subnets
- Borrow 2 bits (2^2 = 4 subnets)
- New prefix: /26
- Subnets: 192.168.1.0/26, 192.168.1.64/26, 192.168.1.128/26, 192.168.1.192/26
- Hosts per subnet: 62

---

## IPv6

### Why IPv6?

- **Address Exhaustion:** IPv4 has 4.3B addresses, IPv6 has 3.4×10^38
- **Simplified Header:** Fixed 40 bytes
- **Built-in Security:** IPsec mandatory
- **No NAT:** End-to-end connectivity
- **SLAAC:** Auto-configuration

### IPv6 Address Structure

**Size:** 128 bits (16 bytes)
**Format:** 8 groups of 4 hex digits (2001:db8:85a3::8a2e:370:7334)

**Structure:**
- **Global Routing Prefix:** 48 bits
- **Subnet ID:** 16 bits
- **Interface ID:** 64 bits

### IPv6 Address Types

| Type | Prefix | Description |
|------|--------|-------------|
| Global Unicast | 2000::/3 | Public IPv6 |
| Link-Local | fe80::/10 | Local network |
| Unique Local | fc00::/7 | Private IPv6 |
| Multicast | ff00::/8 | Group communication |
| Loopback | ::1 | Local host |

### IPv6 Address Compression

**Rules:**
1. Leading zeros can be omitted
2. Consecutive zero groups compress to :: (once only)

**Examples:**
```
Full: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
Compressed: 2001:db8:85a3::8a2e:370:7334
```

### SLAAC (Stateless Address Autoconfiguration)

1. Device generates Link-Local: `fe80::<interface_id>`
2. Verifies uniqueness (DAD - Duplicate Address Detection)
3. Router sends Advertisement with prefix
4. Device combines prefix + interface ID

**Interface ID Generation:**
- **EUI-64:** Derived from MAC address
- **Random:** Privacy extensions

### Transition Mechanisms

| Mechanism | Description |
|-----------|-------------|
| Dual Stack | Run both IPv4 and IPv6 |
| 6to4 | Encapsulate IPv6 in IPv4 |
| Teredo | Tunneling through NAT |
| NAT64 | Translate between IPv6 and IPv4 |

---

## Routing

### How Routing Works

**Definition:** Forwarding packets from one network to another.

**Routing Table Components:**
- **Destination:** Network or host address
- **Gateway:** Next hop router
- **Interface:** Output interface
- **Metric:** Cost/preference

**Routing Decision:** Longest prefix match (most specific route wins)

### Default Gateway

- Route of last resort (0.0.0.0/0)
- Used when no other route matches
- Usually the router at the network edge

### Static vs. Dynamic Routing

| Type | Pros | Cons |
|------|------|------|
| Static | Simple, predictable, no overhead | Doesn't adapt, doesn't scale |
| Dynamic | Adapts, scales | Complex, overhead |

**Dynamic Routing Protocols:**
- **RIP:** Distance-vector (hops)
- **OSPF:** Link-state (fast convergence)
- **BGP:** Path-vector (Internet routing)

### Routing Example

```
Route for 10.1.2.3:
Destination: 10.1.0.0/16 (match 16 bits) ← Longest match
Destination: 10.0.0.0/8 (match 8 bits)
Default: 0.0.0.0/0 (match 0 bits)

Result: Forward via 10.1.0.0/16 route
```

---

## ICMP

### What Is ICMP?

- Internet Control Message Protocol
- Diagnostic and error-reporting protocol
- Carried directly in IP (protocol number 1)
- Not a transport protocol

### Common ICMP Message Types

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Ping response |
| 3 | Destination Unreachable | Network/host/port unreachable |
| 8 | Echo Request | Ping request |
| 11 | Time Exceeded | TTL expired (traceroute) |
| 5 | Redirect | Better route available |

### Destination Unreachable Codes

| Code | Meaning |
|------|---------|
| 0 | Network Unreachable |
| 1 | Host Unreachable |
| 2 | Protocol Unreachable |
| 3 | Port Unreachable |
| 4 | Fragmentation Needed |

### Ping

**Purpose:** Test basic connectivity.

```
$ ping 8.8.8.8
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=12.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=11.8 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss
rtt min/avg/max/mdev = 11.8/12.0/12.3/0.2 ms
```

### Traceroute

**Purpose:** Map the path packets take to a destination.

**How It Works:**
1. Send packets with increasing TTL
2. Each hop sends Time Exceeded
3. Destination sends Port Unreachable
4. Build route based on responses

---

# PART 3: THE TRANSPORT LAYER

## UDP (User Datagram Protocol)

### UDP Characteristics

- **Connectionless:** No handshake
- **Unreliable:** No delivery guarantees
- **Unordered:** No sequence numbers
- **Lightweight:** 8-byte header
- **Fast:** Low overhead

### UDP Header

```
┌────────────────────────────────────┐
│         UDP HEADER (8 bytes)       │
├────────────────────────────────────┤
│  Source Port (16 bits)             │
│  Destination Port (16 bits)        │
│  Length (16 bits)                  │
│  Checksum (16 bits)                │
│  Payload (variable)                │
└────────────────────────────────────┘
```

### UDP Use Cases

| Application | Why UDP |
|-------------|---------|
| DNS | Fast queries |
| VoIP | Low latency |
| Video Streaming | Real-time |
| Gaming | Low latency |
| SNMP | Simple queries |
| DHCP | Broadcast-based |

---

## TCP (Transmission Control Protocol)

### TCP Characteristics

- **Connection-oriented:** Three-way handshake
- **Reliable:** Delivery guaranteed
- **Ordered:** Sequence numbers
- **Flow Control:** Prevents receiver overload
- **Congestion Control:** Prevents network collapse

### TCP Header

```
┌──────────────────────────────────────────────────────┐
│                TCP HEADER (20-60 bytes)              │
├──────────────────────────────────────────────────────┤
│  Source Port (16 bits)                               │
│  Destination Port (16 bits)                          │
│  Sequence Number (32 bits)                           │
│  Acknowledgment Number (32 bits)                     │
│  Data Offset (4 bits)                                │
│  Flags (9 bits) - SYN, ACK, FIN, RST, PSH, URG      │
│  Window Size (16 bits)                               │
│  Checksum (16 bits)                                  │
│  Urgent Pointer (16 bits)                            │
│  Options (variable)                                  │
│  Payload (variable)                                  │
└──────────────────────────────────────────────────────┘
```

### TCP Flags

| Flag | Name | Purpose |
|------|------|---------|
| SYN | Synchronize | Start connection |
| ACK | Acknowledgment | Confirm receipt |
| FIN | Finish | Close connection |
| RST | Reset | Abort connection |
| PSH | Push | Push data immediately |
| URG | Urgent | Urgent data |

### Three-Way Handshake

```
Client                Server
  │                     │
  │  SYN (seq=x)       │
  ├────────────────────►│
  │                     │
  │  SYN-ACK (seq=y,   │
  │           ack=x+1)  │
  │◄────────────────────┤
  │                     │
  │  ACK (seq=x+1,     │
  │       ack=y+1)      │
  ├────────────────────►│
  │                     │
  │    [ESTABLISHED]    │
```

### Four-Way Termination

```
Client                Server
  │                     │
  │  FIN (seq=u)       │
  ├────────────────────►│
  │                     │
  │  ACK (ack=u+1)     │
  │◄────────────────────┤
  │                     │
  │  FIN (seq=v)       │
  │◄────────────────────┤
  │                     │
  │  ACK (ack=v+1)     │
  ├────────────────────►│
  │                     │
  │    [CLOSED]         │
```

### TCP State Machine

- **LISTEN:** Waiting for connection
- **SYN-SENT:** SYN sent
- **SYN-RCVD:** SYN received
- **ESTABLISHED:** Connection open
- **FIN-WAIT-1:** FIN sent
- **FIN-WAIT-2:** FIN acknowledged
- **CLOSE-WAIT:** FIN received
- **CLOSING:** Both FIN sent
- **LAST-ACK:** FIN sent
- **TIME-WAIT:** Wait 2MSL
- **CLOSED:** Connection closed

### Sequence and Acknowledgment Numbers

- **Sequence Number:** Position in data stream
- **Acknowledgment Number:** Next expected byte
- **SYN and FIN consume one sequence number**

### Retransmission

**Timeout-Based Retransmission (RTO):**
- Dynamically calculated based on RTT
- Double timeout on each failure

**Fast Retransmit:**
- After 3 duplicate ACKs
- Retransmit immediately

### Sliding Window

- **Sender Window:** Packets sent but unacknowledged
- **Receiver Window:** Available buffer space
- **Window Size:** Flow control mechanism

### Congestion Control

**Algorithms:**
1. **Slow Start:** Exponential growth from 1 MSS
2. **Congestion Avoidance:** Linear growth after threshold
3. **Fast Retransmit:** Immediate retransmit on duplicate ACKs
4. **Fast Recovery:** Reduce window by half

**BBR (Bottleneck Bandwidth and RTT):**
- Models network capacity
- Avoids bufferbloat
- Measures delivery rate

---

## Socket Programming

### What Is a Socket?

**Definition:** Endpoint of a connection defined by:
- Protocol (TCP/UDP)
- IP address
- Port number

### Port Numbers

| Range | Type |
|-------|------|
| 0-1023 | Well-known (privileged) |
| 1024-49151 | Registered |
| 49152-65535 | Dynamic/private |

### Common Ports

| Port | Service |
|------|---------|
| 22 | SSH |
| 25 | SMTP |
| 53 | DNS |
| 80 | HTTP |
| 443 | HTTPS |
| 3306 | MySQL |

### Socket Types

- **SOCK_STREAM:** TCP
- **SOCK_DGRAM:** UDP
- **SOCK_RAW:** IP access (requires root)

### Python Socket API

**TCP Server:**
```python
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind((host, port))
sock.listen(5)
client, addr = sock.accept()
data = client.recv(4096)
client.send(data)
client.close()
```

**TCP Client:**
```python
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((host, port))
sock.send(b'Hello')
data = sock.recv(4096)
sock.close()
```

**UDP Server:**
```python
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((host, port))
data, addr = sock.recvfrom(4096)
sock.sendto(data, addr)
```

**UDP Client:**
```python
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(b'Hello', (host, port))
data, addr = sock.recvfrom(4096)
```

---

# PART 4: THE APPLICATION LAYER

## DNS (Domain Name System)

### What Is DNS?

- Translates domain names to IP addresses
- Hierarchical, distributed database
- Uses UDP port 53 (TCP for large responses)

### DNS Hierarchy

```
Root (.)
  │
  ├── .com
  │    ├── example.com
  │    │    ├── www.example.com
  │    │    └── mail.example.com
  │    └── google.com
  ├── .org
  ├── .net
  └── .uk
```

### DNS Server Types

1. **Root Servers:** 13 worldwide, point to TLD servers
2. **TLD Servers:** .com, .org, etc.
3. **Authoritative Servers:** Domain's own DNS
4. **Recursive Resolvers:** Client's local DNS server

### DNS Resolution Process

```
Client → Recursive Resolver → Root Server → TLD Server → Authoritative Server → IP

1. Recursive resolver checks cache
2. If not cached, asks root server
3. Root points to TLD server (.com)
4. TLD points to authoritative server (example.com)
5. Authoritative provides IP address
```

### DNS Record Types

| Type | Purpose | Example |
|------|---------|---------|
| A | IPv4 address | `93.184.216.34` |
| AAAA | IPv6 address | `2606:2800:220:1:248:1893:25c8:1946` |
| CNAME | Alias | `www -> example.com` |
| MX | Mail server | `10 mail.example.com` |
| TXT | Text | `"v=spf1 include:_spf.google.com ~all"` |
| NS | Name server | `ns1.example.com` |
| PTR | Reverse DNS | `34.216.184.93.in-addr.arpa` |
| SOA | Zone metadata | Serial, refresh, retry |

### DNS Caching

- **TTL (Time to Live):** How long to cache a record
- **Cache Locations:** Browser, OS, local resolver, ISP
- **Purposes:** Reduce latency, reduce load

### DNS Security

| Attack | Mitigation |
|--------|------------|
| DNS Spoofing | DNSSEC |
| Cache Poisoning | DNSSEC, random source ports |
| Amplification | Rate limiting |

---

## HTTP (Hypertext Transfer Protocol)

### What Is HTTP?

- Foundation of the World Wide Web
- Request-response protocol
- Uses TCP port 80 (HTTP) or 443 (HTTPS)

### HTTP Request

```
GET /index.html HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0
Accept: text/html
Cookie: session=12345

(body)
```

### HTTP Response

```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1256
Set-Cookie: session=abc123

<html>...</html>
```

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Retrieve | ✓ | ✓ |
| HEAD | Headers only | ✓ | ✓ |
| POST | Submit data | ✗ | ✗ |
| PUT | Replace | ✓ | ✗ |
| DELETE | Remove | ✓ | ✗ |
| PATCH | Partial update | ✗ | ✗ |
| OPTIONS | Check methods | ✓ | ✓ |

### HTTP Status Codes

**1xx (Informational):**
- 100 Continue
- 101 Switching Protocols

**2xx (Success):**
- 200 OK
- 201 Created
- 204 No Content

**3xx (Redirection):**
- 301 Moved Permanently
- 302 Found
- 304 Not Modified

**4xx (Client Error):**
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found

**5xx (Server Error):**
- 500 Internal Server Error
- 503 Service Unavailable
- 504 Gateway Timeout

### HTTP Headers

**Request Headers:**
- `Host`: Virtual host
- `User-Agent`: Client identification
- `Accept`: Content types accepted
- `Cookie`: Session data
- `Authorization`: Authentication

**Response Headers:**
- `Content-Type`: Content format
- `Content-Length`: Content size
- `Cache-Control`: Caching directives
- `Set-Cookie`: Cookie to set
- `Location`: Redirect destination

### Cookies and Sessions

**Cookies:**
- Stored on client
- Sent with every request
- Attributes: Path, Domain, Max-Age, Secure, HttpOnly

**Sessions:**
- Data stored on server
- Session ID stored in cookie
- Server-side state management

### HTTP Caching

**Cache-Control Directives:**
- `max-age`: Cache duration
- `no-cache`: Validate before using
- `no-store`: Don't cache at all
- `public`: Cacheable by any
- `private`: Cacheable only by client

**Cache Validation:**
- `ETag`: Entity tag for validation
- `Last-Modified`: Modification timestamp
- `If-Modified-Since`: Conditional GET

### HTTP/2 Multiplexing

**Features:**
- Multiple streams over one connection
- Binary protocol (not text)
- Server push
- Header compression (HPACK)
- Stream prioritization

---

## Email Protocols

### Email System Architecture

```
Sender MUA → MSA → MTA → MDA → Recipient MUA
   (client)  (smtp) (relay)  (pop/imap)
```

**Components:**
- **MUA (Mail User Agent):** Client (Outlook, Thunderbird)
- **MSA (Mail Submission Agent):** Port 587
- **MTA (Mail Transfer Agent):** Port 25
- **MDA (Mail Delivery Agent):** Stores in mailbox

### SMTP (Simple Mail Transfer Protocol)

**Purpose:** Sending email between servers.

**Commands:**
- `HELO/EHLO`: Identify sender
- `MAIL FROM`: Sender address
- `RCPT TO`: Recipient address
- `DATA`: Start message
- `QUIT`: End session

**SMTP Conversation:**
```
220 mail.example.com ESMTP
HELO sender.example.com
250 Hello sender.example.com
MAIL FROM:<alice@example.com>
250 Sender OK
RCPT TO:<bob@example.org>
250 Recipient OK
DATA
354 Send message; end with .
Subject: Hello
...
.
250 OK
QUIT
221 Bye
```

### POP3 (Post Office Protocol version 3)

**Purpose:** Download email from server.

**Characteristics:**
- Download-and-delete model
- Local storage only
- Limited folder support
- Port 110 (plain) or 995 (TLS)

**Commands:**
- `USER`: Username
- `PASS`: Password
- `LIST`: List messages
- `RETR`: Retrieve message
- `DELE`: Delete message
- `QUIT`: End session

### IMAP (Internet Message Access Protocol)

**Purpose:** Access and manage email on server.

**Characteristics:**
- Server-side storage
- Multiple folders
- Multi-device sync
- Server-side search
- Port 143 (plain) or 993 (TLS)

**IMAP Features:**
- Folder synchronization
- Message flags (seen, answered, deleted)
- Partial downloads
- Concurrent access

### POP3 vs. IMAP

| Feature | POP3 | IMAP |
|---------|------|------|
| Storage | Local | Server |
| Folders | No | Yes |
| Multi-device | Limited | Full sync |
| Server search | No | Yes |
| Bandwidth | Full messages | Partial possible |

---

## SNMP (Simple Network Management Protocol)

### What Is SNMP?

- Used for network monitoring and management
- Manager-agent architecture
- Uses UDP ports 161 and 162

### SNMP Architecture

```
NMS (Manager) ←→ Router (Agent)
    │             Switch (Agent)
    │             Server (Agent)
```

### MIB and OID

**MIB (Management Information Base):**
- Data dictionary for managed objects
- Hierarchical structure

**OID (Object Identifier):**
- Unique identifier for each data point
- Example: `.1.3.6.1.2.1.1.1.0` = system description

### SNMP Operations

| Operation | Direction | Purpose |
|-----------|-----------|---------|
| GET | Manager → Agent | Retrieve value |
| GETNEXT | Manager → Agent | Retrieve next OID |
| GETBULK | Manager → Agent | Retrieve many OIDs |
| SET | Manager → Agent | Change value |
| TRAP | Agent → Manager | Unsolicited event |
| INFORM | Agent → Manager | Acknowledged trap |

### SNMP Versions

| Version | Security | Authentication | Privacy |
|---------|----------|---------------|---------|
| v1 | Minimal | Community string | None |
| v2c | Minimal | Community string | None |
| v3 | Strong | MD5/SHA | DES/AES |

---

# PART 5: MODERN WEB SECURITY & PACKET ANALYSIS

## Cryptography Fundamentals

### Symmetric Encryption

**Definition:** Same key for encryption and decryption.

**Characteristics:**
- Fast and efficient
- Key distribution problem
- Algorithms: AES, ChaCha20

**Example:**
```
Plaintext: "Hello, World!"
    │
    ▼
Encryption (AES) with key "secret"
    │
    ▼
Ciphertext: "a7b3c9d1e5f8..."
    │
    ▼
Decryption (AES) with same key
    │
    ▼
Plaintext: "Hello, World!"
```

### Asymmetric Encryption

**Definition:** Key pair (public and private).

**Characteristics:**
- Slow but secure
- No key distribution problem
- Algorithms: RSA, ECC

**Example:**
- Public key (encryption)
- Private key (decryption)

### Hashing

**Definition:** One-way function producing fixed-size output.

**Properties:**
- Deterministic
- One-way
- Collision-resistant
- Algorithms: SHA-256, SHA-384, SHA-512

### Digital Signatures

- Hash message
- Encrypt hash with private key
- Verify with public key

**Purposes:**
- Authentication
- Integrity
- Non-repudiation

### PKI (Public Key Infrastructure)

**Components:**
- **Root CA:** Trust anchor
- **Intermediate CA:** Signed by root
- **Leaf Certificate:** Server certificate

**Certificate Chain:**
```
Leaf Certificate ← Intermediate CA ← Root CA
(example.com)     (Signed by root)  (Trusted)
```

---

## TLS (Transport Layer Security)

### What Is TLS?

- Provides secure communication
- Encryption, authentication, integrity
- Replaced SSL

### TLS 1.3 vs. 1.2

| Feature | TLS 1.2 | TLS 1.3 |
|---------|---------|---------|
| Handshake | 2 RTT | 1 RTT |
| Cipher Suites | Many (some weak) | Few (all strong) |
| PFS | Optional | Mandatory |
| 0-RTT | No | Yes |
| Deprecated | Compression, renegotiation | - |

### TLS 1.3 Handshake

```
Client                                    Server
  │                                          │
  1. ClientHello                             │
     ├─ Cipher suites                        │
     ├─ Key share (ECDHE)                   │
     └─ ALPN: http/1.1, h2                  │
  ├─────────────────────────────────────────►│
  │                                          │
  2. ServerHello                             │
     ├─ Selected cipher suite                │
     ├─ Key share (ECDHE)                   │
     └─ EncryptedExtensions:                 │
         ├─ ALPN: h2                        │
         └─ Certificate                     │
  │◄─────────────────────────────────────────┤
  │                                          │
  3. Client finishes                         │
     ├─ Verify certificate                   │
     ├─ Compute shared secret               │
     └─ Finished                            │
  ├─────────────────────────────────────────►│
  │                                          │
  4. Server finishes                         │
     ├─ Verify Finished                     │
     └─ Application Data                    │
  │◄─────────────────────────────────────────┤
  │                                          │
  │        [HANDSHAKE COMPLETE]              │
```

### Perfect Forward Secrecy (PFS)

**Definition:** Compromise of long-term keys doesn't compromise past sessions.

**How It Works:**
- Session keys derived from ephemeral keys
- Ephemeral keys discarded after use
- Algorithms: ECDHE, DHE

**Without PFS:**
- Private key compromise decrypts all past traffic

**With PFS:**
- Past sessions remain secure

### Certificate Validation

**Validation Steps:**
1. **Certificate Chain:** Leaf → Intermediate → Root
2. **Validity Period:** Not Before < Now < Not After
3. **Revocation Status:** OCSP, CRL
4. **Domain Match:** SAN, CN
5. **Key Usage:** Digital Signature, Server Auth

### ALPN (Application-Layer Protocol Negotiation)

**Purpose:** Negotiate application protocol during TLS handshake.

**Supported Protocols:**
- `http/1.1`
- `h2` (HTTP/2)
- `h3` (HTTP/3)

---

## HTTP/3 and QUIC

### Why QUIC?

**TCP Limitations:**
- Head-of-line blocking
- Connection migration breaks
- Handshake takes 2-3 RTT
- Fixed congestion control

**QUIC Solutions:**
- Independent streams
- Connection ID persists
- 0-1 RTT handshake
- Pluggable congestion control

### QUIC Architecture

```
Application (HTTP/3)
       │
QUIC Streams (multiple independent)
       │
QUIC Frames (STREAM, ACK, etc.)
       │
TLS 1.3 (Encryption & Authentication)
       │
QUIC Packets (Version, Connection ID)
       │
UDP (Port 443)
```

### QUIC Features

**Stream Multiplexing:**
- Independent streams
- No head-of-line blocking
- Per-stream flow control

**Connection Migration:**
- Connection ID persists across IP changes
- Seamless network transitions
- Mobile-friendly

**0-RTT Resumption:**
- Initial connection: 1-RTT
- Subsequent: 0-RTT (send data immediately)

### HTTP/3

- HTTP over QUIC
- Same semantics as HTTP/2
- Better performance
- Lower latency
- Better loss recovery

---

## Packet Analysis

### Essential Tools

**Command-Line:**
- `tcpdump`: Packet capture
- `tshark`: Packet analysis
- `tcpflow`: TCP stream reconstruction

**GUI:**
- `wireshark`: Full-featured analyzer

### Wireshark Essentials

**Capture Filters (BPF):**
```
host 192.168.1.10
port 80
tcp and port 22
not arp
```

**Display Filters:**
```
http.request.method == "GET"
tcp.flags.syn == 1
dns.qry.name contains "example"
tls.handshake.type == 1
```

**Follow Stream:**
- TCP Stream: Complete conversation
- HTTP Stream: Request + Response
- TLS Stream: Decrypted (with keylog)

**Expert Information:**
- Errors: Malformed packets, checksum errors
- Warnings: Retransmissions, dup ACKs
- Notes: Conversation IDs

### TCP Stream Analysis

**Metrics:**
1. **Retransmissions:** Network congestion/packet loss
2. **Duplicate ACKs:** Out-of-order delivery
3. **Window Scaling:** Throughput impact
4. **RTT:** Network latency
5. **Zero Window:** Receiver buffer full

---

## Network Troubleshooting

### Common Problems

1. **Slow Website:**
   - DNS lookup time
   - Network latency
   - TCP handshake time
   - TLS handshake time
   - Server response time

2. **DNS Failure:**
   - DNS server reachability
   - DNS record existence
   - Cache poisoning
   - DNSSEC issues

3. **Connectivity Issues:**
   - Physical layer (cables, link)
   - IP configuration
   - Routing
   - Firewall

4. **Performance Issues:**
   - Bandwidth saturation
   - High latency
   - Packet loss
   - MTU issues

### Troubleshooting Commands

| Command | Purpose |
|---------|---------|
| `ping` | Basic connectivity |
| `traceroute` | Path mapping |
| `nslookup/dig` | DNS resolution |
| `curl` | HTTP tests |
| `tcpdump` | Packet capture |
| `netstat/ss` | Connection status |
| `iptables` | Firewall rules |
| `openssl s_client` | TLS testing |

### Troubleshooting Methodology

1. **Define the Problem**
2. **Gather Information**
3. **Isolate the Issue** (Half-split method)
4. **Identify Root Cause**
5. **Implement Solution**
6. **Verify Resolution**
7. **Document Findings**

---

# COMMON REFERENCE TABLES

## Well-Known Ports

| Port | Protocol | Service |
|------|----------|---------|
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
| 143 | TCP | IMAP |
| 161 | UDP | SNMP |
| 162 | UDP | SNMP Trap |
| 443 | TCP | HTTPS |
| 465 | TCP | SMTPS |
| 993 | TCP | IMAPS |
| 995 | TCP | POP3S |

## EtherType Values

| EtherType | Protocol |
|-----------|----------|
| 0x0800 | IPv4 |
| 0x0806 | ARP |
| 0x86DD | IPv6 |
| 0x8100 | VLAN (802.1Q) |
| 0x8809 | EAPOL |
| 0x888E | EAP over LAN |
| 0x88CC | LLDP |

## TCP Flags

| Flag | Bit | Name |
|------|-----|------|
| FIN | 0 | Finish |
| SYN | 1 | Synchronize |
| RST | 2 | Reset |
| PSH | 3 | Push |
| ACK | 4 | Acknowledgment |
| URG | 5 | Urgent |

## HTTP Status Codes

| Code | Name |
|------|------|
| 200 | OK |
| 201 | Created |
| 301 | Moved Permanently |
| 302 | Found |
| 304 | Not Modified |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

---

**END OF STUDENT NOTES**
