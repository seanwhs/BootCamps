# Complete Lab Book

## Demystifying Network Protocols: From Ethernet Frames to HTTP/3

### Practical Exercises for Every Protocol and Concept

---

## Overview

This lab book contains step-by-step practical exercises for every protocol and concept covered in the "Demystifying Network Protocols" tutorial series. Each lab includes clear objectives, prerequisites, detailed instructions, expected outputs, and reflection questions.

**Purpose:** Build practical skills through hands-on experience with real network traffic, protocol analysis, and network programming.

**How to Use This Lab Book:**
1. Read the corresponding tutorial section first
2. Set up your lab environment
3. Follow the instructions step by step
4. Record your observations
5. Answer the reflection questions
6. Complete the challenges for extra practice

**Prerequisites:**
- Linux/macOS/Windows with WSL2
- Python 3.8+ with pip
- Wireshark installed
- Root/sudo access for packet capture
- Network connection (WiFi or Ethernet)

---

## Lab 1.1: Physical Layer - Cable Testing

**Objective:** Learn to test and terminate network cables.

**Duration:** 30 minutes

**Prerequisites:** Cat5e/Cat6 cable, RJ45 connectors, crimping tool, cable tester

### Step-by-Step Instructions

1. **Strip the cable jacket**
   - Remove approximately 2 inches of outer jacket
   - Be careful not to cut into individual wire insulation

2. **Untwist and arrange wires (T568B standard)**
   ```
   From left to right:
   1. White/Orange
   2. Orange
   3. White/Green
   4. Blue
   5. White/Blue
   6. Green
   7. White/Brown
   8. Brown
   ```

3. **Trim wires to 1/2 inch length**
   - Ensure all wires are straight and in correct order

4. **Insert wires into RJ45 connector**
   - Ensure wires reach the end of the connector
   - Verify order before crimping

5. **Crimp the connector**
   - Apply firm, even pressure with crimping tool

6. **Test the cable**
   - Connect to cable tester
   - Verify continuity on all 8 pins

### Expected Output
```
Cable Tester Results:
Pin 1: Pass
Pin 2: Pass
Pin 3: Pass
Pin 4: Pass
Pin 5: Pass
Pin 6: Pass
Pin 7: Pass
Pin 8: Pass
```

### Reflection Questions
1. What happens if two wires are swapped?
2. Why is the T568B standard important?
3. What is the maximum length for a Cat5e cable?

---

## Lab 1.2: Network Interface Card Configuration

**Objective:** Configure and test network interface settings.

**Duration:** 30 minutes

**Prerequisites:** Administrative access to your system

### Step-by-Step Instructions

1. **View current interface settings**

   **Linux:**
   ```bash
   ip link show
   ethtool eth0
   ```

   **macOS:**
   ```bash
   ifconfig en0
   ```

   **Windows:**
   ```powershell
   ipconfig /all
   Get-NetAdapter
   ```

2. **Check link status**

   **Linux:**
   ```bash
   ethtool eth0 | grep -E "Link detected|Speed|Duplex"
   cat /sys/class/net/eth0/operstate
   ```

   **Windows:**
   ```powershell
   Get-NetAdapter -Name "Ethernet" | Select-Object LinkSpeed
   ```

3. **Change interface settings**

   **Linux:**
   ```bash
   # Set speed and duplex
   sudo ethtool -s eth0 speed 1000 duplex full autoneg on
   ```

4. **Test connectivity**
   ```bash
   ping -c 4 192.168.1.1
   ping -c 4 -s 1472 192.168.1.1  # Verify MTU works
   ```

5. **Check for errors**
   ```bash
   ip -s link show eth0
   ```

### Lab Worksheet

| Field | Value |
|-------|-------|
| Interface Name | |
| MAC Address | |
| Speed | |
| Duplex | |
| Link Status | |
| MTU | |

### Reflection Questions
1. What does full duplex mean?
2. How do you determine the correct MTU size?
3. What causes interface errors?

---

## Lab 1.3: Ethernet Frame Analysis

**Objective:** Capture and analyze Ethernet frames.

**Duration:** 30 minutes

**Prerequisites:** Wireshark installed

### Step-by-Step Instructions

1. **Launch Wireshark**
   ```bash
   wireshark
   ```

2. **Select the correct network interface**
   - Linux: eth0 or wlan0
   - macOS: en0 or en1
   - Windows: Ethernet or Wi-Fi

3. **Start capturing**
   - Click the shark fin icon
   - Or use: `sudo tcpdump -i eth0 -w eth_frames.pcap -c 20`

4. **Generate traffic**
   ```bash
   curl -I https://www.google.com
   ping -c 4 192.168.1.1
   ```

5. **Apply display filter**: `eth`

6. **Select a frame and examine Ethernet header**

### Frame Analysis Worksheet

Select an Ethernet frame and record:

| Field | Value |
|-------|-------|
| Frame Number | |
| Destination MAC | |
| Source MAC | |
| EtherType | |
| Frame Length | |
| Payload Length | |
| Broadcast/Unicast/Multicast? | |

### Expected Wireshark Output

```
Frame 1: 74 bytes on wire (592 bits)
Ethernet II, Src: aa:bb:cc:dd:ee:ff, Dst: 00:11:22:33:44:55
    Destination: 00:11:22:33:44:55 (Cisco_33:44:55)
    Source: aa:bb:cc:dd:ee:ff (Intel_ee:ff:aa)
    Type: IPv4 (0x0800)
```

### Reflection Questions
1. Why is the minimum frame size 64 bytes?
2. What is the purpose of the FCS field?
3. How does EtherType differ from a length field?

---

## Lab 1.4: ARP Exchange Analysis

**Objective:** Capture and analyze ARP request/reply.

**Duration:** 30 minutes

**Prerequisites:** tcpdump installed, root access

### Step-by-Step Instructions

1. **Clear ARP cache**
   ```bash
   # Linux
   sudo ip neigh flush all

   # macOS
   sudo arp -d -a

   # Windows (Admin)
   arp -d *
   ```

2. **Start ARP capture**
   ```bash
   sudo tcpdump -i eth0 arp -w arp_capture.pcap
   ```

3. **Generate ARP traffic**
   ```bash
   ping -c 1 192.168.1.1
   ```

4. **Stop tcpdump** (Ctrl+C)

5. **Analyze the capture**
   ```bash
   # Show all ARP packets
   tshark -r arp_capture.pcap -Y "arp"

   # Show ARP requests
   tshark -r arp_capture.pcap -Y "arp.opcode == 1"

   # Show ARP replies
   tshark -r arp_capture.pcap -Y "arp.opcode == 2"

   # Detailed ARP information
   tshark -r arp_capture.pcap -Y "arp" -V
   ```

### ARP Analysis Worksheet

| Field | ARP Request | ARP Reply |
|-------|-------------|-----------|
| Source MAC | | |
| Destination MAC | | |
| Sender IP | | |
| Target IP | | |
| Hardware Type | | |
| Protocol Type | | |
| Opcode | | |

### Expected Output
```
Address Resolution Protocol (request)
    Hardware type: Ethernet (1)
    Protocol type: IPv4 (0x0800)
    Operation: request (1)
    Sender IP address: 192.168.1.10
    Target IP address: 192.168.1.1

Address Resolution Protocol (reply)
    Hardware type: Ethernet (1)
    Protocol type: IPv4 (0x0800)
    Operation: reply (2)
    Sender IP address: 192.168.1.1
    Target IP address: 192.168.1.10
```

### Reflection Questions
1. Why is ARP request broadcast and ARP reply unicast?
2. What happens if no ARP reply is received?
3. How can you prevent ARP spoofing?

---

## Lab 1.5: DHCP DORA Sequence

**Objective:** Capture and analyze DHCP DORA process.

**Duration:** 30 minutes

**Prerequisites:** root access, dhclient installed

### Step-by-Step Instructions

1. **Release DHCP lease**
   ```bash
   # Linux
   sudo dhclient -r eth0

   # macOS
   sudo ipconfig set en0 NONE

   # Windows (Admin)
   ipconfig /release
   ```

