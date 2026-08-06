# Comprehensive Quiz and Test Bank

## Demystifying Network Protocols: From Ethernet Frames to HTTP/3

### Complete Assessment Package with Answer Keys

---

## Overview

This comprehensive test bank contains quizzes, exams, and practice questions covering every protocol and concept in the "Demystifying Network Protocols" tutorial series. All questions include detailed answer keys with explanations.

**Purpose:** Assess understanding, reinforce learning, and prepare for certification exams.

**Question Types:**
- Multiple Choice
- True/False
- Fill in the Blank
- Matching
- Short Answer
- Essay Questions
- Practical Exercises

**Organization:** Questions are organized by part, with progressive difficulty levels.

---

## Part 1: Foundations & the Local Link

### Section 1.1: Multiple Choice Questions

**1. How many layers does the OSI model have?**
- A) 4
- B) 5
- C) 7
- D) 9

**Answer: C) 7**
*Explanation: The OSI model has seven layers: Physical, Data Link, Network, Transport, Session, Presentation, and Application.*

---

**2. What is the size of a MAC address in bits?**
- A) 32
- B) 48
- C) 64
- D) 128

**Answer: B) 48**
*Explanation: MAC addresses are 48 bits (6 bytes) long, typically represented as 12 hexadecimal digits.*

---

**3. Which protocol translates IP addresses to MAC addresses?**
- A) DHCP
- B) DNS
- C) ARP
- D) NAT

**Answer: C) ARP**
*Explanation: ARP (Address Resolution Protocol) resolves IP addresses to MAC addresses on a local network.*

---

**4. What is the destination MAC address for a broadcast frame?**
- A) 00:00:00:00:00:00
- B) FF:FF:FF:FF:FF:FF
- C) AA:AA:AA:AA:AA:AA
- D) 11:11:11:11:11:11

**Answer: B) FF:FF:FF:FF:FF:FF**
*Explanation: The broadcast MAC address is all Fs, which means the frame is sent to all devices on the network.*

---

**5. What does the DORA process represent in DHCP?**
- A) Discover, Offer, Request, Acknowledge
- B) Domain, Open, Route, Accept
- C) Data, Offer, Request, Accept
- D) Discover, Open, Route, Acknowledge

**Answer: A) Discover, Offer, Request, Acknowledge**
*Explanation: DORA is the four-step DHCP process: Discover (client finds servers), Offer (server offers IP), Request (client requests IP), Acknowledge (server confirms).*

---

**6. Which EtherType value indicates IPv4?**
- A) 0x0800
- B) 0x0806
- C) 0x86DD
- D) 0x8100

**Answer: A) 0x0800**
*Explanation: EtherType 0x0800 indicates IPv4. Other common values: 0x0806 (ARP), 0x86DD (IPv6), 0x8100 (VLAN).*

---

**7. What is the minimum Ethernet frame size?**
- A) 46 bytes
- B) 64 bytes
- C) 128 bytes
- D) 1518 bytes

**Answer: B) 64 bytes**
*Explanation: The minimum Ethernet frame size is 64 bytes (excluding preamble) to ensure proper collision detection.*

---

**8. What is a VLAN?**
- A) A physical segment of a network
- B) A logical partition of a switch
- C) A type of router
- D) A network protocol

**Answer: B) A logical partition of a switch**
*Explanation: VLANs (Virtual Local Area Networks) partition a physical switch into multiple logical switches.*

---

**9. Which DHCP message type is sent by the server to confirm an IP assignment?**
- A) DHCPDISCOVER
- B) DHCPOFFER
- C) DHCPREQUEST
- D) DHCPACK

**Answer: D) DHCPACK**
*Explanation: DHCPACK (Acknowledge) is sent by the server to confirm the IP assignment to the client.*

---

**10. What is the TTL value in a typical Linux system?**
- A) 32
- B) 64
- C) 128
- D) 255

**Answer: B) 64**
*Explanation: Most Linux systems use TTL 64. Windows typically uses 128, and Cisco devices often use 255.*

---

### Section 1.2: True/False Questions

**11. The OSI model is the framework the Internet actually uses.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: The TCP/IP model is what the Internet actually uses. The OSI model is a theoretical framework used for teaching and reference.*

---

**12. MAC addresses are permanent hardware addresses.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: MAC addresses are burned into the NIC during manufacturing and are generally permanent.*

---

**13. ARP requests are sent as unicast messages.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: ARP requests are sent as broadcast messages (FF:FF:FF:FF:FF:FF) so all devices on the network can respond.*

---

**14. DHCP uses a three-step process called DOR.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: DHCP uses a four-step process called DORA: Discover, Offer, Request, Acknowledge.*

---

**15. Switches forward broadcast frames to all ports.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: Switches forward broadcast frames to all ports except the one the frame was received on.*

---

### Section 1.3: Fill in the Blank

**16. The ________ model has 7 layers, while the ________ model has 4 layers.**

**Answer:** OSI, TCP/IP
*Explanation: The OSI model has 7 layers, and the TCP/IP model has 4 layers.*

---

**17. ARP stands for ________.**

**Answer:** Address Resolution Protocol
*Explanation: ARP resolves IP addresses to MAC addresses on a local network.*

---

**18. A MAC address is ________ bits long.**

**Answer:** 48
*Explanation: MAC addresses are 48 bits (6 bytes) long.*

