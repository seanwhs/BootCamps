# Mastering Network Packet Crafting with Scapy
## Module 5: Active Network Manipulation & Security Testing
### Part 1: ARP Spoofing Detection

## The Target: Building ARP Spoofing Detection Systems

In this part, we'll build professional-grade ARP spoofing detection tools. By the end, you'll be able to:

1. Understand ARP spoofing mechanics and risks
2. Build a real-time ARP spoofing detector
3. Implement IP-MAC mapping validation
4. Detect anomalous ARP activity
5. Create alerting and logging systems
6. Build a comprehensive ARP security monitor

---

## The Concept: ARP Spoofing as Identity Theft

Think of ARP spoofing as **identity theft on your network**:

```
Normal ARP:
┌─────────────────────────────────────────────────────────────────┐
│ "Who has 192.168.1.1?" (ARP Request)                          │
│ "I am 192.168.1.1. My MAC is aa:bb:cc:dd:ee:ff" (ARP Reply)  │
│ All traffic to 192.168.1.1 goes to aa:bb:cc:dd:ee:ff         │
└─────────────────────────────────────────────────────────────────┘

ARP Spoofing Attack:
┌─────────────────────────────────────────────────────────────────┐
│ "Who has 192.168.1.1?" (ARP Request)                          │
│ "I am 192.168.1.1. My MAC is 00:11:22:33:44:55" (Fake Reply) │
│ Now traffic to 192.168.1.1 goes to attacker!                 │
│ Attacker intercepts, modifies, or drops traffic              │
└─────────────────────────────────────────────────────────────────┘
```

**Key insight**: ARP spoofing exploits the trust inherent in the ARP protocol. Detection systems must continuously verify that IP-to-MAC mappings remain consistent and identify anomalies that indicate ongoing attacks.

---

## The Implementation: Building ARP Detection Tools

### Step 1: Understanding ARP Spoofing

Create `src/arp_spoofing_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 5, Part 1: ARP Spoofing Basics

This script demonstrates ARP spoofing concepts and
shows how to detect malicious ARP activity.
"""

from scapy.all import Ether, ARP, srp1, srp, get_if_hwaddr, conf
from scapy.all import sniff, wrpcap, rdpcap
import os
import sys
import time
from datetime import datetime
import threading

def demonstrate_arp_spoofing_packets():
    """Demonstrate ARP spoofing packet construction."""
    
    print("\n" + "=" * 60)
    print("ARP SPOOFING PACKET DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # 1. Normal ARP Reply
    print("1. Normal ARP Reply (Legitimate):")
    print("-" * 40)
    normal_reply = Ether(dst="00:11:22:33:44:55", src="aa:bb:cc:dd:ee:ff") / \
                   ARP(op=2, hwsrc="aa:bb:cc:dd:ee:ff", psrc="192.168.1.1",
                       hwdst="00:11:22:33:44:55", pdst="192.168.1.100")
    normal_reply.show()
    print(f"  Legitimate: {normal_reply[ARP].psrc} -> {normal_reply[ARP].hwsrc}\n")
    
    # 2. ARP Spoofing Reply (Malicious)
    print("2. ARP Spoofing Reply (Malicious):")
    print("-" * 40)
    spoofed_reply = Ether(dst="00:11:22:33:44:55", src="00:11:22:33:44:55") / \
                    ARP(op=2, hwsrc="00:11:22:33:44:55", psrc="192.168.1.1",
                        hwdst="00:11:22:33:44:55", pdst="192.168.1.100")
    spoofed_reply.show()
    print(f"  Spoofed: {spoofed_reply[ARP].psrc} -> {spoofed_reply[ARP].hwsrc}")
    print(f"  ⚠️ Attacker claims to be 192.168.1.1 with MAC 00:11:22:33:44:55\n")
    
    # 3. Gratuitous ARP (Common in spoofing)
    print("3. Gratuitous ARP Spoofing:")
    print("-" * 40)
    gratuitous = Ether(dst="ff:ff:ff:ff:ff:ff", src="00:11:22:33:44:55") / \
                 ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.1",
                     hwdst="ff:ff:ff:ff:ff:ff", pdst="192.168.1.1")
    gratuitous.show()
    print(f"  Gratuitous: {gratuitous[ARP].psrc} -> {gratuitous[ARP].hwsrc}")
    print(f"  ⚠️ Attacker announces new mapping without being asked")

def explain_arp_spoofing_risks():
    """Explain the risks of ARP spoofing."""
    
    print("\n" + "=" * 60)
    print("ARP SPOOFING RISKS")
    print("=" * 60 + "\n")
    
    print("Attack Vectors:")
    print("-" * 40)
    print("  1. Man-in-the-Middle (MITM): Intercept and modify traffic")
    print("  2. Session Hijacking: Steal session cookies and tokens")
    print("  3. Denial of Service: Drop traffic to cause disruption")
    print("  4. Credential Theft: Capture usernames and passwords")
    print("  5. Network Reconnaissance: Discover network topology\n")
    
    print("Indicators of ARP Spoofing:")
    print("-" * 40)
    print("  • IP address with changing MAC addresses")
    print("  • Duplicate IP addresses on the network")
    print("  • High rate of ARP replies")
    print("  • Gratuitous ARP packets from unexpected sources")
    print("  • ARP replies to non-existent requests")

def arp_cache_poisoning_demo():
    """Demonstrate ARP cache poisoning concepts."""
    
    print("\n" + "=" * 60)
    print("ARP CACHE POISONING DEMONSTRATION")
    print("=" * 60 + "\n")
    
    print("Normal ARP Cache:")
    print("-" * 40)
    arp_cache = {
        "192.168.1.1": "aa:bb:cc:dd:ee:ff",
        "192.168.1.100": "00:11:22:33:44:55",
        "192.168.1.101": "66:77:88:99:aa:bb"
    }
    for ip, mac in arp_cache.items():
        print(f"  {ip} -> {mac}")
    
    print("\nAfter ARP Spoofing Attack:")
    print("-" * 40)
    poisoned_cache = {
        "192.168.1.1": "00:11:22:33:44:55",  # Attacker's MAC
        "192.168.1.100": "00:11:22:33:44:55",  # Attacker's MAC
        "192.168.1.101": "66:77:88:99:aa:bb"
    }
    for ip, mac in poisoned_cache.items():
        marker = "⚠️" if mac == "00:11:22:33:44:55" else " "
        print(f"  {marker} {ip} -> {mac}")
    
    print("\nConsequences:")
    print("-" * 40)
    print(f"  • Traffic to 192.168.1.1 goes to attacker")
    print(f"  • Traffic to 192.168.1.100 goes to attacker")
    print(f"  • Attacker can intercept, log, or modify traffic")

def main():
    """Main function for ARP spoofing basics."""
    
    print("=" * 60)
    print("ARP SPOOFING BASICS")
    print("=" * 60)
    
    demonstrate_arp_spoofing_packets()
    explain_arp_spoofing_risks()
    arp_cache_poisoning_demo()
    
    print("\n" + "=" * 60)
    print("Remember: ARP spoofing is illegal on networks you don't own.")
    print("Always practice in isolated lab environments.")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### Step 2: ARP Spoofing Detector

Create `src/arp_spoofing_detector.py`:

```python
#!/usr/bin/env python3
"""
Module 5, Part 1: ARP Spoofing Detector

This script provides real-time ARP spoofing detection
with alerting and logging capabilities.
"""

