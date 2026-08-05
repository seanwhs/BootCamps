# Mastering Network Packet Crafting with Scapy
## Module 5: Active Network Manipulation & Security Testing
### Part 2: Packet Injection and Replay

## The Target: Building Packet Injection and Replay Tools

In this part, we'll build professional packet injection and replay tools for authorized security testing. By the end, you'll be able to:

1. Understand packet injection techniques and use cases
2. Build packet replay utilities with safety controls
3. Implement custom payload generation
4. Create security testing tools
5. Develop safety and authorization controls
6. Build a comprehensive packet manipulation framework

---

## The Concept: Packet Injection as Controlled Experimentation

Think of packet injection as **controlled experimentation** on a network:

```
Normal Network Communication:
┌──────────┐     ┌──────────┐
│  Client  │────>│  Server  │   (Normal traffic flow)
└──────────┘     └──────────┘

Packet Injection:
┌──────────┐     ┌──────────┐
│ Attacker │────>│  Server  │   (Injected malicious packets)
└──────────┘     └──────────┘
     │                  │
     └──────────────────┘
          (Responses observed)
```

**Key insight**: Packet injection allows you to test network defenses, simulate attacks, and validate security controls in a controlled environment. Always obtain explicit authorization before using these techniques.

---

## The Implementation: Building Injection and Replay Tools

### Step 1: Understanding Packet Injection

Create `src/injection_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 5, Part 2: Packet Injection Basics

This script demonstrates packet injection techniques
with safety controls and authorization requirements.
"""

from scapy.all import IP, TCP, UDP, ICMP, Ether, send, sr1, conf
from scapy.all import get_if_list, get_if_hwaddr
import os
import sys
import time
import ipaddress

class PacketInjector:
    """
    Safe packet injection utilities.
    
    Features:
    - Authorization checking
    - Target validation
    - Rate limiting
    - Safety controls
    - Multiple injection methods
    """
    
    def __init__(self, interface=None, authorized_targets=None):
        """
        Initialize packet injector.
        
        Args:
            interface: Network interface
            authorized_targets: List of authorized IPs or networks
        """
        self.interface = interface or conf.iface
        self.authorized_targets = authorized_targets or ['127.0.0.1']
        self.rate_limit = 10  # Packets per second
        self.last_packet_time = 0
        self.packet_count = 0
        
        print(f"\n[Injector] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Authorized targets: {', '.join(self.authorized_targets)}")
        print(f"  Rate limit: {self.rate_limit} packets/second")
    
    def is_authorized(self, target_ip):
        """Check if target is authorized for injection."""
        for authorized in self.authorized_targets:
            try:
                # Check if authorized is a network (CIDR)
                if '/' in authorized:
                    network = ipaddress.ip_network(authorized, strict=False)
                    if ipaddress.ip_address(target_ip) in network:
                        return True
                # Direct IP match
                elif target_ip == authorized:
                    return True
            except:
                pass
        return False
    
    def rate_limit_wait(self):
        """Apply rate limiting."""
        current_time = time.time()
        min_interval = 1.0 / self.rate_limit
        
        if current_time - self.last_packet_time < min_interval:
            time.sleep(min_interval - (current_time - self.last_packet_time))
        
        self.last_packet_time = time.time()
        self.packet_count += 1
    
    def inject_packet(self, packet):
        """
        Inject a packet with safety controls.
        
        Args:
            packet: Scapy packet to inject
        
        Returns:
            bool: True if successful
        """
        # Extract target from packet
        target = None
        if packet.haslayer(IP):
            target = packet[IP].dst
        elif packet.haslayer(Ether):
            # If no IP, check if we can determine target
            pass
        
        # Check authorization
        if target and not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            print(f"   Authorized: {', '.join(self.authorized_targets)}")
            return False
        
        # Apply rate limiting
        self.rate_limit_wait()
        
        try:
            # Send packet
            send(packet, iface=self.interface, verbose=False)
            print(f"✓ Injected: {packet.summary()}")
            return True
        except Exception as e:
            print(f"✗ Injection failed: {e}")
            return False
    
    def inject_icmp_echo(self, target, payload=b"Test"):
        """Inject an ICMP echo request."""
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        packet = IP(dst=target) / ICMP() / Raw(load=payload)
        return self.inject_packet(packet)
    
    def inject_tcp_syn(self, target, dport):
        """Inject a TCP SYN packet."""
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        packet = IP(dst=target) / TCP(dport=dport, flags="S")
        return self.inject_packet(packet)
    
    def inject_udp(self, target, dport, payload=b"UDP test"):
        """Inject a UDP packet."""
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        packet = IP(dst=target) / UDP(dport=dport) / Raw(load=payload)
        return self.inject_packet(packet)
    
    def inject_arp_request(self, target_ip, local_ip=None):
        """Inject an ARP request."""
        if not self.is_authorized(target_ip):
            print(f"⚠️ Unauthorized target: {target_ip}")
            return False
        
        local_mac = get_if_hwaddr(self.interface)
        local_ip = local_ip or "0.0.0.0"
        
        packet = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                 ARP(op=1, hwsrc=local_mac, psrc=local_ip, pdst=target_ip)
        
        return self.inject_packet(packet)
    
    def inject_custom(self, dst_ip, src_ip=None, protocol="ICMP", **kwargs):
        """
        Inject a custom packet.
        
        Args:
            dst_ip: Destination IP
            src_ip: Source IP (optional)
            protocol: Protocol (ICMP, TCP, UDP)
            **kwargs: Additional packet parameters
        """
        if not self.is_authorized(dst_ip):
            print(f"⚠️ Unauthorized target: {dst_ip}")
            return False
        
        # Build IP layer
        ip = IP(dst=dst_ip)
        if src_ip:
            ip.src = src_ip
        
        # Build protocol layer
        if protocol == "ICMP":
            proto = ICMP(**kwargs.get('icmp_params', {}))
        elif protocol == "TCP":
            proto = TCP(**kwargs.get('tcp_params', {}))
        elif protocol == "UDP":
            proto = UDP(**kwargs.get('udp_params', {}))
        else:
            print(f"Unsupported protocol: {protocol}")
            return False
        
        # Add payload if specified
        packet = ip / proto
        if 'payload' in kwargs:
            packet = packet / Raw(load=kwargs['payload'])
        
        return self.inject_packet(packet)
    
    def inject_multiple(self, packets, delay=0.1):
        """Inject multiple packets with delay."""
        results = []
        
        for i, packet in enumerate(packets):
            print(f"Injecting packet {i+1}/{len(packets)}")
            success = self.inject_packet(packet)
            results.append(success)
            
            if i < len(packets) - 1:
                time.sleep(delay)
        
        return results

def demonstrate_injection():
    """Demonstrate packet injection concepts."""
    
    print("\n" + "=" * 60)
    print("PACKET INJECTION DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # 1. Injection scenarios
    print("1. Injection Scenarios:")
    print("-" * 40)
    print("  a) ICMP Echo (Ping): Test connectivity")
    print("  b) TCP SYN: Port scanning")
    print("  c) UDP: Service testing")
    print("  d) ARP: Network discovery")
    print("  e) Custom: Protocol fuzzing\n")
    
    # 2. Authorization checks
    print("2. Authorization Requirements:")
    print("-" * 40)
    print("  • Always obtain explicit written permission")
    print("  • Only test in isolated lab environments")
    print("  • Never target production networks")
    print("  • Implement target whitelisting\n")
    
    # 3. Safety controls
    print("3. Safety Controls:")
    print("-" * 40)
    print("  • Rate limiting")
    print("  • Target validation")
    print("  • Packet size limits")
    print("  • Protocol restrictions")
    print("  • Logging and audit trails\n")
    
    # 4. Legal considerations
    print("4. Legal and Ethical Considerations:")
    print("-" * 40)
    print("  • Unauthorized injection is illegal in most jurisdictions")
    print("  • Can violate Computer Fraud and Abuse Act (CFAA)")
    print("  • May violate network policies and terms of service")
    print("  • Can cause denial of service if misused\n")

def main():
    """Main function for injection basics."""
    
    print("=" * 60)
    print("PACKET INJECTION BASICS")
    print("=" * 60)
    
    demonstrate_injection()
    
    # Test injector with localhost
    print("\nTesting injector with localhost:")
    print("-" * 40)
    
    injector = PacketInjector(authorized_targets=['127.0.0.1'])
    
    # Test injection to localhost (safe)
    injector.inject_icmp_echo("127.0.0.1")
    injector.inject_tcp_syn("127.0.0.1", 80)
    injector.inject_udp("127.0.0.1", 53, b"DNS test")
    
    print("\n" + "=" * 60)
    print("Remember: Only inject packets on authorized targets!")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### Step 2: Packet Replay Utility

Create `src/packet_replay.py`:

```python
#!/usr/bin/env python3
"""
Module 5, Part 2: Packet Replay Utility

This script provides professional packet replay capabilities
with advanced features and safety controls.
"""