2. **Start DHCP capture**
   ```bash
   sudo tcpdump -i eth0 "udp and (port 67 or port 68)" -w dhcp_capture.pcap
   ```

3. **Request new lease**
   ```bash
   # Linux
   sudo dhclient eth0

   # macOS
   sudo ipconfig set en0 DHCP

   # Windows (Admin)
   ipconfig /renew
   ```

4. **Stop tcpdump** (Ctrl+C)

5. **Analyze the capture**
   ```bash
   # Show DHCP message types
   tshark -r dhcp_capture.pcap -Y "dhcp" -T fields \
       -e frame.time_relative -e dhcp.msgtype -e ip.src -e ip.dst

   # Show DHCP options
   tshark -r dhcp_capture.pcap -Y "dhcp" -V | grep -A 20 "Options"
   ```

### DHCP DORA Worksheet

| Message | Direction | Time | Key Options |
|---------|-----------|------|-------------|
| Discover | → | | |
| Offer | ← | | |
| Request | → | | |
| ACK | ← | | |

### Expected Output
```
BootP/DHCP Message (DHCPDISCOVER)
    Message type: 1 (DHCPDISCOVER)
    Client MAC: 00:1A:2B:3C:4D:5E

BootP/DHCP Message (DHCPOFFER)
    Message type: 2 (DHCPOFFER)
    Offered IP: 192.168.1.10
    Server IP: 192.168.1.1

BootP/DHCP Message (DHCPREQUEST)
    Message type: 3 (DHCPREQUEST)
    Requested IP: 192.168.1.10
    Server IP: 192.168.1.1

BootP/DHCP Message (DHCPACK)
    Message type: 5 (DHCPACK)
    Your IP: 192.168.1.10
    Lease Time: 86400 seconds
```

### Reflection Questions
1. Why are Discover and Request messages broadcast?
2. What happens if multiple DHCP servers respond?
3. What is the purpose of the lease time?

---

## Lab 1.6: Ethernet Frame Decoder

**Objective:** Build an Ethernet frame decoder in Python.

**Duration:** 45 minutes

**Prerequisites:** Python 3.8+, scapy installed

### Step-by-Step Instructions

1. **Install required packages**
   ```bash
   pip install scapy
   ```

2. **Create Ethernet decoder script**

   ```python
   #!/usr/bin/env python3
   """
   ethernet_decoder.py - Complete Ethernet frame decoder
   """

   import sys
   import struct
   from typing import Dict, Optional
   from scapy.all import sniff, Ether

   class EthernetDecoder:
       """Decodes Ethernet frames and displays fields"""

       def __init__(self):
           self.packet_count = 0
           self.ethertypes = {}

       def decode_frame(self, packet) -> Optional[Dict]:
           """Decode a single Ethernet frame"""
           if not isinstance(packet, Ether):
               return None

           # Extract Ethernet fields
           dst_mac = packet.dst
           src_mac = packet.src
           eth_type = packet.type

           # Get EtherType name
           ethertype_names = {
               0x0800: 'IPv4',
               0x0806: 'ARP',
               0x86DD: 'IPv6',
               0x8100: 'VLAN (802.1Q)',
               0x88CC: 'LLDP'
           }
           eth_type_name = ethertype_names.get(eth_type, f'Unknown (0x{eth_type:04X})')

           # Update statistics
           self.ethertypes[eth_type_name] = self.ethertypes.get(eth_type_name, 0) + 1

           return {
               'dst_mac': dst_mac,
               'src_mac': src_mac,
               'eth_type': eth_type,
               'eth_type_name': eth_type_name,
               'payload_len': len(packet.payload)
           }

       def display_packet(self, num: int, frame: Dict):
           """Display frame information"""
           print(f"\nFrame #{num}:")
           print(f"  Source MAC: {frame['src_mac']}")
           print(f"  Destination MAC: {frame['dst_mac']}")
           print(f"  EtherType: {frame['eth_type_name']}")
           print(f"  Payload Length: {frame['payload_len']} bytes")

           # Determine frame type
           if frame['dst_mac'] == 'ff:ff:ff:ff:ff:ff':
               print("  Frame Type: Broadcast")
           elif frame['dst_mac'][0] in ['01', '33']:
               print("  Frame Type: Multicast")
           else:
               print("  Frame Type: Unicast")

       def display_statistics(self):
           """Display protocol statistics"""
           print("\n" + "=" * 40)
           print("Protocol Statistics:")
           print("=" * 40)
           for protocol, count in sorted(self.ethertypes.items(),
                                        key=lambda x: x[1], reverse=True):
               print(f"  {protocol}: {count}")

       def packet_callback(self, packet):
           """Callback for sniffing"""
           frame = self.decode_frame(packet)
           if frame:
               self.packet_count += 1
               self.display_packet(self.packet_count, frame)

       def run(self, interface: str = None, count: int = 10):
           """Start the decoder"""
           print(f"Starting Ethernet Frame Decoder...")
           print(f"Capturing {count} frames...")
           print("=" * 40)

           try:
               sniff(iface=interface, count=count,
                     prn=self.packet_callback, store=False)
           except PermissionError:
               print("Error: Root privileges required")
               sys.exit(1)
           except KeyboardInterrupt:
               print("\nCapture interrupted")
           finally:
               self.display_statistics()

   if __name__ == "__main__":
       import argparse

       parser = argparse.ArgumentParser(
           description="Ethernet Frame Decoder"
       )
       parser.add_argument('-i', '--interface',
                          help='Network interface')
       parser.add_argument('-c', '--count', type=int, default=10,
                          help='Number of frames to capture')

       args = parser.parse_args()

       decoder = EthernetDecoder()
       decoder.run(args.interface, args.count)
   ```

3. **Run the decoder**
   ```bash
   sudo python3 ethernet_decoder.py -i eth0 -c 10
   ```

### Expected Output
```
Starting Ethernet Frame Decoder...
Capturing 10 frames...
========================================

Frame #1:
  Source MAC: aa:bb:cc:dd:ee:ff
  Destination MAC: 00:11:22:33:44:55
  EtherType: IPv4
  Payload Length: 60 bytes
  Frame Type: Unicast

========================================
Protocol Statistics:
========================================
  IPv4: 8
  ARP: 2
```

### Challenge
1. Add support for VLAN tags
2. Implement a filter to capture only specific EtherTypes
3. Add support for decoding IP headers

---

## Lab 2.1: IPv4 Header Analysis

**Objective:** Capture and analyze IPv4 headers.

**Duration:** 30 minutes

**Prerequisites:** tcpdump, tshark installed

### Step-by-Step Instructions

1. **Start packet capture**
   ```bash
   sudo tcpdump -i eth0 -w ipv4_capture.pcap -c 20
   ```

2. **Generate IPv4 traffic**
   ```bash
   curl -I https://www.google.com
   curl -I https://www.github.com
   ```

3. **Analyze IPv4 headers**
   ```bash
   tshark -r ipv4_capture.pcap -Y "ip" -T fields \
       -e frame.time_relative \
       -e ip.src \
       -e ip.dst \
       -e ip.ttl \
       -e ip.proto \
       -e ip.len \
       -e ip.flags \
       -e ip.frag_offset
   ```

### IPv4 Header Worksheet

Select one IPv4 packet and record:

| Field | Value |
|-------|-------|
| Source IP | |
| Destination IP | |
| Version | |
| Header Length | |
| Total Length | |
| TTL | |
| Protocol | |
| Identification | |
| DF Flag | |
| MF Flag | |

### Expected Output
```
IPv4 Header Analysis:
Source: 192.168.1.10
Destination: 142.250.185.46
Version: 4
Header Length: 20 bytes
Total Length: 92 bytes
TTL: 64
Protocol: 6 (TCP)
DF Flag: Set
MF Flag: Not Set
```

### Reflection Questions
1. What is the purpose of the TTL field?
2. How is fragmentation indicated in the header?
3. What does the Protocol field identify?

---

## Lab 2.2: Subnet Calculation Practice

**Objective:** Master subnet calculations using Python.

**Duration:** 30 minutes

**Prerequisites:** Python 3.8+

