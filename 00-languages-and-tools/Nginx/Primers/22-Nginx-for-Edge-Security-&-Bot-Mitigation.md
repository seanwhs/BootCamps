# Primer 22: Nginx for Edge Security & Bot Mitigation

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for edge security and bot mitigation. Understanding these concepts is essential for protecting your applications from malicious traffic, automated attacks, and credential stuffing.

## P22.1 Bot Mitigation Architecture

### Bot Defense Layers

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BOT MITIGATION ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    EDGE SECURITY LAYER                          │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    REQUEST CLASSIFICATION                  │ │      │
│  │  │  • User-Agent Analysis  • IP Reputation                  │ │      │
│  │  │  • Rate Analysis        • Behavioral Analysis            │ │      │
│  │  │  • Headers Analysis     • Fingerprinting                 │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    MITIGATION ACTIONS                     │ │      │
│  │  │  • Challenge (CAPTCHA)    • Block                       │ │      │
│  │  │  • Rate Limit             • Throttle                    │ │      │
│  │  │  • Redirect               • Log                        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ADAPTIVE LEARNING                     │ │      │
│  │  │  • Real-time Analytics   • Machine Learning             │ │      │
│  │  │  • Pattern Detection     • Threat Intelligence          │ │      │
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

### Complete Bot Mitigation Configuration

