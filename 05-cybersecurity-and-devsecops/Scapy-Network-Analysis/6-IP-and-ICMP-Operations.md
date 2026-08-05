# Mastering Network Packet Crafting with Scapy
## Module 2: Layer 2 & Layer 3 Operations
### Part 3: IP and ICMP Operations

## The Target: Mastering IP and ICMP Operations

In this part, we'll dive into the Internet Protocol (IP) and ICMP — the foundation of internetworking. By the end, you'll be able to:

1. Understand IPv4 header structure and fields
2. Build custom IP packets with precision
3. Implement ICMP echo (ping) from scratch
4. Build a professional traceroute utility
5. Explore IP fragmentation and reassembly
6. Create comprehensive network diagnostic tools

---

## The Concept: IP as the Postal Service, ICMP as the Status Updates

Think of IP (Internet Protocol) as the **global postal service**. It provides:
- **Addressing**: Every device gets a unique IP address (like a street address)
- **Routing**: Packets are forwarded through networks (like mail sorting)
- **Delivery**: Best-effort delivery (like standard mail, not guaranteed)

ICMP (Internet Control Message Protocol) is the **status update system**. Think of it as:
- **Delivery confirmations**: "Your packet was delivered" (Echo Reply)
- **Problem reports**: "Address doesn't exist" (Destination Unreachable)
- **Routing information**: "Try this different route" (Redirect)
- **Timeouts**: "Your packet took too long" (Time Exceeded)

```
┌─────────────────────────────────────────────────────────────┐
│                    IP PACKET                                │
│  ┌─────────────┬──────────┬──────────┬───────────────┐   │
│  │   Version   │   IHL    │ ToS      │ Total Length  │   │
│  ├─────────────┼──────────┼──────────┼───────────────┤   │
│  │   ID        │ Flags    │ Fragment Offset          │   │
│  ├─────────────┼──────────┼──────────┼───────────────┤   │
│  │   TTL       │ Protocol │ Header Checksum          │   │
│  ├─────────────┴──────────┴──────────┴───────────────┤   │
│  │   Source IP Address                                │   │
│  ├───────────────────────────────────────────────────────┤   │
│  │   Destination IP Address                           │   │
│  ├───────────────────────────────────────────────────────┤   │
│  │   Options (if any)                                 │   │
│  ├───────────────────────────────────────────────────────┤   │
│  │   Payload (ICMP, TCP, UDP, etc.)                   │   │
│  └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Key insight**: IP provides the addressing and routing framework, while ICMP provides the feedback and diagnostic mechanisms that make the network manageable.

---

## The Implementation: Building IP and ICMP Tools

### Step 1: Understanding IP Headers

Create `src/ip_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 3: IP Basics

