# Mastering Network Packet Crafting with Scapy
## Module 3: Transport Layer Protocols & Reconnaissance
### Part 2: Port Scanning Techniques

## The Target: Building Professional Port Scanners

In this part, we'll build professional-grade port scanning tools. By the end, you'll be able to:

1. Understand different port scanning techniques
2. Build a TCP SYN scanner (half-open scanning)
3. Implement TCP Connect scanning
4. Create UDP scanners
5. Build multi-threaded scanning engines
6. Implement service detection and banner grabbing
7. Create a comprehensive port scanner with all features

---

## The Concept: Port Scanning as Door Checking

Think of port scanning as **checking doors on a building**:

- **TCP SYN scan**: Like **knocking quickly** and seeing if someone responds (half-open)
- **TCP Connect scan**: Like **fully knocking, introducing yourself, and waiting for response** (full 3-way handshake)
- **UDP scan**: Like **sending a letter** and hoping for a reply (fire-and-forget)
- **FIN/NULL/XMAS scans**: Like **trying different door-opening techniques** (stealth scans)

```
TCP SYN Scan (Half-Open):
┌──────┐                ┌──────┐
│Client│                │Server│
└──┬───┘                └──┬───┘
   │    SYN (port open?)   │
   │──────────────────────>│
   │                        │
   │    SYN-ACK (open)     │
   │<──────────────────────│
   │                        │
   │    RST (abort)        │
   │──────────────────────>│
   │                        │
   │  Port is OPEN         │
   │                        │
   │    SYN (port open?)   │
   │──────────────────────>│
   │                        │
   │    RST (closed)       │
   │<──────────────────────│
   │                        │
   │  Port is CLOSED       │
```

**Key insight**: Different scan types work for different situations. SYN scans are faster and stealthier, Connect scans work without raw sockets, UDP scans require special handling due to the stateless nature of UDP.

---

## The Implementation: Building Port Scanners

### Step 1: TCP SYN Scanner

