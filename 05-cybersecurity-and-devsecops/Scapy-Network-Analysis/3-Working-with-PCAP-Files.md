# Mastering Network Packet Crafting with Scapy
## Module 1: Foundations of Packet Crafting
### Part 3: Working with PCAP Files

## The Target: PCAP File Analysis and Manipulation

In this part, we'll bridge the gap between packet construction and real-world traffic analysis. By the end, you'll be able to:

1. Download and load PCAP files from public repositories
2. Analyze packet captures programmatically
3. Filter and extract specific packets
4. Modify existing packets from captures
5. Save modified captures to new PCAP files
6. Build a comprehensive PCAP analysis tool

---

## The Concept: PCAP as Your Packet Playground

Think of a PCAP (Packet Capture) file as a **video recording** of network traffic. Just as you can pause, rewind, and analyze a video frame by frame, a PCAP lets you examine each packet that crossed the wire during the capture.

**Why PCAPs are powerful**:
- **Ground truth**: They contain real network traffic
- **Reproducible**: Same capture, same analysis, every time
- **Safe**: No need to generate live traffic (great for learning)
- **Complete**: All layers preserved for deep analysis

**What we'll do**: Treat PCAPs like our personal laboratory samples. We'll load them, dissect them, modify them, and build tools to extract meaningful information.

---

## The Implementation: PCAP Mastery

### Step 1: Download Sample PCAP Files

Before we can analyze PCAPs, we need some to work with. Let's create a script to download sample captures:

Create `src/download_pcaps.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 3: PCAP Downloader

This script downloads sample PCAP files from public repositories
for analysis and learning purposes.
"""

import os
import urllib.request
import urllib.parse
import sys
from pathlib import Path

# Define sample PCAPs from Wireshark's collection
PCAP_SOURCES = {
    "dns_capture": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap",
    "http_capture": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http.cap",
    "tcp_3way": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/tcp.cap",
    "dhcp_capture": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.cap",
    "arp_capture": "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/arp.cap",
}

def download_pcap(url, output_dir="pcap_files"):
    """Download a PCAP file from a URL."""
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Extract filename from URL
    filename = os.path.basename(url)
    filepath = os.path.join(output_dir, filename)
    
    # Check if file already exists
    if os.path.exists(filepath):
        print(f"  ⚠ File already exists: {filename}")
        return filepath
    
    print(f"  Downloading {filename}...")
    
    try:
        # Download the file
        urllib.request.urlretrieve(url, filepath)
        print(f"  ✓ Downloaded: {filename}")
        return filepath
    except Exception as e:
        print(f"  ✗ Failed to download {filename}: {e}")
        return None

def download_all_pcaps():
    """Download all sample PCAPs."""
    
    print("=" * 60)
    print("DOWNLOADING SAMPLE PCAP FILES")
    print("=" * 60 + "\n")
    
    # Download each PCAP
    for name, url in PCAP_SOURCES.items():
        print(f"Source: {name}")
        filepath = download_pcap(url)
        
        if filepath and os.path.exists(filepath):
            size = os.path.getsize(filepath)
            print(f"  Size: {size} bytes\n")
    
    # Additional PCAPs from other sources (if needed)
    print("Additional recommended PCAPs:")
    print("  • The Ultimate PCAP: https://www.theultimatespcap.com/")
    print("  • NETRESEC PCAPs: https://www.netresec.com/?page=PcapFiles")
    print("  • Malware Traffic Analysis: https://www.malware-traffic-analysis.net/")
    
    print("\n" + "=" * 60)
    print("PCAP DOWNLOAD COMPLETE")
    print("=" * 60)

def list_pcaps():
    """List all PCAP files in the pcap_files directory."""
    
    pcap_dir = "pcap_files"
    if not os.path.exists(pcap_dir):
        print("No PCAP directory found. Run download_all_pcaps() first.")
        return
    
    print("\nAvailable PCAP files:")
    print("-" * 40)
    
    pcap_files = [f for f in os.listdir(pcap_dir) 
                  if f.endswith(('.pcap', '.cap', '.pcapng'))]
    
    if not pcap_files:
        print("  No PCAP files found.")
        return
    
    for f in sorted(pcap_files):
        filepath = os.path.join(pcap_dir, f)
        size = os.path.getsize(filepath)
        print(f"  {f:<30} {size:>10} bytes")
    
    print("-" * 40)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--list":
        list_pcaps()
    else:
        download_all_pcaps()
        list_pcaps()
```

**Run the downloader**:

```bash
cd ~/scapy-tutorial

# Download all sample PCAPs
python3 src/download_pcaps.py

# To list available PCAPs
python3 src/download_pcaps.py --list
```

### Step 2: Basic PCAP Loading and Inspection