This script demonstrates IPv4 packet construction,
header field manipulation, and IP operations.
"""

from scapy.all import IP, ICMP, TCP, UDP, Ether, sr1, sr, send
from scapy.all import RandIP, RandShort, get_if_list, conf
import os
import sys
import time
import ipaddress

def demonstrate_ip_fields():
    """Demonstrate IP header fields."""
    
    print("\n" + "=" * 60)
    print("IP HEADER FIELD DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Create a basic IP packet
    ip_packet = IP()
    print("Default IP packet fields:")
    print("-" * 40)
    ip_packet.show()
    
    print("\nKey IP Header Fields:")
    print("-" * 40)
    print("  Version:         4 (IPv4)")
    print("  IHL:             5 (20 bytes header, no options)")
    print("  ToS:             0 (Type of Service)")
    print("  Total Length:    Automatically calculated")
    print("  ID:              Random (used for fragmentation)")
    print("  Flags:           DF (Don't Fragment) by default")
    print("  Fragment Offset: 0")
    print("  TTL:             64 (Time To Live)")
    print("  Protocol:        None (set by upper layer)")
    print("  Checksum:        Automatically calculated")
    print("  Source IP:       0.0.0.0 (must be set)")
    print("  Destination IP:  0.0.0.0 (must be set)")

def build_custom_ip_packets():
    """Build custom IP packets with different settings."""
    
    print("\n" + "=" * 60)
    print("CUSTOM IP PACKET CONSTRUCTION")
    print("=" * 60 + "\n")
    
    # 1. Basic IP packet with destination
    print("1. Basic IP Packet:")
    print("-" * 40)
    packet = IP(dst="8.8.8.8")
    packet.show()
    print(f"  Summary: {packet.summary()}\n")
    
    # 2. IP packet with all fields set
    print("2. Complete IP Packet:")
    print("-" * 40)
    packet = IP(src="192.168.1.100", 
                dst="8.8.8.8",
                ttl=128,
                id=12345,
                flags=2,  # DF flag
                tos=0x10  # Low delay
               )
    packet.show()
    print(f"  TTL: {packet.ttl}, ID: {packet.id}")
    print(f"  Flags: {packet.flags}\n")
    
    # 3. IP packet with no fragmentation
    print("3. IP Packet with No Fragmentation (DF flag):")
    print("-" * 40)
    packet = IP(dst="8.8.8.8", flags=2)
    print(f"  DF flag set: {bool(packet.flags & 2)}\n")
    
    # 4. IP packet allowing fragmentation
    print("4. IP Packet Allowing Fragmentation:")
    print("-" * 40)
    packet = IP(dst="8.8.8.8", flags=0)
    print(f"  DF flag set: {bool(packet.flags & 2)}\n")
    
    # 5. IP packet with options (rarely used)
    print("5. IP Packet with Options:")
    print("-" * 40)
    packet = IP(dst="8.8.8.8")
    packet.options = [IPOption_Timestamp(flags=1, addr_list=["8.8.8.8"])]
    print(f"  Options: {packet.options}\n")

def understand_ip_fragmentation():
    """Demonstrate IP fragmentation concepts."""
    
    print("\n" + "=" * 60)
    print("IP FRAGMENTATION DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Create a large packet that will be fragmented
    print("1. Creating a large packet (1500 bytes of payload):")
    print("-" * 40)
    large_packet = IP(dst="8.8.8.8", flags=0) / TCP(sport=12345, dport=80) / Raw(b"X" * 1500)
    print(f"  Original packet length: {len(large_packet)} bytes")
    print(f"  MTU: 1500 bytes (standard Ethernet)")
    print(f"  Will this fragment? {len(large_packet) > 1500}")
    
    # Show the fragments
    print("\n2. Fragments created by Scapy:")
    print("-" * 40)
    fragments = large_packet.fragment()
    print(f"  Number of fragments: {len(fragments)}")
    for i, frag in enumerate(fragments):
        print(f"  Fragment {i+1}: {len(frag)} bytes")
        print(f"    More fragments: {bool(frag.flags & 1)}")
        print(f"    Fragment offset: {frag.frag}")
    
    print("\n3. Reassembling fragments:")
    print("-" * 40)
    reassembled = IP(fragments)
    print(f"  Reassembled length: {len(reassembled)} bytes")
    print(f"  Matches original: {len(reassembled) == len(large_packet)}")
    
    print("\n4. Fragmentation flags:")
    print("-" * 40)
    print("  DF (Don't Fragment): flag 0x02")
    print("  MF (More Fragments): flag 0x01")
    print("  Reserved:            flag 0x04")

def ip_protocol_numbers():
    """Display common IP protocol numbers."""
    
    print("\n" + "=" * 60)
    print("IP PROTOCOL NUMBERS")
    print("=" * 60 + "\n")
    
    protocols = {
        1: "ICMP",
        2: "IGMP",
        4: "IPv4 encapsulation",
        6: "TCP",
        17: "UDP",
        41: "IPv6 encapsulation",
        47: "GRE",
        50: "ESP",
        51: "AH",
        58: "IPv6-ICMP",
        88: "EIGRP",
        89: "OSPF",
        112: "VRRP",
        115: "L2TP",
    }
    
    print("Common IP protocol numbers:")
    print("-" * 40)
    for num, name in sorted(protocols.items()):
        print(f"  {num:>3}: {name}")

def create_protocol_packets():
    """Create IP packets with different protocols."""
    
    print("\n" + "=" * 60)
    print("IP PACKETS WITH DIFFERENT PROTOCOLS")
    print("=" * 60 + "\n")
    
    # 1. ICMP
    print("1. ICMP Packet (Protocol 1):")
    print("-" * 40)
    packet = IP(dst="8.8.8.8") / ICMP()
    print(f"  Protocol: {packet[IP].proto} ({'ICMP' if packet[IP].proto == 1 else 'Unknown'})")
    print(f"  Summary: {packet.summary()}\n")
    
    # 2. TCP
    print("2. TCP Packet (Protocol 6):")
    print("-" * 40)
    packet = IP(dst="8.8.8.8") / TCP(dport=80)
    print(f"  Protocol: {packet[IP].proto} ({'TCP' if packet[IP].proto == 6 else 'Unknown'})")
    print(f"  Summary: {packet.summary()}\n")
    
    # 3. UDP
    print("3. UDP Packet (Protocol 17):")
    print("-" * 40)
    packet = IP(dst="8.8.8.8") / UDP(dport=53)
    print(f"  Protocol: {packet[IP].proto} ({'UDP' if packet[IP].proto == 17 else 'Unknown'})")
    print(f"  Summary: {packet.summary()}\n")
    
    # 4. Custom protocol
    print("4. Custom Protocol Packet (Protocol 255):")
    print("-" * 40)
    packet = IP(dst="8.8.8.8", proto=255) / Raw(b"Custom protocol data")
    print(f"  Protocol: {packet[IP].proto} (Custom)")
    print(f"  Summary: {packet.summary()}")

def ip_checksum_demo():
    """Demonstrate IP checksum calculation."""
    
    print("\n" + "=" * 60)
    print("IP CHECKSUM DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Create packet without checksum
    packet = IP(dst="8.8.8.8", chksum=None)
    print("Before checksum calculation:")
    print(f"  Checksum: {packet.chksum}")
    
    # Scapy calculates checksum automatically
    print("\nAfter checksum calculation (show2):")
    packet.show2()
    print(f"  Checksum: {packet.chksum}")
    
    # Show that modifying packet invalidates checksum
    print("\nModifying packet:")
    packet[IP].ttl = 64
    # Scapy recalculates automatically on send

def ip_ttl_experiment():
    """Experiment with TTL values."""
    
    print("\n" + "=" * 60)
    print("TTL EXPERIMENT")
    print("=" * 60 + "\n")
    
    target = "8.8.8.8"
    
    print(f"Testing TTL values to {target}:")
    print("-" * 40)
    
    for ttl in [1, 5, 10, 20, 30, 50, 64]:
        packet = IP(dst=target, ttl=ttl) / ICMP()
        reply = sr1(packet, timeout=2, verbose=False)
        
        if reply:
            if reply.haslayer(ICMP):
                icmp_type = reply[ICMP].type
                if icmp_type == 0:  # Echo Reply
                    print(f"  TTL {ttl:>3}: ✓ Reached destination")
                    break
                elif icmp_type == 11:  # Time Exceeded
                    print(f"  TTL {ttl:>3}: ✗ Time exceeded at {reply[IP].src}")
            else:
                print(f"  TTL {ttl:>3}: ? Unexpected reply")
        else:
            print(f"  TTL {ttl:>3}: ✗ No reply")
    
    print("\nNote: This shows the number of hops to reach the destination.")

def ip_demo():
    """Run all IP demonstrations."""
    
    print("=" * 60)
    print("MODULE 2, PART 3: IP OPERATIONS")
    print("=" * 60)
    
    demonstrate_ip_fields()
    build_custom_ip_packets()
    understand_ip_fragmentation()
    ip_protocol_numbers()
    create_protocol_packets()
    ip_checksum_demo()
    ip_ttl_experiment()
    
    print("\n" + "=" * 60)
    print("IP DEMONSTRATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    ip_demo()
```

### Step 2: Building a Custom Ping Utility

Create `src/custom_ping.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 3: Custom Ping Utility

This script implements a professional ping utility from scratch
using Scapy, with all the features of standard ping.
"""

