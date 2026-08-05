# Mastering Network Packet Crafting with Scapy
## Module 4: Packet Sniffing, Filtering & Traffic Analysis
### Part 1: Real-Time Packet Sniffing and Filtering

## The Target: Building Professional Packet Sniffers

In this part, we'll build production-grade packet sniffing and filtering tools. By the end, you'll be able to:

1. Implement real-time packet capture with Scapy's `sniff()`
2. Master Berkeley Packet Filter (BPF) syntax
3. Build custom callback functions for packet processing
4. Create protocol-specific filters
5. Implement efficient packet processing pipelines
6. Build a comprehensive packet sniffer with live display

---

## The Concept: Sniffing as Network Eavesdropping

Think of packet sniffing as **eavesdropping on network conversations**:

- **Passive capture**: Like listening to a radio channel—you hear everything within range
- **Promiscuous mode**: Like having a radio that can pick up all channels simultaneously
- **BPF filters**: Like setting your radio to only listen to specific frequencies
- **Callbacks**: Like having a notebook to record only what interests you

```
Network Traffic (All Packets)
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│                   PROMISCUOUS MODE                      │
│                (Capture all packets)                    │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│                   BPF FILTER                            │
│              "tcp port 80"                             │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│              CALLBACK FUNCTION                          │
│         Process only HTTP packets                      │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│              OUTPUT / STORAGE                           │
│         Display, save, analyze packets                 │
└─────────────────────────────────────────────────────────┘
```

**Key insight**: Efficient sniffing is all about filtering early and processing fast. You want to discard irrelevant packets as early as possible to minimize processing overhead.

---

## The Implementation: Building Sniffers and Filters

### Step 1: Basic Packet Sniffer

