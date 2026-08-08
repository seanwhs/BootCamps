# Primer 16: Nginx for Web Application Firewall (WAF)

## The Target

This primer provides a comprehensive deep-dive guide to implementing a Web Application Firewall (WAF) using Nginx. This is a complete, production-ready implementation that protects your applications from common web attacks.

## P16.1 WAF Architecture

### WAF Security Model

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WAF SECURITY ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    WAF (Nginx + ModSecurity)                      │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    REQUEST INSPECTION                     │ │      │
│  │  │  • Method Validation    • URL Validation                  │ │      │
│  │  │  • Header Validation    • Body Validation                 │ │      │
│  │  │  • Parameter Validation • Cookie Validation               │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ATTACK DETECTION                       │ │      │
│  │  │  • SQL Injection      • XSS Attacks                       │ │      │
│  │  │  • Path Traversal     • Command Injection                 │ │      │
│  │  │  • LFI/RFI            • SSRF Attacks                      │ │      │
│  │  │  • CSRF               • File Upload Attacks               │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    RESPONSE INSPECTION                    │ │      │
│  │  │  • Data Leakage      • Error Disclosure                   │ │      │
│  │  │  • Content Injection • Header Injection                   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    RATE LIMITING                          │ │      │
│  │  │  • Global Limits    • Endpoint Limits                     │ │      │
│  │  │  • IP Reputation    • User-Agent Blocking                 │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│                           ┌─────────────────┐                             │
│                           │  Application    │                             │
│                           │  Backend        │                             │
│                           └─────────────────┘                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete WAF Configuration

