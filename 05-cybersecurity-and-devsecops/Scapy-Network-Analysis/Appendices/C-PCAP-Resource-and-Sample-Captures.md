# Mastering Network Packet Crafting with Scapy
## Appendix C: PCAP Resources and Sample Captures

## Overview

This appendix provides a comprehensive guide to public PCAP resources used throughout the series. These captures are essential for practicing packet analysis, building tools, and understanding network protocols in real-world scenarios.

---

## Table of Contents

1. [Why Use Public PCAPs](#why-use-public-pcaps)
2. [Primary PCAP Repositories](#primary-pcap-repositories)
3. [Protocol-Specific Captures](#protocol-specific-captures)
4. [Security and Malware Captures](#security-and-malware-captures)
5. [Industrial and IoT Captures](#industrial-and-iot-captures)
6. [Using PCAPs with Scapy](#using-pcaps-with-scapy)
7. [PCAP Download Scripts](#pcap-download-scripts)
8. [PCAP Analysis Examples](#pcap-analysis-examples)
9. [Creating Your Own PCAPs](#creating-your-own-pcaps)

---

## 1. Why Use Public PCAPs

Public PCAP repositories provide:

- **Real-world traffic**: Authentic network communication patterns
- **Protocol diversity**: Wide range of protocols and applications
- **Security scenarios**: Malware, attacks, and anomalies
- **Reproducible analysis**: Same data, same results every time
- **Safe learning**: No risk to production networks
- **Reference data**: Ground truth for tool validation

### Lab Environment Recommendations

Before working with PCAPs, especially security-related ones:

```bash
# Recommended setup
1. Use a virtual machine (VirtualBox, VMware)
2. Isolate from production networks
3. Use snapshots before analysis
4. Keep analysis tools updated
5. Follow safe handling procedures for malware PCAPs
```

---

## 2. Primary PCAP Repositories

### Wireshark Sample Captures

**URL:** [https://wiki.wireshark.org/SampleCaptures](https://wiki.wireshark.org/SampleCaptures)

**Description:** Official Wireshark sample captures covering a wide range of protocols. Excellent for beginners and protocol-specific study.

**Best For:** Protocol learning, tool validation, packet dissection practice.

**Key Captures:**

| Capture | Protocol | Description |
|---------|----------|-------------|
| `arp.cap` | ARP | ARP request/reply examples |
| `dhcp.cap` | DHCP | DHCP DORA sequence |
| `dns.cap` | DNS | DNS queries and responses |
| `http.cap` | HTTP | HTTP GET/POST requests |
| `tcp.cap` | TCP | TCP handshake and data |
| `udp.cap` | UDP | UDP datagrams |
| `icmp.cap` | ICMP | Ping and ICMP errors |
| `vlan.cap` | VLAN | VLAN-tagged frames |
| `ipv6.cap` | IPv6 | IPv6 traffic examples |
| `tls.cap` | TLS | TLS handshakes |

**Download Script:**

```python
import urllib.request
import os

def download_wireshark_samples():
    """Download Wireshark sample captures."""
    base_url = "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/"
    samples = [
        "arp.cap", "dhcp.cap", "dns.cap", "http.cap", "tcp.cap",
        "udp.cap", "icmp.cap", "vlan.cap", "ipv6.cap", "tls.cap"
    ]
    
    for sample in samples:
        url = base_url + sample
        try:
            urllib.request.urlretrieve(url, sample)
            print(f"Downloaded: {sample}")
        except Exception as e:
            print(f"Failed to download {sample}: {e}")

# Run download
download_wireshark_samples()
```

---

### The Ultimate PCAP

**URL:** [https://www.theultimatespcap.com/](https://www.theultimatespcap.com/)

**Description:** A single comprehensive PCAP file containing 80-90+ protocols and hundreds of variants. Created by Johannes Weber.

**Best For:** Rapid multi-protocol exploration, comprehensive testing, Scapy dissection practice.

**Key Features:**
- 100+ unique protocols
- Real-world traffic patterns
- Enterprise network scenarios
- Protocol variations and edge cases

**Download:**

```python
import urllib.request

def download_ultimate_pcap():
    """Download The Ultimate PCAP."""
    url = "https://www.theultimatespcap.com/ultimate.pcap"
    filename = "ultimate.pcap"
    
    print(f"Downloading The Ultimate PCAP (large file)...")
    try:
        urllib.request.urlretrieve(url, filename)
        size = os.path.getsize(filename) / (1024 * 1024)
        print(f"Downloaded: {filename} ({size:.1f} MB)")
    except Exception as e:
        print(f"Failed to download: {e}")

download_ultimate_pcap()
```

---

### NETRESEC Public PCAP Files

**URL:** [https://www.netresec.com/?page=PcapFiles](https://www.netresec.com/?page=PcapFiles)

**Description:** Curated index of public captures covering enterprise networks, malware, ICS/SCADA, CTF traffic, wireless, and forensics challenges.

**Best For:** Intermediate to advanced analysis, specialized scenarios, security research.

**Categories:**
- Malware traffic analysis
- Industrial control systems
- Network forensics
- Wireless captures
- CTF challenges
- Enterprise networks

**Notable Captures:**
- `mirai-botnet.pcap` - Mirai botnet traffic
- `wannacry.pcap` - WannaCry ransomware traffic
- `industrial.pcap` - SCADA/ICS protocols
- `ctf-challenge.pcap` - CTF network forensics

---

### Malware Traffic Analysis

**URL:** [https://www.malware-traffic-analysis.net/](https://www.malware-traffic-analysis.net/)

**Description:** Real-world malicious traffic captures with detailed walkthroughs and exercises. Updated regularly with new threats.

**Best For:** Security professionals, threat hunting, anomaly detection practice.

**Features:**
- Detailed analysis walkthroughs
- Multiple malware families
- Attack lifecycles
- IOC extraction
- Exercise questions

**Categories:**
- Ransomware traffic
- Banking trojans
- Botnet communication
- Exploit kits
- Phishing attacks

**Typical Analysis Workflow:**

```python
def analyze_malware_pcap(pcap_file):
    """Basic malware analysis workflow."""
    from scapy.all import rdpcap, IP, TCP, UDP, DNS
    
    packets = rdpcap(pcap_file)
    
    # Extract domains from DNS
    domains = set()
    for pkt in packets:
        if pkt.haslayer(DNS) and pkt[DNS].qr == 0:  # Query
            if pkt[DNS].qd:
                domains.add(pkt[DNS].qd.qname.decode())
    
    # Extract suspicious IPs
    malicious_ips = set()
    for pkt in packets:
        if pkt.haslayer(IP):
            # Add known malicious IP patterns
            pass
    
    # Extract HTTP requests
    http_requests = []
    for pkt in packets:
        if pkt.haslayer(TCP) and pkt[TCP].dport == 80:
            # Look for HTTP
            pass
    
    return {
        'domains': domains,
        'ips': malicious_ips,
        'http': http_requests
    }
```

---

### ICS-pcap (GitHub)

**URL:** [https://github.com/automayt/ICS-pcap](https://github.com/automayt/ICS-pcap)

**Description:** Collection of industrial control system / SCADA protocol captures (Modbus, DNP3, S7, PROFINET, etc.).

**Best For:** OT/ICS security research, custom dissector practice, industrial protocol analysis.

**Protocols Included:**
- Modbus (TCP/RTU)
- DNP3
- S7 (Siemens)
- PROFINET
- EtherNet/IP
- IEC 61850
- OPC UA

**Download:**

```bash
# Clone the repository
git clone https://github.com/automayt/ICS-pcap.git

# Or download individual captures
cd ICS-pcap
```

---

### Chris Sanders / Practical Packet Analysis

**URL:** [https://www.chrissanders.org/packet-captures/](https://www.chrissanders.org/packet-captures/)

**Description:** Structured troubleshooting and real-world problem examples from the author of "Practical Packet Analysis."

**Best For:** Network diagnostics, analysis workflows, troubleshooting practice.

**Key Captures:**
- Network troubleshooting scenarios
- Application performance issues
- Security incidents
- Protocol anomalies

---

### CellStream Comprehensive PCAP

**URL:** [https://www.cellstream.com/reference/pcapfiles/](https://www.cellstream.com/reference/pcapfiles/)

**Description:** Large multi-protocol learning capture with hundreds of protocols.

**Best For:** Foundational study, Scapy PCAP loading exercises, protocol discovery.

**Features:**
- Multiple protocol layers
- IPv4 and IPv6
- Various application protocols
- Enterprise network mix

---

### PacketTotal

**URL:** [https://www.packettotal.com/](https://www.packettotal.com/)

**Description:** Online platform for uploading, sharing, and analyzing PCAPs. Includes public samples and community contributions.

**Best For:** Collaborative analysis, malware/incident investigation, quick PCAP sharing.

**Features:**
- Web-based analysis
- Threat intelligence integration
- Community samples
- Quick sharing

---

## 3. Protocol-Specific Captures

### ARP and Ethernet Captures

| Resource | Description | Link |
|----------|-------------|------|
| ARP Examples | Various ARP scenarios | Wireshark Samples |
| VLAN Samples | 802.1Q tagging | Wireshark Samples |
| MAC Address Scenarios | Broadcast/Multicast | NETRESEC |
| ARP Spoofing | Attack examples | Malware Traffic |

**Scapy Analysis Example:**

```python
from scapy.all import rdpcap, ARP, Ether

def analyze_arp(pcap_file):
    """Analyze ARP traffic in a PCAP."""
    packets = rdpcap(pcap_file)
    
    arp_requests = 0
    arp_replies = 0
    arp_cache = {}
    arp_anomalies = []
    
    for pkt in packets:
        if pkt.haslayer(ARP):
            arp = pkt[ARP]
            if arp.op == 1:  # Request
                arp_requests += 1
            elif arp.op == 2:  # Reply
                arp_replies += 1
                
                # Check for IP-MAC changes
                if arp.psrc in arp_cache:
                    if arp_cache[arp.psrc] != arp.hwsrc:
                        arp_anomalies.append({
                            'ip': arp.psrc,
                            'old_mac': arp_cache[arp.psrc],
                            'new_mac': arp.hwsrc
                        })
                arp_cache[arp.psrc] = arp.hwsrc
    
    return {
        'requests': arp_requests,
        'replies': arp_replies,
        'cache': arp_cache,
        'anomalies': arp_anomalies
    }
```

---

### DNS Captures

| Resource | Description | Link |
|----------|-------------|------|
| DNS Samples | Query/Response examples | Wireshark Samples |
| DNS Over HTTPS | Encrypted DNS | NETRESEC |
| DNS Tunneling | Covert channel examples | Malware Traffic |
| DNSSEC | Signed DNS responses | Public DNS providers |

**Scapy Analysis Example:**

```python
from scapy.all import rdpcap, DNS, DNSQR, DNSRR

def analyze_dns(pcap_file):
    """Analyze DNS traffic in a PCAP."""
    packets = rdpcap(pcap_file)
    
    queries = {}
    responses = {}
    suspicious = []
    
    for pkt in packets:
        if pkt.haslayer(DNS):
            dns = pkt[DNS]
            
            if dns.qr == 0:  # Query
                if dns.qd:
                    qname = dns.qd.qname.decode()
                    qtype = dns.qd.qtype
                    queries[(qname, qtype)] = queries.get((qname, qtype), 0) + 1
                    
                    # Check for suspicious domain length
                    if len(qname) > 50:
                        suspicious.append({
                            'type': 'long_domain',
                            'domain': qname
                        })
            
            elif dns.qr == 1:  # Response
                if dns.an:
                    for answer in dns.an:
                        if isinstance(answer, DNSRR):
                            domain = answer.rrname.decode()
                            rdata = str(answer.rdata)
                            responses[domain] = rdata
    
    return {
        'queries': queries,
        'responses': responses,
        'suspicious': suspicious
    }
```

---

### HTTP/HTTPS Captures

| Resource | Description | Link |
|----------|-------------|------|
| HTTP Examples | GET/POST, headers | Wireshark Samples |
| HTTPS Traffic | TLS handshakes | NETRESEC |
| HTTP/2 | Modern HTTP | Public CDNs |
| REST APIs | API traffic | Various |

**Scapy Analysis Example:**

```python
from scapy.all import rdpcap, IP, TCP, Raw

def extract_http(pcap_file):
    """Extract HTTP requests from PCAP."""
    packets = rdpcap(pcap_file)
    
    http_requests = []
    
    for pkt in packets:
        if pkt.haslayer(TCP) and pkt.haslayer(Raw):
            tcp = pkt[TCP]
            if tcp.dport == 80 or tcp.sport == 80:
                payload = bytes(pkt[Raw])
                try:
                    data = payload.decode('utf-8', errors='ignore')
                    if data.startswith(('GET', 'POST', 'PUT', 'DELETE')):
                        lines = data.split('\r\n')
                        if lines:
                            request_line = lines[0]
                            http_requests.append({
                                'src': pkt[IP].src,
                                'dst': pkt[IP].dst,
                                'request': request_line,
                                'headers': lines[1:10]  # First 10 headers
                            })
                except:
                    pass
    
    return http_requests
```

---

### TCP Captures

| Resource | Description | Link |
|----------|-------------|------|
| TCP Handshake | Three-way handshake | Wireshark Samples |
| TCP Retransmissions | Recovery scenarios | Practical Analysis |
| TCP Window Scaling | High performance | NETRESEC |
| TCP Options | Various options | Various |

---

### UDP Captures

| Resource | Description | Link |
|----------|-------------|------|
| DNS over UDP | Standard DNS | Wireshark Samples |
| DHCP over UDP | DORA sequence | Wireshark Samples |
| NTP | Time synchronization | Public NTP Servers |
| SNMP | Network management | Various |

---

### DHCP Captures

| Resource | Description | Link |
|----------|-------------|------|
| DORA Sequence | Complete exchange | Wireshark Samples |
| DHCPv6 | IPv6 DHCP | NETRESEC |
| Rogue DHCP | Attack examples | Security repositories |

**Scapy Analysis Example:**

```python
from scapy.all import rdpcap, DHCP, BOOTP

def analyze_dhcp(pcap_file):
    """Analyze DHCP traffic in a PCAP."""
    packets = rdpcap(pcap_file)
    
    dhcp_sequences = []
    dhcp_servers = set()
    
    for pkt in packets:
        if pkt.haslayer(DHCP):
            dhcp = pkt[DHCP]
            bootp = pkt[BOOTP]
            
            # Extract DHCP message type
            msg_type = None
            for option in dhcp.options:
                if isinstance(option, tuple) and option[0] == 'message-type':
                    msg_type = option[1]
                    break
            
            if msg_type:
                dhcp_servers.add(pkt[IP].src)
                
                dhcp_sequences.append({
                    'type': msg_type,
                    'client_mac': bootp.chaddr,
                    'server_ip': pkt[IP].src,
                    'options': dhcp.options
                })
    
    return {
        'sequences': dhcp_sequences,
        'servers': dhcp_servers
    }
```

---

## 4. Security and Malware Captures

### Malware Families

| Malware | Description | Source |
|---------|-------------|--------|
| Mirai | IoT botnet | Malware Traffic Analysis |
| WannaCry | Ransomware | Malware Traffic Analysis |
| Emotet | Banking trojan | Malware Traffic Analysis |
| TrickBot | Modular malware | Malware Traffic Analysis |
| Ryuk | Ransomware | Malware Traffic Analysis |
| Sodinokibi | Ransomware | Malware Traffic Analysis |

### Attack Types

| Attack | Description | Source |
|--------|-------------|--------|
| DDoS | Distributed denial of service | NETRESEC |
| ARP Spoofing | MITM attack | Security repositories |
| Port Scan | Reconnaissance | Various |
| DNS Tunneling | Covert channel | Malware Traffic |
| C2 Communication | Command and control | Malware Traffic |

### Detection Examples

```python
def detect_malware_patterns(pcap_file):
    """Detect common malware patterns."""
    from scapy.all import rdpcap, IP, TCP, UDP, DNS
    
    packets = rdpcap(pcap_file)
    
    patterns = {
        'beaconing': [],
        'dns_tunneling': [],
        'data_exfiltration': [],
        'command_control': []
    }
    
    for pkt in packets:
        if pkt.haslayer(IP):
            ip = pkt[IP]
            
            # Check for beaconing (periodic small packets)
            # Implementation depends on timing analysis
            
            # DNS tunneling detection (long domains)
            if pkt.haslayer(DNS) and pkt[DNS].qr == 0:
                if pkt[DNS].qd:
                    domain = pkt[DNS].qd.qname.decode()
                    if len(domain) > 50:
                        patterns['dns_tunneling'].append({
                            'domain': domain,
                            'src': ip.src
                        })
            
            # Data exfiltration (large outbound packets)
            if pkt.haslayer(TCP) and pkt[TCP].sport > 1024:
                if len(pkt) > 1000:  # Large packets from ephemeral ports
                    patterns['data_exfiltration'].append({
                        'src': ip.src,
                        'dst': ip.dst,
                        'size': len(pkt)
                    })
    
    return patterns
```

---

## 5. Industrial and IoT Captures

### Industrial Protocols

| Protocol | Description | Source |
|----------|-------------|--------|
| Modbus | Industrial control | ICS-pcap |
| DNP3 | SCADA | ICS-pcap |
| S7 | Siemens | ICS-pcap |
| PROFINET | Industrial Ethernet | ICS-pcap |
| EtherNet/IP | Industrial | ICS-pcap |
| IEC 61850 | Power grid | ICS-pcap |

### IoT Protocols

| Protocol | Description | Source |
|----------|-------------|--------|
| MQTT | IoT messaging | Various |
| CoAP | Constrained devices | Various |
| ZigBee | Wireless IoT | Various |
| Bluetooth | Personal area | Various |

**Scapy Analysis Example:**

```python
# Custom Modbus dissector (partial example)
class ModbusTCP(Packet):
    name = "ModbusTCP"
    fields_desc = [
        ShortField("transaction_id", 0),
        ShortField("protocol_id", 0),
        ShortField("length", 0),
        ByteField("unit_id", 0),
        ByteField("function_code", 0)
    ]

def analyze_modbus(pcap_file):
    """Analyze Modbus traffic."""
    from scapy.all import rdpcap, TCP
    
    # Bind Modbus to TCP port 502
    from scapy.all import bind_layers
    bind_layers(TCP, ModbusTCP, dport=502)
    bind_layers(TCP, ModbusTCP, sport=502)
    
    packets = rdpcap(pcap_file)
    
    modbus_commands = []
    
    for pkt in packets:
        if pkt.haslayer(ModbusTCP):
            modbus = pkt[ModbusTCP]
            modbus_commands.append({
                'transaction_id': modbus.transaction_id,
                'function_code': modbus.function_code,
                'unit_id': modbus.unit_id,
                'src': pkt[IP].src,
                'dst': pkt[IP].dst
            })
    
    return modbus_commands
```

---

## 6. Using PCAPs with Scapy

### Loading PCAP Files

```python
from scapy.all import rdpcap, PcapReader

# Standard loading (memory intensive)
packets = rdpcap("capture.pcap")
print(f"Loaded {len(packets)} packets")

# For large files (memory efficient)
with PcapReader("large_capture.pcap") as reader:
    for packet in reader:
        process(packet)

# Partial loading (first N packets)
packets = rdpcap("capture.pcap")
first_100 = packets[:100]
```

### Filtering Packets

```python
# Filter by protocol
tcp_packets = [p for p in packets if p.haslayer(TCP)]
udp_packets = [p for p in packets if p.haslayer(UDP)]

# Filter by IP
ip_packets = [p for p in packets if p.haslayer(IP) and p[IP].src == "192.168.1.100"]

# Filter by port
http_packets = [p for p in packets if p.haslayer(TCP) and p[TCP].dport == 80]

# Combined filters
filtered = [p for p in packets 
            if p.haslayer(IP) and p[IP].src == "192.168.1.100"
            and p.haslayer(TCP) and p[TCP].dport == 80]
```

### Extracting Data

```python
def extract_packet_info(packets):
    """Extract key information from packets."""
    info = []
    
    for pkt in packets:
        data = {
            'timestamp': pkt.time,
            'length': len(pkt),
            'protocols': []
        }
        
        if pkt.haslayer(Ether):
            data['mac_src'] = pkt[Ether].src
            data['mac_dst'] = pkt[Ether].dst
        
        if pkt.haslayer(IP):
            data['ip_src'] = pkt[IP].src
            data['ip_dst'] = pkt[IP].dst
            data['protocols'].append('IP')
        
        if pkt.haslayer(TCP):
            data['tcp_sport'] = pkt[TCP].sport
            data['tcp_dport'] = pkt[TCP].dport
            data['tcp_flags'] = pkt[TCP].flags
            data['protocols'].append('TCP')
        
        if pkt.haslayer(UDP):
            data['udp_sport'] = pkt[UDP].sport
            data['udp_dport'] = pkt[UDP].dport
            data['protocols'].append('UDP')
        
        info.append(data)
    
    return info
```

### Saving PCAPs

```python
from scapy.all import wrpcap

# Save all packets
wrpcap("output.pcap", packets)

# Save filtered packets
filtered_packets = [p for p in packets if p.haslayer(TCP)]
wrpcap("tcp_only.pcap", filtered_packets)

# Save with append
from scapy.utils import PcapWriter
with PcapWriter("output.pcap", append=True) as writer:
    for packet in packets:
        writer.write(packet)
```

---

## 7. PCAP Download Scripts

### Comprehensive Downloader

```python
#!/usr/bin/env python3
"""
PCAP Downloader for Common Sources
"""

import os
import urllib.request
import json
import sys

class PCAPDownloader:
    """Download PCAPs from various sources."""
    
    def __init__(self, output_dir="pcap_files"):
        """Initialize downloader."""
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
    
    def download_wireshark_samples(self):
        """Download Wireshark sample captures."""
        base_url = "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/"
        samples = [
            "arp.cap", "dhcp.cap", "dns.cap", "http.cap", 
            "tcp.cap", "udp.cap", "icmp.cap", "vlan.cap",
            "ipv6.cap", "tls.cap", "modbus.cap", "snmp.cap"
        ]
        
        print("\nDownloading Wireshark samples...")
        for sample in samples:
            try:
                url = base_url + sample
                output = os.path.join(self.output_dir, sample)
                urllib.request.urlretrieve(url, output)
                print(f"  ✓ {sample}")
            except Exception as e:
                print(f"  ✗ Failed: {sample} - {e}")
    
    def download_ultimate_pcap(self):
        """Download The Ultimate PCAP."""
        print("\nDownloading The Ultimate PCAP...")
        url = "https://www.theultimatespcap.com/ultimate.pcap"
        output = os.path.join(self.output_dir, "ultimate.pcap")
        
        try:
            urllib.request.urlretrieve(url, output)
            size = os.path.getsize(output) / (1024 * 1024)
            print(f"  ✓ Downloaded ({size:.1f} MB)")
        except Exception as e:
            print(f"  ✗ Failed: {e}")
    
    def download_malware_samples(self):
        """Download malware analysis PCAPs."""
        print("\nNote: Malware PCAPs should be handled with care.")
        print("Visit: https://www.malware-traffic-analysis.net/")
        print("Download manually for safety in isolated environments.")
    
    def download_all(self):
        """Download all available PCAPs."""
        self.download_wireshark_samples()
        self.download_ultimate_pcap()
        self.download_malware_samples()
        
        print(f"\n✅ PCAPs downloaded to: {self.output_dir}")

if __name__ == "__main__":
    downloader = PCAPDownloader()
    downloader.download_all()
```

### Custom Download with Progress

```python
#!/usr/bin/env python3
"""
PCAP Downloader with Progress Bar
"""

import urllib.request
import os
import sys

class DownloadProgress:
    """Simple progress bar for downloads."""
    
    def __init__(self, total_size):
        self.total_size = total_size
        self.downloaded = 0
    
    def update(self, bytes_downloaded):
        """Update progress."""
        self.downloaded += bytes_downloaded
        percent = (self.downloaded / self.total_size) * 100
        bar_length = 50
        filled_length = int(bar_length * self.downloaded // self.total_size)
        bar = '█' * filled_length + '░' * (bar_length - filled_length)
        sys.stdout.write(f'\r  [{bar}] {percent:.1f}%')
        sys.stdout.flush()

def download_with_progress(url, filename):
    """Download with progress bar."""
    def progress_hook(block_num, block_size, total_size):
        if not hasattr(progress_hook, 'progress'):
            progress_hook.progress = DownloadProgress(total_size)
        if block_num == 0:
            print(f"\nDownloading: {os.path.basename(filename)}")
        progress_hook.progress.update(block_size)
    
    urllib.request.urlretrieve(url, filename, progress_hook)
    print()  # New line after progress
    print(f"✓ Downloaded: {filename}")

# Example usage
url = "https://www.theultimatespcap.com/ultimate.pcap"
output = "pcap_files/ultimate.pcap"
download_with_progress(url, output)
```

---

## 8. PCAP Analysis Examples

### Complete Analysis Script

```python
#!/usr/bin/env python3
"""
Comprehensive PCAP Analysis Script
"""

from scapy.all import rdpcap, IP, TCP, UDP, ICMP, Ether, ARP, DNS
import json
from datetime import datetime
from collections import defaultdict

class PCAPAnalyzer:
    """Comprehensive PCAP analysis."""
    
    def __init__(self, pcap_file):
        self.pcap_file = pcap_file
        self.packets = rdpcap(pcap_file)
        self.stats = defaultdict(int)
        self.protocols = defaultdict(int)
        self.ips = {
            'src': defaultdict(int),
            'dst': defaultdict(int)
        }
        self.ports = {
            'tcp': defaultdict(int),
            'udp': defaultdict(int)
        }
    
    def analyze(self):
        """Run full analysis."""
        print(f"Analyzing: {self.pcap_file}")
        print(f"Total packets: {len(self.packets)}")
        
        for pkt in self.packets:
            self.analyze_packet(pkt)
        
        self.display_stats()
        return self.get_stats()
    
    def analyze_packet(self, pkt):
        """Analyze a single packet."""
        self.stats['total'] += 1
        
        # Protocol analysis
        if pkt.haslayer(IP):
            ip = pkt[IP]
            self.ips['src'][ip.src] += 1
            self.ips['dst'][ip.dst] += 1
            
            if pkt.haslayer(TCP):
                self.protocols['TCP'] += 1
                tcp = pkt[TCP]
                self.ports['tcp'][tcp.sport] += 1
                self.ports['tcp'][tcp.dport] += 1
            elif pkt.haslayer(UDP):
                self.protocols['UDP'] += 1
                udp = pkt[UDP]
                self.ports['udp'][udp.sport] += 1
                self.ports['udp'][udp.dport] += 1
            elif pkt.haslayer(ICMP):
                self.protocols['ICMP'] += 1
            else:
                self.protocols['Other_IP'] += 1
        elif pkt.haslayer(ARP):
            self.protocols['ARP'] += 1
        elif pkt.haslayer(Ether):
            self.protocols['Ethernet'] += 1
        else:
            self.protocols['Other'] += 1
    
    def display_stats(self):
        """Display analysis statistics."""
        print("\n" + "=" * 60)
        print("PCAP ANALYSIS RESULTS")
        print("=" * 60)
        
        print("\nProtocol Distribution:")
        print("-" * 40)
        for proto, count in sorted(self.protocols.items(), 
                                   key=lambda x: x[1], reverse=True):
            percentage = (count / self.stats['total']) * 100
            print(f"  {proto:<10}: {count:>6} ({percentage:>5.1f}%)")
        
        print("\nTop 10 Source IPs:")
        print("-" * 40)
        for ip, count in sorted(self.ips['src'].items(), 
                                key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {ip:<15}: {count:>6}")
        
        print("\nTop 10 Destination IPs:")
        print("-" * 40)
        for ip, count in sorted(self.ips['dst'].items(), 
                                key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {ip:<15}: {count:>6}")
        
        print("\nTop 10 TCP Ports:")
        print("-" * 40)
        for port, count in sorted(self.ports['tcp'].items(), 
                                  key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {port:<6}: {count:>6}")
        
        print("\nTop 10 UDP Ports:")
        print("-" * 40)
        for port, count in sorted(self.ports['udp'].items(), 
                                  key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {port:<6}: {count:>6}")
        
        print("\n" + "=" * 60)
    
    def get_stats(self):
        """Return statistics as dictionary."""
        return {
            'total_packets': self.stats['total'],
            'protocols': dict(self.protocols),
            'src_ips': dict(self.ips['src']),
            'dst_ips': dict(self.ips['dst']),
            'tcp_ports': dict(self.ports['tcp']),
            'udp_ports': dict(self.ports['udp'])
        }
    
    def export_json(self, filename=None):
        """Export results to JSON."""
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"analysis_{timestamp}.json"
        
        with open(filename, 'w') as f:
            json.dump(self.get_stats(), f, indent=2)
        
        print(f"\nResults exported to: {filename}")

# Usage
if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        analyzer = PCAPAnalyzer(sys.argv[1])
        analyzer.analyze()
        analyzer.export_json()
    else:
        print("Usage: python pcap_analyzer.py <pcap_file>")
```

---

## 9. Creating Your Own PCAPs

### Generate Test Traffic

```python
#!/usr/bin/env python3
"""
Generate Test PCAPs for Practice
"""

from scapy.all import Ether, IP, TCP, UDP, ICMP, ARP, Raw
from scapy.all import wrpcap, RandIP, RandMAC, RandShort
import time
import random

class TestPCAPGenerator:
    """Generate test PCAP files with various protocols."""
    
    def __init__(self):
        self.packets = []
    
    def add_ping_sequence(self, count=5):
        """Add ICMP ping sequence."""
        for i in range(count):
            pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
                  IP(src=RandIP(), dst=RandIP()) / \
                  ICMP(type=8, code=0, id=12345, seq=i)
            self.packets.append(pkt)
            
            # Add reply
            pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
                  IP(src=RandIP(), dst=RandIP()) / \
                  ICMP(type=0, code=0, id=12345, seq=i)
            self.packets.append(pkt)
    
    def add_tcp_handshake(self, count=3):
        """Add TCP handshake sequences."""
        for i in range(count):
            # SYN
            pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
                  IP(src=RandIP(), dst=RandIP()) / \
                  TCP(sport=RandShort(), dport=80, flags="S", seq=1000+i*1000)
            self.packets.append(pkt)
            
            # SYN-ACK
            pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
                  IP(src=RandIP(), dst=RandIP()) / \
                  TCP(sport=80, dport=12345, flags="SA", seq=2000+i*1000, 
                      ack=1001+i*1000)
            self.packets.append(pkt)
            
            # ACK
            pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
                  IP(src=RandIP(), dst=RandIP()) / \
                  TCP(sport=12345, dport=80, flags="A", seq=1001+i*1000, 
                      ack=2001+i*1000)
            self.packets.append(pkt)
    
    def add_http_request(self, count=3):
        """Add HTTP requests."""
        for i in range(count):
            http_data = f"GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n"
            pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
                  IP(src=RandIP(), dst=RandIP()) / \
                  TCP(sport=RandShort(), dport=80, flags="PA") / \
                  Raw(load=http_data.encode())
            self.packets.append(pkt)
    
    def add_dns_query(self, count=3):
        """Add DNS queries."""
        for i in range(count):
            # DNS query for example.com
            dns_payload = (b"\x00\x01" b"\x01\x00" b"\x00\x01" b"\x00\x00" 
                          b"\x00\x00" b"\x00\x00" b"\x07example\x03com\x00"
                          b"\x00\x01" b"\x00\x01")
            pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
                  IP(src=RandIP(), dst=RandIP()) / \
                  UDP(sport=RandShort(), dport=53) / \
                  Raw(load=dns_payload)
            self.packets.append(pkt)
    
    def add_arp_traffic(self):
        """Add ARP request/reply sequences."""
        # ARP Request
        pkt = Ether(src=RandMAC(), dst="ff:ff:ff:ff:ff:ff") / \
              ARP(op=1, hwsrc=RandMAC(), psrc=RandIP(), 
                  hwdst="00:00:00:00:00:00", pdst=RandIP())
        self.packets.append(pkt)
        
        # ARP Reply
        pkt = Ether(src=RandMAC(), dst=RandMAC()) / \
              ARP(op=2, hwsrc=RandMAC(), psrc=RandIP(),
                  hwdst=RandMAC(), pdst=RandIP())
        self.packets.append(pkt)
    
    def generate(self, filename="test_traffic.pcap"):
        """Generate and save PCAP."""
        print(f"Generating {len(self.packets)} packets...")
        wrpcap(filename, self.packets)
        print(f"Saved to: {filename}")
        return filename

# Usage
if __name__ == "__main__":
    generator = TestPCAPGenerator()
    generator.add_ping_sequence(5)
    generator.add_tcp_handshake(3)
    generator.add_http_request(5)
    generator.add_dns_query(3)
    generator.add_arp_traffic()
    generator.generate("test_traffic.pcap")
```

---

## Appendix C Complete

This appendix provides a comprehensive guide to PCAP resources and sample captures. For more details, refer to:

- **Wireshark Sample Captures:** [https://wiki.wireshark.org/SampleCaptures](https://wiki.wireshark.org/SampleCaptures)
- **The Ultimate PCAP:** [https://www.theultimatespcap.com/](https://www.theultimatespcap.com/)
- **NETRESEC PCAPs:** [https://www.netresec.com/?page=PcapFiles](https://www.netresec.com/?page=PcapFiles)
- **Malware Traffic Analysis:** [https://www.malware-traffic-analysis.net/](https://www.malware-traffic-analysis.net/)

---

```
─────────────────────────────────────────────────────────────────────────
│  APPENDIX C: PCAP RESOURCES COMPLETE                                │
│                                                                     │
│  This appendix covers:                                             │
│  ✅ Primary PCAP repositories                                      │
│  ✅ Protocol-specific captures                                     │
│  ✅ Security and malware captures                                  │
│  ✅ Industrial and IoT captures                                    │
│  ✅ PCAP download scripts                                          │
│  ✅ PCAP analysis examples                                         │
│  ✅ Creating test PCAPs                                            │
│                                                                     │
│  Next: Appendix D — Glossary                                      │
└─────────────────────────────────────────────────────────────────────────
```