Create `src/basic_sniffer.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 1: Basic Packet Sniffer

This script demonstrates basic packet sniffing with Scapy,
including various filtering techniques and callback handlers.
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP, Ether, Raw
from scapy.all import conf, get_if_list, get_if_hwaddr
import time
import sys
import os
from datetime import datetime
from collections import defaultdict

class BasicSniffer:
    """
    Basic packet sniffer with various filtering capabilities.
    
    Features:
    - Live packet capture
    - BPF filtering
    - Protocol filtering
    - Packet counting and statistics
    - Timestamp tracking
    - Output formatting
    """
    
    def __init__(self, interface=None, filter_str=None, count=0, timeout=None):
        """
        Initialize the sniffer.
        
        Args:
            interface: Network interface to sniff on
            filter_str: BPF filter string (e.g., "tcp port 80")
            count: Number of packets to capture (0 for unlimited)
            timeout: Stop after N seconds (None for indefinite)
        """
        self.interface = interface or conf.iface
        self.filter_str = filter_str
        self.count = count
        self.timeout = timeout
        
        self.packet_count = 0
        self.start_time = None
        self.end_time = None
        self.packets = []
        self.stats = {
            'total': 0,
            'tcp': 0,
            'udp': 0,
            'icmp': 0,
            'other_ip': 0,
            'non_ip': 0,
            'bytes': 0,
            'protocols': defaultdict(int)
        }
        
        print(f"\n[SNIFFER] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Filter: {self.filter_str or 'None'}")
        print(f"  Count: {self.count if self.count > 0 else 'Unlimited'}")
        print(f"  Timeout: {self.timeout if self.timeout else 'None'}")
    
    def packet_callback(self, packet):
        """
        Callback function for each captured packet.
        
        Args:
            packet: The captured Scapy packet
        """
        self.packet_count += 1
        self.stats['total'] += 1
        self.stats['bytes'] += len(packet)
        
        # Classify packet by protocol
        if packet.haslayer(TCP):
            self.stats['tcp'] += 1
            self.stats['protocols']['TCP'] += 1
            self.handle_tcp_packet(packet)
        elif packet.haslayer(UDP):
            self.stats['udp'] += 1
            self.stats['protocols']['UDP'] += 1
            self.handle_udp_packet(packet)
        elif packet.haslayer(ICMP):
            self.stats['icmp'] += 1
            self.stats['protocols']['ICMP'] += 1
            self.handle_icmp_packet(packet)
        elif packet.haslayer(IP):
            self.stats['other_ip'] += 1
            self.stats['protocols']['Other_IP'] += 1
        else:
            self.stats['non_ip'] += 1
            self.stats['protocols']['Non_IP'] += 1
        
        # Display packet info
        self.display_packet(packet)
        
        # Store packet if within limits
        if len(self.packets) < 100:  # Keep last 100 packets
            self.packets.append(packet)
        
        # Stop condition
        if self.count > 0 and self.packet_count >= self.count:
            raise KeyboardInterrupt  # Stop sniffing
    
    def handle_tcp_packet(self, packet):
        """Handle TCP packets specifically."""
        tcp = packet[TCP]
        
        # Detect SYN packets (connection attempts)
        if tcp.flags & 0x02:  # SYN flag
            if tcp.flags & 0x10:  # SYN-ACK
                print(f"  [!] SYN-ACK from {packet[IP].src}:{tcp.sport} to {packet[IP].dst}:{tcp.dport}")
            else:
                print(f"  [!] SYN from {packet[IP].src}:{tcp.sport} to {packet[IP].dst}:{tcp.dport}")
        
        # Detect RST packets (connection resets)
        if tcp.flags & 0x04:  # RST flag
            print(f"  [!] RST from {packet[IP].src}:{tcp.sport} to {packet[IP].dst}:{tcp.dport}")
    
    def handle_udp_packet(self, packet):
        """Handle UDP packets specifically."""
        udp = packet[UDP]
        
        # Check for DNS (port 53)
        if udp.sport == 53 or udp.dport == 53:
            print(f"  [DNS] {packet[IP].src}:{udp.sport} -> {packet[IP].dst}:{udp.dport}")
    
    def handle_icmp_packet(self, packet):
        """Handle ICMP packets specifically."""
        icmp = packet[ICMP]
        
        icmp_types = {
            0: "Echo Reply",
            3: "Destination Unreachable",
            8: "Echo Request",
            11: "Time Exceeded"
        }
        type_name = icmp_types.get(icmp.type, f"Type {icmp.type}")
        print(f"  [ICMP] {type_name} from {packet[IP].src} to {packet[IP].dst}")
    
    def display_packet(self, packet):
        """Display packet information with timestamp."""
        timestamp = datetime.fromtimestamp(packet.time).strftime('%H:%M:%S.%f')[:-3]
        
        # Basic packet summary
        if self.packet_count % 10 == 0:  # Show every 10th packet
            summary = packet.summary()
            print(f"[{timestamp}] #{self.packet_count}: {summary}")
    
    def get_stats(self):
        """Get current statistics."""
        total_time = self.end_time - self.start_time if self.end_time and self.start_time else 0
        
        stats = {
            'packets': self.stats,
            'duration': total_time,
            'packets_per_second': self.stats['total'] / total_time if total_time > 0 else 0,
            'bytes_per_second': self.stats['bytes'] / total_time if total_time > 0 else 0
        }
        
        return stats
    
    def start_sniffing(self):
        """Start the packet sniffing process."""
        
        print("\n" + "=" * 60)
        print("STARTING PACKET SNIFFER")
        print("=" * 60)
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        
        try:
            # Start sniffing
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self.packet_callback,
                count=self.count if self.count > 0 else None,
                timeout=self.timeout,
                store=False  # Don't store in memory
            )
        
        except KeyboardInterrupt:
            print("\n\nStopping sniffer...")
        except Exception as e:
            print(f"\nError during sniffing: {e}")
        finally:
            self.end_time = time.time()
            self.display_summary()
    
    def display_summary(self):
        """Display sniffing summary."""
        
        stats = self.get_stats()
        
        print("\n" + "=" * 60)
        print("SNIFFING SUMMARY")
        print("=" * 60)
        print(f"Duration: {stats['duration']:.2f} seconds")
        print(f"Total packets: {stats['packets']['total']}")
        print(f"Packets/sec: {stats['packets_per_second']:.2f}")
        print(f"Bytes/sec: {stats['bytes_per_second']:.2f}")
        print(f"Total bytes: {stats['packets']['bytes']:,}")
        
        print("\nProtocol Distribution:")
        print("-" * 40)
        for protocol, count in sorted(stats['packets']['protocols'].items(), 
                                     key=lambda x: x[1], reverse=True):
            percentage = (count / stats['packets']['total']) * 100 if stats['packets']['total'] > 0 else 0
            bar = "█" * int(percentage / 2)
            print(f"  {protocol:<10}: {count:>6} ({percentage:>5.1f}%) {bar}")
        
        print("\nTCP Flag Detection:")
        print("-" * 40)
        # Count special TCP packets from stored packets
        syn_count = 0
        syn_ack_count = 0
        rst_count = 0
        fin_count = 0
        
        for packet in self.packets:
            if packet.haslayer(TCP):
                tcp = packet[TCP]
                if tcp.flags & 0x02:  # SYN
                    if tcp.flags & 0x10:  # SYN-ACK
                        syn_ack_count += 1
                    else:
                        syn_count += 1
                if tcp.flags & 0x04:  # RST
                    rst_count += 1
                if tcp.flags & 0x01:  # FIN
                    fin_count += 1
        
        print(f"  SYN packets: {syn_count}")
        print(f"  SYN-ACK packets: {syn_ack_count}")
        print(f"  RST packets: {rst_count}")
        print(f"  FIN packets: {fin_count}")
        
        print("\n" + "=" * 60)
        print("SNIFFER COMPLETE")
        print("=" * 60)

def main():
    """Main function for basic sniffer."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Basic Packet Sniffer')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-f', '--filter', help='BPF filter (e.g., "tcp port 80")')
    parser.add_argument('-c', '--count', type=int, default=0,
                        help='Number of packets to capture')
    parser.add_argument('-t', '--timeout', type=int,
                        help='Stop after N seconds')
    
    args = parser.parse_args()
    
    # If no interface specified, try to find one
    if not args.interface:
        interfaces = get_if_list()
        # Filter out loopback and choose first non-loopback
        for iface in interfaces:
            if iface != 'lo' and iface != 'Loopback Pseudo-Interface 1':
                args.interface = iface
                break
        if not args.interface:
            args.interface = interfaces[0] if interfaces else 'eth0'
    
    # Check for root privileges
    if os.geteuid() != 0:
        print("Warning: Sniffing may require root privileges")
        print("Try running with: sudo python3 src/basic_sniffer.py")
    
    # Create and start sniffer
    sniffer = BasicSniffer(
        interface=args.interface,
        filter_str=args.filter,
        count=args.count,
        timeout=args.timeout
    )
    
    sniffer.start_sniffing()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("BASIC PACKET SNIFFER")
        print("=" * 60)
        print("\nStarting interactive sniffer...")
        
        # Show available interfaces
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            try:
                mac = get_if_hwaddr(iface)
                print(f"  {i+1}. {iface} ({mac})")
            except:
                print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number (or press Enter for default): ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        filter_str = input("BPF filter (e.g., 'tcp port 80', press Enter for none): ").strip()
        filter_str = filter_str if filter_str else None
        
        sniffer = BasicSniffer(interface=interface, filter_str=filter_str)
        sniffer.start_sniffing()
    else:
        main()
```

### Step 2: Advanced BPF Filtering