from scapy.all import sniff, ARP, Ether, get_if_hwaddr, conf, get_if_list
from scapy.all import wrpcap, rdpcap
import os
import sys
import time
import json
import threading
from datetime import datetime
from collections import defaultdict, deque

class ARPSpoofingDetector:
    """
    Real-time ARP spoofing detector.
    
    Features:
    - IP-MAC mapping validation
    - MAC change detection
    - Gratuitous ARP monitoring
    - ARP request/response rate analysis
    - Alerting and logging
    - PCAP export
    """
    
    def __init__(self, interface=None, log_file=None, threshold_requests=10,
                 threshold_replies=10, window_seconds=5):
        """
        Initialize ARP spoofing detector.
        
        Args:
            interface: Network interface
            log_file: Log file path
            threshold_requests: Max ARP requests per second (alert threshold)
            threshold_replies: Max ARP replies per second (alert threshold)
            window_seconds: Rate calculation window
        """
        self.interface = interface or conf.iface
        self.threshold_requests = threshold_requests
        self.threshold_replies = threshold_replies
        self.window_seconds = window_seconds
        
        # State tracking
        self.ip_mac_mapping = {}
        self.mac_to_ip = defaultdict(set)
        self.suspicious_activity = []
        self.arps = []
        self.packet_count = 0
        
        # Rate tracking
        self.arp_requests = deque(maxlen=1000)
        self.arp_replies = deque(maxlen=1000)
        self.rate_lock = threading.Lock()
        
        # Statistics
        self.stats = {
            'total_arps': 0,
            'requests': 0,
            'replies': 0,
            'gratuitous': 0,
            'suspicious': 0,
            'mac_changes': 0,
            'duplicate_ips': 0
        }
        
        # Alert history
        self.alerts = []
        self.alert_triggered = {}
        
        # Logging
        self.log_file = log_file or f"arp_detector_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        
        # Running state
        self.running = True
        
        print(f"\n[ARP Detector] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Log file: {self.log_file}")
        print(f"  Request threshold: {threshold_requests}/s")
        print(f"  Reply threshold: {threshold_replies}/s")
        print(f"  Window: {window_seconds}s")
    
    def log_event(self, message, level="INFO"):
        """Log event to file and console."""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"[{timestamp}] [{level}] {message}"
        
        # Print to console with color
        if level == "ALERT":
            print(f"\n⚠️ {log_entry}")
        elif level == "WARNING":
            print(f"  ⚠️ {message}")
        else:
            print(f"  {message}")
        
        # Write to log file
        with open(self.log_file, 'a') as f:
            f.write(log_entry + '\n')
    
    def check_mac_change(self, ip, new_mac, packet):
        """Check for MAC address changes (potential spoofing)."""
        if ip in self.ip_mac_mapping:
            old_mac = self.ip_mac_mapping[ip]
            if old_mac != new_mac:
                # MAC change detected
                self.stats['mac_changes'] += 1
                self.suspicious_activity.append({
                    'type': 'MAC_Change',
                    'ip': ip,
                    'old_mac': old_mac,
                    'new_mac': new_mac,
                    'timestamp': datetime.fromtimestamp(packet.time),
                    'packet': packet
                })
                
                self.log_event(
                    f"MAC change for {ip}: {old_mac} -> {new_mac}",
                    "ALERT"
                )
                
                # Add to alert history
                self.alerts.append({
                    'type': 'MAC_Change',
                    'ip': ip,
                    'old_mac': old_mac,
                    'new_mac': new_mac,
                    'timestamp': datetime.fromtimestamp(packet.time)
                })
                
                return True
        
        # Update mapping
        self.ip_mac_mapping[ip] = new_mac
        return False
    
    def check_gratuitous_arp(self, arp, packet):
        """Check for gratuitous ARP (common in spoofing)."""
        if arp.psrc == arp.pdst:
            self.stats['gratuitous'] += 1
            
            # Check if this is suspicious (multiple gratuitous ARPs from same source)
            key = f"{arp.psrc}:{arp.hwsrc}"
            if key not in self.alert_triggered:
                self.alert_triggered[key] = 0
            self.alert_triggered[key] += 1
            
            if self.alert_triggered[key] > 3:  # More than 3 gratuitous ARPs
                self.log_event(
                    f"Excessive gratuitous ARP from {arp.psrc} ({arp.hwsrc}) - potential spoofing",
                    "WARNING"
                )
                
                self.suspicious_activity.append({
                    'type': 'Gratuitous_ARP',
                    'ip': arp.psrc,
                    'mac': arp.hwsrc,
                    'count': self.alert_triggered[key],
                    'timestamp': datetime.fromtimestamp(packet.time),
                    'packet': packet
                })
                
                return True
        
        return False
    
    def check_rate_anomaly(self, packet, is_request):
        """Check for anomalous ARP rates."""
        now = time.time()
        
        with self.rate_lock:
            if is_request:
                self.arp_requests.append(now)
                # Count requests in window
                recent_requests = [t for t in self.arp_requests if now - t <= self.window_seconds]
                request_rate = len(recent_requests) / self.window_seconds
                
                if request_rate > self.threshold_requests:
                    self.log_event(
                        f"High ARP request rate: {request_rate:.1f}/s ({len(recent_requests)} in {self.window_seconds}s)",
                        "WARNING"
                    )
                    return True
            else:
                self.arp_replies.append(now)
                recent_replies = [t for t in self.arp_replies if now - t <= self.window_seconds]
                reply_rate = len(recent_replies) / self.window_seconds
                
                if reply_rate > self.threshold_replies:
                    self.log_event(
                        f"High ARP reply rate: {reply_rate:.1f}/s ({len(recent_replies)} in {self.window_seconds}s)",
                        "WARNING"
                    )
                    return True
        
        return False
    
    def check_duplicate_ip(self, ip, mac, packet):
        """Check for duplicate IP addresses."""
        for existing_mac in self.mac_to_ip[ip]:
            if existing_mac != mac:
                self.stats['duplicate_ips'] += 1
                self.log_event(
                    f"Duplicate IP detected: {ip} claimed by {mac} and {existing_mac}",
                    "ALERT"
                )
                
                self.suspicious_activity.append({
                    'type': 'Duplicate_IP',
                    'ip': ip,
                    'mac1': existing_mac,
                    'mac2': mac,
                    'timestamp': datetime.fromtimestamp(packet.time),
                    'packet': packet
                })
                
                self.alerts.append({
                    'type': 'Duplicate_IP',
                    'ip': ip,
                    'mac1': existing_mac,
                    'mac2': mac,
                    'timestamp': datetime.fromtimestamp(packet.time)
                })
                
                return True
        
        return False
    
    def process_arp_packet(self, packet):
        """Process an ARP packet for spoofing detection."""
        if not packet.haslayer(ARP):
            return
        
        self.packet_count += 1
        self.stats['total_arps'] += 1
        
        arp = packet[ARP]
        is_request = (arp.op == 1)
        
        # Update statistics
        if is_request:
            self.stats['requests'] += 1
        else:
            self.stats['replies'] += 1
        
        # Check rate anomalies
        self.check_rate_anomaly(packet, is_request)
        
        # Get key fields
        src_ip = arp.psrc
        src_mac = arp.hwsrc
        dst_ip = arp.pdst
        dst_mac = arp.hwdst
        
        # Skip if source IP is 0.0.0.0 (often used in DHCP)
        if src_ip == '0.0.0.0':
            return
        
        # Track MAC to IP mapping
        self.mac_to_ip[src_ip].add(src_mac)
        
        # Check for duplicate IPs
        self.check_duplicate_ip(src_ip, src_mac, packet)
        
        # Check for gratuitous ARP
        self.check_gratuitous_arp(arp, packet)
        
        # Check for MAC changes
        self.check_mac_change(src_ip, src_mac, packet)
        
        # Store ARP packet for analysis
        self.arps.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'src_ip': src_ip,
            'src_mac': src_mac,
            'dst_ip': dst_ip,
            'dst_mac': dst_mac,
            'op': 'Request' if is_request else 'Reply',
            'is_gratuitous': (src_ip == dst_ip)
        })
        
        # Periodic status update
        if self.packet_count % 50 == 0:
            self.log_event(
                f"Processed {self.packet_count} ARP packets | "
                f"Requests: {self.stats['requests']}, "
                f"Replies: {self.stats['replies']}, "
                f"Suspicious: {self.stats['suspicious']}",
                "INFO"
            )
    
    def monitor_live(self, timeout=None, save_pcap=False):
        """Start live ARP monitoring."""
        
        print("\n" + "=" * 60)
        print("ARP SPOOFING DETECTOR - LIVE MODE")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print(f"Log file: {self.log_file}")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        start_time = time.time()
        captured_packets = [] if save_pcap else None
        
        try:
            sniff(
                iface=self.interface,
                filter="arp",
                prn=self.process_arp_packet,
                timeout=timeout,
                store=save_pcap
            )
        except KeyboardInterrupt:
            print("\n\nStopping detector...")
        except Exception as e:
            print(f"Error during monitoring: {e}")
        finally:
            elapsed = time.time() - start_time
            self.display_summary(elapsed)
            
            if save_pcap and captured_packets:
                pcap_file = f"output/arp_capture_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pcap"
                os.makedirs("output", exist_ok=True)
                wrpcap(pcap_file, captured_packets)
                print(f"\nARP traffic saved to: {pcap_file}")
    
    def analyze_pcap(self, pcap_file):
        """Analyze a PCAP file for ARP spoofing."""
        
        print(f"\n[ARP Detector] Analyzing PCAP: {pcap_file}")
        
        packets = rdpcap(pcap_file)
        print(f"Processing {len(packets)} packets...")
        
        for packet in packets:
            self.process_arp_packet(packet)
        
        self.display_summary()
    
    def display_summary(self, elapsed=0):
        """Display detection summary."""
        
        print("\n" + "=" * 60)
        print("ARP SPOOFING DETECTION SUMMARY")
        print("=" * 60)
        
        if elapsed > 0:
            print(f"Duration: {elapsed:.2f}s")
        print(f"Total ARP Packets: {self.stats['total_arps']}")
        print(f"ARP Requests: {self.stats['requests']}")
        print(f"ARP Replies: {self.stats['replies']}")
        print(f"Gratuitous ARPs: {self.stats['gratuitous']}")
        print(f"Suspicious Events: {self.stats['suspicious']}")
        print(f"MAC Changes Detected: {self.stats['mac_changes']}")
        print(f"Duplicate IPs Detected: {self.stats['duplicate_ips']}")
        
        if self.suspicious_activity:
            print(f"\n⚠️ Suspicious Activity Detected:")
            print("-" * 40)
            for activity in self.suspicious_activity[-10:]:  # Show last 10
                timestamp = activity.get('timestamp', 'Unknown')
                event_type = activity.get('type', 'Unknown')
                
                if event_type == 'MAC_Change':
                    print(f"  {timestamp}: MAC change - {activity['ip']} ({activity['old_mac']} -> {activity['new_mac']})")
                elif event_type == 'Duplicate_IP':
                    print(f"  {timestamp}: Duplicate IP - {activity['ip']} claimed by {activity['mac1']} and {activity['mac2']}")
                elif event_type == 'Gratuitous_ARP':
                    print(f"  {timestamp}: Excessive gratuitous ARP - {activity['ip']} ({activity['mac']})")
            
            if len(self.suspicious_activity) > 10:
                print(f"  ... and {len(self.suspicious_activity) - 10} more")
        
        print("\nCurrent ARP Cache (IP -> MAC):")
        print("-" * 40)
        for ip, mac in sorted(self.ip_mac_mapping.items())[:10]:
            print(f"  {ip} -> {mac}")
        if len(self.ip_mac_mapping) > 10:
            print(f"  ... and {len(self.ip_mac_mapping) - 10} more")
        
        print("\n" + "=" * 60)
    
    def export_results(self, filename=None):
        """Export detection results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/arp_detection_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'interface': self.interface,
            'stats': self.stats,
            'alerts': self.alerts[-100:],  # Last 100 alerts
            'suspicious_activity': self.suspicious_activity[-100:],
            'arp_cache': self.ip_mac_mapping
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"\nResults exported to: {filename}")

def main():
    """Main function for ARP spoofing detector."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='ARP Spoofing Detector')
    parser.add_argument('file', nargs='?', help='PCAP file to analyze')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-t', '--timeout', type=int, help='Capture timeout in seconds')
    parser.add_argument('--requests', type=int, default=10,
                        help='ARP request threshold per second')
    parser.add_argument('--replies', type=int, default=10,
                        help='ARP reply threshold per second')
    parser.add_argument('--window', type=int, default=5,
                        help='Rate calculation window in seconds')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    parser.add_argument('-p', '--pcap', action='store_true',
                        help='Save ARP traffic to PCAP')
    parser.add_argument('-l', '--log', help='Log file path')
    
    args = parser.parse_args()
    
    # Create detector
    detector = ARPSpoofingDetector(
        interface=args.interface or conf.iface,
        log_file=args.log,
        threshold_requests=args.requests,
        threshold_replies=args.replies,
        window_seconds=args.window
    )
    
    if args.file:
        detector.analyze_pcap(args.file)
        if args.export:
            detector.export_results()
    else:
        detector.monitor_live(timeout=args.timeout, save_pcap=args.pcap)
        if args.export:
            detector.export_results()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("ARP SPOOFING DETECTOR")
        print("=" * 60)
        
        choice = input("\nAnalyze PCAP file or sniff live? (pcap/live): ").strip().lower()
        
        detector = ARPSpoofingDetector()
        
        if choice == 'pcap':
            file_path = input("Enter PCAP file path: ").strip()
            if file_path:
                detector.analyze_pcap(file_path)
                export = input("Export results to JSON? (y/n): ").strip().lower()
                if export == 'y':
                    detector.export_results()
        else:
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
            
            detector = ARPSpoofingDetector(interface=interface)
            detector.monitor_live(save_pcap=True)
    else:
        main()
