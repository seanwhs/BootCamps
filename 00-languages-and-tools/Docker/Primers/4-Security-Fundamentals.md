# Primer 4 – Security Fundamentals for Docker Users

Security is not an afterthought—it's a fundamental part of container design. This primer covers the essential security concepts you need to understand to run containers safely in production. From Linux security features to Docker-specific hardening techniques, you'll learn how to protect your containers from common threats.

By the end, you'll have a security-first mindset and practical techniques to secure any containerized application.

---

## P4.1 The Container Security Landscape

### What Makes Containers Different

Containers share the host kernel, which creates unique security challenges compared to virtual machines.

| Aspect | Virtual Machines | Containers |
|--------|------------------|------------|
| **Isolation** | Strong (separate kernel) | Moderate (shared kernel) |
| **Attack Surface** | Large (full OS) | Small (minimal OS) |
| **Security Boundaries** | Hypervisor | Linux kernel features |
| **Exploit Impact** | VM only | Host kernel compromise |
| **Security Tools** | VM-specific | Linux-specific |

### The Security Pyramid

```
                    ┌─────────────────────────┐
                    │   Application Security   │
                    ├─────────────────────────┤
                    │  Container Configuration │
                    ├─────────────────────────┤
                    │   Image Security         │
                    ├─────────────────────────┤
                    │   Registry Security      │
                    ├─────────────────────────┤
                    │   Host Security          │
                    └─────────────────────────┘
```

**Each layer builds on the ones below it.** You can't have secure containers on an insecure host, and you can't have secure applications in insecure containers.

---

## P4.2 Linux Security Features for Containers

### Namespaces – Isolation Boundaries

Namespaces provide process isolation. Each container gets its own view of the system.

| Namespace | Isolates | Security Benefit |
|-----------|----------|------------------|
| **PID** | Process IDs | Can't see other containers' processes |
| **NET** | Network stack | Separate IP addresses, routing |
| **MNT** | Mount points | Separate filesystem views |
| **UTS** | Hostname | Different hostnames per container |
| **IPC** | Inter-process communication | Can't access other containers' IPC |
| **USER** | User IDs | Map container UIDs to different host UIDs |
| **CGROUP** | Cgroup hierarchy | Isolated resource limits |

**Testing Namespace Isolation:**
```bash
# Run a container
docker run -d --name test-container nginx

# Get its PID on the host
PID=$(docker inspect test-container --format='{{.State.Pid}}')

# View its namespaces
ls -la /proc/$PID/ns/
```

### Cgroups – Resource Control

Cgroups prevent containers from consuming all host resources.

```bash
# Set resource limits
docker run --memory=512M --cpus=1 nginx

# View cgroup limits
docker inspect container-name --format='{{.HostConfig.Memory}}'
docker inspect container-name --format='{{.HostConfig.CpuShares}}'
```

### Capabilities – Fine-grained Permissions

Linux capabilities are like fine-grained root privileges. Instead of giving all-or-nothing root access, you grant specific capabilities.

**Common Capabilities:**

| Capability | Description | Keep? |
|------------|-------------|-------|
| `CHOWN` | Change file ownership | Usually yes |
| `DAC_OVERRIDE` | Bypass file permissions | Usually yes |
| `FOWNER` | Override file ownership checks | Maybe |
| `NET_BIND_SERVICE` | Bind to ports <1024 | Yes (for web servers) |
| `NET_RAW` | Use raw sockets | Usually no |
| `SYS_ADMIN` | Many admin operations | Usually no |
| `SYS_PTRACE` | Trace processes | Usually no |
| `SETUID` | Change UID/GID | Maybe |
| `SETGID` | Change GID | Maybe |
| `SYS_CHROOT` | Change root directory | No |
| `SYS_TIME` | Set system time | No |

**Why This Matters:** By dropping unnecessary capabilities, you reduce the impact of a container compromise.

```bash
# Drop all capabilities, then add only needed ones
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx
```