Create `src/tcp_syn_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 3, Part 2: TCP SYN Scanner

This script implements a professional TCP SYN (half-open) port scanner
using Scapy.
"""

from scapy.all import IP, TCP, sr1, sr, conf
from scapy.all import RandIP, RandShort
import time
import sys
import threading
from datetime import datetime
import argparse
from queue import Queue
import ipaddress

class TCPSYNScanner:
    """
    TCP SYN port scanner (half-open scanning).
    
    Features:
    - SYN scanning (stealth)
    - Multi-threaded scanning
    - Port range specification
    - Timeout handling
    - Result reporting
    - Rate limiting
    """
    
    def __init__(self, target, ports=None, threads=10, timeout=2, 
                 rate_limit=None, source_ip=None):
        """
        Initialize SYN scanner.
        
        Args:
            target: Target IP address or hostname
            ports: List of ports or port range (e.g., "1-1000")
            threads: Number of scanning threads
            timeout: Timeout in seconds per SYN probe
            rate_limit: Max packets per second (None for unlimited)
            source_ip: Source IP address (optional)
        """
        self.target = target
        self.ports = self.parse_ports(ports) if ports else list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.rate_limit = rate_limit
        self.source_ip = source_ip
        
        self.open_ports = []
        self.closed_ports = []
        self.filtered_ports = []
        self.scanned_ports = []
        self.port_queue = Queue()
        self.results_lock = threading.Lock()
        self.rate_lock = threading.Lock()
        self.last_packet_time = 0
        
        # Statistics
        self.total_scanned = 0
        self.start_time = None
        
        print(f"\n[SYN SCAN] Target: {self.target}")
        print(f"[SYN SCAN] Ports to scan: {len(self.ports)}")
        print(f"[SYN SCAN] Threads: {self.threads}")
        print(f"[SYN SCAN] Timeout: {self.timeout}s")
        if rate_limit:
            print(f"[SYN SCAN] Rate limit: {rate_limit} packets/second")
    
    def parse_ports(self, port_spec):
        """Parse port specification (e.g., "1-1000,80,443")."""
        ports = []
        
        if isinstance(port_spec, list):
            return port_spec
        
        for part in port_spec.split(','):
            if '-' in part:
                start, end = part.split('-')
                ports.extend(range(int(start), int(end) + 1))
            else:
                ports.append(int(part))
        
        return ports
    
    def rate_limit_wait(self):
        """Apply rate limiting if configured."""
        if not self.rate_limit:
            return
        
        with self.rate_lock:
            current_time = time.time()
            time_since_last = current_time - self.last_packet_time
            min_interval = 1.0 / self.rate_limit
            
            if time_since_last < min_interval:
                time.sleep(min_interval - time_since_last)
            
            self.last_packet_time = time.time()
    
    def scan_port(self, port):
        """
        Scan a single port using SYN scan.
        
        Args:
            port: Port number to scan
        
        Returns:
            Tuple (port, status, response)
        """
        # Build SYN packet
        ip = IP(dst=self.target)
        if self.source_ip:
            ip.src = self.source_ip
        
        tcp = TCP(sport=RandShort(), dport=port, flags="S", seq=1000)
        packet = ip / tcp
        
        # Apply rate limiting
        self.rate_limit_wait()
        
        # Send SYN and wait for response
        start_time = time.time()
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        elapsed = time.time() - start_time
        
        self.total_scanned += 1
        
        # Analyze response
        if reply is None:
            # No response - likely filtered
            status = "filtered"
            return port, status, None
        
        if reply.haslayer(TCP):
            tcp_reply = reply[TCP]
            
            if tcp_reply.flags & 0x12:  # SYN-ACK
                # Port is open
                status = "open"
                # Send RST to close the connection (stealth)
                rst = IP(dst=self.target) / TCP(sport=tcp_reply.dport, 
                                               dport=port, 
                                               flags="R", 
                                               seq=tcp_reply.ack)
                send(rst, verbose=False)
                return port, status, reply
            elif tcp_reply.flags & 0x04:  # RST
                # Port is closed
                status = "closed"
                return port, status, reply
        
        # ICMP unreachable or other response
        if reply.haslayer(ICMP):
            status = "filtered"
            return port, status, reply
        
        # Default fallback
        status = "unknown"
        return port, status, reply
    
    def worker(self):
        """Worker thread for scanning ports."""
        while not self.port_queue.empty():
            try:
                port = self.port_queue.get_nowait()
                port, status, response = self.scan_port(port)
                
                with self.results_lock:
                    self.scanned_ports.append(port)
                    if status == "open":
                        self.open_ports.append(port)
                    elif status == "closed":
                        self.closed_ports.append(port)
                    else:
                        self.filtered_ports.append(port)
                    
                    # Progress indicator
                    if len(self.scanned_ports) % 100 == 0:
                        progress = (len(self.scanned_ports) / len(self.ports)) * 100
                        print(f"  Progress: {len(self.scanned_ports)}/{len(self.ports)} ports "
                              f"({progress:.1f}%) - {len(self.open_ports)} open")
                
                self.port_queue.task_done()
                
            except Exception as e:
                print(f"  Error scanning port: {e}")
                self.port_queue.task_done()
    
    def scan(self):
        """Execute the port scan."""
        
        print("\n[SYN SCAN] Starting scan...")
        print("-" * 60)
        
        # Fill queue with ports
        for port in self.ports:
            self.port_queue.put(port)
        
        self.start_time = time.time()
        
        # Create and start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for all threads to complete
        for t in threads:
            t.join()
        
        elapsed_time = time.time() - self.start_time
        
        # Display results
        self.display_results(elapsed_time)
        
        return {
            'open_ports': self.open_ports,
            'closed_ports': self.closed_ports,
            'filtered_ports': self.filtered_ports,
            'total': self.total_scanned,
            'elapsed_time': elapsed_time
        }
    
    def display_results(self, elapsed_time):
        """Display scan results."""
        
        print("\n" + "=" * 60)
        print("SYN SCAN RESULTS")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed_time:.2f} seconds")
        print(f"Ports scanned: {len(self.scanned_ports)}")
        print("-" * 60)
        
        if self.open_ports:
            print(f"\nOPEN PORTS ({len(self.open_ports)}):")
            print("-" * 40)
            print(f"{'Port':<10} {'Service':<20} {'Status':<10}")
            print("-" * 40)
            
            # Common service mapping
            services = {
                20: 'FTP-data', 21: 'FTP', 22: 'SSH', 23: 'Telnet',
                25: 'SMTP', 53: 'DNS', 80: 'HTTP', 110: 'POP3',
                111: 'RPC', 135: 'MSRPC', 139: 'NetBIOS', 143: 'IMAP',
                443: 'HTTPS', 445: 'SMB', 993: 'IMAPS', 995: 'POP3S',
                1723: 'PPTP', 3306: 'MySQL', 3389: 'RDP', 5432: 'PostgreSQL',
                5900: 'VNC', 6379: 'Redis', 8080: 'HTTP-Alt'
            }
            
            for port in sorted(self.open_ports):
                service = services.get(port, 'Unknown')
                print(f"{port:<10} {service:<20} Open")
        else:
            print("\nNo open ports found.")
        
        if self.filtered_ports:
            print(f"\nFILTERED PORTS ({len(self.filtered_ports)}):")
            print("-" * 40)
            print(f"  {len(self.filtered_ports)} ports are filtered (no response)")
        
        print("\n" + "=" * 60)
        print("SCAN COMPLETE")
        print("=" * 60)
    
    def export_results(self, filename=None):
        """Export scan results to file."""
        
        if not self.open_ports and not self.filtered_ports:
            print("No results to export")
            return
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/syn_scan_{self.target}_{timestamp}.txt"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        with open(filename, 'w') as f:
            f.write(f"SYN Scan Results for {self.target}\n")
            f.write(f"Date: {datetime.now()}\n")
            f.write("-" * 60 + "\n")
            f.write(f"Open Ports ({len(self.open_ports)}):\n")
            for port in sorted(self.open_ports):
                f.write(f"  {port}\n")
            f.write("\n")
            f.write(f"Filtered Ports ({len(self.filtered_ports)}):\n")
            for port in sorted(self.filtered_ports[:20]):  # Limit output
                f.write(f"  {port}\n")
            if len(self.filtered_ports) > 20:
                f.write(f"  ... and {len(self.filtered_ports) - 20} more\n")
        
        print(f"\nResults exported to: {filename}")

def main():
    """Command-line interface for SYN scanner."""
    
    parser = argparse.ArgumentParser(description='TCP SYN Port Scanner')
    parser.add_argument('target', help='Target IP address or hostname')
    parser.add_argument('-p', '--ports', default='1-1024',
                        help='Port range (e.g., 1-1000,80,443)')
    parser.add_argument('-t', '--threads', type=int, default=10,
                        help='Number of scanning threads')
    parser.add_argument('--timeout', type=float, default=2,
                        help='Timeout per SYN probe')
    parser.add_argument('-r', '--rate-limit', type=int,
                        help='Rate limit (packets per second)')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to file')
    parser.add_argument('-S', '--source', help='Source IP address')
    
    args = parser.parse_args()
    
    # Create scanner
    scanner = TCPSYNScanner(
        target=args.target,
        ports=args.ports,
        threads=args.threads,
        timeout=args.timeout,
        rate_limit=args.rate_limit,
        source_ip=args.source
    )
    
    # Run scan
    try:
        scanner.scan()
        
        if args.export and scanner.open_ports:
            scanner.export_results()
    
    except KeyboardInterrupt:
        print("\n\nScan interrupted by user")
        if scanner.open_ports:
            print(f"Partial results - {len(scanner.open_ports)} open ports found")
    
    except Exception as e:
        print(f"\nError during scan: {e}")

if __name__ == "__main__":
    # If no arguments, interactive mode
    if len(sys.argv) == 1:
        print("=" * 60)
        print("TCP SYN PORT SCANNER")
        print("=" * 60)
        
        target = input("Enter target IP or hostname: ").strip()
        if not target:
            print("No target specified")
            sys.exit(1)
        
        ports = input("Port range (default: 1-1024): ").strip()
        if not ports:
            ports = "1-1024"
        
        threads = input("Number of threads (default: 10): ").strip()
        threads = int(threads) if threads else 10
        
        scanner = TCPSYNScanner(target, ports=ports, threads=threads)
        scanner.scan()
    else:
        main()
```