---

**19. The destination MAC address for a broadcast frame is ________.**

**Answer:** FF:FF:FF:FF:FF:FF
*Explanation: The broadcast MAC address is all Fs.*

---

**20. The first 24 bits of a MAC address identify the ________.**

**Answer:** OUI (Organizationally Unique Identifier)
*Explanation: The OUI identifies the manufacturer of the network interface.*

---

### Section 1.4: Matching

**21. Match the protocol/term to its description:**

| Term | Description |
|------|-------------|
| 1. Ethernet | A. Assigns IP addresses automatically |
| 2. ARP | B. Translates IP to MAC addresses |
| 3. DHCP | C. Local network protocol using MAC addresses |
| 4. VLAN | D. Virtual segmentation of a network |
| 5. Switch | E. Forwards frames based on MAC addresses |

**Answers:**
1. Ethernet → C
2. ARP → B
3. DHCP → A
4. VLAN → D
5. Switch → E

*Explanation: Ethernet is the local network protocol using MAC addresses. ARP translates IP to MAC. DHCP assigns IP addresses. VLAN creates virtual network segments. Switches forward frames based on MAC addresses.*

---

### Section 1.5: Short Answer

**22. Explain the concept of encapsulation in networking.**

**Answer:**
Encapsulation is the process of wrapping data with protocol headers at each layer as it moves down the stack. At each layer, a header containing control information is added. For example, application data is wrapped with a TCP header (Transport Layer), then an IP header (Network Layer), then an Ethernet header (Data Link Layer). When data moves up the stack at the destination, each layer removes its header (decapsulation).

---

**23. Describe the ARP request/reply process.**

**Answer:**
1. A device needs to send data to another device on the same network
2. It checks its ARP cache for the MAC address
3. If not found, it sends an ARP request (broadcast): "Who has IP 192.168.1.20? Tell 192.168.1.10"
4. The target device responds with an ARP reply (unicast): "192.168.1.20 is at 00:11:22:33:44:55"
5. The sender updates its ARP cache with the mapping

---

**24. What is the purpose of the DORA process in DHCP?**

**Answer:**
1. DISCOVER: Client broadcasts to find DHCP servers
2. OFFER: Server offers an IP address to the client
3. REQUEST: Client requests the offered IP address
4. ACKNOWLEDGE: Server confirms the IP assignment

---

### Section 1.6: Essay Questions

**25. Compare and contrast hubs, switches, and routers. Explain their functions at different OSI layers.**

**Answer:**
Hubs (Layer 1):
- Simple repeaters that broadcast all traffic to all ports
- No intelligence, collisions common
- Obsolete in modern networks

Switches (Layer 2):
- Forward frames based on MAC addresses
- Learn which devices are on which ports
- Create separate collision domains
- Reduce broadcast domains (with VLANs)

Routers (Layer 3):
- Forward packets based on IP addresses
- Route between different networks
- Create separate broadcast domains
- Use routing tables and protocols

Key differences: Hubs are unintelligent, switches provide MAC-based forwarding, routers provide IP-based routing between networks.

---

## Part 2: The Network Layer & Diagnostics

### Section 2.1: Multiple Choice Questions

**26. How many bits are in an IPv4 address?**
- A) 32
- B) 48
- C) 64
- D) 128

**Answer: A) 32**
*Explanation: IPv4 addresses are 32 bits (4 bytes) long.*

---

**27. What is the range of a Class C private IP address?**
- A) 10.0.0.0 - 10.255.255.255
- B) 172.16.0.0 - 172.31.255.255
- C) 192.168.0.0 - 192.168.255.255
- D) 169.254.0.0 - 169.254.255.255

**Answer: C) 192.168.0.0 - 192.168.255.255**
*Explanation: The Class C private range is 192.168.0.0/16. Option A is Class A, B is Class B, D is APIPA.*

---

**28. What is the purpose of NAT?**
- A) Translate domain names to IPs
- B) Translate IPs to MACs
- C) Map private IPs to public IPs
- D) Encrypt network traffic

**Answer: C) Map private IPs to public IPs**
*Explanation: NAT maps private IP addresses to public IP addresses, allowing multiple devices to share a single public IP.*

---

**29. Which ICMP message type is used by ping?**
- A) Type 0 (Echo Reply)
- B) Type 3 (Destination Unreachable)
- C) Type 8 (Echo Request)
- D) Type 11 (Time Exceeded)

**Answer: C) Type 8 (Echo Request)**
*Explanation: Ping uses ICMP Echo Request (Type 8) and Echo Reply (Type 0).*

---

**30. What does CIDR stand for?**
- A) Classless Inter-Domain Routing
- B) Classful Internet Domain Routing
- C) Connectionless Internet Data Routing
- D) Classless Internet Domain Resolution

**Answer: A) Classless Inter-Domain Routing**
*Explanation: CIDR replaced classful addressing with variable-length subnet masks.*

---

**31. Which IPv6 address type is analogous to a private IP address?**
- A) Global Unicast
- B) Link-Local
- C) Unique Local
- D) Multicast

**Answer: C) Unique Local**
*Explanation: Unique Local Addresses (FC00::/7) are analogous to IPv4 private addresses (RFC 1918).*

---

**32. What is the default gateway?**
- A) The first device on a subnet
- B) A router that handles traffic outside the local network
- C) The DNS server
- D) The DHCP server

