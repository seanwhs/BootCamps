# Part 0: Introduction

## Welcome to the Series

Hello, developer. Let me guess why you're here.

You've been building web applications for a while now. You understand React, you can spin up a FastAPI server in seconds, and you know your way around Docker. But when you need to configure Nginx, you open a browser tab, search for "nginx reverse proxy nextjs," copy a configuration from some forum post, paste it into your server, and pray it works.

It does work—most of the time. But when it doesn't, you're stuck. The errors are cryptic, the logs are confusing, and you don't understand what the directives actually do. You spend hours tweaking, restarting, and hoping.

This series exists to change that.

## Why Nginx Matters More Than You Think

The modern web stack is increasingly polyglot. Your application might use:

- Next.js for the frontend (running on port 3000)
- FastAPI for one set of APIs (port 8000)
- Django for admin functionality (port 8001)
- A WebSocket server for real-time features (port 8080)
- A Node.js service for background processing (port 3001)

Your users don't want to remember all these ports. They want `https://yourapp.com` to just work.

Without Nginx, you'd be forced to expose multiple ports, deal with CORS issues, and manage TLS certificates across each service. You'd fragment your authentication flow. You'd lose centralized logging. You'd have no consistent way to rate-limit, cache, or compress responses.

**Nginx gives you a single entry point to your entire application stack.** It's not just a "reverse proxy"—it's your application's front door, security guard, traffic controller, and performance optimizer all in one.

## What This Series Actually Teaches

We're going to build a production-grade Nginx gateway piece by piece, starting from absolutely nothing.

### The Final Architecture

By the end of this series, you'll have built and understood this complete system:

```text
                               INTERNET
                                   │
                                   │ HTTPS (443)
                                   ▼
                          ┌─────────────────┐
                          │    Nginx        │
                          │   :443/:80      │
                          │                 │
                          │ ✅ TLS 1.3      │
                          │ ✅ Path Routing │
                          │ ✅ Rate Limiting│
                          │ ✅ Caching      │
                          │ ✅ WebSockets   │
                          │ ✅ SSE          │
                          │ ✅ Logging      │
                          └────────┬────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
             ┌──────────┐  ┌──────────┐  ┌──────────┐
             │ Next.js  │  │ FastAPI  │  │  Django  │
             │  :3000   │  │  :8000   │  │  :8001   │
             └────┬─────┘  └────┬─────┘  └────┬─────┘
                  │              │              │
                  │              └──────┬───────┘
                  │                     │
                  │              ┌──────▼───────┐
                  │              │  Neon DB     │
                  │              └──────────────┘
                  │
                  ├── Clerk Authentication
                  ├── Sanity CMS
                  └── Inngest Webhooks

        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
  WebSocket             SSE Stream
  :8080                 :8081
```

Every component you see here will be running, tested, and explained. You'll understand exactly how Nginx connects to each service, how it handles different protocols, and how everything scales.

### The Learning Philosophy: Break It First

Here's a hard truth: **you don't truly understand a configuration until you've fixed it.**

That's why every module in this series starts with a deliberately broken application. You'll receive a working Docker Compose environment, but the Nginx configuration will have something wrong—a missing header, an incorrect port, a misconfigured WebSocket upgrade, a caching issue.

Your job will be simple:

1. **Observe** the failure (what breaks, how does it break, what error do you get?)
2. **Investigate** the logs, the network traffic, the configuration
3. **Form a hypothesis** about what's wrong
4. **Make one change** to the configuration
5. **Verify** it works
6. **Understand why** the change fixed it

This isn't about memorizing directives. It's about building mental models for how HTTP works, how Nginx processes requests, and how to troubleshoot when things go wrong.

### Your Constant Companion: The Git Repository

Every episode includes both a `start/` and `solution/` directory. The `start/` contains the broken configuration; the `solution/` contains the working version.

```bash
nginx-series/
├── part-01-reverse-proxy/
│   ├── start/
│   │   └── nginx.conf    # Deliberately broken
│   └── solution/
│       └── nginx.conf    # Fixed version with comments
├── part-02-routing/
│   ├── start/
│   └── solution/
└── ... each part continues
```

You can run `git diff` to see exactly what changed:

```bash
git diff part-01/start/nginx.conf part-01/solution/nginx.conf
```

This lets you focus on the *why* instead of copying *what*.

## Who This Series Is For

### You're a Good Fit If You:

- **Build web applications professionally** and want to understand the infrastructure layer
- **Already use frameworks** like Next.js, Django, FastAPI, or similar
- **Have shipped code to production** but feel shaky about reverse proxies
- **Understand HTTP basics** (requests, responses, status codes, headers)
- **Can run Docker commands** and navigate the Linux command line
- **Are comfortable editing configuration files** and restarting services
- **Want to stop copying Nginx configs** and start *writing* them

