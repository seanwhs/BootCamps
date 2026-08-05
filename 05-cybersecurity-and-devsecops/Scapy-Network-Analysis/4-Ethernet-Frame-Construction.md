# Mastering Network Packet Crafting with Scapy
## Module 2: Layer 2 & Layer 3 Operations
### Part 1: Ethernet Frame Construction

## The Target: Mastering Ethernet Frame Construction

In this part, we'll dive deep into Ethernet frames — the foundation of all local network communication. By the end, you'll be able to:

1. Construct Ethernet frames from scratch
2. Understand MAC addressing and frame structure
3. Work with VLAN tagging (802.1Q)
4. Build broadcast, unicast, and multicast frames
5. Create custom Ethernet utilities
6. Analyze Ethernet frames in Wireshark

---

## The Concept: The Ethernet Frame as a Delivery Envelope

Think of an Ethernet frame as a **physical envelope** for network data. Just as a postal envelope has:
- A **return address** (Source MAC)
- A **delivery address** (Destination MAC)
- **Postage/marking** (EtherType)
- The **letter inside** (Payload)

An Ethernet frame follows the same logic:

```
┌─────────────────────────────────────────────────────────────────┐
│                     ETHERNET FRAME                             │
│  ┌─────────┬──────────┬──────────────┬─────────────────┬────┐ │
│  │ Preamble│ Dest MAC │  Src MAC     │ EtherType/Length│Payload│ │
│  │ 8 bytes │ 6 bytes  │  6 bytes     │   2 bytes       │ var  │ │
│  └─────────┴──────────┴──────────────┴─────────────────┴────┘ │
│                                                               │
│  MAC addresses are unique hardware identifiers               │
│  EtherType tells what's inside (IP, ARP, IPv6, VLAN)        │
└─────────────────────────────────────────────────────────────────┘
```

**Key insight**: Ethernet is the **language** that devices on the same network segment speak. All network communication begins (and sometimes ends) at this layer.

---

## The Implementation: Building Ethernet Frames

### Step 1: Understanding MAC Addresses

