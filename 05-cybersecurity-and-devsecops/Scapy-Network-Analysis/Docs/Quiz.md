# Mastering Network Packet Crafting with Scapy
## Quiz and Test Bank with Answer Keys

## Overview

This document contains a comprehensive quiz and test bank for the **Mastering Network Packet Crafting with Scapy** series. It includes:

- **Module Quizzes** (10-15 questions each)
- **Module Tests** (20-25 questions each)
- **Final Exam** (50 questions)
- **Practical Exercises** (Hands-on tasks)
- **Answer Keys** for all questions

---

## Table of Contents

1. [Module 1 Quiz: Foundations](#module-1-quiz)
2. [Module 1 Test](#module-1-test)
3. [Module 2 Quiz: Layer 2 & 3](#module-2-quiz)
4. [Module 2 Test](#module-2-test)
5. [Module 3 Quiz: Transport Layer](#module-3-quiz)
6. [Module 3 Test](#module-3-test)
7. [Module 4 Quiz: Sniffing & Analysis](#module-4-quiz)
8. [Module 4 Test](#module-4-test)
9. [Module 5 Quiz: Active Manipulation](#module-5-quiz)
10. [Module 5 Test](#module-5-test)
11. [Module 6 Quiz: Automation & Custom](#module-6-quiz)
12. [Module 6 Test](#module-6-test)
13. [Final Exam](#final-exam)
14. [Practical Exercises](#practical-exercises)
15. [Answer Keys](#answer-keys)

---

## Module 1 Quiz: Foundations of Packet Crafting

**Instructions:** Answer the following questions. Each question is worth 1 point. Total: 15 points.

---

### Multiple Choice

**1. What does the `/` operator do in Scapy?**

A) Divides two numbers
B) Stacks protocol layers (encapsulation)
C) Comments out code
D) Performs bitwise OR

**2. Which of the following is the correct order for building an HTTP packet?**

A) `TCP() / IP() / Ether() / Raw()`
B) `Ether() / IP() / TCP() / Raw()`
C) `Raw() / TCP() / IP() / Ether()`
D) `IP() / Ether() / TCP() / Raw()`

**3. What is the purpose of `packet.show2()`?**

A) Shows the packet with a different color scheme
B) Shows the packet after Scapy has calculated checksums and lengths
C) Shows only the first layer of the packet
D) Shows the packet in binary format

**4. Which function is used to read a PCAP file?**

A) `readpcap()`
B) `loadpcap()`
C) `rdpcap()`
D) `pcap_read()`

**5. What privilege is typically required to send raw packets?**

A) No special privileges
B) User-level privileges
C) Root/Administrator privileges
D) Network privileges only

---

### True/False

**6.** `packet.summary()` provides a one-line description of a packet.

**7.** The `Raw` layer in Scapy represents the Ethernet header.

**8.** Virtual environments are optional but recommended for Scapy projects.

**9.** `wrpcap()` writes packets to a PCAP file.

**10.** Scapy can only run on Linux operating systems.

---

### Fill in the Blank

**11.** The __________ operator in Scapy is used to stack protocol layers.

**12.** To check if a packet has a TCP layer, you use the __________ method.

**13.** The function __________ is used to save packets to a PCAP file.

**14.** The __________ function is used to load packets from a PCAP file.

**15.** In Scapy, Ethernet frames are constructed using the __________ class.

---

### Answer Key for Quiz 1

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | B | 9 | True |
| 2 | B | 10 | False |
| 3 | B | 11 | / (slash) |
| 4 | C | 12 | haslayer() |
| 5 | C | 13 | wrpcap() |
| 6 | True | 14 | rdpcap() |
| 7 | False | 15 | Ether |
| 8 | True | | |

---

## Module 1 Test

**Instructions:** Answer the following questions. Total: 25 points. Show your work for code questions.

---

### Multiple Choice (10 points)

**1. Which of the following is NOT a valid packet inspection method in Scapy?**

A) `packet.show()`
B) `packet.display()`
C) `packet.summary()`
D) `hexdump(packet)`

**2. What is the default TTL value for an IP packet in Scapy?**

A) 32
B) 64
C) 128
D) 255

**3. Which module contains the `rdpcap()` and `wrpcap()` functions?**

A) `scapy.packet`
B) `scapy.fields`
C) `scapy.utils`
D) `scapy.sendrecv`

**4. What is the purpose of `packet.sprintf("%IP.src% -> %IP.dst%")`?**

A) Formats the packet as a string with source and destination IP
B) Saves the packet to a file
C) Sends the packet to the network
D) Calculates the packet checksum

**5. Which of the following correctly creates a UDP packet?**

A) `IP() / UDP()`
B) `Ether() / UDP()`
C) `UDP() / IP()`
D) `Raw() / UDP()`

**6. What does `packet.haslayer(TCP)` return?**

A) The TCP layer object
B) True if TCP layer exists, False otherwise
C) The TCP checksum
D) The TCP port number

**7. Which function is used to get the list of available network interfaces?**

A) `get_interfaces()`
B) `get_if_list()`
C) `list_ifaces()`
D) `network_interfaces()`

**8. What is the result of `bytes(packet)`?**

A) The packet as a string
B) The packet as raw bytes
C) The packet length
D) The packet checksum

**9. Which layer is the outermost layer in a typical Ethernet/IP/TCP/HTTP packet?**

A) HTTP
B) TCP
C) IP
D) Ethernet

**10. What is the purpose of a virtual environment?**

A) To create virtual machines
B) To isolate project dependencies
C) To speed up packet processing
D) To simulate network traffic

---

### Short Answer (10 points)

**11.** Explain the difference between `packet.show()` and `packet.show2()`.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**12.** What is the difference between `rdpcap()` and `PcapReader()`?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**13.** Write the code to create a TCP SYN packet to 8.8.8.8 port 80.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**14.** Write the code to load a PCAP file named "capture.pcap" and display the first packet.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**15.** What is the purpose of the `Raw` layer in Scapy?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Code Writing (5 points)

**16.** Write a complete Python script that:
- Creates three packets: an ICMP ping, a TCP SYN, and a UDP DNS query
- Saves all three packets to a PCAP file named "output/first_three.pcap"
- Displays the summary of each packet

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Module 2 Quiz: Layer 2 & Layer 3 Operations

**Instructions:** Answer the following questions. Each question is worth 1 point. Total: 15 points.

---

### Multiple Choice

**1. What is the size of a MAC address in bytes?**

A) 4
B) 6
C) 8
D) 12

**2. Which MAC address represents a broadcast frame?**

A) `00:00:00:00:00:00`
B) `01:00:5e:00:00:01`
C) `ff:ff:ff:ff:ff:ff`
D) `00:11:22:33:44:55`

**3. What is the EtherType value for IPv4?**

A) `0x0800`
B) `0x0806`
C) `0x86DD`
D) `0x8100`

**4. Which field identifies the protocol inside an Ethernet frame?**

A) Preamble
B) MAC address
C) EtherType
D) FCS

**5. What is the purpose of ARP?**

A) To route packets between networks
B) To resolve IP addresses to MAC addresses
C) To encrypt network traffic
D) To assign IP addresses automatically

**6. What is the EtherType value for VLAN (802.1Q)?**

A) `0x0800`
B) `0x0806`
C) `0x86DD`
D) `0x8100`

**7. How does traceroute discover the path to a destination?**

A) By sending ICMP Echo Requests
B) By incrementing the TTL value
C) By using UDP to probe all ports
D) By querying DNS servers

**8. What is the maximum VLAN ID value?**

A) 255
B) 1023
C) 4095
D) 65535

**9. What does the DF flag in an IP packet do?**

A) Defragment the packet
B) Don't Fragment the packet
C) Drop the packet
D) Delay the packet

**10. What protocol is used by ping?**

A) TCP
B) UDP
C) ICMP
D) ARP

---

### True/False

**11.** Unicast MAC addresses have the first bit of the first byte set to 0.

**12.** VLAN tagging adds 4 bytes to the Ethernet frame.

**13.** ARP requests are sent as unicast packets.

**14.** The TTL field in IP packets prevents packets from looping forever.

**15.** Ethernet frames have a maximum payload of 1500 bytes.

---

### Answer Key for Quiz 2

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | B | 9 | B |
| 2 | C | 10 | C |
| 3 | A | 11 | True |
| 4 | C | 12 | True |
| 5 | B | 13 | False |
| 6 | D | 14 | True |
| 7 | B | 15 | True |
| 8 | C | | |