### Step 2: TCP Connect Scanner

Create `src/tcp_connect_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 3, Part 2: TCP Connect Scanner

This script implements a TCP Connect port scanner using
Python's socket library and Scapy for analysis.
"""

import socket
import sys
import threading
import time
from datetime import datetime
import argparse
from queue import Queue
import ipaddress

class TCPConnectScanner:
    """
    TCP Connect port scanner (full 3-way handshake).
    
    Features:
    - Full TCP connection establishment
    - Socket-based scanning (no root required)
    - Multi-threaded scanning
    - Service banner grabbing
    - Timeout handling
    """
    
    def __init__(self, target, ports=None, threads=10, timeout=3,
                 banner_timeout=2, scan_services=False):
        """
        Initialize Connect scanner.
        
        Args:
            target: Target IP address or hostname
            ports: List of ports or port range
            threads: Number of scanning threads
            timeout: Connection timeout in seconds
            banner_timeout: Banner grab timeout
            scan_services: Enable service detection
        """
        self.target = target
        self.ports = self.parse_ports(ports) if ports else list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.banner_timeout = banner_timeout
        self.scan_services = scan_services
        
        self.open_ports = []
        self.closed_ports = []
        self.results = {}
        self.port_queue = Queue()
        self.results_lock = threading.Lock()
        
        self.total_scanned = 0
        self.start_time = None
        
        print(f"\n[CONNECT SCAN] Target: {self.target}")
        print(f"[CONNECT SCAN] Ports: {len(self.ports)}")
        print(f"[CONNECT SCAN] Threads: {self.threads}")
        print(f"[CONNECT SCAN] Timeout: {self.timeout}s")
        if self.scan_services:
            print("[CONNECT SCAN] Service detection: Enabled")
    
    def parse_ports(self, port_spec):
        """Parse port specification."""
        ports = []
        
        if isinstance(port_spec, list):
            return port_spec
        
        for part in port_spec.split(','):
            if '-' in part:
                start, end = part.split('-')
                ports.extend(range(int(start), int(end) + 1))
            else:
                ports.append(int(part))
        
        return ports
    
    def get_service_name(self, port):
        """Get common service name for a port."""
        services = {
            20: 'FTP-data', 21: 'FTP', 22: 'SSH', 23: 'Telnet',
            25: 'SMTP', 53: 'DNS', 80: 'HTTP', 110: 'POP3',
            111: 'RPC', 135: 'MSRPC', 139: 'NetBIOS', 143: 'IMAP',
            443: 'HTTPS', 445: 'SMB', 993: 'IMAPS', 995: 'POP3S',
            1723: 'PPTP', 3306: 'MySQL', 3389: 'RDP', 5432: 'PostgreSQL',
            5900: 'VNC', 6379: 'Redis', 8080: 'HTTP-Alt'
        }
        return services.get(port, 'Unknown')
    
    def grab_banner(self, ip, port, timeout):
        """
        Attempt to grab banner/service information.
        
        Returns:
            Banner string or None
        """
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            sock.connect((ip, port))
            
            # Send a probe for common services
            probes = {
                22: b"SSH-2.0-Scapy\r\n",  # SSH
                80: b"HEAD / HTTP/1.0\r\n\r\n",  # HTTP
                443: b"HEAD / HTTP/1.0\r\n\r\n",  # HTTPS
                25: b"EHLO test\r\n",  # SMTP
                21: b"USER anonymous\r\n",  # FTP
                110: b"USER test\r\n",  # POP3
                143: b"a001 CAPABILITY\r\n",  # IMAP
                3306: b"\x00\x00\x00\x0b\x04\x00\x00\x00" + b"\x00"*7,  # MySQL
            }
            
            if port in probes:
                sock.send(probes[port])
            
            # Read banner
            banner = sock.recv(1024).decode('utf-8', errors='ignore')
            sock.close()
            
            return banner.strip() if banner else None
            
        except Exception:
            return None
    
    def scan_port(self, port):
        """
        Scan a single port using TCP connect.
        
        Returns:
            Tuple (port, status, banner)
        """
        result = {
            'port': port,
            'status': 'closed',
            'banner': None,
            'service': None
        }
        
        try:
            # Create socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            
            # Attempt connection
            start_time = time.time()
            result_code = sock.connect_ex((self.target, port))
            elapsed = time.time() - start_time
            
            if result_code == 0:
                # Port is open
                result['status'] = 'open'
                result['service'] = self.get_service_name(port)
                result['response_time'] = elapsed
                
                # Grab banner if enabled
                if self.scan_services:
                    banner = self.grab_banner(self.target, port, self.banner_timeout)
                    if banner:
                        result['banner'] = banner[:200]  # Truncate long banners
            
            sock.close()
            
        except Exception:
            result['status'] = 'error'
        
        return result
    
    def worker(self):
        """Worker thread for scanning ports."""
        while not self.port_queue.empty():
            try:
                port = self.port_queue.get_nowait()
                result = self.scan_port(port)
                
                with self.results_lock:
                    self.total_scanned += 1
                    
                    if result['status'] == 'open':
                        self.open_ports.append(port)
                        self.results[port] = result
                    
                    if self.total_scanned % 50 == 0:
                        progress = (self.total_scanned / len(self.ports)) * 100
                        print(f"  Progress: {self.total_scanned}/{len(self.ports)} "
                              f"({progress:.1f}%) - {len(self.open_ports)} open")
                
                self.port_queue.task_done()
                
            except Exception as e:
                print(f"  Error scanning port: {e}")
                self.port_queue.task_done()
    
    def scan(self):
        """Execute the port scan."""
        
        print("\n[CONNECT SCAN] Starting scan...")
        print("-" * 60)
        
        # Fill queue
        for port in self.ports:
            self.port_queue.put(port)
        
        self.start_time = time.time()
        
        # Start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for completion
        for t in threads:
            t.join()
        
        elapsed_time = time.time() - self.start_time
        
        # Display results
        self.display_results(elapsed_time)
        
        return self.results
    
    def display_results(self, elapsed_time):
        """Display scan results."""
        
        print("\n" + "=" * 60)
        print("TCP CONNECT SCAN RESULTS")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed_time:.2f} seconds")
        print(f"Ports scanned: {self.total_scanned}")
        print("-" * 60)
        
        if self.open_ports:
            print(f"\nOPEN PORTS ({len(self.open_ports)}):")
            print("-" * 60)
            print(f"{'Port':<10} {'Service':<15} {'Status':<10} {'Banner'}")
            print("-" * 60)
            
            for port in sorted(self.open_ports):
                result = self.results.get(port, {})
                service = result.get('service', 'Unknown')
                banner = result.get('banner', '')
                
                if banner:
                    # Clean up banner for display
                    banner = banner.replace('\n', ' ').replace('\r', ' ')[:50]
                    print(f"{port:<10} {service:<15} Open     {banner}")
                else:
                    print(f"{port:<10} {service:<15} Open")
        else:
            print("\nNo open ports found.")
        
        print("\n" + "=" * 60)
        print("SCAN COMPLETE")
        print("=" * 60)
    
    def export_results(self, filename=None):
        """Export results to file."""
        
        if not self.open_ports:
            print("No results to export")
            return
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/connect_scan_{self.target}_{timestamp}.txt"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        with open(filename, 'w') as f:
            f.write(f"TCP Connect Scan Results for {self.target}\n")
            f.write(f"Date: {datetime.now()}\n")
            f.write("-" * 60 + "\n")
            f.write(f"Open Ports ({len(self.open_ports)}):\n\n")
            f.write(f"{'Port':<10} {'Service':<15} {'Banner'}\n")
            f.write("-" * 60 + "\n")
            
            for port in sorted(self.open_ports):
                result = self.results.get(port, {})
                service = result.get('service', 'Unknown')
                banner = result.get('banner', '')
                f.write(f"{port:<10} {service:<15} {banner}\n")
        
        print(f"\nResults exported to: {filename}")

def main():
    """Command-line interface for Connect scanner."""
    
    parser = argparse.ArgumentParser(description='TCP Connect Port Scanner')
    parser.add_argument('target', help='Target IP address or hostname')
    parser.add_argument('-p', '--ports', default='1-1024',
                        help='Port range (e.g., 1-1000,80,443)')
    parser.add_argument('-t', '--threads', type=int, default=10,
                        help='Number of scanning threads')
    parser.add_argument('--timeout', type=float, default=3,
                        help='Connection timeout')
    parser.add_argument('-b', '--banner', action='store_true',
                        help='Enable banner grabbing')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to file')
    
    args = parser.parse_args()
    
    # Create scanner
    scanner = TCPConnectScanner(
        target=args.target,
        ports=args.ports,
        threads=args.threads,
        timeout=args.timeout,
        scan_services=args.banner
    )
    
    # Run scan
    try:
        scanner.scan()
        
        if args.export and scanner.open_ports:
            scanner.export_results()
    
    except KeyboardInterrupt:
        print("\n\nScan interrupted by user")
        if scanner.open_ports:
            print(f"Partial results - {len(scanner.open_ports)} open ports found")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("TCP CONNECT PORT SCANNER")
        print("=" * 60)
        
        target = input("Enter target IP or hostname: ").strip()
        if not target:
            print("No target specified")
            sys.exit(1)
        
        ports = input("Port range (default: 1-1024): ").strip()
        ports = ports if ports else "1-1024"
        
        threads = input("Number of threads (default: 10): ").strip()
        threads = int(threads) if threads else 10
        
        scanner = TCPConnectScanner(target, ports=ports, threads=threads)
        scanner.scan()
    else:
        main()
```