### Seccomp – System Call Filtering

Seccomp (Secure Computing Mode) restricts which system calls a process can make.

**Seccomp Profiles:**
- **Default:** Blocks ~44 system calls
- **Custom:** Tailored to your application
- **Unconfined:** No restrictions (not recommended)

**View Seccomp Profile:**
```bash
docker run --rm nginx cat /proc/self/status | grep Seccomp
```
```
Seccomp:	2  # 2 = filtering enabled
```

**Default Blocked System Calls:**
- `mount` – Can't mount filesystems
- `unshare` – Can't create new namespaces
- `clone` – Restricted for new namespaces
- `reboot` – Can't reboot the system
- `swapon` – Can't manage swap

**Custom Seccomp Profile:**
```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": ["accept", "accept4", "bind", "connect"],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": ["execve", "execveat"],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": ["fork", "vfork", "clone"],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": ["read", "write", "open", "close"],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

---

## P4.3 Docker Security Best Practices

### 1. Run as Non-Root

**The Rule:** Never run containers as root (UID 0) in production.

```dockerfile
# ✅ Good
FROM python:3.11-slim
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# ❌ Bad
FROM python:3.11-slim
# No USER directive, runs as root
```

**Why It Matters:**
- If exploited, attacker has root privileges
- Can escape container in some configurations
- Violates principle of least privilege

**Enforce in CI/CD:**
```bash
# Check for root user in images
docker run --rm my-image id -u
# Should return non-zero (not root)

# In GitHub Actions
- name: Check user
  run: |
    if [ $(docker run --rm my-image id -u) -eq 0 ]; then
      echo "Error: Container runs as root!"
      exit 1
    fi
```

### 2. Use Minimal Base Images

**The Rule:** Use the smallest image that meets your needs.

| Image Type | Size | Security |
|------------|------|----------|
| **Alpine** | ~5MB | Minimal attack surface |
| **Slim** | ~50MB | Reduced attack surface |
| **Full** | ~500MB+ | Large attack surface |
| **Distroless** | ~20MB | No package manager, no shell |
| **Scratch** | ~0MB | No OS, only your binary |

**Comparison:**
```dockerfile
# ❌ Bad
FROM ubuntu:latest  # ~77MB, many packages

# ✅ Good
FROM python:3.11-slim  # ~118MB, minimal packages

# ✅ Even Better
FROM python:3.11-alpine  # ~50MB, Alpine Linux

# ✅ Best for Go
FROM golang:1.21-alpine AS builder
# ... build ...
FROM scratch  # ~0MB, only your binary
```

### 3. Keep Images Updated

**The Rule:** Regularly update base images and dependencies.

```bash
# Check for outdated base images
docker scan my-image

# Check image age
docker inspect my-image --format='{{.Created}}'

# Update in Dockerfile
FROM python:3.11-slim  # Use latest patch version

# In CI, rebuild images weekly
# Schedule a weekly rebuild pipeline
```

### 4. Scan for Vulnerabilities

**The Rule:** Scan all images before deployment.

**Using Trivy:**
```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

# Scan image
trivy image my-image:latest

# Only critical/high vulnerabilities
trivy image --severity HIGH,CRITICAL my-image:latest

# Generate SARIF report
trivy image --format sarif --output trivy-results.sarif my-image:latest
```

**Using Grype:**
```bash
# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh

# Scan image
grype my-image:latest

# Detailed output
grype --fail-on high my-image:latest
```

**Using Docker Scout:**
```bash
# Built into Docker Desktop
docker scout quickview my-image:latest
docker scout cves my-image:latest
```

### 5. Use Read-Only Filesystem

**The Rule:** Make the container's root filesystem read-only.

```yaml
services:
  app:
    read_only: true
    volumes:
      - ./logs:/app/logs:rw  # Only writable directories
      - ./uploads:/app/uploads:rw
    tmpfs:
      - /tmp:size=100M,uid=1001,gid=1001
