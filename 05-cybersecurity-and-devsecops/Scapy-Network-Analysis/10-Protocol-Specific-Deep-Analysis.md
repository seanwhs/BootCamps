# Mastering Network Packet Crafting with Scapy
## Module 4: Packet Sniffing, Filtering & Traffic Analysis
### Part 2: Protocol-Specific Deep Analysis

## The Target: Deep Protocol Analysis Tools

In this part, we'll build advanced protocol analysis tools that perform deep inspection of network traffic. By the end, you'll be able to:

1. Perform deep HTTP request/response analysis
2. Build a DNS query/response monitor with caching
3. Analyze DHCP DORA (Discover, Offer, Request, Acknowledge) sequences
4. Detect network anomalies (port scans, DDoS patterns)
5. Build a comprehensive traffic statistics engine
6. Create protocol dissection and visualization tools

---

## The Concept: Deep Analysis as Network Forensics

Think of deep protocol analysis as **network forensics**—examining network conversations at the application layer to understand exactly what's happening:

```
┌─────────────────────────────────────────────────────────────────┐
│                      NETWORK TRAFFIC                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PROTOCOL DISSECTION                          │
│  ┌─────────┬──────────┬──────────────┬─────────────────────┐  │
│  │  HTTP   │   DNS    │    DHCP      │        TLS          │  │
│  │Headers  │ Queries  │ DORA Sequence│   Handshakes        │  │
│  │Requests │ Responses│ IP Assignment│   Certificates      │  │
│  │Bodies   │ Caching  │ Lease Info   │   Cipher Suites     │  │
│  └─────────┴──────────┴──────────────┴─────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ANOMALY DETECTION                           │
│  • DNS tunneling detection                                    │
│  • Port scan detection                                        │
│  • DDoS pattern detection                                     │
│  • ARP spoofing detection                                     │
│  • Suspicious user agents                                     │
└─────────────────────────────────────────────────────────────────┘
```

**Key insight**: Deep protocol analysis goes beyond basic packet headers to understand application-layer conversations, enabling you to detect anomalies and understand network behavior at a granular level.

---

## The Implementation: Building Deep Analysis Tools

### Step 1: HTTP Deep Analysis