### You Need These Prerequisites:

Let's be honest about what you need to know before starting:

**Fundamental Concepts You Must Understand:**

- **HTTP/HTTPS**: What requests and responses look like, status codes (200, 302, 404, 500), common headers
- **DNS**: What domain names are, how `localhost` resolves, what an A record does
- **Ports**: What `:3000` means, how multiple services use different ports
- **Basic Linux**: Navigating directories (`cd`, `ls`), editing files (`nano`/`vim`), viewing logs (`tail -f`)
- **Docker Fundamentals**: What containers are, `docker compose up`, `docker exec`, volumes
- **Application Servers**: Your app runs on a port and handles requests

**Nice-to-Have Skills:**

- JavaScript/Node.js (for Next.js parts)
- Python (for FastAPI/Django parts)
- Basic bash scripting

**What You Don't Need:**
- Prior Nginx experience (we start from zero)
- DevOps credentials
- A degree in networking
- Previous sysadmin work

### How Much Time to Budget

Each part of this series is designed to be consumed in one focused session:

| Part | Topic | Estimated Time |
|------|-------|---------------|
| 0 | Introduction | 15 minutes |
| 1 | Reverse Proxy Fundamentals | 45 minutes |
| 2 | Path-Based Routing | 1 hour |
| 3 | HTTPS & TLS | 45 minutes |
| 4 | Authentication & Security | 1 hour |
| 5 | WebSockets, SSE & Webhooks | 1 hour |
| 6 | Caching & Performance | 45 minutes |
| 7 | Load Balancing & Zero-Downtime | 1 hour |
| 8 | Debugging & Observability | 45 minutes |
| 9 | Security Hardening | 45 minutes |
| 10 | Capstone Project | 2 hours |

Total: ~12 hours of focused work.

But here's the secret: you'll learn more in the first 2 hours than in months of copying configs.

## What You'll Actually Build

This series isn't theoretical. Every piece of code you see will run on your machine. Here's the full list of what you'll build, configure, and understand:

### By Part 4, You'll Have:

- Nginx installed and running in Docker
- A basic reverse proxy forwarding requests to your application
- Multiple services (Next.js + FastAPI) accessible through one URL
- HTTPS with Let's Encrypt certificates (in a test environment)
- Security headers protecting your application
- Rate limiting to prevent abuse
- Cookie forwarding for authentication

### By Part 7, You'll Add:

- WebSocket support with `Upgrade` headers
- Server-Sent Events (SSE) streaming
- Inngest webhook handling
- Proxy caching for static assets
- Micro-caching for API endpoints
- Gzip compression

### By Part 10, You'll Complete:

- A production-grade gateway with:
  - TLS termination and HTTP→HTTPS redirects
  - Path-based routing to four separate services
  - WebSocket and SSE support
  - Rate limiting with different zones per endpoint
  - Security headers (HSTS, CSP, X-Frame-Options)
  - Structured JSON logging
  - Blue-green deployment readiness
  - Complete Docker Compose setup
  - A troubleshooting runbook for common failures

## The Tools You'll Use

We don't install Nginx directly on your host machine. Instead, we use Docker. This gives us:

- **Isolation**: No conflicts with other services on your machine
- **Reproducibility**: The exact same environment works on Linux, macOS, and Windows
- **Simplicity**: Configuration changes mean editing a file and restarting a container
- **Cleanup**: `docker compose down -v` removes everything when you're done

### The Core Stack:

```yaml
services:
  nginx:
    image: nginx:1.27-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./logs:/var/log/nginx

  nextjs:
    build: ./nextjs
    environment:
      - PORT=3000

  fastapi:
    build: ./fastapi
    environment:
      - PORT=8000

  # Plus Django, WebSocket servers, and databases as needed
```

### Your Development Environment:

- **Code Editor**: Whatever you're comfortable with (VS Code, Vim, Sublime)
- **Terminal**: For running Docker commands and `curl`
- **Browser**: For testing the frontend
- **Git**: For comparing start/solution configurations

No special IDE plugins or paid software required.

## How This Series Is Structured

### Episode Pattern

Every part follows the same format:

1. **The Target**: What problem are we solving, and what's the goal?
2. **The Pain Point**: Why is this difficult without Nginx?
3. **Broken Example**: We start with something that doesn't work
4. **Investigation**: What logs/errors tell us what's wrong?
5. **The Fix**: Add/modify one Nginx directive
6. **Verification**: Test that it works
7. **Deep Dive**: Understand why it works (the underlying HTTP/nginx mechanism)
8. **Production Hardening**: What else should we consider for real deployments?

### Reference Sections