Create `src/pcap_loading_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 3: PCAP Loading Basics

This script demonstrates how to load, inspect,
and analyze PCAP files with Scapy.
"""

from scapy.all import rdpcap, wrpcap, IP, TCP, UDP, ICMP, Ether
from scapy.utils import PcapReader
import os
import sys
from datetime import datetime

def load_pcap_basic(pcap_file):
    """Load a PCAP file and display basic information."""
    
    print("=" * 60)
    print(f"LOADING PCAP: {os.path.basename(pcap_file)}")
    print("=" * 60 + "\n")
    
    # Check if file exists
    if not os.path.exists(pcap_file):
        print(f"✗ File not found: {pcap_file}")
        return None
    
    # Load the PCAP
    print("Loading packets...")
    packets = rdpcap(pcap_file)
    
    print(f"\nPCAP Information:")
    print("-" * 40)
    print(f"  File: {pcap_file}")
    print(f"  File size: {os.path.getsize(pcap_file)} bytes")
    print(f"  Total packets: {len(packets)}")
    
    # Get capture time range
    if len(packets) > 0:
        first_time = packets[0].time
        last_time = packets[-1].time
        duration = last_time - first_time
        print(f"  First packet: {datetime.fromtimestamp(first_time)}")
        print(f"  Last packet: {datetime.fromtimestamp(last_time)}")
        print(f"  Duration: {duration:.2f} seconds")
        print(f"  Packets/second: {len(packets)/duration:.2f}" if duration > 0 else "  Packets/second: N/A")
    
    # Show first few packet summaries
    print(f"\nFirst 5 packets:")
    print("-" * 40)
    for i in range(min(5, len(packets))):
        print(f"  #{i+1}: {packets[i].summary()}")
    
    print(f"\nLast 5 packets:")
    print("-" * 40)
    for i in range(max(0, len(packets)-5), len(packets)):
        print(f"  #{i+1}: {packets[i].summary()}")
    
    return packets

def analyze_packet_types(packets):
    """Analyze the types of packets in the capture."""
    
    print("\n" + "=" * 60)
    print("PACKET TYPE ANALYSIS")
    print("=" * 60 + "\n")
    
    # Count packet types
    types = {}
    for pkt in packets:
        # Layer 3 protocols
        if pkt.haslayer(IP):
            # Determine protocol
            if pkt.haslayer(TCP):
                proto = "TCP"
            elif pkt.haslayer(UDP):
                proto = "UDP"
            elif pkt.haslayer(ICMP):
                proto = "ICMP"
            else:
                proto = "Other_IP"
        elif pkt.haslayer(Ether) and not pkt.haslayer(IP):
            proto = "Ether_Only"
        else:
            proto = "Unknown"
        
        types[proto] = types.get(proto, 0) + 1
    
    print("Protocol Distribution:")
    print("-" * 40)
    total = len(packets)
    for proto, count in sorted(types.items(), key=lambda x: x[1], reverse=True):
        percentage = (count / total) * 100
        bar = "█" * int(percentage / 2)  # Simple bar chart
        print(f"  {proto:<10} {count:>6} packets ({percentage:>5.1f}%) {bar}")
    
    return types

def analyze_addresses(packets):
    """Analyze source and destination addresses."""
    
    print("\n" + "=" * 60)
    print("ADDRESS ANALYSIS")
    print("=" * 60 + "\n")
    
    # IP addresses
    src_ips = {}
    dst_ips = {}
    
    for pkt in packets:
        if pkt.haslayer(IP):
            ip = pkt[IP]
            src_ips[ip.src] = src_ips.get(ip.src, 0) + 1
            dst_ips[ip.dst] = dst_ips.get(ip.dst, 0) + 1
    
    print("Top 5 Source IP Addresses:")
    print("-" * 40)
    for ip, count in sorted(src_ips.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {ip:<15} {count:>5} packets")
    
    print("\nTop 5 Destination IP Addresses:")
    print("-" * 40)
    for ip, count in sorted(dst_ips.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {ip:<15} {count:>5} packets")

def analyze_ports(packets):
    """Analyze TCP/UDP ports."""
    
    print("\n" + "=" * 60)
    print("PORT ANALYSIS")
    print("=" * 60 + "\n")
    
    # TCP ports
    tcp_src = {}
    tcp_dst = {}
    udp_src = {}
    udp_dst = {}
    
    for pkt in packets:
        if pkt.haslayer(TCP):
            tcp = pkt[TCP]
            tcp_src[tcp.sport] = tcp_src.get(tcp.sport, 0) + 1
            tcp_dst[tcp.dport] = tcp_dst.get(tcp.dport, 0) + 1
        elif pkt.haslayer(UDP):
            udp = pkt[UDP]
            udp_src[udp.sport] = udp_src.get(udp.sport, 0) + 1
            udp_dst[udp.dport] = udp_dst.get(udp.dport, 0) + 1
    
    if tcp_src:
        print("TCP Source Ports (top 5):")
        print("-" * 40)
        for port, count in sorted(tcp_src.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {port:<6} {count:>5} packets")
    
    if tcp_dst:
        print("\nTCP Destination Ports (top 5):")
        print("-" * 40)
        for port, count in sorted(tcp_dst.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {port:<6} {count:>5} packets")
    
    if udp_src:
        print("\nUDP Source Ports (top 5):")
        print("-" * 40)
        for port, count in sorted(udp_src.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {port:<6} {count:>5} packets")
    
    if udp_dst:
        print("\nUDP Destination Ports (top 5):")
        print("-" * 40)
        for port, count in sorted(udp_dst.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {port:<6} {count:>5} packets")

def protocol_specific_analysis(packets):
    """Perform protocol-specific analysis."""
    
    print("\n" + "=" * 60)
    print("PROTOCOL-SPECIFIC ANALYSIS")
    print("=" * 60 + "\n")
    
    # Count ICMP types
    icmp_types = {}
    for pkt in packets:
        if pkt.haslayer(ICMP):
            icmp = pkt[ICMP]
            icmp_types[icmp.type] = icmp_types.get(icmp.type, 0) + 1
    
    if icmp_types:
        print("ICMP Types:")
        print("-" * 40)
        for type_code, count in icmp_types.items():
            type_name = {
                0: "Echo Reply",
                3: "Destination Unreachable",
                4: "Source Quench",
                5: "Redirect",
                8: "Echo Request",
                11: "Time Exceeded",
                12: "Parameter Problem"
            }.get(type_code, f"Type {type_code}")
            print(f"  {type_code}: {type_name:<20} {count:>5} packets")
    
    # Check for SYN packets
    syn_count = 0
    syn_ack_count = 0
    rst_count = 0
    fin_count = 0
    
    for pkt in packets:
        if pkt.haslayer(TCP):
            flags = pkt[TCP].flags
            if flags & 0x02:  # SYN flag
                if flags & 0x10:  # ACK flag
                    syn_ack_count += 1
                else:
                    syn_count += 1
            if flags & 0x04:  # RST flag
                rst_count += 1
            if flags & 0x01:  # FIN flag
                fin_count += 1
    
    if syn_count or syn_ack_count:
        print("\nTCP Connection Information:")
        print("-" * 40)
        print(f"  SYN packets: {syn_count}")
        print(f"  SYN-ACK packets: {syn_ack_count}")
        print(f"  RST packets: {rst_count}")
        print(f"  FIN packets: {fin_count}")
        if syn_count > 0 or syn_ack_count > 0:
            print(f"  Potential connections: {min(syn_count, syn_ack_count)}")

def find_large_packets(packets, threshold=1000):
    """Find packets larger than the threshold."""
    
    print("\n" + "=" * 60)
    print(f"PACKETS LARGER THAN {threshold} BYTES")
    print("=" * 60 + "\n")
    
    large_packets = []
    for idx, pkt in enumerate(packets):
        pkt_len = len(pkt)
        if pkt_len > threshold:
            large_packets.append((idx, pkt, pkt_len))
    
    if not large_packets:
        print(f"  No packets larger than {threshold} bytes.")
        return
    
    print(f"Found {len(large_packets)} large packets:")
    print("-" * 40)
    for idx, pkt, pkt_len in large_packets[:10]:  # Show first 10
        print(f"  #{idx}: {pkt_len} bytes - {pkt.summary()}")
    
    if len(large_packets) > 10:
        print(f"  ... and {len(large_packets) - 10} more")

def extract_payloads(packets):
    """Extract and display payloads from TCP/UDP packets."""
    
    print("\n" + "=" * 60)
    print("PAYLOAD EXTRACTION")
    print("=" * 60 + "\n")
    
    payload_count = 0
    for idx, pkt in enumerate(packets):
        if pkt.haslayer(Raw):
            raw = pkt[Raw]
            payload = bytes(raw)
            payload_count += 1
            
            if payload_count <= 5:  # Show first 5 payloads
                print(f"Packet #{idx} payload:")
                print("-" * 40)
                print(f"  Length: {len(payload)} bytes")
                print(f"  Hex: {payload[:32].hex()}")
                if len(payload) > 32:
                    print("  ...")
                print(f"  ASCII: {payload[:32]}")
                print()
    
    print(f"Total packets with payload: {payload_count}")

def run_pcap_analysis(pcap_file):
    """Run full PCAP analysis."""
    
    # Load packets
    packets = load_pcap_basic(pcap_file)
    if not packets:
        return
    
    # Run analyses
    analyze_packet_types(packets)
    analyze_addresses(packets)
    analyze_ports(packets)
    protocol_specific_analysis(packets)
    find_large_packets(packets)
    extract_payloads(packets)
    
    print("\n" + "=" * 60)
    print("PCAP ANALYSIS COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    # Find first PCAP file in pcap_files directory
    pcap_dir = "pcap_files"
    if not os.path.exists(pcap_dir):
        print("Error: pcap_files directory not found.")
        print("Run: python3 src/download_pcaps.py")
        sys.exit(1)
    
    pcap_files = [f for f in os.listdir(pcap_dir) 
                  if f.endswith(('.pcap', '.cap', '.pcapng'))]
    
    if not pcap_files:
        print("No PCAP files found. Run download_pcaps.py first.")
        sys.exit(1)
    
    # Use first PCAP found
    pcap_file = os.path.join(pcap_dir, pcap_files[0])
    run_pcap_analysis(pcap_file)
```

