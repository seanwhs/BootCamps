# Mastering Network Packet Crafting with Scapy
## Module 3: Transport Layer Protocols & Reconnaissance
### Part 1: TCP and UDP Deep Dive

## The Target: Mastering Transport Layer Protocols

In this part, we'll dive deep into TCP and UDP — the protocols that power application communication. By the end, you'll be able to:

1. Understand TCP segment structure and the three-way handshake
2. Work with TCP flags, sequence numbers, and acknowledgments
3. Understand UDP datagram structure and stateless communication
4. Build custom TCP and UDP packets
5. Analyze TCP state transitions
6. Create TCP handshake visualizers

---

## The Concept: TCP as a Phone Call, UDP as a Postcard

Think of TCP (Transmission Control Protocol) as a **phone call**:
- **Connection establishment**: "Hello, is this Bob?" (SYN)
- **Acknowledgment**: "Yes, this is Bob" (SYN-ACK)
- **Connection confirmed**: "Great, let's talk" (ACK)
- **Reliable delivery**: "Did you get what I said?" (ACK every segment)
- **Ordered delivery**: "Let me tell you in sequence" (Sequence numbers)
- **Flow control**: "Don't talk too fast, I need time to write" (Window size)
- **Connection teardown**: "Goodbye" (FIN), "Goodbye to you too" (FIN-ACK)

UDP (User Datagram Protocol) is like sending **postcards**:
- **No connection**: Just send and hope it arrives
- **No acknowledgment**: You don't know if it was received
- **No ordering**: Postcards might arrive out of order
- **No flow control**: Send as fast as you want
- **Faster**: Less overhead, less delay

```
TCP: The Reliable Phone Call
┌──────┐                ┌──────┐
│Client│                │Server│
└──┬───┘                └──┬───┘
   │    SYN (seq=100)      │
   │──────────────────────>│
   │                        │
   │    SYN-ACK (seq=200,  │
   │    ack=101)           │
   │<──────────────────────│
   │                        │
   │    ACK (ack=201)      │
   │──────────────────────>│
   │                        │
   │    DATA (seq=101,     │
   │    ack=201)           │
   │──────────────────────>│
   │                        │
   │    ACK (ack=102)      │
   │<──────────────────────│
   │                        │
   │    FIN (seq=150)      │
   │──────────────────────>│
   │                        │
   │    ACK (ack=151)      │
   │<──────────────────────│
   │                        │
   │    FIN (seq=300)      │
   │<──────────────────────│
   │                        │
   │    ACK (ack=301)      │
   │──────────────────────>│
```

**Key insight**: TCP provides reliability at the cost of overhead, while UDP provides speed at the cost of reliability. Understanding both is essential for network programming and analysis.

---

## The Implementation: TCP and UDP Operations

### Step 1: Understanding TCP and UDP Basics

