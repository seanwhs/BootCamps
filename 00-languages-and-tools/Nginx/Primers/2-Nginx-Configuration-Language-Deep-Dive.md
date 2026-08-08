# Primer 2: Nginx Configuration Language Deep Dive

## The Target

This primer provides a comprehensive, deep-dive explanation of the Nginx configuration language. Understanding the syntax, structure, and evaluation rules is essential for writing correct, maintainable, and powerful Nginx configurations.

## P2.1 Configuration File Structure

### Main Configuration Hierarchy

```text
/etc/nginx/
├── nginx.conf                 # Main configuration file
├── conf.d/                    # Additional config files
│   ├── default.conf
│   ├── ssl.conf
│   └── security.conf
├── sites-available/           # Virtual host definitions
│   ├── example.com.conf
│   └── api.example.com.conf
├── sites-enabled/             # Enabled virtual hosts (symlinks)
│   ├── example.com.conf -> ../sites-available/example.com.conf
│   └── api.example.com.conf -> ../sites-available/api.example.com.conf
├── ssl/                       # SSL certificates
│   ├── cert.pem
│   └── key.pem
├── snippets/                  # Reusable configuration snippets
│   ├── proxy-headers.conf
│   └── security-headers.conf
└── modules/                   # Loadable modules
    └── ngx_http_module.so
```

