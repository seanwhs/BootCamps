# Primer 2 – Networking Fundamentals for Docker Users

Networking is one of the most complex aspects of Docker. This primer breaks down the networking concepts you need to understand—from the OSI model to container networking, IP addressing, ports, and DNS.

By the end, you'll have a solid mental model of how networking works in Docker and be able to debug network issues with confidence.

---

## P2.1 The OSI Model: A Mental Framework

The OSI (Open Systems Interconnection) model is a conceptual framework that describes how network communication works. Understanding it helps you pinpoint where problems occur.

### The 7 Layers

```
┌─────────────────────────────────────────────────────────────┐
│ 7. Application Layer    │ HTTP, FTP, SMTP, DNS, SSH       │
├─────────────────────────┼─────────────────────────────────┤
│ 6. Presentation Layer   │ Encryption, compression          │
├─────────────────────────┼─────────────────────────────────┤
│ 5. Session Layer        │ Connection management            │
├─────────────────────────┼─────────────────────────────────┤
│ 4. Transport Layer      │ TCP, UDP, SCTP                  │
├─────────────────────────┼─────────────────────────────────┤
│ 3. Network Layer        │ IP, ICMP, ARP                   │
├─────────────────────────┼─────────────────────────────────┤
│ 2. Data Link Layer      │ Ethernet, Wi-Fi                 │
├─────────────────────────┼─────────────────────────────────┤
│ 1. Physical Layer       │ Cables, radio waves             │
└─────────────────────────┴─────────────────────────────────┘
```

**In Docker Context:**

| Layer | What Docker Does |
|-------|------------------|
| Application | Your app's HTTP/GRPC endpoints |
| Transport | TCP/UDP ports (mapped to host) |
| Network | Container IP addresses |
| Data Link | Bridge networks, MAC addresses |

**Why This Matters:** When you debug network issues, you can work through the layers. If you can't connect, start at Layer 1 and work up.

---

## P2.2 IP Addressing and Subnetting

### IPv4 Addresses

An IPv4 address is 32 bits, shown as four decimal numbers (octets) separated by dots:

```
192.168.1.100
│   │   │   │
│   │   │   └── Host (last octet)
│   │   └────── Subnet
│   └────────── Network
└────────────── Network
```

### Private IP Ranges

These IP ranges are reserved for private networks and are not routable on the internet:

| Range | CIDR | Use Case |
|-------|------|----------|
| 10.0.0.0 – 10.255.255.255 | 10.0.0.0/8 | Large networks |
| 172.16.0.0 – 172.31.255.255 | 172.16.0.0/12 | Medium networks |
| 192.168.0.0 – 192.168.255.255 | 192.168.0.0/16 | Small networks |
| 169.254.0.0 – 169.254.255.255 | 169.254.0.0/16 | Link-local (autoconfig) |

**Docker's Default Networks:**

| Network | Subnet | Purpose |
|---------|--------|---------|
| Default bridge | 172.17.0.0/16 | Docker's default bridge |
| User-defined bridges | 172.18.0.0/16+ | Custom bridge networks |
| Host | N/A | Uses host IP |

### CIDR Notation

CIDR (Classless Inter-Domain Routing) notation specifies a subnet:

```
192.168.1.0/24
           ││
           │└── Number of network bits
           └──── Network address
```

**Common Subnets:**

| CIDR | Netmask | Available IPs | Example |
|------|---------|---------------|---------|
| /24 | 255.255.255.0 | 254 | 192.168.1.0/24 |
| /16 | 255.255.0.0 | 65,534 | 172.16.0.0/16 |
| /8 | 255.0.0.0 | 16,777,214 | 10.0.0.0/8 |
| /28 | 255.255.255.240 | 14 | Small subnets |

### IP Address Components

```
192.168.1.100/24
│         │   │
│         │   └── Network: 192.168.1.0/24
│         └────── Broadcast: 192.168.1.255
└─────────────── Gateway: 192.168.1.1 (usually)
```

**Special IP Addresses:**

| Address | Purpose |
|---------|---------|
| Network address (x.x.x.0) | Identifies the network |
| Broadcast (x.x.x.255) | Sends to all hosts on network |
| Gateway (x.x.x.1) | Router for the network |
| Localhost (127.0.0.1) | Loopback, refers to itself |