Create `src/bpf_filters.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 1: BPF Filter Examples

This script demonstrates various BPF filters for packet capture
with practical examples and explanations.
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP, Ether
import time
import sys

class BPFFilterDemo:
    """
    Demonstration of BPF filter expressions.
    
    BPF (Berkeley Packet Filter) allows filtering packets at the kernel level,
    making capture highly efficient.
    """
    
    def __init__(self):
        """Initialize BPF filter demo."""
        self.filters = {
            'all': {
                'filter': None,
                'description': 'Capture all packets'
            },
            'tcp_traffic': {
                'filter': 'tcp',
                'description': 'TCP packets only'
            },
            'udp_traffic': {
                'filter': 'udp',
                'description': 'UDP packets only'
            },
            'icmp_traffic': {
                'filter': 'icmp',
                'description': 'ICMP packets only'
            },
            'http_traffic': {
                'filter': 'tcp port 80',
                'description': 'HTTP traffic (port 80)'
            },
            'https_traffic': {
                'filter': 'tcp port 443',
                'description': 'HTTPS traffic (port 443)'
            },
            'dns_traffic': {
                'filter': 'udp port 53',
                'description': 'DNS traffic (port 53)'
            },
            'ssh_traffic': {
                'filter': 'tcp port 22',
                'description': 'SSH traffic (port 22)'
            },
            'dhcp_traffic': {
                'filter': 'udp port 67 or udp port 68',
                'description': 'DHCP traffic (ports 67-68)'
            },
            'web_traffic': {
                'filter': 'tcp port 80 or tcp port 443',
                'description': 'Web traffic (HTTP + HTTPS)'
            },
            'from_ip': {
                'filter': 'src host 192.168.1.1',
                'description': 'Traffic from 192.168.1.1'
            },
            'to_ip': {
                'filter': 'dst host 192.168.1.1',
                'description': 'Traffic to 192.168.1.1'
            },
            'between_ips': {
                'filter': 'host 192.168.1.1 and host 192.168.1.2',
                'description': 'Traffic between two IPs'
            },
            'specific_subnet': {
                'filter': 'net 192.168.0.0/16',
                'description': 'Traffic to/from 192.168.x.x'
            },
            'syn_packets': {
                'filter': 'tcp[13] & 0x02 != 0',
                'description': 'TCP SYN packets only'
            },
            'ack_packets': {
                'filter': 'tcp[13] & 0x10 != 0',
                'description': 'TCP ACK packets only'
            },
            'rst_packets': {
                'filter': 'tcp[13] & 0x04 != 0',
                'description': 'TCP RST packets only'
            },
            'fin_packets': {
                'filter': 'tcp[13] & 0x01 != 0',
                'description': 'TCP FIN packets only'
            },
            'syn_ack_packets': {
                'filter': 'tcp[13] & 0x12 != 0',
                'description': 'TCP SYN-ACK packets only'
            },
            'tcp_no_ack': {
                'filter': 'tcp[13] & 0x10 = 0 and tcp[13] & 0x02 != 0',
                'description': 'TCP packets without ACK (including SYN)'
            },
            'large_packets': {
                'filter': 'greater 1000',
                'description': 'Packets larger than 1000 bytes'
            },
            'small_packets': {
                'filter': 'less 64',
                'description': 'Packets smaller than 64 bytes'
            },
            'broadcast': {
                'filter': 'ether dst ff:ff:ff:ff:ff:ff',
                'description': 'Broadcast packets'
            },
            'multicast': {
                'filter': 'ether dst 01:00:5e:00:00:00/24',
                'description': 'Multicast packets'
            },
            'not_arp': {
                'filter': 'not arp',
                'description': 'All packets except ARP'
            },
            'not_icmp': {
                'filter': 'not icmp',
                'description': 'All packets except ICMP'
            }
        }
    
    def explain_filters(self):
        """Display all filter examples."""
        
        print("\n" + "=" * 60)
        print("BPF FILTER REFERENCE")
        print("=" * 60 + "\n")
        
        categories = {
            'Protocol-based': ['tcp_traffic', 'udp_traffic', 'icmp_traffic'],
            'Port-based': ['http_traffic', 'https_traffic', 'dns_traffic', 
                          'ssh_traffic', 'dhcp_traffic', 'web_traffic'],
            'Host-based': ['from_ip', 'to_ip', 'between_ips', 'specific_subnet'],
            'TCP Flag-based': ['syn_packets', 'ack_packets', 'rst_packets', 
                              'fin_packets', 'syn_ack_packets', 'tcp_no_ack'],
            'Size-based': ['large_packets', 'small_packets'],
            'Layer 2-based': ['broadcast', 'multicast'],
            'Negations': ['not_arp', 'not_icmp']
        }
        
        for category, filter_list in categories.items():
            print(f"\n{category}:")
            print("-" * 40)
            for key in filter_list:
                if key in self.filters:
                    info = self.filters[key]
                    print(f"  {info['filter']:<30} - {info['description']}")
    
    def demonstrate_filter(self, filter_name, packet_count=5, timeout=5):
        """
        Demonstrate a specific BPF filter by capturing packets.
        
        Args:
            filter_name: Key from self.filters
            packet_count: Number of packets to capture
            timeout: Timeout in seconds
        """
        if filter_name not in self.filters:
            print(f"Filter '{filter_name}' not found")
            return
        
        filter_info = self.filters[filter_name]
        filter_str = filter_info['filter']
        
        print("\n" + "=" * 60)
        print(f"DEMONSTRATING FILTER: {filter_info['description']}")
        print("=" * 60)
        print(f"Filter expression: {filter_str}")
        print(f"Capturing {packet_count} packets (timeout: {timeout}s)...")
        print("-" * 40)
        
        # Counter for callback
        captured = {'count': 0}
        
        def callback(packet):
            captured['count'] += 1
            timestamp = time.strftime('%H:%M:%S')
            print(f"[{timestamp}] {packet.summary()}")
        
        try:
            sniff(
                filter=filter_str,
                prn=callback,
                count=packet_count,
                timeout=timeout,
                store=False
            )
        except Exception as e:
            print(f"Error during sniffing: {e}")
        
        print(f"\nCaptured {captured['count']} packets")
        print("=" * 60)
    
    def interactive_demo(self):
        """Interactive filter demonstration."""
        
        self.explain_filters()
        
        print("\n" + "=" * 60)
        print("INTERACTIVE FILTER DEMONSTRATION")
        print("=" * 60)
        print("\nChoose a filter to demonstrate:")
        
        # Show numbered list
        filter_items = list(self.filters.items())
        for i, (key, info) in enumerate(filter_items, 1):
            print(f"  {i:2}. {key:<20} - {info['description']}")
        
        print(f"  {len(filter_items) + 1:2}. Demo a custom filter")
        print(f"  {len(filter_items) + 2:2}. Exit")
        
        while True:
            choice = input(f"\nSelect filter (1-{len(filter_items) + 2}): ").strip()
            
            try:
                choice_num = int(choice)
                if choice_num == len(filter_items) + 2:
                    break
                elif choice_num == len(filter_items) + 1:
                    custom_filter = input("Enter custom BPF filter: ").strip()
                    if custom_filter:
                        print(f"\nUsing custom filter: {custom_filter}")
                        count = input("Number of packets to capture (default: 5): ").strip()
                        count = int(count) if count else 5
                        self.demonstrate_custom_filter(custom_filter, count)
                    continue
                elif 1 <= choice_num <= len(filter_items):
                    key = filter_items[choice_num - 1][0]
                    count = input("Number of packets to capture (default: 5): ").strip()
                    count = int(count) if count else 5
                    self.demonstrate_filter(key, count)
                else:
                    print("Invalid choice")
            except ValueError:
                print("Please enter a valid number")
    
    def demonstrate_custom_filter(self, filter_str, packet_count=5):
        """Demonstrate a custom BPF filter."""
        print("\n" + "=" * 60)
        print("CUSTOM FILTER DEMONSTRATION")
        print("=" * 60)
        print(f"Filter: {filter_str}")
        print("-" * 40)
        
        captured = {'count': 0}
        
        def callback(packet):
            captured['count'] += 1
            timestamp = time.strftime('%H:%M:%S')
            print(f"[{timestamp}] {packet.summary()}")
        
        try:
            sniff(
                filter=filter_str,
                prn=callback,
                count=packet_count,
                timeout=5,
                store=False
            )
        except Exception as e:
            print(f"Error: {e}")
        
        print(f"\nCaptured {captured['count']} packets")

def main():
    """Main function for BPF filter demo."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='BPF Filter Examples')
    parser.add_argument('-l', '--list', action='store_true',
                        help='List all available filters')
    parser.add_argument('-d', '--demo', help='Filter name to demonstrate')
    parser.add_argument('-c', '--count', type=int, default=5,
                        help='Number of packets to capture')
    parser.add_argument('-f', '--filter', help='Custom BPF filter')
    
    args = parser.parse_args()
    
    demo = BPFFilterDemo()
    
    if args.list:
        demo.explain_filters()
    elif args.demo:
        demo.demonstrate_filter(args.demo, args.count)
    elif args.filter:
        demo.demonstrate_custom_filter(args.filter, args.count)
    else:
        demo.interactive_demo()

if __name__ == "__main__":
    main()
```

