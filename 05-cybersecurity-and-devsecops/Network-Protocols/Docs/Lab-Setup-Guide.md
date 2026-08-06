# Complete Virtual Lab Setup Guide (FOSS Only)

## Simulators, Virtual Machines & Free Open-Source Tools for Network Protocol Learning

---

## Overview

This guide provides complete instructions for setting up a professional-grade virtual lab environment using **only Free and Open-Source Software (FOSS)**. No physical switches, routers, or expensive hardware required. No proprietary licenses needed.

**Purpose:** Enable you to create a safe, reproducible, and powerful environment for hands-on network protocol learning using entirely free tools.

**Why FOSS-Only:**
- Zero cost
- No licensing restrictions
- Full control over your environment
- Transparent and auditable
- Community-supported

---

## Section 1: The Core Lab Platform

### 1.1 System Requirements

**Minimum Specifications:**
- **CPU:** Multi-core (quad-core recommended)
- **RAM:** 8 GB minimum, 16 GB strongly recommended
- **Storage:** 256 GB SSD or larger
- **OS:** Windows 10/11, macOS 10.14+, Ubuntu 18.04+ (Linux recommended)

**Virtualization Requirements:**
- **Hardware Virtualization:** Intel VT-x or AMD-V enabled in BIOS
- **Virtualization Software:** One of the options below (all FOSS)

### 1.2 Virtualization Platform Options (All FOSS)

**Option A: VirtualBox (Recommended for Beginners)**
- **License:** GPLv2 (Free and Open Source)
- **Cross-Platform:** Windows, macOS, Linux
- **Download:** virtualbox.org

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack

# Install Extension Pack for USB 2.0/3.0 support
wget https://download.virtualbox.org/virtualbox/7.0.12/Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack
sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack
```

**Option B: KVM/QEMU (Advanced, Linux-only)**
- **License:** GPLv2 (Free and Open Source)
- **Performance:** Near-native performance
- **Recommended for:** Advanced users on Linux

```bash
# Ubuntu/Debian
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Add user to libvirt group
sudo usermod -aG libvirt $USER
```

### 1.3 Recommended Virtual Machines (All FOSS)

| VM | Purpose | License | Download |
|----|---------|---------|----------|
| **Ubuntu Server** | DHCP, DNS, HTTP servers | GPL | ubuntu.com/download/server |
| **Kali Linux** | Penetration testing, packet generation | GPL | kali.org/get-kali |
| **Alpine Linux** | Lightweight container host | MIT | alpinelinux.org/downloads |
| **Metasploitable 2** | Vulnerable target (security labs) | GPL | SourceForge |
| **pfSense** | Firewall, routing | Apache 2.0 | pfsense.org/download |
| **OpenWrt** | Router emulation | GPL | openwrt.org/downloads |

---

## Section 2: Container-Based Network Simulation (Recommended)

### 2.1 Containerlab - The Modern Approach

**What is Containerlab?** Containerlab is an open-source network emulation tool that uses containers instead of virtual machines, making it extremely lightweight and fast .

**Advantages over traditional VMs:**
- ✅ ~50MB per router vs 1GB+ for VMs
- ✅ 30-second startup vs 10+ minutes
- ✅ Easy YAML-based topology definition
- ✅ GitHub Actions CI integration
- ✅ Complete FOSS stack

**Installation:**

```bash
# Install Docker (FOSS)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Containerlab
curl -sL https://containerlab.dev/install.sh | sudo bash

# Verify installation
containerlab version
```

### 2.2 Free Containerlab Labs

**Available Free Labs:** 

**1. OSPF Basics Lab ⭐⭐ (Beginner, 45 minutes)**
- 3 FRR (Free Range Routing) routers in Area 0
- Learn OSPF neighbor adjacency, DR/BDR election, LSA propagation
- 6 automated validation tests
- Complete troubleshooting scenarios

**2. BGP eBGP Basics Lab ⭐⭐ (Beginner, 60 minutes)**
- 4 FRR routers across 3 autonomous systems
- Learn eBGP peering, AS-path, route advertisement
- 6 automated validation tests
- Real-world multi-AS topology

**3. Linux Network Namespaces Lab ⭐ (Beginner, 30 minutes)**
- 4 Alpine Linux containers
- Understand container networking fundamentals
- 5 automated validation tests
- Foundation for understanding containerlab

**Quick Start:**

```bash
# Clone the free labs repository
git clone https://github.com/ciscoittech/containerlab-free-labs.git
cd containerlab-free-labs