**In Docker:**
```bash
# Create a network with specific subnet
docker network create \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  custom-net

# Assign a specific IP
docker run --network custom-net --ip 192.168.100.50 nginx
```

---

## P2.3 TCP and UDP: Transport Layer Protocols

### TCP (Transmission Control Protocol)

TCP is connection-oriented, reliable, and ordered.

**Characteristics:**
- ✅ Connection establishment (three-way handshake)
- ✅ Error checking and correction
- ✅ Ordered delivery
- ✅ Flow control
- ✅ Slower than UDP

**The Three-Way Handshake:**
```
Client                    Server
  │                         │
  │─── SYN (Sync) ──────────►│
  │                         │
  │◄── SYN-ACK (Acknowledge)─│
  │                         │
  │─── ACK ─────────────────►│
  │                         │
  │    Connection Established│
  │                         │
```

**Common TCP Ports:**

| Port | Service |
|------|---------|
| 80 | HTTP |
| 443 | HTTPS |
| 22 | SSH |
| 5432 | PostgreSQL |
| 3306 | MySQL |
| 6379 | Redis |
| 8080 | HTTP Alternative |

### UDP (User Datagram Protocol)

UDP is connectionless, unreliable, but fast.

**Characteristics:**
- ❌ No connection establishment
- ❌ No guaranteed delivery
- ❌ No ordering
- ✅ Faster than TCP
- ✅ Lower overhead

**Common UDP Ports:**

| Port | Service |
|------|---------|
| 53 | DNS |
| 67/68 | DHCP |
| 123 | NTP |
| 161 | SNMP |
| 514 | Syslog |
| 1194 | OpenVPN |

### TCP vs UDP in Docker

```yaml
# Docker Compose specifying protocols
services:
  web:
    ports:
      - "8080:80/tcp"    # TCP (default)
      - "53:53/udp"      # UDP
      - "8080:80"        # TCP is default
```

---

## P2.4 Ports and Port Mapping

### Understanding Ports

A port is a number (0-65535) that identifies a specific service on a host.

**Port Ranges:**

| Range | Purpose |
|-------|---------|
| 0-1023 | Well-known (privileged) ports |
| 1024-49151 | Registered ports |
| 49152-65535 | Dynamic/private ports |

**Why Port Mapping Matters:** Containers have their own network namespace. Port 80 inside a container is not the same as port 80 on the host.

### Port Mapping in Docker

**Syntax:**
```
-p [HOST_PORT]:[CONTAINER_PORT]/[PROTOCOL]
```

**Examples:**

| Command | What It Does |
|---------|--------------|
| `-p 8080:80` | Map host port 8080 → container port 80 |
| `-p 80:80` | Map host port 80 → container port 80 |
| `-p 8080-8085:80-85` | Map range of ports |
| `-p 127.0.0.1:8080:80` | Bind to specific host interface |
| `-p 53:53/udp` | Map UDP port |

### Testing Port Mapping

```bash
# Run a container with port mapping
docker run -d --name web -p 8080:80 nginx:alpine

# Check port mapping
docker port web
```
```
80/tcp -> 0.0.0.0:8080
```

```bash
# Test connectivity
curl http://localhost:8080

# Or from another container
docker run --rm alpine wget -O- http://host.docker.internal:8080  # Mac/Windows
docker run --rm alpine wget -O- http://172.17.0.1:8080  # Linux
```

### Publishing Ports vs Exposing Ports