---

## Module 2 Test

**Instructions:** Answer the following questions. Total: 30 points. Show your work for code questions.

---

### Multiple Choice (10 points)

**1. Which of the following is a valid multicast MAC address?**

A) `00:11:22:33:44:55`
B) `01:00:5e:00:00:01`
C) `ff:ff:ff:ff:ff:ff`
D) `00:00:00:00:00:00`

**2. What is the EtherType for ARP?**

A) `0x0800`
B) `0x0806`
C) `0x86DD`
D) `0x8100`

**3. In a Q-in-Q frame, how many VLAN tags are present?**

A) 0
B) 1
C) 2
D) 3

**4. What is the purpose of the VLAN priority field?**

A) To identify the VLAN
B) To provide Quality of Service (QoS)
C) To encrypt the frame
D) To indicate frame length

**5. What is the default TTL value used by most operating systems?**

A) 32
B) 64
C) 128
D) 255

**6. Which of the following correctly builds an ARP request?**

A) `Ether() / ARP(op=1)`
B) `IP() / ARP(op=1)`
C) `Ether() / ARP(op=2)`
D) `TCP() / ARP(op=1)`

**7. What ICMP type is used for Echo Request?**

A) 0
B) 8
C) 11
D) 3

**8. What is the purpose of the Fragment Offset field in an IP packet?**

A) To identify the fragment
B) To indicate the position of the fragment in the original packet
C) To store the fragment checksum
D) To indicate the fragment length

**9. Which of the following is NOT a MAC address type?**

A) Unicast
B) Multicast
C) Broadcast
D) Anycast

**10. What is the VLAN protocol ID (TPID) value?**

A) `0x0800`
B) `0x0806`
C) `0x8100`
D) `0x86DD`

---

### Short Answer (12 points)

**11.** Explain the difference between unicast, multicast, and broadcast addresses.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**12.** How does ARP work? Describe the request/reply process.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**13.** What is VLAN tagging and why is it used?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**14.** Explain how traceroute works.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**15.** What is the difference between VLAN and Q-in-Q?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**16.** What is IP fragmentation and when is it needed?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Code Writing (8 points)

**17.** Write a complete Python script that:
- Performs an ARP scan on the local network (192.168.1.0/24)
- Displays all discovered hosts (IP and MAC)
- Checks for duplicate IP addresses

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**18.** Write a complete Python script that:
- Implements a traceroute to 8.8.8.8
- Displays each hop with its IP address
- Stops when the destination is reached or 30 hops are exceeded

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Module 3 Quiz: Transport Layer Protocols & Reconnaissance

**Instructions:** Answer the following questions. Each question is worth 1 point. Total: 15 points.

---

### Multiple Choice

**1. What is the size of a TCP header (minimum)?**

A) 8 bytes
B) 20 bytes
C) 32 bytes
D) 60 bytes

**2. Which TCP flag is used to establish a connection?**

A) FIN
B) ACK
C) SYN
D) RST

**3. What is the size of a UDP header?**

A) 8 bytes
B) 20 bytes
C) 32 bytes
D) 60 bytes

**4. Which scan type is considered "half-open"?**

A) Connect scan
B) SYN scan
C) UDP scan
D) FIN scan

**5. What protocol is used by the three-way handshake?**

A) UDP
B) TCP
C) ICMP
D) ARP

**6. Which TCP flag is used to reset a connection?**

A) FIN
B) ACK
C) SYN
D) RST

**7. What is the purpose of the sequence number in TCP?**

A) To identify the packet
B) To ensure ordered delivery
C) To detect duplicates
D) All of the above

**8. Which scan type does NOT require root privileges?**

A) SYN scan
B) Connect scan
C) FIN scan
D) XMAS scan

**9. What is banner grabbing used for?**

A) To identify service versions
B) To test network speed
C) To discover open ports
D) To generate traffic

**10. What is the well-known port for HTTPS?**

A) 80
B) 443
C) 22
D) 53

---

### True/False

**11.** UDP is a connection-oriented protocol.

**12.** The ACK flag acknowledges received data.

**13.** FIN and RST both terminate TCP connections.

**14.** UDP scans are faster than TCP scans.

**15.** Banner grabbing can reveal service vulnerabilities.

---

### Answer Key for Quiz 3

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | B | 9 | A |
| 2 | C | 10 | B |
| 3 | A | 11 | False |
| 4 | B | 12 | True |
| 5 | B | 13 | True |
| 6 | D | 14 | False |
| 7 | D | 15 | True |
| 8 | B | | |

---

## Module 3 Test

**Instructions:** Answer the following questions. Total: 30 points. Show your work for code questions.

---

### Multiple Choice (10 points)

**1. Which of the following is NOT a TCP flag?**

A) SYN
B) ACK
C) URG
D) UDP

**2. What is the well-known port for DNS?**

A) 53
B) 80
C) 443
D) 22

**3. Which scan type is considered the most stealthy?**

A) Connect scan
B) SYN scan
C) UDP scan
D) Connect scan

**4. What does the window size field in TCP control?**

A) The size of the TCP header
B) The amount of data that can be sent without ACK
C) The number of packets in the window
D) The time to wait for ACK

**5. What is the purpose of the checksum in TCP?**

A) To encrypt the data
B) To detect errors in the segment
C) To compress the data
D) To identify the application

**6. Which of the following correctly builds a TCP SYN packet?**

A) `IP() / TCP(flags="S")`
B) `IP() / TCP(flags="A")`
C) `IP() / TCP(flags="F")`
D) `IP() / TCP(flags="R")`

**7. What is the difference between SYN and Connect scans?**

A) SYN scan is faster
B) SYN scan is more stealthy
C) Connect scan completes the handshake
D) All of the above

**8. What is the well-known port for SSH?**

A) 21
B) 22
C) 23
D) 25

**9. Which type of scan sends FIN packets?**

A) SYN scan
B) Connect scan
C) FIN scan
D) UDP scan

**10. What is the purpose of the PSH flag?**

A) To push data immediately
B) To reset the connection
C) To finish the connection
D) To acknowledge data

---

### Short Answer (12 points)

**11.** Explain the TCP three-way handshake.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**12.** What is the difference between TCP and UDP?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**13.** Explain the difference between SYN scan and Connect scan.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**14.** What is banner grabbing and why is it useful?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**15.** Why is UDP scanning difficult?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**16.** Explain the TCP four-way termination sequence.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Code Writing (8 points)

**17.** Write a complete Python script that:
- Implements a SYN scanner for a target IP
- Scans ports 1-1024
- Uses multi-threading (10 threads)
- Displays open ports

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**18.** Write a complete Python script that:
- Performs a TCP connect scan on a target IP
- Grabs banners from open ports
- Displays the banner information

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Module 4 Quiz: Packet Sniffing, Filtering & Traffic Analysis

**Instructions:** Answer the following questions. Each question is worth 1 point. Total: 15 points.

---

### Multiple Choice

**1. Which function is used to capture live packets in Scapy?**

A) `capture()`
B) `sniff()`
C) `listen()`
D) `receive()`

**2. What does BPF stand for?**

A) Berkeley Packet Filter
B) Binary Packet Format
C) Basic Packet Filter
D) Byte Protocol Format

**3. Which BPF filter captures only TCP traffic?**

A) `tcp`
B) `tcp only`
C) `proto tcp`
D) `protocol tcp`

**4. What is promiscuous mode used for?**

A) To capture all packets on the network
B) To encrypt packet data
C) To filter packet traffic
D) To compress packet captures

**5. Which of the following is a valid BPF filter?**

A) `tcp port 80`
B) `tcp.port == 80`
C) `tcp:port=80`
D) `tcp[port=80]`

**6. What is flow tracking?**

A) Tracking the flow of data between applications
B) Tracking conversations between hosts
C) Tracking packet flow through the network
D) Tracking the flow of TCP segments

**7. Which port is used by DNS?**

A) 53
B) 80
C) 443
D) 22

**8. What is the purpose of `sniff(store=False)`?**

A) To not store packets in memory
B) To disable packet capture
C) To store packets to disk
D) To enable promiscuous mode

**9. Which BPF filter captures traffic to/from IP 192.168.1.100?**