# Deploy OSPF lab
cd ospf-basics
sudo containerlab deploy -t topology.clab.yml

# Verify deployment
docker ps
sudo containerlab inspect

# Access routers
docker exec -it clab-ospf-basics-r1 vtysh
```

### 2.3 FRR (Free Range Routing)

**What is FRR?** FRR is a fully open-source routing software suite that provides Cisco-like syntax. Perfect for CCNA/CCNP practice without expensive hardware .

**FRR Features:**
- OSPFv2/v3
- BGP (full implementation)
- RIP, RIPng
- IS-IS
- MPLS, LDP
- VXLAN, EVPN

**Basic FRR Configuration:**
```bash
# Enter FRR configuration mode
vtysh

# Configure OSPF
configure terminal
router ospf
network 10.0.0.0/24 area 0
network 10.0.1.0/24 area 0
exit

# Configure BGP
router bgp 65001
neighbor 10.0.0.2 remote-as 65002
network 192.168.1.0/24
exit

# Save configuration
write memory
```

---

## Section 3: Traditional Simulators

### 3.1 Packet Tracer (Free with Cisco NetAcad)

**Note:** Packet Tracer requires a free Cisco NetAcad account. It is not fully open-source but is freely available for educational use.

**Installation Steps:**

1. Create free account at netacad.com
2. Download Packet Tracer from NetAcad Resources
3. Install and log in

**Sample Topology:**
```
PC1 -- Switch1 -- Router1 -- WAN -- Router2 -- Switch2 -- PC2
```

### 3.2 NS-3 Network Simulator (Fully Open Source)

**What is NS-3?** NS-3 is a free and open-source discrete-event network simulator for research and education. It is written in C++ with Python bindings .

**License:** GNU GPLv2

**Installation:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install g++ python3 python3-dev mercurial \
  cmake ninja-build build-essential \
  libsqlite3-dev libgtk-3-dev \
  libxml2-dev libboost-all-dev

# Download NS-3
wget https://www.nsnam.org/release/ns-allinone-3.46.tar.bz2
tar -xjf ns-allinone-3.46.tar.bz2
cd ns-allinone-3.46

# Build
./build.py --enable-examples --enable-tests

# Verify
cd ns-3.46
./waf --run hello-simulator
```

**Key NS-3 Features :**
- **Modular design** - Nodes, channels, network devices, applications
- **Multiple simulation modes** - Discrete event, real-time sync, distributed parallel
- **pcap output** - Can analyze with Wireshark
- **Docker support** - Containerized deployment
- **IPv6 support** - Full IPv6 protocol suite
- **802.11 modules** - Complete WiFi simulation
- **Visualization** - NetAnim and PyViz for simulation visualization

### 3.3 GNS3 (Free and Open Source)

**What is GNS3?** GNS3 is a network emulation platform that can run real router images (which you must obtain separately, but the platform itself is open source).

**Installation:**

```bash
# Ubuntu
sudo add-apt-repository ppa:gns3/ppa
sudo apt update
sudo apt install gns3-gui gns3-server

# Install GNS3 VM for better performance
# Download OVA from gns3.com and import into VirtualBox
```

---

## Section 4: Browser-Based Interactive Labs

### 4.1 Interactive Networking Laboratory (Fully Open Source)

**What is it?** A collection of browser-based educational resources for teaching networking through visual explanations and interactive simulations .

**License:** Creative Commons Attribution 4.0 International (CC BY 4.0)

**No installation required** - Works offline with a modern web browser.

**Key Components:** 

**NetLab v5.5 - The Main Simulator:**
- Visual representation of communication across ISO/OSI and TCP/IP layers
- Guided scenarios covering:
  - Packet encapsulation and decapsulation
  - Communication between hosts, routers, and WAN devices
  - ARP resolution within a local network
  - DNS queries
  - TCP three-way handshake
  - HTTP request and response
  - TCP acknowledgements
  - ICMP and Ping
  - Traceroute and TTL
  - IPv4 fragmentation
  - Routing across multiple devices
  - Ethernet frames, MAC addresses, and FCS error detection

