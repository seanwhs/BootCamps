# Part 3: The Transport Layer

## Reliability vs Speed: Inside TCP and UDP

---

## Synopsis

The Transport Layer determines whether applications prioritize speed, reliability, or both. This tutorial explores how TCP establishes reliable connections, how UDP minimizes overhead for real-time applications, and how operating systems multiplex thousands of simultaneous connections through ports and sockets.

Readers will also implement their own network applications using sockets to reinforce protocol behavior, build a complete TCP server, examine congestion control algorithms, and understand when to choose each protocol.

By the end of this part, you'll understand how applications communicate over networks and be able to build network programs using both TCP and UDP.

---

## Prerequisites

Before starting Part 3, ensure you have:
1. **Completed Parts 1 and 2** or have equivalent knowledge
2. **Python 3.8+** installed with `pip` available
3. **Node.js 14+** installed (for JavaScript socket examples)
4. **Wireshark** installed and working
5. **Root/Administrator privileges** for packet capture

---

## Part 3 Roadmap

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 3: TRANSPORT LAYER                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. UDP: User Datagram Protocol                             │
│     ├─ Datagram Communication                              │
│     ├─ UDP Header Format                                   │
│     ├─ Checksum Calculation                               │
│     ├─ Broadcast & Multicast                              │
│     └─ Use Cases: DNS, Streaming, VoIP, Gaming            │
│                                                             │
│  2. TCP: Transmission Control Protocol                      │
│     ├─ Segment Format                                      │
│     ├─ Three-Way Handshake                                 │
│     ├─ Four-Way Termination                                │
│     ├─ TCP State Machine                                   │
│     ├─ Sequence & Acknowledgment Numbers                  │
│     └─ Retransmissions                                    │
│                                                             │
│  3. Reliability Mechanisms                                  │
│     ├─ Sliding Windows                                     │
│     ├─ Flow Control (Window Scaling)                      │
│     ├─ Congestion Control (Slow Start, Reno, Cubic)      │
│     └─ BBR (Bottleneck Bandwidth and RTT)                 │
│                                                             │
│  4. Socket Programming                                      │
│     ├─ Ports & Sockets                                     │
│     ├─ TCP Socket Programming in Python                   │
│     ├─ UDP Socket Programming in Python                   │
│     ├─ Node.js TCP/UDP Examples                           │
│     └─ Multiplexing (Select/Poll/Epoll)                   │
│                                                             │
│  5. Hands-On Labs                                           │
│     ├─ Lab 1: Build a TCP Echo Server                     │
│     ├─ Lab 2: Build a UDP Echo Server                     │
│     ├─ Lab 3: Observe TCP Handshake & Termination        │
│     ├─ Lab 4: Capture TCP Retransmissions                │
│     └─ Lab 5: Build a Multi-Client Chat Server            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 1: UDP - User Datagram Protocol

### What is UDP?

**UDP (User Datagram Protocol)** is a connectionless, unreliable transport protocol. It provides minimal functionality: just multiplexing via ports and an optional checksum. Everything else—reliability, ordering, flow control, congestion control—is left to the application.

**Analogy**: UDP is like sending postcards. You drop them in the mailbox (send), and they might arrive, might not, might arrive out of order, and you won't know either way. It's fast and efficient but provides no guarantees.

### UDP Header Format

The UDP header is only 8 bytes long:

```
┌─────────────────────────────────────────────────────────────────┐
│                    UDP HEADER (8 bytes)                        │
├───────────────────┬─────────────────────────────────────────────┤
│                   │                                             │
│  0-15 bits: Source Port                                         │
│  16-31 bits: Destination Port                                   │
│  32-47 bits: Length                                            │
│  48-63 bits: Checksum                                          │
│                                                                 │
│  Payload follows immediately after header                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Field Details**:

| Field | Size | Description | Notes |
|-------|------|-------------|-------|
| **Source Port** | 16 bits | Sender's port number | Optional; if not used, set to 0 |
| **Destination Port** | 16 bits | Recipient's port number | Required |
| **Length** | 16 bits | Entire UDP datagram size (header + payload) | Minimum 8 bytes |
| **Checksum** | 16 bits | Error detection | Optional in IPv4; mandatory in IPv6 |
| **Payload** | variable | Application data | Maximum 65,507 bytes (65,535 - 8 header - 20 IP header) |

### UDP Checksum Calculation

The UDP checksum covers the UDP header, payload, and a **pseudo-header** (containing IP addresses and protocol number):

```
┌─────────────────────────────────────────────────────────────┐
│                    UDP PSEUDO-HEADER                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Source IP Address (32 bits)                               │
│  Destination IP Address (32 bits)                          │
│  Zero (8 bits)                                             │
│  Protocol (8 bits: 17 for UDP)                            │
│  UDP Length (16 bits)                                     │
│                                                             │
│  Combined with UDP header and payload for checksum        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

The checksum provides **end-to-end** integrity verification across the entire path.

### UDP Use Cases

UDP is preferred when speed matters more than reliability:

| Application | Why UDP | Details |
|-------------|---------|---------|
| **DNS** | Fast queries | Single request/response, retransmit if needed |
| **VoIP** | Low latency | Packet loss is preferable to delay |
| **Video Streaming** | Real-time | Missing frames are okay; buffering is not |
| **Online Gaming** | Low latency | Fast updates for game state |
| **SNMP** | Simple queries | Network monitoring |
| **DHCP** | Broadcast-based | Dynamic IP configuration |
| **TFTP** | Simple file transfer | Trivial File Transfer Protocol |

### Broadcast and Multicast with UDP

UDP supports **broadcast** (sending to all devices on a network) and **multicast** (sending to a group of interested devices):

```python
# UDP Broadcast Example
import socket

# Create UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Enable broadcast
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

# Send to broadcast address
sock.sendto(b"Hello everyone!", ('255.255.255.255', 12345))
```

---

## Section 2: TCP - Transmission Control Protocol

### What is TCP?

**TCP (Transmission Control Protocol)** is a connection-oriented, reliable transport protocol. It provides:
- **Connection establishment** (three-way handshake)
- **Reliable delivery** (acknowledgments and retransmissions)
- **Ordered delivery** (sequence numbers)
- **Flow control** (prevents sender from overwhelming receiver)
- **Congestion control** (prevents network collapse)

**Analogy**: TCP is like making a phone call. You dial, the other person answers, you talk (send data), listen (receive data), and then say goodbye (close the connection). Everything is delivered in order, and if something isn't heard, you repeat it.

### TCP Segment Format

TCP segments are larger and more complex than UDP datagrams:

```
┌─────────────────────────────────────────────────────────────────┐
│                    TCP HEADER (20-60 bytes)                    │
├───────────────────┬─────────────────────────────────────────────┤
│                   │                                             │
│  0-15 bits: Source Port                                         │
│  16-31 bits: Destination Port                                   │
│  32-63 bits: Sequence Number                                   │
│  64-95 bits: Acknowledgment Number (if ACK flag set)           │
│  96-99 bits: Data Offset (header length in 32-bit words)       │
│  100-102 bits: Reserved                                        │
│  103-111 bits: Flags (NS, CWR, ECE, URG, ACK, PSH, RST, SYN, │
│                 FIN)                                           │
│  112-127 bits: Window Size                                     │
│  128-143 bits: Checksum                                        │
│  144-159 bits: Urgent Pointer (if URG flag set)               │
│  160-... bits: Options (optional)                             │
│  ... bits: Payload                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Field Details**:

| Field | Size | Description |
|-------|------|-------------|
| **Source Port** | 16 bits | Sender's port number |
| **Destination Port** | 16 bits | Recipient's port number |
| **Sequence Number** | 32 bits | Position of this segment's data in the stream |
| **Acknowledgment Number** | 32 bits | Next expected byte (if ACK set) |
| **Data Offset** | 4 bits | Header length in 32-bit words (5-15) |
| **Flags** | 9 bits | Control bits: SYN, ACK, FIN, RST, PSH, URG, ECE, CWR, NS |
| **Window Size** | 16 bits | Available receive buffer (flow control) |
| **Checksum** | 16 bits | Error detection (includes pseudo-header) |
| **Urgent Pointer** | 16 bits | Offset to urgent data (if URG set) |
| **Options** | variable | Extended features (MSS, window scaling, SACK, Timestamp) |
| **Payload** | variable | Application data |

### TCP Flags Explained

| Flag | Name | Purpose |
|------|------|---------|
| **SYN** | Synchronize | Start a new connection (handshake) |
| **ACK** | Acknowledgment | Acknowledge received data |
| **FIN** | Finish | Gracefully close a connection |
| **RST** | Reset | Abruptly terminate a connection |
| **PSH** | Push | Push data to application immediately |
| **URG** | Urgent | Urgent data (rarely used) |
| **ECE** | ECN-Echo | Congestion notification |
| **CWR** | Congestion Window Reduced | Congestion control |

### The Three-Way Handshake

TCP connections are established using a **three-way handshake**:

```
┌─────────────────────────────────────────────────────────────┐
│                    THREE-WAY HANDSHAKE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Client (192.168.1.10)        Server (192.168.1.20)       │
│          │                                │                 │
│          │  1. SYN (seq=x)               │                 │
│          │  "I want to connect, my ISN is x"              │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│          │  2. SYN+ACK (seq=y, ack=x+1)  │                 │
│          │  "OK, my ISN is y, I received x"               │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  3. ACK (seq=x+1, ack=y+1)    │                 │
│          │  "Great, I received y, connection established"  │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│          │        [ESTABLISHED]          │                 │
│          │                                │                 │
└─────────────────────────────────────────────────────────────┘
```

**Important Details**:

- **ISN (Initial Sequence Number)**: Randomly chosen to prevent attacks
- **SYN consumes one sequence number** in the stream
- **The connection is half-open** after step 1 (SYN_SENT state)
- **The connection is fully open** after step 3 (ESTABLISHED state)

### The Four-Way Termination

TCP connections are gracefully closed with a **four-way handshake**:

```
┌─────────────────────────────────────────────────────────────┐
│                    FOUR-WAY TERMINATION                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Client (192.168.1.10)        Server (192.168.1.20)       │
│          │                                │                 │
│          │  1. FIN (seq=u)               │                 │
│          │  "I'm done sending data"      │                 │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│          │  2. ACK (ack=u+1)             │                 │
│          │  "I received your FIN"        │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │        [Client waits for server]                │
│          │                                │                 │
│          │  3. FIN (seq=v)               │                 │
│          │  "I'm done sending data too"   │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  4. ACK (ack=v+1)             │                 │
│          │  "Connection closed"          │                 │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│          │        [CLOSED]               │                 │
│          │                                │                 │
└─────────────────────────────────────────────────────────────┘
```

**Important Notes**:
- **Both sides must FIN**: TCP is full-duplex
- **TIME_WAIT state**: Client waits 2MSL (Maximum Segment Lifetime) before closing
- **MSL** is typically 60 seconds (2 minutes typical for TIME_WAIT)
- **RST** can close the connection immediately (abortive close)

### TCP State Machine

A TCP connection transitions through several states:

```
┌─────────────────────────────────────────────────────────────┐
│                    TCP STATE MACHINE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Server:                    Client:                        │
│   LISTEN                     CLOSED                         │
│      │                          │                           │
│      │    SYN received          │ SYN sent                  │
│      ▼                          ▼                           │
│   SYN-RCVD                  SYN-SENT                       │
│      │                          │                           │
│      └────────── SYN-ACK ──────┘                           │
│               │                                             │
│               ▼                                             │
│           ESTABLISHED                                       │
│               │                                             │
│         (Data Transfer)                                     │
│               │                                             │
│               ├─ FIN sent ──► FIN-WAIT-1                   │
│               │               │                             │
│               │   ACK received▼                             │
│               │           FIN-WAIT-2                       │
│               │               │                             │
│               │   FIN received│                             │
│               │               ▼                             │
│               │           TIME-WAIT                       │
│               │               │                             │
│               │   2MSL wait   │                             │
│               │               ▼                             │
│               │           CLOSED                           │
│               │                                             │
│   FIN received │                                            │
│       ▼          │                                            │
│   CLOSE-WAIT     │                                            │
│       │          │                                            │
│   FIN sent │     │                                            │
│       ▼          │                                            │
│   LAST-ACK       │                                            │
│       │          │                                            │
│   ACK received │                                              │
│       ▼          │                                            │
│   CLOSED         │                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Sequence and Acknowledgment Numbers

Sequence and acknowledgment numbers are the heart of TCP reliability:

```
┌─────────────────────────────────────────────────────────────┐
│                    SEQUENCE/ACK EXAMPLE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Client seq=100, sends 10 bytes:                           │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Seq=100, Len=10, Data "Hello World"                   ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Server receives, sends ACK for next expected byte:        │
│  ┌────────────────────────────────────────────────────────┐│
│  │ ACK=110 (100 + 10)                                    ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  If a segment is lost, the receiver ACKs the last received │
│  byte, and the sender retransmits:                        │
│                                                             │
│  Sender: Seq=100 (sent), Seq=110 (lost)                   │
│  Receiver: ACK=110 (still expecting byte 110)             │
│  Sender: Retransmits Seq=110                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Retransmission and Timeout

TCP uses **retransmission timeouts (RTO)** and **fast retransmit** to recover lost segments:

```
┌─────────────────────────────────────────────────────────────┐
│                    RETRANSMISSION MECHANISM                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Normal Operation:                                          │
│  ┌──────────┐    ┌──────────┐                              │
│  │  Data    │───►│  ACK     │                              │
│  └──────────┘    └──────────┘                              │
│                                                             │
│  Lost Segment:                                              │
│  ┌──────────┐    ┌──────────┐                              │
│  │  Data    │───►│ (lost)   │                              │
│  └──────────┘    └──────────┘                              │
│       │                                                     │
│       │  Timer expires (RTO)                               │
│       ▼                                                     │
│  ┌──────────┐    ┌──────────┐                              │
│  │ Retrans  │───►│  ACK     │                              │
│  └──────────┘    └──────────┘                              │
│                                                             │
│  Fast Retransmit (3 duplicate ACKs):                       │
│  ┌──────────┐    ┌──────────┐                              │
│  │ Seg 1    │───►│  ACK 1   │                              │
│  └──────────┘    └──────────┘                              │
│  ┌──────────┐    ┌──────────┐                              │
│  │ Seg 2    │───►│ (lost)   │                              │
│  └──────────┘    └──────────┘                              │
│  ┌──────────┐    ┌──────────┐                              │
│  │ Seg 3    │───►│  ACK 1   │ (dup)                       │
│  └──────────┘    └──────────┘                              │
│  ┌──────────┐    ┌──────────┐                              │
│  │ Seg 4    │───►│  ACK 1   │ (dup)                       │
│  └──────────┘    └──────────┘                              │
│  ┌──────────┐    ┌──────────┐                              │
│  │ Seg 5    │───►│  ACK 1   │ (dup)                       │
│  └──────────┘    └──────────┘                              │
│                                                             │
│  After 3 duplicate ACKs, sender retransmits immediately   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 3: Reliability Mechanisms

### Sliding Window

TCP uses a **sliding window** to manage the flow of data:

```
┌─────────────────────────────────────────────────────────────┐
│                    SLIDING WINDOW                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Sender's View:                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Sent and ACKed │ Sent and Waiting │ Can Send │ Cannot ││
│  │    ✓✓✓✓✓✓     │     ????        │  █████  │  Send  ││
│  └────────────────────────────────────────────────────────┘│
│  ▲                 ▲                ▲          ▲          │
│  │                 │                │          │          │
│  Last ACKed      SND.NXT      SND.UNA+Window   │          │
│                                                             │
│  Receiver's View:                                           │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Received and ACKed │ Can Receive │ Cannot Receive    ││
│  │    ✓✓✓✓✓✓✓        │   ███████   │                   ││
│  └────────────────────────────────────────────────────────┘│
│  ▲                     ▲                                   │
│  │                     │                                   │
│  RCV.NXT          RCV.NXT+Window                          │
│                                                             │
│  Window Size: Available buffer space at receiver          │
│  Flow Control: Prevents sender from overwhelming receiver  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Flow Control (Window Scaling)

**Window scaling** (RFC 1323) allows windows larger than 65,535 bytes:

```
┌─────────────────────────────────────────────────────────────┐
│                    WINDOW SCALING                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Without Scaling:                                           │
│  ├─ Max window: 65,535 bytes                              │
│  └─ Limited performance on high-speed networks            │
│                                                             │
│  With Scaling (Window Scale Option):                       │
│  ├─ Window size = 65,535 × 2^scale_factor                │
│  ├─ Scale factor negotiated in SYN packets                │
│  └─ Max window: ~1GB (when scale=14)                     │
│                                                             │
│  Example:                                                   │
│  ├─ Window: 65,535                                        │
│  ├─ Scale: 7                                              │
│  └─ Effective window: 65,535 × 128 = 8,388,480 bytes     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Congestion Control

TCP uses four primary congestion control algorithms:

**1. Slow Start**:
- Start with a small congestion window (cwnd = 1 MSS)
- Double cwnd every RTT until a threshold is reached
- Exponential growth

**2. Congestion Avoidance**:
- Once ssthresh is reached, increase cwnd by 1 MSS per RTT
- Linear growth

**3. Fast Retransmit**:
- When 3 duplicate ACKs are received, retransmit immediately
- No waiting for timeout

**4. Fast Recovery**:
- After fast retransmit, reduce ssthresh to half of cwnd
- Set cwnd to ssthresh + 3 MSS (segments already in flight)

```
┌─────────────────────────────────────────────────────────────┐
│                    CONGESTION CONTROL GRAPH                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Congestion Window (cwnd)                                  │
│       ▲                                                     │
│       │                    ┌──────────────────┐            │
│       │                    │  Congestion      │            │
│       │                   /│  Avoidance      │            │
│       │                  / │  (Additive)     │            │
│       │                 /  │  Increase       │            │
│       │                /   │                  │            │
│       │               /    │                  │            │
│       │              /     │                  │            │
│       │     ┌───────┘      │                  │            │
│       │     │ Slow Start   │                  │            │
│       │     │ (Exponential)│                  │            │
│       │     │              │                  │            │
│       ├─────┘              │                  │            │
│       │                    │                  │            │
│       │                    │    Packet Loss ──┼──► ssthresh│
│       │                    │                  │   = cwnd/2│
│       │                    │    Timeout ──────┼──► cwnd=1 │
│       │                    │                  │            │
│       └────────────────────────────────────────────────────►
│                       Time                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### BBR (Bottleneck Bandwidth and Round-Trip Time)

**BBR** is a modern congestion control algorithm (developed by Google) that models network capacity:

```
┌─────────────────────────────────────────────────────────────┐
│                    BBR CONGESTION CONTROL                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Traditional (Cubic/Reno):                                 │
│  ├─ React to packet loss                                  │
│  └─ Probe for bandwidth by filling buffers                │
│                                                             │
│  BBR:                                                       │
│  ├─ Models bottleneck bandwidth and RTT                   │
│  ├─ Sends at precisely the network's capacity             │
│  ├─ Avoids bufferbloat                                    │
│  └─ Measures delivery rate of ACKs                        │
│                                                             │
│  States:                                                    │
│  ├─ STARTUP: Ramp up quickly (like slow start)            │
│  ├─ DRAIN: Let queues drain                               │
│  ├─ PROBE_BW: Explore bandwidth                           │
│  └─ PROBE_RTT: Check for lower RTT                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 4: Socket Programming

### Ports and Sockets

**Ports** identify specific applications on a host (0-65535):

| Port Range | Purpose |
|------------|---------|
| 0-1023 | Well-known ports (privileged) |
| 1024-49151 | Registered ports |
| 49152-65535 | Dynamic/private ports |

**A socket** is the endpoint of a connection. It's defined by:
- Protocol (TCP/UDP)
- Local IP address
- Local port number

```
┌─────────────────────────────────────────────────────────────┐
│                    SOCKET ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Socket: (192.168.1.10:54321)                              │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │                   TCP Socket                          ││
│  │  ┌────────────────────────────────────────────────────┐││
│  │  │  Connection: (192.168.1.10:54321) ────────────► │││
│  │  │              (192.168.1.20:80)                    │││
│  │  └────────────────────────────────────────────────────┘││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │                   UDP Socket                          ││
│  │  ┌────────────────────────────────────────────────────┐││
│  │  │  Datagram: (192.168.1.10:54321) ────────────►   │││
│  │  │            (192.168.1.20:53)                     │││
│  │  └────────────────────────────────────────────────────┘││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Socket Types:                                              │
│  ├─ Stream (SOCK_STREAM): TCP                              │
│  ├─ Datagram (SOCK_DGRAM): UDP                            │
│  └─ Raw (SOCK_RAW): Direct IP access                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### TCP Socket Programming in Python

A complete TCP echo server and client:

**TCP Server**:
```python
#!/usr/bin/env python3
"""
tcp_echo_server.py - Complete TCP echo server with error handling
"""

import socket
import sys
import threading
import time
from typing import Optional

class TCPEchoServer:
    """TCP echo server with connection handling and logging"""
    
    def __init__(self, host: str = '', port: int = 8080, buffer_size: int = 4096):
        self.host = host
        self.port = port
        self.buffer_size = buffer_size
        self.server_socket: Optional[socket.socket] = None
        self.running = False
        self.client_count = 0
        
    def start(self):
        """Start the TCP echo server"""
        try:
            # Create socket
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            
            # Allow address reuse
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            # Bind to address
            self.server_socket.bind((self.host, self.port))
            
            # Listen for connections
            self.server_socket.listen(5)
            self.running = True
            
            print(f"[*] TCP Echo Server listening on port {self.port}")
            print(f"[*] Server address: {self.host or '0.0.0.0'}:{self.port}")
            
            # Accept connections
            while self.running:
                try:
                    client_socket, client_address = self.server_socket.accept()
                    self.client_count += 1
                    
                    # Start client handler thread
                    client_thread = threading.Thread(
                        target=self.handle_client,
                        args=(client_socket, client_address),
                        daemon=True
                    )
                    client_thread.start()
                    
                except socket.error as e:
                    if self.running:
                        print(f"[!] Accept error: {e}")
                        continue
                    
        except Exception as e:
            print(f"[!] Server error: {e}")
            sys.exit(1)
        finally:
            self.shutdown()
    
    def handle_client(self, client_socket: socket.socket, address: tuple):
        """Handle a single client connection"""
        client_id = f"{address[0]}:{address[1]}"
        print(f"[+] New connection from {client_id} (Total: {self.client_count})")
        
        try:
            client_socket.settimeout(30.0)  # 30 second timeout
            
            while self.running:
                # Receive data
                data = client_socket.recv(self.buffer_size)
                
                if not data:
                    # Client closed connection
                    print(f"[-] Connection closed by {client_id}")
                    break
                
                print(f"[*] Received {len(data)} bytes from {client_id}")
                
                # Echo data back
                client_socket.send(data)
                print(f"[*] Echoed {len(data)} bytes to {client_id}")
                
        except socket.timeout:
            print(f"[!] Connection timeout from {client_id}")
        except socket.error as e:
            print(f"[!] Socket error with {client_id}: {e}")
        finally:
            client_socket.close()
            print(f"[-] Connection from {client_id} closed")
    
    def shutdown(self):
        """Shutdown the server gracefully"""
        self.running = False
        
        if self.server_socket:
            self.server_socket.close()
            print("[*] Server socket closed")
    
    def get_stats(self):
        """Return server statistics"""
        return {
            'port': self.port,
            'client_count': self.client_count,
            'running': self.running
        }

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="TCP Echo Server")
    parser.add_argument('-p', '--port', type=int, default=8080, help='Port to listen on')
    parser.add_argument('-b', '--buffer', type=int, default=4096, help='Buffer size')
    
    args = parser.parse_args()
    
    server = TCPEchoServer(port=args.port, buffer_size=args.buffer)
    
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Shutting down...")
        server.shutdown()

