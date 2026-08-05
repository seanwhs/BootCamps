# Mastering Network Packet Crafting with Scapy
## Module 1: Foundations of Packet Crafting
### Part 2: Understanding the Packet Stacking Model

## The Target: Mastering Scapy's Packet Construction Model

In this part, we'll build our first real packets using Scapy's elegant layering system. By the end, you'll understand:

1. How Scapy represents packets as protocol layers
2. The `/` operator and how it stacks layers
3. How to construct packets from Ethernet to application data
4. How to inspect packets using Scapy's powerful visualization methods
5. How to validate our packets by comparing with Wireshark

---

## The Concept: Packets as Onions (Not Ogres)

Think of a network packet like a set of Russian nesting dolls or an onion with multiple layers. Each layer wraps the one inside it:

```
┌─────────────────────────────────────────────────────────────┐
│                     ETHERNET FRAME                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                    IP HEADER                        │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │                 TCP HEADER                   │   │   │
│  │  │  ┌──────────────────────────────────────┐   │   │   │
│  │  │  │          APPLICATION DATA            │   │   │   │
│  │  │  │  (HTTP, DNS, or custom payload)      │   │   │   │
│  │  │  └──────────────────────────────────────┘   │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

In Scapy, we build these layers from **outside to inside** (like peeling an onion in reverse):

```python
# Outside layer (Ethernet) -> Next layer (IP) -> Next layer (TCP) -> Inside layer (Raw data)
packet = Ether() / IP() / TCP() / Raw()
```

The `/` operator in Scapy means **"encapsulate"** or **"layer on top of."** Think of it as "Ethernet contains IP, which contains TCP, which contains Raw data."

---

## The Implementation: Building Your First Packets

### Step 1: Understanding the Basic Layers

Create a new script: `src/packet_building_basics.py`

```python
#!/usr/bin/env python3
"""
Module 1, Part 2: Packet Building Basics

This script demonstrates Scapy's packet layering model
and how to construct, inspect, and manipulate packets.
"""

from scapy.all import Ether, IP, TCP, UDP, ICMP, Raw
from scapy.all import rdpcap, wrpcap, hexdump
import sys

def demonstrate_basic_packets():
    """Build and inspect basic packets at each layer."""
    
    print("\n" + "=" * 60)
    print("BASIC PACKET CONSTRUCTION")
    print("=" * 60 + "\n")
    
    # 1. Layer 2: Ethernet Frame Only
    print("1. ETHERNET FRAME (Layer 2)")
    print("-" * 40)
    ether = Ether()
    print("Default Ethernet frame:")
    ether.show()
    print(f"Packet summary: {ether.summary()}")
    print(f"Packet length: {len(ether)} bytes\n")
    
    # 2. Layer 3: IP Packet Only
    print("2. IP PACKET (Layer 3)")
    print("-" * 40)
    ip = IP()
    print("Default IP packet:")
    ip.show()
    print(f"Packet summary: {ip.summary()}")
    print(f"Packet length: {len(ip)} bytes\n")
    
    # 3. Layer 4: TCP Segment (requires IP or Ethernet)
    print("3. TCP SEGMENT (Layer 4)")
    print("-" * 40)
    tcp = TCP()
    print("Default TCP segment:")
    tcp.show()
    print(f"Packet summary: {tcp.summary()}")
    print(f"Packet length: {len(tcp)} bytes\n")
    
    # 4. Application Layer: Raw Data
    print("4. RAW DATA (Application Layer)")
    print("-" * 40)
    raw = Raw(b"Hello, Scapy! This is application data.")
    print("Raw data payload:")
    raw.show()
    print(f"Packet summary: {raw.summary()}")
    print(f"Packet length: {len(raw)} bytes\n")