Create `src/transport_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 3, Part 1: Transport Layer Basics

This script demonstrates TCP and UDP packet construction,
header fields, and basic operations.
"""

from scapy.all import IP, TCP, UDP, ICMP, Ether, sr1, sr, send
from scapy.all import RandIP, RandShort, RandNum, conf
import sys
import time
import ipaddress

def demonstrate_tcp_fields():
    """Demonstrate TCP header fields."""
    
    print("\n" + "=" * 60)
    print("TCP HEADER FIELD DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Create default TCP segment
    tcp = TCP()
    print("Default TCP segment fields:")
    print("-" * 40)
    tcp.show()
    
    print("\nKey TCP Header Fields:")
    print("-" * 40)
    print("  Source Port:      16-bit port number")
    print("  Destination Port: 16-bit port number")
    print("  Sequence Number:  32-bit sequence number")
    print("  Acknowledgment:   32-bit ACK number")
    print("  Data Offset:      4-bit header length (in 32-bit words)")
    print("  Flags:            9 bits (SYN, ACK, FIN, RST, PSH, URG, ECE, CWR, NS)")
    print("  Window Size:      16-bit flow control window")
    print("  Checksum:         16-bit checksum (covers header + data)")
    print("  Urgent Pointer:   16-bit (if URG flag set)")
    print("  Options:          Variable (MSS, SACK, Timestamp, Window Scale)")
    
    print("\nTCP Flag Bits:")
    print("-" * 40)
    flags = [
        (0x001, "FIN - Finish (end connection)"),
        (0x002, "SYN - Synchronize (establish connection)"),
        (0x004, "RST - Reset (force connection reset)"),
        (0x008, "PSH - Push (immediate delivery)"),
        (0x010, "ACK - Acknowledgment"),
        (0x020, "URG - Urgent"),
        (0x040, "ECE - ECN Echo"),
        (0x080, "CWR - Congestion Window Reduced"),
        (0x100, "NS - Nonce Sum"),
    ]
    
    for bit, description in flags:
        flag_value = bit
        flag_name = description.split('-')[0].strip()
        print(f"  0x{bit:03x}: {flag_name:<8} - {description}")

def demonstrate_udp_fields():
    """Demonstrate UDP header fields."""
    
    print("\n" + "=" * 60)
    print("UDP HEADER FIELD DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Create default UDP datagram
    udp = UDP()
    print("Default UDP datagram fields:")
    print("-" * 40)
    udp.show()
    
    print("\nKey UDP Header Fields:")
    print("-" * 40)
    print("  Source Port:      16-bit port number")
    print("  Destination Port: 16-bit port number")
    print("  Length:           16-bit datagram length (header + data)")
    print("  Checksum:         16-bit checksum (optional for IPv4)")
    print("\nNote: UDP is connectionless and unreliable by design.")

def build_tcp_packets():
    """Build custom TCP packets."""
    
    print("\n" + "=" * 60)
    print("CUSTOM TCP PACKET CONSTRUCTION")
    print("=" * 60 + "\n")
    
    # 1. TCP SYN packet (connection initiation)
    print("1. TCP SYN Packet:")
    print("-" * 40)
    syn = IP(src="192.168.1.100", dst="10.0.0.1") / \
          TCP(sport=54321, dport=80, flags="S", seq=1000, window=65535)
    syn.show()
    print(f"  Flags: {syn[TCP].flags}")
    print(f"  Sequence: {syn[TCP].seq}\n")
    
    # 2. TCP SYN-ACK packet (connection response)
    print("2. TCP SYN-ACK Packet:")
    print("-" * 40)
    syn_ack = IP(src="10.0.0.1", dst="192.168.1.100") / \
              TCP(sport=80, dport=54321, flags="SA", seq=2000, ack=1001, window=65535)
    syn_ack.show()
    print(f"  Flags: {syn_ack[TCP].flags}")
    print(f"  Sequence: {syn_ack[TCP].seq}, ACK: {syn_ack[TCP].ack}\n")
    
    # 3. TCP ACK with data
    print("3. TCP ACK with Data:")
    print("-" * 40)
    data = IP(src="192.168.1.100", dst="10.0.0.1") / \
           TCP(sport=54321, dport=80, flags="PA", seq=1001, ack=2001) / \
           Raw(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    data.show()
    print(f"  Flags: {data[TCP].flags}")
    print(f"  Data length: {len(data[Raw])} bytes\n")
    
    # 4. TCP FIN packet (connection termination)
    print("4. TCP FIN Packet:")
    print("-" * 40)
    fin = IP(src="192.168.1.100", dst="10.0.0.1") / \
          TCP(sport=54321, dport=80, flags="FA", seq=1500, ack=2100)
    fin.show()
    print(f"  Flags: {fin[TCP].flags}\n")
    
    # 5. TCP RST packet (connection reset)
    print("5. TCP RST Packet:")
    print("-" * 40)
    rst = IP(src="10.0.0.1", dst="192.168.1.100") / \
          TCP(sport=80, dport=54321, flags="R", seq=2100)
    rst.show()
    print(f"  Flags: {rst[TCP].flags}\n")
    
    # 6. TCP with options
    print("6. TCP with Options (MSS, SACK, Timestamp):")
    print("-" * 40)
    tcp_opt = IP(src="192.168.1.100", dst="10.0.0.1") / \
              TCP(sport=54321, dport=80, flags="S",
                  options=[('MSS', 1460), 
                           ('SAckOK', b''), 
                           ('Timestamp', (1234567890, 0))])
    tcp_opt.show()
    print(f"  Options: {tcp_opt[TCP].options}\n")

def build_udp_packets():
    """Build custom UDP packets."""
    
    print("\n" + "=" * 60)
    print("CUSTOM UDP PACKET CONSTRUCTION")
    print("=" * 60 + "\n")
    
    # 1. Simple UDP datagram
    print("1. Simple UDP Datagram:")
    print("-" * 40)
    udp = IP(src="192.168.1.100", dst="8.8.8.8") / \
          UDP(sport=54321, dport=53) / \
          Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
    udp.show()
    print(f"  UDP Source Port: {udp[UDP].sport}")
    print(f"  UDP Dest Port: {udp[UDP].dport}")
    print(f"  Payload length: {len(udp[Raw])} bytes\n")
    
    # 2. UDP DNS query (with proper DNS format)
    print("2. UDP DNS Query:")
    print("-" * 40)
    # DNS query for example.com
    dns_payload = (b"\x00\x01"  # Transaction ID
                   b"\x01\x00"  # Flags: RD
                   b"\x00\x01"  # Questions: 1
                   b"\x00\x00"  # Answer RRs: 0
                   b"\x00\x00"  # Authority RRs: 0
                   b"\x00\x00"  # Additional RRs: 0
                   b"\x07example\x03com\x00"  # Domain name
                   b"\x00\x01"  # Type: A
                   b"\x00\x01")  # Class: IN
    
    dns = IP(src="192.168.1.100", dst="8.8.8.8") / \
          UDP(sport=54321, dport=53) / \
          Raw(load=dns_payload)
    dns.show()
    print(f"  DNS Query for: example.com\n")
    
    # 3. UDP DHCP discover
    print("3. UDP DHCP Discover:")
    print("-" * 40)
    dhcp = IP(src="0.0.0.0", dst="255.255.255.255") / \
           UDP(sport=68, dport=67) / \
           Raw(b"\x01\x01\x06\x00"  # DHCP Discover
               b"\x00" * 236)  # Rest of DHCP packet
    dhcp.show()
    print(f"  UDP Source Port: {dhcp[UDP].sport}")
    print(f"  UDP Dest Port: {dhcp[UDP].dport}\n")

def tcp_state_machine():
    """Demonstrate TCP state machine concepts."""
    
    print("\n" + "=" * 60)
    print("TCP STATE MACHINE")
    print("=" * 60 + "\n")
    
    states = {
        "CLOSED": "No connection state",
        "LISTEN": "Waiting for connection requests",
        "SYN-SENT": "Sent SYN, waiting for SYN-ACK",
        "SYN-RECEIVED": "Received SYN, sent SYN-ACK",
        "ESTABLISHED": "Connection established",
        "FIN-WAIT-1": "Sent FIN, waiting for ACK",
        "FIN-WAIT-2": "Received ACK, waiting for FIN",
        "CLOSE-WAIT": "Received FIN, sent ACK",
        "CLOSING": "Sent FIN, received FIN",
        "LAST-ACK": "Sent FIN, waiting for ACK",
        "TIME-WAIT": "Waiting for delayed segments",
    }
    
    print("TCP States:")
    print("-" * 40)
    for state, description in states.items():
        print(f"  {state:<15} - {description}")
    
    print("\nState Transitions (Client):")
    print("-" * 40)
    print("  CLOSED -> SYN-SENT -> ESTABLISHED -> FIN-WAIT-1 -> FIN-WAIT-2 -> TIME-WAIT -> CLOSED")
    
    print("\nState Transitions (Server):")
    print("-" * 40)
    print("  CLOSED -> LISTEN -> SYN-RECEIVED -> ESTABLISHED -> CLOSE-WAIT -> LAST-ACK -> CLOSED")

def tcp_handshake_visualizer():
    """Visualize the TCP three-way handshake."""
    
    print("\n" + "=" * 60)
    print("TCP THREE-WAY HANDSHAKE VISUALIZER")
    print("=" * 60 + "\n")
    
    print("""
    Client (192.168.1.100)          Server (10.0.0.1)
    │                                    │
    │          1. SYN                    │
    │       ────────────────────────>    │
    │    seq=1000, flags=SYN             │
    │                                    │
    │          2. SYN-ACK                │
    │       <────────────────────────    │
    │    seq=2000, ack=1001, flags=SYN-ACK
    │                                    │
    │          3. ACK                    │
    │       ────────────────────────>    │
    │    seq=1001, ack=2001, flags=ACK  │
    │                                    │
    │           ESTABLISHED              │
    │                                    │
    """)
    
    # Build the three packets
    syn = IP(src="192.168.1.100", dst="10.0.0.1") / \
          TCP(sport=54321, dport=80, flags="S", seq=1000)
    
    syn_ack = IP(src="10.0.0.1", dst="192.168.1.100") / \
              TCP(sport=80, dport=54321, flags="SA", seq=2000, ack=1001)
    
    ack = IP(src="192.168.1.100", dst="10.0.0.1") / \
          TCP(sport=54321, dport=80, flags="A", seq=1001, ack=2001)
    
    print("Handshake Packets:")
    print("-" * 40)
    print(f"1. SYN:      {syn.summary()}")
    print(f"2. SYN-ACK:  {syn_ack.summary()}")
    print(f"3. ACK:      {ack.summary()}")
    
    # Show sequence number relationships
    print("\nSequence Number Relationships:")
    print("-" * 40)
    print(f"  Client ISN (Initial Sequence Number): {syn[TCP].seq}")
    print(f"  Server ISN: {syn_ack[TCP].seq}")
    print(f"  Client ACK for SYN-ACK: {ack[TCP].ack} (ISN + 1)")
    print(f"  Server ACK for SYN: {syn_ack[TCP].ack} (ISN + 1)")
    
    print("\nNote: SYN flag consumes 1 byte of sequence number space.")

def tcp_connection_termination():
    """Visualize TCP connection termination."""
    
    print("\n" + "=" * 60)
    print("TCP CONNECTION TERMINATION")
    print("=" * 60 + "\n")
    
    print("""
    Client                        Server
    │                              │
    │          1. FIN              │
    │       ─────────────────>     │
    │    seq=1500, flags=FIN       │
    │                              │
    │          2. ACK              │
    │       <─────────────────     │
    │    ack=1501, flags=ACK       │
    │                              │
    │          3. FIN              │
    │       <─────────────────     │
    │    seq=2500, flags=FIN       │
    │                              │
    │          4. ACK              │
    │       ─────────────────>     │
    │    ack=2501, flags=ACK       │
    │                              │
    │         CLOSED               │
    """)
    
    # Build termination packets
    fin = IP(src="192.168.1.100", dst="10.0.0.1") / \
          TCP(sport=54321, dport=80, flags="F", seq=1500)
    
    ack_fin = IP(src="10.0.0.1", dst="192.168.1.100") / \
              TCP(sport=80, dport=54321, flags="A", seq=2500, ack=1501)
    
    fin2 = IP(src="10.0.0.1", dst="192.168.1.100") / \
           TCP(sport=80, dport=54321, flags="F", seq=2500, ack=1501)
    
    ack_fin2 = IP(src="192.168.1.100", dst="10.0.0.1") / \
               TCP(sport=54321, dport=80, flags="A", seq=1501, ack=2501)
    
    print("Termination Packets:")
    print("-" * 40)
    print(f"1. FIN:     {fin.summary()}")
    print(f"2. ACK:     {ack_fin.summary()}")
    print(f"3. FIN:     {fin2.summary()}")
    print(f"4. ACK:     {ack_fin2.summary()}")
    
    print("\nNote: FIN consumes 1 byte of sequence number space.")

def tcp_window_explanation():
    """Explain TCP windowing and flow control."""
    
    print("\n" + "=" * 60)
    print("TCP WINDOWING AND FLOW CONTROL")
    print("=" * 60 + "\n")
    
    print("TCP Flow Control Concepts:")
    print("-" * 40)
    print("  Window Size: Number of bytes sender can send before requiring ACK")
    print("  Window Scaling: Option to expand window beyond 64KB")
    print("  Sliding Window: Window moves as data is ACKed")
    
    print("\nWindow Size Examples:")
    print("-" * 40)
    windows = [
        (16384, "16KB - Common for many systems"),
        (32768, "32KB - Increased performance"),
        (65535, "64KB - Maximum without scaling"),
        (262144, "256KB - With window scaling"),
        (1048576, "1MB - High-performance networks"),
    ]
    
    for size, description in windows:
        print(f"  {size:>8} ({description})")
    
    print("\nWindow Update Example:")
    print("-" * 40)
    print("  Client sends SYN with window=65535")
    print("  Server replies SYN-ACK with window=65535")
    print("  Client sets window based on available buffer")
    print("  Window updates dynamically during connection")

def compare_tcp_udp():
    """Compare TCP and UDP characteristics."""
    
    print("\n" + "=" * 60)
    print("TCP vs UDP COMPARISON")
    print("=" * 60 + "\n")
    
    print(f"{'Feature':<20} {'TCP':<25} {'UDP':<25}")
    print("-" * 70)
    
    features = [
        ("Connection", "Connection-oriented", "Connectionless"),
        ("Reliability", "Reliable (ACKs)", "Unreliable (best effort)"),
        ("Ordering", "Ordered delivery", "Unordered (may arrive out of order)"),
        ("Flow Control", "Window-based", "None"),
        ("Congestion Control", "Complex algorithms", "None"),
        ("Error Detection", "Checksum", "Checksum (optional in IPv4)"),
        ("Speed", "Slower (overhead)", "Faster (minimal overhead)"),
        ("Header Size", "20-60 bytes", "8 bytes"),
        ("Use Cases", "Web, email, SSH, FTP", "DNS, DHCP, VoIP, gaming"),
        ("Retransmission", "Automatic", "None (application must handle)"),
    ]
    
    for feature, tcp_value, udp_value in features:
        print(f"{feature:<20} {tcp_value:<25} {udp_value:<25}")

def main():
    """Main function for transport layer demonstrations."""
    
    print("=" * 60)
    print("MODULE 3, PART 1: TCP AND UDP DEEP DIVE")
    print("=" * 60)
    
    demonstrate_tcp_fields()
    demonstrate_udp_fields()
    build_tcp_packets()
    build_udp_packets()
    tcp_state_machine()
    tcp_handshake_visualizer()
    tcp_connection_termination()
    tcp_window_explanation()
    compare_tcp_udp()
    
    print("\n" + "=" * 60)
    print("TCP/UDP DEMONSTRATION COMPLETE")
    print("=" * 60)
    print("\nYou've learned to:")
    print("  • Understand TCP and UDP header fields")
    print("  • Build custom TCP and UDP packets")
    print("  • Visualize the three-way handshake")
    print("  • Understand TCP state transitions")
    print("  • Compare TCP and UDP characteristics")

if __name__ == "__main__":
    main()
```