### Step-by-Step Instructions

1. **Create subnet calculator script**

   ```python
   #!/usr/bin/env python3
   """
   subnet_calc.py - Interactive subnet calculator
   """

   import ipaddress

   def calculate_subnet(cidr):
       """Calculate and display subnet details"""
       try:
           network = ipaddress.ip_network(cidr, strict=False)
       except ValueError as e:
           print(f"Error: {e}")
           return

       print(f"\n{'='*50}")
       print(f"Network: {cidr}")
       print(f"{'='*50}")
       print(f"Network Address: {network.network_address}")
       print(f"Broadcast Address: {network.broadcast_address}")
       print(f"Subnet Mask: {network.netmask}")
       print(f"Prefix Length: /{network.prefixlen}")
       print(f"Total Addresses: {network.num_addresses}")
       print(f"Usable Hosts: {network.num_addresses - 2}")
       print(f"Host Range: {list(network.hosts())[0]} - {list(network.hosts())[-1]}")

       # Show binary representation
       ip_bin = ''.join([f"{int(octet):08b}." for octet in
                         str(network.network_address).split('.')])
       mask_bin = ''.join([f"{int(octet):08b}." for octet in
                           str(network.netmask).split('.')])
       print(f"\nBinary Network: {ip_bin[:-1]}")
       print(f"Binary Mask: {mask_bin[:-1]}")

   def main():
       print("Subnet Calculator")
       print("=" * 50)

       while True:
           cidr = input("\nEnter CIDR (or 'quit'): ")
           if cidr.lower() == 'quit':
               break
           calculate_subnet(cidr)

   if __name__ == "__main__":
       main()
   ```

2. **Run the calculator**
   ```bash
   python3 subnet_calc.py
   ```

3. **Practice calculations**

   **Exercise 1:**
   ```
   Enter CIDR: 192.168.1.0/24
   ```

   **Exercise 2:**
   ```
   Enter CIDR: 10.0.0.0/16
   ```

   **Exercise 3:**
   ```
   Enter CIDR: 172.16.0.0/12
   ```

   **Exercise 4:**
   ```
   Enter CIDR: 192.168.1.128/26
   ```

### Practice Problems

1. Divide 192.168.0.0/24 into 4 equal subnets
   - What is the new subnet mask?
   - List all network addresses
   - List the host range for subnet 1

2. Calculate the subnet for 10.0.0.1/19
   - Network address: ____________
   - Broadcast address: ____________
   - Netmask: ____________
   - Number of hosts: ____________

3. Find the broadcast address for 172.16.10.0/22
   - Broadcast address: ____________

### Reflection Questions
1. Why is subnetting important?
2. How does VLSM improve address utilization?
3. What happens if two hosts have the same IP address?

---

## Lab 2.3: Traceroute Analysis

**Objective:** Map network paths using traceroute.

**Duration:** 30 minutes

**Prerequisites:** traceroute installed

### Step-by-Step Instructions

1. **Trace to various destinations**
   ```bash
   traceroute -n 8.8.8.8
   traceroute -n 1.1.1.1
   traceroute -n google.com
   ```

2. **Trace using different methods**
   ```bash
   # ICMP traceroute
   traceroute -I 8.8.8.8

   # TCP SYN traceroute
   traceroute -T -p 80 8.8.8.8

   # UDP traceroute (default)
   traceroute -n 8.8.8.8
   ```

3. **Capture traceroute traffic**
   ```bash
   sudo tcpdump -i eth0 "icmp and (icmp[icmptype] == 11 or icmp[icmptype] == 3)" \
       -w traceroute.pcap
   ```

   Then run traceroute in another terminal:
   ```bash
   traceroute -n 8.8.8.8
   ```

4. **Analyze captured traceroute**
   ```bash
   tshark -r traceroute.pcap -Y "icmp.type == 11" -T fields \
       -e frame.time_relative -e ip.src -e ip.dst
   ```

### Traceroute Worksheet

Trace to 8.8.8.8:

| Hop | IP Address | Latency (ms) | Hostname |
|-----|------------|--------------|----------|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |
| 6 | | | |
| 7 | | | |
| 8 | | | |
| 9 | | | |
| 10 | | | |

### Expected Output
```
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max
 1  192.168.1.1  0.523 ms  0.456 ms  0.398 ms
 2  10.0.0.1  2.123 ms  2.456 ms  2.567 ms
 3  172.16.1.1  5.789 ms  5.890 ms  6.123 ms
 4  203.0.113.1  8.456 ms  8.567 ms  8.678 ms
 5  203.0.113.254  10.123 ms  10.234 ms  10.345 ms
 6  8.8.8.8  12.456 ms  12.567 ms  12.678 ms
```

### Reflection Questions
1. How does traceroute work?
2. Why do some hops show "* * *"?
3. What network issues can traceroute reveal?

---

## Lab 3.1: TCP Three-Way Handshake

**Objective:** Capture and analyze TCP three-way handshake.

**Duration:** 30 minutes

**Prerequisites:** tcpdump, Python 3.8+

### Step-by-Step Instructions

1. **Create TCP echo server**

   ```python
   #!/usr/bin/env python3
   """
   tcp_echo_server.py - TCP echo server
   """

   import socket
   import threading

   class TCPEchoServer:
       def __init__(self, host='', port=8080):
           self.host = host
           self.port = port

       def start(self):
           server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
           server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
           server_sock.bind((self.host, self.port))
           server_sock.listen(5)

           print(f"Server listening on port {self.port}")

           while True:
               client_sock, addr = server_sock.accept()
               thread = threading.Thread(target=self.handle_client,
                                        args=(client_sock, addr))
               thread.start()

       def handle_client(self, client_sock, addr):
           print(f"Connection from {addr}")
           try:
               while True:
                   data = client_sock.recv(4096)
                   if not data:
                       break
                   client_sock.send(data)
           finally:
               client_sock.close()
               print(f"Connection from {addr} closed")

   if __name__ == "__main__":
       server = TCPEchoServer()
       server.start()
   ```

2. **Start server in one terminal**
   ```bash
   python3 tcp_echo_server.py
   ```

3. **Start packet capture**
   ```bash
   sudo tcpdump -i eth0 "tcp port 8080" -w tcp_handshake.pcap
   ```

4. **Connect to server**
   ```bash
   python3 -c "
   import socket
   s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
   s.connect(('localhost', 8080))
   s.send(b'Hello')
   s.recv(1024)
   s.close()
   "
   ```

5. **Analyze the capture**
   ```bash
   tshark -r tcp_handshake.pcap -Y "tcp.flags.syn == 1 or tcp.flags.ack == 1" \
       -T fields -e frame.time_relative -e ip.src -e ip.dst -e tcp.flags -e tcp.seq -e tcp.ack
   ```

### TCP Handshake Worksheet

| Packet | Time | Direction | Flags | Seq | Ack |
|--------|------|-----------|-------|-----|-----|
| 1 | | → | | | |
| 2 | | ← | | | |
| 3 | | → | | | |

### Expected Output
```
Frame Time: 0.000000  Src: 192.168.1.10:54321  Dst: 192.168.1.1:8080  Flags: SYN  Seq: 123456789
Frame Time: 0.001234  Src: 192.168.1.1:8080    Dst: 192.168.1.10:54321 Flags: SYN-ACK Seq: 987654321 Ack: 123456790
Frame Time: 0.001456  Src: 192.168.1.10:54321  Dst: 192.168.1.1:8080  Flags: ACK  Seq: 123456790 Ack: 987654322
```

### Reflection Questions
1. Why is the handshake called "three-way"?
2. What are the ISN values?
3. How does the handshake prevent SYN flooding attacks?

---

## Lab 3.2: TCP Echo Server

**Objective:** Build a complete TCP echo server with threading.

**Duration:** 45 minutes

**Prerequisites:** Python 3.8+

### Step-by-Step Instructions

