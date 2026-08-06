# Comprehensive Student Workbook

## Demystifying Network Protocols: From Ethernet Frames to HTTP/3

### A Complete Hands-On Learning Companion

---

## Overview

This workbook is designed to accompany the "Demystifying Network Protocols" tutorial series. It provides structured exercises, fill-in-the-blank activities, lab worksheets, review questions, and project checklists to reinforce learning and build practical skills.

**Purpose:** Transform passive learning into active skill-building through guided practice, self-assessment, and hands-on application.

**How to Use This Workbook:**
1. Read each part of the tutorial series
2. Complete the corresponding workbook sections
3. Perform the hands-on labs and record your results
4. Test your knowledge with review questions
5. Track your progress using the skill matrices

---

## Table of Contents

1. [Part 1: Foundations & the Local Link](#part-1-foundations--the-local-link)
2. [Part 2: The Network Layer & Diagnostics](#part-2-the-network-layer--diagnostics)
3. [Part 3: The Transport Layer](#part-3-the-transport-layer)
4. [Part 4: The Application Layer](#part-4-the-application-layer)
5. [Part 5: Modern Web Security & Packet Analysis](#part-5-modern-web-security--packet-analysis)
6. [Lab Worksheets](#lab-worksheets)
7. [Review Questions](#review-questions)
8. [Skill Matrices](#skill-matrices)
9. [Project Checklists](#project-checklists)
10. [Final Assessment](#final-assessment)

---

# PART 1: FOUNDATIONS & THE LOCAL LINK

## Knowledge Check

### Fill in the Blanks

1. The ________ model has seven layers, while the ________ model has four layers.

2. A ________ is a set of rules that define how devices communicate on a network.

3. ________ is the process of wrapping data with headers at each layer.

4. A MAC address is ________ bits (________ bytes) long.

5. The destination MAC address for a broadcast frame is ________.

6. ARP stands for ________.

7. DHCP uses the ________ process to assign IP addresses.

8. An ARP request is sent to ________, while an ARP reply is sent to ________.

9. The minimum Ethernet frame size is ________ bytes.

10. VLAN stands for ________.

### True or False

1. [ ] The OSI model is the framework the Internet actually uses.
2. [ ] MAC addresses are permanent hardware addresses burned into the NIC.
3. [ ] ARP translates IP addresses to MAC addresses.
4. [ ] DHCP uses a four-step process called DORA.
5. [ ] Switches forward broadcast frames to all ports.
6. [ ] ARP spoofing is a legitimate network management technique.
7. [ ] VLANs provide security isolation between network segments.
8. [ ] The EtherType field in an Ethernet frame identifies the payload protocol.
9. [ ] A static IP address is assigned by DHCP.
10. [ ] The ARP cache stores IP-to-MAC address mappings temporarily.

### Matching

Match the protocol/term to its description:

| Term | Description |
|------|-------------|
| 1. Ethernet | A. Translates domain names to IP addresses |
| 2. ARP | B. Assigns IP addresses automatically |
| 3. DHCP | C. Local network protocol using MAC addresses |
| 4. DNS | D. Resolves IP addresses to MAC addresses |
| 5. VLAN | E. Virtual segmentation of a network |

---

## Concept Map

Complete the concept map below by filling in the missing terms:

```
Network Protocols
       │
       ├── OSI Model (7 layers)
       │    ├── Application
       │    ├── Presentation
       │    ├── Session
       │    ├── Transport
       │    ├── Network
       │    ├── __________
       │    └── Physical
       │
       ├── TCP/IP Model (4 layers)
       │    ├── __________
       │    ├── Transport
       │    ├── Internet
       │    └── __________
       │
       └── Local Link Layer
            ├── __________ (MAC addresses, frames)
            ├── ARP (IP → MAC)
            └── __________ (IP assignment)
```

---

## Lab Worksheet 1: Ethernet Frame Inspection

**Objective:** Capture and analyze Ethernet frames.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the purpose of the Ethernet preamble?

2. What information does the EtherType field provide?

3. Why is the Frame Check Sequence (FCS) important?

### Lab Procedure

1. Launch Wireshark and select the appropriate interface.

2. Start capturing traffic.

3. Generate traffic using `curl -I https://www.google.com`.

4. Stop the capture and apply the filter `eth`.

5. Select a frame and answer the following:

| Field | Value |
|-------|-------|
| Source MAC | |
| Destination MAC | |
| EtherType | |
| Frame Length | |

6. Is the frame a broadcast, unicast, or multicast?

7. What protocol is indicated by the EtherType?

### Reflection

What did you learn from capturing and analyzing Ethernet frames?

________________________________________________________________

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 2: ARP Exchange

**Objective:** Capture and analyze ARP request/reply messages.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What triggers an ARP request?

2. How does a device know when to send an ARP reply?

3. What is the purpose of the ARP cache?

### Lab Procedure

1. Clear the ARP cache: `sudo ip neigh flush all`

2. Start ARP capture: `sudo tcpdump -i eth0 arp -w arp_capture.pcap`

3. Ping the gateway: `ping -c 1 192.168.1.1`

4. Stop the capture and analyze:

```bash
tshark -r arp_capture.pcap -Y "arp" -T fields -e arp.opcode -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4
```

5. Record the ARP request and reply:

| Message | Source IP | Target IP | Opcode |
|---------|-----------|-----------|--------|
| Request | | | |
| Reply | | | |

### Reflection

What happens if no ARP reply is received?

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 3: DHCP DORA Sequence

**Objective:** Capture and analyze the DHCP DORA process.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. Why is DHCP preferable to static IP addressing?

2. What does DORA stand for?

3. What happens if a DHCP server is unavailable?

### Lab Procedure

1. Release current lease: `sudo dhclient -r eth0`

2. Start DHCP capture: `sudo tcpdump -i eth0 "udp port 67 or udp port 68" -w dhcp_capture.pcap`

3. Request a new lease: `sudo dhclient eth0`

4. Stop the capture and analyze:

```bash
tshark -r dhcp_capture.pcap -Y "dhcp" -T fields -e dhcp.msgtype -e dhcp.option.dhcp_server
```

5. Record the DORA sequence:

| Message | Direction | DHCP Message Type |
|---------|-----------|-------------------|
| Discover | Client → Server | |
| Offer | Server → Client | |
| Request | Client → Server | |
| Ack | Server → Client | |

### Reflection

Why does DHCP use broadcast for the Discover and Request messages?

________________________________________________________________

________________________________________________________________

---

# PART 2: THE NETWORK LAYER & DIAGNOSTICS

## Knowledge Check

### Fill in the Blanks

1. IPv4 addresses are ________ bits long.

2. IPv6 addresses are ________ bits long.

3. CIDR stands for ________.

4. NAT stands for ________.

5. The default TTL for most Linux systems is ________.

6. ICMP stands for ________.

7. The ICMP type for Echo Request is ________, and for Echo Reply is ________.

8. Traceroute works by exploiting the ________ field in the IP header.

9. The default gateway handles traffic destined for networks ________.

10. IPv6 link-local addresses start with ________.

### True or False

1. [ ] IPv4 has a larger address space than IPv6.
2. [ ] NAT allows multiple private IPs to share a single public IP.
3. [ ] The default gateway is a router.
4. [ ] Ping uses ICMP Echo Request and Echo Reply messages.
5. [ ] Traceroute shows the path packets take to a destination.
6. [ ] IPv6 eliminates the need for NAT.
7. [ ] Private IP addresses are routable on the Internet.
8. [ ] The TTL field prevents packets from looping forever.
9. [ ] ICMP is a transport protocol like TCP or UDP.
10. [ ] Path MTU Discovery uses ICMP to find the optimal packet size.

### Matching

Match the term to its description:

| Term | Description |
|------|-------------|
| 1. IPv4 | A. 128-bit address space |
| 2. IPv6 | B. 32-bit address space |
| 3. NAT | C. Network diagnostic protocol |
| 4. ICMP | D. Translates private to public IPs |
| 5. Subnet | E. Divides a network into smaller segments |

---

## Subnet Calculation Practice

Calculate the following subnets:

**1. Divide 192.168.1.0/24 into 4 subnets**

| Subnet | Network Address | Broadcast | Host Range | CIDR |
|--------|----------------|-----------|------------|------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |

**2. Calculate the subnet for 10.0.0.1/19**

- Network Address: ____________________
- Broadcast Address: ____________________
- Netmask: ____________________
- Number of Hosts: ____________________

**3. Find the broadcast address for 172.16.10.0/22**

- Broadcast Address: ____________________

---

## Lab Worksheet 4: IPv4 Header Analysis

**Objective:** Analyze IPv4 headers in captured traffic.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the purpose of the TTL field?

2. What does the Protocol field indicate?

3. What is the difference between the DF and MF flags?

### Lab Procedure

1. Capture IPv4 traffic: `sudo tcpdump -i eth0 -w ipv4_capture.pcap`

2. Generate traffic: `curl -I https://www.google.com`

3. Analyze the capture:

```bash
tshark -r ipv4_capture.pcap -Y "ip" -T fields -e ip.src -e ip.dst -e ip.ttl -e ip.proto -e ip.len
```

4. Record the IPv4 header fields for one packet:

| Field | Value |
|-------|-------|
| Source IP | |
| Destination IP | |
| TTL | |
| Protocol | |
| Total Length | |

5. What protocol is indicated by the Protocol field?

### Reflection

How does the TTL field help prevent routing loops?

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 5: Subnet Calculation

**Objective:** Practice subnet calculations using Python.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the difference between a network address and a broadcast address?

2. How do you calculate the number of hosts in a subnet?

3. What does CIDR notation represent?

### Lab Procedure

1. Write a Python script to calculate subnet details:

```python
import ipaddress

def calculate_subnet(cidr):
    network = ipaddress.ip_network(cidr, strict=False)
    print(f"Network: {network}")
    print(f"Network Address: {network.network_address}")
    print(f"Broadcast: {network.broadcast_address}")
    print(f"Netmask: {network.netmask}")
    print(f"Prefix: /{network.prefixlen}")
    print(f"Hosts: {network.num_addresses - 2}")

# Test with different subnets
calculate_subnet('192.168.1.0/24')
calculate_subnet('10.0.0.0/16')
calculate_subnet('172.16.0.0/12')
```

2. Record the results for each subnet:

| Subnet | Network | Broadcast | Netmask | Hosts |
|--------|---------|-----------|---------|-------|
| 192.168.1.0/24 | | | | |
| 10.0.0.0/16 | | | | |
| 172.16.0.0/12 | | | | |

### Reflection

How does subnetting improve network efficiency and security?

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 6: Traceroute Analysis

**Objective:** Trace packet paths using traceroute.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. How does traceroute work?

2. What ICMP message type is used by traceroute?

3. What information does traceroute provide?

### Lab Procedure

1. Trace to various destinations:

```bash
traceroute -n 8.8.8.8
traceroute -n 1.1.1.1
traceroute -n google.com
```

2. Capture traceroute traffic:

```bash
sudo tcpdump -i eth0 "icmp and (icmp[icmptype] == 11)" -w traceroute_capture.pcap
```

3. In another terminal, run traceroute: `traceroute -n 8.8.8.8`

4. Record the results for 8.8.8.8:

| Hop | IP Address | Latency (ms) |
|-----|------------|--------------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |

5. How many hops to reach the destination?

### Reflection

What can you learn about network topology from traceroute?

________________________________________________________________

________________________________________________________________

---

# PART 3: THE TRANSPORT LAYER

## Knowledge Check

### Fill in the Blanks

1. UDP provides ________, while TCP provides ________ delivery.

2. TCP uses a ________ to establish a connection.

3. The TCP ________ field indicates the position of data in the stream.

4. UDP headers are ________ bytes long.

5. TCP headers are at least ________ bytes long.

6. TCP uses ________ control to prevent network collapse.

7. The TCP flags include SYN, ACK, FIN, and ________.

8. The FIN flag initiates a ________.

9. A ________ is the endpoint of a network connection.

10. A port is a numerical identifier from ________ to ________.

### True or False

1. [ ] UDP is connection-oriented.
2. [ ] TCP guarantees delivery of data.
3. [ ] UDP is faster than TCP.
4. [ ] TCP uses a three-way handshake.
5. [ ] UDP provides ordered delivery.
6. [ ] TCP has flow control.
7. [ ] UDP has congestion control.
8. [ ] The RST flag is used to gracefully close a connection.
9. [ ] The ACK flag indicates acknowledgment data is valid.
10. [ ] Port 80 is used for HTTPS.

### Matching

Match the term to its description:

| Term | Description |
|------|-------------|
| 1. SYN | A. Closed connection abruptly |
| 2. ACK | B. Start connection |
| 3. FIN | C. Acknowledgment |
| 4. RST | D. Push data to application |
| 5. PSH | E. Close connection gracefully |

---

## TCP Handshake Diagram

Complete the TCP three-way handshake diagram:

```
Client                                    Server
   │                                         │
   │  1. ______ (seq=x)                      │
   │  "I want to connect"                    │
   ├────────────────────────────────────────►│
   │                                         │
   │  2. ______ (seq=y, ack=x+1)            │
   │  "OK, I'm ready"                       │
   │◄────────────────────────────────────────┤
   │                                         │
   │  3. ______ (seq=x+1, ack=y+1)          │
   │  "Great, let's go"                     │
   ├────────────────────────────────────────►│
   │                                         │
   │        [______]                        │
```

---

## Lab Worksheet 7: TCP Echo Server

**Objective:** Build and test a TCP echo server.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the purpose of the TCP echo server?

2. Why do we use `SO_REUSEADDR`?

3. What is a thread and why do we use threads in the server?

### Lab Procedure

1. Create the TCP echo server (use the code from the tutorial):

```python
#!/usr/bin/env python3
import socket
import threading

class TCPEchoServer:
    # ... server code ...
```

2. Start the server: `python3 tcp_echo_server.py`

3. Test with netcat: `nc localhost 8080`

4. Test with the Python client:

```python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('localhost', 8080))
sock.send(b'Hello, TCP!')
response = sock.recv(4096)
print(response.decode())
sock.close()
```

5. Capture the TCP handshake:

```bash
sudo tcpdump -i eth0 "tcp port 8080" -w tcp_handshake.pcap
# Then run the client
```

6. Record the handshake packets:

| Packet | Time | Flags | Seq | Ack |
|--------|------|-------|-----|-----|
| 1 (Client → Server) | | | | |
| 2 (Server → Client) | | | | |
| 3 (Client → Server) | | | | |

### Reflection

How does the TCP handshake ensure a reliable connection?

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 8: UDP Echo Server

**Objective:** Build and test a UDP echo server.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the difference between TCP and UDP echo servers?

2. Why does UDP not use a three-way handshake?

3. What are the advantages and disadvantages of UDP?

### Lab Procedure

1. Create the UDP echo server:

```python
#!/usr/bin/env python3
import socket

class UDPEchoServer:
    # ... server code ...
```

2. Start the UDP server: `python3 udp_echo_server.py`

3. Test with Python:

```python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(b'Hello, UDP!', ('localhost', 8081))
data, _ = sock.recvfrom(4096)
print(data.decode())
sock.close()
```

4. Test with netcat: `echo "Hello" | nc -u localhost 8081`

5. Capture UDP traffic:

```bash
sudo tcpdump -i eth0 "udp port 8081" -w udp_capture.pcap
```

6. Record your observations:

| Aspect | TCP | UDP |
|--------|-----|-----|
| Connection establishment | | |
| Reliability | | |
| Speed | | |
| Use cases | | |

### Reflection

When would you choose UDP over TCP in a real application?

________________________________________________________________

________________________________________________________________

---

# PART 4: THE APPLICATION LAYER

## Knowledge Check

### Fill in the Blanks

1. DNS translates ________ to ________.

2. The top-level domain for the United Kingdom is ________.

3. HTTP stands for ________.

4. A ________ HTTP status code indicates success.

5. HTTP methods that don't modify server state are called ________.

6. SMTP sends emails using port ________.

7. ________ downloads and deletes email from the server.

8. ________ keeps email on the server for multiple device access.

9. SNMP uses ________ to identify managed objects.

10. A DNS ________ record maps a domain to an IPv4 address.

### True or False

1. [ ] DNS is a hierarchical distributed database.
2. [ ] A 404 status code means "OK."
3. [ ] GET is a safe method.
4. [ ] SMTP is used to receive email.
5. [ ] IMAP stores email on the server.
6. [ ] POP3 allows folder synchronization.
7. [ ] SNMP uses OIDs to identify data points.
8. [ ] HTTP/2 supports multiplexing.
9. [ ] The MX record specifies the mail server.
10. [ ] A CNAME record creates an alias.

### Matching

Match the DNS record to its purpose:

| Record | Purpose |
|--------|---------|
| 1. A | A. IPv6 address |
| 2. AAAA | B. Alias name |
| 3. CNAME | C. IPv4 address |
| 4. MX | D. Name server |
| 5. NS | E. Mail server |

---

## DNS Resolution Path

Complete the DNS resolution path:

```
Client ──► ________ Resolver
                     │
                     ▼
               ________ Server
                     │
                     ▼
               ________ Server (.com)
                     │
                     ▼
               ________ Server (example.com)
                     │
                     ▼
               IP Address: ________
```

---

## Lab Worksheet 9: DNS Lookup Tool

**Objective:** Build a DNS lookup tool.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the difference between `dig` and `nslookup`?

2. What are the common DNS record types?

3. What is the purpose of the DNS cache?

### Lab Procedure

1. Use dig to query different record types:

```bash
dig example.com A
dig example.com AAAA
dig gmail.com MX
dig example.com TXT
dig example.com NS
```

2. Build a Python DNS client:

```python
#!/usr/bin/env python3
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
    # ... command-line parsing ...
```

3. Test with multiple record types:

| Domain | Record Type | Result |
|--------|-------------|--------|
| example.com | A | |
| google.com | AAAA | |
| gmail.com | MX | |
| example.com | TXT | |

### Reflection

How does DNS caching improve performance?

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 10: HTTP Server

**Objective:** Build a simple HTTP server.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the structure of an HTTP request?

2. What is the difference between GET and POST?

3. What does the Status Code 200 indicate?

### Lab Procedure

1. Create the HTTP server:

```python
#!/usr/bin/env python3
import socket
import os

class HTTPServer:
    # ... server code ...
```

2. Start the server and create a simple web page:

```html
<!DOCTYPE html>
<html>
<body>
<h1>Hello, World!</h1>
</body>
</html>
```

3. Test with curl:

```bash
curl -v http://localhost:8080/
curl -v http://localhost:8080/api
```

4. Record the request and response:

| Request Component | Value |
|-------------------|-------|
| Method | |
| Path | |
| HTTP Version | |
| Host Header | |

| Response Component | Value |
|--------------------|-------|
| Status Code | |
| Content-Type | |
| Content-Length | |

### Reflection

What are the key components of an HTTP server?

________________________________________________________________

________________________________________________________________

---

# PART 5: MODERN WEB SECURITY & PACKET ANALYSIS

## Knowledge Check

### Fill in the Blanks

1. ________ encryption uses one key, while ________ encryption uses a key pair.

2. TLS stands for ________.

3. TLS 1.3 handshake uses ________ RTT.

4. ________ ensures past sessions remain secure even if keys are compromised.

5. HTTP/3 uses ________ instead of TCP.

6. QUIC stands for ________.

7. The TLS handshake type for ClientHello is ________.

8. Wireshark's ________ can analyze entire network conversations.

9. A ________ certificate confirms the identity of the server.

10. ________ provides end-to-end integrity verification.

### True or False

1. [ ] AES is a symmetric encryption algorithm.
2. [ ] RSA is a symmetric encryption algorithm.
3. [ ] TLS 1.3 has perfect forward secrecy by default.
4. [ ] HTTP/3 uses TCP for transport.
5. [ ] QUIC uses UDP for transport.
6. [ ] Perfect Forward Secrecy protects past sessions.
7. [ ] Certificate validation checks the certificate chain.
8. [ ] OCSP is used for certificate revocation checking.
9. [ ] Wireshark can decrypt TLS traffic with key logs.
10. [ ] HTTP/3 has a single stream per connection.

### Matching

Match the term to its description:

| Term | Description |
|------|-------------|
| 1. TLS | A. Modern transport protocol over UDP |
| 2. QUIC | B. Secure web protocol |
| 3. PFS | C. Past sessions remain secure |
| 4. CA | D. Issues certificates |
| 5. OCSP | E. Certificate revocation check |

---

## Lab Worksheet 11: TLS Handshake Analysis

**Objective:** Capture and analyze TLS handshake.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the purpose of the TLS handshake?

2. What is a cipher suite?

3. What does ALPN negotiate?

### Lab Procedure

1. Capture TLS traffic:

```bash
sudo tcpdump -i eth0 "tcp port 443" -w tls_capture.pcap
```

2. Generate TLS traffic:

```bash
curl -v https://www.google.com
openssl s_client -connect google.com:443
```

3. Analyze the handshake:

```bash
tshark -r tls_capture.pcap -Y "tls.handshake" -T fields -e frame.time_relative -e tls.handshake.type
```

4. Record the handshake sequence:

| Packet | Type | Time (relative) |
|--------|------|-----------------|
| 1 | ClientHello | |
| 2 | ServerHello | |
| 3 | Certificate | |
| 4 | ServerHelloDone | |
| 5 | ClientKeyExchange | |
| 6 | ChangeCipherSpec | |
| 7 | Finished | |

5. What cipher suite was selected?

### Reflection

How does the TLS handshake establish a secure connection?

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 12: TLS Certificate Validation

**Objective:** Validate and inspect TLS certificates.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What information is in a TLS certificate?

2. What is a Certificate Authority?

3. What is the certificate chain?

### Lab Procedure

1. View certificate details:

```bash
openssl s_client -showcerts -connect google.com:443 </dev/null
```

2. Extract and examine certificate:

```bash
openssl s_client -showcerts -connect google.com:443 </dev/null | \
    openssl x509 -text -noout
```

3. Check certificate validity:

```bash
openssl x509 -in google.pem -noout -dates
```

4. Verify the certificate chain:

```bash
openssl verify -CAfile root.pem google.pem
```

5. Record certificate details:

| Field | Value |
|-------|-------|
| Subject | |
| Issuer | |
| Validity (Not Before) | |
| Validity (Not After) | |
| Public Key Algorithm | |
| SAN (Subject Alternative Names) | |

### Reflection

How does certificate validation protect against man-in-the-middle attacks?

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet 13: HTTP/3 and QUIC Analysis

**Objective:** Capture and analyze HTTP/3 and QUIC traffic.

**Student Name:** ________________________

**Date:** ________________________

### Pre-Lab Questions

1. What is the difference between HTTP/3 and HTTP/2?

2. How does QUIC improve performance?

3. What is the role of connection IDs in QUIC?

### Lab Procedure

1. Install tools for HTTP/3 testing:

```bash
# Install curl with HTTP/3 support
sudo apt-get install nghttp3 nghttp2
```

2. Test HTTP/3:

```bash
curl --http3 -I https://www.google.com
```

3. Capture QUIC traffic:

```bash
sudo tcpdump -i eth0 "udp port 443" -w quic_capture.pcap
```

4. Analyze QUIC packets:

```bash
tshark -r quic_capture.pcap -Y "quic" -V | head -50
```

5. Record QUIC observations:

| Feature | Observation |
|---------|-------------|
| Connection ID | |
| Version | |
| Packet Types | |
| Streams | |

### Reflection

How does QUIC improve performance compared to TCP-based protocols?

________________________________________________________________

________________________________________________________________

---

# LAB WORKSHEETS

## General Lab Worksheet Template

**Lab Name:** ________________________

**Student Name:** ________________________

**Date:** ________________________

**Objective:** 

________________________________________________________________

**Tools Used:** 

________________________________________________________________

**Procedure:**

1. ____________________________________________________________

2. ____________________________________________________________

3. ____________________________________________________________

**Results:**

| Step | Observation | Expected Outcome | Success? |
|------|-------------|------------------|----------|
| 1 | | | |
| 2 | | | |
| 3 | | | |

**Analysis:**

What did you observe? 

________________________________________________________________

________________________________________________________________

**Challenges Encountered:**

________________________________________________________________

________________________________________________________________

**Solutions Applied:**

________________________________________________________________

________________________________________________________________

**Key Learnings:**

________________________________________________________________

________________________________________________________________

**Additional Notes:**

________________________________________________________________

________________________________________________________________

---

## Lab Worksheet: Packet Capture Log

**Capture Name:** ________________________

**Date:** ________________________

**Interface:** ________________________

**Filter:** ________________________

**Duration:** ________________________

### Packet Summary

| # | Time | Source | Destination | Protocol | Info |
|---|------|--------|-------------|----------|------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

### Protocol Distribution

| Protocol | Count | Percentage |
|----------|-------|------------|
| Ethernet | | |
| IPv4 | | |
| IPv6 | | |
| TCP | | |
| UDP | | |
| HTTP | | |
| DNS | | |
| ARP | | |
| DHCP | | |
| Other | | |

### Key Observations

________________________________________________________________

________________________________________________________________

________________________________________________________________

---

# REVIEW QUESTIONS

## Part 1 Review Questions

1. What is the difference between the OSI and TCP/IP models?

2. Explain the concept of encapsulation in networking.

3. What is a MAC address and why is it important?

4. How does ARP work?

5. What is the DORA process in DHCP?

6. What is the difference between a switch and a hub?

7. Why are VLANs useful?

8. What is ARP spoofing and how can it be prevented?

## Part 2 Review Questions

1. Explain the difference between IPv4 and IPv6.

2. What is NAT and why is it used?

3. How do routers make forwarding decisions?

4. What is the purpose of ICMP?

5. How does traceroute work?

6. Why is subnetting important?

7. What is the default gateway and why is it needed?

8. What is Path MTU Discovery?

## Part 3 Review Questions

1. What is the difference between TCP and UDP?

2. Explain the TCP three-way handshake.

3. Why does TCP use sequence numbers?

4. What is congestion control and why is it important?

5. What is the purpose of the sliding window?

6. What is the difference between a port and a socket?

7. What are the advantages and disadvantages of UDP?

## Part 4 Review Questions

1. How does DNS work?

2. What are the different types of DNS records?

3. What is the difference between POP3 and IMAP?

4. How does SMTP work?

5. What are the common HTTP methods?

6. What do HTTP status codes indicate?

7. What is the purpose of cookies in HTTP?

8. What are the benefits of HTTP/2?

## Part 5 Review Questions

1. What is the difference between symmetric and asymmetric encryption?

2. Explain the TLS 1.3 handshake process.

3. What is Perfect Forward Secrecy?

4. How does certificate validation work?

5. What is the difference between HTTP/2 and HTTP/3?

6. How does QUIC improve performance?

7. What tools are used for packet analysis?

8. What are common network troubleshooting techniques?

---

# SKILL MATRICES

## Self-Assessment: Part 1

Rate your proficiency for each skill (1-5):

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Understand OSI and TCP/IP models | | | | | |
| Explain Ethernet frame structure | | | | | |
| Identify MAC addresses | | | | | |
| Analyze ARP messages | | | | | |
| Explain DHCP operation | | | | | |
| Configure VLANs | | | | | |
| Capture frames with Wireshark | | | | | |
| Decode Ethernet frames | | | | | |

## Self-Assessment: Part 2

Rate your proficiency for each skill (1-5):

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Understand IPv4 addressing | | | | | |
| Understand IPv6 addressing | | | | | |
| Calculate subnets | | | | | |
| Explain routing concepts | | | | | |
| Use ping and traceroute | | | | | |
| Analyze IP headers | | | | | |
| Understand ICMP messages | | | | | |
| Configure routes | | | | | |

## Self-Assessment: Part 3

Rate your proficiency for each skill (1-5):

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Understand UDP protocol | | | | | |
| Understand TCP protocol | | | | | |
| Explain TCP handshake | | | | | |
| Analyze TCP streams | | | | | |
| Build TCP applications | | | | | |
| Build UDP applications | | | | | |
| Understand congestion control | | | | | |
| Use socket programming | | | | | |

## Self-Assessment: Part 4

Rate your proficiency for each skill (1-5):

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Understand DNS resolution | | | | | |
| Query DNS records | | | | | |
| Understand HTTP protocol | | | | | |
| Analyze HTTP requests/responses | | | | | |
| Build HTTP applications | | | | | |
| Understand email protocols | | | | | |
| Use SNMP for monitoring | | | | | |
| Understand HTTP/2 features | | | | | |

## Self-Assessment: Part 5

Rate your proficiency for each skill (1-5):

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Understand encryption basics | | | | | |
| Explain TLS handshake | | | | | |
| Validate TLS certificates | | | | | |
| Understand HTTP/3 and QUIC | | | | | |
| Use Wireshark for analysis | | | | | |
| Decrypt HTTPS traffic | | | | | |
| Diagnose network problems | | | | | |
| Analyze packet captures | | | | | |

---

# PROJECT CHECKLISTS

## Project 1: Ethernet Frame Decoder

**Objective:** Build a Python tool that decodes Ethernet frames.

**Checklist:**

- [ ] Install Python and required libraries (scapy)
- [ ] Implement Ethernet header decoding
- [ ] Display source and destination MAC addresses
- [ ] Display EtherType
- [ ] Show payload length
- [ ] Handle different EtherType values
- [ ] Add error handling
- [ ] Test with captured packets
- [ ] Add command-line interface
- [ ] Document the code

**Presentation:** Demonstrate the tool by decoding captured frames.

---

## Project 2: Network Scanner

**Objective:** Build a tool that discovers devices on a local network.

**Checklist:**

- [ ] Implement ARP scanning
- [ ] Display IP and MAC addresses
- [ ] Show hostnames (reverse DNS)
- [ ] Implement parallel scanning
- [ ] Add port scanning capability
- [ ] Detect operating systems (TTL)
- [ ] Export results to file
- [ ] Add command-line interface
- [ ] Handle errors gracefully
- [ ] Document the code

**Presentation:** Scan the local network and explain the results.

---

## Project 3: Chat Server

**Objective:** Build a multi-client chat server.

**Checklist:**

- [ ] Implement TCP server with threading
- [ ] Handle multiple clients
- [ ] Implement message broadcasting
- [ ] Add user authentication
- [ ] Add private messaging
- [ ] Add room creation
- [ ] Implement graceful disconnection
- [ ] Add logging
- [ ] Add command-line interface
- [ ] Document the code

**Presentation:** Demonstrate the chat server with multiple clients.

---

## Project 4: HTTP Server

**Objective:** Build a complete HTTP server.

**Checklist:**

- [ ] Implement HTTP request parsing
- [ ] Handle GET requests
- [ ] Serve static files
- [ ] Handle 404 errors
- [ ] Add support for POST
- [ ] Implement content types
- [ ] Add API endpoints
- [ ] Implement logging
- [ ] Add security headers
- [ ] Document the code

**Presentation:** Deploy the server and demonstrate web page delivery.

---

## Project 5: TLS Client and Server

**Objective:** Build a TLS server with certificate validation.

**Checklist:**

- [ ] Generate certificates
- [ ] Implement TLS server
- [ ] Implement TLS client
- [ ] Validate certificates
- [ ] Implement certificate verification
- [ ] Support cipher suite negotiation
- [ ] Add error handling
- [ ] Add logging
- [ ] Document the code
- [ ] Test secure communication

**Presentation:** Demonstrate secure communication between client and server.

---

## Project 6: Packet Analysis Toolkit

**Objective:** Build a comprehensive packet analysis tool.

**Checklist:**

- [ ] Capture packets in real-time
- [ ] Decode Ethernet frames
- [ ] Decode IP headers
- [ ] Decode TCP/UDP headers
- [ ] Analyze HTTP traffic
- [ ] Analyze DNS traffic
- [ ] Show protocol statistics
- [ ] Export results to file
- [ ] Add command-line interface
- [ ] Document the code

**Presentation:** Analyze a packet capture and explain the findings.

---

## Capstone Project: Network Monitoring System

**Objective:** Build a complete network monitoring system.

**Checklist:**

### Network Discovery
- [ ] Implement ARP scanning
- [ ] Implement port scanning
- [ ] Discover network topology
- [ ] Store device information

### Monitoring
- [ ] Continuously ping devices
- [ ] Check services
- [ ] Monitor bandwidth usage
- [ ] Track device status changes

### Alert System
- [ ] Detect device downtime
- [ ] Detect high latency
- [ ] Send email alerts
- [ ] Send Slack alerts

### Web Dashboard
- [ ] Display device status
- [ ] Show real-time updates
- [ ] Display history
- [ ] Show alerts
- [ ] Mobile-responsive design

### Data Storage
- [ ] Store device data
- [ ] Track historical data
- [ ] Export reports
- [ ] Monitor system health

**Presentation:** Deploy the system and demonstrate monitoring of your network.

---

# FINAL ASSESSMENT

## Comprehensive Exam

### Part 1: Multiple Choice

1. Which OSI layer is responsible for routing?
   - [ ] A) Application
   - [ ] B) Transport
   - [ ] C) Network
   - [ ] D) Data Link

2. What does ARP do?
   - [ ] A) Translates domain names to IPs
   - [ ] B) Translates IPs to MAC addresses
   - [ ] C) Assigns IP addresses
   - [ ] D) Secures network traffic

3. What is the DHCP DORA process?
   - [ ] A) Discover, Offer, Request, Acknowledge
   - [ ] B) Domain, Offer, Route, Accept
   - [ ] C) Data, Open, Receive, Acknowledge
   - [ ] D) Discover, Open, Request, Accept