def build_multi_layer_packets():
    """Build packets with multiple layers using the / operator."""
    
    print("\n" + "=" * 60)
    print("MULTI-LAYER PACKET CONSTRUCTION")
    print("=" * 60 + "\n")
    
    # 1. Ethernet + IP + ICMP (Ping packet)
    print("1. ETHERNET / IP / ICMP (Ping Request)")
    print("-" * 40)
    ping_packet = Ether() / IP(dst="8.8.8.8") / ICMP()
    print("Packet structure:")
    ping_packet.show()
    print(f"Packet summary: {ping_packet.summary()}")
    print(f"Packet length: {len(ping_packet)} bytes")
    print("\nLayer breakdown:")
    print(f"  Ethernet layer: {ping_packet[Ether].summary()}")
    print(f"  IP layer: {ping_packet[IP].summary()}")
    print(f"  ICMP layer: {ping_packet[ICMP].summary()}\n")
    
    # 2. Ethernet + IP + TCP (HTTP request)
    print("2. ETHERNET / IP / TCP (HTTP-like)")
    print("-" * 40)
    http_packet = Ether() / IP(dst="192.168.1.1") / TCP(dport=80) / Raw(b"GET / HTTP/1.1\r\n\r\n")
    print("Packet structure:")
    http_packet.show()
    print(f"Packet summary: {http_packet.summary()}")
    print(f"Packet length: {len(http_packet)} bytes")
    print("\nLayer breakdown:")
    print(f"  Ethernet layer: {http_packet[Ether].summary()}")
    print(f"  IP layer: {http_packet[IP].summary()}")
    print(f"  TCP layer: {http_packet[TCP].summary()}")
    print(f"  Raw payload: {http_packet[Raw].summary()}\n")
    
    # 3. Ethernet + IP + UDP + Raw (DNS query simulation)
    print("3. ETHERNET / IP / UDP / Raw (DNS-like)")
    print("-" * 40)
    dns_packet = Ether() / IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
    print("Packet structure:")
    dns_packet.show()
    print(f"Packet summary: {dns_packet.summary()}")
    print(f"Packet length: {len(dns_packet)} bytes\n")

def understand_the_operator():
    """Demonstrate how the / operator works in Scapy."""
    
    print("\n" + "=" * 60)
    print("UNDERSTANDING THE '/' OPERATOR")
    print("=" * 60 + "\n")
    
    # Demonstrating that order matters
    print("Order matters in Scapy:")
    print("-" * 40)
    
    # Correct order: Ethernet -> IP -> TCP
    correct = Ether() / IP() / TCP()
    print(f"Correct order (Ether / IP / TCP): {correct.summary()}")
    
    # Incorrect order: IP -> Ethernet -> TCP (doesn't make sense)
    try:
        incorrect = IP() / Ether() / TCP()
        print(f"Incorrect order (IP / Ether / TCP): {incorrect.summary()}")
        print("Note: Scapy tries to adapt, but this doesn't represent a valid network packet!")
    except Exception as e:
        print("Could not build invalid packet order (expected)")
    
    print("\nThe '/' operator builds layers from left to right:")
    print("  Leftmost = Outer/encapsulating layer")
    print("  Rightmost = Inner/encapsulated layer")
    
    # Demonstrating field inheritance
    print("\nField inheritance with / operator:")
    packet1 = IP(src="192.168.1.1", dst="8.8.8.8") / TCP(sport=12345, dport=80)
    print(f"  Packet 1: {packet1.summary()}")
    
    # Fields set on parent layers don't affect child layers
    packet2 = IP(dst="10.0.0.1") / TCP(dport=443)
    print(f"  Packet 2: {packet2.summary()}")
    print(f"    IP.dst = {packet2[IP].dst}, TCP.dport = {packet2[TCP].dport}\n")
    
    # You can also build layers step by step
    print("Building layers step by step:")
    ether = Ether(src="aa:bb:cc:dd:ee:ff", dst="ff:ee:dd:cc:bb:aa")
    ip = IP(src="10.0.0.5", dst="10.0.0.1")
    tcp = TCP(sport=54321, dport=22)  # SSH
    raw = Raw(b"SSH handshake data...")
    
    # Combine them
    ssh_packet = ether / ip / tcp / raw
    print(f"  SSH packet: {ssh_packet.summary()}")
    print(f"  Ethernet src: {ssh_packet[Ether].src}")
    print(f"  IP dst: {ssh_packet[IP].dst}")
    print(f"  TCP dport: {ssh_packet[TCP].dport}")
    print(f"  Raw payload (first 20 bytes): {bytes(ssh_packet[Raw])[:20]}\n")