**Simulated Topology:**
```
Client → Router-A → DCE/WAN → Router-B → Server
```

**Features:**
- Adjustable animation speed
- Pause and step-by-step execution
- ISO/OSI and TCP/IP views
- Detailed simulation log
- PDF export of the log
- Guided error simulation
- Interactive quiz
- Didactic board for classroom explanations

**Interactive TCP/IP and ISO/OSI Conceptual Map:**
- Visual relationships between TCP/IP layers and ISO/OSI layers
- Protocols, PDUs, networking devices
- Encapsulation and decapsulation
- Routing, addressing, error-control mechanisms
- Five integrated mini-simulations:
  - Encapsulation
  - Packet routing
  - DNS resolution
  - ARP resolution
  - IP addresses, MAC addresses, next-hop delivery

**Glossary and Network Commands:**
- Definitions of key networking concepts
- Common diagnostic commands for Windows, Linux, macOS:
  - `ipconfig /all`
  - `ifconfig` and `ip addr`
  - `ping`
  - `tracert` / `traceroute`
  - `arp -a`
  - `nslookup`
  - `netstat`

**Download:** https://doi.org/10.5281/zenodo.21299699 

---

## Section 5: From-Scratch Protocol Implementation

### 5.1 TCP/IP Protocol Stack Implementation (FOSS)

For advanced students who want to understand protocols at the deepest level, these projects implement TCP/IP from scratch .

**Project 1: Lightweight TCP/IP Stack** 
- **License:** Open source (see repository)
- **Language:** C/C++ with CMake
- **Features:**
  - Ethernet link layer support (PCAP/Npcap backend)
  - ARP implementation
  - IP networking
  - TCP echo client/server examples
  - Windows/Linux support

```bash
# Clone the repository
git clone https://github.com/123lishiming/TCP-IP.git
cd TCP-IP

# Build with CMake
mkdir build && cd build
cmake ..
cmake --build . --config Debug

# Run the echo server
./Debug/net.exe
```

**Project 2: Complete TCP/IP Protocol Stack** 
- **License:** Apache 2.0
- **Language:** C++ with CMake
- **Based on:** Stanford CS144
- **Features:**
  - ByteStream for flow control
  - NetworkInterface (link layer to network layer)
  - Reassembler for stream reconstruction
  - Router with routing table
  - TCP Receiver (receives and reassembles)
  - TCP Sender (segments and retransmits)
  - TUN/TAP support for virtual networking
  - Complete test suite

```bash
# Clone the repository
git clone https://github.com/qmmzzdx/tcpip_network_protocol_stack.git
cd tcpip_network_protocol_stack

# One-click build and test
chmod +x ./script/run_start.sh
./script/run_start.sh

# Monitor the build
tail -f /var/log/package_install.log
```

**Key Implementation Details:** 
- **TUN/TAP Technology:** Virtual network interfaces that allow user-level programs to access the network layer
- **Data Flow:**
  1. Application layer generates data
  2. TCP Sender: three-way handshake, segmentation, retransmission
  3. NetworkInterface: ARP resolution, IP datagram encapsulation
  4. Router: routing table lookup, packet forwarding
  5. TCP Receiver: reassembly, ByteStream delivery

---

## Section 6: Packet Analysis Tools (FOSS)

### 6.1 Wireshark

**License:** GPLv2

**Installation:**

```bash
# Ubuntu/Debian
sudo apt install wireshark

# Add user to wireshark group (for non-root capture)
sudo usermod -aG wireshark $USER

# macOS (with Homebrew)
brew install wireshark

# Windows
# Download from wireshark.org and install
```

**Wireshark is essential for every lab :**

**Display Filter Examples :**
- `ip.addr == 192.168.1.10` - Filter by IP
- `http` - Filter HTTP traffic
- `dns` - Filter DNS queries
- `arp` - Filter ARP packets
- `icmp` - Filter ICMP packets
- `tcp.flags.syn == 1` - Find SYN packets
- `tls.handshake.type == 1` - Find ClientHello

**Capture Filter Examples :**
- `host 192.168.1.10` - Only this host
- `tcp port 80` - HTTP traffic
- `udp port 53` - DNS traffic
- `icmp` - Only ICMP