```nginx
# nginx-waf.conf - Complete WAF Configuration
# ============================================================================
# NGINX WEB APPLICATION FIREWALL
# Complete production-ready WAF configuration
# ============================================================================

# ============================================================================
# LOAD MODSECURITY MODULE
# ============================================================================
load_module modules/ngx_http_modsecurity_module.so;

# ============================================================================
# GLOBAL SETTINGS
# ============================================================================
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# ============================================================================
# EVENTS
# ============================================================================
events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
    accept_mutex off;
}

# ============================================================================
# HTTP BLOCK
# ============================================================================
http {
    # ------------------------------------------------------------------------
    # BASIC SETTINGS
    # ------------------------------------------------------------------------
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server_tokens off;
    charset utf-8;

    # ------------------------------------------------------------------------
    # MODSECURITY CONFIGURATION
    # ------------------------------------------------------------------------
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsecurity/modsecurity.conf;

    # ------------------------------------------------------------------------
    # REQUEST VALIDATION
    # ------------------------------------------------------------------------
    # Buffer settings for WAF
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    client_max_body_size 10M;

    # Timeouts
    client_body_timeout 10s;
    client_header_timeout 10s;
    send_timeout 10s;
    keepalive_timeout 30s;

    # ------------------------------------------------------------------------
    # LOGGING
    # ------------------------------------------------------------------------
    log_format waf escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request_id":"$request_id",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"modsecurity_action":"$modsecurity_action",'
        '"modsecurity_rule_id":"$modsecurity_rule_id",'
        '"modsecurity_msg":"$modsecurity_msg"'
    '}';

    access_log /var/log/nginx/waf.log waf;
    error_log /var/log/nginx/error.log warn;

    # =========================================================================
    # WAF CUSTOM RULES
    # =========================================================================
    # SQL Injection Protection
    # =========================================================================
    location / {
        # SQL Injection patterns
        set $sql_injection 0;

        if ($query_string ~* "(?i)(union|select|insert|update|delete|drop|truncate|alter|create|execute|exec|eval|declare|begin|commit|rollback|grant|revoke|rename|replace|restore|backup)") {
            set $sql_injection 1;
        }

        if ($query_string ~* "(?i)(and|or|not|in|like|between|exists|any|all|having|group by|order by)") {
            set $sql_injection 1;
        }

        if ($query_string ~* "(?i)(--|#|/\*|\*/|%27|%22|%3B|%2D%2D|%23|%2F%2A|%2A%2F)") {
            set $sql_injection 1;
        }

        if ($request_body ~* "(?i)(union|select|insert|update|delete|drop|truncate|alter|create|execute|exec|eval|declare|begin|commit|rollback|grant|revoke|rename|replace|restore|backup)") {
            set $sql_injection 1;
        }

        if ($sql_injection = 1) {
            return 403;
        }

        # XSS Protection
        set $xss_attack 0;

        if ($query_string ~* "(?i)(<script|alert\(|onerror|onload|onclick|onmouseover|onfocus|onblur|onchange|onkeydown|onkeyup|onkeypress|onmousedown|onmouseup)") {
            set $xss_attack 1;
        }

        if ($query_string ~* "(?i)(javascript:|vbscript:|expression:|on[a-z]+=|eval\(|document\.|window\.|location\.|cookie\.|alert\(|confirm\(|prompt\()") {
            set $xss_attack 1;
        }

        if ($request_body ~* "(?i)(<script|alert\(|onerror|onload|onclick|onmouseover|onfocus|onblur|onchange|onkeydown|onkeyup|onkeypress|onmousedown|onmouseup)") {
            set $xss_attack 1;
        }

        if ($xss_attack = 1) {
            return 403;
        }

        # Path Traversal Protection
        set $path_traversal 0;

        if ($request_uri ~* "\.\./") {
            set $path_traversal 1;
        }

        if ($request_uri ~* "(?i)(/etc/passwd|/etc/shadow|/proc/self/environ|/boot.ini|/win.ini)") {
            set $path_traversal 1;
        }

        if ($path_traversal = 1) {
            return 403;
        }

        # Command Injection Protection
        set $cmd_injection 0;

        if ($query_string ~* "(?i)(;|\||&|\$\(|`|\${|\$\()") {
            set $cmd_injection 1;
        }

        if ($query_string ~* "(?i)(ping|nmap|netstat|ifconfig|whoami|id|uname|ps|kill|shutdown|reboot|rm|mv|cp|wget|curl|nc|telnet|ssh|ftp)") {
            set $cmd_injection 1;
        }

        if ($cmd_injection = 1) {
            return 403;
        }

        # File Upload Validation
        if ($request_method = POST) {
            set $file_type 0;
            
            # Check content type
            if ($content_type ~* "(?i)(image/jpeg|image/png|image/gif|application/pdf)") {
                set $file_type 1;
            }

            if ($file_type = 0) {
                return 415;
            }

            # Check file size
            if ($content_length > 5000000) {
                return 413;
            }
        }

        # User-Agent Blocking
        if ($http_user_agent ~* "(?i)(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan|joomscan|dirbuster|gobuster|wfuzz|ffuf|nikto|skipfish|w3af|arachni|zap|burp|acunetix|netsparker|appscan|webinspect|retire|retire.js|snyk|npm-audit|yarn-audit|depscan|dependency-check|owasp)") {
            return 403;
        }

        # Block empty User-Agent
        if ($http_user_agent = "") {
            return 403;
        }

        # Block suspicious headers
        if ($http_x_forwarded_for ~* "(?i)(127\.0\.0\.1|10\.|172\.16\.|192\.168\.)") {
            set $suspicious_header 1;
        }

        if ($http_x_forwarded_for ~* "(?i)(localhost|\.\./|%00)") {
            set $suspicious_header 1;
        }

        if ($suspicious_header = 1) {
            return 403;
        }

        # Block null bytes
        if ($request_uri ~* "\x00") {
            return 400;
        }

        # Block request smuggling
        if ($http_content_length ~* "^[0-9]+$") {
            set $content_length_valid 1;
        }

        if ($content_length_valid = 0) {
            return 400;
        }

        proxy_pass http://backend/;
    }

    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=suspicious:10m rate=10r/m;

    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # Global Rate Limiting
        limit_req zone=global burst=20 nodelay;

        # Security Headers
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

        # Location-specific rules
        location /login/ {
            # Stricter rate limiting for login
            limit_req zone=suspicious burst=2 nodelay;

            # Additional login protection
            if ($http_user_agent ~* "(?i)(curl|wget|python|perl|ruby|java|http)") {
                return 403;
            }

            if ($request_method != POST) {
                return 405;
            }

            proxy_pass http://auth_backend/login/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        location /api/ {
            # API-specific WAF rules
            limit_req zone=global burst=20 nodelay;

            # Validate API key
            if ($http_x_api_key = "") {
                return 401;
            }

            # Validate content type for POST/PUT
            if ($request_method = POST) {
                if ($content_type !~ "application/json") {
                    return 415;
                }
            }

            # Check for API abuse patterns
            if ($query_string ~* "(?i)(page|limit|offset|sort|order|filter)") {
                set $api_params 1;
            }

            if ($request_body ~* "(?i)(password|secret|token|key)") {
                set $sensitive_data 1;
            }

            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;
        }

        location /admin/ {
            # Very strict WAF rules for admin
            limit_req zone=suspicious burst=2 nodelay;

            # IP-based access control
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;

            # Additional admin security
            auth_basic "Admin Area";
            auth_basic_user_file /etc/nginx/.htpasswd;

            # Admin-specific headers
            add_header X-Robots-Tag "noindex, nofollow" always;
            add_header Cache-Control "no-store, no-cache, must-revalidate" always;

            proxy_pass http://admin_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # WAF status endpoint
        location /waf-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;

            return 200 '{
                "status":"active",
                "rules_loaded": true,
                "modsecurity":"enabled",
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }

        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }

    # HTTP redirect
    server {
        listen 80;
        listen [::]:80;
        server_name _;

        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

        return 301 https://$host$request_uri;
    }
}
```

## P16.2 ModSecurity Rules

### ModSecurity Configuration

```nginx
# /etc/nginx/modsecurity/modsecurity.conf
# ============================================================================
# MODSECURITY CONFIGURATION
# ============================================================================