def packet_inspection_methods():
    """Explore Scapy's packet inspection capabilities."""
    
    print("\n" + "=" * 60)
    print("PACKET INSPECTION METHODS")
    print("=" * 60 + "\n")
    
    # Create a complex test packet
    test_packet = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                  IP(src="192.168.1.100", dst="8.8.8.8", ttl=64) / \
                  TCP(sport=45678, dport=443, flags="S", seq=1000, ack=0) / \
                  Raw(b"SYN packet for testing")
    
    # 1. show() - Detailed hierarchical display
    print("1. show() - Hierarchical packet display")
    print("-" * 40)
    test_packet.show()
    
    # 2. summary() - One-line description
    print("\n2. summary() - One-line summary")
    print("-" * 40)
    print(f"  {test_packet.summary()}")
    
    # 3. hexdump() - Hexadecimal and ASCII display
    print("\n3. hexdump() - Hexadecimal dump")
    print("-" * 40)
    hexdump(test_packet)
    
    # 4. show2() - Show after Scapy's modifications
    print("\n4. show2() - Show after Scapy's automatic changes")
    print("-" * 40)
    # Scapy automatically sets length and checksum
    test_packet.show2()
    
    # 5. sprintf() - Custom formatted output
    print("\n5. sprintf() - Custom formatting")
    print("-" * 40)
    format_str = "IP %IP.src% -> %IP.dst% | TCP sport=%TCP.sport% dport=%TCP.dport% flags=%TCP.flags%"
    formatted = test_packet.sprintf(format_str)
    print(f"  {formatted}")
    
    # 6. command() - Get Python code to recreate this packet
    print("\n6. command() - Get recreate code")
    print("-" * 40)
    print(f"  Recreate with: {test_packet.command()}")
    
    # 7. raw() - Get raw bytes
    print("\n7. raw() - Raw bytes")
    print("-" * 40)
    raw_bytes = bytes(test_packet)
    print(f"  Length: {len(raw_bytes)} bytes")
    print(f"  Hex (first 20 bytes): {raw_bytes[:20].hex()}")
    
    # 8. str() - String representation
    print("\n8. str() - String representation")
    print("-" * 40)
    print(f"  {str(test_packet)[:150]}...\n")
    
    # 9. Accessing layers by type
    print("\n9. Accessing specific layers:")
    print("-" * 40)
    print(f"  Ethernet src: {test_packet[Ether].src}")
    print(f"  IP src: {test_packet[IP].src}")
    print(f"  TCP flags: {test_packet[TCP].flags}")
    print(f"  Raw payload: {test_packet[Raw].load}")
    
    # 10. The 'haslayer' method
    print("\n10. Checking for layer presence:")
    print("-" * 40)
    print(f"  Has IP layer: {test_packet.haslayer(IP)}")
    print(f"  Has UDP layer: {test_packet.haslayer(UDP)}")
    print(f"  Has Raw layer: {test_packet.haslayer(Raw)}")

def create_varied_packets():
    """Create different types of packets to show versatility."""
    
    print("\n" + "=" * 60)
    print("VARIED PACKET EXAMPLES")
    print("=" * 60 + "\n")
    
    # 1. ICMP Echo Request (Ping)
    print("1. ICMP Echo Request:")
    ping = IP(dst="8.8.8.8") / ICMP(type=8, code=0, id=12345, seq=1)
    print(f"  {ping.summary()}")
    print(f"  ICMP type: {ping[ICMP].type}, code: {ping[ICMP].code}\n")
    
    # 2. ICMP Echo Reply
    print("2. ICMP Echo Reply:")
    pong = IP(dst="192.168.1.100") / ICMP(type=0, code=0, id=12345, seq=1)
    print(f"  {pong.summary()}\n")
    
    # 3. TCP SYN packet (connection initiation)
    print("3. TCP SYN Packet:")
    syn = IP(dst="192.168.1.1") / TCP(sport=54321, dport=22, flags="S", seq=1000)
    print(f"  {syn.summary()}")
    print(f"  TCP flags: {syn[TCP].flags}\n")
    
    # 4. TCP SYN-ACK packet (connection response)
    print("4. TCP SYN-ACK Packet:")
    syn_ack = IP(src="192.168.1.1", dst="192.168.1.100") / TCP(sport=22, dport=54321, flags="SA", seq=2000, ack=1001)
    print(f"  {syn_ack.summary()}\n")
    
    # 5. UDP packet with payload
    print("5. UDP Packet with Payload:")
    udp = IP(dst="8.8.8.8") / UDP(sport=54321, dport=53) / Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
    print(f"  {udp.summary()}")
    print(f"  Raw payload: {bytes(udp[Raw])}\n")
    
    # 6. VLAN tagged packet (802.1Q)
    print("6. VLAN Tagged Packet:")
    # Note: Linux doesn't use Ethernet headers for VLAN by default, but Scapy supports it
    vlan = Ether(dst="ff:ff:ff:ff:ff:ff") / Ether() / IP(dst="10.0.0.1") / TCP(dport=80)
    print(f"  VLAN capable: {vlan.summary()}\n")

