# Primer 5: How the Internet Works

## Welcome to the Internet Primer!

This primer explains the foundational concepts of how the internet works. Understanding these concepts will help you understand what Django does and why it's structured the way it is.

By the end of this primer, you'll understand how data travels across the internet, what happens when you visit a website, and where Django fits into the bigger picture.

---

## P.1: What is the Internet?

### The Simple Answer

The internet is a global network of computers that can talk to each other. Think of it like a postal system:

- **Computers** = Houses
- **IP Addresses** = Street addresses
- **Data packets** = Letters and packages
- **Routers** = Post offices and sorting centers
- **Protocols** = Postal rules and procedures

### The Internet vs The Web

Many people use these terms interchangeably, but they're different:

```
┌─────────────────────────────────────────────────┐
│                 The Internet                     │
│  (The physical network of computers)            │
│  ┌───────────────────────────────────────────┐  │
│  │            The World Wide Web             │  │
│  │  (Websites, browsers, HTTP)              │  │
│  │  ┌─────────────────────────────────────┐ │  │
│  │  │          Your Application           │ │  │
│  │  │  (Django, HTML, CSS, JS)           │ │  │
│  │  └─────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

- **Internet**: The underlying network (roads, postal system)
- **Web**: One service that runs on the internet (the postal service)
- **Your Application**: One website on the web (your house)

### Other Internet Services

- Email (SMTP, POP3, IMAP)
- File sharing (FTP)
- Video streaming (RTMP)
- Voice calls (VoIP)
- Gaming (custom protocols)

---

## P.2: The Client-Server Model

### The Basic Relationship

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│   ┌──────────────┐          ┌──────────────────────┐   │
│   │   Client     │          │      Server          │   │
│   │  (Browser)   │          │   (Web Server)       │   │
│   │              │          │                      │   │
│   │  Requests    ├──────────┤  Processes requests  │   │
│   │  content     │          │  Serves responses    │   │
│   │  Renders     │          │  Stores data         │   │
│   │  displays    │          │  Handles logic       │   │
│   └──────────────┘          └──────────────────────┘   │
│                                                          │
│   Examples:               Examples:                     │
│   - Your browser          - Django server               │
│   - Mobile app            - Database server              │
│   - Smart TV              - File server                 │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### How They Communicate

1. **Client sends request**: "I want this page"
2. **Server processes request**: "Let me get that"
3. **Server sends response**: "Here's the page"
4. **Client renders response**: Shows the page

### Why This Model?

- **Centralization**: One server can serve many clients
- **Maintenance**: Update one server, all clients benefit
- **Security**: Sensitive data stays on the server
- **Scalability**: Add more servers to handle more clients

---

## P.3: IP Addresses and DNS

### What is an IP Address?

An IP address is like a phone number for a computer.

```
IP Address Format: 192.168.1.1 (IPv4)
                    2001:0db8:85a3:0000:0000:8a2e:0370:7334 (IPv6)

Two main types:
- IPv4: 4 numbers (0-255) separated by dots
- IPv6: 8 groups of 4 hex digits (more addresses)
```

### What is DNS?

DNS (Domain Name System) translates human-readable domain names into IP addresses.

```
You type: www.example.com
         ↓
DNS asks: "Where is www.example.com?"
         ↓
DNS responds: "It's at 93.184.216.34"
         ↓
Your browser: "Let me connect to 93.184.216.34"
```

### DNS Lookup Process

```
Your Computer:
  "I want to go to www.example.com"

  ↓ Checks local cache
  ↓ (if not found) asks Recursive DNS

Recursive DNS (your ISP):
  "Where is www.example.com?"
  
  ↓ Asks Root DNS Server
  Root: "Ask .com TLD server"

  ↓ Asks .com TLD Server
  .com: "Ask example.com's nameserver"

  ↓ Asks example.com's Nameserver
  example.com: "It's at 93.184.216.34"

  ↓ Returns to your computer
