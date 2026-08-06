# Part 2: The Network Layer & Diagnostics

## Mapping the Globe and Keeping Networks Healthy: IP, Routing, and ICMP

---

## Synopsis

Once a device joins the local network, packets must travel across routers and interconnected networks to reach their destination. This tutorial explores Internet Protocol (IP), the addressing schemes that enable global connectivity, and the diagnostic protocols used by engineers to troubleshoot networks.

Readers will learn how routers make forwarding decisions, how subnetting improves scalability, why fragmentation occurs, and how ICMP provides essential feedback for network diagnostics.

By the end of this part, you'll understand how packets traverse the global Internet and how to diagnose common network problems using ICMP-based tools.

---

## Prerequisites

Before starting Part 2, ensure you have:
1. **Completed Part 1** or have equivalent knowledge of Ethernet, ARP, and DHCP
2. **Wireshark** installed and working
3. **Python 3.8+** with Scapy installed (`pip install scapy`)
4. **Network access** to the Internet (for traceroute and ping exercises)
5. **Root/Administrator privileges** for packet capture

---

## Part 2 Roadmap

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 2: NETWORK LAYER                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. IPv4 Fundamentals                                       │
│     ├─ IPv4 Packet Structure                                │
│     ├─ Header Fields Explained                              │
│     ├─ Fragmentation & MTU                                 │
│     └─ IP Addressing & CIDR Notation                       │
│                                                             │
│  2. IPv4 Addressing in Depth                                │
│     ├─ Private vs Public Addressing                        │
│     ├─ NAT (Network Address Translation)                   │
│     ├─ Subnetting & VLSM                                   │
│     └─ Reserved Address Ranges                             │
│                                                             │
│  3. IPv6 Fundamentals                                       │
│     ├─ IPv6 Address Structure                               │
│     ├─ Prefixes & Address Types                            │
│     ├─ SLAAC (Stateless Address Autoconfiguration)         │
│     └─ Transition Mechanisms (Dual Stack, Tunneling)      │
│                                                             │
│  4. Routing Concepts                                        │
│     ├─ Routing Tables                                       │
│     ├─ Default Gateway                                      │
│     ├─ Static vs Dynamic Routing                           │
│     └─ Longest Prefix Match                                │
│                                                             │
│  5. ICMP: Internet Control Message Protocol                 │
│     ├─ ICMP Message Types                                   │
│     ├─ Echo Request/Reply (Ping)                           │
│     ├─ Destination Unreachable                              │
│     ├─ TTL Exceeded (Traceroute)                          │
│     └─ Path MTU Discovery                                  │
│                                                             │
│  6. Hands-On Labs                                           │
│     ├─ Lab 1: Analyze IPv4 Headers                         │
│     ├─ Lab 2: Perform Subnet Calculations                  │
│     ├─ Lab 3: Trace Packet Paths with Traceroute          │
│     ├─ Lab 4: Capture ICMP Traffic                         │
│     └─ Lab 5: Build an IP Packet Decoder                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 1: IPv4 Fundamentals

### What is IPv4?

**Internet Protocol version 4 (IPv4)** is the primary protocol that delivers packets across the Internet. It provides:
- **Addressing**: Each device gets a unique 32-bit address
- **Routing**: Packets are forwarded through routers based on destination addresses
- **Fragmentation**: Large packets are split to fit smaller network links
- **Best-effort delivery**: No guarantees; reliability is handled by higher layers (TCP)

### The IPv4 Packet Structure

Every IPv4 packet has a header followed by the payload. Let's examine each field in detail:

```
┌─────────────────────────────────────────────────────────────────┐
│                    IPv4 HEADER (20-60 bytes)                    │
├───────────────────┬─────────────────────────────────────────────┤
│                   │                                             │
│  0-3 bits: Version│  4-7 bits: IHL (Internet Header Length)    │
│  8-15 bits: DSCP  │  16-31 bits: Total Length                  │
│                   │                                             │
│  32-47 bits: Identification                                    │
│  48-51 bits: Flags  │  52-63 bits: Fragment Offset             │
│  64-71 bits: TTL   │  72-79 bits: Protocol                    │
│  80-95 bits: Header Checksum                                   │
│  96-127 bits: Source IP Address                                │
│  128-159 bits: Destination IP Address                          │
│  160-... bits: Options (optional)                              │
│  ... bits: Payload                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Detailed Field Explanations**:

| Field | Size | Description |
|-------|------|-------------|
| **Version** | 4 bits | IPv4 = 4, IPv6 = 6 |
| **IHL** | 4 bits | Internet Header Length (in 32-bit words). Minimum 5 (20 bytes), maximum 15 (60 bytes) |
| **DSCP** | 6 bits | Differentiated Services Code Point - Quality of Service marking |
| **ECN** | 2 bits | Explicit Congestion Notification - Signals network congestion |
| **Total Length** | 16 bits | Entire packet size in bytes (header + payload). Maximum 65,535 bytes |
| **Identification** | 16 bits | Unique identifier for fragments of the same packet |
| **Flags** | 3 bits | DF (Don't Fragment), MF (More Fragments), Reserved |
| **Fragment Offset** | 13 bits | Position of this fragment in the original packet (in 8-byte units) |
| **TTL** | 8 bits | Time To Live - Decremented by each router; packet discarded when 0 |
| **Protocol** | 8 bits | Next layer protocol (6 = TCP, 17 = UDP, 1 = ICMP, 2 = IGMP) |
| **Header Checksum** | 16 bits | Error check for header only (payload has its own checksums) |
| **Source IP** | 32 bits | Sender's IP address |
| **Destination IP** | 32 bits | Recipient's IP address |
| **Options** | variable | Rarely used; includes security, timestamp, routing options |
| **Payload** | variable | The actual data being carried (TCP segment, UDP datagram, etc.) |

**Key Insight**: The IPv4 header is critical for routing. Each router reads the destination IP address, consults its routing table, and forwards the packet toward the destination.

### Fragmentation and MTU

**MTU (Maximum Transmission Unit)** is the largest packet size a network link can transmit. Standard Ethernet MTU is 1500 bytes. When a packet is too large for a link, it must be **fragmented**:

```
┌─────────────────────────────────────────────────────────────┐
│                    FRAGMENTATION PROCESS                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Original Packet (4000 bytes):                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  IP Header │            Payload                        ││
│  │   (20)     │            (3980)                         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
│        ↓ Fragmentation at MTU 1500                         │
│                                                             │
│  Fragment 1 (1500 bytes):                                   │
│  ┌────────────┬────────────────────────────────────────────┐│
│  │ IP Header  │        Payload (1480 bytes)              ││
│  │ MF=1, Off=0│                                           ││
│  └────────────┴────────────────────────────────────────────┘│
│                                                             │
│  Fragment 2 (1500 bytes):                                   │
│  ┌────────────┬────────────────────────────────────────────┐│
│  │ IP Header  │        Payload (1480 bytes)              ││
│  │ MF=1, Off=185│                                         ││
│  └────────────┴────────────────────────────────────────────┘│
│                                                             │
│  Fragment 3 (1020 bytes):                                   │
│  ┌────────────┬────────────────────────────────────────────┐│
│  │ IP Header  │        Payload (1000 bytes)              ││
│  │ MF=0, Off=370│                                         ││
│  └────────────┴────────────────────────────────────────────┘│
│                                                             │
│  The destination reassembles fragments using:               │
│  ├─ Identification: Same value in all fragments            │
│  ├─ Fragment Offset: Order of fragments                    │
│  └─ MF flag: 1 = More fragments, 0 = Last fragment        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Important**:
- The **DF (Don't Fragment)** flag prevents fragmentation. If a packet with DF set exceeds the MTU, it's dropped, and an ICMP "Fragmentation Needed" message is sent.
- **Path MTU Discovery** uses this mechanism to find the smallest MTU along a path.
- Fragmentation is undesirable because it increases overhead and decreases performance.

### IP Addressing and CIDR Notation

**IPv4 addresses** are 32-bit numbers, typically written as four decimal octets:
```
192.168.1.10
```

**Binary representation**:
```
11000000.10101000.00000001.00001010
```

**CIDR (Classless Inter-Domain Routing)** notation specifies the network prefix length:
```
192.168.1.10/24
```
This means the first 24 bits are the network, and the remaining 8 bits are for hosts.

**Network vs Host portions**:
```
192.168.1.10/24
Network:  192.168.1.0 (first 24 bits)
Hosts:    192.168.1.1 - 192.168.1.254
Broadcast: 192.168.1.255
```

---

## Section 2: IPv4 Addressing in Depth

### Private vs Public Addressing

**Public IP addresses** are globally unique and routable on the Internet. **Private IP addresses** are reserved for internal networks and are not routed on the public Internet.

**RFC 1918 Private Address Ranges**:

| Range | CIDR | Number of Addresses | Use Case |
|-------|------|-------------------|----------|
| 10.0.0.0 - 10.255.255.255 | 10.0.0.0/8 | 16,777,216 | Large enterprise networks |
| 172.16.0.0 - 172.31.255.255 | 172.16.0.0/12 | 1,048,576 | Medium networks |
| 192.168.0.0 - 192.168.255.255 | 192.168.0.0/16 | 65,536 | Small/home networks |

**Special-Purpose Addresses**:

| Address | Purpose |
|---------|---------|
| 0.0.0.0/8 | "This host" - used for default routes and DHCP |
| 127.0.0.0/8 | Loopback - local host (127.0.0.1 is localhost) |
| 169.254.0.0/16 | Link-Local - APIPA (Automatic Private IP Addressing) |
| 224.0.0.0/4 | Multicast addresses |
| 255.255.255.255 | Limited broadcast (never forwarded) |

### NAT (Network Address Translation)

**NAT** allows multiple devices on a private network to share a single public IP address when accessing the Internet.

```
┌─────────────────────────────────────────────────────────────┐
│                    NAT ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Internal Network (192.168.1.0/24)                         │
│  ┌──────────────┐                                          │
│  │ PC1: 192.168.1.10│                                      │
│  └──────────────┘                                          │
│         │                                                   │
│  ┌──────────────┐                                          │
│  │ PC2: 192.168.1.20│                                      │
│  └──────────────┘                                          │
│         │                                                   │
│  ┌──────────────┐                                          │
│  │ PC3: 192.168.1.30│                                      │
│  └──────────────┘                                          │
│         │                                                   │
│    ┌─────┴─────┐                                           │
│    │  Router   │  NAT Table:                               │
│    │  (NAT)    │  ┌────────────────────────────────────┐   │
│    │ Public:   │  │ Internal IP:Port | External Port │   │
│    │ 203.0.113.5│  │ 192.168.1.10:12345 | 60001      │   │
│    └───────────┘  │ 192.168.1.20:12346 | 60002      │   │
│         │          │ 192.168.1.30:12347 | 60003      │   │
│         │          └────────────────────────────────────┘   │
│         ▼                                                   │
│    ┌─────────────┐                                         │
│    │  Internet   │  All three PCs share the same           │
│    └─────────────┘  public IP: 203.0.113.5                │
│                                                             │
│  NAT Types:                                                 │
│  ├─ Source NAT (SNAT): Changes source IP on outgoing       │
│  ├─ Destination NAT (DNAT): Changes destination IP         │
│  └─ Port Address Translation (PAT): Maps many-to-one       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Subnetting and VLSM

**Subnetting** divides a network into smaller, manageable pieces. **VLSM (Variable Length Subnet Masking)** allows different subnet masks within the same network.

**Example: Subnetting 192.168.1.0/24 into 4 subnets**:

```
Original Network: 192.168.1.0/24
Subnet Mask: 255.255.255.0
Hosts: 254 (192.168.1.1 - 192.168.1.254)

Borrow 2 bits for subnets (2^2 = 4 subnets):
Subnet Mask: 255.255.255.192 (/26)

┌─────────────────────────────────────────────────────────────┐
│ Subnet 1: 192.168.1.0/26                                   │
│   ├─ Network: 192.168.1.0                                 │
│   ├─ Host Range: 192.168.1.1 - 192.168.1.62              │
│   └─ Broadcast: 192.168.1.63                              │
│                                                             │
│ Subnet 2: 192.168.1.64/26                                  │
│   ├─ Network: 192.168.1.64                                │
│   ├─ Host Range: 192.168.1.65 - 192.168.1.126             │
│   └─ Broadcast: 192.168.1.127                             │
│                                                             │
│ Subnet 3: 192.168.1.128/26                                 │
│   ├─ Network: 192.168.1.128                               │
│   ├─ Host Range: 192.168.1.129 - 192.168.1.190            │
│   └─ Broadcast: 192.168.1.191                             │
│                                                             │
│ Subnet 4: 192.168.1.192/26                                 │
│   ├─ Network: 192.168.1.192                               │
│   ├─ Host Range: 192.168.1.193 - 192.168.1.254            │
│   └─ Broadcast: 192.168.1.255                             │
└─────────────────────────────────────────────────────────────┘
```

### Subnetting Calculation Reference

| CIDR | Subnet Mask | Number of Addresses | Usable Hosts |
|------|-------------|--------------------|--------------|
| /8 | 255.0.0.0 | 16,777,216 | 16,777,214 |
| /16 | 255.255.0.0 | 65,536 | 65,534 |
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |
| /32 | 255.255.255.255 | 1 | 1 (host route) |

---

## Section 3: IPv6 Fundamentals

### Why IPv6?

**IPv6** was developed to address IPv4's limitations:
- **Address exhaustion**: IPv4 has only 4.3 billion addresses; IPv6 has 340 undecillion (3.4×10^38)
- **Simplified header**: Fixed 40-byte header, no fragmentation in the header
- **Built-in security**: IPsec is mandatory
- **No NAT**: End-to-end connectivity restored
- **Auto-configuration**: SLAAC for plug-and-play networking

### IPv6 Address Structure

IPv6 addresses are 128 bits, written as 8 groups of 4 hexadecimal digits:

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

**Rules for shortening**:
1. Leading zeros in each group can be omitted: `2001:db8:85a3:0:0:8a2e:370:7334`
2. Consecutive groups of zeros can be compressed to `::` (once per address):
   `2001:db8:85a3::8a2e:370:7334`

**Structure**:
```
┌─────────────────────────────────────────────────────────────┐
│                    IPv6 ADDRESS STRUCTURE                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  2001:0db8:85a3:0000:0000:8a2e:0370:7334                  │
│  │    │    │    │    │    │    │    │                       │
│  │    │    │    │    │    │    │    └─ Interface ID       │
│  │    │    │    │    │    │    └────── Interface ID       │
│  │    │    │    │    │    └─────────── Interface ID       │
│  │    │    │    │    └─────────────── Subnet ID          │
│  │    │    │    └──────────────────── Subnet ID          │
│  │    │    └───────────────────────── Global Routing Prefix│
│  │    └────────────────────────────── Global Routing Prefix│
│  └─────────────────────────────────── Global Routing Prefix│
│                                                             │
│  First 48 bits: Global Routing Prefix (assigned by RIR)   │
│  Next 16 bits: Subnet ID (for internal subnetting)        │
│  Last 64 bits: Interface ID (host identifier)             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### IPv6 Address Types

| Address Type | Prefix | Description |
|--------------|--------|-------------|
| **Global Unicast** | 2000::/3 | Public IPv6 addresses (routable on Internet) |
| **Link-Local** | fe80::/10 | Auto-configured local addresses (like 169.254.x.x) |
| **Unique Local** | fc00::/7 | Private IPv6 addresses (like RFC 1918) |
| **Multicast** | ff00::/8 | Group communication |
| **Anycast** | varies | One-to-nearest (multiple devices, same address) |
| **Loopback** | ::1/128 | Local host (like 127.0.0.1) |
| **Unspecified** | ::/128 | "This host" (like 0.0.0.0) |

### SLAAC (Stateless Address Autoconfiguration)

**SLAAC** allows IPv6 devices to auto-configure their addresses without DHCP:

```
┌─────────────────────────────────────────────────────────────┐
│                    SLAAC PROCESS                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Device generates a Link-Local Address:                 │
│     └─ fe80::<interface_id>                                │
│                                                             │
│  2. Device sends a Neighbor Solicitation to verify it's    │
│     unique (Duplicate Address Detection)                   │
│                                                             │
│  3. Router sends Router Advertisement (RA) with prefix:    │
│     └─ "2001:db8:1::/64"                                  │
│                                                             │
│  4. Device combines prefix + interface ID:                 │
│     └─ 2001:db8:1::<interface_id>                         │
│                                                             │
│  5. (Optional) DNS information via RDNSS (RFC 8106)       │
│                                                             │
│  Interface ID can be:                                       │
│  ├─ EUI-64: Derived from MAC address (flips 7th bit)      │
│  └─ Random: Privacy Extensions (RFC 4941)                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Transition Mechanisms

Transitioning from IPv4 to IPv6 requires coexistence:

| Mechanism | Description |
|-----------|-------------|
| **Dual Stack** | Devices run both IPv4 and IPv6 simultaneously |
| **6to4** | Encapsulates IPv6 in IPv4 packets |
| **Teredo** | Tunnels IPv6 over UDP through NAT |
| **NAT64/DNS64** | Translates between IPv6 and IPv4 |
| **DS-Lite** | IPv6-only core with IPv4 as a service |

---

## Section 4: Routing Concepts

### How Routing Works

**Routing** is the process of forwarding packets from one network to another. Routers use **routing tables** to make forwarding decisions:

```
┌─────────────────────────────────────────────────────────────┐
│                    ROUTING TABLE EXAMPLE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  $ ip route show                                            │
│                                                             │
│  default via 192.168.1.1 dev eth0                          │
│  10.0.0.0/8 via 10.0.0.1 dev eth1                         │
│  192.168.1.0/24 dev eth0 proto kernel scope link           │
│  192.168.2.0/24 dev eth2 proto kernel scope link           │
│                                                             │
│  Fields:                                                    │
│  ├─ Destination: Network or host address                   │
│  ├─ Gateway: Next hop router (or "via")                   │
│  ├─ Interface: Which network interface to use              │
│  ├─ Metric: Cost preference (lower is better)             │
│  └─ Scope: Link-local, global, etc.                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### The Routing Decision Process

When a router receives a packet, it:
1. Extracts the destination IP address
2. Searches its routing table for the **longest prefix match**
3. Forwards the packet to the next hop
4. Decrements the TTL (discards if TTL reaches 0)

```
┌─────────────────────────────────────────────────────────────┐
│                    LONGEST PREFIX MATCH                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Routing Table:                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Destination     │ Gateway       │ Interface          ││
│  ├────────────────────────────────────────────────────────┤│
│  │ 10.0.0.0/8      │ 10.0.0.1      │ eth1              ││
│  │ 10.1.0.0/16     │ 10.1.0.1      │ eth2              ││
│  │ 0.0.0.0/0       │ 192.168.1.1   │ eth0 (default)    ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Packet for 10.1.2.3:                                       │
│  ├─ Matches 10.0.0.0/8 (8 bits)                           │
│  ├─ Matches 10.1.0.0/16 (16 bits) - LONGEST MATCH        │
│  └─ Forward via 10.1.0.1 on eth2                          │
│                                                             │
│  Default route (0.0.0.0/0) matches everything but has      │
│  the shortest prefix (0 bits) - used when no better match │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Static vs Dynamic Routing

| Type | Description | Advantages | Disadvantages |
|------|-------------|------------|---------------|
| **Static Routing** | Manually configured routes | Simple, predictable, no overhead | Doesn't adapt to changes, doesn't scale |
| **Dynamic Routing** | Routers automatically exchange routes | Adapts to failures, scales | More complex, adds overhead |

**Common Dynamic Routing Protocols**:
- **RIP (Routing Information Protocol)**: Simple distance-vector (hops)
- **OSPF (Open Shortest Path First)**: Link-state (fast convergence)
- **BGP (Border Gateway Protocol)**: Path-vector (Internet routing)

### Default Gateway

The **default gateway** is a router that handles traffic destined for networks not in the local routing table:

```
┌─────────────────────────────────────────────────────────────┐
│                    DEFAULT GATEWAY                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Host 192.168.1.10 with default gateway 192.168.1.1       │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Host routing table:                                  ││
│  │  ├─ 127.0.0.0/8 -> local                             ││
│  │  ├─ 192.168.1.0/24 -> eth0 (local subnet)           ││
│  │  └─ 0.0.0.0/0 -> 192.168.1.1 (default gateway)     ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  When accessing 8.8.8.8:                                   │
│  1. Check for specific routes: none match                  │
│  2. Use default route: 192.168.1.1                         │
│  3. ARP for 192.168.1.1 to get MAC address                │
│  4. Send packet to gateway                                │
│  5. Gateway makes its own routing decision               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 5: ICMP: Internet Control Message Protocol

### What is ICMP?

**ICMP (Internet Control Message Protocol)** is the diagnostic and error-reporting protocol of the IP suite. It's used by network devices to communicate problems and test connectivity.

**Key Insight**: ICMP is not a transport protocol like TCP or UDP. It's carried directly in IP packets (protocol number 1) and is used for control and diagnostic messages.

### ICMP Message Types

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Response to an Echo Request (ping response) |
| 3 | Destination Unreachable | Network, host, or port unreachable |
| 4 | Source Quench | Slow down sending (deprecated) |
| 5 | Redirect | Better route available |
| 8 | Echo Request | Ping request |
| 9 | Router Advertisement | Router discovery |
| 10 | Router Solicitation | Router discovery |
| 11 | Time Exceeded | TTL expired (traceroute uses this) |
| 12 | Parameter Problem | Bad IP header |
| 13 | Timestamp Request | Request timestamp |
| 14 | Timestamp Reply | Timestamp response |
| 17 | Address Mask Request | Request subnet mask |
| 18 | Address Mask Reply | Subnet mask response |
| 30 | Traceroute | Traceroute (obsolete) |

### Echo Request/Reply (Ping)

**Ping** uses ICMP Echo Request (Type 8) and Echo Reply (Type 0) to test reachability:

```
┌─────────────────────────────────────────────────────────────┐
│                    PING OPERATION                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Host A (192.168.1.10)                 Host B (8.8.8.8)   │
│          │                                │                 │
│          │  ICMP Echo Request (Type 8)   │                 │
│          │  ├─ Identifier: 1234         │                 │
│          │  ├─ Sequence: 1              │                 │
│          │  └─ Payload: "Hello!"        │                 │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│          │  ICMP Echo Reply (Type 0)     │                 │
│          │  ├─ Identifier: 1234         │                 │
│          │  ├─ Sequence: 1              │                 │
│          │  └─ Payload: "Hello!"        │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  Round Trip Time (RTT)        │                 │
│          │  └─ Time sent - Time received │                 │
│          │                                │                 │
└─────────────────────────────────────────────────────────────┘
```

**Ping Output Explanation**:
```bash
$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=12.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=11.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=12.1 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 11.8/12.0/12.3/0.2 ms
```

### Destination Unreachable (Type 3)

ICMP Destination Unreachable messages help diagnose routing problems:

| Code | Name | Description |
|------|------|-------------|
| 0 | Network Unreachable | Router can't reach the network |
| 1 | Host Unreachable | Router can't reach the host |
| 2 | Protocol Unreachable | Protocol not supported |
| 3 | Port Unreachable | Port not open (UDP) |
| 4 | Fragmentation Needed | Packet too large, DF set |
| 5 | Source Route Failed | Source routing failed |
| 6 | Destination Network Unknown | Network doesn't exist |
| 7 | Destination Host Unknown | Host doesn't exist |
| 8 | Source Host Isolated | Source host isolated |
| 9 | Communication with Destination Network Prohibited | Admin restriction |
| 10 | Communication with Destination Host Prohibited | Admin restriction |
| 13 | Communication with Destination Administratively Prohibited | Policy restriction |
| 14 | Host Precedence Violation | Precedence error |

### TTL Exceeded and Traceroute

**Traceroute** works by sending packets with incrementing TTL values:

```
┌─────────────────────────────────────────────────────────────┐
│                    TRACEROUTE OPERATION                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Host (192.168.1.10)   Router1   Router2   Router3   Dest │
│          │                │         │         │         │    │
│  1. TTL=1 UDP            │         │         │         │    │
│     ├──────────────────►│         │         │         │    │
│                          │  ICMP Time Exceeded             │    │
│     │◄──────────────────┤         │         │         │    │
│      "Router1 at 192.168.1.1 (1.2 ms)"                   │    │
│          │                │         │         │         │    │
│  2. TTL=2 UDP            │         │         │         │    │
│     ├──────────────────►├────────►│         │         │    │
│                          │         │  ICMP Time Exceeded │    │
│     │◄──────────────────┼─────────┤         │         │    │
│      "Router2 at 10.0.0.1 (5.6 ms)"                    │    │
│          │                │         │         │         │    │
│  3. TTL=3 UDP            │         │         │         │    │
│     ├──────────────────►├────────►├────────►│         │    │
│                          │         │         │  ICMP Port   │
│     │◄──────────────────┼─────────┼─────────┤  Unreachable │
│      "Destination at 8.8.8.8 (12.3 ms)"                 │    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Path MTU Discovery

**Path MTU Discovery** uses ICMP to find the largest packet size that can traverse a path without fragmentation:

```
┌─────────────────────────────────────────────────────────────┐
│                    PATH MTU DISCOVERY                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Host (1500 MTU)        Router1    Router2   Dest (1500)  │
│          │                │          │         │           │
│  1. Send 1500-byte       │          │         │           │
│     packet with DF=1     │          │         │           │
│     ├──────────────────►│          │         │           │
│                          │  MTU 1400 (DSL link)          │
│                          │  Packet is too large!         │
│                          │          │         │           │
│  2. ICMP Fragmentation   │          │         │           │
│     Needed (Type 3,      │          │         │           │
│     Code 4) with MTU=1400│          │         │           │
│     │◄──────────────────┤          │         │           │
│          │                │          │         │           │
│  3. Send 1400-byte       │          │         │           │
│     packet (works!)      │          │         │           │
│     ├──────────────────►├────────►├────────►│           │
│          │                │          │         │           │
│  PMTU = 1400 bytes (cached for 10 minutes)               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 6: Hands-On Labs

---

### Lab 1: Analyze IPv4 Headers with Wireshark

**The Target**: Capture IPv4 traffic and examine header fields in detail.

**The Implementation**:

1. **Start Wireshark capture** on your primary interface.

2. **Generate IPv4 traffic**:
   ```bash
   # HTTP traffic to generate packets
   curl -I https://www.google.com
   curl -I https://www.github.com
   curl -I https://www.stackoverflow.com
   ```

3. **Stop the capture** after a few seconds.

4. **Apply an IPv4 filter**:
   ```
   ip.version == 4
   ```

5. **Select a packet** and expand the Internet Protocol section:

   ```
   Internet Protocol Version 4, Src: 192.168.1.10, Dst: 142.250.185.46
       0100 .... = Version: 4
       .... 0101 = Header Length: 20 bytes (5)
       Differentiated Services Field: 0x00 (DSCP: CS0, ECN: Not-ECT)
       Total Length: 92
       Identification: 0x1a2b (6699)
       Flags: 0x4000, Don't fragment
       Fragment Offset: 0
       Time to Live: 64
       Protocol: TCP (6)
       Header Checksum: 0xabcd [validation disabled]
       Source: 192.168.1.10
       Destination: 142.250.185.46
   ```

6. **View header bytes** in hex:

   ```
   0000  45 00 00 5c 1a 2b 40 00 40 06 ab cd c0 a8 01 0a
   0010  8e fa b9 2e 01 bb 00 50 00 00 00 00 00 00 00 00
   ```

**The Verification**:

Run this Python script to decode a pcap file:

```python
#!/usr/bin/env python3
"""
ipv4_decoder.py - Decode IPv4 packets and display header fields
"""

import sys
from scapy.all import rdpcap, IP, TCP, UDP, ICMP

def decode_ipv4(filename):
    """Read and decode IPv4 packets from a pcap file"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    ip_packets = [p for p in packets if IP in p]
    
    if not ip_packets:
        print("No IPv4 packets found in the capture")
        return
    
    print(f"Found {len(ip_packets)} IPv4 packets\n")
    print("=" * 100)
    print(f"{'#':<4} {'Src IP':<16} {'Dst IP':<16} {'TTL':<5} {'Proto':<8} {'Len':<8} {'Flags':<8}")
    print("=" * 100)
    
    for i, packet in enumerate(ip_packets[:20], 1):  # Show first 20
        ip = packet[IP]
        proto_map = {1: 'ICMP', 6: 'TCP', 17: 'UDP'}
        proto = proto_map.get(ip.proto, f'Unknown({ip.proto})')
        
        flags = []
        if ip.flags & 0x02:  # DF bit
            flags.append('DF')
        if ip.flags & 0x01:  # MF bit
            flags.append('MF')
        if not flags:
            flags.append('None')
        flags_str = ','.join(flags)
        
        print(f"{i:<4} {ip.src:<16} {ip.dst:<16} {ip.ttl:<5} {proto:<8} "
              f"{ip.len:<8} {flags_str:<8}")
    
    print("=" * 100)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    decode_ipv4(sys.argv[1])
```

**Run the decoder**:
```bash
python3 ipv4_decoder.py capture.pcap
```

---

### Lab 2: Subnet Calculation Practice

**The Target**: Master subnet calculations with hands-on exercises.

**The Concept**: Practice subnetting by hand, then verify with Python.

**The Implementation**:

Create a subnet calculator in Python:

```python
#!/usr/bin/env python3
"""
subnet_calculator.py - Calculate subnet details from IP and CIDR
"""

import ipaddress
import sys

def calculate_subnet(network_cidr):
    """Calculate and display subnet details"""
    try:
        network = ipaddress.ip_network(network_cidr, strict=False)
    except ValueError as e:
        print(f"Error: Invalid network {network_cidr}")
        print(f"Details: {e}")
        return
    
    print(f"\n{'='*60}")
    print(f"Network: {network_cidr}")
    print(f"{'='*60}")
    print(f"Network Address: {network.network_address}")
    print(f"Broadcast Address: {network.broadcast_address}")
    print(f"Netmask: {network.netmask}")
    print(f"Prefix Length: {network.prefixlen}")
    print(f"Total Addresses: {network.num_addresses}")
    print(f"Usable Hosts: {network.num_addresses - 2}")
    print(f"Host Range: {list(network.hosts())[0]} - {list(network.hosts())[-1]}")
    
    # Show subnet in binary
    ip_bin = ''.join([f"{int(octet):08b}." for octet in str(network.network_address).split('.')])
    mask_bin = ''.join([f"{int(octet):08b}." for octet in str(network.netmask).split('.')])
    print(f"\nBinary Network: {ip_bin[:-1]}")
    print(f"Binary Mask: {mask_bin[:-1]}")

def main():
    """Main entry point"""
    if len(sys.argv) != 2:
        print("Usage: python3 subnet_calculator.py <network/cidr>")
        print("Example: python3 subnet_calculator.py 192.168.1.0/24")
        sys.exit(1)
    
    calculate_subnet(sys.argv[1])

if __name__ == "__main__":
    main()
```

**Run the calculator**:
```bash
python3 subnet_calculator.py 192.168.1.0/24
python3 subnet_calculator.py 10.0.0.0/16
python3 subnet_calculator.py 172.16.0.0/12
```

**Practice Exercises**:
1. Divide 192.168.0.0/24 into 4 equal subnets
2. Calculate the subnet for 10.0.0.1/19
3. Find the broadcast address for 172.16.10.0/22
4. How many hosts in 192.168.1.0/26?

---

### Lab 3: Trace Packet Paths with Traceroute

**The Target**: Use traceroute to map the path to various destinations.

**The Implementation**:

1. **Trace to Google DNS**:
   ```bash
   # Linux
   traceroute -n 8.8.8.8
   
   # macOS
   traceroute -n 8.8.8.8
   
   # Windows
   tracert 8.8.8.8
   ```

2. **Trace to a local server**:
   ```bash
   traceroute -n 192.168.1.1
   ```

3. **Use ICMP instead of UDP** (Linux):
   ```bash
   traceroute -I 8.8.8.8
   ```

4. **Use TCP SYN probes**:
   ```bash
   traceroute -T -p 80 8.8.8.8
   ```

5. **Capture the traffic**:
   ```bash
   sudo tcpdump -i eth0 "icmp and (icmp[icmptype] == 11 or icmp[icmptype] == 3)" -w traceroute.pcap
   ```
   Then run traceroute in another terminal.

6. **Analyze with Wireshark**:
   - Open the capture
   - Follow the TTL sequence
   - Note each router's response

**The Verification**:

Create a Python script to parse traceroute output:

```python
#!/usr/bin/env python3
"""
parse_traceroute.py - Parse and analyze traceroute output
"""

import subprocess
import re
import sys

def run_traceroute(target):
    """Run traceroute and capture output"""
    try:
        result = subprocess.run(
            ['traceroute', '-n', target],
            capture_output=True,
            text=True,
            timeout=60
        )
        return result.stdout
    except subprocess.TimeoutExpired:
        print(f"Traceroute to {target} timed out")
        return None
    except FileNotFoundError:
        print("Error: traceroute command not found")
        return None

def parse_output(output):
    """Parse traceroute output into hops"""
    if not output:
        return []
    
    hops = []
    for line in output.split('\n'):
        if not line.strip() or line.startswith('traceroute'):
            continue
        
        # Split the line by spaces
        parts = line.split()
        if not parts:
            continue
        
        # First part is hop number
        hop_num = parts[0]
        if not hop_num.endswith(':'):
            continue
        hop_num = hop_num[:-1]  # Remove colon
        
        # Subsequent parts are IP addresses and times
        hop_data = {
            'hop': int(hop_num),
            'hosts': [],
            'rtts': []
        }
        
        i = 1
        while i < len(parts):
            # Check if it's an IP address
            if re.match(r'\d+\.\d+\.\d+\.\d+', parts[i]):
                hop_data['hosts'].append(parts[i])
                
                # Check for RTT values
                if i + 1 < len(parts) and re.match(r'\d+\.\d+', parts[i + 1]):
                    hop_data['rtts'].append(float(parts[i + 1]))
                    i += 2
                else:
                    hop_data['rtts'].append(None)
                    i += 1
            elif parts[i] == '*':
                hop_data['hosts'].append('*')
                hop_data['rtts'].append(None)
                i += 1
            else:
                i += 1
        
        hops.append(hop_data)
    
    return hops

def display_hops(hops):
    """Display hops in a formatted table"""
    if not hops:
        print("No hops found")
        return
    
    print("\n" + "=" * 80)
    print(f"{'Hop':<6} {'Host(s)':<40} {'RTT (ms)':<20} {'Status':<10}")
    print("=" * 80)
    
    for hop in hops:
        hosts_str = ', '.join(hop['hosts'])
        rtts_str = ', '.join([str(r) if r is not None else '*' for r in hop['rtts'][:3]])
        status = "✓" if any(r is not None for r in hop['rtts']) else "✗"
        
        print(f"{hop['hop']:<6} {hosts_str:<40} {rtts_str:<20} {status:<10}")
    
    print("=" * 80)

def main():
    """Main entry point"""
    if len(sys.argv) != 2:
        print("Usage: python3 parse_traceroute.py <target>")
        print("Example: python3 parse_traceroute.py 8.8.8.8")
        sys.exit(1)
    
    target = sys.argv[1]
    print(f"Tracing route to {target}...")
    
    output = run_traceroute(target)
    if not output:
        sys.exit(1)
    
    print(output)  # Show raw output
    
    hops = parse_output(output)
    display_hops(hops)

if __name__ == "__main__":
    main()
```

---

### Lab 4: Capture and Analyze ICMP Traffic

**The Target**: Capture ICMP packets and understand each message type.

**The Implementation**:

1. **Start capturing ICMP traffic**:
   ```bash
   sudo tcpdump -i eth0 "icmp" -vv -w icmp.pcap
   ```

2. **Generate ICMP traffic** (in another terminal):
   ```bash
   # Generate Echo Request/Reply
   ping -c 5 8.8.8.8
   
   # Generate TTL Exceeded
   traceroute -n 8.8.8.8
   
   # Generate Port Unreachable (UDP to closed port)
   nc -u -v 8.8.8.8 12345
   ```

3. **Analyze the capture**:
   ```bash
   # Show all ICMP packets
   tshark -r icmp.pcap -Y "icmp"
   
   # Show only Echo Requests
   tshark -r icmp.pcap -Y "icmp.type == 8"
   
   # Show only Echo Replies
   tshark -r icmp.pcap -Y "icmp.type == 0"
   
   # Show TTL Exceeded messages
   tshark -r icmp.pcap -Y "icmp.type == 11"
   
   # Show details of each ICMP message
   tshark -r icmp.pcap -Y "icmp" -V | grep -A 20 "Internet Control Message Protocol"
   ```

**The Verification**:

Run a Python ICMP packet analyzer:

```python
#!/usr/bin/env python3
"""
icmp_analyzer.py - Analyze ICMP packets from a pcap
"""

import sys
from scapy.all import rdpcap, ICMP, IP, ICMP

def analyze_icmp(filename):
    """Analyze ICMP packets and display statistics"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    icmp_packets = [p for p in packets if ICMP in p]
    
    if not icmp_packets:
        print("No ICMP packets found")
        return
    
    print(f"Found {len(icmp_packets)} ICMP packets")
    
    # Statistics by type
    types = {}
    for p in icmp_packets:
        icmp = p[ICMP]
        types[icmp.type] = types.get(icmp.type, 0) + 1
    
    type_names = {
        0: "Echo Reply",
        3: "Destination Unreachable",
        4: "Source Quench",
        8: "Echo Request",
        9: "Router Advertisement",
        10: "Router Solicitation",
        11: "Time Exceeded",
        12: "Parameter Problem",
        13: "Timestamp Request",
        14: "Timestamp Reply",
        17: "Address Mask Request",
        18: "Address Mask Reply"
    }
    
    print("\nICMP Type Statistics:")
    print("=" * 50)
    for type_id, count in sorted(types.items()):
        name = type_names.get(type_id, f"Unknown ({type_id})")
        print(f"  {type_id} ({name}): {count}")
    
    print("=" * 50)
    
    # Show detailed packets
    print("\nDetailed ICMP Packets:")
    print("=" * 80)
    
    for i, packet in enumerate(icmp_packets[:10], 1):
        icmp = packet[ICMP]
        ip = packet[IP]
        
        print(f"\nPacket {i}:")
        print(f"  Source: {ip.src}")
        print(f"  Destination: {ip.dst}")
        print(f"  Type: {icmp.type} ({type_names.get(icmp.type, 'Unknown')})")
        print(f"  Code: {icmp.code}")
        
        # Show payload if present
        if hasattr(icmp, 'payload'):
            print(f"  Payload: {icmp.payload}")
        
        print("-" * 80)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    analyze_icmp(sys.argv[1])
```

---

### Lab 5: Build an IP Packet Decoder

**The Target**: Build a complete IP packet decoder and router simulation.

**The Implementation**:

Create a file called `ip_decoder.py`:

```python
#!/usr/bin/env python3
"""
ip_decoder.py - Complete IP packet decoder with router simulation
"""

import sys
import struct
import socket
import ipaddress
from typing import Dict, Optional, Tuple, List
from scapy.all import sniff, IP, TCP, UDP, ICMP, Raw, Ether

class IPv4Packet:
    """Represents an IPv4 packet with decoded fields"""
    
    def __init__(self, raw_data):
        self.raw = raw_data
        self.version = (raw_data[0] >> 4) & 0xF
        self.ihl = raw_data[0] & 0xF
        self.dscp = (raw_data[1] >> 2) & 0x3F
        self.ecn = raw_data[1] & 0x3
        self.total_length = struct.unpack('>H', raw_data[2:4])[0]
        self.identification = struct.unpack('>H', raw_data[4:6])[0]
        self.flags = (raw_data[6] >> 5) & 0x7
        self.fragment_offset = ((raw_data[6] & 0x1F) << 8) | raw_data[7]
        self.ttl = raw_data[8]
        self.protocol = raw_data[9]
        self.checksum = struct.unpack('>H', raw_data[10:12])[0]
        self.src_ip = socket.inet_ntoa(raw_data[12:16])
        self.dst_ip = socket.inet_ntoa(raw_data[16:20])
        
        # Options (if any)
        self.options = []
        if self.ihl > 5:
            options_start = 20
            options_len = (self.ihl - 5) * 4
            self.options = raw_data[options_start:options_start + options_len]
        
        # Payload
        self.payload = raw_data[self.ihl * 4:self.total_length]
        
        self.protocol_name = self._protocol_name()
        self.valid = self._verify_checksum()
    
    def _protocol_name(self):
        """Map protocol number to name"""
        protocols = {
            1: 'ICMP', 2: 'IGMP', 6: 'TCP', 17: 'UDP',
            50: 'ESP', 51: 'AH', 58: 'ICMPv6', 89: 'OSPF'
        }
        return protocols.get(self.protocol, f'Protocol({self.protocol})')
    
    def _verify_checksum(self):
        """Verify header checksum"""
        # Copy the header
        header = bytearray(self.raw[:self.ihl * 4])
        # Zero out checksum field
        header[10:12] = b'\x00\x00'
        
        # Calculate checksum
        checksum = 0
        for i in range(0, len(header), 2):
            word = (header[i] << 8) + (header[i+1] if i+1 < len(header) else 0)
            checksum += word
            checksum = (checksum & 0xFFFF) + (checksum >> 16)
        checksum = ~checksum & 0xFFFF
        
        return checksum == self.checksum
    
    def display(self, verbose=False):
        """Display packet information"""
        print(f"\n┌{'─'*60}┐")
        print(f"│ IPv4 Packet from {self.src_ip} to {self.dst_ip}")
        print(f"├{'─'*60}┤")
        print(f"│ Version: {self.version} {'✓' if self.version == 4 else '✗'}")
        print(f"│ Header Length: {self.ihl * 4} bytes")
        print(f"│ Total Length: {self.total_length} bytes")
        print(f"│ Identification: 0x{self.identification:04X}")
        print(f"│ Flags: {'DF' if self.flags & 0x2 else ''} {'MF' if self.flags & 0x1 else ''}")
        print(f"│ Fragment Offset: {self.fragment_offset}")
        print(f"│ TTL: {self.ttl}")
        print(f"│ Protocol: {self.protocol_name}")
        print(f"│ Header Checksum: 0x{self.checksum:04X} {'✓' if self.valid else '✗'}")
        print(f"│ Payload Size: {len(self.payload)} bytes")
        
        if self.options:
            print(f"│ Options: {self.options.hex()}")
        
        if verbose and self.payload:
            print(f"│ Payload (first 32 bytes): {self.payload[:32].hex()}")
            # Try to decode payload based on protocol
            if self.protocol == 6:  # TCP
                try:
                    tcp = TCP(self.payload)
                    print(f"│   └─ TCP: {tcp.sport} -> {tcp.dport}")
                except:
                    pass
            elif self.protocol == 17:  # UDP
                try:
                    udp = UDP(self.payload)
                    print(f"│   └─ UDP: {udp.sport} -> {udp.dport}")
                except:
                    pass
            elif self.protocol == 1:  # ICMP
                try:
                    icmp = ICMP(self.payload)
                    print(f"│   └─ ICMP: Type {icmp.type} Code {icmp.code}")
                except:
                    pass
        
        print(f"└{'─'*60}┘")

class SimpleRouter:
    """Simulate a basic router with routing table"""
    
    def __init__(self):
        self.routing_table = []
        self.packets_forwarded = 0
        self.packets_dropped = 0
    
    def add_route(self, network, next_hop, interface, metric=1):
        """Add a route to the routing table"""
        self.routing_table.append({
            'network': ipaddress.ip_network(network, strict=False),
            'next_hop': next_hop,
            'interface': interface,
            'metric': metric
        })
        print(f"Added route: {network} -> {next_hop} via {interface}")
    
    def route_packet(self, packet):
        """Route an IP packet based on destination"""
        dst_ip = ipaddress.ip_address(packet.dst_ip)
        
        # Find best match (longest prefix)
        best_match = None
        best_len = 0
        
        for route in self.routing_table:
            if dst_ip in route['network']:
                prefix_len = route['network'].prefixlen
                if prefix_len > best_len:
                    best_len = prefix_len
                    best_match = route
        
        if best_match:
            print(f"  Forwarding {packet.dst_ip} -> {best_match['next_hop']} via {best_match['interface']}")
            self.packets_forwarded += 1
            return best_match
        else:
            print(f"  No route to {packet.dst_ip}")
            self.packets_dropped += 1
            return None
    
    def display_stats(self):
        """Display routing statistics"""
        print(f"\nRouting Statistics:")
        print(f"  Packets Forwarded: {self.packets_forwarded}")
        print(f"  Packets Dropped: {self.packets_dropped}")
        print(f"  Routes: {len(self.routing_table)}")
        
        print(f"\nRouting Table:")
        print(f"  {'Network':<20} {'Next Hop':<16} {'Interface':<12} {'Metric':<8}")
        print(f"  {'-'*20} {'-'*16} {'-'*12} {'-'*8}")
        for route in self.routing_table:
            print(f"  {str(route['network']):<20} {route['next_hop']:<16} "
                  f"{route['interface']:<12} {route['metric']:<8}")

def packet_callback(packet):
    """Callback for sniffing packets"""
    if IP in packet:
        ip = packet[IP]
        
        # Create IPv4Packet object
        raw_data = bytes(packet[IP])
        ip_packet = IPv4Packet(raw_data)
        ip_packet.display(verbose=True)

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="IPv4 Packet Decoder and Router")
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-c', '--count', type=int, default=5, help='Number of packets')
    parser.add_argument('-r', '--route', action='append', help='Add route (network/prefix:next_hop:interface)')
    parser.add_argument('-d', '--dump', help='Dump packets to file')
    
    args = parser.parse_args()
    
    # Create router if routes provided
    router = SimpleRouter() if args.route else None
    
    if router:
        for route_str in args.route:
            parts = route_str.split(':')
            if len(parts) == 3:
                network, next_hop, interface = parts
                router.add_route(network, next_hop, interface)
    
    print(f"Starting IP Packet Decoder on {args.interface or 'default'}...")
    print(f"Capturing {args.count} packets...")
    
    try:
        sniff(
            iface=args.interface,
            count=args.count,
            prn=packet_callback,
            store=False
        )
    except KeyboardInterrupt:
        print("\nCapture interrupted")
    
    if router:
        router.display_stats()

if __name__ == "__main__":
    main()
```

**Run the decoder**:
```bash
# Capture packets from the network
sudo python3 ip_decoder.py -i eth0 -c 5

# Capture with router simulation
sudo python3 ip_decoder.py -i eth0 -r 10.0.0.0/8:10.0.0.1:eth1 -r 0.0.0.0/0:192.168.1.1:eth0
```

---

## Section 7: Reference: Complete IP and ICMP Field Reference

### IPv4 Header Fields (Complete)

| Field | Offset (bits) | Size (bits) | Description | Values |
|-------|--------------|------------|-------------|--------|
| Version | 0 | 4 | IP version | 4 for IPv4, 6 for IPv6 |
| IHL | 4 | 4 | Internet Header Length | 5-15 (20-60 bytes) |
| DSCP | 8 | 6 | Differentiated Services | 0-63 |
| ECN | 14 | 2 | Explicit Congestion Notification | 0-3 |
| Total Length | 16 | 16 | Total packet size | 20-65535 bytes |
| Identification | 32 | 16 | Fragment identifier | 0-65535 |
| Flags | 48 | 3 | Control flags | DF, MF, Reserved |
| Fragment Offset | 51 | 13 | Fragment position | 0-8191 (8-byte units) |
| TTL | 64 | 8 | Time to Live | 0-255 |
| Protocol | 72 | 8 | Next protocol | 1=ICMP, 6=TCP, 17=UDP |
| Header Checksum | 80 | 16 | Error check | Computed over header |
| Source IP | 96 | 32 | Sender address | IPv4 address |
| Destination IP | 128 | 32 | Recipient address | IPv4 address |
| Options | 160 | variable | Optional fields | Varies |
| Payload | variable | variable | Data | Varies |

### ICMP Message Types (Complete)

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Ping response |
| 1 | Unassigned | - |
| 2 | Unassigned | - |
| 3 | Destination Unreachable | Network/host/protocol unreachable |
| 4 | Source Quench | Deprecated |
| 5 | Redirect | Better route available |
| 6 | Alternate Host Address | Deprecated |
| 7 | Unassigned | - |
| 8 | Echo Request | Ping request |
| 9 | Router Advertisement | Router discovery |
| 10 | Router Solicitation | Router discovery |
| 11 | Time Exceeded | TTL expired |
| 12 | Parameter Problem | Bad header |
| 13 | Timestamp Request | Timestamp request |
| 14 | Timestamp Reply | Timestamp response |
| 15 | Information Request | Deprecated |
| 16 | Information Reply | Deprecated |
| 17 | Address Mask Request | Deprecated |
| 18 | Address Mask Reply | Deprecated |
| 19 | Reserved | Security |
| 20-29 | Reserved | Experimental |
| 30 | Traceroute | Deprecated |
| 31 | Datagram Conversion Error | Deprecated |
| 32 | Mobile Host Redirect | Mobile IP |
| 33 | IPv6 Where-Are-You | IPv6 |
| 34 | IPv6 I-Am-Here | IPv6 |
| 35 | Mobile Registration Request | Mobile IP |
| 36 | Mobile Registration Reply | Mobile IP |
| 39 | SKIP | Simple Key Management |
| 40 | Photuris | Security |
| 41 | ICMP for IPv6 | Experimental |

### Common IP Protocol Numbers

| Protocol Number | Name |
|-----------------|------|
| 1 | ICMP |
| 2 | IGMP |
| 6 | TCP |
| 17 | UDP |
| 41 | IPv6 |
| 50 | ESP |
| 51 | AH |
| 58 | ICMPv6 |
| 89 | OSPF |
| 132 | SCTP |

---

## Summary

In Part 2, we've covered the global addressing and routing that makes the Internet work:

1. **IPv4**: The fundamental network protocol with its 32-bit addresses, packet structure, and fragmentation mechanisms.

2. **IPv6**: The next-generation protocol solving address exhaustion with 128-bit addresses and auto-configuration.

3. **Routing**: How routers use routing tables and longest prefix match to forward packets across networks.

4. **ICMP**: The diagnostic protocol providing ping, traceroute, and error reporting.

**Key Takeaways**:
- IPv4 addresses have both network and host portions identified by subnet masks
- NAT enables private networks to share public IP addresses
- IPv6 provides vastly larger address space and simplified headers
- Routing is based on longest prefix match in routing tables
- ICMP provides essential network diagnostics and error reporting
- Traceroute uses TTL expiration to discover network paths

**What's Next**: In Part 3, we'll explore the Transport Layer and examine TCP and UDP - how applications establish reliable connections, manage congestion, and choose between reliability and speed.