Create `src/http_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 2: HTTP Deep Analyzer

This script performs deep analysis of HTTP traffic,
extracting requests, responses, headers, and content.
"""

from scapy.all import sniff, IP, TCP, Raw, rdpcap, wrpcap
from scapy.all import conf, get_if_list
import os
import sys
import time
import re
import json
from datetime import datetime
from collections import defaultdict
from urllib.parse import urlparse, parse_qs

class HTTPAnalyzer:
    """
    Deep HTTP traffic analyzer.
    
    Features:
    - HTTP request/response extraction
    - Header analysis
    - URL and parameter extraction
    - User agent tracking
    - Response code analysis
    - Content type detection
    - Session tracking
    """
    
    def __init__(self):
        """Initialize HTTP analyzer."""
        self.http_requests = []
        self.http_responses = []
        self.sessions = defaultdict(list)
        
        # Statistics
        self.stats = {
            'total_requests': 0,
            'total_responses': 0,
            'methods': defaultdict(int),
            'status_codes': defaultdict(int),
            'content_types': defaultdict(int),
            'user_agents': defaultdict(int),
            'hosts': defaultdict(int),
            'paths': defaultdict(int)
        }
        
        # Suspicious patterns
        self.suspicious_patterns = {
            'sql_injection': re.compile(r'(SELECT|INSERT|DELETE|UPDATE|DROP|UNION|WHERE).*(FROM|INTO|TABLE)', re.IGNORECASE),
            'xss': re.compile(r'<script|javascript:|onerror=|onload=', re.IGNORECASE),
            'path_traversal': re.compile(r'\.\./|\.\.\\|/etc/passwd|/windows/win.ini', re.IGNORECASE),
            'command_injection': re.compile(r'[\|;&]|\$(\(|\))|`|&&|\|\|', re.IGNORECASE)
        }
        self.suspicious_requests = []
    
    def parse_http_request(self, data):
        """Parse HTTP request from raw bytes."""
        try:
            # Decode as string
            if isinstance(data, bytes):
                data = data.decode('utf-8', errors='ignore')
            
            # Split into headers and body
            parts = data.split('\r\n\r\n', 1)
            headers_text = parts[0]
            body = parts[1] if len(parts) > 1 else ''
            
            # Parse request line
            lines = headers_text.split('\r\n')
            if not lines:
                return None
            
            request_line = lines[0]
            parts = request_line.split(' ')
            if len(parts) < 3:
                return None
            
            method = parts[0]
            uri = parts[1]
            version = parts[2] if len(parts) > 2 else 'HTTP/1.1'
            
            # Parse headers
            headers = {}
            for line in lines[1:]:
                if ': ' in line:
                    key, value = line.split(': ', 1)
                    headers[key] = value
            
            # Parse URI
            parsed_uri = urlparse(uri)
            path = parsed_uri.path
            query = parsed_uri.query
            params = parse_qs(query)
            
            # Extract host
            host = headers.get('Host', '')
            
            # Extract user agent
            user_agent = headers.get('User-Agent', '')
            
            # Extract content type
            content_type = headers.get('Content-Type', '')
            
            # Check for suspicious patterns
            suspicious = []
            for pattern_name, pattern in self.suspicious_patterns.items():
                if pattern.search(data):
                    suspicious.append(pattern_name)
            
            return {
                'method': method,
                'uri': uri,
                'path': path,
                'query': query,
                'params': params,
                'version': version,
                'host': host,
                'user_agent': user_agent,
                'content_type': content_type,
                'headers': headers,
                'body': body[:1000],  # Truncate large bodies
                'suspicious': suspicious,
                'body_length': len(body)
            }
        
        except Exception as e:
            return None
    
    def parse_http_response(self, data):
        """Parse HTTP response from raw bytes."""
        try:
            # Decode as string
            if isinstance(data, bytes):
                data = data.decode('utf-8', errors='ignore')
            
            # Split into headers and body
            parts = data.split('\r\n\r\n', 1)
            headers_text = parts[0]
            body = parts[1] if len(parts) > 1 else ''
            
            # Parse status line
            lines = headers_text.split('\r\n')
            if not lines:
                return None
            
            status_line = lines[0]
            parts = status_line.split(' ', 2)
            if len(parts) < 3:
                return None
            
            version = parts[0]
            status_code = int(parts[1])
            status_text = parts[2] if len(parts) > 2 else ''
            
            # Parse headers
            headers = {}
            for line in lines[1:]:
                if ': ' in line:
                    key, value = line.split(': ', 1)
                    headers[key] = value
            
            # Extract content type
            content_type = headers.get('Content-Type', '')
            
            # Extract content length
            content_length = headers.get('Content-Length', 0)
            
            return {
                'version': version,
                'status_code': status_code,
                'status_text': status_text,
                'headers': headers,
                'content_type': content_type,
                'content_length': int(content_length) if content_length else len(body),
                'body': body[:1000],  # Truncate large bodies
                'body_length': len(body)
            }
        
        except Exception as e:
            return None
    
    def analyze_tcp_stream(self, packet):
        """Analyze TCP stream for HTTP traffic."""
        if not packet.haslayer(TCP):
            return
        
        tcp = packet[TCP]
        
        # Check if this is HTTP traffic
        if tcp.sport not in [80, 8080, 8000, 443] and tcp.dport not in [80, 8080, 8000, 443]:
            return
        
        if not packet.haslayer(Raw):
            return
        
        raw = bytes(packet[Raw])
        
        # Try to parse as HTTP
        if raw[:4] in [b'GET ', b'POST', b'PUT ', b'HEAD', b'DELE', b'OPTI', b'HTTP']:
            # Check if it's a request
            if raw[:4] != b'HTTP':
                request = self.parse_http_request(raw)
                if request:
                    self.http_requests.append({
                        'timestamp': datetime.fromtimestamp(packet.time),
                        'src': packet[IP].src,
                        'dst': packet[IP].dst,
                        'sport': tcp.sport,
                        'dport': tcp.dport,
                        'request': request
                    })
                    
                    self.stats['total_requests'] += 1
                    self.stats['methods'][request['method']] += 1
                    if request['host']:
                        self.stats['hosts'][request['host']] += 1
                    if request['path']:
                        self.stats['paths'][request['path']] += 1
                    if request['user_agent']:
                        self.stats['user_agents'][request['user_agent']] += 1
                    
                    if request['suspicious']:
                        self.suspicious_requests.append({
                            'timestamp': datetime.fromtimestamp(packet.time),
                            'src': packet[IP].src,
                            'dst': packet[IP].dst,
                            'uri': request['uri'],
                            'suspicious': request['suspicious']
                        })
                        print(f"\n[!] Suspicious HTTP request from {packet[IP].src}: {request['uri']}")
                        print(f"    Patterns: {', '.join(request['suspicious'])}")
                    
                    # Add to session
                    session_key = f"{packet[IP].src}:{tcp.sport}-{packet[IP].dst}:{tcp.dport}"
                    self.sessions[session_key].append({
                        'type': 'request',
                        'timestamp': packet.time,
                        'data': request
                    })
            
            # Check if it's a response
            elif raw[:4] == b'HTTP':
                response = self.parse_http_response(raw)
                if response:
                    self.http_responses.append({
                        'timestamp': datetime.fromtimestamp(packet.time),
                        'src': packet[IP].src,
                        'dst': packet[IP].dst,
                        'sport': tcp.sport,
                        'dport': tcp.dport,
                        'response': response
                    })
                    
                    self.stats['total_responses'] += 1
                    self.stats['status_codes'][response['status_code']] += 1
                    if response['content_type']:
                        self.stats['content_types'][response['content_type']] += 1
                    
                    # Add to session
                    session_key = f"{packet[IP].dst}:{tcp.dport}-{packet[IP].src}:{tcp.sport}"
                    self.sessions[session_key].append({
                        'type': 'response',
                        'timestamp': packet.time,
                        'data': response
                    })
    
    def analyze_pcap(self, pcap_file):
        """Analyze HTTP traffic from a PCAP file."""
        print(f"\n[HTTP Analyzer] Analyzing PCAP: {pcap_file}")
        
        packets = rdpcap(pcap_file)
        print(f"Processing {len(packets)} packets...")
        
        for packet in packets:
            self.analyze_tcp_stream(packet)
        
        self.display_summary()
    
    def sniff_live(self, interface=None, count=1000, timeout=60):
        """Sniff live traffic for HTTP analysis."""
        
        interface = interface or conf.iface
        
        print("\n" + "=" * 60)
        print("HTTP DEEP ANALYZER - LIVE MODE")
        print("=" * 60)
        print(f"Interface: {interface}")
        print(f"Count: {count if count > 0 else 'Unlimited'}")
        print(f"Timeout: {timeout}s")
        print("-" * 60)
        print("Analyzing HTTP traffic...")
        
        try:
            sniff(
                iface=interface,
                filter="tcp port 80 or tcp port 8080 or tcp port 443",
                prn=self.analyze_tcp_stream,
                count=count if count > 0 else None,
                timeout=timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\nStopping...")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.display_summary()
    
    def display_summary(self):
        """Display HTTP analysis summary."""
        
        print("\n" + "=" * 60)
        print("HTTP ANALYSIS SUMMARY")
        print("=" * 60)
        
        print(f"Total Requests: {self.stats['total_requests']}")
        print(f"Total Responses: {self.stats['total_responses']}")
        print(f"Unique Hosts: {len(self.stats['hosts'])}")
        print(f"Unique Paths: {len(self.stats['paths'])}")
        
        print("\nHTTP Methods:")
        print("-" * 40)
        for method, count in sorted(self.stats['methods'].items(), 
                                    key=lambda x: x[1], reverse=True):
            print(f"  {method:<10}: {count:>6}")
        
        print("\nStatus Codes:")
        print("-" * 40)
        for code, count in sorted(self.stats['status_codes'].items(), 
                                  key=lambda x: x[1], reverse=True):
            print(f"  {code:<10}: {count:>6}")
        
        print("\nTop Hosts:")
        print("-" * 40)
        for host, count in sorted(self.stats['hosts'].items(), 
                                  key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {host:<30}: {count:>6}")
        
        print("\nTop User Agents:")
        print("-" * 40)
        for ua, count in sorted(self.stats['user_agents'].items(), 
                                key=lambda x: x[1], reverse=True)[:10]:
            ua_short = ua[:40] + '...' if len(ua) > 40 else ua
            print(f"  {ua_short:<40}: {count:>6}")
        
        if self.suspicious_requests:
            print(f"\n⚠️ Suspicious Requests Detected: {len(self.suspicious_requests)}")
            print("-" * 40)
            for req in self.suspicious_requests[:10]:
                print(f"  {req['src']} -> {req['uri'][:50]}")
                print(f"    Patterns: {', '.join(req['suspicious'])}")
            if len(self.suspicious_requests) > 10:
                print(f"  ... and {len(self.suspicious_requests) - 10} more")
        
        print("\n" + "=" * 60)
    
    def export_results(self, filename=None):
        """Export HTTP analysis results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/http_analysis_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'stats': dict(self.stats),
            'suspicious': self.suspicious_requests,
            'requests': self.http_requests[:100],  # Limit
            'responses': self.http_responses[:100]
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"\nResults exported to: {filename}")

def main():
    """Main function for HTTP analyzer."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='HTTP Deep Analyzer')
    parser.add_argument('file', nargs='?', help='PCAP file to analyze')
    parser.add_argument('-i', '--interface', help='Interface for live capture')
    parser.add_argument('-c', '--count', type=int, default=1000,
                        help='Number of packets to capture')
    parser.add_argument('-t', '--timeout', type=int, default=60,
                        help='Capture timeout in seconds')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    
    args = parser.parse_args()
    
    analyzer = HTTPAnalyzer()
    
    if args.file:
        # Analyze PCAP file
        analyzer.analyze_pcap(args.file)
        if args.export:
            analyzer.export_results()
    else:
        # Live capture
        interface = args.interface or conf.iface
        analyzer.sniff_live(interface, args.count, args.timeout)
        if args.export:
            analyzer.export_results()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("HTTP DEEP ANALYZER")
        print("=" * 60)
        
        choice = input("\nAnalyze PCAP file or sniff live? (pcap/live): ").strip().lower()
        
        if choice == 'pcap':
            file_path = input("Enter PCAP file path: ").strip()
            if file_path:
                analyzer = HTTPAnalyzer()
                analyzer.analyze_pcap(file_path)
                export = input("Export results to JSON? (y/n): ").strip().lower()
                if export == 'y':
                    analyzer.export_results()
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
            
            analyzer = HTTPAnalyzer()
            analyzer.sniff_live(interface)
    else:
        main()
```

### Step 2: DNS Monitor with Caching

Create `src/dns_monitor.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 2: DNS Monitor with Caching

This script provides real-time DNS monitoring with caching,
query/response tracking, and anomaly detection.
"""

from scapy.all import sniff, IP, UDP, DNS, DNSQR, DNSRR, conf, get_if_list
from scapy.all import rdpcap, wrpcap
import os
import sys
import time
import json
from datetime import datetime, timedelta
from collections import defaultdict, deque
import threading

class DNSMonitor:
    """
    Real-time DNS monitor with caching and anomaly detection.
    
    Features:
    - DNS query/response tracking
    - DNS caching
    - Query rate monitoring
    - Domain blocking
    - Suspicious domain detection
    - Statistics export
    """
    
    def __init__(self, cache_ttl=300, max_cache=1000):
        """
        Initialize DNS monitor.
        
        Args:
            cache_ttl: Cache TTL in seconds
            max_cache: Maximum cache entries
        """
        self.cache = {}
        self.cache_ttl = cache_ttl
        self.max_cache = max_cache
        
        self.queries = []
        self.responses = []
        self.query_count = 0
        self.response_count = 0
        
        # Rate tracking
        self.query_rate_window = deque(maxlen=60)  # Last 60 seconds
        self.query_rate_lock = threading.Lock()
        
        # Statistics
        self.stats = {
            'total_queries': 0,
            'total_responses': 0,
            'unique_domains': 0,
            'cache_hits': 0,
            'cache_misses': 0,
            'suspicious_queries': 0,
            'blocked_queries': 0,
            'top_domains': defaultdict(int),
            'top_queryers': defaultdict(int)
        }
        
        # Suspicious patterns
        self.suspicious_patterns = {
            'random_subdomain': re.compile(r'^[a-z0-9]{8,}\.', re.IGNORECASE),
            'long_domain': re.compile(r'.{50,}\.'),
            'base64_domain': re.compile(r'^[A-Za-z0-9+/]{20,}\=*\.'),
            'dynamic_dns': re.compile(r'(dyndns|no-ip|ddns|dynamic-dns)\.', re.IGNORECASE)
        }
        
        # Blocklist
        self.blocklist = set()
        
        # Running state
        self.running = True
        
        print(f"\n[DNS Monitor] Initialized:")
        print(f"  Cache TTL: {cache_ttl}s")
        print(f"  Max Cache: {max_cache}")
        print("  Monitoring DNS traffic...")
    
    def cache_lookup(self, domain):
        """Look up domain in cache."""
        if domain in self.cache:
            entry = self.cache[domain]
            if time.time() - entry['timestamp'] < self.cache_ttl:
                self.stats['cache_hits'] += 1
                return entry['data']
            else:
                # Expired
                del self.cache[domain]
        
        self.stats['cache_misses'] += 1
        return None
    
    def cache_store(self, domain, data):
        """Store domain in cache."""
        if len(self.cache) >= self.max_cache:
            # Remove oldest entries
            oldest = sorted(self.cache.items(), key=lambda x: x[1]['timestamp'])[:100]
            for key, _ in oldest:
                del self.cache[key]
        
        self.cache[domain] = {
            'data': data,
            'timestamp': time.time()
        }
    
    def is_suspicious(self, domain):
        """Check if domain is suspicious."""
        for pattern_name, pattern in self.suspicious_patterns.items():
            if pattern.search(domain):
                return pattern_name
        return None
    
    def is_blocked(self, domain):
        """Check if domain is blocked."""
        for blocked in self.blocklist:
            if domain.endswith(blocked) or blocked in domain:
                return True
        return False
    
    def process_dns_query(self, packet, dns):
        """Process DNS query."""
        if not dns.qd:
            return
        
        query = dns.qd
        domain = query.qname.decode('utf-8') if query.qname else ''
        qtype = query.qtype
        
        # Remove trailing dot
        if domain.endswith('.'):
            domain = domain[:-1]
        
        self.query_count += 1
        self.stats['total_queries'] += 1
        self.stats['top_domains'][domain] += 1
        
        # Track query rate
        with self.query_rate_lock:
            self.query_rate_window.append(time.time())
        
        # Get source
        src_ip = packet[IP].src
        self.stats['top_queryers'][src_ip] += 1
        
        # Check if suspicious
        suspicion = self.is_suspicious(domain)
        if suspicion:
            self.stats['suspicious_queries'] += 1
            print(f"\n[!] Suspicious DNS query: {domain} (Pattern: {suspicion}) from {src_ip}")
        
        # Check if blocked
        if self.is_blocked(domain):
            self.stats['blocked_queries'] += 1
            print(f"\n[BLOCK] Blocked DNS query: {domain} from {src_ip}")
            return
        
        # Check cache
        cached = self.cache_lookup(domain)
        if cached:
            print(f"[DNS] Cache hit: {domain} -> {cached}")
        else:
            print(f"[DNS] Query: {domain} (Type: {qtype}) from {src_ip}")
        
        self.queries.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'src': src_ip,
            'dst': packet[IP].dst,
            'domain': domain,
            'qtype': qtype,
            'suspicious': suspicion
        })
    
    def process_dns_response(self, packet, dns):
        """Process DNS response."""
        if not dns.an:
            return
        
        self.response_count += 1
        self.stats['total_responses'] += 1
        
        answers = []
        for answer in dns.an:
            if isinstance(answer, DNSRR):
                domain = answer.rrname.decode('utf-8') if answer.rrname else ''
                if domain.endswith('.'):
                    domain = domain[:-1]
                
                rdata = str(answer.rdata)
                answers.append({
                    'domain': domain,
                    'type': answer.type,
                    'rdata': rdata
                })
                
                # Store in cache
                self.cache_store(domain, rdata)
        
        if answers:
            print(f"[DNS] Response: {answers[0]['domain']} -> {answers[0]['rdata']}")
        
        self.responses.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'src': packet[IP].src,
            'dst': packet[IP].dst,
            'answers': answers
        })
    
    def packet_callback(self, packet):
        """Callback for DNS packet processing."""
        if not packet.haslayer(DNS):
            return
        
        dns = packet[DNS]
        
        if dns.qr == 0:  # Query
            self.process_dns_query(packet, dns)
        else:  # Response
            self.process_dns_response(packet, dns)
    
    def get_query_rate(self):
        """Get current query rate (queries per second)."""
        with self.query_rate_lock:
            if not self.query_rate_window:
                return 0
            
            now = time.time()
            recent = [t for t in self.query_rate_window if now - t < 1]
            return len(recent)
    
    def monitor_live(self, interface=None, timeout=None):
        """Monitor DNS traffic live."""
        
        interface = interface or conf.iface
        
        print("\n" + "=" * 60)
        print("DNS MONITOR - LIVE MODE")
        print("=" * 60)
        print(f"Interface: {interface}")
        print(f"Cache TTL: {self.cache_ttl}s")
        print(f"Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        
        try:
            sniff(
                iface=interface,
                filter="udp port 53",
                prn=self.packet_callback,
                timeout=timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\nStopping monitor...")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.display_summary()
    
    def analyze_pcap(self, pcap_file):
        """Analyze DNS traffic from PCAP."""
        
        print(f"\n[DNS Monitor] Analyzing PCAP: {pcap_file}")
        
        packets = rdpcap(pcap_file)
        print(f"Processing {len(packets)} packets...")
        
        for packet in packets:
            self.packet_callback(packet)
        
        self.display_summary()
    
    def display_summary(self):
        """Display DNS monitor summary."""
        
        elapsed = time.time() - self.start_time if hasattr(self, 'start_time') else 0
        
        print("\n" + "=" * 60)
        print("DNS MONITOR SUMMARY")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f}s" if elapsed else "Duration: N/A")
        print(f"Queries: {self.stats['total_queries']}")
        print(f"Responses: {self.stats['total_responses']}")
        print(f"Unique Domains: {len(self.stats['top_domains'])}")
        print(f"Cache Hits: {self.stats['cache_hits']}")
        print(f"Cache Misses: {self.stats['cache_misses']}")
        print(f"Cache Hit Rate: {self.stats['cache_hits'] / max(1, self.stats['cache_hits'] + self.stats['cache_misses']) * 100:.1f}%")
        print(f"Suspicious Queries: {self.stats['suspicious_queries']}")
        print(f"Blocked Queries: {self.stats['blocked_queries']}")
        
        print("\nTop Domains:")
        print("-" * 40)
        for domain, count in sorted(self.stats['top_domains'].items(), 
                                    key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {domain:<40}: {count:>6}")
        
        print("\nTop Query Sources:")
        print("-" * 40)
        for src, count in sorted(self.stats['top_queryers'].items(), 
                                 key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {src:<20}: {count:>6}")
        
        print("\nCache Contents:")
        print("-" * 40)
        for domain, entry in sorted(self.cache.items())[:10]:
            age = time.time() - entry['timestamp']
            print(f"  {domain:<40}: {entry['data']} (age: {age:.1f}s)")
        
        print("\n" + "=" * 60)
    
    def export_results(self, filename=None):
        """Export DNS monitor results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/dns_analysis_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'stats': dict(self.stats),
            'queries': self.queries[-100:],
            'responses': self.responses[-100:],
            'cache': {k: {'data': v['data'], 'age': time.time() - v['timestamp']} 
                     for k, v in list(self.cache.items())[:100]}
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"\nResults exported to: {filename}")

def main():
    """Main function for DNS monitor."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='DNS Monitor with Caching')
    parser.add_argument('file', nargs='?', help='PCAP file to analyze')
    parser.add_argument('-i', '--interface', help='Interface for live capture')
    parser.add_argument('-c', '--cache-ttl', type=int, default=300,
                        help='Cache TTL in seconds')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    parser.add_argument('-b', '--blocklist', help='File with domains to block')
    
    args = parser.parse_args()
    
    monitor = DNSMonitor(cache_ttl=args.cache_ttl)
    
    # Load blocklist if provided
    if args.blocklist and os.path.exists(args.blocklist):
        with open(args.blocklist, 'r') as f:
            for line in f:
                domain = line.strip()
                if domain:
                    monitor.blocklist.add(domain)
        print(f"Loaded {len(monitor.blocklist)} domains to blocklist")
    
    if args.file:
        monitor.analyze_pcap(args.file)
        if args.export:
            monitor.export_results()
    else:
        interface = args.interface or conf.iface
        monitor.monitor_live(interface)
        if args.export:
            monitor.export_results()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("DNS MONITOR")
        print("=" * 60)
        
        choice = input("\nAnalyze PCAP file or sniff live? (pcap/live): ").strip().lower()
        
        monitor = DNSMonitor()
        
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
            
            monitor.monitor_live(interface)
    else:
        main()
```

### Step 3: DHCP Analyzer and Anomaly Detector

Create `src/dhcp_analyzer.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 2: DHCP Analyzer

This script analyzes DHCP traffic, tracks DORA sequences,
and detects rogue DHCP servers.
"""

from scapy.all import sniff, IP, UDP, DHCP, BOOTP, Ether, conf, get_if_list
from scapy.all import rdpcap
import os
import sys
import time
import json
from datetime import datetime
from collections import defaultdict

class DHCPAnalyzer:
    """
    DHCP traffic analyzer with DORA sequence tracking.
    
    Features:
    - DHCP DORA sequence tracking
    - Rogue DHCP server detection
    - Lease analysis
    - Option extraction
    - Statistics
    """
    
    def __init__(self):
        """Initialize DHCP analyzer."""
        self.dhcp_packets = []
        self.dora_sequences = []
        self.dhcp_servers = {}
        self.clients = {}
        
        # Statistics
        self.stats = {
            'total_packets': 0,
            'discover': 0,
            'offer': 0,
            'request': 0,
            'ack': 0,
            'nak': 0,
            'decline': 0,
            'release': 0
        }
        
        # DORA tracking
        self.pending_discoveries = {}
        self.offers = {}
        
        # Rogue detection
        self.authorized_servers = set()
        self.potential_rogue = []
        self.start_time = None
        
        print("\n[DHCP Analyzer] Initialized:")
        print("  Tracking DORA sequences")
        print("  Rogue DHCP server detection enabled")
    
    def get_dhcp_type(self, packet):
        """Extract DHCP message type."""
        if not packet.haslayer(DHCP):
            return None
        
        dhcp = packet[DHCP]
        for option in dhcp.options:
            if isinstance(option, tuple) and len(option) == 2:
                if option[0] == 'message-type':
                    return option[1]
        return None
    
    def get_dhcp_options(self, packet):
        """Extract DHCP options as dictionary."""
        options = {}
        if not packet.haslayer(DHCP):
            return options
        
        dhcp = packet[DHCP]
        for option in dhcp.options:
            if isinstance(option, tuple) and len(option) == 2:
                key, value = option
                if key not in ['end', 'pad']:
                    options[key] = value
        
        return options
    
    def process_dhcp_discover(self, packet, bootp, options):
        """Process DHCP Discover."""
        client_mac = bootp.chaddr
        src_ip = packet[IP].src
        
        print(f"\n[DHCP] Discover from {client_mac} ({src_ip})")
        
        # Store pending discovery
        self.pending_discoveries[client_mac] = {
            'timestamp': packet.time,
            'src_ip': src_ip,
            'options': options,
            'sequence': 'DISCOVER'
        }
        
        self.dhcp_packets.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'type': 'DISCOVER',
            'client_mac': client_mac,
            'src_ip': src_ip,
            'options': options
        })
    
    def process_dhcp_offer(self, packet, bootp, options):
        """Process DHCP Offer."""
        client_mac = bootp.chaddr
        src_ip = packet[IP].src
        offered_ip = bootp.yiaddr
        
        print(f"\n[DHCP] Offer from {src_ip}: {offered_ip} -> {client_mac}")
        
        # Track DHCP server
        if src_ip not in self.dhcp_servers:
            self.dhcp_servers[src_ip] = {
                'mac': packet[Ether].src,
                'offers': 0,
                'first_seen': datetime.fromtimestamp(packet.time)
            }
        self.dhcp_servers[src_ip]['offers'] += 1
        
        # Check if this is a rogue server
        if self.authorized_servers and src_ip not in self.authorized_servers:
            self.potential_rogue.append({
                'server_ip': src_ip,
                'server_mac': packet[Ether].src,
                'detected_at': datetime.fromtimestamp(packet.time),
                'offered_ip': offered_ip,
                'client_mac': client_mac
            })
            print(f"  ⚠️ Potential rogue DHCP server: {src_ip}")
        
        # Store offer
        offer_key = f"{src_ip}:{offered_ip}"
        self.offers[offer_key] = {
            'timestamp': packet.time,
            'server_ip': src_ip,
            'offered_ip': offered_ip,
            'client_mac': client_mac,
            'options': options
        }
        
        self.dhcp_packets.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'type': 'OFFER',
            'server_ip': src_ip,
            'client_mac': client_mac,
            'offered_ip': offered_ip,
            'options': options
        })
    
    def process_dhcp_request(self, packet, bootp, options):
        """Process DHCP Request."""
        client_mac = bootp.chaddr
        src_ip = packet[IP].src
        
        # Find requested IP
        requested_ip = None
        server_id = None
        for key, value in options.items():
            if key == 'requested_addr':
                requested_ip = str(value)
            elif key == 'server_id':
                server_id = str(value)
        
        print(f"\n[DHCP] Request from {client_mac}: requesting {requested_ip} from {server_id}")
        
        # Check if this client had a discovery
        if client_mac in self.pending_discoveries:
            del self.pending_discoveries[client_mac]
        
        # Track client
        if client_mac not in self.clients:
            self.clients[client_mac] = {
                'ip': src_ip,
                'first_seen': datetime.fromtimestamp(packet.time),
                'requests': 0
            }
        self.clients[client_mac]['requests'] += 1
        
        self.dhcp_packets.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'type': 'REQUEST',
            'client_mac': client_mac,
            'src_ip': src_ip,
            'requested_ip': requested_ip,
            'server_id': server_id,
            'options': options
        })
    
    def process_dhcp_ack(self, packet, bootp, options):
        """Process DHCP ACK."""
        client_mac = bootp.chaddr
        assigned_ip = bootp.yiaddr
        src_ip = packet[IP].src
        
        print(f"\n[DHCP] ACK from {src_ip}: {assigned_ip} -> {client_mac}")
        
        # Complete the DORA sequence
        if client_mac in self.pending_discoveries:
            # Build complete DORA sequence
            dora_sequence = {
                'timestamp': datetime.fromtimestamp(packet.time),
                'client_mac': client_mac,
                'discover': self.pending_discoveries[client_mac],
                'offer': None,
                'request': None,
                'ack': {
                    'timestamp': packet.time,
                    'server_ip': src_ip,
                    'assigned_ip': assigned_ip,
                    'options': options
                },
                'duration': packet.time - self.pending_discoveries[client_mac]['timestamp']
            }
            
            # Find matching offer
            for offer_key, offer in self.offers.items():
                if offer['client_mac'] == client_mac and offer['offered_ip'] == assigned_ip:
                    dora_sequence['offer'] = offer
                    break
            
            self.dora_sequences.append(dora_sequence)
            print(f"  ✓ DORA sequence completed in {dora_sequence['duration']:.2f}s")
            
            # Clean up
            if client_mac in self.pending_discoveries:
                del self.pending_discoveries[client_mac]
        
        self.dhcp_packets.append({
            'timestamp': datetime.fromtimestamp(packet.time),
            'type': 'ACK',
            'server_ip': src_ip,
            'client_mac': client_mac,
            'assigned_ip': assigned_ip,
            'options': options
        })
    
    def process_dhcp_packet(self, packet):
        """Main DHCP packet processing."""
        if not packet.haslayer(DHCP):
            return
        
        self.stats['total_packets'] += 1
        
        dhcp_type = self.get_dhcp_type(packet)
        if dhcp_type is None:
            return
        
        bootp = packet[BOOTP]
        options = self.get_dhcp_options(packet)
        
        # Map DHCP types to handler functions
        type_handlers = {
            1: self.process_dhcp_discover,
            2: self.process_dhcp_offer,
            3: self.process_dhcp_request,
            4: self.process_dhcp_decline,
            5: self.process_dhcp_ack,
            6: self.process_dhcp_nak,
            7: self.process_dhcp_release,
            8: self.process_dhcp_inform
        }
        
        # Update statistics
        type_names = {
            1: 'discover',
            2: 'offer',
            3: 'request',
            4: 'decline',
            5: 'ack',
            6: 'nak',
            7: 'release',
            8: 'inform'
        }
        type_name = type_names.get(dhcp_type, 'unknown')
        if type_name in self.stats:
            self.stats[type_name] += 1
        
        # Process if we have a handler
        if dhcp_type in type_handlers:
            handler = type_handlers[dhcp_type]
            handler(packet, bootp, options)
    
    def process_dhcp_decline(self, packet, bootp, options):
        """Process DHCP Decline."""
        print(f"\n[DHCP] Decline from {bootp.chaddr}")
        self.stats['decline'] += 1
    
    def process_dhcp_nak(self, packet, bootp, options):
        """Process DHCP NAK."""
        print(f"\n[DHCP] NAK from {packet[IP].src} for {bootp.chaddr}")
        self.stats['nak'] += 1
    
    def process_dhcp_release(self, packet, bootp, options):
        """Process DHCP Release."""
        print(f"\n[DHCP] Release from {bootp.chaddr}")
        self.stats['release'] += 1
    
    def process_dhcp_inform(self, packet, bootp, options):
        """Process DHCP Inform."""
        print(f"\n[DHCP] Inform from {bootp.chaddr}")
        self.stats['inform'] += 1
    
    def monitor_live(self, interface=None, timeout=None):
        """Monitor DHCP traffic live."""
        
        interface = interface or conf.iface
        
        print("\n" + "=" * 60)
        print("DHCP ANALYZER - LIVE MODE")
        print("=" * 60)
        print(f"Interface: {interface}")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        
        try:
            sniff(
                iface=interface,
                filter="udp port 67 or udp port 68",
                prn=self.process_dhcp_packet,
                timeout=timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\nStopping...")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.display_summary()
    
    def analyze_pcap(self, pcap_file):
        """Analyze DHCP traffic from PCAP."""
        
        print(f"\n[DHCP Analyzer] Analyzing PCAP: {pcap_file}")
        
        packets = rdpcap(pcap_file)
        print(f"Processing {len(packets)} packets...")
        
        for packet in packets:
            self.process_dhcp_packet(packet)
        
        self.display_summary()
    
    def display_summary(self):
        """Display DHCP analysis summary."""
        
        elapsed = time.time() - self.start_time if self.start_time else 0
        
        print("\n" + "=" * 60)
        print("DHCP ANALYSIS SUMMARY")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f}s" if elapsed else "Duration: N/A")
        print(f"Total DHCP Packets: {self.stats['total_packets']}")
        print("-" * 40)
        
        print("\nMessage Types:")
        print("-" * 40)
        msg_types = {
            'discover': 'DISCOVER',
            'offer': 'OFFER',
            'request': 'REQUEST',
            'ack': 'ACK',
            'nak': 'NAK',
            'decline': 'DECLINE',
            'release': 'RELEASE',
            'inform': 'INFORM'
        }
        
        for key, label in msg_types.items():
            count = self.stats.get(key, 0)
            if count > 0:
                print(f"  {label:<10}: {count:>6}")
        
        print(f"\nComplete DORA Sequences: {len(self.dora_sequences)}")
        
        if self.dora_sequences:
            # Calculate average DORA duration
            durations = [s['duration'] for s in self.dora_sequences]
            avg_duration = sum(durations) / len(durations)
            print(f"  Average DORA duration: {avg_duration:.2f}s")
            print(f"  Min: {min(durations):.2f}s, Max: {max(durations):.2f}s")
        
        print(f"\nDHCP Servers Detected: {len(self.dhcp_servers)}")
        for server, data in self.dhcp_servers.items():
            status = "⚠️ ROGUE" if self.authorized_servers and server not in self.authorized_servers else "✓ Authorized"
            print(f"  {server} ({data['mac']}) - {data['offers']} offers - {status}")
        
        if self.potential_rogue:
            print(f"\n⚠️ Potential Rogue DHCP Servers: {len(self.potential_rogue)}")
            print("-" * 40)
            for rogue in self.potential_rogue[:10]:
                print(f"  {rogue['server_ip']} ({rogue['server_mac']})")
                print(f"    Offered {rogue['offered_ip']} to {rogue['client_mac']}")
        
        print(f"\nClients: {len(self.clients)}")
        
        print("\n" + "=" * 60)
    
    def export_results(self, filename=None):
        """Export DHCP analysis results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/dhcp_analysis_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'stats': self.stats,
            'servers': self.dhcp_servers,
            'clients': self.clients,
            'dora_sequences': self.dora_sequences,
            'potential_rogue': self.potential_rogue
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"\nResults exported to: {filename}")

def main():
    """Main function for DHCP analyzer."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='DHCP Analyzer')
    parser.add_argument('file', nargs='?', help='PCAP file to analyze')
    parser.add_argument('-i', '--interface', help='Interface for live capture')
    parser.add_argument('-a', '--authorized', help='Authorized DHCP server IP')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    
    args = parser.parse_args()
    
    analyzer = DHCPAnalyzer()
    
    if args.authorized:
        analyzer.authorized_servers.add(args.authorized)
        print(f"Authorized DHCP server: {args.authorized}")
    
    if args.file:
        analyzer.analyze_pcap(args.file)
        if args.export:
            analyzer.export_results()
    else:
        interface = args.interface or conf.iface
        analyzer.monitor_live(interface)
        if args.export:
            analyzer.export_results()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("DHCP ANALYZER")
        print("=" * 60)
        
        choice = input("\nAnalyze PCAP file or sniff live? (pcap/live): ").strip().lower()
        
        analyzer = DHCPAnalyzer()
        
        if choice == 'pcap':
            file_path = input("Enter PCAP file path: ").strip()
            if file_path:
                analyzer.analyze_pcap(file_path)
                export = input("Export results to JSON? (y/n): ").strip().lower()
                if export == 'y':
                    analyzer.export_results()
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
            
            authorized = input("Enter authorized DHCP server IP (optional): ").strip()
            if authorized:
                analyzer.authorized_servers.add(authorized)
                print(f"Authorized DHCP server: {authorized}")
            
            analyzer.monitor_live(interface)
    else:
        main()