from scapy.all import rdpcap, send, sendp, IP, Ether, TCP, UDP
from scapy.all import conf, get_if_list, get_if_hwaddr
import os
import sys
import time
import json
import threading
from datetime import datetime
import argparse
from queue import Queue

class PacketReplay:
    """
    Professional packet replay utility.
    
    Features:
    - PCAP file replay
    - Live capture replay
    - Rate control
    - Packet modification
    - Loop and timed replay
    - Safety controls
    - Progress reporting
    """
    
    def __init__(self, interface=None, rate=100, loop=False, modify=None):
        """
        Initialize packet replay.
        
        Args:
            interface: Network interface
            rate: Packets per second
            loop: Loop replay
            modify: Modification function
        """
        self.interface = interface or conf.iface
        self.rate = rate
        self.loop = loop
        self.modify = modify
        
        self.packets = []
        self.total_packets = 0
        self.sent_packets = 0
        self.start_time = None
        self.last_packet_time = 0
        
        # Safety controls
        self.max_packets = 10000
        self.max_packet_size = 1500
        self.authorized_targets = ['127.0.0.1']
        
        # Running state
        self.running = True
        self.packet_queue = Queue()
        
        print(f"\n[Replay] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Rate: {rate} packets/second")
        print(f"  Loop: {loop}")
        print(f"  Max packets: {self.max_packets}")
    
    def load_pcap(self, pcap_file):
        """Load a PCAP file for replay."""
        
        if not os.path.exists(pcap_file):
            print(f"✗ PCAP file not found: {pcap_file}")
            return False
        
        try:
            self.packets = rdpcap(pcap_file)
            self.total_packets = len(self.packets)
            
            if self.total_packets > self.max_packets:
                print(f"⚠️ Truncating to {self.max_packets} packets")
                self.packets = self.packets[:self.max_packets]
                self.total_packets = len(self.packets)
            
            print(f"✓ Loaded {self.total_packets} packets from {pcap_file}")
            
            # Show packet summary
            print("\nPacket summary:")
            print("-" * 40)
            for i, pkt in enumerate(self.packets[:10]):
                print(f"  #{i+1}: {pkt.summary()}")
            if self.total_packets > 10:
                print(f"  ... and {self.total_packets - 10} more")
            
            return True
            
        except Exception as e:
            print(f"✗ Error loading PCAP: {e}")
            return False
    
    def modify_packet(self, packet):
        """Apply modifications to packet before sending."""
        if self.modify:
            return self.modify(packet)
        return packet
    
    def is_safe_packet(self, packet):
        """Check if packet is safe to replay."""
        # Check packet size
        if len(packet) > self.max_packet_size:
            return False
        
        # Check destination IP (if present)
        if packet.haslayer(IP):
            dst_ip = packet[IP].dst
            # Only allow localhost for safety
            if dst_ip not in self.authorized_targets:
                print(f"⚠️ Skipping packet to {dst_ip} (not authorized)")
                return False
        
        return True
    
    def rate_limit_wait(self):
        """Apply rate limiting."""
        if self.rate <= 0:
            return
        
        current_time = time.time()
        min_interval = 1.0 / self.rate
        
        if current_time - self.last_packet_time < min_interval:
            time.sleep(min_interval - (current_time - self.last_packet_time))
        
        self.last_packet_time = time.time()
    
    def replay_packet(self, packet):
        """Replay a single packet."""
        try:
            # Modify packet if needed
            packet = self.modify_packet(packet)
            
            # Check safety
            if not self.is_safe_packet(packet):
                return False
            
            # Rate limit
            self.rate_limit_wait()
            
            # Send packet
            send(packet, iface=self.interface, verbose=False)
            self.sent_packets += 1
            
            return True
            
        except Exception as e:
            print(f"✗ Error replaying packet: {e}")
            return False
    
    def replay_loop(self):
        """Main replay loop."""
        
        if not self.packets:
            print("No packets loaded for replay")
            return
        
        print("\n" + "=" * 60)
        print("STARTING PACKET REPLAY")
        print("=" * 60)
        print(f"Packets: {self.total_packets}")
        print(f"Rate: {self.rate} packets/second")
        print(f"Loop: {self.loop}")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        self.sent_packets = 0
        self.running = True
        
        try:
            while self.running:
                for packet in self.packets:
                    if not self.running:
                        break
                    
                    self.replay_packet(packet)
                    
                    # Progress indicator
                    if self.sent_packets % 100 == 0:
                        elapsed = time.time() - self.start_time
                        print(f"  Sent {self.sent_packets} packets ({self.sent_packets/elapsed:.1f}/s)")
                
                if not self.loop:
                    break
                
                print(f"\nLoop completed, restarting...")
        
        except KeyboardInterrupt:
            print("\n\nReplay interrupted by user")
        except Exception as e:
            print(f"\nError during replay: {e}")
        finally:
            self.running = False
            self.display_summary()
    
    def display_summary(self):
        """Display replay summary."""
        
        elapsed = time.time() - self.start_time if self.start_time else 0
        
        print("\n" + "=" * 60)
        print("REPLAY SUMMARY")
        print("=" * 60)
        print(f"Total packets loaded: {self.total_packets}")
        print(f"Packets sent: {self.sent_packets}")
        print(f"Duration: {elapsed:.2f}s")
        
        if elapsed > 0:
            print(f"Rate: {self.sent_packets/elapsed:.1f} packets/second")
        
        # Calculate success rate
        success_rate = (self.sent_packets / self.total_packets) * 100 if self.total_packets > 0 else 0
        print(f"Success rate: {success_rate:.1f}%")
        
        print("\n" + "=" * 60)
    
    def replay_with_delay(self, packets, delay=0.1, loop=False):
        """Replay packets with custom delay."""
        
        self.packets = packets
        self.total_packets = len(packets)
        self.rate = 1.0 / delay if delay > 0 else 0
        
        self.replay_loop()
    
    def replay_filtered(self, filter_func, **kwargs):
        """Replay packets that match a filter function."""
        
        filtered = [p for p in self.packets if filter_func(p)]
        
        if not filtered:
            print("No packets matched the filter")
            return
        
        print(f"Filtered {len(filtered)} packets from {len(self.packets)}")
        self.packets = filtered
        self.total_packets = len(filtered)
        
        self.replay_loop()