| Concept | Purpose | Command |
|---------|---------|---------|
| **EXPOSE** | Documentation (doesn't publish) | `EXPOSE 80` in Dockerfile |
| **-p** | Publish to host | `docker run -p 8080:80` |
| **-P** | Publish all exposed ports | `docker run -P` |

---

## P2.5 DNS: Domain Name System

### How DNS Works

DNS translates human-readable names to IP addresses.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Browser    │     │  DNS        │     │  DNS        │
│  or App     │────►│  Resolver   │────►│  Server     │
│             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

**DNS Resolution Process:**

```
1. Application requests: api.example.com
2. Resolver checks cache
3. If not in cache, queries DNS server
4. DNS server returns IP: 93.184.216.34
5. Application connects to IP
```

### Docker's Built-in DNS

Docker provides DNS resolution on user-defined bridge networks.

```bash
# Create a network
docker network create app-net

# Run a container
docker run -d --name redis --network app-net redis:alpine

# Another container can resolve "redis"
docker run --rm --network app-net alpine nslookup redis
```
```
Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:
Name:   redis
Address: 172.18.0.2
```

**Key Insight:** The DNS server is at 127.0.0.11 (a special address inside containers).

### Custom DNS Configuration

```bash
# Use specific DNS servers
docker run --dns 8.8.8.8 --dns 1.1.1.1 my-image

# Search domains
docker run --dns-search example.com my-image

# In Docker Compose
services:
  app:
    dns:
      - 8.8.8.8
      - 1.1.1.1
    dns_search:
      - example.com
      - internal.example.com
```

### Network Aliases

```bash
# Create a container with multiple names
docker run -d --name api-v1 \
  --network app-net \
  --network-alias api \
  --network-alias api-v1 \
  nginx

# Other containers can reach it by any alias
docker run --rm --network app-net alpine nslookup api
docker run --rm --network app-net alpine nslookup api-v1
```

---

## P2.6 Docker Network Types Explained

### Bridge Network (Default)

**How it works:**
- Docker creates a virtual bridge (`docker0`) on the host
- Containers connect to this bridge
- Each container gets its own IP (172.17.x.x)
- Port mapping required for external access

```
┌─────────────────────────────────────────────────────────┐
│                      Host                               │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ Container A │  │ Container B │  │ Container C │    │
│  │ 172.17.0.2  │  │ 172.17.0.3  │  │ 172.17.0.4  │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │            │
│         └────────────────┼────────────────┘            │
│                          │                             │
│                    ┌─────▼─────┐                       │
│                    │ docker0   │                       │
│                    │ bridge    │                       │
│                    └─────┬─────┘                       │
│                          │                             │
│                   ┌──────▼──────┐                      │
│                   │ Host NIC   │                      │
│                   │ 192.168.1.10│                      │
│                   └─────────────┘                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Pros:**
- Good isolation
- DNS resolution (user-defined only)
- Fine-grained control

**Cons:**
- Manual port mapping needed
- Performance overhead (small)

### Host Network

**How it works:**
- Container uses host's network stack
- No network isolation
- No port mapping needed

```
┌─────────────────────────────────────────────────────────┐
│                      Host                               │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ Container A │  │ Container B │  │ Container C │    │
│  │ Uses host   │  │ Uses host   │  │ Uses host   │    │
│  │ network     │  │ network     │  │ network     │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                         │
│              ┌─────────────────────┐                    │
│              │ Host Network Stack  │                    │
│              └─────────────────────┘                    │
│                                                         │
│              ┌─────────────────────┐                    │
│              │ Host NIC           │                    │
│              │ 192.168.1.10       │                    │
│              └─────────────────────┘                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Pros:**
- Best performance (no network isolation overhead)
- No port mapping needed
- All host ports available

**Cons:**
- No network isolation
- Port conflicts with host services
- Not portable across hosts

```bash
docker run --network host nginx:alpine
# Now accessible on host's IP: http://192.168.1.10:80
```

### None Network

**How it works:**
- Container has no network interfaces
- Completely isolated from network

```
┌─────────────────────────────────────────────────────────┐
│                      Host                               │
│                                                         │
│  ┌─────────────┐                                        │
│  │ Container A │                                        │
│  │ No network  │                                        │
│  │ interfaces  │                                        │
│  └─────────────┘                                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Pros:**
- Maximum security
- No network exposure

**Cons:**
- Can't communicate with anything
- Very limited use cases

```bash
docker run --network none ubuntu:22.04 ping google.com  # Fails
```

### Overlay Network (Swarm/Kubernetes)

**How it works:**
- Creates a network across multiple hosts
- Uses VXLAN tunneling
- Enables cross-host container communication

```
┌──────────────────────┐    ┌──────────────────────┐
│      Host 1          │    │      Host 2          │
│                      │    │                      │
│ ┌──────┐ ┌──────┐   │    │ ┌──────┐ ┌──────┐   │
│ │Cont A│ │Cont B│   │    │ │Cont C│ │Cont D│   │
│ └──┬───┘ └──┬───┘   │    │ └──┬───┘ └──┬───┘   │
│    │        │       │    │    │        │       │
│    └────────┼───────┼────┼────┼────────┘       │
│             │       │    │    │                 │
│    ┌────────▼───────┼────┼────▼────────┐       │
│    │  Overlay Network (VXLAN)          │       │
│    └────────┬──────────────────────────┘       │
│             │                                   │
│    ┌────────▼────────┐    ┌────────▼────────┐   │
│    │ Physical Network│    │ Physical Network│   │
│    └─────────────────┘    └─────────────────┘   │
│                      │    │                      │
└──────────────────────┘    └──────────────────────┘
```

```bash
# In Swarm mode
docker network create --driver overlay --attachable my-overlay
docker service create --network my-overlay nginx
```

---

## P2.7 Network Troubleshooting Commands

### Checking Network Connectivity

```bash
# Ping a host
ping google.com
ping 8.8.8.8

# Check route
ip route
route -n

# Check DNS resolution
nslookup google.com
dig google.com
host google.com

# Check open ports
ss -tulpn
netstat -tulpn
lsof -i :8080

# Check ARP table
arp -n
ip neigh
```

### Inside a Container

```bash
# Execute network commands inside container
docker exec container-name ping google.com
docker exec container-name nslookup google.com
docker exec container-name curl http://localhost:8080
docker exec container-name ss -tulpn

# Get interactive shell
docker exec -it container-name /bin/bash
# Then run network commands inside
```

### Docker-Specific Network Commands

```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge

# Show network statistics
docker network inspect bridge --format='{{json .Containers}}' | jq '.'

# Connect container to network
docker network connect app-net container-name

# Disconnect container from network
docker network disconnect app-net container-name

# Check container IP
docker inspect container-name --format='{{.NetworkSettings.IPAddress}}'

# Check all IPs for container
docker inspect container-name --format='{{json .NetworkSettings.Networks}}' | jq '.'
```

---

## P2.8 Common Networking Scenarios

### Scenario 1: Container Can't Reach Internet

**Problem:** Container can't ping google.com.

```bash
docker run --rm ubuntu:22.04 ping google.com
# ping: google.com: Temporary failure in name resolution
```

**Debugging Steps:**
```bash
# 1. Check DNS
docker run --rm ubuntu:22.04 cat /etc/resolv.conf

# 2. Try direct IP
docker run --rm ubuntu:22.04 ping 8.8.8.8

# 3. Check container can reach host
docker run --rm ubuntu:22.04 ping 172.17.0.1

# 4. Check host can reach internet
ping 8.8.8.8
```

**Solutions:**
```bash
# 1. Fix DNS
docker run --dns 8.8.8.8 ubuntu:22.04 ping google.com

# 2. Use host network
docker run --network host ubuntu:22.04 ping google.com

# 3. Check proxy settings
docker run -e http_proxy=http://proxy:8080 ubuntu:22.04 ping google.com

# 4. On Linux, check iptables
sudo iptables -L -n | grep DOCKER
```

### Scenario 2: Containers Can't Communicate

**Problem:** Two containers on different networks can't talk.

**The Setup:**
```bash
docker run -d --name app1 nginx
docker run -d --name app2 --network custom-net nginx

# app1 can't ping app2
docker exec app1 ping app2  # Fails: ping: app2: Name or service not known
```

**Debugging:**
```bash
# 1. Check container networks
docker inspect app1 --format='{{json .NetworkSettings.Networks}}' | jq '.'
docker inspect app2 --format='{{json .NetworkSettings.Networks}}' | jq '.'

# 2. Check IPs
docker inspect app1 --format='{{.NetworkSettings.IPAddress}}'
docker inspect app2 --format='{{.NetworkSettings.IPAddress}}'

# 3. Try by IP
docker exec app1 ping 172.18.0.2  # Should work if same network
```

**Solutions:**
```bash
# 1. Connect to same network
docker network connect bridge app2

# 2. Create new network and attach both
docker network create shared-net
docker network connect shared-net app1
docker network connect shared-net app2

# 3. Use container name (if on same network)
docker exec app1 ping app2  # Should work now
```

### Scenario 3: Port Conflict

**Problem:** Port already in use.

```bash
docker run -d -p 8080:80 nginx
docker run -d -p 8080:80 nginx
# Error: port is already allocated
```

**Solutions:**
```bash
# 1. Find what's using the port
docker ps --filter "publish=8080"
lsof -i :8080
netstat -tulpn | grep 8080

# 2. Use a different host port
docker run -d -p 8081:80 nginx

# 3. Stop the conflicting container
docker stop conflicting-container

# 4. In Docker Compose, change port
services:
  web:
    ports:
      - "8081:80"
```

---

## P2.9 Networking Lab: Debug a Broken Network

### The Lab Setup

```bash
# Create the lab environment
cat > docker-compose.network-lab.yml << EOF
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      - webnet
    ports:
      - "8080:80"

  api:
    image: python:3.11-slim
    command: python -m http.server 5000
    networks:
      - apinet
    ports:
      - "5000:5000"

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=secret
    networks:
      - dbanet
EOF

# Start the lab
docker compose -f docker-compose.network-lab.yml up -d
```

### Step 1: Check Container Status

```bash
docker compose -f docker-compose.network-lab.yml ps
```
```
NAME                COMMAND                  SERVICE             STATUS              PORTS
web                 "/docker-entrypoint.…"   web                 running             0.0.0.0:8080->80/tcp
api                 "python -m http.serv…"   api                 running             0.0.0.0:5000->5000/tcp
db                  "docker-entrypoint.s…"   db                  running             5432/tcp
```

### Step 2: Identify the Problem

**Problem:** The web container can't reach the api container.

**Diagnosis:**
```bash
# Try to reach api from web
docker compose exec web ping api
```
```
ping: api: Name or service not known
```

**Why?** They're on different networks!

### Step 3: Investigate Networks

```bash
# List networks
docker network ls

# Inspect web's networks
docker inspect web --format='{{json .NetworkSettings.Networks}}' | jq '.'

# Inspect api's networks
docker inspect api --format='{{json .NetworkSettings.Networks}}' | jq '.'
```

### Step 4: Fix the Problem

**Solution 1: Connect them on the same network**
```bash
docker network connect webnet api
```

**Test:**
```bash
docker compose exec web ping api
# Should work now!
```

**Solution 2: Use host network (not recommended)**
```bash
# In compose file
services:
  api:
    network_mode: host
```

**Solution 3: Use port mapping and localhost**
```bash
docker compose exec web curl http://host.docker.internal:5000
# Only works on Mac/Windows
```

### Step 5: Verify the Fix

```bash
# Test HTTP connectivity
docker compose exec web curl -s http://api:5000

# Should show HTML from Python's http.server
# Example output:
# <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" ...>
# <title>Directory listing for /</title>
```

---

## P2.10 Summary: Docker Networking Quick Reference

### Network Types Comparison

| Network Type | Isolation | Performance | Use Case |
|--------------|-----------|-------------|----------|
| **Bridge** | Good | Good | Default, single-host apps |
| **Host** | None | Best | Performance-critical, simple apps |
| **None** | Complete | N/A | Security-critical, no networking |
| **Overlay** | Good | Good | Multi-host Swarm/Kubernetes |
| **Macvlan** | Good | Best | Legacy apps needing MAC addresses |

### Common Port Mappings

```bash
# Map port 80 on container to port 8080 on host
-p 8080:80

# Map only to localhost
-p 127.0.0.1:8080:80

# Map UDP port
-p 53:53/udp

# Map multiple ports
-p 8080:80 -p 8443:443

# Map random host port (for testing)
-p 80  # Host port is auto-assigned

# Map range
-p 8080-8085:80-85
```

### Network Debugging Checklist

```bash
# 1. Check container is running
docker ps

# 2. Check network connectivity
docker exec container-name ping google.com

# 3. Check DNS resolution
docker exec container-name nslookup service-name

# 4. Check open ports
docker exec container-name ss -tulpn

# 5. Check port mapping
docker port container-name

# 6. Check network configuration
docker network inspect network-name

# 7. Check firewall (Linux)
sudo iptables -L -n | grep DOCKER

# 8. Check proxy settings
docker exec container-name env | grep -i proxy
```

### Essential Networking Commands

| Command | Purpose |
|---------|---------|
| `docker network ls` | List all networks |
| `docker network inspect` | See detailed network info |
| `docker network create` | Create a network |
| `docker network connect` | Connect container to network |
| `docker port` | Show port mappings |
| `docker exec container ping` | Test connectivity |
| `docker exec container nslookup` | Test DNS resolution |
| `docker exec container curl` | Test HTTP connectivity |
| `docker exec container ss -tulpn` | Check open ports |
| `docker exec container traceroute` | Trace network path (if installed) |