### Step 2: TCP Handshake Analysis Tool

Create `src/tcp_handshake_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 3, Part 1: TCP Handshake Analyzer

This script analyzes TCP handshakes from packet captures
and visualizes the connection establishment process.
"""

from scapy.all import rdpcap, IP, TCP, Ether, wrpcap
import os
import sys
import time
from datetime import datetime
from collections import defaultdict

class TCPHandshakeAnalyzer:
    """
    TCP handshake analyzer that extracts and visualizes
    TCP connection establishment sequences.
    """
    
    def __init__(self):
        """Initialize handshake analyzer."""
        self.packets = []
        self.connections = {}
        self.handshakes = []
    
    def load_pcap(self, pcap_file):
        """Load a PCAP file."""
        if not os.path.exists(pcap_file):
            print(f"Error: File not found: {pcap_file}")
            return False
        
        print(f"Loading PCAP: {pcap_file}")
        self.packets = rdpcap(pcap_file)
        print(f"Loaded {len(self.packets)} packets")
        return True
    
    def extract_handshakes(self):
        """Extract TCP handshakes from packets."""
        
        print("\nExtracting TCP handshakes...")
        print("-" * 40)
        
        # Track connection states
        connections = defaultdict(lambda: {
            'syn': None,
            'syn_ack': None,
            'ack': None,
            'completed': False,
            'client_ip': None,
            'server_ip': None,
            'client_port': None,
            'server_port': None,
            'packets': []
        })
        
        # Scan packets for handshake packets
        for packet in self.packets:
            if not packet.haslayer(TCP):
                continue
            
            ip = packet[IP]
            tcp = packet[TCP]
            
            # Create connection key
            if tcp.flags & 0x02:  # SYN packet
                # Potential connection initiation
                key = (ip.dst, tcp.dport)  # Server IP and port
                
                # Check if we have a SYN for this connection
                if connections[key]['syn'] is None:
                    connections[key]['syn'] = packet
                    connections[key]['client_ip'] = ip.src
                    connections[key]['server_ip'] = ip.dst
                    connections[key]['client_port'] = tcp.sport
                    connections[key]['server_port'] = tcp.dport
                    connections[key]['packets'].append(packet)
            
            elif tcp.flags & 0x12:  # SYN-ACK packet
                # Find the matching connection
                for key, conn in connections.items():
                    if (conn['syn'] is not None and 
                        ip.src == conn['server_ip'] and
                        ip.dst == conn['client_ip'] and
                        tcp.sport == conn['server_port'] and
                        tcp.dport == conn['client_port']):
                        
                        if conn['syn_ack'] is None:
                            conn['syn_ack'] = packet
                            conn['packets'].append(packet)
            
            elif tcp.flags & 0x10:  # ACK packet (maybe handshake complete)
                for key, conn in connections.items():
                    if (conn['syn'] is not None and 
                        conn['syn_ack'] is not None and
                        conn['ack'] is None):
                        
                        # Check if this is the handshake ACK
                        if (ip.src == conn['client_ip'] and
                            ip.dst == conn['server_ip'] and
                            tcp.sport == conn['client_port'] and
                            tcp.dport == conn['server_port']):
                            
                            conn['ack'] = packet
                            conn['completed'] = True
                            conn['packets'].append(packet)
                            self.handshakes.append(conn)
        
        print(f"Found {len(self.handshakes)} complete TCP handshakes")
        return self.handshakes
    
    def analyze_handshake(self, handshake):
        """Analyze a single handshake in detail."""
        
        print("\n" + "=" * 60)
        print("TCP HANDSHAKE ANALYSIS")
        print("=" * 60)
        
        # Get packet details
        syn = handshake['syn']
        syn_ack = handshake['syn_ack']
        ack = handshake['ack']
        
        print(f"\nConnection: {handshake['client_ip']}:{handshake['client_port']} -> {handshake['server_ip']}:{handshake['server_port']}")
        print("-" * 40)
        
        # 1. SYN packet
        print("\n1. SYN (Connection Request):")
        if syn:
            tcp = syn[TCP]
            print(f"   Timestamp: {datetime.fromtimestamp(syn.time)}")
            print(f"   Source: {syn[IP].src}:{tcp.sport}")
            print(f"   Destination: {syn[IP].dst}:{tcp.dport}")
            print(f"   Sequence: {tcp.seq}")
            print(f"   Window: {tcp.window}")
            print(f"   Options: {tcp.options}")
        else:
            print("   SYN packet not found")
        
        # 2. SYN-ACK packet
        print("\n2. SYN-ACK (Connection Acknowledged):")
        if syn_ack:
            tcp = syn_ack[TCP]
            print(f"   Timestamp: {datetime.fromtimestamp(syn_ack.time)}")
            print(f"   Source: {syn_ack[IP].src}:{tcp.sport}")
            print(f"   Destination: {syn_ack[IP].dst}:{tcp.dport}")
            print(f"   Sequence: {tcp.seq}")
            print(f"   Acknowledgment: {tcp.ack}")
            print(f"   Window: {tcp.window}")
            print(f"   Options: {tcp.options}")
        else:
            print("   SYN-ACK packet not found")
        
        # 3. ACK packet (handshake complete)
        print("\n3. ACK (Handshake Complete):")
        if ack:
            tcp = ack[TCP]
            print(f"   Timestamp: {datetime.fromtimestamp(ack.time)}")
            print(f"   Source: {ack[IP].src}:{tcp.sport}")
            print(f"   Destination: {ack[IP].dst}:{tcp.dport}")
            print(f"   Sequence: {tcp.seq}")
            print(f"   Acknowledgment: {tcp.ack}")
            print(f"   Window: {tcp.window}")
        else:
            print("   ACK packet not found")
        
        # Calculate timing
        if syn and syn_ack and ack:
            syn_time = syn.time
            syn_ack_time = syn_ack.time
            ack_time = ack.time
            
            print("\nHandshake Timing:")
            print("-" * 40)
            print(f"   SYN -> SYN-ACK: {(syn_ack_time - syn_time) * 1000:.2f} ms")
            print(f"   SYN-ACK -> ACK: {(ack_time - syn_ack_time) * 1000:.2f} ms")
            print(f"   Total handshake: {(ack_time - syn_time) * 1000:.2f} ms")
    
    def visualize_handshake(self, handshake):
        """Visualize the handshake sequence."""
        
        syn = handshake['syn']
        syn_ack = handshake['syn_ack']
        ack = handshake['ack']
        
        print("\n" + "=" * 60)
        print("HANDSHAKE VISUALIZATION")
        print("=" * 60)
        
        client_ip = handshake['client_ip']
        server_ip = handshake['server_ip']
        
        print(f"\n{client_ip:<20}                    {server_ip:<20}")
        print("-" * 50)
        
        # SYN
        if syn:
            time_str = datetime.fromtimestamp(syn.time).strftime('%H:%M:%S.%f')[:-3]
            print(f"{time_str:<8}    │           SYN          │")
            print(f"{time_str:<8}    │─────────────────────> │")
        
        # SYN-ACK
        if syn_ack:
            time_str = datetime.fromtimestamp(syn_ack.time).strftime('%H:%M:%S.%f')[:-3]
            print(f"{time_str:<8}    │                     │")
            print(f"{time_str:<8}    │     SYN-ACK         │")
            print(f"{time_str:<8}    │<───────────────────── │")
        
        # ACK
        if ack:
            time_str = datetime.fromtimestamp(ack.time).strftime('%H:%M:%S.%f')[:-3]
            print(f"{time_str:<8}    │                     │")
            print(f"{time_str:<8}    │          ACK        │")
            print(f"{time_str:<8}    │─────────────────────> │")
        
        print("-" * 50)
        print("Connection Established")
    
    def display_summary(self):
        """Display summary of all handshakes found."""
        
        if not self.handshakes:
            print("No handshakes found in the capture.")
            return
        
        print("\n" + "=" * 60)
        print("HANDSHAKE SUMMARY")
        print("=" * 60)
        print(f"\nTotal complete handshakes: {len(self.handshakes)}")
        print("-" * 60)
        
        for i, handshake in enumerate(self.handshakes, 1):
            print(f"{i:2}. {handshake['client_ip']}:{handshake['client_port']} -> {handshake['server_ip']}:{handshake['server_port']}")
    
    def analyze_all(self):
        """Analyze all handshakes found."""
        
        self.extract_handshakes()
        self.display_summary()
        
        if self.handshakes:
            # Analyze each handshake
            for i, handshake in enumerate(self.handshakes, 1):
                print(f"\n{'='*60}")
                print(f"HANDSHAKE {i}/{len(self.handshakes)}")
                print(f"{'='*60}")
                self.analyze_handshake(handshake)
                self.visualize_handshake(handshake)

def main():
    """Main function for handshake analyzer."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='TCP Handshake Analyzer')
    parser.add_argument('pcap_file', help='PCAP file to analyze')
    
    args = parser.parse_args()
    
    analyzer = TCPHandshakeAnalyzer()
    if analyzer.load_pcap(args.pcap_file):
        analyzer.analyze_all()
    else:
        print("Could not load PCAP file")

if __name__ == "__main__":
    # If no arguments, interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("TCP HANDSHAKE ANALYZER")
        print("=" * 60)
        
        pcap_file = input("Enter PCAP file path: ").strip()
        if not pcap_file:
            print("No file specified.")
            sys.exit(1)
        
        analyzer = TCPHandshakeAnalyzer()
        if analyzer.load_pcap(pcap_file):
            analyzer.analyze_all()
    else:
        main()
```