from scapy.all import IP, ICMP, sr1, sr, conf, get_if_list
from scapy.all import RandIP, RandShort
import time
import sys
import signal
import threading
from datetime import datetime
import argparse
import statistics

class CustomPing:
    """
    Professional ping utility implemented with Scapy.
    
    Features:
    - ICMP echo request/reply
    - Statistics collection
    - Timeout handling
    - Summary statistics
    - Continuous ping mode
    - Custom packet size
    - TTL/DF configuration
    """
    
    def __init__(self, target, count=4, timeout=3, interval=1, 
                 packet_size=64, ttl=64, df=True, source=None):
        """
        Initialize ping utility.
        
        Args:
            target: Target IP address or hostname
            count: Number of ping requests to send (0 for continuous)
            timeout: Timeout in seconds per ping
            interval: Interval in seconds between pings
            packet_size: Size of ICMP payload in bytes
            ttl: Time To Live value
            df: Don't Fragment flag
            source: Source IP address (optional)
        """
        self.target = target
        self.count = count
        self.timeout = timeout
        self.interval = interval
        self.packet_size = packet_size
        self.ttl = ttl
        self.df = df
        self.source = source
        
        # Statistics
        self.sent = 0
        self.received = 0
        self.times = []
        self.min_time = float('inf')
        self.max_time = 0
        self.total_time = 0
        
        # Running state
        self.running = True
        
        # Results
        self.results = []
    
    def build_packet(self, seq):
        """
        Build an ICMP echo request packet.
        
        Args:
            seq: Sequence number
        
        Returns:
            Scapy packet
        """
        # Calculate payload size
        payload = b"Ping data from Scapy!" + b"X" * max(0, self.packet_size - len(b"Ping data from Scapy!"))
        payload = payload[:self.packet_size]  # Truncate to exact size
        
        # Build IP layer
        ip = IP(dst=self.target, ttl=self.ttl)
        if self.df:
            ip.flags = 2  # DF flag
        
        if self.source:
            ip.src = self.source
        
        # Build ICMP layer
        icmp = ICMP(type=8, code=0, id=threading.get_ident() & 0xFFFF, seq=seq)
        
        # Complete packet
        packet = ip / icmp / Raw(load=payload)
        
        return packet
    
    def ping_one(self, seq):
        """
        Send one ping request and wait for reply.
        
        Args:
            seq: Sequence number
        
        Returns:
            Dictionary with ping results
        """
        packet = self.build_packet(seq)
        
        # Send and receive
        start_time = time.time()
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        elapsed = (time.time() - start_time) * 1000  # Convert to milliseconds
        
        self.sent += 1
        
        result = {
            'seq': seq,
            'sent': True,
            'received': False,
            'time': elapsed,
            'reply': None
        }
        
        if reply:
            # Check if reply is ICMP echo reply
            if reply.haslayer(ICMP) and reply[ICMP].type == 0:
                self.received += 1
                self.times.append(elapsed)
                self.total_time += elapsed
                
                if elapsed < self.min_time:
                    self.min_time = elapsed
                if elapsed > self.max_time:
                    self.max_time = elapsed
                
                result['received'] = True
                result['reply'] = reply
                result['time'] = elapsed
                result['ttl'] = reply[IP].ttl
            else:
                # Some other ICMP message (e.g., Destination Unreachable)
                result['error'] = f"ICMP type {reply[ICMP].type}"
        else:
            result['error'] = "Timeout"
        
        self.results.append(result)
        return result
    
    def ping(self):
        """
        Execute the ping sequence.
        
        Returns:
            Dictionary with ping statistics
        """
        print(f"\nPING {self.target} ({self.target})")
        print(f"Packet size: {self.packet_size} bytes, TTL: {self.ttl}")
        print("-" * 60)
        
        # Determine number of pings
        if self.count == 0:
            print("Press Ctrl+C to stop")
            print("-" * 60)
            count = float('inf')
        else:
            count = self.count
        
        seq = 1
        start_time = time.time()
        
        while self.running and seq <= count:
            result = self.ping_one(seq)
            
            # Print result
            if result['received']:
                print(f"{len(str(seq)) * ' '}Reply from {self.target}:")
                print(f"  Seq={seq} time={result['time']:.2f}ms TTL={result['ttl']}")
            else:
                print(f"{len(str(seq)) * ' '}Request timed out")
            
            seq += 1
            
            # Wait for next interval if more pings
            if seq <= count:
                time.sleep(self.interval)
        
        total_time = time.time() - start_time
        
        # Print statistics
        self.print_stats(total_time)
        
        return self.get_stats()
    
    def print_stats(self, total_time):
        """Print ping statistics."""
        
        print("-" * 60)
        print(f"PING statistics for {self.target}:")
        print(f"  Packets: Sent={self.sent}, Received={self.received}, Lost={self.sent - self.received}")
        
        if self.received > 0:
            loss_percent = ((self.sent - self.received) / self.sent) * 100
            print(f"  Packet loss: {loss_percent:.1f}%")
            print(f"  Time: {total_time:.2f}s")
            print(f"  RTT Statistics:")
            print(f"    Min: {self.min_time:.2f}ms")
            print(f"    Avg: {self.total_time / self.received:.2f}ms")
            print(f"    Max: {self.max_time:.2f}ms")
            
            if len(self.times) > 1:
                stddev = statistics.stdev(self.times)
                print(f"    StdDev: {stddev:.2f}ms")
                print(f"    MDEV: {stddev:.2f}ms")  # Roughly equivalent
    
    def get_stats(self):
        """Get ping statistics as a dictionary."""
        
        stats = {
            'target': self.target,
            'sent': self.sent,
            'received': self.received,
            'lost': self.sent - self.received,
            'loss_percent': ((self.sent - self.received) / max(1, self.sent)) * 100,
            'times': self.times,
            'results': self.results
        }
        
        if self.received > 0:
            stats['min_time'] = self.min_time
            stats['max_time'] = self.max_time
            stats['avg_time'] = self.total_time / self.received
            if len(self.times) > 1:
                stats['stddev'] = statistics.stdev(self.times)
        
        return stats
    
    def stop(self):
        """Stop continuous ping."""
        self.running = False