### Step 3: Protocol-Specific Analyzer

Create `src/protocol_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 1: Protocol-Specific Analyzer

This script provides deep packet analysis for specific protocols
including HTTP, DNS, DHCP, and more.
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP, Ether, Raw
from scapy.all import DNS, DNSQR, DNSRR, DHCP, BOOTP
from scapy.all import conf, get_if_list
import time
import sys
import json
from datetime import datetime
from collections import defaultdict

class ProtocolAnalyzer:
    """
    Protocol-specific packet analyzer.
    
    Features:
    - HTTP request/response analysis
    - DNS query/response tracking
    - DHCP DORA sequence detection
    - ARP request/reply analysis
    - TLS handshake detection
    - Flow reconstruction
    """
    
    def __init__(self, interface=None, filter_str=None):
        """
        Initialize protocol analyzer.
        
        Args:
            interface: Network interface
            filter_str: BPF filter
        """
        self.interface = interface or conf.iface
        self.filter_str = filter_str
        
        self.packet_count = 0
        self.start_time = None
        
        # Protocol-specific storage
        self.http_requests = []
        self.http_responses = []
        self.dns_queries = []
        self.dns_responses = []
        self.dhcp_packets = []
        self.arp_packets = []
        self.tls_packets = []
        
        # Flow tracking
        self.flows = defaultdict(lambda: {'packets': 0, 'bytes': 0})
        
        print(f"\n[ANALYZER] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Filter: {self.filter_str or 'None'}")
    
    def analyze_http(self, packet):
        """Analyze HTTP traffic."""
        if not packet.haslayer(Raw):
            return
        
        try:
            payload = bytes(packet[Raw])
            # Try to decode as HTTP
            try:
                http_data = payload.decode('utf-8', errors='ignore')
            except:
                return
            
            # Check if it's an HTTP request
            if http_data.startswith(('GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS')):
                # Extract first line
                lines = http_data.split('\r\n')
                if lines:
                    request_line = lines[0]
                    print(f"\n[HTTP] Request: {request_line}")
                    
                    # Extract host
                    for line in lines:
                        if line.lower().startswith('host:'):
                            host = line.split(':', 1)[1].strip()
                            print(f"  Host: {host}")
                            break
                    
                    self.http_requests.append({
                        'timestamp': datetime.fromtimestamp(packet.time),
                        'src': packet[IP].src,
                        'dst': packet[IP].dst,
                        'request': request_line,
                        'data': http_data[:500]  # Truncate
                    })
            
            # Check if it's an HTTP response
            elif http_data.startswith('HTTP/'):
                lines = http_data.split('\r\n')
                if lines:
                    status_line = lines[0]
                    print(f"\n[HTTP] Response: {status_line}")
                    
                    # Extract status code
                    parts = status_line.split(' ')
                    if len(parts) >= 3:
                        status_code = parts[1]
                        status_text = ' '.join(parts[2:])
                        print(f"  Status: {status_code} - {status_text}")
                    
                    self.http_responses.append({
                        'timestamp': datetime.fromtimestamp(packet.time),
                        'src': packet[IP].src,
                        'dst': packet[IP].dst,
                        'status': status_line,
                        'data': http_data[:500]
                    })
        
        except Exception as e:
            pass
    
    def analyze_dns(self, packet):
        """Analyze DNS traffic."""
        if not packet.haslayer(DNS):
            return
        
        dns = packet[DNS]
        
        # Check for queries
        if dns.qr == 0:  # Query
            if dns.qd:
                query_name = dns.qd.qname.decode('utf-8') if dns.qd.qname else 'Unknown'
                query_type = dns.qd.qtype
                
                print(f"\n[DNS] Query: {query_name} (Type: {query_type})")
                
                self.dns_queries.append({
                    'timestamp': datetime.fromtimestamp(packet.time),
                    'src': packet[IP].src,
                    'dst': packet[IP].dst,
                    'name': query_name,
                    'type': query_type
                })
        
        # Check for responses
        elif dns.qr == 1:  # Response
            answers = []
            if dns.an:
                for answer in dns.an:
                    if isinstance(answer, DNSRR):
                        ans_name = answer.rrname.decode('utf-8') if answer.rrname else 'Unknown'
                        ans_data = answer.rdata
                        answers.append(f"{ans_name} -> {ans_data}")
            
            if answers:
                print(f"\n[DNS] Response: {', '.join(answers)}")
                
                self.dns_responses.append({
                    'timestamp': datetime.fromtimestamp(packet.time),
                    'src': packet[IP].src,
                    'dst': packet[IP].dst,
                    'answers': answers
                })
    
    def analyze_dhcp(self, packet):
        """Analyze DHCP traffic."""
        if not packet.haslayer(DHCP):
            return
        
        dhcp = packet[DHCP]
        bootp = packet[BOOTP]
        
        # Extract DHCP options
        options = {}
        for option in dhcp.options:
            if isinstance(option, tuple) and len(option) == 2:
                options[option[0]] = option[1]
        
        dhcp_type = options.get('message-type', 'Unknown')
        
        msg_types = {
            1: 'DISCOVER',
            2: 'OFFER',
            3: 'REQUEST',
            4: 'DECLINE',
            5: 'ACK',
            6: 'NAK',
            7: 'RELEASE',
            8: 'INFORM'
        }
        type_name = msg_types.get(dhcp_type, f'Type {dhcp_type}')
        
        print(f"\n[DHCP] {type_name} from {packet[IP].src} to {packet[IP].dst}")
        print(f"  Client MAC: {bootp.chaddr}")
        if 'server_id' in options:
            print(f"  Server ID: {options['server_id']}")
        if 'router' in options:
            print(f"  Gateway: {options['router']}")
        if 'subnet_mask' in options:
            print(f"  Subnet: {options['subnet_mask']}")
        
        self.dhcp_packets.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'src': packet[IP].src,
            'dst': packet[IP].dst,
            'type': type_name,
            'options': options
        })
    
    def analyze_arp(self, packet):
        """Analyze ARP traffic."""
        if not packet.haslayer(ARP):
            return
        
        arp = packet[ARP]
        
        if arp.op == 1:  # Request
            print(f"\n[ARP] Request: Who has {arp.pdst}? Tell {arp.psrc}")
        elif arp.op == 2:  # Reply
            print(f"\n[ARP] Reply: {arp.psrc} is at {arp.hwsrc}")
        
        self.arp_packets.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'src': packet[IP].src if packet.haslayer(IP) else 'N/A',
            'op': 'Request' if arp.op == 1 else 'Reply',
            'psrc': arp.psrc,
            'pdst': arp.pdst,
            'hwsrc': arp.hwsrc
        })
    
    def analyze_tls(self, packet):
        """Analyze TLS traffic."""
        if not packet.haslayer(TCP) or not packet.haslayer(Raw):
            return
        
        tcp = packet[TCP]
        
        # Check for TLS on port 443 or other common TLS ports
        if tcp.dport in [443, 465, 993, 995] or tcp.sport in [443, 465, 993, 995]:
            try:
                payload = bytes(packet[Raw])
                if len(payload) > 0:
                    # Check for TLS handshake
                    if payload[0] == 0x16:  # TLS Handshake
                        print(f"\n[TLS] Handshake detected: {packet[IP].src}:{tcp.sport} -> {packet[IP].dst}:{tcp.dport}")
                        self.tls_packets.append({
                            'timestamp': datetime.fromtimestamp(packet.time),
                            'src': packet[IP].src,
                            'dst': packet[IP].dst,
                            'data': payload[:100]
                        })
            except:
                pass
    
    def packet_callback(self, packet):
        """Main packet callback for analysis."""
        
        self.packet_count += 1
        
        # Track flows
        if packet.haslayer(IP):
            ip = packet[IP]
            if packet.haslayer(TCP):
                tcp = packet[TCP]
                flow_key = f"{ip.src}:{tcp.sport}->{ip.dst}:{tcp.dport}"
            elif packet.haslayer(UDP):
                udp = packet[UDP]
                flow_key = f"{ip.src}:{udp.sport}->{ip.dst}:{udp.dport}"
            else:
                flow_key = f"{ip.src}->{ip.dst}"
            
            self.flows[flow_key]['packets'] += 1
            self.flows[flow_key]['bytes'] += len(packet)
        
        # Analyze by protocol
        if packet.haslayer(IP):
            # DNS (port 53)
            if packet.haslayer(UDP) and (packet[UDP].sport == 53 or packet[UDP].dport == 53):
                self.analyze_dns(packet)
            
            # DHCP (ports 67, 68)
            if packet.haslayer(UDP) and (packet[UDP].sport in [67, 68] or packet[UDP].dport in [67, 68]):
                self.analyze_dhcp(packet)
            
            # HTTP (port 80)
            if packet.haslayer(TCP) and (packet[TCP].sport == 80 or packet[TCP].dport == 80):
                self.analyze_http(packet)
            
            # HTTPS/TLS (port 443)
            if packet.haslayer(TCP) and (packet[TCP].sport == 443 or packet[TCP].dport == 443):
                self.analyze_tls(packet)
        
        # ARP
        if packet.haslayer(ARP):
            self.analyze_arp(packet)
        
        # Display progress
        if self.packet_count % 50 == 0:
            timestamp = datetime.fromtimestamp(packet.time).strftime('%H:%M:%S')
            print(f"[{timestamp}] Processed {self.packet_count} packets...")
    
    def start_analysis(self):
        """Start packet analysis."""
        
        print("\n" + "=" * 60)
        print("STARTING PROTOCOL ANALYSIS")
        print("=" * 60)
        print("Analyzing: HTTP, DNS, DHCP, ARP, TLS")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        
        try:
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self.packet_callback,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping analysis...")
        except Exception as e:
            print(f"Error during analysis: {e}")
        finally:
            self.display_summary()
    
    def display_summary(self):
        """Display analysis summary."""
        
        elapsed = time.time() - self.start_time
        
        print("\n" + "=" * 60)
        print("PROTOCOL ANALYSIS SUMMARY")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f} seconds")
        print(f"Total packets: {self.packet_count}")
        print("-" * 60)
        
        print("\nProtocol Statistics:")
        print("-" * 40)
        print(f"  HTTP Requests: {len(self.http_requests)}")
        print(f"  HTTP Responses: {len(self.http_responses)}")
        print(f"  DNS Queries: {len(self.dns_queries)}")
        print(f"  DNS Responses: {len(self.dns_responses)}")
        print(f"  DHCP Packets: {len(self.dhcp_packets)}")
        print(f"  ARP Packets: {len(self.arp_packets)}")
        print(f"  TLS Handshakes: {len(self.tls_packets)}")
        
        print("\nTop Flows:")
        print("-" * 40)
        for flow, data in sorted(self.flows.items(), 
                                 key=lambda x: x[1]['packets'], 
                                 reverse=True)[:10]:
            print(f"  {flow}: {data['packets']} packets, {data['bytes']:,} bytes")
        
        print("\n" + "=" * 60)
        print("ANALYSIS COMPLETE")
        print("=" * 60)

def main():
    """Main function for protocol analyzer."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Protocol Analyzer')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-f', '--filter', help='BPF filter')
    
    args = parser.parse_args()
    
    if not args.interface:
        interfaces = get_if_list()
        for iface in interfaces:
            if iface != 'lo' and iface != 'Loopback Pseudo-Interface 1':
                args.interface = iface
                break
        if not args.interface:
            args.interface = interfaces[0] if interfaces else 'eth0'
    
    analyzer = ProtocolAnalyzer(
        interface=args.interface,
        filter_str=args.filter
    )
    
    analyzer.start_analysis()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("PROTOCOL ANALYZER")
        print("=" * 60)
        
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            try:
                mac = get_if_hwaddr(iface)
                print(f"  {i+1}. {iface} ({mac})")
            except:
                print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        analyzer = ProtocolAnalyzer(interface=interface)
        analyzer.start_analysis()
    else:
        main()
```