def compare_with_wireshark():
    """
    Compare Scapy's representation with Wireshark.
    This is a conceptual guide for visual verification.
    """
    
    print("\n" + "=" * 60)
    print("WIRESHARK CORRELATION GUIDE")
    print("=" * 60 + "\n")
    
    # Create a packet to analyze in Wireshark
    packet = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
             IP(src="192.168.1.100", dst="8.8.8.8") / \
             TCP(sport=45678, dport=80, flags="PA", seq=1000, ack=0) / \
             Raw(b"GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n")
    
    print("Packet for Wireshark analysis:")
    print("-" * 40)
    packet.show()
    
    print("\nTo verify in Wireshark:")
    print("1. Save packet: wrpcap('output/sample.pcap', packet)")
    print("2. Open in Wireshark: wireshark output/sample.pcap")
    print("3. Compare the layers:")
    print("   - Ethernet header: src=00:11:22:33:44:55, dst=66:77:88:99:aa:bb")
    print("   - IP header: src=192.168.1.100, dst=8.8.8.8")
    print("   - TCP header: sport=45678, dport=80, flags=PA")
    print("   - Data: GET /index.html HTTP/1.1...")
    print("4. Notice how Scapy's output matches Wireshark's dissection")

def packet_modification():
    """Demonstrate how to modify existing packets."""
    
    print("\n" + "=" * 60)
    print("PACKET MODIFICATION")
    print("=" * 60 + "\n")
    
    # Create a base packet
    packet = IP(src="192.168.1.100", dst="8.8.8.8") / TCP(sport=12345, dport=80)
    print("Original packet:")
    print(f"  {packet.summary()}")
    print(f"  IP.src: {packet[IP].src}, IP.dst: {packet[IP].dst}")
    print(f"  TCP.sport: {packet[TCP].sport}, TCP.dport: {packet[TCP].dport}\n")
    
    # Modify individual fields
    print("After modification:")
    packet[IP].src = "10.0.0.5"
    packet[IP].dst = "10.0.0.1"
    packet[TCP].sport = 54321
    packet[TCP].dport = 443
    print(f"  {packet.summary()}")
    print(f"  IP.src: {packet[IP].src}, IP.dst: {packet[IP].dst}")
    print(f"  TCP.sport: {packet[TCP].sport}, TCP.dport: {packet[TCP].dport}\n")
    
    # Adding new layers
    print("Adding new layers:")
    packet_with_raw = packet / Raw(b"Custom data payload")
    print(f"  Original: {packet.summary()}")
    print(f"  With Raw: {packet_with_raw.summary()}")
    print(f"  Raw payload: {bytes(packet_with_raw[Raw])}\n")
    
    # Removing layers
    print("Removing layers:")
    ip_only = packet_with_raw[IP]  # Extract IP layer and everything above
    print(f"  After removing Ethernet (if any): {ip_only.summary()}\n")

def packet_length_and_checksum():
    """Understand automatic packet calculations."""
    
    print("\n" + "=" * 60)
    print("AUTOMATIC CALCULATIONS (Length & Checksum)")
    print("=" * 60 + "\n")
    
    # Create a packet without specifying length/checksum
    packet = IP(dst="8.8.8.8") / ICMP()
    print("Before show2() (before Scapy auto-calculates):")
    packet.show()
    
    print("\nAfter show2() (Scapy calculates checksums and lengths):")
    packet.show2()
    
    print("\nUnderstanding the differences:")
    print("  - IP length: Scapy calculates the total IP packet length")
    print("  - IP checksum: Calculated for the IP header")
    print("  - ICMP checksum: Calculated for the ICMP payload")
    print("  - All these are updated automatically when you send the packet")