A) `ip 192.168.1.100`
B) `host 192.168.1.100`
C) `addr 192.168.1.100`
D) `target 192.168.1.100`

**10. What is the purpose of the `prn` parameter in `sniff()`?**

A) To specify the interface
B) To specify the filter
C) To specify the callback function
D) To specify the count

---

### True/False

**11.** BPF filters operate at the user level, not the kernel level.

**12.** HTTP uses TCP port 80 by default.

**13.** DNS uses UDP port 53 by default.

**14.** The `sniff()` function can only capture packets on Ethernet interfaces.

**15.** Promiscuous mode allows a network interface to capture packets not addressed to it.

---

### Answer Key for Quiz 4

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | B | 9 | B |
| 2 | A | 10 | C |
| 3 | A | 11 | False |
| 4 | A | 12 | True |
| 5 | A | 13 | True |
| 6 | B | 14 | False |
| 7 | A | 15 | True |
| 8 | A | | |

---

## Module 4 Test

**Instructions:** Answer the following questions. Total: 30 points. Show your work for code questions.

---

### Multiple Choice (10 points)

**1. Which BPF filter captures only HTTP traffic?**

A) `http`
B) `tcp port 80`
C) `port 80`
D) `web traffic`

**2. What is the purpose of the `count` parameter in `sniff()`?**

A) To specify the number of packets to capture
B) To specify the number of seconds to capture
C) To specify the number of bytes to capture
D) To specify the number of interfaces to capture

**3. Which BPF filter captures DNS queries?**

A) `dns`
B) `udp port 53`
C) `port 53`
D) `dns query`

**4. What is the difference between `store=True` and `store=False` in `sniff()`?**

A) `store=True` saves packets to disk, `store=False` doesn't
B) `store=True` keeps packets in memory, `store=False` doesn't
C) `store=True` enables promiscuous mode, `store=False` doesn't
D) `store=True` captures all packets, `store=False` captures only filtered

**5. Which BPF filter captures SYN packets?**

A) `tcp[13] & 0x02 != 0`
B) `tcp[13] & 0x10 != 0`
C) `tcp[13] & 0x04 != 0`
D) `tcp[13] & 0x01 != 0`

**6. What is the DHCP DORA sequence?**

A) Discover, Offer, Request, Acknowledge
B) Discover, Offer, Response, Acknowledge
C) Data, Offer, Request, Acknowledge
D) Discover, Offer, Request, Answer

**7. Which HTTP method is used to retrieve a web page?**

A) POST
B) GET
C) PUT
D) DELETE

**8. What is the purpose of TCP flag analysis?**

A) To identify connection state changes
B) To measure packet size
C) To count packets
D) To detect encryption

**9. Which BPF filter captures broadcast packets?**

A) `broadcast`
B) `ether broadcast`
C) `ether dst ff:ff:ff:ff:ff:ff`
D) `multicast`

**10. What is the purpose of DNS monitoring?**

A) To track domain name resolutions
B) To measure DNS response time
C) To count DNS packets
D) All of the above

---

### Short Answer (12 points)

**11.** Explain the purpose of BPF filters and why they are important for packet capture.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**12.** Describe the DHCP DORA sequence and its purpose.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**13.** What is promiscuous mode and when should it be used?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**14.** Explain the difference between HTTP and HTTPS traffic analysis.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**15.** What is flow tracking and why is it useful for network analysis?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**16.** Explain how to detect DNS anomalies using monitoring.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Code Writing (8 points)

**17.** Write a complete Python script that:
- Sniffs HTTP traffic on port 80
- Extracts and displays the HTTP method and Host header
- Counts requests by HTTP method (GET, POST, etc.)

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**18.** Write a complete Python script that:
- Monitors DNS traffic
- Tracks the frequency of domain queries
- Alerts when a domain is queried more than 10 times
- Displays the top 5 most queried domains

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Module 5 Quiz: Active Network Manipulation & Security Testing

**Instructions:** Answer the following questions. Each question is worth 1 point. Total: 15 points.

---

### Multiple Choice

**1. What is ARP spoofing?**

A) Sending forged ARP replies
B) Sending forged IP packets
C) Sending forged TCP segments
D) Sending forged UDP datagrams

**2. What is the purpose of ARP spoofing?**

A) To discover network topology
B) To perform man-in-the-middle attacks
C) To scan for open ports
D) To detect network errors

**3. How can ARP spoofing be detected?**

A) By monitoring MAC changes
B) By checking duplicate IPs
C) By analyzing ARP request rates
D) All of the above

**4. What is packet injection?**

A) Sending crafted packets to the network
B) Analyzing captured packets
C) Reading packets from a PCAP
D) Sniffing packets from the network

**5. What is a safety control for packet injection?**

A) Rate limiting
B) Target validation
C) Logging
D) All of the above

**6. What is responsible disclosure?**

A) Reporting vulnerabilities to the public immediately
B) Reporting vulnerabilities to the vendor privately first
C) Keeping vulnerabilities secret forever
D) Selling vulnerabilities to third parties

**7. What is a MITM attack?**

A) Man-in-the-middle attack
B) Machine-in-the-middle attack
C) Message-in-transmission attack
D) More-in-TCP attack

**8. What is the purpose of packet replay?**

A) To test network security
B) To reproduce network conditions
C) To perform performance testing
D) All of the above

**9. What is a rogue DHCP server?**

A) An unauthorized DHCP server on the network
B) A misconfigured DHCP server
C) A DHCP server with no addresses
D) A DHCP server on the wrong subnet

**10. What is the first step in detecting a rogue DHCP server?**

A) Block all DHCP traffic
B) Track DHCP offers from different servers
C) Shut down the network
D) Contact the network administrator

---

### True/False

**11.** ARP spoofing is always illegal.

**12.** Packet injection can be used for authorized security testing.

**13.** Gratuitous ARP is always malicious.

**14.** Rate limiting helps prevent network flooding during testing.

**15.** Responsible disclosure protects users from vulnerabilities.

---

### Answer Key for Quiz 5

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | A | 9 | A |
| 2 | B | 10 | B |
| 3 | D | 11 | False |
| 4 | A | 12 | True |
| 5 | D | 13 | False |
| 6 | B | 14 | True |
| 7 | A | 15 | True |
| 8 | D | | |

---

## Module 5 Test

**Instructions:** Answer the following questions. Total: 30 points. Show your work for code questions.

---

### Multiple Choice (10 points)

**1. Which of the following is a sign of ARP spoofing?**

A) IP with changing MAC addresses
B) Duplicate IP addresses
C) High rate of ARP replies
D) All of the above

**2. What is the purpose of rate limiting in packet injection?**

A) To prevent network flooding
B) To speed up packet injection
C) To increase packet size
D) To improve accuracy

**3. What is DNS tunneling?**

A) Using DNS to exfiltrate data
B) Using DNS to resolve domain names
C) Using DNS to route TCP traffic
D) Using DNS to encrypt traffic

**4. How can DNS tunneling be detected?**

A) By monitoring domain length
B) By monitoring query frequency
C) By analyzing domain patterns
D) All of the above

**5. What is a SYN flood?**

A) Sending many SYN packets
B) Sending many ACK packets
C) Sending many RST packets
D) Sending many FIN packets

**6. What is the purpose of authorizing targets for injection?**

A) To prevent accidental testing on unauthorized systems
B) To speed up packet injection
C) To increase packet size
D) To improve accuracy

**7. Which of the following is an example of responsible disclosure?**

A) Posting a vulnerability on social media immediately
B) Notifying the vendor and giving them time to fix it
C) Selling the vulnerability to the highest bidder
D) Ignoring the vulnerability

**8. What is the purpose of logging injection activities?**

A) To create an audit trail
B) To slow down the injection
C) To increase packet size
D) To improve accuracy

**9. What is a common indicator of DNS-based attacks?**

A) Long domain names
B) High query rates
C) Random subdomains
D) All of the above

**10. What is the difference between IDS and IPS?**

A) IDS detects, IPS prevents
B) IPS detects, IDS prevents
C) Both detect and prevent
D) Neither detects nor prevents

---

### Short Answer (12 points)

**11.** Explain how ARP spoofing works and how to detect it.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**12.** What are the safety controls that should be implemented for packet injection?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**13.** Explain the concept of responsible disclosure.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
**

14.** How can rogue DHCP servers be detected?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**15.** What is DNS tunneling and why is it a security concern?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**16.** Explain the ethical considerations for network security testing.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Code Writing (8 points)