### Step 4: Live Traffic Dashboard

Create `src/traffic_dashboard.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 1: Live Traffic Dashboard

This script creates a live traffic dashboard with:
- Real-time packet rate display
- Protocol distribution
- Top talkers
- Live updates
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP, Ether
from scapy.all import conf, get_if_list
import time
import sys
import threading
from datetime import datetime
from collections import defaultdict, deque
import os

class TrafficDashboard:
    """
    Live traffic dashboard with real-time statistics.
    
    Features:
    - Real-time packet rate monitoring
    - Protocol distribution charts
    - Top talkers (IP addresses)
    - Top ports
    - Live updates
    """
    
    def __init__(self, interface=None, filter_str=None, refresh_rate=1):
        """
        Initialize traffic dashboard.
        
        Args:
            interface: Network interface
            filter_str: BPF filter
            refresh_rate: Refresh rate in seconds
        """
        self.interface = interface or conf.iface
        self.filter_str = filter_str
        self.refresh_rate = refresh_rate
        
        # Statistics
        self.packet_count = 0
        self.byte_count = 0
        self.start_time = None
        
        # Rolling windows for rate calculation
        self.packet_history = deque(maxlen=10)
        self.byte_history = deque(maxlen=10)
        
        # Protocol distribution
        self.protocols = defaultdict(int)
        self.protocol_bytes = defaultdict(int)
        
        # Top talkers
        self.src_ips = defaultdict(int)
        self.dst_ips = defaultdict(int)
        self.src_bytes = defaultdict(int)
        self.dst_bytes = defaultdict(int)
        
        # Top ports
        self.src_ports = defaultdict(int)
        self.dst_ports = defaultdict(int)
        self.src_port_bytes = defaultdict(int)
        self.dst_port_bytes = defaultdict(int)
        
        # Flow tracking
        self.flows = defaultdict(lambda: {'packets': 0, 'bytes': 0})
        
        # Running state
        self.running = True
        
        # Lock for thread safety
        self.stats_lock = threading.Lock()
        
        print(f"\n[DASHBOARD] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Filter: {self.filter_str or 'None'}")
        print(f"  Refresh rate: {self.refresh_rate}s")
    
    def packet_callback(self, packet):
        """Process each packet and update statistics."""
        
        with self.stats_lock:
            self.packet_count += 1
            self.byte_count += len(packet)
            
            # Update protocol distribution
            if packet.haslayer(TCP):
                self.protocols['TCP'] += 1
                self.protocol_bytes['TCP'] += len(packet)
                tcp = packet[TCP]
                
                # Update ports
                self.src_ports[tcp.sport] += 1
                self.dst_ports[tcp.dport] += 1
                self.src_port_bytes[tcp.sport] += len(packet)
                self.dst_port_bytes[tcp.dport] += len(packet)
                
                # Update flow
                ip = packet[IP]
                flow_key = f"{ip.src}:{tcp.sport}->{ip.dst}:{tcp.dport}"
                self.flows[flow_key]['packets'] += 1
                self.flows[flow_key]['bytes'] += len(packet)
                
            elif packet.haslayer(UDP):
                self.protocols['UDP'] += 1
                self.protocol_bytes['UDP'] += len(packet)
                udp = packet[UDP]
                
                # Update ports
                self.src_ports[udp.sport] += 1
                self.dst_ports[udp.dport] += 1
                self.src_port_bytes[udp.sport] += len(packet)
                self.dst_port_bytes[udp.dport] += len(packet)
                
                # Update flow
                ip = packet[IP]
                flow_key = f"{ip.src}:{udp.sport}->{ip.dst}:{udp.dport}"
                self.flows[flow_key]['packets'] += 1
                self.flows[flow_key]['bytes'] += len(packet)
                
            elif packet.haslayer(ICMP):
                self.protocols['ICMP'] += 1
                self.protocol_bytes['ICMP'] += len(packet)
                
            elif packet.haslayer(IP):
                self.protocols['Other_IP'] += 1
                self.protocol_bytes['Other_IP'] += len(packet)
            else:
                self.protocols['Other'] += 1
                self.protocol_bytes['Other'] += len(packet)
            
            # Update IP talkers
            if packet.haslayer(IP):
                ip = packet[IP]
                self.src_ips[ip.src] += 1
                self.dst_ips[ip.dst] += 1
                self.src_bytes[ip.src] += len(packet)
                self.dst_bytes[ip.dst] += len(packet)
            
            # Update history for rate calculation
            self.packet_history.append((time.time(), len(packet)))
            self.byte_history.append((time.time(), len(packet)))
    
    def calculate_rates(self):
        """Calculate packet and byte rates."""
        
        with self.stats_lock:
            current_time = time.time()
            
            # Calculate packet rate
            if self.packet_history:
                # Count packets in last second
                recent_packets = [p for t, p in self.packet_history 
                                 if current_time - t < 1]
                packet_rate = len(recent_packets)
            else:
                packet_rate = 0
            
            # Calculate byte rate
            if self.byte_history:
                recent_bytes = [b for t, b in self.byte_history 
                               if current_time - t < 1]
                byte_rate = sum(recent_bytes)
            else:
                byte_rate = 0
            
            return packet_rate, byte_rate
    
    def get_top_talkers(self, n=5):
        """Get top talkers by packet count."""
        
        with self.stats_lock:
            top_src = sorted(self.src_ips.items(), key=lambda x: x[1], reverse=True)[:n]
            top_dst = sorted(self.dst_ips.items(), key=lambda x: x[1], reverse=True)[:n]
            return top_src, top_dst
    
    def get_top_ports(self, n=5):
        """Get top ports by packet count."""
        
        with self.stats_lock:
            top_src_ports = sorted(self.src_ports.items(), key=lambda x: x[1], reverse=True)[:n]
            top_dst_ports = sorted(self.dst_ports.items(), key=lambda x: x[1], reverse=True)[:n]
            return top_src_ports, top_dst_ports
    
    def get_top_protocols(self):
        """Get protocol distribution."""
        
        with self.stats_lock:
            return dict(self.protocols)
    
    def get_flow_stats(self):
        """Get flow statistics."""
        
        with self.stats_lock:
            return dict(self.flows)
    
    def display_dashboard(self):
        """Display the traffic dashboard."""
        
        # Clear screen
        os.system('clear' if os.name == 'posix' else 'cls')
        
        # Calculate rates
        packet_rate, byte_rate = self.calculate_rates()
        
        # Get top statistics
        top_src, top_dst = self.get_top_talkers()
        top_src_ports, top_dst_ports = self.get_top_ports()
        protocols = self.get_top_protocols()
        total_packets = sum(protocols.values())
        
        # Header
        print("=" * 70)
        print(f"LIVE TRAFFIC DASHBOARD - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 70)
        
        # Basic stats
        print(f"\nInterface: {self.interface}")
        if self.filter_str:
            print(f"Filter: {self.filter_str}")
        print(f"Total Packets: {self.packet_count:,}")
        print(f"Total Bytes: {self.byte_count:,}")
        print(f"Packet Rate: {packet_rate} pkts/sec")
        print(f"Byte Rate: {byte_rate/1024:.2f} KB/sec")
        
        # Protocol distribution
        print("\nProtocol Distribution:")
        print("-" * 50)
        for proto, count in sorted(protocols.items(), key=lambda x: x[1], reverse=True):
            percentage = (count / total_packets * 100) if total_packets > 0 else 0
            bar = "█" * int(percentage / 2)
            print(f"  {proto:<10}: {count:>8} ({percentage:>5.1f}%) {bar}")
        
        # Top sources
        print("\nTop Sources (by packets):")
        print("-" * 50)
        for ip, count in top_src:
            print(f"  {ip:<20}: {count:>8}")
        
        # Top destinations
        print("\nTop Destinations (by packets):")
        print("-" * 50)
        for ip, count in top_dst:
            print(f"  {ip:<20}: {count:>8}")
        
        # Top ports
        print("\nTop Source Ports:")
        print("-" * 50)
        for port, count in top_src_ports:
            print(f"  {port:<8}: {count:>8}")
        
        print("\nTop Destination Ports:")
        print("-" * 50)
        for port, count in top_dst_ports:
            print(f"  {port:<8}: {count:>8}")
        
        print("\n" + "=" * 70)
        print("Press Ctrl+C to stop")
    
    def update_dashboard(self):
        """Update the dashboard in a loop."""
        
        while self.running:
            self.display_dashboard()
            time.sleep(self.refresh_rate)
    
    def start_dashboard(self):
        """Start the traffic dashboard."""
        
        print("\n" + "=" * 60)
        print("STARTING TRAFFIC DASHBOARD")
        print("=" * 60)
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        
        # Start update thread
        update_thread = threading.Thread(target=self.update_dashboard)
        update_thread.daemon = True
        update_thread.start()
        
        try:
            # Start sniffing
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self.packet_callback,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping dashboard...")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.running = False
            update_thread.join(timeout=2)

def main():
    """Main function for traffic dashboard."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Live Traffic Dashboard')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-f', '--filter', help='BPF filter')
    parser.add_argument('-r', '--refresh', type=int, default=1,
                        help='Refresh rate in seconds')
    
    args = parser.parse_args()
    
    if not args.interface:
        interfaces = get_if_list()
        for iface in interfaces:
            if iface != 'lo' and iface != 'Loopback Pseudo-Interface 1':
                args.interface = iface
                break
        if not args.interface:
            args.interface = interfaces[0] if interfaces else 'eth0'
    
    dashboard = TrafficDashboard(
        interface=args.interface,
        filter_str=args.filter,
        refresh_rate=args.refresh
    )
    
    try:
        dashboard.start_dashboard()
    except KeyboardInterrupt:
        print("\nDashboard stopped")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("LIVE TRAFFIC DASHBOARD")
        print("=" * 60)
        
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            try:
                mac = get_if_hwaddr(iface)
                print(f"  {i+1}. {iface} ({mac})")
            except:
                print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        dashboard = TrafficDashboard(interface=interface)
        dashboard.start_dashboard()
    else:
        main()
```