```

### Step 4: Traffic Statistics Engine

Create `src/traffic_stats_engine.py`:

```python
#!/usr/bin/env python3
"""
Module 4, Part 2: Traffic Statistics Engine

This script provides comprehensive traffic statistics
including protocol distribution, top talkers, and
network metrics.
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP, Ether, conf, get_if_list
from scapy.all import rdpcap, wrpcap
import os
import sys
import time
import json
import csv
from datetime import datetime
from collections import defaultdict, deque
import threading

class TrafficStatsEngine:
    """
    Comprehensive traffic statistics engine.
    
    Features:
    - Protocol distribution
    - Top talkers (IP addresses)
    - Top ports
    - Flow tracking
    - Packet/byte rates
    - TCP flag statistics
    - Export to CSV and JSON
    """
    
    def __init__(self, interface=None, filter_str=None, window_size=10):
        """
        Initialize traffic stats engine.
        
        Args:
            interface: Network interface
            filter_str: BPF filter
            window_size: Window size for rate calculation (seconds)
        """
        self.interface = interface or conf.iface
        self.filter_str = filter_str
        self.window_size = window_size
        
        self.packet_count = 0
        self.byte_count = 0
        self.start_time = None
        self.last_update_time = None
        
        # Protocol distribution
        self.protocol_counts = defaultdict(int)
        self.protocol_bytes = defaultdict(int)
        
        # IP talkers
        self.src_ips = defaultdict(int)
        self.dst_ips = defaultdict(int)
        self.src_bytes = defaultdict(int)
        self.dst_bytes = defaultdict(int)
        
        # Port statistics
        self.tcp_ports = defaultdict(int)
        self.udp_ports = defaultdict(int)
        self.tcp_port_bytes = defaultdict(int)
        self.udp_port_bytes = defaultdict(int)
        
        # TCP flag statistics
        self.tcp_flags = defaultdict(int)
        
        # Flow tracking
        self.flows = defaultdict(lambda: {'packets': 0, 'bytes': 0, 'start': 0, 'last': 0})
        
        # Rate tracking (sliding windows)
        self.packet_timestamps = deque(maxlen=10000)
        self.byte_timestamps = deque(maxlen=10000)
        
        # Running state
        self.running = True
        self.stats_lock = threading.Lock()
        
        print(f"\n[Stats Engine] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Filter: {self.filter_str or 'None'}")
        print(f"  Window: {self.window_size}s")
    
    def packet_callback(self, packet):
        """Process each packet and update statistics."""
        
        with self.stats_lock:
            self.packet_count += 1
            packet_len = len(packet)
            self.byte_count += packet_len
            
            timestamp = time.time()
            self.packet_timestamps.append((timestamp, packet_len))
            self.byte_timestamps.append((timestamp, packet_len))
            
            # Update flow
            flow_key = None
            if packet.haslayer(IP):
                ip = packet[IP]
                
                # Update IP talkers
                self.src_ips[ip.src] += 1
                self.dst_ips[ip.dst] += 1
                self.src_bytes[ip.src] += packet_len
                self.dst_bytes[ip.dst] += packet_len
                
                # Update protocol distribution
                if packet.haslayer(TCP):
                    tcp = packet[TCP]
                    self.protocol_counts['TCP'] += 1
                    self.protocol_bytes['TCP'] += packet_len
                    
                    # Update port statistics
                    self.tcp_ports[tcp.sport] += 1
                    self.tcp_ports[tcp.dport] += 1
                    self.tcp_port_bytes[tcp.sport] += packet_len
                    self.tcp_port_bytes[tcp.dport] += packet_len
                    
                    # Update TCP flags
                    flag_str = self.get_tcp_flags(tcp.flags)
                    self.tcp_flags[flag_str] += 1
                    
                    # Update flow
                    flow_key = f"TCP:{ip.src}:{tcp.sport}->{ip.dst}:{tcp.dport}"
                    
                elif packet.haslayer(UDP):
                    udp = packet[UDP]
                    self.protocol_counts['UDP'] += 1
                    self.protocol_bytes['UDP'] += packet_len
                    
                    # Update port statistics
                    self.udp_ports[udp.sport] += 1
                    self.udp_ports[udp.dport] += 1
                    self.udp_port_bytes[udp.sport] += packet_len
                    self.udp_port_bytes[udp.dport] += packet_len
                    
                    # Update flow
                    flow_key = f"UDP:{ip.src}:{udp.sport}->{ip.dst}:{udp.dport}"
                    
                elif packet.haslayer(ICMP):
                    self.protocol_counts['ICMP'] += 1
                    self.protocol_bytes['ICMP'] += packet_len
                    flow_key = f"ICMP:{ip.src}->{ip.dst}"
                    
                else:
                    self.protocol_counts['Other_IP'] += 1
                    self.protocol_bytes['Other_IP'] += packet_len
                    flow_key = f"IP:{ip.src}->{ip.dst}"
            else:
                self.protocol_counts['Non_IP'] += 1
                self.protocol_bytes['Non_IP'] += packet_len
                flow_key = f"Non-IP:{packet.summary()[:20]}"
            
            # Update flow
            if flow_key:
                if self.flows[flow_key]['start'] == 0:
                    self.flows[flow_key]['start'] = timestamp
                self.flows[flow_key]['packets'] += 1
                self.flows[flow_key]['bytes'] += packet_len
                self.flows[flow_key]['last'] = timestamp
    
    def get_tcp_flags(self, flags):
        """Convert TCP flags to string."""
        flag_names = []
        if flags & 0x01: flag_names.append('FIN')
        if flags & 0x02: flag_names.append('SYN')
        if flags & 0x04: flag_names.append('RST')
        if flags & 0x08: flag_names.append('PSH')
        if flags & 0x10: flag_names.append('ACK')
        if flags & 0x20: flag_names.append('URG')
        if flags & 0x40: flag_names.append('ECE')
        if flags & 0x80: flag_names.append('CWR')
        return '+'.join(flag_names) if flag_names else 'None'
    
    def get_rates(self):
        """Calculate packet and byte rates."""
        with self.stats_lock:
            now = time.time()
            
            # Calculate rates using sliding window
            recent_packets = [t for t, _ in self.packet_timestamps if now - t <= self.window_size]
            recent_bytes = [b for _, b in self.byte_timestamps if now - t <= self.window_size]
            
            packet_rate = len(recent_packets) / self.window_size if self.window_size > 0 else 0
            byte_rate = sum(recent_bytes) / self.window_size if self.window_size > 0 else 0
            
            return packet_rate, byte_rate
    
    def get_stats(self):
        """Get current statistics snapshot."""
        with self.stats_lock:
            packet_rate, byte_rate = self.get_rates()
            
            return {
                'total_packets': self.packet_count,
                'total_bytes': self.byte_count,
                'packet_rate': packet_rate,
                'byte_rate': byte_rate,
                'protocols': dict(self.protocol_counts),
                'protocol_bytes': dict(self.protocol_bytes),
                'top_src_ips': sorted(self.src_ips.items(), key=lambda x: x[1], reverse=True)[:10],
                'top_dst_ips': sorted(self.dst_ips.items(), key=lambda x: x[1], reverse=True)[:10],
                'top_tcp_ports': sorted(self.tcp_ports.items(), key=lambda x: x[1], reverse=True)[:10],
                'top_udp_ports': sorted(self.udp_ports.items(), key=lambda x: x[1], reverse=True)[:10],
                'tcp_flags': dict(self.tcp_flags),
                'top_flows': sorted(self.flows.items(), key=lambda x: x[1]['packets'], reverse=True)[:10]
            }
    
    def monitor_live(self, timeout=None):
        """Monitor live traffic."""
        
        print("\n" + "=" * 60)
        print("TRAFFIC STATISTICS ENGINE - LIVE MODE")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        self.last_update_time = self.start_time
        
        # Start stats display thread
        display_thread = threading.Thread(target=self.display_stats_loop)
        display_thread.daemon = True
        display_thread.start()
        
        try:
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self.packet_callback,
                timeout=timeout,
                store=False
            )
        except KeyboardInterrupt:
            print("\nStopping...")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.running = False
            self.display_final_stats()
    
    def display_stats_loop(self):
        """Periodically display statistics."""
        
        while self.running:
            time.sleep(5)
            if self.packet_count > 0:
                self.display_current_stats()
    
    def display_current_stats(self):
        """Display current statistics."""
        
        stats = self.get_stats()
        
        # Clear screen
        os.system('clear' if os.name == 'posix' else 'cls')
        
        print("=" * 70)
        print(f"TRAFFIC STATISTICS - {datetime.now().strftime('%H:%M:%S')}")
        print("=" * 70)
        
        print(f"\nTotal Packets: {stats['total_packets']:,}")
        print(f"Total Bytes: {stats['total_bytes']:,}")
        print(f"Packet Rate: {stats['packet_rate']:.2f}/s")
        print(f"Byte Rate: {stats['byte_rate']/1024:.2f} KB/s")
        
        print("\nProtocol Distribution:")
        print("-" * 50)
        total = max(1, stats['total_packets'])
        for proto, count in sorted(stats['protocols'].items(), 
                                   key=lambda x: x[1], reverse=True):
            percentage = (count / total) * 100
            bar = "█" * int(percentage / 2)
            print(f"  {proto:<10}: {count:>8} ({percentage:>5.1f}%) {bar}")
        
        print("\nTop Source IPs:")
        print("-" * 50)
        for ip, count in stats['top_src_ips'][:5]:
            print(f"  {ip:<20}: {count:>8}")
        
        print("\nTop Destination IPs:")
        print("-" * 50)
        for ip, count in stats['top_dst_ips'][:5]:
            print(f"  {ip:<20}: {count:>8}")
        
        if stats['top_tcp_ports']:
            print("\nTop TCP Ports:")
            print("-" * 50)
            for port, count in stats['top_tcp_ports'][:5]:
                print(f"  {port:<8}: {count:>8}")
        
        if stats['top_udp_ports']:
            print("\nTop UDP Ports:")
            print("-" * 50)
            for port, count in stats['top_udp_ports'][:5]:
                print(f"  {port:<8}: {count:>8}")
        
        print("\n" + "=" * 70)
    
    def display_final_stats(self):
        """Display final statistics summary."""
        
        stats = self.get_stats()
        elapsed = time.time() - self.start_time if self.start_time else 0
        
        print("\n" + "=" * 70)
        print("FINAL TRAFFIC STATISTICS")
        print("=" * 70)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Total Packets: {stats['total_packets']:,}")
        print(f"Total Bytes: {stats['total_bytes']:,}")
        print(f"Average Packet Rate: {stats['total_packets'] / max(1, elapsed):.2f}/s")
        print(f"Average Byte Rate: {stats['total_bytes'] / max(1, elapsed):.2f} B/s")
        print("-" * 70)
        
        print("\nProtocol Distribution:")
        print("-" * 50)
        total = max(1, stats['total_packets'])
        for proto, count in sorted(stats['protocols'].items(), 
                                   key=lambda x: x[1], reverse=True):
            percentage = (count / total) * 100
            print(f"  {proto:<10}: {count:>8} ({percentage:>5.1f}%)")
        
        print(f"\nActive Flows: {len(stats['top_flows'])}")
        
        print("\n" + "=" * 70)
    
    def analyze_pcap(self, pcap_file):
        """Analyze PCAP file."""
        
        print(f"\n[Stats Engine] Analyzing PCAP: {pcap_file}")
        
        packets = rdpcap(pcap_file)
        print(f"Processing {len(packets)} packets...")
        
        self.start_time = time.time()
        for packet in packets:
            self.packet_callback(packet)
        
        self.display_final_stats()
        return self.get_stats()
    
    def export_stats(self, filename=None, format='json'):
        """Export statistics to file."""
        
        stats = self.get_stats()
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/traffic_stats_{timestamp}.{format}"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        if format == 'json':
            with open(filename, 'w') as f:
                json.dump(stats, f, indent=2)
        elif format == 'csv':
            with open(filename, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(['Category', 'Item', 'Value'])
                
                # Write protocol stats
                for proto, count in stats['protocols'].items():
                    writer.writerow(['Protocol', proto, count])
                
                # Write top talkers
                for ip, count in stats['top_src_ips']:
                    writer.writerow(['Source IP', ip, count])
                
                for ip, count in stats['top_dst_ips']:
                    writer.writerow(['Destination IP', ip, count])
        
        print(f"\nStatistics exported to: {filename}")
        return filename

def main():
    """Main function for traffic stats engine."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Traffic Statistics Engine')
    parser.add_argument('file', nargs='?', help='PCAP file to analyze')
    parser.add_argument('-i', '--interface', help='Interface for live capture')
    parser.add_argument('-f', '--filter', help='BPF filter')
    parser.add_argument('-e', '--export', help='Export results (json/csv)')
    parser.add_argument('-w', '--window', type=int, default=10,
                        help='Rate calculation window in seconds')
    
    args = parser.parse_args()
    
    engine = TrafficStatsEngine(
        interface=args.interface or conf.iface,
        filter_str=args.filter,
        window_size=args.window
    )
    
    if args.file:
        stats = engine.analyze_pcap(args.file)
        if args.export:
            export_format = 'csv' if args.export.endswith('.csv') else 'json'
            engine.export_stats(args.export, export_format)
    else:
        engine.monitor_live()
        if args.export:
            engine.export_stats(args.export)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("TRAFFIC STATISTICS ENGINE")
        print("=" * 60)
        
        choice = input("\nAnalyze PCAP file or sniff live? (pcap/live): ").strip().lower()
        
        engine = TrafficStatsEngine()
        
        if choice == 'pcap':
            file_path = input("Enter PCAP file path: ").strip()
            if file_path:
                engine.analyze_pcap(file_path)
                export = input("Export results? (y/n): ").strip().lower()
                if export == 'y':
                    format_choice = input("Format (json/csv): ").strip().lower()
                    engine.export_stats(format=format_choice)
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
            
            engine = TrafficStatsEngine(interface=interface)
            engine.monitor_live()
    else:
        main()
