# Appendix F: Security Reference & Compliance

## The Target

This appendix provides a comprehensive security reference for Nginx, covering security headers, hardening practices, compliance requirements, and security testing. Use this as your security checklist and reference guide for production deployments.

## F.1 Security Headers Quick Reference

### Complete Security Headers Configuration

```nginx
# Add these to your server block for complete security hardening

# 1. HSTS - HTTP Strict Transport Security
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

# 2. Content Security Policy (CSP)
add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self' 'unsafe-inline' 'unsafe-eval';
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https:;
    font-src 'self';
    connect-src 'self';
    frame-ancestors 'none';
    form-action 'self';
    base-uri 'self';
    upgrade-insecure-requests;
    block-all-mixed-content;
" always;

# 3. X-Content-Type-Options
add_header X-Content-Type-Options "nosniff" always;

# 4. X-Frame-Options
add_header X-Frame-Options "DENY" always;

# 5. X-XSS-Protection
add_header X-XSS-Protection "1; mode=block" always;

# 6. Referrer Policy
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# 7. Permissions Policy
add_header Permissions-Policy "
    geolocation=(),
    microphone=(),
    camera=(),
    payment=(),
    usb=(),
    magnetometer=(),
    accelerometer=(),
    gyroscope=(),
    document-domain=(),
    fullscreen=(self)
" always;

# 8. Cross-Origin-Resource-Policy
add_header Cross-Origin-Resource-Policy "same-origin" always;

# 9. Cross-Origin-Opener-Policy
add_header Cross-Origin-Opener-Policy "same-origin" always;

# 10. Cross-Origin-Embedder-Policy
add_header Cross-Origin-Embedder-Policy "require-corp" always;

# 11. Remove Server Header
server_tokens off;
```

### Header Descriptions and Security Impact

| Header | Purpose | Security Impact | Recommended Value |
|--------|---------|----------------|-------------------|
| **Strict-Transport-Security** | Enforce HTTPS | Prevents protocol downgrade attacks | `max-age=63072000; includeSubDomains; preload` |
| **Content-Security-Policy** | Prevent XSS/injection | Blocks inline scripts, prevents data exfiltration | Custom policy based on application |
| **X-Content-Type-Options** | Prevent MIME sniffing | Prevents XSS through MIME type confusion | `nosniff` |
| **X-Frame-Options** | Prevent clickjacking | Prevents site being embedded in iframes | `DENY` or `SAMEORIGIN` |
| **X-XSS-Protection** | Enable browser XSS filter | Adds extra XSS protection | `1; mode=block` |
| **Referrer-Policy** | Control referrer data | Prevents sensitive data leakage | `strict-origin-when-cross-origin` |
| **Permissions-Policy** | Control browser features | Limits API access (geolocation, camera, etc.) | Feature-specific restrictions |
| **Cross-Origin-Resource-Policy** | Cross-origin resource control | Prevents cross-origin data theft | `same-origin` |
| **Cross-Origin-Opener-Policy** | Cross-window communication | Prevents cross-origin attacks | `same-origin` |
| **Cross-Origin-Embedder-Policy** | Cross-origin embedding | Prevents malicious embedding | `require-corp` |

## F.2 TLS/SSL Security Configuration

### Modern TLS Configuration

```nginx
# Complete TLS configuration for maximum security

# SSL certificates
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;

# Modern TLS protocols - only secure versions
ssl_protocols TLSv1.2 TLSv1.3;

# Modern cipher suites - authenticated encryption only
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';

# Server preference - disable to allow client negotiation
ssl_prefer_server_ciphers off;

# Session caching for performance
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1h;
ssl_session_tickets off;

# OCSP stapling for certificate validation
ssl_stapling on;
ssl_stapling_verify on;
resolver 1.1.1.1 8.8.8.8 valid=300s;
resolver_timeout 5s;

# DH parameters for Perfect Forward Secrecy
ssl_dhparam /etc/nginx/ssl/dhparam.pem;

# Disable SSL compression (CRIME attack)
ssl_compression off;

# Enable HSTS for maximum security
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```

### TLS Configuration by Security Level

| Security Level | Protocols | Ciphers | Use Case |
|----------------|-----------|---------|----------|
| **Maximum** | TLSv1.3 only | AEAD only | Government, financial |
| **High** | TLSv1.2, TLSv1.3 | Strong AEAD | Most production |
| **Standard** | TLSv1.1, TLSv1.2, TLSv1.3 | Balanced | Legacy support |
| **Minimum** | All TLS versions | All ciphers | Testing only |

### Generate Strong DH Parameters

```bash
# Generate 2048-bit DH parameters
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

# For maximum security (takes longer)
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 4096

# Verify DH parameters
openssl dhparam -in /etc/nginx/ssl/dhparam.pem -text -noout
```

## F.3 Security Compliance Reference

### OWASP Top 10 Compliance