---

## The Verification: Testing Packet Sniffing Tools

### Verification 1: Test Basic Sniffer

```bash
cd ~/scapy-tutorial

# Start basic sniffer (may need sudo)
sudo python3 src/basic_sniffer.py -c 10

# Sniff with filter
sudo python3 src/basic_sniffer.py -f "tcp port 80" -c 5
```

**Expected output**: Live packet display with statistics summary.

### Verification 2: Test BPF Filters

```bash
# List all filters
python3 src/bpf_filters.py -l

# Demonstrate a specific filter
sudo python3 src/bpf_filters.py -d http_traffic -c 5
```

**Expected output**: Filter demonstration with captured packets.

### Verification 3: Test Protocol Analyzer

```bash
# Run protocol analyzer (may need sudo)
sudo python3 src/protocol_analyzer.py -f "port 53 or port 80 or port 443"
```

**Expected output**: Protocol-specific analysis with HTTP, DNS, and TLS detection.

### Verification 4: Test Traffic Dashboard

```bash
# Launch traffic dashboard
sudo python3 src/traffic_dashboard.py
```

**Expected output**: Live updating dashboard with traffic statistics.

### Verification 5: Quick Sniffing Tests

```bash
# Quick capture with default settings
sudo python3 -c "from scapy.all import sniff; sniff(prn=lambda x: x.summary(), count=5)"

# Capture with filter
sudo python3 -c "from scapy.all import sniff; sniff(filter='tcp', prn=lambda x: x.summary(), count=5)"

# Save to PCAP
sudo python3 -c "from scapy.all import sniff, wrpcap; packets = sniff(count=10); wrpcap('output/test_capture.pcap', packets); print('Saved 10 packets')"

# Read captured PCAP
python3 -c "from scapy.all import rdpcap; packets = rdpcap('output/test_capture.pcap'); [print(p.summary()) for p in packets]"
```