Your Computer: "Got it! 93.184.216.34"
```

### Public vs Private IPs

| Type | Example | Usage |
|------|---------|-------|
| **Public** | 93.184.216.34 | Internet-facing servers |
| **Private** | 192.168.1.100 | Local networks |
| **Localhost** | 127.0.0.1 | Your own computer |

---

## P.4: TCP/IP and Ports

### What is TCP/IP?

TCP/IP is the fundamental protocol of the internet. It's like the postal service's rules for addressing and delivering mail.

```
┌─────────────────────────────────────────────────┐
│              TCP/IP Stack                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │         Application Layer              │   │
│  │  (HTTP, FTP, SMTP, DNS)               │   │
│  ├─────────────────────────────────────────┤   │
│  │         Transport Layer                │   │
│  │  (TCP, UDP)                           │   │
│  ├─────────────────────────────────────────┤   │
│  │         Internet Layer                 │   │
│  │  (IP, ICMP)                           │   │
│  ├─────────────────────────────────────────┤   │
│  │         Link Layer                     │   │
│  │  (Ethernet, Wi-Fi)                    │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

### TCP vs UDP

| TCP | UDP |
|-----|-----|
| Reliable | Unreliable |
| Ordered | Not ordered |
| Checked | Not checked |
| Slower | Faster |
| Web browsing | Streaming |

### What are Ports?

Ports are like apartment numbers within a building (IP address). They help identify specific services on a server.

```
┌─────────────────────────────────────────────┐
│            Server (93.184.216.34)           │
│  ┌───────────────────────────────────────┐ │
│  │  Port 80: Web Server (HTTP)           │ │
│  │  Port 443: Web Server (HTTPS)         │ │
│  │  Port 25: Email (SMTP)                │ │
│  │  Port 5432: Database (PostgreSQL)     │ │
│  │  Port 6379: Cache (Redis)             │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Common Ports

| Port | Protocol | Service |
|------|----------|---------|
| 20, 21 | TCP | FTP (File Transfer) |
| 22 | TCP | SSH (Secure Shell) |
| 25 | TCP | SMTP (Email) |
| 53 | TCP/UDP | DNS |
| 80 | TCP | HTTP |
| 110 | TCP | POP3 (Email) |
| 143 | TCP | IMAP (Email) |
| 443 | TCP | HTTPS |
| 3306 | TCP | MySQL |
| 5432 | TCP | PostgreSQL |
| 6379 | TCP | Redis |
| 8000 | TCP | Django development server |
| 27017 | TCP | MongoDB |

---

## P.5: HTTP Protocol

### What is HTTP?

HTTP (Hypertext Transfer Protocol) is the language that browsers and web servers use to talk to each other.

### HTTP Request Structure

```
GET /blog/my-post/ HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0
Accept: text/html
Cookie: session_id=abc123

[Body - only for POST/PUT]
```

### HTTP Response Structure

```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1234
Set-Cookie: session_id=xyz789

<!DOCTYPE html>
<html>
<head>
    <title>My Blog</title>
</head>
<body>
    <h1>My Post</h1>
</body>
</html>
```

### HTTP Methods

| Method | Purpose | Idempotent? | Example |
|--------|---------|-------------|---------|
| **GET** | Retrieve data | Yes | Viewing a page |
| **POST** | Create data | No | Submitting a form |
| **PUT** | Update data | Yes | Updating a profile |
| **DELETE** | Delete data | Yes | Deleting a post |
| **PATCH** | Partial update | No | Updating status |
| **HEAD** | Get headers only | Yes | Checking if page exists |

### HTTP Status Codes

**1xx: Informational**
- 100 Continue

**2xx: Success**
- 200 OK
- 201 Created
- 204 No Content

**3xx: Redirection**
- 301 Moved Permanently
- 302 Found
- 304 Not Modified

**4xx: Client Error**
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 405 Method Not Allowed
- 429 Too Many Requests

**5xx: Server Error**
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable
- 504 Gateway Timeout

### HTTP Headers

**Request Headers:**
```
Host: www.example.com
User-Agent: Mozilla/5.0
Accept: text/html,application/xhtml+xml
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9
Cookie: session_id=abc123
Authorization: Bearer token
Content-Type: application/json
```

**Response Headers:**
```
Content-Type: text/html
Content-Length: 1234
Cache-Control: max-age=3600
Set-Cookie: session_id=xyz789
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
```

### HTTP vs HTTPS

```
HTTP:
┌─────────────┐        ┌─────────────┐
│   Browser   │ ───── │   Server    │
│             │        │             │
│  Unencrypted│        │  Unencrypted│
└─────────────┘        └─────────────┘