if __name__ == "__main__":
    print("=" * 60)
    print("MODULE 1, PART 2: PACKET STACKING MODEL")
    print("=" * 60)
    
    # Run all demonstrations
    demonstrate_basic_packets()
    build_multi_layer_packets()
    understand_the_operator()
    packet_inspection_methods()
    create_varied_packets()
    compare_with_wireshark()
    packet_modification()
    packet_length_and_checksum()
    
    print("\n" + "=" * 60)
    print("✅ PACKET STACKING DEMONSTRATION COMPLETE")
    print("=" * 60)
    print("\nYou've learned to:")
    print("  • Build packets layer by layer")
    print("  • Use the '/' operator for encapsulation")
    print("  • Inspect packets with show(), summary(), hexdump()")
    print("  • Modify packet fields")
    print("  • Understand automatic checksum/length calculations")
    print("\nTry creating your own custom packets in the labs!")
```

### Step 2: Save a Packet to PCAP for Wireshark Verification

Create `src/save_to_pcap.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 2: Save Packets to PCAP

This script creates a variety of packets and saves
them to a PCAP file for verification in Wireshark.
"""

from scapy.all import Ether, IP, TCP, UDP, ICMP, Raw, wrpcap, rdpcap
import os

def create_sample_packets():
    """Create a diverse set of packets for Wireshark analysis."""
    
    packets = []
    
    # 1. Simple ping packet
    ping = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
           IP(src="192.168.1.100", dst="8.8.8.8") / \
           ICMP(type=8, code=0, id=12345, seq=1)
    packets.append(ping)
    
    # 2. TCP SYN packet
    syn = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
          IP(src="192.168.1.100", dst="10.0.0.1") / \
          TCP(sport=54321, dport=80, flags="S", seq=1000)
    packets.append(syn)
    
    # 3. TCP SYN-ACK packet
    syn_ack = Ether(src="66:77:88:99:aa:bb", dst="00:11:22:33:44:55") / \
              IP(src="10.0.0.1", dst="192.168.1.100") / \
              TCP(sport=80, dport=54321, flags="SA", seq=2000, ack=1001)
    packets.append(syn_ack)
    
    # 4. TCP ACK with HTTP data
    http_data = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                IP(src="192.168.1.100", dst="10.0.0.1") / \
                TCP(sport=54321, dport=80, flags="A", seq=1001, ack=2001) / \
                Raw(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    packets.append(http_data)
    
    # 5. UDP DNS query
    dns_query = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                IP(src="192.168.1.100", dst="8.8.8.8") / \
                UDP(sport=54321, dport=53) / \
                Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
    packets.append(dns_query)
    
    # 6. UDP DNS response (simple simulated)
    dns_response = Ether(src="66:77:88:99:aa:bb", dst="00:11:22:33:44:55") / \
                   IP(src="8.8.8.8", dst="192.168.1.100") / \
                   UDP(sport=53, dport=54321) / \
                   Raw(b"\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\x00\x00")
    packets.append(dns_response)
    
    return packets

def save_and_verify():
    """Save packets and provide verification instructions."""
    
    # Create output directory if it doesn't exist
    os.makedirs("output", exist_ok=True)
    
    # Generate packets
    packets = create_sample_packets()
    
    # Save to PCAP
    output_file = "output/sample_packets.pcap"
    wrpcap(output_file, packets)
    
    print("=" * 60)
    print("PACKET SAVED TO PCAP")
    print("=" * 60)
    print(f"\nFile saved: {output_file}")
    print(f"Total packets: {len(packets)}")
    
    print("\nPacket summaries:")
    print("-" * 40)
    for i, pkt in enumerate(packets, 1):
        print(f"{i:2}. {pkt.summary()}")
    
    print("\n" + "=" * 60)
    print("WIRESHARK VERIFICATION")
    print("=" * 60)
    print("\nTo verify in Wireshark:")
    print("1. Open Wireshark")
    print("2. File -> Open -> Navigate to your project directory")
    print("3. Open: output/sample_packets.pcap")
    print("4. Examine each packet and compare with Scapy's display")
    print("5. Notice the field values match exactly!")
    
    print("\nAlternatively, from the command line:")
    print("  # Using tshark:")
    print("  tshark -r output/sample_packets.pcap -V")
    print("\n  # Using tcpdump:")
    print("  tcpdump -r output/sample_packets.pcap -n -vv")
    
    print("\n" + "=" * 60)
    print("To load this PCAP back into Scapy:")
    print("  from scapy.all import rdpcap")
    print("  packets = rdpcap('output/sample_packets.pcap')")
    print("  for pkt in packets:")
    print("      pkt.show()")
    print("=" * 60)

if __name__ == "__main__":
    save_and_verify()
```

### Step 3: Create Interactive Lab Exercises

Create `labs/lab_01_packet_exploration.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 2: Lab - Packet Exploration

This lab guides you through creating and exploring
custom packets on your own.
"""

