# Appendix J: Complete Hands-On Lab Workbook

## Practical Exercises for Every Protocol and Concept

---

## Overview

This appendix provides a comprehensive workbook of hands-on labs covering every protocol and concept discussed in the series. Each lab includes clear objectives, step-by-step instructions, expected outputs, and verification steps.

**Purpose**: Provide practical, self-paced exercises that reinforce learning and build real-world skills.

**Organization**: Labs are organized by protocol layer, progressing from basic to advanced. Each lab is self-contained.

---

## Table of Contents

1. [Physical Layer Labs](#1-physical-layer-labs)
2. [Data Link Layer Labs](#2-data-link-layer-labs)
3. [Network Layer Labs](#3-network-layer-labs)
4. [Transport Layer Labs](#4-transport-layer-labs)
5. [Application Layer Labs](#5-application-layer-labs)
6. [Security Labs](#6-security-labs)
7. [Modern Protocol Labs](#7-modern-protocol-labs)
8. [Troubleshooting Labs](#8-troubleshooting-labs)
9. [Capstone Project](#9-capstone-project)

---

## 1. Physical Layer Labs

### Lab 1.1: Cable Testing and Termination

**Objective**: Learn to test and terminate network cables.

**Duration**: 30 minutes

**Materials**:
- Cat5e or Cat6 cable
- RJ45 connectors
- Crimping tool
- Cable tester
- Wire stripper

**Procedure**:

**Step 1**: Strip the cable jacket
```bash
# Using wire stripper, remove approximately 2 inches of outer jacket
# Be careful not to cut into the individual wire insulation
```

**Step 2**: Untwist and arrange wires
```
Standard T568B wiring (from left to right):
1. White/Orange
2. Orange
3. White/Green
4. Blue
5. White/Blue
6. Green
7. White/Brown
8. Brown
```

**Step 3**: Trim wires to proper length
```bash
# Trim wires so they are approximately 1/2 inch from the jacket
# Ensure all wires are straight and in the correct order
```

**Step 4**: Insert wires into RJ45 connector
```bash
# Insert wires into the connector, ensuring they reach the end
# Verify the order is correct before crimping
```

**Step 5**: Crimp the connector
```bash
# Use the crimping tool to secure the connector
# Apply firm, even pressure
```

**Step 6**: Test the cable
```bash
# Connect the cable to the tester
# Verify continuity on all 8 pins
```

**Verification**:
```bash
# Expected output from cable tester:
# Pin 1: Pass
# Pin 2: Pass
# Pin 3: Pass
# Pin 4: Pass
# Pin 5: Pass
# Pin 6: Pass
# Pin 7: Pass
# Pin 8: Pass
```

### Lab 1.2: Network Interface Card Configuration

**Objective**: Configure and test network interface settings.

**Duration**: 30 minutes

**Procedure**:

**Step 1**: View current interface settings
```bash
# Linux
ip link show
ethtool eth0

# macOS
ifconfig en0

# Windows
ipconfig /all
get-netadapter
```

**Step 2**: Check link status
```bash
# Linux
ethtool eth0 | grep -E "Link detected|Speed|Duplex"
cat /sys/class/net/eth0/operstate

# macOS
networksetup -getairportnetwork en0

# Windows
Get-NetAdapter -Name "Ethernet" | Select-Object LinkSpeed
```

**Step 3**: Change interface settings
```bash
# Linux - Set speed and duplex
sudo ethtool -s eth0 speed 1000 duplex full autoneg on

# macOS
sudo networksetup -setairportpower en0 off
sudo networksetup -setairportpower en0 on

# Windows
Set-NetAdapter -Name "Ethernet" -Automatic
```

**Step 4**: Test connectivity
```bash
# Ping local network
ping -c 4 192.168.1.1

# Test with different packet sizes
ping -c 4 -s 1472 192.168.1.1
ping -c 4 -s 1500 192.168.1.1  # Should fail if MTU is 1500
```

**Step 5**: Check for errors
```bash
# Linux - Show interface statistics
ip -s link show eth0
ethtool -S eth0

# Windows - Show interface statistics
Get-NetAdapterStatistics -Name "Ethernet"
```

**Verification**:
```bash
# Expected output for link status:
# Link detected: yes
# Speed: 1000Mb/s
# Duplex: Full

# Expected ping results:
# 4 packets transmitted, 4 received, 0% packet loss
```

### Lab 1.3: WiFi Signal Analysis

**Objective**: Analyze WiFi signals and optimize connectivity.

**Duration**: 45 minutes

**Procedure**:

**Step 1**: Scan for WiFi networks
```bash
# Linux
sudo iwlist wlan0 scan | grep -E "ESSID|Channel|Signal"

# macOS
airport -s

# Windows
netsh wlan show networks
```

**Step 2**: Analyze signal strength
```bash
# Linux
iwconfig wlan0 | grep Signal

# Monitor signal over time
while true; do
    iwconfig wlan0 | grep Signal
    sleep 1
done
```

**Step 3**: Check channel interference
```bash
# Linux - List networks on each channel
sudo iwlist wlan0 scan | grep -E "ESSID|Channel" | paste - - | sort

# Identify overlapping channels
# 2.4 GHz channels: 1, 6, 11 are non-overlapping
# 5 GHz channels: More available, less interference
```

**Step 4**: Optimize WiFi settings
```bash
# Linux - Change channel (requires root)
sudo iwconfig wlan0 channel 6

# Disable power saving for better performance
sudo iwconfig wlan0 power off

# Change transmit power (if supported)
sudo iwconfig wlan0 txpower 20
```

**Step 5**: Measure throughput
```bash
# Use iperf to test WiFi throughput
# Server side
iperf3 -s

# Client side
iperf3 -c <server_ip> -t 30
```

**Verification**:
```bash
# Expected signal strength:
# Signal level: -50 dBm (excellent)
# Signal level: -60 dBm (good)
# Signal level: -70 dBm (fair)
# Signal level: -80 dBm (poor)

# Expected throughput:
# 2.4 GHz: 50-150 Mbps (typical)
# 5 GHz: 200-800 Mbps (typical)
```

---

## 2. Data Link Layer Labs

### Lab 2.1: ARP Analysis

**Objective**: Observe and analyze ARP behavior.

**Duration**: 30 minutes

**Procedure**:

**Step 1**: View current ARP cache
```bash
# Linux
arp -a
ip neigh show

# macOS
arp -a

# Windows
arp -a
```

**Step 2**: Clear ARP cache
```bash
# Linux
sudo ip neigh flush all

# macOS
sudo arp -d -a

# Windows (Admin)
arp -d *
```

**Step 3**: Generate ARP traffic
```bash
# Ping the gateway to generate ARP
ping -c 1 192.168.1.1

# Capture ARP traffic
sudo tcpdump -i eth0 arp -vv
```

**Step 4**: Analyze ARP packets
```bash
# Save ARP traffic to file
sudo tcpdump -i eth0 arp -w arp_lab.pcap -c 5

# View ARP packets
tshark -r arp_lab.pcap -Y "arp" -T fields \
    -e arp.opcode -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 \
    -e arp.src.hw_mac -e arp.dst.hw_mac
```

**Step 5**: Add static ARP entry
```bash
# Linux
sudo arp -s 192.168.1.100 00:11:22:33:44:55

# macOS
sudo arp -s 192.168.1.100 00:11:22:33:44:55

# Windows
arp -s 192.168.1.100 00-11-22-33-44-55
```

**Verification**:
```bash
# Expected ARP request:
# 00:11:22:33:44:55 > ff:ff:ff:ff:ff:ff, ARP, Request who-has 192.168.1.1 tell 192.168.1.100

# Expected ARP reply:
# 00:aa:bb:cc:dd:ee > 00:11:22:33:44:55, ARP, Reply 192.168.1.1 is-at 00:aa:bb:cc:dd:ee

# Static ARP entry should appear in ARP cache
```

### Lab 2.2: VLAN Configuration

**Objective**: Configure and test VLANs on a switch.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Create VLANs (Cisco)
```bash
# Enter configuration mode
enable
configure terminal

# Create VLANs
vlan 10
name Engineering
exit

vlan 20
name Marketing
exit

vlan 30
name Management
exit

# Verify VLANs
show vlan brief
```

**Step 2**: Assign ports to VLANs
```bash
# Configure interface
interface GigabitEthernet0/1
switchport mode access
switchport access vlan 10
no shutdown
exit

interface GigabitEthernet0/2
switchport mode access
switchport access vlan 20
no shutdown
exit

interface GigabitEthernet0/24
switchport mode trunk
switchport trunk allowed vlan 10,20,30
no shutdown
exit
```

**Step 3**: Configure VLAN interfaces (SVI)
```bash
interface vlan 10
ip address 10.0.10.1 255.255.255.0
no shutdown
exit

interface vlan 20
ip address 10.0.20.1 255.255.255.0
no shutdown
exit

interface vlan 30
ip address 10.0.30.1 255.255.255.0
no shutdown
exit
```

**Step 4**: Test connectivity
```bash
# Verify IP configuration
show ip interface brief

# Test inter-VLAN routing
ping 10.0.20.1 source vlan 10
ping 10.0.30.1 source vlan 10

# Verify trunk
show interfaces trunk
```

**Step 5**: Capture VLAN traffic
```bash
# Capture VLAN 10 traffic
sudo tcpdump -i eth0 vlan 10

# Capture specific VLAN ID
sudo tcpdump -i eth0 vlan and vlan 10
```

**Verification**:
```bash
# Expected VLAN output:
# VLAN Name          Status    Ports
# ---- ------------ --------- ---------
# 1    default        active   Gi0/3, Gi0/4...
# 10   Engineering    active   Gi0/1
# 20   Marketing      active   Gi0/2
# 30   Management     active

# Expected routing:
# ping 10.0.20.1 from VLAN 10 - Should succeed
# ping 10.0.30.1 from VLAN 10 - Should succeed
```

### Lab 2.3: Ethernet Frame Decoding

**Objective**: Decode Ethernet frames and analyze headers.

**Duration**: 45 minutes

**Procedure**:

**Step 1**: Capture Ethernet frames
```bash
# Capture with full frames
sudo tcpdump -i eth0 -s 0 -e -w ethernet_lab.pcap -c 10

# Capture without name resolution
sudo tcpdump -i eth0 -e -nn -c 10
```

**Step 2**: View Ethernet headers
```bash
# Show Ethernet headers
tshark -r ethernet_lab.pcap -Y "eth" -T fields \
    -e eth.dst -e eth.src -e eth.type

# Show in hex
tshark -r ethernet_lab.pcap -x
```

**Step 3**: Analyze specific frames
```bash
# Decode a specific frame
tshark -r ethernet_lab.pcap -Y "eth" -V

# Show frame 1 details
tshark -r ethernet_lab.pcap -Y "frame.number == 1" -V

# Show Ethernet type
tshark -r ethernet_lab.pcap -Y "eth" -T fields -e eth.type_original
```

**Step 4**: Build Ethernet frame decoder (Python)
```python
#!/usr/bin/env python3
"""
ethernet_frame_decoder.py - Decode Ethernet frames
"""

import sys
from scapy.all import rdpcap, Ether

def decode_ethernet_frame(pcap_file):
    """Decode Ethernet frames from pcap"""
    packets = rdpcap(pcap_file)
    
    print("Ethernet Frame Decoder")
    print("=" * 80)
    
    for i, packet in enumerate(packets[:10], 1):
        if Ether in packet:
            eth = packet[Ether]
            print(f"\nFrame {i}:")
            print(f"  Destination MAC: {eth.dst}")
            print(f"  Source MAC: {eth.src}")
            print(f"  EtherType: 0x{eth.type:04x}")
            print(f"  Length: {len(packet)} bytes")
            print(f"  Payload: {len(eth.payload)} bytes")
            
            # Show payload type
            if hasattr(eth.payload, 'name'):
                print(f"  Protocol: {eth.payload.name}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    decode_ethernet_frame(sys.argv[1])
```

**Verification**:
```bash
# Expected output:
# Ethernet Frame Decoder
# ================================================================================
# Frame 1:
#   Destination MAC: 00:11:22:33:44:55
#   Source MAC: aa:bb:cc:dd:ee:ff
#   EtherType: 0x0800
#   Length: 74 bytes
#   Payload: 60 bytes
#   Protocol: IP
```

---

## 3. Network Layer Labs

### Lab 3.1: Subnet Calculation and Implementation

**Objective**: Calculate subnets and implement them on a network.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Calculate subnets
```python
#!/usr/bin/env python3
"""
subnet_calculator.py - Calculate subnets
"""

import ipaddress
from typing import List, Dict

def calculate_subnets(network: str, num_subnets: int) -> List[Dict]:
    """
    Calculate subnets from a network address
    """
    # Parse network
    net = ipaddress.ip_network(network)
    net_mask = net.prefixlen
    
    # Calculate new prefix length
    # Need 2^n >= num_subnets
    import math
    bits_needed = math.ceil(math.log2(num_subnets))
    new_prefix = net_mask + bits_needed
    
    # Create subnets
    subnets = []
    for i, subnet in enumerate(net.subnets(prefixlen_diff=bits_needed)):
        subnets.append({
            'name': f'subnet_{i+1}',
            'network': str(subnet),
            'first_host': str(next(subnet.hosts())),
            'last_host': str(list(subnet.hosts())[-1]),
            'broadcast': str(subnet.broadcast_address),
            'num_hosts': subnet.num_addresses - 2,
            'prefix': subnet.prefixlen,
            'netmask': str(subnet.netmask)
        })
    
    return subnets

def main():
    """Example subnet calculations"""
    # Example: Divide 192.168.1.0/24 into 4 subnets
    network = '192.168.1.0/24'
    subnets = calculate_subnets(network, 4)
    
    print(f"Network: {network}")
    print("=" * 60)
    
    for subnet in subnets:
        print(f"\n{subnet['name']}:")
        print(f"  Network: {subnet['network']}")
        print(f"  Netmask: {subnet['netmask']}")
        print(f"  First Host: {subnet['first_host']}")
        print(f"  Last Host: {subnet['last_host']}")
        print(f"  Broadcast: {subnet['broadcast']}")
        print(f"  Hosts: {subnet['num_hosts']}")
        print(f"  Prefix: /{subnet['prefix']}")

if __name__ == "__main__":
    main()
```

**Step 2**: Configure subnets on interfaces
```bash
# Linux
sudo ip addr add 192.168.1.1/25 dev eth0.10
sudo ip addr add 192.168.1.129/25 dev eth0.20

# Cisco
interface GigabitEthernet0/0
ip address 192.168.1.1 255.255.255.128
no shutdown

interface GigabitEthernet0/1
ip address 192.168.1.129 255.255.255.128
no shutdown
```

**Step 3**: Test subnet connectivity
```bash
# Test host in same subnet
ping -c 4 192.168.1.10

# Test host in different subnet
ping -c 4 192.168.1.150

# Trace route between subnets
traceroute -n 192.168.1.150
```

**Verification**:
```bash
# Expected subnet output:
# 192.168.1.0/24 -> 4 subnets /26
# Subnet 1: 192.168.1.0/26 (hosts: 1-62)
# Subnet 2: 192.168.1.64/26 (hosts: 65-126)
# Subnet 3: 192.168.1.128/26 (hosts: 129-190)
# Subnet 4: 192.168.1.192/26 (hosts: 193-254)

# ping between subnets should require routing
# ping within subnet should work directly
```

### Lab 3.2: Static and Dynamic Routing

**Objective**: Configure and verify static and dynamic routing.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Configure static routes
```bash
# Cisco
ip route 10.0.0.0 255.0.0.0 192.168.1.2
ip route 172.16.0.0 255.255.0.0 192.168.1.2
ip route 0.0.0.0 0.0.0.0 192.168.1.1

# Linux
sudo ip route add 10.0.0.0/8 via 192.168.1.2
sudo ip route add 172.16.0.0/16 via 192.168.1.2
sudo ip route add default via 192.168.1.1
```

**Step 2**: View routing table
```bash
# Linux
ip route show
route -n

# Cisco
show ip route
show ip route static

# Verify specific route
ip route get 10.0.0.1
```

**Step 3**: Configure OSPF
```bash
# Cisco
router ospf 1
network 192.168.1.0 0.0.0.255 area 0
network 10.0.0.0 0.255.255.255 area 0
exit

# Juniper
set protocols ospf area 0.0.0.0 interface ge-0/0/1
set protocols ospf area 0.0.0.0 interface ge-0/0/2 passive
```

**Step 4**: Verify OSPF
```bash
# Cisco
show ip ospf neighbor
show ip ospf database
show ip route ospf

# Verify OSPF routes
show ip route | include O
```

**Step 5**: Test routing
```bash
# Trace route to remote network
traceroute -n 10.0.0.1
traceroute -n 172.16.0.1

# Ping with specific source
ping -c 4 10.0.0.1 -I 192.168.1.1
```

**Verification**:
```bash
# Expected static routes:
# S    10.0.0.0/8 [1/0] via 192.168.1.2
# S    172.16.0.0/16 [1/0] via 192.168.1.2
# S*   0.0.0.0/0 [1/0] via 192.168.1.1

# Expected OSPF neighbors:
# Neighbor ID     Pri   State           Dead Time   Address         Interface
# 192.168.1.2       1   FULL/DR         00:00:30    192.168.1.2     Gig0/0
```

### Lab 3.3: IPv6 Configuration

**Objective**: Configure IPv6 addressing and routing.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Enable IPv6
```bash
# Linux
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0

# Cisco
ipv6 unicast-routing
```

**Step 2**: Configure IPv6 addresses
```bash
# Linux
sudo ip -6 addr add 2001:db8:1::1/64 dev eth0
sudo ip -6 addr add fe80::1/64 dev eth0

# Cisco
interface GigabitEthernet0/0
ipv6 address 2001:DB8:1::1/64
ipv6 address FE80::1 link-local
no shutdown
```

**Step 3**: Configure IPv6 routing
```bash
# Cisco
ipv6 route 2001:DB8:2::/64 2001:DB8:1::2

# Linux
sudo ip -6 route add 2001:db8:2::/64 via 2001:db8:1::2
sudo ip -6 route add default via 2001:db8:1::1
```

**Step 4**: Test IPv6 connectivity
```bash
# Ping IPv6
ping6 -c 4 2001:db8:1::2
ping6 -c 4 2001:db8:2::1

# Trace IPv6 route
traceroute6 -n 2001:db8:2::1

# IPv6 DNS
dig AAAA google.com
```

**Step 5**: Configure SLAAC
```bash
# Cisco
interface GigabitEthernet0/0
ipv6 nd ra-interval 30
ipv6 nd prefix 2001:DB8:1::/64

# Verify router advertisements
show ipv6 interface GigabitEthernet0/0
```

**Verification**:
```bash
# Expected IPv6 output:
# 2001:DB8:1::1/64
# FE80::1 link-local

# IPv6 routes:
# IPv6 Routing Table - 2 entries
# C   2001:DB8:1::/64 [0/0] via GigabitEthernet0/0
# S   2001:DB8:2::/64 [1/0] via 2001:DB8:1::2

# ping6 expected:
# 64 bytes from 2001:db8:2::1: icmp_seq=1 ttl=64 time=1.23 ms
```

---

## 4. Transport Layer Labs

### Lab 4.1: TCP Three-Way Handshake Analysis

**Objective**: Capture and analyze TCP handshake.

**Duration**: 30 minutes

**Procedure**:

**Step 1**: Start packet capture
```bash
# Capture TCP handshake on port 80
sudo tcpdump -i eth0 "tcp port 80" -w tcp_handshake.pcap
```

**Step 2**: Generate TCP connection
```bash
# Connect to web server
curl -v http://example.com

# Or use telnet
telnet example.com 80
```

**Step 3**: Analyze handshake
```bash
# Show TCP handshake packets
tshark -r tcp_handshake.pcap -Y "tcp.flags.syn == 1 or tcp.flags.ack == 1" \
    -T fields -e frame.time_relative -e tcp.flags -e tcp.seq -e tcp.ack

# Show handshake only
tshark -r tcp_handshake.pcap -Y "tcp.flags.syn == 1" -V

# Follow TCP stream
tshark -r tcp_handshake.pcap -z follow,tcp,hex,0
```

**Step 4**: Calculate RTT
```bash
# Extract SYN and SYN-ACK times
tshark -r tcp_handshake.pcap -Y "tcp.flags.syn == 1" \
    -T fields -e frame.time_relative

# Calculate RTT = SYN-ACK time - SYN time
```

**Step 5**: Analyze TCP options
```bash
# Show TCP options
tshark -r tcp_handshake.pcap -Y "tcp.options" -V | grep -A 20 "Options"
```

**Verification**:
```bash
# Expected handshake:
# Client -> Server: SYN (seq=0)
# Server -> Client: SYN-ACK (seq=0, ack=1)
# Client -> Server: ACK (seq=1, ack=1)

# Expected RTT:
# RTT calculated from handshake
```

### Lab 4.2: TCP Echo Server and Client

**Objective**: Build and test TCP echo server.

**Duration**: 45 minutes

**Procedure**:

**Step 1**: Create TCP echo server
```python
#!/usr/bin/env python3
"""
tcp_echo_server_lab.py - TCP echo server with timing
"""

import socket
import time
import threading

class TCPEchoServer:
    def __init__(self, host='0.0.0.0', port=8080):
        self.host = host
        self.port = port
        self.socket = None
        self.running = False
        self.connections = []
        self.stats = {'bytes': 0, 'connections': 0}
    
    def start(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind((self.host, self.port))
        self.socket.listen(5)
        self.running = True
        
        print(f"Echo Server started on {self.host}:{self.port}")
        
        while self.running:
            try:
                client, addr = self.socket.accept()
                thread = threading.Thread(target=self.handle_client, args=(client, addr))
                thread.start()
                self.connections.append(thread)
                self.stats['connections'] += 1
                print(f"Connection from {addr[0]}:{addr[1]}")
            except:
                break
    
    def handle_client(self, client, addr):
        try:
            while True:
                data = client.recv(1024)
                if not data:
                    break
                self.stats['bytes'] += len(data)
                client.send(data)
        except:
            pass
        finally:
            client.close()
            print(f"Connection from {addr[0]}:{addr[1]} closed")
    
    def stop(self):
        self.running = False
        if self.socket:
            self.socket.close()
        print(f"Stats: {self.stats['bytes']} bytes, {self.stats['connections']} connections")

if __name__ == "__main__":
    server = TCPEchoServer()
    try:
        server.start()
    except KeyboardInterrupt:
        server.stop()
```

**Step 2**: Create TCP echo client
```python
#!/usr/bin/env python3
"""
tcp_echo_client_lab.py - TCP echo client
"""

import socket
import time
import sys

class TCPEchoClient:
    def __init__(self, host='localhost', port=8080):
        self.host = host
        self.port = port
        self.socket = None
    
    def connect(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.connect((self.host, self.port))
        print(f"Connected to {self.host}:{self.port}")
    
    def echo(self, message, count=1):
        start = time.time()
        
        for i in range(count):
            self.socket.send(message.encode())
            data = self.socket.recv(1024)
        
        end = time.time()
        return end - start
    
    def close(self):
        self.socket.close()

if __name__ == "__main__":
    client = TCPEchoClient()
    client.connect()
    
    # Test with different message sizes
    sizes = [16, 64, 256, 1024, 4096]
    for size in sizes:
        msg = 'X' * size
        elapsed = client.echo(msg, 100)
        print(f"Size: {size} bytes, Time: {elapsed:.3f}s, Rate: {size*100/elapsed/1024:.1f} KB/s")
    
    client.close()
```

**Step 3**: Test server performance
```bash
# Start server in one terminal
python3 tcp_echo_server_lab.py

# Test with client
python3 tcp_echo_client_lab.py

# Use netcat
echo "Hello" | nc localhost 8080

# Use telnet
telnet localhost 8080
```

**Verification**:
```bash
# Expected server output:
# Echo Server started on 0.0.0.0:8080
# Connection from 127.0.0.1:54321
# Stats: 40960 bytes, 1 connections

# Expected client output:
# Connected to localhost:8080
# Size: 16 bytes, Time: 0.123s, Rate: 12.3 KB/s
```

### Lab 4.3: UDP Echo Server and Client

**Objective**: Build and test UDP echo server.

**Duration**: 30 minutes

**Procedure**:

**Step 1**: Create UDP echo server
```python
#!/usr/bin/env python3
"""
udp_echo_server_lab.py - UDP echo server
"""

import socket
import time

class UDPEchoServer:
    def __init__(self, host='0.0.0.0', port=8081):
        self.host = host
        self.port = port
        self.socket = None
        self.running = False
        self.stats = {'bytes': 0, 'packets': 0}
    
    def start(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind((self.host, self.port))
        self.running = True
        
        print(f"UDP Echo Server started on {self.host}:{self.port}")
        
        while self.running:
            try:
                data, addr = self.socket.recvfrom(4096)
                self.stats['bytes'] += len(data)
                self.stats['packets'] += 1
                self.socket.sendto(data, addr)
                print(f"Echoed {len(data)} bytes to {addr[0]}:{addr[1]}")
            except:
                break
    
    def stop(self):
        self.running = False
        if self.socket:
            self.socket.close()
        print(f"Stats: {self.stats['packets']} packets, {self.stats['bytes']} bytes")

if __name__ == "__main__":
    server = UDPEchoServer()
    try:
        server.start()
    except KeyboardInterrupt:
        server.stop()
```

**Step 2**: Create UDP echo client
```python
#!/usr/bin/env python3
"""
udp_echo_client_lab.py - UDP echo client
"""

import socket
import time

class UDPEchoClient:
    def __init__(self, host='localhost', port=8081):
        self.host = host
        self.port = port
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.settimeout(2.0)
    
    def echo(self, message):
        self.socket.sendto(message.encode(), (self.host, self.port))
        data, _ = self.socket.recvfrom(4096)
        return data.decode()

if __name__ == "__main__":
    client = UDPEchoClient()
    
    # Test with different message sizes
    sizes = [16, 64, 256, 1024, 4096]
    for size in sizes:
        msg = 'X' * size
        start = time.time()
        response = client.echo(msg)
        elapsed = time.time() - start
        print(f"Size: {size} bytes, Time: {elapsed:.3f}s, Rate: {size/elapsed/1024:.1f} KB/s")
```

**Verification**:
```bash
# Expected UDP server output:
# UDP Echo Server started on 0.0.0.0:8081
# Echoed 1024 bytes to 127.0.0.1:54321

# Expected UDP client output:
# Size: 16 bytes, Time: 0.001s, Rate: 15.6 KB/s
```

---

## 5. Application Layer Labs

### Lab 5.1: DNS Lookup and Resolution

**Objective**: Perform and analyze DNS lookups.

**Duration**: 30 minutes

**Procedure**:

**Step 1**: Perform basic lookups
```bash
# A record lookup
dig example.com
dig google.com A

# AAAA record lookup
dig google.com AAAA

# MX record lookup
dig gmail.com MX

# NS record lookup
dig example.com NS

# TXT record lookup
dig example.com TXT

# Any record type
dig example.com ANY
```

**Step 2**: Use nslookup
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

**Step 3**: Trace DNS resolution
```bash
# Trace full resolution
dig +trace example.com

# Trace to specific DNS server
dig @8.8.8.8 example.com
dig @1.1.1.1 example.com

# Show query times
dig +stats example.com
```

**Step 4**: DNS capture and analysis
```bash
# Capture DNS traffic
sudo tcpdump -i eth0 "udp port 53" -w dns_lab.pcap

# Generate DNS queries
dig example.com
dig google.com
dig gmail.com

# Analyze capture
tshark -r dns_lab.pcap -Y "dns" -T fields \
    -e dns.qry.name -e dns.qry.type -e dns.resp.name

# Show DNS queries
tshark -r dns_lab.pcap -Y "dns.flags.response == 0" \
    -T fields -e dns.qry.name

# Show DNS responses
tshark -r dns_lab.pcap -Y "dns.flags.response == 1" \
    -T fields -e dns.resp.name
```

**Step 5**: Python DNS client
```python
#!/usr/bin/env python3
"""
dns_lookup.py - DNS lookup tool
"""

import dns.resolver
import sys

def lookup(domain, record_type='A', dns_server=None):
    resolver = dns.resolver.Resolver()
    if dns_server:
        resolver.nameservers = [dns_server]
    
    try:
        answers = resolver.resolve(domain, record_type)
        for answer in answers:
            print(f"{domain} {record_type} {answer}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: dns_lookup.py <domain> [record_type] [dns_server]")
        sys.exit(1)
    
    domain = sys.argv[1]
    record_type = sys.argv[2] if len(sys.argv) > 2 else 'A'
    dns_server = sys.argv[3] if len(sys.argv) > 3 else None
    
    lookup(domain, record_type, dns_server)
```

**Verification**:
```bash
# Expected DNS output:
# google.com. 300 IN A 142.250.185.46
# google.com. 300 IN AAAA 2607:f8b0:4004:804::200e
# gmail.com. 3600 IN MX 5 gmail-smtp-in.l.google.com.
# example.com. 86400 IN NS a.iana-servers.net.
```

### Lab 5.2: HTTP Request/Response Analysis

**Objective**: Capture and analyze HTTP communication.

**Duration**: 45 minutes

**Procedure**:

**Step 1**: Capture HTTP traffic
```bash
# Capture HTTP on port 80
sudo tcpdump -i eth0 "tcp port 80" -w http_lab.pcap

# Generate HTTP traffic
curl -v http://example.com
curl -v -H "User-Agent: LabClient" http://example.com
```

**Step 2**: Analyze HTTP requests
```bash
# Show HTTP requests
tshark -r http_lab.pcap -Y "http.request" -V

# Extract specific fields
tshark -r http_lab.pcap -Y "http.request" -T fields \
    -e http.request.method \
    -e http.request.uri \
    -e http.host \
    -e http.user_agent

# Show HTTP headers
tshark -r http_lab.pcap -Y "http.request" -V | grep -A 20 "Line-based"
```

**Step 3**: Analyze HTTP responses
```bash
# Show HTTP responses
tshark -r http_lab.pcap -Y "http.response" -V

# Extract status codes
tshark -r http_lab.pcap -Y "http.response" -T fields \
    -e http.response.code \
    -e http.content_type \
    -e http.content_length

# Show response headers
tshark -r http_lab.pcap -Y "http.response" -V | grep -A 20 "Line-based"
```

**Step 4**: Follow HTTP stream
```bash
# Follow TCP stream
tshark -r http_lab.pcap -z follow,tcp,hex,0

# Show complete conversation
tshark -r http_lab.pcap -q -z follow,tcp,text,0
```

**Step 5**: Python HTTP client
```python
#!/usr/bin/env python3
"""
http_client_lab.py - HTTP client with analysis
"""

import http.client
import time

class HTTPClient:
    def __init__(self, host):
        self.host = host
        self.connection = None
    
    def get(self, path, headers=None):
        if not headers:
            headers = {}
        
        # Add default headers
        headers['User-Agent'] = 'LabClient/1.0'
        
        # Create connection
        self.connection = http.client.HTTPConnection(self.host)
        
        # Send request
        start = time.time()
        self.connection.request('GET', path, headers=headers)
        response = self.connection.getresponse()
        elapsed = time.time() - start
        
        # Read response
        data = response.read()
        
        # Display results
        print(f"Request: GET {path}")
        print(f"Status: {response.status} {response.reason}")
        print(f"Response Time: {elapsed:.3f}s")
        print(f"Size: {len(data)} bytes")
        print(f"Headers: {dict(response.getheaders())}")
        
        return {
            'status': response.status,
            'headers': dict(response.getheaders()),
            'body': data[:200],
            'time': elapsed
        }
    
    def close(self):
        if self.connection:
            self.connection.close()

if __name__ == "__main__":
    # Test HTTP client
    client = HTTPClient('example.com')
    
    # Basic GET
    client.get('/')
    
    # GET with custom headers
    client.get('/', {'X-Test': 'Hello', 'Accept': 'text/plain'})
    
    client.close()
```

**Verification**:
```bash
# Expected HTTP output:
# Request: GET /
# Status: 200 OK
# Response Time: 0.123s
# Size: 1256 bytes
# Headers: {'Content-Type': 'text/html', ...}
```

### Lab 5.3: Simple HTTP Server

**Objective**: Build a basic HTTP server.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Create HTTP server
```python
#!/usr/bin/env python3
"""
http_server_lab.py - Simple HTTP server
"""

import socket
import os
import datetime
import threading

class HTTPServer:
    def __init__(self, host='0.0.0.0', port=8080, root='./www'):
        self.host = host
        self.port = port
        self.root = root
        self.socket = None
        self.running = False
        
        # Create root directory
        os.makedirs(root, exist_ok=True)
        self.create_test_files()
    
    def create_test_files(self):
        """Create test files for the server"""
        # index.html
        with open(os.path.join(self.root, 'index.html'), 'w') as f:
            f.write("""
<!DOCTYPE html>
<html>
<head><title>HTTP Server</title></head>
<body>
<h1>Welcome to the HTTP Server!</h1>
<p>This is a test page.</p>
</body>
</html>
""")
        
        # test.txt
        with open(os.path.join(self.root, 'test.txt'), 'w') as f:
            f.write("Hello, World!\nThis is a test file.")
        
        # api endpoint
        with open(os.path.join(self.root, 'api.txt'), 'w') as f:
            f.write('{"status": "ok", "message": "API endpoint"}')
    
    def start(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind((self.host, self.port))
        self.socket.listen(5)
        self.running = True
        
        print(f"HTTP Server started on http://{self.host}:{self.port}")
        print(f"Root directory: {os.path.abspath(self.root)}")
        
        while self.running:
            try:
                client, addr = self.socket.accept()
                thread = threading.Thread(target=self.handle_client, args=(client, addr))
                thread.start()
            except:
                break
    
    def handle_client(self, client, addr):
        try:
            # Read request
            data = client.recv(4096)
            if not data:
                client.close()
                return
            
            # Parse request
            request = data.decode('utf-8', errors='ignore')
            lines = request.split('\r\n')
            
            if not lines:
                client.close()
                return
            
            # Parse request line
            parts = lines[0].split(' ')
            if len(parts) < 3:
                client.close()
                return
            
            method, path, version = parts
            
            # Handle only GET
            if method != 'GET':
                self.send_error(client, 405, 'Method Not Allowed')
                client.close()
                return
            
            # Security: Prevent directory traversal
            if '..' in path:
                self.send_error(client, 403, 'Forbidden')
                client.close()
                return
            
            # Determine file path
            if path == '/':
                path = '/index.html'
            
            file_path = os.path.join(self.root, path[1:])
            
            # Handle API endpoint
            if path == '/api':
                response = {
                    'time': datetime.datetime.now().isoformat(),
                    'method': method,
                    'path': path,
                    'status': 'ok'
                }
                import json
                self.send_response(client, 200, 'application/json', json.dumps(response).encode())
                client.close()
                return
            
            # Serve static file
            if not os.path.exists(file_path):
                self.send_error(client, 404, 'Not Found')
                client.close()
                return
            
            if os.path.isdir(file_path):
                self.send_error(client, 403, 'Forbidden')
                client.close()
                return
            
            # Read file
            with open(file_path, 'rb') as f:
                content = f.read()
            
            # Determine content type
            if file_path.endswith('.html'):
                content_type = 'text/html'
            elif file_path.endswith('.txt'):
                content_type = 'text/plain'
            elif file_path.endswith('.json'):
                content_type = 'application/json'
            else:
                content_type = 'application/octet-stream'
            
            # Send response
            self.send_response(client, 200, content_type, content)
            client.close()
            
        except Exception as e:
            print(f"Error: {e}")
            client.close()
    
    def send_response(self, client, status, content_type, content):
        status_line = f"HTTP/1.1 {status} OK\r\n"
        headers = f"Content-Type: {content_type}\r\n"
        headers += f"Content-Length: {len(content)}\r\n"
        headers += f"Server: PythonHTTPServer/1.0\r\n"
        headers += f"Date: {datetime.datetime.now().strftime('%a, %d %b %Y %H:%M:%S GMT')}\r\n"
        headers += "\r\n"
        
        client.send(status_line.encode())
        client.send(headers.encode())
        client.send(content)
    
    def send_error(self, client, code, message):
        body = f"<html><body><h1>{code} {message}</h1><p>Error</p></body></html>"
        self.send_response(client, code, 'text/html', body.encode())
    
    def stop(self):
        self.running = False
        if self.socket:
            self.socket.close()

if __name__ == "__main__":
    server = HTTPServer()
    try:
        server.start()
    except KeyboardInterrupt:
        server.stop()
        print("Server stopped")
```

**Step 2**: Test the HTTP server
```bash
# Start server
python3 http_server_lab.py

# Test in another terminal
curl -v http://localhost:8080/
curl -v http://localhost:8080/test.txt
curl -v http://localhost:8080/api

# Create a test file
echo "Test content" > www/test.html
curl -v http://localhost:8080/test.html

# Browser test
open http://localhost:8080/
```

**Verification**:
```bash
# Expected curl output:
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 1256
# Server: PythonHTTPServer/1.0
# Date: Mon, 01 Jan 2024 12:00:00 GMT

# <!DOCTYPE html>
# <html>
# <head><title>HTTP Server</title></head>
# <body>
# <h1>Welcome to the HTTP Server!</h1>
# ...
```

---

## 6. Security Labs

### Lab 6.1: TLS Handshake Analysis

**Objective**: Capture and analyze TLS handshake.

**Duration**: 45 minutes

**Procedure**:

**Step 1**: Capture TLS traffic
```bash
# Capture HTTPS traffic
sudo tcpdump -i eth0 "tcp port 443" -w tls_lab.pcap

# Generate TLS traffic
curl -v https://www.google.com
openssl s_client -connect google.com:443
```

**Step 2**: Analyze TLS handshake
```bash
# Show TLS handshake messages
tshark -r tls_lab.pcap -Y "tls.handshake" -V

# Extract ClientHello
tshark -r tls_lab.pcap -Y "tls.handshake.type == 1" -V

# Extract ServerHello
tshark -r tls_lab.pcap -Y "tls.handshake.type == 2" -V

# Show cipher suites
tshark -r tls_lab.pcap -Y "tls.handshake.ciphersuite" \
    -T fields -e tls.handshake.ciphersuite
```

**Step 3**: Analyze certificate
```bash
# Extract certificate
tshark -r tls_lab.pcap -Y "tls.handshake.certificate" -V | grep -A 50 "Certificate"

# Show certificate details
openssl s_client -showcerts -connect google.com:443 </dev/null
```

**Step 4**: Decrypt TLS with keylog
```bash
# Set keylog environment
export SSLKEYLOGFILE=~/tls_keys.log

# Browse HTTPS site
curl -v https://www.google.com

# Analyze with keylog
tshark -r tls_lab.pcap -o tls.keylog_file:~/tls_keys.log \
    -Y "http2" -T fields -e http2.headers
```

**Step 5**: Test TLS configuration
```bash
# Test TLS version support
openssl s_client -connect google.com:443 -tls1_3
openssl s_client -connect google.com:443 -tls1_2

# Test cipher suites
openssl s_client -connect google.com:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384'

# Show certificate chain
openssl s_client -showcerts -connect google.com:443 </dev/null
```

**Verification**:
```bash
# Expected TLS handshake:
# ClientHello
# ServerHello
# Certificate
# ServerKeyExchange
# ServerHelloDone
# ClientKeyExchange
# ChangeCipherSpec
# Finished

# Expected cipher suites:
# TLS_AES_256_GCM_SHA384
# TLS_CHACHA20_POLY1305_SHA256
# TLS_AES_128_GCM_SHA256
```

### Lab 6.2: Network Scanning

**Objective**: Perform network scanning and analyze results.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Scan with nmap
```bash
# Ping scan
sudo nmap -sn 192.168.1.0/24

# TCP SYN scan (default)
sudo nmap -sS 192.168.1.1

# TCP connect scan
sudo nmap -sT 192.168.1.1

# UDP scan
sudo nmap -sU -p 53,67,68,123,161 192.168.1.1

# OS detection
sudo nmap -O 192.168.1.1

# Service version detection
sudo nmap -sV 192.168.1.1

# Full port scan
sudo nmap -p- 192.168.1.1
```

**Step 2**: Scan specific ports
```bash
# Common ports
sudo nmap -p 21,22,23,25,53,80,110,143,443,445,993,995,3306,3389,5432,8080 192.168.1.1

# Range of ports
sudo nmap -p 1-1000 192.168.1.1

# Multiple ranges
sudo nmap -p 1-100,200-300,443,8080 192.168.1.1
```

**Step 3**: Advanced scanning
```bash
# Idle scan (stealth)
sudo nmap -sI 192.168.1.100 192.168.1.1

# FIN scan
sudo nmap -sF 192.168.1.1

# Xmas scan
sudo nmap -sX 192.168.1.1

# ACK scan
sudo nmap -sA 192.168.1.1

# Window scan
sudo nmap -sW 192.168.1.1

# RPC scan
sudo nmap -sR 192.168.1.1
```

**Step 4**: Analyze scan results
```bash
# Show open ports
nmap -p 1-1000 192.168.1.1 | grep open

# Export to XML
sudo nmap -sS -sV -oX scan_results.xml 192.168.1.1

# Parse XML
sudo nmap -sS -sV -oN scan_results.txt 192.168.1.1

# Grep for specific services
nmap 192.168.1.1 | grep -E "http|ssh|https"
```

**Step 5**: Python port scanner
```python
#!/usr/bin/env python3
"""
port_scanner_lab.py - Simple port scanner
"""

import socket
import threading
import queue
import time

class PortScanner:
    def __init__(self, target, threads=100):
        self.target = target
        self.threads = threads
        self.open_ports = []
        self.queue = queue.Queue()
    
    def scan_port(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.5)
            result = sock.connect_ex((self.target, port))
            sock.close()
            if result == 0:
                self.open_ports.append(port)
                print(f"Port {port} is open")
        except:
            pass
    
    def worker(self):
        while not self.queue.empty():
            port = self.queue.get()
            self.scan_port(port)
            self.queue.task_done()
    
    def scan(self, start=1, end=1024):
        start_time = time.time()
        
        # Queue ports
        for port in range(start, end + 1):
            self.queue.put(port)
        
        # Start threads
        for _ in range(self.threads):
            thread = threading.Thread(target=self.worker)
            thread.start()
        
        # Wait for completion
        self.queue.join()
        
        elapsed = time.time() - start_time
        print(f"Scan completed in {elapsed:.2f} seconds")
        print(f"Open ports: {sorted(self.open_ports)}")

if __name__ == "__main__":
    target = input("Enter target IP: ")
    scanner = PortScanner(target)
    scanner.scan()
```

**Verification**:
```bash
# Expected nmap output:
# Starting Nmap 7.80 ( https://nmap.org ) at 2024-01-01 12:00
# Nmap scan report for 192.168.1.1
# Host is up (0.0012s latency).
# Not shown: 997 closed ports
# PORT     STATE SERVICE
# 22/tcp   open  ssh
# 80/tcp   open  http
# 443/tcp  open  https

# Open ports: [22, 80, 443]
```

---

## 7. Modern Protocol Labs

### Lab 7.1: HTTP/2 and HTTP/3 Comparison

**Objective**: Compare performance of HTTP/2 and HTTP/3.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Install HTTP/2 tools
```bash
# Install h2load (HTTP/2 load tester)
sudo apt-get install nghttp2-client

# Install curl with HTTP/2 support
curl --version | grep http2
```

**Step 2**: Test HTTP/2
```bash
# Check HTTP/2 support
curl --http2 -I https://www.google.com

# Download with HTTP/2
curl --http2 -o /dev/null -s -w "HTTP/2: %{time_total}s\n" https://www.google.com

# Performance comparison
for i in {1..10}; do
    curl --http2 -o /dev/null -s -w "%{time_total}\n" https://www.google.com
done | awk '{sum+=$1} END {print "HTTP/2 avg: " sum/NR}'
```

**Step 3**: Test HTTP/3
```bash
# Install curl with HTTP/3 support
sudo apt-get install nghttp3
sudo apt-get install libnghttp3-dev

# Build curl with HTTP/3 support
# Or use a pre-built version

# Test HTTP/3
curl --http3 -I https://www.google.com

# Download with HTTP/3
curl --http3 -o /dev/null -s -w "HTTP/3: %{time_total}s\n" https://www.google.com
```

**Step 4**: Performance comparison script
```python
#!/usr/bin/env python3
"""
http_compare.py - Compare HTTP/2 vs HTTP/3
"""

import subprocess
import time
import sys

def test_http(version, url, count=5):
    times = []
    
    for i in range(count):
        cmd = ['curl', '-o', '/dev/null', '-s', '-w', '%{time_total}']
        if version == '2':
            cmd.append('--http2')
        elif version == '3':
            cmd.append('--http3')
        cmd.append(url)
        
        start = time.time()
        result = subprocess.run(cmd, capture_output=True, text=True)
        elapsed = time.time() - start
        
        try:
            times.append(float(result.stdout.strip()))
        except:
            pass
        
        time.sleep(0.5)
    
    if times:
        return sum(times) / len(times), min(times), max(times)
    return None, None, None

def main():
    url = sys.argv[1] if len(sys.argv) > 1 else "https://www.google.com"
    
    print(f"Testing URL: {url}")
    print("=" * 60)
    
    # Test HTTP/2
    print("HTTP/2:")
    avg, min_t, max_t = test_http('2', url)
    if avg:
        print(f"  Avg: {avg:.3f}s")
        print(f"  Min: {min_t:.3f}s")
        print(f"  Max: {max_t:.3f}s")
    else:
        print("  Not supported")
    
    print()
    
    # Test HTTP/3
    print("HTTP/3:")
    avg, min_t, max_t = test_http('3', url)
    if avg:
        print(f"  Avg: {avg:.3f}s")
        print(f"  Min: {min_t:.3f}s")
        print(f"  Max: {max_t:.3f}s")
    else:
        print("  Not supported")

if __name__ == "__main__":
    main()
```

**Verification**:
```bash
# Expected output:
# HTTP/2:
#   Avg: 0.123s
#   Min: 0.112s
#   Max: 0.145s
#
# HTTP/3:
#   Avg: 0.089s
#   Min: 0.078s
#   Max: 0.098s
```

### Lab 7.2: QUIC Connection Analysis

**Objective**: Capture and analyze QUIC connections.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Capture QUIC traffic
```bash
# Capture QUIC (UDP port 443)
sudo tcpdump -i eth0 "udp port 443" -w quic_lab.pcap

# Generate QUIC traffic
curl --http3 https://www.google.com
```

**Step 2**: Analyze QUIC packets
```bash
# Show QUIC packets
tshark -r quic_lab.pcap -Y "quic" -V

# Show QUIC handshake
tshark -r quic_lab.pcap -Y "quic.long_packet_type == 0" -V
tshark -r quic_lab.pcap -Y "quic.long_packet_type == 2" -V

# Show QUIC streams
tshark -r quic_lab.pcap -Y "quic.stream" -T fields -e quic.stream_id -e quic.stream_offset
```

**Step 3**: QUIC analysis script
```python
#!/usr/bin/env python3
"""
quic_analyzer.py - Analyze QUIC traffic
"""

import sys
from scapy.all import rdpcap, UDP, Raw

def analyze_quic(pcap_file):
    packets = rdpcap(pcap_file)
    
    quic_packets = []
    for packet in packets:
        if UDP in packet and packet[UDP].dport == 443:
            quic_packets.append(packet)
    
    print(f"Found {len(quic_packets)} QUIC packets")
    
    # Analyze connection IDs
    connection_ids = {}
    for packet in quic_packets[:20]:
        if Raw in packet:
            data = packet[Raw].load
            if len(data) > 4:
                # First byte indicates long/short header
                header_type = data[0] >> 6
                version = data[1:5]
                if version == b'\x00\x00\x00\x01':
                    print(f"QUIC v1 packet - {len(data)} bytes")
                    # Extract connection ID
                    if len(data) > 5:
                        dcid_len = data[5]
                        if len(data) > 6 + dcid_len:
                            dcid = data[6:6+dcid_len]
                            connection_ids[dcid] = connection_ids.get(dcid, 0) + 1
    
    print("\nConnection IDs:")
    for cid, count in connection_ids.items():
        print(f"  {cid.hex()}: {count} packets")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    analyze_quic(sys.argv[1])
```

**Verification**:
```bash
# Expected output:
# Found 234 QUIC packets
# QUIC v1 packet - 1234 bytes
# QUIC v1 packet - 1024 bytes
# QUIC v1 packet - 2048 bytes

# Connection IDs:
#   0x1234567890abcdef: 45 packets
#   0xfedcba0987654321: 78 packets
```

---

## 8. Troubleshooting Labs

### Lab 8.1: Network Performance Analysis

**Objective**: Diagnose and analyze network performance issues.

**Duration**: 1 hour

**Procedure**:

**Step 1**: Baseline performance measurement
```bash
# Measure latency
ping -c 100 8.8.8.8 | tee latency_baseline.txt

# Measure packet loss
ping -c 100 -i 0.05 8.8.8.8 | grep loss

# Measure throughput
iperf3 -c <server> -t 30

# Measure path
mtr -r -c 100 8.8.8.8
```

**Step 2**: Latency analysis
```python
#!/usr/bin/env python3
"""
latency_analyzer.py - Analyze latency
"""

import re
import sys
from statistics import mean, median, stdev

def analyze_ping_output(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    times = []
    for line in lines:
        match = re.search(r'time=(\d+\.\d+)', line)
        if match:
            times.append(float(match.group(1)))
    
    if not times:
        print("No ping times found")
        return
    
    print(f"Ping Analysis:")
    print(f"  Samples: {len(times)}")
    print(f"  Min: {min(times):.2f}ms")
    print(f"  Max: {max(times):.2f}ms")
    print(f"  Avg: {mean(times):.2f}ms")
    print(f"  Median: {median(times):.2f}ms")
    print(f"  Std Dev: {stdev(times):.2f}ms")
    
    # Jitter (variation between consecutive pings)
    jitter = []
    for i in range(1, len(times)):
        jitter.append(abs(times[i] - times[i-1]))
    
    if jitter:
        print(f"  Jitter (avg): {mean(jitter):.2f}ms")
        print(f"  Jitter (max): {max(jitter):.2f}ms")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <ping_log>")
        sys.exit(1)
    analyze_ping_output(sys.argv[1])
```

**Step 3**: Bandwidth monitoring
```bash
# Monitor real-time bandwidth
sudo iftop -i eth0

# Monitor per-process bandwidth
sudo nethogs eth0

# Check interface stats
ip -s link show eth0
ethtool -S eth0

# Monitor TCP performance
ss -ti
```

**Step 4**: Packet loss detection
```bash
# Detect packet loss with mtr
mtr -r -c 100 8.8.8.8

# Detect retransmissions
tcpdump -i eth0 "tcp" -vv | grep retransmission

# Analyze TCP retransmissions
tshark -r capture.pcap -Y "tcp.analysis.retransmission"
```

**Verification**:
```bash
# Expected ping analysis:
# Samples: 100
# Min: 12.34ms
# Max: 45.67ms
# Avg: 15.23ms
# Median: 14.56ms
# Std Dev: 3.21ms
# Jitter (avg): 2.34ms
# Jitter (max): 8.90ms
```

### Lab 8.2: DNS Troubleshooting

**Objective**: Diagnose and resolve DNS issues.

**Duration**: 45 minutes

**Procedure**:

**Step 1**: DNS connectivity check
```bash
# Test DNS server reachability
ping -c 4 8.8.8.8
ping -c 4 1.1.1.1

# Test DNS query
dig @8.8.8.8 google.com
dig @1.1.1.1 google.com

# Check local DNS configuration
cat /etc/resolv.conf
systemd-resolve --status
```

**Step 2**: DNS resolution analysis
```bash
# Trace full resolution
dig +trace google.com

# Check specific record types
dig google.com A
dig google.com AAAA
dig google.com MX
dig google.com NS

# Check reverse DNS
dig -x 8.8.8.8
```

**Step 3**: DNS cache analysis
```bash
# Check DNS cache
systemd-resolve --statistics
systemd-resolve --cache=yes google.com

# Flush DNS cache
sudo systemd-resolve --flush-caches

# Check cache status
sudo systemd-resolve --statistics
```

**Step 4**: DNS troubleshooting script
```python
#!/usr/bin/env python3
"""
dns_troubleshoot.py - DNS troubleshooting tool
"""

import dns.resolver
import socket
import time
import sys

def troubleshoot_dns(domain):
    print(f"Troubleshooting DNS for {domain}")
    print("=" * 60)
    
    # Test 1: Basic resolution
    print("\n1. Basic A record resolution:")
    resolver = dns.resolver.Resolver()
    try:
        answers = resolver.resolve(domain, 'A')
        for answer in answers:
            print(f"  {domain} -> {answer}")
    except Exception as e:
        print(f"  Error: {e}")
    
    # Test 2: Specific DNS servers
    print("\n2. Testing with different DNS servers:")
    dns_servers = ['8.8.8.8', '1.1.1.1', '9.9.9.9']
    for server in dns_servers:
        resolver.nameservers = [server]
        try:
            start = time.time()
            answers = resolver.resolve(domain, 'A')
            elapsed = time.time() - start
            print(f"  {server}: {answers[0]} ({elapsed:.3f}s)")
        except Exception as e:
            print(f"  {server}: Failed ({e})")
    
    # Test 3: Record types
    print("\n3. Record type check:")
    record_types = ['A', 'AAAA', 'MX', 'NS', 'TXT']
    resolver.nameservers = ['8.8.8.8']
    for rtype in record_types:
        try:
            answers = resolver.resolve(domain, rtype)
            print(f"  {rtype}: {len(answers)} records")
        except:
            print(f"  {rtype}: No records")
    
    # Test 4: DNSSEC
    print("\n4. DNSSEC check:")
    try:
        resolver.resolve(domain, 'A', want_dnssec=True)
        print("  DNSSEC: Supported")
    except:
        print("  DNSSEC: Not supported or enabled")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <domain>")
        sys.exit(1)
    troubleshoot_dns(sys.argv[1])
```

**Verification**:
```bash
# Expected output:
# 1. Basic A record resolution:
#   google.com -> 142.250.185.46

# 2. Testing with different DNS servers:
#   8.8.8.8: 142.250.185.46 (0.012s)
#   1.1.1.1: 142.250.185.46 (0.015s)

# 3. Record type check:
#   A: 1 records
#   AAAA: 1 records
#   MX: 5 records
#   NS: 4 records
#   TXT: 2 records
```

---

## 9. Capstone Project

### Project: Complete Network Monitoring System

**Objective**: Build a comprehensive network monitoring system.

**Duration**: 4-6 hours

**Components**:
1. Network discovery
2. Device monitoring
3. Traffic analysis
4. Alert system
5. Web dashboard

**Implementation**:

**Step 1**: Network Discovery Module
```python
#!/usr/bin/env python3
"""
discovery.py - Network discovery module
"""

import socket
import nmap
from scapy.all import ARP, Ether, srp

class NetworkDiscovery:
    def __init__(self, network='192.168.1.0/24'):
        self.network = network
        self.devices = []
    
    def arp_scan(self):
        """ARP scan for devices"""
        arp = ARP(pdst=self.network)
        ether = Ether(dst="ff:ff:ff:ff:ff:ff")
        packet = ether / arp
        
        result = srp(packet, timeout=3, verbose=0)[0]
        
        devices = []
        for sent, received in result:
            devices.append({
                'ip': received.psrc,
                'mac': received.hwsrc,
                'status': 'up'
            })
        
        return devices
    
    def nmap_scan(self):
        """NMAP scan for services"""
        nm = nmap.PortScanner()
        nm.scan(hosts=self.network, arguments='-sS -sV -T4')
        
        devices = []
        for host in nm.all_hosts():
            if nm[host].state() == 'up':
                device = {
                    'ip': host,
                    'status': 'up',
                    'ports': []
                }
                
                for proto in nm[host].all_protocols():
                    for port in nm[host][proto].keys():
                        if nm[host][proto][port]['state'] == 'open':
                            device['ports'].append({
                                'port': port,
                                'protocol': proto,
                                'service': nm[host][proto][port]['name']
                            })
                
                devices.append(device)
        
        return devices
    
    def discover(self):
        """Full network discovery"""
        print("Discovering network...")
        devices = self.arp_scan()
        print(f"Found {len(devices)} devices")
        self.devices = devices
        return devices
```

**Step 2**: Monitoring Module
```python
#!/usr/bin/env python3
"""
monitor.py - Device monitoring module
"""

import ping3
import time
import threading
from datetime import datetime

class Monitor:
    def __init__(self):
        self.devices = []
        self.status = {}
        self.running = False
    
    def add_device(self, device):
        self.devices.append(device)
        self.status[device['ip']] = {
            'status': 'unknown',
            'last_check': None,
            'uptime': 0,
            'latency': None,
            'history': []
        }
    
    def check_device(self, device):
        """Check a single device"""
        try:
            latency = ping3.ping(device['ip'], timeout=2)
            
            if latency is not None:
                status = 'up'
                if self.status[device['ip']]['status'] == 'down':
                    self.status[device['ip']]['uptime'] = 0
            else:
                status = 'down'
            
            # Update status
            self.status[device['ip']]['status'] = status
            self.status[device['ip']]['last_check'] = datetime.now()
            self.status[device['ip']]['latency'] = latency
            
            # Update history
            self.status[device['ip']]['history'].append({
                'timestamp': datetime.now(),
                'status': status,
                'latency': latency
            })
            
            # Keep last 100 entries
            if len(self.status[device['ip']]['history']) > 100:
                self.status[device['ip']]['history'] = self.status[device['ip']]['history'][-100:]
            
        except Exception as e:
            print(f"Error checking {device['ip']}: {e}")
    
    def monitor_loop(self):
        """Main monitoring loop"""
        while self.running:
            for device in self.devices:
                self.check_device(device)
            time.sleep(60)  # Check every 60 seconds
    
    def start(self):
        """Start monitoring"""
        self.running = True
        thread = threading.Thread(target=self.monitor_loop)
        thread.start()
        print("Monitoring started")
    
    def stop(self):
        """Stop monitoring"""
        self.running = False
        print("Monitoring stopped")
    
    def get_status(self):
        """Get current status"""
        status = {}
        for ip, data in self.status.items():
            status[ip] = {
                'status': data['status'],
                'latency': data['latency'],
                'last_check': data['last_check'].isoformat() if data['last_check'] else None,
                'uptime': data['uptime']
            }
        return status
```

**Step 3**: Alert System Module
```python
#!/usr/bin/env python3
"""
alert.py - Alert system module
"""

import smtplib
import json
from email.mime.text import MIMEText

class AlertSystem:
    def __init__(self, config_file='alert_config.json'):
        self.config = self.load_config(config_file)
        self.alerts = []
    
    def load_config(self, config_file):
        default_config = {
            'email': {
                'enabled': False,
                'smtp_server': 'smtp.gmail.com',
                'smtp_port': 587,
                'username': '',
                'password': '',
                'from': '',
                'to': []
            },
            'slack': {
                'enabled': False,
                'webhook_url': ''
            }
        }
        
        try:
            with open(config_file, 'r') as f:
                config = json.load(f)
                for key in default_config:
                    if key not in config:
                        config[key] = default_config[key]
                return config
        except:
            return default_config
    
    def check_thresholds(self, status_data):
        """Check if alerts should be triggered"""
        alerts = []
        
        for ip, data in status_data.items():
            if data['status'] == 'down':
                alerts.append({
                    'severity': 'critical',
                    'message': f"Device {ip} is down!",
                    'timestamp': datetime.now()
                })
            elif data.get('latency') and data['latency'] > 100:
                alerts.append({
                    'severity': 'warning',
                    'message': f"Device {ip} latency is high ({data['latency']:.2f}ms)",
                    'timestamp': datetime.now()
                })
        
        self.alerts.extend(alerts)
        return alerts
    
    def send_email_alert(self, alert):
        """Send email alert"""
        if not self.config['email']['enabled']:
            return
        
        msg = MIMEText(f"Alert: {alert['message']}\nTimestamp: {alert['timestamp']}")
        msg['Subject'] = f"Network Alert: {alert['severity']}"
        msg['From'] = self.config['email']['from']
        msg['To'] = ', '.join(self.config['email']['to'])
        
        try:
            server = smtplib.SMTP(self.config['email']['smtp_server'], self.config['email']['smtp_port'])
            server.starttls()
            server.login(self.config['email']['username'], self.config['email']['password'])
            server.send_message(msg)
            server.quit()
            print(f"Email alert sent: {alert['message']}")
        except Exception as e:
            print(f"Error sending email: {e}")
    
    def send_alert(self, alert):
        """Send alert through configured channels"""
        if self.config['email']['enabled']:
            self.send_email_alert(alert)
    
    def get_alerts(self):
        """Get all alerts"""
        return self.alerts
```

**Step 4**: Web Dashboard Module
```python
#!/usr/bin/env python3
"""
dashboard.py - Web dashboard module
"""

from flask import Flask, render_template, jsonify
import json
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    """Home page"""
    return render_template('dashboard.html')

@app.route('/api/status')
def get_status():
    """Get status API endpoint"""
    # Get status from monitor
    status = monitor.get_status()
    return jsonify(status)

@app.route('/api/alerts')
def get_alerts():
    """Get alerts API endpoint"""
    # Get alerts from alert system
    alerts = alert_system.get_alerts()
    return jsonify(alerts)

@app.route('/api/devices')
def get_devices():
    """Get devices API endpoint"""
    devices = []
    for device in monitor.devices:
        devices.append({
            'ip': device['ip'],
            'status': monitor.status[device['ip']]['status']
        })
    return jsonify(devices)

def run_dashboard(monitor_instance, alert_instance):
    """Run the dashboard"""
    global monitor, alert_system
    monitor = monitor_instance
    alert_system = alert_instance
    app.run(host='0.0.0.0', port=5000, debug=False)
```

**Step 5: Dashboard HTML Template**
```html
<!-- templates/dashboard.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Network Monitor</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .device { display: inline-block; margin: 10px; padding: 10px; border: 1px solid #ccc; }
        .up { border-color: green; background: #e8f5e9; }
        .down { border-color: red; background: #ffebee; }
        .unknown { border-color: gray; background: #f5f5f5; }
        .alert { background: #fff3e0; padding: 10px; margin: 10px 0; border-left: 4px solid #ff9800; }
        .critical { border-left-color: #f44336; }
        .warning { border-left-color: #ff9800; }
        #alerts { margin-top: 20px; }
        #status { margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Network Monitor</h1>
    
    <div id="status">
        <h2>Device Status</h2>
        <div id="devices"></div>
    </div>
    
    <div id="alerts">
        <h2>Alerts</h2>
        <div id="alerts-list"></div>
    </div>
    
    <script>
        function updateStatus() {
            fetch('/api/status')
                .then(response => response.json())
                .then(data => {
                    let html = '';
                    for (const [ip, info] of Object.entries(data)) {
                        const statusClass = info.status;
                        html += `
                            <div class="device ${statusClass}">
                                <strong>${ip}</strong><br>
                                Status: ${info.status}<br>
                                Latency: ${info.latency ? info.latency.toFixed(2) + 'ms' : 'N/A'}<br>
                                Last Check: ${info.last_check ? new Date(info.last_check).toLocaleTimeString() : 'Never'}
                            </div>
                        `;
                    }
                    document.getElementById('devices').innerHTML = html;
                });
        }
        
        function updateAlerts() {
            fetch('/api/alerts')
                .then(response => response.json())
                .then(data => {
                    let html = '';
                    data.forEach(alert => {
                        html += `
                            <div class="alert ${alert.severity}">
                                <strong>${alert.severity.toUpperCase()}</strong>
                                ${alert.message}
                                <br><small>${new Date(alert.timestamp).toLocaleString()}</small>
                            </div>
                        `;
                    });
                    document.getElementById('alerts-list').innerHTML = html || 'No alerts';
                });
        }
        
        // Update every 10 seconds
        updateStatus();
        updateAlerts();
        setInterval(updateStatus, 10000);
        setInterval(updateAlerts, 10000);
    </script>
</body>
</html>
```

**Step 6: Main Application**
```python
#!/usr/bin/env python3
"""
main.py - Main network monitoring application
"""

import sys
import threading
from discovery import NetworkDiscovery
from monitor import Monitor
from alert import AlertSystem
from dashboard import run_dashboard

def main():
    print("Network Monitoring System")
    print("=" * 60)
    
    # Step 1: Discover network
    discovery = NetworkDiscovery()
    devices = discovery.discover()
    
    # Step 2: Initialize monitor
    monitor = Monitor()
    for device in devices:
        monitor.add_device(device)
    
    # Step 3: Initialize alert system
    alert_system = AlertSystem()
    
    # Step 4: Start monitoring
    monitor.start()
    
    # Step 5: Start dashboard
    print("Starting web dashboard on http://localhost:5000")
    run_dashboard(monitor, alert_system)

if __name__ == "__main__":
    main()
```

**Verification**:
```bash
# Expected output:
# Network Monitoring System
# ============================================================
# Discovering network...
# Found 12 devices
# Monitoring started
# Starting web dashboard on http://localhost:5000

# Access dashboard at http://localhost:5000
# Expected to see:
# - List of devices with status
# - Alerts when devices go down
# - Latency information
# - Real-time updates
```

---

## Summary

This workbook provides comprehensive hands-on labs covering:

1. **Physical Layer**: Cable testing, interface configuration, WiFi analysis
2. **Data Link Layer**: ARP analysis, VLAN configuration, Ethernet decoding
3. **Network Layer**: Subnetting, routing, IPv6 configuration
4. **Transport Layer**: TCP/UDP programming, handshake analysis
5. **Application Layer**: DNS, HTTP, server implementation
6. **Security Labs**: TLS analysis, network scanning
7. **Modern Protocols**: HTTP/2, HTTP/3, QUIC analysis
8. **Troubleshooting**: Performance analysis, DNS troubleshooting
9. **Capstone**: Complete network monitoring system

**Key Takeaways**:
- Practice reinforces understanding
- Real-world scenarios build practical skills
- Automation reduces manual effort
- Monitoring is essential for network health
- Security must be integrated throughout

**[END OF APPENDIX J]**