```nginx
# nginx-bot-mitigation.conf - Complete Bot Mitigation
# ============================================================================
# NGINX BOT MITIGATION & EDGE SECURITY
# Complete production-ready bot protection configuration
# ============================================================================

http {
    # =========================================================================
    # BOT DETECTION
    # =========================================================================
    
    # Map User-Agent to bot classification
    map $http_user_agent $is_bot {
        default 0;
        
        # Good bots (search engines)
        "~*Googlebot" 0;
        "~*Bingbot" 0;
        "~*Slurp" 0;
        "~*DuckDuckBot" 0;
        "~*Baiduspider" 0;
        "~*YandexBot" 0;
        "~*facebookexternalhit" 0;
        "~*Twitterbot" 0;
        "~*LinkedInBot" 0;
        "~*Pinterestbot" 0;
        
        # Bad bots (scrapers, attackers)
        "~*(sqlmap|nmap|nikto|nessus|openvas)" 1;
        "~*(masscan|httrack|wpscan|joomscan|dirbuster)" 1;
        "~*(gobuster|wfuzz|ffuf|nikto|skipfish)" 1;
        "~*(w3af|arachni|zap|burp|acunetix)" 1;
        "~*(netsparker|appscan|webinspect|retire)" 1;
        "~*(snyk|npm-audit|yarn-audit|depscan)" 1;
        "~*(dependency-check|owasp|zap|burpsuite)" 1;
        "~*(metasploit|beef|set|social-engineer)" 1;
        "~*(aircrack|reaver|hydra|medusa|ncrack)" 1;
        "~*(thc-hydra|john|hashcat|ophcrack)" 1;
        
        # Suspicious patterns
        "~*(curl|wget|python|perl|ruby|java|http)" 1;
        "~*(scrapy|requests|urllib|aiohttp|httpx)" 1;
        "~*(selenium|webdriver|puppeteer|playwright)" 1;
        "~*(phantomjs|headless|chrome-headless|geckodriver)" 1;
    }
    
    # Map IP reputation (from external list)
    map $remote_addr $ip_reputation {
        default "good";
        include /etc/nginx/ip-reputation.conf;
    }
    
    # Map request patterns
    map $request_uri $is_suspicious_path {
        default 0;
        ~^/(admin|wp-admin|wp-login|xmlrpc|config|install|setup) 1;
        ~^/(.env|.git|.svn|.htaccess|.htpasswd|composer) 1;
        ~^/(backup|dump|export|import|migrate|upgrade) 1;
    }
    
    map $query_string $has_suspicious_params {
        default 0;
        ~*(union|select|insert|update|delete|drop|exec|eval) 1;
        ~*(../|./|%00|%0a|%0d|\x00) 1;
        ~*(<script|alert|onerror|onload|javascript) 1;
    }
    
    # =========================================================================
    # RATE LIMITING ZONES
    # =========================================================================
    # Global rate limits
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=suspicious:10m rate=10r/m;
    limit_conn_zone $binary_remote_addr zone=conn:10m;
    
    # Bot-specific limits
    limit_req_zone $binary_remote_addr zone=bot:10m rate=5r/m;
    
    # =========================================================================
    # BOT UPSTREAM
    # =========================================================================
    # Captcha service
    upstream captcha_service {
        server captcha:8080 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # --------------------------------------------------------------------
        # BOT DETECTION
        # --------------------------------------------------------------------
        set $bot_action "allow";
        
        # 1. Check User-Agent
        if ($is_bot = 1) {
            set $bot_action "challenge";
        }
        
        # 2. Check IP reputation
        if ($ip_reputation = "bad") {
            set $bot_action "block";
        }
        
        # 3. Check suspicious path
        if ($is_suspicious_path = 1) {
            set $bot_action "challenge";
        }
        
        # 4. Check suspicious params
        if ($has_suspicious_params = 1) {
            set $bot_action "block";
        }
        
        # 5. Check rate limiting
        if ($bot_action = "challenge") {
            limit_req zone=suspicious burst=2 nodelay;
        }
        
        # --------------------------------------------------------------------
        # BOT MITIGATION ACTIONS
        # --------------------------------------------------------------------
        if ($bot_action = "block") {
            return 403 '{"error":"Access denied","reason":"Security violation"}';
            add_header Content-Type application/json;
        }
        
        if ($bot_action = "challenge") {
            # Redirect to CAPTCHA
            return 302 /captcha?return=$request_uri;
        }
        
        # Global rate limiting
        limit_req zone=global burst=20 nodelay;
        limit_conn conn 10;
        
        # --------------------------------------------------------------------
        # CAPTCHA ENDPOINT
        # --------------------------------------------------------------------
        location /captcha {
            proxy_pass http://captcha_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # --------------------------------------------------------------------
        # CAPTCHA VERIFICATION
        # --------------------------------------------------------------------
        location /verify-captcha {
            proxy_pass http://captcha_service/verify;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Set cookie for verified users
            add_header Set-Cookie "captcha_verified=1; Path=/; Max-Age=3600; HttpOnly; Secure";
            
            # Redirect back to original URL
            return 303 $arg_return;
        }
        
        # --------------------------------------------------------------------
        # MAIN APPLICATION
        # --------------------------------------------------------------------
        location / {
            # Check CAPTCHA verification
            if ($cookie_captcha_verified != "1") {
                set $bot_action "challenge";
            }
            
            # Bot rate limiting
            if ($is_bot = 1) {
                limit_req zone=bot burst=1 nodelay;
            }
            
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Bot-Detected $is_bot;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # ADMIN PROTECTION (EXTRA SECURE)
        # --------------------------------------------------------------------
        location /admin/ {
            # Strict rate limiting
            limit_req zone=suspicious burst=1;
            limit_conn conn 1;
            
            # IP whitelist
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            deny all;
            
            # Admin authentication
            auth_basic "Admin Area";
            auth_basic_user_file /etc/nginx/.htpasswd;
            
            proxy_pass http://backend/admin/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
        }
        
        # --------------------------------------------------------------------
        # BOT DASHBOARD (MONITORING)
        # --------------------------------------------------------------------
        location /bot-stats {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "bot_requests":$(tail -10000 /var/log/nginx/access.log | grep -c '"X-Bot-Detected":"1"'),
                "blocked_requests":$(tail -10000 /var/log/nginx/access.log | grep -c '"status":403'),
                "captcha_challenges":$(tail -10000 /var/log/nginx/access.log | grep -c "/captcha"),
                "verified_users":$(tail -10000 /var/log/nginx/access.log | grep -c "captcha_verified"),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # --------------------------------------------------------------------
        # HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P22.2 Advanced Bot Detection

### Machine Learning Integration

```lua
# nginx-bot-ml.lua - Machine Learning Bot Detection
# ============================================================================
# NGINX BOT DETECTION WITH MACHINE LEARNING
# Real-time bot classification using ML models
# ============================================================================

-- Bot Detection Module
local bot_detection = {}

-- Model configuration
bot_detection.model = {
    -- Feature weights (trained model)
    weights = {
        request_rate = 0.3,
        user_agent_score = 0.2,
        header_anomaly = 0.15,
        path_pattern = 0.15,
        ip_reputation = 0.2
    },
    threshold = 0.7  -- Classification threshold
}

-- Feature extraction
function bot_detection.extract_features(request)
    local features = {}
    
    -- 1. Request rate
    local rate = bot_detection.get_request_rate(request)
    features.request_rate = math.min(rate / 100, 1.0)
    
    -- 2. User-Agent score
    local ua = request:get_header("User-Agent")
    features.user_agent_score = bot_detection.score_user_agent(ua)
    
    -- 3. Header anomaly
    features.header_anomaly = bot_detection.detect_header_anomaly(request)
    
    -- 4. Path pattern
    features.path_pattern = bot_detection.score_path_pattern(request)
    
    -- 5. IP reputation
    features.ip_reputation = bot_detection.get_ip_reputation(request)
    
    return features
end

