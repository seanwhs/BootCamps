# Appendix D: Network Troubleshooting Reference

## Comprehensive Troubleshooting Guide for Network Engineers and Developers

---

## Overview

This appendix provides a complete reference for diagnosing and resolving common network issues. It covers systematic troubleshooting approaches, diagnostic tools, and specific resolution procedures for each layer of the network stack.

**Purpose**: Serve as an on-the-job reference for network engineers, system administrators, and developers when facing network problems.

**Organization**: Organized by the OSI/TCP/IP layers, mirroring the series structure, with a focus on practical diagnostics and proven solutions.

---

## Table of Contents

1. [Troubleshooting Methodology](#1-troubleshooting-methodology)
2. [Physical Layer Troubleshooting](#2-physical-layer-troubleshooting)
3. [Data Link Layer Troubleshooting](#3-data-link-layer-troubleshooting)
4. [Network Layer Troubleshooting](#4-network-layer-troubleshooting)
5. [Transport Layer Troubleshooting](#5-transport-layer-troubleshooting)
6. [Application Layer Troubleshooting](#6-application-layer-troubleshooting)
7. [Common Issues and Solutions](#7-common-issues-and-solutions)
8. [Diagnostic Tools Reference](#8-diagnostic-tools-reference)
9. [Scenario-Based Troubleshooting](#9-scenario-based-troubleshooting)
10. [Performance Optimization](#10-performance-optimization)

---

## 1. Troubleshooting Methodology

### The OSI Troubleshooting Approach

```
┌─────────────────────────────────────────────────────────────┐
│                  OSI TROUBLESHOOTING FLOW                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Start at Layer 1 (Physical) and work up                   │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Layer 7: Application                              │    │
│  │ ├─ Can the application connect?                   │    │
│  │ └─ Is the service running?                       │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Layer 6: Presentation                            │    │
│  │ ├─ Is data being encoded/decoded correctly?      │    │
│  │ └─ Are encryption/compression working?           │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Layer 5: Session                                 │    │
│  │ ├─ Are sessions being established?                │    │
│  │ └─ Is authentication working?                    │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Layer 4: Transport                               │    │
│  │ ├─ Are ports reachable?                          │    │
│  │ ├─ Are firewalls blocking?                      │    │
│  │ └─ Are there retransmissions?                   │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Layer 3: Network                                 │    │
│  │ ├─ Is the IP address correct?                    │    │
│  │ ├─ Is the default gateway reachable?             │    │
│  │ └─ Is routing working?                           │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Layer 2: Data Link                               │    │
│  │ ├─ Is ARP working?                               │    │
│  │ ├─ Are MAC addresses correct?                    │    │
│  │ └─ Is the switch forwarding?                    │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Layer 1: Physical                                │    │
│  │ ├─ Are cables connected?                         │    │
│  │ ├─ Are link lights on?                           │    │
│  │ └─ Is there signal?                              │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### The Troubleshooting Process

**1. Define the Problem**
- What is failing?
- When did it start?
- Is it intermittent or consistent?
- Is it affecting one user or many?

**2. Gather Information**
- System logs
- Network captures
- Error messages
- Configuration changes
- Recent updates

**3. Isolate the Issue**
- Test at each OSI layer
- Use binary search (half-split method)
- Reproduce the issue in a controlled environment

**4. Identify the Root Cause**
- Look for patterns
- Check for known issues
- Verify assumptions

**5. Implement a Solution**
- Test in a non-production environment
- Document the change
- Monitor for recurrence

**6. Document the Resolution**
- Update knowledge base
- Share with team
- Update monitoring systems

### The Half-Split Method

```
┌─────────────────────────────────────────────────────────────┐
│                    HALF-SPLIT TROUBLESHOOTING               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Is it a client or server issue?                       │
│     ├─ Client side: Check local configuration            │
│     └─ Server side: Check service and logs               │
│                                                             │
│  2. Is it a network issue?                                │
│     ├─ Yes: Move to network diagnostics                  │
│     └─ No: Check application layer                       │
│                                                             │
│  3. Is it a local or remote issue?                       │
│     ├─ Local: Check switching, ARP, DHCP                 │
│     └─ Remote: Check routing, firewalls, DNS             │
│                                                             │
│  4. Is it a hardware or software issue?                   │
│     ├─ Hardware: Check cables, NICs, switches            │
│     └─ Software: Check configuration, services, patches  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Physical Layer Troubleshooting

### Common Physical Layer Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **Cable Failure** | No link light, intermittent connectivity | Check cable with cable tester | Replace cable |
| **Wrong Cable Type** | Link but no traffic, errors | Check cable category | Use correct cable |
| **Connector Damage** | Intermittent connectivity | Visual inspection | Replace connector |
| **Distance Exceeded** | Packet loss, errors | Check cable length | Use repeater/switch |
| **Interference** | Errors, retransmissions | Check environment | Shield cable, move |
| **NIC Failure** | No link, errors | Check other devices | Replace NIC |
| **Port Failure** | No link on specific port | Test with known good cable | Change port |
| **Power Issue** | Device not responding | Check power indicators | Restart device |

### Physical Layer Diagnostic Commands

```bash
# Check network interface status
ethtool eth0
ip link show eth0
ifconfig eth0

# Check for errors
ethtool -S eth0
netstat -i

# Check cable connection
ethtool -p eth0  # Blink LED

# Check link speed and duplex
ethtool eth0 | grep -E "Speed|Duplex"

# Check for dropped packets
ifconfig eth0 | grep -E "RX|TX" | grep -E "errors|dropped"

# Check MAC address
ip link show eth0 | grep link/ether

# Check physical connection
ping -c 3 -I eth0 192.168.1.1
```

### WiFi Troubleshooting

```bash
# Check WiFi interface
iwconfig

# Scan for networks
iwlist scan wlan0

# Check signal strength
iwconfig wlan0 | grep Signal

# Check connection status
iw dev wlan0 link

# Check for interference
# Look for other networks on same channel
iwlist scan | grep -E "ESSID|Channel"

# Check WiFi errors
dmesg | grep -i wifi
journalctl -u NetworkManager -f
```

---

## 3. Data Link Layer Troubleshooting

### Common Data Link Layer Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **ARP Cache Poisoning** | Intermittent connectivity, MITM | Check ARP cache | Clear ARP cache |
| **MAC Address Conflict** | Intermittent connectivity | Check MAC addresses | Change MAC address |
| **VLAN Mismatch** | No connectivity to some hosts | Check VLAN configuration | Fix VLAN assignment |
| **Switch Loop** | Broadcast storm, high CPU | Check for loops | Enable STP |
| **Frame Errors** | CRC errors, packet loss | Check FCS errors | Bad cable/port |
| **MAC Table Full** | Flooding, poor performance | Check MAC table size | Upgrade switch |
| **Broadcast Storm** | Network slow, high utilization | Check broadcast rate | Find source |
| **Duplex Mismatch** | High collisions, errors | Check duplex settings | Force matching mode |

### Data Link Layer Diagnostic Commands

```bash
# ARP diagnostics
arp -a                              # Show ARP cache
arp -d <ip>                         # Clear ARP entry
arp -s <ip> <mac>                   # Static ARP entry
ip neigh show                       # Show neighbor table
ip neigh flush all                  # Clear ARP cache

# MAC address diagnostics
ip link set dev eth0 address <mac>  # Change MAC address
macchanger -s eth0                  # Show MAC address

# Bridge/Switch diagnostics
brctl show                          # Show bridges
brctl showmacs <bridge>             # Show MAC table
brctl showstp <bridge>              # Show STP status

# Frame statistics
ethtool -S eth0                     # Show statistics
ip -s link show eth0                # Show interface stats

# VLAN diagnostics
ip link add link eth0 name eth0.10 type vlan id 10
ip link show eth0.10
vlan show

# Port mirroring (tcpdump on specific VLAN)
tcpdump -i eth0 vlan 10
```

### ARP Troubleshooting Script

```bash
#!/bin/bash
# arp_troubleshooter.sh - Diagnose ARP issues

echo "===== ARP Troubleshooter ====="

# Show ARP cache
echo -e "\n1. ARP Cache:"
arp -a

# Check gateway reachability
GATEWAY=$(ip route | grep default | awk '{print $3}')
echo -e "\n2. Gateway: $GATEWAY"
ping -c 3 $GATEWAY

# Check ARP for gateway
echo -e "\n3. ARP for gateway:"
arp -a | grep $GATEWAY

# Check for duplicate IPs
echo -e "\n4. Checking for duplicate IPs:"
for ip in $(arp -a | awk '{print $1}' | sort -u); do
    macs=$(arp -a | grep $ip | awk '{print $3}' | sort -u | wc -l)
    if [ $macs -gt 1 ]; then
        echo "  Duplicate IP: $ip has $macs MACs"
        arp -a | grep $ip
    fi
done

# Gratuitous ARP check
echo -e "\n5. Recent ARP activity:"
tcpdump -i any -c 10 arp
```

---

## 4. Network Layer Troubleshooting

### Common Network Layer Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **IP Address Conflict** | Intermittent connectivity | Check logs, ARP table | Change IP |
| **Wrong Subnet Mask** | Some hosts unreachable | Check netmask | Correct netmask |
| **No Default Gateway** | Can't reach outside network | Check routing table | Add gateway |
| **Routing Loop** | TTL expired, ping fails | Traceroute | Fix routing |
| **NAT Issues** | Can't access some services | Check NAT table | Correct NAT rules |
| **IP Fragmentation** | Performance issues, MTU errors | Check ICMP needs fragmentation | Fix MTU |
| **TTL Exceeded** | Traceroute fails, loops | Traceroute | Fix routing |
| **ICMP Blocked** | Ping fails, but service works | Check firewall | Allow ICMP |

### Network Layer Diagnostic Commands

```bash
# IP configuration
ip addr show                       # Show IP addresses
ifconfig                           # Show IP addresses
ip route show                      # Show routing table
route -n                           # Show routing table (numeric)

# Connectivity tests
ping -c 4 <target>                 # Basic ping
ping -c 4 -I eth0 <target>         # Ping from specific interface
ping -c 4 -s 1472 <target>         # Ping with specific size
ping -c 4 -M do -s 1472 <target>   # Ping with DF flag set

# Path tracing
traceroute -n <target>            # Trace route
traceroute -I <target>            # Use ICMP
traceroute -T -p 80 <target>      # Use TCP SYN (port 80)
mtr -n <target>                   # Continuous traceroute

# Routing diagnostics
ip route get <ip>                 # Route lookup
ip route add default via <gateway> # Add default route
ip route del default              # Delete default route

# IPv6 diagnostics
ip -6 addr show
ip -6 route show
ping6 -c 4 <target>
traceroute6 -n <target>
```

### IP Conflict Detection Script

```bash
#!/bin/bash
# ip_conflict.sh - Detect IP address conflicts

echo "===== IP Conflict Detector ====="

# Get local IP
LOCAL_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1)

# Find network
NETWORK=$(ip route | grep $LOCAL_IP | awk '{print $1}')

echo "Local IP: $LOCAL_IP"
echo "Network: $NETWORK"
echo "Scanning for conflicts..."

# Send ARP requests and check for duplicate responses
sudo arp-scan --local --interface eth0 | grep -v "DUP"

# Alternative: Use arping
for ip in $(nmap -sn $NETWORK | grep "Nmap scan" | awk '{print $5}'); do
    macs=$(arping -c 3 $ip 2>/dev/null | grep "reply from" | awk '{print $5}' | sort -u | wc -l)
    if [ $macs -gt 1 ]; then
        echo "Conflict detected for $ip"
    fi
done

echo -e "\nCheck complete."
```

---

## 5. Transport Layer Troubleshooting

### Common Transport Layer Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **Port Blocking** | Connection refused/timeout | Check firewall, netstat | Open port |
| **Connection Refused** | RST received | Service not listening | Start service |
| **Connection Timeout** | No response | Firewall, network issues | Check path |
| **High Retransmissions** | Slow performance | TCP analysis | Network issues |
| **Zero Window** | Connection stalls | TCP window analysis | Increase buffers |
| **TCP SYN Flood** | Can't establish connections | Check SYN rate | Rate limiting |
| **NAT Issues** | Can't establish connections | Check NAT tables | Fix NAT |
| **UDP Packet Loss** | Application issues | Check UDP stats | Increase buffers |

### Transport Layer Diagnostic Commands

```bash
# TCP connection diagnostics
netstat -tulpn                        # Show listening ports
ss -tulpn                              # Show listening ports (modern)
netstat -tn                            # TCP connections
netstat -tnp                           # TCP connections with process
ss -tnp                               # TCP connections with process

# Connection state counts
netstat -tan | awk '{print $6}' | sort | uniq -c | sort -nr

# Port scanning
nmap -p 80 <target>                  # Scan specific port
nmap -p- <target>                    # Scan all ports
nmap -sU -p 53 <target>              # Scan UDP port

# Connection testing
telnet <host> <port>                 # Test TCP connection
nc -zv <host> <port>                 # Test TCP connection
nc -zvu <host> <port>                # Test UDP connection

# TCP statistics
netstat -s                            # TCP statistics
ss -s                                # Summary statistics

# TCP dump for specific port
tcpdump -i eth0 port 80
tcpdump -i eth0 tcp port 443

# Follow TCP connection
tcpdump -i eth0 -A "tcp and host <ip>"

# Connection tracking
conntrack -L                         # Show connection table
conntrack -L -p tcp --state ESTABLISHED
```

### TCP Window Troubleshooting

```python
#!/usr/bin/env python3
"""
tcp_window_analyzer.py - Analyze TCP window behavior
"""

import sys
from scapy.all import rdpcap, TCP, IP

def analyze_tcp_window(filename):
    """Analyze TCP window behavior from pcap"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    tcp_packets = [p for p in packets if TCP in p]
    
    if not tcp_packets:
        print("No TCP packets found")
        return
    
    print("TCP Window Analysis")
    print("=" * 60)
    
    # Track windows per connection
    windows = {}
    zero_windows = 0
    window_scaling = 0
    
    for packet in tcp_packets:
        ip = packet[IP]
        tcp = packet[TCP]
        conn = f"{ip.src}:{tcp.sport}->{ip.dst}:{tcp.dport}"
        
        # Track window
        if conn not in windows:
            windows[conn] = {'windows': [], 'scaling': 0, 'zero_count': 0}
        
        windows[conn]['windows'].append(tcp.window)
        
        if tcp.window == 0:
            windows[conn]['zero_count'] += 1
            zero_windows += 1
        
        # Check for window scaling
        if hasattr(tcp, 'options'):
            for option in tcp.options:
                if option[0] == 'WScale':
                    windows[conn]['scaling'] = option[1]
                    window_scaling += 1
    
    print(f"Total TCP packets: {len(tcp_packets)}")
    print(f"Connections tracked: {len(windows)}")
    print(f"Zero window events: {zero_windows}")
    print(f"Connections with window scaling: {window_scaling}")
    
    print("\nConnections:")
    for conn, data in windows.items():
        if data['windows']:
            avg_window = sum(data['windows']) / len(data['windows'])
            max_window = max(data['windows'])
            min_window = min(data['windows'])
            
            print(f"  {conn}")
            print(f"    Average Window: {avg_window:.0f}")
            print(f"    Max Window: {max_window}")
            print(f"    Min Window: {min_window}")
            print(f"    Zero Events: {data['zero_count']}")
            if data['scaling'] > 0:
                print(f"    Window Scaling: {data['scaling']} (effective: {data['scaling'] * 65536})")
            print()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    analyze_tcp_window(sys.argv[1])
```

---

## 6. Application Layer Troubleshooting

### Common Application Layer Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **DNS Resolution Failure** | Can't resolve hostnames | Check DNS | Fix DNS |
| **HTTP 404** | Page not found | Check URL, path | Fix path |
| **HTTP 403** | Access denied | Check permissions | Fix permissions |
| **HTTP 500** | Server error | Check logs | Fix application |
| **TLS Certificate Error** | HTTPS warnings | Check certificate | Fix certificate |
| **TLS Handshake Failure** | Can't connect | Check cipher suites | Update configuration |
| **SMTP Relay Denied** | Can't send email | Check relay settings | Configure relay |
| **Authentication Failure** | Login fails | Check credentials | Reset password |

### Application Layer Diagnostic Commands

```bash
# DNS diagnostics
dig <domain>                         # Basic lookup
dig +trace <domain>                  # Full trace
nslookup <domain>                    # Lookup
nslookup <domain> 8.8.8.8           # Lookup with specific DNS
host -v <domain>                     # Verbose lookup

# HTTP diagnostics
curl -v http://<domain>              # Verbose HTTP request
curl -I http://<domain>              # Headers only
curl -w "@curl-format.txt" http://<domain>  # With formatting
httping -c 10 http://<domain>        # HTTP ping

# TLS diagnostics
openssl s_client -connect <domain>:443  # TLS connection
openssl s_client -showcerts -connect <domain>:443
openssl x509 -in cert.pem -text -noout  # View certificate

# SMTP diagnostics
telnet <smtp-server> 25              # SMTP connection
openssl s_client -starttls smtp -connect <smtp-server>:587

# POP3 diagnostics
telnet <pop3-server> 110
openssl s_client -connect <pop3-server>:995

# IMAP diagnostics
telnet <imap-server> 143
openssl s_client -connect <imap-server>:993

# System logs
journalctl -u <service>              # View service logs
tail -f /var/log/<service>.log       # Follow service log
grep -i error /var/log/*.log         # Find errors in logs
```

### HTTP Performance Analysis Script

```bash
#!/bin/bash
# http_performance.sh - Analyze HTTP performance

echo "===== HTTP Performance Analyzer ====="

URL="$1"
if [ -z "$URL" ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

echo "Testing: $URL"
echo

# DNS lookup time
echo "1. DNS Lookup:"
dig +stats "$(echo $URL | awk -F/ '{print $3}')" | grep "Query time"

# TCP connection time
echo -e "\n2. TCP Connection:"
curl -o /dev/null -s -w "TCP Connect: %{time_connect}s\n" $URL

# TLS handshake time (if HTTPS)
if [[ $URL == https://* ]]; then
    echo -e "\n3. TLS Handshake:"
    curl -o /dev/null -s -w "TLS Handshake: %{time_appconnect}s\n" $URL
fi

# Time to first byte
echo -e "\n4. Time to First Byte:"
curl -o /dev/null -s -w "TTFB: %{time_starttransfer}s\n" $URL

# Total download time
echo -e "\n5. Total Download:"
curl -o /dev/null -s -w "Total: %{time_total}s\n" $URL

# Detailed timing
echo -e "\n6. Detailed Timing:"
curl -o /dev/null -s -w @- $URL <<'EOF'
    namelookup: %{time_namelookup}s
    connect:    %{time_connect}s
    appconnect: %{time_appconnect}s
    pretransfer: %{time_pretransfer}s
    redirect:   %{time_redirect}s
    starttransfer: %{time_starttransfer}s
    total:      %{time_total}s
EOF

# HTTP status
echo -e "\n7. HTTP Status:"
curl -I -s $URL | head -1
```

---

## 7. Common Issues and Solutions

### DNS Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **No DNS Resolution** | Can't ping hostname | dig hostname | Check DNS servers |
| **Wrong IP Resolved** | Host resolves to wrong IP | dig hostname | Check DNS records |
| **DNS Timeout** | Slow resolution | dig +stats | Check DNS server response |
| **NXDOMAIN** | Host doesn't exist | dig hostname | Check domain spelling |
| **DNS Cache Poisoning** | Wrong IP resolved | dig +trace | Flush cache, DNSSEC |

**DNS Troubleshooting Commands**:
```bash
# Find current DNS servers
cat /etc/resolv.conf
systemd-resolve --status

# Test DNS resolution
dig @8.8.8.8 example.com
nslookup example.com 1.1.1.1

# Trace full resolution path
dig +trace example.com

# Check reverse DNS
dig -x 8.8.8.8

# Flush DNS cache
sudo systemd-resolve --flush-caches  # Linux
sudo killall -HUP mDNSResponder        # macOS
ipconfig /flushdns                    # Windows

# Check DNS record types
dig example.com A
dig example.com AAAA
dig example.com MX
dig example.com TXT
```

### Connectivity Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **No Connectivity** | Can't ping anything | ip addr, ping | Check interface, cable |
| **Local Only** | Can't reach internet | ping gateway, traceroute | Check default gateway |
| **Some Hosts Unreachable** | Partial connectivity | ping, traceroute, route | Check routing |
| **Intermittent** | Works sometimes | ping -f, continuous ping | Check for flapping |
| **Slow** | High latency | ping, traceroute | Check for congestion |

**Connectivity Troubleshooting Commands**:
```bash
# Basic connectivity test
ping -c 4 8.8.8.8

# Continuous ping with timestamps
ping -D -i 0.5 8.8.8.8

# Check routing
ip route get 8.8.8.8
traceroute -n 8.8.8.8

# Check interface status
ip link show eth0
ethtool eth0

# Check for packet loss
mtr -r -c 100 8.8.8.8

# TCP connectivity test
nc -zv google.com 80
telnet google.com 80

# Check all interfaces
ip addr
ip route
```

### Performance Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **High Latency** | Slow response | ping, traceroute | Check network path |
| **Packet Loss** | Retransmissions | ping, tcpdump | Check physical layer |
| **Bandwidth Saturation** | Slow network | iftop, nethogs | Identify top talkers |
| **Bufferbloat** | High latency under load | ping with load | QoS, buffer settings |
| **MTU Issues** | Some sites fail | ping -M do | Fix MTU |

**Performance Troubleshooting Commands**:
```bash
# Measure latency
ping -c 10 8.8.8.8

# Measure jitter
ping -c 100 -i 0.1 8.8.8.8 | grep "time=" | awk -F'=' '{print $4}' | sort -n

# Check bandwidth
iperf3 -c <server> -p 5201
iperf3 -c <server> -p 5201 -u -b 100M

# Identify top talkers
sudo iftop -i eth0
sudo nethogs eth0

# Check network utilization
sudo bmon
sudo nload

# Check for MTU issues
ping -M do -s 1472 8.8.8.8
ping -M do -s 1500 8.8.8.8

# Check socket buffers
sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.ipv4.tcp_mem

# Adjust buffer sizes
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
```

### Firewall Issues

| Issue | Symptoms | Diagnosis | Solution |
|-------|----------|-----------|----------|
| **Port Blocked** | Connection timeout | telnet, nc | Open port |
| **ICMP Blocked** | Ping fails | ping, traceroute | Allow ICMP |
| **NAT Issues** | Some traffic blocked | conntrack | Fix NAT rules |
| **Stateful Firewall** | Connection reset | tcpdump | Check state |
| **Load Balancer** | Intermittent issues | traceroute, tcpdump | Check health checks |

**Firewall Troubleshooting Commands**:
```bash
# Check iptables rules
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v

# Check firewall status
sudo ufw status
sudo firewall-cmd --list-all

# Check connection tracking
sudo conntrack -L -n
sudo conntrack -L -p tcp --state ESTABLISHED

# Monitor dropped packets
sudo iptables -L -n -v | grep DROP
sudo watch -n 1 'iptables -L -n -v | grep DROP'

# Test with curl
curl -v -I http://example.com
curl --interface eth0 -v -I http://example.com

# Test with nc
nc -zv example.com 80
nc -zvu example.com 53
```

---

## 8. Diagnostic Tools Reference

### Command-Line Tools

| Tool | Purpose | Example |
|------|---------|---------|
| **ping** | Test connectivity | `ping 8.8.8.8` |
| **traceroute** | Trace path | `traceroute 8.8.8.8` |
| **mtr** | Combined ping/traceroute | `mtr 8.8.8.8` |
| **nslookup** | DNS lookup | `nslookup example.com` |
| **dig** | DNS lookup (detailed) | `dig example.com` |
| **host** | DNS lookup | `host example.com` |
| **curl** | HTTP/HTTPS requests | `curl -I example.com` |
| **wget** | HTTP/HTTPS downloads | `wget -d example.com` |
| **openssl** | TLS/SSL diagnostics | `openssl s_client -connect host:443` |
| **telnet** | TCP connection test | `telnet host 80` |
| **nc (netcat)** | TCP/UDP connection test | `nc -zv host 80` |
| **nmap** | Port scanning | `nmap -p 80 host` |
| **tcpdump** | Packet capture | `tcpdump -i eth0` |
| **tshark** | Packet analysis | `tshark -r capture.pcap` |
| **ss** | Socket statistics | `ss -tulpn` |
| **netstat** | Network statistics | `netstat -tulpn` |
| **ip** | IP configuration | `ip addr show` |
| **ifconfig** | Interface configuration | `ifconfig` |
| **route** | Routing table | `route -n` |
| **arp** | ARP cache | `arp -a` |
| **iptables** | Firewall rules | `iptables -L` |
| **conntrack** | Connection tracking | `conntrack -L` |
| **ifstat** | Interface statistics | `ifstat -i eth0` |
| **iftop** | Top talkers | `iftop -i eth0` |
| **nethogs** | Process bandwidth | `nethogs eth0` |
| **bmon** | Bandwidth monitor | `bmon` |
| **nload** | Network load | `nload eth0` |
| **iperf3** | Bandwidth measurement | `iperf3 -c server` |
| **speedtest-cli** | Internet speed test | `speedtest-cli` |

### Graphical Tools

| Tool | Purpose |
|------|---------|
| **Wireshark** | Packet analysis |
| **Ettercap** | Network sniffing |
| **Nmap (GUI)** | Port scanning |
| **Wireshark** | Protocol analysis |
| **NetSpot** | WiFi analysis |
| **InSSIDer** | WiFi scanning |
| **Angry IP Scanner** | Network scanning |
| **PingPlotter** | Traceroute visualization |
| **CloudShark** | Online PCAP analysis |
| **PacketTotal** | PCAP analysis |

### Online Tools

| Tool | URL | Purpose |
|------|-----|---------|
| **DNS Check** | dnschecker.org | DNS propagation |
| **MX Toolbox** | mxtoolbox.com | Email diagnostics |
| **WhatsMyIP** | whatsmyip.com | Public IP |
| **Speedtest** | speedtest.net | Bandwidth test |
| **Ping** | ping.eu | Ping test |
| **Traceroute** | traceroute.org | Traceroute |
| **Port Check** | yougetsignal.com/tools/open-ports | Port testing |
| **SSL Check** | ssllabs.com/ssltest | SSL/TLS testing |

---

## 9. Scenario-Based Troubleshooting

### Scenario 1: Cannot Access Website

**Symptom**: User reports "can't access google.com"

**Diagnostic Steps**:

1. **Check local connectivity**:
   ```bash
   ping 8.8.8.8
   ```
   - If successful, network is working

2. **Check DNS resolution**:
   ```bash
   dig google.com
   nslookup google.com
   ```
   - If no response, check DNS configuration

3. **Check HTTP connectivity**:
   ```bash
   curl -v http://google.com
   telnet google.com 80
   ```
   - If connection refused, check firewall

4. **Check HTTPS connectivity**:
   ```bash
   curl -v https://google.com
   openssl s_client -connect google.com:443
   ```
   - If TLS error, check certificates

5. **Check path**:
   ```bash
   traceroute -n google.com
   ```
   - Find where path stops

**Resolution Steps**:

1. If DNS fails: Check /etc/resolv.conf, test with 8.8.8.8
2. If HTTP fails: Check proxy settings, firewall
3. If route fails: Check default gateway, routing
4. If intermittent: Check packet loss with mtr

### Scenario 2: Slow Application Performance

**Symptom**: Database application response time > 5 seconds

**Diagnostic Steps**:

1. **Check basic latency**:
   ```bash
   ping -c 10 dbserver
   mtr -r -c 100 dbserver
   ```
   - Look for packet loss and high latency

2. **Check network utilization**:
   ```bash
   iftop -i eth0
   nethogs eth0
   ```
   - Identify bandwidth consumers

3. **Check TCP retransmissions**:
   ```bash
   tcpdump -i eth0 "host dbserver and tcp" -w db_issue.pcap
   tshark -r db_issue.pcap -Y "tcp.analysis.retransmission"
   ```

4. **Check TCP window size**:
   ```bash
   tshark -r db_issue.pcap -Y "tcp" -T fields -e tcp.window_size
   ```

5. **Check database metrics**:
   - CPU usage
   - Disk I/O
   - Connection pool
   - Query performance

**Resolution Steps**:

1. If high latency: Check physical path, optimize routing
2. If packet loss: Check cables, switches, congestion
3. If retransmissions: Check for packet loss, adjust TCP settings
4. If bandwidth saturation: QoS, rate limiting, upgrades
5. If database issue: Optimize queries, increase cache

### Scenario 3: VPN Connection Fails

**Symptom**: VPN client says "connection failed"

**Diagnostic Steps**:

1. **Check physical connectivity**:
   ```bash
   ping <vpn-server>
   ```

2. **Check VPN port**:
   ```bash
   nc -zv <vpn-server> <vpn-port>
   ```
   - Common ports: 1194 (OpenVPN), 1723 (PPTP), 500/4500 (IPSec)

3. **Check firewall**:
   ```bash
   sudo iptables -L -n -v | grep -E "500|1194|1723"
   ```

4. **Check NAT**:
   ```bash
   sudo conntrack -L | grep -E "500|1194|1723"
   ```

5. **Check VPN logs**:
   ```bash
   tail -f /var/log/openvpn.log
   tail -f /var/log/syslog | grep vpn
   ```

**Resolution Steps**:

1. If port blocked: Open firewall port
2. If NAT issue: Configure port forwarding, allow IPSec passthrough
3. If certificate issue: Renew certificates
4. If authentication issue: Reset credentials
5. If routing issue: Add routes, configure split tunneling

### Scenario 4: VoIP Quality Issues

**Symptom**: Voice calls choppy, delay, echo

**Diagnostic Steps**:

1. **Check network latency**:
   ```bash
   ping -c 100 <voip-server>
   mtr -r -c 100 <voip-server>
   ```
   - VoIP requires < 150ms latency

2. **Check jitter**:
   ```bash
   ping -c 100 -i 0.05 <voip-server>
   ```
   - VoIP requires < 30ms jitter

3. **Check packet loss**:
   ```bash
   ping -c 100 -i 0.05 <voip-server> | grep loss
   ```
   - VoIP requires < 1% loss

4. **Check QoS**:
   ```bash
   # Check if DSCP is being marked
   tcpdump -i eth0 -v "udp port 5060"
   ```

5. **Check codec**:
   - G.711: 64kbps, no compression
   - G.729: 8kbps, compressed
   - G.722: 64kbps, HD voice

**Resolution Steps**:

1. If latency high: Optimize routing, use QoS
2. If jitter high: Implement jitter buffer, QoS
3. If packet loss: Check physical layer, bandwidth
4. If QoS missing: Configure DSCP marking, priority queuing
5. If codec: Use appropriate codec for bandwidth

---

## 10. Performance Optimization

### TCP Optimization

```bash
# TCP tuning parameters
# /etc/sysctl.conf

# Increase TCP buffer sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Increase connection tracking
net.netfilter.nf_conntrack_max = 1048576

# Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3

# Enable BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Increase backlog
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 8192

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1

# Disable TCP slow start after idle
net.ipv4.tcp_slow_start_after_idle = 0
```

### Apply sysctl settings:
```bash
sudo sysctl -p
sudo sysctl -a | grep tcp
```

### Network Interface Optimization

```bash
# Check interface settings
ethtool eth0

# Enable jumbo frames (if supported)
sudo ip link set dev eth0 mtu 9000

# Enable hardware offload
ethtool -K eth0 tx on
ethtool -K eth0 rx on
ethtool -K eth0 gro on
ethtool -K eth0 gso on

# Optimize interrupt coalescing
ethtool -C eth0 rx-usecs 100
ethtool -C eth0 tx-usecs 100

# Set multi-queue (RSS)
ethtool -L eth0 combined 4

# Disable power saving (for performance)
iwconfig wlan0 power off
```

### Application Optimization

| Application | Optimization |
|-------------|--------------|
| **Web Server** | Enable keep-alive, HTTP/2, caching, compression |
| **Database** | Connection pooling, query optimization, caching |
| **Application** | Connection pooling, timeouts, retry logic |
| **Load Balancer** | Health checks, persistence, SSL offload |
| **CDN** | Cache static assets, geographic distribution |
| **Monitoring** | Metrics, alerts, dashboards |

### Troubleshooting Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                  QUICK TROUBLESHOOTING GUIDE               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Is it up?            ping <host>                       │
│  2. Is DNS working?      dig <domain>                      │
│  3. Is the port open?    nc -zv <host> <port>             │
│  4. Is the service up?   curl <url>                        │
│  5. What's the path?     traceroute <host>                │
│  6. Is it fast?          mtr <host>                        │
│  7. What's happening?    tcpdump -i eth0                  │
│  8. Who's talking?       iftop -i eth0                    │
│  9. Any errors?          dmesg | tail                     │
│  10. What changed?       history | tail                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

**[END OF APPENDIX D]**