Deep conceptual explanations are moved to "Reference" sections at the end of each part. This keeps the main flow practical while still providing depth for curious learners.

For example, Part 1's reference covers:
- How Nginx processes a request (the 11-phase request lifecycle)
- The difference between forward and reverse proxies
- How `proxy_pass` manipulates the URI

## The Verification Mindset

Throughout this series, we'll emphasize *verification*. Every change you make should be testable immediately. You'll use these tools constantly:

### `curl` (Your Best Friend)

```bash
# See the full request/response
curl -v http://localhost

# Just check headers
curl -I http://localhost

# Send a specific Host header
curl -H "Host: api.local" http://localhost

# Follow redirects
curl -L http://localhost
```

### `nginx -t` (Test Configuration)

```bash
# Always test before reloading
docker exec nginx nginx -t
```

### `tail -f` (Watch Logs)

```bash
# Access log in real-time
tail -f logs/access.log

# Error log in real-time
tail -f logs/error.log
```

### Browser DevTools

- Network tab to inspect requests
- Console for JavaScript errors
- Application tab for cookies and storage

### Docker Commands

```bash
# See if containers are running
docker ps

# View container logs
docker logs nginx
docker logs nextjs
docker logs fastapi

# Restart Nginx after config change
docker restart nginx
```

## How to Get the Most Out of This Series

### 1. Run Every Command

Don't just read the code blocks—type them out or paste them. The muscle memory of executing commands helps reinforce the learning.

### 2. Break Things on Purpose

After you fix a configuration, break it again—intentionally. Change a port, remove a header, set a timeout too low. Observe what happens. This builds diagnostic intuition faster than anything else.

### 3. Keep Notes

Create a personal "failure gallery." When you encounter an error, note:

- The symptom (what broke)
- The error message (exact text)
- Where you looked (logs, curl output, browser devtools)
- What you changed to fix it

This becomes your troubleshooting reference.

### 4. Compare Start vs. Solution

After each part, run `git diff` and study the changes line by line. Ask yourself:

- Why did they add this line?
- What would happen if they didn't?
- Could I have solved it differently?

### 5. Don't Skip Verification

The "Verification" steps are not optional. They confirm that your understanding matches reality. If the verification fails, something is wrong—and that's valuable information.

## What This Series Does NOT Cover

To keep the focus sharp, we're deliberately not covering:

- **Nginx as a web server**: We use Nginx primarily as a *reverse proxy*, not to serve static files directly (though we'll touch on it). Static files are better served by a CDN in production.
- **Nginx as a mail proxy**: Nginx can proxy IMAP/POP3, but that's outside our scope.
- **Nginx Plus features**: We use the open-source version. Features like active health checks, JWT authentication, and key-value stores are Nginx Plus only.
- **Kubernetes Ingress**: That's a different layer. This series focuses on the Nginx process itself.
- **Windows deployment**: Nginx runs on Windows, but we use Docker on Linux containers for consistency. The configuration works everywhere.

## Before You Begin: Setup Your Environment

You'll need a working Docker environment. Verify it now:

```bash
docker --version
# Should show Docker version 20.10 or higher

docker compose version
# Should show Docker Compose version v2 or higher
```

If these commands fail, install Docker Desktop for your OS.

You'll also need `curl` (pre-installed on macOS/Linux, available via WSL on Windows).

## A Note About Production vs. Development

This series distinguishes carefully between:

- **Local development**: Testing on your machine, using `localhost`, self-signed certificates, and simple configurations
- **Production deployment**: Using real domains, Let's Encrypt, load balancing, and hardened security

Every "production" recommendation includes the "why" behind the practice, so you can adapt it to your specific needs.

## Your First Challenge

Before we start Part 1, try this mini-exercise:

1. Open a terminal
2. Run: `curl -v http://localhost:3000`
3. What happens? (You'll get "Connection refused" because nothing is running on port 3000)

Now try:
4. Run: `curl -v http://localhost`
5. What happens? (Same thing, but now you're connecting to port 80)

**The mental model**: Port `80` is the default HTTP port. That's what browsers use when you type `http://example.com`. Your application, however, runs on port `3000`. If we want users to access your app at port `80`, something needs to bridge the gap.

That something is Nginx.

## What Comes Next

**Part 1: Reverse Proxy Fundamentals** starts immediately.

We'll set up a running Nginx container, point it at a Next.js application, and handle our first failure: a `502 Bad Gateway` that reveals everything we need to know about how Nginx connects to upstream services.

You'll learn:
- How to install and run Nginx in Docker
- What a `server` block does
- How `location` matches URLs
- What `proxy_pass` actually does under the hood
- How to read access and error logs
- Why your first configuration always fails (and how to fix it)

Ready? Let's go.