1. **Build advanced TCP echo server**

   ```python
   #!/usr/bin/env python3
   """
   tcp_echo_server_advanced.py - Advanced TCP echo server
   """

   import socket
   import threading
   import time
   import logging
   from datetime import datetime

   logging.basicConfig(level=logging.INFO,
                       format='%(asctime)s - %(levelname)s - %(message)s')
   logger = logging.getLogger(__name__)

   class TCPEchoServer:
       def __init__(self, host='', port=8080, max_workers=10):
           self.host = host
           self.port = port
           self.max_workers = max_workers
           self.server_socket = None
           self.running = False
           self.stats = {
               'bytes_received': 0,
               'bytes_sent': 0,
               'connections': 0,
               'errors': 0
           }
           self.lock = threading.Lock()

       def start(self):
           try:
               self.server_socket = socket.socket(socket.AF_INET,
                                                  socket.SOCK_STREAM)
               self.server_socket.setsockopt(socket.SOL_SOCKET,
                                             socket.SO_REUSEADDR, 1)
               self.server_socket.bind((self.host, self.port))
               self.server_socket.listen(100)
               self.running = True

               logger.info(f"Server listening on port {self.port}")

               while self.running:
                   try:
                       client_sock, addr = self.server_socket.accept()
                       client_sock.settimeout(30.0)
                       with self.lock:
                           self.stats['connections'] += 1
                       thread = threading.Thread(target=self.handle_client,
                                                args=(client_sock, addr))
                       thread.start()
                   except socket.timeout:
                       continue
                   except socket.error as e:
                       if self.running:
                           logger.error(f"Accept error: {e}")

           except Exception as e:
               logger.error(f"Server error: {e}")
           finally:
               self.shutdown()

       def handle_client(self, client_sock, addr):
           client_id = f"{addr[0]}:{addr[1]}"
           logger.info(f"New connection from {client_id}")

           try:
               bytes_received = 0
               while self.running:
                   data = client_sock.recv(4096)
                   if not data:
                       break

                   bytes_received += len(data)
                   with self.lock:
                       self.stats['bytes_received'] += len(data)

                   # Echo back
                   client_sock.send(data)
                   with self.lock:
                       self.stats['bytes_sent'] += len(data)

           except socket.timeout:
               logger.warning(f"Timeout from {client_id}")
           except socket.error as e:
               logger.error(f"Socket error with {client_id}: {e}")
               with self.lock:
                   self.stats['errors'] += 1
           finally:
               try:
                   client_sock.close()
               except:
                   pass
               logger.info(f"Connection from {client_id} closed")

       def get_stats(self):
           with self.lock:
               return self.stats

       def shutdown(self):
           self.running = False
           if self.server_socket:
               self.server_socket.close()
           logger.info("Server shutdown complete")

   if __name__ == "__main__":
       import argparse

       parser = argparse.ArgumentParser(description="TCP Echo Server")
       parser.add_argument('-p', '--port', type=int, default=8080,
                          help='Port to listen on')
       args = parser.parse_args()

       server = TCPEchoServer(port=args.port)
       try:
           server.start()
       except KeyboardInterrupt:
           print("\n")
           logger.info("Shutting down...")
           server.shutdown()
           print(f"Statistics: {server.get_stats()}")
   ```

2. **Test the server**
   ```bash
   # Terminal 1 - Server
   python3 tcp_echo_server_advanced.py -p 8080

   # Terminal 2 - Test with netcat
   nc localhost 8080

   # Terminal 3 - Performance test
   yes "Hello" | head -100 | while read line; do
       echo "$line" | nc localhost 8080
   done
   ```

3. **Monitor statistics**
   ```bash
   # Press Ctrl+C to see statistics
   Statistics: {'bytes_received': 102400, 'bytes_sent': 102400,
                'connections': 10, 'errors': 0}
   ```

### Reflection Questions
1. Why are threads used for concurrent connections?
2. What is the purpose of the timeout?
3. How could you improve error handling?

---

## Lab 3.3: UDP Echo Server

**Objective:** Build a UDP echo server.

**Duration:** 30 minutes

**Prerequisites:** Python 3.8+

### Step-by-Step Instructions

1. **Create UDP echo server**

   ```python
   #!/usr/bin/env python3
   """
   udp_echo_server.py - UDP echo server
   """

   import socket
   import time
   import logging

   logging.basicConfig(level=logging.INFO,
                       format='%(asctime)s - %(levelname)s - %(message)s')
   logger = logging.getLogger(__name__)

   class UDPEchoServer:
       def __init__(self, host='', port=8081):
           self.host = host
           self.port = port
           self.socket = None
           self.running = False
           self.stats = {
               'bytes_received': 0,
               'bytes_sent': 0,
               'packets': 0,
               'clients': set()
           }

       def start(self):
           try:
               self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
               self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
               self.socket.bind((self.host, self.port))
               self.running = True

               logger.info(f"UDP server listening on port {self.port}")

               while self.running:
                   try:
                       data, addr = self.socket.recvfrom(4096)
                       self.stats['clients'].add(addr)
                       self.stats['packets'] += 1
                       self.stats['bytes_received'] += len(data)

                       # Echo back
                       self.socket.sendto(data, addr)
                       self.stats['bytes_sent'] += len(data)

                       logger.info(f"Echoed {len(data)} bytes from {addr[0]}:{addr[1]}")
                   except socket.error as e:
                       if self.running:
                           logger.error(f"Socket error: {e}")

           except Exception as e:
               logger.error(f"Server error: {e}")
           finally:
               self.shutdown()

       def get_stats(self):
           return self.stats

       def shutdown(self):
           self.running = False
           if self.socket:
               self.socket.close()
           logger.info("Server shutdown complete")

   if __name__ == "__main__":
       import argparse

       parser = argparse.ArgumentParser(description="UDP Echo Server")
       parser.add_argument('-p', '--port', type=int, default=8081,
                          help='Port to listen on')
       args = parser.parse_args()

       server = UDPEchoServer(port=args.port)
       try:
           server.start()
       except KeyboardInterrupt:
           print("\n")
           logger.info("Shutting down...")
           server.shutdown()
           stats = server.get_stats()
           print(f"Statistics: {stats}")
   ```

2. **Test the UDP server**
   ```bash
   # Terminal 1 - Server
   python3 udp_echo_server.py -p 8081

   # Terminal 2 - Test with Python
   python3 -c "
   import socket
   s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
   s.sendto(b'Hello', ('localhost', 8081))
   data, _ = s.recvfrom(4096)
   print(data.decode())
   s.close()
   "

   # Test with netcat
   echo "Hello" | nc -u localhost 8081
   ```

3. **Performance test**
   ```bash
   # Send multiple packets
   for i in {1..10}; do
       echo "Message $i" | nc -u localhost 8081
   done

   # View statistics
   Statistics: {'bytes_received': 1024, 'bytes_sent': 1024,
                'packets': 10, 'clients': 1}
   ```

### Reflection Questions
1. How does UDP differ from TCP?
2. Why is there no connection establishment?
3. When would you use UDP instead of TCP?

---

## Lab 3.4: Multi-Client Chat Server

**Objective:** Build a multi-client chat server.

**Duration:** 1 hour

**Prerequisites:** Python 3.8+

### Step-by-Step Instructions

