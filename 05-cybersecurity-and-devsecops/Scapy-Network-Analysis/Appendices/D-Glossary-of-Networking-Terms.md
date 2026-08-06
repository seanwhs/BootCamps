# Mastering Network Packet Crafting with Scapy
## Appendix D: Glossary of Networking Terms

## Overview

This appendix provides a comprehensive glossary of networking terms used throughout the series. Each term includes a clear definition, context, and where applicable, examples or references to the series.

---

## Table of Contents

1. [Network Fundamentals](#network-fundamentals)
2. [Protocol Layers](#protocol-layers)
3. [Ethernet and Layer 2](#ethernet-and-layer-2)
4. [IP and Layer 3](#ip-and-layer-3)
5. [Transport Layer](#transport-layer)
6. [Application Layer](#application-layer)
7. [Network Security](#network-security)
8. [Scapy-Specific Terms](#scapy-specific-terms)
9. [Tools and Utilities](#tools-and-utilities)

---

## Network Fundamentals

### Bandwidth
**Definition:** The maximum rate of data transfer across a network path, typically measured in bits per second (bps). Higher bandwidth means more data can flow per second.

**Context:** Bandwidth affects network performance, packet rates, and the feasibility of certain attacks or monitoring scenarios.

**Example:** A 1 Gbps Ethernet connection can theoretically transfer 1,000,000,000 bits per second.

---

### Broadcast
**Definition:** A network communication method where a packet is sent to all devices on a network segment. Broadcast packets use a special destination address (FF:FF:FF:FF:FF:FF at Layer 2, or a broadcast IP at Layer 3).

**Context:** Used by protocols like ARP and DHCP to discover devices on the local network.

**Example:** ARP requests are broadcast to find the MAC address associated with an IP.

**Related Terms:** Multicast, Unicast, Anycast

---

### CIDR (Classless Inter-Domain Routing)
**Definition:** A method for allocating IP addresses and routing IP packets. CIDR notation uses a slash followed by the number of bits in the network prefix (e.g., 192.168.1.0/24).

**Context:** Used throughout the series for network scanning and subnet definition.

**Example:** 192.168.1.0/24 represents all IPs from 192.168.1.0 to 192.168.1.255.

**Key CIDR Ranges:**
- /24: 256 addresses (255.255.255.0)
- /16: 65,536 addresses (255.255.0.0)
- /8: 16,777,216 addresses (255.0.0.0)

---

### Checksum
**Definition:** A value calculated from packet data used to detect errors during transmission. If the calculated checksum doesn't match the received checksum, the packet is assumed corrupted.

**Context:** Used in IP, TCP, UDP, and ICMP headers. Scapy automatically calculates checksums when sending packets.

**Example:** TCP checksum covers the TCP header, data, and a pseudo-header with IP addresses.

---

### Client-Server Model
**Definition:** A network architecture where client devices request services and resources from central servers. Clients initiate communications, servers respond to requests.

**Context:** Fundamental to understanding TCP, UDP, HTTP, DNS, DHCP, and many other protocols.

**Example:** Web browser (client) requests a webpage from a web server. DNS client queries a DNS server.

---

### DORA (DHCP Process)
**Definition:** The sequence of DHCP messages: **D**iscover, **O**ffer, **R**equest, **A**cknowledge.

**Context:** Used by DHCP to assign IP addresses to clients.

**Example:**
1. Client broadcasts DISCOVER
2. Server responds with OFFER
3. Client sends REQUEST
4. Server sends ACKNOWLEDGE

---

### Duplex
**Definition:** Communication mode specifying whether data can flow in one direction (simplex), both directions but not simultaneously (half-duplex), or both directions simultaneously (full-duplex).

**Context:** Network interface cards and switches operate in full-duplex mode for optimal performance.

**Example:** Modern Ethernet is typically full-duplex, allowing simultaneous send and receive.

---

### Encapsulation
**Definition:** The process of wrapping data with protocol headers at each layer of the network stack. Each layer adds its own header, creating a nested packet structure.

**Context:** Fundamental to understanding packet construction. Scapy's `/` operator builds packets through encapsulation.

**Example:** HTTP data is encapsulated in TCP, which is encapsulated in IP, which is encapsulated in Ethernet.

```
Ethernet | IP | TCP | HTTP Data
    Layer 2  Layer 3  Layer 4  Application
```

---

### Flow
**Definition:** A sequence of packets between a specific source and destination, typically identified by the 5-tuple: (source IP, destination IP, source port, destination port, protocol).

**Context:** Flow tracking is essential for understanding conversations, analyzing traffic patterns, and detecting anomalies.

**Example:** A TCP flow from 192.168.1.100:54321 to 8.8.8.8:80 represents an HTTP connection.

---

### Latency
**Definition:** The time delay between sending a packet and receiving a response. Often measured in milliseconds (ms).

**Context:** Critical for understanding network performance, identifying bottlenecks, and analyzing response times.

**Example:** Ping round-trip time (RTT) measures latency.

---

### MTU (Maximum Transmission Unit)
**Definition:** The largest packet size that can be transmitted without fragmentation on a network link. Standard Ethernet MTU is 1500 bytes.

**Context:** Affects packet size, fragmentation, and network efficiency.

**Example:** Sending a packet larger than the MTU requires fragmentation (or is dropped if the DF flag is set).

---

### Multicast
**Definition:** Network communication where packets are sent to a group of devices that have joined a multicast group. Uses special IP addresses (224.0.0.0/4 for IPv4) and MAC addresses.

**Context:** Used by protocols like IGMP, streaming media, and network discovery.

**Example:** 224.0.0.1 is the multicast address for all hosts on a subnet.

**Related Terms:** Broadcast, Unicast, Anycast

---

### Payload
**Definition:** The actual data being carried by a packet, excluding protocol headers. The payload is what the packet is delivering to the destination.

**Context:** Every layer has its own payload. For example, IP's payload is the transport layer segment, TCP's payload is the application data.

**Example:** In an HTTP packet, the payload is the HTTP request/response data.

---

### Port
**Definition:** A 16-bit number (0-65535) used to identify specific applications or services at the transport layer (TCP or UDP). Well-known ports (0-1023) are assigned to common services.

**Context:** Essential for TCP and UDP communication. Ports allow multiple applications on the same host to communicate simultaneously.

**Common Ports:**
- 80: HTTP
- 443: HTTPS
- 22: SSH
- 53: DNS
- 25: SMTP

---

### Protocol
**Definition:** A set of rules and conventions for communication between network devices. Protocols define format, order of messages, and actions to take on errors.

**Context:** The foundation of all network communication. Scapy allows crafting packets for any protocol.

**Example:** TCP, UDP, IP, HTTP, DNS, and ARP are all protocols.

---

### Router
**Definition:** A network device that forwards packets between different networks based on IP addresses. Routers maintain routing tables to determine the best path.

**Context:** Essential for communication between different networks. Traceroute tracks the path packets take through routers.

**Example:** A home router connects a local network (192.168.1.0/24) to the internet.

---

### Routing
**Definition:** The process of selecting paths in a network along which to send network traffic. Routing determines how packets reach their destination.

**Context:** Understanding routing helps in tracing packet paths, diagnosing issues, and analyzing network topology.

**Example:** Traceroute reveals the routing path by incrementing TTL values.

---

### Socket
**Definition:** A programming abstraction for network communication, identified by an IP address and port number combination (e.g., 192.168.1.100:80).

**Context:** Used in TCP and UDP communication. Scapy bypasses sockets to work directly with packets.

**Example:** A web server listens on socket 0.0.0.0:80 (all interfaces, port 80).

---

### Subnet
**Definition:** A logical subdivision of an IP network. Devices on the same subnet can communicate directly without routing.

**Context:** Essential for IP addressing, scanning, and network design.

**Example:** 192.168.1.0/24 is a subnet with 256 addresses (192.168.1.0 to 192.168.1.255).

---

### Switch
**Definition:** A network device that forwards packets within the same network based on MAC addresses. Switches operate at Layer 2 (Ethernet) and learn which MAC addresses are on which ports.

**Context:** Fundamental to local network communication. ARP is used to find MAC addresses for communication within a switch.

**Example:** A network switch connects multiple devices in an office network.

---

### TTL (Time To Live)
**Definition:** An 8-bit field in the IP header that limits a packet's lifetime. Each router decrements TTL by 1. When TTL reaches 0, the packet is discarded and an ICMP Time Exceeded message is sent.

**Context:** Prevents packets from looping forever. Traceroute uses TTL to discover the route to a destination.

**Example:** A packet with TTL=1 will only reach the first router.

---

### Unicast
**Definition:** Network communication where packets are sent to a single specific destination. Most network traffic is unicast.

**Context:** The default communication mode for TCP and most UDP traffic.

**Example:** A web request from a client to a web server is unicast.

**Related Terms:** Broadcast, Multicast, Anycast

---

## Protocol Layers

### Application Layer (Layer 7)
**Definition:** The top layer of the OSI model where applications communicate. It provides services to user applications and defines how programs interact with the network.

**Context:** HTTP, DNS, DHCP, FTP, SMTP, and other application protocols operate at this layer.

**Example:** A web browser uses HTTP at the application layer to request web pages.

---

### Data Link Layer (Layer 2)
**Definition:** The layer that provides node-to-node data transfer within a network segment. It handles framing, addressing (MAC addresses), and error detection.

**Context:** Ethernet and ARP operate at this layer. Scapy's `Ether()` constructs Layer 2 frames.

**Example:** An Ethernet frame contains source/destination MAC addresses and the payload (which could be IP).

---

### Network Layer (Layer 3)
**Definition:** The layer responsible for routing and addressing packets across multiple networks. It provides logical addressing (IP addresses) and determines the best path for data.

**Context:** IP and ICMP operate at this layer. Scapy's `IP()` constructs Layer 3 packets.

**Example:** An IP packet contains source/destination IP addresses and transports TCP or UDP segments.

---

### Physical Layer (Layer 1)
**Definition:** The lowest layer of the OSI model, dealing with the physical transmission of raw bit streams over a physical medium (cables, wireless, etc.).

**Context:** Generally not manipulated directly in packet crafting, but affects performance and limitations.

**Example:** Ethernet cables, Wi-Fi signals, and fiber optics operate at this layer.

---

### Presentation Layer (Layer 6)
**Definition:** The layer that handles data representation, encryption, and compression. It ensures that data is presented in a format the application can understand.

**Context:** TLS/SSL encryption is often associated with this layer, though it's usually considered part of the application layer in TCP/IP.

**Example:** SSL/TLS encryption of HTTP traffic (HTTPS).

---

### Session Layer (Layer 5)
**Definition:** The layer that manages sessions or connections between applications. It establishes, maintains, and terminates connections.

**Context:** TCP's connection management is often associated with this layer, though TCP is considered a transport layer protocol.

**Example:** A TCP session between a client and server.

---

### Transport Layer (Layer 4)
**Definition:** The layer responsible for end-to-end communication between applications. It provides services like connection-oriented communication (TCP) and connectionless communication (UDP).

**Context:** TCP and UDP operate at this layer. Scapy's `TCP()` and `UDP()` construct Layer 4 segments.

**Example:** TCP provides reliable, ordered delivery; UDP provides fast, unreliable delivery.

---

## Ethernet and Layer 2

### ARP (Address Resolution Protocol)
**Definition:** A protocol used to map IP addresses to MAC addresses on a local network. ARP requests are broadcast, and replies are unicast.

**Context:** Essential for local network communication. Module 2 covers ARP operations and scanning.

**Example:** "Who has 192.168.1.1? Tell 00:11:22:33:44:55" (ARP Request)

**Related Terms:** ARP Cache, ARP Spoofing, Gratuitous ARP

---

### EtherType
**Definition:** A 16-bit field in an Ethernet frame that identifies the protocol of the payload. Common EtherType values indicate IPv4 (0x0800), ARP (0x0806), and VLAN (0x8100).

**Context:** Used by network devices to determine how to process the frame.

**Example:** EtherType 0x0800 means the payload is an IPv4 packet.

---

### MAC Address (Media Access Control Address)
**Definition:** A unique 48-bit (6-byte) hardware address assigned to a network interface. MAC addresses are used for communication within a local network segment.

**Context:** Fundamental to Ethernet communication. ARP maps IP addresses to MAC addresses.

**Format:** Six groups of two hexadecimal digits, separated by colons (e.g., 00:11:22:33:44:55).

**Types:**
- Unicast: Unique to one device (first octet LSB = 0)
- Multicast: Group of devices (first octet LSB = 1)
- Broadcast: All devices (FF:FF:FF:FF:FF:FF)

---

### VLAN (Virtual Local Area Network)
**Definition:** A logical grouping of devices on a network that behave as if they are on the same physical network. VLANs are implemented using 802.1Q tagging.

**Context:** Used to segment networks, improve security, and manage broadcast domains. Module 2 covers VLAN operations.

**Example:** VLAN ID 100 represents a specific logical network.

**Related Terms:** 802.1Q, Q-in-Q, VLAN Tagging

---

### VLAN Tagging (802.1Q)
**Definition:** A method of inserting a VLAN identifier into an Ethernet frame. The tag is inserted after the source MAC address and before the EtherType field.

**Context:** Allows multiple VLANs to share the same physical network.

**Example:** A VLAN tag with VID 100 identifies the frame as belonging to VLAN 100.

---

## IP and Layer 3

### Anycast
**Definition:** A network addressing and routing method where the same IP address is assigned to multiple devices (usually in different locations). Traffic is routed to the nearest or best-performing device.

**Context:** Used for DNS, CDN, and load balancing.

**Example:** 1.1.1.1 (Cloudflare DNS) is an anycast address.

**Related Terms:** Unicast, Multicast, Broadcast

---

### DF Flag (Don't Fragment Flag)
**Definition:** A bit in the IP header flags field that instructs routers not to fragment the packet. If the packet is too large for the next link, it's dropped and an ICMP Fragmentation Needed message is sent.

**Context:** Used for Path MTU Discovery and preventing fragmentation overhead.

**Example:** Setting DF=1 prevents fragmentation.

---

### DHCP (Dynamic Host Configuration Protocol)
**Definition:** A protocol used to automatically assign IP addresses and network configuration parameters to devices on a network.

**Context:** Essential for automated network configuration. Module 4 covers DHCP analysis.

**Example:** A device requests an IP address using DORA sequence.

**Related Terms:** DORA, DHCP Server, DHCP Client

---

### DNS (Domain Name System)
**Definition:** A hierarchical distributed naming system that translates domain names (example.com) to IP addresses.

**Context:** Critical for internet functionality. Module 4 covers DNS analysis and monitoring.

**Example:** example.com resolves to 93.184.216.34.

**Related Terms:** DNS Query, DNS Response, DNS Server, DNS Cache

---

### Fragmentation
**Definition:** The process of breaking a large IP packet into smaller pieces for transmission over a network with a smaller MTU. Fragments are reassembled at the destination.

**Context:** Handled by Scapy's `fragment()` method. Important for understanding MTU limitations.

**Example:** A 2000-byte packet is fragmented into two 1500-byte fragments.

---

### ICMP (Internet Control Message Protocol)
**Definition:** A protocol used for error reporting and diagnostic functions in IP networks. Common ICMP types include Echo Request/Reply (ping) and Time Exceeded (traceroute).

**Context:** Essential for network diagnostics. Module 2 covers ICMP operations.

**Common ICMP Types:**
- 0: Echo Reply
- 3: Destination Unreachable
- 8: Echo Request
- 11: Time Exceeded

---

### IP (Internet Protocol)
**Definition:** The network layer protocol that provides addressing and routing for packets across networks. IPv4 uses 32-bit addresses; IPv6 uses 128-bit addresses.

**Context:** Core protocol for internet communication. Module 2 covers IP operations.

**Example:** IPv4 address: 192.168.1.100

**Related Terms:** IPv4, IPv6, IP Addressing, IP Header

---

### IPv4 (Internet Protocol version 4)
**Definition:** The fourth version of the Internet Protocol, using 32-bit addresses (e.g., 192.168.1.100). IPv4 is still the dominant protocol but is being replaced by IPv6 due to address exhaustion.

**Context:** The primary protocol used throughout the series.

**Example:** 192.168.1.100

**Address Classes:**
- Class A: 1.0.0.0 to 126.255.255.255 (/8)
- Class B: 128.0.0.0 to 191.255.255.255 (/16)
- Class C: 192.0.0.0 to 223.255.255.255 (/24)

---

### IPv6 (Internet Protocol version 6)
**Definition:** The sixth version of the Internet Protocol, using 128-bit addresses to resolve address exhaustion. IPv6 addresses are represented in hexadecimal (e.g., 2001:db8::1).

**Context:** Growing in importance as IPv4 addresses become scarce.

**Example:** 2001:db8::1

**Related Terms:** IPv6 Autoconfiguration, IPv6 Neighbor Discovery

---

### NAT (Network Address Translation)
**Definition:** A method of remapping one IP address space to another by modifying packet headers. NAT allows multiple devices to share a single public IP address.

**Context:** Common in home and enterprise networks to conserve public IP addresses.

**Example:** A home router translates private IPs (192.168.1.x) to its public IP address.

---

### Subnet Mask
**Definition:** A 32-bit number that separates an IP address into network and host portions. The mask identifies which bits are part of the network prefix.

**Context:** Essential for IP addressing and routing.

**Example:** /24 (255.255.255.0) means the first 24 bits are the network prefix.

---

## Transport Layer

### ACK (Acknowledgment)
**Definition:** A TCP flag indicating that the Acknowledgment Number field is valid. ACK packets acknowledge receipt of data.

**Context:** Critical for TCP's reliability. Every packet (except the first SYN) typically has the ACK flag set.

**Example:** In a TCP connection, every data segment is acknowledged.

**Related Terms:** SYN, SYN-ACK, FIN, RST, PSH, URG

---

### Congestion Control
**Definition:** A mechanism used by TCP to prevent network congestion by controlling the rate of data transmission. Techniques include slow start, congestion avoidance, and fast recovery.

**Context:** Essential for TCP performance and network stability.

**Example:** TCP uses the AIMD (Additive Increase, Multiplicative Decrease) algorithm.

---

### FIN (Finish)
**Definition:** A TCP flag used to initiate connection termination. FIN packets indicate that the sender has finished sending data.

**Context:** Part of TCP's four-way connection teardown.

**Example:** A FIN packet closes one direction of a TCP connection.

---

### Handshake (TCP Three-Way Handshake)
**Definition:** The process of establishing a TCP connection. The client sends SYN, the server responds with SYN-ACK, and the client sends ACK.

**Context:** Foundational to TCP communication. Module 3 covers TCP handshake analysis.

**Example:**
1. Client -> Server: SYN (seq=1000)
2. Server -> Client: SYN-ACK (seq=2000, ack=1001)
3. Client -> Server: ACK (seq=1001, ack=2001)

---

### RST (Reset)
**Definition:** A TCP flag used to immediately terminate a connection. RST is typically sent when a connection is refused or to abort an existing connection.

**Context:** Used for error handling and connection rejection.

**Example:** A RST packet indicates the connection was refused or reset.

---

### Sequence Number
**Definition:** A 32-bit number in TCP that identifies the position of data in a stream. The sequence number is incremented for each byte of data sent.

**Context:** Essential for TCP's reliable, ordered delivery.

**Example:** A TCP packet with seq=1000 and 100 bytes of data means the data occupies bytes 1000-1099.

---

### SYN (Synchronize)
**Definition:** A TCP flag used to initiate a connection. SYN packets are the first step in the three-way handshake and consume one byte of sequence space.

**Context:** Used for connection establishment and port scanning.

**Example:** SYN packet with seq=1000 initiates a connection.

**Related Terms:** SYN-ACK, ACK, FIN, RST

---

### TCP (Transmission Control Protocol)
**Definition:** A reliable, connection-oriented transport layer protocol that provides ordered, error-checked delivery of data.

**Context:** Used by HTTP, HTTPS, SSH, FTP, SMTP, and many other applications.

**Key Features:**
- Reliable delivery (ACKs)
- Ordered delivery (sequence numbers)
- Connection-oriented (three-way handshake)
- Flow control (window size)
- Congestion control

---

### UDP (User Datagram Protocol)
**Definition:** A simple, connectionless transport layer protocol that provides fast but unreliable delivery.

**Context:** Used by DNS, DHCP, streaming media, VoIP, and gaming.

**Key Features:**
- Connectionless
- Unreliable (best effort)
- No ordering
- Low overhead (8-byte header)
- Fast

---

### Window Size
**Definition:** A 16-bit field in TCP that specifies the number of bytes the sender can transmit before receiving an acknowledgment. Window size controls flow.

**Context:** Essential for TCP flow control and performance.

**Example:** A window size of 65535 means the sender can send up to 65535 bytes without ACK.

---

### Window Scaling
**Definition:** A TCP option that allows window sizes larger than 65535. Window scaling multiplies the window size by a shift factor.

**Context:** Used for high-performance networks (e.g., 1 Gbps+).

**Example:** Window scale of 7 multiplies window size by 2^7 (128).

---

## Application Layer

### DHCP (Dynamic Host Configuration Protocol)
**Definition:** A protocol for automatically assigning IP addresses and configuration parameters to devices.

**Context:** Module 4 covers DHCP analysis and DORA sequence tracking.

**Example:** A device uses DHCP to obtain IP, subnet mask, gateway, and DNS servers.

---

### DNS (Domain Name System)
**Definition:** A protocol for translating domain names to IP addresses.

**Context:** Module 4 covers DNS monitoring, caching, and analysis.

**Example:** A DNS query for example.com returns 93.184.216.34.

---

### HTTP (Hypertext Transfer Protocol)
**Definition:** An application layer protocol for transmitting web pages and resources. HTTP uses TCP port 80 by default.

**Context:** Module 4 covers HTTP analysis, header extraction, and request/response tracking.

**Example:** GET /index.html HTTP/1.1

**Related Terms:** HTTPS, Status Codes, Headers

---

### HTTPS (HTTP Secure)
**Definition:** HTTP over SSL/TLS encryption. HTTPS uses TCP port 443 and provides confidentiality and integrity.

**Context:** SSL/TLS handshakes can be analyzed in PCAPs.

**Example:** https://example.com uses HTTPS.

---

### SMTP (Simple Mail Transfer Protocol)
**Definition:** A protocol for sending email. SMTP uses TCP port 25.

**Context:** Email traffic analysis.

**Example:** SMTP commands: HELO, MAIL FROM, RCPT TO, DATA.

---

### Telnet
**Definition:** An unencrypted remote terminal protocol. Telnet uses TCP port 23.

**Context:** Security concerns due to lack of encryption.

**Example:** telnet example.com 23 establishes a session.

---

### SSH (Secure Shell)
**Definition:** An encrypted remote terminal protocol. SSH uses TCP port 22 and provides secure remote access.

**Context:** Security research and protocol analysis.

**Example:** SSH connection establishment includes key exchange.

---

### FTP (File Transfer Protocol)
**Definition:** A protocol for transferring files. FTP uses TCP ports 20 (data) and 21 (control).

**Context:** File transfer analysis.

**Example:** FTP commands: USER, PASS, RETR, STOR.

---

### VoIP (Voice over IP)
**Definition:** Protocols for transmitting voice communications over IP networks. Common protocols include SIP (Session Initiation Protocol) and RTP (Real-time Transport Protocol).

**Context:** Network analysis of voice traffic.

**Example:** SIP INVITE sets up a call; RTP carries voice data.

---

## Network Security

### ARP Spoofing (ARP Poisoning)
**Definition:** A technique where an attacker sends forged ARP replies to associate their MAC address with a legitimate IP address. This allows the attacker to intercept, modify, or block traffic.

**Context:** Module 5 covers ARP spoofing detection and prevention.

**Example:** Attacker sends "192.168.1.1 is at 00:11:22:33:44:55" (attacker's MAC).

**Related Terms:** MITM, ARP Cache Poisoning, Gratuitous ARP

---

### Banner Grabbing
**Definition:** The process of connecting to a service and reading its welcome banner to identify the service version and configuration.

**Context:** Module 3 covers banner grabbing for service detection.

**Example:** Connecting to port 80 and reading "Server: Apache/2.4.41".

---

### DDoS (Distributed Denial of Service)
**Definition:** An attack where multiple compromised systems flood a target with traffic, making it unavailable to legitimate users.

**Context:** Network monitoring can detect DDoS patterns.

**Example:** A SYN flood attacks a server with TCP SYN packets.

---

### Firewall
**Definition:** A network security device that monitors and controls incoming and outgoing network traffic based on predetermined security rules.

**Context:** Firewalls can filter traffic, affecting packet crafting and analysis.

**Example:** A firewall might block inbound TCP port 22 (SSH).

---

### IDS (Intrusion Detection System)
**Definition:** A system that monitors network traffic for suspicious activity and issues alerts. Passive detection.

**Context:** Detecting attacks and anomalies in network traffic.

**Example:** An IDS might alert on ARP spoofing patterns.

---

### IPS (Intrusion Prevention System)
**Definition:** A system that monitors network traffic and actively blocks or prevents malicious activity. Active defense.

**Context:** More advanced than IDS, can take automated action.

**Example:** An IPS might drop packets matching a known exploit signature.

---

### Man-in-the-Middle (MITM)
**Definition:** An attack where the attacker intercepts and potentially alters communication between two parties without their knowledge.

**Context:** ARP spoofing enables MITM attacks.

**Example:** Attacker intercepts traffic between a client and server.

---

### MITM (Man-in-the-Middle)
**Definition:** See Man-in-the-Middle (MITM).

---

### Port Scanning
**Definition:** The process of sending packets to ports on a target to determine which ports are open and listening.

**Context:** Module 3 covers various port scanning techniques.

**Techniques:**
- SYN scan (half-open)
- Connect scan (full handshake)
- UDP scan
- FIN scan
- NULL scan
- XMAS scan

---

### Reconnaissance
**Definition:** The phase of an attack where the attacker gathers information about the target, including open ports, services, and network topology.

**Context:** Port scanning and network discovery are reconnaissance techniques.

**Example:** Using port scanning to discover a web server on port 80.

---

### SYN Flood
**Definition:** A DDoS attack where an attacker sends a large number of TCP SYN packets to a target, consuming server resources and preventing legitimate connections.

**Context:** Detection and prevention of SYN flood attacks.

**Example:** Thousands of SYN packets without completing the handshake.

---

### Threat Hunting
**Definition:** The process of proactively searching for threats that have evaded existing security controls.

**Context:** Using network traffic analysis to find hidden threats.

**Example:** Analyzing DNS traffic to detect data exfiltration.

---

## Scapy-Specific Terms

### Binding
**Definition:** The process of linking two protocol layers so that Scapy knows how to dissect packets. Bindings determine which protocol follows which other protocol.

**Context:** Custom protocol development. `bind_layers()` creates bindings.

**Example:** `bind_layers(IP, CustomProtocol, proto=250)` binds CustomProtocol to IP.

---

### Dissection
**Definition:** The process of parsing raw packet bytes into structured protocol layers.

**Context:** Scapy automatically dissects packets when they are loaded or captured.

**Example:** Rdpcap dissects packets into Ether/IP/TCP/Raw layers.

---

### Field
**Definition:** A component of a packet layer that holds a specific value (e.g., source IP address, destination port). Fields define the structure of a protocol.

**Context:** Custom protocols are built by defining fields in `fields_desc`.

**Example:** `IPField("src", "0.0.0.0")` defines a source IP field.

---

### Fragment
**Definition:** A piece of a larger IP packet that has been broken up for transmission. Fragments are reassembled at the destination.

**Context:** Scapy's `fragment()` method fragments packets.

**Example:** A 2000-byte packet becomes two 1000-byte fragments.

---

### Layer Stacking
**Definition:** The process of building packets by combining protocol layers using the `/` operator. Layers are constructed from outside to inside.

**Context:** Fundamental to Scapy packet construction.

**Example:** `Ether() / IP() / TCP() / Raw()` stacks four layers.

---

### PCAP (Packet Capture)
**Definition:** A file format for storing captured network packets. PCAP files can be read, written, and analyzed.

**Context:** Scapy reads PCAPs with `rdpcap()` and writes with `wrpcap()`.

**Example:** `packets = rdpcap("capture.pcap")`

---

### Promiscuous Mode
**Definition:** A mode where a network interface captures all packets it sees, not just those addressed to it.

**Context:** Used for sniffing. Requires root privileges.

**Example:** `sniff(promisc=True)` captures all packets on the network.

---

### Raw Socket
**Definition:** A socket that allows direct access to packet headers, bypassing the operating system's normal networking stack.

**Context:** Required for sending and receiving raw packets. Requires root privileges.

**Example:** Scapy uses raw sockets to craft and send packets.

---

### Sniffing
**Definition:** The process of capturing packets from a network interface in real-time.

**Context:** Scapy's `sniff()` function captures packets.

**Example:** `sniff(count=10)` captures 10 packets.

---

### Stacking Operator (/)
**Definition:** The operator used in Scapy to stack protocol layers. Layers are stacked from outside to inside.

**Context:** Core to Scapy packet construction.

**Example:** `Ether() / IP() / TCP()` constructs an Ethernet frame containing an IP packet containing a TCP segment.

---

## Tools and Utilities

### BPF (Berkeley Packet Filter)
**Definition:** A filtering mechanism that operates at the kernel level to capture specific packets efficiently.

**Context:** Used with `sniff()` and `tcpdump` to filter packets.

**Example:** `sniff(filter="tcp port 80")` captures only HTTP traffic.

---

### Wireshark
**Definition:** A GUI network protocol analyzer used to capture and display packet details.

**Context:** Used throughout the series for visual packet verification and analysis.

**Example:** Opening a PCAP in Wireshark to verify packet construction.

---

### tcpdump
**Definition:** A command-line packet capture utility that supports BPF filters.

**Context:** Used for quick captures and scripted analysis.

**Example:** `tcpdump -i eth0 -c 100 -w capture.pcap`

---

### tshark
**Definition:** The command-line version of Wireshark, used for automated analysis and scripting.

**Context:** Useful for batch processing of PCAPs.

**Example:** `tshark -r capture.pcap -T fields -e ip.src`

---

### Scapy
**Definition:** A Python library for crafting, sending, receiving, and analyzing network packets. Provides full control over packet construction.

**Context:** The primary tool used throughout the series.

**Example:** `send(IP(dst="8.8.8.8")/ICMP())`

---

### nmap
**Definition:** A network discovery and security auditing tool used for port scanning and service detection.

**Context:** Alternatives to Scapy for port scanning.

**Example:** `nmap -sS 192.168.1.0/24` (SYN scan)

---

### Traceroute
**Definition:** A tool that tracks the path packets take to reach a destination by incrementing TTL values.

**Context:** Custom traceroute implemented in Module 2.

**Example:** `traceroute 8.8.8.8`

---

### Ping
**Definition:** A tool that tests network connectivity using ICMP Echo Request/Reply.

**Context:** Custom ping implemented in Module 2.

**Example:** `ping 8.8.8.8`

---

### ARP
**Definition:** The Address Resolution Protocol itself; also the `arp` command-line utility.

**Context:** `arp -n` displays the ARP cache.

**Example:** `arp -n` shows IP to MAC mappings.

---

### netstat
**Definition:** A tool that displays network connections, routing tables, and interface statistics.

**Context:** Useful for checking open ports and active connections.

**Example:** `netstat -tuln` shows listening TCP/UDP ports.

---

### ip (Linux)
**Definition:** A powerful Linux command for network configuration and display. Replaces `ifconfig`.

**Context:** Used for interface management and configuration.

**Example:** `ip addr show` displays interface IP addresses.

---

### ifconfig
**Definition:** A legacy Linux command for network interface configuration.

**Context:** Still used on some systems.

**Example:** `ifconfig eth0` shows interface configuration.

---

## Appendix D Complete

This glossary provides definitions for key networking terms used throughout the series. For more detailed information, refer to:

- **RFCs (Request for Comments):** Official protocol specifications
- **IEEE Standards:** Ethernet and related standards
- **IANA:** Port assignments and protocol numbers
- **Network Dictionary:** Comprehensive networking glossaries

---

```
─────────────────────────────────────────────────────────────────────────
│  APPENDIX D: GLOSSARY COMPLETE                                      │
│                                                                     │
│  This appendix covers:                                             │
│  ✅ Network fundamentals                                           │
│  ✅ Protocol layers                                                │
│  ✅ Ethernet and Layer 2                                          │
│  ✅ IP and Layer 3                                               │
│  ✅ Transport layer                                               │
│  ✅ Application layer                                              │
│  ✅ Network security                                               │
│  ✅ Scapy-specific terms                                          │
│  ✅ Tools and utilities                                           │
│                                                                     │
│  Next: Appendix E — Troubleshooting Guide                        │
└─────────────────────────────────────────────────────────────────────────
```