### Configuration Contexts

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CONFIGURATION CONTEXTS                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  main (global)                                                              │
│  ├── events { }              # Connection handling                         │
│  │                                                                          │
│  └── http { }                # HTTP protocol settings                      │
│      │                                                                      │
│      ├── upstream { }        # Backend server groups                       │
│      │                                                                      │
│      ├── server { }          # Virtual host                                │
│      │   │                                                                  │
│      │   ├── location { }    # URL pattern matching                        │
│      │   │                                                                  │
│      │   ├── location { }    # Multiple locations                          │
│      │   │                                                                  │
│      │   └── server { }      # Multiple server blocks                      │
│      │                                                                      │
│      └── server { }          # Another virtual host                        │
│                                                                             │
│  Additional contexts:                                                       │
│  • if { }                    # Conditional evaluation                      │
│  • upstream { }              # Server groups                               │
│  • map { }                   # Variable mapping                            │
│  • geo { }                   # IP address mapping                          │
│  • split_clients { }         # Traffic splitting                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Directive Types

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DIRECTIVE TYPES                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. SIMPLE DIRECTIVES                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ directive value;                                                      │   │
│  │                                                                     │   │
│  │ Example:                                                             │   │
│  │ worker_processes auto;                                               │   │
│  │ keepalive_timeout 65;                                                │   │
│  │ root /var/www/html;                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  2. BLOCK DIRECTIVES                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ directive { ... }                                                    │   │
│  │                                                                     │   │
│  │ Example:                                                             │   │
│  │ server {                                                             │   │
│  │     listen 80;                                                       │   │
│  │     server_name example.com;                                         │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  3. ARRAY DIRECTIVES                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ directive value1 value2 value3;                                     │   │
│  │                                                                     │   │
│  │ Example:                                                             │   │
│  │ server_name example.com www.example.com api.example.com;             │   │
│  │ allow 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16;                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  4. DEPRECATED DIRECTIVES                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ ❌ Avoid: if, set (in server/location)                              │   │
│  │ ✅ Use: map, geo, split_clients                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P2.2 Directive Inheritance and Scope

### Inheritance Rules

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INHERITANCE RULES                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Nginx directives follow a "nearest wins" inheritance model:                │
│                                                                             │
│  Global Level                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ http {                                                               │   │
│  │     gzip on;                     # Inherited by all servers          │   │
│  │     proxy_set_header Host $host;  # Inherited by all locations       │   │
│  │                                                                     │   │
│  │     server {                                                         │   │
│  │         server_name example.com;                                     │   │
│  │         gzip off;                 # Overrides global                 │   │
│  │                                                                     │   │
│  │         location /api/ {                                             │   │
│  │             proxy_set_header Host api.example.com;  # Overrides      │   │
│  │             gzip on;              # Overrides server                 │   │
│  │         }                                                            │   │
│  │     }                                                                │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Inheritance Hierarchy:                                                     │
│  1. Location-specific (highest priority)                                   │
│  2. Server-specific                                                         │
│  3. HTTP-level (lowest priority)                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Merge Rules

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MERGE RULES                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  DIRECTIVES THAT MERGE (Additive)                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ proxy_set_header                                                    │   │
│  │ add_header                                                          │   │
│  │ allow/deny                                                          │   │
│  │ access_log                                                          │   │
│  │ error_log                                                           │   │
│  │                                                                     │   │
│  │ Example:                                                             │   │
│  │ http {                                                               │   │
│  │     add_header X-Frame-Options DENY;                                 │   │
│  │                                                                     │   │
│  │     server {                                                         │   │
│  │         add_header X-Content-Type-Options nosniff;                  │   │
│  │         # Results in both headers                                    │   │
│  │     }                                                                │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  DIRECTIVES THAT OVERRIDE (Replace)                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ root                                                                │   │
│  │ index                                                               │   │
│  │ expires                                                             │   │
│  │ proxy_pass                                                          │   │
│  │ listen                                                              │   │
│  │ server_name                                                         │   │
│  │                                                                     │   │
│  │ Example:                                                             │   │
│  │ http {                                                               │   │
│  │     root /var/www/html;                                             │   │
│  │                                                                     │   │
│  │     server {                                                         │   │
│  │         root /var/www/example;      # Overrides global              │   │
│  │     }                                                                │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P2.3 Variable System

### Built-in Variables

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VARIABLE CATEGORIES                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  REQUEST VARIABLES                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ $request_method      GET/POST/PUT/DELETE                           │   │
│  │ $request_uri         /api/users?page=1                             │   │
│  │ $uri                 /api/users                                    │   │
│  │ $args                page=1                                        │   │
│  │ $query_string        page=1&limit=10                               │   │
│  │ $is_args             ?                                             │   │
│  │ $http_*              $http_user_agent, $http_referer               │   │
│  │ $remote_addr         192.168.1.100                                 │   │
│  │ $remote_port         54321                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  SERVER VARIABLES                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ $host                example.com                                   │   │
│  │ $hostname            server1                                       │   │
│  │ $server_name         example.com                                   │   │
│  │ $server_port         443                                           │   │
│  │ $server_addr         10.0.0.1                                      │   │
│  │ $scheme              https                                         │   │
│  │ $request_time        0.123                                         │   │
│  │ $request_id          abc123def456                                  │   │
│  │ $status              200                                           │   │
│  │ $body_bytes_sent     1024                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  SSL VARIABLES                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ $ssl_protocol        TLSv1.3                                       │   │
│  │ $ssl_cipher          ECDHE-RSA-AES128-GCM-SHA256                   │   │
│  │ $ssl_session_id      abc123...                                     │   │
│  │ $ssl_client_verify   SUCCESS                                       │   │
│  │ $ssl_client_cert     -----BEGIN CERTIFICATE...                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  UPSTREAM VARIABLES                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ $upstream_addr       10.0.0.1:8000                                 │   │
│  │ $upstream_status     200                                           │   │
│  │ $upstream_response_time  0.123                                     │   │
│  │ $upstream_cache_status    HIT/MISS/BYPASS                          │   │
│  │ $upstream_connect_time    0.001                                    │   │
│  │ $upstream_header_time     0.005                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Variable Evaluation

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VARIABLE EVALUATION                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  When variables are evaluated:                                              │
│                                                                             │
│  1. Variables are evaluated lazily (on demand)                              │
│  2. Some variables exist only in specific phases                           │
│  3. Variables may be empty if not available                                │
│                                                                             │
│  Example:                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ location /api/ {                                                    │   │
│  │     # $request_id is generated when accessed                        │   │
│  │     proxy_set_header X-Request-ID $request_id;                      │   │
│  │                                                                     │   │
│  │     # $upstream_addr is only available after proxy_pass             │   │
│  │     add_header X-Upstream $upstream_addr;                           │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Variable Availability:                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Phase 1-3:   $remote_addr, $request_method, $uri                   │   │
│  │ Phase 4-5:   $host, $server_name                                   │   │
│  │ Phase 6:     $limit_rate, $proxy_host                              │   │
│  │ Phase 7-8:   $proxy_add_x_forwarded_for, $upstream_*               │   │
│  │ Phase 9-10:  $status, $body_bytes_sent, $request_time              │   │
│  │ Phase 11:    Log variables only                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P2.4 Conditional Logic

### If Directive (Use with Caution)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        IF DIRECTIVE - WARNING!                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ⚠️  The if directive is often misused and can cause unexpected behavior   │
│  ⚠️  It creates a new location context                                    │
│  ⚠️  It can break try_files and other directives                          │
│  ⚠️  Use map, geo, or rewrite instead when possible                      │
│                                                                             │
│  SAFE USES:                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Return errors                                                     │   │
│  │ if ($request_method !~ ^(GET|HEAD)$) {                              │   │
│  │     return 405;                                                     │   │
│  │ }                                                                   │   │
│  │                                                                     │   │
│  │ # Return redirects                                                  │   │
│  │ if ($http_user_agent ~* "MSIE") {                                   │   │
│  │     rewrite ^(.*)$ /ie/$1 break;                                    │   │
│  │ }                                                                   │   │
│  │                                                                     │   │
│  │ # Simple conditions with return                                     │   │
│  │ if ($http_referer !~* "example.com") {                              │   │
│  │     return 403;                                                     │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  UNSAFE USES (AVOID):                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # ❌ Don't do this - breaks try_files                               │   │
│  │ if (!-f $request_filename) {                                         │   │
│  │     rewrite ^ /index.php last;                                       │   │
│  │ }                                                                   │   │
│  │                                                                     │   │
│  │ # ❌ Don't do this - creates location context                       │   │
│  │ if ($request_uri ~* "^/admin/") {                                    │   │
│  │     proxy_pass http://admin;                                         │   │
│  │ }                                                                   │   │
│  │                                                                     │   │
│  │ # ❌ Don't do this - unpredictable behavior                         │   │
│  │ if ($http_cookie ~* "session=([^;]+)") {                            │   │
│  │     set $session_id $1;                                              │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Map Directive (Safe Alternative)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MAP DIRECTIVE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  The map directive creates a new variable based on another variable:        │
│                                                                             │
│  Syntax:                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ map $source $destination {                                           │   │
│  │     default value;                                                   │   │
│  │     pattern1 value1;                                                 │   │
│  │     pattern2 value2;                                                 │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Examples:                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # User agent detection                                              │   │
│  │ map $http_user_agent $is_mobile {                                    │   │
│  │     default 0;                                                       │   │
│  │     ~*"(android|iphone|ipad|mobile)" 1;                             │   │
│  │ }                                                                    │   │
│  │                                                                     │   │
│  │ # Request method mapping                                            │   │
│  │ map $request_method $method_type {                                   │   │
│  │     default read;                                                    │   │
│  │     GET read;                                                        │   │
│  │     HEAD read;                                                       │   │
│  │     POST write;                                                      │   │
│  │     PUT write;                                                       │   │
│  │     DELETE write;                                                    │   │
│  │ }                                                                    │   │
│  │                                                                     │   │
│  │ # Host-based routing                                                │   │
│  │ map $host $backend {                                                 │   │
│  │     default default_backend:8000;                                   │   │
│  │     api.example.com api_backend:8000;                               │   │
│  │     admin.example.com admin_backend:5000;                           │   │
│  │ }                                                                    │   │
│  │                                                                     │   │
│  │ # Country-based routing                                             │   │
│  │ map $geoip_country_code $dc {                                       │   │
│  │     default us-east;                                                │   │
│  │     US us-east;                                                     │   │
│  │     DE eu-west;                                                     │   │
│  │     FR eu-west;                                                     │   │
│  │     JP ap-northeast;                                                │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Geo Directive (IP Mapping)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         GEO DIRECTIVE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  The geo directive maps IP addresses to values:                             │
│                                                                             │
│  Syntax:                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ geo $variable {                                                     │   │
│  │     default value;                                                   │   │
│  │     IP_ADDRESS value;                                                │   │
│  │     CIDR_RANGE value;                                                │   │
│  │     include file;                                                    │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Examples:                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Allowlist/blocklist                                               │   │
│  │ geo $blocked {                                                       │   │
│  │     default 0;                                                       │   │
│  │     192.168.1.100 1;                                                │   │
│  │     10.0.0.0/8 0;                                                   │   │
│  │     include /etc/nginx/blocklist.conf;                              │   │
│  │ }                                                                    │   │
│  │                                                                     │   │
│  │ # Whitelist internal IPs                                           │   │
│  │ geo $internal {                                                     │   │
│  │     default 0;                                                       │   │
│  │     10.0.0.0/8 1;                                                   │   │
│  │     172.16.0.0/12 1;                                                │   │
│  │     192.168.0.0/16 1;                                               │   │
│  │     127.0.0.1 1;                                                    │   │
│  │ }                                                                    │   │
│  │                                                                     │   │
│  │ # Environment-based routing                                        │   │
│  │ geo $environment {                                                  │   │
│  │     default production;                                              │   │
│  │     127.0.0.1 development;                                           │   │
│  │     10.0.0.0/8 staging;                                              │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Split Clients Directive

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SPLIT CLIENTS DIRECTIVE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  The split_clients directive splits traffic based on a variable:            │
│                                                                             │
│  Syntax:                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ split_clients $source_variable $dest_variable {                      │   │
│  │     percentage% value1;                                              │   │
│  │     percentage% value2;                                              │   │
│  │     * default_value;                                                │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Examples:                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # A/B Testing - 10% to version B                                    │   │
│  │ split_clients $remote_addr $ab_group {                               │   │
│  │     10% "B";                                                         │   │
│  │     * "A";                                                           │   │
│  │ }                                                                    │   │
│  │                                                                     │   │
│  │ # Canary Deployment - 5% to new version                             │   │
│  │ split_clients $remote_addr $canary_group {                           │   │
│  │     5% "new";                                                        │   │
│  │     * "old";                                                         │   │
│  │ }                                                                    │   │
│  │                                                                     │   │
│  │ # Multi-variant testing                                             │   │
│  │ split_clients $remote_addr $variant {                               │   │
│  │     20% "A";                                                         │   │
│  │     20% "B";                                                         │   │
│  │     20% "C";                                                         │   │
│  │     20% "D";                                                         │   │
│  │     * "E";                                                           │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Using in location:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ location /api/ {                                                    │   │
│  │     if ($ab_group = "B") {                                           │   │
│  │         proxy_pass http://api-v2/;                                   │   │
│  │     }                                                               │   │
│  │     proxy_pass http://api-v1/;                                      │   │
│  │ }                                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P2.5 Rewrite and Redirect

### Rewrite Directive

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         REWRITE DIRECTIVE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Syntax: rewrite regex replacement [flag];                                  │
│                                                                             │
│  Flags:                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ last    - Stop processing and restart search for new location       │   │
│  │ break   - Stop processing but don't restart search                  │   │
│  │ redirect - Return 302 (temporary redirect)                          │   │
│  │ permanent - Return 301 (permanent redirect)                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Examples:                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Simple redirect                                                    │   │
│  │ rewrite ^/old-path$ /new-path permanent;                             │   │
│  │                                                                     │   │
│  │ # Pattern-based rewrite                                             │   │
│  │ rewrite ^/blog/(.*)$ /articles/$1 permanent;                         │   │
│  │                                                                     │   │
│  │ # Remove .html extension                                            │   │
│  │ rewrite ^/(.*)\.html$ /$1 permanent;                                 │   │
│  │                                                                     │   │
│  │ # Add trailing slash                                                │   │
│  │ rewrite ^([^.]*[^/])$ $1/ permanent;                                 │   │
│  │                                                                     │   │
│  │ # Query string rewrite                                              │   │
│  │ rewrite ^/search$ /search/?q=$arg_q permanent;                      │   │
│  │                                                                     │   │
│  │ # With last flag (internal rewrite)                                 │   │
│  │ rewrite ^/api/v1/(.*)$ /api/v2/$1 last;                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Rewrite vs Return:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Use return for simple redirects (more efficient)                  │   │
│  │ return 301 https://example.com$request_uri;                         │   │
│  │                                                                     │   │
│  │ # Use rewrite for pattern-based transformations                    │   │
│  │ rewrite ^/blog/(.*)$ /articles/$1 permanent;                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P2.6 Includes and Modularization

### Include Directive

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INCLUDE DIRECTIVE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Syntax: include file_or_pattern;                                           │
│                                                                             │
│  Examples:                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Include specific file                                              │   │
│  │ include /etc/nginx/sites-available/example.com.conf;                │   │
│  │                                                                     │   │
│  │ # Include all files in directory                                    │   │
│  │ include /etc/nginx/conf.d/*.conf;                                   │   │
│  │                                                                     │   │
│  │ # Include snippet                                                   │   │
│  │ include /etc/nginx/snippets/security-headers.conf;                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Best Practices:                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Organize by purpose                                               │   │
│  │ /etc/nginx/                                                          │   │
│  │ ├── conf.d/                                                         │   │
│  │ │   ├── ssl.conf           # SSL settings                           │   │
│  │ │   ├── security.conf      # Security headers                       │   │
│  │ │   ├── caching.conf       # Cache settings                         │   │
│  │ │   └── rate-limit.conf    # Rate limiting                         │   │
│  │ ├── sites-enabled/         # Enabled virtual hosts                  │   │
│  │ └── snippets/              # Reusable snippets                      │   │
│  │     ├── proxy-headers.conf  # Common proxy headers                   │   │
│  │     └── security-headers.conf # Common security headers              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Example Snippet: snippets/proxy-headers.conf                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ proxy_set_header Host $host;                                        │   │
│  │ proxy_set_header X-Real-IP $remote_addr;                            │   │
│  │ proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;        │   │
│  │ proxy_set_header X-Forwarded-Proto $scheme;                         │   │
│  │ proxy_set_header X-Request-ID $request_id;                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P2.7 Advanced Patterns

### Dynamic Upstream Selection

```nginx
# Map-based upstream selection
upstream default_backend {
    server default:8000;
}

upstream api_backend {
    server api:8000;
}

upstream admin_backend {
    server admin:5000;
}

# Dynamic routing
map $host $backend {
    default default_backend;
    api.example.com api_backend;
    admin.example.com admin_backend;
    ~^dev-.*\.example\.com$ dev_backend;
}

server {
    listen 80;
    server_name .example.com;
    
    location / {
        proxy_pass http://$backend;
    }
}
```

### Conditional Headers

```nginx
# Set headers based on conditions
map $scheme $forwarded_proto {
    default $scheme;
    https https;
    http http;
}

map $http_x_forwarded_proto $real_proto {
    default $scheme;
    https https;
    http http;
}

location / {
    proxy_set_header X-Forwarded-Proto $real_proto;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Port $server_port;
}
```

### Graceful Degradation

```nginx
# Fallback when upstream fails
location /api/ {
    # Primary upstream
    proxy_pass http://api-primary/;
    
    # Fallback if primary fails
    proxy_next_upstream error timeout http_500 http_502 http_503;
    proxy_next_upstream_tries 2;
    proxy_next_upstream_timeout 5s;
    
    # Custom error handling
    error_page 500 502 503 504 = @fallback;
}

location @fallback {
    # Serve cached version or static fallback
    proxy_pass http://api-fallback/;
    add_header X-Fallback "true";
}
```

---

This primer provides a deep understanding of the Nginx configuration language. Master these concepts to write clean, maintainable, and powerful configurations.