| OWASP Risk | Nginx Mitigation | Configuration |
|------------|------------------|---------------|
| **A1: Injection** | Request validation, CSP | `if ($query_string ~* "union|select|exec|eval") { return 403; }` |
| **A2: Broken Authentication** | Rate limiting, HSTS | `limit_req zone=auth_limit burst=2 nodelay;` |
| **A3: Sensitive Data Exposure** | TLS, HSTS | `ssl_protocols TLSv1.2 TLSv1.3;` |
| **A4: XXE** | Request validation | Validate XML requests |
| **A5: Broken Access Control** | IP restrictions | `allow 10.0.0.0/8; deny all;` |
| **A6: Security Misconfiguration** | Hide version, headers | `server_tokens off;` |
| **A7: XSS** | CSP, X-XSS-Protection | `add_header Content-Security-Policy` |
| **A8: Insecure Deserialization** | Input validation | Content type validation |
| **A9: Vulnerable Components** | Version updates | Regular updates |
| **A10: Insufficient Logging** | Structured logging | JSON logs with request IDs |

### GDPR Compliance

| GDPR Requirement | Nginx Implementation |
|------------------|---------------------|
| **Right to be Forgotten** | Log rotation, data anonymization |
| **Data Minimization** | Log only necessary fields |
| **Security of Processing** | TLS, security headers |
| **Breach Notification** | Logging, monitoring |
| **Data Protection Impact** | Security testing, audits |

### PCI DSS Compliance

| PCI DSS Requirement | Nginx Implementation |
|--------------------|---------------------|
| **3: Protect Cardholder Data** | TLS encryption |
| **4: Encrypt Transmission** | TLS 1.2+, strong ciphers |
| **6: Secure Configurations** | Hardened configuration |
| **10: Logging and Monitoring** | Structured logs, monitoring |
| **11: Security Testing** | Regular security scans |

## F.4 Security Testing Tools

### Vulnerability Scanning

```bash
# 1. SSL/TLS Scanner (TestSSL)
docker run --rm -it drwetter/testssl.sh https://localhost

# 2. Web Vulnerability Scanner (Nikto)
docker run --rm -it sullo/nikto -h https://localhost

# 3. Nmap Security Scan
nmap -sV -p 80,443 --script ssl-enum-ciphers localhost

# 4. OWASP ZAP (Basic scan)
docker run --rm -v $(pwd):/zap/wrk -it owasp/zap2docker-stable \
    zap-baseline.py -t https://localhost -r report.html

# 5. Security Headers Check
docker run --rm -it cyberpion/security-headers-check https://localhost
```

### Security Monitoring Script

**File: `security-monitor.sh`**

```bash
#!/bin/bash
# security-monitor.sh - Real-time security monitoring

echo "=== Security Monitoring Dashboard ==="
echo ""

# Monitor failed authentication attempts
echo "1. Failed Authentication Attempts (last 5 min):"
grep "401" /var/log/nginx/access.log | tail -20

echo ""
echo "2. Rate Limit Hits (last 5 min):"
grep "429" /var/log/nginx/access.log | tail -20

echo ""
echo "3. Suspicious Requests (last 5 min):"
grep -E "union|select|exec|eval|<script>|../../../" /var/log/nginx/access.log | tail -20

echo ""
echo "4. Error Responses (last 5 min):"
grep -E "5[0-9][0-9]" /var/log/nginx/access.log | tail -20

echo ""
echo "5. SSL/TLS Issues (last 5 min):"
grep -i "ssl\|tls" /var/log/nginx/error.log | tail -10

echo ""
echo "6. Active Connections:"
docker exec nginx-proxy netstat -an | grep ':443' | grep ESTABLISHED | wc -l

echo ""
echo "7. Blocked IPs:"
grep "403" /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
```

### Automated Security Testing

**File: `security-test-suite.sh`**

```bash
#!/bin/bash
# security-test-suite.sh - Automated security testing

echo "=== Automated Security Test Suite ==="
echo ""

# Test 1: Security Headers
echo "Test 1: Security Headers"
echo "------------------------"
curl -k -I https://localhost/api/ | grep -E "Strict-Transport-Security|X-Content-Type-Options|X-Frame-Options|Content-Security-Policy"

# Test 2: TLS Configuration
echo ""
echo "Test 2: TLS Configuration"
echo "------------------------"
nmap -p 443 --script ssl-enum-ciphers localhost

# Test 3: Rate Limiting
echo ""
echo "Test 3: Rate Limiting"
echo "------------------------"
echo "Making 20 rapid requests..."
for i in {1..20}; do
    echo -n "."
    curl -k -s -o /dev/null https://localhost/auth/login
done
echo ""
echo "Checking rate limit responses..."
tail -5 /var/log/nginx/access.log | grep "429"

# Test 4: SQL Injection Protection
echo ""
echo "Test 4: SQL Injection Protection"
echo "------------------------"
curl -k -s -o /dev/null -w "SQL Injection: %{http_code}\n" \
    "https://localhost/api/?id=1 UNION SELECT * FROM users"

# Test 5: XSS Protection
echo ""
echo "Test 5: XSS Protection"
echo "------------------------"
curl -k -s -o /dev/null -w "XSS: %{http_code}\n" \
    "https://localhost/api/?q=<script>alert(1)</script>"

# Test 6: Path Traversal Protection
echo ""
echo "Test 6: Path Traversal Protection"
echo "------------------------"
curl -k -s -o /dev/null -w "Path Traversal: %{http_code}\n" \
    "https://localhost/api/../../../etc/passwd"

# Test 7: Method Override Protection
echo ""
echo "Test 7: Method Override Protection"
echo "------------------------"
curl -k -s -o /dev/null -w "TRACE: %{http_code}\n" \
    -X TRACE https://localhost/api/
curl -k -s -o /dev/null -w "TRACK: %{http_code}\n" \
    -X TRACK https://localhost/api/

echo ""
echo "Security tests complete!"
```