### Step 3: TCP Flags Analysis Tool

Create `src/tcp_flags_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 3, Part 1: TCP Flags Analyzer

This script analyzes TCP flags in a packet capture
and provides detailed statistics and visualizations.
"""

from scapy.all import rdpcap, IP, TCP, Ether
import os
import sys
from collections import defaultdict, Counter
from datetime import datetime

class TCPFlagsAnalyzer:
    """
    Analyze TCP flags in network traffic.
    
    Features:
    - Flag distribution analysis
    - Flag sequence detection
    - Handshake completion tracking
    - Reset analysis
    - SYN flood detection
    """
    
    def __init__(self):
        """Initialize flags analyzer."""
        self.packets = []
        self.tcp_packets = []
        self.flag_counts = Counter()
        self.connection_states = {}
        self.suspicious_activity = []
    
    def load_pcap(self, pcap_file):
        """Load a PCAP file."""
        if not os.path.exists(pcap_file):
            print(f"Error: File not found: {pcap_file}")
            return False
        
        print(f"Loading PCAP: {pcap_file}")
        self.packets = rdpcap(pcap_file)
        print(f"Loaded {len(self.packets)} packets")
        return True
    
    def analyze_flags(self):
        """Analyze TCP flags in all packets."""
        
        print("\nAnalyzing TCP flags...")
        print("-" * 40)
        
        for packet in self.packets:
            if not packet.haslayer(TCP):
                continue
            
            tcp = packet[TCP]
            self.tcp_packets.append(packet)
            
            # Get flag string
            flags = self.get_flag_string(tcp.flags)
            self.flag_counts[flags] += 1
            
            # Check for suspicious flag combinations
            self.check_suspicious(packet)
            
            # Track connections
            self.track_connection(packet)
        
        print(f"Found {len(self.tcp_packets)} TCP packets")
        print(f"Unique flag combinations: {len(self.flag_counts)}")
    
    def get_flag_string(self, flags):
        """Convert flag bits to string representation."""
        flag_names = []
        if flags & 0x01: flag_names.append('FIN')
        if flags & 0x02: flag_names.append('SYN')
        if flags & 0x04: flag_names.append('RST')
        if flags & 0x08: flag_names.append('PSH')
        if flags & 0x10: flag_names.append('ACK')
        if flags & 0x20: flag_names.append('URG')
        if flags & 0x40: flag_names.append('ECE')
        if flags & 0x80: flag_names.append('CWR')
        
        return '+'.join(flag_names) if flag_names else 'None'
    
    def check_suspicious(self, packet):
        """Check for suspicious flag combinations."""
        
        tcp = packet[TCP]
        flags = tcp.flags
        
        # SYN without ACK (potential SYN flood)
        if flags == 0x02:  # SYN only
            # Track SYN packets
            key = f"{packet[IP].dst}:{tcp.dport}"
            if key not in self.connection_states:
                self.connection_states[key] = {'syn_count': 0, 'complete': False}
            self.connection_states[key]['syn_count'] += 1
        
        # SYN-ACK without corresponding SYN (potential spoofing)
        if flags == 0x12:  # SYN-ACK
            # Check if we saw a SYN for this connection
            key = f"{packet[IP].src}:{tcp.sport}"
            if key in self.connection_states:
                if self.connection_states[key]['syn_count'] == 0:
                    self.suspicious_activity.append({
                        'type': 'SYN-ACK without SYN',
                        'packet': packet,
                        'key': key
                    })
        
        # RST without prior connection
        if flags == 0x04:  # RST
            key = f"{packet[IP].src}:{tcp.sport}:{packet[IP].dst}:{tcp.dport}"
            if key not in self.connection_states:
                self.suspicious_activity.append({
                    'type': 'RST without connection',
                    'packet': packet,
                    'key': key
                })
    
    def track_connection(self, packet):
        """Track connection state."""
        
        ip = packet[IP]
        tcp = packet[TCP]
        flags = tcp.flags
        
        key = f"{ip.src}:{tcp.sport}:{ip.dst}:{tcp.dport}"
        reverse_key = f"{ip.dst}:{tcp.dport}:{ip.src}:{tcp.sport}"
        
        # Initialize connection tracking
        if key not in self.connection_states:
            self.connection_states[key] = {
                'syn_sent': False,
                'syn_ack_received': False,
                'ack_sent': False,
                'established': False,
                'closed': False,
                'packets': [],
                'first_seen': packet.time
            }
        
        # Update state based on flags
        if flags & 0x02:  # SYN
            self.connection_states[key]['syn_sent'] = True
        
        if flags & 0x12:  # SYN-ACK
            self.connection_states[key]['syn_ack_received'] = True
        
        if flags & 0x10 and not flags & 0x02:  # ACK without SYN
            if self.connection_states[key]['syn_sent'] and self.connection_states[key]['syn_ack_received']:
                self.connection_states[key]['established'] = True
        
        if flags & 0x01:  # FIN
            self.connection_states[key]['closed'] = True
        
        if flags & 0x04:  # RST
            self.connection_states[key]['closed'] = True
        
        self.connection_states[key]['packets'].append(packet)
    
    def display_flag_distribution(self):
        """Display flag distribution statistics."""
        
        print("\n" + "=" * 60)
        print("TCP FLAG DISTRIBUTION")
        print("=" * 60)
        
        total = len(self.tcp_packets)
        
        print(f"\nTotal TCP packets: {total}")
        print("-" * 40)
        
        # Sort by frequency
        for flags, count in self.flag_counts.most_common():
            percentage = (count / total) * 100
            bar = "█" * int(percentage / 2)
            print(f"  {flags:<20} {count:>6} ({percentage:>5.1f}%) {bar}")
    
    def display_connection_stats(self):
        """Display connection statistics."""
        
        print("\n" + "=" * 60)
        print("CONNECTION STATISTICS")
        print("=" * 60)
        
        completed = 0
        syn_flood = 0
        total_connections = len(self.connection_states)
        
        for key, state in self.connection_states.items():
            if state.get('established', False):
                completed += 1
            if state.get('syn_count', 0) > 10:
                syn_flood += 1
        
        print(f"\nTotal connections tracked: {total_connections}")
        print(f"Completed handshakes: {completed}")
        print(f"Potential SYN floods: {syn_flood}")
        
        if self.suspicious_activity:
            print(f"\nSuspicious activity detected: {len(self.suspicious_activity)}")
            print("-" * 40)
            for activity in self.suspicious_activity[:10]:  # Show first 10
                print(f"  {activity['type']}: {activity['key']}")
    
    def detect_syn_flood(self, threshold=10):
        """Detect potential SYN flood attacks."""
        
        print("\n" + "=" * 60)
        print("SYN FLOOD DETECTION")
        print("=" * 60)
        
        syn_sources = defaultdict(int)
        
        for packet in self.tcp_packets:
            tcp = packet[TCP]
            if tcp.flags == 0x02:  # SYN only
                src_ip = packet[IP].src
                syn_sources[src_ip] += 1
        
        potential_attacks = [(ip, count) for ip, count in syn_sources.items() 
                           if count > threshold]
        
        if potential_attacks:
            print(f"\nPotential SYN flood attacks detected ({len(potential_attacks)} sources):")
            print("-" * 40)
            print(f"{'Source IP':<20} {'SYN Count':<12} {'Status':<15}")
            print("-" * 40)
            for ip, count in sorted(potential_attacks, key=lambda x: x[1], reverse=True):
                status = "Attack" if count > threshold * 3 else "Suspicious"
                print(f"{ip:<20} {count:<12} {status:<15}")
        else:
            print("\nNo SYN flood attacks detected.")
    
    def generate_report(self):
        """Generate a complete report of TCP flag analysis."""
        
        print("\n" + "=" * 60)
        print("TCP FLAGS ANALYSIS REPORT")
        print("=" * 60)
        print(f"Generated: {datetime.now()}")
        print(f"PCAP: {self.pcap_file if hasattr(self, 'pcap_file') else 'Unknown'}")
        print("-" * 60)
        
        self.display_flag_distribution()
        self.display_connection_stats()
        self.detect_syn_flood()
        
        print("\n" + "=" * 60)
        print("REPORT COMPLETE")
        print("=" * 60)
    
    def analyze(self):
        """Run complete analysis."""
        
        self.analyze_flags()
        self.generate_report()

def main():
    """Main function for TCP flags analyzer."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='TCP Flags Analyzer')
    parser.add_argument('pcap_file', help='PCAP file to analyze')
    parser.add_argument('-t', '--threshold', type=int, default=10,
                        help='SYN flood detection threshold')
    
    args = parser.parse_args()
    
    analyzer = TCPFlagsAnalyzer()
    if analyzer.load_pcap(args.pcap_file):
        analyzer.threshold = args.threshold
        analyzer.analyze()

if __name__ == "__main__":
    # If no arguments, interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("TCP FLAGS ANALYZER")
        print("=" * 60)
        
        pcap_file = input("Enter PCAP file path: ").strip()
        if not pcap_file:
            print("No file specified.")
            sys.exit(1)
        
        analyzer = TCPFlagsAnalyzer()
        if analyzer.load_pcap(pcap_file):
            analyzer.analyze()
    else:
        main()
```