**Answer: B) A router that handles traffic outside the local network**
*Explanation: The default gateway routes packets to networks not in the local routing table.*

---

**33. Which protocol does traceroute primarily use?**
- A) TCP
- B) UDP
- C) ICMP
- D) ARP

**Answer: C) ICMP**
*Explanation: Traceroute uses ICMP (Type 11 - Time Exceeded) to map the path to a destination.*

---

**34. How many bits are in an IPv6 address?**
- A) 32
- B) 48
- C) 64
- D) 128

**Answer: D) 128**
*Explanation: IPv6 addresses are 128 bits (16 bytes) long.*

---

**35. What is the prefix for IPv6 link-local addresses?**
- A) 2000::/3
- B) fc00::/7
- C) fe80::/10
- D) ff00::/8

**Answer: C) fe80::/10**
*Explanation: IPv6 link-local addresses start with fe80::/10.*

---

### Section 2.2: True/False Questions

**36. IPv6 has a larger address space than IPv4.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: IPv6 has 128-bit addresses (3.4×10^38 addresses) compared to IPv4's 32-bit (4.3 billion addresses).*

---

**37. NAT eliminates the need for private IP addresses.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: NAT requires private IP addresses to map to public IPs. IPv6 eliminates the need for NAT.*

---

**38. Traceroute shows the physical path packets take.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: Traceroute shows the logical path (routers) packets take, not the physical path.*

---

**39. IPv6 includes built-in security features.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: IPv6 has IPsec built in, providing authentication and encryption.*

---

**40. ICMP is a transport protocol like TCP or UDP.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: ICMP is a control and diagnostic protocol, not a transport protocol.*

---

### Section 2.3: Fill in the Blank

**41. IPv4 addresses are ________ bits long.**

**Answer:** 32
*Explanation: IPv4 addresses are 32 bits (4 bytes) long.*

---

**42. NAT stands for ________.**

**Answer:** Network Address Translation
*Explanation: NAT maps private IPs to public IPs.*

---

**43. The TTL field prevents ________.**

**Answer:** routing loops / packets from looping forever
*Explanation: TTL (Time to Live) is decremented at each hop to prevent packets from circulating indefinitely.*

---

**44. IPv6 link-local addresses start with ________.**

**Answer:** fe80::/10
*Explanation: Link-local addresses are auto-configured for local network communication.*

---

**45. ________ is the diagnostic protocol of the IP suite.**

**Answer:** ICMP (Internet Control Message Protocol)
*Explanation: ICMP provides error reporting and diagnostics.*

---

### Section 2.4: Matching

**46. Match the term to its description:**

| Term | Description |
|------|-------------|
| 1. IPv4 | A. 128-bit address space |
| 2. IPv6 | B. 32-bit address space |
| 3. NAT | C. Network diagnostic protocol |
| 4. ICMP | D. Translates private to public IPs |
| 5. Subnet | E. Divides a network into smaller segments |

**Answers:**
1. IPv4 → B
2. IPv6 → A
3. NAT → D
4. ICMP → C
5. Subnet → E

*Explanation: IPv4 is 32-bit, IPv6 is 128-bit, NAT translates addresses, ICMP provides diagnostics, subnets divide networks.*

---

### Section 2.5: Short Answer

**47. Explain the difference between static and dynamic routing.**

**Answer:**
Static Routing:
- Manually configured by an administrator
- Does not adapt to network changes
- No overhead or complexity
- Suitable for small, stable networks

Dynamic Routing:
- Automatically discovers and updates routes
- Adapts to changes and failures
- Adds overhead and complexity
- Suitable for large, changing networks

Protocols: Static has no protocol; dynamic uses RIP, OSPF, BGP, etc.

---

**48. How does traceroute work?**

**Answer:**
1. Traceroute sends packets with incrementing TTL values
2. First packet: TTL=1 (first router decrements to 0, sends Time Exceeded)
3. Second packet: TTL=2 (second router sends Time Exceeded)
4. Continues until destination is reached
5. Destination sends Port Unreachable (ICMP Type 3, Code 3) to indicate end
6. The sequence of responses builds the path map

---

**49. What is subnetting and why is it used?**

**Answer:**
Subnetting divides a large network into smaller, more manageable pieces called subnets.

Benefits:
- Reduces broadcast domains
- Improves network performance
- Increases security (isolation)
- Efficient IP address utilization
- Simplifies network management

---

### Section 2.6: Essay Questions

**50. Compare and contrast IPv4 and IPv6.**

**Answer:**

| Aspect | IPv4 | IPv6 |
|--------|------|------|
| Address Size | 32 bits | 128 bits |
| Address Format | Dotted decimal | Hexadecimal |
| Address Count | ~4.3 billion | ~3.4×10^38 |
| NAT | Required | Not needed |
| Security | Optional (IPsec) | Built-in (IPsec) |
| Auto-configuration | DHCP | SLAAC, DHCPv6 |
| Header | Variable length | Fixed 40 bytes |
| Fragmentation | Done by routers | Done by hosts |
| Broadcast | Present | Not present |
| Transition | N/A | Various mechanisms |

IPv6 was developed to solve IPv4 address exhaustion and provides improved features, including built-in security and auto-configuration.

---

## Part 3: The Transport Layer

### Section 3.1: Multiple Choice Questions