### Step 3: UDP Scanner

Create `src/udp_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 3, Part 2: UDP Scanner

This script implements a UDP port scanner with various techniques.
"""

from scapy.all import IP, UDP, sr1, sr, conf, ICMP
import socket
import time
import sys
import threading
from datetime import datetime
import argparse
from queue import Queue

class UDPScanner:
    """
    UDP port scanner.
    
    Features:
    - UDP datagram scanning
    - ICMP unreachable detection
    - Multi-threaded scanning
    - Custom payload support
    - Service detection via probes
    """
    
    def __init__(self, target, ports=None, threads=10, timeout=3,
                 scan_method='icmp'):
        """
        Initialize UDP scanner.
        
        Args:
            target: Target IP address
            ports: List of ports or range
            threads: Number of scanning threads
            timeout: Timeout in seconds
            scan_method: 'icmp' or 'response'
        """
        self.target = target
        self.ports = self.parse_ports(ports) if ports else list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.scan_method = scan_method
        
        self.open_ports = []
        self.closed_ports = []
        self.filtered_ports = []
        self.port_queue = Queue()
        self.results_lock = threading.Lock()
        
        self.total_scanned = 0
        self.start_time = None
        
        print(f"\n[UDP SCAN] Target: {self.target}")
        print(f"[UDP SCAN] Ports: {len(self.ports)}")
        print(f"[UDP SCAN] Method: {scan_method}")
        print(f"[UDP SCAN] Threads: {self.threads}")
    
    def parse_ports(self, port_spec):
        """Parse port specification."""
        ports = []
        
        if isinstance(port_spec, list):
            return port_spec
        
        for part in port_spec.split(','):
            if '-' in part:
                start, end = part.split('-')
                ports.extend(range(int(start), int(end) + 1))
            else:
                ports.append(int(part))
        
        return ports
    
    def scan_port_icmp(self, port):
        """
        Scan UDP port using ICMP unreachable detection.
        """
        # Build UDP packet with small payload
        payload = b"UDP probe from Scapy"
        packet = IP(dst=self.target) / UDP(sport=12345, dport=port) / Raw(load=payload)
        
        # Send and wait for ICMP response
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply is None:
            # No response - likely open or filtered
            return 'open'
        
        if reply.haslayer(ICMP):
            icmp = reply[ICMP]
            if icmp.type == 3 and icmp.code == 3:
                # Port Unreachable
                return 'closed'
            else:
                # Other ICMP error
                return 'filtered'
        
        return 'open'
    
    def scan_port_response(self, port):
        """
        Scan UDP port by looking for direct response.
        """
        # Send probe that might elicit a response
        payload = b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00"  # DNS query
        packet = IP(dst=self.target) / UDP(sport=12345, dport=port) / Raw(load=payload)
        
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply is None:
            return 'filtered'
        
        if reply.haslayer(UDP):
            # Got a UDP response - likely open
            return 'open'
        
        if reply.haslayer(ICMP):
            icmp = reply[ICMP]
            if icmp.type == 3 and icmp.code == 3:
                return 'closed'
        
        return 'filtered'
    
    def scan_port(self, port):
        """
        Scan a single UDP port.
        
        Returns:
            Tuple (port, status)
        """
        if self.scan_method == 'icmp':
            status = self.scan_port_icmp(port)
        else:
            status = self.scan_port_response(port)
        
        self.total_scanned += 1
        return port, status
    
    def worker(self):
        """Worker thread for scanning ports."""
        while not self.port_queue.empty():
            try:
                port = self.port_queue.get_nowait()
                port, status = self.scan_port(port)
                
                with self.results_lock:
                    if status == 'open':
                        self.open_ports.append(port)
                    elif status == 'closed':
                        self.closed_ports.append(port)
                    else:
                        self.filtered_ports.append(port)
                    
                    if self.total_scanned % 50 == 0:
                        progress = (self.total_scanned / len(self.ports)) * 100
                        print(f"  Progress: {self.total_scanned}/{len(self.ports)} "
                              f"({progress:.1f}%) - {len(self.open_ports)} open")
                
                self.port_queue.task_done()
                
            except Exception as e:
                print(f"  Error scanning port: {e}")
                self.port_queue.task_done()
    
    def scan(self):
        """Execute the UDP scan."""
        
        print("\n[UDP SCAN] Starting scan...")
        print("-" * 60)
        
        # Fill queue
        for port in self.ports:
            self.port_queue.put(port)
        
        self.start_time = time.time()
        
        # Start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for completion
        for t in threads:
            t.join()
        
        elapsed_time = time.time() - self.start_time
        
        # Display results
        self.display_results(elapsed_time)
        
        return self.open_ports
    
    def display_results(self, elapsed_time):
        """Display scan results."""
        
        print("\n" + "=" * 60)
        print("UDP SCAN RESULTS")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed_time:.2f} seconds")
        print(f"Ports scanned: {self.total_scanned}")
        print("-" * 60)
        
        if self.open_ports:
            print(f"\nOPEN/FILTERED PORTS ({len(self.open_ports)}):")
            print("-" * 40)
            print(f"  Note: UDP ports may be open or filtered")
            for port in sorted(self.open_ports)[:20]:
                print(f"  {port}")
            if len(self.open_ports) > 20:
                print(f"  ... and {len(self.open_ports) - 20} more")
        else:
            print("\nNo open/filtered ports found.")
        
        if self.closed_ports:
            print(f"\nCLOSED PORTS ({len(self.closed_ports)}):")
            print("-" * 40)
            print(f"  {len(self.closed_ports)} ports are closed")
        
        print("\n" + "=" * 60)
        print("SCAN COMPLETE")
        print("=" * 60)

def main():
    """Command-line interface for UDP scanner."""
    
    parser = argparse.ArgumentParser(description='UDP Port Scanner')
    parser.add_argument('target', help='Target IP address')
    parser.add_argument('-p', '--ports', default='1-1024',
                        help='Port range (e.g., 1-1000,53,123)')
    parser.add_argument('-t', '--threads', type=int, default=5,
                        help='Number of scanning threads')
    parser.add_argument('--timeout', type=float, default=3,
                        help='Timeout in seconds')
    parser.add_argument('-m', '--method', choices=['icmp', 'response'],
                        default='icmp', help='Scan method')
    
    args = parser.parse_args()
    
    scanner = UDPScanner(
        target=args.target,
        ports=args.ports,
        threads=args.threads,
        timeout=args.timeout,
        scan_method=args.method
    )
    
    try:
        scanner.scan()
    except KeyboardInterrupt:
        print("\n\nScan interrupted by user")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("UDP PORT SCANNER")
        print("=" * 60)
        
        target = input("Enter target IP: ").strip()
        if not target:
            print("No target specified")
            sys.exit(1)
        
        ports = input("Port range (default: 1-1024): ").strip()
        ports = ports if ports else "1-1024"
        
        scanner = UDPScanner(target, ports=ports)
        scanner.scan()
    else:
        main()
```