# ----------------------------------------------------------------------------
# RULE ENGINE
# ----------------------------------------------------------------------------
SecRuleEngine On
SecRequestBodyAccess On
SecResponseBodyAccess On

# ----------------------------------------------------------------------------
# PARSERS
# ----------------------------------------------------------------------------
SecDefaultAction "phase:1,log,auditlog,pass"
SecDefaultAction "phase:2,log,auditlog,pass"

# ----------------------------------------------------------------------------
# FILE LIMITS
# ----------------------------------------------------------------------------
SecRequestBodyLimit 10485760
SecRequestBodyNoFilesLimit 131072
SecRequestBodyInMemoryLimit 131072
SecResponseBodyLimit 1048576

# ----------------------------------------------------------------------------
# AUDIT LOG
# ----------------------------------------------------------------------------
SecAuditEngine RelevantOnly
SecAuditLogRelevantStatus "^(?:5|4(?!04))"
SecAuditLogParts ABIJDEFHZ
SecAuditLogType Serial
SecAuditLog /var/log/nginx/audit.log

# ----------------------------------------------------------------------------
# CORE RULES
# ----------------------------------------------------------------------------
Include /etc/nginx/modsecurity/owasp-crs/crs-setup.conf
Include /etc/nginx/modsecurity/owasp-crs/rules/*.conf

# ----------------------------------------------------------------------------
# CUSTOM RULES
# ----------------------------------------------------------------------------
# SQL Injection
SecRule ARGS|ARGS_NAMES|REQUEST_BODY "@rx (?i)(union|select|insert|update|delete|drop|truncate|alter|create|execute|exec|eval|declare|begin|commit|rollback|grant|revoke|rename|replace|restore|backup)" \
    "id:10001,phase:2,deny,status:403,msg:'SQL Injection Attempt'"

# XSS Attacks
SecRule ARGS|ARGS_NAMES|REQUEST_BODY "@rx (?i)(<script|alert\(|onerror|onload|onclick|onmouseover|onfocus|onblur|onchange|onkeydown|onkeyup|onkeypress|onmousedown|onmouseup)" \
    "id:10002,phase:2,deny,status:403,msg:'XSS Attack Attempt'"

# Path Traversal
SecRule ARGS|ARGS_NAMES "@rx (\.\./|/etc/passwd|/etc/shadow|/proc/self/environ|/boot.ini|/win.ini)" \
    "id:10003,phase:2,deny,status:403,msg:'Path Traversal Attempt'"

# Command Injection
SecRule ARGS|ARGS_NAMES|REQUEST_BODY "@rx (?i)(;|\||&|\$\()" \
    "id:10004,phase:2,deny,status:403,msg:'Command Injection Attempt'"

# Suspicious User-Agent
SecRule REQUEST_HEADERS:User-Agent "@rx (?i)(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan|joomscan|dirbuster|gobuster|wfuzz|ffuf)" \
    "id:10005,phase:1,deny,status:403,msg:'Suspicious User-Agent'"

# Request Smuggling
SecRule REQUEST_HEADERS:Content-Length "@rx ^[0-9]+$" \
    "id:10006,phase:1,deny,status:400,msg:'Invalid Content-Length'"

# Null Byte Attacks
SecRule ARGS|ARGS_NAMES|REQUEST_URI "@rx \x00" \
    "id:10007,phase:2,deny,status:400,msg:'Null Byte Attack'"

# Backdoor Access
SecRule REQUEST_URI "@rx (wp-config|config|settings|database|db)\.(php|ini|yaml|yml|json|xml)" \
    "id:10008,phase:1,deny,status:403,msg:'Configuration File Access'"

# File Upload Attacks
SecRule FILES|FILES_NAMES|REQUEST_FILENAME "@rx (\.php|\.phtml|\.jsp|\.asp|\.aspx|\.cgi|\.pl|\.py|\.rb)" \
    "id:10009,phase:2,deny,status:403,msg:'Malicious File Upload'"

# Sensitive Data Exposure
SecRule RESPONSE_BODY "@rx (password|secret|token|key|api_key|access_token|refresh_token)" \
    "id:10010,phase:4,deny,status:403,msg:'Sensitive Data Exposure'"
```

## P16.3 WAF Monitoring & Alerting

### WAF Monitoring Script

```bash
#!/bin/bash
# waf-monitor.sh - WAF monitoring and alerting

echo "=== WAF Monitoring ==="

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function: Check WAF status
check_waf_status() {
    local status=$(curl -s http://localhost/waf-status 2>/dev/null)
    if [ -n "$status" ]; then
        echo -e "${GREEN}✓ WAF is active${NC}"
        echo "$status" | python -m json.tool
    else
        echo -e "${RED}✗ WAF is not responding${NC}"
    fi
}

# Function: Analyze blocked requests
analyze_blocked() {
    local blocked=$(tail -1000 /var/log/nginx/waf.log | grep -c '"status":403')
    echo "Blocked requests (last 1000): $blocked"
}

# Function: Show top attacking IPs
top_attackers() {
    echo ""
    echo "Top Attackers (last hour):"
    tail -10000 /var/log/nginx/waf.log | grep '"status":403' | \
        python -c "
import json, sys, collections
ips = collections.Counter()
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'remote_addr' in data:
            ips[data['remote_addr']] += 1
    except:
        pass
for ip, count in ips.most_common(10):
    print(f'  {ip}: {count} attacks')
"
}

# Function: Show attack types
attack_types() {
    echo ""
    echo "Attack Types (last hour):"
    tail -10000 /var/log/nginx/waf.log | grep '"status":403' | \
        grep -o '"modsecurity_msg":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10
}

# Function: Show suspicious User-Agents
suspicious_ua() {
    echo ""
    echo "Suspicious User-Agents (last hour):"
    tail -10000 /var/log/nginx/waf.log | grep '"status":403' | \
        grep -o '"http_user_agent":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10
}

# Function: Send alerts
send_alert() {
    local message=$1
    local severity=$2

    # Email alert
    echo "$message" | mail -s "[WAF Alert] $severity" admin@example.com

    # Slack alert (if configured)
    # curl -X POST -H 'Content-type: application/json' \
    #     --data "{\"text\":\"$message\"}" $SLACK_WEBHOOK_URL

    # PagerDuty alert (if configured)
    # curl -X POST -H 'Content-type: application/json' \
    #     --data "{\"service_key\":\"$PAGERDUTY_KEY\",\"event_type\":\"trigger\",\"description\":\"$message\"}" \
    #     https://events.pagerduty.com/generic/2010-04-15/create_event.json
}

# Main monitoring loop
echo "Starting WAF monitoring..."
echo ""

check_waf_status
echo ""

while true; do
    TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
    
    echo "[$TIMESTAMP] WAF Status:"
    analyze_blocked
    
    # Check for attack spikes
    ATTACKS=$(tail -1000 /var/log/nginx/waf.log | grep -c '"status":403')
    
    if [ $ATTACKS -gt 100 ]; then
        send_alert "Attack spike detected: $ATTACKS attacks in last 1000 requests" "CRITICAL"
        echo -e "${RED}⚠️ ATTACK SPIKE DETECTED: $ATTACKS attacks${NC}"
        top_attackers
        attack_types
        suspicious_ua
    fi
    
    echo "----------------------------------------"
    sleep 60
done
```

### WAF Alert Rules

```bash
#!/bin/bash
# waf-alerts.sh - WAF alert rules

echo "=== WAF Alert Rules ==="

# Alert thresholds
ATTACK_THRESHOLD=100
BLOCK_IP_THRESHOLD=50

# Check for high attack rate
check_attack_rate() {
    local attacks=$(tail -1000 /var/log/nginx/waf.log | grep -c '"status":403')
    
    if [ $attacks -gt $ATTACK_THRESHOLD ]; then
        echo "⚠️ HIGH ATTACK RATE: $attacks attacks in last 1000 requests"
        echo "Time: $(date)"
        echo "Action: Investigate immediately"
        
        # Get attacking IPs
        tail -1000 /var/log/nginx/waf.log | grep '"status":403' | \
            python -c "
import json, sys, collections
ips = collections.Counter()
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'remote_addr' in data:
            ips[data['remote_addr']] += 1
    except:
        pass
print('Top Attackers:')
for ip, count in ips.most_common(5):
    print(f'  {ip}: {count} attacks')
"
    fi
}

# Check for blocked IPs
check_blocked_ips() {
    local blocked_ips=$(tail -10000 /var/log/nginx/waf.log | grep '"status":403' | \
        python -c "
import json, sys, collections
ips = collections.Counter()
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'remote_addr' in data:
            ips[data['remote_addr']] += 1
    except:
        pass
print(sum(1 for count in ips.values() if count > $BLOCK_IP_THRESHOLD))
")
    
    if [ $blocked_ips -gt 0 ]; then
        echo "⚠️ $blocked_ips IPs exceeded block threshold"
        
        # Show IPs to block
        tail -10000 /var/log/nginx/waf.log | grep '"status":403' | \
            python -c "
import json, sys, collections
ips = collections.Counter()
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'remote_addr' in data:
            ips[data['remote_addr']] += 1
    except:
        pass
print('IPs to block:')
for ip, count in ips.most_common():
    if count > $BLOCK_IP_THRESHOLD:
        print(f'  {ip}: {count} attacks')
"
    fi
}

# Check for attack patterns
check_attack_patterns() {
    local patterns=$(tail -10000 /var/log/nginx/waf.log | grep '"status":403' | \
        grep -o '"modsecurity_msg":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5)
    
    if [ -n "$patterns" ]; then
        echo ""
        echo "Top Attack Patterns:"
        echo "$patterns"
    fi
}

# Check for suspicious User-Agents
check_suspicious_ua() {
    local ua=$(tail -10000 /var/log/nginx/waf.log | grep '"status":403' | \
        grep -o '"http_user_agent":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5)
    
    if [ -n "$ua" ]; then
        echo ""
        echo "Suspicious User-Agents:"
        echo "$ua"
    fi
}

# Main alert check
check_attack_rate
check_blocked_ips
check_attack_patterns
check_suspicious_ua

echo ""
echo "Alert check complete: $(date)"
```

---

This primer provides a comprehensive deep dive into implementing a Web Application Firewall using Nginx. Use these techniques to protect your applications from common web attacks and ensure security compliance.