from scapy.all import Ether, IP, TCP, UDP, ICMP, Raw, rdpcap, wrpcap
import sys

def lab_challenge_1():
    """Challenge 1: Build a custom TCP packet."""
    
    print("\n" + "=" * 60)
    print("LAB CHALLENGE 1: Custom TCP Packet")
    print("=" * 60)
    print("\nTask: Build a TCP SYN packet to 8.8.8.8 port 443")
    print("Requirements:")
    print("  - Source IP: 10.0.0.5")
    print("  - Destination IP: 8.8.8.8")
    print("  - Source port: 12345")
    print("  - Destination port: 443")
    print("  - TCP flags: SYN")
    print("  - Sequence number: 123456\n")
    
    # Your code here:
    # packet = IP(src=???, dst=???) / TCP(???)
    # Then packet.show()
    
    # Uncomment and complete:
    # packet = IP(___ ) / TCP( ___ )
    # packet.show()
    
    input("Press Enter when you've completed the challenge to see the solution...")
    
    # Solution
    packet = IP(src="10.0.0.5", dst="8.8.8.8") / TCP(sport=12345, dport=443, flags="S", seq=123456)
    print("\nSolution:")
    packet.show()
    
    if packet[IP].src == "10.0.0.5" and packet[IP].dst == "8.8.8.8":
        if packet[TCP].sport == 12345 and packet[TCP].dport == 443:
            if packet[TCP].flags == "S":
                print("✓ Correct! You built a valid TCP SYN packet.")
            else:
                print("✗ Check TCP flags - should be 'S' for SYN.")
        else:
            print("✗ Check TCP ports - should be sport=12345, dport=443.")
    else:
        print("✗ Check IP addresses - should be src=10.0.0.5, dst=8.8.8.8.")

def lab_challenge_2():
    """Challenge 2: Build a UDP packet with custom payload."""
    
    print("\n" + "=" * 60)
    print("LAB CHALLENGE 2: UDP Packet with Payload")
    print("=" * 60)
    print("\nTask: Build a UDP packet to 8.8.8.8 port 53")
    print("Payload: b'Hello from Scapy!'")
    print("Requirements:")
    print("  - Source IP: 192.168.1.100")
    print("  - Destination IP: 8.8.8.8")
    print("  - Source port: 56789")
    print("  - Destination port: 53")
    print("  - UDP packet with Raw payload\n")
    
    input("Press Enter when you've completed the challenge to see the solution...")
    
    # Solution
    packet = IP(src="192.168.1.100", dst="8.8.8.8") / UDP(sport=56789, dport=53) / Raw(b"Hello from Scapy!")
    print("\nSolution:")
    packet.show()
    
    # Verify
    if packet[Raw].load == b"Hello from Scapy!":
        print("✓ Correct! You built a UDP packet with the right payload.")
    else:
        print("✗ Check the Raw payload - should be b'Hello from Scapy!'")

def lab_challenge_3():
    """Challenge 3: Build a multi-layer packet with VLAN."""
    
    print("\n" + "=" * 60)
    print("LAB CHALLENGE 3: VLAN Tagged Packet")
    print("=" * 60)
    print("\nTask: Build a VLAN-tagged packet (IEEE 802.1Q)")
    print("Requirements:")
    print("  - Ethernet src: 00:11:22:33:44:55")
    print("  - Ethernet dst: 66:77:88:99:aa:bb")
    print("  - VLAN ID: 100")
    print("  - IP src: 10.0.0.5")
    print("  - IP dst: 10.0.0.1")
    print("  - ICMP (ping request)\n")
    print("Hint: In Scapy, VLAN is a separate layer: Ether / VLAN / IP / ICMP")
    
    input("Press Enter when you've completed the challenge to see the solution...")
    
    # Solution
    packet = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
             Dot1Q(vlan=100) / \
             IP(src="10.0.0.5", dst="10.0.0.1") / ICMP()
    print("\nSolution:")
    packet.show()
    
    print("\nNote: Dot1Q is Scapy's 802.1Q VLAN layer.")
    print("You can see the VLAN ID in the packet fields.")