4. Which protocol is connection-oriented?
   - [ ] A) UDP
   - [ ] B) TCP
   - [ ] C) DNS
   - [ ] D) SNMP

5. What is the purpose of the TTL field?
   - [ ] A) Ensure delivery
   - [ ] B) Prevent loops
   - [ ] C) Encrypt data
   - [ ] D) Compress packets

### Part 2: Short Answer

1. Explain the difference between TCP and UDP.

2. What is the three-way handshake and why is it important?

3. Describe the DNS resolution process.

4. What is subnetting and why is it useful?

5. Explain how TLS secures communications.

### Part 3: Practical Exercise

**Scenario:** Users report that they cannot access `https://api.example.com`. The website is down.

**Question:** What steps would you take to diagnose and resolve this issue?

**Answer:** (Write your step-by-step diagnosis)

1. ____________________________________________________________

2. ____________________________________________________________

3. ____________________________________________________________

4. ____________________________________________________________

5. ____________________________________________________________

6. ____________________________________________________________

### Part 4: Reflection

1. What was the most important concept you learned in this series?

2. How will you apply this knowledge in your work?

3. What topics would you like to learn more about?

4. What was the most challenging topic and how did you overcome it?

---

## Answer Key

### Knowledge Check: Part 1
1. OSI, TCP/IP
2. protocol
3. Encapsulation
4. 48, 6
5. FF:FF:FF:FF:FF:FF
6. Address Resolution Protocol
7. DORA
8. broadcast, unicast
9. 64
10. Virtual Local Area Network