```

---

## The Verification: Testing Deep Analysis Tools

### Verification 1: Test HTTP Analyzer

```bash
cd ~/scapy-tutorial

# Download a PCAP with HTTP traffic if you don't have one
cd pcap_files
wget https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http.cap
cd ..

# Analyze HTTP traffic
python3 src/http_analyzer.py pcap_files/http.cap -e
```

**Expected output**: HTTP request/response analysis with methods, status codes, user agents, and suspicious pattern detection.

### Verification 2: Test DNS Monitor

```bash
# Download a DNS PCAP
cd pcap_files
wget https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap
cd ..

# Analyze DNS traffic with caching
python3 src/dns_monitor.py pcap_files/dns.cap -e
```

**Expected output**: DNS query/response tracking with cache hit rates, top domains, and suspicious query detection.

### Verification 3: Test DHCP Analyzer

```bash
# Download DHCP PCAP if available
cd pcap_files
wget https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.cap
cd ..

# Analyze DHCP traffic
python3 src/dhcp_analyzer.py pcap_files/dhcp.cap -e
```

**Expected output**: DORA sequence tracking, DHCP server detection, and rogue server identification.

### Verification 4: Test Traffic Stats Engine

```bash
# Analyze traffic with stats engine
python3 src/traffic_stats_engine.py pcap_files/http.cap -e stats.json