if __name__ == "__main__":
    main()
```

**TCP Client**:
```python
#!/usr/bin/env python3
"""
tcp_echo_client.py - TCP echo client with connection management
"""

import socket
import sys
import time

class TCPEchoClient:
    """TCP echo client with connection handling"""
    
    def __init__(self, host: str = 'localhost', port: int = 8080):
        self.host = host
        self.port = port
        self.socket: socket.socket = None
        self.connected = False
    
    def connect(self) -> bool:
        """Connect to the echo server"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.host, self.port))
            self.connected = True
            print(f"[*] Connected to {self.host}:{self.port}")
            return True
        except socket.error as e:
            print(f"[!] Connection failed: {e}")
            return False
    
    def echo(self, message: str, timeout: float = 5.0) -> Optional[str]:
        """Send message and wait for echo"""
        if not self.connected:
            print("[!] Not connected")
            return None
        
        try:
            self.socket.settimeout(timeout)
            
            # Send message
            self.socket.send(message.encode('utf-8'))
            print(f"[*] Sent: {message}")
            
            # Receive echo
            data = self.socket.recv(4096)
            response = data.decode('utf-8')
            print(f"[*] Received: {response}")
            
            return response
            
        except socket.timeout:
            print("[!] Timeout waiting for echo")
            return None
        except socket.error as e:
            print(f"[!] Error: {e}")
            return None
    
    def close(self):
        """Close the connection"""
        if self.socket:
            self.socket.close()
            self.connected = False
            print("[*] Connection closed")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="TCP Echo Client")
    parser.add_argument('-h', '--host', default='localhost', help='Server host')
    parser.add_argument('-p', '--port', type=int, default=8080, help='Server port')
    parser.add_argument('-m', '--message', help='Message to echo')
    
    args = parser.parse_args()
    
    client = TCPEchoClient(host=args.host, port=args.port)
    
    try:
        if client.connect():
            if args.message:
                client.echo(args.message)
            else:
                # Interactive mode
                print("\n[*] Interactive mode. Enter messages to echo (Ctrl+C to exit)")
                print("[*] Type 'quit' or 'exit' to close\n")
                while True:
                    try:
                        msg = input("> ")
                        if msg.lower() in ['quit', 'exit']:
                            break
                        if msg.strip():
                            client.echo(msg)
                    except KeyboardInterrupt:
                        break
    except KeyboardInterrupt:
        print("\n[!] Interrupted")
    finally:
        client.close()

if __name__ == "__main__":
    main()
```

### UDP Socket Programming in Python

**UDP Echo Server**:
```python
#!/usr/bin/env python3
"""
udp_echo_server.py - UDP echo server with connection tracking
"""

import socket
import sys
import datetime
from typing import Dict, Tuple

class UDPEchoServer:
    """UDP echo server with client tracking"""
    
    def __init__(self, host: str = '', port: int = 8081, buffer_size: int = 4096):
        self.host = host
        self.port = port
        self.buffer_size = buffer_size
        self.socket: socket.socket = None
        self.running = False
        self.client_stats: Dict[Tuple[str, int], int] = {}
    
    def start(self):
        """Start the UDP echo server"""
        try:
            # Create UDP socket
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            
            # Allow address reuse
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            # Bind to address
            self.socket.bind((self.host, self.port))
            self.running = True
            
            print(f"[*] UDP Echo Server listening on port {self.port}")
            print(f"[*] Server address: {self.host or '0.0.0.0'}:{self.port}")
            
            while self.running:
                try:
                    # Receive data
                    data, client_address = self.socket.recvfrom(self.buffer_size)
                    
                    # Update client statistics
                    if client_address not in self.client_stats:
                        self.client_stats[client_address] = 0
                    self.client_stats[client_address] += 1
                    
                    # Echo data back
                    self.socket.sendto(data, client_address)
                    
                    # Log the interaction
                    timestamp = datetime.datetime.now().isoformat()
                    print(f"[{timestamp}] Echoed {len(data)} bytes to {client_address[0]}:{client_address[1]}")
                    
                except socket.error as e:
                    if self.running:
                        print(f"[!] Socket error: {e}")
                        continue
                    
        except Exception as e:
            print(f"[!] Server error: {e}")
            sys.exit(1)
        finally:
            self.shutdown()
    
    def get_stats(self):
        """Return client statistics"""
        total_messages = sum(self.client_stats.values())
        return {
            'port': self.port,
            'client_count': len(self.client_stats),
            'total_messages': total_messages,
            'clients': self.client_stats
        }
    
    def shutdown(self):
        """Shutdown the server"""
        self.running = False
        if self.socket:
            self.socket.close()
            print("[*] Server socket closed")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="UDP Echo Server")
    parser.add_argument('-p', '--port', type=int, default=8081, help='Port to listen on')
    parser.add_argument('-b', '--buffer', type=int, default=4096, help='Buffer size')
    
    args = parser.parse_args()
    
    server = UDPEchoServer(port=args.port, buffer_size=args.buffer)
    
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Shutting down...")
        print("\nClient Statistics:")
        stats = server.get_stats()
        print(f"  Total Clients: {stats['client_count']}")
        print(f"  Total Messages: {stats['total_messages']}")
        for client, count in stats['clients'].items():
            print(f"    {client[0]}:{client[1]}: {count} messages")
        server.shutdown()

if __name__ == "__main__":
    main()
```

**UDP Client**:
```python
#!/usr/bin/env python3
"""
udp_echo_client.py - UDP echo client
"""

import socket
import sys

class UDPEchoClient:
    """UDP echo client"""
    
    def __init__(self, host: str = 'localhost', port: int = 8081):
        self.host = host
        self.port = port
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.settimeout(5.0)  # 5 second timeout
    
    def echo(self, message: str) -> bool:
        """Send message and wait for echo"""
        try:
            # Send message
            self.socket.sendto(message.encode('utf-8'), (self.host, self.port))
            print(f"[*] Sent: {message}")
            
            # Wait for echo
            data, server = self.socket.recvfrom(4096)
            response = data.decode('utf-8')
            print(f"[*] Received: {response}")
            
            return response == message
            
        except socket.timeout:
            print("[!] Timeout waiting for echo")
            return False
        except socket.error as e:
            print(f"[!] Error: {e}")
            return False
    
    def close(self):
        """Close the socket"""
        self.socket.close()

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="UDP Echo Client")
    parser.add_argument('-h', '--host', default='localhost', help='Server host')
    parser.add_argument('-p', '--port', type=int, default=8081, help='Server port')
    parser.add_argument('-m', '--message', help='Message to echo')
    
    args = parser.parse_args()
    
    client = UDPEchoClient(host=args.host, port=args.port)
    
    try:
        if args.message:
            client.echo(args.message)
        else:
            print("\n[*] Interactive mode. Enter messages to echo (Ctrl+C to exit)")
            print("[*] Type 'quit' or 'exit' to close\n")
            while True:
                try:
                    msg = input("> ")
                    if msg.lower() in ['quit', 'exit']:
                        break
                    if msg.strip():
                        client.echo(msg)
                except KeyboardInterrupt:
                    break
    except KeyboardInterrupt:
        print("\n[!] Interrupted")
    finally:
        client.close()

if __name__ == "__main__":
    main()
```

### Node.js Socket Programming

**TCP Echo Server (Node.js)**:
```javascript
#!/usr/bin/env node
/**
 * tcp_echo_server.js - TCP echo server in Node.js
 */

const net = require('net');
const readline = require('readline');

class TCPEchoServer {
    constructor(port = 8080) {
        this.port = port;
        this.clients = new Map();
        this.server = null;
        this.running = false;
        this.clientCount = 0;
    }
    
    start() {
        this.server = net.createServer((socket) => {
            this.handleClient(socket);
        });
        
        this.server.listen(this.port, '0.0.0.0', () => {
            this.running = true;
            console.log(`[+] TCP Echo Server listening on port ${this.port}`);
        });
        
        this.server.on('error', (err) => {
            console.error(`[!] Server error: ${err.message}`);
            this.shutdown();
        });
    }
    
    handleClient(socket) {
        const clientId = `${socket.remoteAddress}:${socket.remotePort}`;
        this.clientCount++;
        this.clients.set(socket, clientId);
        
        console.log(`[+] New connection from ${clientId} (Total: ${this.clientCount})`);
        
        socket.setTimeout(30000); // 30 second timeout
        
        socket.on('data', (data) => {
            console.log(`[*] Received ${data.length} bytes from ${clientId}`);
            
            // Echo data back
            socket.write(data);
            console.log(`[*] Echoed ${data.length} bytes to ${clientId}`);
        });
        
        socket.on('timeout', () => {
            console.log(`[!] Timeout for ${clientId}`);
            socket.end();
        });
        
        socket.on('error', (err) => {
            console.error(`[!] Error with ${clientId}: ${err.message}`);
        });
        
        socket.on('close', () => {
            this.clients.delete(socket);
            console.log(`[-] Connection from ${clientId} closed`);
        });
    }
    
    getStats() {
        return {
            port: this.port,
            clientCount: this.clientCount,
            activeClients: this.clients.size,
            running: this.running
        };
    }
    
    shutdown() {
        this.running = false;
        if (this.server) {
            this.server.close();
            console.log('[*] Server closed');
        }
    }
}

// CLI interface
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const server = new TCPEchoServer(8080);
server.start();

console.log('\nServer running. Press Ctrl+C to stop.');
console.log('Type "stats" for server statistics\n');

rl.on('line', (input) => {
    if (input === 'stats') {
        const stats = server.getStats();
        console.log('\nServer Statistics:');
        console.log(`  Port: ${stats.port}`);
        console.log(`  Total Connections: ${stats.clientCount}`);
        console.log(`  Active Clients: ${stats.activeClients}`);
        console.log(`  Status: ${stats.running ? 'Running' : 'Stopped'}\n`);
    }
});

process.on('SIGINT', () => {
    console.log('\n[*] Shutting down...');
    server.shutdown();
    process.exit(0);
});
```

**UDP Echo Server (Node.js)**:
```javascript
#!/usr/bin/env node
/**
 * udp_echo_server.js - UDP echo server in Node.js
 */

const dgram = require('dgram');

class UDPEchoServer {
    constructor(port = 8081) {
        this.port = port;
        this.socket = null;
        this.running = false;
        this.clientStats = new Map();
    }
    
    start() {
        this.socket = dgram.createSocket('udp4');
        
        this.socket.on('error', (err) => {
            console.error(`[!] Socket error: ${err.message}`);
            this.shutdown();
        });
        
        this.socket.on('message', (msg, rinfo) => {
            const clientKey = `${rinfo.address}:${rinfo.port}`;
            
            // Update client statistics
            if (!this.clientStats.has(clientKey)) {
                this.clientStats.set(clientKey, 0);
            }
            this.clientStats.set(clientKey, this.clientStats.get(clientKey) + 1);
            
            // Echo message back
            this.socket.send(msg, rinfo.port, rinfo.address, (err) => {
                if (err) {
                    console.error(`[!] Error echoing to ${clientKey}: ${err.message}`);
                } else {
                    console.log(`[*] Echoed ${msg.length} bytes to ${clientKey}`);
                }
            });
        });
        
        this.socket.bind(this.port, '0.0.0.0', () => {
            this.running = true;
            console.log(`[+] UDP Echo Server listening on port ${this.port}`);
        });
    }
    
    getStats() {
        let totalMessages = 0;
        for (const count of this.clientStats.values()) {
            totalMessages += count;
        }
        
        return {
            port: this.port,
            clientCount: this.clientStats.size,
            totalMessages: totalMessages,
            clients: Array.from(this.clientStats.entries())
        };
    }
    
    shutdown() {
        this.running = false;
        if (this.socket) {
            this.socket.close();
            console.log('[*] Server closed');
        }
    }
}

const server = new UDPEchoServer(8081);
server.start();

console.log('\nUDP server running. Press Ctrl+C to stop.\n');

process.on('SIGINT', () => {
    console.log('\n[*] Shutting down...');
    const stats = server.getStats();
    console.log('\nClient Statistics:');
    console.log(`  Total Clients: ${stats.clientCount}`);
    console.log(`  Total Messages: ${stats.totalMessages}`);
    server.shutdown();
    process.exit(0);
});
```

---

## Section 5: Hands-On Labs

---

### Lab 1: Build a TCP Echo Server

**The Target**: Create and test a complete TCP echo server.

**The Implementation**:

1. **Create the server** (use the code above or run directly):
   ```bash
   # Save the server code to a file
   chmod +x tcp_echo_server.py
   
   # Start the server
   ./tcp_echo_server.py -p 8080
   ```

2. **In another terminal, test with the client**:
   ```bash
   ./tcp_echo_client.py -h localhost -p 8080 -m "Hello TCP!"
   ```

3. **Test with netcat**:
   ```bash
   nc localhost 8080
   # Type some text and press Enter
   ```

4. **Test with curl**:
   ```bash
   curl telnet://localhost:8080
   ```

**The Verification**:

Run this test script to verify the server works:

```python
#!/usr/bin/env python3
"""
test_tcp_echo.py - Automated test for TCP echo server
"""

import socket
import time
import sys

def test_tcp_echo(host='localhost', port=8080):
    """Test TCP echo server with multiple messages"""
    print("Testing TCP Echo Server...")
    
    try:
        # Connect to server
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2.0)
        sock.connect((host, port))
        print(f"[✓] Connected to {host}:{port}")
        
        # Test messages
        messages = [
            "Hello, TCP!",
            "Testing echo server",
            "How are you doing?",
            "1234567890",
            "Special chars: !@#$%^&*()"
        ]
        
        success_count = 0
        for msg in messages:
            # Send message
            sock.send(msg.encode('utf-8'))
            print(f"[*] Sent: {msg}")
            
            # Receive echo
            data = sock.recv(4096)
            response = data.decode('utf-8')
            print(f"[*] Received: {response}")
            
            if msg == response:
                success_count += 1
                print(f"  [✓] Matched")
            else:
                print(f"  [✗] Mismatch: expected '{msg}', got '{response}'")
        
        print(f"\nResult: {success_count}/{len(messages)} successful")
        sock.close()
        
        return success_count == len(messages)
        
    except Exception as e:
        print(f"[!] Test failed: {e}")
        return False

if __name__ == "__main__":
    success = test_tcp_echo()
    sys.exit(0 if success else 1)
```

---

### Lab 2: Build a UDP Echo Server

**The Target**: Create and test a complete UDP echo server.

**The Implementation**:

1. **Start the UDP server**:
   ```bash
   ./udp_echo_server.py -p 8081
   ```

2. **In another terminal, test with the client**:
   ```bash
   ./udp_echo_client.py -h localhost -p 8081 -m "Hello UDP!"
   ```

3. **Test with netcat**:
   ```bash
   echo "Test message" | nc -u localhost 8081
   ```

**The Verification**:

Run this automated test:

```python
#!/usr/bin/env python3
"""
test_udp_echo.py - Automated test for UDP echo server
"""

import socket
import sys

def test_udp_echo(host='localhost', port=8081):
    """Test UDP echo server with multiple messages"""
    print("Testing UDP Echo Server...")
    
    try:
        # Create UDP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(2.0)
        
        # Test messages
        messages = [
            "Hello, UDP!",
            "Testing datagrams",
            "Faster than TCP",
            "Who needs reliability?",
            "Gaming and streaming"
        ]
        
        success_count = 0
        for msg in messages:
            # Send message
            sock.sendto(msg.encode('utf-8'), (host, port))
            print(f"[*] Sent: {msg}")
            
            # Wait for echo
            try:
                data, server = sock.recvfrom(4096)
                response = data.decode('utf-8')
                print(f"[*] Received: {response}")
                
                if msg == response:
                    success_count += 1
                    print(f"  [✓] Matched")
                else:
                    print(f"  [✗] Mismatch: expected '{msg}', got '{response}'")
            except socket.timeout:
                print(f"  [✗] Timeout waiting for echo")
        
        print(f"\nResult: {success_count}/{len(messages)} successful")
        sock.close()
        
        return success_count == len(messages)
        
    except Exception as e:
        print(f"[!] Test failed: {e}")
        return False

if __name__ == "__main__":
    success = test_udp_echo()
    sys.exit(0 if success else 1)
```

---

### Lab 3: Observe TCP Handshake and Termination

**The Target**: Capture and analyze a complete TCP connection lifecycle.

**The Implementation**:

1. **Start Wireshark** or tcpdump:
   ```bash
   sudo tcpdump -i eth0 "tcp and port 8080" -vv -w tcp_handshake.pcap
   ```

2. **Start the TCP echo server**:
   ```bash
   ./tcp_echo_server.py -p 8080
   ```

3. **Connect and communicate**:
   ```bash
   ./tcp_echo_client.py -p 8080 -m "Testing handshake"
   ```

4. **Stop tcpdump**.

5. **Analyze the capture**:
   ```bash
   # Show all TCP packets in order
   tshark -r tcp_handshake.pcap -Y "tcp.port == 8080" -T fields -e frame.time_relative -e tcp.flags -e tcp.seq -e tcp.ack -e tcp.len
   
   # Show only handshake packets
   tshark -r tcp_handshake.pcap -Y "tcp.flags.syn == 1 or tcp.flags.fin == 1"
   
   # Show connection establishment sequence
   tshark -r tcp_handshake.pcap -Y "tcp.flags.syn == 1" -V
   ```

**The Verification**:

Create a TCP handshake analyzer:

```python
#!/usr/bin/env python3
"""
tcp_handshake_analyzer.py - Analyze TCP handshake from pcap
"""

import sys
from scapy.all import rdpcap, TCP, IP

def analyze_handshake(filename):
    """Extract and display TCP handshake sequence"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    tcp_packets = [p for p in packets if TCP in p]
    
    if not tcp_packets:
        print("No TCP packets found")
        return
    
    print(f"Found {len(tcp_packets)} TCP packets")
    print("\n" + "=" * 80)
    print(f"{'#':<4} {'Time':<12} {'Flags':<12} {'Seq':<12} {'Ack':<12} {'Len':<8} {'Src->Dst':<20}")
    print("=" * 80)
    
    flag_names = {
        'SYN': 0x02,
        'ACK': 0x10,
        'FIN': 0x01,
        'RST': 0x04,
        'PSH': 0x08,
        'URG': 0x20
    }
    
    def get_flag_str(flags):
        flag_parts = []
        for name, mask in flag_names.items():
            if flags & mask:
                flag_parts.append(name)
        return '+'.join(flag_parts) if flag_parts else 'NONE'
    
    # Find connection establishment
    syn_packets = []
    syn_ack_packets = []
    ack_packets = []
    
    for i, packet in enumerate(tcp_packets[:50], 1):
        tcp = packet[TCP]
        ip = packet[IP]
        
        flags = tcp.flags
        flag_str = get_flag_str(flags)
        
        # Track handshake phases
        if flags & 0x02 and not (flags & 0x10):  # SYN only
            syn_packets.append(i)
        elif flags & 0x02 and flags & 0x10:  # SYN-ACK
            syn_ack_packets.append(i)
        elif flags & 0x10 and not (flags & 0x02):  # ACK only
            ack_packets.append(i)
        
        print(f"{i:<4} {packet.time:<12.6f} {flag_str:<12} {tcp.seq:<12} "
              f"{tcp.ack:<12} {len(tcp.payload):<8} {ip.src}:{tcp.sport}->{ip.dst}:{tcp.dport}")
    
    print("=" * 80)
    print(f"\nHandshake Analysis:")
    print(f"  SYN packets: {len(syn_packets)} (packets {syn_packets})")
    print(f"  SYN-ACK packets: {len(syn_ack_packets)} (packets {syn_ack_packets})")
    print(f"  ACK packets: {len(ack_packets)} (packets {ack_packets})")
    
    if syn_packets and syn_ack_packets and ack_packets:
        print(f"\n  Complete three-way handshake observed:")
        print(f"    1. SYN (packet {syn_packets[0]})")
        print(f"    2. SYN-ACK (packet {syn_ack_packets[0]})")
        print(f"    3. ACK (packet {ack_packets[0]})")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    analyze_handshake(sys.argv[1])