1. **Build chat server**

   ```python
   #!/usr/bin/env python3
   """
   chat_server.py - Multi-client chat server
   """

   import socket
   import threading
   import logging
   import time
   from typing import Dict, Set

   logging.basicConfig(level=logging.INFO,
                       format='%(asctime)s - %(levelname)s - %(message)s')
   logger = logging.getLogger(__name__)

   class ChatServer:
       def __init__(self, host='', port=8082):
           self.host = host
           self.port = port
           self.clients: Dict[object, str] = {}
           self.rooms: Dict[str, Set[object]] = {'general': set()}
           self.lock = threading.Lock()
           self.running = False
           self.server_socket = None

       def start(self):
           try:
               self.server_socket = socket.socket(socket.AF_INET,
                                                  socket.SOCK_STREAM)
               self.server_socket.setsockopt(socket.SOL_SOCKET,
                                             socket.SO_REUSEADDR, 1)
               self.server_socket.bind((self.host, self.port))
               self.server_socket.listen(10)
               self.running = True

               logger.info(f"Chat server started on port {self.port}")
               logger.info("Commands: /help, /join <room>, /leave, /list, /quit")

               while self.running:
                   try:
                       client_sock, addr = self.server_socket.accept()
                       thread = threading.Thread(target=self.handle_client,
                                                args=(client_sock, addr))
                       thread.start()
                   except socket.error:
                       if self.running:
                           continue

           except Exception as e:
               logger.error(f"Server error: {e}")
           finally:
               self.shutdown()

       def handle_client(self, client_sock, addr):
           try:
               # Get username
               client_sock.send(b"Welcome to Chat Server!\n")
               client_sock.send(b"Enter username: ")

               username = client_sock.recv(1024).decode().strip()
               if not username:
                   client_sock.close()
                   return

               with self.lock:
                   if username in self.clients.values():
                       client_sock.send(b"Username taken. Disconnecting.\n")
                       client_sock.close()
                       return

                   self.clients[client_sock] = username
                   self.rooms['general'].add(client_sock)

               logger.info(f"{username} connected from {addr[0]}:{addr[1]}")
               self.broadcast(f"[Server] {username} joined the chat!", 'general',
                              exclude=client_sock)

               client_sock.send(f"Welcome {username}!\n".encode())
               client_sock.send(b"Commands: /help for help\n")

               # Message loop
               while self.running:
                   try:
                       data = client_sock.recv(4096)
                       if not data:
                           break

                       message = data.decode().strip()
                       if not message:
                           continue

                       # Handle commands
                       if message.startswith('/'):
                           self.handle_command(client_sock, message)
                       else:
                           room = self.get_user_room(client_sock)
                           self.broadcast(f"{username}: {message}", room,
                                         exclude=client_sock)

                   except socket.error:
                       break

           except Exception as e:
               logger.error(f"Error with {addr}: {e}")
           finally:
               self.remove_client(client_sock)
               client_sock.close()

       def handle_command(self, client_sock, command):
           """Handle chat commands"""
           parts = command.split(' ', 1)
           cmd = parts[0].lower()
           username = self.clients.get(client_sock, 'Unknown')

           if cmd == '/help':
               help_text = """
   Commands:
     /help          - Show help
     /join <room>   - Join/create a room
     /leave         - Leave current room
     /list          - List rooms and users
     /msg <user> <msg> - Private message
     /who           - List users in room
     /quit          - Disconnect
   """
               client_sock.send(help_text.encode())

           elif cmd == '/join':
               if len(parts) < 2:
                   client_sock.send(b"Usage: /join <room>\n")
                   return

               room = parts[1].strip()
               old_room = self.get_user_room(client_sock)

               if old_room:
                   with self.lock:
                       if client_sock in self.rooms.get(old_room, set()):
                           self.rooms[old_room].remove(client_sock)

               with self.lock:
                   if room not in self.rooms:
                       self.rooms[room] = set()
                   self.rooms[room].add(client_sock)

               client_sock.send(f"Joined room: {room}\n".encode())
               self.broadcast(f"[Server] {username} joined the room", room,
                             exclude=client_sock)

           elif cmd == '/leave':
               room = self.get_user_room(client_sock)
               if room and room != 'general':
                   with self.lock:
                       if client_sock in self.rooms.get(room, set()):
                           self.rooms[room].remove(client_sock)
                       self.rooms['general'].add(client_sock)

                   client_sock.send(f"Left {room}, joined general\n".encode())
                   self.broadcast(f"[Server] {username} left the room", room,
                                 exclude=client_sock)
               else:
                   client_sock.send(b"Already in general room\n")

           elif cmd == '/list':
               response = "\nRooms and users:\n"
               with self.lock:
                   for room, users in self.rooms.items():
                       if users:
                           user_list = [self.clients.get(s, 'Unknown')
                                      for s in users]
                           response += f"  {room}: {len(users)} users - {', '.join(user_list)}\n"
                       else:
                           response += f"  {room}: empty\n"
                   response += f"\nTotal users: {len(self.clients)}\n"

               client_sock.send(response.encode())

           elif cmd == '/who':
               room = self.get_user_room(client_sock)
               if room:
                   with self.lock:
                       users = [self.clients.get(s, 'Unknown')
                               for s in self.rooms.get(room, set())]
                       response = f"Users in {room}: {', '.join(users)}\n"
                       client_sock.send(response.encode())

           elif cmd == '/msg':
               if len(parts) < 2:
                   client_sock.send(b"Usage: /msg <user> <message>\n")
                   return

               parts = parts[1].split(' ', 1)
               if len(parts) < 2:
                   client_sock.send(b"Usage: /msg <user> <message>\n")
                   return

               target_user, message = parts
               self.private_message(username, target_user, message)

           elif cmd == '/quit':
               client_sock.close()

           else:
               client_sock.send(f"Unknown command: {cmd}\n".encode())

       def broadcast(self, message: str, room: str, exclude=None):
           """Broadcast to all users in a room"""
           with self.lock:
               users = self.rooms.get(room, set())
               for client in users:
                   if client != exclude and client.fileno() != -1:
                       try:
                           client.send((message + '\n').encode())
                       except:
                           pass

       def private_message(self, sender: str, recipient: str, message: str):
           """Send private message"""
           with self.lock:
               target_sock = None
               for sock, name in self.clients.items():
                   if name == recipient:
                       target_sock = sock
                       break

               if target_sock and target_sock.fileno() != -1:
                   target_sock.send(f"[PM from {sender}] {message}\n".encode())
                   for sock, name in self.clients.items():
                       if name == sender:
                           sock.send(f"[PM to {recipient}] {message}\n".encode())
               else:
                   for sock, name in self.clients.items():
                       if name == sender:
                           sock.send(f"User '{recipient}' not found\n".encode())

       def get_user_room(self, client_sock):
           """Find user's room"""
           with self.lock:
               for room, users in self.rooms.items():
                   if client_sock in users:
                       return room
           return 'general'

       def remove_client(self, client_sock):
           """Remove client from all rooms"""
           username = self.clients.pop(client_sock, 'Unknown')

           with self.lock:
               for room, users in self.rooms.items():
                   if client_sock in users:
                       users.remove(client_sock)

           logger.info(f"{username} disconnected")
           self.broadcast(f"[Server] {username} left the chat", 'general')

       def shutdown(self):
           self.running = False
           if self.server_socket:
               self.server_socket.close()

           with self.lock:
               for client in list(self.clients.keys()):
                   try:
                       client.close()
                   except:
                       pass

           logger.info("Server shutdown complete")

   if __name__ == "__main__":
       import argparse

       parser = argparse.ArgumentParser(description="Chat Server")
       parser.add_argument('-p', '--port', type=int, default=8082,
                          help='Port to listen on')
       args = parser.parse_args()

       server = ChatServer(port=args.port)
       try:
           server.start()
       except KeyboardInterrupt:
           print("\n")
           logger.info("Shutting down...")
           server.shutdown()
   ```

2. **Create simple chat client**

   ```python
   #!/usr/bin/env python3
   """
   chat_client.py - Simple chat client
   """

   import socket
   import threading
   import sys

   class ChatClient:
       def __init__(self, host='localhost', port=8082):
           self.host = host
           self.port = port
           self.socket = None
           self.running = False

       def connect(self):
           try:
               self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
               self.socket.connect((self.host, self.port))
               self.running = True

               print("Connected to chat server")

               # Receive thread
               recv_thread = threading.Thread(target=self.receive_messages)
               recv_thread.daemon = True
               recv_thread.start()

               # Send messages
               while self.running:
                   message = input()
                   if message.lower() == '/quit':
                       break
                   if message.strip():
                       self.socket.send(message.encode())

           except Exception as e:
               print(f"Connection error: {e}")
           finally:
               self.close()

       def receive_messages(self):
           while self.running:
               try:
                   data = self.socket.recv(4096)
                   if not data:
                       break
                   print(data.decode(), end='')
               except:
                   break

       def close(self):
           self.running = False
           if self.socket:
               self.socket.close()
           print("Disconnected")

   if __name__ == "__main__":
       import argparse

       parser = argparse.ArgumentParser(description="Chat Client")
       parser.add_argument('-h', '--host', default='localhost',
                          help='Server host')
       parser.add_argument('-p', '--port', type=int, default=8082,
                          help='Server port')
       args = parser.parse_args()

       client = ChatClient(args.host, args.port)
       client.connect()
   ```