**51. Which protocol is connection-oriented?**
- A) UDP
- B) TCP
- C) ICMP
- D) ARP

**Answer: B) TCP**
*Explanation: TCP is connection-oriented (requires a handshake), while UDP is connectionless.*

---

**52. How many bytes is the TCP header (minimum)?**
- A) 8
- B) 20
- C) 40
- D) 60

**Answer: B) 20**
*Explanation: The TCP header is at least 20 bytes, with options extending to 60 bytes.*

---

**53. What is the purpose of the sequence number in TCP?**
- A) Encrypt data
- B) Order data correctly
- C) Compress data
- D) Route packets

**Answer: B) Order data correctly**
*Explanation: Sequence numbers allow TCP to reassemble data in the correct order.*

---

**54. Which TCP flag initiates a connection?**
- A) ACK
- B) FIN
- C) SYN
- D) RST

**Answer: C) SYN**
*Explanation: SYN (Synchronize) initiates the three-way handshake.*

---

**55. What is the UDP header size?**
- A) 8 bytes
- B) 20 bytes
- C) 40 bytes
- D) 60 bytes

**Answer: A) 8 bytes**
*Explanation: UDP has a simple 8-byte header, contributing to its low overhead.*

---

**56. Which TCP state is entered after receiving a FIN?**
- A) FIN-WAIT-1
- B) FIN-WAIT-2
- C) CLOSE-WAIT
- D) LAST-ACK

**Answer: C) CLOSE-WAIT**
*Explanation: CLOSE-WAIT is entered when a device receives a FIN from the other side.*

---

**57. What is the purpose of the window size in TCP?**
- A) Route packets
- B) Flow control
- C) Encryption
- D) Error detection

**Answer: B) Flow control**
*Explanation: Window size indicates how much data the receiver can accept (flow control).*

---

**58. Which flag abruptly terminates a TCP connection?**
- A) FIN
- B) ACK
- C) RST
- D) PSH

**Answer: C) RST**
*Explanation: RST (Reset) aborts a connection abruptly, unlike FIN which does it gracefully.*

---

**59. What port does HTTPS use?**
- A) 80
- B) 443
- C) 8080
- D) 8443

**Answer: B) 443**
*Explanation: HTTPS uses port 443. HTTP uses port 80.*

---

**60. What is a socket?**
- A) A connection endpoint
- B) A network cable
- C) A router interface
- D) A switch port

**Answer: A) A connection endpoint**
*Explanation: A socket is an endpoint defined by IP address and port number.*

---

### Section 3.2: True/False Questions

**61. UDP is connection-oriented.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: UDP is connectionless, requiring no handshake.*

---

**62. TCP guarantees delivery of data.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: TCP provides reliable, ordered delivery with acknowledgments and retransmissions.*

---

**63. UDP is faster than TCP.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: UDP has lower overhead and no congestion control, making it faster.*

---

**64. TCP uses a three-way handshake.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: TCP uses SYN, SYN-ACK, ACK to establish a connection.*

---

**65. Port 22 is used for HTTP.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: Port 22 is used for SSH. Port 80 is used for HTTP.*

---

### Section 3.3: Fill in the Blank

**66. TCP uses a ________ to establish a connection.**

**Answer:** three-way handshake
*Explanation: The three-way handshake (SYN, SYN-ACK, ACK) establishes a TCP connection.*

---

**67. UDP provides ________ delivery.**

**Answer:** unreliable / best-effort
*Explanation: UDP does not guarantee delivery, ordering, or integrity.*

---

**68. The ACK flag indicates ________.**

**Answer:** acknowledgment / that the acknowledgment field is valid
*Explanation: ACK indicates that the acknowledgment number field contains valid data.*

---

**69. A ________ is the endpoint of a network connection.**

**Answer:** socket
*Explanation: A socket is defined by IP address and port number.*

---

**70. The TCP ________ field indicates the position of data in the stream.**

**Answer:** sequence number
*Explanation: Sequence numbers track byte positions for ordered delivery.*

---

### Section 3.4: Matching

**71. Match the term to its description:**

| Term | Description |
|------|-------------|
| 1. SYN | A. Acknowledgment |
| 2. ACK | B. Start connection |
| 3. FIN | C. Abort connection |
| 4. RST | D. Push data to application |
| 5. PSH | E. Close connection gracefully |

**Answers:**
1. SYN → B
2. ACK → A
3. FIN → E
4. RST → C
5. PSH → D

*Explanation: SYN starts the connection, ACK acknowledges, FIN closes gracefully, RST aborts, PSH pushes data.*

---

### Section 3.5: Short Answer

**72. Explain the TCP three-way handshake.**

**Answer:**
1. Client → Server: SYN (seq=x) - "I want to connect"
2. Server → Client: SYN-ACK (seq=y, ack=x+1) - "OK, I'm ready"
3. Client → Server: ACK (seq=x+1, ack=y+1) - "Great, let's go"

The handshake establishes sequence numbers and ensures both sides are ready before data transfer.

---

**73. Compare and contrast TCP and UDP.**

**Answer:**

| Feature | TCP | UDP |
|---------|-----|-----|
| Connection | Connection-oriented | Connectionless |
| Reliability | Reliable | Unreliable |
| Ordering | Ordered | Unordered |
| Flow Control | Yes | No |
| Congestion Control | Yes | No |
| Header Size | 20+ bytes | 8 bytes |
| Speed | Slower | Faster |
| Use Cases | Web, email, file transfer | Streaming, gaming, DNS |