---

## Reference: BPF Filter Syntax

### Basic BPF Expressions

| Expression | Meaning |
|------------|---------|
| `tcp` | Match TCP packets |
| `udp` | Match UDP packets |
| `icmp` | Match ICMP packets |
| `arp` | Match ARP packets |
| `ip` | Match IPv4 packets |
| `ip6` | Match IPv6 packets |

### Transport Layer Filters

| Expression | Meaning |
|------------|---------|
| `tcp port 80` | TCP port 80 |
| `udp port 53` | UDP port 53 |
| `tcp portrange 1-1000` | TCP ports 1-1000 |
| `tcp[13] & 0x02 != 0` | SYN packets |
| `tcp[13] & 0x10 != 0` | ACK packets |

### Host Filters

| Expression | Meaning |
|------------|---------|
| `host 192.168.1.1` | Packets to/from IP |
| `src host 192.168.1.1` | Packets from IP |
| `dst host 192.168.1.1` | Packets to IP |
| `net 192.168.0.0/16` | Packets to/from network |

### Layer 2 Filters

| Expression | Meaning |
|------------|---------|
| `ether host 00:11:22:33:44:55` | Packets to/from MAC |
| `ether src 00:11:22:33:44:55` | Packets from MAC |
| `ether dst 00:11:22:33:44:55` | Packets to MAC |
| `ether broadcast` | Broadcast packets |
| `ether multicast` | Multicast packets |