```

### Step 3: ARP Security Monitor

Create `src/arp_security_monitor.py`:

```python
#!/usr/bin/env python3
"""
Module 5, Part 1: ARP Security Monitor

This script provides a comprehensive ARP security monitoring
system with multiple detection techniques.
"""

from scapy.all import sniff, ARP, Ether, IP, ICMP, sr1, get_if_hwaddr, conf
from scapy.all import get_if_list, wrpcap, rdpcap
import os
import sys
import time
import json
import threading
from datetime import datetime
from collections import defaultdict, deque
import socket

class ARPSecurityMonitor:
    """
    Comprehensive ARP security monitoring system.
    
    Features:
    - IP-MAC binding validation
    - MAC address vendor lookup
    - ARP poisoning detection
    - DHCP snooping integration
    - Active probing for validation
    - Alert correlation
    - Historical trend analysis
    """
    
    def __init__(self, interface=None, bindings_file=None, probe_interval=60):
        """
        Initialize ARP security monitor.
        
        Args:
            interface: Network interface
            bindings_file: Static IP-MAC bindings file
            probe_interval: Active probe interval in seconds
        """
        self.interface = interface or conf.iface
        self.probe_interval = probe_interval
        
        # IP-MAC bindings (static and learned)
        self.static_bindings = {}
        self.learned_bindings = {}
        self.binding_history = defaultdict(list)
        
        # Load static bindings
        if bindings_file and os.path.exists(bindings_file):
            self.load_bindings(bindings_file)
        
        # State tracking
        self.arp_requests = defaultdict(int)
        self.arp_replies = defaultdict(int)
        self.arp_cache = {}
        self.alert_history = []
        self.packet_count = 0
        
        # Vendor OUI database
        self.oui_db = self.load_oui_database()
        
        # Statistics
        self.stats = {
            'total_arps': 0,
            'requests': 0,
            'replies': 0,
            'gratuitous': 0,
            'alerts': 0,
            'binding_violations': 0,
            'probes_sent': 0,
            'probe_responses': 0
        }
        
        # Running state
        self.running = True
        self.probe_thread = None
        
        print(f"\n[ARP Security] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Static bindings: {len(self.static_bindings)}")
        print(f"  Probe interval: {probe_interval}s")
    
    def load_bindings(self, bindings_file):
        """Load static IP-MAC bindings from file."""
        try:
            with open(bindings_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        parts = line.split()
                        if len(parts) >= 2:
                            ip = parts[0]
                            mac = parts[1]
                            self.static_bindings[ip] = mac
                            print(f"  Loaded binding: {ip} -> {mac}")
        except Exception as e:
            print(f"Error loading bindings: {e}")
    
    def load_oui_database(self):
        """Load OUI database for vendor identification."""
        # Simplified OUI database
        return {
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
        oui = mac[:8].upper()
        return self.oui_db.get(oui, "Unknown")
    
    def validate_binding(self, ip, mac):
        """Validate IP-MAC binding against static bindings."""
        if ip in self.static_bindings:
            if self.static_bindings[ip] != mac:
                self.stats['binding_violations'] += 1
                self.alert({
                    'type': 'Binding Violation',
                    'ip': ip,
                    'expected_mac': self.static_bindings[ip],
                    'observed_mac': mac,
                    'severity': 'HIGH'
                })
                return False
        return True
    
    def alert(self, alert_data):
        """Handle an alert."""
        alert_data['timestamp'] = datetime.now().isoformat()
        self.alert_history.append(alert_data)
        self.stats['alerts'] += 1
        
        # Print alert with severity
        severity = alert_data.get('severity', 'MEDIUM')
        icon = "🔴" if severity == "HIGH" else "🟡" if severity == "MEDIUM" else "🟢"
        
        print(f"\n{icon} ALERT: {alert_data['type']}")
        print(f"  Severity: {severity}")
        for key, value in alert_data.items():
            if key not in ['type', 'severity', 'timestamp']:
                print(f"  {key}: {value}")
    
    def process_arp_packet(self, packet):
        """Process ARP packet for security monitoring."""
        if not packet.haslayer(ARP):
            return
        
        self.packet_count += 1
        self.stats['total_arps'] += 1
        
        arp = packet[ARP]
        is_request = (arp.op == 1)
        
        if is_request:
            self.stats['requests'] += 1
            self.arp_requests[arp.pdst] += 1
        else:
            self.stats['replies'] += 1
            self.arp_replies[arp.psrc] += 1
        
        # Get key fields
        src_ip = arp.psrc
        src_mac = arp.hwsrc
        dst_ip = arp.pdst
        
        # Skip 0.0.0.0 source (common in DHCP)
        if src_ip == '0.0.0.0':
            return
        
        # Validate against static bindings
        if not self.validate_binding(src_ip, src_mac):
            self.alert({
                'type': 'Static Binding Violation',
                'ip': src_ip,
                'expected_mac': self.static_bindings.get(src_ip),
                'observed_mac': src_mac,
                'vendor': self.get_vendor(src_mac),
                'severity': 'HIGH'
            })
        
        # Check for duplicate IP
        if src_ip in self.arp_cache and self.arp_cache[src_ip] != src_mac:
            self.alert({
                'type': 'Duplicate IP',
                'ip': src_ip,
                'mac1': self.arp_cache[src_ip],
                'mac2': src_mac,
                'vendor1': self.get_vendor(self.arp_cache[src_ip]),
                'vendor2': self.get_vendor(src_mac),
                'severity': 'HIGH'
            })
        
        # Check for MAC change
        if src_ip in self.learned_bindings:
            old_mac = self.learned_bindings[src_ip]
            if old_mac != src_mac:
                self.alert({
                    'type': 'MAC Change',
                    'ip': src_ip,
                    'old_mac': old_mac,
                    'new_mac': src_mac,
                    'old_vendor': self.get_vendor(old_mac),
                    'new_vendor': self.get_vendor(src_mac),
                    'severity': 'MEDIUM'
                })
        
        # Update learned bindings
        self.learned_bindings[src_ip] = src_mac
        self.arp_cache[src_ip] = src_mac
        
        # Check for gratuitous ARP
        if src_ip == dst_ip:
            self.stats['gratuitous'] += 1
            if self.arp_requests[src_ip] > 5:  # Multiple gratuitous ARPs
                self.alert({
                    'type': 'Excessive Gratuitous ARP',
                    'ip': src_ip,
                    'mac': src_mac,
                    'count': self.arp_requests[src_ip],
                    'severity': 'MEDIUM'
                })
        
        # Periodic statistics
        if self.packet_count % 100 == 0:
            print(f"\n[Stats] Processed {self.packet_count} ARP packets")
            print(f"  Active hosts: {len(self.learned_bindings)}")
            print(f"  Alerts: {self.stats['alerts']}")
    
    def active_probe(self, ip):
        """
        Actively probe an IP to verify its MAC address.
        
        Returns:
            bool: True if MAC matches learned binding
        """
        try:
            # Send ARP request and wait for reply
            arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                          ARP(op=1, pdst=ip)
            
            reply = sr1(arp_request, timeout=2, verbose=False)
            self.stats['probes_sent'] += 1
            
            if reply and reply.haslayer(ARP):
                self.stats['probe_responses'] += 1
                observed_mac = reply[ARP].hwsrc
                
                if ip in self.learned_bindings:
                    expected_mac = self.learned_bindings[ip]
                    if observed_mac != expected_mac:
                        self.alert({
                            'type': 'Active Probe Mismatch',
                            'ip': ip,
                            'expected_mac': expected_mac,
                            'observed_mac': observed_mac,
                            'severity': 'HIGH'
                        })
                        return False
                
                return True
            
            return False
            
        except Exception as e:
            return False
    
    def probe_loop(self):
        """Continuous active probing loop."""
        while self.running:
            try:
                # Get list of known IPs
                ips = list(self.learned_bindings.keys())
                
                if ips:
                    # Probe each IP
                    for ip in ips[:10]:  # Limit to 10 per cycle
                        if not self.running:
                            break
                        self.active_probe(ip)
                        time.sleep(1)  # 1 second between probes
                
                # Wait for next probe cycle
                time.sleep(self.probe_interval - 10)  # Adjust for probe time
                
            except Exception as e:
                print(f"Error in probe loop: {e}")
                time.sleep(5)
    
    def monitor_live(self, timeout=None):
        """Start live ARP security monitoring."""
        
        print("\n" + "=" * 60)
        print("ARP SECURITY MONITOR - LIVE MODE")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print(f"Static bindings: {len(self.static_bindings)}")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        # Start probe thread if interval > 0
        if self.probe_interval > 0:
            self.probe_thread = threading.Thread(target=self.probe_loop)
            self.probe_thread.daemon = True
            self.probe_thread.start()
        
        try:
            sniff(
                iface=self.interface,
                filter="arp",
                prn=self.process_arp_packet,
                timeout=timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\n\nStopping monitor...")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.running = False
            if self.probe_thread:
                self.probe_thread.join(timeout=2)
            self.display_summary()
    
    def analyze_pcap(self, pcap_file):
        """Analyze PCAP for ARP security issues."""
        
        print(f"\n[ARP Security] Analyzing PCAP: {pcap_file}")
        
        packets = rdpcap(pcap_file)
        print(f"Processing {len(packets)} packets...")
        
        for packet in packets:
            self.process_arp_packet(packet)
        
        self.display_summary()
    
    def display_summary(self):
        """Display security monitoring summary."""
        
        print("\n" + "=" * 60)
        print("ARP SECURITY MONITOR SUMMARY")
        print("=" * 60)
        
        print(f"Total ARP Packets: {self.stats['total_arps']}")
        print(f"ARP Requests: {self.stats['requests']}")
        print(f"ARP Replies: {self.stats['replies']}")
        print(f"Gratuitous ARPs: {self.stats['gratuitous']}")
        print(f"Total Alerts: {self.stats['alerts']}")
        print(f"Binding Violations: {self.stats['binding_violations']}")
        print(f"Active Probes Sent: {self.stats['probes_sent']}")
        print(f"Probe Responses: {self.stats['probe_responses']}")
        
        print(f"\nActive Hosts: {len(self.learned_bindings)}")
        print("-" * 40)
        for ip, mac in sorted(self.learned_bindings.items())[:10]:
            vendor = self.get_vendor(mac)
            status = "✓" if ip in self.static_bindings and self.static_bindings[ip] == mac else " "
            print(f"  {status} {ip} -> {mac} ({vendor})")
        if len(self.learned_bindings) > 10:
            print(f"  ... and {len(self.learned_bindings) - 10} more")
        
        if self.alert_history:
            print(f"\nRecent Alerts ({len(self.alert_history)} total):")
            print("-" * 40)
            for alert in self.alert_history[-10:]:
                severity = alert.get('severity', 'MEDIUM')
                icon = "🔴" if severity == "HIGH" else "🟡" if severity == "MEDIUM" else "🟢"
                print(f"  {icon} {alert['type']}: {alert.get('ip', '')}")
                if 'expected_mac' in alert:
                    print(f"      Expected: {alert['expected_mac']}, Got: {alert['observed_mac']}")
        
        print("\n" + "=" * 60)
    
    def export_results(self, filename=None):
        """Export security monitor results."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/arp_security_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'interface': self.interface,
            'stats': self.stats,
            'learned_bindings': self.learned_bindings,
            'static_bindings': self.static_bindings,
            'alerts': self.alert_history
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"\nResults exported to: {filename}")

def main():
    """Main function for ARP security monitor."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='ARP Security Monitor')
    parser.add_argument('file', nargs='?', help='PCAP file to analyze')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-b', '--bindings', help='Static IP-MAC bindings file')
    parser.add_argument('-p', '--probe-interval', type=int, default=60,
                        help='Active probe interval in seconds')
    parser.add_argument('-t', '--timeout', type=int, help='Capture timeout')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    
    args = parser.parse_args()
    
    monitor = ARPSecurityMonitor(
        interface=args.interface or conf.iface,
        bindings_file=args.bindings,
        probe_interval=args.probe_interval
    )
    
    if args.file:
        monitor.analyze_pcap(args.file)
        if args.export:
            monitor.export_results()
    else:
        monitor.monitor_live(timeout=args.timeout)
        if args.export:
            monitor.export_results()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("ARP SECURITY MONITOR")
        print("=" * 60)
        
        choice = input("\nAnalyze PCAP file or sniff live? (pcap/live): ").strip().lower()
        
        monitor = ARPSecurityMonitor()
        
        if choice == 'pcap':
            file_path = input("Enter PCAP file path: ").strip()
            if file_path:
                monitor.analyze_pcap(file_path)
                export = input("Export results to JSON? (y/n): ").strip().lower()
                if export == 'y':
                    monitor.export_results()
        else:
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
            
            bindings_file = input("Static bindings file (optional): ").strip()
            
            monitor = ARPSecurityMonitor(
                interface=interface,
                bindings_file=bindings_file if bindings_file else None
            )
            monitor.monitor_live()
    else:
        main()
```

---

## The Verification: Testing ARP Detection Tools

### Verification 1: Test ARP Spoofing Basics

```bash
cd ~/scapy-tutorial
python3 src/arp_spoofing_basics.py
```

**Expected output**: ARP spoofing concept demonstrations and packet examples.

### Verification 2: Test ARP Spoofing Detector

```bash
# Monitor for ARP spoofing (may need sudo)
sudo python3 src/arp_spoofing_detector.py -i eth0 --export
```

**Expected output**: Real-time ARP monitoring with detection alerts.

### Verification 3: Test ARP Security Monitor

```bash
# With static bindings
echo "192.168.1.1 aa:bb:cc:dd:ee:ff" > bindings.txt
sudo python3 src/arp_security_monitor.py -i eth0 -b bindings.txt -p 30
```

**Expected output**: ARP security monitoring with active probing and validation.

### Verification 4: Quick ARP Detection Tests

```bash
# Generate ARP traffic for testing
sudo python3 -c "from scapy.all import Ether, ARP, send; send(Ether(dst='ff:ff:ff:ff:ff:ff')/ARP(op=1, pdst='192.168.1.1'))"

# Check ARP cache
arp -n

# Simulate ARP spoofing (in lab only!)
sudo python3 -c "from scapy.all import Ether, ARP, send; send(Ether(dst='ff:ff:ff:ff:ff:ff')/ARP(op=2, psrc='192.168.1.1', hwsrc='00:11:22:33:44:55', pdst='192.168.1.100'))"
```

---

## Reference: ARP Security Quick Reference

### ARP Spoofing Detection Methods

| Method | Description | Effectiveness |
|--------|-------------|---------------|
| IP-MAC Binding | Verify static mappings | High |
| MAC Change Detection | Monitor for changes | Medium |
| Gratuitous ARP Monitoring | Detect unsolicited announcements | Medium |
| Rate Analysis | Detect floods | Low-Medium |
| Active Probing | Verify with additional requests | High |
| Duplicate IP Detection | Find IP conflicts | Medium |

### ARP Attack Indicators

| Indicator | Description | Severity |
|-----------|-------------|----------|
| MAC Change | IP has different MAC | HIGH |
| Duplicate IP | IP claimed by multiple MACs | HIGH |
| High ARP Rate | Unusual volume of ARP traffic | MEDIUM |
| Gratuitous ARP | Unsolicited MAC announcements | MEDIUM |
| ARP Cache Poisoning | Man-in-the-middle attack | HIGH |

### Response Actions

| Action | Description | When to Use |
|--------|-------------|-------------|
| Alert | Log and notify | All detections |
| Block | Drop packets from source | Confirmed attack |
| Remediate | Fix ARP cache | After attack confirmed |
| Investigate | Analyze attack origin | All detections |

---

## Common Pitfalls and Best Practices

### Pitfall 1: False Positives

```python
# DON'T: Alert on normal DHCP traffic
if src_ip == '0.0.0.0':  # DHCP client
    alert()  # Would cause false positives

# DO: Skip known legitimate sources
if src_ip == '0.0.0.0':
    return  # Skip DHCP initial requests
```

### Pitfall 2: Not Handling Dynamic Environments

```python
# DON'T: Only use static bindings
# Will alert on legitimate changes

# DO: Allow learning with thresholds
if binding_changed and not learning_mode:
    alert()
```

### Best Practice: Implement Alert Throttling

```python
class AlertThrottle:
    def __init__(self, max_alerts=5, window=60):
        self.max_alerts = max_alerts
        self.window = window
        self.alerts = deque(maxlen=100)
    
    def should_alert(self, alert_key):
        # Count alerts for this key in the window
        now = time.time()
        recent = [a for a in self.alerts 
                  if a['key'] == alert_key and now - a['timestamp'] < self.window]
        return len(recent) < self.max_alerts
```

### Best Practice: Validate Before Alerting

```python
def validate_alert(ip, mac):
    """Validate before alerting to reduce false positives."""
    # Check if this is a known DHCP server
    if ip in dhcp_servers:
        return False
    
    # Check if we've seen this MAC before
    if mac in trusted_macs:
        return False
    
    # Additional validation...
    return True
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ ARP spoofing mechanics and risks
2. ✅ Real-time ARP spoofing detection
3. ✅ IP-MAC binding validation
4. ✅ Gratuitous ARP monitoring
5. ✅ Active probing for verification
6. ✅ Comprehensive ARP security monitoring

---

## Next Steps: Preview of Part 2

In **Module 5, Part 2: Packet Injection and Replay**, we'll:

1. Implement packet injection techniques
2. Build packet replay utilities
3. Create custom payload generators
4. Develop security testing tools
5. Implement safety controls

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 5, PART 1 COMPLETE                                  │
│  ✅ ARP spoofing basics understood                                  │
│  ✅ ARP spoofing detector built                                     │
│  ✅ ARP security monitor created                                    │
│  ✅ IP-MAC binding validation implemented                          │
│  ✅ Active probing system developed                                │
│  NEXT: MODULE 5, PART 2 — Packet Injection and Replay             │
│  ● Packet injection techniques                                     │
│  ● Packet replay utilities                                         │
│  ● Custom payload generation                                       │
│  ● Security testing tools                                         │
│  ● Safety controls                                                │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 2, where we'll build packet injection and replay tools — learning how to modify, replay, and inject packets for authorized security testing.*