Create `src/ethernet_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 1: Ethernet Frame Basics

This script demonstrates Ethernet frame construction,
MAC addressing, and basic Ethernet operations.
"""

from scapy.all import Ether, IP, ARP, ICMP, TCP, UDP, Raw, Dot1Q
from scapy.all import wrpcap, rdpcap, hexdump, conf
import os
import sys

def demonstrate_mac_addresses():
    """Demonstrate MAC addressing in Scapy."""
    
    print("\n" + "=" * 60)
    print("MAC ADDRESS DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # 1. Working with MAC addresses
    print("1. MAC Address Types:")
    print("-" * 40)
    
    # Unicast MAC (unique to a single device)
    unicast = "00:11:22:33:44:55"
    print(f"  Unicast MAC: {unicast}")
    
    # Broadcast MAC (all devices on network)
    broadcast = "ff:ff:ff:ff:ff:ff"
    print(f"  Broadcast MAC: {broadcast}")
    
    # Multicast MAC (group of devices)
    multicast = "01:00:5e:00:00:01"  # IPv4 multicast
    print(f"  Multicast MAC: {multicast}")
    
    # 2. Creating Ethernet frames with different MACs
    print("\n2. Ethernet Frame Construction:")
    print("-" * 40)
    
    # Unicast frame
    unicast_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb")
    print(f"  Unicast frame: {unicast_frame.summary()}")
    print(f"    Src: {unicast_frame.src}, Dst: {unicast_frame.dst}")
    
    # Broadcast frame
    broadcast_frame = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff")
    print(f"  Broadcast frame: {broadcast_frame.summary()}")
    print(f"    Src: {broadcast_frame.src}, Dst: {broadcast_frame.dst}")
    
    # Multicast frame (IPv4 multicast)
    multicast_frame = Ether(src="00:11:22:33:44:55", dst="01:00:5e:00:00:01")
    print(f"  Multicast frame: {multicast_frame.summary()}")
    print(f"    Src: {multicast_frame.src}, Dst: {multicast_frame.dst}")
    
    # 3. Checking MAC types
    print("\n3. MAC Type Detection:")
    print("-" * 40)
    
    def get_mac_type(mac):
        """Determine if MAC is unicast, broadcast, or multicast."""
        if mac == "ff:ff:ff:ff:ff:ff":
            return "Broadcast"
        elif int(mac.split(':')[0], 16) & 0x01:
            return "Multicast"
        else:
            return "Unicast"
    
    for mac in ["00:11:22:33:44:55", "ff:ff:ff:ff:ff:ff", "01:00:5e:00:00:01"]:
        print(f"  {mac}: {get_mac_type(mac)}")

def build_ethernet_frames():
    """Build various Ethernet frames."""
    
    print("\n" + "=" * 60)
    print("BUILDING ETHERNET FRAMES")
    print("=" * 60 + "\n")
    
    frames = []
    
    # 1. Ethernet frame with IP packet (ARP)
    print("1. Ethernet + ARP (Address Resolution Protocol):")
    print("-" * 40)
    arp_frame = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
                ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100", 
                    hwdst="00:00:00:00:00:00", pdst="192.168.1.1")
    arp_frame.show()
    frames.append(arp_frame)
    print()
    
    # 2. Ethernet frame with IP packet (ICMP ping)
    print("2. Ethernet + IP + ICMP (Ping Request):")
    print("-" * 40)
    ping_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                 IP(src="192.168.1.100", dst="8.8.8.8") / \
                 ICMP(type=8, code=0, id=12345, seq=1)
    ping_frame.show()
    frames.append(ping_frame)
    print()
    
    # 3. Ethernet frame with IP + TCP (HTTP request)
    print("3. Ethernet + IP + TCP (HTTP GET):")
    print("-" * 40)
    http_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                 IP(src="192.168.1.100", dst="10.0.0.1") / \
                 TCP(sport=54321, dport=80, flags="PA", seq=1000, ack=0) / \
                 Raw(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    http_frame.show()
    frames.append(http_frame)
    print()
    
    # 4. Ethernet frame with IP + UDP (DNS query)
    print("4. Ethernet + IP + UDP (DNS Query):")
    print("-" * 40)
    dns_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                IP(src="192.168.1.100", dst="8.8.8.8") / \
                UDP(sport=54321, dport=53) / \
                Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
    dns_frame.show()
    frames.append(dns_frame)
    print()
    
    return frames

def understand_ethertype():
    """Demonstrate EtherType field."""
    
    print("\n" + "=" * 60)
    print("ETHERTYPE FIELD DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Common EtherType values
    ethertypes = {
        0x0800: "IPv4",
        0x0806: "ARP",
        0x86DD: "IPv6",
        0x8100: "VLAN (802.1Q)",
        0x8847: "MPLS (unicast)",
        0x8848: "MPLS (multicast)",
        0x888E: "EAPOL (802.1X)",
        0x22F4: "ARP (proprietary)",
    }
    
    print("Common EtherType values:")
    print("-" * 40)
    for value, name in sorted(ethertypes.items()):
        print(f"  0x{value:04x}: {name}")
    
    # Build Ethernet frames with different EtherTypes
    print("\nScapy automatically sets EtherType:")
    print("-" * 40)
    
    # IP frame - EtherType 0x0800
    ip_frame = Ether() / IP(dst="8.8.8.8")
    print(f"  IP frame EtherType: 0x{ip_frame.type:04x}")
    
    # ARP frame - EtherType 0x0806
    arp_frame = Ether() / ARP()
    print(f"  ARP frame EtherType: 0x{arp_frame.type:04x}")
    
    # VLAN frame - EtherType 0x8100
    vlan_frame = Ether() / Dot1Q(vlan=100) / IP(dst="8.8.8.8")
    print(f"  VLAN frame EtherType: 0x{vlan_frame.type:04x}")
    
    # Manually set EtherType (advanced)
    custom_frame = Ether(type=0x88B5) / Raw(b"Custom protocol")
    print(f"  Custom EtherType: 0x{custom_frame.type:04x}")

def build_vlan_frames():
    """Build VLAN-tagged frames (802.1Q)."""
    
    print("\n" + "=" * 60)
    print("VLAN TAGGED FRAMES (802.1Q)")
    print("=" * 60 + "\n")
    
    # Import Dot1Q if not already imported
    from scapy.layers.l2 import Dot1Q
    
    # 1. Basic VLAN frame
    print("1. Basic VLAN Frame (VLAN ID 100):")
    print("-" * 40)
    vlan_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                 Dot1Q(vlan=100) / \
                 IP(src="192.168.1.100", dst="8.8.8.8") / \
                 ICMP()
    vlan_frame.show()
    
    # 2. VLAN with priority (QoS)
    print("\n2. VLAN with Priority (VLAN ID 200, Priority 5):")
    print("-" * 40)
    vlan_prio = Ether() / Dot1Q(vlan=200, prio=5) / IP(dst="8.8.8.8")
    vlan_prio.show()
    print(f"  Priority: {vlan_prio[Dot1Q].prio}")
    print(f"  VLAN ID: {vlan_prio[Dot1Q].vlan}")
    
    # 3. Double VLAN (Q-in-Q / 802.1ad)
    print("\n3. Double VLAN (Q-in-Q):")
    print("-" * 40)
    from scapy.layers.l2 import Dot1Q, SNAP
    
    # Note: Q-in-Q uses two Dot1Q layers
    qinq_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                 Dot1Q(vlan=100) / \
                 Dot1Q(vlan=200) / \
                 IP(src="192.168.1.100", dst="8.8.8.8")
    print("  Q-in-Q frame with outer VLAN 100, inner VLAN 200")
    qinq_frame.show()
    
    # 4. VLAN frame with payload
    print("\n4. VLAN Frame with Payload:")
    print("-" * 40)
    vlan_payload = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                   Dot1Q(vlan=300) / \
                   IP(src="192.168.1.100", dst="10.0.0.1") / \
                   TCP(sport=54321, dport=22, flags="S") / \
                   Raw(b"SSH handshake start")
    vlan_payload.show()
    print(f"  VLAN ID: {vlan_payload[Dot1Q].vlan}")
    print(f"  TCP flags: {vlan_payload[TCP].flags}")

def frame_manipulation():
    """Demonstrate Ethernet frame manipulation."""
    
    print("\n" + "=" * 60)
    print("ETHERNET FRAME MANIPULATION")
    print("=" * 60 + "\n")
    
    # Create a base frame
    base_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                 IP(src="192.168.1.100", dst="8.8.8.8") / \
                 ICMP()
    
    print("Original frame:")
    base_frame.show()
    
    # 1. Change MAC addresses
    print("\n1. Changing MAC addresses:")
    print("-" * 40)
    modified = base_frame.copy()
    modified[Ether].src = "aa:bb:cc:dd:ee:ff"
    modified[Ether].dst = "ff:ee:dd:cc:bb:aa"
    print(f"  New src MAC: {modified[Ether].src}")
    print(f"  New dst MAC: {modified[Ether].dst}")
    print(f"  Summary: {modified.summary()}")
    
    # 2. Add VLAN tag
    print("\n2. Adding VLAN tag:")
    print("-" * 40)
    from scapy.layers.l2 import Dot1Q
    
    # Create new frame with VLAN
    vlan_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                 Dot1Q(vlan=50) / \
                 IP(src="192.168.1.100", dst="8.8.8.8") / \
                 ICMP()
    print(f"  VLAN frame summary: {vlan_frame.summary()}")
    print(f"  VLAN ID: {vlan_frame[Dot1Q].vlan}")
    
    # 3. Remove VLAN tag
    print("\n3. Removing VLAN tag:")
    print("-" * 40)
    # If we have a VLAN frame, we can remove the VLAN layer
    if vlan_frame.haslayer(Dot1Q):
        # Get the payload of the VLAN layer (everything above it)
        inner_payload = vlan_frame[Dot1Q].payload
        # Create new frame without VLAN
        new_frame = Ether(src=vlan_frame[Ether].src, dst=vlan_frame[Ether].dst) / inner_payload
        print(f"  Original: {vlan_frame.summary()}")
        print(f"  Without VLAN: {new_frame.summary()}")
    
    # 4. Extract inner packet
    print("\n4. Extracting inner packet from Ethernet frame:")
    print("-" * 40)
    inner = base_frame[IP]  # Get just the IP layer and above
    print(f"  Original: {base_frame.summary()}")
    print(f"  Inner packet: {inner.summary()}")
    print(f"  Type: {type(inner).__name__}")
    
    # 5. Build from raw bytes
    print("\n5. Building Ethernet frame from raw bytes:")
    print("-" * 40)
    raw_bytes = bytes(base_frame)
    print(f"  Raw length: {len(raw_bytes)} bytes")
    print(f"  Hex (first 20 bytes): {raw_bytes[:20].hex()}")
    
    # Reconstruct from raw bytes
    reconstructed = Ether(raw_bytes)
    print(f"  Reconstructed: {reconstructed.summary()}")

def create_multicast_frame():
    """Create and demonstrate multicast Ethernet frames."""
    
    print("\n" + "=" * 60)
    print("MULTICAST ETHERNET FRAMES")
    print("=" * 60 + "\n")
    
    # 1. IPv4 multicast (mapped to Ethernet)
    print("1. IPv4 Multicast to Ethernet Mapping:")
    print("-" * 40)
    
    # IPv4 multicast addresses map to 01:00:5e:xx:xx:xx
    ipv4_multicast = "239.255.255.250"  # UPnP/SSDP
    # Calculate Ethernet multicast MAC
    # 01:00:5e:00:00:00 + lower 23 bits of IP
    print(f"  IPv4 multicast IP: {ipv4_multicast}")
    print(f"  Ethernet multicast: 01:00:5e:7f:ff:fa")
    
    # 2. Build multicast frame
    print("\n2. Building Multicast Frame:")
    print("-" * 40)
    multicast_frame = Ether(src="00:11:22:33:44:55", dst="01:00:5e:00:00:01") / \
                      IP(src="192.168.1.100", dst="224.0.0.1") / \
                      ICMP()
    multicast_frame.show()
    print(f"  Is multicast: {multicast_frame[Ether].dst.startswith('01:00:5e')}")
    
    # 3. Build broadcast frame
    print("\n3. Building Broadcast Frame:")
    print("-" * 40)
    broadcast_frame = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
                      ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100",
                          hwdst="00:00:00:00:00:00", pdst="192.168.1.1")
    broadcast_frame.show()
    print(f"  Is broadcast: {broadcast_frame[Ether].dst == 'ff:ff:ff:ff:ff:ff'}")

def analyze_frame_components(packet):
    """Analyze the components of an Ethernet frame."""
    
    print("\n" + "=" * 60)
    print("FRAME COMPONENT ANALYSIS")
    print("=" * 60 + "\n")
    
    if not packet.haslayer(Ether):
        print("Not an Ethernet frame.")
        return
    
    print(f"Ethernet frame analysis:")
    print("-" * 40)
    print(f"  Source MAC: {packet[Ether].src}")
    print(f"  Destination MAC: {packet[Ether].dst}")
    print(f"  EtherType: 0x{packet[Ether].type:04x}")
    print(f"  Frame length: {len(packet)} bytes")
    
    # Check if VLAN
    if packet.haslayer(Dot1Q):
        print(f"  VLAN ID: {packet[Dot1Q].vlan}")
        print(f"  VLAN Priority: {packet[Dot1Q].prio}")
        print(f"  VLAN CFI: {packet[Dot1Q].cfi}")
    
    # List all layers
    print(f"\n  Layers in this frame:")
    layers = []
    p = packet
    while p:
        layers.append(p.name)
        p = p.payload if hasattr(p, 'payload') else None
    
    for i, layer in enumerate(layers):
        print(f"    {i+1}. {layer}")

def save_ethernet_samples():
    """Save sample Ethernet frames to PCAP."""
    
    print("\n" + "=" * 60)
    print("SAVING ETHERNET SAMPLES TO PCAP")
    print("=" * 60 + "\n")
    
    packets = []
    
    # 1. Unicast frame
    unicast = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
              IP(src="192.168.1.100", dst="8.8.8.8") / ICMP()
    packets.append(unicast)
    
    # 2. Broadcast frame (ARP)
    broadcast = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
                ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100",
                    hwdst="00:00:00:00:00:00", pdst="192.168.1.1")
    packets.append(broadcast)
    
    # 3. Multicast frame
    multicast = Ether(src="00:11:22:33:44:55", dst="01:00:5e:00:00:01") / \
                IP(src="192.168.1.100", dst="224.0.0.1") / ICMP()
    packets.append(multicast)
    
    # 4. VLAN frame
    from scapy.layers.l2 import Dot1Q
    vlan = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
           Dot1Q(vlan=100) / \
           IP(src="192.168.1.100", dst="8.8.8.8") / ICMP()
    packets.append(vlan)
    
    # 5. Double VLAN (Q-in-Q)
    qinq = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
           Dot1Q(vlan=100) / \
           Dot1Q(vlan=200) / \
           IP(src="192.168.1.100", dst="8.8.8.8") / ICMP()
    packets.append(qinq)
    
    # Save to PCAP
    output_file = "output/ethernet_samples.pcap"
    os.makedirs("output", exist_ok=True)
    wrpcap(output_file, packets)
    
    print(f"Saved {len(packets)} Ethernet frames to: {output_file}")
    print("\nPacket summaries:")
    for i, pkt in enumerate(packets, 1):
        print(f"  #{i}: {pkt.summary()}")
    
    print(f"\nTo view in Wireshark:")
    print(f"  wireshark {output_file}")

def main():
    """Main function to run Ethernet demonstrations."""
    
    print("=" * 60)
    print("MODULE 2, PART 1: ETHERNET FRAME CONSTRUCTION")
    print("=" * 60)
    
    # Run all demonstrations
    demonstrate_mac_addresses()
    frames = build_ethernet_frames()
    understand_ethertype()
    build_vlan_frames()
    frame_manipulation()
    create_multicast_frame()
    
    # Analyze a sample frame
    if frames:
        analyze_frame_components(frames[0])
    
    save_ethernet_samples()
    
    print("\n" + "=" * 60)
    print("ETHERNET CONSTRUCTION DEMONSTRATION COMPLETE")
    print("=" * 60)
    print("\nYou've learned to:")
    print("  • Construct Ethernet frames with different MAC types")
    print("  • Understand EtherType values")
    print("  • Build VLAN-tagged frames")
    print("  • Manipulate Ethernet frames")
    print("  • Work with unicast, broadcast, and multicast")

if __name__ == "__main__":
    main()
```