**17.** Write a complete Python script that:
- Monitors ARP traffic for spoofing
- Detects MAC address changes for IPs
- Alerts when a MAC change is detected
- Maintains an IP-MAC mapping table

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**18.** Write a complete Python script that:
- Detects rogue DHCP servers on the network
- Maintains a list of authorized DHCP servers
- Alerts when an unauthorized DHCP server is detected
- Displays DHCP server information

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Module 6 Quiz: Automation, Performance & Custom Protocols

**Instructions:** Answer the following questions. Each question is worth 1 point. Total: 15 points.

---

### Multiple Choice

**1. What is the producer-consumer pattern?**

A) A design pattern for separating data production from processing
B) A pattern for creating network packets
C) A pattern for analyzing PCAP files
D) A pattern for scanning ports

**2. What is the purpose of multi-threading in packet processing?**

A) To process packets in parallel
B) To slow down packet processing
C) To compress packet data
D) To encrypt packet data

**3. What is asyncio used for?**

A) Asynchronous I/O operations
B) Synchronous I/O operations
C) Packet construction
D) Packet analysis

**4. What is a bloom filter used for?**

A) Fast membership testing
B) Packet encryption
C) Packet compression
D) Packet authentication

**5. How do you create a custom protocol in Scapy?**

A) By creating a class that inherits from Packet
B) By using the `Protocol` class
C) By modifying the `Packet` class
D) By using the `Custom` class

**6. What is the purpose of `bind_layers()` in Scapy?**

A) To bind two protocol layers together
B) To bind a packet to an interface
C) To bind a packet to a port
D) To bind a packet to an IP address

**7. What is the `fields_desc` attribute used for?**

A) To define packet fields
B) To define packet methods
C) To define packet classes
D) To define packet exceptions

**8. What is the purpose of the `mysummary()` method?**

A) To provide a custom summary for a protocol
B) To display the packet in hex
C) To send the packet
D) To calculate the checksum

**9. What is protocol fuzzing?**

A) Testing protocol robustness with malformed packets
B) Testing protocol speed
C) Testing protocol security
D) Testing protocol correctness

**10. What is the purpose of a queue in packet processing?**

A) To buffer packets between producer and consumer
B) To compress packet data
C) To encrypt packet data
D) To analyze packet data

---

### True/False

**11.** Custom protocols can extend Scapy's capabilities.

**12.** `asyncio` is only useful for network applications.

**13.** Bloom filters can have false positives.

**14.** Protocol fuzzing can help find security vulnerabilities.

**15.** Multi-threading always improves performance.

---

### Answer Key for Quiz 6

| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 1 | A | 9 | A |
| 2 | A | 10 | A |
| 3 | A | 11 | True |
| 4 | A | 12 | False |
| 5 | A | 13 | True |
| 6 | A | 14 | True |
| 7 | A | 15 | False |
| 8 | A | | |

---

## Module 6 Test

**Instructions:** Answer the following questions. Total: 30 points. Show your work for code questions.

---

### Multiple Choice (10 points)

**1. Which of the following is NOT a benefit of asynchronous processing?**

A) Non-blocking operations
B) Concurrent processing
C) Slower performance
D) Efficient resource usage

**2. What is the purpose of a deque in packet processing?**

A) To store a limited number of packets
B) To store an unlimited number of packets
C) To compress packet data
D) To encrypt packet data

**3. Which field type would you use for a single byte in a custom protocol?**

A) `ByteField`
B) `ShortField`
C) `IntField`
D) `LongField`

**4. What is the purpose of the `guess_payload_class` method?**

A) To determine the next layer
B) To determine the packet size
C) To determine the checksum
D) To determine the destination

**5. What is the difference between a bloom filter and a set?**

A) Bloom filters can have false positives
B) Sets can have false positives
C) Both can have false positives
D) Neither can have false positives

**6. What is the maximum size of a Scapy packet?**

A) 1500 bytes
B) 65535 bytes
C) 65536 bytes
D) Unlimited

**7. What is the purpose of the `unbind_layers()` function?**

A) To remove a protocol binding
B) To create a protocol binding
C) To update a protocol binding
D) To list protocol bindings

**8. Which of the following is a valid custom protocol field?**

A) `IPField`
B) `StringField`
C) `BinaryField`
D) `DataField`

**9. What is the advantage of using a PcapReader over rdpcap() for large files?**

A) It uses less memory
B) It's faster
C) It supports more formats
D) It's more compatible

**10. What is the purpose of the `count` parameter in `sniff()`?**

A) To specify the number of packets to capture
B) To specify the number of threads
C) To specify the number of bytes
D) To specify the number of interfaces

---

### Short Answer (12 points)

**11.** Explain the producer-consumer pattern and how it applies to packet processing.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**12.** How do you create a custom protocol in Scapy? Provide the key steps.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**13.** What is the difference between multi-threading and asyncio for packet processing?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**14.** Explain the concept of protocol fuzzing and its benefits.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**15.** What are bloom filters and how are they useful for packet analysis?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
**

16.** How can you optimize memory usage when processing large PCAP files?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Code Writing (8 points)

**17.** Write a complete Python script that:
- Defines a custom protocol with the following fields:
  - Version (1 byte)
  - Type (1 byte)
  - Sequence (4 bytes)
  - Data (variable length)
- Binds the protocol to IP with protocol number 253
- Creates and displays a packet using the custom protocol

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**18.** Write a complete Python script that:
- Implements a high-performance packet capture using the producer-consumer pattern
- Uses 4 worker threads to process captured packets
- Counts packets by protocol (TCP, UDP, ICMP)
- Displays statistics when stopped

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Final Exam

**Instructions:** Answer the following questions. Total: 50 points. This exam covers all modules.

---

### Multiple Choice (20 points)

**1. What does the `/` operator do in Scapy?**

A) Divides two numbers
B) Stacks protocol layers
C) Comments out code
D) Performs bitwise OR

**2. Which function is used to read a PCAP file?**

A) `readpcap()`
B) `loadpcap()`
C) `rdpcap()`
D) `pcap_read()`

**3. What is the size of a MAC address in bytes?**

A) 4
B) 6
C) 8
D) 12

**4. What is the EtherType value for IPv4?**

A) `0x0800`
B) `0x0806`
C) `0x86DD`
D) `0x8100`

**5. What is the purpose of ARP?**

A) To route packets between networks
B) To resolve IP addresses to MAC addresses
C) To encrypt network traffic
D) To assign IP addresses automatically

**6. Which TCP flag is used to establish a connection?**

A) FIN
B) ACK
C) SYN
D) RST

**7. What is the size of a UDP header?**

A) 8 bytes
B) 20 bytes
C) 32 bytes
D) 60 bytes

**8. Which function is used to capture live packets in Scapy?**

A) `capture()`
B) `sniff()`
C) `listen()`
D) `receive()`

**9. What does BPF stand for?**

A) Berkeley Packet Filter
B) Binary Packet Format
C) Basic Packet Filter
D) Byte Protocol Format

**10. Which BPF filter captures TCP port 80 traffic?**

A) `tcp port 80`
B) `port 80`
C) `http`
D) `tcp.port == 80`

**11. What is the maximum VLAN ID value?**

A) 255
B) 1023
C) 4095
D) 65535

**12. What is the well-known port for DNS?**

A) 53
B) 80
C) 443
D) 22

**13. Which scan type is considered "half-open"?**

A) Connect scan
B) SYN scan
C) UDP scan
D) FIN scan

**14. What is the purpose of packet injection?**

A) To send crafted packets to the network
B) To analyze captured packets
C) To read packets from a PCAP
D) To sniff packets from the network

**15. How can ARP spoofing be detected?**

A) By monitoring MAC changes
B) By checking duplicate IPs
C) By analyzing ARP request rates
D) All of the above

**16. What is the producer-consumer pattern?**

A) A design pattern for separating data production from processing
B) A pattern for creating network packets
C) A pattern for analyzing PCAP files
D) A pattern for scanning ports

**17. How do you create a custom protocol in Scapy?**

A) By creating a class that inherits from Packet
B) By using the `Protocol` class
C) By modifying the `Packet` class
D) By using the `Custom` class

**18. What is the purpose of `bind_layers()` in Scapy?**