### 6.2 tcpdump / tshark

**tshark** is the command-line version of Wireshark .

```bash
# Basic capture
sudo tcpdump -i eth0

# Capture to file
sudo tcpdump -i eth0 -w capture.pcap

# Read capture
tshark -r capture.pcap

# Apply display filter
tshark -r capture.pcap -Y "http.request"
```

---

## Section 7: Complete Lab Topology (FOSS-Only)

### 7.1 Containerlab Topology

**YAML Topology File:**

```yaml
# topology.clab.yml - Complete FOSS Network Lab
name: foss-net-lab

topology:
  kinds:
    linux:
      image: alpine:latest

  nodes:
    # FRR Routers
    r1:
      kind: linux
      image: frrouting/frr:latest
      exec:
        - vtysh -c "configure terminal"
        - vtysh -c "router ospf"
        - vtysh -c "network 10.0.0.0/24 area 0"
        - vtysh -c "exit"
      labels:
        node: r1

    r2:
      kind: linux
      image: frrouting/frr:latest
      exec:
        - vtysh -c "configure terminal"
        - vtysh -c "router ospf"
        - vtysh -c "network 10.0.0.0/24 area 0"
        - vtysh -c "exit"
      labels:
        node: r2

    r3:
      kind: linux
      image: frrouting/frr:latest
      exec:
        - vtysh -c "configure terminal"
        - vtysh -c "router ospf"
        - vtysh -c "network 10.0.0.0/24 area 0"
        - vtysh -c "exit"
      labels:
        node: r3

    # Clients
    client1:
      kind: linux
      image: alpine:latest
      exec:
        - apk add iputils net-tools curl
      labels:
        node: client1

    client2:
      kind: linux
      image: alpine:latest
      exec:
        - apk add iputils net-tools curl
      labels:
        node: client2

  links:
    - endpoints: ["r1:eth1", "r2:eth1"]
    - endpoints: ["r1:eth2", "r3:eth1"]
    - endpoints: ["r2:eth2", "r3:eth2"]
    - endpoints: ["client1:eth1", "r1:eth3"]
    - endpoints: ["client2:eth1", "r2:eth3"]
```

### 7.2 VirtualBox Lab Topology

```
┌─────────────────────────────────────────────────────────────┐
│                    FOSS VIRTUAL LAB TOPOLOGY               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Host Computer (Your machine)                     │    │
│  │  ├─ Wireshark (GPL)                              │    │
│  │  ├─ tcpdump / tshark (GPL)                       │    │
│  │  └─ Python scripts (FOSS)                        │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│          ┌──────────────┼──────────────┐                   │
│          │              │              │                   │
│          ▼              ▼              ▼                   │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐      │
│  │ Ubuntu Server│ │ Kali Linux  │ │ pfSense     │      │
│  │ (Services)  │ │ (Testing)   │ │ (Firewall)  │      │
│  │              │ │              │ │              │      │
│  │ DHCP        │ │ Packet Gen  │ │ Routing     │      │
│  │ DNS         │ │ Security    │ │ NAT         │      │
│  │ HTTP        │ │ Tools       │ │              │      │
│  └──────────────┘ └──────────────┘ └──────────────┘      │
│          │              │              │                   │
│          └──────────────┼──────────────┘                   │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Internal Network (Host-Only)                      │    │
│  │  e.g., 192.168.56.0/24                           │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 8: Quick Start Checklist

### Software Installation Checklist

- [ ] VirtualBox (GPL) or KVM/QEMU
- [ ] Containerlab (Apache 2.0)
- [ ] Docker CE (Apache 2.0)
- [ ] Ubuntu Server ISO (GPL) installed in VM
- [ ] Kali Linux ISO (GPL) installed in VM
- [ ] pfSense ISO (Apache 2.0) installed in VM
- [ ] Wireshark (GPL)
- [ ] Python 3.8+ (PSF License)
- [ ] curl, dig, nslookup (various FOSS)
- [ ] openssl (Apache 1.1)

### Lab Deployment Steps

1. **Install VirtualBox**
   ```bash
   sudo apt install virtualbox
   ```

2. **Install Docker & Containerlab**
   ```bash
   curl -fsSL https://get.docker.com | sh
   curl -sL https://containerlab.dev/install.sh | sudo bash
   ```

3. **Deploy Containerlab Lab**
   ```bash
   git clone https://github.com/ciscoittech/containerlab-free-labs.git
   cd containerlab-free-labs/ospf-basics
   sudo containerlab deploy -t topology.clab.yml
   ```

4. **Install Wireshark**
   ```bash
   sudo apt install wireshark
   ```

5. **Launch Browser-Based Simulator**
   ```bash
   # Download Interactive Networking Laboratory
   wget https://zenodo.org/records/21299699/files/Interactive_Networking_Laboratory.zip
   unzip Interactive_Networking_Laboratory.zip
   # Open netlab_v5_5.html in your browser
   ```

6. **Start Capturing Traffic**
   ```bash
   sudo tcpdump -i eth0 -w lab_capture.pcap
   ```

7. **Analyze Capture**
   ```bash
   wireshark lab_capture.pcap
   # or
   tshark -r lab_capture.pcap -Y "http"
   ```

---

## Section 9: Troubleshooting Common Issues

### Issue 1: "Permission Denied" for tcpdump

**Solution:**
```bash
sudo usermod -aG wireshark $USER
# Log out and back in
```

### Issue 2: Containerlab "No such file or directory"

**Solution:**
```bash
# Ensure Docker is running
sudo systemctl status docker