```

---

### Lab 4: Capture TCP Retransmissions

**The Target**: Observe TCP retransmission behavior.

**The Implementation**:

1. **Simulate a lossy connection** (use iptables on Linux):
   ```bash
   # Drop 10% of packets on port 8080
   sudo iptables -A INPUT -p tcp --dport 8080 -m statistic --mode random --probability 0.1 -j DROP
   sudo iptables -A OUTPUT -p tcp --sport 8080 -m statistic --mode random --probability 0.1 -j DROP
   ```

2. **Start Wireshark capture**:
   ```bash
   sudo tcpdump -i eth0 "tcp port 8080" -vv -w retransmit.pcap
   ```

3. **Start the TCP server**:
   ```bash
   ./tcp_echo_server.py -p 8080
   ```

4. **Send data**:
   ```bash
   # Send large data to trigger retransmissions
   yes "Hello, this is a test message that will cause retransmission" | head -100 | while read line; do echo "$line"; done | nc localhost 8080
   ```

5. **Analyze retransmissions**:
   ```bash
   # Show TCP retransmissions
   tshark -r retransmit.pcap -Y "tcp.analysis.retransmission"
   
   # Show duplicate ACKs
   tshark -r retransmit.pcap -Y "tcp.analysis.duplicate_ack"
   
   # Show RTO events
   tshark -r retransmit.pcap -Y "tcp.analysis.rto"
   ```

6. **Clean up**:
   ```bash
   sudo iptables -D INPUT -p tcp --dport 8080 -m statistic --mode random --probability 0.1 -j DROP
   sudo iptables -D OUTPUT -p tcp --sport 8080 -m statistic --mode random --probability 0.1 -j DROP
   ```

---

### Lab 5: Build a Multi-Client Chat Server

**The Target**: Build a complete chat server using TCP that handles multiple clients.

**The Implementation**:

Create a file called `chat_server.py`:

```python
#!/usr/bin/env python3
"""
chat_server.py - Multi-client TCP chat server
"""

