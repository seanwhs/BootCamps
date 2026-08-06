# Part 4: The Application Layer

## Powering the Internet: DNS, HTTP, Email Protocols, and SNMP

---

## Synopsis

The Application Layer is where users interact with network services. This tutorial explores the protocols that make websites accessible, enable email delivery, and provide centralized infrastructure monitoring.

Readers will trace a complete browser request from DNS lookup to encrypted web communication while also examining how enterprise email systems and network monitoring platforms operate.

By the end of this part, you'll understand how the protocols you use every day actually work under the hood, from resolving domain names to rendering web pages and delivering email.

---

## Prerequisites

Before starting Part 4, ensure you have:
1. **Completed Parts 1-3** or have equivalent knowledge
2. **Wireshark** installed and working
3. **Python 3.8+** with `pip` available
4. **curl**, **dig**, **nslookup**, and **openssl** installed
5. **Root/Administrator privileges** for packet capture

---

## Part 4 Roadmap

```
┌─────────────────────────────────────────────────────────────┐
│                    PART 4: APPLICATION LAYER                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. DNS: Domain Name System                                 │
│     ├─ Hierarchical Namespace                              │
│     ├─ Root Servers, TLD Servers, Authoritative Servers   │
│     ├─ Recursive Resolvers                                 │
│     ├─ DNS Caching                                         │
│     └─ Common Record Types (A, AAAA, CNAME, MX, TXT, NS)  │
│                                                             │
│  2. HTTP: Hypertext Transfer Protocol                       │
│     ├─ HTTP Request Lifecycle                              │
│     ├─ Methods (GET, POST, PUT, DELETE, etc.)             │
│     ├─ Status Codes (1xx-5xx)                              │
│     ├─ Headers, Cookies, Sessions                         │
│     ├─ Caching & Compression                               │
│     ├─ Persistent Connections                              │
│     └─ HTTP/2 Multiplexing                                │
│                                                             │
│  3. Email Protocols                                         │
│     ├─ SMTP: Message Submission & Relay                   │
│     ├─ SMTP Authentication & Mail Queues                  │
│     ├─ POP3: Local Download Model                         │
│     ├─ IMAP: Remote Storage & Synchronization             │
│     └─ Comparing POP3 vs IMAP                             │
│                                                             │
│  4. SNMP: Simple Network Management Protocol                │
│     ├─ SNMP Architecture (Managers, Agents, MIBs)        │
│     ├─ OIDs and MIB Trees                                  │
│     ├─ GET, GETNEXT, GETBULK, SET, TRAP, INFORM          │
│     └─ SNMPv1, v2c, and v3 Security                      │
│                                                             │
│  5. Hands-On Labs                                           │
│     ├─ Lab 1: Capture and Analyze DNS Lookups             │
│     ├─ Lab 2: Inspect HTTP Requests and Responses         │
│     ├─ Lab 3: Build a Simple HTTP Server                 │
│     ├─ Lab 4: Follow SMTP Conversations                   │
│     └─ Lab 5: Query SNMP Devices                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 1: DNS - Domain Name System

### What is DNS?

**DNS (Domain Name System)** is the phonebook of the Internet. It translates human-readable domain names (like `example.com`) into machine-readable IP addresses (like `93.184.216.34`).

**Analogy**: DNS is like your phone's contacts app. You know someone by their name (domain), but to call them you need their phone number (IP address). DNS automatically looks up the number for you.

### The Hierarchical Namespace

DNS is organized as a hierarchical tree structure:

```
                    ┌─────────────┐
                    │   Root (.)  │
                    └─────────────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
      ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
      │  .com   │    │  .org   │    │  .net   │
      └─────────┘    └─────────┘    └─────────┘
           │
      ┌────┴────┐
      │example  │
      └─────────┘
           │
      ┌────┴────┐
      │   www   │
      └─────────┘