### True or False: Part 1
1. F
2. T
3. T
4. T
5. T
6. F
7. T
8. T
9. F
10. T

### Knowledge Check: Part 2
1. 32
2. 128
3. Classless Inter-Domain Routing
4. Network Address Translation
5. 64
6. Internet Control Message Protocol
7. 8, 0
8. TTL
9. not in the local routing table
10. fe80::/10

### Knowledge Check: Part 3
1. unreliable, reliable
2. three-way handshake
3. sequence number
4. 8
5. 20
6. congestion
7. RST
8. graceful close
9. socket
10. 0, 65535

### Knowledge Check: Part 4
1. domain names, IP addresses
2. .uk
3. Hypertext Transfer Protocol
4. 2xx
5. safe
6. 25
7. POP3
8. IMAP
9. OIDs
10. A

### Knowledge Check: Part 5
1. Symmetric, asymmetric
2. Transport Layer Security
3. 1
4. Perfect Forward Secrecy
5. QUIC
6. Quick UDP Internet Connections
7. 1
8. Follow Stream
9. TLS
10. TLS

---

**Congratulations on completing the Demystifying Network Protocols Student Workbook!**

This workbook was designed to help you build deep, practical understanding of network protocols. Fill it out completely, track your progress, and revisit challenging sections as needed. The skills you develop here will serve you throughout your career.

---

**[END OF STUDENT WORKBOOK]**