---

**74. What is congestion control and why is it important?**

**Answer:**
Congestion control prevents network collapse by adjusting the transmission rate based on network conditions.

Key algorithms:
1. Slow Start: Exponential growth from 1 MSS
2. Congestion Avoidance: Linear growth after threshold
3. Fast Retransmit: Immediate retransmit on duplicate ACKs
4. Fast Recovery: Reduce window by half

Importance: Prevents packet loss, maintains network stability, ensures fair bandwidth distribution.

---

### Section 3.6: Essay Questions

**75. Describe the TCP state machine and explain the states involved in connection establishment and termination.**

**Answer:**

Connection Establishment States:
1. LISTEN: Server waiting for connection
2. SYN-SENT: Client sent SYN, waiting for SYN-ACK
3. SYN-RCVD: Server received SYN, sent SYN-ACK, waiting for ACK
4. ESTABLISHED: Connection fully open

Connection Termination States:
5. FIN-WAIT-1: Sent FIN, waiting for ACK
6. FIN-WAIT-2: Received ACK to FIN, waiting for FIN
7. CLOSE-WAIT: Received FIN, sent ACK
8. LAST-ACK: Sent FIN, waiting for ACK
9. TIME-WAIT: Waiting 2MSL before closing
10. CLOSED: Connection fully closed

The state machine ensures orderly connection establishment and termination, preventing data loss and improper connection handling.

---

## Part 4: The Application Layer

### Section 4.1: Multiple Choice Questions

**76. What is the primary purpose of DNS?**
- A) Assign IP addresses
- B) Translate domain names to IP addresses
- C) Route network traffic
- D) Encrypt communications

**Answer: B) Translate domain names to IP addresses**
*Explanation: DNS translates human-readable domain names to machine-readable IP addresses.*

---

**77. Which DNS record type maps a domain to an IPv6 address?**
- A) A
- B) AAAA
- C) CNAME
- D) MX

**Answer: B) AAAA**
*Explanation: AAAA records map domains to IPv6 addresses (A records map to IPv4).*

---

**78. What is the default port for HTTP?**
- A) 21
- B) 25
- C) 80
- D) 443

**Answer: C) 80**
*Explanation: HTTP uses port 80. HTTPS uses port 443.*

---

**79. Which HTTP status code indicates "Not Found"?**
- A) 200
- B) 301
- C) 404
- D) 500

**Answer: C) 404**
*Explanation: 404 indicates the requested resource was not found.*

---

**80. Which SMTP command starts the message data?**
- A) HELO
- B) MAIL FROM
- C) RCPT TO
- D) DATA

**Answer: D) DATA**
*Explanation: DATA starts the message body, ending with a dot on a line by itself.*

---

**81. Which email protocol downloads and deletes email from the server?**
- A) SMTP
- B) POP3
- C) IMAP
- D) HTTP

**Answer: B) POP3**
*Explanation: POP3 downloads email to the local client and typically deletes it from the server.*

---

**82. What is a MIB in SNMP?**
- A) Management Information Base
- B) Main Interface Bridge
- C) Managed Internet Block
- D) Message Information Buffer

**Answer: A) Management Information Base**
*Explanation: MIB is a database of managed objects used by SNMP.*

---

**83. Which HTTP method is considered safe?**
- A) POST
- B) PUT
- C) GET
- D) DELETE

**Answer: C) GET**
*Explanation: GET is safe because it doesn't modify server state.*

---

**84. What is the purpose of the MX record in DNS?**
- A) Name server
- B) Mail exchange server
- C) IPv4 address
- D) Alias name

**Answer: B) Mail exchange server**
*Explanation: MX records specify the mail server for a domain.*

---

**85. Which HTTP status code indicates a permanent redirect?**
- A) 200
- B) 301
- C) 302
- D) 304

**Answer: B) 301**
*Explanation: 301 indicates Moved Permanently. 302 indicates temporary redirect.*

---

### Section 4.2: True/False Questions

**86. DNS is a hierarchical distributed database.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: DNS is organized hierarchically from root servers to TLD servers to authoritative servers.*

---

**87. A 404 status code means "OK".**
- [ ] True
- [x] False

**Answer: False**
*Explanation: 404 means "Not Found". 200 means "OK".*

---

**88. GET is an idempotent method.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: Multiple identical GET requests have the same effect as one request.*

---

**89. SMTP is used to receive email.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: SMTP is used to send email. POP3 and IMAP are used to receive email.*

---

**90. HTTP/2 supports multiplexing.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: HTTP/2 allows multiple requests over a single connection through multiplexing.*

---

### Section 4.3: Fill in the Blank

**91. DNS translates ________ to ________.**

**Answer:** domain names, IP addresses
*Explanation: DNS resolves human-readable names to machine-readable IPs.*

---

**92. HTTP stands for ________.**

**Answer:** Hypertext Transfer Protocol
*Explanation: HTTP is the foundation of the World Wide Web.*

---

**93. SMTP uses port ________ for sending email.**

**Answer:** 25
*Explanation: SMTP uses port 25 (unencrypted). Port 587 is used for submission with TLS.*

---

**94. IMAP stores email on the ________.**