```

**Benefits:**
- Prevents attackers from writing malicious files
- Prevents accidental modifications
- Enforces logging to stdout (12-factor)

### 6. Drop Unnecessary Capabilities

**The Rule:** Drop all capabilities, then add only required ones.

```bash
# Docker run
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx

# Docker Compose
services:
  app:
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
      - CHOWN
      - DAC_OVERRIDE
```

**What Capabilities Does Your App Need?**

| Application Type | Required Capabilities |
|------------------|----------------------|
| Web server (HTTP) | `NET_BIND_SERVICE` |
| Database | `CHOWN`, `DAC_OVERRIDE`, `SETGID`, `SETUID` |
| Application server | `CHOWN`, `DAC_OVERRIDE` |
| Background worker | None (drop all) |
| Proxy | `NET_BIND_SERVICE`, `NET_ADMIN` (maybe) |

### 7. Use Seccomp Profiles

**The Rule:** Apply seccomp profiles to restrict system calls.

```bash
# Use default seccomp profile
docker run --security-opt seccomp=default.json nginx

# Use custom profile
docker run --security-opt seccomp=custom.json nginx

# Disable seccomp (NOT RECOMMENDED)
docker run --security-opt seccomp=unconfined nginx
```

**Creating a Custom Profile:**
```bash
# Generate base profile from running container
docker run --rm nginx cat /proc/1/status | grep Seccomp

# Use tools like `docker-slim` to generate minimal profiles
```

### 8. No Secrets in Images

**The Rule:** Never bake secrets into Docker images.

**❌ Bad:**
```dockerfile
ENV DB_PASSWORD=super_secret
COPY config/production.json /app/config.json  # Contains secrets
```

**✅ Good (Environment Variables):**
```dockerfile
# No secrets in Dockerfile
ENV DB_PASSWORD=${DB_PASSWORD}
```

```bash
# Pass at runtime
docker run -e DB_PASSWORD=secret my-image
```

**✅ Good (Secrets Files):**
```yaml
services:
  app:
    secrets:
      - db_password
      - api_key
    # Read from /run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    external: true
```

---

## P4.4 Attack Vectors and Mitigations

### Common Attack Vectors

| Vector | Risk | Mitigation |
|--------|------|------------|
| **Image Supply Chain** | Malicious images | Use official images, sign images |
| **Container Escape** | Break out of container | Namespaces, seccomp, capabilities |
| **Privilege Escalation** | Gain higher privileges | Non-root user, drop capabilities |
| **Resource Exhaustion** | Denial of service | Resource limits |
| **Secret Exposure** | Credential theft | No secrets in images |
| **Vulnerable Dependencies** | Exploited software | Regular scanning |
| **Denial of Service** | System overload | Rate limiting, resource quotas |

### Defense in Depth Strategy

```
┌─────────────────────────────────────────────────────────┐
│ Layer 7: Application Security (code, auth, TLS)        │
├─────────────────────────────────────────────────────────┤
│ Layer 6: Container Configuration (read-only, user)      │
├─────────────────────────────────────────────────────────┤
│ Layer 5: Runtime Security (seccomp, capabilities)       │
├─────────────────────────────────────────────────────────┤
│ Layer 4: Image Security (scanning, signing, SBOM)      │
├─────────────────────────────────────────────────────────┤
│ Layer 3: Registry Security (auth, scanning)            │
├─────────────────────────────────────────────────────────┤
│ Layer 2: Host Security (kernel, updates)               │
├─────────────────────────────────────────────────────────┤
│ Layer 1: Network Security (firewall, isolation)        │
└─────────────────────────────────────────────────────────┘
```

---

## P4.5 Security Tools and Commands

### Image Scanning Tools

```bash
# Docker Scout
docker scout quickview my-image:latest
docker scout cves my-image:latest
docker scout recommendations my-image:latest