---

## The Verification: Testing Transport Layer Operations

### Verification 1: Run Transport Basics

```bash
cd ~/scapy-tutorial
python3 src/transport_basics.py
```

**Expected output**: Detailed TCP and UDP header field demonstrations with packet examples.

### Verification 2: Analyze TCP Handshakes

```bash
# Download a sample PCAP with TCP traffic if you don't have one
cd pcap_files
wget https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http.cap
cd ..

# Analyze handshakes
python3 src/tcp_handshake_analyzer.py pcap_files/http.cap
```

**Expected output**: Complete handshake analysis with timing and visualization.

### Verification 3: Analyze TCP Flags

```bash
python3 src/tcp_flags_analyzer.py pcap_files/http.cap
```

**Expected output**: Flag distribution, connection statistics, and SYN flood detection.

### Verification 4: Build Custom TCP/UDP Packets

```bash
# Build and show TCP packet
python3 -c "from scapy.all import IP, TCP; p=IP(dst='8.8.8.8')/TCP(dport=80, flags='S', seq=1000); p.show()"

# Build and show UDP packet
python3 -c "from scapy.all import IP, UDP, Raw; p=IP(dst='8.8.8.8')/UDP(dport=53)/Raw(b'DNS query'); p.show()"

# Create TCP SYN to test (don't actually send unless authorized)
python3 -c "from scapy.all import IP, TCP, sr1; p=IP(dst='8.8.8.8')/TCP(dport=80, flags='S'); print('SYN packet built:', p.summary())"
```

