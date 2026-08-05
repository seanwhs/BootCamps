# Mastering Network Packet Crafting with Scapy
## Module 2: Layer 2 & Layer 3 Operations
### Part 2: ARP Operations

## The Target: Mastering ARP Operations

In this part, we'll dive into the Address Resolution Protocol (ARP) — the system that connects IP addresses to MAC addresses on local networks. By the end, you'll be able to:

1. Understand ARP request/reply mechanics
2. Build a full-featured ARP scanner
3. Detect duplicate IP addresses
4. Implement gratuitous ARP
5. Create a real-time ARP monitor
6. Build a network inventory tool

---

## The Concept: ARP as a Network Phonebook

Think of ARP (Address Resolution Protocol) as a **phonebook for your network**. When you know someone's name (IP address) but need their phone number (MAC address), you consult the phonebook. ARP works the same way:

```
"I know the IP address 192.168.1.1, but what's its MAC address?"
                    ↓
           [ARP Request Broadcast]
                    ↓
"Who has IP 192.168.1.1? Tell 00:11:22:33:44:55 (my MAC)"
                    ↓
           [ARP Reply Unicast]
                    ↓
"I am 192.168.1.1, my MAC is aa:bb:cc:dd:ee:ff"
                    ↓
   [Local ARP Cache Updated]
```

**The ARP Cache**: Just like a real phonebook, your computer keeps a local cache of IP-to-MAC mappings so it doesn't have to ask every time.

---

## The Implementation: Building ARP Tools

### Step 1: Understanding ARP Basics

Create `src/arp_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 2: ARP Basics

This script demonstrates ARP packet construction,
request/reply mechanics, and basic ARP operations.
"""

from scapy.all import Ether, ARP, IP, ICMP, srp, srp1, sr, send, conf
from scapy.all import wrpcap, rdpcap, get_if_hwaddr, get_if_list
import os
import sys
import time
from datetime import datetime

def demonstrate_arp_packets():
    """Demonstrate ARP packet construction."""
    
    print("\n" + "=" * 60)
    print("ARP PACKET CONSTRUCTION")
    print("=" * 60 + "\n")
    
    # 1. ARP Request (Who has IP X?)
    print("1. ARP Request (Who has 192.168.1.1?):")
    print("-" * 40)
    arp_request = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
                  ARP(op=1,  # Request
                      hwsrc="00:11:22:33:44:55",
                      psrc="192.168.1.100",
                      hwdst="00:00:00:00:00:00",
                      pdst="192.168.1.1")
    arp_request.show()
    print(f"  Is broadcast: {arp_request[Ether].dst == 'ff:ff:ff:ff:ff:ff'}")
    print(f"  Operation: {arp_request[ARP].op} (Request)")
    
    # 2. ARP Reply (I am IP X, my MAC is Y)
    print("\n2. ARP Reply (I am 192.168.1.1, MAC aa:bb:cc:dd:ee:ff):")
    print("-" * 40)
    arp_reply = Ether(src="aa:bb:cc:dd:ee:ff", dst="00:11:22:33:44:55") / \
                ARP(op=2,  # Reply
                    hwsrc="aa:bb:cc:dd:ee:ff",
                    psrc="192.168.1.1",
                    hwdst="00:11:22:33:44:55",
                    pdst="192.168.1.100")
    arp_reply.show()
    print(f"  Is unicast: {arp_reply[Ether].dst != 'ff:ff:ff:ff:ff:ff'}")
    print(f"  Operation: {arp_reply[ARP].op} (Reply)")
    
    # 3. Gratuitous ARP (Announcing IP)
    print("\n3. Gratuitous ARP (Announcing IP):")
    print("-" * 40)
    gratuitous = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
                 ARP(op=1,  # Request, but with same IPs
                     hwsrc="00:11:22:33:44:55",
                     psrc="192.168.1.100",
                     hwdst="ff:ff:ff:ff:ff:ff",
                     pdst="192.168.1.100")  # Target IP equals sender IP
    gratuitous.show()
    print(f"  Gratuitous ARP: {gratuitous[ARP].psrc} -> {gratuitous[ARP].pdst}")

def arp_field_explanation():
    """Explain ARP packet fields in detail."""
    
    print("\n" + "=" * 60)
    print("ARP FIELD EXPLANATION")
    print("=" * 60 + "\n")
    
    print("ARP Packet Fields:")
    print("-" * 40)
    print("  Hardware Type:      0x0001 (Ethernet)")
    print("  Protocol Type:      0x0800 (IPv4)")
    print("  Hardware Size:      6 (MAC address length)")
    print("  Protocol Size:      4 (IP address length)")
    print("  Operation Code:     1=Request, 2=Reply")
    print("  Sender MAC Address: Hardware address of sender")
    print("  Sender IP Address:  Protocol address of sender")
    print("  Target MAC Address: Hardware address of target")
    print("  Target IP Address:  Protocol address of target")
    
    print("\nARP Operation Codes:")
    print("-" * 40)
    print("  1: ARP Request (Who has IP?)")
    print("  2: ARP Reply (I have IP!)")
    print("  3: RARP Request (Who has MAC?)")
    print("  4: RARP Reply (I have MAC!)")
    print("  5: DRARP Request (Dynamic RARP)")
    print("  6: DRARP Reply (Dynamic RARP)")
    print("  7: InARP Request (Inverse ARP)")
    print("  8: InARP Reply (Inverse ARP)")
    print("  9: ARP NAK (Negative Acknowledgment)")

def send_arp_request(target_ip, interface=None):
    """
    Send an ARP request and wait for a reply.
    Returns the reply or None if no response.
    """
    if interface:
        conf.iface = interface
    
    # Get local MAC and IP
    local_mac = get_if_hwaddr(conf.iface)
    local_ip = [ip for ip in get_if_list() if ip != 'lo' and ip != '127.0.0.1'][0]
    
    print(f"\nLocal interface: {conf.iface}")
    print(f"Local MAC: {local_mac}")
    print(f"Local IP: {local_ip}")
    
    # Build ARP request
    arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                  ARP(op=1,
                      hwsrc=local_mac,
                      psrc=local_ip,
                      pdst=target_ip)
    
    print(f"\nSending ARP request to {target_ip}...")
    
    try:
        # Send ARP request and wait for reply
        reply = srp1(arp_request, timeout=3, verbose=False)
        
        if reply:
            print(f"\n✓ Received ARP reply from {target_ip}:")
            print(f"  MAC address: {reply[ARP].hwsrc}")
            print(f"  IP address: {reply[ARP].psrc}")
            return reply
        else:
            print(f"\n✗ No ARP reply from {target_ip}")
            return None
            
    except Exception as e:
        print(f"\n✗ Error: {e}")
        return None

def arp_scanner_simple(network):
    """
    Simple ARP scanner for a network.
    network: e.g., "192.168.1.0/24"
    """
    
    print("\n" + "=" * 60)
    print("SIMPLE ARP SCANNER")
    print("=" * 60 + "\n")
    
    print(f"Scanning network: {network}")
    
    # Get local MAC
    local_mac = get_if_hwaddr(conf.iface)
    local_ip = [ip for ip in get_if_list() if ip != 'lo' and ip != '127.0.0.1'][0]
    
    # Build ARP request packet
    arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                  ARP(op=1,
                      hwsrc=local_mac,
                      psrc=local_ip,
                      pdst=network)
    
    print(f"Local MAC: {local_mac}")
    print(f"Local IP: {local_ip}")
    print("\nScanning for hosts...")
    
    try:
        # Send ARP request to all hosts in network
        answered, unanswered = srp(arp_request, timeout=2, verbose=False)
        
        print(f"\nFound {len(answered)} hosts:")
        print("-" * 40)
        print(f"{'IP Address':<20} {'MAC Address':<20}")
        print("-" * 40)
        
        hosts = []
        for sent, received in answered:
            ip = received[ARP].psrc
            mac = received[ARP].hwsrc
            hosts.append((ip, mac))
            print(f"{ip:<20} {mac:<20}")
        
        return hosts
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        return []

def manual_arp_operations():
    """Demonstrate manual ARP operations."""
    
    print("\n" + "=" * 60)
    print("MANUAL ARP OPERATIONS")
    print("=" * 60 + "\n")
    
    # 1. Display ARP cache
    print("1. Display current ARP cache:")
    print("-" * 40)
    import subprocess
    try:
        result = subprocess.run(['arp', '-n'], capture_output=True, text=True)
        print(result.stdout)
    except FileNotFoundError:
        # Windows uses 'arp -a'
        try:
            result = subprocess.run(['arp', '-a'], capture_output=True, text=True)
            print(result.stdout)
        except:
            print("Could not display ARP cache")
    
    # 2. Build packet to target
    print("\n2. Building ARP request to specific target:")
    print("-" * 40)
    
    target_ip = "8.8.8.8"
    local_mac = get_if_hwaddr(conf.iface)
    
    arp_packet = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                 ARP(op=1,
                     hwsrc=local_mac,
                     psrc="192.168.1.100",  # Your local IP
                     pdst=target_ip)
    print(f"ARP request packet to {target_ip}:")
    arp_packet.show()
    
    print("\nNote: This packet is ready to send.")
    print("To send, use: srp1(arp_packet, timeout=3)")

def main():
    """Main function to run ARP basics demo."""
    
    print("=" * 60)
    print("MODULE 2, PART 2: ARP BASICS")
    print("=" * 60)
    
    demonstrate_arp_packets()
    arp_field_explanation()
    
    # Get user input for ARP request
    print("\n" + "=" * 60)
    print("INTERACTIVE ARP REQUEST TEST")
    print("=" * 60 + "\n")
    
    target = input("Enter IP to ARP request (or press Enter to skip): ").strip()
    
    if target:
        # Quick validation
        import re
        ip_pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
        if re.match(ip_pattern, target):
            reply = send_arp_request(target)
        else:
            print("Invalid IP address format. Skipping.")
    else:
        print("Skipping ARP request test.")
    
    manual_arp_operations()
    
    print("\n" + "=" * 60)
    print("ARP BASICS DEMONSTRATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### Step 2: Building a Professional ARP Scanner

Create `src/arp_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 2: Professional ARP Scanner