def ping_continuous(target, **kwargs):
    """Run continuous ping."""
    pinger = CustomPing(target, count=0, **kwargs)
    try:
        pinger.ping()
    except KeyboardInterrupt:
        pinger.stop()
        print("\nPing stopped")

def main():
    """Command-line interface for custom ping."""
    
    parser = argparse.ArgumentParser(description='Custom Ping Utility with Scapy')
    parser.add_argument('target', help='Target IP address or hostname')
    parser.add_argument('-c', '--count', type=int, default=4,
                        help='Number of pings (0 for continuous)')
    parser.add_argument('-t', '--timeout', type=int, default=3,
                        help='Timeout in seconds')
    parser.add_argument('-i', '--interval', type=float, default=1,
                        help='Interval between pings in seconds')
    parser.add_argument('-s', '--size', type=int, default=64,
                        help='Packet size in bytes')
    parser.add_argument('--ttl', type=int, default=64,
                        help='Time To Live')
    parser.add_argument('--no-df', action='store_true',
                        help='Allow fragmentation (clear DF flag)')
    parser.add_argument('-S', '--source', help='Source IP address')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Verbose output')
    
    args = parser.parse_args()
    
    # Create pinger
    pinger = CustomPing(
        target=args.target,
        count=args.count,
        timeout=args.timeout,
        interval=args.interval,
        packet_size=args.size,
        ttl=args.ttl,
        df=not args.no_df,
        source=args.source
    )
    
    # Run ping
    try:
        pinger.ping()
    except KeyboardInterrupt:
        if args.count == 0:
            pinger.stop()
            print("\nPing stopped")
        else:
            print("\nInterrupted")

if __name__ == "__main__":
    # If no arguments, run interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("INTERACTIVE PING UTILITY")
        print("=" * 60)
        
        target = input("Enter target IP or hostname: ").strip()
        if not target:
            print("No target specified.")
            sys.exit(1)
        
        count = input("Number of pings (0 for continuous): ").strip()
        count = int(count) if count else 4
        
        pinger = CustomPing(target, count=count)
        
        try:
            pinger.ping()
        except KeyboardInterrupt:
            if count == 0:
                pinger.stop()
                print("\nPing stopped")
            else:
                print("\nInterrupted")
    else:
        main()
```

### Step 3: Building a Traceroute Utility

Create `src/custom_traceroute.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 3: Custom Traceroute Utility