### Verification 5: Quick TCP/UDP Operations

```bash
# Show TCP flags
python3 -c "from scapy.all import TCP; t=TCP(); print(f'Default TCP flags: {t.flags}')"

# Show UDP checksum behavior
python3 -c "from scapy.all import IP, UDP; u=IP()/UDP(); print('UDP before show2:'); u.show(); print('\nUDP after show2:'); u.show2()"

# Compare TCP vs UDP packets
python3 -c "from scapy.all import IP, TCP, UDP; t=IP()/TCP(); u=IP()/UDP(); print(f'TCP length: {len(t)} bytes, UDP length: {len(u)} bytes')"
```

---

## Reference: TCP and UDP Deep Dive

### TCP Header Fields

| Field | Size | Description |
|-------|------|-------------|
| Source Port | 16 bits | Sending application port |
| Dest Port | 16 bits | Receiving application port |
| Sequence Number | 32 bits | Data sequence position |
| Acknowledgment | 32 bits | Next expected sequence |
| Data Offset | 4 bits | Header length in 32-bit words |
| Flags | 9 bits | Control flags (SYN, ACK, etc.) |
| Window | 16 bits | Advertised receive window |
| Checksum | 16 bits | Header + data checksum |
| Urgent Pointer | 16 bits | Urgent data position |
| Options | Variable | TCP options (MSS, SACK, etc.) |