import socket
import threading
import sys
import time
import re
from typing import Dict, Set

class ChatServer:
    """Multi-client chat server with rooms and commands"""
    
    def __init__(self, host: str = '', port: int = 8082):
        self.host = host
        self.port = port
        self.clients: Dict[object, str] = {}  # socket -> username
        self.rooms: Dict[str, Set[object]] = {'general': set()}
        self.lock = threading.Lock()
        self.running = False
        self.server_socket = None
    
    def start(self):
        """Start the chat server"""
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(10)
            self.running = True
            
            print(f"[*] Chat Server started on port {self.port}")
            print("[*] Commands: /help, /join <room>, /leave, /list, /quit\n")
            
            while self.running:
                try:
                    client_socket, address = self.server_socket.accept()
                    client_thread = threading.Thread(
                        target=self.handle_client,
                        args=(client_socket, address),
                        daemon=True
                    )
                    client_thread.start()
                except socket.error:
                    if self.running:
                        continue
                    
        except Exception as e:
            print(f"[!] Server error: {e}")
        finally:
            self.shutdown()
    
    def handle_client(self, client_socket: socket.socket, address: tuple):
        """Handle a connected client"""
        try:
            # Ask for username
            client_socket.send("Welcome to the Chat Server!\n".encode('utf-8'))
            client_socket.send("Enter your username: ".encode('utf-8'))
            
            username = client_socket.recv(1024).decode('utf-8').strip()
            if not username or not self._validate_username(username):
                client_socket.send("Invalid username. Connection closed.\n".encode('utf-8'))
                client_socket.close()
                return
            
            # Validate username uniqueness
            with self.lock:
                if username in self.clients.values():
                    client_socket.send("Username already taken. Connection closed.\n".encode('utf-8'))
                    client_socket.close()
                    return
                
                self.clients[client_socket] = username
                self.rooms['general'].add(client_socket)
            
            print(f"[+] {username} connected from {address[0]}:{address[1]}")
            self._broadcast(f"[SERVER] {username} has joined the chat!", 'general', exclude=client_socket)
            
            # Send welcome message
            client_socket.send(f"\nWelcome {username}!\n".encode('utf-8'))
            client_socket.send("Commands: /help for available commands\n".encode('utf-8'))
            client_socket.send(f"Active users: {len(self.clients)}\n".encode('utf-8'))
            
            # Message loop
            while self.running:
                try:
                    data = client_socket.recv(4096)
                    if not data:
                        break
                    
                    message = data.decode('utf-8').strip()
                    if not message:
                        continue
                    
                    # Handle commands
                    if message.startswith('/'):
                        self._handle_command(client_socket, message)
                    else:
                        # Regular message - find user's room
                        room = self._get_user_room(client_socket)
                        self._broadcast(f"{username}: {message}", room, exclude=client_socket)
                        
                except socket.error:
                    break
            
        except Exception as e:
            print(f"[!] Error with {address}: {e}")
        finally:
            self._remove_client(client_socket)
            client_socket.close()
    
    def _handle_command(self, client_socket: socket.socket, command: str):
        """Handle chat commands"""
        parts = command.split(' ', 1)
        cmd = parts[0].lower()
        username = self.clients.get(client_socket, 'Unknown')
        
        if cmd == '/help':
            help_text = """
Available commands:
  /help          - Show this help message
  /join <room>   - Join or create a room
  /leave         - Leave current room (goes to general)
  /list          - List all rooms and users
  /quit          - Disconnect from server
  /msg <user> <msg> - Send private message
  /who           - List users in current room
"""
            client_socket.send(help_text.encode('utf-8'))
        
        elif cmd == '/join':
            if len(parts) != 2:
                client_socket.send("/join <room> - Specify a room name\n".encode('utf-8'))
                return
            
            room = parts[1].strip()
            if not self._validate_room_name(room):
                client_socket.send("Invalid room name. Use letters, numbers, and underscores.\n".encode('utf-8'))
                return
            
            # Leave current room
            old_room = self._get_user_room(client_socket)
            if old_room:
                with self.lock:
                    if client_socket in self.rooms.get(old_room, set()):
                        self.rooms[old_room].remove(client_socket)
            
            # Join new room
            with self.lock:
                if room not in self.rooms:
                    self.rooms[room] = set()
                self.rooms[room].add(client_socket)
            
            client_socket.send(f"[SERVER] You joined room: {room}\n".encode('utf-8'))
            self._broadcast(f"[SERVER] {username} joined the room", room, exclude=client_socket)
        
        elif cmd == '/leave':
            room = self._get_user_room(client_socket)
            if room and room != 'general':
                with self.lock:
                    if client_socket in self.rooms.get(room, set()):
                        self.rooms[room].remove(client_socket)
                    self.rooms['general'].add(client_socket)
                
                client_socket.send(f"[SERVER] You left {room} and joined general\n".encode('utf-8'))
                self._broadcast(f"[SERVER] {username} left the room", room, exclude=client_socket)
            else:
                client_socket.send("[SERVER] You're already in the general room\n".encode('utf-8'))
        
        elif cmd == '/list':
            with self.lock:
                response = "\nRooms and users:\n"
                for room, users in self.rooms.items():
                    if users:
                        user_list = []
                        for sock in users:
                            user_list.append(self.clients.get(sock, 'Unknown'))
                        response += f"  {room}: {len(users)} users - {', '.join(user_list)}\n"
                    else:
                        response += f"  {room}: empty\n"
                response += f"\nTotal users: {len(self.clients)}\n"
            
            client_socket.send(response.encode('utf-8'))
        
        elif cmd == '/who':
            room = self._get_user_room(client_socket)
            if room:
                with self.lock:
                    users = [self.clients.get(sock, 'Unknown') for sock in self.rooms.get(room, set())]
                    response = f"Users in {room}: {', '.join(users)}\n"
                    response += f"Total: {len(users)} users\n"
                    client_socket.send(response.encode('utf-8'))
        
        elif cmd == '/msg':
            if len(parts) != 2:
                client_socket.send("/msg <user> <message> - Send private message\n".encode('utf-8'))
                return
            
            parts = parts[1].split(' ', 1)
            if len(parts) != 2:
                client_socket.send("Please specify both user and message\n".encode('utf-8'))
                return
            
            target_user, message = parts
            if target_user == username:
                client_socket.send("[SERVER] You can't message yourself\n".encode('utf-8'))
                return
            
            self._private_message(username, target_user, message)
        
        elif cmd == '/quit':
            client_socket.close()
        
        else:
            client_socket.send(f"Unknown command: {cmd}. Type /help for commands.\n".encode('utf-8'))
    
    def _broadcast(self, message: str, room: str, exclude: socket.socket = None):
        """Broadcast message to all users in a room"""
        with self.lock:
            users = self.rooms.get(room, set())
            for client in users:
                if client != exclude and client.fileno() != -1:
                    try:
                        client.send((message + '\n').encode('utf-8'))
                    except:
                        pass
    
    def _private_message(self, sender: str, recipient: str, message: str):
        """Send a private message between users"""
        with self.lock:
            # Find recipient socket
            target_socket = None
            for sock, name in self.clients.items():
                if name == recipient:
                    target_socket = sock
                    break
            
            if target_socket and target_socket.fileno() != -1:
                try:
                    target_socket.send(f"[PM from {sender}] {message}\n".encode('utf-8'))
                except:
                    pass
                
                # Send confirmation to sender
                for sock, name in self.clients.items():
                    if name == sender:
                        try:
                            sock.send(f"[PM to {recipient}] {message}\n".encode('utf-8'))
                        except:
                            pass
            else:
                # Recipient not found
                for sock, name in self.clients.items():
                    if name == sender:
                        try:
                            sock.send(f"[SERVER] User '{recipient}' not found\n".encode('utf-8'))
                        except:
                            pass
    
    def _get_user_room(self, client_socket: socket.socket) -> str:
        """Find which room a user is in"""
        with self.lock:
            for room, users in self.rooms.items():
                if client_socket in users:
                    return room
        return 'general'
    
    def _remove_client(self, client_socket: socket.socket):
        """Remove client from all rooms"""
        username = self.clients.pop(client_socket, 'Unknown')
        
        with self.lock:
            for room, users in self.rooms.items():
                if client_socket in users:
                    users.remove(client_socket)
        
        print(f"[-] {username} disconnected")
        self._broadcast(f"[SERVER] {username} has left the chat", 'general')
    
    def _validate_username(self, username: str) -> bool:
        """Validate username format"""
        if not username or len(username) > 30:
            return False
        return bool(re.match(r'^[a-zA-Z0-9_]{1,30}$', username))
    
    def _validate_room_name(self, room: str) -> bool:
        """Validate room name format"""
        if not room or len(room) > 30:
            return False
        return bool(re.match(r'^[a-zA-Z0-9_-]{1,30}$', room))
    
    def shutdown(self):
        """Shut down the server"""
        self.running = False
        if self.server_socket:
            self.server_socket.close()
        
        # Close all client connections
        with self.lock:
            for client in list(self.clients.keys()):
                try:
                    client.close()
                except:
                    pass
        
        print("[*] Server shutdown complete")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Multi-Client Chat Server")
    parser.add_argument('-p', '--port', type=int, default=8082, help='Port to listen on')
    
    args = parser.parse_args()
    
    server = ChatServer(port=args.port)
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Shutting down...")
        server.shutdown()