This script implements a professional traceroute utility
from scratch using Scapy.
"""

from scapy.all import IP, ICMP, UDP, sr1, sr, conf
from scapy.all import RandIP, RandShort
import time
import sys
import socket
import argparse
from datetime import datetime

class CustomTraceroute:
    """
    Professional traceroute utility implemented with Scapy.
    
    Features:
    - UDP and ICMP tracing
    - TTL incrementing
    - Time measurement
    - Reverse DNS lookup
    - Hop-by-hop display
    """
    
    def __init__(self, target, max_hops=30, timeout=3, probe_count=3,
                 use_udp=True, source=None):
        """
        Initialize traceroute utility.
        
        Args:
            target: Target IP address or hostname
            max_hops: Maximum hops to trace
            timeout: Timeout in seconds per probe
            probe_count: Number of probes per hop
            use_udp: Use UDP (True) or ICMP (False)
            source: Source IP address (optional)
        """
        self.target = target
        self.max_hops = max_hops
        self.timeout = timeout
        self.probe_count = probe_count
        self.use_udp = use_udp
        self.source = source
        
        # Resolve hostname
        try:
            self.target_ip = socket.gethostbyname(target)
            self.target_name = target
        except:
            self.target_ip = target
            self.target_name = target
        
        self.hops = []
        self.hop_times = []
    
    def build_probe(self, ttl, dest_port=None):
        """
        Build a traceroute probe packet.
        
        Args:
            ttl: Time To Live value
            dest_port: Destination port (for UDP)
        
        Returns:
            Scapy packet
        """
        if dest_port is None:
            dest_port = 33434  # Standard traceroute port
        
        # Build IP layer
        ip = IP(dst=self.target_ip, ttl=ttl)
        if self.source:
            ip.src = self.source
        
        # Build transport layer
        if self.use_udp:
            # UDP probe (standard traceroute)
            payload = Raw(b"Traceroute probe")
            probe = ip / UDP(sport=RandShort(), dport=dest_port) / payload
        else:
            # ICMP Echo Request (like ping)
            probe = ip / ICMP(type=8, code=0, id=threading.get_ident() & 0xFFFF)
        
        return probe
    
    def resolve_hostname(self, ip):
        """Resolve IP address to hostname."""
        try:
            hostname = socket.gethostbyaddr(ip)[0]
            return hostname
        except:
            return ip
    
    def do_one_hop(self, ttl, attempt):
        """
        Perform one hop trace.
        
        Args:
            ttl: TTL value for this hop
            attempt: Attempt number (for multiple probes)
        
        Returns:
            Dictionary with hop result
        """
        # Build probe
        probe = self.build_probe(ttl, 33434 + (ttl - 1))
        
        # Send and receive
        start_time = time.time()
        reply = sr1(probe, timeout=self.timeout, verbose=False)
        elapsed = (time.time() - start_time) * 1000  # Milliseconds
        
        result = {
            'ttl': ttl,
            'attempt': attempt,
            'reply': reply,
            'time': elapsed,
            'ip': None,
            'hostname': None,
            'received': False,
            'reached': False,
            'type': None
        }
        
        if reply:
            result['received'] = True
            result['ip'] = reply[IP].src
            result['hostname'] = self.resolve_hostname(result['ip'])
            
            # Determine what kind of reply
            if reply.haslayer(ICMP):
                icmp_type = reply[ICMP].type
                result['type'] = icmp_type
                
                if icmp_type == 0:  # Echo Reply
                    result['reached'] = True
                elif icmp_type == 11:  # Time Exceeded
                    result['reached'] = False
                elif icmp_type == 3:  # Destination Unreachable
                    result['reached'] = True  # We reached but can't go further
            elif reply.haslayer(UDP):
                result['reached'] = True
                result['type'] = 'udp'
        
        return result
    
    def trace(self):
        """
        Perform traceroute.
        
        Returns:
            List of hop results
        """
        print(f"\nTraceroute to {self.target_name} ({self.target_ip})")
        print(f"Max hops: {self.max_hops}, Probes per hop: {self.probe_count}")
        print(f"Method: {'UDP' if self.use_udp else 'ICMP'}")
        print("-" * 80)
        
        # Column headers
        print(f"{'Hop':>4} {'IP Address':<20} {'Hostname':<35} {'Time':<10}")
        print("-" * 80)
        
        reached_target = False
        start_time = time.time()
        
        for ttl in range(1, self.max_hops + 1):
            if reached_target:
                break
            
            # Send multiple probes for this hop
            hop_results = []
            for attempt in range(self.probe_count):
                result = self.do_one_hop(ttl, attempt + 1)
                hop_results.append(result)
            
            # Calculate statistics for this hop
            avg_time = sum(r['time'] for r in hop_results if r['received']) / max(1, sum(1 for r in hop_results if r['received']))
            min_time = min((r['time'] for r in hop_results if r['received']), default=0)
            max_time = max((r['time'] for r in hop_results if r['received']), default=0)
            
            # Get best result (first received reply)
            best_result = None
            for r in hop_results:
                if r['received']:
                    best_result = r
                    break
            
            # Display hop
            if best_result:
                ip = best_result['ip']
                hostname = best_result['hostname'][:35] if best_result['hostname'] else 'Unknown'
                time_str = f"{avg_time:.2f}ms" if best_result['received'] else "*"
                reached = best_result['reached']
                print(f"{ttl:>4} {ip:<20} {hostname:<35} {time_str:<10}")
                
                self.hops.append({
                    'ttl': ttl,
                    'ip': ip,
                    'hostname': hostname,
                    'avg_time': avg_time,
                    'min_time': min_time,
                    'max_time': max_time,
                    'reached': reached,
                    'results': hop_results
                })
                
                if reached:
                    reached_target = True
                    # If we reached the target, we can stop
            else:
                # All probes timed out
                print(f"{ttl:>4} {'*':<20} {'*':<35} {'*':<10}")
                self.hops.append({
                    'ttl': ttl,
                    'ip': None,
                    'hostname': None,
                    'avg_time': None,
                    'min_time': None,
                    'max_time': None,
                    'reached': False,
                    'results': hop_results
                })
        
        # Display summary
        total_time = time.time() - start_time
        print("-" * 80)
        print(f"Trace completed in {total_time:.2f}s")
        print(f"Hops: {len(self.hops)}")
        
        if reached_target:
            print(f"✓ Reached {self.target_ip} in {len(self.hops)} hops")
        else:
            print(f"✗ Did not reach {self.target_ip} (traced {len(self.hops)} hops)")
        
        return self.hops
    
    def export_trace(self, filename=None):
        """Export traceroute results to file."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"traceroute_{self.target_name}_{timestamp}.txt"
        
        with open(filename, 'w') as f:
            f.write(f"Traceroute to {self.target_name} ({self.target_ip})\n")
            f.write(f"Date: {datetime.now()}\n")
            f.write("-" * 80 + "\n")
            f.write(f"{'Hop':>4} {'IP Address':<20} {'Hostname':<35} {'Time':<10}\n")
            f.write("-" * 80 + "\n")
            
            for hop in self.hops:
                if hop['ip']:
                    time_str = f"{hop['avg_time']:.2f}ms" if hop['avg_time'] else "*"
                    f.write(f"{hop['ttl']:>4} {hop['ip']:<20} {hop['hostname']:<35} {time_str:<10}\n")
                else:
                    f.write(f"{hop['ttl']:>4} {'*':<20} {'*':<35} {'*':<10}\n")
            
            f.write("-" * 80 + "\n")
        
        print(f"\nTrace exported to: {filename}")
        return filename

def main():
    """Command-line interface for custom traceroute."""
    
    parser = argparse.ArgumentParser(description='Custom Traceroute Utility with Scapy')
    parser.add_argument('target', help='Target IP address or hostname')
    parser.add_argument('-m', '--max-hops', type=int, default=30,
                        help='Maximum hops to trace')
    parser.add_argument('-t', '--timeout', type=int, default=3,
                        help='Timeout in seconds per probe')
    parser.add_argument('-p', '--probes', type=int, default=3,
                        help='Number of probes per hop')
    parser.add_argument('-I', '--icmp', action='store_true',
                        help='Use ICMP Echo instead of UDP')
    parser.add_argument('-S', '--source', help='Source IP address')
    parser.add_argument('-e', '--export', help='Export results to file')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Verbose output')
    
    args = parser.parse_args()
    
    # Create traceroute
    tracer = CustomTraceroute(
        target=args.target,
        max_hops=args.max_hops,
        timeout=args.timeout,
        probe_count=args.probes,
        use_udp=not args.icmp,
        source=args.source
    )
    
    # Run trace
    try:
        hops = tracer.trace()
        
        # Export if requested
        if args.export:
            tracer.export_trace(args.export)
        elif args.verbose:
            # Print detailed results
            print("\nDetailed Results:")
            print("-" * 80)
            for hop in hops:
                if hop['ip']:
                    print(f"Hop {hop['ttl']}: {hop['ip']} ({hop['hostname']})")
                    print(f"  Time: {hop['avg_time']:.2f}ms (min: {hop['min_time']:.2f}ms, max: {hop['max_time']:.2f}ms)")
                    print(f"  Reached target: {hop['reached']}")
                else:
                    print(f"Hop {hop['ttl']}: * (no response)")
    
    except KeyboardInterrupt:
        print("\nTrace interrupted by user")
        sys.exit(0)