HTTPS:
┌─────────────┐        ┌─────────────┐
│   Browser   │ ─SSL─ │   Server    │
│             │  ←───  │             │
│   Encrypted │        │   Encrypted │
└─────────────┘        └─────────────┘
```

---

## P.6: Domain Names and URLs

### Anatomy of a URL

```
https://www.example.com:443/blog/my-post/?page=2#comments
│      │                │    │        │        │       │
│      │                │    │        │        │       │
│      │                │    │        │        │       └─ Fragment (anchor)
│      │                │    │        │        └─ Query Parameters
│      │                │    │        └─ Path
│      │                │    └─ Port (default: 80 for HTTP, 443 for HTTPS)
│      │                └─ Domain Name
│      └─ Subdomain
└─ Protocol/Scheme
```

### Domain Name Hierarchy

```
www.example.com
│   │      │
│   │      └─ Top-Level Domain (TLD)
│   └─ Second-Level Domain (SLD)
└─ Subdomain

┌────────────────────────────────────────────┐
│  Root DNS Servers                         │
│  ├─ .com TLD Servers                     │
│  │  ├─ example.com Nameserver            │
│  │  │  ├─ www.example.com → 93.184.216.34│
│  │  │  └─ blog.example.com → 93.184.216.35│
│  │  └─ google.com Nameserver            │
│  ├─ .org TLD Servers                     │
│  ├─ .net TLD Servers                     │
│  └─ Country TLD Servers (.uk, .jp, etc.)│
└────────────────────────────────────────────┘
```

### URL Encoding

Some characters must be encoded in URLs:

```
Space → %20
!     → %21
"     → %22
#     → %23
$     → %24
%     → %25
&     → %26
'     → %27
(     → %28
)     → %29
*     → %2A
+     → %2B
,     → %2C
/     → %2F
:     → %3A
;     → %3B
=     → %3D
?     → %3F
@     → %40
```

---

## P.7: Security Concepts

### SSL/TLS (HTTPS)

SSL/TLS encrypts communication between browser and server:

```
Without HTTPS:
Your data is visible to anyone listening

With HTTPS:
Your data is encrypted, only browser and server can read it

How it works:
1. Browser requests HTTPS connection
2. Server sends SSL certificate
3. Browser verifies certificate
4. Browser and server agree on encryption
5. All data is now encrypted
```

### CSRF Protection

CSRF (Cross-Site Request Forgery) prevents malicious websites from making requests on behalf of users:

```
How it works:
1. Django generates a CSRF token
2. Token is included in forms
3. Server checks token on submission
4. If token is missing/incorrect, request is rejected

Why you need {% csrf_token %}:
- Ensures request came from your site
- Prevents external sites from submitting forms
```

### XSS Protection

XSS (Cross-Site Scripting) prevents malicious scripts from being injected:

```
How Django protects you:
1. Template variables are auto-escaped
2. {{ variable }} → Encodes HTML special characters
3. Use {{ variable|safe }} only when you trust the content
```

### SQL Injection Protection

SQL Injection is prevented by Django's ORM:

```
Bad: Raw SQL query with user input
cursor.execute(f"SELECT * FROM users WHERE name = '{name}'")
# name = "'; DROP TABLE users; --" → Disaster!

Good: Django ORM
User.objects.filter(name=name)
# Automatically escaped and parameterized
```

---

## P.8: How a Request Travels

### The Complete Journey

```
1. You type "example.com" in your browser
   ↓
2. Browser checks cache
   ↓
3. DNS resolves domain to IP
   ↓
4. Browser establishes TCP connection (3-way handshake)
   ↓
5. Browser sends HTTP request
   ↓
6. Request travels through routers
   ↓
7. Server receives request
   ↓
8. Server processes request (Django)
   ↓
9. Server generates response
   ↓
10. Response travels back through routers
   ↓
11. Browser receives response
   ↓
12. Browser renders page
   ↓