### Step 2: Ethernet Frame Utilities

Create `src/ethernet_utils.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 1: Ethernet Utilities

This script provides utility functions for working
with Ethernet frames in Scapy.
"""

from scapy.all import Ether, IP, ARP, ICMP, TCP, UDP, Raw, Dot1Q
from scapy.all import wrpcap, rdpcap, hexdump, conf
import os
import sys
import re

class EthernetUtils:
    """Utility class for Ethernet frame operations."""
    
    @staticmethod
    def validate_mac(mac):
        """Validate a MAC address."""
        mac_pattern = r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
        return bool(re.match(mac_pattern, mac))
    
    @staticmethod
    def get_mac_type(mac):
        """Determine MAC address type."""
        if not EthernetUtils.validate_mac(mac):
            return "Invalid"
        
        # Normalize format
        mac = mac.replace(':', '').lower()
        
        if mac == 'ffffffffffff':
            return "Broadcast"
        elif int(mac[0:2], 16) & 0x01:
            return "Multicast"
        else:
            return "Unicast"
    
    @staticmethod
    def format_mac(mac):
        """Format MAC address with colons."""
        if not EthernetUtils.validate_mac(mac):
            mac = mac.replace(':', '').replace('-', '')
            if len(mac) == 12:
                return ':'.join([mac[i:i+2] for i in range(0, 12, 2)])
        return mac.lower()
    
    @staticmethod
    def mac_to_binary(mac):
        """Convert MAC address to binary string."""
        mac = EthernetUtils.format_mac(mac)
        return ''.join([format(int(x, 16), '08b') for x in mac.split(':')])
    
    @staticmethod
    def binary_to_mac(binary):
        """Convert binary string to MAC address."""
        if len(binary) != 48:
            return None
        mac = ':'.join([format(int(binary[i:i+8], 2), '02x') 
                       for i in range(0, 48, 8)])
        return mac
    
    @staticmethod
    def get_oui(mac):
        """Extract OUI (Organizationally Unique Identifier) from MAC."""
        mac = EthernetUtils.format_mac(mac)
        return mac[:8]  # First 3 bytes
    
    @staticmethod
    def build_frame(dst_mac, src_mac, payload, vlan_id=None):
        """Build an Ethernet frame with optional VLAN."""
        if not (EthernetUtils.validate_mac(dst_mac) and 
                EthernetUtils.validate_mac(src_mac)):
            raise ValueError("Invalid MAC address")
        
        frame = Ether(src=src_mac, dst=dst_mac)
        
        if vlan_id is not None:
            frame = frame / Dot1Q(vlan=vlan_id)
        
        if payload:
            frame = frame / payload
        
        return frame
    
    @staticmethod
    def extract_ethertype(frame):
        """Extract EtherType from frame."""
        if not frame.haslayer(Ether):
            return None
        return frame[Ether].type
    
    @staticmethod
    def is_broadcast(frame):
        """Check if frame is broadcast."""
        return frame.haslayer(Ether) and frame[Ether].dst == "ff:ff:ff:ff:ff:ff"
    
    @staticmethod
    def is_multicast(frame):
        """Check if frame is multicast."""
        if not frame.haslayer(Ether):
            return False
        dst = frame[Ether].dst
        return dst != "ff:ff:ff:ff:ff:ff" and int(dst.split(':')[0], 16) & 0x01
    
    @staticmethod
    def is_unicast(frame):
        """Check if frame is unicast."""
        if not frame.haslayer(Ether):
            return False
        dst = frame[Ether].dst
        return not (EthernetUtils.is_broadcast(frame) or 
                   EthernetUtils.is_multicast(frame))
    
    @staticmethod
    def get_payload_size(frame):
        """Get the size of the payload (excluding Ethernet header)."""
        if not frame.haslayer(Ether):
            return 0
        return len(frame) - 14  # 14 bytes for Ethernet header

def demo_utils():
    """Demonstrate Ethernet utilities."""
    
    print("\n" + "=" * 60)
    print("ETHERNET UTILITY DEMONSTRATION")
    print("=" * 60 + "\n")
    
    utils = EthernetUtils()
    
    # 1. MAC validation
    print("1. MAC Address Validation:")
    print("-" * 40)
    test_macs = [
        "00:11:22:33:44:55",
        "ff:ff:ff:ff:ff:ff",
        "invalid",
        "00-11-22-33-44-55",
        "00:11:22:33:44:5",
    ]
    for mac in test_macs:
        valid = utils.validate_mac(mac)
        status = "✓" if valid else "✗"
        print(f"  {status} {mac}")
    
    # 2. MAC type detection
    print("\n2. MAC Type Detection:")
    print("-" * 40)
    for mac in ["00:11:22:33:44:55", "ff:ff:ff:ff:ff:ff", "01:00:5e:00:00:01"]:
        mac_type = utils.get_mac_type(mac)
        print(f"  {mac}: {mac_type}")
    
    # 3. MAC formatting
    print("\n3. MAC Formatting:")
    print("-" * 40)
    test_macs = ["001122334455", "00:11:22:33:44:55", "00-11-22-33-44-55"]
    for mac in test_macs:
        formatted = utils.format_mac(mac)
        print(f"  {mac} -> {formatted}")
    
    # 4. MAC to binary conversion
    print("\n4. MAC to Binary Conversion:")
    print("-" * 40)
    mac = "00:11:22:33:44:55"
    binary = utils.mac_to_binary(mac)
    recovered = utils.binary_to_mac(binary)
    print(f"  MAC: {mac}")
    print(f"  Binary: {binary}")
    print(f"  Recovered: {recovered}")
    
    # 5. OUI extraction
    print("\n5. OUI Extraction:")
    print("-" * 40)
    mac = "00:11:22:33:44:55"
    oui = utils.get_oui(mac)
    print(f"  MAC: {mac}")
    print(f"  OUI: {oui}")
    
    # 6. Build frames with utility
    print("\n6. Building Frames with Utility:")
    print("-" * 40)
    
    # Build standard frame
    frame = utils.build_frame(
        dst_mac="66:77:88:99:aa:bb",
        src_mac="00:11:22:33:44:55",
        payload=IP(dst="8.8.8.8")/ICMP()
    )
    print(f"  Standard frame: {frame.summary()}")
    
    # Build VLAN frame
    vlan_frame = utils.build_frame(
        dst_mac="66:77:88:99:aa:bb",
        src_mac="00:11:22:33:44:55",
        payload=IP(dst="8.8.8.8")/ICMP(),
        vlan_id=100
    )
    print(f"  VLAN frame: {vlan_frame.summary()}")
    
    # 7. Frame analysis
    print("\n7. Frame Analysis:")
    print("-" * 40)
    print(f"  Is broadcast: {utils.is_broadcast(frame)}")
    print(f"  Is multicast: {utils.is_multicast(frame)}")
    print(f"  Is unicast: {utils.is_unicast(frame)}")
    print(f"  Payload size: {utils.get_payload_size(frame)} bytes")
    print(f"  EtherType: 0x{utils.extract_ethertype(frame):04x}")

def main():
    """Main function to run utilities demo."""
    
    print("=" * 60)
    print("ETHERNET UTILITIES")
    print("=" * 60)
    
    demo_utils()
    
    print("\n" + "=" * 60)
    print("UTILITY DEMONSTRATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### Step 3: Ethernet Frame Lab Exercises

Create `labs/lab_02_ethernet.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 1: Ethernet Frame Lab