if __name__ == "__main__":
    # If no arguments, run interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("INTERACTIVE TRACEROUTE")
        print("=" * 60)
        
        target = input("Enter target IP or hostname: ").strip()
        if not target:
            print("No target specified.")
            sys.exit(1)
        
        tracer = CustomTraceroute(target)
        try:
            tracer.trace()
        except KeyboardInterrupt:
            print("\nTrace interrupted")
    else:
        main()
```

### Step 4: Network Diagnostic Tool

Create `src/network_diagnostics.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 3: Network Diagnostic Tool

This script provides a comprehensive network diagnostic tool
combining ping, traceroute, and ARP operations.
"""

from scapy.all import IP, ICMP, UDP, sr1, srp, Ether, ARP
from scapy.all import conf, get_if_list, get_if_hwaddr
import time
import sys
import socket
import ipaddress
from datetime import datetime
import argparse
import threading
import subprocess
import json

class NetworkDiagnostic:
    """
    Comprehensive network diagnostic tool.
    
    Features:
    - Connectivity test (ping)
    - Path discovery (traceroute)
    - Local network discovery (ARP scan)
    - Interface information
    - DNS resolution
    - Route information
    """
    
    def __init__(self):
        """Initialize diagnostic tool."""
        self.interface = None
        self.local_ip = None
        self.local_mac = None
        self._detect_local_info()
    
    def _detect_local_info(self):
        """Detect local network information."""
        # Get default interface
        self.interface = conf.iface
        
        # Get local IP
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(('8.8.8.8', 1))
            self.local_ip = s.getsockname()[0]
            s.close()
        except:
            self.local_ip = '127.0.0.1'
        
        # Get local MAC
        try:
            self.local_mac = get_if_hwaddr(self.interface)
        except:
            self.local_mac = 'Unknown'
    
    def ping_test(self, target, count=4):
        """Perform a ping test."""
        print(f"\n[PING] Testing connectivity to {target}")
        print("-" * 60)
        
        try:
            # Use custom ping
            from custom_ping import CustomPing
            pinger = CustomPing(target, count=count)
            stats = pinger.ping()
            return stats
        except ImportError:
            # Fallback to system ping
            try:
                # Detect OS and use appropriate ping command
                import platform
                if platform.system() == 'Windows':
                    cmd = ['ping', '-n', str(count), target]
                else:
                    cmd = ['ping', '-c', str(count), target]
                
                result = subprocess.run(cmd, capture_output=True, text=True)
                print(result.stdout)
                if result.stderr:
                    print(result.stderr)
                return result.returncode == 0
            except:
                print("Error: Could not run ping test")
                return False
    
    def traceroute_test(self, target):
        """Perform a traceroute test."""
        print(f"\n[TRACE] Tracing path to {target}")
        print("-" * 60)
        
        try:
            from custom_traceroute import CustomTraceroute
            tracer = CustomTraceroute(target)
            hops = tracer.trace()
            return hops
        except ImportError:
            # Fallback to system traceroute
            try:
                import platform
                if platform.system() == 'Windows':
                    cmd = ['tracert', target]
                else:
                    cmd = ['traceroute', '-n', target]
                
                result = subprocess.run(cmd, capture_output=True, text=True)
                print(result.stdout)
                if result.stderr:
                    print(result.stderr)
                return result.returncode == 0
            except:
                print("Error: Could not run traceroute")
                return False
    
    def arp_scan(self, network=''):
        """Perform ARP scan on local network."""
        print(f"\n[ARP] Scanning local network")
        print("-" * 60)
        
        if not network:
            # Auto-detect network
            if self.local_ip != '127.0.0.1':
                network = self.local_ip.split('.')[0] + '.' + \
                          self.local_ip.split('.')[1] + '.' + \
                          self.local_ip.split('.')[2] + '.0/24'
            else:
                network = '192.168.1.0/24'
        
        try:
            # Use ARP scanner
            from arp_scanner import ARPScanner
            scanner = ARPScanner(self.interface)
            hosts = scanner.scan_network(network)
            
            if hosts:
                print("\nDiscovered Hosts:")
                print("-" * 60)
                print(f"{'IP Address':<20} {'MAC Address':<20}")
                print("-" * 60)
                for ip, mac in sorted(hosts.items()):
                    print(f"{ip:<20} {mac:<20}")
                print("-" * 60)
                print(f"Total: {len(hosts)} hosts")
            else:
                print("No hosts found")
            
            return hosts
        except ImportError:
            # Simple ARP scan with Scapy
            try:
                arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                              ARP(op=1, psrc=self.local_ip, pdst=network)
                answered, _ = srp(arp_request, timeout=2, verbose=False)
                
                hosts = {}
                for sent, received in answered:
                    hosts[received.psrc] = received.hwsrc
                
                print("\nDiscovered Hosts:")
                print("-" * 60)
                print(f"{'IP Address':<20} {'MAC Address':<20}")
                print("-" * 60)
                for ip, mac in sorted(hosts.items()):
                    print(f"{ip:<20} {mac:<20}")
                print("-" * 60)
                print(f"Total: {len(hosts)} hosts")
                
                return hosts
            except Exception as e:
                print(f"Error scanning network: {e}")
                return {}
    
    def dns_resolve(self, hostname):
        """Resolve hostname to IP address."""
        print(f"\n[DNS] Resolving {hostname}")
        print("-" * 60)
        
        try:
            ip = socket.gethostbyname(hostname)
            print(f"  {hostname} -> {ip}")
            
            # Try to get all IPs
            try:
                ips = socket.gethostbyname_ex(hostname)
                if len(ips[2]) > 1:
                    print(f"  All addresses:")
                    for addr in ips[2]:
                        print(f"    {addr}")
            except:
                pass
            
            return ip
        except Exception as e:
            print(f"Error resolving {hostname}: {e}")
            return None
    
    def interface_info(self):
        """Display interface information."""
        print("\n[IFACE] Network Interface Information")
        print("-" * 60)
        
        print(f"Default interface: {self.interface}")
        print(f"Local IP address: {self.local_ip}")
        print(f"Local MAC address: {self.local_mac}")
        
        # List all interfaces
        try:
            interfaces = get_if_list()
            print(f"\nAvailable interfaces: {', '.join(interfaces)}")
        except:
            pass
        
        # Try to get more detailed interface info
        try:
            import netifaces
            for iface in netifaces.interfaces():
                addrs = netifaces.ifaddresses(iface)
                if netifaces.AF_INET in addrs:
                    for addr in addrs[netifaces.AF_INET]:
                        if 'addr' in addr:
                            ip = addr['addr']
                            netmask = addr.get('netmask', '')
                            print(f"  {iface}: {ip} (netmask {netmask})")
        except ImportError:
            # Netifaces not available
            pass
    
    def route_info(self):
        """Display routing information."""
        print("\n[ROUTE] Routing Information")
        print("-" * 60)
        
        try:
            import platform
            if platform.system() == 'Windows':
                cmd = ['route', 'print']
            else:
                cmd = ['route', '-n']
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            print(result.stdout)
        except Exception as e:
            print(f"Error getting route information: {e}")
    
    def full_diagnostic(self, target=None):
        """Run a complete diagnostic suite."""
        print("\n" + "=" * 60)
        print("NETWORK DIAGNOSTIC SUITE")
        print("=" * 60)
        print(f"Time: {datetime.now()}")
        print("-" * 60)
        
        # Interface information
        self.interface_info()
        
        # If target specified, run tests
        if target:
            # DNS resolution
            self.dns_resolve(target)
            
            # Ping test
            self.ping_test(target)
            
            # Traceroute
            self.traceroute_test(target)
            
            # ARP scan (if target is local)
            try:
                local_network = self.local_ip.split('.')[0] + '.' + \
                                self.local_ip.split('.')[1] + '.' + \
                                self.local_ip.split('.')[2] + '.0/24'
                if ipaddress.ip_address(target).is_private:
                    self.arp_scan(local_network)
            except:
                pass
        
        # Route information
        self.route_info()
        
        print("\n" + "=" * 60)
        print("DIAGNOSTIC COMPLETE")
        print("=" * 60)

def main():
    """Command-line interface for diagnostic tool."""
    
    parser = argparse.ArgumentParser(description='Network Diagnostic Tool')
    parser.add_argument('target', nargs='?', help='Target to diagnose')
    parser.add_argument('-p', '--ping', action='store_true',
                        help='Run ping test')
    parser.add_argument('-t', '--traceroute', action='store_true',
                        help='Run traceroute test')
    parser.add_argument('-a', '--arp', action='store_true',
                        help='Run ARP scan')
    parser.add_argument('-d', '--dns', action='store_true',
                        help='Run DNS resolution')
    parser.add_argument('-i', '--interface', action='store_true',
                        help='Show interface information')
    parser.add_argument('-r', '--route', action='store_true',
                        help='Show routing information')
    parser.add_argument('--all', action='store_true',
                        help='Run all tests')
    
    args = parser.parse_args()
    
    # Create diagnostic tool
    diag = NetworkDiagnostic()
    
    # Determine what to run
    if args.all or not any(vars(args).values()):
        # Run full diagnostic
        diag.full_diagnostic(args.target)
    else:
        # Run specific tests
        if args.interface:
            diag.interface_info()
        
        if args.target:
            if args.dns:
                diag.dns_resolve(args.target)
            
            if args.ping:
                diag.ping_test(args.target)
            
            if args.traceroute:
                diag.traceroute_test(args.target)
            
            if args.arp:
                diag.arp_scan()
        
        if args.route:
            diag.route_info()

if __name__ == "__main__":
    # If no arguments, run interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("INTERACTIVE NETWORK DIAGNOSTIC")
        print("=" * 60)
        
        diag = NetworkDiagnostic()
        
        # Show basic info
        diag.interface_info()
        
        # Ask for tests
        while True:
            print("\nOptions:")
            print("  1. Ping test")
            print("  2. Traceroute")
            print("  3. ARP scan")
            print("  4. DNS lookup")
            print("  5. Full diagnostic")
            print("  6. Show routes")
            print("  7. Exit")
            
            choice = input("Select option (1-7): ").strip()
            
            if choice == '1':
                target = input("Enter target: ").strip()
                if target:
                    diag.ping_test(target)
            
            elif choice == '2':
                target = input("Enter target: ").strip()
                if target:
                    diag.traceroute_test(target)
            
            elif choice == '3':
                network = input("Enter network (CIDR) or press Enter for auto: ").strip()
                diag.arp_scan(network if network else '')
            
            elif choice == '4':
                hostname = input("Enter hostname: ").strip()
                if hostname:
                    diag.dns_resolve(hostname)
            
            elif choice == '5':
                target = input("Enter target (optional): ").strip()
                diag.full_diagnostic(target if target else None)
            
            elif choice == '6':
                diag.route_info()
            
            elif choice == '7':
                print("Goodbye!")
                break
            
            else:
                print("Invalid choice")
    else:
        main()
```

---

## The Verification: Testing IP and ICMP Operations

### Verification 1: Run IP Basics

```bash
cd ~/scapy-tutorial
python3 src/ip_basics.py
```

**Expected output**: Detailed IP header field demonstrations and fragment handling.

### Verification 2: Test Custom Ping

```bash
# Standard ping
python3 src/custom_ping.py 8.8.8.8

# Continuous ping
python3 src/custom_ping.py 8.8.8.8 -c 0

# Ping with custom size
python3 src/custom_ping.py 8.8.8.8 -s 1000 -c 4

# Ping with different TTL
python3 src/custom_ping.py 8.8.8.8 --ttl 128 -c 4
```

**Expected output**: ICMP echo requests and replies with statistics.

### Verification 3: Test Custom Traceroute

```bash
# Basic traceroute
python3 src/custom_traceroute.py 8.8.8.8

# With more probes
python3 src/custom_traceroute.py 8.8.8.8 -p 3

# Using ICMP instead of UDP
python3 src/custom_traceroute.py 8.8.8.8 -I

# Export results
python3 src/custom_traceroute.py 8.8.8.8 -e trace.txt
```

**Expected output**: Hop-by-hop path to destination with timing.

### Verification 4: Run Network Diagnostic

```bash
# Full diagnostic
python3 src/network_diagnostics.py --all 8.8.8.8

# Specific tests
python3 src/network_diagnostics.py 8.8.8.8 -p -t -d
```

**Expected output**: Comprehensive network diagnostic information.

### Verification 5: Quick IP Tests

```bash
# Build and show IP packet
python3 -c "from scapy.all import IP; p=IP(dst='8.8.8.8',ttl=64); p.show()"

# Send IP packet and get reply
python3 -c "from scapy.all import IP, ICMP, sr1; r=sr1(IP(dst='8.8.8.8')/ICMP(), timeout=3); print(f'Reply: {r.summary()}' if r else 'No reply')"

# Test TTL values
python3 -c "from scapy.all import IP, ICMP, sr1; print('TTL Test:'); [print(f'TTL {ttl}: {sr1(IP(dst=\"8.8.8.8\",ttl=ttl)/ICMP(), timeout=2, verbose=False)}') for ttl in [1,10,20,30,50]]"

# Show IP fragmentation
python3 -c "from scapy.all import IP, ICMP; p=IP(dst='8.8.8.8')/ICMP()/Raw(b'X'*2000); f=p.fragment(); print(f'Fragments: {len(f)}'); [print(f'Frag {i+1}: {len(frag)} bytes') for i,frag in enumerate(f)]"
```

---

## Reference: IP and ICMP Deep Dive

### IPv4 Header Fields

| Field | Size | Description |
|-------|------|-------------|
| Version | 4 bits | Always 4 for IPv4 |
| IHL | 4 bits | Header length in 32-bit words (5 = no options) |
| ToS | 8 bits | Type of Service (QoS) |
| Total Length | 16 bits | Total packet length including header |
| ID | 16 bits | Identification for fragmentation |
| Flags | 3 bits | DF (Don't Fragment), MF (More Fragments) |
| Fragment Offset | 13 bits | Fragment position in original packet |
| TTL | 8 bits | Time To Live (decremented at each hop) |
| Protocol | 8 bits | Transport protocol (TCP=6, UDP=17, ICMP=1) |
| Checksum | 16 bits | Header checksum |
| Source IP | 32 bits | Source address |
| Destination IP | 32 bits | Destination address |
| Options | Variable | Optional fields (rarely used) |

### ICMP Types

| Type | Name | Description |
|------|------|-------------|
| 0 | Echo Reply | Response to Echo Request |
| 3 | Destination Unreachable | Destination unreachable |
| 4 | Source Quench | Congestion control (deprecated) |
| 5 | Redirect | Route change |
| 8 | Echo Request | Ping request |
| 9 | Router Advertisement | Router discovery |
| 10 | Router Solicitation | Router discovery |
| 11 | Time Exceeded | TTL expired |
| 12 | Parameter Problem | Bad IP header |

### TTL Values in Practice

| Value | Typical Use |
|-------|-------------|
| 1 | Same network only |
| 32 | Microsoft Windows (older) |
| 64 | Linux, macOS |
| 128 | Windows 10+ |
| 255 | Maximum, used for loopback |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Not Checking for Permission

```python
# DON'T: Assume you can send packets
send(packet)  # May fail without root/sudo

# DO: Handle permission errors gracefully
try:
    send(packet)
except PermissionError:
    print("Need root/sudo privileges for raw sockets")
```

### Pitfall 2: Ignoring Timeouts

```python
# DON'T: Infinite wait
reply = sr1(packet)  # Could hang forever

# DO: Set timeout
reply = sr1(packet, timeout=3)  # 3 second timeout
```

### Pitfall 3: Not Resolving Hostnames

```python
# DON'T: Use hostname directly
packet = IP(dst="example.com")  # Works but may resolve

# DO: Explicitly resolve
import socket
ip = socket.gethostbyname("example.com")
packet = IP(dst=ip)  # Clear and explicit
```

### Best Practice: Use show2() for Checksum Verification

```python
# Show with checksums calculated
packet.show2()
```

### Best Practice: Test with Safe Targets First

```python
# Always test with localhost or known safe targets
test_targets = ["127.0.0.1", "8.8.8.8", "1.1.1.1"]

for target in test_targets:
    reply = sr1(IP(dst=target)/ICMP(), timeout=2)
    if reply:
        print(f"✓ {target} is reachable")
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ IPv4 header structure and fields
2. ✅ Custom IP packet construction
3. ✅ ICMP echo (ping) from scratch
4. ✅ Professional traceroute implementation
5. ✅ IP fragmentation and reassembly
6. ✅ Comprehensive diagnostic tools
7. ✅ TTL experimentation and routing discovery

---

## Module 2 Complete!

**Congratulations!** You've completed Module 2. You now have a deep understanding of Layer 2 and Layer 3 operations, and you've built:

- Ethernet frame tools
- ARP scanner and monitor
- Network inventory tool
- Custom ping utility
- Professional traceroute
- Comprehensive diagnostic suite

---

## Next Steps: Preview of Module 3

In **Module 3: Transport Layer Protocols & Reconnaissance**, we'll:

1. Deep dive into TCP and UDP
2. Build a professional port scanner
3. Implement banner grabbing
4. Create service detection tools
5. Build TCP handshake visualizers
6. Create multi-threaded scanning engines

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 2 COMPLETE                                           │
│  ✅ Ethernet frame operations mastered                              │
│  ✅ ARP operations implemented                                      │
│  ✅ IP and ICMP tools built                                         │
│  ✅ Custom ping and traceroute created                             │
│  ✅ Network diagnostic tools developed                             │
│  NEXT: MODULE 3 — TRANSPORT LAYER PROTOCOLS & RECONNAISSANCE      │
│  ● TCP and UDP deep dive                                          │
│  ● Professional port scanner                                      │
│  ● Banner grabbing                                                │
│  ● Service detection                                              │
│  ● TCP handshake visualizer                                       │
│  ● Multi-threaded scanning                                        │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Module 3, where we'll explore the transport layer — understanding how applications communicate reliably (TCP) and efficiently (UDP) across networks.*