def lab_exploration():
    """Free exploration of packet construction."""
    
    print("\n" + "=" * 60)
    print("FREE EXPLORATION: Build Your Own Packets")
    print("=" * 60)
    print("\nNow it's your turn to experiment!")
    print("Try creating packets with different combinations:")
    print("  - Different protocols (Ether, IP, IPv6, TCP, UDP, ICMP)")
    print("  - Different port numbers")
    print("  - Custom payloads")
    print("  - Different flags")
    print("  - VLAN tags")
    print("  - Fragmented packets")
    print("\nYou're in an interactive Python shell - type your code here.")
    print("Type 'exit()' when you're done.")
    
    import code
    code.interact(local=globals())

if __name__ == "__main__":
    print("=" * 60)
    print("MODULE 1, PART 2: PACKET EXPLORATION LAB")
    print("=" * 60)
    
    # Run through challenges
    lab_challenge_1()
    lab_challenge_2()
    lab_challenge_3()
    
    # Free exploration
    lab_exploration()
```

---

## The Verification: Testing Your Packet Building Skills

### Verification 1: Run the Packet Building Script

```bash
cd ~/scapy-tutorial
python3 src/packet_building_basics.py
```

**Expected output**: Detailed packet displays showing layer-by-layer construction. The output will demonstrate:

- Each layer's fields
- How layers combine with the `/` operator
- Different inspection methods working correctly
- Automatic checksum calculations

### Verification 2: Save and View with Wireshark

```bash
# Generate the PCAP file
python3 src/save_to_pcap.py

# Open with Wireshark (GUI)
wireshark output/sample_packets.pcap

# Or view with tshark (CLI)
tshark -r output/sample_packets.pcap -V
```

**Expected output**: Wireshark should show each packet with correctly identified protocols and field values matching what Scapy generated.

### Verification 3: Complete the Lab Challenges

```bash
python3 labs/lab_01_packet_exploration.py
```

**Expected output**: Success messages for each completed challenge.

### Verification 4: Quick Packet Building Test

```bash
# Create a packet and print its summary
python3 -c "from scapy.all import IP, TCP; pkt = IP(dst='8.8.8.8')/TCP(dport=80, flags='S'); print(pkt.summary())"
```

**Expected output**: `IP / TCP 0.0.0.0:20 > 8.8.8.8:80 S`

---

## Reference: Scapy's Packet Structure Deep Dive

### The `/` Operator Mechanics

When you use the `/` operator:

```python
packet = Ether() / IP() / TCP()
```

Scapy:
1. Creates an `Ether` object
2. Sets `Ether.payload` to the `IP` object
3. Sets `IP.payload` to the `TCP` object
4. Each layer can access its `payload` attribute to get the next layer

### Layer Access Methods

| Method | Description | Example |
|--------|-------------|---------|
| `pkt[Layer]` | Access layer by class | `pkt[IP].src` |
| `pkt.haslayer(Layer)` | Check if layer exists | `pkt.haslayer(TCP)` |
| `pkt.getlayer(Layer)` | Get layer or None | `pkt.getlayer(UDP)` |
| `pkt.payload` | Direct access to next layer | `pkt.payload.payload` |
| `pkt.summary()` | One-line description | `Ether / IP / TCP` |
| `pkt.show()` | Detailed hierarchy | All fields displayed |
| `pkt.show2()` | After auto-calculations | Checksums calculated |
| `pkt.hexdump()` | Hex/ASCII display | Raw bytes |
| `bytes(pkt)` | Raw packet bytes | For transmission |

### Common Layer Fields

**Ethernet (`Ether`)**:
- `src`: Source MAC address
- `dst`: Destination MAC address
- `type`: EtherType (auto-set by Scapy)

**IP (`IP`)**:
- `src`: Source IP address
- `dst`: Destination IP address
- `ttl`: Time To Live (default: 64)
- `id`: IP ID (auto-set)
- `flags`: IP flags (DF, MF)
- `frag`: Fragment offset

**TCP (`TCP`)**:
- `sport`: Source port
- `dport`: Destination port
- `seq`: Sequence number
- `ack`: Acknowledgment number
- `flags`: TCP flags (S, A, F, R, P, U, E, C)
- `window`: Window size (auto-set)

**UDP (`UDP`)**:
- `sport`: Source port
- `dport`: Destination port
- `len`: UDP length (auto-set)
- `chksum`: Checksum (auto-set)

**ICMP (`ICMP`)**:
- `type`: ICMP type (8=Echo Request, 0=Echo Reply)
- `code`: ICMP code (usually 0)
- `id`: ICMP ID
- `seq`: Sequence number

---

## Common Pitfalls and Best Practices

### Pitfall 1: Wrong Layer Order

```python
# DON'T DO THIS:
bad = TCP() / IP() / Ether()  # Wrong order