### Step 4: Comprehensive Port Scanner

Create `src/comprehensive_scanner.py`:

```python
#!/usr/bin/env python3
"""
Module 3, Part 2: Comprehensive Port Scanner

This script integrates all scan types into a single,
comprehensive port scanning tool.
"""

import sys
import os
import time
import argparse
from datetime import datetime
import json

# Import scanner modules
from tcp_syn_scanner import TCPSYNScanner
from tcp_connect_scanner import TCPConnectScanner
from udp_scanner import UDPScanner

class ComprehensiveScanner:
    """
    Comprehensive port scanner that combines multiple scan types.
    
    Features:
    - Multiple scan techniques (SYN, Connect, UDP)
    - Service detection
    - Parallel scanning
    - Unified reporting
    """
    
    def __init__(self, target, ports="1-1024", threads=10, timeout=3,
                 scan_type="syn", scan_services=False):
        """
        Initialize comprehensive scanner.
        
        Args:
            target: Target IP address
            ports: Port range or list
            threads: Number of threads
            timeout: Timeout in seconds
            scan_type: "syn", "connect", "udp", or "all"
            scan_services: Enable service detection
        """
        self.target = target
        self.ports = ports
        self.threads = threads
        self.timeout = timeout
        self.scan_type = scan_type
        self.scan_services = scan_services
        
        self.results = {}
        self.timings = {}
        
        print("\n" + "=" * 70)
        print("COMPREHENSIVE PORT SCANNER")
        print("=" * 70)
        print(f"Target: {target}")
        print(f"Ports: {ports}")
        print(f"Scan type: {scan_type}")
        print(f"Threads: {threads}")
        print(f"Timeout: {timeout}s")
        print("=" * 70)
    
    def run_syn_scan(self):
        """Run TCP SYN scan."""
        print("\n[SCAN] Running TCP SYN scan...")
        
        scanner = TCPSYNScanner(
            target=self.target,
            ports=self.ports,
            threads=self.threads,
            timeout=self.timeout
        )
        
        start_time = time.time()
        results = scanner.scan()
        elapsed = time.time() - start_time
        
        self.results['syn'] = {
            'open_ports': results['open_ports'],
            'elapsed': elapsed
        }
        self.timings['syn'] = elapsed
        
        return results['open_ports']
    
    def run_connect_scan(self):
        """Run TCP Connect scan."""
        print("\n[SCAN] Running TCP Connect scan...")
        
        scanner = TCPConnectScanner(
            target=self.target,
            ports=self.ports,
            threads=self.threads,
            timeout=self.timeout,
            scan_services=self.scan_services
        )
        
        start_time = time.time()
        results = scanner.scan()
        elapsed = time.time() - start_time
        
        self.results['connect'] = {
            'open_ports': results['open_ports'],
            'elapsed': elapsed
        }
        self.timings['connect'] = elapsed
        
        return results['open_ports']
    
    def run_udp_scan(self):
        """Run UDP scan."""
        print("\n[SCAN] Running UDP scan...")
        
        scanner = UDPScanner(
            target=self.target,
            ports=self.ports,
            threads=int(self.threads / 2) or 1,  # UDP is slower
            timeout=self.timeout,
            scan_method='icmp'
        )
        
        start_time = time.time()
        results = scanner.scan()
        elapsed = time.time() - start_time
        
        self.results['udp'] = {
            'open_ports': results,
            'elapsed': elapsed
        }
        self.timings['udp'] = elapsed
        
        return results
    
    def run_scan(self):
        """Execute the chosen scan(s)."""
        
        if self.scan_type == "syn":
            self.run_syn_scan()
        elif self.scan_type == "connect":
            self.run_connect_scan()
        elif self.scan_type == "udp":
            self.run_udp_scan()
        elif self.scan_type == "all":
            # Run all scans
            self.run_syn_scan()
            self.run_connect_scan()
            self.run_udp_scan()
        
        self.display_summary()
    
    def display_summary(self):
        """Display a summary of all scan results."""
        
        print("\n" + "=" * 70)
        print("SCAN SUMMARY")
        print("=" * 70)
        
        for scan_type, data in self.results.items():
            print(f"\n{scan_type.upper()} Scan:")
            print(f"  Elapsed: {data['elapsed']:.2f}s")
            print(f"  Open ports: {len(data['open_ports'])}")
            if data['open_ports']:
                print(f"  Ports: {', '.join(map(str, sorted(data['open_ports'])[:20]))}")
                if len(data['open_ports']) > 20:
                    print(f"  ... and {len(data['open_ports']) - 20} more")
        
        # Combined results
        if 'syn' in self.results and 'connect' in self.results:
            syn_ports = set(self.results['syn']['open_ports'])
            connect_ports = set(self.results['connect']['open_ports'])
            
            print("\nComparison (SYN vs Connect):")
            print(f"  Common ports: {len(syn_ports & connect_ports)}")
            print(f"  Only in SYN: {len(syn_ports - connect_ports)}")
            print(f"  Only in Connect: {len(connect_ports - syn_ports)}")
        
        print("\n" + "=" * 70)
        print("SCAN COMPLETE")
        print("=" * 70)
    
    def export_results(self, filename=None):
        """Export all results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/comprehensive_scan_{self.target}_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        # Build export data
        export_data = {
            'target': self.target,
            'timestamp': datetime.now().isoformat(),
            'scan_type': self.scan_type,
            'ports': self.ports,
            'results': self.results,
            'timings': self.timings
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2)
        
        print(f"\nResults exported to: {filename}")

def main():
    """Command-line interface for comprehensive scanner."""
    
    parser = argparse.ArgumentParser(description='Comprehensive Port Scanner')
    parser.add_argument('target', help='Target IP address or hostname')
    parser.add_argument('-p', '--ports', default='1-1024',
                        help='Port range (e.g., 1-1000,80,443)')
    parser.add_argument('-t', '--threads', type=int, default=10,
                        help='Number of scanning threads')
    parser.add_argument('--timeout', type=float, default=3,
                        help='Timeout in seconds')
    parser.add_argument('-s', '--scan-type', choices=['syn', 'connect', 'udp', 'all'],
                        default='syn', help='Scan type')
    parser.add_argument('-b', '--banner', action='store_true',
                        help='Enable banner grabbing (connect scan only)')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    
    args = parser.parse_args()
    
    scanner = ComprehensiveScanner(
        target=args.target,
        ports=args.ports,
        threads=args.threads,
        timeout=args.timeout,
        scan_type=args.scan_type,
        scan_services=args.banner
    )
    
    try:
        scanner.run_scan()
        
        if args.export:
            scanner.export_results()
    
    except KeyboardInterrupt:
        print("\n\nScan interrupted by user")
    
    except Exception as e:
        print(f"\nError during scan: {e}")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("COMPREHENSIVE PORT SCANNER")
        print("=" * 60)
        
        target = input("Enter target IP or hostname: ").strip()
        if not target:
            print("No target specified")
            sys.exit(1)
        
        ports = input("Port range (default: 1-1024): ").strip()
        ports = ports if ports else "1-1024"
        
        print("\nScan types:")
        print("  1. SYN scan (default)")
        print("  2. Connect scan")
        print("  3. UDP scan")
        print("  4. All scans")
        
        choice = input("Select scan type (1-4): ").strip()
        scan_types = {'1': 'syn', '2': 'connect', '3': 'udp', '4': 'all'}
        scan_type = scan_types.get(choice, 'syn')
        
        scanner = ComprehensiveScanner(target, ports=ports, scan_type=scan_type)
        scanner.run_scan()
    else:
        main()
```