def main():
    """Command-line interface for packet replay."""
    
    parser = argparse.ArgumentParser(description='Packet Replay Utility')
    parser.add_argument('pcap_file', help='PCAP file to replay')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-r', '--rate', type=int, default=100,
                        help='Packets per second')
    parser.add_argument('-l', '--loop', action='store_true',
                        help='Loop replay')
    parser.add_argument('-d', '--delay', type=float,
                        help='Delay between packets (overrides rate)')
    parser.add_argument('--max-packets', type=int, default=10000,
                        help='Maximum packets to replay')
    parser.add_argument('--filter-ip', help='Filter by destination IP')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Verbose output')
    
    args = parser.parse_args()
    
    # Create replay utility
    replay = PacketReplay(
        interface=args.interface or conf.iface,
        rate=args.delay and 1.0/args.delay or args.rate,
        loop=args.loop
    )
    
    # Set max packets
    replay.max_packets = args.max_packets
    
    # Load PCAP
    if not replay.load_pcap(args.pcap_file):
        sys.exit(1)
    
    # Add filter if specified
    if args.filter_ip:
        def ip_filter(packet):
            return packet.haslayer(IP) and packet[IP].dst == args.filter_ip
        
        replay.replay_filtered(ip_filter)
    else:
        replay.replay_loop()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("PACKET REPLAY UTILITY")
        print("=" * 60)
        
        pcap_file = input("Enter PCAP file path: ").strip()
        if not pcap_file:
            print("No PCAP file specified")
            sys.exit(1)
        
        rate = input("Packets per second (default: 100): ").strip()
        rate = int(rate) if rate else 100
        
        loop = input("Loop replay? (y/n): ").strip().lower() == 'y'
        
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number (default: 1): ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = interfaces[0] if interfaces else conf.iface
        else:
            interface = interfaces[0] if interfaces else conf.iface
        
        replay = PacketReplay(interface=interface, rate=rate, loop=loop)
        
        if replay.load_pcap(pcap_file):
            replay.replay_loop()
    else:
        main()