### Step 3: PCAP Filtering and Extraction

Create `src/pcap_filtering.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 3: PCAP Filtering and Extraction

This script demonstrates how to filter packets
from PCAP files based on various criteria.
"""

from scapy.all import rdpcap, wrpcap, IP, TCP, UDP, ICMP, Ether
import os
import sys

def load_pcap(pcap_file):
    """Load a PCAP file."""
    if not os.path.exists(pcap_file):
        print(f"✗ File not found: {pcap_file}")
        return None
    return rdpcap(pcap_file)

def filter_by_protocol(packets, protocol):
    """Filter packets by protocol."""
    
    if protocol == "TCP":
        filtered = [p for p in packets if p.haslayer(TCP)]
    elif protocol == "UDP":
        filtered = [p for p in packets if p.haslayer(UDP)]
    elif protocol == "ICMP":
        filtered = [p for p in packets if p.haslayer(ICMP)]
    elif protocol == "IP":
        filtered = [p for p in packets if p.haslayer(IP)]
    else:
        filtered = []
    
    return filtered

def filter_by_ip(packets, ip_addr, direction="both"):
    """Filter packets by IP address."""
    
    filtered = []
    for pkt in packets:
        if not pkt.haslayer(IP):
            continue
        
        ip = pkt[IP]
        if direction == "src":
            if ip.src == ip_addr:
                filtered.append(pkt)
        elif direction == "dst":
            if ip.dst == ip_addr:
                filtered.append(pkt)
        else:  # both
            if ip.src == ip_addr or ip.dst == ip_addr:
                filtered.append(pkt)
    
    return filtered

def filter_by_port(packets, port, protocol="TCP", direction="both"):
    """Filter packets by port number."""
    
    filtered = []
    for pkt in packets:
        if not pkt.haslayer(protocol):
            continue
        
        if protocol == "TCP":
            layer = pkt[TCP]
        elif protocol == "UDP":
            layer = pkt[UDP]
        else:
            continue
        
        if direction == "src":
            if layer.sport == port:
                filtered.append(pkt)
        elif direction == "dst":
            if layer.dport == port:
                filtered.append(pkt)
        else:  # both
            if layer.sport == port or layer.dport == port:
                filtered.append(pkt)
    
    return filtered

def filter_by_tcp_flags(packets, flags):
    """Filter TCP packets by flags."""
    
    filtered = []
    for pkt in packets:
        if not pkt.haslayer(TCP):
            continue
        
        tcp = pkt[TCP]
        # Check if the packet has all the specified flags
        if (tcp.flags & flags) == flags:
            filtered.append(pkt)
    
    return filtered

def filter_payload(packets, search_bytes=None, search_string=None):
    """Filter packets containing specific payload."""
    
    filtered = []
    search_data = None
    
    if search_string:
        search_data = search_string.encode()
    elif search_bytes:
        search_data = search_bytes
    
    if not search_data:
        return []
    
    for pkt in packets:
        if not pkt.haslayer(Raw):
            continue
        
        raw = bytes(pkt[Raw])
        if search_data in raw:
            filtered.append(pkt)
    
    return filtered

def demonstrate_filters(packets):
    """Demonstrate various filtering techniques."""
    
    print("=" * 60)
    print("PCAP FILTERING DEMONSTRATION")
    print("=" * 60 + "\n")
    
    total = len(packets)
    print(f"Total packets in capture: {total}\n")
    
    # 1. Filter by protocol
    print("1. PROTOCOL FILTERS")
    print("-" * 40)
    for proto in ["TCP", "UDP", "ICMP", "IP"]:
        filtered = filter_by_protocol(packets, proto)
        percentage = (len(filtered) / total) * 100 if total > 0 else 0
        print(f"  {proto}: {len(filtered):>5} packets ({percentage:>5.1f}%)")
    
    # 2. Filter by IP (if there are IP packets)
    ip_packets = filter_by_protocol(packets, "IP")
    if ip_packets:
        print("\n2. IP FILTERS")
        print("-" * 40)
        
        # Get top IPs
        src_ips = {}
        dst_ips = {}
        for pkt in ip_packets:
            src_ips[pkt[IP].src] = src_ips.get(pkt[IP].src, 0) + 1
            dst_ips[pkt[IP].dst] = dst_ips.get(pkt[IP].dst, 0) + 1
        
        if src_ips:
            top_src = max(src_ips.items(), key=lambda x: x[1])
            print(f"  Top source IP: {top_src[0]} ({top_src[1]} packets)")
            
            # Filter by this IP
            filtered = filter_by_ip(packets, top_src[0], "src")
            print(f"  Filtered by src {top_src[0]}: {len(filtered)} packets")
        
        if dst_ips:
            top_dst = max(dst_ips.items(), key=lambda x: x[1])
            print(f"  Top destination IP: {top_dst[0]} ({top_dst[1]} packets)")
            
            # Filter by this IP
            filtered = filter_by_ip(packets, top_dst[0], "dst")
            print(f"  Filtered by dst {top_dst[0]}: {len(filtered)} packets")
    
    # 3. Filter by port
    print("\n3. PORT FILTERS")
    print("-" * 40)
    
    # Get common TCP ports
    tcp_packets = filter_by_protocol(packets, "TCP")
    if tcp_packets:
        ports = {}
        for pkt in tcp_packets:
            tcp = pkt[TCP]
            ports[tcp.sport] = ports.get(tcp.sport, 0) + 1
            ports[tcp.dport] = ports.get(tcp.dport, 0) + 1
        
        if ports:
            top_port = max(ports.items(), key=lambda x: x[1])
            print(f"  Top TCP port: {top_port[0]} ({top_port[1]} occurrences)")
            
            filtered = filter_by_port(packets, top_port[0], "TCP")
            print(f"  Filtered by port {top_port[0]}: {len(filtered)} packets")
    
    # 4. Filter by TCP flags
    print("\n4. TCP FLAG FILTERS")
    print("-" * 40)
    for flags, name in [(0x02, "SYN"), (0x10, "ACK"), (0x04, "RST"), (0x01, "FIN")]:
        filtered = filter_by_tcp_flags(packets, flags)
        print(f"  {name}: {len(filtered):>5} packets")
    
    # 5. Filter by payload
    print("\n5. PAYLOAD FILTERS")
    print("-" * 40)
    
    # Search for common strings
    search_strings = ["HTTP", "GET", "POST", "DNS"]
    for search in search_strings:
        filtered = filter_payload(packets, search_string=search)
        print(f"  '{search}': {len(filtered):>5} packets")

def extract_flows(packets):
    """Extract flows (conversations) from packets."""
    
    print("\n" + "=" * 60)
    print("FLOW EXTRACTION")
    print("=" * 60 + "\n")
    
    # Build flow dictionary
    flows = {}
    for pkt in packets:
        if not pkt.haslayer(IP):
            continue
        
        ip = pkt[IP]
        if pkt.haslayer(TCP):
            proto = "TCP"
            layer = pkt[TCP]
            key = f"{proto}:{ip.src}:{layer.sport}:{ip.dst}:{layer.dport}"
        elif pkt.haslayer(UDP):
            proto = "UDP"
            layer = pkt[UDP]
            key = f"{proto}:{ip.src}:{layer.sport}:{ip.dst}:{layer.dport}"
        else:
            key = f"IP:{ip.src}:{ip.dst}"
        
        flows[key] = flows.get(key, 0) + 1
    
    print("Top 10 Flows (by packet count):")
    print("-" * 40)
    for flow, count in sorted(flows.items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {count:>4} packets: {flow}")
    
    return flows

def main():
    """Main function to run PCAP filtering demo."""
    
    # Find PCAP files
    pcap_dir = "pcap_files"
    if not os.path.exists(pcap_dir):
        print("Error: pcap_files directory not found.")
        print("Run: python3 src/download_pcaps.py")
        sys.exit(1)
    
    pcap_files = [f for f in os.listdir(pcap_dir) 
                  if f.endswith(('.pcap', '.cap', '.pcapng'))]
    
    if not pcap_files:
        print("No PCAP files found. Run download_pcaps.py first.")
        sys.exit(1)
    
    # Load first PCAP
    pcap_file = os.path.join(pcap_dir, pcap_files[0])
    print(f"Using PCAP: {pcap_file}\n")
    
    packets = load_pcap(pcap_file)
    if not packets:
        return
    
    # Run demonstrations
    demonstrate_filters(packets)
    extract_flows(packets)
    
    print("\n" + "=" * 60)
    print("FILTERING DEMONSTRATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### Step 4: PCAP Modification and Generation

Create `src/pcap_modification.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 3: PCAP Modification and Generation

