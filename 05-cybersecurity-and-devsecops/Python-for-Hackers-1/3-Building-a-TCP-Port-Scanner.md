# Phase 1: Foundations & Network Fundamentals
## Part 3: Building a TCP Port Scanner

### The Target: Multi-Threaded TCP Port Scanner

By the end of this part, you will:
- Understand how port scanning works and why it's important
- Build a multi-threaded TCP port scanner from scratch
- Implement service banner grabbing for service identification
- Create a comprehensive scanning framework with reporting capabilities
- Optimize scanning performance using threading and connection pooling

### The Concept: What is Port Scanning?

Think of port scanning like checking all the doors and windows of a building to see which ones are open. In networking:

- **IP Address** = The building's street address (where the computer lives)
- **Ports** = Different doors/windows (numbered 1-65535)
- **Open Port** = An unlocked door (a service is listening)
- **Closed Port** = A locked door (no service is listening)
- **Filtered Port** = A door guarded by a firewall (we can't tell if it's open)

Port scanning helps us discover:
- What services are running on a target system
- What operating system might be running (based on service fingerprints)
- Potential attack vectors (vulnerable services)

### How TCP Port Scanning Works

TCP (Transmission Control Protocol) establishes connections using a "three-way handshake":

1. **SYN** → Client sends SYN packet (I want to connect)
2. **SYN-ACK** → Server responds with SYN-ACK (Okay, let's connect)
3. **ACK** → Client sends ACK (Connection established!)

**Scanning Techniques:**
- **Connect Scan**: Performs full TCP handshake (most reliable, most detectable)
- **SYN Scan**: Only sends SYN packet (stealthier, requires root)
- **UDP Scan**: Sends UDP packets (unreliable, often blocked)

We'll implement a **Connect Scan** because it works without root privileges and is most reliable for beginners.

### The Implementation: Complete Port Scanner

#### File: `~/hacking-toolkit/recon/port_scanner.py`

```python
#!/usr/bin/env python3
"""
port_scanner.py - Multi-threaded TCP Port Scanner with Banner Grabbing
This scanner identifies open ports, services, and grabs banners for identification.
"""

import socket
import threading
import queue
import time
import sys
import ipaddress
from datetime import datetime
from typing import List, Dict, Tuple, Optional, Set
import argparse

# Try to import colorama for colored output
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    HAS_COLOR = True
except ImportError:
    # Fallback if colorama is not installed
    class Fore:
        RED = GREEN = YELLOW = BLUE = CYAN = MAGENTA = WHITE = RESET = ''
    Style = Fore
    HAS_COLOR = False

class PortScanner:
    """
    A multi-threaded TCP port scanner with banner grabbing capabilities.
    Scans specified ports on a target host and identifies services.
    """
    
    # Common service signatures for banner matching
    SERVICE_SIGNATURES = {
        'SSH': [b'SSH', b'OpenSSH', b'ssh'],
        'HTTP': [b'HTTP', b'Server:', b'Apache', b'nginx', b'IIS'],
        'HTTPS': [b'HTTP', b'Server:', b'Apache', b'nginx', b'SSL'],
        'FTP': [b'FTP', b'220', b'vsFTPd', b'ProFTPD'],
        'SMTP': [b'SMTP', b'220', b'ESMTP', b'Postfix', b'Exim'],
        'MySQL': [b'MySQL', b'MariaDB', b'5.', b'8.'],
        'PostgreSQL': [b'PostgreSQL', b'PSQL'],
        'MongoDB': [b'MongoDB', b'wire protocol'],
        'Redis': [b'Redis', b'redis'],
        'RDP': [b'RDP', b'Microsoft', b'Terminal Services'],
        'VNC': [b'VNC', b'RFB', b'RealVNC'],
        'SMB': [b'SMB', b'CIFS', b'Microsoft Windows'],
    }
    
    def __init__(self, target: str, ports: List[int], 
                 max_threads: int = 50, timeout: float = 2.0,
                 grab_banners: bool = True):
        """
        Initialize the port scanner
        
        Args:
            target: Target IP address or hostname
            ports: List of ports to scan
            max_threads: Maximum number of concurrent threads
            timeout: Connection timeout in seconds
            grab_banners: Whether to attempt banner grabbing
        """
        self.target = target
        self.ports = sorted(set(ports))  # Remove duplicates and sort
        self.max_threads = max_threads
        self.timeout = timeout
        self.grab_banners = grab_banners
        
        # Scanner state
        self.open_ports: List[Dict] = []
        self.locked_ports: Set[int] = set()
        self.scan_queue = queue.Queue()
        self.lock = threading.Lock()
        self.completed = 0
        self.total_ports = len(self.ports)
        self.start_time = None
        self.end_time = None
        self.scan_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        
    def scan_port(self, port: int) -> Optional[Dict]:
        """
        Attempt to connect to a single port
        
        Args:
            port: Port number to scan
            
        Returns:
            Dict with port information if open, None otherwise
        """
        try:
            # Create a socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            
            # Attempt connection
            # connect_ex returns 0 on success, error code otherwise
            result = sock.connect_ex((self.target, port))
            
            if result == 0:
                # Port is open!
                service = self._get_service_name(port)
                banner = None
                
                # Grab banner if enabled
                if self.grab_banners:
                    banner = self._grab_banner(sock, port)
                
                sock.close()
                
                # Get service version from banner
                if banner:
                    service_detected = self._identify_service(banner, port)
                    if service_detected:
                        service = service_detected
                
                return {
                    'port': port,
                    'service': service,
                    'banner': banner,
                    'state': 'open'
                }
            
            sock.close()
            return None
            
        except socket.timeout:
            return None
        except socket.error:
            return None
        except Exception:
            return None
    
    def _get_service_name(self, port: int) -> str:
        """
        Get the default service name for a port
        
        Args:
            port: Port number
            
        Returns:
            Service name or 'unknown'
        """
        # Common port mappings
        common_ports = {
            20: 'ftp-data', 21: 'ftp', 22: 'ssh', 23: 'telnet',
            25: 'smtp', 53: 'dns', 80: 'http', 110: 'pop3',
            111: 'rpcbind', 135: 'msrpc', 139: 'netbios-ssn',
            143: 'imap', 443: 'https', 445: 'microsoft-ds',
            993: 'imaps', 995: 'pop3s', 1723: 'pptp',
            3306: 'mysql', 3389: 'ms-wbt-server', 5432: 'postgresql',
            5900: 'vnc', 6379: 'redis', 8080: 'http-proxy',
            8443: 'https-alt', 27017: 'mongod'
        }
        
        return common_ports.get(port, 'unknown')
    
    def _grab_banner(self, sock: socket.socket, port: int, timeout: float = 2.0) -> Optional[str]:
        """
        Attempt to grab a service banner from the connection
        
        Args:
            sock: Connected socket
            port: Port number (used to determine what to send)
            timeout: Banner read timeout
            
        Returns:
            Banner string or None
        """
        try:
            # Set timeout for banner reading
            sock.settimeout(timeout)
            
            # For HTTP/HTTPS ports, send a GET request
            if port in [80, 443, 8080, 8443, 8000, 3000]:
                sock.send(b'HEAD / HTTP/1.0\r\n\r\n')
            # For SMTP
            elif port == 25:
                sock.send(b'HELO localhost\r\n')
            # For FTP
            elif port == 21:
                sock.send(b'USER anonymous\r\n')
            # For other services, just read the initial banner
            else:
                # Wait for server to send banner
                pass
            
            # Read the banner
            banner = sock.recv(1024).strip()
            if banner:
                # Try to decode the banner
                try:
                    return banner.decode('utf-8', errors='ignore').strip()
                except:
                    return None
            
            return None
            
        except socket.timeout:
            return None
        except socket.error:
            return None
        except Exception:
            return None
    
    def _identify_service(self, banner: str, port: int) -> Optional[str]:
        """
        Identify service from banner
        
        Args:
            banner: Banner text from service
            port: Port number
            
        Returns:
            Service name if identified, None otherwise
        """
        if not banner:
            return None
            
        banner_bytes = banner.encode('utf-8', errors='ignore')
        
        for service, signatures in self.SERVICE_SIGNATURES.items():
            for sig in signatures:
                if sig in banner_bytes:
                    return service
        
        # If no match, try common port mapping
        return self._get_service_name(port)
    
    def _worker(self):
        """
        Worker thread function - processes ports from the queue
        """
        while True:
            try:
                # Get next port from the queue
                port = self.scan_queue.get_nowait()
            except queue.Empty:
                break
            
            # Scan the port
            result = self.scan_port(port)
            
            # Update results
            with self.lock:
                if result:
                    self.open_ports.append(result)
                    print(f"[+] Port {port} is OPEN - {result['service']}")
                else:
                    # Print progress for closed ports (debug)
                    pass
                
                self.completed += 1
                progress = (self.completed / self.total_ports) * 100
                sys.stdout.write(f"\r[*] Progress: {self.completed}/{self.total_ports} ports scanned ({progress:.1f}%)")
                sys.stdout.flush()
            
            # Mark task as done
            self.scan_queue.task_done()
    
    def scan(self) -> List[Dict]:
        """
        Execute the port scan
        
        Returns:
            List of open port dictionaries
        """
        print(f"[*] Starting port scan on {self.target}")
        print(f"[*] Scanning {len(self.ports)} ports using {self.max_threads} threads")
        print(f"[*] Timeout: {self.timeout}s, Banner grabbing: {self.grab_banners}")
        print(f"[*] Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        self.start_time = time.time()
        
        # Fill the queue with ports to scan
        for port in self.ports:
            self.scan_queue.put(port)
        
        # Create and start worker threads
        threads = []
        for _ in range(min(self.max_threads, len(self.ports))):
            thread = threading.Thread(target=self._worker)
            thread.daemon = True
            thread.start()
            threads.append(thread)
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join(timeout=30)
        
        # Wait for queue to be empty
        self.scan_queue.join()
        
        self.end_time = time.time()
        elapsed = self.end_time - self.start_time
        
        print(f"\n[*] Scan completed in {elapsed:.2f} seconds")
        print(f"[*] Found {len(self.open_ports)} open ports")
        
        return self.open_ports
    
    def print_results(self, show_banners: bool = False):
        """
        Print formatted scan results
        
        Args:
            show_banners: Whether to display banners
        """
        if not self.open_ports:
            print("\n[*] No open ports found")
            return
        
        print("\n" + "="*60)
        print(f"  SCAN RESULTS FOR {self.target}")
        print("="*60)
        print(f"\n{'PORT':<8} {'STATE':<8} {'SERVICE':<15} {'VERSION'}")
        print("-"*60)
        
        for result in sorted(self.open_ports, key=lambda x: x['port']):
            port = result['port']
            service = result['service']
            banner = result.get('banner', '')
            
            # Try to extract version from banner
            version = 'Unknown'
            if banner and ' ' in banner:
                # Simple version extraction
                parts = banner.split()
                for part in parts:
                    if any(c.isdigit() for c in part):
                        version = part
                        break
            
            # Colorize if available
            if HAS_COLOR:
                print(f"{Fore.GREEN}{port:<8} open     {Fore.CYAN}{service:<15} {Fore.WHITE}{version}")
            else:
                print(f"{port:<8} open     {service:<15} {version}")
            
            if show_banners and banner:
                if HAS_COLOR:
                    print(f"  {Fore.YELLOW}Banner:{Fore.WHITE} {banner[:100]}")
                else:
                    print(f"  Banner: {banner[:100]}")
                if len(banner) > 100:
                    print(f"  ... (truncated, total length: {len(banner)} bytes)")
        
        print("="*60)
        print(f"Total open ports: {len(self.open_ports)}")
        print(f"Scan duration: {self.end_time - self.start_time:.2f} seconds")
    
    def save_results(self, filename: Optional[str] = None):
        """
        Save scan results to a file
        
        Args:
            filename: Output filename (auto-generated if None)
        """
        if not filename:
            filename = f"scan_{self.scan_id}_{self.target}.txt"
        
        with open(filename, 'w') as f:
            f.write("="*60 + "\n")
            f.write(f"  PORT SCAN RESULTS\n")
            f.write("="*60 + "\n\n")
            f.write(f"Target: {self.target}\n")
            f.write(f"Scan started: {datetime.fromtimestamp(self.start_time).strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Scan completed: {datetime.fromtimestamp(self.end_time).strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Total ports scanned: {self.total_ports}\n")
            f.write(f"Open ports found: {len(self.open_ports)}\n\n")
            
            f.write(f"{'PORT':<8} {'STATE':<8} {'SERVICE':<15} {'VERSION'}\n")
            f.write("-"*60 + "\n")
            
            for result in sorted(self.open_ports, key=lambda x: x['port']):
                port = result['port']
                service = result['service']
                banner = result.get('banner', 'Unknown')
                f.write(f"{port:<8} open     {service:<15} {banner}\n")
        
        print(f"[*] Results saved to {filename}")

def parse_ports(port_string: str) -> List[int]:
    """
    Parse port specifications from command line
    
    Supports:
    - Single port: 80
    - Range: 1-100
    - Mixed: 22,80,443,8000-9000
    
    Args:
        port_string: Port specification string
        
    Returns:
        List of port numbers
    """
    ports = []
    
    if not port_string:
        return []
    
    for part in port_string.split(','):
        part = part.strip()
        if '-' in part:
            start, end = part.split('-')
            try:
                start_port = int(start)
                end_port = int(end)
                if start_port < 0 or end_port > 65535:
                    raise ValueError("Ports must be between 0 and 65535")
                ports.extend(range(start_port, min(end_port, 65535) + 1))
            except ValueError as e:
                print(f"[-] Invalid port range '{part}': {e}")
                sys.exit(1)
        else:
            try:
                port = int(part)
                if 0 <= port <= 65535:
                    ports.append(port)
                else:
                    print(f"[-] Port {port} is out of range (0-65535)")
                    sys.exit(1)
            except ValueError:
                print(f"[-] Invalid port number '{part}'")
                sys.exit(1)
    
    return ports

def validate_target(target: str) -> bool:
    """
    Validate target IP address or hostname
    
    Args:
        target: Target string
        
    Returns:
        True if valid
    """
    try:
        ipaddress.ip_address(target)
        return True
    except ValueError:
        # Try to resolve hostname
        try:
            socket.gethostbyname(target)
            return True
        except socket.gaierror:
            return False

def main():
    """Main entry point with argument parsing"""
    parser = argparse.ArgumentParser(
        description="Multi-threaded TCP Port Scanner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 port_scanner.py 192.168.1.1
  python3 port_scanner.py 192.168.1.1 -p 80,443,8080
  python3 port_scanner.py 192.168.1.1 -p 1-1000
  python3 port_scanner.py 192.168.1.1 -p 1-65535 -t 100 -T 1.0
  python3 port_scanner.py 192.168.1.1 -p 22,80,443 --no-banner
        """
    )
    
    parser.add_argument('target', help='Target IP address or hostname')
    parser.add_argument('-p', '--ports', default='20-25,80,443,3306,3389,5432,5900,6379,8080,8443',
                        help='Ports to scan (e.g., 22,80,443 or 1-1000)')
    parser.add_argument('-t', '--threads', type=int, default=50,
                        help='Maximum threads (default: 50)')
    parser.add_argument('-T', '--timeout', type=float, default=2.0,
                        help='Connection timeout in seconds (default: 2.0)')
    parser.add_argument('--no-banner', action='store_true',
                        help='Disable banner grabbing')
    parser.add_argument('-o', '--output', help='Output file for results')
    parser.add_argument('-b', '--banners', action='store_true',
                        help='Display banners in output')
    
    args = parser.parse_args()
    
    # Validate target
    if not validate_target(args.target):
        print(f"[-] Invalid target: {args.target}")
        sys.exit(1)
    
    # Parse ports
    try:
        ports = parse_ports(args.ports)
        if not ports:
            print("[-] No ports specified")
            sys.exit(1)
    except ValueError as e:
        print(f"[-] {e}")
        sys.exit(1)
    
    # Create scanner
    scanner = PortScanner(
        target=args.target,
        ports=ports,
        max_threads=args.threads,
        timeout=args.timeout,
        grab_banners=not args.no_banner
    )
    
    # Run scan
    try:
        results = scanner.scan()
        
        # Display results
        scanner.print_results(show_banners=args.banners)
        
        # Save results if requested
        if args.output or args.banners:
            scanner.save_results(args.output)
        
    except KeyboardInterrupt:
        print("\n[!] Scan interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"[-] Scan error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### The Implementation: Quick Scan Wrapper

#### File: `~/hacking-toolkit/recon/quick_scan.py`

```python
#!/usr/bin/env python3
"""
quick_scan.py - Quick port scan wrapper for common services
This script provides presets for common scanning scenarios.
"""

import subprocess
import sys
import os

# Preset port lists
PRESETS = {
    'web': '80,443,8080,8443,3000,5000,8000',
    'database': '3306,5432,6379,27017,1433,1521,9200',
    'common': '21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5432,5900,6379,8080,8443',
    'all': '1-65535',
    'ssh': '22',
    'rdp': '3389',
    'ftp': '21',
    'smtp': '25,465,587'
}

def main():
    """Run quick scan with presets"""
    if len(sys.argv) < 2:
        print("Usage: python3 quick_scan.py <target> [preset] [threads]")
        print("\nPresets:")
        print("  web      - Web servers (80,443,8080,8443,3000,5000,8000)")
        print("  database - Database services (3306,5432,6379,27017,1433,1521,9200)")
        print("  common   - Common services (21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5432,5900,6379,8080,8443)")
        print("  all      - All ports (1-65535)")
        print("  ssh      - SSH only (22)")
        print("  rdp      - RDP only (3389)")
        print("  ftp      - FTP only (21)")
        print("  smtp     - SMTP ports (25,465,587)")
        sys.exit(1)
    
    target = sys.argv[1]
    preset = sys.argv[2] if len(sys.argv) > 2 else 'common'
    threads = sys.argv[3] if len(sys.argv) > 3 else '50'
    
    if preset not in PRESETS:
        print(f"[-] Unknown preset: {preset}")
        print(f"[*] Available presets: {', '.join(PRESETS.keys())}")
        sys.exit(1)
    
    ports = PRESETS[preset]
    
    print(f"[*] Running quick scan on {target}")
    print(f"[*] Preset: {preset} ({ports})")
    print(f"[*] Threads: {threads}")
    print("[*] Starting scan...\n")
    
    # Run the port scanner
    cmd = f"python3 port_scanner.py {target} -p {ports} -t {threads}"
    subprocess.run(cmd, shell=True)

if __name__ == "__main__":
    main()
```

### The Verification: Testing Your Port Scanner

Now let's test the port scanner with various scenarios:

#### Test 1: Basic Scan on Localhost

```bash
cd ~/hacking-toolkit/recon
python3 port_scanner.py 127.0.0.1 -p 22,80,443,3306
```

**Expected Output:**
```
[*] Starting port scan on 127.0.0.1
[*] Scanning 4 ports using 50 threads
[*] Timeout: 2.0s, Banner grabbing: True
[*] Start time: 2024-01-15 14:30:25
[+] Port 22 is OPEN - ssh
[+] Port 80 is OPEN - http
[*] Progress: 4/4 ports scanned (100.0%)
[*] Scan completed in 0.23 seconds
[*] Found 2 open ports

============================================================
  SCAN RESULTS FOR 127.0.0.1
============================================================

PORT     STATE    SERVICE         VERSION
22       open     ssh             SSH-2.0-OpenSSH_8.9p1
80       open     http            Apache/2.4.52

============================================================
Total open ports: 2
Scan duration: 0.23 seconds
```

#### Test 2: Comprehensive Scan

```bash
# Scan common services on a target machine
python3 port_scanner.py 192.168.100.20 -p 1-1000 -t 100 -T 1.0 --banners
```

**Expected Output:**
```
[*] Starting port scan on 192.168.100.20
[*] Scanning 1000 ports using 100 threads
[*] Timeout: 1.0s, Banner grabbing: True
[*] Start time: 2024-01-15 14:35:12
[+] Port 21 is OPEN - ftp
[+] Port 22 is OPEN - ssh
[+] Port 80 is OPEN - http
[+] Port 443 is OPEN - https
[*] Progress: 1000/1000 ports scanned (100.0%)
[*] Scan completed in 12.45 seconds
[*] Found 4 open ports

============================================================
  SCAN RESULTS FOR 192.168.100.20
============================================================

PORT     STATE    SERVICE         VERSION
21       open     ftp             vsFTPd 3.0.3
22       open     ssh             SSH-2.0-OpenSSH_8.9p1
80       open     http            Apache/2.4.52 (Ubuntu)
443      open     https           Apache/2.4.52 (Ubuntu)

============================================================
Total open ports: 4
Scan duration: 12.45 seconds
[*] Results saved to scan_20240115_143512_192.168.100.20.txt
```

#### Test 3: Quick Scan Presets

```bash
# Quick scan for web services
python3 quick_scan.py 192.168.100.20 web

# Quick scan for databases
python3 quick_scan.py 192.168.100.20 database

# Full port scan (may take a while)
python3 quick_scan.py 192.168.100.20 all 200
```

#### Test 4: Scanning Range with Banner Grabbing

```bash
# Scan a range with detailed banner output
python3 port_scanner.py 192.168.100.20 -p 1-500 -t 50 -T 2.0 -b
```

### The Verification: Performance Testing

Let's test the scanner's performance with different configurations:

```bash
# Test script to compare performance
cat > test_performance.py << 'EOF'
#!/usr/bin/env python3
import time
import subprocess
import sys

def test_scan(threads, target, ports='22,80,443,3306'):
    start = time.time()
    cmd = f"python3 port_scanner.py {target} -p {ports} -t {threads} -T 1.0 --no-banner"
    subprocess.run(cmd, shell=True, capture_output=True)
    return time.time() - start

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else '127.0.0.1'
    
    print(f"[*] Performance test on {target}\n")
    
    for threads in [10, 25, 50, 100]:
        elapsed = test_scan(threads, target)
        print(f"Threads: {threads:3d} - Time: {elapsed:.2f}s")
EOF

python3 test_performance.py 127.0.0.1
```

**Expected Output:**
```
[*] Performance test on 127.0.0.1

Threads:  10 - Time: 0.45s
Threads:  25 - Time: 0.23s
Threads:  50 - Time: 0.18s
Threads: 100 - Time: 0.15s
```

### Troubleshooting Common Issues

#### 1. Connection Timeouts

If you're getting many timeouts:

```bash
# Increase timeout
python3 port_scanner.py 192.168.100.20 -p 22,80 -T 5.0

# Decrease threads (to reduce network congestion)
python3 port_scanner.py 192.168.100.20 -p 1-1000 -t 20
```

#### 2. Permission Denied

Some operations require root privileges:

```bash
# Run with sudo if needed
sudo python3 port_scanner.py 192.168.100.20 -p 1-100
```

#### 3. No Open Ports Found

If scanning shows no open ports:

```bash
# Check network connectivity
ping -c 4 192.168.100.20

# Check if firewall is blocking
nmap -p 22 192.168.100.20

# Verify target has services running
ssh user@192.168.100.20
```

### Advanced Usage: Integration with Other Tools

You can pipe the output to other tools for further processing:

```bash
# Save results and grep for specific services
python3 port_scanner.py 192.168.100.20 -p 1-1000 --no-banner | grep -A1 "open"

# Export to CSV for analysis
python3 port_scanner.py 192.168.100.20 -p 22,80,443 -o results.txt

# Chain with other scanning tools
python3 port_scanner.py 192.168.100.20 -p 1-1000 > open_ports.txt
cat open_ports.txt | grep "open" | awk '{print $1}' | while read port; do
    echo "Checking $port"
    python3 ../web-attack/brute_forcer.py http://192.168.100.20:$port
done
```