# Live monitoring (with sudo)
sudo python3 src/traffic_stats_engine.py -i eth0 -w 5
```

**Expected output**: Comprehensive traffic statistics including rates, protocol distribution, and top talkers.

---

## Reference: Protocol Analysis Quick Reference

### HTTP Status Code Categories

| Category | Code Range | Description |
|----------|------------|-------------|
| 1xx | 100-199 | Informational |
| 2xx | 200-299 | Success |
| 3xx | 300-399 | Redirection |
| 4xx | 400-499 | Client Error |
| 5xx | 500-599 | Server Error |

### DNS Record Types

| Type | Description | Example |
|------|-------------|---------|
| A | IPv4 address | 192.168.1.1 |
| AAAA | IPv6 address | 2001:db8::1 |
| CNAME | Canonical name | www.example.com |
| MX | Mail exchange | mail.example.com |
| NS | Name server | ns1.example.com |
| TXT | Text record | "v=spf1 ..." |

### DHCP Message Types

| Type | Code | Direction | Description |
|------|------|-----------|-------------|
| DISCOVER | 1 | Client -> Server | Client looking for DHCP server |
| OFFER | 2 | Server -> Client | Server offering IP configuration |
| REQUEST | 3 | Client -> Server | Client requesting offered config |
| ACK | 5 | Server -> Client | Server confirming configuration |
| NAK | 6 | Server -> Client | Server denying request |
| RELEASE | 7 | Client -> Server | Client releasing IP address |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Not Handling Large PCAPs Efficiently

```python
# DON'T: Load entire PCAP into memory
packets = rdpcap(large_file)  # Memory intensive