# DO THIS INSTEAD:
good = Ether() / IP() / TCP()  # Correct: outside to inside
```

### Pitfall 2: Not Using `show2()` for Checksums

```python
# Initial packet may show checksum 0x0
pkt = IP(dst="8.8.8.8") / ICMP()
pkt.show()  # Shows checksum as 0x0

# After show2(), checksums are calculated
pkt.show2()  # Shows actual checksum values
```

### Pitfall 3: Assuming Fields Are Set Automatically

```python
# NOT auto-filled:
pkt = TCP()  # sport=20, dport=80 (defaults)
pkt = TCP(sport=12345, dport=80)  # Explicitly set

# NOT auto-filled in IP:
pkt = IP()  # src=0.0.0.0, dst=0.0.0.0
pkt = IP(dst="8.8.8.8")  # Explicit dst
```

### Best Practice 1: Use Variables for Repeated Values

```python
# Good
SRC_IP = "192.168.1.100"
DST_IP = "8.8.8.8"
pkt = IP(src=SRC_IP, dst=DST_IP) / TCP()

# Better for multiple packets
common_eth = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff")
common_ip = IP(src="192.168.1.100")
pkt1 = common_eth / common_ip / TCP(dport=80)
pkt2 = common_eth / common_ip / UDP(dport=53)
```

### Best Practice 2: Use `haslayer()` Before Accessing

```python
# Safe approach
if pkt.haslayer(TCP):
    print(f"TCP dport: {pkt[TCP].dport}")
else:
    print("No TCP layer")

# Unsafe approach (causes error if TCP missing)
print(f"TCP dport: {pkt[TCP].dport}")  # Might raise AttributeError
```

### Best Practice 3: Verify with Wireshark

Always verify your crafted packets with Wireshark, especially when:
- Implementing new protocols
- Testing complex field combinations
- Debugging packet transmission issues

---

## What We've Accomplished

By completing this part, you've learned:

1. ✅ How Scapy represents packets as layer stacks
2. ✅ The `/` operator for building layered packets
3. ✅ How to inspect packets using `show()`, `summary()`, `hexdump()`
4. ✅ How to access and modify individual fields
5. ✅ How to save packets to PCAP for Wireshark verification
6. ✅ How to build various packet types (ICMP, TCP, UDP, VLAN)
7. ✅ How to work with Raw payloads
8. ✅ Automatic checksum and length calculations

---

## Next Steps: Preview of Part 3

In **Module 1, Part 3: Working with PCAP Files**, we'll:

1. Load existing PCAPs from the internet
2. Analyze captured traffic programmatically
3. Extract and filter packets
4. Modify packets from captures
5. Save modified packets back to PCAP
6. Build our first PCAP analysis tool

**Before Part 3**, make sure:
- You have a PCAP file to work with (download one from the resource list)
- You understand packet layers and the `/` operator
- You can build and inspect packets
- You have Wireshark installed for visual verification

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 1, PART 2 COMPLETE                                  │
│  ✅ Packet stacking model understood                                │
│  ✅ Multi-layer packets constructed                                 │
│  ✅ All inspection methods explored                                │
│  ✅ PCAP saved for Wireshark verification                          │
│  ✅ Lab challenges completed                                       │
│  NEXT: MODULE 1, PART 3 — Working with PCAP Files                 │
│  ● Loading PCAPs with rdpcap()                                    │
│  ● Analyzing captured traffic                                      │
│  ● Filtering packets programmatically                              │
│  ● Modifying and resaving PCAPs                                   │
│  ● Building a PCAP analysis tool                                  │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 3, where we'll start analyzing real network traffic captured from the wild — using the packet construction skills you've just learned to dissect and understand actual network communications.*