**Answer:** server
*Explanation: IMAP keeps email on the server for access from multiple devices.*

---

**95. A DNS ________ record maps a domain to an IPv4 address.**

**Answer:** A
*Explanation: A records map domains to IPv4 addresses.*

---

### Section 4.4: Matching

**96. Match the DNS record to its purpose:**

| Record | Purpose |
|--------|---------|
| 1. A | A. IPv6 address |
| 2. AAAA | B. Alias name |
| 3. CNAME | C. IPv4 address |
| 4. MX | D. Name server |
| 5. NS | E. Mail server |

**Answers:**
1. A → C
2. AAAA → A
3. CNAME → B
4. MX → E
5. NS → D

*Explanation: A maps to IPv4, AAAA to IPv6, CNAME is alias, MX is mail server, NS is name server.*

---

### Section 4.5: Short Answer

**97. Describe the HTTP request/response cycle.**

**Answer:**
1. Client establishes TCP connection
2. Client sends HTTP request:
   - Request line: Method, path, version
   - Headers: Host, User-Agent, Accept, etc.
   - Body (optional): POST data
3. Server processes request
4. Server sends HTTP response:
   - Status line: Version, status code, reason
   - Headers: Content-Type, Content-Length, etc.
   - Body: HTML, JSON, etc.
5. Client receives and processes response

---

**98. Compare POP3 and IMAP.**

**Answer:**

| Feature | POP3 | IMAP |
|---------|------|------|
| Storage | Local | Server |
| Folders | Not supported | Supported |
| Multi-device | Limited | Full sync |
| Server search | Not supported | Supported |
| Bandwidth | Full messages | Partial possible |
| Access | Single device | Multiple devices |

POP3 is suited for single-device offline use; IMAP is suited for multi-device online use.

---

**99. What is SNMP and how does it work?**

**Answer:**
SNMP (Simple Network Management Protocol) monitors and manages network devices.

Components:
- Manager: Central monitoring system
- Agent: Software on managed devices
- MIB: Database of managed objects
- OID: Unique identifier for each data point

Operations:
- GET: Retrieve a value
- GETNEXT: Retrieve the next OID
- GETBULK: Retrieve many OIDs
- SET: Change a value
- TRAP: Unsolicited event notification

---

## Part 5: Modern Web Security & Packet Analysis

### Section 5.1: Multiple Choice Questions

**100. Which encryption type uses one key for both encryption and decryption?**
- A) Asymmetric
- B) Symmetric
- C) Hashing
- D) Digital signature

**Answer: B) Symmetric**
*Explanation: Symmetric encryption uses the same key for both operations (AES, ChaCha20).*

---

**101. What does TLS stand for?**
- A) Transport Layer Security
- B) Transmission Layer System
- C) Technical Link Standard
- D) Trusted Layer Service

**Answer: A) Transport Layer Security**
*Explanation: TLS is the successor to SSL, providing secure communication.*

---

**102. How many RTT does TLS 1.3 handshake require?**
- A) 0 RTT
- B) 1 RTT
- C) 2 RTT
- D) 3 RTT

**Answer: B) 1 RTT**
*Explanation: TLS 1.3 handshake requires 1 RTT (down from 2 RTT in TLS 1.2).*

---

**103. What is Perfect Forward Secrecy?**
- A) Always valid certificates
- B) Past sessions remain secure if keys are compromised
- C) Future sessions remain secure
- D) All sessions are encrypted

**Answer: B) Past sessions remain secure if keys are compromised**
*Explanation: PFS ensures that compromising long-term keys doesn't reveal past session keys.*

---

**104. Which protocol does HTTP/3 use for transport?**
- A) TCP
- B) UDP
- C) SCTP
- D) DCCP

**Answer: B) UDP**
*Explanation: HTTP/3 uses QUIC, which runs over UDP.*

---

**105. What is the primary benefit of QUIC streams?**
- A) Lower latency
- B) No head-of-line blocking
- C) Higher throughput
- D) All of the above

**Answer: D) All of the above**
*Explanation: QUIC provides lower latency, no head-of-line blocking, and higher throughput.*

---

**106. Which Wireshark filter shows HTTP requests?**
- A) http
- B) http.request
- C) http.response
- D) http.content

**Answer: B) http.request**
*Explanation: `http.request` filters for HTTP request messages.*

---

**107. What is the purpose of ALPN in TLS?**
- A) Negotiate application protocols
- B) Authenticate servers
- C) Encrypt data
- D) Compress headers

**Answer: A) Negotiate application protocols**
*Explanation: ALPN (Application-Layer Protocol Negotiation) negotiates protocols like HTTP/2 or HTTP/3.*

---

**108. Which of the following is a TLS 1.3 cipher suite?**
- A) TLS_RSA_WITH_AES_256_CBC_SHA
- B) TLS_AES_256_GCM_SHA384
- C) TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
- D) TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA

**Answer: B) TLS_AES_256_GCM_SHA384**
*Explanation: TLS 1.3 cipher suites have the format TLS_AES_*.* Options A, C, and D are TLS 1.2.*

---

**109. What does QUIC stand for?**
- A) Quick UDP Internet Connections
- B) Quality Universal Internet Control
- C) Quantum Unified Internet Connections
- D) Quick Unified Internet Control