A) To bind two protocol layers together
B) To bind a packet to an interface
C) To bind a packet to a port
D) To bind a packet to an IP address

**19. What is responsible disclosure?**

A) Reporting vulnerabilities to the public immediately
B) Reporting vulnerabilities to the vendor privately first
C) Keeping vulnerabilities secret forever
D) Selling vulnerabilities to third parties

**20. What is the purpose of the `sniff(store=False)` parameter?**

A) To not store packets in memory
B) To disable packet capture
C) To store packets to disk
D) To enable promiscuous mode

---

### True/False (10 points)

**21.** `packet.summary()` provides a one-line description of a packet.

**22.** VLAN tagging adds 4 bytes to the Ethernet frame.

**23.** UDP is a connection-oriented protocol.

**24.** The ACK flag acknowledges received data.

**25.** BPF filters operate at the user level, not the kernel level.

**26.** Promiscuous mode allows a network interface to capture packets not addressed to it.

**27.** ARP spoofing is always illegal.

**28.** Custom protocols can extend Scapy's capabilities.

**29.** Bloom filters can have false positives.

**30.** `asyncio` is only useful for network applications.

---

### Short Answer (12 points)

**31.** Explain the TCP three-way handshake.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**32.** Explain the difference between SYN scan and Connect scan.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**33.** What is VLAN tagging and why is it used?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
**

34.** Explain how ARP works.

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**35.** What are the safety controls for packet injection?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**36.** How do you create a custom protocol in Scapy?

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

### Code Writing (8 points)

**37.** Write a complete Python script that:
- Scans a target IP for open TCP ports using SYN scan
- Scans ports 1-1024
- Uses multi-threading (10 threads)
- Displays open ports with service names

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

**38.** Write a complete Python script that:
- Defines a custom protocol with at least 3 fields
- Binds the protocol to a parent protocol
- Creates and sends a packet using the custom protocol
- Demonstrates dissection of the custom protocol

```python
# Your code here:
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Practical Exercises

**Instructions:** These are hands-on exercises to test practical skills. Each exercise is worth 10 points.

---

### Exercise 1: Packet Construction and Analysis

**Task:** Create a Python script that:
1. Builds the following packets and saves them to a PCAP file:
   - An ICMP Echo Request to 8.8.8.8 with ID 12345 and sequence 1
   - A TCP SYN packet to port 443 with source port 54321
   - A UDP packet to port 53 with payload "DNS query"
2. Loads the PCAP file back
3. Displays the summary of each packet
4. Counts how many TCP packets are in the PCAP

**Scoring:**
- [ ] Correct packet construction (3 points)
- [ ] PCAP save and load (2 points)
- [ ] Packet summaries displayed (2 points)
- [ ] TCP packet count correct (3 points)

---

### Exercise 2: ARP Scanner

**Task:** Create a Python script that:
1. Performs an ARP scan on the local network (192.168.1.0/24)
2. Discovers all active hosts
3. Displays the results in a formatted table
4. Detects duplicate IP addresses
5. Optionally, can be run with a different network as input

**Scoring:**
- [ ] ARP request built correctly (2 points)
- [ ] Hosts discovered (2 points)
- [ ] Formatted table display (2 points)
- [ ] Duplicate IP detection (2 points)
- [ ] Command-line argument support (2 points)

---

### Exercise 3: HTTP Analyzer

**Task:** Create a Python script that:
1. Sniffs HTTP traffic on port 80
2. Extracts the following from each request:
   - HTTP method (GET, POST, etc.)
   - Request URI
   - Host header
3. Extracts the following from each response:
   - Status code
   - Content type
4. Maintains statistics on:
   - Methods used
   - Status codes returned
   - Top 5 hosts accessed
5. Stops after 50 packets

**Scoring:**
- [ ] HTTP traffic sniffing (2 points)
- [ ] Request extraction (2 points)
- [ ] Response extraction (2 points)
- [ ] Statistics maintained (2 points)
- [ ] Correct packet count (2 points)

---

### Exercise 4: ARP Spoofing Detector

**Task:** Create a Python script that:
1. Sniffs ARP traffic on the local network
2. Maintains an IP-MAC mapping table
3. Detects and alerts on:
   - MAC address changes for an IP
   - Duplicate IP addresses
   - High rate of ARP replies (>10 per second)
4. Displays a running log of ARP activity
5. Runs for 60 seconds and displays final statistics

**Scoring:**
- [ ] ARP traffic sniffing (2 points)
- [ ] IP-MAC mapping maintained (2 points)
- [ ] MAC change detection (2 points)
- [ ] Duplicate IP detection (2 points)
- [ ] Rate detection and statistics (2 points)

---

### Exercise 5: Custom Protocol

**Task:** Create a Python script that:
1. Defines a custom protocol with the following fields:
   - Version (1 byte, default 1)
   - Message Type (1 byte)
   - Sequence Number (4 bytes)
   - Flags (1 byte)
   - Payload Length (2 bytes)
   - Payload (variable, length determined by Payload Length)
2. Binds the protocol to IP with protocol number 253
3. Creates 3 packets with different message types
4. Saves the packets to a PCAP file
5. Loads the PCAP file and dissects the custom protocol
6. Displays the fields of each packet

**Scoring:**
- [ ] Protocol class defined correctly (3 points)
- [ ] Binding implemented (1 point)
- [ ] Packets created with different types (2 points)
- [ ] PCAP save and load (2 points)
- [ ] Dissection and display (2 points)

---

## Answer Keys

---

### Module 1 Test Answer Key

**Multiple Choice:**
1. B
2. B
3. C
4. A
5. A
6. B
7. B
8. B
9. D
10. B

**Short Answer:**

**11.** `packet.show()` displays the packet with default values (some fields may show `None`). `packet.show2()` displays the packet after Scapy has calculated checksums, lengths, and other derived fields.

**12.** `rdpcap()` loads the entire PCAP file into memory, which can be memory-intensive for large files. `PcapReader()` streams packets one at a time, making it memory-efficient for large PCAPs.

**13.** `packet = IP(dst="8.8.8.8") / TCP(dport=80, flags="S")`

**14.** `packets = rdpcap("capture.pcap"); packets[0].show()`

**15.** The `Raw` layer contains application data (the payload). It represents the actual data being carried by the packet.

**Code Writing:**

```python
#!/usr/bin/env python3
from scapy.all import IP, ICMP, TCP, UDP, wrpcap
import os

# Create packets
packets = []
packets.append(IP(dst="8.8.8.8") / ICMP())
packets.append(IP(dst="8.8.8.8") / TCP(dport=80, flags="S"))
packets.append(IP(dst="8.8.8.8") / UDP(dport=53))

# Save to PCAP
os.makedirs("output", exist_ok=True)
wrpcap("output/first_three.pcap", packets)

# Display summaries
for i, pkt in enumerate(packets, 1):
    print(f"Packet {i}: {pkt.summary()}")
```

---

### Module 2 Test Answer Key

**Multiple Choice:**
1. B
2. B
3. C
4. B
5. B
6. A
7. B
8. B
9. D
10. C

**Short Answer:**

**11.** Unicast: One-to-one communication (single destination). Multicast: One-to-many communication (group of destinations). Broadcast: One-to-all communication (all devices on network).

**12.** ARP sends a broadcast request "Who has IP X?" The device with that IP replies with a unicast response containing its MAC address.

**13.** VLAN tagging adds an 802.1Q tag to Ethernet frames to identify which VLAN the frame belongs to. It's used for network segmentation and management.

**14.** Traceroute sends packets with incrementing TTL values. Each router decrements TTL; when TTL reaches 0, the router returns ICMP Time Exceeded. The destination returns ICMP Echo Reply when reached.

**15.** VLAN uses a single 802.1Q tag (customer VLAN). Q-in-Q uses two tags: an outer provider VLAN and an inner customer VLAN.

**16.** IP fragmentation breaks large packets into smaller pieces for networks with smaller MTU. Fragments are reassembled at the destination.

**Code Writing:**

**17.**
```python
#!/usr/bin/env python3
from scapy.all import Ether, ARP, srp
import ipaddress