# Trivy
trivy image --severity HIGH,CRITICAL my-image:latest
trivy fs --security-checks vuln,secret,config .

# Grype
grype --fail-on high my-image:latest
grype --scope all-layers my-image:latest

# Clair (via clair-scanner)
clair-scanner --ip 127.0.0.1 --clair=http://clair:6060 my-image:latest
```

### Container Inspection

```bash
# Check user
docker inspect container-name --format='{{.Config.User}}'

# Check capabilities
docker inspect container-name --format='{{.HostConfig.CapAdd}}'
docker inspect container-name --format='{{.HostConfig.CapDrop}}'

# Check read-only filesystem
docker inspect container-name --format='{{.HostConfig.ReadonlyRootfs}}'

# Check security options
docker inspect container-name --format='{{.HostConfig.SecurityOpt}}'

# Check privileged mode
docker inspect container-name --format='{{.HostConfig.Privileged}}'

# Check resource limits
docker inspect container-name --format='{{.HostConfig.Memory}}'
docker inspect container-name --format='{{.HostConfig.CpuShares}}'
```

### Security Auditing

```bash
# Check Docker daemon security
docker info | grep Security

# Check docker group membership
getent group docker

# Check Docker socket permissions
ls -la /var/run/docker.sock

# Check for root containers
docker ps -q | xargs docker inspect --format='{{.Name}} runs as root' | grep root

# Find privileged containers
docker ps -q | xargs docker inspect --format='{{.Name}} is privileged: {{.HostConfig.Privileged}}'
```

---

## P4.6 Security Checklist for Production

### Pre-Deployment Security Checklist

- [ ] **Image:**
  - [ ] From trusted source (official or verified)
  - [ ] Scanned for vulnerabilities
  - [ ] Minimal base image used
  - [ ] Non-root user set
  - [ ] No secrets in image
  - [ ] Signed (if using signed images)
  - [ ] SBOM generated

- [ ] **Container Configuration:**
  - [ ] Read-only filesystem (where possible)
  - [ ] Capabilities dropped
  - [ ] Seccomp profile applied
  - [ ] Resource limits set (CPU, memory)
  - [ ] Restart policy configured
  - [ ] Health check defined

- [ ] **Environment:**
  - [ ] No secrets in environment variables
  - [ ] Secrets mounted via secrets system
  - [ ] SSL/TLS configured
  - [ ] Network isolation implemented
  - [ ] Logging configured

- [ ] **Host:**
  - [ ] Linux kernel up-to-date
  - [ ] Docker daemon up-to-date
  - [ ] Firewall configured
  - [ ] No unnecessary services running

### Runtime Security Monitoring

```bash
# Monitor resource usage
docker stats --no-stream

# Check for suspicious processes
docker exec container-name ps aux

# Check for open ports
docker exec container-name netstat -tulpn

# Check for file changes (in development)
docker diff container-name

# Monitor container logs
docker logs -f container-name

# Check Docker events
docker events --filter "type=container"
```

---

## P4.7 Security Lab: Harden an Insecure Container

### The Insecure Container

```dockerfile
# Dockerfile.insecure
FROM ubuntu:latest

RUN apt-get update && apt-get install -y python3

COPY app.py /app/app.py

CMD ["python3", "/app/app.py"]
```

```bash
# Run the insecure container
docker build -f Dockerfile.insecure -t insecure-app .
docker run -d --name insecure-container insecure-app
```

### Step 1: Assess the Security

```bash
# Check user (runs as root)
docker exec insecure-container id
# uid=0(root) gid=0(root)

# Check capabilities
docker inspect insecure-container --format='{{.HostConfig.CapAdd}}'
# []

# Check privileged status
docker inspect insecure-container --format='{{.HostConfig.Privileged}}'
# false