**Answer: A) Quick UDP Internet Connections**
*Explanation: QUIC is a UDP-based transport protocol developed by Google.*

---

**110. Which of the following is NOT a QUIC frame type?**
- A) STREAM
- B) ACK
- C) SYN
- D) CRYPTO

**Answer: C) SYN**
*Explanation: SYN is a TCP flag. QUIC frame types include STREAM, ACK, CRYPTO, and others.*

---

### Section 5.2: True/False Questions

**111. AES is a symmetric encryption algorithm.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: AES (Advanced Encryption Standard) is a symmetric encryption algorithm.*

---

**112. RSA is a symmetric encryption algorithm.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: RSA is an asymmetric (public-key) encryption algorithm.*

---

**113. TLS 1.3 has perfect forward secrecy by default.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: TLS 1.3 requires Perfect Forward Secrecy for all cipher suites.*

---

**114. HTTP/3 uses TCP for transport.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: HTTP/3 uses QUIC over UDP, not TCP.*

---

**115. QUIC uses UDP for transport.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: QUIC runs on top of UDP (port 443).*

---

### Section 5.3: Fill in the Blank

**116. TLS stands for ________.**

**Answer:** Transport Layer Security
*Explanation: TLS secures communications over a network.*

---

**117. HTTP/3 uses ________ instead of TCP.**

**Answer:** QUIC / UDP
*Explanation: HTTP/3 runs on QUIC, which is built on UDP.*

---

**118. ________ ensures past sessions remain secure even if keys are compromised.**

**Answer:** Perfect Forward Secrecy (PFS)
*Explanation: PFS protects past sessions from future key compromise.*

---

**119. The TLS handshake type for ClientHello is ________.**

**Answer:** 1
*Explanation: ClientHello is handshake type 1 in TLS.*

---

**120. Wireshark can decrypt TLS traffic with ________ files.**

**Answer:** keylog / key log
*Explanation: TLS session keys can be logged for decryption in Wireshark.*

---

### Section 5.4: Matching

**121. Match the term to its description:**

| Term | Description |
|------|-------------|
| 1. TLS | A. Modern transport protocol over UDP |
| 2. QUIC | B. Secure web protocol |
| 3. PFS | C. Past sessions remain secure |
| 4. CA | D. Issues certificates |
| 5. OCSP | E. Certificate revocation check |

**Answers:**
1. TLS → B
2. QUIC → A
3. PFS → C
4. CA → D
5. OCSP → E

*Explanation: TLS secures communications, QUIC is modern transport, PFS protects past sessions, CA issues certificates, OCSP checks revocation.*

---

### Section 5.5: Short Answer

**122. Explain the TLS 1.3 handshake process.**

**Answer:**
1. ClientHello: Client sends supported cipher suites, key share (ECDHE), and ALPN
2. ServerHello: Server selects cipher suite, provides key share
3. EncryptedExtensions: Server sends certificate and other parameters
4. Client finishes: Client verifies certificate, computes shared secret, sends Finished
5. Server finishes: Server verifies Finished, sends Application Data

TLS 1.3 handshake takes 1 RTT (2 RTT in TLS 1.2) and provides Perfect Forward Secrecy.

---

**123. How does QUIC eliminate head-of-line blocking?**

**Answer:**
Head-of-line blocking occurs in TCP when one lost packet blocks all subsequent packets on a connection.

QUIC eliminates it by:
1. Multiple independent streams per connection
2. Each stream has its own sequence numbers
3. Lost packets in one stream don't affect others
4. Each stream has independent flow control
5. Multiplexing allows parallel processing

This results in better performance, especially when packet loss occurs.

---

**124. What is the difference between symmetric and asymmetric encryption?**

**Answer:**
Symmetric Encryption:
- Same key for encryption and decryption
- Fast and efficient
- Key distribution problem
- Examples: AES, ChaCha20

Asymmetric Encryption:
- Key pair (public and private)
- Slower but more secure
- No key distribution problem
- Examples: RSA, ECC

Hybrid systems (like TLS) use asymmetric for key exchange and symmetric for bulk encryption.

---

### Section 5.6: Essay Questions

**125. Compare and contrast TCP-based protocols (HTTP/2) with UDP-based protocols (HTTP/3/QUIC).**

**Answer:**

TCP (HTTP/2):
- Requires three-way handshake (2-3 RTT)
- Head-of-line blocking present
- Connection migration not supported
- Fixed congestion control
- Stateful: network changes break connection

UDP (HTTP/3/QUIC):
- 0-1 RTT handshake (with TLS)
- No head-of-line blocking (independent streams)
- Connection migration supported
- Pluggable congestion control
- Connection ID persists through network changes

Performance benefits:
- Reduced latency
- Better loss recovery
- Seamless network transitions
- Mobile-friendly

Trade-offs:
- TCP has more mature implementations
- UDP requires application-layer reliability
- QUIC is newer with limited adoption

---

## Comprehensive Final Exam

### Section F1: Multiple Choice (50 Questions)

**126. Which OSI layer is responsible for routing packets?**
- A) Application
- B) Transport
- C) Network
- D) Data Link

**Answer: C) Network**
*Explanation: The Network Layer (Layer 3) handles routing and addressing.*

---

**127. What is the default port for SSH?**
- A) 21
- B) 22
- C) 23
- D) 25

**Answer: B) 22**
*Explanation: SSH uses port 22. Telnet uses 23.*