This lab provides hands-on exercises for Ethernet frame construction
and manipulation in Scapy.
"""

from scapy.all import Ether, IP, ARP, ICMP, TCP, UDP, Raw, Dot1Q
from scapy.all import wrpcap, rdpcap
import os
import sys

def challenge_1():
    """Challenge 1: Build a broadcast ARP request."""
    
    print("\n" + "=" * 60)
    print("CHALLENGE 1: Broadcast ARP Request")
    print("=" * 60)
    print("\nTask: Build an ARP request frame")
    print("Requirements:")
    print("  - Ethernet src: 00:11:22:33:44:55")
    print("  - Ethernet dst: Broadcast")
    print("  - ARP operation: Request (1)")
    print("  - Sender MAC: 00:11:22:33:44:55")
    print("  - Sender IP: 192.168.1.100")
    print("  - Target IP: 192.168.1.1\n")
    
    input("Press Enter to see the solution...")
    
    # Solution
    arp_frame = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
                ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100",
                    hwdst="00:00:00:00:00:00", pdst="192.168.1.1")
    print("\nSolution:")
    arp_frame.show()
    print(f"\n✓ Built ARP request to {arp_frame[ARP].pdst}")

def challenge_2():
    """Challenge 2: Build a VLAN-tagged ping packet."""
    
    print("\n" + "=" * 60)
    print("CHALLENGE 2: VLAN-Tagged Ping")
    print("=" * 60)
    print("\nTask: Build a VLAN-tagged ICMP echo request")
    print("Requirements:")
    print("  - Ethernet src: 00:11:22:33:44:55")
    print("  - Ethernet dst: 66:77:88:99:aa:bb")
    print("  - VLAN ID: 50")
    print("  - IP src: 10.0.0.5")
    print("  - IP dst: 10.0.0.1")
    print("  - ICMP Echo Request")
    print("  - ICMP ID: 12345")
    print("  - ICMP Sequence: 1\n")
    
    input("Press Enter to see the solution...")
    
    # Solution
    vlan_ping = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
                Dot1Q(vlan=50) / \
                IP(src="10.0.0.5", dst="10.0.0.1") / \
                ICMP(type=8, code=0, id=12345, seq=1)
    print("\nSolution:")
    vlan_ping.show()
    print(f"\n✓ Built VLAN-tagged ping (VLAN ID: {vlan_ping[Dot1Q].vlan})")

def challenge_3():
    """Challenge 3: Build a frame with custom EtherType."""
    
    print("\n" + "=" * 60)
    print("CHALLENGE 3: Custom EtherType Frame")
    print("=" * 60)
    print("\nTask: Build a frame with a custom EtherType")
    print("Requirements:")
    print("  - Ethernet src: 00:11:22:33:44:55")
    print("  - Ethernet dst: 66:77:88:99:aa:bb")
    print("  - EtherType: 0x88B5 (Local Experimental)")
    print("  - Payload: b'Custom protocol data'\n")
    print("Hint: You can set the 'type' field in Ether()")
    
    input("Press Enter to see the solution...")
    
    # Solution
    custom_frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb", type=0x88B5) / \
                   Raw(b"Custom protocol data")
    print("\nSolution:")
    custom_frame.show()
    print(f"\n✓ Built frame with EtherType: 0x{custom_frame.type:04x}")

def challenge_4():
    """Challenge 4: Extract inner packet from frame."""
    
    print("\n" + "=" * 60)
    print("CHALLENGE 4: Extract Inner Packet")
    print("=" * 60)
    print("\nTask: Given a complete Ethernet frame,")
    print("extract and display just the IP packet inside")
    print("\nFrame:")
    
    # Create frame
    frame = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
            IP(src="192.168.1.100", dst="8.8.8.8") / \
            TCP(sport=54321, dport=80, flags="S")
    
    frame.show()
    
    input("\nPress Enter to see how to extract the inner packet...")
    
    # Solution
    print("\nSolution:")
    inner_packet = frame[IP]  # Extract just the IP layer and above
    print(f"\nInner packet:")
    inner_packet.show()
    print(f"\n✓ Extracted IP packet from Ethernet frame")

def challenge_5():
    """Challenge 5: Build Q-in-Q (double VLAN) frame."""
    
    print("\n" + "=" * 60)
    print("CHALLENGE 5: Q-in-Q Frame (Double VLAN)")
    print("=" * 60)
    print("\nTask: Build a Q-in-Q frame with two VLAN tags")
    print("Requirements:")
    print("  - Ethernet src: 00:11:22:33:44:55")
    print("  - Ethernet dst: 66:77:88:99:aa:bb")
    print("  - Outer VLAN ID: 100")
    print("  - Inner VLAN ID: 200")
    print("  - IP src: 10.0.0.5")
    print("  - IP dst: 10.0.0.1")
    print("  - ICMP Echo Request\n")
    
    input("Press Enter to see the solution...")
    
    # Solution
    qinq = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
           Dot1Q(vlan=100) / \
           Dot1Q(vlan=200) / \
           IP(src="10.0.0.5", dst="10.0.0.1") / ICMP()
    print("\nSolution:")
    qinq.show()
    print(f"\n✓ Built Q-in-Q frame (Outer VLAN: {qinq[Dot1Q].vlan}, Inner VLAN: {qinq[Dot1Q].vlan})")

def explore():
    """Free exploration mode."""
    
    print("\n" + "=" * 60)
    print("FREE EXPLORATION MODE")
    print("=" * 60)
    print("\nNow it's your turn to experiment!")
    print("Try building different Ethernet frames:")
    print("  - Frames with different MAC types (unicast, broadcast, multicast)")
    print("  - Frames with VLAN tags (single or double)")
    print("  - Frames with different EtherTypes")
    print("  - Frames with custom payloads")
    print("  - Frames with different combinations of protocols")
    print("\nType your code in the interactive shell below.")
    print("Type 'exit()' when done.")
    
    import code
    code.interact(local=globals())

def main():
    """Main function to run lab."""
    
    print("=" * 60)
    print("MODULE 2, PART 1: ETHERNET FRAME LAB")
    print("=" * 60)
    
    # Run challenges
    challenge_1()
    challenge_2()
    challenge_3()
    challenge_4()
    challenge_5()
    
    # Free exploration
    explore()
    
    print("\n" + "=" * 60)
    print("LAB COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

---

## The Verification: Testing Ethernet Frame Construction

### Verification 1: Run Ethernet Basics

```bash
cd ~/scapy-tutorial
python3 src/ethernet_basics.py
```

**Expected output**: Detailed demonstrations of Ethernet frame construction with all frame types displayed.

### Verification 2: Run Ethernet Utilities

```bash
python3 src/ethernet_utils.py
```

**Expected output**: MAC address validation, formatting, type detection, and frame building utilities.

### Verification 3: Complete Lab Challenges

```bash
python3 labs/lab_02_ethernet.py
```

**Expected output**: Success messages for each completed challenge.

### Verification 4: Save and Verify with Wireshark

```bash
# Generate the Ethernet samples
python3 src/ethernet_basics.py

# Open in Wireshark
wireshark output/ethernet_samples.pcap
```

**Expected output**: Wireshark showing all Ethernet frames with correct MAC addresses, EtherTypes, VLAN tags, and protocols.

### Verification 5: Quick Ethernet Operations

```bash
# Build and show an Ethernet frame
python3 -c "from scapy.all import Ether; f = Ether(src='00:11:22:33:44:55', dst='66:77:88:99:aa:bb'); f.show()"

# Build a VLAN frame
python3 -c "from scapy.all import Ether, Dot1Q; f = Ether()/Dot1Q(vlan=100)/IP(dst='8.8.8.8'); print(f.summary())"

# Check EtherType
python3 -c "from scapy.all import Ether; f = Ether()/IP(dst='8.8.8.8'); print(f'EtherType: 0x{f.type:04x}')"

# Check MAC type
python3 -c "from scapy.all import Ether; f = Ether(dst='ff:ff:ff:ff:ff:ff'); print(f'Broadcast: {f.dst == \"ff:ff:ff:ff:ff:ff\"}')"
```

---

## Reference: Ethernet Frame Deep Dive

### Ethernet Frame Structure

| Field | Size (bytes) | Description |
|-------|--------------|-------------|
| Destination MAC | 6 | Recipient's MAC address |
| Source MAC | 6 | Sender's MAC address |
| EtherType/Length | 2 | Protocol type or frame length |
| Payload | 46-1500 | Data (contains higher-layer protocol) |
| FCS (Frame Check Sequence) | 4 | CRC error checking (calculated by hardware) |

### VLAN Frame (802.1Q)

| Field | Size (bits) | Description |
|-------|-------------|-------------|
| TPID (Tag Protocol ID) | 16 | 0x8100 for VLAN |
| PCP (Priority) | 3 | Class of Service (0-7) |
| DEI/CFI | 1 | Drop Eligible or Canonical Format |
| VID (VLAN ID) | 12 | VLAN identifier (0-4095) |

### EtherType Common Values

| Value | Protocol |
|-------|----------|
| 0x0800 | IPv4 |
| 0x0806 | ARP |
| 0x86DD | IPv6 |
| 0x8100 | VLAN (802.1Q) |
| 0x88CC | LLDP |
| 0x8847 | MPLS Unicast |
| 0x8848 | MPLS Multicast |
| 0x888E | EAPOL |
| 0x88B5 | Local Experimental |

### MAC Address Types

| Type | Example | Characteristic |
|------|---------|----------------|
| Unicast | `00:11:22:33:44:55` | First bit of first byte = 0 |
| Multicast | `01:00:5e:00:00:01` | First bit of first byte = 1 |
| Broadcast | `ff:ff:ff:ff:ff:ff` | All bits = 1 |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Forgetting to Include Ethernet Layer

```python
# DON'T: Missing Ethernet layer
packet = IP(dst="8.8.8.8") / ICMP()  # This will NOT have Ethernet encapsulation

# DO: Include Ethernet layer
packet = Ether() / IP(dst="8.8.8.8") / ICMP()  # Complete frame
```

### Pitfall 2: Using Incorrect MAC Address Format

```python
# DON'T: Missing colons
bad = "001122334455"
Ether(dst=bad)  # This will work but is less readable

# DO: Use colons for clarity
good = "00:11:22:33:44:55"
Ether(dst=good)  # Clear and standard
```

### Pitfall 3: Invalid VLAN IDs

```python
# DON'T: Invalid VLAN range (0-4095 allowed)
Dot1Q(vlan=5000)  # Invalid

# DO: Use valid VLAN IDs
Dot1Q(vlan=100)  # Valid
```

### Best Practice: Use Scapy's MAC Utilities

```python
from scapy.all import RandMAC

# Generate random MAC
random_mac = RandMAC()
print(random_mac)

# Use in frame
frame = Ether(src=RandMAC(), dst="ff:ff:ff:ff:ff:ff")
```

### Best Practice: Verify with Wireshark

Always verify complex Ethernet frames with Wireshark to ensure:
- MAC addresses are correctly formatted
- VLAN tags are in the right place
- EtherType values are correct
- Frame length is valid

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ Ethernet frame structure and components
2. ✅ MAC addressing (unicast, broadcast, multicast)
3. ✅ VLAN tagging (802.1Q)
4. ✅ Q-in-Q (double VLAN) encapsulation
5. ✅ Custom EtherType values
6. ✅ Ethernet frame utilities and validation
7. ✅ Frame manipulation and extraction
8. ✅ Comprehensive Ethernet lab exercises

---

## Next Steps: Preview of Part 2

In **Module 2, Part 2: ARP Operations**, we'll:

1. Understand ARP request/reply mechanics
2. Build an ARP scanner to discover hosts
3. Detect duplicate IP addresses
4. Implement gratuitous ARP
5. Create a real-time ARP monitor
6. Build a network inventory tool

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 2, PART 1 COMPLETE                                  │
│  ✅ Ethernet frame construction mastered                           │
│  ✅ MAC addressing understood                                      │
│  ✅ VLAN tagging implemented                                        │
│  ✅ Q-in-Q frames built                                            │
│  ✅ Ethernet utilities created                                     │
│  NEXT: MODULE 2, PART 2 — ARP Operations                          │
│  ● ARP request/reply mechanics                                     │
│  ● ARP scanner implementation                                      │
│  ● Duplicate IP detection                                          │
│  ● Gratuitous ARP                                                  │
│  ● Network discovery tools                                         │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 2, where we'll explore the Address Resolution Protocol — the critical system that maps IP addresses to MAC addresses on local networks.*