---

## The Verification: Testing Port Scanners

### Verification 1: Test SYN Scanner

```bash
cd ~/scapy-tutorial

# Scan localhost (safe)
python3 src/tcp_syn_scanner.py 127.0.0.1 -p 22,80,443 -t 5

# Scan common ports on a target
python3 src/tcp_syn_scanner.py 8.8.8.8 -p 53,80,443,123 -t 5
```

**Expected output**: Open ports identified with service names.

### Verification 2: Test Connect Scanner

```bash
# Connect scan with banner grabbing
python3 src/tcp_connect_scanner.py 127.0.0.1 -p 22,80,443 -b
```

**Expected output**: Open ports with service banners when available.

### Verification 3: Test UDP Scanner

```bash
# UDP scan for common services
python3 src/udp_scanner.py 8.8.8.8 -p 53,123,161 -t 5
```

**Expected output**: Open/filtered UDP ports.

### Verification 4: Test Comprehensive Scanner

```bash
# Run all scan types
python3 src/comprehensive_scanner.py 127.0.0.1 -s all -p 22,80,443,53

# Export results
python3 src/comprehensive_scanner.py 127.0.0.1 -s all -e
```

**Expected output**: Combined results from all scan types.

---

## Reference: Port Scanning Techniques

### Scan Type Comparison