### TCP Flags

| Flag | Bit Value | Description |
|------|-----------|-------------|
| FIN | 0x01 | Finish - end connection |
| SYN | 0x02 | Synchronize - start connection |
| RST | 0x04 | Reset - abort connection |
| PSH | 0x08 | Push - immediate delivery |
| ACK | 0x10 | Acknowledgment |
| URG | 0x20 | Urgent data |
| ECE | 0x40 | ECN Echo (congestion) |
| CWR | 0x80 | Congestion Window Reduced |
| NS | 0x100 | Nonce Sum (experimental) |

### UDP Header Fields

| Field | Size | Description |
|-------|------|-------------|
| Source Port | 16 bits | Sending application port |
| Dest Port | 16 bits | Receiving application port |
| Length | 16 bits | Datagram length (header + data) |
| Checksum | 16 bits | Optional checksum |

### Common TCP Ports

| Port | Protocol | Service |
|------|----------|---------|
| 20/21 | TCP | FTP |
| 22 | TCP | SSH |
| 23 | TCP | Telnet |
| 25 | TCP | SMTP |
| 53 | TCP/UDP | DNS |
| 80 | TCP | HTTP |
| 110 | TCP | POP3 |
| 143 | TCP | IMAP |
| 443 | TCP | HTTPS |
| 465 | TCP | SMTPS |
| 993 | TCP | IMAPS |
| 995 | TCP | POP3S |
| 3306 | TCP | MySQL |
| 5432 | TCP | PostgreSQL |