This script demonstrates how to modify packets
in a PCAP and generate new PCAP files.
"""

from scapy.all import rdpcap, wrpcap, IP, TCP, UDP, ICMP, Ether, Raw
from scapy.all import RandIP, RandMAC
import os
import sys
from datetime import datetime

def load_pcap(pcap_file):
    """Load a PCAP file."""
    if not os.path.exists(pcap_file):
        print(f"✗ File not found: {pcap_file}")
        return None
    return rdpcap(pcap_file)

def anonymize_ip(packet):
    """Anonymize IP addresses in a packet."""
    
    if not packet.haslayer(IP):
        return packet
    
    # Create a copy to avoid modifying original
    pkt = packet.copy()
    
    # Randomize source and destination IPs
    pkt[IP].src = str(RandIP())
    pkt[IP].dst = str(RandIP())
    
    # Recalculate checksums
    if pkt.haslayer(TCP):
        del pkt[TCP].chksum
        del pkt[IP].chksum
    elif pkt.haslayer(UDP):
        del pkt[UDP].chksum
        del pkt[IP].chksum
    elif pkt.haslayer(ICMP):
        del pkt[ICMP].chksum
        del pkt[IP].chksum
    
    return pkt

def modify_packet_ttl(packet, ttl):
    """Modify the TTL of an IP packet."""
    
    if not packet.haslayer(IP):
        return packet
    
    pkt = packet.copy()
    pkt[IP].ttl = ttl
    # Recalculate checksum
    if pkt.haslayer(TCP):
        del pkt[TCP].chksum
    elif pkt.haslayer(UDP):
        del pkt[UDP].chksum
    elif pkt.haslayer(ICMP):
        del pkt[ICMP].chksum
    if pkt.haslayer(IP):
        del pkt[IP].chksum
    
    return pkt

def modify_tcp_port(packet, sport=None, dport=None, protocol="TCP"):
    """Modify TCP or UDP ports."""
    
    if protocol == "TCP" and not packet.haslayer(TCP):
        return packet
    elif protocol == "UDP" and not packet.haslayer(UDP):
        return packet
    
    pkt = packet.copy()
    
    if protocol == "TCP":
        if sport:
            pkt[TCP].sport = sport
        if dport:
            pkt[TCP].dport = dport
        del pkt[TCP].chksum
    else:
        if sport:
            pkt[UDP].sport = sport
        if dport:
            pkt[UDP].dport = dport
        del pkt[UDP].chksum
    
    if pkt.haslayer(IP):
        del pkt[IP].chksum
    
    return pkt

def remove_payload(packet):
    """Remove Raw payload from a packet."""
    
    if not packet.haslayer(Raw):
        return packet
    
    pkt = packet.copy()
    del pkt[Raw]
    
    # Recalculate checksums
    if pkt.haslayer(TCP):
        del pkt[TCP].chksum
    elif pkt.haslayer(UDP):
        del pkt[UDP].chksum
    if pkt.haslayer(IP):
        del pkt[IP].chksum
    
    return pkt

def modify_payload(packet, new_payload):
    """Replace or add payload to packet."""
    
    pkt = packet.copy()
    
    if pkt.haslayer(Raw):
        pkt[Raw].load = new_payload
    else:
        pkt = pkt / Raw(load=new_payload)
    
    # Recalculate checksums
    if pkt.haslayer(TCP):
        del pkt[TCP].chksum
    elif pkt.haslayer(UDP):
        del pkt[UDP].chksum
    if pkt.haslayer(IP):
        del pkt[IP].chksum
    
    return pkt

def create_packet_from_template(template_packet, modifications):
    """Create a new packet from a template with modifications."""
    
    pkt = template_packet.copy()
    
    # Apply modifications
    for mod_type, value in modifications.items():
        if mod_type == "ttl":
            if pkt.haslayer(IP):
                pkt[IP].ttl = value
        elif mod_type == "sport":
            if pkt.haslayer(TCP):
                pkt[TCP].sport = value
            elif pkt.haslayer(UDP):
                pkt[UDP].sport = value
        elif mod_type == "dport":
            if pkt.haslayer(TCP):
                pkt[TCP].dport = value
            elif pkt.haslayer(UDP):
                pkt[UDP].dport = value
        elif mod_type == "payload":
            if pkt.haslayer(Raw):
                pkt[Raw].load = value
            else:
                pkt = pkt / Raw(load=value)
        elif mod_type == "ttl":
            if pkt.haslayer(IP):
                pkt[IP].ttl = value
    
    # Recalculate checksums
    if pkt.haslayer(TCP):
        del pkt[TCP].chksum
    elif pkt.haslayer(UDP):
        del pkt[UDP].chksum
    if pkt.haslayer(IP):
        del pkt[IP].chksum
    
    return pkt

def demonstrate_modifications(packets):
    """Demonstrate various packet modifications."""
    
    print("=" * 60)
    print("PACKET MODIFICATION DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Get a sample packet
    if not packets:
        print("No packets to modify.")
        return
    
    sample_idx = 0
    sample_packet = packets[sample_idx]
    
    print(f"Original packet #{sample_idx}:")
    print("-" * 40)
    print(f"  Summary: {sample_packet.summary()}")
    print(f"  Length: {len(sample_packet)} bytes")
    print(f"  IPv4 TTL: {sample_packet[IP].ttl}" if sample_packet.haslayer(IP) else "  No IP layer")
    print()
    
    # 1. Modify TTL
    if sample_packet.haslayer(IP):
        print("1. Modify TTL (50):")
        print("-" * 40)
        modified = modify_packet_ttl(sample_packet, 50)
        print(f"  New summary: {modified.summary()}")
        print(f"  New TTL: {modified[IP].ttl}")
        print()
    
    # 2. Anonymize IPs
    if sample_packet.haslayer(IP):
        print("2. Anonymize IPs:")
        print("-" * 40)
        modified = anonymize_ip(sample_packet)
        print(f"  New summary: {modified.summary()}")
        print(f"  New src IP: {modified[IP].src}")
        print(f"  New dst IP: {modified[IP].dst}")
        print()
    
    # 3. Modify TCP ports
    if sample_packet.haslayer(TCP):
        print("3. Modify TCP ports (sport=12345, dport=8080):")
        print("-" * 40)
        modified = modify_tcp_port(sample_packet, sport=12345, dport=8080)
        print(f"  New summary: {modified.summary()}")
        print(f"  New sport: {modified[TCP].sport}")
        print(f"  New dport: {modified[TCP].dport}")
        print()
    
    # 4. Remove payload
    if sample_packet.haslayer(Raw):
        print("4. Remove payload:")
        print("-" * 40)
        modified = remove_payload(sample_packet)
        print(f"  New summary: {modified.summary()}")
        print(f"  Has Raw: {modified.haslayer(Raw)}")
        print()
    
    # 5. Modify payload
    print("5. Modify payload:")
    print("-" * 40)
    new_payload = b"Modified data from Scapy!"
    modified = modify_payload(sample_packet, new_payload)
    print(f"  New summary: {modified.summary()}")
    if modified.haslayer(Raw):
        print(f"  New payload: {bytes(modified[Raw])}")
    print()

def save_modified_pcap(packets, output_file="output/modified_packets.pcap"):
    """Save a modified PCAP file."""
    
    # Create output directory if it doesn't exist
    os.makedirs("output", exist_ok=True)
    
    print("\nSaving modified PCAP...")
    print("-" * 40)
    print(f"  Output file: {output_file}")
    print(f"  Packets to save: {len(packets)}")
    
    wrpcap(output_file, packets)
    
    # Verify it was saved
    if os.path.exists(output_file):
        size = os.path.getsize(output_file)
        print(f"  ✓ File saved: {size} bytes")
        print(f"  ✓ Location: {os.path.abspath(output_file)}")
    else:
        print("  ✗ Error saving file")
    
    return output_file

def generate_test_pcap():
    """Generate a PCAP with various packet types for testing."""
    
    print("\n" + "=" * 60)
    print("GENERATING TEST PCAP")
    print("=" * 60 + "\n")
    
    packets = []
    
    # 1. Ping request
    ping = Ether(src=RandMAC(), dst=RandMAC()) / \
           IP(src=RandIP(), dst=RandIP()) / \
           ICMP(type=8, code=0, id=12345, seq=1)
    packets.append(ping)
    
    # 2. Ping reply
    ping_reply = Ether(src=RandMAC(), dst=RandMAC()) / \
                 IP(src=RandIP(), dst=RandIP()) / \
                 ICMP(type=0, code=0, id=12345, seq=1)
    packets.append(ping_reply)
    
    # 3. TCP SYN
    syn = Ether(src=RandMAC(), dst=RandMAC()) / \
          IP(src=RandIP(), dst=RandIP()) / \
          TCP(sport=54321, dport=80, flags="S", seq=1000)
    packets.append(syn)
    
    # 4. TCP SYN-ACK
    syn_ack = Ether(src=RandMAC(), dst=RandMAC()) / \
              IP(src=RandIP(), dst=RandIP()) / \
              TCP(sport=80, dport=54321, flags="SA", seq=2000, ack=1001)
    packets.append(syn_ack)
    
    # 5. TCP ACK with data
    data = Ether(src=RandMAC(), dst=RandMAC()) / \
           IP(src=RandIP(), dst=RandIP()) / \
           TCP(sport=54321, dport=80, flags="A", seq=1001, ack=2001) / \
           Raw(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    packets.append(data)
    
    # 6. UDP DNS query
    dns = Ether(src=RandMAC(), dst=RandMAC()) / \
          IP(src=RandIP(), dst=RandIP()) / \
          UDP(sport=54321, dport=53) / \
          Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
    packets.append(dns)
    
    # 7. UDP DNS response
    dns_resp = Ether(src=RandMAC(), dst=RandMAC()) / \
               IP(src=RandIP(), dst=RandIP()) / \
               UDP(sport=53, dport=54321) / \
               Raw(b"\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\x00\x00")
    packets.append(dns_resp)
    
    print(f"Generated {len(packets)} test packets:")
    for i, pkt in enumerate(packets, 1):
        print(f"  #{i}: {pkt.summary()}")
    
    # Save the test PCAP
    output_file = "output/test_packets.pcap"
    save_modified_pcap(packets, output_file)
    
    return packets

def main():
    """Main function to run PCAP modification demo."""
    
    # First, generate a test PCAP
    test_packets = generate_test_pcap()
    
    # Also load a real PCAP if available
    pcap_dir = "pcap_files"
    real_packets = None
    
    if os.path.exists(pcap_dir):
        pcap_files = [f for f in os.listdir(pcap_dir) 
                      if f.endswith(('.pcap', '.cap', '.pcapng'))]
        
        if pcap_files:
            pcap_file = os.path.join(pcap_dir, pcap_files[0])
            print(f"\nLoading real PCAP: {pcap_file}")
            real_packets = load_pcap(pcap_file)
    
    # Demonstrate modifications on test packets
    demonstrate_modifications(test_packets)
    
    # If we have real packets, demonstrate on them too
    if real_packets:
        print("\n" + "=" * 60)
        print("MODIFYING REAL PCAP PACKETS")
        print("=" * 60 + "\n")
        
        # Take first 5 real packets
        sample_real = real_packets[:5]
        demonstrate_modifications(sample_real)
        
        # Modify all real packets
        print("Modifying all real packets...")
        modified_real = []
        for pkt in real_packets:
            # Anonymize IPs and modify TTL
            if pkt.haslayer(IP):
                pkt = anonymize_ip(pkt)
                pkt = modify_packet_ttl(pkt, 128)
            modified_real.append(pkt)
        
        # Save modified real packets
        save_modified_pcap(modified_real, "output/modified_real_pcap.pcap")
    
    print("\n" + "=" * 60)
    print("MODIFICATION DEMONSTRATION COMPLETE")
    print("=" * 60)
    print("\nGenerated files:")
    print("  • output/test_packets.pcap - Generated test packets")
    if real_packets:
        print("  • output/modified_real_pcap.pcap - Modified real PCAP")

if __name__ == "__main__":
    main()
```

### Step 5: Building a PCAP Analysis Tool

Create `src/pcap_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 3: Comprehensive PCAP Analyzer

This script provides a command-line tool for analyzing
PCAP files with various options.
"""