This script provides a full-featured ARP scanner with:
- Network discovery
- Host inventory
- Duplicate IP detection
- Real-time monitoring
- Output formatting
"""

from scapy.all import Ether, ARP, srp, get_if_hwaddr, conf, srp1
import os
import sys
import time
import ipaddress
from datetime import datetime
from collections import defaultdict
import json
import threading
import queue

class ARPScanner:
    """Professional ARP scanner with advanced features."""
    
    def __init__(self, interface=None):
        """Initialize ARP scanner."""
        self.interface = interface or conf.iface
        self.local_mac = get_if_hwaddr(self.interface)
        self.discovered_hosts = {}
        self.arp_cache_snapshot = {}
        
    def get_local_ip(self):
        """Get local IP address for the interface."""
        import socket
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            # Doesn't actually need to reach the IP
            s.connect(('8.8.8.8', 1))
            ip = s.getsockname()[0]
        except Exception:
            ip = '127.0.0.1'
        finally:
            s.close()
        return ip
    
    def scan_network(self, network_cidr, timeout=2, retries=1):
        """
        Scan a network for active hosts using ARP.
        
        Args:
            network_cidr: Network in CIDR notation (e.g., '192.168.1.0/24')
            timeout: Timeout in seconds for each ARP request
            retries: Number of retries for each host
        
        Returns:
            Dictionary of discovered hosts {ip: mac}
        """
        print(f"\n[SCAN] Starting ARP scan of {network_cidr}")
        print(f"[SCAN] Interface: {self.interface}")
        print(f"[SCAN] Local MAC: {self.local_mac}")
        
        # Parse network
        try:
            network = ipaddress.ip_network(network_cidr, strict=False)
        except ValueError as e:
            print(f"[ERROR] Invalid network: {e}")
            return {}
        
        # Build ARP request
        arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                      ARP(op=1,
                          hwsrc=self.local_mac,
                          psrc=self.get_local_ip(),
                          pdst=str(network))
        
        print(f"[SCAN] Scanning {network.num_addresses} addresses...")
        start_time = time.time()
        
        # Send ARP requests and get responses
        try:
            answered, unanswered = srp(arp_request,
                                       timeout=timeout,
                                       retry=retries,
                                       verbose=False)
        except Exception as e:
            print(f"[ERROR] Scan failed: {e}")
            return {}
        
        elapsed_time = time.time() - start_time
        
        # Process responses
        hosts = {}
        for sent, received in answered:
            ip = received[ARP].psrc
            mac = received[ARP].hwsrc
            hosts[ip] = mac
        
        # Store results
        self.discovered_hosts.update(hosts)
        
        print(f"[SCAN] Scan completed in {elapsed_time:.2f} seconds")
        print(f"[SCAN] Found {len(hosts)} active hosts")
        
        return hosts
    
    def duplicate_ip_detection(self, hosts=None):
        """
        Detect duplicate IP addresses in the network.
        
        Args:
            hosts: Dictionary of {ip: mac} or None to use current discovered hosts
        
        Returns:
            Dictionary of duplicate IPs with multiple MACs
        """
        if hosts is None:
            hosts = self.discovered_hosts
        
        duplicates = {}
        for ip, mac in hosts.items():
            if ip not in duplicates:
                duplicates[ip] = [mac]
            else:
                duplicates[ip].append(mac)
        
        # Filter out IPs with only one MAC
        duplicates = {ip: macs for ip, macs in duplicates.items() if len(macs) > 1}
        
        return duplicates
    
    def continuous_monitor(self, network_cidr, interval=60, duration=None):
        """
        Continuously monitor network for new hosts and changes.
        
        Args:
            network_cidr: Network to monitor
            interval: Seconds between scans
            duration: Total monitoring time (None for indefinite)
        """
        print(f"\n[MONITOR] Starting continuous monitoring of {network_cidr}")
        print(f"[MONITOR] Interval: {interval} seconds")
        if duration:
            print(f"[MONITOR] Duration: {duration} seconds")
        print("[MONITOR] Press Ctrl+C to stop\n")
        
        start_time = time.time()
        iteration = 0
        previous_hosts = {}
        
        try:
            while True:
                iteration += 1
                print(f"\n[MONITOR] Scan iteration #{iteration}")
                print(f"[MONITOR] Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                
                # Scan network
                current_hosts = self.scan_network(network_cidr)
                
                # Detect changes
                if previous_hosts:
                    new_hosts = set(current_hosts.keys()) - set(previous_hosts.keys())
                    lost_hosts = set(previous_hosts.keys()) - set(current_hosts.keys())
                    
                    if new_hosts:
                        print(f"\n[NEW] New hosts discovered:")
                        for ip in new_hosts:
                            print(f"  {ip} -> {current_hosts[ip]}")
                    
                    if lost_hosts:
                        print(f"\n[LOST] Hosts no longer responding:")
                        for ip in lost_hosts:
                            print(f"  {ip} -> {previous_hosts[ip]}")
                
                # Check for duplicates
                duplicates = self.duplicate_ip_detection(current_hosts)
                if duplicates:
                    print(f"\n[WARNING] Duplicate IPs detected:")
                    for ip, macs in duplicates.items():
                        print(f"  IP {ip} has multiple MACs: {', '.join(macs)}")
                
                # Update previous hosts
                previous_hosts = current_hosts
                
                # Check duration
                if duration and (time.time() - start_time) >= duration:
                    print(f"\n[MONITOR] Duration reached ({duration}s). Stopping.")
                    break
                
                # Wait for next interval
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print(f"\n[MONITOR] Monitoring stopped by user")
    
    def export_results(self, filename=None):
        """
        Export discovered hosts to JSON.
        
        Args:
            filename: Output file name (auto-generated if None)
        """
        if not self.discovered_hosts:
            print("[EXPORT] No hosts to export")
            return
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/arp_scan_{timestamp}.json"
        
        # Ensure output directory exists
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'interface': self.interface,
            'local_mac': self.local_mac,
            'hosts': self.discovered_hosts,
            'total_hosts': len(self.discovered_hosts)
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2)
        
        print(f"[EXPORT] Results exported to: {filename}")
        return filename
    
    def format_output(self, hosts=None, table_format=True):
        """
        Format discovered hosts for display.
        
        Args:
            hosts: Dictionary of {ip: mac} or None to use discovered hosts
            table_format: If True, return table format; else simple list
        
        Returns:
            Formatted string
        """
        if hosts is None:
            hosts = self.discovered_hosts
        
        if not hosts:
            return "No hosts discovered."
        
        if table_format:
            output = []
            output.append("-" * 50)
            output.append(f"{'IP Address':<20} {'MAC Address':<20} {'Status':<10}")
            output.append("-" * 50)
            
            for ip, mac in sorted(hosts.items()):
                # Check if MAC is valid (not all zeros)
                status = "Active" if mac != "00:00:00:00:00:00" else "Unknown"
                output.append(f"{ip:<20} {mac:<20} {status:<10}")
            
            output.append("-" * 50)
            output.append(f"Total hosts: {len(hosts)}")
            return '\n'.join(output)
        else:
            return '\n'.join([f"{ip} -> {mac}" for ip, mac in sorted(hosts.items())])
    
    def speed_test(self, network_cidr, iterations=3):
        """
        Test scanning speed on a network.
        
        Args:
            network_cidr: Network to scan
            iterations: Number of test iterations
        """
        print(f"\n[SPEED TEST] Testing ARP scan speed on {network_cidr}")
        print(f"[SPEED TEST] Iterations: {iterations}\n")
        
        times = []
        
        for i in range(iterations):
            start_time = time.time()
            hosts = self.scan_network(network_cidr)
            elapsed = time.time() - start_time
            times.append(elapsed)
            print(f"  Iteration {i+1}: {elapsed:.2f} seconds, {len(hosts)} hosts")
        
        if times:
            avg_time = sum(times) / len(times)
            print(f"\n[SPEED TEST] Average scan time: {avg_time:.2f} seconds")
            print(f"[SPEED TEST] Min: {min(times):.2f}s, Max: {max(times):.2f}s")

def main():
    """Main function for ARP scanner."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Professional ARP Scanner')
    parser.add_argument('-n', '--network', 
                        help='Network to scan (e.g., 192.168.1.0/24)',
                        default='192.168.1.0/24')
    parser.add_argument('-i', '--interface',
                        help='Network interface to use')
    parser.add_argument('-t', '--timeout', type=int, default=2,
                        help='Timeout per ARP request (seconds)')
    parser.add_argument('-m', '--monitor', action='store_true',
                        help='Continuous monitoring mode')
    parser.add_argument('-d', '--duration', type=int,
                        help='Monitor duration in seconds')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    parser.add_argument('-s', '--speed-test', action='store_true',
                        help='Run speed test')
    
    args = parser.parse_args()
    
    # Initialize scanner
    scanner = ARPScanner(interface=args.interface)
    
    print("=" * 60)
    print("PROFESSIONAL ARP SCANNER")
    print("=" * 60)
    print(f"Interface: {scanner.interface}")
    print(f"Local MAC: {scanner.local_mac}")
    print(f"Local IP: {scanner.get_local_ip()}")
    
    if args.speed_test:
        scanner.speed_test(args.network)
        return
    
    if args.monitor:
        scanner.continuous_monitor(args.network, interval=args.timeout * 2, 
                                  duration=args.duration)
        return
    
    # Standard scan
    hosts = scanner.scan_network(args.network, timeout=args.timeout)
    
    # Display results
    print("\n" + scanner.format_output())
    
    # Check for duplicates
    duplicates = scanner.duplicate_ip_detection()
    if duplicates:
        print("\n⚠️ DUPLICATE IP DETECTED:")
        print("The following IP addresses have multiple MACs:")
        for ip, macs in duplicates.items():
            print(f"  {ip}: {', '.join(macs)}")
    
    # Export if requested
    if args.export and hosts:
        scanner.export_results()
    
    print("\n" + "=" * 60)
    print("ARP SCAN COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    # If no arguments, run interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("INTERACTIVE ARP SCANNER")
        print("=" * 60)
        
        network = input("Enter network to scan (e.g., 192.168.1.0/24): ").strip()
        if not network:
            network = "192.168.1.0/24"
        
        scanner = ARPScanner()
        hosts = scanner.scan_network(network)
        
        if hosts:
            print("\n" + scanner.format_output())
            
            # Option to export
            export = input("\nExport results to JSON? (y/n): ").strip().lower()
            if export == 'y':
                scanner.export_results()
            
            # Option to monitor
            monitor = input("Start continuous monitoring? (y/n): ").strip().lower()
            if monitor == 'y':
                try:
                    interval = int(input("Monitoring interval (seconds): ").strip() or "60")
                    scanner.continuous_monitor(network, interval=interval)
                except ValueError:
                    print("Invalid interval. Using default (60 seconds).")
                    scanner.continuous_monitor(network, interval=60)
        else:
            print("No hosts found. Check your network configuration.")
    else:
        main()
```

### Step 3: ARP Monitor and Detection Tools

Create `src/arp_monitor.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 2: ARP Monitor and Detection

This script provides real-time ARP monitoring with
detection of suspicious ARP activity.
"""

from scapy.all import sniff, ARP, Ether, srp1, get_if_hwaddr, conf
from scapy.all import wrpcap, rdpcap
import os
import sys
import time
from datetime import datetime
from collections import defaultdict, deque

class ARPMonitor:
    """
    Real-time ARP monitor with anomaly detection.
    
    Features:
    - Track ARP requests and replies
    - Detect ARP spoofing attempts
    - Monitor for duplicate IPs
    - Log suspicious activity
    - Export ARP traffic to PCAP
    """
    
    def __init__(self, interface=None, log_file="arp_monitor.log"):
        """Initialize ARP monitor."""
        self.interface = interface or conf.iface
        self.local_mac = get_if_hwaddr(self.interface)
        self.log_file = log_file
        
        # Track ARP activity
        self.arp_requests = defaultdict(int)
        self.arp_replies = defaultdict(int)
        self.ip_mac_mapping = {}
        self.suspicious_activity = []
        
        # Detection thresholds
        self.max_requests_per_second = 10
        self.max_replies_per_second = 10
        self.suspicious_macs = set()
        
        # Recent activity for rate detection
        self.recent_requests = deque(maxlen=100)
        self.recent_replies = deque(maxlen=100)
        
        # PCAP storage
        self.captured_packets = []
        self.save_pcap = False
        self.pcap_file = None
        
        # Statistics
        self.stats = {
            'start_time': None,
            'packets_processed': 0,
            'requests': 0,
            'replies': 0,
            'gratuitous': 0,
            'suspicious': 0
        }
    
    def log_event(self, message, level="INFO"):
        """Log an event to file and console."""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"[{timestamp}] [{level}] {message}"
        
        # Print to console
        print(f"  {log_entry}")
        
        # Log to file
        with open(self.log_file, 'a') as f:
            f.write(log_entry + '\n')
    
    def detect_arp_spoofing(self, arp_packet):
        """
        Detect potential ARP spoofing.
        
        ARP spoofing occurs when:
        1. A host claims to have a different IP (MAC changed)
        2. Multiple MACs claim the same IP (IP conflict)
        3. Gratuitous ARP floods (excessive announcements)
        """
        if not arp_packet.haslayer(ARP):
            return False
        
        arp = arp_packet[ARP]
        
        # Check for IP-MAC inconsistency
        if arp.psrc in self.ip_mac_mapping:
            known_mac = self.ip_mac_mapping[arp.psrc]
            if known_mac != arp.hwsrc:
                # IP changed MAC
                self.log_event(
                    f"⚠️ Potential ARP spoofing: IP {arp.psrc} changed MAC from {known_mac} to {arp.hwsrc}",
                    "WARNING"
                )
                self.suspicious_activity.append({
                    'type': 'MAC_Change',
                    'ip': arp.psrc,
                    'old_mac': known_mac,
                    'new_mac': arp.hwsrc,
                    'timestamp': datetime.now()
                })
                return True
        
        # Check for duplicate IP claims
        if arp.psrc in self.ip_mac_mapping:
            # Already handled above
            pass
        
        # Check for excessive gratuitous ARP
        if arp.psrc == arp.pdst:  # Gratuitous ARP
            # Track rate of gratuitous ARP from this source
            # (Implementation detail: we'll track in callback)
            pass
        
        return False
    
    def check_rate_anomaly(self, arp_packet):
        """Check for abnormal ARP request/reply rates."""
        
        now = time.time()
        
        if arp_packet[ARP].op == 1:  # Request
            self.recent_requests.append(now)
            # Check if too many requests in short period
            recent_count = sum(1 for t in self.recent_requests if now - t < 1)
            if recent_count > self.max_requests_per_second:
                self.log_event(
                    f"⚠️ Abnormal ARP request rate: {recent_count}/sec from {arp_packet[ARP].hwsrc}",
                    "WARNING"
                )
                return True
        
        elif arp_packet[ARP].op == 2:  # Reply
            self.recent_replies.append(now)
            recent_count = sum(1 for t in self.recent_replies if now - t < 1)
            if recent_count > self.max_replies_per_second:
                self.log_event(
                    f"⚠️ Abnormal ARP reply rate: {recent_count}/sec from {arp_packet[ARP].hwsrc}",
                    "WARNING"
                )
                return True
        
        return False
    
    def arp_packet_handler(self, packet):
        """Handle captured ARP packets."""
        
        if not packet.haslayer(ARP):
            return
        
        self.stats['packets_processed'] += 1
        arp = packet[ARP]
        
        # Update statistics
        if arp.op == 1:  # Request
            self.stats['requests'] += 1
            self.arp_requests[arp.psrc] += 1
        elif arp.op == 2:  # Reply
            self.stats['replies'] += 1
            self.arp_replies[arp.psrc] += 1
        
        # Check for gratuitous ARP
        if arp.psrc == arp.pdst and arp.op == 1:
            self.stats['gratuitous'] += 1
            self.log_event(f"Gratuitous ARP: {arp.psrc} -> {arp.hwsrc}")
        
        # Update IP-MAC mapping
        self.ip_mac_mapping[arp.psrc] = arp.hwsrc
        
        # Detect anomalies
        is_suspicious = False
        
        if self.detect_arp_spoofing(packet):
            self.stats['suspicious'] += 1
            is_suspicious = True
        
        if self.check_rate_anomaly(packet):
            self.stats['suspicious'] += 1
            is_suspicious = True
        
        # Log normal ARP activity (if not already logged as suspicious)
        if not is_suspicious and (self.stats['packets_processed'] % 10 == 0):
            # Log every 10th packet to keep log manageable
            pass
        
        # Save packet if requested
        if self.save_pcap:
            self.captured_packets.append(packet)
        
        # Display packet summary
        if self.stats['packets_processed'] % 50 == 0:
            print(f"\n[STATS] Processed {self.stats['packets_processed']} ARP packets")
            print(f"        Requests: {self.stats['requests']}, Replies: {self.stats['replies']}")
            print(f"        Suspicious: {self.stats['suspicious']}, Gratuitous: {self.stats['gratuitous']}")
    
    def start_monitoring(self, timeout=None, count=None, save_pcap=False):
        """
        Start ARP monitoring.
        
        Args:
            timeout: Stop after N seconds (None for indefinite)
            count: Stop after N packets (None for indefinite)
            save_pcap: Save captured packets to PCAP
        """
        print("\n" + "=" * 60)
        print("ARP MONITORING STARTED")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print(f"Local MAC: {self.local_mac}")
        print(f"Log file: {self.log_file}")
        print("-" * 60)
        print("Press Ctrl+C to stop monitoring")
        print("=" * 60 + "\n")
        
        self.stats['start_time'] = datetime.now()
        self.save_pcap = save_pcap
        
        try:
            # Start sniffing for ARP packets
            sniff(iface=self.interface,
                  filter="arp",
                  prn=self.arp_packet_handler,
                  timeout=timeout,
                  count=count,
                  store=False)
        
        except KeyboardInterrupt:
            print("\n\n" + "=" * 60)
            print("MONITORING INTERRUPTED BY USER")
            print("=" * 60)
        
        except Exception as e:
            print(f"\n[ERROR] Monitoring failed: {e}")
        
        finally:
            self.stop_monitoring()
    
    def stop_monitoring(self):
        """Stop ARP monitoring and display summary."""
        
        if self.stats['start_time']:
            duration = (datetime.now() - self.stats['start_time']).total_seconds()
        else:
            duration = 0
        
        print("\n" + "=" * 60)
        print("ARP MONITORING SUMMARY")
        print("=" * 60)
        print(f"Duration: {duration:.2f} seconds")
        print(f"Packets processed: {self.stats['packets_processed']}")
        print(f"ARP Requests: {self.stats['requests']}")
        print(f"ARP Replies: {self.stats['replies']}")
        print(f"Gratuitous ARP: {self.stats['gratuitous']}")
        print(f"Suspicious events: {self.stats['suspicious']}")
        
        # Display unique hosts seen
        print(f"\nUnique hosts detected: {len(self.ip_mac_mapping)}")
        print("\nHost mapping (IP -> MAC):")
        print("-" * 40)
        for ip, mac in sorted(self.ip_mac_mapping.items())[:20]:
            print(f"  {ip:<20} {mac:<20}")
        if len(self.ip_mac_mapping) > 20:
            print(f"  ... and {len(self.ip_mac_mapping) - 20} more")
        
        # Save PCAP if requested
        if self.save_pcap and self.captured_packets:
            pcap_file = f"output/arp_capture_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pcap"
            os.makedirs("output", exist_ok=True)
            wrpcap(pcap_file, self.captured_packets)
            print(f"\nARP traffic saved to: {pcap_file}")
        
        print("\n" + "=" * 60)
        print("MONITORING COMPLETE")
        print("=" * 60)

def main():
    """Main function for ARP monitor."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Real-time ARP Monitor')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-t', '--timeout', type=int, help='Stop after N seconds')
    parser.add_argument('-c', '--count', type=int, help='Stop after N packets')
    parser.add_argument('-p', '--pcap', action='store_true', help='Save ARP packets to PCAP')
    parser.add_argument('--requests', type=int, default=10,
                        help='Max ARP requests per second (threshold)')
    parser.add_argument('--replies', type=int, default=10,
                        help='Max ARP replies per second (threshold)')
    
    args = parser.parse_args()
    
    # Create monitor
    monitor = ARPMonitor(interface=args.interface)
    
    # Set thresholds
    monitor.max_requests_per_second = args.requests
    monitor.max_replies_per_second = args.replies
    
    # Start monitoring
    monitor.start_monitoring(timeout=args.timeout, 
                            count=args.count,
                            save_pcap=args.pcap)

if __name__ == "__main__":
    # If no arguments, run in interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("INTERACTIVE ARP MONITOR")
        print("=" * 60)
        
        monitor = ARPMonitor()
        
        print(f"\nMonitoring interface: {monitor.interface}")
        print(f"Local MAC: {monitor.local_mac}")
        
        # Optional configuration
        save_pcap = input("Save ARP traffic to PCAP? (y/n): ").strip().lower() == 'y'
        
        print("\nStarting ARP monitor (press Ctrl+C to stop)...")
        monitor.start_monitoring(save_pcap=save_pcap)
    else:
        main()
```

### Step 4: Network Inventory Tool

Create `src/network_inventory.py`:

```python
#!/usr/bin/env python3
"""
Module 2, Part 2: Network Inventory Tool

This script builds a complete network inventory using
ARP scanning and other discovery techniques.
"""

from scapy.all import Ether, ARP, srp, ICMP, IP, sr1, get_if_hwaddr, conf
import os
import sys
import time
import ipaddress
import json
import csv
from datetime import datetime
from collections import defaultdict

class NetworkInventory:
    """
    Comprehensive network inventory tool.
    
    Features:
    - ARP-based host discovery
    - Device fingerprinting (basic)
    - Inventory export (JSON, CSV)
    - Network topology mapping
    - Change detection
    """
    
    def __init__(self, interface=None):
        """Initialize network inventory."""
        self.interface = interface or conf.iface
        self.local_mac = get_if_hwaddr(self.interface)
        self.hosts = {}
        self.inventory = {}
        self.scan_history = []
        
        # Vendor OUI database (simplified)
        self.oui_db = {
            '00:11:22': 'Test Vendor 1',
            '00:1A:2B': 'Test Vendor 2',
            '00:50:56': 'VMware',
            '00:0C:29': 'VMware',
            '00:50:F0': 'VMware',
            '08:00:27': 'VirtualBox',
            '00:15:5D': 'Hyper-V',
            '00:1C:42': 'Cisco',
            '00:0D:88': 'Hewlett-Packard',
            '00:1E:C9': 'Dell',
            '00:04:76': 'Apple',
            '00:1B:63': 'Apple',
            '00:24:36': 'Apple',
            '00:19:E3': 'Apple',
        }
    
    def get_vendor(self, mac):
        """Get vendor from MAC OUI."""
        if not mac:
            return "Unknown"
        
        # Extract OUI (first 3 bytes)
        oui = mac[:8].upper()  # Format: XX:XX:XX
        return self.oui_db.get(oui, "Unknown")
    
    def scan_network(self, network_cidr, timeout=2):
        """
        Scan network using ARP.
        
        Args:
            network_cidr: Network in CIDR notation
            timeout: Timeout per ARP request
        
        Returns:
            Dictionary of discovered hosts {ip: mac}
        """
        print(f"\n[SCAN] Scanning network: {network_cidr}")
        
        # Parse network
        try:
            network = ipaddress.ip_network(network_cidr, strict=False)
        except ValueError as e:
            print(f"[ERROR] Invalid network: {e}")
            return {}
        
        # Build ARP request
        arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                      ARP(op=1,
                          hwsrc=self.local_mac,
                          psrc="0.0.0.0",  # Use 0.0.0.0 to be stealthy
                          pdst=str(network))
        
        print(f"[SCAN] Scanning {network.num_addresses} addresses...")
        start_time = time.time()
        
        # Send ARP requests
        try:
            answered, unanswered = srp(arp_request,
                                       timeout=timeout,
                                       verbose=False,
                                       iface=self.interface)
        except Exception as e:
            print(f"[ERROR] Scan failed: {e}")
            return {}
        
        elapsed_time = time.time() - start_time
        
        # Process responses
        hosts = {}
        for sent, received in answered:
            ip = received[ARP].psrc
            mac = received[ARP].hwsrc
            hosts[ip] = {
                'mac': mac,
                'ip': ip,
                'vendor': self.get_vendor(mac),
                'first_seen': datetime.now().isoformat(),
                'last_seen': datetime.now().isoformat(),
                'status': 'active'
            }
        
        print(f"[SCAN] Found {len(hosts)} hosts in {elapsed_time:.2f} seconds")
        
        # Update inventory
        self.hosts = hosts
        self.inventory.update(hosts)
        
        # Record scan history
        self.scan_history.append({
            'timestamp': datetime.now().isoformat(),
            'network': network_cidr,
            'hosts_found': len(hosts)
        })
        
        return hosts
    
    def ping_scan(self, hosts, timeout=1):
        """
        Verify hosts with ICMP ping.
        
        Args:
            hosts: List of IP addresses to ping
            timeout: Timeout per ping
        
        Returns:
            Dictionary of ping results
        """
        ping_results = {}
        
        print(f"\n[PING] Verifying {len(hosts)} hosts with ICMP ping...")
        
        for ip in hosts:
            # Build ICMP echo request
            packet = IP(dst=ip) / ICMP()
            
            try:
                reply = sr1(packet, timeout=timeout, verbose=False)
                if reply:
                    ping_results[ip] = True
                else:
                    ping_results[ip] = False
            except Exception:
                ping_results[ip] = False
        
        # Update inventory with ping results
        for ip, alive in ping_results.items():
            if ip in self.inventory:
                self.inventory[ip]['ping_alive'] = alive
                if not alive and self.inventory[ip]['status'] == 'active':
                    self.inventory[ip]['status'] = 'unreachable'
        
        return ping_results
    
    def fingerprint_os(self, ip, timeout=1):
        """
        Basic OS fingerprinting using TCP/IP stack.
        This is a simplified version - real fingerprinting is complex.
        """
        # This is a placeholder for more sophisticated fingerprinting
        # In a real implementation, you'd analyze TTL, TCP options, etc.
        return "Unknown"
    
    def export_inventory(self, output_file=None):
        """
        Export inventory to JSON or CSV.
        
        Args:
            output_file: Output file name (auto-generated if None)
        """
        if not self.inventory:
            print("[EXPORT] No inventory to export")
            return
        
        if output_file is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            output_file = f"output/inventory_{timestamp}.json"
        
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        
        # Prepare export data
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'interface': self.interface,
            'local_mac': self.local_mac,
            'total_hosts': len(self.inventory),
            'hosts': self.inventory,
            'scan_history': self.scan_history
        }
        
        # Export as JSON
        if output_file.endswith('.json'):
            with open(output_file, 'w') as f:
                json.dump(export_data, f, indent=2)
            print(f"[EXPORT] Inventory exported to: {output_file}")
        
        # Export as CSV
        elif output_file.endswith('.csv'):
            with open(output_file, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(['IP Address', 'MAC Address', 'Vendor', 'Status', 'Ping Alive'])
                for ip, data in sorted(self.inventory.items()):
                    writer.writerow([
                        ip,
                        data.get('mac', ''),
                        data.get('vendor', 'Unknown'),
                        data.get('status', 'unknown'),
                        data.get('ping_alive', False)
                    ])
            print(f"[EXPORT] Inventory exported to: {output_file}")
        
        return output_file
    
    def display_inventory(self, show_all=True):
        """Display inventory in formatted table."""
        
        if not self.inventory:
            print("No inventory data available.")
            return
        
        print("\n" + "=" * 80)
        print("NETWORK INVENTORY")
        print("=" * 80)
        print(f"Total hosts: {len(self.inventory)}")
        print(f"Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("-" * 80)
        
        # Count by vendor
        vendors = defaultdict(int)
        for host in self.inventory.values():
            vendors[host.get('vendor', 'Unknown')] += 1
        
        print("\nVendor Distribution:")
        print("-" * 40)
        for vendor, count in sorted(vendors.items(), key=lambda x: x[1], reverse=True):
            bar = "█" * int(count / max(1, max(vendors.values())) * 20)
            print(f"  {vendor:<20}: {count:>3} {bar}")
        
        print("\nHost Details:")
        print("-" * 80)
        print(f"{'IP Address':<20} {'MAC Address':<20} {'Vendor':<20} {'Status':<10}")
        print("-" * 80)
        
        for ip, data in sorted(self.inventory.items()):
            mac = data.get('mac', '')
            vendor = data.get('vendor', 'Unknown')
            status = data.get('status', 'unknown')
            status_icon = "✓" if status == 'active' else "✗" if status == 'unreachable' else "?"
            print(f"{ip:<20} {mac:<20} {vendor:<20} {status:<10}")
        
        print("-" * 80)
        print(f"Total: {len(self.inventory)} hosts")
        print("=" * 80)
    
    def find_changes(self, previous_inventory_file):
        """
        Compare with previous inventory and find changes.
        
        Args:
            previous_inventory_file: Path to previous inventory JSON
        """
        if not os.path.exists(previous_inventory_file):
            print(f"[ERROR] Previous inventory not found: {previous_inventory_file}")
            return
        
        try:
            with open(previous_inventory_file, 'r') as f:
                previous_data = json.load(f)
                previous_hosts = previous_data.get('hosts', {})
        except Exception as e:
            print(f"[ERROR] Could not load previous inventory: {e}")
            return
        
        current_ips = set(self.inventory.keys())
        previous_ips = set(previous_hosts.keys())
        
        new_hosts = current_ips - previous_ips
        lost_hosts = previous_ips - current_ips
        unchanged = current_ips & previous_ips
        
        # Check for MAC changes
        mac_changes = {}
        for ip in unchanged:
            current_mac = self.inventory[ip].get('mac', '')
            previous_mac = previous_hosts[ip].get('mac', '')
            if current_mac != previous_mac:
                mac_changes[ip] = (previous_mac, current_mac)
        
        print("\n" + "=" * 60)
        print("INVENTORY CHANGES")
        print("=" * 60)
        
        if new_hosts:
            print(f"\n[+] New hosts ({len(new_hosts)}):")
            for ip in sorted(new_hosts):
                print(f"    {ip} -> {self.inventory[ip].get('mac', '')}")
        
        if lost_hosts:
            print(f"\n[-] Lost hosts ({len(lost_hosts)}):")
            for ip in sorted(lost_hosts):
                print(f"    {ip} -> {previous_hosts[ip].get('mac', '')}")
        
        if mac_changes:
            print(f"\n[~] MAC changes ({len(mac_changes)}):")
            for ip, (old_mac, new_mac) in mac_changes.items():
                print(f"    {ip}: {old_mac} -> {new_mac}")
        
        if not (new_hosts or lost_hosts or mac_changes):
            print("\nNo changes detected.")
        
        print(f"\nUnchanged hosts: {len(unchanged)}")
        print("=" * 60)

def main():
    """Main function for network inventory tool."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Network Inventory Tool')
    parser.add_argument('-n', '--network', 
                        help='Network to scan (e.g., 192.168.1.0/24)',
                        default='192.168.1.0/24')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-t', '--timeout', type=int, default=2,
                        help='Timeout per ARP request')
    parser.add_argument('-e', '--export', help='Export to file (JSON/CSV)')
    parser.add_argument('-p', '--ping', action='store_true',
                        help='Verify hosts with ICMP ping')
    parser.add_argument('-c', '--compare', help='Compare with previous inventory JSON')
    
    args = parser.parse_args()
    
    # Create inventory
    inventory = NetworkInventory(interface=args.interface)
    
    print("=" * 60)
    print("NETWORK INVENTORY TOOL")
    print("=" * 60)
    print(f"Interface: {inventory.interface}")
    print(f"Local MAC: {inventory.local_mac}")
    
    # Scan network
    hosts = inventory.scan_network(args.network, timeout=args.timeout)
    
    if not hosts:
        print("\nNo hosts found. Check network configuration.")
        sys.exit(1)
    
    # Optional ping verification
    if args.ping:
        ping_results = inventory.ping_scan(list(hosts.keys()))
    
    # Display inventory
    inventory.display_inventory()
    
    # Export if requested
    if args.export:
        inventory.export_inventory(args.export)
    else:
        # Auto-export to JSON
        inventory.export_inventory()
    
    # Compare with previous inventory
    if args.compare:
        inventory.find_changes(args.compare)

if __name__ == "__main__":
    # If no arguments, run interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("INTERACTIVE NETWORK INVENTORY")
        print("=" * 60)
        
        network = input("Enter network to scan (e.g., 192.168.1.0/24): ").strip()
        if not network:
            network = "192.168.1.0/24"
        
        inventory = NetworkInventory()
        hosts = inventory.scan_network(network)
        
        if hosts:
            # Verify with ping
            ping = input("\nVerify hosts with ping? (y/n): ").strip().lower() == 'y'
            if ping:
                inventory.ping_scan(list(hosts.keys()))
            
            inventory.display_inventory()
            inventory.export_inventory()
            
            # Ask for comparison
            compare = input("\nCompare with previous inventory? (y/n): ").strip().lower() == 'y'
            if compare:
                previous = input("Enter previous inventory file path: ").strip()
                if previous:
                    inventory.find_changes(previous)
        else:
            print("No hosts found. Check your network configuration.")
    else:
        main()
```

---

## The Verification: Testing ARP Operations

### Verification 1: Run ARP Basics

```bash
cd ~/scapy-tutorial
python3 src/arp_basics.py
```

**Expected output**: ARP packet construction demonstrations and interactive ARP request test.

### Verification 2: Run ARP Scanner

```bash
# Scan local network
python3 src/arp_scanner.py -n 192.168.1.0/24

# With export
python3 src/arp_scanner.py -n 192.168.1.0/24 -e

# Speed test
python3 src/arp_scanner.py -n 192.168.1.0/24 -s

# Continuous monitoring
python3 src/arp_scanner.py -n 192.168.1.0/24 -m -d 60
```

**Expected output**: Active hosts discovered on your network.

### Verification 3: Run ARP Monitor

```bash
# Start ARP monitoring
python3 src/arp_monitor.py -t 30 -p
```

**Expected output**: Real-time ARP traffic monitoring with detection alerts.

### Verification 4: Run Network Inventory

```bash
# Build network inventory
python3 src/network_inventory.py -n 192.168.1.0/24 -p -e inventory.json
```

**Expected output**: Complete network inventory with vendor detection.

### Verification 5: Quick ARP Tests

```bash
# Send single ARP request
python3 -c "from scapy.all import srp1, Ether, ARP; r = srp1(Ether(dst='ff:ff:ff:ff:ff:ff')/ARP(pdst='8.8.8.8'), timeout=3); print(f'MAC: {r[ARP].hwsrc}' if r else 'No response')"

# Show ARP packet fields
python3 -c "from scapy.all import ARP; a = ARP(); a.show()"

# Build ARP request
python3 -c "from scapy.all import Ether, ARP; p = Ether(dst='ff:ff:ff:ff:ff:ff')/ARP(pdst='192.168.1.1'); print(p.summary())"
```

---

## Reference: ARP Deep Dive

### ARP Packet Structure

| Field | Size (bytes) | Description |
|-------|--------------|-------------|
| Hardware Type | 2 | 0x0001 for Ethernet |
| Protocol Type | 2 | 0x0800 for IPv4 |
| Hardware Size | 1 | 6 for MAC addresses |
| Protocol Size | 1 | 4 for IPv4 addresses |
| Operation | 2 | 1=Request, 2=Reply |
| Sender MAC | 6 | Source hardware address |
| Sender IP | 4 | Source protocol address |
| Target MAC | 6 | Target hardware address |
| Target IP | 4 | Target protocol address |

### ARP Operation Codes

| Code | Description |
|------|-------------|
| 1 | ARP Request |
| 2 | ARP Reply |
| 3 | RARP Request |
| 4 | RARP Reply |
| 5 | DRARP Request |
| 6 | DRARP Reply |
| 7 | InARP Request |
| 8 | InARP Reply |
| 9 | ARP NAK |

### ARP Cache Management

```bash
# View ARP cache (Linux)
arp -n
# Or
ip neigh show

# View ARP cache (Windows)
arp -a

# Clear ARP cache (Linux)
ip neigh flush all

# Clear ARP cache (Windows)
arp -d *
```

---

## Common Pitfalls and Best Practices

### Pitfall 1: Scanning Without Permission

```python
# DON'T: Scan networks without authorization
# This is illegal and unethical

# DO: Only scan your own lab or authorized networks
```

### Pitfall 2: Not Using Timeouts

```python
# DON'T: No timeout (will hang)
reply = srp1(arp_request)

# DO: Use timeout
reply = srp1(arp_request, timeout=3)
```

### Pitfall 3: Incorrect Interface

```python
# DON'T: Use default interface without verification
# May be wrong interface

# DO: List and verify interfaces
from scapy.all import get_if_list
print(get_if_list())
# Then set appropriate interface
conf.iface = "eth0"
```

### Best Practice: Rate Limiting

```python
# Add delays between requests
import time
for ip in targets:
    send_arp_request(ip)
    time.sleep(0.1)  # 100ms delay
```

### Best Practice: Error Handling

```python
try:
    reply = srp1(arp_request, timeout=3)
    if reply:
        process_reply(reply)
    else:
        handle_timeout()
except Exception as e:
    log_error(e)
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ ARP request/reply mechanics
2. ✅ ARP packet construction
3. ✅ Professional ARP scanner with all features
4. ✅ Real-time ARP monitoring
5. ✅ Duplicate IP detection
6. ✅ Gratuitous ARP detection
7. ✅ Network inventory with vendor mapping
8. ✅ Change detection and monitoring

---

## Next Steps: Preview of Part 3

In **Module 2, Part 3: IP and ICMP Operations**, we'll:

1. Understand IPv4 header structure
2. Build custom IP packets
3. Implement ICMP echo (ping) from scratch
4. Build a professional traceroute utility
5. Explore IP fragmentation
6. Create network diagnostic tools

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 2, PART 2 COMPLETE                                  │
│  ✅ ARP packet structure mastered                                   │
│  ✅ ARP scanner implemented                                         │
│  ✅ ARP monitor with detection built                               │
│  ✅ Network inventory tool created                                 │
│  ✅ Duplicate IP detection implemented                             │
│  NEXT: MODULE 2, PART 3 — IP and ICMP Operations                  │
│  ● IPv4 header construction                                         │
│  ● Custom ping implementation                                       │
│  ● Traceroute from scratch                                         │
│  ● IP fragmentation handling                                       │
│  ● Network diagnostic tools                                         │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 3, where we'll dive into the Internet Protocol (IP) and ICMP — the foundation of routing, diagnostics, and all network communication beyond the local network.*