3. **Test the chat server**
   ```bash
   # Terminal 1 - Server
   python3 chat_server.py -p 8082

   # Terminals 2-4 - Clients
   python3 chat_client.py -p 8082

   # Test commands
   /help          # Show commands
   /join gaming   # Create/join a room
   /list          # List all rooms
   /who           # List users in current room
   /msg alice Hello # Private message
   /leave         # Leave current room
   ```

### Reflection Questions
1. How are messages broadcast to all clients?
2. What is the purpose of the threading model?
3. How could you add message history?

---

## Lab 4.1: DNS Lookup Analysis

**Objective:** Perform and analyze DNS lookups.

**Duration:** 30 minutes

**Prerequisites:** dig, nslookup installed

### Step-by-Step Instructions

1. **Perform basic lookups**
   ```bash
   # A record lookup
   dig example.com
   dig google.com A

   # AAAA record lookup
   dig google.com AAAA

   # MX record lookup
   dig gmail.com MX

   # TXT record lookup
   dig example.com TXT

   # NS record lookup
   dig example.com NS
   ```

2. **Use nslookup**
   ```bash
   # Interactive mode
   nslookup
   > server 8.8.8.8
   > set type=MX
   > gmail.com
   > set type=TXT
   > example.com
   > exit

   # Single query
   nslookup -type=MX gmail.com
   nslookup -type=TXT example.com 8.8.8.8
   ```

3. **Trace DNS resolution**
   ```bash
   # Trace full resolution
   dig +trace example.com

   # Query specific DNS servers
   dig @8.8.8.8 example.com
   dig @1.1.1.1 example.com

   # Show query times
   dig +stats example.com
   ```

4. **Capture DNS traffic**
   ```bash
   sudo tcpdump -i eth0 "udp port 53" -w dns_lab.pcap

   # Generate DNS queries in another terminal
   dig example.com
   dig google.com
   dig gmail.com
   ```

5. **Analyze DNS capture**
   ```bash
   # Show DNS queries
   tshark -r dns_lab.pcap -Y "dns.flags.response == 0" \
       -T fields -e dns.qry.name -e dns.qry.type

   # Show DNS responses
   tshark -r dns_lab.pcap -Y "dns.flags.response == 1" \
       -T fields -e dns.resp.name -e dns.a
   ```

### DNS Worksheet

| Domain | Record Type | Result |
|--------|-------------|--------|
| example.com | A | |
| google.com | AAAA | |
| gmail.com | MX | |
| example.com | TXT | |

### Expected Output
```
google.com. 300 IN A 142.250.185.46
google.com. 300 IN AAAA 2607:f8b0:4004:804::200e
gmail.com. 3600 IN MX 5 gmail-smtp-in.l.google.com.
example.com. 86400 IN TXT "v=spf1 -all"
```

### Reflection Questions
1. What is the difference between `dig` and `nslookup`?
2. How does DNS caching work?
3. What is DNSSEC and why is it important?

---

## Lab 4.2: HTTP Request/Response Analysis

**Objective:** Capture and analyze HTTP communication.

**Duration:** 30 minutes

**Prerequisites:** curl, tcpdump installed

### Step-by-Step Instructions

1. **Capture HTTP traffic**
   ```bash
   sudo tcpdump -i eth0 "tcp port 80" -w http_lab.pcap
   ```

2. **Generate HTTP traffic**
   ```bash
   curl -v http://example.com
   curl -v -H "User-Agent: MyClient" http://example.com
   ```

3. **Analyze HTTP requests**
   ```bash
   # Show HTTP requests
   tshark -r http_lab.pcap -Y "http.request" -V

   # Extract fields
   tshark -r http_lab.pcap -Y "http.request" -T fields \
       -e http.request.method \
       -e http.request.uri \
       -e http.host \
       -e http.user_agent
   ```

4. **Analyze HTTP responses**
   ```bash
   # Show HTTP responses
   tshark -r http_lab.pcap -Y "http.response" -V

   # Extract status codes
   tshark -r http_lab.pcap -Y "http.response" -T fields \
       -e http.response.code \
       -e http.content_type \
       -e http.content_length
   ```

5. **Follow HTTP stream**
   ```bash
   tshark -r http_lab.pcap -z follow,tcp,hex,0
   ```

### HTTP Worksheet

| Request Component | Value |
|-------------------|-------|
| Method | |
| Path | |
| HTTP Version | |
| Host | |
| User-Agent | |

| Response Component | Value |
|--------------------|-------|
| Status Code | |
| Content-Type | |
| Content-Length | |
| Server | |

### Expected Output
```
GET / HTTP/1.1
Host: example.com
User-Agent: curl/7.68.0
Accept: */*

HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1256
Server: nginx/1.14.0
```

### Reflection Questions
1. What information is in an HTTP request?
2. What do status codes indicate?
3. How does HTTP differ from HTTPS?

---

## Lab 4.3: Simple HTTP Server

**Objective:** Build a simple HTTP server.

**Duration:** 45 minutes

**Prerequisites:** Python 3.8+

### Step-by-Step Instructions

1. **Build HTTP server**

   ```python
   #!/usr/bin/env python3
   """
   http_server.py - Simple HTTP server
   """

   import socket
   import os
   import datetime
   import threading
   import mimetypes

   class HTTPServer:
       def __init__(self, host='0.0.0.0', port=8080, root='./www'):
           self.host = host
           self.port = port
           self.root = root
           self.socket = None
           self.running = False
           self.stats = {'requests': 0, 'bytes': 0}

           # Create root directory
           os.makedirs(root, exist_ok=True)
           self.create_test_files()

       def create_test_files(self):
           """Create test files"""
           # index.html
           with open(os.path.join(self.root, 'index.html'), 'w') as f:
               f.write("""
           <!DOCTYPE html>
           <html>
           <head><title>HTTP Server</title></head>
           <body>
           <h1>Welcome to HTTP Server!</h1>
           <p>Test page</p>
           <a href="/api">API</a>
           </body>
           </html>
           """)

           # api endpoint
           with open(os.path.join(self.root, 'api.json'), 'w') as f:
               import json
               json.dump({
                   'status': 'ok',
                   'time': datetime.datetime.now().isoformat()
               }, f)

       def start(self):
           try:
               self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
               self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
               self.socket.bind((self.host, self.port))
               self.socket.listen(5)
               self.running = True

               print(f"HTTP Server started on http://{self.host}:{self.port}")
               print(f"Root: {os.path.abspath(self.root)}")

               while self.running:
                   try:
                       client, addr = self.socket.accept()
                       thread = threading.Thread(target=self.handle_client,
                                                args=(client, addr))
                       thread.start()
                   except:
                       if self.running:
                           continue

           except Exception as e:
               print(f"Error: {e}")
           finally:
               self.stop()

       def handle_client(self, client, addr):
           try:
               data = client.recv(4096)
               if not data:
                   client.close()
                   return

               self.stats['requests'] += 1

               # Parse request
               request = data.decode('utf-8', errors='ignore')
               lines = request.split('\r\n')
               if not lines:
                   client.close()
                   return

               parts = lines[0].split(' ')
               if len(parts) < 3:
                   client.close()
                   return

               method, path, version = parts

               # Only GET supported
               if method != 'GET':
                   self.send_error(client, 405)
                   client.close()
                   return

               # Security: prevent directory traversal
               if '..' in path:
                   self.send_error(client, 403)
                   client.close()
                   return

               # Determine file path
               if path == '/':
                   path = '/index.html'
               elif path == '/api':
                   path = '/api.json'

               file_path = os.path.join(self.root, path[1:])

               if not os.path.exists(file_path):
                   self.send_error(client, 404)
                   client.close()
                   return

               if os.path.isdir(file_path):
                   self.send_error(client, 403)
                   client.close()
                   return

               # Read and serve file
               with open(file_path, 'rb') as f:
                   content = f.read()

               content_type = mimetypes.guess_type(file_path)[0] or 'text/html'

               self.send_response(client, 200, content_type, content)
               self.stats['bytes'] += len(content)
               client.close()

           except Exception as e:
               print(f"Error: {e}")
               client.close()

       def send_response(self, client, status, content_type, content):
           """Send HTTP response"""
           status_line = f"HTTP/1.1 {status} OK\r\n"
           headers = (
               f"Content-Type: {content_type}\r\n"
               f"Content-Length: {len(content)}\r\n"
               f"Server: PythonHTTPServer/1.0\r\n"
               f"Date: {datetime.datetime.now().strftime('%a, %d %b %Y %H:%M:%S GMT')}\r\n"
               f"Connection: close\r\n"
               f"\r\n"
           )

           client.send(status_line.encode())
           client.send(headers.encode())
           client.send(content)

       def send_error(self, client, code):
           """Send error response"""
           messages = {404: 'Not Found', 403: 'Forbidden', 405: 'Method Not Allowed'}
           message = messages.get(code, 'Error')
           html = f"<html><body><h1>{code} {message}</h1></body></html>"
           self.send_response(client, code, 'text/html', html.encode())

       def stop(self):
           self.running = False
           if self.socket:
               self.socket.close()
           print(f"Stats: {self.stats['requests']} requests, {self.stats['bytes']} bytes")
           print("Server stopped")

   if __name__ == "__main__":
       import argparse

       parser = argparse.ArgumentParser(description="HTTP Server")
       parser.add_argument('-p', '--port', type=int, default=8080,
                          help='Port to listen on')
       parser.add_argument('-d', '--directory', default='./www',
                          help='Root directory')
       args = parser.parse_args()

       server = HTTPServer(port=args.port, root=args.directory)
       try:
           server.start()
       except KeyboardInterrupt:
           print("\n")
           server.stop()
   ```