### TCP Options

| Option | Description |
|--------|-------------|
| MSS | Maximum Segment Size |
| SACK | Selective Acknowledgment |
| Timestamp | RTT measurement |
| Window Scale | Window size scaling |
| NOP | No Operation (padding) |
| EOL | End of Options List |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Assuming TCP Reliable in Simulation

```python
# DON'T: Assume packet will arrive
tcp_packet = IP(dst="8.8.8.8")/TCP(dport=80, flags="S")
send(tcp_packet)  # May be dropped, no guarantee

# DO: Use sr1 for request-response
reply = sr1(tcp_packet, timeout=3)
if reply:
    print("Response received")
else:
    print("No response")
```

### Pitfall 2: Forgetting Checksum Recalculation

```python
# DON'T: Modify packet without recalculating
packet = IP(dst="8.8.8.8")/TCP(dport=80)
packet[IP].ttl = 64  # Change TTL
send(packet)  # Checksum now invalid

# DO: Use show2() to recalculate
packet[IP].ttl = 64
packet.show2()  # Recalculates checksums
send(packet)
```

### Pitfall 3: Using UDP Without Timeouts

```python
# DON'T: No timeout for UDP
send(udp_packet)  # Will not get response

# DO: Use sr1 with timeout for UDP
reply = sr1(udp_packet, timeout=2)
```

### Best Practice: Use Flags Constants

```python
# Use flag constants for clarity
from scapy.all import TCP
SYN = 0x02
ACK = 0x10
SYN_ACK = SYN | ACK

tcp = TCP(flags=SYN_ACK)
```

### Best Practice: Validate Checksums

```python
def validate_checksum(packet):
    """Check if packet has valid checksum."""
    if packet.haslayer(IP):
        # Recalculate checksum
        packet.show2()
        # Checksum is now recalculated
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ TCP and UDP header structures
2. ✅ TCP three-way handshake mechanics
3. ✅ Custom TCP and UDP packet construction
4. ✅ TCP flag analysis and visualization
5. ✅ Handshake extraction from captures
6. ✅ Connection state tracking
7. ✅ SYN flood detection

---

## Next Steps: Preview of Part 2

In **Module 3, Part 2: Port Scanning Techniques**, we'll:

1. Understand different port scanning techniques
2. Build a TCP SYN scanner
3. Implement TCP Connect scanning
4. Create UDP scanners
5. Build a multi-threaded scanning engine
6. Implement service detection and banner grabbing

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 3, PART 1 COMPLETE                                  │
│  ✅ TCP and UDP structures mastered                                 │
│  ✅ TCP handshake analysis built                                    │
│  ✅ Custom TCP/UDP packets created                                  │
│  ✅ Flag analysis tools developed                                   │
│  ✅ Handshake visualizer created                                    │
│  NEXT: MODULE 3, PART 2 — Port Scanning Techniques                │
│  ● TCP SYN scanning                                                │
│  ● TCP Connect scanning                                           │
│  ● UDP scanning                                                    │
│  ● Multi-threaded scanning                                         │
│  ● Service detection                                               │
│  ● Banner grabbing                                                │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 2, where we'll build professional port scanning tools — learning how to discover open ports and services on network hosts.*