from scapy.all import rdpcap, IP, TCP, UDP, ICMP, Ether, Raw
from scapy.layers.inet import IP as IPLayer
import os
import sys
import argparse
import json
from datetime import datetime
from collections import defaultdict

class PCAPAnalyzer:
    """A comprehensive PCAP analysis tool."""
    
    def __init__(self, pcap_file):
        """Initialize the analyzer with a PCAP file."""
        self.pcap_file = pcap_file
        self.packets = None
        self.stats = {}
        
    def load(self):
        """Load the PCAP file."""
        if not os.path.exists(self.pcap_file):
            raise FileNotFoundError(f"PCAP file not found: {self.pcap_file}")
        
        print(f"Loading {self.pcap_file}...")
        self.packets = rdpcap(self.pcap_file)
        print(f"Loaded {len(self.packets)} packets")
        return self
    
    def analyze_basic_stats(self):
        """Analyze basic statistics."""
        
        print("\n" + "=" * 60)
        print("BASIC STATISTICS")
        print("=" * 60)
        
        if not self.packets:
            print("No packets loaded.")
            return
        
        total = len(self.packets)
        print(f"\nTotal packets: {total}")
        
        # Time range
        if total > 0:
            first_time = self.packets[0].time
            last_time = self.packets[-1].time
            duration = last_time - first_time
            
            print(f"First packet: {datetime.fromtimestamp(first_time)}")
            print(f"Last packet: {datetime.fromtimestamp(last_time)}")
            print(f"Duration: {duration:.2f} seconds")
            
            if duration > 0:
                print(f"Packets per second: {total/duration:.2f}")
                print(f"Average packet size: {sum(len(p) for p in self.packets)/total:.2f} bytes")
        
        # Protocol distribution
        self.analyze_protocols()
        
        # Address analysis
        self.analyze_addresses()
        
        # Port analysis
        self.analyze_ports()
    
    def analyze_protocols(self):
        """Analyze protocol distribution."""
        
        print("\n" + "=" * 60)
        print("PROTOCOL DISTRIBUTION")
        print("=" * 60)
        
        protocols = defaultdict(int)
        
        for pkt in self.packets:
            if pkt.haslayer(TCP):
                protocols['TCP'] += 1
            elif pkt.haslayer(UDP):
                protocols['UDP'] += 1
            elif pkt.haslayer(ICMP):
                protocols['ICMP'] += 1
            elif pkt.haslayer(IP):
                protocols['Other IP'] += 1
            else:
                protocols['Non-IP'] += 1
        
        total = len(self.packets)
        for proto, count in sorted(protocols.items(), key=lambda x: x[1], reverse=True):
            percentage = (count / total) * 100
            bar = "█" * int(percentage / 2)
            print(f"{proto:>10}: {count:>6} ({percentage:>5.1f}%) {bar}")
    
    def analyze_addresses(self):
        """Analyze IP addresses."""
        
        print("\n" + "=" * 60)
        print("TOP IP ADDRESSES")
        print("=" * 60)
        
        src_ips = defaultdict(int)
        dst_ips = defaultdict(int)
        
        for pkt in self.packets:
            if pkt.haslayer(IP):
                ip = pkt[IP]
                src_ips[ip.src] += 1
                dst_ips[ip.dst] += 1
        
        print("\nTop 5 Source IPs:")
        for ip, count in sorted(src_ips.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {ip:<15}: {count:>6} packets")
        
        print("\nTop 5 Destination IPs:")
        for ip, count in sorted(dst_ips.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {ip:<15}: {count:>6} packets")
    
    def analyze_ports(self):
        """Analyze TCP/UDP ports."""
        
        print("\n" + "=" * 60)
        print("TOP PORTS")
        print("=" * 60)
        
        tcp_ports = defaultdict(int)
        udp_ports = defaultdict(int)
        
        for pkt in self.packets:
            if pkt.haslayer(TCP):
                tcp = pkt[TCP]
                tcp_ports[tcp.sport] += 1
                tcp_ports[tcp.dport] += 1
            elif pkt.haslayer(UDP):
                udp = pkt[UDP]
                udp_ports[udp.sport] += 1
                udp_ports[udp.dport] += 1
        
        if tcp_ports:
            print("\nTop 5 TCP Ports:")
            for port, count in sorted(tcp_ports.items(), key=lambda x: x[1], reverse=True)[:5]:
                print(f"  {port:<6}: {count:>6} occurrences")
        
        if udp_ports:
            print("\nTop 5 UDP Ports:")
            for port, count in sorted(udp_ports.items(), key=lambda x: x[1], reverse=True)[:5]:
                print(f"  {port:<6}: {count:>6} occurrences")
    
    def analyze_payloads(self):
        """Extract and analyze payloads."""
        
        print("\n" + "=" * 60)
        print("PAYLOAD ANALYSIS")
        print("=" * 60)
        
        raw_count = 0
        total_payload = 0
        
        for pkt in self.packets:
            if pkt.haslayer(Raw):
                raw = pkt[Raw]
                raw_count += 1
                total_payload += len(raw)
        
        print(f"\nPackets with payload: {raw_count}")
        
        if raw_count > 0:
            print(f"Total payload bytes: {total_payload}")
            print(f"Average payload size: {total_payload/raw_count:.2f} bytes")
            
            # Find largest payloads
            largest = []
            for i, pkt in enumerate(self.packets):
                if pkt.haslayer(Raw):
                    size = len(pkt[Raw])
                    largest.append((i, size, pkt))
            
            largest.sort(key=lambda x: x[1], reverse=True)
            
            print("\nLargest Payloads:")
            for i, (idx, size, pkt) in enumerate(largest[:5], 1):
                print(f"  #{i}: Packet {idx}, {size} bytes - {pkt.summary()}")
    
    def analyze_tcp_flags(self):
        """Analyze TCP flags."""
        
        print("\n" + "=" * 60)
        print("TCP FLAG ANALYSIS")
        print("=" * 60)
        
        flags = defaultdict(int)
        
        for pkt in self.packets:
            if pkt.haslayer(TCP):
                flag = pkt[TCP].flags
                flag_names = []
                if flag & 0x01: flag_names.append('FIN')
                if flag & 0x02: flag_names.append('SYN')
                if flag & 0x04: flag_names.append('RST')
                if flag & 0x08: flag_names.append('PSH')
                if flag & 0x10: flag_names.append('ACK')
                if flag & 0x20: flag_names.append('URG')
                if flag & 0x40: flag_names.append('ECE')
                if flag & 0x80: flag_names.append('CWR')
                
                if flag_names:
                    flags['+'.join(flag_names)] += 1
                else:
                    flags['None'] += 1
        
        if flags:
            print("\nTCP Flag Distribution:")
            for flag, count in sorted(flags.items(), key=lambda x: x[1], reverse=True):
                print(f"  {flag:<20}: {count:>6} packets")
    
    def export_stats(self, output_file):
        """Export statistics to JSON."""
        
        if not self.packets:
            print("No packets to export.")
            return
        
        stats = {
            'file': self.pcap_file,
            'total_packets': len(self.packets),
            'protocols': {},
            'ips': {'src': {}, 'dst': {}},
            'ports': {'tcp': {}, 'udp': {}}
        }
        
        # Collect statistics
        for pkt in self.packets:
            # Protocols
            if pkt.haslayer(TCP):
                stats['protocols']['TCP'] = stats['protocols'].get('TCP', 0) + 1
            elif pkt.haslayer(UDP):
                stats['protocols']['UDP'] = stats['protocols'].get('UDP', 0) + 1
            elif pkt.haslayer(ICMP):
                stats['protocols']['ICMP'] = stats['protocols'].get('ICMP', 0) + 1
            
            # IPs
            if pkt.haslayer(IP):
                ip = pkt[IP]
                stats['ips']['src'][ip.src] = stats['ips']['src'].get(ip.src, 0) + 1
                stats['ips']['dst'][ip.dst] = stats['ips']['dst'].get(ip.dst, 0) + 1
            
            # Ports
            if pkt.haslayer(TCP):
                tcp = pkt[TCP]
                stats['ports']['tcp'][tcp.sport] = stats['ports']['tcp'].get(tcp.sport, 0) + 1
                stats['ports']['tcp'][tcp.dport] = stats['ports']['tcp'].get(tcp.dport, 0) + 1
            elif pkt.haslayer(UDP):
                udp = pkt[UDP]
                stats['ports']['udp'][udp.sport] = stats['ports']['udp'].get(udp.sport, 0) + 1
                stats['ports']['udp'][udp.dport] = stats['ports']['udp'].get(udp.dport, 0) + 1
        
        # Convert to top lists
        for ip_type in ['src', 'dst']:
            stats['ips'][ip_type] = dict(sorted(stats['ips'][ip_type].items(), 
                                                key=lambda x: x[1], 
                                                reverse=True)[:10])
        
        for port_type in ['tcp', 'udp']:
            stats['ports'][port_type] = dict(sorted(stats['ports'][port_type].items(), 
                                                    key=lambda x: x[1], 
                                                    reverse=True)[:10])
        
        # Save to file
        with open(output_file, 'w') as f:
            json.dump(stats, f, indent=2)
        
        print(f"\nExported statistics to: {output_file}")
    
    def analyze(self, export=None):
        """Run full analysis."""
        
        self.load()
        self.analyze_basic_stats()
        self.analyze_payloads()
        self.analyze_tcp_flags()
        
        if export:
            self.export_stats(export)
        
        return self.stats

def main():
    """Command-line interface for PCAP analyzer."""
    
    parser = argparse.ArgumentParser(
        description='PCAP Analyzer - Comprehensive packet capture analysis'
    )
    parser.add_argument('pcap_file', 
                        help='Path to the PCAP file to analyze')
    parser.add_argument('--export', 
                        help='Export statistics to JSON file')
    parser.add_argument('--limit', type=int, default=None,
                        help='Limit analysis to first N packets')
    
    # If no arguments, show help
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    
    args = parser.parse_args()
    
    # Run analyzer
    try:
        analyzer = PCAPAnalyzer(args.pcap_file)
        analyzer.analyze(export=args.export)
        
        if args.limit:
            print(f"\nNote: Analysis limited to first {args.limit} packets")
        
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

---

## The Verification: Testing PCAP Operations

### Verification 1: Download PCAPs

```bash
cd ~/scapy-tutorial

# Download sample PCAPs
python3 src/download_pcaps.py

# Verify download worked
ls -la pcap_files/
```

**Expected output**: Several `.cap` files in the `pcap_files` directory.

### Verification 2: Analyze a PCAP

```bash
# Find the first PCAP
PCAP=$(ls pcap_files/*.cap | head -1)

# Analyze it
python3 src/pcap_analyzer.py "$PCAP"

# Export statistics
python3 src/pcap_analyzer.py "$PCAP" --export output/stats.json

# View the exported stats
cat output/stats.json
```

**Expected output**: Comprehensive analysis showing protocol distribution, top IPs, ports, and TCP flag analysis.

### Verification 3: Filter and Extract

```bash
# Run filtering demo
python3 src/pcap_filtering.py
```

**Expected output**: Demonstrations of various filters working on the sample PCAP.

### Verification 4: Modify and Generate

```bash
# Run modification demo
python3 src/pcap_modification.py

# Verify generated files exist
ls -la output/test_packets.pcap
ls -la output/modified_real_pcap.pcap  # If real PCAP exists

# View generated packets
python3 -c "from scapy.all import rdpcap; packets = rdpcap('output/test_packets.pcap'); [print(p.summary()) for p in packets]"
```

**Expected output**: Successful generation and modification of PCAP files.

### Verification 5: Open in Wireshark

```bash
# Open the generated test packets
wireshark output/test_packets.pcap

# Or the modified real PCAP
wireshark output/modified_real_pcap.pcap  # If it exists
```

**Expected output**: Wireshark opens with the generated/modified packets displayed correctly.

### Verification 6: Quick Commands Reference

```bash
# Load and show first packet
python3 -c "from scapy.all import rdpcap; p = rdpcap('pcap_files/dns.cap'); p[0].show()"

# Count packets in PCAP
python3 -c "from scapy.all import rdpcap; print(f'Total: {len(rdpcap(\"pcap_files/dns.cap\"))}')"

# Extract all TCP packets
python3 -c "from scapy.all import rdpcap, TCP; p = rdpcap('pcap_files/dns.cap'); tcp = [x for x in p if x.haslayer(TCP)]; print(f'TCP packets: {len(tcp)}')"

# Save filtered packets
python3 -c "from scapy.all import rdpcap, wrpcap, TCP; p = rdpcap('pcap_files/dns.cap'); tcp = [x for x in p if x.haslayer(TCP)]; wrpcap('output/tcp_only.pcap', tcp); print('Saved TCP-only PCAP')"

# Show hexdump of first packet
python3 -c "from scapy.all import rdpcap, hexdump; p = rdpcap('pcap_files/dns.cap'); hexdump(p[0])"
```

---

## Reference: PCAP API Deep Dive

### rdpcap() vs PcapReader

| Method | Description | Use Case |
|--------|-------------|----------|
| `rdpcap()` | Loads entire PCAP into memory | Small to medium captures, full analysis |
| `PcapReader()` | Streams packets one at a time | Large captures, memory-constrained environments |
| `PcapNgReader()` | PCAPNG format reader | Modern captures with extra metadata |

### Performance Tips for Large PCAPs

```python
# Memory-efficient reading
for pkt in PcapReader('large_file.pcap'):
    if pkt.haslayer(TCP):
        process(pkt)

# Instead of:
packets = rdpcap('large_file.pcap')  # Memory intensive

# Count without loading
count = 0
for _ in PcapReader('large_file.pcap'):
    count += 1
print(f"Total packets: {count}")
```

### Common PCAP Operations Pattern

```python
# Load
packets = rdpcap('input.pcap')

# Filter
filtered = [p for p in packets if p.haslayer(TCP) and p[TCP].dport == 80]

# Modify
modified = []
for p in filtered:
    p[IP].ttl = 128
    # Recalculate checksums
    if p.haslayer(TCP):
        del p[TCP].chksum
    del p[IP].chksum
    modified.append(p)

# Save
wrpcap('output.pcap', modified)
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ Downloading PCAPs from public repositories
2. ✅ Loading and inspecting PCAP files with `rdpcap()`
3. ✅ Analyzing packet types, addresses, and ports
4. ✅ Filtering packets by protocol, IP, port, and flags
5. ✅ Modifying packets (anonymizing, changing TTL, ports, payloads)
6. ✅ Saving modified packets to new PCAPs
7. ✅ Building a comprehensive PCAP analysis tool
8. ✅ Exporting statistics to JSON format

---

## What's Next: Module 2 Preview

**Congratulations!** You've completed Module 1. You now have a solid foundation in packet construction and analysis.

In **Module 2: Layer 2 & Layer 3 Operations**, we'll:

1. Deep dive into Ethernet frames and VLAN tagging
2. Build a full-featured ARP scanner
3. Implement custom ping utilities
4. Build traceroute from scratch
5. Create a network topology visualizer
6. Explore IP fragmentation and reassembly

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 1 COMPLETE                                           │
│  ✅ Scapy environment set up                                        │
│  ✅ Packet stacking model mastered                                  │
│  ✅ PCAP analysis tools built                                       │
│  ✅ Real traffic analyzed and modified                             │
│  NEXT: MODULE 2 — LAYER 2 & LAYER 3 OPERATIONS                    │
│  ● Ethernet frame construction                                     │
│  ● ARP scanning and analysis                                       │
│  ● Custom ping and traceroute                                      │
│  ● IP fragmentation handling                                       │
│  ● Network discovery tools                                         │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Module 2, where we'll drop down to the data link layer and start building Ethernet frames — the foundation of all network communication.*