## F.5 Incident Response

### Security Incident Response Flow

```text
1. Detection
   ↓
2. Initial Response (5 minutes)
   └── Identify scope
   └── Isolate affected systems
   └── Preserve evidence
   ↓
3. Investigation (15 minutes)
   └── Analyze logs
   └── Determine attack vector
   └── Identify impacted data
   ↓
4. Containment (30 minutes)
   └── Block attacker IPs
   └── Rotate credentials
   └── Apply emergency patches
   ↓
5. Eradication (1 hour)
   └── Remove malware
   └── Fix vulnerabilities
   └── Update security controls
   ↓
6. Recovery (2 hours)
   └── Restore from backups
   └── Verify system integrity
   └── Gradual service restoration
   ↓
7. Post-Incident (24 hours)
   └── Document incident
   └── Update runbooks
   └── Implement lessons learned
```

### Emergency Security Scripts

**File: `emergency-block.sh`**

```bash
#!/bin/bash
# emergency-block.sh - Emergency IP blocking

if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS> [REASON]"
    exit 1
fi

IP=$1
REASON=${2:-"Security violation"}

# Add to Nginx block list
echo "Adding $IP to block list..."

# Method 1: Geo block
echo "deny $IP;" >> /etc/nginx/conf.d/blocklist.conf

# Method 2: iptables
iptables -A INPUT -s $IP -j DROP

# Reload Nginx
nginx -t && nginx -s reload

echo "IP $IP blocked. Reason: $REASON"
echo "Timestamp: $(date)"

# Log the block
echo "$(date) - Blocked $IP - $REASON" >> /var/log/nginx/security-blocks.log
```

**File: `emergency-rotate-ssl.sh`**

```bash
#!/bin/bash
# emergency-rotate-ssl.sh - Emergency SSL certificate rotation

echo "=== Emergency SSL Rotation ==="

# Backup current certificates
mkdir -p /tmp/ssl-backup-$(date +%Y%m%d)
cp /etc/nginx/ssl/* /tmp/ssl-backup-$(date +%Y%m%d)/

# Generate new certificates
echo "Generating new certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/cert.key \
    -out /etc/nginx/ssl/cert.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$HOSTNAME"

# Set permissions
chmod 600 /etc/nginx/ssl/*.key
chmod 644 /etc/nginx/ssl/*.crt

# Test configuration
nginx -t && nginx -s reload

echo "SSL certificates rotated successfully!"
```

## F.6 Security Audit Checklist

### Production Security Audit

- [ ] **Network Security**
  - [ ] Firewall configured
  - [ ] Only ports 80/443 exposed
  - [ ] Internal services not exposed
  - [ ] Rate limiting implemented

- [ ] **TLS/SSL Security**
  - [ ] TLS 1.2/1.3 only
  - [ ] Strong ciphers configured
  - [ ] HSTS enabled
  - [ ] OCSP stapling enabled
  - [ ] DH parameters generated

- [ ] **Security Headers**
  - [ ] HSTS header present
  - [ ] CSP header configured
  - [ ] X-Content-Type-Options set
  - [ ] X-Frame-Options set
  - [ ] X-XSS-Protection enabled
  - [ ] Referrer-Policy set

- [ ] **Access Control**
  - [ ] Admin endpoints restricted
  - [ ] Debug endpoints restricted
  - [ ] IP whitelisting implemented
  - [ ] Authentication enforced

- [ ] **Request Validation**
  - [ ] SQL injection protection
  - [ ] XSS protection
  - [ ] Path traversal protection
  - [ ] Method validation

- [ ] **Logging & Monitoring**
  - [ ] Structured logging enabled
  - [ ] Request IDs generated
  - [ ] Error logging configured
  - [ ] Security monitoring active

- [ ] **Updates & Maintenance**
  - [ ] Nginx version up-to-date
  - [ ] Certificates not expired
  - [ ] Security patches applied
  - [ ] Regular security scans

---

This security reference provides everything you need to harden your Nginx installation against common threats and maintain compliance with industry standards. Regular security audits and testing are essential for maintaining a strong security posture.