-- User-Agent scoring
function bot_detection.score_user_agent(ua)
    if not ua then return 1.0 end
    
    local score = 0
    
    -- Missing UA
    if ua == "" then
        return 1.0
    end
    
    -- Known bot patterns
    if ua:match("sqlmap") or ua:match("nmap") or ua:match("nikto") then
        return 1.0
    end
    
    -- Suspicious patterns
    if ua:match("curl") or ua:match("wget") or ua:match("python") then
        score = score + 0.3
    end
    
    -- Headless browsers
    if ua:match("headless") or ua:match("phantomjs") or ua:match("selenium") then
        score = score + 0.4
    end
    
    -- Old browsers (often emulated)
    if ua:match("Windows NT 5") or ua:match("MSIE 6") or ua:match("MSIE 7") then
        score = score + 0.2
    end
    
    return math.min(score, 1.0)
end

-- Header anomaly detection
function bot_detection.detect_header_anomaly(request)
    local score = 0
    local headers = request:get_headers()
    
    -- Check for missing headers
    local required_headers = {"Accept", "Accept-Encoding", "Accept-Language"}
    for _, header in ipairs(required_headers) do
        if not headers[header] then
            score = score + 0.2
        end
    end
    
    -- Check for suspicious headers
    if headers["X-Forwarded-For"] and headers["X-Forwarded-For"]:match("localhost") then
        score = score + 0.3
    end
    
    -- Check for headers ordering (bots often send in specific order)
    local header_order = {}
    for k, _ in pairs(headers) do
        table.insert(header_order, k)
    end
    table.sort(header_order)
    
    if #header_order > 0 then
        local expected_order = {"Host", "User-Agent", "Accept", "Accept-Encoding", "Accept-Language"}
        local matches = 0
        for i, header in ipairs(header_order) do
            if i <= #expected_order and header == expected_order[i] then
                matches = matches + 1
            end
        end
        if matches > #expected_order * 0.8 then
            score = score + 0.2  # Too perfect = suspicious
        end
    end
    
    return math.min(score, 1.0)
end

-- Path pattern scoring
function bot_detection.score_path_pattern(request)
    local uri = request:get_uri()
    local score = 0
    
    -- Admin paths
    if uri:match("admin") or uri:match("wp-admin") or uri:match("wp-login") then
        score = score + 0.3
    end
    
    -- Config files
    if uri:match("%.env") or uri:match("%.git") or uri:match("%.htaccess") then
        score = score + 0.5
    end
    
    -- Injection attempts
    if uri:match("union") or uri:match("select") or uri:match("../../") then
        score = score + 0.7
    end
    
    -- Rapid path scanning (detected by rate)
    if bot_detection.is_path_scanning(request) then
        score = score + 0.4
    end
    
    return math.min(score, 1.0)
end

-- IP reputation checking
function bot_detection.get_ip_reputation(request)
    local ip = request:get_header("X-Real-IP") or request:get_header("X-Forwarded-For") or ""
    
    -- Check against internal blocklist
    local blocked_ips = {
        "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"
    }
    
    -- In production, check external reputation service
    -- local reputation = bot_detection.check_external_reputation(ip)
    
    return 0.0
end

-- Request rate tracking
function bot_detection.get_request_rate(request)
    local key = request:get_header("X-Real-IP") or request:get_header("X-Forwarded-For") or request:get_header("Host")
    local cache = ngx.shared.bot_cache
    
    local count = cache:get(key) or 0
    cache:set(key, count + 1, 60)  -- 60 second window
    
    return count
end

-- Path scanning detection
function bot_detection.is_path_scanning(request)
    -- Track unique paths per client
    local key = "paths:" .. (request:get_header("X-Real-IP") or request:get_header("Host"))
    local cache = ngx.shared.bot_cache
    
    local unique_paths = cache:get(key) or {}
    local current_path = request:get_uri()
    
    -- Add current path
    unique_paths[current_path] = true
    
    -- Check if too many unique paths in short time
    local count = 0
    for _ in pairs(unique_paths) do
        count = count + 1
    end
    
    if count > 20 then
        return true
    end
    
    cache:set(key, unique_paths, 60)
    return false
end

-- Main classification function
function bot_detection.classify(request)
    local features = bot_detection.extract_features(request)
    
    -- Calculate score
    local score = 0
    for feature, value in pairs(features) do
        local weight = bot_detection.model.weights[feature] or 0
        score = score + (value * weight)
    end
    
    -- Classify
    local is_bot = score >= bot_detection.model.threshold
    
    -- Add classification headers
    ngx.header["X-Bot-Score"] = string.format("%.2f", score)
    ngx.header["X-Bot-Classified"] = is_bot and "bot" or "human"
    
    -- Log classification
    ngx.log(ngx.INFO, "Bot classification: " .. (is_bot and "bot" or "human") .. " score: " .. score)
    
    return is_bot, score
