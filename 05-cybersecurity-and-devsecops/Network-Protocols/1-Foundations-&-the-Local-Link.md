# Part 1: Foundations & the Local Link

## The Wire, Frames, and Local Discovery: Ethernet, ARP, and DHCP

---

## Synopsis

Every network journey begins on the local link. Before a device can browse the web, send an email, or access cloud services, it must establish its identity, obtain an IP address, discover neighboring devices, and encapsulate data into Ethernet frames.

This tutorial introduces the fundamental building blocks of computer networking, explaining how binary data becomes electrical or optical signals, how switches forward frames, how MAC addresses uniquely identify devices, and how DHCP automatically configures network hosts.

By the end of this part, you'll understand everything that occurs from the moment a computer connects to a network until it is ready to communicate with the outside world.

---

## Prerequisites

Before starting Part 1, ensure you have:

1. **A computer with Wireshark installed** ([Download here](https://www.wireshark.org/))
2. **Python 3.8+** installed with `pip` available
3. **Administrative/root access** to capture raw network traffic
4. **A network connection** (WiFi or Ethernet works fine)
5. **Basic command-line familiarity** (you can navigate directories and run commands)

---

## Part 1 Roadmap

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 1: LOCAL LINK                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Networking Foundations                                  │
│     ├─ OSI Seven-Layer Model                               │
│     ├─ TCP/IP Protocol Suite                               │
│     ├─ Encapsulation & Decapsulation                       │
│     └─ Network Interface Cards (NICs)                      │
│                                                             │
│  2. Ethernet                                                │
│     ├─ Ethernet Evolution                                   │
│     ├─ Frame Structure                                      │
│     ├─ MAC Addressing                                      │
│     ├─ Broadcast vs Unicast vs Multicast                   │
│     ├─ VLAN Fundamentals                                   │
│     └─ Switching & MAC Address Tables                      │
│                                                             │
│  3. Address Resolution Protocol (ARP)                       │
│     ├─ Why ARP Exists                                       │
│     ├─ ARP Request & Reply                                 │
│     ├─ ARP Cache                                           │
│     ├─ Gratuitous ARP                                      │
│     ├─ Proxy ARP                                           │
│     └─ ARP Spoofing Attacks                                │
│                                                             │
│  4. Dynamic Host Configuration Protocol (DHCP)              │
│     ├─ Why Static Addressing Doesn't Scale                 │
│     ├─ DHCP Architecture                                    │
│     ├─ DORA Process (Discover, Offer, Request, Ack)        │
│     ├─ Lease Renewal                                       │
│     ├─ DHCP Relay Agents                                   │
│     └─ DHCP Options & Reservations                         │
│                                                             │
│  5. Hands-On Labs                                           │
│     ├─ Lab 1: Inspect Ethernet Frames                      │
│     ├─ Lab 2: Capture an ARP Exchange                      │
│     ├─ Lab 3: Observe a DHCP DORA Sequence                 │
│     └─ Lab 4: Build an Ethernet Frame Decoder in Python    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 1: Networking Foundations

Before we dive into specific protocols, let's establish a mental framework for how networks are organized.

### The OSI Seven-Layer Model

The **Open Systems Interconnection (OSI) model** is a conceptual framework that describes how network protocols interact. Think of it like a postal system:

| Layer | Name | What It Does | Analogy |
|-------|------|--------------|---------|
| 7 | Application | User-facing services (HTTP, SMTP, DNS) | The letter writer |
| 6 | Presentation | Data formatting, encryption, compression | Translating the letter to the recipient's language |
| 5 | Session | Managing conversations between applications | The post office tracking a package |
| 4 | Transport | Reliable vs unreliable delivery (TCP/UDP) | The shipping company (FedEx vs USPS) |
| 3 | Network | Routing across multiple networks (IP) | Highway signs guiding the package across states |
| 2 | Data Link | Local delivery (Ethernet) | The local truck driver on your street |
| 1 | Physical | Raw bits over wire/fiber/air | The road, asphalt, traffic lights |

**Key Insight**: Each layer only talks to the same layer on another device. Your browser (Layer 7) talks to the web server's Layer 7. Your Ethernet driver (Layer 2) talks to the switch's Layer 2. Layers don't skip—they only communicate with their peer layer.

### The TCP/IP Protocol Suite

The OSI model is theoretical. The **TCP/IP suite** is what the Internet actually uses, and it maps roughly to the OSI layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    TCP/IP MODEL                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  4. Application Layer (OSI Layers 5-7)                     │
│     ├─ DNS, HTTP, SMTP, FTP, SSH, TLS                     │
│     ├─ Protocols applications use directly                 │
│                                                             │
│  3. Transport Layer (OSI Layer 4)                          │
│     ├─ TCP (reliable, connection-oriented)                 │
│     └─ UDP (fast, connectionless)                          │
│                                                             │
│  2. Internet Layer (OSI Layer 3)                           │
│     ├─ IPv4, IPv6                                          │
│     ├─ ICMP, IGMP                                          │
│     └─ Routing and addressing                              │
│                                                             │
│  1. Link Layer (OSI Layers 1-2)                            │
│     ├─ Ethernet, Wi-Fi                                     │
│     ├─ ARP                                                 │
│     └─ Physical transmission                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Encapsulation and Decapsulation

**Encapsulation** is the process of wrapping data with headers at each layer as it moves down the stack. **Decapsulation** is removing headers as data moves up.

Think of it like shipping a gift:

1. You write a message (Application Layer data)
2. You put it in an envelope with the recipient's address (TCP/UDP header)
3. You put the envelope in a box with the city/state (IP header)
4. You put the box on a truck with the street address (Ethernet header)
5. The truck drives down the road (Physical Layer)

Each layer adds its own header containing instructions for the peer layer on the receiving device.

**Visual Encapsulation Flow**:

```
┌─────────────────────────────────────────────────────────────┐
│                       APPLICATION DATA                       │
│                   (e.g., "Hello, Server!")                  │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌───────────────┬─────────────────────────────────────────────┐
│  TCP Header   │              APPLICATION DATA               │
│  (Source/Dest │          (HTTP request, etc.)              │
│   Ports, Seq) │                                            │
└───────────────┴─────────────────────────────────────────────┘
                          │
                          ▼
┌───────────────┬───────────────┬─────────────────────────────┐
│  IP Header    │  TCP Header   │       APPLICATION DATA       │
│  (Source/Dest │  (Source/Dest │                              │
│   IPs, TTL)   │   Ports, Seq) │                              │
└───────────────┴───────────────┴─────────────────────────────┘
                          │
                          ▼
┌───────────────┬───────────────┬───────────────┬─────────────┐
│  Ethernet     │  IP Header    │  TCP Header   │ APPLICATION │
│  Header       │  (Source/Dest │  (Source/Dest │    DATA     │
│  (Source/Dest │   IPs, TTL)   │   Ports, Seq) │             │
│   MACs, Type) │               │               │             │
└───────────────┴───────────────┴───────────────┴─────────────┘
                          │
                          ▼
                  ┌───────────────┐
                  │  PHYSICAL BITS │
                  │ (1s and 0s)   │
                  └───────────────┘
```

### Network Interface Cards (NICs)

A **Network Interface Card (NIC)** is the hardware that connects a computer to a network. Every NIC has a unique **Media Access Control (MAC) address** burned into its firmware during manufacturing.

**Key NIC Characteristics**:

- **MAC Address**: 48-bit hardware address (e.g., `00:1A:2B:3C:4D:5E`)
- **Promiscuous Mode**: When enabled, the NIC passes all frames to the OS, not just those addressed to it (essential for packet capture)
- **Full Duplex**: Can send and receive simultaneously
- **Half Duplex**: Can send or receive, but not both at once (obsolete for modern Ethernet)

### Physical Transmission Media

Data travels as signals across various media:

| Medium | Speed | Distance | Characteristics |
|--------|-------|----------|-----------------|
| **Copper (Cat5e/Cat6)** | 1-10 Gbps | 100 meters | Electrical signals, interference-sensitive |
| **Fiber Optic** | 40-100 Gbps | 100+ km | Light signals, immune to interference |
| **WiFi (802.11)** | 1-10 Gbps | 50-100m | Radio signals, affected by obstacles |
| **Coaxial Cable** | 1 Gbps | 500m | Electrical signals, used in cable internet |

---

## Section 2: Ethernet

### Ethernet Evolution

Ethernet has evolved dramatically since its invention in 1973 at Xerox PARC:

| Standard | Year | Speed | Media | Key Innovation |
|----------|------|-------|-------|----------------|
| 10BASE5 | 1980 | 10 Mbps | Coax (Thicknet) | Original Ethernet |
| 10BASE2 | 1985 | 10 Mbps | Coax (Thinnet) | Cheaper, thinner cables |
| 10BASE-T | 1990 | 10 Mbps | Twisted pair | Star topology, hubs |
| 100BASE-TX | 1995 | 100 Mbps | Cat5 | Fast Ethernet |
| 1000BASE-T | 1999 | 1 Gbps | Cat5e | Gigabit Ethernet |
| 10GBASE-T | 2006 | 10 Gbps | Cat6a | 10-Gigabit Ethernet |
| 40/100GBASE-T | 2016 | 40/100 Gbps | Cat8 | 40/100-Gigabit Ethernet |

Modern Ethernet is nearly ubiquitous in LANs (Local Area Networks), with speeds up to 400 Gbps available in data centers.

### Ethernet Frame Structure

An **Ethernet frame** is the basic unit of data at the Data Link Layer. Let's examine each field in detail:

```
┌─────────────────────────────────────────────────────────────────┐
│                      ETHERNET FRAME (IEEE 802.3)               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Preamble (7 bytes)                                          │
│     └─ 10101010 repeated 7 times: synchronizes receiver clock  │
│                                                                 │
│  2. Start Frame Delimiter (1 byte)                             │
│     └─ 10101011: signals the start of actual frame             │
│                                                                 │
│  3. Destination MAC Address (6 bytes)                          │
│     └─ Where the frame is going                                │
│                                                                 │
│  4. Source MAC Address (6 bytes)                               │
│     └─ Where the frame came from                               │
│                                                                 │
│  5. EtherType / Length (2 bytes)                               │
│     └─ Either the type of payload (0x0800 = IPv4,             │
│        0x0806 = ARP) or the payload length (if < 1536)        │
│                                                                 │
│  6. Payload (46-1500 bytes)                                    │
│     └─ The data being transmitted (IP packet, ARP, etc.)      │
│                                                                 │
│  7. Frame Check Sequence (4 bytes)                             │
│     └─ CRC-32 checksum for error detection                    │
│                                                                 │
│  Total frame size: 64-1518 bytes (excluding preamble)         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Important Frame Fields**:

- **Preamble & SFD**: Enable the receiver to synchronize its clock. The alternating 1s and 0s allow the receiver to lock onto the bit timing.

- **Destination MAC**: Identifies the recipient. If set to `FF:FF:FF:FF:FF:FF`, it's a **broadcast** frame sent to all devices on the network.

- **Source MAC**: Identifies the sender. This is always a unicast MAC address (never broadcast).

- **EtherType**: Values over 0x05DC (1500 decimal) indicate protocol type:
  - `0x0800`: IPv4
  - `0x0806`: ARP
  - `0x86DD`: IPv6
  - `0x8100`: VLAN-tagged frame

- **Payload**: Contains the encapsulated data. Minimum 46 bytes (padding added if necessary) to ensure the frame is at least 64 bytes for collision detection.

- **FCS**: The **Frame Check Sequence** uses a **Cyclic Redundancy Check (CRC-32)** to detect errors. The sender calculates a checksum over the frame data and includes it here. The receiver recalculates and compares—if they differ, the frame is corrupted and discarded.

**Minimum Frame Size (64 bytes)**: Ethernet requires a minimum frame size of 64 bytes (excluding preamble) to ensure proper collision detection. If the payload is less than 46 bytes, padding bytes (`0x00`) are added.

### MAC Addressing

A **MAC (Media Access Control) address** is a 48-bit (6-byte) hardware address assigned to every NIC during manufacture.

**Structure**:

```
┌─────────────────────────────────────────────────────────────┐
│                    MAC ADDRESS FORMAT                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  00:1A:2B:3C:4D:5E                                         │
│  │  │  │  │  │  │                                          │
│  │  │  │  │  │  └─ Last byte                               │
│  │  │  │  │  └──── Fifth byte                              │
│  │  │  │  └─────── Fourth byte                             │
│  │  │  └─────────── Third byte                             │
│  │  └─────────────── Second byte                           │
│  └─────────────────── First byte                           │
│                                                             │
│  First 24 bits: OUI (Organizationally Unique Identifier)   │
│    └─ Identifies the manufacturer                          │
│                                                             │
│  Last 24 bits: NIC-specific identifier                     │
│    └─ Assigned by manufacturer                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Special MAC Addresses**:

- **Broadcast**: `FF:FF:FF:FF:FF:FF` — All devices on the local network receive the frame
- **Multicast**: The first byte's least significant bit is `1` (e.g., `01:00:5E:XX:XX:XX`) — Group communication
- **Unicast**: The first byte's least significant bit is `0` (e.g., `00:1A:2B:3C:4D:5E`) — Single device

### Broadcast vs Unicast vs Multicast

Understanding these three delivery modes is crucial:

| Type | MAC Address | Behavior | Use Case |
|------|-------------|----------|----------|
| **Unicast** | Specific MAC (e.g., 00:1A:2B:3C:4D:5E) | Sent to one specific device | Normal communication (HTTP, SSH, etc.) |
| **Broadcast** | `FF:FF:FF:FF:FF:FF` | Sent to all devices on the network | ARP requests, DHCP discovery |
| **Multicast** | Starts with `01:00:5E` or `33:33` | Sent to a group of interested devices | Video streaming, routing protocols |

**How a switch handles each**:

```
┌─────────────────────────────────────────────────────────────┐
│                  SWITCH FORWARDING LOGIC                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Unicast:                                                   │
│    └─ Switch checks its MAC address table                  │
│    └─ Forwards frame only to the port with the target MAC  │
│                                                             │
│  Broadcast:                                                 │
│    └─ Switch forwards frame to ALL ports (except incoming) │
│                                                             │
│  Multicast:                                                 │
│    └─ Switch forwards frame to ports in the multicast group│
│    └─ If no IGMP snooping, floods to all ports             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### VLAN Fundamentals

**VLANs (Virtual Local Area Networks)** allow you to partition a physical switch into multiple logical switches:

```
┌─────────────────────────────────────────────────────────────┐
│                    VLAN ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐                                       │
│  │  SWITCH (Physical) │                                     │
│  │                    │                                     │
│  │  ┌─────────────┐  │  ┌─────────────┐                   │
│  │  │   VLAN 10   │  │  │   VLAN 20   │                   │
│  │  │  Engineering │  │  │   Finance   │                   │
│  │  │             │  │  │             │                   │
│  │  │ Port 1-5    │  │  │ Port 6-10   │                   │
│  │  │ 10.0.10.0/24│  │  │ 10.0.20.0/24│                   │
│  │  └─────────────┘  │  └─────────────┘                   │
│  └─────────────────┘                                       │
│                                                             │
│  Benefits:                                                  │
│  ├─ Broadcast isolation                                     │
│  ├─ Security separation                                     │
│  ├─ Traffic optimization                                    │
│  └─ Logical grouping of devices                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Switching and MAC Address Tables

**Switches** are the core devices of Ethernet LANs. Unlike hubs (which simply repeat frames), switches learn which devices are on each port.

**MAC Address Table Learning Process**:

1. **Switching begins**: Switch receives a frame from Port 1 with source MAC `A`

2. **Learning**: Switch records: `MAC A is on Port 1`

3. **Forwarding**: 
   - If the destination MAC is `B`, the switch checks its table
   - If `B` is on Port 2, the switch forwards only to Port 2
   - If `B` is unknown, the switch floods the frame to all ports

4. **Aging**: The switch removes entries after 300-600 seconds (the **aging time**) to accommodate network changes

```
┌─────────────────────────────────────────────────────────────┐
│              MAC ADDRESS TABLE EXAMPLE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┬─────────┬────────────────────┬─────────────┐│
│  │ VLAN     │ MAC     │ Port               │ Age (sec)   ││
│  ├──────────┼─────────┼────────────────────┼─────────────┤│
│  │ 1        │ AA:BB:CC│ Gi0/1              │ 12          ││
│  │ 1        │ DD:EE:FF│ Gi0/2              │ 5           ││
│  │ 10       │ 11:22:33│ Gi1/1              │ 300         ││
│  │ 20       │ 44:55:66│ Gi2/1              │ 180         ││
│  └──────────┴─────────┴────────────────────┴─────────────┘│
│                                                             │
│  Flooding occurs when destination MAC is not in the table  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 3: Address Resolution Protocol (ARP)

### Why ARP Exists

**ARP (Address Resolution Protocol)** solves a fundamental problem: IP addresses (Layer 3) and MAC addresses (Layer 2) exist in different addressing spaces.

When Device A wants to send an IP packet to Device B on the same local network, A needs B's MAC address to construct the Ethernet frame. But A only knows B's IP address. **ARP bridges this gap**.

**Analogy**: Imagine you want to mail a package to someone in your apartment building. You know their apartment number (IP address), but you need their actual name (MAC address) to put on the envelope. ARP is like calling out, "Who lives in apartment 10?" and they respond with their name.

### ARP Request and Reply

ARP operates through a simple two-message exchange:

**ARP Request (Broadcast)**:
```
┌─────────────────────────────────────────────────────────────┐
│                    ARP REQUEST PACKET                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Ethernet Header:                                           │
│  ├─ Destination MAC: FF:FF:FF:FF:FF:FF (Broadcast)        │
│  ├─ Source MAC: 00:1A:2B:3C:4D:5E (Device A)              │
│  └─ EtherType: 0x0806 (ARP)                               │
│                                                             │
│  ARP Payload:                                              │
│  ├─ Hardware Type: 1 (Ethernet)                           │
│  ├─ Protocol Type: 0x0800 (IPv4)                          │
│  ├─ Hardware Address Length: 6                            │
│  ├─ Protocol Address Length: 4                            │
│  ├─ Operation: 1 (Request)                                │
│  ├─ Sender MAC: 00:1A:2B:3C:4D:5E                        │
│  ├─ Sender IP: 192.168.1.10                               │
│  ├─ Target MAC: 00:00:00:00:00:00 (Unknown)              │
│  └─ Target IP: 192.168.1.20                               │
│                                                             │
│  "Who has 192.168.1.20? Tell 192.168.1.10"               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**ARP Reply (Unicast)**:
```
┌─────────────────────────────────────────────────────────────┐
│                    ARP REPLY PACKET                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Ethernet Header:                                           │
│  ├─ Destination MAC: 00:1A:2B:3C:4D:5E (Device A)         │
│  ├─ Source MAC: 11:22:33:44:55:66 (Device B)              │
│  └─ EtherType: 0x0806 (ARP)                               │
│                                                             │
│  ARP Payload:                                              │
│  ├─ Operation: 2 (Reply)                                   │
│  ├─ Sender MAC: 11:22:33:44:55:66                        │
│  ├─ Sender IP: 192.168.1.20                               │
│  ├─ Target MAC: 00:1A:2B:3C:4D:5E                        │
│  └─ Target IP: 192.168.1.10                               │
│                                                             │
│  "192.168.1.20 is at 11:22:33:44:55:66"                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### ARP Cache

To avoid sending ARP requests for every packet, devices maintain an **ARP cache**:

```
┌─────────────────────────────────────────────────────────────┐
│                    ARP CACHE EXAMPLE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  $ arp -a                                                   │
│                                                             │
│  Address                  HWtype  HWaddress           Flags │
│  192.168.1.1              ether   00:11:22:33:44:55   C    │
│  192.168.1.20             ether   11:22:33:44:55:66   C    │
│  192.168.1.100            ether   aa:bb:cc:dd:ee:ff   C    │
│                                                             │
│  Flags: C = Complete, M = Permanent, P = Published         │
│                                                             │
│  Cache entries expire after 1-5 minutes (the ARP timeout)  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Gratuitous ARP

A **Gratuitous ARP** is an ARP request sent for the device's own IP address. This happens when:

1. A device boots up and wants to detect address conflicts (if another device responds, there's an IP conflict)
2. A device has changed its MAC address and wants to update other devices' caches
3. A high-availability system takes over an IP address

```
Gratuitous ARP Example:
  └─ Sender IP: 192.168.1.10 (itself)
  └─ Target IP: 192.168.1.10 (itself)
  └─ "Does anyone have 192.168.1.10? I'm checking..."
```

### Proxy ARP

**Proxy ARP** allows a router to respond to ARP requests for devices on another network. This enables systems to communicate with remote devices as if they were local.

```
┌─────────────────────────────────────────────────────────────┐
│                    PROXY ARP SCENARIO                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Device A (192.168.1.10) ---> ARP Request for 192.168.2.20│
│                                                             │
│   Router (192.168.1.1, 192.168.2.1):                       │
│   └─ "I know where 192.168.2.20 is! My MAC is XX:XX:XX"   │
│                                                             │
│   Device A sends packets to XX:XX:XX (the router)          │
│   Router forwards them to the remote network              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### ARP Spoofing Attacks

**ARP spoofing** (also called **ARP poisoning**) is a common attack where a malicious device sends forged ARP replies to redirect traffic.

```
┌─────────────────────────────────────────────────────────────┐
│                    ARP SPOOFING ATTACK                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Attacker sends forged ARP replies:                       │
│   ├─ "192.168.1.1 (gateway) is at MAC: AA:AA:AA"          │
│   └─ "192.168.1.10 (victim) is at MAC: AA:AA:AA"          │
│                                                             │
│   Victim's ARP cache is poisoned:                          │
│   └─ 192.168.1.1 -> AA:AA:AA                              │
│                                                             │
│   All traffic from victim to internet goes to attacker    │
│                                                             │
│   Attacker can:                                             │
│   ├─ Sniff traffic                                          │
│   ├─ Modify traffic (man-in-the-middle)                    │
│   └─ Block traffic (denial of service)                    │
│                                                             │
│   Mitigations:                                              │
│   ├─ Static ARP entries                                    │
│   ├─ Dynamic ARP Inspection (DAI)                         │
│   └─ Packet filtering                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 4: Dynamic Host Configuration Protocol (DHCP)

### Why Static Addressing Doesn't Scale

In the early days of networking, every device had a statically assigned IP address. This approach fails at any reasonable scale:

**Problems with static IP addressing**:
- Administrators must manually configure every device
- IP conflicts occur when two devices get the same address
- Devices can't easily move between networks
- Cannot support large networks efficiently
- Difficult to track inventory and usage

**DHCP solves all of these problems** by dynamically assigning IP addresses from a pool.

### DHCP Architecture

**DHCP** uses a **client-server architecture**:

```
┌─────────────────────────────────────────────────────────────┐
│                    DHCP ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐                │
│  │  DHCP   │    │  DHCP   │    │  DHCP   │                │
│  │ Client  │    │  Relay  │    │ Server  │                │
│  │(Device) │    │ (Agent) │    │(Central)│                │
│  └─────────┘    └─────────┘    └─────────┘                │
│       │              │              │                       │
│       │  Broadcast   │  Unicast     │                       │
│       └──────────────┼──────────────┘                       │
│                      │                                      │
│                 ┌────┴────┐                                 │
│                 │ Router  │                                 │
│                 └─────────┘                                 │
│                                                             │
│  Components:                                                │
│  ├─ DHCP Server: Manages IP address pool, leases addresses │
│  ├─ DHCP Client: Requests and renews IP addresses          │
│  └─ DHCP Relay: Forwards DHCP messages across subnets      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### DORA Process: The Four-Step Dance

DHCP uses a four-message exchange called **DORA** (Discover, Offer, Request, Acknowledge):

```
┌─────────────────────────────────────────────────────────────┐
│                    DHCP DORA SEQUENCE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Client (192.168.1.10)         Server (192.168.1.1)       │
│          │                                │                 │
│          │  1. DHCPDISCOVER (Broadcast)  │                 │
│          │  "Does anyone have an IP?"    │                 │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│          │  2. DHCPOFFER (Unicast)       │                 │
│          │  "Here's IP 192.168.1.10"    │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  3. DHCPREQUEST (Broadcast)   │                 │
│          │  "I'll take 192.168.1.10"    │                 │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│          │  4. DHCPACK (Unicast)         │                 │
│          │  "Confirmed! Use 192.168.1.10"│                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│   [Device configures its IP address]      │                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Detailed Message Breakdown**:

1. **DHCPDISCOVER**:
   - Client sends a broadcast to discover available DHCP servers
   - Source IP: `0.0.0.0` (no IP yet)
   - Destination IP: `255.255.255.255` (broadcast)
   - Source MAC: Client's MAC address
   - Destination MAC: `FF:FF:FF:FF:FF:FF`
   - Includes client MAC in the `chaddr` (client hardware address) field

2. **DHCPOFFER**:
   - Server responds with an available IP address
   - Source IP: Server's IP (`192.168.1.1`)
   - Destination IP: `255.255.255.255` (client doesn't have an IP yet)
   - Source MAC: Server's MAC
   - Destination MAC: Client's MAC
   - Includes: Offered IP, subnet mask, lease duration, server identifier

3. **DHCPREQUEST**:
   - Client requests the offered IP address
   - Broadcast (to reach all servers)
   - Request message includes the chosen server's ID
   - Other servers see this and know their offers were declined

4. **DHCPACK**:
   - Server acknowledges the request
   - Source IP: Server's IP
   - Destination IP: `255.255.255.255`
   - Confirms the IP assignment and includes additional configuration

**Optional DHCP Messages**:
- **DHCPNAK**: Server declines the request (e.g., IP is taken)
- **DHCPDECLINE**: Client declines the offered IP (detects conflict)
- **DHCPRELEASE**: Client releases an IP address when shutting down
- **DHCPINFORM**: Client already has an IP but needs more configuration

### Lease Renewal

DHCP addresses are **leased** (temporary) to prevent address exhaustion. The renewal process:

```
┌─────────────────────────────────────────────────────────────┐
│                    DHCP LEASE TIMELINE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Time: 0          T1 (50%)      T2 (87.5%)    Timeout     │
│     │                │              │              │        │
│     ▼                ▼              ▼              ▼        │
│  ┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐  │
│  │ Leased │     │Renewal │     │Rebind  │     │Release │  │
│  │  IP    │     │Attempt │     │Attempt │     │  IP    │  │
│  └────────┘     └────────┘     └────────┘     └────────┘  │
│                                                             │
│  T1 (50% of lease): Client tries to renew with the same    │
│  server (unicast DHCPREQUEST)                              │
│                                                             │
│  T2 (87.5% of lease): If no response, client broadcasts    │
│  to any DHCP server (rebind)                              │
│                                                             │
│  Lease expires: Client must release the IP and start over  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### DHCP Relay Agents

**DHCP Relay Agents** forward DHCP messages between clients and servers across different subnets:

```
┌─────────────────────────────────────────────────────────────┐
│                    DHCP RELAY ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Client (192.168.1.10)                                     │
│         │                                                   │
│         │  DHCPDISCOVER (Broadcast)                        │
│         ▼                                                   │
│   ┌─────────────┐                                          │
│   │   Router    │  Relay Agent                              │
│   │ (Gateway)   ├─────────────────────────────────┐        │
│   └─────────────┘                                 │        │
│         │                                         │        │
│         │         DHCP Server (10.0.0.1)          │        │
│         │                 │                       │        │
│         └────────────────►│                       │        │
│                 DHCPDISCOVER (Unicast)            │        │
│                 ├─ giaddr: 192.168.1.1            │        │
│                 │                                 │        │
│                 │  DHCPOFFER (Unicast)            │        │
│                 │                                 │        │
│                 ▼                                 │        │
│         ┌─────────────────────────────────────────┘        │
│         │                                                  │
│         │  DHCPOFFER (Unicast to client)                  │
│         ▼                                                  │
│   Client (192.168.1.10)                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### DHCP Options

DHCP provides additional configuration via **options**:

| Option Number | Name | Purpose |
|---------------|------|---------|
| 1 | Subnet Mask | Network mask for the client |
| 3 | Router | Default gateway |
| 6 | DNS Server | DNS server IP addresses |
| 15 | Domain Name | DNS domain name |
| 42 | NTP Server | Time server addresses |
| 50 | Requested IP | IP address the client wants |
| 51 | IP Address Lease Time | Lease duration in seconds |
| 53 | DHCP Message Type | DISCOVER, OFFER, REQUEST, etc. |
| 54 | Server Identifier | DHCP server's IP address |
| 55 | Parameter Request List | Options the client wants |
| 66 | TFTP Server Name | PXE boot server |
| 67 | Bootfile Name | PXE boot file |

**Reservations and Static Leases**: Administrators can configure DHCP to always give the same IP to specific MAC addresses, combining dynamic management with predictable addressing.

---

## Section 5: Hands-On Labs

Now we'll apply everything we've learned through practical exercises. Complete each lab in order—they build on each other.

---

### Lab 1: Inspect Ethernet Frames with Wireshark

**The Target**: Capture and analyze Ethernet frames to see the structure we learned about.

**The Concept**: Wireshark captures network traffic and displays each frame with its headers decoded. We'll capture some traffic and inspect the Ethernet header fields.

**The Implementation**:

1. **Launch Wireshark**:
   ```bash
   # Linux
   wireshark
   
   # macOS (if installed via Homebrew)
   open -a Wireshark
   
   # Windows (Start Menu -> Wireshark)
   ```

2. **Select the correct network interface**:
   - On Linux: Usually `eth0` or `wlan0`
   - On macOS: Usually `en0` or `en1`
   - On Windows: Usually `Wi-Fi` or `Ethernet`

   Look for the interface with active traffic (you'll see a wave pattern).

3. **Start capturing**:
   - Click the shark fin icon or select **Capture -> Start**
   - Alternatively, use: `tcpdump -i eth0 -w capture.pcap` and load the file later

4. **Generate some traffic**:
   Open a terminal and run:
   ```bash
   # Generate HTTP traffic
   curl -I https://www.google.com
   
   # Generate ARP traffic (gratuitous ARP)
   arping -I eth0 192.168.1.1 -c 1
   ```

5. **Stop the capture** (click the red square).

6. **Apply a display filter** to focus on a specific protocol:
   ```
   # Only show Ethernet frames
   ether.dst == ff:ff:ff:ff:ff:ff
   
   # Only show ARP traffic
   arp
   
   # Only show IPv4 traffic
   ip
   ```

7. **Select a frame** and examine the Ethernet header in the packet details pane:

```
Frame 1: 74 bytes on wire (592 bits), 74 bytes captured (592 bits)
Ethernet II, Src: aa:bb:cc:dd:ee:ff, Dst: 00:11:22:33:44:55
    Destination: 00:11:22:33:44:55 (Cisco_33:44:55)
    Source: aa:bb:cc:dd:ee:ff (Intel_ee:ff:aa)
    Type: IPv4 (0x0800)
```

8. **Examine the frame bytes** in the hex dump pane:
```
0000  00 11 22 33 44 55 aa bb cc dd ee ff 08 00 45 00  .."3DU........E.
0010  00 3c 00 01 40 00 40 06 d4 a4 c0 a8 01 0a c0 a8  .<..@.@.........
0020  01 01 00 50 00 16 00 00 00 00 00 00 00 00 50 02  ...P..........P.
```

**The Verification**:

Run these commands to confirm your capture worked:

```bash
# Check that you captured packets
ls -la ~/capture.pcap

# Count frames in your capture
tshark -r ~/capture.pcap | wc -l

# Show Ethernet statistics
tshark -r ~/capture.pcap -z io,stat,0,"eth" | head -20
```

**Expected Output**:
- You should see at least 10+ frames captured
- Ethernet II headers should show valid MAC addresses
- The EtherType field should display `0x0800` for IPv4 or `0x0806` for ARP

---

### Lab 2: Capture an ARP Exchange

**The Target**: Capture a complete ARP request-reply exchange.

**The Concept**: ARP packets are small and easy to identify. We'll capture the request (broadcast) and the reply (unicast).

**The Implementation**:

1. **Clear the ARP cache** to force a fresh ARP request:
   ```bash
   # Linux
   sudo ip neigh flush all
   
   # macOS
   sudo arp -d -a
   
   # Windows (as Administrator)
   arp -d *
   ```

2. **Start Wireshark** or use tcpdump directly:
   ```bash
   # Capture only ARP traffic to a file
   sudo tcpdump -i eth0 -vv arp -w arp_capture.pcap
   ```

3. **Generate ARP traffic** (in a separate terminal):
   ```bash
   # Ping your gateway to trigger ARP
   ping -c 1 $(route -n | grep '^0.0.0.0' | awk '{print $2}')
   
   # OR use arping specifically
   sudo arping -I eth0 192.168.1.1 -c 1
   ```

4. **Stop tcpdump** (Ctrl+C).

5. **Analyze the ARP packets** with tshark:
   ```bash
   # Show all ARP packets
   tshark -r arp_capture.pcap -Y "arp"
   
   # Show only ARP requests
   tshark -r arp_capture.pcap -Y "arp.opcode == 1"
   
   # Show only ARP replies
   tshark -r arp_capture.pcap -Y "arp.opcode == 2"
   
   # Show detailed ARP information
   tshark -r arp_capture.pcap -Y "arp" -V | grep -A 10 "Address Resolution Protocol"
   ```

6. **Inspect ARP timestamps** to see request/reply sequence:
   ```bash
   tshark -r arp_capture.pcap -Y "arp" -T fields -e frame.time_relative -e arp.opcode -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4
   ```

**The Verification**:

Run this Python script to decode your ARP capture:

```python
#!/usr/bin/env python3
"""
arp_decoder.py - Decodes ARP packets from a pcap file
"""

import sys
import struct
from scapy.all import rdpcap, ARP

def decode_arp(filename):
    """Read and decode ARP packets from a pcap file"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    arp_packets = [p for p in packets if ARP in p]
    
    if not arp_packets:
        print("No ARP packets found in the capture")
        return
    
    print(f"Found {len(arp_packets)} ARP packets\n")
    print("=" * 80)
    print(f"{'#':<4} {'Time':<12} {'Type':<8} {'Sender IP':<16} {'Target IP':<16} {'Sender MAC':<18}")
    print("=" * 80)
    
    for i, packet in enumerate(arp_packets, 1):
        arp = packet[ARP]
        op_type = "Request" if arp.op == 1 else "Reply" if arp.op == 2 else f"Unknown({arp.op})"
        timestamp = packet.time if hasattr(packet, 'time') else 0
        
        print(f"{i:<4} {timestamp:<12.6f} {op_type:<8} {arp.psrc:<16} {arp.pdst:<16} {arp.hwsrc:<18}")
    
    print("=" * 80)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    decode_arp(sys.argv[1])
```

**Run the decoder**:
```bash
python3 arp_decoder.py arp_capture.pcap
```

**Expected Output**:
```
Found 2 ARP packets

================================================================================
#    Time         Type     Sender IP        Target IP       Sender MAC       
================================================================================
1    0.001234     Request  192.168.1.10     192.168.1.1     00:1A:2B:3C:4D:5E
2    0.003456     Reply    192.168.1.1      192.168.1.10    11:22:33:44:55:66
================================================================================
```

---

### Lab 3: Observe a DHCP DORA Sequence

**The Target**: Capture a complete DHCP DORA sequence.

**The Concept**: DHCP uses four messages (Discover, Offer, Request, ACK). We'll force a DHCP renew to see the entire sequence.

**The Implementation**:

1. **Release your current DHCP lease**:
   ```bash
   # Linux (replace eth0 with your interface)
   sudo dhclient -v -r eth0
   
   # macOS
   sudo ipconfig set en0 NONE
   sudo ipconfig set en0 DHCP
   
   # Windows
   ipconfig /release
   ipconfig /renew
   ```

2. **Start capturing DHCP traffic**:
   ```bash
   # Capture DHCP (UDP ports 67 and 68)
   sudo tcpdump -i eth0 -vv "udp and (port 67 or port 68)" -w dhcp_capture.pcap
   ```

3. **Request a new lease** (in a separate terminal):
   ```bash
   # Linux
   sudo dhclient -v eth0
   
   # macOS
   sudo ipconfig set en0 DHCP
   
   # Windows
   ipconfig /renew
   ```

4. **Stop tcpdump** after the DHCP process completes.

5. **Analyze the DHCP sequence**:
   ```bash
   # Show all DHCP packets
   tshark -r dhcp_capture.pcap
   
   # Show DHCP message types
   tshark -r dhcp_capture.pcap -Y "dhcp" -T fields -e frame.time_relative -e dhcp.msgtype -e dhcp.option.dhcp_server -e dhcp.option.router
   
   # Show DHCP options
   tshark -r dhcp_capture.pcap -Y "dhcp" -V | grep -A 20 "Dynamic Host Configuration Protocol"
   ```

6. **Use Wireshark's DHCP analysis**:
   - Open the capture in Wireshark
   - Go to **Statistics -> Protocol Hierarchy**
   - Select a DHCP packet and expand the **Bootstrap Protocol** section
   - Examine each field: opcode, hardware type, flags, client IP, your IP, server IP, gateway IP, client MAC

**The Verification**:

Run this Python script to parse DHCP packets:

```python
#!/usr/bin/env python3
"""
dhcp_decoder.py - Decodes DHCP packets from a pcap file
"""

import sys
from scapy.all import rdpcap, DHCP, BOOTP

def decode_dhcp(filename):
    """Read and decode DHCP packets from a pcap file"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    dhcp_packets = [p for p in packets if DHCP in p]
    
    if not dhcp_packets:
        print("No DHCP packets found in the capture")
        return
    
    print(f"Found {len(dhcp_packets)} DHCP packets\n")
    print("=" * 90)
    print(f"{'#':<4} {'Time':<12} {'Type':<10} {'Client IP':<16} {'Server IP':<16} {'Gateway':<16}")
    print("=" * 90)
    
    msg_types = {
        1: "DISCOVER",
        2: "OFFER",
        3: "REQUEST",
        4: "DECLINE",
        5: "ACK",
        6: "NAK",
        7: "RELEASE",
        8: "INFORM"
    }
    
    for i, packet in enumerate(dhcp_packets, 1):
        bootp = packet[BOOTP]
        dhcp = packet[DHCP]
        
        msg_type = dhcp.options.get('message-type', None)
        msg_type_str = msg_types.get(msg_type, f"Unknown({msg_type})") if msg_type else "Unknown"
        
        client_ip = bootp.ciaddr
        server_ip = bootp.siaddr
        gateway_ip = bootp.giaddr
        timestamp = packet.time if hasattr(packet, 'time') else 0
        
        print(f"{i:<4} {timestamp:<12.6f} {msg_type_str:<10} {client_ip:<16} {server_ip:<16} {gateway_ip:<16}")
    
    print("=" * 90)
    
    # Show DHCP options for each packet
    print("\nDetailed DHCP Options:")
    print("-" * 90)
    for i, packet in enumerate(dhcp_packets, 1):
        bootp = packet[BOOTP]
        dhcp = packet[DHCP]
        print(f"\nPacket {i}:")
        for option, value in dhcp.options.items():
            if isinstance(value, bytes):
                print(f"  {option}: (binary data)")
            elif option != 'end':
                print(f"  {option}: {value}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    decode_dhcp(sys.argv[0])
```

**Expected Output**:
```
Found 4 DHCP packets

==========================================================================================
#    Time         Type       Client IP        Server IP        Gateway        
==========================================================================================
1    0.000000     DISCOVER   0.0.0.0          0.0.0.0          0.0.0.0        
2    0.002345     OFFER      0.0.0.0          192.168.1.1      192.168.1.1    
3    0.004567     REQUEST    192.168.1.10     192.168.1.1      192.168.1.1    
4    0.006789     ACK        192.168.1.10     192.168.1.1      192.168.1.1    
==========================================================================================
```

---

### Lab 4: Build an Ethernet Frame Decoder in Python

**The Target**: Build a complete Ethernet frame decoder that reads raw packets and displays each field.

**The Concept**: We'll use Python's `scapy` library to capture frames in real-time and display their structure. This gives you programmatic access to network traffic.

**The Implementation**:

Create a new file called `ethernet_decoder.py`:

```python
#!/usr/bin/env python3
"""
ethernet_decoder.py - Complete Ethernet Frame Decoder

This script captures Ethernet frames and decodes each field,
displaying the results in a human-readable format.
"""

import sys
import struct
import socket
from typing import Optional, Tuple, Dict
from scapy.all import sniff, Ether, IP, TCP, UDP, ARP, DNS, Raw
from scapy.layers.l2 import LLC, SNAP
from scapy.packet import Packet

# Protocol EtherType mappings
ETHERTYPE_MAP = {
    0x0800: "IPv4",
    0x0806: "ARP",
    0x86DD: "IPv6",
    0x8100: "VLAN (802.1Q)",
    0x88A8: "VLAN (802.1AD - QinQ)",
    0x8809: "EAPOL",
    0x888E: "EAP over LAN",
    0x8847: "MPLS Unicast",
    0x8848: "MPLS Multicast",
    0x8863: "PPPoE Discovery",
    0x8864: "PPPoE Session",
    0x8892: "PROFINET",
    0x809B: "AppleTalk",
    0x80F3: "AARP",
    0x8137: "IPX",
    0x8138: "IPX (old)",
    0x8000: "IS-IS",
    0x86DD: "IPv6",
    0x88CC: "LLDP",
    0x8915: "HSRP",
    0x8910: "HSRP (old)",
    0x88E1: "HomePlug AV",
    0x88E5: "MAC Security (802.1AE)",
    0x88F7: "PTP (1588)",
    0x8906: "FCoE",
    0x890D: "FCoE Initialization",
    0x8914: "FCoE Discovery",
}

class EthernetFrameDecoder:
    """Decodes and displays Ethernet frame structures"""
    
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
        self.packet_count = 0
        self.protocol_stats: Dict[str, int] = {}
        self.filtered_protocols: Optional[set] = None
        
    def set_protocol_filter(self, protocols: set) -> None:
        """Only show packets matching the given protocols"""
        self.filtered_protocols = protocols
    
    def display_header(self) -> None:
        """Display a formatted table header"""
        print("\n" + "=" * 100)
        print(f"{'#':<6} {'Time':<14} {'Ethertype':<12} {'Protocol':<12} {'Src MAC':<20} {'Dst MAC':<20}")
        print("=" * 100)
    
    def decode_ethernet(self, packet: Packet) -> Tuple[str, str, str, int, Optional[str]]:
        """
        Decode the Ethernet header from a packet
        
        Returns:
            Tuple of (src_mac, dst_mac, eth_type_str, eth_type_num, protocol_name)
        """
        if not isinstance(packet, Ether):
            return None, None, None, None, None
        
        dst_mac = packet.dst
        src_mac = packet.src
        
        # Get the EtherType or length
        eth_type = packet.type
        eth_type_str = f"0x{eth_type:04X}"
        protocol_name = ETHERTYPE_MAP.get(eth_type, "Unknown")
        
        return src_mac, dst_mac, eth_type_str, eth_type, protocol_name
    
    def decode_payload(self, packet: Packet, protocol_name: str) -> str:
        """Decode the packet payload based on protocol type"""
        if protocol_name == "IPv4":
            if IP in packet:
                ip = packet[IP]
                return f"IP: {ip.src} -> {ip.dst}"
        elif protocol_name == "ARP":
            if ARP in packet:
                arp = packet[ARP]
                op = "Request" if arp.op == 1 else "Reply" if arp.op == 2 else f"Op{arp.op}"
                return f"ARP {op}: {arp.psrc} ({arp.hwsrc}) -> {arp.pdst}"
        elif protocol_name == "IPv6":
            if hasattr(packet, 'ipv6'):
                return f"IPv6: {packet.ipv6.src} -> {packet.ipv6.dst}"
        elif protocol_name in ["TCP", "UDP"]:
            if TCP in packet:
                tcp = packet[TCP]
                return f"TCP: {tcp.sport} -> {tcp.dport}"
            elif UDP in packet:
                udp = packet[UDP]
                return f"UDP: {udp.sport} -> {udp.dport}"
        elif protocol_name == "DNS":
            if DNS in packet:
                dns = packet[DNS]
                return f"DNS: {dns.qd.qname if dns.qd else 'N/A'}"
        
        # Try to get raw payload
        if Raw in packet:
            raw = packet[Raw]
            payload = raw.load[:50]  # Show first 50 bytes
            return f"Raw: {payload.hex()[:30]}..."
        
        return "No payload decoded"
    
    def packet_callback(self, packet: Packet) -> None:
        """Callback function for each captured packet"""
        if not isinstance(packet, Ether):
            return
        
        self.packet_count += 1
        
        # Decode Ethernet header
        src_mac, dst_mac, eth_type_str, eth_type, protocol_name = self.decode_ethernet(packet)
        
        # Skip if protocol filter is set and this packet doesn't match
        if self.filtered_protocols and protocol_name not in self.filtered_protocols:
            return
        
        # Update statistics
        if protocol_name not in self.protocol_stats:
            self.protocol_stats[protocol_name] = 0
        self.protocol_stats[protocol_name] += 1
        
        # Decode payload
        payload_info = self.decode_payload(packet, protocol_name)
        
        # Display packet info
        timestamp = packet.time if hasattr(packet, 'time') else 0
        
        print(f"{self.packet_count:<6} {timestamp:<14.6f} {eth_type_str:<12} {protocol_name:<12} "
              f"{src_mac:<20} {dst_mac:<20}")
        
        # Show payload info if verbose
        if self.verbose and payload_info:
            print(f"  └─ {payload_info}")
        
        # Show additional details for specific protocols
        if protocol_name == "ARP" and ARP in packet:
            arp = packet[ARP]
            print(f"    ├─ Hardware Type: {arp.hwtype} ({'Ethernet' if arp.hwtype == 1 else 'Unknown'})")
            print(f"    ├─ Protocol Type: {arp.ptype} ({'IPv4' if arp.ptype == 0x0800 else 'Unknown'})")
            print(f"    ├─ Operation: {arp.op} ({'Request' if arp.op == 1 else 'Reply' if arp.op == 2 else 'Unknown'})")
            print(f"    ├─ Sender MAC: {arp.hwsrc}")
            print(f"    ├─ Sender IP: {arp.psrc}")
            print(f"    ├─ Target MAC: {arp.hwdst}")
            print(f"    └─ Target IP: {arp.pdst}")
        
        elif protocol_name == "IPv4" and IP in packet:
            ip = packet[IP]
            print(f"    ├─ Version: {ip.version}")
            print(f"    ├─ Header Length: {ip.ihl * 4} bytes")
            print(f"    ├─ TTL: {ip.ttl}")
            print(f"    ├─ Protocol: {ip.proto} ({'TCP' if ip.proto == 6 else 'UDP' if ip.proto == 17 else 'ICMP' if ip.proto == 1 else 'Unknown'})")
            print(f"    ├─ Source IP: {ip.src}")
            print(f"    └─ Destination IP: {ip.dst}")
    
    def run(self, interface: str = None, count: int = 10, filter_expr: str = None) -> None:
        """
        Start capturing and decoding Ethernet frames
        
        Args:
            interface: Network interface to capture on (default: None for auto)
            count: Number of packets to capture (default: 10)
            filter_expr: BPF filter expression (e.g., "arp", "ip", "tcp")
        """
        print(f"Starting Ethernet Frame Decoder...")
        print(f"Interface: {interface or 'Auto'}")
        print(f"Count: {count}")
        print(f"Filter: {filter_expr or 'None'}")
        
        # Check for root privileges
        if interface and not self._check_root_privileges():
            print("WARNING: Root privileges may be required for packet capture on some systems")
        
        self.display_header()
        
        try:
            # Start capture
            sniff(
                iface=interface,
                count=count,
                prn=self.packet_callback,
                filter=filter_expr,
                store=False  # Don't store packets to save memory
            )
        except PermissionError:
            print("\nERROR: Permission denied. Try running with sudo:")
            print(f"  sudo {sys.argv[0]}")
            sys.exit(1)
        except KeyboardInterrupt:
            print("\n\nCapture interrupted by user")
        except Exception as e:
            print(f"\nERROR: {e}")
            sys.exit(1)
        
        # Display statistics
        self.display_statistics()
    
    def display_statistics(self) -> None:
        """Display protocol statistics after capture"""
        print("\n" + "=" * 100)
        print("Protocol Statistics")
        print("=" * 100)
        
        total = sum(self.protocol_stats.values())
        
        for protocol, count in sorted(self.protocol_stats.items(), key=lambda x: x[1], reverse=True):
            percentage = (count / total * 100) if total > 0 else 0
            print(f"  {protocol:<20}: {count:>6} ({percentage:>5.1f}%)")
        
        print(f"\n  {'Total':<20}: {total:>6} (100.0%)")
        print("=" * 100)
    
    @staticmethod
    def _check_root_privileges() -> bool:
        """Check if the script is running with root privileges"""
        try:
            import os
            return os.geteuid() == 0
        except:
            return False

def main():
    """Main entry point with command-line argument parsing"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Ethernet Frame Decoder - Capture and decode network frames",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Capture 10 frames on eth0
  sudo %(prog)s -i eth0 -c 10
  
  # Capture ARP packets only
  sudo %(prog)s -i eth0 -f "arp" -c 5
  
  # Capture without verbose output
  sudo %(prog)s -i eth0 -q
        """
    )
    
    parser.add_argument(
        "-i", "--interface",
        help="Network interface to capture on (e.g., eth0, en0)"
    )
    parser.add_argument(
        "-c", "--count", type=int, default=10,
        help="Number of packets to capture (default: 10)"
    )
    parser.add_argument(
        "-f", "--filter",
        help="BPF filter expression (e.g., 'arp', 'ip', 'tcp port 80')"
    )
    parser.add_argument(
        "-p", "--protocols", nargs="+",
        help="Only show specific protocols (e.g., ARP IPv4 TCP)"
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true",
        help="Disable verbose output"
    )
    
    args = parser.parse_args()
    
    # Create decoder instance
    decoder = EthernetFrameDecoder(verbose=not args.quiet)
    
    # Set protocol filter if specified
    if args.protocols:
        decoder.set_protocol_filter(set(args.protocols))
    
    # Run capture
    decoder.run(
        interface=args.interface,
        count=args.count,
        filter_expr=args.filter
    )

if __name__ == "__main__":
    # Check if running as root (warning only)
    import os
    if os.geteuid() != 0:
        print("WARNING: Running without root privileges. Packet capture may be limited.")
        print("Try: sudo python3 ethernet_decoder.py\n")
    
    main()
```

**Install dependencies**:
```bash
pip install scapy
```

**Run the decoder**:
```bash
# Run with root privileges
sudo python3 ethernet_decoder.py -i eth0 -c 10

# Capture only ARP packets
sudo python3 ethernet_decoder.py -i eth0 -f "arp" -c 5

# Show only IPv4 traffic with less output
sudo python3 ethernet_decoder.py -i eth0 -p IPv4 -q
```

**The Verification**:

Test the decoder with a sample capture file:

```bash
# First, create a test capture
sudo tcpdump -i eth0 -c 5 -w test.pcap

# Then, use Scapy to read it programmatically
python3 -c "
from scapy.all import rdpcap, Ether
packets = rdpcap('test.pcap')
for p in packets[:5]:
    if Ether in p:
        eth = p[Ether]
        print(f'Frame: {eth.src} -> {eth.dst} Type: 0x{eth.type:04X}')
"
```

**Expected Output**:
```
Starting Ethernet Frame Decoder...
Interface: eth0
Count: 10
Filter: None

====================================================================================================
#      Time           Ethertype    Protocol     Src MAC              Dst MAC              
====================================================================================================
1      1634.567890    0x0800       IPv4         aa:bb:cc:dd:ee:ff   00:11:22:33:44:55  
  └─ IP: 192.168.1.10 -> 192.168.1.1
    ├─ Version: 4
    ├─ Header Length: 20 bytes
    ├─ TTL: 64
    ├─ Protocol: 6 (TCP)
    ├─ Source IP: 192.168.1.10
    └─ Destination IP: 192.168.1.1

2      1634.568901    0x0806       ARP         aa:bb:cc:dd:ee:ff   00:11:22:33:44:55  
  └─ ARP Request: 192.168.1.10 (aa:bb:cc:dd:ee:ff) -> 192.168.1.1
    ├─ Hardware Type: 1 (Ethernet)
    ├─ Protocol Type: 0x0800 (IPv4)
    ├─ Operation: 1 (Request)
    ├─ Sender MAC: aa:bb:cc:dd:ee:ff
    ├─ Sender IP: 192.168.1.10
    ├─ Target MAC: 00:00:00:00:00:00
    └─ Target IP: 192.168.1.1

====================================================================================================
Protocol Statistics
====================================================================================================
  IPv4                 :      6 (60.0%)
  ARP                  :      4 (40.0%)
  Total                :     10 (100.0%)
====================================================================================================
```

---

## Section 6: Reference: Complete Ethernet and ARP Field Reference

### Ethernet II Frame Fields

| Field | Size | Description |
|-------|------|-------------|
| **Preamble** | 7 bytes | Synchronization pattern (10101010 repeated) |
| **SFD** | 1 byte | Start Frame Delimiter (10101011) |
| **Destination MAC** | 6 bytes | Recipient's MAC address |
| **Source MAC** | 6 bytes | Sender's MAC address |
| **EtherType/Length** | 2 bytes | Protocol type (>=0x0600) or frame length (<0x0600) |
| **Payload** | 46-1500 bytes | Encapsulated data (IP, ARP, etc.) |
| **FCS** | 4 bytes | CRC-32 checksum |

### ARP Packet Fields

| Field | Size | Values |
|-------|------|--------|
| **Hardware Type** | 2 bytes | 1 = Ethernet, 6 = IEEE 802 |
| **Protocol Type** | 2 bytes | 0x0800 = IPv4, 0x86DD = IPv6 |
| **Hardware Address Length** | 1 byte | 6 for Ethernet |
| **Protocol Address Length** | 1 byte | 4 for IPv4 |
| **Operation** | 2 bytes | 1 = Request, 2 = Reply |
| **Sender Hardware Address** | variable | Source MAC (6 for Ethernet) |
| **Sender Protocol Address** | variable | Source IP (4 for IPv4) |
| **Target Hardware Address** | variable | Target MAC (6 for Ethernet) |
| **Target Protocol Address** | variable | Target IP (4 for IPv4) |

### DHCP Message Types

| Type | Code | Description |
|------|------|-------------|
| DHCPDISCOVER | 1 | Client discovers DHCP servers |
| DHCPOFFER | 2 | Server offers an IP address |
| DHCPREQUEST | 3 | Client requests offered IP |
| DHCPDECLINE | 4 | Client declines IP (conflict detected) |
| DHCPACK | 5 | Server acknowledges IP assignment |
| DHCPNAK | 6 | Server declines request |
| DHCPRELEASE | 7 | Client releases IP |
| DHCPINFORM | 8 | Client requests configuration info |

### Common DHCP Options

| Option | Code | Description | Example |
|--------|------|-------------|---------|
| Subnet Mask | 1 | Network mask | 255.255.255.0 |
| Router | 3 | Default gateway | 192.168.1.1 |
| Domain Name Server | 6 | DNS servers | 8.8.8.8, 1.1.1.1 |
| Host Name | 12 | Client hostname | my-hostname |
| Domain Name | 15 | DNS domain | example.com |
| Interface MTU | 26 | MTU size | 1500 |
| DHCP Message Type | 53 | Message type | 1 (Discover) |
| Server Identifier | 54 | DHCP server IP | 192.168.1.1 |
| Parameter Request List | 55 | Options requested | 1,3,6,15 |
| Lease Time | 51 | Lease duration in seconds | 86400 |
| Renewal (T1) | 58 | Renewal time | 43200 |
| Rebinding (T2) | 59 | Rebinding time | 75600 |

---

## Summary

In Part 1, we've covered the foundation of all network communication:

1. **Networking Models**: The OSI and TCP/IP models provide the framework for understanding how protocols interact.

2. **Ethernet**: The most common local network protocol, using MAC addresses for device identification and Ethernet frames for data encapsulation.

3. **ARP**: The glue between IP and MAC addresses, enabling devices to find each other on the local network.

4. **DHCP**: Automatic IP address configuration that makes modern networks scalable and manageable.

**Key Takeaways**:
- Data travels through layers, with each layer adding and removing headers
- MAC addresses are hardware identifiers; IP addresses are logical identifiers
- Switches operate at Layer 2 using MAC addresses
- ARP converts IP addresses to MAC addresses on local networks
- DHCP automates network configuration through the DORA process
- Real network traffic is complex but follows predictable patterns

**What's Next**: In Part 2, we'll move beyond the local network to explore how data travels across the global Internet using IP addressing, routing, and ICMP. We'll examine how packets find their way across thousands of networks to reach any device on Earth.