if __name__ == "__main__":
    main()
```

**Create a simple chat client**:

```python
#!/usr/bin/env python3
"""
chat_client.py - Simple TCP chat client
"""

import socket
import threading
import sys

class ChatClient:
    """Simple chat client"""
    
    def __init__(self, host: str = 'localhost', port: int = 8082):
        self.host = host
        self.port = port
        self.socket = None
        self.running = False
    
    def connect(self):
        """Connect to chat server"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.host, self.port))
            self.running = True
            print("[*] Connected to chat server")
            
            # Start receive thread
            receive_thread = threading.Thread(target=self.receive_messages, daemon=True)
            receive_thread.start()
            
            # Send messages from stdin
            while self.running:
                try:
                    message = input()
                    if message.lower() == '/quit':
                        break
                    if message.strip():
                        self.socket.send(message.encode('utf-8'))
                except KeyboardInterrupt:
                    break
                except:
                    break
                    
        except Exception as e:
            print(f"[!] Connection error: {e}")
        finally:
            self.close()
    
    def receive_messages(self):
        """Receive messages from server"""
        while self.running:
            try:
                data = self.socket.recv(4096)
                if not data:
                    break
                print(data.decode('utf-8'), end='')
            except:
                break
    
    def close(self):
        """Close connection"""
        self.running = False
        if self.socket:
            self.socket.close()
        print("[*] Disconnected")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Chat Client")
    parser.add_argument('-h', '--host', default='localhost', help='Server host')
    parser.add_argument('-p', '--port', type=int, default=8082, help='Server port')
    
    args = parser.parse_args()
    
    client = ChatClient(host=args.host, port=args.port)
    client.connect()

if __name__ == "__main__":
    main()
```

**Testing the chat server**:

1. **Start the server**:
   ```bash
   ./chat_server.py -p 8082
   ```

2. **Connect multiple clients** (different terminals):
   ```bash
   ./chat_client.py -h localhost -p 8082
   ```

3. **Test commands**:
   ```
   /help           # Show commands
   /join gaming    # Create/join a room
   /list           # List all rooms
   /who            # List users in current room
   /msg alice Hello  # Private message
   /leave          # Leave room
   /quit           # Disconnect
   ```

---

## Section 6: Reference: Complete TCP/UDP Field Reference

### TCP Header Fields (Complete)

| Field | Offset (bits) | Size (bits) | Description | Values |
|-------|--------------|------------|-------------|--------|
| Source Port | 0 | 16 | Sender's port | 0-65535 |
| Destination Port | 16 | 16 | Recipient's port | 0-65535 |
| Sequence Number | 32 | 32 | Data position in stream | 0-2^32-1 |
| Acknowledgment Number | 64 | 32 | Next expected byte | 0-2^32-1 |
| Data Offset | 96 | 4 | Header length (32-bit words) | 5-15 (20-60 bytes) |
| Reserved | 100 | 3 | Must be zero | 0 |
| NS | 103 | 1 | Nonce Sum | 0/1 |
| CWR | 104 | 1 | Congestion Window Reduced | 0/1 |
| ECE | 105 | 1 | ECN-Echo | 0/1 |
| URG | 106 | 1 | Urgent pointer valid | 0/1 |
| ACK | 107 | 1 | Acknowledgment valid | 0/1 |
| PSH | 108 | 1 | Push data to application | 0/1 |
| RST | 109 | 1 | Reset connection | 0/1 |
| SYN | 110 | 1 | Synchronize sequence numbers | 0/1 |
| FIN | 111 | 1 | Finish connection | 0/1 |
| Window Size | 112 | 16 | Available buffer space | 0-65535 |
| Checksum | 128 | 16 | Error check (includes pseudo-header) | Computed |
| Urgent Pointer | 144 | 16 | Offset to urgent data | 0-2^16-1 |
| Options | 160 | variable | Extended features | Varies |
| Payload | variable | variable | Application data | Varies |

### TCP Options (Common)

| Option | Value | Length | Description |
|--------|-------|--------|-------------|
| End of Option List | 0 | 1 | End of options |
| NOP | 1 | 1 | No operation (padding) |
| MSS | 2 | 4 | Maximum Segment Size |
| Window Scale | 3 | 3 | Window scaling factor |
| SACK Permitted | 4 | 2 | Selective ACK allowed |
| SACK | 5 | variable | Selective ACK blocks |
| Timestamp | 8 | 10 | Timestamps for RTT |

### UDP Header Fields

| Field | Size | Description | Values |
|-------|------|-------------|--------|
| Source Port | 16 bits | Sender's port | 0-65535 |
| Destination Port | 16 bits | Recipient's port | 0-65535 |
| Length | 16 bits | Header + payload size | 8-65535 |
| Checksum | 16 bits | Error check | Computed |
| Payload | variable | Application data | Varies |

### Well-Known Ports

| Port | Protocol | Service |
|------|----------|---------|
| 20 | TCP | FTP Data |
| 21 | TCP | FTP Control |
| 22 | TCP | SSH |
| 23 | TCP | Telnet |
| 25 | TCP | SMTP |
| 53 | TCP/UDP | DNS |
| 80 | TCP | HTTP |
| 110 | TCP | POP3 |
| 123 | UDP | NTP |
| 143 | TCP | IMAP |
| 443 | TCP | HTTPS |
| 465 | TCP | SMTPS |
| 993 | TCP | IMAPS |
| 995 | TCP | POP3S |
| 3306 | TCP | MySQL |
| 5432 | TCP | PostgreSQL |
| 6379 | TCP | Redis |
| 8080 | TCP | HTTP-Alt |
| 27017 | TCP | MongoDB |

---

## Summary

In Part 3, we've covered the Transport Layer and explored TCP and UDP in depth:

1. **UDP**: Connectionless, unreliable, fast - perfect for real-time applications like gaming, streaming, and VoIP.

2. **TCP**: Connection-oriented, reliable, ordered - essential for applications requiring guaranteed delivery like web, email, and file transfer.

3. **Socket Programming**: How applications use ports and sockets to communicate, with complete examples in Python and Node.js.

4. **Reliability Mechanisms**: Sliding windows, flow control, congestion control - the algorithms that make TCP work.

**Key Takeaways**:
- TCP provides reliable, ordered delivery through sequence numbers, acknowledgments, and retransmissions
- UDP is simple and fast but provides no guarantees
- The three-way handshake establishes TCP connections
- Congestion control prevents network collapse
- Sockets provide the programming interface to transport protocols
- Choose UDP when speed matters more than reliability

**What's Next**: In Part 4, we'll move to the Application Layer and explore the protocols that power the Internet - DNS, HTTP, email protocols (SMTP, POP3, IMAP), and SNMP.