| Feature | SYN Scan | Connect Scan | UDP Scan |
|---------|----------|--------------|----------|
| Speed | Fast | Slower | Slow |
| Stealth | More stealthy | Not stealthy | Not stealthy |
| Requires Root | Yes | No | Yes |
| Reliability | Good | Excellent | Fair |
| Service Detection | No | Yes | Limited |

### Common Services and Ports

| Port | Protocol | Service | Common Use |
|------|----------|---------|------------|
| 20-21 | TCP | FTP | File Transfer |
| 22 | TCP | SSH | Secure Shell |
| 23 | TCP | Telnet | Remote Terminal |
| 25 | TCP | SMTP | Email |
| 53 | TCP/UDP | DNS | Domain Resolution |
| 80 | TCP | HTTP | Web |
| 110 | TCP | POP3 | Email |
| 123 | UDP | NTP | Time Sync |
| 143 | TCP | IMAP | Email |
| 161 | UDP | SNMP | Network Management |
| 443 | TCP | HTTPS | Secure Web |
| 445 | TCP | SMB | File Sharing |
| 3306 | TCP | MySQL | Database |
| 3389 | TCP | RDP | Remote Desktop |

### Scan Time Estimation

| Network | Ports | Threads | Estimated Time |
|---------|-------|---------|----------------|
| Localhost | 1000 | 10 | < 5 seconds |
| Local Network | 1000 | 10 | ~30 seconds |
| Internet | 1000 | 20 | ~60 seconds |
| Internet | 65535 | 50 | ~30 minutes |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Scanning Without Permission

