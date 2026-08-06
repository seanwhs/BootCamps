# Appendix B: Complete Packet Capture Reference

## Practical Guide to Capturing, Analyzing, and Interpreting Network Traffic

---

## Overview

This appendix provides a comprehensive reference for packet capture and analysis techniques used throughout the series. It covers everything from basic capture commands to advanced Wireshark features, with practical examples for every protocol discussed.

**Purpose**: Serve as a quick reference for network engineers, developers, and security professionals when performing packet analysis.

**Organization**: Organized by tool, with detailed capture recipes for specific protocols and scenarios.

---

## Table of Contents

1. [Packet Capture Tools](#1-packet-capture-tools)
2. [Capture Filters Reference](#2-capture-filters-reference)
3. [Display Filters Reference](#3-display-filters-reference)
4. [Protocol-Specific Capture Recipes](#4-protocol-specific-capture-recipes)
5. [Wireshark Advanced Features](#5-wireshark-advanced-features)
6. [Command-Line Analysis with tshark](#6-command-line-analysis-with-tshark)
7. [Python Packet Processing](#7-python-packet-processing)
8. [Performance Analysis Techniques](#8-performance-analysis-techniques)
9. [Security Analysis Techniques](#9-security-analysis-techniques)
10. [Troubleshooting Scenarios](#10-troubleshooting-scenarios)

---

## 1. Packet Capture Tools

### tcpdump - Command-Line Capture

**Basic Syntax**:
```bash
tcpdump [options] [filter]
```

**Common Options**:

| Option | Description |
|--------|-------------|
| `-i <interface>` | Specify network interface |
| `-c <count>` | Capture only X packets |
| `-s <snaplen>` | Capture bytes per packet (0 = full) |
| `-w <file>` | Write to file (pcap format) |
| `-r <file>` | Read from file |
| `-n` | Don't resolve hostnames |
| `-nn` | Don't resolve hostnames or ports |
| `-v`, `-vv`, `-vvv` | Verbose output levels |
| `-e` | Print link-level headers |
| `-X` | Show hex and ASCII |
| `-A` | Show ASCII only |
| `-q` | Quiet mode |

**Basic Examples**:

```bash
# Capture on eth0
tcpdump -i eth0

# Capture 100 packets
tcpdump -i eth0 -c 100

# Save to file
tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# No hostname resolution
tcpdump -i eth0 -nn

# Verbose output
tcpdump -i eth0 -vvv

# Show hex and ASCII
tcpdump -i eth0 -X

# Capture only headers (no payload)
tcpdump -i eth0 -s 64
```

### Wireshark - GUI Analysis

**Keyboard Shortcuts**:

| Shortcut | Action |
|----------|--------|
| Ctrl+E | Start/Stop capture |
| Ctrl+K | Capture options |
| Ctrl+R | Reload capture file |
| Ctrl+F | Find packet |
| Ctrl+G | Go to packet |
| Ctrl+Alt+Shift+T | Follow TCP stream |
| Ctrl+Alt+Shift+H | Follow HTTP stream |
| Shift+Ctrl+R | Restart capture |
| Ctrl+Shift+S | Save as |
| Ctrl+Shift+E | Export packets |

**Packet Detail Panes**:

| Pane | Description |
|------|-------------|
| **Packet List** | Summary of all packets |
| **Packet Details** | Decoded protocol fields |
| **Packet Bytes** | Raw hex and ASCII |

### tshark - Command-Line Analysis

**Basic Syntax**:
```bash
tshark [options] [filter]
```

**Common Options**:

| Option | Description |
|--------|-------------|
| `-r <file>` | Read from file |
| `-Y <filter>` | Display filter |
| `-T <format>` | Output format (fields, text, ps, etc.) |
| `-e <field>` | Field to display (with -T fields) |
| `-z <statistic>` | Display statistics |
| `-V` | Verbose output |
| `-q` | Quiet mode |
| `-c <count>` | Process only X packets |

**Examples**:

```bash
# Read and display packets
tshark -r capture.pcap

# Apply display filter
tshark -r capture.pcap -Y "tcp.port == 80"

# Show specific fields
tshark -r capture.pcap -T fields -e ip.src -e ip.dst -e tcp.port

# Protocol statistics
tshark -r capture.pcap -z protocol,hierarchy

# IO statistics
tshark -r capture.pcap -z io,stat,1

# Follow TCP stream
tshark -r capture.pcap -z follow,tcp,hex,0
```

### Wireshark Capture Options

**Capture Interfaces** (Linux naming):
- `eth0, eth1, ...` - Ethernet interfaces
- `wlan0, wlan1, ...` - WiFi interfaces
- `lo` - Loopback interface
- `any` - All interfaces

**Common Capture Settings**:

| Setting | Recommendation |
|---------|---------------|
| Buffer size | 2-128 MB |
| Promiscuous mode | Enable for complete capture |
| Snap length | 65535 (full packet) |
| Capture filter | Apply if needed |
| Stop after | 1000-10000 packets |

---

## 2. Capture Filters Reference

### Basic Filters (BPF Syntax)

**Host Filters**:
```bash
# Single host
host 192.168.1.10

# Source host
src host 192.168.1.10

# Destination host
dst host 192.168.1.10

# Multiple hosts
host 192.168.1.10 or host 192.168.1.20
```

**Network Filters**:
```bash
# Network range
net 192.168.1.0/24

# Source network
src net 192.168.1.0/24

# Destination network
dst net 192.168.1.0/24
```

**Port Filters**:
```bash
# Single port
port 80

# Source port
src port 80

# Destination port
dst port 80

# Port range
portrange 1000-2000
```

**Protocol Filters**:
```bash
# Protocol by name
arp
icmp
tcp
udp
ip
ip6
```

**Combined Filters**:
```bash
# Logical operators: and, or, not
host 192.168.1.10 and port 80

# Parentheses for grouping
host 192.168.1.10 and (port 80 or port 443)

# Negation
not arp and not icmp
```

### Protocol-Specific Capture Filters

**ARP**:
```bash
# ARP requests only
arp and arp[6:2] == 1

# ARP replies only
arp and arp[6:2] == 2

# ARP for specific IP
arp host 192.168.1.1
```

**DHCP**:
```bash
# DHCP traffic
port 67 or port 68

# DHCP Discover
port 67 or port 68 and udp[247:1] == 1

# DHCP Offer
port 67 or port 68 and udp[247:1] == 2

# DHCP Request
port 67 or port 68 and udp[247:1] == 3

# DHCP ACK
port 67 or port 68 and udp[247:1] == 5
```

**DNS**:
```bash
# DNS queries
udp port 53

# DNS over TCP
tcp port 53

# Specific domain
udp port 53 and domain name contains "example"

# DNS queries only
udp port 53 and dns[2:1] & 0x80 == 0

# DNS responses only
udp port 53 and dns[2:1] & 0x80 == 0x80
```

**HTTP**:
```bash
# HTTP traffic
tcp port 80

# HTTP GET requests
tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420

# HTTP POST requests
tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354

# HTTP responses
tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x48545450
```

**HTTPS/TLS**:
```bash
# HTTPS traffic
tcp port 443

# TLS ClientHello
tcp port 443 and tcp[((tcp[12:1] & 0xf0) >> 2):1] == 0x16 and tcp[((tcp[12:1] & 0xf0) >> 2)+5:1] == 0x01

# TLS ServerHello
tcp port 443 and tcp[((tcp[12:1] & 0xf0) >> 2):1] == 0x16 and tcp[((tcp[12:1] & 0xf0) >> 2)+5:1] == 0x02
```

**ICMP**:
```bash
# All ICMP
icmp

# Ping (echo request)
icmp[0] == 8

# Ping reply
icmp[0] == 0

# TTL exceeded
icmp[0] == 11

# Destination unreachable
icmp[0] == 3
```

**TCP**:
```bash
# SYN packets
tcp[tcpflags] == tcp-syn

# SYN-ACK packets
tcp[tcpflags] == tcp-syn|tcp-ack

# FIN packets
tcp[tcpflags] == tcp-fin

# RST packets
tcp[tcpflags] == tcp-rst

# ACK packets
tcp[tcpflags] == tcp-ack

# SYN (not ACK)
tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack == 0
```

**IP**:
```bash
# IPv4
ip

# IPv6
ip6

# Specific IP version
ip[0] & 0xf0 == 0x40  # IPv4
ip[0] & 0xf0 == 0x60  # IPv6

# Fragmented packets
ip[6:2] & 0x1fff != 0

# Don't fragment flag
ip[6] & 0x40 != 0
```

---

## 3. Display Filters Reference

### Comparison Operators

| Operator | Description |
|----------|-------------|
| `==` | Equal |
| `!=` | Not equal |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |
| `contains` | Contains substring |
| `matches` | Regular expression |
| `in` | Set membership |

### Logical Operators

| Operator | Description |
|----------|-------------|
| `and` / `&&` | Logical AND |
| `or` / `||` | Logical OR |
| `not` / `!` | Logical NOT |
| `...` | Parentheses for grouping |

### Protocol Filters

**ARP**:
```
arp
arp.opcode == 1              # Request
arp.opcode == 2              # Reply
arp.src.proto_ipv4 == 192.168.1.10
arp.dst.proto_ipv4 == 192.168.1.1
arp.src.hw_mac == 00:11:22:33:44:55
```

**Ethernet**:
```
eth
eth.dst == 00:11:22:33:44:55
eth.src == 00:11:22:33:44:55
eth.dst == ff:ff:ff:ff:ff:ff  # Broadcast
eth.type == 0x0800            # IPv4
eth.type == 0x0806            # ARP
eth.type == 0x86dd            # IPv6
```

**IP**:
```
ip
ip.src == 192.168.1.10
ip.dst == 192.168.1.1
ip.addr == 192.168.1.10
ip.ttl == 64
ip.flags.df == 1
ip.flags.mf == 1
ip.frag_offset > 0
ip.len > 1500
ip.tos == 0x00
ip.proto == 6                  # TCP
ip.proto == 17                 # UDP
ip.proto == 1                  # ICMP
```

**IPv6**:
```
ipv6
ipv6.src == 2001:db8::1
ipv6.dst == 2001:db8::2
ipv6.addr == 2001:db8::1
ipv6.hlim == 64
ipv6.nxt == 6                  # TCP
ipv6.nxt == 17                 # UDP
ipv6.nxt == 58                 # ICMPv6
```

**TCP**:
```
tcp
tcp.port == 80
tcp.srcport == 80
tcp.dstport == 80
tcp.flags.syn == 1
tcp.flags.ack == 1
tcp.flags.fin == 1
tcp.flags.rst == 1
tcp.flags.push == 1
tcp.flags.urg == 1
tcp.seq == 123456789
tcp.ack == 123456789
tcp.window_size > 65535
tcp.len > 0
tcp.analysis.retransmission
tcp.analysis.duplicate_ack
tcp.analysis.rto
tcp.analysis.out_of_order
tcp.analysis.window_full
tcp.analysis.zero_window
tcp.analysis.zero_window_probe
tcp.analysis.window_update
tcp.analysis.ack_lost
```

**UDP**:
```
udp
udp.port == 53
udp.srcport == 53
udp.dstport == 53
udp.length > 512
udp.checksum == 0
```

**HTTP**:
```
http
http.request.method == "GET"
http.request.method == "POST"
http.response.code == 200
http.response.code == 404
http.host == "www.example.com"
http.request.uri == "/index.html"
http.request.uri contains "login"
http.user_agent contains "Chrome"
http.cookie contains "session"
http.content_type == "text/html"
http.content_encoding == "gzip"
http.server contains "Apache"
http.location contains "https"
http.referer contains "google"
```

**HTTP/2**:
```
http2
http2.stream.id == 1
http2.header.name == ":method"
http2.header.value == "GET"
http2.header.value contains "text/html"
http2.settings.enable_push == 1
http2.ping.data != 0
```

**TLS**:
```
tls
tls.handshake.type == 1      # ClientHello
tls.handshake.type == 2      # ServerHello
tls.handshake.type == 11     # Certificate
tls.handshake.type == 16     # KeyUpdate
tls.handshake.type == 20     # Finished
tls.handshake.extensions_server_name contains "example.com"
tls.cipher_suite == 0x1301   # TLS_AES_128_GCM_SHA256
tls.record.content_type == 23  # Application Data
```

**QUIC**:
```
quic
quic.version == 0x00000001
quic.long_packet_type == 0    # Initial
quic.long_packet_type == 1    # 0-RTT
quic.long_packet_type == 2    # Handshake
quic.long_packet_type == 3    # Retry
quic.short_dcid == "..."      # Destination connection ID
```

**DNS**:
```
dns
dns.qry.name == "example.com"
dns.qry.type == 1             # A
dns.qry.type == 28            # AAAA
dns.qry.type == 15            # MX
dns.flags.response == 0       # Query
dns.flags.response == 1       # Response
dns.flags.rcode == 3          # NXDOMAIN
dns.flags.authoritative == 1
dns.resp.type == 1
```

**SMTP**:
```
smtp
smtp.req.command == "HELO"
smtp.req.command == "EHLO"
smtp.req.command == "MAIL"
smtp.req.command == "RCPT"
smtp.req.command == "DATA"
smtp.resp.code == 250
smtp.resp.code == 354
smtp.resp.code == 550
smtp.mail_from contains "example.com"
smtp.rcpt_to contains "example.com"
```

**POP3**:
```
pop
pop.request.command == "USER"
pop.request.command == "PASS"
pop.request.command == "LIST"
pop.request.command == "RETR"
pop.response.code == "+OK"
pop.response.code == "-ERR"
```

**IMAP**:
```
imap
imap.request.command == "LOGIN"
imap.request.command == "SELECT"
imap.request.command == "FETCH"
imap.response.code == "OK"
imap.response.code == "NO"
imap.response.code == "BAD"
```

**SNMP**:
```
snmp
snmp.version == 0               # SNMPv1
snmp.version == 1               # SNMPv2c
snmp.version == 3               # SNMPv3
snmp.pdu.type == 0              # GET
snmp.pdu.type == 1              # GETNEXT
snmp.pdu.type == 2              # RESPONSE
snmp.pdu.type == 3              # SET
snmp.pdu.type == 4              # TRAP
snmp.pdu.type == 5              # GETBULK
snmp.var_bind.value == "..."    # Specific value
```

---

## 4. Protocol-Specific Capture Recipes

### Ethernet Frame Analysis

**Capture**:
```bash
# Capture Ethernet II frames
tcpdump -i eth0 -e -nn -c 100

# Capture VLAN-tagged frames
tcpdump -i eth0 -e -nn -c 100 "vlan"

# Capture only specific MAC
tcpdump -i eth0 -e -nn "ether host 00:11:22:33:44:55"

# Capture broadcast frames
tcpdump -i eth0 -e -nn "ether dst ff:ff:ff:ff:ff:ff"
```

**Analyze**:
```bash
# Show MAC addresses
tshark -r capture.pcap -T fields -e eth.src -e eth.dst

# Show EtherType values
tshark -r capture.pcap -T fields -e eth.type

# Show VLAN tags
tshark -r capture.pcap -Y "vlan" -T fields -e vlan.id -e vlan.priority
```

### ARP Analysis

**Capture**:
```bash
# Capture all ARP traffic
tcpdump -i eth0 -nn arp

# Capture ARP requests
tcpdump -i eth0 -nn "arp and arp[6:2] == 1"

# Capture ARP replies
tcpdump -i eth0 -nn "arp and arp[6:2] == 2"

# Capture ARP for specific IP
tcpdump -i eth0 -nn "arp host 192.168.1.1"

# Capture gratuitous ARP
tcpdump -i eth0 -nn "arp and arp[6:2] == 1 and arp[24:4] == arp[38:4]"
```

**Analyze**:
```bash
# Show all ARP packets
tshark -r capture.pcap -Y "arp"

# Show ARP request/reply details
tshark -r capture.pcap -Y "arp" -T fields -e arp.opcode -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 -e arp.src.hw_mac

# Show only ARP replies with specific IP
tshark -r capture.pcap -Y "arp.dst.proto_ipv4 == 192.168.1.1"

# Show ARP request rate
tshark -r capture.pcap -Y "arp.opcode == 1" -z io,stat,1
```

### DHCP Analysis

**Capture**:
```bash
# Capture all DHCP traffic
tcpdump -i eth0 -nn "port 67 or port 68"

# Capture DHCP Discover
tcpdump -i eth0 -nn "port 67 or port 68 and udp[247:1] == 1"

# Capture DORA sequence
tcpdump -i eth0 -nn "port 67 or port 68 and (udp[247:1] == 1 or udp[247:1] == 2 or udp[247:1] == 3 or udp[247:1] == 5)"
```

**Analyze**:
```bash
# Show DHCP message types
tshark -r capture.pcap -Y "dhcp" -T fields -e dhcp.msgtype -e dhcp.option.dhcp_server -e dhcp.option.router

# Show client MAC addresses
tshark -r capture.pcap -Y "dhcp" -T fields -e dhcp.hwaddr -e dhcp.msgtype

# Show lease duration
tshark -r capture.pcap -Y "dhcp" -T fields -e dhcp.option.lease_time

# Show DORA sequence with timestamps
tshark -r capture.pcap -Y "dhcp" -T fields -e frame.time_relative -e dhcp.msgtype -e ip.src -e ip.dst
```

### DNS Analysis

**Capture**:
```bash
# Capture DNS queries and responses
tcpdump -i eth0 -nn "udp port 53"

# Capture DNS over TCP
tcpdump -i eth0 -nn "tcp port 53"

# Capture DNS queries to specific server
tcpdump -i eth0 -nn "host 8.8.8.8 and port 53"

# Capture specific domain
tcpdump -i eth0 -nn "udp port 53 and domain name contains 'example'"
```

**Analyze**:
```bash
# Show all DNS queries
tshark -r capture.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name -e dns.qry.type

# Show DNS responses
tshark -r capture.pcap -Y "dns.flags.response == 1" -T fields -e dns.resp.name -e dns.a

# Show NXDOMAIN responses
tshark -r capture.pcap -Y "dns.flags.rcode == 3" -T fields -e dns.qry.name

# Show DNS query statistics
tshark -r capture.pcap -Y "dns" -z io,stat,1,dns.qry.name

# Show DNS response time
tshark -r capture.pcap -Y "dns" -z conv,udp
```

### HTTP/HTTPS Analysis

**Capture**:
```bash
# Capture HTTP traffic
tcpdump -i eth0 -nn "tcp port 80"

# Capture HTTPS traffic
tcpdump -i eth0 -nn "tcp port 443"

# Capture both HTTP and HTTPS
tcpdump -i eth0 -nn "tcp port 80 or tcp port 443"

# Capture HTTP GET requests
tcpdump -i eth0 -nn -A "tcp port 80 and tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420"
```

**Analyze**:
```bash
# Show HTTP requests
tshark -r capture.pcap -Y "http.request" -T fields -e http.request.method -e http.request.uri -e http.host -e http.user_agent

# Show HTTP responses
tshark -r capture.pcap -Y "http.response" -T fields -e http.response.code -e http.content_type -e http.content_length -e http.server

# Show URLs with parameters
tshark -r capture.pcap -Y "http.request" -T fields -e http.request.uri -e http.referer

# Show HTTPS/TLS handshakes
tshark -r capture.pcap -Y "tls.handshake" -T fields -e tls.handshake.type -e tls.handshake.extensions_server_name

# Follow HTTP stream
tshark -r capture.pcap -Y "http" -z follow,tcp,hex,0
```

### TCP Analysis

**Capture**:
```bash
# Capture TCP traffic
tcpdump -i eth0 -nn tcp

# Capture SYN packets
tcpdump -i eth0 -nn "tcp[tcpflags] == tcp-syn"

# Capture SYN-ACK packets
tcpdump -i eth0 -nn "tcp[tcpflags] == tcp-syn|tcp-ack"

# Capture RST packets
tcpdump -i eth0 -nn "tcp[tcpflags] == tcp-rst"

# Capture specific port
tcpdump -i eth0 -nn "tcp port 80"
```

**Analyze**:
```bash
# Show TCP handshake
tshark -r capture.pcap -Y "tcp.flags.syn == 1" -T fields -e frame.time_relative -e tcp.flags -e tcp.seq -e tcp.ack

# Show retransmissions
tshark -r capture.pcap -Y "tcp.analysis.retransmission" -T fields -e frame.time_relative -e tcp.srcport -e tcp.dstport -e tcp.seq

# Show duplicate ACKs
tshark -r capture.pcap -Y "tcp.analysis.duplicate_ack" -T fields -e frame.time_relative -e tcp.ack

# Show zero window events
tshark -r capture.pcap -Y "tcp.window_size == 0" -T fields -e frame.time_relative -e tcp.window_size

# Show connection statistics
tshark -r capture.pcap -z conv,tcp

# Show TCP throughput
tshark -r capture.pcap -z io,stat,1,"tcp.port==80"
```

### TLS Analysis

**Capture**:
```bash
# Capture TLS traffic
tcpdump -i eth0 -nn "tcp port 443"

# Capture TLS ClientHello
tcpdump -i eth0 -nn "tcp port 443 and tcp[((tcp[12:1] & 0xf0) >> 2):1] == 0x16"

# Capture TLS certificates
tcpdump -i eth0 -nn "tcp port 443 and tcp[((tcp[12:1] & 0xf0) >> 2):1] == 0x16 and tcp[((tcp[12:1] & 0xf0) >> 2)+5:1] == 0x0b"
```

**Analyze**:
```bash
# Show TLS handshake messages
tshark -r capture.pcap -Y "tls.handshake" -T fields -e tls.handshake.type -e frame.time_relative

# Show server name indication (SNI)
tshark -r capture.pcap -Y "tls.handshake.extensions_server_name" -T fields -e tls.handshake.extensions_server_name

# Show cipher suites offered
tshark -r capture.pcap -Y "tls.handshake.ciphersuite" -T fields -e tls.handshake.ciphersuite

# Show certificate details
tshark -r capture.pcap -Y "tls.handshake.certificate" -V | grep -A 20 "Certificate"

# Show TLS version
tshark -r capture.pcap -Y "tls" -T fields -e tls.record.version
```

### ICMP Analysis

**Capture**:
```bash
# Capture all ICMP
tcpdump -i eth0 -nn icmp

# Capture ping requests
tcpdump -i eth0 -nn "icmp[0] == 8"

# Capture ping replies
tcpdump -i eth0 -nn "icmp[0] == 0"

# Capture TTL exceeded
tcpdump -i eth0 -nn "icmp[0] == 11"

# Capture destination unreachable
tcpdump -i eth0 -nn "icmp[0] == 3"
```

**Analyze**:
```bash
# Show ICMP types
tshark -r capture.pcap -Y "icmp" -T fields -e icmp.type -e icmp.code

# Show ping RTT
tshark -r capture.pcap -Y "icmp.type == 8 or icmp.type == 0" -z conv,ip

# Show TTL exceeded messages
tshark -r capture.pcap -Y "icmp.type == 11" -T fields -e ip.src -e ip.dst

# Show destination unreachable reasons
tshark -r capture.pcap -Y "icmp.type == 3" -T fields -e icmp.code -e ip.src
```

---

## 5. Wireshark Advanced Features

### Following Streams

**TCP Stream**:
```
Right-click packet -> Follow -> TCP Stream

# Shows entire conversation in order
# Can filter to show only that stream
# Can save to file
```

**UDP Stream**:
```
Right-click packet -> Follow -> UDP Stream

# Similar to TCP stream but for UDP
# Good for DNS, DHCP, SNMP analysis
```

**TLS Stream**:
```
# Requires key log file
Edit -> Preferences -> Protocols -> TLS
Set "(Pre)-Master-Secret log filename"

# Then follow stream to see decrypted data
```

### Exporting Objects

**HTTP Objects**:
```
File -> Export Objects -> HTTP

# Export files transferred over HTTP
# Can save images, HTML, JavaScript files
```

**SMB Objects**:
```
File -> Export Objects -> SMB

# Export files transferred over SMB
```

**TLS Session Keys**:
```
# Export session keys for decrypting other captures
File -> Export TLS Session Keys
```

### Protocol Statistics

**Protocol Hierarchy**:
```
Statistics -> Protocol Hierarchy

# Shows protocol distribution
# Useful for identifying dominant protocols
```

**Endpoints**:
```
Statistics -> Endpoints

# Lists all addresses communicating
# Shows traffic per endpoint
```

**Conversations**:
```
Statistics -> Conversations

# Shows traffic between endpoints
# Good for identifying heavy talkers
```

**IO Graph**:
```
Statistics -> IO Graph

# Visual representation of traffic over time
# Can filter per protocol
```

**TCP Stream Graph**:
```
Statistics -> TCP Stream Graph -> ...

# Time-Sequence Graph (Stevens)
# Throughput Graph
# RTT Graph
# Window Scaling Graph
```

### Expert Information

```
Analyze -> Expert Information

# Shows warnings and errors
# Filter by severity
# Quick way to find problems
```

### Coloring Rules

```
View -> Coloring Rules

# Highlight packets based on conditions
# Example: TCP retransmissions in red
```

---

## 6. Command-Line Analysis with tshark

### Field Extraction

**Basic Field Extraction**:
```bash
# Extract IP addresses
tshark -r capture.pcap -T fields -e ip.src -e ip.dst

# Extract ports
tshark -r capture.pcap -T fields -e tcp.srcport -e tcp.dstport

# Extract DNS names
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name

# Multiple fields
tshark -r capture.pcap -T fields -e frame.time_relative -e ip.src -e ip.dst -e tcp.port
```

**Custom Separators**:
```bash
# Tab-separated
tshark -r capture.pcap -T fields -E separator="\t" -e ip.src -e ip.dst

# Comma-separated
tshark -r capture.pcap -T fields -E separator="," -e ip.src -e ip.dst

# Header row
tshark -r capture.pcap -T fields -E header=y -e ip.src -e ip.dst
```

### Statistics with tshark

**Protocol Statistics**:
```bash
# Protocol hierarchy
tshark -r capture.pcap -z protocol,hierarchy

# IO statistics
tshark -r capture.pcap -z io,stat,1

# Conversations
tshark -r capture.pcap -z conv,tcp

# Endpoints
tshark -r capture.pcap -z endpoints,ip
```

**Custom Statistics**:
```bash
# HTTP request count per host
tshark -r capture.pcap -Y "http.request" -z proto,colinfo,http.host,http.host

# DNS query count
tshark -r capture.pcap -Y "dns.flags.response == 0" -z proto,colinfo,dns.qry.name,dns.qry.name
```

### Filtering and Processing

**Complex Filtering**:
```bash
# Packets with specific conditions
tshark -r capture.pcap -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0"

# Packets with specific content
tshark -r capture.pcap -Y "http.request.uri contains 'login'"

# Multiple conditions
tshark -r capture.pcap -Y "(ip.src == 192.168.1.10 and tcp.port == 80) or (ip.dst == 192.168.1.10 and tcp.port == 443)"
```

### Automation Scripts

**Bash Example - Extract HTTP Requests**:
```bash
#!/bin/bash
# extract_http.sh - Extract HTTP requests from pcap

PCAP_FILE="$1"
OUTPUT_FILE="${PCAP_FILE%.pcap}_http.csv"

echo "Extracting HTTP requests from $PCAP_FILE"

tshark -r "$PCAP_FILE" -Y "http.request" \
    -T fields \
    -E header=y \
    -E separator="," \
    -e frame.time \
    -e ip.src \
    -e http.request.method \
    -e http.request.uri \
    -e http.host \
    -e http.user_agent \
    -e http.referer \
    -e http.content_type \
    > "$OUTPUT_FILE"

echo "Output written to $OUTPUT_FILE"
```

**Bash Example - Analyze DNS Queries**:
```bash
#!/bin/bash
# analyze_dns.sh - Analyze DNS queries from pcap

PCAP_FILE="$1"

echo "Top DNS queries:"
tshark -r "$PCAP_FILE" -Y "dns.flags.response == 0" \
    -T fields -e dns.qry.name \
    | sort | uniq -c | sort -nr | head -20

echo -e "\nNXDOMAIN queries:"
tshark -r "$PCAP_FILE" -Y "dns.flags.rcode == 3" \
    -T fields -e dns.qry.name \
    | sort | uniq -c | sort -nr | head -10
```

---

## 7. Python Packet Processing

### Reading PCAP Files with Scapy

```python
#!/usr/bin/env python3
"""
basic_pcap_reader.py - Read and process PCAP files
"""

from scapy.all import rdpcap, IP, TCP, UDP, ARP, DNS, HTTP
import sys

def analyze_pcap(filename):
    """Basic PCAP analysis"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    print(f"Total packets: {len(packets)}")
    
    # Count protocols
    counts = {
        'IP': 0,
        'TCP': 0,
        'UDP': 0,
        'ARP': 0,
        'DNS': 0,
        'HTTP': 0,
    }
    
    for packet in packets:
        if IP in packet:
            counts['IP'] += 1
            if TCP in packet:
                counts['TCP'] += 1
            elif UDP in packet:
                counts['UDP'] += 1
        elif ARP in packet:
            counts['ARP'] += 1
        
        if DNS in packet:
            counts['DNS'] += 1
        if HTTP in packet:
            counts['HTTP'] += 1
    
    print("\nProtocol Distribution:")
    for protocol, count in counts.items():
        if count > 0:
            print(f"  {protocol}: {count}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    analyze_pcap(sys.argv[1])
```

### Extracting HTTP Objects

```python
#!/usr/bin/env python3
"""
extract_http.py - Extract HTTP objects from pcap
"""

from scapy.all import rdpcap, IP, TCP, Raw, HTTP
from scapy.layers.http import HTTPRequest, HTTPResponse
import sys
import os
import re

def extract_http_objects(filename):
    """Extract HTTP objects from pcap"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    objects = []
    current_obj = None
    
    for packet in packets:
        if TCP in packet and Raw in packet:
            payload = packet[Raw].load
            
            # Look for HTTP response
            if b'HTTP/1' in payload or b'HTTP/2' in payload:
                # Extract status line
                lines = payload.split(b'\r\n')
                status_line = lines[0].decode('utf-8', errors='ignore')
                status_match = re.search(r'HTTP/\d\.\d (\d+)', status_line)
                
                if status_match:
                    current_obj = {
                        'status': int(status_match.group(1)),
                        'headers': {},
                        'body': b''
                    }
                    
                    # Parse headers
                    for line in lines[1:]:
                        if line == b'':
                            break
                        if b': ' in line:
                            key, value = line.split(b': ', 1)
                            current_obj['headers'][key.decode('utf-8', errors='ignore')] = value.decode('utf-8', errors='ignore')
                    
                    # Find body
                    body_start = b'\r\n\r\n'.join(lines).find(b'\r\n\r\n') + 4
                    if body_start > 0:
                        body = payload[body_start:]
                        current_obj['body'] = body
                        
                        # Check if complete
                        content_length = current_obj['headers'].get('Content-Length')
                        if content_length and len(body) >= int(content_length):
                            objects.append(current_obj)
                            current_obj = None
    
    print(f"Extracted {len(objects)} HTTP objects")
    
    # Display first object
    if objects:
        obj = objects[0]
        print(f"\nStatus: {obj['status']}")
        print(f"Headers: {len(obj['headers'])}")
        print(f"Body size: {len(obj['body'])} bytes")
        
        content_type = obj['headers'].get('Content-Type', 'Unknown')
        print(f"Content-Type: {content_type}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    extract_http_objects(sys.argv[1])
```

### DNS Query Analyzer

```python
#!/usr/bin/env python3
"""
dns_query_analyzer.py - Analyze DNS queries
"""

from scapy.all import rdpcap, DNS, IP, UDP
from collections import defaultdict, Counter
import sys
import re

def analyze_dns_queries(filename):
    """Analyze DNS queries from pcap"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    queries = defaultdict(list)
    responses = {}
    nxdomain = []
    suspicious = []
    
    for packet in packets:
        if DNS in packet:
            dns = packet[DNS]
            
            if dns.qr == 0:  # Query
                if dns.qd:
                    qname = dns.qd.qname.decode().lower()
                    qtype = dns.qd.qtype
                    queries[qname].append(qtype)
            
            elif dns.qr == 1:  # Response
                if dns.qd:
                    qname = dns.qd.qname.decode().lower()
                    qtype = dns.qd.qtype
                    
                    if dns.rcode == 3:  # NXDOMAIN
                        nxdomain.append(qname)
                    
                    # Check for suspicious response
                    if dns.an:
                        for an in dns.an:
                            if an.type == 1:  # A record
                                ip = an.rdata
                                responses[qname] = ip
                                
                                # Check for suspicious domains
                                suspicious_domains = ['.tk', '.top', '.xyz', '.info']
                                if any(s in qname for s in suspicious_domains):
                                    suspicious.append((qname, ip))
    
    print("=" * 60)
    print("DNS Query Analysis")
    print("=" * 60)
    
    print(f"\nTotal unique domains queried: {len(queries)}")
    print(f"Total queries: {sum(len(v) for v in queries.values())}")
    
    # Top domains
    print("\nTop 10 Domains:")
    for domain, types in sorted(queries.items(), key=lambda x: len(x[1]), reverse=True)[:10]:
        print(f"  {domain} ({len(types)} queries)")
    
    # NXDOMAIN
    if nxdomain:
        print(f"\nNXDOMAIN Responses ({len(nxdomain)}):")
        for domain in nxdomain[:10]:
            print(f"  {domain}")
    
    # Suspicious domains
    if suspicious:
        print(f"\nSuspicious Domains ({len(suspicious)}):")
        for domain, ip in suspicious[:10]:
            print(f"  {domain} -> {ip}")
    
    print("=" * 60)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    analyze_dns_queries(sys.argv[1])
```

---

## 8. Performance Analysis Techniques

### Latency Analysis

**Measure RTT from TCP Handshake**:
```bash
# Extract handshake times
tshark -r capture.pcap -Y "tcp.flags.syn == 1 or tcp.flags.ack == 1" \
    -T fields -e frame.time_relative -e tcp.flags

# Calculate RTT (SYN to SYN-ACK)
tshark -r capture.pcap -Y "tcp.flags.syn == 1" \
    -T fields -e frame.time_relative -e tcp.srcport -e tcp.dstport
```

**Python RTT Calculator**:
```python
#!/usr/bin/env python3
"""
rtt_calculator.py - Calculate RTT from pcap
"""

from scapy.all import rdpcap, TCP, IP
from collections import defaultdict
import sys

def calculate_rtt(filename):
    packets = rdpcap(filename)
    
    syn_times = {}
    rtts = []
    
    for packet in packets:
        if TCP in packet:
            tcp = packet[TCP]
            
            # SYN
            if tcp.flags & 0x02 and not (tcp.flags & 0x10):
                key = (packet[IP].src, packet[IP].dst, tcp.sport, tcp.dport)
                syn_times[key] = packet.time
            
            # SYN-ACK
            elif tcp.flags & 0x02 and tcp.flags & 0x10:
                key = (packet[IP].dst, packet[IP].src, tcp.dport, tcp.sport)
                if key in syn_times:
                    rtt = packet.time - syn_times[key]
                    rtts.append(rtt)
                    del syn_times[key]
    
    if rtts:
        print(f"RTT Statistics:")
        print(f"  Min: {min(rtts)*1000:.2f}ms")
        print(f"  Max: {max(rtts)*1000:.2f}ms")
        print(f"  Avg: {sum(rtts)/len(rtts)*1000:.2f}ms")
        print(f"  Samples: {len(rtts)}")
    else:
        print("No handshake found")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    calculate_rtt(sys.argv[1])
```

### Throughput Analysis

**Calculate Throughput**:
```bash
# IO statistics per second
tshark -r capture.pcap -z io,stat,1

# Traffic per conversation
tshark -r capture.pcap -z conv,tcp

# Traffic per IP
tshark -r capture.pcap -z endpoints,ip
```

**Python Throughput Calculator**:
```python
#!/usr/bin/env python3
"""
throughput_calculator.py - Calculate throughput from pcap
"""

from scapy.all import rdpcap, IP
import sys
import time

def calculate_throughput(filename):
    packets = rdpcap(filename)
    
    if not packets:
        print("No packets found")
        return
    
    first_time = packets[0].time
    last_time = packets[-1].time
    duration = last_time - first_time
    
    total_bytes = 0
    for packet in packets:
        if IP in packet:
            total_bytes += len(packet)
    
    throughput_mbps = (total_bytes * 8) / (duration * 1000000)
    
    print(f"Throughput Analysis:")
    print(f"  Duration: {duration:.2f} seconds")
    print(f"  Total Data: {total_bytes / 1024 / 1024:.2f} MB")
    print(f"  Average Throughput: {throughput_mbps:.2f} Mbps")
    print(f"  Packets: {len(packets)}")
    print(f"  Packet Rate: {len(packets)/duration:.2f} pps")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    calculate_throughput(sys.argv[1])
```

### Packet Loss Analysis

**Detect Loss**:
```bash
# TCP retransmissions
tshark -r capture.pcap -Y "tcp.analysis.retransmission"

# Duplicate ACKs
tshark -r capture.pcap -Y "tcp.analysis.duplicate_ack"

# Out-of-order packets
tshark -r capture.pcap -Y "tcp.analysis.out_of_order"
```

---

## 9. Security Analysis Techniques

### Detecting ARP Spoofing

```bash
# Look for conflicting ARP replies
tshark -r capture.pcap -Y "arp.opcode == 2" -T fields -e arp.src.proto_ipv4 -e arp.src.hw_mac

# Identify multiple MACs for same IP
tshark -r capture.pcap -Y "arp.opcode == 2" -T fields -e arp.src.proto_ipv4 -e arp.src.hw_mac | sort | uniq
```

### Detecting DNS Tunneling

```bash
# Look for long subdomains
tshark -r capture.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name | awk 'length($0) > 50'

# Look for high-frequency NXDOMAIN
tshark -r capture.pcap -Y "dns.flags.rcode == 3" -T fields -e dns.qry.name | sort | uniq -c | sort -nr | head -20
```

### Detecting Malware Traffic

```bash
# Suspicious ports
tshark -r capture.pcap -Y "tcp.port in {4444,1337,31337,6667,6668}"

# Suspicious domains
tshark -r capture.pcap -Y "dns.qry.name matches '\.(tk|top|xyz|info)$'"

# Beaconing (regular intervals)
tshark -r capture.pcap -Y "tcp" -z io,stat,1
```

---

## 10. Troubleshooting Scenarios

### Scenario 1: Slow Website Load

**Capture**:
```bash
tcpdump -i eth0 -nn "host example.com and (tcp port 80 or tcp port 443)" -w slow_site.pcap
```

**Analyze**:
```bash
# Check DNS lookup time
tshark -r slow_site.pcap -Y "dns"

# Check TCP handshake time
tshark -r slow_site.pcap -Y "tcp.flags.syn == 1" -T fields -e frame.time_relative

# Check TLS handshake time
tshark -r slow_site.pcap -Y "tls.handshake" -T fields -e frame.time_relative -e tls.handshake.type

# Check HTTP response time
tshark -r slow_site.pcap -Y "http" -T fields -e frame.time_relative -e http.request.method
```

### Scenario 2: DNS Resolution Issues

**Capture**:
```bash
tcpdump -i eth0 -nn "udp port 53" -w dns_issue.pcap
```

**Analyze**:
```bash
# Check DNS query
tshark -r dns_issue.pcap -Y "dns.flags.response == 0"

# Check DNS response
tshark -r dns_issue.pcap -Y "dns.flags.response == 1"

# Check for errors
tshark -r dns_issue.pcap -Y "dns.flags.rcode != 0"

# Check response time
tshark -r dns_issue.pcap -Y "dns" -z conv,udp
```

### Scenario 3: Connection Refused

**Capture**:
```bash
tcpdump -i eth0 -nn "host 192.168.1.10 and port 8080" -w refused.pcap
```

**Analyze**:
```bash
# Check SYN packets
tshark -r refused.pcap -Y "tcp.flags.syn == 1"

# Check RST packets
tshark -r refused.pcap -Y "tcp.flags.rst == 1"

# Check ICMP unreachable
tshark -r refused.pcap -Y "icmp.type == 3"
```

### Scenario 4: SSL/TLS Error

**Capture**:
```bash
tcpdump -i eth0 -nn "tcp port 443" -w tls_error.pcap
```

**Analyze**:
```bash
# Check TLS alerts
tshark -r tls_error.pcap -Y "tls.record.content_type == 21"

# Check certificate errors
tshark -r tls_error.pcap -Y "tls.handshake.certificate" -V | grep -A 20 "Certificate"

# Check cipher suite negotiation
tshark -r tls_error.pcap -Y "tls.handshake.ciphersuite" -T fields -e tls.handshake.ciphersuite
```

---

**[END OF APPENDIX B]**