# Fix permissions
sudo chmod 666 /var/run/docker.sock
```

### Issue 3: VMs Can't Ping Each Other

**Solution:**
```bash
# Check VirtualBox network configuration
# Ensure all VMs are on the same host-only network

# On each VM, verify IP configuration
ip addr show
# Ensure static IPs are in the same subnet
```

### Issue 4: Wireshark Shows "No interfaces found"

**Solution:**
```bash
# Linux - Set non-root capture
sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap

# Windows - Run Wireshark as Administrator
```

### Issue 5: Packet Capture is Empty

**Solution:**
```bash
# Verify you're capturing on the correct interface
ip link show
# Capture with the correct interface name
sudo tcpdump -i ens33 -c 10
```

---

## Section 10: Recommended Learning Path

### Week 1-2: The Basics
1. **Interactive Networking Laboratory** - Run the browser-based simulator to understand encapsulation and layers 
2. **Wireshark Tutorial** - Capture your first packets 
3. **Containerlab OSPF Lab** - Deploy your first router topology 

### Week 3-4: Network Layer
1. **FRR Configuration** - Configure OSPF and BGP in FRR routers
2. **Subnet Calculator** - Build a Python subnet calculator
3. **Traceroute Analysis** - Capture and analyze traceroute packets

### Week 5-6: Transport Layer
1. **TCP Echo Server** - Build in Python
2. **TCP Handshake Analysis** - Capture and analyze three-way handshake 
3. **UDP vs TCP Comparison** - Test and compare both protocols

### Week 7-8: Application Layer
1. **DNS Client** - Build in Python
2. **HTTP Server** - Build a simple HTTP server
3. **Email Client** - SMTP/POP3 implementation

### Week 9-10: Security & Advanced
1. **TLS Handshake Analysis** - Capture and analyze TLS 
2. **Protocol Stack Implementation** - Explore from-scratch implementations 
3. **Capstone Project** - Complete network monitoring system

---

## Section 11: Resources Summary

| Tool | License | Purpose | Link |
|------|---------|---------|------|
| VirtualBox | GPLv2 | Virtualization | virtualbox.org |
| Containerlab | Apache 2.0 | Network emulation | containerlab.dev |
| FRR | GPLv2 | Routing software | frrouting.org |
| Wireshark | GPLv2 | Packet analysis | wireshark.org |
| NS-3 | GNU GPLv2 | Network simulation | nsnam.org |
| Interactive NetLab | CC BY 4.0 | Browser-based simulation | zenodo.org (10.5281/zenodo.21299699) |
| Kali Linux | GPL | Security testing | kali.org |
| Ubuntu Server | GPL | Server services | ubuntu.com |
| pfSense | Apache 2.0 | Firewall | pfsense.org |
| Docker CE | Apache 2.0 | Containerization | docker.com |

---

**END OF VIRTUAL LAB SETUP GUIDE**