13. You see the page!
```

### What Django Handles

```
Request arrives at server
  ↓
Django receives request
  ↓
Middleware processes request
  ↓
URL resolver finds matching view
  ↓
View processes request
  ↓ (may query database)
Database returns data
  ↓
View renders template
  ↓
Django generates response
  ↓
Response sent back
```

---

## P.9: Key Concepts Glossary

| Term | Definition | Simple Analogy |
|------|------------|----------------|
| **Internet** | Global network of computers | The worldwide postal system |
| **IP Address** | Computer's address on internet | Your street address |
| **DNS** | Translates domains to IPs | Phone book |
| **Domain Name** | Human-readable website name | Your name |
| **URL** | Complete web address | Full mailing address |
| **HTTP** | Web communication protocol | Language used for mail |
| **HTTPS** | Secure HTTP | Certified mail |
| **TCP** | Reliable data transfer | Registered mail |
| **UDP** | Fast data transfer | Regular mail |
| **Port** | Specific service on server | Apartment number |
| **Server** | Computer that serves data | Store/warehouse |
| **Client** | Computer that requests data | Customer |
| **Request** | Message from client to server | Asking for something |
| **Response** | Message from server to client | Receiving something |
| **Cookie** | Small data stored on client | Loyalty card |
| **Session** | User's interaction with site | Shopping trip |
| **Cache** | Stored data for speed | Memory/remembering |
| **Proxy** | Middleman server | Personal assistant |

---

## P.10: Common Internet Tools

### Ping

Ping checks if a server is reachable:

```bash
ping example.com
# PING example.com (93.184.216.34) 56(84) bytes of data.
# 64 bytes from 93.184.216.34: icmp_seq=1 ttl=56 time=14.7 ms
# 64 bytes from 93.184.216.34: icmp_seq=2 ttl=56 time=14.2 ms
```

### Traceroute

Traceroute shows the path to a server:

```bash
traceroute example.com
#  1  192.168.1.1  1.234 ms
#  2  10.0.0.1    5.678 ms
#  3  93.184.216.1 12.345 ms
#  4  93.184.216.34 14.567 ms
```

### DNS Lookup

Dig shows DNS information:

```bash
dig example.com
# ;; ANSWER SECTION:
# example.com.  86400  IN  A  93.184.216.34
```

### Curl

Curl makes HTTP requests:

```bash
curl example.com
# <!DOCTYPE html>
# <html>
# <head>
#    <title>Example Domain</title>
# </head>
# ...

curl -I example.com
# HTTP/1.1 200 OK
# Content-Type: text/html
# ...
```

### Wget

Wget downloads content:

```bash
wget example.com
# Downloads the page to a file
```

---

## P.11: Why This Matters for Django

### Understanding Django's Role

```
┌─────────────────────────────────────────────────────────┐
│                     Your Django App                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │    How Django fits in the internet stack:      │   │
│  │                                                 │   │
│  │  Browser → HTTP → Nginx → Gunicorn → Django    │   │
│  │                            ↓                    │   │
│  │                          Database               │   │
│  │                                                 │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  Why Django does things its way:                      │
│  • URLs: Because HTTP has URLs                        │
│  • Views: Because HTTP has requests/responses         │
│  • Models: Because databases store data               │
│  • Templates: Because browsers render HTML            │
│  • Security: Because the internet is insecure         │
│  • Sessions: Because HTTP is stateless               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Practical Implications

| Internet Concept | Django Implementation |
|------------------|----------------------|
| URLs | URL routing (`urls.py`) |
| HTTP Methods | Views handle GET/POST |
| Headers | `request.META`, `response.headers` |
| Status Codes | `HttpResponse(status=404)` |
| HTTPS | `SECURE_SSL_REDIRECT = True` |
| DNS | Deployment domain names |
| Ports | `runserver 8000`, Nginx on 80/443 |
| Caching | `django.core.cache` |
| Sessions | `django.contrib.sessions` |
| Security | CSRF, XSS, SQL injection protection |

---

This primer explains the internet infrastructure that Django builds upon. Understanding these concepts will help you appreciate why Django is structured the way it is and how to troubleshoot issues when they arise!