```

### Step 3: Custom Payload Generator

Create `src/payload_generator.py`:

```python
#!/usr/bin/env python3
"""
Module 5, Part 2: Custom Payload Generator

This script generates custom payloads for packet injection
testing and security validation.
"""

import random
import string
import struct
import time
import os
import sys
from datetime import datetime

class PayloadGenerator:
    """
    Custom payload generator for network testing.
    
    Features:
    - Random payload generation
    - Pattern generation
    - Malformed payload generation
    - Fuzzing payloads
    - Protocol-specific payloads
    """
    
    def __init__(self, seed=None):
        """
        Initialize payload generator.
        
        Args:
            seed: Random seed for reproducibility
        """
        if seed is not None:
            random.seed(seed)
        else:
            random.seed()
        
        print(f"\n[Payload Generator] Initialized")
        print(f"  Random seed: {seed or 'random'}")
    
    def generate_random(self, size=100, printable=False):
        """
        Generate random payload.
        
        Args:
            size: Payload size in bytes
            printable: Only generate printable characters
        
        Returns:
            bytes: Random payload
        """
        if printable:
            chars = string.ascii_letters + string.digits + string.punctuation
            payload = ''.join(random.choice(chars) for _ in range(size))
            return payload.encode()
        else:
            return bytes(random.randint(0, 255) for _ in range(size))
    
    def generate_pattern(self, pattern="A", size=100, repeat=True):
        """
        Generate pattern payload.
        
        Args:
            pattern: Pattern string or bytes
            size: Payload size
            repeat: Repeat pattern to fill size
        
        Returns:
            bytes: Pattern payload
        """
        if isinstance(pattern, str):
            pattern = pattern.encode()
        
        if repeat:
            payload = pattern * (size // len(pattern) + 1)
            return payload[:size]
        else:
            return pattern + b'\x00' * (size - len(pattern))
    
    def generate_sequential(self, size=100, start=0):
        """
        Generate sequential payload.
        
        Args:
            size: Payload size
            start: Starting value
        
        Returns:
            bytes: Sequential bytes
        """
        return bytes((i + start) % 256 for i in range(size))
    
    def generate_fuzzing(self, size=100, mutations=10):
        """
        Generate fuzzing payload with mutations.
        
        Args:
            size: Payload size
            mutations: Number of mutations
        
        Returns:
            bytes: Fuzzed payload
        """
        # Start with random payload
        payload = bytearray(self.generate_random(size))
        
        # Apply mutations
        for _ in range(mutations):
            if random.random() < 0.3:
                # Bit flip
                bit_pos = random.randint(0, size * 8 - 1)
                byte_pos = bit_pos // 8
                bit_offset = bit_pos % 8
                payload[byte_pos] ^= (1 << bit_offset)
            
            elif random.random() < 0.3:
                # Byte mutation
                pos = random.randint(0, size - 1)
                payload[pos] = random.randint(0, 255)
            
            elif random.random() < 0.2:
                # Insertion
                insert_pos = random.randint(0, size)
                insert_byte = random.randint(0, 255)
                payload.insert(insert_pos, insert_byte)
                if len(payload) > size * 2:
                    payload = payload[:size]
            
            else:
                # Deletion
                if len(payload) > 1:
                    del_pos = random.randint(0, len(payload) - 1)
                    del payload[del_pos]
        
        return bytes(payload[:size])
    
    def generate_http_request(self, method="GET", path="/", host="example.com", size=100):
        """
        Generate HTTP request payload.
        
        Args:
            method: HTTP method
            path: Request path
            host: Host header
            size: Total payload size
        
        Returns:
            bytes: HTTP request
        """
        headers = [
            f"{method} {path} HTTP/1.1",
            f"Host: {host}",
            "User-Agent: Scapy-Payload-Generator/1.0",
            "Accept: */*",
            ""
        ]
        
        request = "\r\n".join(headers)
        
        # Add random content if needed
        if len(request) < size:
            content = self.generate_random(size - len(request), printable=True)
            request = request[:-(size - len(request))] + content.decode()
        
        return request.encode()
    
    def generate_http_response(self, status_code=200, status_text="OK", size=100):
        """
        Generate HTTP response payload.
        
        Args:
            status_code: HTTP status code
            status_text: Status text
            size: Total payload size
        
        Returns:
            bytes: HTTP response
        """
        headers = [
            f"HTTP/1.1 {status_code} {status_text}",
            "Server: Scapy-Payload-Generator/1.0",
            "Content-Type: text/html",
            f"Content-Length: {size - 100}",  # Approximate
            ""
        ]
        
        response = "\r\n".join(headers)
        
        # Add content
        content = self.generate_random(max(0, size - len(response)), printable=True)
        response = (response + "\r\n").encode() + content
        
        return response[:size]
    
    def generate_dns_query(self, domain="example.com", query_type=1):
        """
        Generate DNS query payload.
        
        Args:
            domain: Domain to query
            query_type: DNS query type (1=A, 28=AAAA, etc.)
        
        Returns:
            bytes: DNS query
        """
        # Build DNS query structure
        transaction_id = struct.pack('>H', random.randint(0, 65535))
        flags = b'\x01\x00'  # RD flag
        questions = struct.pack('>H', 1)  # One question
        
        # Build domain name
        domain_parts = []
        for part in domain.split('.'):
            domain_parts.append(struct.pack('B', len(part)) + part.encode())
        domain_parts.append(b'\x00')
        domain_bytes = b''.join(domain_parts)
        
        # Query type and class
        qtype = struct.pack('>H', query_type)
        qclass = struct.pack('>H', 1)  # IN class
        
        return transaction_id + flags + questions + domain_bytes + qtype + qclass
    
    def generate_dns_response(self, domain="example.com", ip="192.168.1.1"):
        """
        Generate DNS response payload.
        
        Args:
            domain: Domain name
            ip: IP address to respond with
        
        Returns:
            bytes: DNS response
        """
        # Build DNS response structure
        transaction_id = struct.pack('>H', random.randint(0, 65535))
        flags = b'\x81\x80'  # Response, No error
        questions = struct.pack('>H', 1)  # One question
        answers = struct.pack('>H', 1)   # One answer
        authority = b'\x00\x00'
        additional = b'\x00\x00'
        
        # Build domain name (compressed)
        domain_bytes = b'\x07example\x03com\x00'
        
        # Question
        qtype = b'\x00\x01'  # A record
        qclass = b'\x00\x01'  # IN class
        
        # Answer
        answer_name = b'\xc0\x0c'  # Pointer to domain name
        answer_type = b'\x00\x01'  # A record
        answer_class = b'\x00\x01'  # IN class
        answer_ttl = b'\x00\x00\x01\x2c'  # 300 seconds
        answer_length = struct.pack('>H', 4)  # IPv4 length
        answer_ip = bytes(map(int, ip.split('.')))
        
        return (transaction_id + flags + questions + answers + authority + additional +
                domain_bytes + qtype + qclass +
                answer_name + answer_type + answer_class + answer_ttl + answer_length + answer_ip)
    
    def generate_tcp_payload(self, protocol="http", size=100):
        """
        Generate TCP payload.
        
        Args:
            protocol: Application protocol
            size: Payload size
        
        Returns:
            bytes: TCP payload
        """
        if protocol == "http":
            return self.generate_http_request(size=size)
        elif protocol == "dns":
            return self.generate_dns_query()
        elif protocol == "smtp":
            return b"HELO test\r\nMAIL FROM: <test@example.com>\r\n"
        elif protocol == "ftp":
            return b"USER anonymous\r\nPASS test@example.com\r\n"
        else:
            return self.generate_random(size)
    
    def generate_malformed(self, base_payload, corruption_type="bit_flip"):
        """
        Generate malformed payload.
        
        Args:
            base_payload: Original payload
            corruption_type: Type of corruption
        
        Returns:
            bytes: Malformed payload
        """
        payload = bytearray(base_payload)
        
        if corruption_type == "bit_flip":
            # Flip random bits
            pos = random.randint(0, len(payload) - 1)
            bit = random.randint(0, 7)
            payload[pos] ^= (1 << bit)
        
        elif corruption_type == "truncate":
            # Truncate payload
            new_len = random.randint(1, max(1, len(payload) // 2))
            payload = payload[:new_len]
        
        elif corruption_type == "double":
            # Duplicate section
            pos = random.randint(0, len(payload) - 1)
            length = random.randint(1, min(10, len(payload) - pos))
            duplicate = payload[pos:pos+length]
            insert_pos = random.randint(0, len(payload))
            payload = payload[:insert_pos] + duplicate + payload[insert_pos:]
        
        elif corruption_type == "replace":
            # Replace section with random data
            pos = random.randint(0, len(payload) - 1)
            length = random.randint(1, min(10, len(payload) - pos))
            replacement = self.generate_random(length)
            payload = payload[:pos] + bytearray(replacement) + payload[pos+length:]
        
        return bytes(payload)
    
    def save_payload(self, payload, filename=None):
        """Save payload to file."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/payload_{timestamp}.bin"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        with open(filename, 'wb') as f:
            f.write(payload)
        
        print(f"Payload saved to: {filename}")
        return filename

def main():
    """Main function for payload generator demo."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Payload Generator')
    parser.add_argument('-s', '--size', type=int, default=100,
                        help='Payload size in bytes')
    parser.add_argument('-t', '--type', choices=['random', 'pattern', 'sequential', 'fuzzing',
                                                'http_request', 'http_response', 'dns_query',
                                                'dns_response', 'tcp_payload'],
                        default='random', help='Payload type')
    parser.add_argument('--pattern', default='A', help='Pattern for pattern generation')
    parser.add_argument('--seed', type=int, help='Random seed')
    parser.add_argument('-o', '--output', help='Output file')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Verbose output')
    
    args = parser.parse_args()
    
    generator = PayloadGenerator(seed=args.seed)
    
    # Generate payload based on type
    if args.type == 'random':
        payload = generator.generate_random(args.size, printable=False)
    elif args.type == 'pattern':
        payload = generator.generate_pattern(args.pattern, args.size)
    elif args.type == 'sequential':
        payload = generator.generate_sequential(args.size)
    elif args.type == 'fuzzing':
        payload = generator.generate_fuzzing(args.size)
    elif args.type == 'http_request':
        payload = generator.generate_http_request(size=args.size)
    elif args.type == 'http_response':
        payload = generator.generate_http_response(size=args.size)
    elif args.type == 'dns_query':
        payload = generator.generate_dns_query()
    elif args.type == 'dns_response':
        payload = generator.generate_dns_response()
    elif args.type == 'tcp_payload':
        payload = generator.generate_tcp_payload('http', args.size)
    
    # Display payload info
    print(f"\nGenerated {len(payload)} bytes:")
    print("-" * 40)
    
    # Show hex dump
    print(f"Hex: {payload[:64].hex()}")
    if len(payload) > 64:
        print(f"  ... and {len(payload) - 64} more bytes")
    
    # Show ASCII
    try:
        ascii_data = payload.decode('ascii', errors='ignore')[:200]
        print(f"ASCII: {ascii_data}")
        if len(payload) > 200:
            print(f"  ... and {len(payload) - 200} more characters")
    except:
        print("(Binary data - not printable)")
    
    # Save if requested
    if args.output or args.verbose:
        generator.save_payload(payload, args.output)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("PAYLOAD GENERATOR")
        print("=" * 60)
        
        payload_type = input("Payload type (random/pattern/sequential/fuzzing): ").strip()
        size = input("Size (bytes): ").strip()
        size = int(size) if size else 100
        
        generator = PayloadGenerator()
        
        if payload_type == 'pattern':
            pattern = input("Pattern: ").strip() or 'A'
            payload = generator.generate_pattern(pattern, size)
        elif payload_type == 'sequential':
            start = input("Start value: ").strip()
            start = int(start) if start else 0
            payload = generator.generate_sequential(size, start)
        elif payload_type == 'fuzzing':
            mutations = input("Mutations: ").strip()
            mutations = int(mutations) if mutations else 10
            payload = generator.generate_fuzzing(size, mutations)
        else:
            payload = generator.generate_random(size)
        
        print(f"\nGenerated {len(payload)} bytes")
        print(f"Hex: {payload[:32].hex()}")
        
        save = input("Save to file? (y/n): ").strip().lower() == 'y'
        if save:
            generator.save_payload(payload)
    else:
        main()
```

### Step 4: Comprehensive Injection Framework

Create `src/injection_framework.py`:

```python
#!/usr/bin/env python3
"""
Module 5, Part 2: Comprehensive Injection Framework

This script provides a complete framework for packet injection
with multiple attack vectors and safety controls.
"""

from scapy.all import IP, TCP, UDP, ICMP, Ether, ARP, send, sr1, conf
from scapy.all import get_if_list, get_if_hwaddr, RandIP
import os
import sys
import time
import json
import threading
from datetime import datetime
import argparse
import ipaddress
import subprocess

class InjectionFramework:
    """
    Comprehensive packet injection framework.
    
    Features:
    - Multiple injection vectors
    - Safety controls
    - Rate limiting
    - Target validation
    - Results logging
    - Module architecture
    """
    
    def __init__(self, interface=None, targets=None, rate_limit=10):
        """
        Initialize injection framework.
        
        Args:
            interface: Network interface
            targets: Authorized targets
            rate_limit: Packets per second
        """
        self.interface = interface or conf.iface
        self.targets = targets or ['127.0.0.1']
        self.rate_limit = rate_limit
        
        self.last_packet_time = 0
        self.packet_count = 0
        self.results = []
        self.modules = {}
        
        # Safety controls
        self.safety_checks = True
        self.max_packet_size = 1500
        
        print(f"\n[Framework] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Targets: {', '.join(self.targets)}")
        print(f"  Rate limit: {rate_limit} packets/second")
    
    def is_authorized(self, target):
        """Check if target is authorized."""
        for authorized in self.targets:
            try:
                if '/' in authorized:
                    network = ipaddress.ip_network(authorized, strict=False)
                    if ipaddress.ip_address(target) in network:
                        return True
                elif target == authorized:
                    return True
            except:
                pass
        return False
    
    def rate_limit_wait(self):
        """Apply rate limiting."""
        current_time = time.time()
        min_interval = 1.0 / self.rate_limit
        
        if current_time - self.last_packet_time < min_interval:
            time.sleep(min_interval - (current_time - self.last_packet_time))
        
        self.last_packet_time = time.time()
        self.packet_count += 1
    
    def inject_packet(self, packet, description=""):
        """
        Inject a packet with safety controls.
        
        Args:
            packet: Packet to inject
            description: Description of injection
        
        Returns:
            bool: Success status
        """
        # Extract target
        target = None
        if packet.haslayer(IP):
            target = packet[IP].dst
        
        # Check authorization
        if target and not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        # Check size
        if len(packet) > self.max_packet_size:
            print(f"⚠️ Packet too large: {len(packet)} bytes")
            return False
        
        # Rate limit
        self.rate_limit_wait()
        
        try:
            # Send packet
            send(packet, iface=self.interface, verbose=False)
            
            # Log result
            result = {
                'timestamp': datetime.now().isoformat(),
                'target': target,
                'description': description,
                'packet_summary': packet.summary(),
                'success': True
            }
            self.results.append(result)
            
            print(f"✓ Injected: {description} -> {target}")
            return True
            
        except Exception as e:
            print(f"✗ Injection failed: {e}")
            return False
    
    def register_module(self, name, function, description=""):
        """Register an injection module."""
        self.modules[name] = {
            'function': function,
            'description': description
        }
        print(f"Registered module: {name} - {description}")
    
    def list_modules(self):
        """List available injection modules."""
        print("\nAvailable Modules:")
        print("-" * 40)
        for name, module in self.modules.items():
            print(f"  {name}: {module['description']}")
    
    def run_module(self, name, **kwargs):
        """Run an injection module."""
        if name not in self.modules:
            print(f"Module not found: {name}")
            return False
        
        try:
            result = self.modules[name]['function'](self, **kwargs)
            return result
        except Exception as e:
            print(f"Error running module {name}: {e}")
            return False
    
    def module_ping_flood(self, target, count=10):
        """Module: ICMP ping flood."""
        print(f"\n[Module] ICMP Ping Flood to {target}")
        
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        for i in range(count):
            packet = IP(dst=target) / ICMP(id=12345, seq=i) / Raw(b"Ping flood test")
            self.inject_packet(packet, f"Ping flood #{i+1}")
        
        return True
    
    def module_tcp_syn_scan(self, target, ports=[22, 80, 443]):
        """Module: TCP SYN scan."""
        print(f"\n[Module] TCP SYN Scan on {target}")
        
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        for port in ports:
            packet = IP(dst=target) / TCP(dport=port, flags="S")
            self.inject_packet(packet, f"SYN scan port {port}")
            time.sleep(0.1)  # Brief pause between ports
        
        return True
    
    def module_udp_scan(self, target, ports=[53, 123, 161]):
        """Module: UDP service scan."""
        print(f"\n[Module] UDP Scan on {target}")
        
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        for port in ports:
            payload = b"UDP scan probe"
            packet = IP(dst=target) / UDP(dport=port) / Raw(load=payload)
            self.inject_packet(packet, f"UDP scan port {port}")
            time.sleep(0.1)
        
        return True
    
    def module_arp_spoof(self, target, gateway):
        """Module: ARP spoofing (educational only)."""
        print(f"\n[Module] ARP Spoofing Demonstration")
        print("⚠️ This is for educational purposes only!")
        
        if not self.is_authorized(target) or not self.is_authorized(gateway):
            print("⚠️ Unauthorized targets")
            return False
        
        # Send ARP reply claiming to be the gateway
        packet = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                 ARP(op=2, psrc=gateway, hwsrc=get_if_hwaddr(self.interface), pdst=target)
        
        self.inject_packet(packet, f"ARP spoof: {target} -> {gateway}")
        
        return True
    
    def module_custom_packet(self, target, protocol="ICMP", **kwargs):
        """Module: Custom packet injection."""
        print(f"\n[Module] Custom Packet Injection to {target}")
        
        if not self.is_authorized(target):
            print(f"⚠️ Unauthorized target: {target}")
            return False
        
        # Build packet
        packet = IP(dst=target)
        
        if protocol == "ICMP":
            packet = packet / ICMP(**kwargs.get('icmp_params', {}))
        elif protocol == "TCP":
            packet = packet / TCP(**kwargs.get('tcp_params', {}))
        elif protocol == "UDP":
            packet = packet / UDP(**kwargs.get('udp_params', {}))
        else:
            print(f"Unknown protocol: {protocol}")
            return False
        
        # Add payload
        if 'payload' in kwargs:
            packet = packet / Raw(load=kwargs['payload'])
        
        self.inject_packet(packet, f"Custom {protocol} packet")
        
        return True
    
    def export_results(self, filename=None):
        """Export injection results."""
        
        if not self.results:
            print("No results to export")
            return
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/injection_results_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'interface': self.interface,
            'targets': self.targets,
            'total_injections': len(self.results),
            'results': self.results
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"Results exported to: {filename}")
        return filename

def main():
    """Main function for injection framework."""
    
    parser = argparse.ArgumentParser(description='Injection Framework')
    parser.add_argument('target', help='Target IP address')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-m', '--module', help='Module to run')
    parser.add_argument('-l', '--list-modules', action='store_true',
                        help='List available modules')
    parser.add_argument('-r', '--rate', type=int, default=10,
                        help='Rate limit (packets/second)')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results')
    
    args = parser.parse_args()
    
    # Create framework
    framework = InjectionFramework(
        interface=args.interface or conf.iface,
        targets=[args.target],
        rate_limit=args.rate
    )
    
    # Register modules
    framework.register_module('ping_flood', InjectionFramework.module_ping_flood,
                             'ICMP ping flood')
    framework.register_module('syn_scan', InjectionFramework.module_tcp_syn_scan,
                             'TCP SYN port scan')
    framework.register_module('udp_scan', InjectionFramework.module_udp_scan,
                             'UDP service scan')
    framework.register_module('arp_spoof', InjectionFramework.module_arp_spoof,
                             'ARP spoofing (educational)')
    framework.register_module('custom_packet', InjectionFramework.module_custom_packet,
                             'Custom packet injection')
    
    # List modules
    if args.list_modules:
        framework.list_modules()
        return
    
    # Run module
    if args.module:
        if args.module not in framework.modules:
            print(f"Module not found: {args.module}")
            print("Use --list-modules to see available modules")
            return
        
        if args.module == 'ping_flood':
            count = input("Number of pings: ").strip()
            count = int(count) if count else 10
            framework.run_module('ping_flood', target=args.target, count=count)
        elif args.module == 'syn_scan':
            ports = input("Ports (comma-separated): ").strip()
            ports = [int(p.strip()) for p in ports.split(',')] if ports else [22, 80, 443]
            framework.run_module('syn_scan', target=args.target, ports=ports)
        elif args.module == 'udp_scan':
            ports = input("Ports (comma-separated): ").strip()
            ports = [int(p.strip()) for p in ports.split(',')] if ports else [53, 123, 161]
            framework.run_module('udp_scan', target=args.target, ports=ports)
        elif args.module == 'arp_spoof':
            gateway = input("Gateway IP: ").strip()
            if gateway:
                framework.run_module('arp_spoof', target=args.target, gateway=gateway)
            else:
                print("Gateway required")
        elif args.module == 'custom_packet':
            protocol = input("Protocol (ICMP/TCP/UDP): ").strip().upper()
            payload = input("Payload (optional): ").strip()
            framework.run_module('custom_packet', target=args.target, 
                               protocol=protocol, payload=payload.encode() if payload else None)
    
    # Export results
    if args.export:
        framework.export_results()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("INJECTION FRAMEWORK - INTERACTIVE MODE")
        print("=" * 60)
        
        target = input("Target IP: ").strip()
        if not target:
            print("No target specified")
            sys.exit(1)
        
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
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
        
        framework = InjectionFramework(
            interface=interface,
            targets=[target],
            rate_limit=10
        )
        
        # Register modules
        framework.register_module('ping_flood', InjectionFramework.module_ping_flood,
                                 'ICMP ping flood')
        framework.register_module('syn_scan', InjectionFramework.module_tcp_syn_scan,
                                 'TCP SYN port scan')
        framework.register_module('udp_scan', InjectionFramework.module_udp_scan,
                                 'UDP service scan')
        framework.register_module('custom_packet', InjectionFramework.module_custom_packet,
                                 'Custom packet injection')
        
        while True:
            print("\nSelect module to run:")
            print("  1. Ping Flood")
            print("  2. TCP SYN Scan")
            print("  3. UDP Scan")
            print("  4. Custom Packet")
            print("  5. Export Results")
            print("  6. Exit")
            
            choice = input("\nChoice: ").strip()
            
            if choice == '1':
                count = input("Number of pings: ").strip()
                count = int(count) if count else 10
                framework.run_module('ping_flood', target=target, count=count)
            elif choice == '2':
                ports = input("Ports (comma-separated): ").strip()
                ports = [int(p.strip()) for p in ports.split(',')] if ports else [22, 80, 443]
                framework.run_module('syn_scan', target=target, ports=ports)
            elif choice == '3':
                ports = input("Ports (comma-separated): ").strip()
                ports = [int(p.strip()) for p in ports.split(',')] if ports else [53, 123, 161]
                framework.run_module('udp_scan', target=target, ports=ports)
            elif choice == '4':
                protocol = input("Protocol (ICMP/TCP/UDP): ").strip().upper()
                payload = input("Payload: ").strip()
                framework.run_module('custom_packet', target=target,
                                   protocol=protocol, payload=payload.encode() if payload else None)
            elif choice == '5':
                framework.export_results()
            elif choice == '6':
                break
            else:
                print("Invalid choice")
    else:
        main()
```

---

## The Verification: Testing Injection and Replay Tools

### Verification 1: Test Injection Basics

```bash
cd ~/scapy-tutorial
python3 src/injection_basics.py
```

**Expected output**: Injection demonstrations with safety controls.

### Verification 2: Test Packet Replay

```bash
# Generate a test PCAP if you don't have one
sudo python3 -c "from scapy.all import wrpcap, IP, ICMP; packets = [IP(dst='127.0.0.1')/ICMP() for _ in range(10)]; wrpcap('output/test.pcap', packets)"

# Replay the PCAP
python3 src/packet_replay.py output/test.pcap -r 10
```

**Expected output**: Replay of packets with rate control and summary.

### Verification 3: Test Payload Generator

```bash
# Generate random payload
python3 src/payload_generator.py -t random -s 100

# Generate HTTP request
python3 src/payload_generator.py -t http_request -s 200

# Generate fuzzing payload
python3 src/payload_generator.py -t fuzzing -s 50
```

**Expected output**: Generated payloads with hex and ASCII display.

### Verification 4: Test Injection Framework

```bash
# Test on localhost (safe)
sudo python3 src/injection_framework.py 127.0.0.1 -m ping_flood -r 5
```

**Expected output**: Controlled injection with safety checks.

---

## Reference: Injection and Replay Quick Reference

### Injection Types

| Type | Description | Use Case |
|------|-------------|----------|
| ICMP Echo | Ping testing | Connectivity validation |
| TCP SYN | Port scanning | Service discovery |
| UDP | Service testing | Protocol validation |
| ARP | Network discovery | Mapping |
| Custom | Protocol testing | Fuzzing |

### Safety Controls

| Control | Description |
|---------|-------------|
| Authorization | Target whitelisting |
| Rate Limiting | Prevent flooding |
| Size Limits | Prevent oversized packets |
| Logging | Audit trail |
| Confirmation | User verification |

### Attack Vectors (Educational Only)

| Vector | Description | Detection |
|--------|-------------|-----------|
| Ping Flood | ICMP echo flood | Rate detection |
| SYN Flood | TCP connection flood | SYN rate |
| ARP Spoofing | MAC poisoning | IP-MAC verification |
| UDP Flood | Datagram flood | Rate detection |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Lack of Authorization

```python
# DON'T: Inject without checking
send(packet)  # Dangerous

# DO: Always check authorization
if not is_authorized(target):
    print("Unauthorized target")
    return
```

### Pitfall 2: No Rate Limiting

```python
# DON'T: Send packets as fast as possible
for packet in packets:
    send(packet)  # Could flood network

# DO: Implement rate limiting
for packet in packets:
    send(packet)
    time.sleep(0.1)  # 100ms delay
```

### Best Practice: Always Log Activities

```python
def log_injection(packet, target, result):
    """Log all injection activities for audit."""
    log_entry = {
        'timestamp': datetime.now().isoformat(),
        'target': target,
        'packet': str(packet.summary()),
        'result': result
    }
    with open('injection.log', 'a') as f:
        f.write(json.dumps(log_entry) + '\n')
```

### Best Practice: Implement Safety Confirmations

```python
def safety_confirmation(packet):
    """Confirm injection safety before sending."""
    print(f"About to inject: {packet.summary()}")
    confirm = input("Continue? (y/n): ").strip().lower()
    return confirm == 'y'
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ Packet injection techniques with safety controls
2. ✅ Professional packet replay utilities
3. ✅ Custom payload generation
4. ✅ Comprehensive injection framework
5. ✅ Security testing modules
6. ✅ Authorization and safety controls

---

## Module 5 Complete!

**Congratulations!** You've completed Module 5. You now have professional-grade active network manipulation and security testing tools.

---

## Next Steps: Preview of Module 6

In **Module 6: Automation, Performance & Custom Protocols**, we'll:

1. Implement high-performance packet processing
2. Build multi-threaded and asynchronous tools
3. Create custom protocol dissectors
4. Optimize for production environments
5. Build plugin architectures

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 5 COMPLETE                                           │
│  ✅ ARP spoofing detection built                                    │
│  ✅ Packet injection tools developed                                │
│  ✅ Packet replay implemented                                       │
│  ✅ Payload generation mastered                                     │
│  ✅ Security testing framework created                              │
│  NEXT: MODULE 6 — Automation, Performance & Custom Protocols       │
│  ● High-performance packet processing                              │
│  ● Multi-threaded and async tools                                  │
│  ● Custom protocol dissectors                                      │
│  ● Production optimization                                         │
│  ● Plugin architecture                                             │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Module 6, where we'll optimize our tools for production environments and build custom protocol dissectors for proprietary protocols.*