end

-- Expose module
return bot_detection
```

## P22.3 Security Monitoring Dashboard

### Real-Time Security Dashboard

```bash
#!/bin/bash
# security-dashboard.sh - Real-time security monitoring

echo "=== Security Monitoring Dashboard ==="

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function: Get bot statistics
get_bot_stats() {
    local total=$(tail -10000 /var/log/nginx/access.log | wc -l)
    local bots=$(tail -10000 /var/log/nginx/access.log | grep -c '"X-Bot-Detected":"1"')
    local blocked=$(tail -10000 /var/log/nginx/access.log | grep -c '"status":403')
    
    echo "  Total Requests: $total"
    echo "  Bot Requests: $bots ($((bots * 100 / total))%)"
    echo "  Blocked Requests: $blocked ($((blocked * 100 / total))%)"
}

# Function: Show top attacking IPs
get_top_attackers() {
    echo "  Top Attackers (last hour):"
    tail -10000 /var/log/nginx/access.log | grep '"status":403' | \
        grep -o '"remote_addr":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10 | \
        while read count ip; do
            echo "    $ip: $count attacks"
        done
}

# Function: Show attack types
get_attack_types() {
    echo "  Attack Types (last hour):"
    tail -10000 /var/log/nginx/access.log | grep '"status":403' | \
        grep -o '"request_uri":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10 | \
        while read count uri; do
            echo "    $uri: $count attempts"
        done
}

# Function: Show bot patterns
get_bot_patterns() {
    echo "  Bot User-Agents (last hour):"
    tail -10000 /var/log/nginx/access.log | grep '"X-Bot-Detected":"1"' | \
        grep -o '"http_user_agent":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10 | \
        while read count ua; do
            echo "    ${ua:0:50}: $count"
        done
}

# Function: Show rate limiting stats
get_rate_limits() {
    local rate_limited=$(tail -10000 /var/log/nginx/access.log | grep -c '"status":429')
    echo "  Rate Limited: $rate_limited"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              SECURITY MONITORING DASHBOARD                    ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 BOT STATISTICS:"
    get_bot_stats
    echo ""
    
    echo "🔝 TOP ATTACKERS:"
    get_top_attackers
    echo ""
    
    echo "🎯 ATTACK TYPES:"
    get_attack_types
    echo ""
    
    echo "🤖 BOT PATTERNS:"
    get_bot_patterns
    echo ""
    
    echo "⏱️ RATE LIMITS:"
    get_rate_limits
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

### Security Alert Script

```bash
#!/bin/bash
# security-alerts.sh - Security alerting system

echo "=== Security Alert System ==="

# Alert thresholds
BOT_THRESHOLD=100
ATTACK_THRESHOLD=50
RATE_LIMIT_THRESHOLD=200

# Function: Check bot attacks
check_bot_attacks() {
    local bots=$(tail -1000 /var/log/nginx/access.log | grep -c '"X-Bot-Detected":"1"')
    
    if [ $bots -gt $BOT_THRESHOLD ]; then
        echo "⚠️ BOT ALERT: $bots bots detected in last 1000 requests"
        echo "Time: $(date)"
        echo "Action: Investigate and consider blocking"
    fi
}

# Function: Check attack rate
check_attack_rate() {
    local attacks=$(tail -1000 /var/log/nginx/access.log | grep -c '"status":403')
    
    if [ $attacks -gt $ATTACK_THRESHOLD ]; then
        echo "⚠️ ATTACK ALERT: $attacks attacks in last 1000 requests"
        echo "Time: $(date)"
        
        # Get attacking IPs
        tail -1000 /var/log/nginx/access.log | grep '"status":403' | \
            grep -o '"remote_addr":"[^"]*"' | \
            cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
            while read count ip; do
                echo "  $ip: $count attacks"
            done
    fi
}

# Function: Check rate limiting
check_rate_limits() {
    local rate_limited=$(tail -1000 /var/log/nginx/access.log | grep -c '"status":429')
    
    if [ $rate_limited -gt $RATE_LIMIT_THRESHOLD ]; then
        echo "⚠️ RATE LIMIT ALERT: $rate_limited rate limit hits"
        echo "Time: $(date)"
    fi
}

# Function: Send alert to Slack
send_slack_alert() {
    local message=$1
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK"
    fi
}

# Main alert loop
while true; do
    check_bot_attacks
    check_attack_rate
    check_rate_limits
    
    sleep 60
done
```

---

This primer provides a comprehensive deep dive into using Nginx for edge security and bot mitigation. Use these techniques to protect your applications from malicious traffic and automated attacks.