def arp_scan(network_cidr):
    print(f"Scanning: {network_cidr}")
    network = ipaddress.ip_network(network_cidr, strict=False)
    
    arp_request = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst=str(network))
    answered, unanswered = srp(arp_request, timeout=2, verbose=False)
    
    hosts = {}
    for sent, received in answered:
        hosts[received[ARP].psrc] = received[ARP].hwsrc
    
    print(f"\n{'IP Address':<20} {'MAC Address':<20}")
    print("-" * 40)
    for ip, mac in sorted(hosts.items()):
        print(f"{ip:<20} {mac:<20}")
    
    # Check for duplicates
    ip_to_macs = {}
    for ip, mac in hosts.items():
        if ip not in ip_to_macs:
            ip_to_macs[ip] = []
        ip_to_macs[ip].append(mac)
    
    duplicates = {ip: macs for ip, macs in ip_to_macs.items() if len(macs) > 1}
    if duplicates:
        print("\nDuplicate IPs found:")
        for ip, macs in duplicates.items():
            print(f"  {ip}: {', '.join(macs)}")
    
    return hosts

if __name__ == "__main__":
    hosts = arp_scan("192.168.1.0/24")
```

**18.**
```python
#!/usr/bin/env python3
from scapy.all import IP, ICMP, sr1
import time

def traceroute(target, max_hops=30, timeout=2):
    print(f"Traceroute to {target}")
    print("-" * 40)
    
    for ttl in range(1, max_hops + 1):
        packet = IP(dst=target, ttl=ttl) / ICMP()
        start = time.time()
        reply = sr1(packet, timeout=timeout, verbose=False)
        elapsed = (time.time() - start) * 1000
        
        if reply is None:
            print(f"{ttl:>4}. * * *")
            continue
        
        ip = reply[IP].src
        if reply.haslayer(ICMP):
            if reply[ICMP].type == 0:  # Echo Reply
                print(f"{ttl:>4}. {ip:<20} {elapsed:.2f}ms - Reached destination!")
                break
            elif reply[ICMP].type == 11:  # Time Exceeded
                print(f"{ttl:>4}. {ip:<20} {elapsed:.2f}ms")
        else:
            print(f"{ttl:>4}. {ip:<20} {elapsed:.2f}ms")

if __name__ == "__main__":
    traceroute("8.8.8.8")
```

---

### Module 3 Test Answer Key

**Multiple Choice:**
1. D
2. A
3. B
4. B
5. B
6. A
7. D
8. D
9. C
10. B

**Short Answer:**

**11.** TCP Three-Way Handshake: (1) Client sends SYN with sequence number; (2) Server responds with SYN-ACK; (3) Client sends ACK. Connection is established.

**12.** TCP is connection-oriented, reliable, ordered, with flow control. UDP is connectionless, unreliable, unordered, without flow control.

**13.** SYN scan is half-open (sends SYN, responds with RST). Connect scan completes the full handshake. SYN scan is stealthier and faster.

**14.** Banner grabbing identifies service versions by reading welcome banners, helping assess vulnerabilities.

**15.** UDP scanning is difficult because UDP is stateless, no response doesn't indicate closed (could be filtered), and only ICMP unreachable confirms closed.

**16.** TCP Termination: (1) FIN from one side; (2) ACK from other side; (3) FIN from other side; (4) ACK from first side.

**Code Writing:**

**17.**
```python
#!/usr/bin/env python3
from scapy.all import IP, TCP, sr1, send
import threading
import queue

class SYNScanner:
    def __init__(self, target, ports, threads=10, timeout=2):
        self.target = target
        self.ports = ports
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
        self.queue = queue.Queue()
        self.lock = threading.Lock()
    
    def scan_port(self, port):
        packet = IP(dst=self.target) / TCP(dport=port, flags="S")
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply and reply.haslayer(TCP):
            if reply[TCP].flags & 0x12:
                rst = IP(dst=self.target) / TCP(dport=port, flags="R", seq=reply[TCP].ack)
                send(rst, verbose=False)
                return True
        return False
    
    def worker(self):
        while not self.queue.empty():
            port = self.queue.get()
            if self.scan_port(port):
                with self.lock:
                    self.open_ports.append(port)
            self.queue.task_done()
    
    def scan(self):
        for port in self.ports:
            self.queue.put(port)
        
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        for t in threads:
            t.join()
        
        print(f"Open ports: {sorted(self.open_ports)}")

if __name__ == "__main__":
    scanner = SYNScanner("192.168.1.1", range(1, 1025))
    scanner.scan()
```

**18.**
```python
#!/usr/bin/env python3
import socket
import threading
import queue