# DO: Process incrementally
from scapy.utils import PcapReader
with PcapReader(large_file) as pcap_reader:
    for packet in pcap_reader:
        process(packet)
```

### Pitfall 2: Exposing Sensitive Information

```python
# DON'T: Log full request/response bodies
print(request)  # May contain passwords, tokens

# DO: Truncate or redact sensitive data
print(request[:200])  # Only show first 200 characters
```

### Pitfall 3: Not Using Locking in Multi-threaded Code

```python
# DON'T: Update shared state without locks
self.counter += 1  # Race condition

# DO: Use locks
with self.lock:
    self.counter += 1
```

### Best Practice: Implement Rate Limiting for Live Capture

```python
class RateLimiter:
    def __init__(self, max_rate):
        self.max_rate = max_rate
        self.last_time = 0
    
    def wait(self):
        current_time = time.time()
        min_interval = 1.0 / self.max_rate
        if current_time - self.last_time < min_interval:
            time.sleep(min_interval - (current_time - self.last_time))
        self.last_time = time.time()
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ Deep HTTP request/response analysis
2. ✅ DNS monitoring with caching
3. ✅ DHCP DORA sequence tracking
4. ✅ Rogue DHCP server detection
5. ✅ Comprehensive traffic statistics
6. ✅ Protocol-specific anomaly detection

---

## Module 4 Complete!

**Congratulations!** You've completed Module 4. You now have professional-grade packet sniffing and traffic analysis tools.

---

## Next Steps: Preview of Module 5

In **Module 5: Active Network Manipulation & Security Testing**, we'll:

1. Implement ARP spoofing detection
2. Build DNS monitoring tools
3. Create packet replay utilities
4. Develop security assessment tools
5. Build defensive monitoring systems

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 4 COMPLETE                                           │
│  ✅ HTTP deep analyzer built                                        │
│  ✅ DNS monitor with caching created                                │
│  ✅ DHCP analyzer and DORA tracker built                            │
│  ✅ Traffic statistics engine developed                             │
│  ✅ Anomaly detection implemented                                   │
│  NEXT: MODULE 5 — Active Network Manipulation & Security Testing  │
│  ● ARP spoofing detection                                           │
│  ● DNS monitoring tools                                             │
│  ● Packet replay utilities                                         │
│  ● Security assessment tools                                       │
│  ● Defensive monitoring systems                                    │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Module 5, where we'll explore active network manipulation techniques and build defensive detection tools for network attacks.*