2. **Test the server**
   ```bash
   # Start server
   python3 http_server.py -p 8080

   # Test with curl
   curl -v http://localhost:8080/
   curl -v http://localhost:8080/api
   curl -v http://localhost:8080/nonexistent

   # Browser test
   open http://localhost:8080/
   ```

### Reflection Questions
1. How does the server parse HTTP requests?
2. What security measures are implemented?
3. How could you add POST support?

---

## Lab 5.1: TLS Handshake Analysis

**Objective:** Capture and analyze TLS handshake.

**Duration:** 45 minutes

**Prerequisites:** tcpdump, openssl, curl installed

### Step-by-Step Instructions

1. **Capture TLS traffic**
   ```bash
   sudo tcpdump -i eth0 "tcp port 443" -w tls_lab.pcap
   ```

2. **Generate TLS traffic**
   ```bash
   curl -v https://www.google.com
   openssl s_client -connect google.com:443
   ```

3. **Analyze TLS handshake**
   ```bash
   # Show handshake messages
   tshark -r tls_lab.pcap -Y "tls.handshake" -V

   # Extract ClientHello
   tshark -r tls_lab.pcap -Y "tls.handshake.type == 1" -V

   # Extract ServerHello
   tshark -r tls_lab.pcap -Y "tls.handshake.type == 2" -V

   # Show cipher suites
   tshark -r tls_lab.pcap -Y "tls.handshake.ciphersuite" \
       -T fields -e tls.handshake.ciphersuite
   ```

4. **Analyze certificates**
   ```bash
   # Extract certificate
   tshark -r tls_lab.pcap -Y "tls.handshake.certificate" -V

   # Use openssl
   openssl s_client -showcerts -connect google.com:443 </dev/null
   ```

5. **Test TLS configuration**
   ```bash
   # Check TLS version support
   openssl s_client -connect google.com:443 -tls1_3
   openssl s_client -connect google.com:443 -tls1_2

   # Check cipher suites
   openssl s_client -connect google.com:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384'
   ```

### TLS Handshake Worksheet

| Message | Direction | Time |
|---------|-----------|------|
| ClientHello | → | |
| ServerHello | ← | |
| Certificate | ← | |
| ServerKeyExchange | ← | |
| ServerHelloDone | ← | |
| ClientKeyExchange | → | |
| ChangeCipherSpec | → | |
| Finished | → | |

### Expected Output
```
TLSv1.3 Record Layer: Handshake Protocol: ClientHello
    Version: TLS 1.2
    Cipher Suites: TLS_AES_256_GCM_SHA384, TLS_CHACHA20_POLY1305_SHA256

TLSv1.3 Record Layer: Handshake Protocol: ServerHello
    Version: TLS 1.2
    Cipher Suite: TLS_AES_256_GCM_SHA384
```

### Reflection Questions
1. What is the purpose of the TLS handshake?
2. What is a cipher suite?
3. How does Perfect Forward Secrecy work?

---

## Lab 5.2: TLS Certificate Validation

**Objective:** Validate and inspect TLS certificates.

**Duration:** 30 minutes

**Prerequisites:** openssl installed

### Step-by-Step Instructions

1. **View certificate details**
   ```bash
   openssl s_client -showcerts -connect google.com:443 </dev/null
   ```

2. **Extract and examine certificate**
   ```bash
   openssl s_client -showcerts -connect google.com:443 </dev/null | \
       openssl x509 -text -noout
   ```

3. **Check certificate validity**
   ```bash
   openssl x509 -in google.pem -noout -dates
   ```

4. **Verify certificate chain**
   ```bash
   openssl verify -CAfile root.pem google.pem
   ```

5. **Check certificate revocation**
   ```bash
   openssl s_client -connect google.com:443 -status 2>&1
   ```

### Certificate Worksheet

| Field | Value |
|-------|-------|
| Subject | |
| Issuer | |
| Not Before | |
| Not After | |
| Public Key Algorithm | |
| SANs | |

### Reflection Questions
1. What is a Certificate Authority?
2. How does certificate validation work?
3. What is OCSP and why is it used?

---

## Lab 5.3: Packet Capture Analysis

**Objective:** Analyze a complete packet capture.

**Duration:** 1 hour

**Prerequisites:** tcpdump, tshark, Wireshark installed

### Step-by-Step Instructions

1. **Capture complete session**
   ```bash
   sudo tcpdump -i eth0 -w full_session.pcap
   ```

2. **Browse to multiple sites**
   ```bash
   # Visit these sites in a browser
   http://example.com
   https://www.google.com
   https://www.github.com
   ```

3. **Generate additional traffic**
   ```bash
   ping -c 4 8.8.8.8
   dig example.com
   curl -I https://www.google.com
   ```

4. **Analyze the capture**
   ```bash
   # Protocol hierarchy
   tshark -r full_session.pcap -z protocol,hierarchy

   # Top talkers
   tshark -r full_session.pcap -z endpoints,ip

   # Conversations
   tshark -r full_session.pcap -z conv,tcp

   # DNS queries
   tshark -r full_session.pcap -Y "dns" -T fields -e dns.qry.name

   # HTTP requests
   tshark -r full_session.pcap -Y "http.request" -T fields \
       -e http.request.method -e http.request.uri
   ```

5. **Export HTTP objects**
   ```bash
   # In Wireshark
   File → Export Objects → HTTP
   ```

### Packet Analysis Worksheet

| Protocol | Packets | Bytes | % Packets | % Bytes |
|----------|---------|-------|-----------|---------|
| Ethernet | | | | |
| IPv4 | | | | |
| TCP | | | | |
| UDP | | | | |
| DNS | | | | |
| HTTP | | | | |
| TLS | | | | |

### Reflection Questions
1. Which protocol has the most traffic?
2. What are the top talking IP addresses?
3. How many DNS queries were made?

---

## Capstone Project: Network Monitoring System

**Objective:** Build a complete network monitoring system.

**Duration:** 2-3 hours

**Prerequisites:** Python 3.8+, Flask installed

### Step-by-Step Instructions

1. **Create project structure**
   ```bash
   mkdir network-monitor
   cd network-monitor
   mkdir templates static
   ```