# Check read-only filesystem
docker inspect insecure-container --format='{{.HostConfig.ReadonlyRootfs}}'
# false
```

**Findings:**
1. Runs as root
2. No capability restrictions
3. Full write access
4. Large base image (Ubuntu)

### Step 2: Apply Security Hardening

```dockerfile
# Dockerfile.secure
FROM python:3.11-slim  # Smaller base image

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app

# Install dependencies (as root)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=appuser:appgroup app.py .

# Switch to non-root user
USER appuser

# Security labels
LABEL org.opencontainers.image.security.level="hardened"

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost/health')" || exit 1

# Run the application
CMD ["python", "app.py"]
```

```bash
# Build secure container
docker build -f Dockerfile.secure -t secure-app .

# Run with additional security
docker run -d \
  --name secure-container \
  --read-only \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt seccomp=default.json \
  --user 1001:1001 \
  --memory=512M \
  --cpus=1 \
  --restart=unless-stopped \
  -v $(pwd)/logs:/app/logs:rw \
  -v $(pwd)/uploads:/app/uploads:rw \
  secure-app
```

### Step 3: Verify Security

```bash
# Check user
docker exec secure-container id
# uid=1001(appuser) gid=1001(appgroup)

# Check read-only
docker exec secure-container touch /test.txt
# touch: /test.txt: Read-only file system

# Check capabilities
docker inspect secure-container --format='{{.HostConfig.CapAdd}}'
# [NET_BIND_SERVICE]

# Check seccomp
docker exec secure-container cat /proc/self/status | grep Seccomp
# Seccomp: 2

# Check resources
docker inspect secure-container --format='{{.HostConfig.Memory}}'
# 536870912 (512MB)

# Check restart policy
docker inspect secure-container --format='{{.HostConfig.RestartPolicy.Name}}'
# unless-stopped
```

---

## P4.8 Summary: Security Fundamentals

### Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Least Privilege** | Non-root user, minimal capabilities |
| **Defense in Depth** | Multiple security layers |
| **Zero Trust** | Verify everything, trust nothing |
| **Secure by Default** | Configure security at build time |
| **Continuous Monitoring** | Always watch, always scan |

### Security Quick Reference

```bash
# Run container securely
docker run \
  --read-only \                    # Read-only filesystem
  --user 1001:1001 \               # Non-root user
  --cap-drop=ALL \                 # Drop all capabilities
  --cap-add=NET_BIND_SERVICE \     # Add only needed
  --security-opt seccomp=default.json \
  --memory=512M \                  # Memory limit
  --cpus=1 \                       # CPU limit
  --restart=unless-stopped \
  my-image
```

```yaml
# Docker Compose security
services:
  app:
    read_only: true
    user: "1001:1001"
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true
      - seccomp:default.json
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1'
    restart: unless-stopped
```

```dockerfile
# Dockerfile security
FROM python:3.11-slim
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser
USER appuser
HEALTHCHECK CMD python -c "..." || exit 1
```

### The Security Mindset

Remember: **Security is not a one-time task but a continuous process.** Every container you build, every image you pull, every deployment you make should be viewed through a security lens.

**Ask yourself:**
- What's the worst that could happen if this container is compromised?
- What privileges does this container really need?
- Could I make this container more restrictive?
- Have I scanned this image for vulnerabilities?
- Are my dependencies up-to-date?

**Final Thought:** In container security, trust no one and nothing. Verify everything. Secure every layer. Monitor everything. And always assume you've missed something—because you probably have.

# Primers Complete

This concludes the Primer series for Docker users. You now have foundational knowledge in:

| Primer | Topic |
|--------|-------|
| Primer 1 | Linux Fundamentals for Docker |
| Primer 2 | Networking Fundamentals for Docker |
| Primer 3 | Storage and Filesystem Fundamentals |
| Primer 4 | Security Fundamentals for Docker |

These primers provide the essential background knowledge that makes Docker concepts easier to understand and apply. Use them as reference materials when you encounter topics in the main series that build on these fundamentals.

**Happy containerizing! 🐳**