class ConnectScanner:
    def __init__(self, target, ports, threads=10, timeout=3):
        self.target = target
        self.ports = ports
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
        self.banners = {}
        self.queue = queue.Queue()
        self.lock = threading.Lock()
    
    def grab_banner(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            sock.connect((self.target, port))
            
            probes = {
                22: b"SSH-2.0-Scapy\r\n",
                80: b"HEAD / HTTP/1.0\r\n\r\n",
                443: b"HEAD / HTTP/1.0\r\n\r\n",
                25: b"EHLO test\r\n",
            }
            
            if port in probes:
                sock.send(probes[port])
            
            banner = sock.recv(1024).decode('utf-8', errors='ignore')
            sock.close()
            return banner.strip()[:200]
        except:
            return None
    
    def scan_port(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((self.target, port))
            sock.close()
            
            if result == 0:
                banner = self.grab_banner(port)
                with self.lock:
                    self.open_ports.append(port)
                    if banner:
                        self.banners[port] = banner
        except:
            pass
    
    def worker(self):
        while not self.queue.empty():
            port = self.queue.get()
            self.scan_port(port)
            self.queue.task_done()
    
    def scan(self):
        for port in self.ports:
            self.queue.put(port)
        
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        for t in threads:
            t.join()
        
        print("\nOpen Ports:")
        print("-" * 60)
        for port in sorted(self.open_ports):
            banner = self.banners.get(port, "")
            print(f"Port {port}: {banner[:50] if banner else '(no banner)'}")

if __name__ == "__main__":
    scanner = ConnectScanner("192.168.1.1", range(1, 1025))
    scanner.scan()
```

---

### Module 4 Test Answer Key

**Multiple Choice:**
1. B
2. A
3. B
4. B
5. A
6. B
7. A
8. A
9. C
10. D

**Short Answer:**

**11.** BPF filters operate at the kernel level to capture specific packets efficiently. They reduce captured packet volume and improve performance by discarding unwanted packets before they reach user space.

**12.** DHCP DORA: Discover (client finds servers), Offer (server offers IP), Request (client requests offered IP), Acknowledge (server confirms). Assigns IP addresses automatically.

**13.** Promiscuous mode allows an interface to capture all packets on the network, not just those addressed to it. Used for network monitoring, troubleshooting, and security analysis.

**14.** HTTP traffic is unencrypted on port 80, allowing full analysis of requests/responses. HTTPS is encrypted on port 443, requiring TLS decryption for deep analysis.

**15.** Flow tracking monitors conversations between hosts (5-tuple: src/dst IP, src/dst port, protocol). Useful for understanding communication patterns, detecting anomalies, and network monitoring.

**16.** DNS anomalies: long domain names (tunneling), high query rates (DDoS), random subdomains (DGA), unusual TLDs, queries to known malicious domains.

**Code Writing:**

**17.**
```python
#!/usr/bin/env python3
from scapy.all import sniff, IP, TCP, Raw
from collections import defaultdict

class HTTPAnalyzer:
    def __init__(self):
        self.methods = defaultdict(int)
        self.hosts = defaultdict(int)
    
    def process(self, packet):
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
        
        lines = data.split('\r\n')
        if not lines:
            return
        
        # Check for request
        parts = lines[0].split(' ')
        if len(parts) >= 2 and parts[0] in ['GET', 'POST', 'PUT', 'DELETE', 'HEAD']:
            method = parts[0]
            self.methods[method] += 1
            print(f"\n[HTTP] {method} request: {parts[1] if len(parts) > 1 else '/'}")
            
            # Extract Host
            for line in lines:
                if line.lower().startswith('host:'):
                    host = line.split(':', 1)[1].strip()
                    self.hosts[host] += 1
                    print(f"  Host: {host}")
                    break

if __name__ == "__main__":
    analyzer = HTTPAnalyzer()
    sniff(filter="tcp port 80", prn=analyzer.process, count=50, store=False)
    
    print("\n" + "=" * 60)
    print("HTTP STATISTICS")
    print("=" * 60)
    print("\nMethods:")
    for method, count in sorted(analyzer.methods.items(), key=lambda x: x[1], reverse=True):
        print(f"  {method}: {count}")
    
    print("\nTop Hosts:")
    for host, count in sorted(analyzer.hosts.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {host}: {count}")
```

**18.**
```python
#!/usr/bin/env python3
from scapy.all import sniff, IP, UDP, DNS
from collections import defaultdict

class DNSMonitor:
    def __init__(self):
        self.queries = defaultdict(int)
        self.alerts = []
        self.count = 0
    
    def process(self, packet):
        if not packet.haslayer(DNS):
            return
        
        dns = packet[DNS]
        if dns.qr == 0 and dns.qd:  # Query
            qname = dns.qd.qname.decode('utf-8').rstrip('.')
            self.queries[qname] += 1
            self.count += 1
            
            if self.queries[qname] > 10:
                alert_msg = f"ALERT: {qname} queried {self.queries[qname]} times"
                print(alert_msg)
                self.alerts.append(alert_msg)
    
    def display_stats(self):
        print("\n" + "=" * 60)
        print("DNS STATISTICS")
        print("=" * 60)
        print(f"Total queries: {self.count}")
        print(f"Unique domains: {len(self.queries)}")
        
        print("\nTop 5 Domains:")
        print("-" * 40)
        for domain, count in sorted(self.queries.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {domain}: {count}")
        
        if self.alerts:
            print(f"\nAlerts: {len(self.alerts)}")

if __name__ == "__main__":
    monitor = DNSMonitor()
    sniff(filter="udp port 53", prn=monitor.process, count=100, store=False)
    monitor.display_stats()
```

---

### Module 5 Test Answer Key

**Multiple Choice:**
1. D
2. A
3. A
4. D
5. A
6. A
7. B
8. A
9. D
10. A

**Short Answer:**

**11.** ARP spoofing sends forged ARP replies claiming to be another host. Detection: monitor MAC changes, duplicate IPs, high ARP rates, gratuitous ARP.

**12.** Safety controls: authorization (target whitelisting), rate limiting (prevent flooding), target validation, logging (audit trail), confirmation (user verification).

**13.** Responsible disclosure: reporting vulnerabilities privately to the vendor first, giving them time to fix it, then coordinating public disclosure.

**14.** Rogue DHCP detection: track DHCP servers seen, compare with authorized list, alert on unknown servers offering IPs.

**15.** DNS tunneling uses DNS to exfiltrate data by encoding data in domain names. Security concern because it bypasses firewalls and security controls.

**16.** Ethical considerations: obtain authorization, practice in isolated labs, build defensive tools, respect privacy, disclose responsibly, stay within scope.

**Code Writing:**

**17.**
```python
#!/usr/bin/env python3
from scapy.all import sniff, ARP
from datetime import datetime

class ARPSpoofingDetector:
    def __init__(self):
        self.ip_mac_mapping = {}
        self.alerts = []
    
    def process(self, packet):
        if not packet.haslayer(ARP):
            return
        
        arp = packet[ARP]
        src_ip = arp.psrc
        src_mac = arp.hwsrc
        
        if src_ip == '0.0.0.0':
            return
        
        if src_ip in self.ip_mac_mapping:
            if self.ip_mac_mapping[src_ip] != src_mac:
                alert = f"[!] MAC change for {src_ip}: {self.ip_mac_mapping[src_ip]} -> {src_mac}"
                print(alert)
                self.alerts.append(alert)
        
        self.ip_mac_mapping[src_ip] = src_mac
        
        # Check for duplicate IPs
        for ip, mac in self.ip_mac_mapping.items():
            if ip != src_ip and mac == src_mac:
                alert = f"[!] Duplicate IP: {ip} and {src_ip} share MAC {src_mac}"
                print(alert)
                self.alerts.append(alert)
    
    def display_summary(self):
        print("\n" + "=" * 60)
        print("ARP DETECTION SUMMARY")
        print("=" * 60)
        print(f"IP-MAC mappings: {len(self.ip_mac_mapping)}")
        print(f"Alerts: {len(self.alerts)}")

if __name__ == "__main__":
    detector = ARPSpoofingDetector()
    sniff(filter="arp", prn=detector.process, timeout=30, store=False)
    detector.display_summary()
```

**18.**
```python
#!/usr/bin/env python3
from scapy.all import sniff, DHCP, BOOTP

class DHCPMonitor:
    def __init__(self, authorized_servers=None):
        self.authorized_servers = authorized_servers or {'192.168.1.1'}
        self.seen_servers = {}
    
    def process(self, packet):
        if not packet.haslayer(DHCP):
            return
        
        dhcp = packet[DHCP]
        bootp = packet[BOOTP]
        
        # Get message type
        msg_type = None
        for option in dhcp.options:
            if isinstance(option, tuple) and option[0] == 'message-type':
                msg_type = option[1]
                break
        
        if msg_type in [2, 5]:  # OFFER or ACK
            server_ip = packet[IP].src
            server_mac = packet[Ether].src
            
            if server_ip not in self.seen_servers:
                self.seen_servers[server_ip] = {
                    'mac': server_mac,
                    'offers': 0,
                    'first_seen': datetime.now()
                }
            
            self.seen_servers[server_ip]['offers'] += 1
            
            if server_ip not in self.authorized_servers:
                print(f"⚠️ ROGUE DHCP SERVER: {server_ip} ({server_mac})")
                print(f"   Offering IPs on the network!")
    
    def display_summary(self):
        print("\n" + "=" * 60)
        print("DHCP SERVER SUMMARY")
        print("=" * 60)
        print(f"Total DHCP servers: {len(self.seen_servers)}")
        print(f"Authorized servers: {', '.join(self.authorized_servers)}")
        
        for server, info in self.seen_servers.items():
            status = "✓" if server in self.authorized_servers else "⚠️ ROGUE"
            print(f"  {server} ({info['mac']}) - {status}")

if __name__ == "__main__":
    monitor = DHCPMonitor(authorized_servers={'192.168.1.1', '192.168.1.2'})
    sniff(filter="udp port 67 or udp port 68", prn=monitor.process, timeout=30, store=False)
    monitor.display_summary()
```

---

### Module 6 Test Answer Key

**Multiple Choice:**
1. C
2. A
3. A
4. A
5. A
6. D
7. A
8. A
9. A
10. A

**Short Answer:**

**11.** Producer-consumer pattern separates data production (packet capture) from data consumption (packet processing) using a queue. Producer captures packets and adds to queue; consumers process packets from queue in parallel.

**12.** Steps: (1) Create class inheriting from Packet; (2) Define `fields_desc` with field types; (3) Define `mysummary()` for custom summary; (4) Use `bind_layers()` to bind to parent protocol; (5) Test creation and dissection.

**13.** Multi-threading uses threads for concurrent execution; asyncio uses event loops for asynchronous operations. asyncio is better for I/O-bound tasks; threading for CPU-bound tasks.

**14.** Protocol fuzzing sends malformed or unexpected packets to test protocol robustness. Benefits: finds edge cases, discovers vulnerabilities, tests error handling.

**15.** Bloom filters provide fast membership testing with configurable false positive rate. Useful for packet analysis: IP tracking, duplicate detection, pattern matching with low memory usage.

**16.** Use PcapReader instead of rdpcap() to stream packets; use deques with maxlen to limit memory; process in batches; filter early; use efficient data structures.

**Code Writing:**

**17.**
```python
#!/usr/bin/env python3
from scapy.packet import Packet
from scapy.fields import ByteField, ShortField, IntField, StrLenField
from scapy.all import bind_layers, IP

class MyProtocol(Packet):
    name = "MyProtocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        IntField("sequence", 0),
        ByteField("flags", 0),
        ShortField("payload_len", 0),
        StrLenField("data", "", length_from=lambda p: p.payload_len)
    ]
    
    def mysummary(self):
        return f"MyProtocol v{self.version} type={self.type} seq={self.sequence} len={self.payload_len}"

# Bind to IP
bind_layers(IP, MyProtocol, proto=253)

# Create and display packet
pkt = MyProtocol(
    version=2,
    type=5,
    sequence=12345,
    flags=0x03,
    payload_len=10,
    data=b"Test Data"
)

print("Custom Protocol Packet:")
pkt.show()
print(f"Summary: {pkt.mysummary()}")

# Stack with IP
ip_pkt = IP(src="192.168.1.100", dst="192.168.1.1", proto=253) / pkt
print("\nStacked with IP:")
ip_pkt.show()
```

**18.**
```python
#!/usr/bin/env python3
from scapy.all import sniff, IP, TCP, UDP, ICMP
import threading
import queue
import time
from collections import defaultdict

class HighPerformanceCapture:
    def __init__(self, workers=4, buffer_size=10000):
        self.workers = workers
        self.packet_queue = queue.Queue(maxsize=buffer_size)
        self.running = False
        self.protocol_counts = defaultdict(int)
        self.lock = threading.Lock()
        self.stats = {'captured': 0, 'processed': 0}
    
    def packet_callback(self, packet):
        try:
            self.packet_queue.put_nowait(packet)
            with self.lock:
                self.stats['captured'] += 1
        except queue.Full:
            pass
    
    def worker(self):
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
        if packet.haslayer(TCP):
            self.protocol_counts['TCP'] += 1
        elif packet.haslayer(UDP):
            self.protocol_counts['UDP'] += 1
        elif packet.haslayer(ICMP):
            self.protocol_counts['ICMP'] += 1
        elif packet.haslayer(IP):
            self.protocol_counts['Other_IP'] += 1
        else:
            self.protocol_counts['Other'] += 1
    
    def start(self, count=None, timeout=None):
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
            sniff(prn=self.packet_callback, count=count, timeout=timeout, store=False)
        except KeyboardInterrupt:
            print("\nStopping...")
        finally:
            self.running = False
            elapsed = time.time() - start_time
            
            for t in threads:
                t.join(timeout=1)
            
            self.display_stats(elapsed)
    
    def display_stats(self, elapsed):
        print("\n" + "=" * 60)
        print("CAPTURE STATISTICS")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Captured: {self.stats['captured']}")
        print(f"Processed: {self.stats['processed']}")
        print(f"Rate: {self.stats['captured'] / max(1, elapsed):.1f} pkts/s")
        
        print("\nProtocol Distribution:")
        print("-" * 40)
        total = sum(self.protocol_counts.values())
        for proto, count in sorted(self.protocol_counts.items(), key=lambda x: x[1], reverse=True):
            pct = (count / max(1, total)) * 100
            print(f"  {proto}: {count} ({pct:.1f}%)")

if __name__ == "__main__":
    capture = HighPerformanceCapture(workers=4)
    capture.start(count=100)
```

---

### Final Exam Answer Key

**Multiple Choice:**
1. B
2. C
3. B
4. A
5. B
6. C
7. A
8. B
9. A
10. A
11. C
12. A
13. B
14. A
15. D
16. A
17. A
18. A
19. B
20. A

**True/False:**
21. True
22. True
23. False
24. True
25. False
26. True
27. False
28. True
29. True
30. False

**Short Answer:**

**31.** TCP Three-Way Handshake: (1) Client sends SYN with sequence number; (2) Server responds with SYN-ACK; (3) Client sends ACK. Connection established.

**32.** SYN scan is half-open (SYN, RST response), stealthier, faster. Connect scan completes full handshake, more detectable, works without root.

**33.** VLAN tagging adds 802.1Q tags to Ethernet frames for network segmentation, security, and management.

**34.** ARP broadcasts "Who has IP X?" The owner replies with MAC address. Mappings are cached for efficiency.

**35.** Safety controls: authorization (whitelist), rate limiting, target validation, logging, user confirmation.

**36.** Steps: (1) Create Packet subclass; (2) Define fields_desc; (3) Implement mysummary(); (4) Bind to parent protocol; (5) Test creation/dissection.

**Code Writing:**

**37.**
```python
#!/usr/bin/env python3
from scapy.all import IP, TCP, sr1, send
import threading
import queue

class SYNScanner:
    SERVICES = {
        20: 'FTP-Data', 21: 'FTP', 22: 'SSH', 23: 'Telnet',
        25: 'SMTP', 53: 'DNS', 80: 'HTTP', 443: 'HTTPS',
        3306: 'MySQL', 3389: 'RDP', 5432: 'PostgreSQL'
    }
    
    def __init__(self, target, threads=10, timeout=2):
        self.target = target
        self.threads = threads
        self.timeout = timeout
        self.open_ports = []
        self.queue = queue.Queue()
        self.lock = threading.Lock()
    
    def scan_port(self, port):
        packet = IP(dst=self.target) / TCP(dport=port, flags="S")
        reply = sr1(packet, timeout=self.timeout, verbose=False)
        
        if reply and reply.haslayer(TCP):
            if reply[TCP].flags & 0x12:
                rst = IP(dst=self.target) / TCP(dport=port, flags="R", seq=reply[TCP].ack)
                send(rst, verbose=False)
                return True
        return False
    
    def worker(self):
        while not self.queue.empty():
            port = self.queue.get()
            if self.scan_port(port):
                with self.lock:
                    self.open_ports.append(port)
            self.queue.task_done()
    
    def scan(self):
        for port in range(1, 1025):
            self.queue.put(port)
        
        threads = []
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.start()
            threads.append(t)
        
        for t in threads:
            t.join()
        
        print("\nOpen Ports:")
        print("-" * 50)
        for port in sorted(self.open_ports):
            service = self.SERVICES.get(port, 'Unknown')
            print(f"  {port:<6} {service}")

if __name__ == "__main__":
    import sys
    target = sys.argv[1] if len(sys.argv) > 1 else input("Target IP: ")
    scanner = SYNScanner(target)
    scanner.scan()
```

**38.**
```python
#!/usr/bin/env python3
from scapy.packet import Packet
from scapy.fields import ByteField, ShortField, IntField, StrLenField
from scapy.all import bind_layers, IP, send, sr1

class CustomProtocol(Packet):
    name = "CustomProtocol"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        ByteField("flags", 0),
        ShortField("length", 0),
        IntField("sequence", 0),
        StrLenField("data", "", length_from=lambda p: p.length)
    ]
    
    def mysummary(self):
        return f"CustomProtocol v{self.version} type={self.type} seq={self.sequence} len={self.length}"

# Bind to IP protocol 250
bind_layers(IP, CustomProtocol, proto=250)

def demo():
    # Create packet
    pkt = CustomProtocol(
        version=2,
        type=5,
        flags=0x03,
        sequence=12345,
        length=12,
        data=b"Custom Data!"
    )
    
    print("Original Custom Protocol Packet:")
    pkt.show()
    print(f"Summary: {pkt.mysummary()}")
    
    # Stack with IP
    ip_pkt = IP(src="192.168.1.100", dst="8.8.8.8", proto=250) / pkt
    print("\nIP Stacked Packet:")
    ip_pkt.show()
    
    # Dissection from raw bytes
    raw_bytes = bytes(ip_pkt)
    dissected = IP(raw_bytes)
    print("\nDissected Packet:")
    print(f"  IP Protocol: {dissected[IP].proto}")
    if dissected.haslayer(CustomProtocol):
        print(f"  CustomProtocol: {dissected[CustomProtocol].mysummary()}")
        print(f"  Data: {dissected[CustomProtocol].data}")
    else:
        print("  CustomProtocol not found (dissection failed)")

if __name__ == "__main__":
    demo()
```

---

## Grading Guide

### Module Tests

| Module | Points | Grade Scale |
|--------|--------|-------------|
| Module 1 Test | 25 | A: 22-25, B: 19-21, C: 16-18, D: 13-15, F: <13 |
| Module 2 Test | 30 | A: 27-30, B: 23-26, C: 20-22, D: 17-19, F: <17 |
| Module 3 Test | 30 | A: 27-30, B: 23-26, C: 20-22, D: 17-19, F: <17 |
| Module 4 Test | 30 | A: 27-30, B: 23-26, C: 20-22, D: 17-19, F: <17 |
| Module 5 Test | 30 | A: 27-30, B: 23-26, C: 20-22, D: 17-19, F: <17 |
| Module 6 Test | 30 | A: 27-30, B: 23-26, C: 20-22, D: 17-19, F: <17 |

### Final Exam

| Score | Grade |
|-------|-------|
| 45-50 | A |
| 40-44 | B |
| 35-39 | C |
| 30-34 | D |
| <30 | F |

### Practical Exercises

Each exercise is worth 10 points:
- 9-10: Excellent
- 7-8: Good
- 5-6: Satisfactory
- <5: Needs Improvement

---

**End of Quiz and Test Bank**
