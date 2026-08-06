# Mastering Network Packet Crafting with Scapy
## Student Workbook

## Overview

This workbook accompanies the **Mastering Network Packet Crafting with Scapy** series. It contains exercises, lab activities, verification checkpoints, and self-assessment questions for each module. Use this workbook to track your progress and reinforce your learning.

---

## Table of Contents

1. [Using This Workbook](#using-this-workbook)
2. [Module 1: Foundations of Packet Crafting](#module-1-foundations-of-packet-crafting)
3. [Module 2: Layer 2 & Layer 3 Operations](#module-2-layer-2--layer-3-operations)
4. [Module 3: Transport Layer Protocols & Reconnaissance](#module-3-transport-layer-protocols--reconnaissance)
5. [Module 4: Packet Sniffing, Filtering & Traffic Analysis](#module-4-packet-sniffing-filtering--traffic-analysis)
6. [Module 5: Active Network Manipulation & Security Testing](#module-5-active-network-manipulation--security-testing)
7. [Module 6: Automation, Performance & Custom Protocols](#module-6-automation-performance--custom-protocols)
8. [Capstone Project: Network Security Toolkit](#capstone-project-network-security-toolkit)
9. [Answer Key](#answer-key)

---

## Using This Workbook

### Workbook Structure

Each module section contains:

| Section | Description |
|---------|-------------|
| **Learning Objectives** | What you should know after completing the module |
| **Key Concepts Review** | Summary of important concepts |
| **Lab Exercises** | Hands-on activities to reinforce learning |
| **Code Challenges** | Programming challenges to test your skills |
| **Verification Checklist** | Steps to confirm your work is correct |
| **Self-Assessment Questions** | Questions to test your understanding |
| **Troubleshooting Notes** | Common issues and solutions |

### How to Use This Workbook

1. **Read the module content** in the main series first
2. **Complete the lab exercises** as you go
3. **Write your code** directly in this workbook (or in your editor)
4. **Check off verification steps** as you complete them
5. **Answer self-assessment questions** to test your understanding
6. **Review troubleshooting notes** if you get stuck

### Symbol Legend

| Symbol | Meaning |
|--------|---------|
| 📘 | Reading/Review |
| 💻 | Code Exercise |
| ✅ | Verification Step |
| ❓ | Self-Assessment Question |
| ⚠️ | Warning/Troubleshooting |
| 🎯 | Key Concept |
| 🏆 | Challenge Exercise |

---

## Module 1: Foundations of Packet Crafting

---

### Learning Objectives

After completing this module, you should be able to:

- [ ] Install and configure Scapy on your system
- [ ] Build multi-layer packets using the `/` operator
- [ ] Inspect packets using `show()`, `summary()`, and `hexdump()`
- [ ] Read and write PCAP files
- [ ] Modify existing packets
- [ ] Build a basic PCAP analysis tool

---

### Key Concepts Review

**📘 Complete this section after reading the module content.**

1. **What is packet crafting?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

2. **What does the `/` operator do in Scapy?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

3. **What is the difference between `show()` and `show2()`?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

4. **What is a PCAP file used for?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

5. **List three packet inspection methods in Scapy:**
   - _________________________________________________________
   - _________________________________________________________
   - _________________________________________________________

---

### Lab Exercise 1.1: Environment Setup

**💻 Complete the following steps to set up your environment.**

```bash
# Step 1: Create project directory
mkdir ~/scapy-tutorial
cd ~/scapy-tutorial

# Step 2: Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate   # Windows

# Step 3: Install Scapy
pip install scapy[complete]

# Step 4: Create directory structure
mkdir -p src labs pcap_files output config tests docs
touch src/__init__.py

# Step 5: Verify installation
python3 -c "from scapy.all import *; print('Scapy version:', scapy.__version__)"
```

**✅ Verification:**

- [ ] Project directory created
- [ ] Virtual environment activated
- [ ] Scapy installed successfully
- [ ] Directory structure created
- [ ] Verification script ran without errors

**📝 Record your output:**

```
Scapy version: _________________________________________________
```

---

### Lab Exercise 1.2: Your First Packets

**💻 Create a file called `src/first_packets.py` and write the following code:**

```python
#!/usr/bin/env python3
"""
Module 1 Lab: First Packets
"""

from scapy.all import Ether, IP, TCP, UDP, ICMP, Raw, wrpcap

def build_packets():
    """Build a variety of packets."""
    packets = []
    
    # 1. ICMP Echo Request (Ping)
    ping = IP(dst="8.8.8.8") / ICMP()
    packets.append(ping)
    
    # 2. TCP SYN Packet
    syn = IP(dst="192.168.1.1") / TCP(dport=80, flags="S")
    packets.append(syn)
    
    # 3. UDP DNS Query
    dns = IP(dst="8.8.8.8") / UDP(dport=53) / Raw(b"\x00\x01\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00")
    packets.append(dns)
    
    # 4. HTTP GET Request
    http = IP(dst="10.0.0.1") / TCP(dport=80, flags="PA") / Raw(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    packets.append(http)
    
    return packets

def inspect_packets(packets):
    """Inspect each packet."""
    for i, packet in enumerate(packets, 1):
        print(f"\n{'='*60}")
        print(f"Packet {i}: {packet.summary()}")
        print(f"{'='*60}")
        packet.show()
        print(f"Length: {len(packet)} bytes")

if __name__ == "__main__":
    packets = build_packets()
    inspect_packets(packets)
    
    # Save to PCAP
    wrpcap("output/first_packets.pcap", packets)
    print("\n✅ Packets saved to output/first_packets.pcap")
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] All four packets display correctly
- [ ] PCAP file is created in the output directory
- [ ] You can open the PCAP in Wireshark

**❓ Questions:**

1. What is the default source IP for the ping packet?
   ```
   Answer: ______________________________________________________
   ```

2. What TCP flag is set in the SYN packet?
   ```
   Answer: ______________________________________________________
   ```

3. What port is used for the DNS query?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 1.3: PCAP Analysis

**💻 Download a sample PCAP and analyze it.**

```bash
# Download a sample PCAP
cd pcap_files
wget https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http.cap
cd ..
```

**💻 Write a script to analyze the PCAP: `src/analyze_pcap.py`**

```python
#!/usr/bin/env python3
"""
Module 1 Lab: PCAP Analysis
"""

from scapy.all import rdpcap, IP, TCP, UDP, ICMP
from collections import defaultdict

def analyze_pcap(pcap_file):
    """Analyze a PCAP file and print statistics."""
    
    # Load packets
    print(f"Loading: {pcap_file}")
    packets = rdpcap(pcap_file)
    print(f"Total packets: {len(packets)}")
    
    # Protocol distribution
    protocols = defaultdict(int)
    src_ips = defaultdict(int)
    dst_ips = defaultdict(int)
    
    for packet in packets:
        # Count protocols
        if packet.haslayer(TCP):
            protocols['TCP'] += 1
        elif packet.haslayer(UDP):
            protocols['UDP'] += 1
        elif packet.haslayer(ICMP):
            protocols['ICMP'] += 1
        elif packet.haslayer(IP):
            protocols['Other IP'] += 1
        else:
            protocols['Other'] += 1
        
        # Track IPs
        if packet.haslayer(IP):
            ip = packet[IP]
            src_ips[ip.src] += 1
            dst_ips[ip.dst] += 1
    
    # Display results
    print("\nProtocol Distribution:")
    print("-" * 40)
    for proto, count in sorted(protocols.items(), key=lambda x: x[1], reverse=True):
        print(f"  {proto}: {count}")
    
    print("\nTop 5 Source IPs:")
    print("-" * 40)
    for ip, count in sorted(src_ips.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {ip}: {count}")
    
    print("\nTop 5 Destination IPs:")
    print("-" * 40)
    for ip, count in sorted(dst_ips.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {ip}: {count}")

if __name__ == "__main__":
    analyze_pcap("pcap_files/http.cap")
```

**✅ Verification:**

- [ ] PCAP file downloaded successfully
- [ ] Analysis script runs without errors
- [ ] Protocol distribution is displayed
- [ ] Top IPs are displayed

**❓ Questions:**

1. What is the most common protocol in the capture?
   ```
   Answer: ______________________________________________________
   ```

2. How many packets are in the capture?
   ```
   Answer: ______________________________________________________
   ```

---

### Code Challenges

**🏆 Try these challenges on your own.**

**Challenge 1: Create a packet with custom EtherType**

```python
# Build an Ethernet frame with EtherType 0x88B5 (Local Experimental)
# Include a Raw payload with your name

# Your code here:
```

**Challenge 2: Build a VLAN-tagged ping packet**

```python
# Build an Ethernet frame with VLAN ID 100 containing an ICMP ping
# Use source IP 192.168.1.100 and destination IP 8.8.8.8

# Your code here:
```

**Challenge 3: Extract HTTP host headers from a PCAP**

```python
# Write a script that extracts all HTTP Host headers from a PCAP file

# Your code here:
```

---

### Self-Assessment Questions

**❓ Answer these questions without looking at the course material.**

1. What is the purpose of the `/` operator in Scapy?
   ```
   Answer: ______________________________________________________
   ```

2. How do you access the source IP address of a packet?
   ```
   Answer: ______________________________________________________
   ```

3. What is the difference between `rdpcap()` and `PcapReader()`?
   ```
   Answer: ______________________________________________________
   ```

4. Why do you need root/sudo privileges to send packets?
   ```
   Answer: ______________________________________________________
   ```

5. How do you save packets to a PCAP file?
   ```
   Answer: ______________________________________________________
   ```

---

### Troubleshooting Notes

**⚠️ Record solutions to any issues you encounter.**

| Issue | Solution |
|-------|----------|
| `ModuleNotFoundError: No module named 'scapy'` | |
| `Permission denied` when sending packets | |
| Wireshark can't open the PCAP file | |

---

## Module 2: Layer 2 & Layer 3 Operations

---

### Learning Objectives

After completing this module, you should be able to:

- [ ] Construct Ethernet frames with various MAC types
- [ ] Build VLAN-tagged frames (802.1Q)
- [ ] Implement ARP scanning
- [ ] Build a custom ping utility
- [ ] Implement traceroute from scratch
- [ ] Handle IP fragmentation

---

### Key Concepts Review

**📘 Complete this section after reading the module content.**

1. **What is a MAC address and how is it structured?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

2. **What is the difference between unicast, broadcast, and multicast?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

3. **What is VLAN tagging and why is it used?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

4. **How does ARP work?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

5. **How does traceroute work?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

---

### Lab Exercise 2.1: Ethernet Frame Construction

**💻 Create `src/ethernet_frames.py`**

```python
#!/usr/bin/env python3
"""
Module 2 Lab: Ethernet Frames
"""

from scapy.all import Ether, IP, ARP, ICMP, Dot1Q, wrpcap
from scapy.layers.l2 import Dot1Q

def build_ethernet_frames():
    """Build various Ethernet frames."""
    frames = []
    
    # 1. Unicast frame
    unicast = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
              IP(src="192.168.1.100", dst="8.8.8.8") / ICMP()
    frames.append(("Unicast", unicast))
    
    # 2. Broadcast frame (ARP)
    broadcast = Ether(src="00:11:22:33:44:55", dst="ff:ff:ff:ff:ff:ff") / \
                ARP(op=1, hwsrc="00:11:22:33:44:55", psrc="192.168.1.100",
                    hwdst="00:00:00:00:00:00", pdst="192.168.1.1")
    frames.append(("Broadcast", broadcast))
    
    # 3. VLAN frame
    vlan = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
           Dot1Q(vlan=100) / \
           IP(src="192.168.1.100", dst="8.8.8.8") / ICMP()
    frames.append(("VLAN", vlan))
    
    # 4. Q-in-Q frame
    qinq = Ether(src="00:11:22:33:44:55", dst="66:77:88:99:aa:bb") / \
           Dot1Q(vlan=100) / \
           Dot1Q(vlan=200) / \
           IP(src="192.168.1.100", dst="8.8.8.8") / ICMP()
    frames.append(("Q-in-Q", qinq))
    
    return frames

def display_frames(frames):
    """Display all frames."""
    for name, frame in frames:
        print(f"\n{'='*60}")
        print(f"{name} Frame")
        print(f"{'='*60}")
        print(f"Summary: {frame.summary()}")
        print(f"Length: {len(frame)} bytes")
        frame.show()

if __name__ == "__main__":
    frames = build_ethernet_frames()
    display_frames(frames)
    
    # Save to PCAP
    packets = [f for _, f in frames]
    wrpcap("output/ethernet_frames.pcap", packets)
    print("\n✅ Frames saved to output/ethernet_frames.pcap")
```

**✅ Verification:**

- [ ] All four frame types display correctly
- [ ] PCAP file is created
- [ ] You can view all frames in Wireshark

**❓ Questions:**

1. What is the destination MAC of the broadcast frame?
   ```
   Answer: ______________________________________________________
   ```

2. What VLAN ID is used in the VLAN frame?
   ```
   Answer: ______________________________________________________
   ```

3. How many VLAN tags are in the Q-in-Q frame?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 2.2: ARP Scanner

**💻 Create `src/arp_scanner.py`**

```python
#!/usr/bin/env python3
"""
Module 2 Lab: ARP Scanner
"""

from scapy.all import Ether, ARP, srp, get_if_hwaddr, conf
import ipaddress
import time

class SimpleARPScanner:
    def __init__(self, interface=None):
        self.interface = interface or conf.iface
        self.local_mac = get_if_hwaddr(self.interface)
        self.hosts = {}
    
    def get_local_ip(self):
        """Get local IP address."""
        import socket
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            s.connect(('8.8.8.8', 1))
            ip = s.getsockname()[0]
        except:
            ip = '127.0.0.1'
        finally:
            s.close()
        return ip
    
    def scan(self, network_cidr, timeout=2):
        """Scan network for hosts."""
        print(f"\n[SCAN] Scanning {network_cidr}")
        print(f"[SCAN] Interface: {self.interface}")
        print(f"[SCAN] Local MAC: {self.local_mac}")
        
        # Build ARP request
        arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / \
                      ARP(op=1,
                          hwsrc=self.local_mac,
                          psrc=self.get_local_ip(),
                          pdst=network_cidr)
        
        # Send and receive
        print("[SCAN] Sending ARP requests...")
        start = time.time()
        answered, unanswered = srp(arp_request, timeout=timeout, verbose=False)
        elapsed = time.time() - start
        
        # Process responses
        for sent, received in answered:
            ip = received[ARP].psrc
            mac = received[ARP].hwsrc
            self.hosts[ip] = mac
        
        print(f"[SCAN] Completed in {elapsed:.2f}s")
        print(f"[SCAN] Found {len(self.hosts)} hosts")
        return self.hosts
    
    def display_hosts(self):
        """Display discovered hosts."""
        if not self.hosts:
            print("No hosts discovered.")
            return
        
        print("\n" + "=" * 60)
        print("DISCOVERED HOSTS")
        print("=" * 60)
        print(f"{'IP Address':<20} {'MAC Address':<20}")
        print("-" * 40)
        for ip, mac in sorted(self.hosts.items()):
            print(f"{ip:<20} {mac:<20}")
        print("-" * 40)
        print(f"Total: {len(self.hosts)} hosts")

if __name__ == "__main__":
    scanner = SimpleARPScanner()
    scanner.scan("192.168.1.0/24")
    scanner.display_hosts()
```

**✅ Verification:**

- [ ] Scanner runs without errors
- [ ] Hosts are discovered
- [ ] IP and MAC addresses are displayed

**❓ Questions:**

1. What is your local IP address?
   ```
   Answer: ______________________________________________________
   ```

2. How many hosts were discovered?
   ```
   Answer: ______________________________________________________
   ```

3. What is the MAC address of your gateway (if found)?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 2.3: Custom Ping

**💻 Create `src/custom_ping.py`**

```python
#!/usr/bin/env python3
"""
Module 2 Lab: Custom Ping Utility
"""

from scapy.all import IP, ICMP, sr1
import time
import statistics

class CustomPing:
    def __init__(self, target, count=4, timeout=2, interval=1):
        self.target = target
        self.count = count
        self.timeout = timeout
        self.interval = interval
        self.sent = 0
        self.received = 0
        self.times = []
    
    def ping(self):
        """Execute ping."""
        print(f"\nPING {self.target}")
        print(f"Count: {self.count}, Timeout: {self.timeout}s")
        print("-" * 40)
        
        for i in range(self.count):
            packet = IP(dst=self.target) / ICMP(id=12345, seq=i+1)
            start = time.time()
            reply = sr1(packet, timeout=self.timeout, verbose=False)
            elapsed = (time.time() - start) * 1000  # ms
            
            self.sent += 1
            
            if reply and reply.haslayer(ICMP) and reply[ICMP].type == 0:
                self.received += 1
                self.times.append(elapsed)
                print(f"Reply from {self.target}: time={elapsed:.2f}ms")
            else:
                print("Request timed out")
            
            if i < self.count - 1:
                time.sleep(self.interval)
        
        self.display_stats()
    
    def display_stats(self):
        """Display statistics."""
        print("-" * 40)
        print(f"Sent: {self.sent}, Received: {self.received}")
        print(f"Packet loss: {((self.sent - self.received) / self.sent) * 100:.1f}%")
        
        if self.times:
            print(f"Min: {min(self.times):.2f}ms")
            print(f"Avg: {sum(self.times) / len(self.times):.2f}ms")
            print(f"Max: {max(self.times):.2f}ms")
            if len(self.times) > 1:
                print(f"StdDev: {statistics.stdev(self.times):.2f}ms")

if __name__ == "__main__":
    target = input("Enter target IP: ").strip()
    count = int(input("Number of pings (default 4): ").strip() or 4)
    
    ping = CustomPing(target, count)
    ping.ping()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Ping replies are received (or timeouts displayed)
- [ ] Statistics are displayed

**❓ Questions:**

1. What was the average RTT?
   ```
   Answer: ______________________________________________________
   ```

2. What was the packet loss percentage?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 2.4: Traceroute

**💻 Create `src/custom_traceroute.py`**

```python
#!/usr/bin/env python3
"""
Module 2 Lab: Custom Traceroute
"""

from scapy.all import IP, ICMP, sr1
import time
import socket

def traceroute(target, max_hops=30, timeout=2):
    """Perform traceroute to target."""
    print(f"\nTRACEROUTE to {target}")
    print(f"Max hops: {max_hops}")
    print("-" * 40)
    
    resolved = False
    try:
        target_ip = socket.gethostbyname(target)
        resolved = True
        print(f"Resolved: {target} -> {target_ip}")
    except:
        target_ip = target
    
    print("-" * 40)
    print(f"{'Hop':>4} {'IP Address':<20} {'Time':<10}")
    print("-" * 40)
    
    for ttl in range(1, max_hops + 1):
        packet = IP(dst=target_ip, ttl=ttl) / ICMP()
        start = time.time()
        reply = sr1(packet, timeout=timeout, verbose=False)
        elapsed = (time.time() - start) * 1000
        
        if reply is None:
            print(f"{ttl:>4} * * *")
            continue
        
        ip = reply[IP].src
        if reply.haslayer(ICMP):
            if reply[ICMP].type == 0:  # Echo Reply
                print(f"{ttl:>4} {ip:<20} {elapsed:.2f}ms - Reached destination!")
                break
            elif reply[ICMP].type == 11:  # Time Exceeded
                print(f"{ttl:>4} {ip:<20} {elapsed:.2f}ms")
            else:
                print(f"{ttl:>4} {ip:<20} {elapsed:.2f}ms (type={reply[ICMP].type})")
        else:
            print(f"{ttl:>4} {ip:<20} {elapsed:.2f}ms")

if __name__ == "__main__":
    target = input("Enter target IP or hostname: ").strip()
    if target:
        traceroute(target)
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Each hop is displayed
- [ ] Destination is reached (or max hops reached)

**❓ Questions:**

1. How many hops to reach the destination?
   ```
   Answer: ______________________________________________________
   ```

2. What is the first hop's IP address?
   ```
   Answer: ______________________________________________________
   ```

---

### Code Challenges

**🏆 Try these challenges on your own.**

**Challenge 1: MAC Address Validator**

```python
# Write a function that validates MAC address format
# Should handle: XX:XX:XX:XX:XX:XX and XX-XX-XX-XX-XX-XX
# Return True if valid, False otherwise

# Your code here:
```

**Challenge 2: VLAN Scanner**

```python
# Write a script that scans for VLAN tags in a PCAP
# Count how many packets have VLAN tags
# List the VLAN IDs found

# Your code here:
```

**Challenge 3: ARP Cache Monitor**

```python
# Write a script that monitors ARP cache for changes
# Alert when IP-MAC mappings change

# Your code here:
```

---

### Self-Assessment Questions

**❓ Answer these questions without looking at the course material.**

1. What is the purpose of the TTL field in IP packets?
   ```
   Answer: ______________________________________________________
   ```

2. How does ARP resolve IP addresses to MAC addresses?
   ```
   Answer: ______________________________________________________
   ```

3. What is the difference between VLAN and Q-in-Q?
   ```
   Answer: ______________________________________________________
   ```

4. How does traceroute discover the path to a destination?
   ```
   Answer: ______________________________________________________
   ```

5. What is the DF flag in IP packets?
   ```
   Answer: ______________________________________________________
   ```

---

## Module 3: Transport Layer Protocols & Reconnaissance

---

### Learning Objectives

After completing this module, you should be able to:

- [ ] Build TCP and UDP packets
- [ ] Perform TCP SYN scanning
- [ ] Implement TCP Connect scanning
- [ ] Build UDP scanners
- [ ] Implement banner grabbing
- [ ] Create multi-threaded scanning tools

---

### Key Concepts Review

**📘 Complete this section after reading the module content.**

1. **What is the difference between TCP and UDP?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

2. **What are the TCP flags and what do they do?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

3. **What is the TCP three-way handshake?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

4. **What is the difference between SYN scan and Connect scan?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

5. **What is banner grabbing?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

---

### Lab Exercise 3.1: TCP SYN Scanner

**💻 Create `src/tcp_syn_scanner.py`**

```python
#!/usr/bin/env python3
"""
Module 3 Lab: TCP SYN Scanner
"""

from scapy.all import IP, TCP, sr1, send, conf
import threading
import time
import queue

class TCPSYNScanner:
    def __init__(self, target, ports=None, threads=10, timeout=2):
        self.target = target
        self.ports = ports or list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
        self.filtered_ports = []
        self.port_queue = queue.Queue()
        self.lock = threading.Lock()
        self.total_scanned = 0
    
    def scan_port(self, port):
        """Scan a single port using SYN scan."""
        packet = IP(dst=self.target) / TCP(dport=port, flags="S")
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply is None:
            return "filtered"
        
        if reply.haslayer(TCP):
            tcp = reply[TCP]
            if tcp.flags & 0x12:  # SYN-ACK
                # Send RST to close
                rst = IP(dst=self.target) / TCP(dport=port, flags="R", seq=tcp.ack)
                send(rst, verbose=False)
                return "open"
            elif tcp.flags & 0x04:  # RST
                return "closed"
        
        return "filtered"
    
    def worker(self):
        """Worker thread."""
        while not self.port_queue.empty():
            try:
                port = self.port_queue.get_nowait()
                status = self.scan_port(port)
                
                with self.lock:
                    self.total_scanned += 1
                    if status == "open":
                        self.open_ports.append(port)
                    elif status == "filtered":
                        self.filtered_ports.append(port)
                    
                    if self.total_scanned % 50 == 0:
                        progress = (self.total_scanned / len(self.ports)) * 100
                        print(f"  Progress: {self.total_scanned}/{len(self.ports)} ({progress:.1f}%)")
                
                self.port_queue.task_done()
            except:
                self.port_queue.task_done()
    
    def scan(self):
        """Execute the scan."""
        print(f"\n[SYN SCAN] Target: {self.target}")
        print(f"[SYN SCAN] Ports: {len(self.ports)}")
        print(f"[SYN SCAN] Threads: {self.threads}")
        print("-" * 40)
        
        # Fill queue
        for port in self.ports:
            self.port_queue.put(port)
        
        start = time.time()
        
        # Start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for completion
        for t in threads:
            t.join()
        
        elapsed = time.time() - start
        
        # Display results
        print("\n" + "=" * 60)
        print("SYN SCAN RESULTS")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed:.2f}s")
        print(f"Open ports: {len(self.open_ports)}")
        print(f"Filtered ports: {len(self.filtered_ports)}")
        
        if self.open_ports:
            print("\nOpen Ports:")
            print("-" * 40)
            for port in sorted(self.open_ports):
                print(f"  {port}")

if __name__ == "__main__":
    target = input("Enter target IP: ").strip()
    port_spec = input("Port range (e.g., 1-1000, or press Enter for 1-1024): ").strip()
    
    if port_spec and '-' in port_spec:
        start, end = port_spec.split('-')
        ports = list(range(int(start), int(end) + 1))
    else:
        ports = list(range(1, 1025))
    
    scanner = TCPSYNScanner(target, ports=ports, threads=20)
    scanner.scan()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Open ports are discovered
- [ ] Scan progress is displayed

**❓ Questions:**

1. What ports were found open?
   ```
   Answer: ______________________________________________________
   ```

2. How long did the scan take?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 3.2: TCP Connect Scanner with Banner Grabbing

**💻 Create `src/tcp_connect_scanner.py`**

```python
#!/usr/bin/env python3
"""
Module 3 Lab: TCP Connect Scanner with Banner Grabbing
"""

import socket
import threading
import time
import queue
import sys

class TCPConnectScanner:
    def __init__(self, target, ports=None, threads=10, timeout=3, grab_banner=False):
        self.target = target
        self.ports = ports or list(range(1, 1025))
        self.threads = threads
        self.timeout = timeout
        self.grab_banner = grab_banner
        self.open_ports = []
        self.banners = {}
        self.port_queue = queue.Queue()
        self.lock = threading.Lock()
        self.total_scanned = 0
    
    def grab_banner_thread(self, ip, port):
        """Grab banner from service."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            sock.connect((ip, port))
            
            # Send probes for common services
            probes = {
                22: b"SSH-2.0-Scapy\r\n",
                80: b"HEAD / HTTP/1.0\r\n\r\n",
                443: b"HEAD / HTTP/1.0\r\n\r\n",
                25: b"EHLO test\r\n",
                21: b"USER anonymous\r\n",
            }
            
            if port in probes:
                sock.send(probes[port])
            
            banner = sock.recv(1024).decode('utf-8', errors='ignore')
            sock.close()
            return banner.strip()[:200]
        except:
            return None
    
    def scan_port(self, port):
        """Scan a port using TCP connect."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            if result == 0:  # Connection successful
                banner = None
                if self.grab_banner:
                    banner = self.grab_banner_thread(self.target, port)
                return "open", banner
            return "closed", None
        except:
            return "error", None
    
    def worker(self):
        """Worker thread."""
        while not self.port_queue.empty():
            try:
                port = self.port_queue.get_nowait()
                status, banner = self.scan_port(port)
                
                with self.lock:
                    self.total_scanned += 1
                    if status == "open":
                        self.open_ports.append(port)
                        if banner:
                            self.banners[port] = banner
                    
                    if self.total_scanned % 50 == 0:
                        progress = (self.total_scanned / len(self.ports)) * 100
                        print(f"  Progress: {self.total_scanned}/{len(self.ports)} ({progress:.1f}%)")
                
                self.port_queue.task_done()
            except:
                self.port_queue.task_done()
    
    def scan(self):
        """Execute the scan."""
        print(f"\n[CONNECT SCAN] Target: {self.target}")
        print(f"[CONNECT SCAN] Ports: {len(self.ports)}")
        print(f"[CONNECT SCAN] Threads: {self.threads}")
        if self.grab_banner:
            print("[CONNECT SCAN] Banner grabbing: Enabled")
        print("-" * 40)
        
        # Fill queue
        for port in self.ports:
            self.port_queue.put(port)
        
        start = time.time()
        
        # Start threads
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        # Wait for completion
        for t in threads:
            t.join()
        
        elapsed = time.time() - start
        
        # Display results
        print("\n" + "=" * 60)
        print("CONNECT SCAN RESULTS")
        print("=" * 60)
        print(f"Target: {self.target}")
        print(f"Scan time: {elapsed:.2f}s")
        print(f"Open ports: {len(self.open_ports)}")
        
        if self.open_ports:
            print("\nOpen Ports:")
            print("-" * 60)
            print(f"{'Port':<10} {'Service':<15} {'Banner'}")
            print("-" * 60)
            for port in sorted(self.open_ports):
                banner = self.banners.get(port, '')
                if banner:
                    print(f"{port:<10} {'':<15} {banner[:50]}")
                else:
                    print(f"{port:<10} {'':<15} (no banner)")

if __name__ == "__main__":
    target = input("Enter target IP: ").strip()
    port_spec = input("Port range (e.g., 1-1000): ").strip()
    
    if port_spec and '-' in port_spec:
        start, end = port_spec.split('-')
        ports = list(range(int(start), int(end) + 1))
    else:
        ports = list(range(1, 1025))
    
    grab = input("Grab banners? (y/n): ").strip().lower() == 'y'
    
    scanner = TCPConnectScanner(target, ports=ports, threads=10, grab_banner=grab)
    scanner.scan()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Open ports are discovered
- [ ] Banners are displayed (if enabled)

**❓ Questions:**

1. What service banners were found?
   ```
   Answer: ______________________________________________________
   ```

2. What is the difference between this scan and the SYN scan?
   ```
   Answer: ______________________________________________________
   ```

---

### Code Challenges

**🏆 Try these challenges on your own.**

**Challenge 1: UDP Scanner**

```python
# Write a UDP scanner that checks for open UDP ports
# Use ICMP unreachable detection

# Your code here:
```

**Challenge 2: Port Scanner with Rate Limiting**

```python
# Modify the SYN scanner to include rate limiting
# Set a maximum packets per second

# Your code here:
```

**Challenge 3: Service Detection**

```python
# Write a script that maps open ports to service names
# Use a dictionary of common ports and services

# Your code here:
```

---

### Self-Assessment Questions

**❓ Answer these questions without looking at the course material.**

1. What is the TCP three-way handshake?
   ```
   Answer: ______________________________________________________
   ```

2. What is the difference between SYN and Connect scans?
   ```
   Answer: ______________________________________________________
   ```

3. Why is UDP scanning difficult?
   ```
   Answer: ______________________________________________________
   ```

4. What is banner grabbing used for?
   ```
   Answer: ______________________________________________________
   ```

5. What are the advantages of multi-threaded scanning?
   ```
   Answer: ______________________________________________________
   ```

---

## Module 4: Packet Sniffing, Filtering & Traffic Analysis

---

### Learning Objectives

After completing this module, you should be able to:

- [ ] Capture packets with `sniff()`
- [ ] Apply BPF filters
- [ ] Analyze HTTP traffic
- [ ] Monitor DNS traffic
- [ ] Build traffic statistics
- [ ] Create live dashboards

---

### Key Concepts Review

**📘 Complete this section after reading the module content.**

1. **What is packet sniffing?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

2. **What are BPF filters and why are they useful?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

3. **What is promiscuous mode?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

4. **What can you learn from HTTP traffic analysis?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

5. **What is flow tracking?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

---

### Lab Exercise 4.1: Basic Packet Sniffer

**💻 Create `src/basic_sniffer.py`**

```python
#!/usr/bin/env python3
"""
Module 4 Lab: Basic Packet Sniffer
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP, conf
from datetime import datetime
import time

class BasicSniffer:
    def __init__(self, interface=None, filter_str=None, count=0, timeout=None):
        self.interface = interface or conf.iface
        self.filter_str = filter_str
        self.count = count
        self.timeout = timeout
        self.packet_count = 0
        self.start_time = None
        self.stats = {
            'total': 0,
            'tcp': 0,
            'udp': 0,
            'icmp': 0,
            'other': 0
        }
    
    def packet_callback(self, packet):
        """Callback for each packet."""
        self.packet_count += 1
        self.stats['total'] += 1
        
        # Protocol classification
        if packet.haslayer(TCP):
            self.stats['tcp'] += 1
            self.handle_tcp(packet)
        elif packet.haslayer(UDP):
            self.stats['udp'] += 1
        elif packet.haslayer(ICMP):
            self.stats['icmp'] += 1
        else:
            self.stats['other'] += 1
        
        # Display packet
        if self.packet_count % 10 == 0:
            timestamp = datetime.fromtimestamp(packet.time).strftime('%H:%M:%S')
            print(f"[{timestamp}] #{self.packet_count}: {packet.summary()}")
    
    def handle_tcp(self, packet):
        """Handle TCP packets."""
        tcp = packet[TCP]
        # Detect SYN packets
        if tcp.flags & 0x02:  # SYN
            if tcp.flags & 0x10:  # SYN-ACK
                print(f"  [!] SYN-ACK from {packet[IP].src}:{tcp.sport}")
            else:
                print(f"  [!] SYN from {packet[IP].src}:{tcp.sport}")
    
    def start_sniffing(self):
        """Start sniffing."""
        print("\n" + "=" * 60)
        print("STARTING PACKET SNIFFER")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print(f"Filter: {self.filter_str or 'None'}")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.start_time = time.time()
        
        try:
            sniff(iface=self.interface,
                  filter=self.filter_str,
                  prn=self.packet_callback,
                  count=self.count if self.count > 0 else None,
                  timeout=self.timeout,
                  store=False)
        except KeyboardInterrupt:
            print("\n\nStopping sniffer...")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display statistics."""
        elapsed = time.time() - self.start_time if self.start_time else 0
        
        print("\n" + "=" * 60)
        print("SNIFFER STATISTICS")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Total packets: {self.stats['total']}")
        print(f"Packets/sec: {self.stats['total'] / max(1, elapsed):.2f}")
        print(f"TCP: {self.stats['tcp']}")
        print(f"UDP: {self.stats['udp']}")
        print(f"ICMP: {self.stats['icmp']}")
        print(f"Other: {self.stats['other']}")

if __name__ == "__main__":
    from scapy.all import get_if_list
    
    interfaces = get_if_list()
    print("Available interfaces:")
    for i, iface in enumerate(interfaces):
        print(f"  {i+1}. {iface}")
    
    choice = input("Select interface number: ").strip()
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
    
    sniffer = BasicSniffer(interface=interface, filter_str=filter_str, count=20)
    sniffer.start_sniffing()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Packets are captured
- [ ] Statistics are displayed
- [ ] TCP SYN packets are highlighted

**❓ Questions:**

1. How many packets were captured?
   ```
   Answer: ______________________________________________________
   ```

2. What was the protocol distribution?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 4.2: HTTP Analyzer

**💻 Create `src/http_analyzer.py`**

```python
#!/usr/bin/env python3
"""
Module 4 Lab: HTTP Analyzer
"""

from scapy.all import sniff, IP, TCP, Raw
import re

class HTTPAnalyzer:
    def __init__(self, interface=None, count=0):
        self.interface = interface
        self.count = count
        self.requests = []
        self.responses = []
        self.stats = {
            'GET': 0,
            'POST': 0,
            'PUT': 0,
            'DELETE': 0,
            '200': 0,
            '301': 0,
            '302': 0,
            '304': 0,
            '404': 0,
            '500': 0
        }
    
    def process_packet(self, packet):
        """Process packet for HTTP data."""
        if not packet.haslayer(TCP) or not packet.haslayer(Raw):
            return
        
        tcp = packet[TCP]
        if tcp.sport != 80 and tcp.dport != 80:
            return
        
        payload = bytes(packet[Raw])
        try:
            data = payload.decode('utf-8', errors='ignore')
        except:
            return
        
        # Check for HTTP request
        request_match = re.match(r'^(GET|POST|PUT|DELETE|HEAD|OPTIONS)', data)
        if request_match:
            method = request_match.group(1)
            self.stats[method] = self.stats.get(method, 0) + 1
            
            # Extract request line
            lines = data.split('\r\n')
            if lines:
                print(f"\n[HTTP] {method} Request: {lines[0]}")
                # Extract Host header
                for line in lines:
                    if line.lower().startswith('host:'):
                        print(f"  Host: {line.split(':', 1)[1].strip()}")
                        break
            return
        
        # Check for HTTP response
        response_match = re.match(r'^HTTP/\d+\.\d+ (\d+)', data)
        if response_match:
            status = response_match.group(1)
            status_key = status[:3]  # e.g., "200", "404"
            if status_key in self.stats:
                self.stats[status_key] += 1
            
            lines = data.split('\r\n')
            if lines:
                print(f"\n[HTTP] Response: {lines[0]}")
    
    def start(self):
        """Start sniffing."""
        print("\n" + "=" * 60)
        print("HTTP ANALYZER")
        print("=" * 60)
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        try:
            sniff(iface=self.interface,
                  filter="tcp port 80",
                  prn=self.process_packet,
                  count=self.count if self.count > 0 else None,
                  store=False)
        except KeyboardInterrupt:
            print("\n\nStopping...")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display statistics."""
        print("\n" + "=" * 60)
        print("HTTP STATISTICS")
        print("=" * 60)
        print("\nMethods:")
        print("-" * 40)
        for method in ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS']:
            if method in self.stats:
                print(f"  {method}: {self.stats[method]}")
        
        print("\nStatus Codes:")
        print("-" * 40)
        for status in ['200', '301', '302', '304', '404', '500']:
            if status in self.stats:
                print(f"  {status}: {self.stats[status]}")

if __name__ == "__main__":
    analyzer = HTTPAnalyzer()
    analyzer.start()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] HTTP requests and responses are displayed
- [ ] Statistics are shown

**❓ Questions:**

1. What HTTP methods were observed?
   ```
   Answer: ______________________________________________________
   ```

2. What status codes were returned?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 4.3: DNS Monitor

**💻 Create `src/dns_monitor.py`**

```python
#!/usr/bin/env python3
"""
Module 4 Lab: DNS Monitor
"""

from scapy.all import sniff, IP, UDP, DNS, DNSQR, DNSRR
import time
from collections import defaultdict

class DNSMonitor:
    def __init__(self, interface=None, count=0):
        self.interface = interface
        self.count = count
        self.queries = defaultdict(int)
        self.responses = {}
        self.cache = {}
        self.suspicious = []
    
    def process_packet(self, packet):
        """Process DNS packet."""
        if not packet.haslayer(DNS):
            return
        
        dns = packet[DNS]
        
        if dns.qr == 0:  # Query
            self.handle_query(packet, dns)
        else:  # Response
            self.handle_response(packet, dns)
    
    def handle_query(self, packet, dns):
        """Handle DNS query."""
        if dns.qd:
            qname = dns.qd.qname.decode('utf-8') if dns.qd.qname else 'Unknown'
            qname = qname.rstrip('.')
            self.queries[qname] += 1
            
            # Check for suspicious domains
            if len(qname) > 50:
                self.suspicious.append({
                    'type': 'long_domain',
                    'domain': qname,
                    'src': packet[IP].src
                })
                print(f"[!] Suspicious: Long domain {qname} from {packet[IP].src}")
            
            print(f"[DNS] Query: {qname} from {packet[IP].src}")
    
    def handle_response(self, packet, dns):
        """Handle DNS response."""
        if dns.an:
            for answer in dns.an:
                if isinstance(answer, DNSRR):
                    domain = answer.rrname.decode('utf-8').rstrip('.')
                    rdata = str(answer.rdata)
                    self.responses[domain] = rdata
                    self.cache[domain] = {
                        'data': rdata,
                        'time': time.time()
                    }
                    print(f"[DNS] Response: {domain} -> {rdata}")
    
    def start(self):
        """Start monitoring."""
        print("\n" + "=" * 60)
        print("DNS MONITOR")
        print("=" * 60)
        print("Press Ctrl+C to stop")
        print("-" * 40)
        
        try:
            sniff(iface=self.interface,
                  filter="udp port 53",
                  prn=self.process_packet,
                  count=self.count if self.count > 0 else None,
                  store=False)
        except KeyboardInterrupt:
            print("\n\nStopping...")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display statistics."""
        print("\n" + "=" * 60)
        print("DNS STATISTICS")
        print("=" * 60)
        print(f"Queries: {len(self.queries)}")
        print(f"Responses: {len(self.responses)}")
        print(f"Cache entries: {len(self.cache)}")
        
        print("\nTop 10 Domains:")
        print("-" * 40)
        for domain, count in sorted(self.queries.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {domain}: {count}")
        
        if self.suspicious:
            print(f"\n⚠️ Suspicious Activity: {len(self.suspicious)}")
            print("-" * 40)
            for item in self.suspicious[:5]:
                print(f"  {item['type']}: {item['domain']} from {item['src']}")

if __name__ == "__main__":
    monitor = DNSMonitor()
    monitor.start()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] DNS queries and responses are displayed
- [ ] Statistics are shown

**❓ Questions:**

1. What domains were queried?
   ```
   Answer: ______________________________________________________
   ```

2. Were any suspicious domains detected?
   ```
   Answer: ______________________________________________________
   ```

---

### Code Challenges

**🏆 Try these challenges on your own.**

**Challenge 1: Traffic Dashboard**

```python
# Write a script that displays live traffic statistics
# Include: packet rate, protocol distribution, top talkers

# Your code here:
```

**Challenge 2: DHCP Analyzer**

```python
# Write a script that analyzes DHCP traffic
# Track DORA sequences
# Detect rogue DHCP servers

# Your code here:
```

**Challenge 3: TCP Flag Analysis**

```python
# Write a script that analyzes TCP flags in traffic
# Count SYN, ACK, RST, FIN packets
# Detect port scans

# Your code here:
```

---

### Self-Assessment Questions

**❓ Answer these questions without looking at the course material.**

1. What is the purpose of BPF filters?
   ```
   Answer: ______________________________________________________
   ```

2. How do you capture packets with Scapy?
   ```
   Answer: ______________________________________________________
   ```

3. What is flow tracking?
   ```
   Answer: ______________________________________________________
   ```

4. What can you learn from HTTP headers?
   ```
   Answer: ______________________________________________________
   ```

5. Why is DNS monitoring important for security?
   ```
   Answer: ______________________________________________________
   ```

---

## Module 5: Active Network Manipulation & Security Testing

---

### Learning Objectives

After completing this module, you should be able to:

- [ ] Detect ARP spoofing
- [ ] Build packet injection tools
- [ ] Implement packet replay
- [ ] Generate custom payloads
- [ ] Build security assessment tools

---

### Key Concepts Review

**📘 Complete this section after reading the module content.**

1. **What is ARP spoofing and how does it work?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

2. **What is packet injection?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

3. **What are the safety controls for packet injection?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

4. **What is a man-in-the-middle attack?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

5. **What is responsible disclosure?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

---

### Lab Exercise 5.1: ARP Spoofing Detection

**💻 Create `src/arp_detector.py`**

```python
#!/usr/bin/env python3
"""
Module 5 Lab: ARP Spoofing Detector
"""

from scapy.all import sniff, ARP, Ether
from datetime import datetime

class ARPSpoofingDetector:
    def __init__(self, interface=None):
        self.interface = interface
        self.ip_mac_mapping = {}
        self.alerts = []
        self.packet_count = 0
    
    def process_arp(self, packet):
        """Process ARP packet."""
        if not packet.haslayer(ARP):
            return
        
        self.packet_count += 1
        arp = packet[ARP]
        src_ip = arp.psrc
        src_mac = arp.hwsrc
        
        # Skip 0.0.0.0 (DHCP)
        if src_ip == '0.0.0.0':
            return
        
        # Check for MAC change
        if src_ip in self.ip_mac_mapping:
            if self.ip_mac_mapping[src_ip] != src_mac:
                self.alert({
                    'type': 'MAC_Change',
                    'ip': src_ip,
                    'old_mac': self.ip_mac_mapping[src_ip],
                    'new_mac': src_mac,
                    'timestamp': datetime.now()
                })
        
        # Update mapping
        self.ip_mac_mapping[src_ip] = src_mac
        
        # Check for duplicate IP
        for ip, mac in self.ip_mac_mapping.items():
            if ip != src_ip and mac == src_mac:
                self.alert({
                    'type': 'Duplicate_IP',
                    'ip': ip,
                    'mac': src_mac,
                    'timestamp': datetime.now()
                })
        
        # Display packet
        if self.packet_count % 10 == 0:
            print(f"[ARP] {src_ip} -> {src_mac}")
    
    def alert(self, alert_data):
        """Handle alert."""
        self.alerts.append(alert_data)
        alert_type = alert_data['type']
        
        if alert_type == 'MAC_Change':
            print(f"\n⚠️ ALERT: MAC change for {alert_data['ip']}")
            print(f"   Old MAC: {alert_data['old_mac']}")
            print(f"   New MAC: {alert_data['new_mac']}")
        elif alert_type == 'Duplicate_IP':
            print(f"\n⚠️ ALERT: Duplicate IP {alert_data['ip']}")
            print(f"   MAC: {alert_data['mac']}")
    
    def start(self, timeout=None):
        """Start monitoring."""
        print("\n" + "=" * 60)
        print("ARP SPOOFING DETECTOR")
        print("=" * 60)
        print("Press Ctrl+C to stop")
        print("-" * 40)
        
        try:
            sniff(iface=self.interface,
                  filter="arp",
                  prn=self.process_arp,
                  timeout=timeout,
                  store=False)
        except KeyboardInterrupt:
            print("\n\nStopping...")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display statistics."""
        print("\n" + "=" * 60)
        print("ARP DETECTION SUMMARY")
        print("=" * 60)
        print(f"Packets processed: {self.packet_count}")
        print(f"IP-MAC mappings: {len(self.ip_mac_mapping)}")
        print(f"Alerts: {len(self.alerts)}")
        
        if self.alerts:
            print("\nAlerts:")
            print("-" * 40)
            for alert in self.alerts:
                if alert['type'] == 'MAC_Change':
                    print(f"  MAC Change: {alert['ip']} {alert['old_mac']} -> {alert['new_mac']}")
                elif alert['type'] == 'Duplicate_IP':
                    print(f"  Duplicate IP: {alert['ip']} ({alert['mac']})")

if __name__ == "__main__":
    from scapy.all import conf, get_if_list
    
    interfaces = get_if_list()
    print("Available interfaces:")
    for i, iface in enumerate(interfaces):
        print(f"  {i+1}. {iface}")
    
    choice = input("Select interface number: ").strip()
    if choice:
        try:
            idx = int(choice) - 1
            interface = interfaces[idx]
        except:
            interface = conf.iface
    else:
        interface = conf.iface
    
    detector = ARPSpoofingDetector(interface=interface)
    detector.start()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] ARP packets are displayed
- [ ] Alerts are generated for anomalies

**❓ Questions:**

1. How many ARP packets were processed?
   ```
   Answer: ______________________________________________________
   ```

2. Were any alerts generated?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 5.2: Packet Replay

**💻 Create `src/packet_replay.py`**

```python
#!/usr/bin/env python3
"""
Module 5 Lab: Packet Replay
"""

from scapy.all import rdpcap, send, conf
import time
import sys

class PacketReplay:
    def __init__(self, interface=None, rate=100, loop=False):
        self.interface = interface or conf.iface
        self.rate = rate
        self.loop = loop
        self.packets = []
        self.sent = 0
    
    def load_pcap(self, pcap_file):
        """Load packets from PCAP."""
        try:
            self.packets = rdpcap(pcap_file)
            print(f"Loaded {len(self.packets)} packets from {pcap_file}")
            return True
        except Exception as e:
            print(f"Error loading PCAP: {e}")
            return False
    
    def replay(self):
        """Replay packets."""
        if not self.packets:
            print("No packets loaded.")
            return
        
        print("\n" + "=" * 60)
        print("STARTING PACKET REPLAY")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print(f"Rate: {self.rate} packets/second")
        print(f"Loop: {self.loop}")
        print("Press Ctrl+C to stop")
        print("-" * 40)
        
        interval = 1.0 / self.rate
        
        try:
            while True:
                for packet in self.packets:
                    send(packet, iface=self.interface, verbose=False)
                    self.sent += 1
                    
                    if self.sent % 100 == 0:
                        print(f"  Sent {self.sent} packets")
                    
                    time.sleep(interval)
                
                if not self.loop:
                    break
                
                print(f"\nLoop completed, restarting...")
        
        except KeyboardInterrupt:
            print("\n\nReplay interrupted")
        finally:
            self.display_stats()
    
    def display_stats(self):
        """Display statistics."""
        print("\n" + "=" * 60)
        print("REPLAY STATISTICS")
        print("=" * 60)
        print(f"Packets sent: {self.sent}")
        print(f"Packets loaded: {len(self.packets)}")

if __name__ == "__main__":
    pcap_file = input("Enter PCAP file path: ").strip()
    if not pcap_file:
        print("No PCAP file specified.")
        sys.exit(1)
    
    rate = input("Packets per second (default: 100): ").strip()
    rate = int(rate) if rate else 100
    
    loop = input("Loop replay? (y/n): ").strip().lower() == 'y'
    
    replay = PacketReplay(rate=rate, loop=loop)
    if replay.load_pcap(pcap_file):
        replay.replay()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Packets are replayed
- [ ] Statistics are displayed

**❓ Questions:**

1. How many packets were replayed?
   ```
   Answer: ______________________________________________________
   ```

2. What was the replay rate?
   ```
   Answer: ______________________________________________________
   ```

---

### Code Challenges

**🏆 Try these challenges on your own.**

**Challenge 1: Rogue DHCP Detector**

```python
# Write a script that detects rogue DHCP servers
# Compare observed DHCP servers with authorized list

# Your code here:
```

**Challenge 2: DNS Tunneling Detector**

```python
# Write a script that detects DNS tunneling
# Look for long domains, high query rates, base64 patterns

# Your code here:
```

**Challenge 3: Packet Injection Framework**

```python
# Build a framework for packet injection with safety controls
# Include: authorization, rate limiting, logging

# Your code here:
```

---

### Self-Assessment Questions

**❓ Answer these questions without looking at the course material.**

1. What is ARP spoofing and how can it be detected?
   ```
   Answer: ______________________________________________________
   ```

2. What safety controls should be used for packet injection?
   ```
   Answer: ______________________________________________________
   ```

3. What is packet replay used for?
   ```
   Answer: ______________________________________________________
   ```

4. How can you detect rogue DHCP servers?
   ```
   Answer: ______________________________________________________
   ```

5. What is responsible disclosure?
   ```
   Answer: ______________________________________________________
   ```

---

## Module 6: Automation, Performance & Custom Protocols

---

### Learning Objectives

After completing this module, you should be able to:

- [ ] Build high-performance capture engines
- [ ] Implement asynchronous processing
- [ ] Use efficient data structures
- [ ] Create custom protocols in Scapy
- [ ] Build a complete toolkit

---

### Key Concepts Review

**📘 Complete this section after reading the module content.**

1. **What is the producer-consumer pattern?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

2. **What is asynchronous processing?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

3. **What are efficient data structures for packet analysis?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

4. **How do you create a custom protocol in Scapy?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

5. **What is protocol fuzzing?**
   ```
   Your answer: __________________________________________________
   _____________________________________________________________
   ```

---

### Lab Exercise 6.1: Custom Protocol

**💻 Create `src/custom_protocol.py`**

```python
#!/usr/bin/env python3
"""
Module 6 Lab: Custom Protocol
"""

from scapy.packet import Packet
from scapy.fields import *
from scapy.all import bind_layers, IP

class MyProtocol(Packet):
    """Custom Protocol"""
    name = "MyProtocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        ShortField("length", 0),
        IntField("sequence", 0),
        IntField("timestamp", 0)
    ]
    
    def mysummary(self):
        return f"MyProtocol v{self.version} type={self.type} seq={self.sequence}"

class MyData(Packet):
    """Custom Data Payload"""
    name = "MyData"
    fields_desc = [
        ByteField("data_type", 0),
        ShortField("data_length", 0),
        StrLenField("data", "", length_from=lambda p: p.data_length)
    ]
    
    def mysummary(self):
        return f"MyData type={self.data_type} len={self.data_length}"

# Bind protocols
bind_layers(IP, MyProtocol, proto=252)
bind_layers(MyProtocol, MyData, type=0)

def build_custom_packet(version=1, msg_type=0, seq=0, data_type=0, data=b"Hello"):
    """Build a custom protocol packet."""
    import time
    
    proto = MyProtocol(
        version=version,
        type=msg_type,
        length=len(data) + 3,  # Data header size
        sequence=seq,
        timestamp=int(time.time())
    )
    
    data_pkt = MyData(
        data_type=data_type,
        data_length=len(data),
        data=data
    )
    
    return proto / data_pkt

def demonstrate():
    """Demonstrate custom protocol."""
    print("\n" + "=" * 60)
    print("CUSTOM PROTOCOL DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Build packet
    pkt = build_custom_packet(
        version=1,
        msg_type=0,
        seq=1001,
        data_type=1,
        data=b"Custom protocol data!"
    )
    
    print("Built packet:")
    pkt.show()
    
    # Stack with IP
    ip_pkt = IP(src="192.168.1.100", dst="192.168.1.1", proto=252) / pkt
    print("\nStacked with IP:")
    ip_pkt.show()
    
    # Dissect from raw bytes
    raw = bytes(ip_pkt)
    dissected = IP(raw)
    print("\nDissected packet:")
    print(f"  {dissected.summary()}")
    if dissected.haslayer(MyProtocol):
        print(f"  Custom protocol found: {dissected[MyProtocol].mysummary()}")
    if dissected.haslayer(MyData):
        print(f"  Custom data: {dissected[MyData].mysummary()}")

if __name__ == "__main__":
    demonstrate()
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Custom protocol is built and displayed
- [ ] Dissection works correctly

**❓ Questions:**

1. What fields does MyProtocol contain?
   ```
   Answer: ______________________________________________________
   ```

2. What is the protocol number used for binding?
   ```
   Answer: ______________________________________________________
   ```

---

### Lab Exercise 6.2: High-Performance Capture

**💻 Create `src/high_performance.py`**

```python
#!/usr/bin/env python3
"""
Module 6 Lab: High-Performance Capture
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP
import threading
import queue
import time
from collections import defaultdict

class HighPerformanceCapture:
    def __init__(self, interface=None, buffer_size=10000, workers=4):
        self.interface = interface
        self.buffer_size = buffer_size
        self.workers = workers
        self.packet_queue = queue.Queue(maxsize=buffer_size)
        self.running = False
        self.stats = {
            'captured': 0,
            'processed': 0,
            'dropped': 0
        }
        self.protocol_counts = defaultdict(int)
        self.lock = threading.Lock()
    
    def packet_callback(self, packet):
        """Callback for captured packets."""
        try:
            self.packet_queue.put_nowait(packet)
            self.stats['captured'] += 1
        except queue.Full:
            self.stats['dropped'] += 1
    
    def worker(self):
        """Worker thread."""
        while self.running:
            try:
                packet = self.packet_queue.get(timeout=0.5)
                self.process_packet(packet)
                self.packet_queue.task_done()
                with self.lock:
                    self.stats['processed'] += 1
            except queue.Empty:
                continue
    
    def process_packet(self, packet):
        """Process a single packet."""
        if packet.haslayer(TCP):
            self.protocol_counts['TCP'] += 1
        elif packet.haslayer(UDP):
            self.protocol_counts['UDP'] += 1
        elif packet.haslayer(ICMP):
            self.protocol_counts['ICMP'] += 1
        elif packet.haslayer(IP):
            self.protocol_counts['Other IP'] += 1
        else:
            self.protocol_counts['Other'] += 1
    
    def start(self, count=None, timeout=None):
        """Start capture."""
        print("\n" + "=" * 60)
        print("HIGH-PERFORMANCE CAPTURE")
        print("=" * 60)
        print(f"Workers: {self.workers}")
        print(f"Buffer: {self.buffer_size}")
        print("Press Ctrl+C to stop")
        print("-" * 40)
        
        self.running = True
        
        # Start workers
        threads = []
        for _ in range(self.workers):
            t = threading.Thread(target=self.worker)
            t.daemon = True
            t.start()
            threads.append(t)
        
        start_time = time.time()
        
        try:
            sniff(iface=self.interface,
                  prn=self.packet_callback,
                  count=count,
                  timeout=timeout,
                  store=False)
        except KeyboardInterrupt:
            print("\n\nStopping...")
        finally:
            self.running = False
            elapsed = time.time() - start_time
            self.display_stats(elapsed)
    
    def display_stats(self, elapsed):
        """Display statistics."""
        print("\n" + "=" * 60)
        print("CAPTURE STATISTICS")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Captured: {self.stats['captured']}")
        print(f"Processed: {self.stats['processed']}")
        print(f"Dropped: {self.stats['dropped']}")
        print(f"Rate: {self.stats['captured'] / max(1, elapsed):.1f} pkts/s")
        
        print("\nProtocol Distribution:")
        print("-" * 40)
        total = sum(self.protocol_counts.values())
        for proto, count in sorted(self.protocol_counts.items(), key=lambda x: x[1], reverse=True):
            pct = (count / max(1, total)) * 100
            print(f"  {proto}: {count} ({pct:.1f}%)")

if __name__ == "__main__":
    from scapy.all import conf, get_if_list
    
    interfaces = get_if_list()
    print("Available interfaces:")
    for i, iface in enumerate(interfaces):
        print(f"  {i+1}. {iface}")
    
    choice = input("Select interface number: ").strip()
    if choice:
        try:
            idx = int(choice) - 1
            interface = interfaces[idx]
        except:
            interface = conf.iface
    else:
        interface = conf.iface
    
    workers = input("Number of workers (default: 4): ").strip()
    workers = int(workers) if workers else 4
    
    capture = HighPerformanceCapture(interface=interface, workers=workers)
    capture.start(count=100)
```

**✅ Verification:**

- [ ] Script runs without errors
- [ ] Packets are captured and processed
- [ ] Statistics are displayed

**❓ Questions:**

1. How many packets were captured?
   ```
   Answer: ______________________________________________________
   ```

2. What was the packet processing rate?
   ```
   Answer: ______________________________________________________
   ```

---

### Code Challenges

**🏆 Try these challenges on your own.**

**Challenge 1: Async Packet Processor**

```python
# Write an async packet processor using asyncio
# Process packets in parallel batches

# Your code here:
```

**Challenge 2: Protocol Fuzzer**

```python
# Write a fuzzer for your custom protocol
# Generate malformed packets and test dissection

# Your code here:
```

**Challenge 3: Complete Toolkit**

```python
# Build a complete network toolkit
# Integrate: scanning, sniffing, analysis, custom protocols

# Your code here:
```

---

### Self-Assessment Questions

**❓ Answer these questions without looking at the course material.**

1. What is the producer-consumer pattern?
   ```
   Answer: ______________________________________________________
   ```

2. How do you create a custom protocol in Scapy?
   ```
   Answer: ______________________________________________________
   ```

3. What is protocol binding?
   ```
   Answer: ______________________________________________________
   ```

4. What are the benefits of asynchronous processing?
   ```
   Answer: ______________________________________________________
   ```

5. What is protocol fuzzing?
   ```
   Answer: ______________________________________________________
   ```

---

## Capstone Project: Network Security Toolkit

---

### Project Overview

**Objective:** Build a complete Network Security Toolkit that integrates all the tools and techniques learned throughout the series.

**Requirements:**
- Command-line interface
- Modular design
- Plugin architecture
- Configuration management
- Logging and reporting

### Project Checklist

- [ ] **Discovery Module**
  - [ ] ARP scanner
  - [ ] Ping utility
  - [ ] Traceroute
  - [ ] Port scanner (SYN and Connect)

- [ ] **Analysis Module**
  - [ ] PCAP reader
  - [ ] Protocol dissector
  - [ ] Custom protocol parser
  - [ ] Statistics generation

- [ ] **Monitoring Module**
  - [ ] Live sniffer
  - [ ] BPF filtering
  - [ ] Flow reassembly
  - [ ] Anomaly detection

- [ ] **Export Module**
  - [ ] JSON export
  - [ ] CSV export
  - [ ] PCAP export
  - [ ] Report generation

### Project Template

```python
#!/usr/bin/env python3
"""
Network Security Toolkit (NSTool)

A comprehensive network analysis and security toolkit.
"""

import argparse
import sys
import logging
from datetime import datetime

class NSTool:
    def __init__(self):
        self.config = {}
        self.logger = self.setup_logging()
    
    def setup_logging(self):
        """Setup logging configuration."""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        return logging.getLogger(__name__)
    
    def run_discovery(self, args):
        """Run discovery module."""
        # Implement discovery
        pass
    
    def run_analysis(self, args):
        """Run analysis module."""
        # Implement analysis
        pass
    
    def run_monitoring(self, args):
        """Run monitoring module."""
        # Implement monitoring
        pass
    
    def main(self):
        """Main entry point."""
        parser = argparse.ArgumentParser(description='Network Security Toolkit')
        subparsers = parser.add_subparsers(dest='command', help='Command to run')
        
        # Discovery commands
        discovery_parser = subparsers.add_parser('scan', help='Network discovery')
        discovery_parser.add_argument('target', help='Target IP or network')
        discovery_parser.add_argument('-p', '--ports', help='Port range')
        discovery_parser.add_argument('-t', '--type', choices=['arp', 'syn', 'connect', 'udp'],
                                       default='arp', help='Scan type')
        
        # Analysis commands
        analysis_parser = subparsers.add_parser('analyze', help='PCAP analysis')
        analysis_parser.add_argument('pcap_file', help='PCAP file to analyze')
        analysis_parser.add_argument('-e', '--export', help='Export to file')
        
        # Monitoring commands
        monitor_parser = subparsers.add_parser('sniff', help='Live monitoring')
        monitor_parser.add_argument('-i', '--interface', help='Network interface')
        monitor_parser.add_argument('-f', '--filter', help='BPF filter')
        monitor_parser.add_argument('-c', '--count', type=int, default=0,
                                    help='Number of packets')
        
        args = parser.parse_args()
        
        if args.command == 'scan':
            self.run_discovery(args)
        elif args.command == 'analyze':
            self.run_analysis(args)
        elif args.command == 'sniff':
            self.run_monitoring(args)
        else:
            parser.print_help()

if __name__ == "__main__":
    tool = NSTool()
    tool.main()
```

---

## Answer Key

---

### Module 1 Self-Assessment Answers

1. **What is the purpose of the `/` operator in Scapy?**
   - The `/` operator stacks protocol layers, building packets from outside to inside (Ethernet -> IP -> TCP -> Data).

2. **How do you access the source IP address of a packet?**
   - `packet[IP].src` or `packet.getlayer(IP).src`

3. **What is the difference between `rdpcap()` and `PcapReader()`?**
   - `rdpcap()` loads the entire PCAP into memory; `PcapReader()` streams packets one at a time (memory efficient).

4. **Why do you need root/sudo privileges to send packets?**
   - Scapy uses raw sockets which require root privileges to bypass the normal networking stack.

5. **How do you save packets to a PCAP file?**
   - `wrpcap("filename.pcap", packets)`

---

### Module 2 Self-Assessment Answers

1. **What is the purpose of the TTL field in IP packets?**
   - TTL (Time To Live) prevents packets from looping indefinitely by limiting the number of hops.

2. **How does ARP resolve IP addresses to MAC addresses?**
   - ARP broadcasts a request "Who has IP X?" and the owner replies with their MAC address.

3. **What is the difference between VLAN and Q-in-Q?**
   - VLAN uses a single 802.1Q tag; Q-in-Q uses double tagging (provider VLAN + customer VLAN).

4. **How does traceroute discover the path to a destination?**
   - Traceroute sends packets with incrementing TTL values; each hop returns ICMP Time Exceeded.

5. **What is the DF flag in IP packets?**
   - DF (Don't Fragment) prevents fragmentation; packets exceeding MTU are dropped.

---

### Module 3 Self-Assessment Answers

1. **What is the TCP three-way handshake?**
   - SYN -> SYN-ACK -> ACK establishes a TCP connection.

2. **What is the difference between SYN and Connect scans?**
   - SYN scan sends SYN and replies with RST (half-open); Connect scan completes the full handshake.

3. **Why is UDP scanning difficult?**
   - UDP is stateless; no response doesn't mean closed (could be filtered); ICMP unreachable indicates closed.

4. **What is banner grabbing used for?**
   - Identifying service versions to assess vulnerabilities and prioritize targets.

5. **What are the advantages of multi-threaded scanning?**
   - Increased speed, parallel processing, faster results.

---

### Module 4 Self-Assessment Answers

1. **What is the purpose of BPF filters?**
   - BPF filters reduce captured packet volume by filtering at the kernel level.

2. **How do you capture packets with Scapy?**
   - `sniff(iface="eth0", filter="tcp", prn=callback, count=10)`

3. **What is flow tracking?**
   - Tracking conversations between hosts (5-tuple: src IP, dst IP, src port, dst port, protocol).

4. **What can you learn from HTTP headers?**
   - User agents, referrers, accepted content types, cookies, and more.

5. **Why is DNS monitoring important for security?**
   - DNS can reveal malware communication, data exfiltration, and command-and-control traffic.

---

### Module 5 Self-Assessment Answers

1. **What is ARP spoofing and how can it be detected?**
   - ARP spoofing sends forged replies; detection: MAC changes, duplicate IPs, high ARP rates.

2. **What safety controls should be used for packet injection?**
   - Authorization, rate limiting, target validation, logging, confirmation.

3. **What is packet replay used for?**
   - Testing network security, reproducing traffic, performance testing.

4. **How can you detect rogue DHCP servers?**
   - Track DHCP offers, compare with authorized servers, alert on unknown sources.

5. **What is responsible disclosure?**
   - Reporting vulnerabilities privately to the vendor before public disclosure.

---

### Module 6 Self-Assessment Answers

1. **What is the producer-consumer pattern?**
   - Separates data production (capture) from data consumption (processing) using a queue.

2. **How do you create a custom protocol in Scapy?**
   - Create a class inheriting from Packet, define `fields_desc`, and bind to a parent protocol.

3. **What is protocol binding?**
   - Tells Scapy which protocol follows which, enabling automatic dissection.

4. **What are the benefits of asynchronous processing?**
   - Non-blocking operations, concurrent processing, efficient resource usage.

5. **What is protocol fuzzing?**
   - Testing protocol robustness by sending malformed or unexpected data.

---

## Workbook Completion Checklist

- [ ] **Module 1:** All labs completed, self-assessment answered
- [ ] **Module 2:** All labs completed, self-assessment answered
- [ ] **Module 3:** All labs completed, self-assessment answered
- [ ] **Module 4:** All labs completed, self-assessment answered
- [ ] **Module 5:** All labs completed, self-assessment answered
- [ ] **Module 6:** All labs completed, self-assessment answered
- [ ] **Capstone Project:** Complete toolkit implemented
- [ ] **All code challenges:** Attempted (or completed)

---

**Congratulations on completing this workbook!** You now have a comprehensive record of your learning journey through packet crafting with Scapy.