### Logical Operators

| Operator | Example |
|----------|---------|
| `and` / `&&` | `tcp and port 80` |
| `or` / `||` | `tcp or udp` |
| `not` / `!` | `not arp` |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Sniffing Without Proper Permissions

```python
# DON'T: Run without checking permissions
sniff()  # Will fail without root

# DO: Check and warn
if os.geteuid() != 0:
    print("Warning: Running without root privileges")
    print("Try: sudo python3 script.py")
```

### Pitfall 2: Not Using BPF Filters

```python
# DON'T: Capture everything then filter in Python
sniff(prn=process_packet)  # Inefficient

# DO: Use BPF filters at kernel level
sniff(filter="tcp port 80", prn=process_packet)
```

### Pitfall 3: Heavy Callback Processing

```python
# DON'T: Slow callbacks
def process_packet(packet):
    time.sleep(0.1)  # Too slow, will drop packets

# DO: Fast callbacks
def process_packet(packet):
    # Quick processing only
    print(packet.summary())
```

### Best Practice: Use Store=False

```python
# DON'T: Store all packets in memory
sniff(prn=process, store=True)  # Memory intensive

# DO: Only store when needed
sniff(prn=process, store=False)  # Memory efficient
```

### Best Practice: Handle Keyboard Interrupt

```python
try:
    sniff(prn=process, count=100)
except KeyboardInterrupt:
    print("Sniffing stopped by user")
    # Clean up
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ Real-time packet capture with `sniff()`
2. ✅ BPF filtering at the kernel level
3. ✅ Protocol-specific packet analysis
4. ✅ Live traffic dashboard creation
5. ✅ Efficient packet processing pipelines
6. ✅ HTTP, DNS, DHCP, ARP, and TLS analysis

---

## Next Steps: Preview of Part 2

In **Module 4, Part 2: Protocol-Specific Deep Analysis**, we'll:

1. Deep dive into HTTP analysis
2. Build a DNS query/response monitor
3. Analyze DHCP DORA sequences
4. Detect network anomalies
5. Build traffic statistics engines
6. Create protocol dissection tools

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 4, PART 1 COMPLETE                                  │
│  ✅ Real-time packet sniffer built                                  │
│  ✅ BPF filtering mastered                                          │
│  ✅ Protocol analyzer created                                       │
│  ✅ Traffic dashboard implemented                                   │
│  ✅ Efficient capture pipelines built                              │
│  NEXT: MODULE 4, PART 2 — Protocol-Specific Deep Analysis         │
│  ● HTTP request/response analysis                                  │
│  ● DNS monitor                                                     │
│  ● DHCP sequence analysis                                          │
│  ● Anomaly detection                                               │
│  ● Traffic statistics engine                                       │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 2, where we'll perform deep analysis of specific protocols and build advanced traffic analysis tools.*