---

**128. Which protocol is used to automatically assign IP addresses?**
- A) DNS
- B) ARP
- C) DHCP
- D) NAT

**Answer: C) DHCP**
*Explanation: DHCP automatically assigns IP addresses to devices on a network.*

---

**129. What is the purpose of ARP?**
- A) Translate IP to MAC
- B) Translate MAC to IP
- C) Assign IP addresses
- D) Route packets

**Answer: A) Translate IP to MAC**
*Explanation: ARP resolves IP addresses to MAC addresses.*

---

**130. Which IPv6 address is analogous to localhost?**
- A) 2001:db8::1
- B) ::1
- C) fe80::1
- D) ff00::1

**Answer: B) ::1**
*Explanation: ::1 is the IPv6 loopback address.*

---

### Section F2: True/False (20 Questions)

**131. UDP is reliable.**
- [ ] True
- [x] False

**Answer: False**
*Explanation: UDP is unreliable; it does not guarantee delivery.*

---

**132. HTTP uses port 80.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: HTTP uses port 80 by default.*

---

**133. IPv6 has more addresses than IPv4.**
- [x] True
- [ ] False

**Answer: True**
*Explanation: IPv6 has 128-bit addresses (3.4×10^38) vs IPv4's 32-bit (4.3 billion).*

---

### Section F3: Fill in the Blank (20 Questions)

**134. TCP uses a ________ to establish a connection.**

**Answer:** three-way handshake
*Explanation: The three-way handshake (SYN, SYN-ACK, ACK) establishes TCP connections.*

---

**135. The ________ flag is used to reset a TCP connection.**

**Answer:** RST
*Explanation: RST (Reset) abruptly terminates a connection.*

---

### Section F4: Short Answer (10 Questions)

**136. Explain the difference between a router and a switch.**

**Answer:**
Router (Layer 3):
- Forwards packets based on IP addresses
- Routes between different networks
- Provides NAT, firewall, and other services
- Creates separate broadcast domains

Switch (Layer 2):
- Forwards frames based on MAC addresses
- Works within a single network
- Provides high-speed connectivity
- Learning MAC table

Key difference: Routers connect different networks, switches connect devices within a network.

---

**137. Describe the four layers of the TCP/IP model.**

**Answer:**
1. Application Layer: User-facing protocols (HTTP, DNS, SMTP)
2. Transport Layer: End-to-end delivery (TCP, UDP)
3. Internet Layer: Addressing and routing (IP, ICMP)
4. Network Access Layer: Physical transmission (Ethernet, Wi-Fi)

---

### Section F5: Essay Questions (5 Questions)

**138. Explain the complete journey of a packet from your browser to a web server and back.**

**Answer:**
1. Browser generates HTTP request for www.example.com
2. DNS resolves domain to IP address
3. TCP three-way handshake establishes connection
4. TLS handshake secures connection (if HTTPS)
5. HTTP request sent over TCP/TLS
6. Packet moves through protocol stack:
   - Application: HTTP request
   - Transport: TCP segment with ports
   - Network: IP packet with addresses
   - Link: Ethernet frame with MACs
7. Routers forward packet to destination
8. Server processes request
9. Response follows reverse path
10. Browser renders content

---

## Answer Keys Summary

### Part 1: Foundations
- Multiple Choice: 1-C, 2-B, 3-C, 4-B, 5-A, 6-A, 7-B, 8-B, 9-D, 10-B
- True/False: 11-F, 12-T, 13-F, 14-F, 15-T
- Fill in the Blank: 16-OSI/TCP/IP, 17-Address Resolution Protocol, 18-48, 19-FF:FF:FF:FF:FF:FF, 20-OUI

### Part 2: Network Layer
- Multiple Choice: 26-A, 27-C, 28-C, 29-C, 30-A, 31-C, 32-B, 33-C, 34-D, 35-C
- True/False: 36-T, 37-F, 38-F, 39-T, 40-F
- Fill in the Blank: 41-32, 42-Network Address Translation, 43-routing loops, 44-fe80::/10, 45-ICMP

### Part 3: Transport Layer
- Multiple Choice: 51-B, 52-B, 53-B, 54-C, 55-A, 56-C, 57-B, 58-C, 59-B, 60-A
- True/False: 61-F, 62-T, 63-T, 64-T, 65-F
- Fill in the Blank: 66-three-way handshake, 67-unreliable/best-effort, 68-acknowledgment, 69-socket, 70-sequence number

### Part 4: Application Layer
- Multiple Choice: 76-B, 77-B, 78-C, 79-C, 80-D, 81-B, 82-A, 83-C, 84-B, 85-B
- True/False: 86-T, 87-F, 88-T, 89-F, 90-T
- Fill in the Blank: 91-domain names/IP addresses, 92-Hypertext Transfer Protocol, 93-25, 94-server, 95-A

### Part 5: Security and Analysis
- Multiple Choice: 100-B, 101-A, 102-B, 103-B, 104-B, 105-D, 106-B, 107-A, 108-B, 109-A, 110-C
- True/False: 111-T, 112-F, 113-T, 114-F, 115-T
- Fill in the Blank: 116-Transport Layer Security, 117-QUIC/UDP, 118-Perfect Forward Secrecy, 119-1, 120-keylog

---

**END OF QUIZ AND TEST BANK**