```python
# DON'T: Scan networks you don't own or have permission for
scanner.scan("192.168.1.0/24")  # Unauthorized = illegal

# DO: Only scan authorized targets
scanner.scan("127.0.0.1")  # Your own machine
```

### Pitfall 2: Too Many Threads

```python
# DON'T: Too many threads (resource exhaustion)
scanner = TCPSYNScanner(threads=1000)

# DO: Reasonable thread count
scanner = TCPSYNScanner(threads=20)
```

### Pitfall 3: No Rate Limiting

```python
# DON'T: Flood network
scanner = TCPSYNScanner(rate_limit=None)

# DO: Implement rate limiting
scanner = TCPSYNScanner(rate_limit=100)  # 100 packets/sec
```

### Best Practice: Use Progress Indicators

```python
def display_progress(current, total):
    """Display scanning progress."""
    percent = (current / total) * 100
    bar = "#" * int(percent / 2)
    print(f"\rProgress: [{bar:<50}] {percent:.1f}%", end="")
```

### Best Practice: Implement Timeouts

```python
# Always use timeouts to prevent hanging
reply = sr1(packet, timeout=3)
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ TCP SYN scanning (half-open)
2. ✅ TCP Connect scanning
3. ✅ UDP scanning
4. ✅ Multi-threaded scanning engines
5. ✅ Service detection and banner grabbing
6. ✅ Rate limiting and performance optimization
7. ✅ Comprehensive scanning with multiple techniques

---

## Module 3 Complete!

**Congratulations!** You've completed Module 3. You now have professional-grade port scanning tools and a deep understanding of TCP and UDP operations.

---

## Next Steps: Preview of Module 4

In **Module 4: Packet Sniffing, Filtering & Traffic Analysis**, we'll:

1. Implement real-time packet sniffing
2. Use BPF filters for efficient capture
3. Build protocol-specific analyzers
4. Create traffic dashboards
5. Analyze DNS, HTTP, and DHCP traffic
6. Build a comprehensive network monitor

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 3 COMPLETE                                           │
│  ✅ TCP and UDP structures mastered                                 │
│  ✅ Port scanning tools built                                       │
│  ✅ SYN, Connect, and UDP scanners created                         │
│  ✅ Multi-threaded scanning implemented                            │
│  ✅ Service detection and banner grabbing                          │
│  ✅ Comprehensive scanning framework developed                     │
│  NEXT: MODULE 4 — Packet Sniffing, Filtering & Traffic Analysis   │
│  ● Real-time packet capture                                       │
│  ● BPF filtering                                                  │
│  ● Protocol analysis                                              │
│  ● Traffic dashboards                                            │
│  ● Network monitoring tools                                      │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Module 4, where we'll build professional packet sniffing and traffic analysis tools — capturing, filtering, and analyzing network traffic in real-time.*