2. **Build discovery module**

   ```python
   # discovery.py
   import nmap
   import socket

   class NetworkDiscovery:
       def __init__(self):
           self.nm = nmap.PortScanner()

       def scan_network(self, network='192.168.1.0/24'):
           """Discover active hosts"""
           self.nm.scan(hosts=network, arguments='-sn -PE -PA21,22,23,80,443 -T4')
           devices = []

           for host in self.nm.all_hosts():
               if self.nm[host].state() == 'up':
                   devices.append({
                       'ip': host,
                       'hostname': self._reverse_lookup(host),
                       'mac': self.nm[host].get('addresses', {}).get('mac')
                   })

           return devices

       def _reverse_lookup(self, ip):
           try:
               return socket.gethostbyaddr(ip)[0]
           except:
               return None
   ```

3. **Build monitor module**

   ```python
   # monitor.py
   import time
   import threading
   import ping3
   from datetime import datetime

   class NetworkMonitor:
       def __init__(self):
           self.devices = {}
           self.status = {}
           self.running = False

       def add_device(self, device):
           ip = device['ip']
           self.devices[ip] = device
           self.status[ip] = {'status': 'unknown', 'last_check': None}

       def check_device(self, ip):
           """Check device status"""
           latency = ping3.ping(ip, timeout=2)

           self.status[ip]['last_check'] = datetime.now()

           if latency is not None:
               self.status[ip]['status'] = 'up'
               self.status[ip]['latency'] = latency
           else:
               self.status[ip]['status'] = 'down'
               self.status[ip]['latency'] = None

       def monitor_loop(self):
           """Main monitoring loop"""
           while self.running:
               for ip in self.devices:
                   self.check_device(ip)
               time.sleep(60)

       def start(self):
           self.running = True
           thread = threading.Thread(target=self.monitor_loop)
           thread.daemon = True
           thread.start()

       def stop(self):
           self.running = False

       def get_status(self):
           """Get current status"""
           return self.status
   ```

4. **Build web dashboard**

   ```python
   # app.py
   from flask import Flask, render_template, jsonify
   from discovery import NetworkDiscovery
   from monitor import NetworkMonitor
   import threading

   app = Flask(__name__)

   # Initialize components
   discovery = NetworkDiscovery()
   monitor = NetworkMonitor()

   @app.route('/')
   def index():
       return render_template('dashboard.html')

   @app.route('/api/discover')
   def discover():
       devices = discovery.scan_network()
       for device in devices:
           monitor.add_device(device)
       return jsonify(devices)

   @app.route('/api/status')
   def get_status():
       return jsonify(monitor.get_status())

   @app.route('/api/start')
   def start_monitor():
       monitor.start()
       return jsonify({'status': 'started'})

   @app.route('/api/stop')
   def stop_monitor():
       monitor.stop()
       return jsonify({'status': 'stopped'})

   if __name__ == '__main__':
       # Discover devices on startup
       devices = discovery.scan_network()
       for device in devices:
           monitor.add_device(device)

       # Start monitoring
       monitor.start()

       # Run web server
       app.run(host='0.0.0.0', port=5000, debug=False)
   ```

5. **Create web dashboard template**

   ```html
   <!-- templates/dashboard.html -->
   <!DOCTYPE html>
   <html>
   <head>
       <title>Network Monitor</title>
       <style>
           body { font-family: Arial, sans-serif; margin: 20px; }
           .device { display: inline-block; margin: 10px; padding: 10px; border: 1px solid #ccc; border-radius: 5px; min-width: 150px; }
           .up { border-color: green; background: #e8f5e9; }
           .down { border-color: red; background: #ffebee; }
           .unknown { border-color: gray; background: #f5f5f5; }
           .status { font-weight: bold; }
           .controls { margin: 20px 0; }
           button { padding: 10px 20px; margin: 5px; }
       </style>
   </head>
   <body>
       <h1>Network Monitoring System</h1>

       <div class="controls">
           <button onclick="discover()">Discover Network</button>
           <button onclick="startMonitor()">Start Monitoring</button>
           <button onclick="stopMonitor()">Stop Monitoring</button>
       </div>

       <div id="devices"></div>

       <script>
           function updateStatus() {
               fetch('/api/status')
                   .then(r => r.json())
                   .then(data => {
                       let html = '';
                       for (const [ip, info] of Object.entries(data)) {
                           const statusClass = info.status;
                           const lastCheck = info.last_check ? new Date(info.last_check).toLocaleTimeString() : 'Never';
                           html += `
                               <div class="device ${statusClass}">
                                   <strong>${ip}</strong><br>
                                   Status: <span class="status">${info.status}</span><br>
                                   ${info.latency ? `Latency: ${info.latency.toFixed(2)}ms` : ''}
                                   <br><small>Last: ${lastCheck}</small>
                               </div>
                           `;
                       }
                       document.getElementById('devices').innerHTML = html;
                   });
           }

           function discover() {
               fetch('/api/discover')
                   .then(r => r.json())
                   .then(data => {
                       alert(`Found ${data.length} devices`);
                       updateStatus();
                   });
           }

           function startMonitor() {
               fetch('/api/start')
                   .then(() => updateStatus());
           }

           function stopMonitor() {
               fetch('/api/stop')
                   .then(() => updateStatus());
           }

           // Update every 10 seconds
           updateStatus();
           setInterval(updateStatus, 10000);
       </script>
   </body>
   </html>
   ```

6. **Run the system**
   ```bash
   # Install dependencies
   pip install flask nmap python-ping3

   # Start the system
   python3 app.py
   ```

7. **Access dashboard**
   - Open browser to `http://localhost:5000`
   - Click "Discover Network" to scan
   - Click "Start Monitoring" to begin

### Capstone Reflection Questions
1. How does the system discover devices?
2. What does the monitoring module do?
3. How could you improve the system?
4. What additional features would be useful?

---

## Lab Challenge Solutions

### Challenge 1: ARP Scanner
**Problem:** Build a tool that scans for devices using ARP.

```python
#!/usr/bin/env python3
from scapy.all import ARP, Ether, srp

def arp_scan(network='192.168.1.0/24'):
    arp = ARP(pdst=network)
    ether = Ether(dst="ff:ff:ff:ff:ff:ff")
    packet = ether/arp
    result = srp(packet, timeout=3, verbose=0)[0]

    devices = []
    for sent, received in result:
        devices.append({'ip': received.psrc, 'mac': received.hwsrc})

    return devices

if __name__ == "__main__":
    devices = arp_scan()
    for device in devices:
        print(f"{device['ip']} -> {device['mac']}")
```

### Challenge 2: Port Scanner
**Problem:** Build a TCP port scanner.

```python
#!/usr/bin/env python3
import socket
import threading
from queue import Queue

def scan_port(ip, port, timeout=1):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((ip, port))
        sock.close()
        return result == 0
    except:
        return False

def scan_ports(ip, start=1, end=1024, threads=50):
    open_ports = []
    queue = Queue()

    def worker():
        while not queue.empty():
            port = queue.get()
            if scan_port(ip, port):
                open_ports.append(port)
            queue.task_done()

    for port in range(start, end + 1):
        queue.put(port)

    for _ in range(threads):
        thread = threading.Thread(target=worker)
        thread.daemon = True
        thread.start()

    queue.join()
    return sorted(open_ports)

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: port_scanner.py <ip>")
        sys.exit(1)

    ports = scan_ports(sys.argv[1])
    print(f"Open ports: {ports}")
```

### Challenge 3: Packet Sniffer
**Problem:** Build a simple packet sniffer.

```python
#!/usr/bin/env python3
import socket

def sniff_packets(interface='eth0', count=10):
    # Create raw socket
    sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.ntohs(3))
    sock.bind((interface, 0))

    for i in range(count):
        data, addr = sock.recvfrom(65536)
        print(f"Packet {i+1}: {len(data)} bytes from {addr}")

if __name__ == "__main__":
    import sys
    interface = sys.argv[1] if len(sys.argv) > 1 else 'eth0'
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    sniff_packets(interface, count)
```

---

**END OF LAB BOOK**