Fully Qualified Domain Name (FQDN): www.example.com.
```

**DNS Hierarchy Levels**:

| Level | Example | Purpose |
|-------|---------|---------|
| **Root Zone** | `.` (dot) | The root of the DNS tree, managed by ICANN |
| **Top-Level Domains (TLDs)** | `.com`, `.org`, `.net`, `.uk` | Generic TLDs (gTLDs) and Country Code TLDs (ccTLDs) |
| **Second-Level Domains** | `example.com` | Registered by organizations/individuals |
| **Subdomains** | `www.example.com` | Divisions within a domain |
| **Hostnames** | `mail.example.com` | Specific machines/services |

### DNS Server Types

```
┌─────────────────────────────────────────────────────────────┐
│                    DNS RESOLUTION PATH                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Client (Recursive Resolver)                               │
│     │                                                       │
│     │  1. "What is www.example.com?"                       │
│     ▼                                                       │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Local DNS Resolver (ISP/Corporate)                   ││
│  │  ├─ Checks local cache                                ││
│  │  └─ If not cached, queries root servers              ││
│  └────────────────────────────────────────────────────────┘│
│     │                                                       │
│     │  2. "Where is .com?"                                ││
│     ▼                                                       │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Root Server (13 root servers worldwide)              ││
│  │  └─ "Ask the .com TLD server at X.X.X.X"             ││
│  └────────────────────────────────────────────────────────┘│
│     │                                                       │
│     │  3. "Where is example.com?"                         ││
│     ▼                                                       │
│  ┌────────────────────────────────────────────────────────┐│
│  │  TLD Server (.com)                                    ││
│  │  └─ "Ask the authoritative server for example.com"   ││
│  └────────────────────────────────────────────────────────┘│
│     │                                                       │
│     │  4. "What is www.example.com?"                      ││
│     ▼                                                       │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Authoritative Server (example.com's DNS)             ││
│  │  └─ "www.example.com is 93.184.216.34"               ││
│  └────────────────────────────────────────────────────────┘│
│     │                                                       │
│     │  5. Return IP to client                             ││
│     ▼                                                       │
│  Client receives IP and caches result                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### DNS Record Types

| Record Type | Purpose | Example |
|-------------|---------|---------|
| **A** | IPv4 address | `example.com. IN A 93.184.216.34` |
| **AAAA** | IPv6 address | `example.com. IN AAAA 2606:2800:220:1:248:1893:25c8:1946` |
| **CNAME** | Canonical name (alias) | `www.example.com. IN CNAME example.com.` |
| **MX** | Mail exchange server | `example.com. IN MX 10 mail.example.com.` |
| **TXT** | Text information | `example.com. IN TXT "v=spf1 include:_spf.google.com ~all"` |
| **NS** | Name server | `example.com. IN NS ns1.example.com.` |
| **PTR** | Reverse DNS (IP to name) | `34.216.184.93.in-addr.arpa. IN PTR example.com.` |
| **SOA** | Start of Authority | Zone metadata (serial, refresh, retry, expire, TTL) |
| **SRV** | Service location | `_sip._tcp.example.com. IN SRV 10 5 5060 sip.example.com.` |
| **CAA** | Certificate Authority Authorization | `example.com. IN CAA 0 issue "letsencrypt.org"` |

### DNS Query Types

**Recursive Query**:
- The resolver does all the work and returns the final answer
- Used by clients (stub resolvers) asking their local DNS server

**Iterative Query**:
- The resolver returns the best answer it has (or a referral)
- Used between DNS servers (e.g., root to TLD to authoritative)

**Non-Recursive Query**:
- The resolver returns a cached answer immediately
- Happens when the answer is already in the cache

### DNS Caching

DNS responses are cached to reduce latency and load:

```
┌─────────────────────────────────────────────────────────────┐
│                    DNS CACHING                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  TTL (Time To Live) values control caching duration:       │
│                                                             │
│  Record: example.com. IN A 93.184.216.34                   │
│  TTL: 300 seconds (5 minutes)                              │
│                                                             │
│  Cache Behavior:                                            │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Time 0:  Query → response stored in cache            ││
│  │ Time 100: Query → cache hit (0.1ms response)         ││
│  │ Time 250: Query → cache hit (0.1ms response)         ││
│  │ Time 301: Query → cache expired → new query         ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Cache levels:                                              │
│  ├─ Browser cache                                          │
│  ├─ OS cache                                               │
│  ├─ Local DNS resolver cache                               │
│  └─ ISP/Corporate DNS server cache                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### DNS Security

| Attack | Description | Mitigation |
|--------|-------------|------------|
| **DNS Spoofing** | Forged DNS responses | DNSSEC |
| **DNS Cache Poisoning** | Injecting false records into cache | DNSSEC, random source ports |
| **DNS Amplification** | DDoS using reflected queries | Rate limiting, anycast |
| **DNS Tunneling** | Exfiltrating data via DNS | Traffic analysis, blocking |
| **NXDOMAIN Attacks** | Flood of non-existent domains | Response rate limiting |

---

## Section 2: HTTP - Hypertext Transfer Protocol

### What is HTTP?

**HTTP (Hypertext Transfer Protocol)** is the foundation of data communication on the World Wide Web. It's a request-response protocol where clients (browsers) send requests to servers, and servers respond with content.

**Analogy**: HTTP is like ordering at a restaurant. You (the client) look at the menu (request a resource), the waiter (server) takes your order (receives the request), the kitchen (application) prepares your food (processes the request), and the waiter brings it to you (sends the response).

### HTTP Request Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    HTTP REQUEST LIFECYCLE                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Client (Browser)                    Server                 │
│          │                                │                 │
│  1. User enters URL: https://example.com │                 │
│          │                                │                 │
│  2. DNS Lookup (separate request)       │                 │
│          │                                │                 │
│  3. TCP Connection (port 443 for HTTPS)  │                 │
│          │                                │                 │
│  4. TLS Handshake (for HTTPS)           │                 │
│          │                                │                 │
│  5. HTTP Request:                       │                 │
│     ├─ GET /index.html HTTP/1.1        │                 │
│     ├─ Host: example.com               │                 │
│     └─ User-Agent: Mozilla/5.0        │                 │
│          ├───────────────────────────────►│                 │
│          │                                │                 │
│  6. Server processes request            │                 │
│          │                                │                 │
│  7. HTTP Response:                      │                 │
│     ├─ HTTP/1.1 200 OK                 │                 │
│     ├─ Content-Type: text/html         │                 │
│     ├─ Content-Length: 1256            │                 │
│     └─ <html>...</html>                │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│  8. Browser renders page               │                 │
│          │                                │                 │
│  9. Additional requests (CSS, JS, images)│                 │
│          │                                │                 │
└─────────────────────────────────────────────────────────────┘
```

### HTTP Request Format

An HTTP request consists of:

```
┌─────────────────────────────────────────────────────────────┐
│                    HTTP REQUEST FORMAT                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Request Line:                                              │
│  ┌────────────────────────────────────────────────────────┐│
│  │ METHOD /path HTTP/version                             ││
│  │ GET /index.html HTTP/1.1                              ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Headers:                                                   │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Header-Name: Value                                    ││
│  │ Host: www.example.com                                 ││
│  │ User-Agent: Mozilla/5.0                              ││
│  │ Accept: text/html,application/xhtml+xml              ││
│  │ Accept-Encoding: gzip, deflate                       ││
│  │ Connection: keep-alive                               ││
│  │ Cookie: session_id=12345                             ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Empty Line (CRLF):                                        │
│  ┌────────────────────────────────────────────────────────┐│
│  │ (blank line)                                         ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Body (optional):                                          │
│  ┌────────────────────────────────────────────────────────┐│
│  │ request body data (for POST, PUT, etc.)              ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| **GET** | Retrieve a resource | ✓ | ✓ |
| **HEAD** | Retrieve headers only | ✓ | ✓ |
| **POST** | Submit data to be processed | ✗ | ✗ |
| **PUT** | Replace a resource | ✓ | ✗ |
| **DELETE** | Remove a resource | ✓ | ✗ |
| **PATCH** | Partial resource update | ✗ | ✗ |
| **OPTIONS** | Check supported methods | ✓ | ✓ |
| **TRACE** | Echo the request (debugging) | ✓ | ✓ |
| **CONNECT** | Establish a tunnel (proxies) | ✗ | ✗ |

**Idempotent**: Multiple identical requests have the same effect as one request.
**Safe**: The request doesn't modify server state.

### HTTP Status Codes

**1xx: Informational**
- `100 Continue`: Client should continue the request
- `101 Switching Protocols`: Server is switching protocols

**2xx: Success**
- `200 OK`: Standard success response
- `201 Created`: Resource created successfully
- `202 Accepted`: Request accepted but not yet processed
- `204 No Content`: Request successful, no content to return

**3xx: Redirection**
- `301 Moved Permanently`: Resource has a new permanent URL
- `302 Found`: Resource temporarily at a different URL
- `304 Not Modified`: Resource not modified since last request

**4xx: Client Errors**
- `400 Bad Request`: Malformed request
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `405 Method Not Allowed`: HTTP method not supported
- `408 Request Timeout`: Server timeout waiting for request
- `429 Too Many Requests`: Rate limiting

**5xx: Server Errors**
- `500 Internal Server Error`: Generic server error
- `501 Not Implemented`: Method not supported
- `502 Bad Gateway`: Invalid response from upstream
- `503 Service Unavailable`: Server overloaded or down
- `504 Gateway Timeout`: Upstream server timeout

### HTTP Headers

**Request Headers**:
```
Host: www.example.com                    # Virtual hosting
User-Agent: Mozilla/5.0                  # Client identification
Accept: text/html,application/xhtml+xml  # Accepted content types
Accept-Encoding: gzip, deflate           # Compression support
Accept-Language: en-US,en                # Language preferences
Cookie: session=abc123                   # Session data
Authorization: Bearer token              # Authentication
Referer: https://google.com              # Previous page
```

**Response Headers**:
```
Content-Type: text/html; charset=utf-8   # Content format
Content-Length: 1256                     # Content size
Cache-Control: max-age=3600              # Caching directives
Last-Modified: Mon, 01 Jan 2024 12:00:00 GMT  # Modification time
ETag: "33a64df5"                         # Entity tag for caching
Set-Cookie: session=abc123               # Cookie to set
Location: https://newurl.com             # Redirect destination
Access-Control-Allow-Origin: *           # CORS policy
```

### Cookies and Sessions

```
┌─────────────────────────────────────────────────────────────┐
│                    COOKIES AND SESSIONS                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Server sends Set-Cookie:                                   │
│  ┌────────────────────────────────────────────────────────┐│
│  │ HTTP/1.1 200 OK                                      ││
│  │ Set-Cookie: session_id=abc123; Path=/; HttpOnly     ││
│  │ Set-Cookie: theme=dark; Path=/; Max-Age=31536000   ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Browser stores cookies                                     │
│                                                             │
│  Client sends Cookie:                                       │
│  ┌────────────────────────────────────────────────────────┐│
│  │ GET /dashboard HTTP/1.1                              ││
│  │ Host: example.com                                    ││
│  │ Cookie: session_id=abc123; theme=dark               ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Cookie Attributes:                                         │
│  ├─ Path: URL path where cookie applies                   │
│  ├─ Domain: Domain where cookie applies                   │
│  ├─ Max-Age/Expires: Cookie lifetime                      │
│  ├─ Secure: Only send over HTTPS                         │
│  ├─ HttpOnly: Not accessible via JavaScript               │
│  └─ SameSite: CSRF protection (Strict/Lax/None)          │
│                                                             │
│  Session vs Cookie:                                         │
│  ├─ Cookies stored on client                              │
│  ├─ Session data stored on server                         │
│  └─ Session ID stored in cookie to link server data      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### HTTP Caching

```
┌─────────────────────────────────────────────────────────────┐
│                    HTTP CACHING STRATEGIES                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Cache-Control Headers:                                     │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Cache-Control: max-age=3600                          ││
│  │ Cache-Control: no-cache                              ││
│  │ Cache-Control: no-store                              ││
│  │ Cache-Control: public                                ││
│  │ Cache-Control: private                               ││
│  │ Cache-Control: must-revalidate                       ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Cache Validation:                                          │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Client: GET /script.js                                ││
│  │ Headers: If-Modified-Since: Mon, 01 Jan 2024 12:00  ││
│  │                                                       ││
│  │ Server: If not modified:                             ││
│  │   304 Not Modified                                    ││
│  │                                                       ││
│  │ Server: If modified:                                  ││
│  │   200 OK with new content                            ││
│  │   ETag: "33a64df5"                                   ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Cache Locations:                                           │
│  ├─ Browser cache                                          │
│  ├─ Proxy cache (ISP/CDN)                                 │
│  └─ Server cache (reverse proxy)                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### HTTP/2 Multiplexing

```
┌─────────────────────────────────────────────────────────────┐
│                    HTTP/2 MULTIPLEXING                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  HTTP/1.1 (One request at a time per connection):          │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Request 1 ──────────────────────────────► Response 1 ││
│  │ Request 2 ──────────────────────────────► Response 2 ││
│  │ Request 3 ──────────────────────────────► Response 3 ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  HTTP/2 (Multiple requests in parallel):                   │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Request 1 ──┐                                        ││
│  │ Request 2 ──┼──►[Single TCP Connection]──► Responses ││
│  │ Request 3 ──┘                                        ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Features:                                                  │
│  ├─ Binary protocol (not text)                             │
│  ├─ Multiplexed streams                                    │
│  ├─ Server push                                            │
│  ├─ Header compression (HPACK)                            │
│  └─ Prioritization of streams                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 3: Email Protocols

### Email System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    EMAIL SYSTEM ARCHITECTURE                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Sender's Side:                                             │
│  ┌──────────┐  SMTP  ┌──────────┐   SMTP   ┌──────────┐  │
│  │ User     │───────►│  MSA     │─────────►│  MTA     │  │
│  │ Client   │        │ (Mail    │          │ (Mail    │  │
│  │ (MUA)    │        │ Submission│          │ Transfer │  │
│  │          │        │ Agent)   │          │ Agent)   │  │
│  └──────────┘        └──────────┘          └──────────┘  │
│                                                    │       │
│                                                    │ SMTP  │
│                                                    ▼       │
│  Recipient's Side:                               ┌──────────┐│
│  ┌──────────┐  SMTP  ┌──────────┐   POP/IMAP  │  MDA     ││
│  │ User     │◄───────│  MDA     │◄────────────│  (Mail   ││
│  │ Client   │        │  (Mail   │              │Delivery  ││
│  │ (MUA)    │        │ Delivery │              │Agent)    ││
│  └──────────┘        │  Agent)  │              └──────────┘│
│                      └──────────┘                          │
│                                                             │
│  Components:                                                │
│  ├─ MUA: Mail User Agent (client: Outlook, Thunderbird)   │
│  ├─ MSA: Mail Submission Agent (port 587, authenticated)  │
│  ├─ MTA: Mail Transfer Agent (port 25, routing between servers)│
│  └─ MDA: Mail Delivery Agent (stores in mailbox)         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### SMTP - Simple Mail Transfer Protocol

SMTP is used for sending and relaying email between servers.

**SMTP Commands**:

```
┌─────────────────────────────────────────────────────────────┐
│                    SMTP CONVERSATION                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Client (sender)              Server (recipient)            │
│          │                                │                 │
│          │  HELO mail.example.com        │                 │
│          ├───────────────────────────────►│                 │
│          │  250 mail.example.com Hello   │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  MAIL FROM:<alice@example.com>│                 │
│          ├───────────────────────────────►│                 │
│          │  250 Sender OK                │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  RCPT TO:<bob@example.org>    │                 │
│          ├───────────────────────────────►│                 │
│          │  250 Recipient OK             │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  DATA                          │                 │
│          ├───────────────────────────────►│                 │
│          │  354 Send message; end with . │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  Subject: Hello Bob           │                 │
│          │  From: Alice <alice@example.com>│               │
│          │  To: Bob <bob@example.org>   │                 │
│          │                                │                 │
│          │  Hi Bob,                      │                 │
│          │  How are you?                  │                 │
│          │  .                            │                 │
│          ├───────────────────────────────►│                 │
│          │  250 OK                       │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  QUIT                          │                 │
│          ├───────────────────────────────►│                 │
│          │  221 Bye                      │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
└─────────────────────────────────────────────────────────────┘
```

**SMTP Response Codes**:

| Code | Meaning | Category |
|------|---------|----------|
| 211 | System status | Informational |
| 214 | Help message | Informational |
| 220 | Service ready | Success |
| 221 | Service closing | Success |
| 250 | Requested action taken | Success |
| 251 | User not local; will forward | Success |
| 354 | Start mail input | Intermediate |
| 421 | Service not available | Transient failure |
| 450 | Mailbox busy | Transient failure |
| 451 | Local error | Transient failure |
| 452 | Insufficient storage | Transient failure |
| 500 | Syntax error | Permanent failure |
| 501 | Syntax error in parameters | Permanent failure |
| 502 | Command not implemented | Permanent failure |
| 503 | Bad command sequence | Permanent failure |
| 550 | Mailbox unavailable | Permanent failure |
| 551 | User not local | Permanent failure |
| 552 | Storage quota exceeded | Permanent failure |
| 553 | Mailbox name not allowed | Permanent failure |

### POP3 - Post Office Protocol version 3

POP3 is used for downloading email from a server to a client, typically deleting it from the server.

```
┌─────────────────────────────────────────────────────────────┐
│                    POP3 CONVERSATION                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Client                            Server                   │
│          │                                │                 │
│          │  +OK POP3 server ready        │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  USER bob                      │                 │
│          ├───────────────────────────────►│                 │
│          │  +OK User accepted            │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  PASS password123              │                 │
│          ├───────────────────────────────►│                 │
│          │  +OK Mailbox locked           │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  STAT                          │                 │
│          ├───────────────────────────────►│                 │
│          │  +OK 2 2048                   │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  LIST                          │                 │
│          ├───────────────────────────────►│                 │
│          │  +OK 2 messages               │                 │
│          │  1 1024                       │                 │
│          │  2 1024                       │                 │
│          │  .                            │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  RETR 1                        │                 │
│          ├───────────────────────────────►│                 │
│          │  +OK 1024 bytes               │                 │
│          │  (message content)            │                 │
│          │  .                            │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  DELE 1                        │                 │
│          ├───────────────────────────────►│                 │
│          │  +OK Message deleted          │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
│          │  QUIT                          │                 │
│          ├───────────────────────────────►│                 │
│          │  +OK Goodbye                  │                 │
│          │◄───────────────────────────────┤                 │
│          │                                │                 │
└─────────────────────────────────────────────────────────────┘
```

**POP3 Features**:
- Download-and-delete model (traditional)
- Messages stored on server until downloaded
- Typically uses port 110 (plain) or 995 (TLS)
- Simple, stateful protocol
- Limited folder support

### IMAP - Internet Message Access Protocol

IMAP provides more advanced features for managing email on the server.

```
┌─────────────────────────────────────────────────────────────┐
│                    IMAP FEATURES                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Server-Side Folders                                 ││
│  │  ├─ INBOX                                            ││
│  │  ├─ Sent                                             ││
│  │  ├─ Drafts                                           ││
│  │  └─ Archive                                          ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Features:                                                  │
│  ├─ Messages stored on server permanently                 │
│  ├─ Multiple folders/folders                              │
│  ├─ Server-side search                                    │
│  ├─ Message flags (seen, answered, deleted, flagged)      │
│  ├─ Partial downloads (only headers first)               │
│  ├─ Multiple device synchronization                       │
│  └─ Concurrent access                                     │
│                                                             │
│  IMAP States:                                               │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Non-authenticated: Initial connection               ││
│  │  Authenticated: Login successful                     ││
│  │  Selected: A mailbox is selected                     ││
│  │  Logout: Disconnected                                ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  IMAP vs POP3:                                              │
│  ┌────────────────────────────────────────────────────────┐│
│  │ Feature            POP3           IMAP                ││
│  ├────────────────────────────────────────────────────────┤│
│  │ Storage            Local          Server              ││
│  │ Folders            Not supported  Supported           ││
│  │ Multi-device       Limited        Full sync           ││
│  │ Server-side search Not supported  Supported           ││
│  │ Bandwidth          Full messages  Partial possible    ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 4: SNMP - Simple Network Management Protocol

### SNMP Architecture

SNMP is used for monitoring and managing network devices.

```
┌─────────────────────────────────────────────────────────────┐
│                    SNMP ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Network Management System (NMS)                     ││
│  │  ├─ SNMP Manager                                     ││
│  │  └─ Monitoring dashboard                             ││
│  └────────────────────────────────────────────────────────┘│
│     │          │          │                                │
│     │ SNMP     │ SNMP     │ SNMP                          │
│     ▼          ▼          ▼                                │
│  ┌────────┐ ┌────────┐ ┌────────┐                        │
│  │Router  │ │Switch  │ │Server  │                        │
│  │(Agent) │ │(Agent) │ │(Agent) │                        │
│  └────────┘ └────────┘ └────────┘                        │
│                                                             │
│  Components:                                                │
│  ├─ SNMP Manager: Central monitoring system               │
│  ├─ SNMP Agent: Software on managed devices              │
│  ├─ MIB: Management Information Base (data dictionary)   │
│  └─ OID: Object Identifier (unique data point)           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### MIBs and OIDs

```
┌─────────────────────────────────────────────────────────────┐
│                    MIB TREE STRUCTURE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  .iso (1)                                                   │
│     │                                                       │
│     └── .org (3)                                           │
│          │                                                  │
│          └── .dod (6)                                      │
│               │                                             │
│               └── .internet (1)                            │
│                    │                                        │
│                    ├── .private (4)                        │
│                    │    │                                   │
│                    │    └── .enterprises (1)               │
│                    │         │                              │
│                    │         └── .cisco (9)                │
│                    │              │                         │
│                    │              └── ....                 │
│                    │                                        │
│                    └── .mib-2 (1)                          │
│                         │                                   │
│                         ├── .system (1)                    │
│                         │    ├── .sysDescr (1)            │
│                         │    ├── .sysObjectID (2)         │
│                         │    └── .sysUpTime (3)           │
│                         │                                   │
│                         ├── .interfaces (2)                │
│                         │    ├── .ifNumber (1)            │
│                         │    └── .ifTable (2)             │
│                         │                                   │
│                         └── .ip (4)                        │
│                              ├── .ipForwarding (1)         │
│                              └── .ipDefaultTTL (2)         │
│                                                             │
│  OID for system description: .1.3.6.1.2.1.1.1.0           │
│  OID for interface count: .1.3.6.1.2.1.2.1.0              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### SNMP Operations

| Operation | Direction | Purpose |
|-----------|-----------|---------|
| **GET** | Manager → Agent | Retrieve a specific OID value |
| **GETNEXT** | Manager → Agent | Retrieve the next OID in the tree |
| **GETBULK** | Manager → Agent | Retrieve many OIDs efficiently (SNMPv2+) |
| **SET** | Manager → Agent | Change a value on the device |
| **TRAP** | Agent → Manager | Unsolicited event notification |
| **INFORM** | Agent → Manager | Acknowledged trap (SNMPv2+) |

### SNMP Versions

| Version | Security | Authentication | Privacy |
|---------|----------|---------------|---------|
| **SNMPv1** | Minimal | Community strings (plaintext) | None |
| **SNMPv2c** | Minimal | Community strings (plaintext) | None |
| **SNMPv3** | Strong | Auth (MD5/SHA) | Encryption (DES/AES) |

**Community Strings** (v1/v2c):
- **Public**: Read-only access (default)
- **Private**: Read-write access (default)
- Should be changed from defaults for security

**SNMPv3 Security Models**:
- **noAuthNoPriv**: No authentication or encryption
- **authNoPriv**: Authentication only (MD5/SHA)
- **authPriv**: Authentication and encryption (DES/AES)

---

## Section 5: Hands-On Labs

---

### Lab 1: Capture and Analyze DNS Lookups

**The Target**: Capture a complete DNS resolution process.

**The Implementation**:

1. **Start capturing DNS traffic**:
   ```bash
   sudo tcpdump -i eth0 "udp port 53" -vv -w dns_lookup.pcap
   ```

2. **Perform DNS lookups**:
   ```bash
   # Query with dig
   dig example.com
   
   # Query with nslookup
   nslookup google.com
   
   # Query specific record types
   dig example.com A
   dig example.com AAAA
   dig example.com MX
   dig example.com TXT
   
   # Trace the query path
   dig +trace example.com
   ```

3. **Analyze the capture**:
   ```bash
   # Show all DNS packets
   tshark -r dns_lookup.pcap -Y "dns"
   
   # Show query types
   tshark -r dns_lookup.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name -e dns.qry.type
   
   # Show responses
   tshark -r dns_lookup.pcap -Y "dns.flags.response == 1" -T fields -e dns.resp.name -e dns.a
   
   # Show DNS query times
   tshark -r dns_lookup.pcap -T fields -e frame.time_relative -e dns.qry.name
   ```

**The Verification**:

Run this DNS analyzer:

```python
#!/usr/bin/env python3
"""
dns_analyzer.py - Analyze DNS packets from pcap
"""

import sys
from scapy.all import rdpcap, DNS, IP, UDP

def analyze_dns(filename):
    """Analyze DNS traffic"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    dns_packets = [p for p in packets if DNS in p]
    
    if not dns_packets:
        print("No DNS packets found")
        return
    
    print(f"Found {len(dns_packets)} DNS packets\n")
    print("=" * 80)
    print(f"{'#':<4} {'Time':<12} {'Type':<12} {'Name':<30} {'Response':<20}")
    print("=" * 80)
    
    query_types = {
        1: 'A', 2: 'NS', 5: 'CNAME', 6: 'SOA',
        12: 'PTR', 15: 'MX', 16: 'TXT', 28: 'AAAA',
        33: 'SRV', 255: 'ANY'
    }
    
    for i, packet in enumerate(dns_packets[:20], 1):
        dns = packet[DNS]
        ip = packet[IP]
        
        if dns.qr == 0:  # Query
            qtype = dns.qd.qtype if dns.qd else 0
            qname = dns.qd.qname.decode() if dns.qd else 'Unknown'
            qtype_name = query_types.get(qtype, f'Type{qtype}')
            
            print(f"{i:<4} {packet.time:<12.6f} {'Query':<12} {qname:<30} {qtype_name:<20}")
            
        elif dns.qr == 1:  # Response
            # Get answer
            answer = ''
            if dns.an:
                for an in dns.an:
                    if an.type in [1, 28]:  # A or AAAA
                        answer = an.rdata
                    elif an.type == 15:  # MX
                        answer = f"{an.rdata.exchange} (pref {an.rdata.preference})"
                    elif an.type == 16:  # TXT
                        answer = an.rdata
                    else:
                        answer = str(an.rdata)
                    break
            
            print(f"{i:<4} {packet.time:<12.6f} {'Response':<12} "
                  f"{dns.qd.qname.decode() if dns.qd else '':<30} {str(answer):<20}")
    
    print("=" * 80)
    
    # DNS statistics
    queries = sum(1 for p in dns_packets if p[DNS].qr == 0)
    responses = sum(1 for p in dns_packets if p[DNS].qr == 1)
    
    print(f"\nDNS Statistics:")
    print(f"  Queries: {queries}")
    print(f"  Responses: {responses}")
    print(f"  Total: {len(dns_packets)}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    analyze_dns(sys.argv[1])
```

---

### Lab 2: Inspect HTTP Requests and Responses

**The Target**: Capture and analyze HTTP traffic.

**The Implementation**:

1. **Start capturing HTTP traffic**:
   ```bash
   sudo tcpdump -i eth0 "tcp port 80" -vv -w http_traffic.pcap
   ```

2. **Generate HTTP traffic**:
   ```bash
   # Simple GET request
   curl -I http://example.com
   
   # Full page request
   curl -v http://example.com
   
   # With custom headers
   curl -H "User-Agent: CustomClient" -H "X-Test: Hello" http://example.com
   ```

3. **Analyze the capture**:
   ```bash
   # Show HTTP requests
   tshark -r http_traffic.pcap -Y "http.request" -T fields -e http.request.method -e http.request.uri -e http.host
   
   # Show HTTP responses
   tshark -r http_traffic.pcap -Y "http.response" -T fields -e http.response.code -e http.content_type
   
   # Follow TCP stream
   tshark -r http_traffic.pcap -z follow,tcp,hex,0
   ```

**The Verification**:

Run this HTTP analyzer:

```python
#!/usr/bin/env python3
"""
http_analyzer.py - Analyze HTTP traffic from pcap
"""

import sys
from scapy.all import rdpcap, IP, TCP, Raw

def analyze_http(filename):
    """Analyze HTTP traffic"""
    try:
        packets = rdpcap(filename)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    
    print(f"Analyzing {len(packets)} packets...\n")
    
    http_requests = []
    http_responses = []
    
    for packet in packets:
        if TCP in packet and Raw in packet:
            tcp = packet[TCP]
            payload = packet[Raw].load
            
            # Check for HTTP
            if b'HTTP' in payload or b'GET ' in payload or b'POST ' in payload:
                try:
                    lines = payload.split(b'\r\n')
                    first_line = lines[0].decode('utf-8', errors='ignore')
                    
                    # Request
                    if first_line.startswith(('GET ', 'POST ', 'PUT ', 'DELETE ', 'HEAD ')):
                        method, path, version = first_line.split(' ')
                        http_requests.append({
                            'method': method,
                            'path': path,
                            'version': version,
                            'src': packet[IP].src,
                            'dst': packet[IP].dst
                        })
                    
                    # Response
                    if first_line.startswith(('HTTP/')):
                        version, code, msg = first_line.split(' ', 2)
                        http_responses.append({
                            'code': code,
                            'msg': msg,
                            'src': packet[IP].src,
                            'dst': packet[IP].dst
                        })
                except:
                    continue
    
    print("=" * 80)
    print(f"HTTP Requests: {len(http_requests)}")
    print("=" * 80)
    
    for req in http_requests[:10]:
        print(f"  {req['method']} {req['path']} {req['version']}")
        print(f"    {req['src']} -> {req['dst']}")
    
    print("\n" + "=" * 80)
    print(f"HTTP Responses: {len(http_responses)}")
    print("=" * 80)
    
    for resp in http_responses[:10]:
        print(f"  {resp['code']} {resp['msg']}")
        print(f"    {resp['src']} -> {resp['dst']}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    analyze_http(sys.argv[1])
```

---

### Lab 3: Build a Simple HTTP Server

**The Target**: Build a minimal HTTP server in Python.

**The Implementation**:

Create a file called `http_server.py`:

```python
#!/usr/bin/env python3
"""
http_server.py - Simple HTTP server with routing
"""

import socket
import sys
import os
import threading
import mimetypes
from datetime import datetime
from typing import Dict, Tuple, Optional

class HTTPServer:
    """Simple HTTP server implementation"""
    
    def __init__(self, host: str = '', port: int = 8080, root_dir: str = '.'):
        self.host = host
        self.port = port
        self.root_dir = root_dir
        self.server_socket = None
        self.running = False
        
        # Status code messages
        self.status_messages = {
            200: 'OK',
            301: 'Moved Permanently',
            302: 'Found',
            400: 'Bad Request',
            403: 'Forbidden',
            404: 'Not Found',
            405: 'Method Not Allowed',
            500: 'Internal Server Error',
        }
        
        # Routes (path -> handler function)
        self.routes = {}
        
    def route(self, path: str):
        """Decorator to register route handlers"""
        def decorator(handler):
            self.routes[path] = handler
            return handler
        return decorator
    
    def start(self):
        """Start the HTTP server"""
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(10)
            self.running = True
            
            print(f"[*] HTTP Server started on http://{self.host or 'localhost'}:{self.port}")
            print(f"[*] Serving files from: {os.path.abspath(self.root_dir)}")
            print("[*] Press Ctrl+C to stop\n")
            
            while self.running:
                try:
                    client_socket, address = self.server_socket.accept()
                    client_thread = threading.Thread(
                        target=self.handle_client,
                        args=(client_socket, address),
                        daemon=True
                    )
                    client_thread.start()
                except socket.error:
                    if self.running:
                        continue
                    
        except Exception as e:
            print(f"[!] Server error: {e}")
        finally:
            self.shutdown()
    
    def handle_client(self, client_socket: socket.socket, address: tuple):
        """Handle a client connection"""
        try:
            # Receive request
            data = client_socket.recv(8192)
            if not data:
                return
            
            # Parse request
            request = self.parse_request(data)
            if not request:
                self.send_error(client_socket, 400)
                return
            
            # Log request
            timestamp = datetime.now().isoformat()
            print(f"[{timestamp}] {address[0]}:{address[1]} "
                  f"{request['method']} {request['path']} {request['version']}")
            
            # Process request
            if request['path'] in self.routes:
                # Route handler
                handler = self.routes[request['path']]
                response = handler(request)
                self.send_response(client_socket, response)
            else:
                # Static file serving
                self.serve_file(client_socket, request)
                
        except Exception as e:
            print(f"[!] Error: {e}")
            self.send_error(client_socket, 500)
        finally:
            client_socket.close()
    
    def parse_request(self, data: bytes) -> Optional[Dict]:
        """Parse HTTP request"""
        try:
            lines = data.split(b'\r\n')
            
            # Parse request line
            parts = lines[0].decode('utf-8').split(' ')
            if len(parts) != 3:
                return None
            
            method, path, version = parts
            
            # Parse headers
            headers = {}
            i = 1
            while i < len(lines) and lines[i]:
                line = lines[i].decode('utf-8')
                if ': ' in line:
                    key, value = line.split(': ', 1)
                    headers[key] = value
                i += 1
            
            # Body (after headers)
            body = b''
            if i + 1 < len(lines) and lines[i] == b'' and i + 1 < len(lines):
                body = b'\r\n'.join(lines[i+1:])
            
            return {
                'method': method,
                'path': path,
                'version': version,
                'headers': headers,
                'body': body
            }
            
        except Exception:
            return None
    
    def serve_file(self, client_socket: socket.socket, request: Dict):
        """Serve a static file"""
        path = request['path']
        
        # Security: Prevent directory traversal
        path = path.lstrip('/')
        if '..' in path or path.startswith('/'):
            self.send_error(client_socket, 403)
            return
        
        # Default to index.html for directories
        if not path:
            path = 'index.html'
        
        file_path = os.path.join(self.root_dir, path)
        
        # Check if file exists
        if not os.path.exists(file_path) or os.path.isdir(file_path):
            self.send_error(client_socket, 404)
            return
        
        # Read file
        try:
            with open(file_path, 'rb') as f:
                content = f.read()
                
            # Determine content type
            content_type = mimetypes.guess_type(file_path)[0] or 'application/octet-stream'
            
            # Build response
            response = {
                'status': 200,
                'headers': {
                    'Content-Type': content_type,
                    'Content-Length': str(len(content)),
                    'Server': 'SimpleHTTPServer/1.0',
                    'Date': datetime.now().strftime('%a, %d %b %Y %H:%M:%S GMT'),
                },
                'body': content
            }
            
            self.send_response(client_socket, response)
            
        except Exception as e:
            print(f"[!] Error reading file: {e}")
            self.send_error(client_socket, 500)
    
    def send_response(self, client_socket: socket.socket, response: Dict):
        """Send an HTTP response"""
        status = response.get('status', 200)
        status_msg = self.status_messages.get(status, 'Unknown')
        headers = response.get('headers', {})
        body = response.get('body', b'')
        
        # Build status line
        status_line = f"HTTP/1.1 {status} {status_msg}\r\n"
        
        # Build headers
        header_lines = []
        for key, value in headers.items():
            header_lines.append(f"{key}: {value}")
        
        # Add Content-Length if not present
        if 'Content-Length' not in headers and body:
            header_lines.append(f"Content-Length: {len(body)}")
        
        headers_str = '\r\n'.join(header_lines)
        
        # Send response
        response_str = status_line + headers_str + '\r\n\r\n'
        client_socket.send(response_str.encode('utf-8'))
        
        if body:
            client_socket.send(body)
    
    def send_error(self, client_socket: socket.socket, code: int, message: str = None):
        """Send an error response"""
        status_msg = self.status_messages.get(code, 'Error')
        if not message:
            message = status_msg
        
        html = f"""
        <!DOCTYPE html>
        <html>
        <head><title>{code} {status_msg}</title></head>
        <body>
            <h1>{code} {status_msg}</h1>
            <p>{message}</p>
            <hr>
            <p>SimpleHTTPServer/1.0</p>
        </body>
        </html>
        """
        
        response = {
            'status': code,
            'headers': {
                'Content-Type': 'text/html',
                'Content-Length': str(len(html)),
                'Server': 'SimpleHTTPServer/1.0',
            },
            'body': html.encode('utf-8')
        }
        
        self.send_response(client_socket, response)
    
    def shutdown(self):
        """Shut down the server"""
        self.running = False
        if self.server_socket:
            self.server_socket.close()
        print("[*] Server shutdown complete")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Simple HTTP Server")
    parser.add_argument('-p', '--port', type=int, default=8080, help='Port to listen on')
    parser.add_argument('-d', '--directory', default='.', help='Root directory')
    parser.add_argument('--host', default='', help='Host to bind to')
    
    args = parser.parse_args()
    
    server = HTTPServer(host=args.host, port=args.port, root_dir=args.directory)
    
    # Example route handler
    @server.route('/api/hello')
    def hello_handler(request):
        """API endpoint example"""
        return {
            'status': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': b'{"message": "Hello, World!", "time": "' + 
                    datetime.now().isoformat().encode('utf-8') + b'"}'
        }
    
    @server.route('/api/echo')
    def echo_handler(request):
        """Echo endpoint"""
        body = request['body'] or b'{}'
        return {
            'status': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': b'{"echo": ' + body + b'}'
        }
    
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Shutting down...")
        server.shutdown()

if __name__ == "__main__":
    main()
```

**Test the server**:
```bash
# Start the server
./http_server.py -p 8080

# In another terminal, test with curl
curl http://localhost:8080/api/hello
curl -X POST -d '{"test": "data"}' http://localhost:8080/api/echo
curl http://localhost:8080/
curl -I http://localhost:8080/
```

---

### Lab 4: Follow SMTP Conversations

**The Target**: Capture and analyze SMTP email submission.

**The Implementation**:

1. **Start capturing SMTP traffic**:
   ```bash
   sudo tcpdump -i eth0 "tcp port 25 or tcp port 587" -vv -w smtp_traffic.pcap
   ```

2. **Send a test email** (using a local SMTP server or telnet):
   ```bash
   # Connect to a public SMTP server (example only - use a test server)
   telnet smtp.example.com 25
   
   # Or use Python
   python3 -c "
   import smtplib
   server = smtplib.SMTP('smtp.gmail.com', 587)
   server.starttls()
   print('Connected')
   "
   ```

3. **Analyze the capture**:
   ```bash
   # Show SMTP commands
   tshark -r smtp_traffic.pcap -Y "smtp" -T fields -e smtp.req.command -e smtp.req.parameter
   
   # Show SMTP responses
   tshark -r smtp_traffic.pcap -Y "smtp.response" -T fields -e smtp.resp.code -e smtp.resp.parameter
   
   # Show complete conversation
   tshark -r smtp_traffic.pcap -z follow,tcp,hex,0
   ```

---

### Lab 5: Query SNMP Devices

**The Target**: Query network devices using SNMP.

**The Implementation**:

1. **Install SNMP tools**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install snmp snmp-mibs-downloader
   
   # macOS
   brew install snmp
   ```

2. **Query the local system**:
   ```bash
   # Get system description
   snmpget -v 2c -c public localhost .1.3.6.1.2.1.1.1.0
   
   # Get system uptime
   snmpget -v 2c -c public localhost .1.3.6.1.2.1.1.3.0
   
   # Get interface list
   snmpwalk -v 2c -c public localhost .1.3.6.1.2.1.2.2.1.2
   ```

3. **Create an SNMP query tool**:

```python
#!/usr/bin/env python3
"""
snmp_query.py - Simple SNMP query tool
"""

import sys
from pysnmp.hlapi import *
import argparse

def snmp_get(host, community, oid, version='2c'):
    """Perform SNMP GET operation"""
    error_indication, error_status, error_index, var_binds = next(
        getCmd(
            SnmpEngine(),
            CommunityData(community),
            UdpTransportTarget((host, 161)),
            ContextData(),
            ObjectType(ObjectIdentity(oid))
        )
    )
    
    if error_indication:
        print(f"Error: {error_indication}")
        return None
    elif error_status:
        print(f"Error: {error_status.prettyPrint()} at {error_index}")
        return None
    else:
        for var_bind in var_binds:
            return var_bind.prettyPrint()

def snmp_walk(host, community, oid, version='2c'):
    """Perform SNMP WALK operation"""
    results = []
    
    for (error_indication, error_status, error_index, var_binds) in nextCmd(
        SnmpEngine(),
        CommunityData(community),
        UdpTransportTarget((host, 161)),
        ContextData(),
        ObjectType(ObjectIdentity(oid)),
        lexicographicMode=False
    ):
        if error_indication:
            print(f"Error: {error_indication}")
            break
        elif error_status:
            print(f"Error: {error_status.prettyPrint()} at {error_index}")
            break
        else:
            for var_bind in var_binds:
                results.append(var_bind.prettyPrint())
    
    return results

def main():
    parser = argparse.ArgumentParser(description="SNMP Query Tool")
    parser.add_argument('-H', '--host', default='localhost', help='SNMP agent host')
    parser.add_argument('-c', '--community', default='public', help='Community string')
    parser.add_argument('-o', '--oid', default='.1.3.6.1.2.1.1.1.0', help='OID to query')
    parser.add_argument('-w', '--walk', action='store_true', help='Perform SNMP walk')
    
    args = parser.parse_args()
    
    print(f"Querying {args.host} with community '{args.community}'")
    print(f"OID: {args.oid}\n")
    
    if args.walk:
        results = snmp_walk(args.host, args.community, args.oid)
        if results:
            for result in results:
                print(result)
    else:
        result = snmp_get(args.host, args.community, args.oid)
        if result:
            print(result)

if __name__ == "__main__":
    main()
```

---

## Section 6: Reference: Complete DNS, HTTP, and SMTP Reference

### DNS Record Types (Complete)

| Type | Code | Purpose | Example |
|------|------|---------|---------|
| A | 1 | IPv4 address | `93.184.216.34` |
| NS | 2 | Name server | `ns1.example.com` |
| CNAME | 5 | Canonical name | `www.example.com` → `example.com` |
| SOA | 6 | Start of Authority | Zone metadata |
| PTR | 12 | Pointer (reverse DNS) | `34.216.184.93.in-addr.arpa` → `example.com` |
| MX | 15 | Mail exchange | `mail.example.com` (priority 10) |
| TXT | 16 | Text information | `"v=spf1 include:_spf.google.com ~all"` |
| AAAA | 28 | IPv6 address | `2606:2800:220:1:248:1893:25c8:1946` |
| SRV | 33 | Service location | `_sip._tcp.example.com` → `sip.example.com:5060` |
| CAA | 257 | Certificate Authority Authorization | `0 issue "letsencrypt.org"` |

### HTTP Status Codes (Complete)

| Code | Category | Meaning |
|------|----------|---------|
| 100 | Informational | Continue |
| 101 | Informational | Switching Protocols |
| 102 | Informational | Processing |
| 200 | Success | OK |
| 201 | Success | Created |
| 202 | Success | Accepted |
| 204 | Success | No Content |
| 301 | Redirection | Moved Permanently |
| 302 | Redirection | Found |
| 304 | Redirection | Not Modified |
| 307 | Redirection | Temporary Redirect |
| 308 | Redirection | Permanent Redirect |
| 400 | Client Error | Bad Request |
| 401 | Client Error | Unauthorized |
| 403 | Client Error | Forbidden |
| 404 | Client Error | Not Found |
| 405 | Client Error | Method Not Allowed |
| 408 | Client Error | Request Timeout |
| 410 | Client Error | Gone |
| 429 | Client Error | Too Many Requests |
| 500 | Server Error | Internal Server Error |
| 501 | Server Error | Not Implemented |
| 502 | Server Error | Bad Gateway |
| 503 | Server Error | Service Unavailable |
| 504 | Server Error | Gateway Timeout |

### Common HTTP Headers

| Header | Direction | Purpose |
|--------|-----------|---------|
| Host | Request | Virtual hosting |
| User-Agent | Request | Client identification |
| Accept | Request | Accepted content types |
| Accept-Encoding | Request | Compression support |
| Accept-Language | Request | Language preferences |
| Authorization | Request | Authentication |
| Cookie | Request | Session data |
| Cache-Control | Both | Caching directives |
| Content-Type | Both | Content format |
| Content-Length | Both | Content size |
| Location | Response | Redirect destination |
| Set-Cookie | Response | Cookie to set |
| ETag | Response | Entity tag for caching |
| Last-Modified | Response | Modification time |

### SMTP Response Codes (Complete)

| Code | Meaning |
|------|---------|
| 211 | System status |
| 214 | Help message |
| 220 | Service ready |
| 221 | Service closing |
| 250 | Requested action taken |
| 251 | User not local; will forward |
| 252 | Cannot verify recipient |
| 354 | Start mail input |
| 421 | Service not available |
| 450 | Mailbox busy |
| 451 | Local error |
| 452 | Insufficient storage |
| 500 | Syntax error |
| 501 | Syntax error in parameters |
| 502 | Command not implemented |
| 503 | Bad command sequence |
| 504 | Command parameter not implemented |
| 550 | Mailbox unavailable |
| 551 | User not local |
| 552 | Storage quota exceeded |
| 553 | Mailbox name not allowed |
| 554 | Transaction failed |

---

## Summary

In Part 4, we've covered the Application Layer protocols that power everyday Internet use:

1. **DNS**: The hierarchical naming system that translates human-readable domains to IP addresses.

2. **HTTP**: The protocol that powers the web, with its request/response model, methods, status codes, and headers.

3. **Email Protocols**: SMTP for sending, POP3 for downloading, and IMAP for synchronization.

4. **SNMP**: Network monitoring and management through MIBs and OIDs.

**Key Takeaways**:
- DNS is hierarchical and uses caching for performance
- HTTP is stateless but can maintain sessions with cookies
- SMTP handles email transfer between servers
- POP3 downloads and deletes; IMAP keeps messages on the server
- SNMP enables remote monitoring of network devices
- Each protocol serves a specific purpose in the application layer

**What's Next**: In Part 5, we'll explore modern web security with TLS, the next-generation HTTP/3 and QUIC protocols, and comprehensive packet analysis techniques for troubleshooting and forensics.
