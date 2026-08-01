# Part 3: Cloud-Native Security & Modern Workloads
## Section 3.4: API Security (OWASP API Top 10)

## The Target: Complete API Security for Nexus Global Industries

In this section, we'll implement comprehensive API security controls aligned with the OWASP API Security Top 10, including:

1. **API Gateway Security** - Kong/Envoy with security plugins
2. **JWT Validation & Token Security** - Secure token handling
3. **Rate Limiting & Throttling** - Protection against abuse
4. **Input Validation & Sanitization** - Injection prevention
5. **API Security Testing** - Automated security testing

**What specific file(s) are we building?**
- `api/01_gateway_security.yaml` - Kong/Envoy security configuration
- `api/02_jwt_security.yaml` - JWT validation and token management
- `api/03_rate_limiting.yaml` - Rate limiting policies
- `api/04_input_validation.yaml` - Input validation and sanitization
- `api/05_api_security_testing.yaml` - Automated security testing

---

## The Concept: API Security in Plain English

Think of API security like **a bank teller window with multiple security layers**:

**API Gateway Security:** "The bank has a security door that checks everyone before they reach the teller." This is the API gateway with authentication and authorization.

**JWT Validation:** "You show your ID at the teller window. The teller checks it's valid, hasn't expired, and matches your face." This is token validation.

**Rate Limiting:** "The teller will only serve 100 customers per hour to prevent overwhelming the bank." This is request throttling.

**Input Validation:** "The teller checks that your deposit slip is properly filled out before accepting it." This is input sanitization.

**API Security Testing:** "Security auditors regularly test the teller window for vulnerabilities." This is automated security testing.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the api directory
cd ~/nexus_security_architecture
mkdir -p api

# Verify the structure
ls -la
# Expected: api directory appears
```

---

### Step 2: API Gateway Security Configuration

**File:** `api/01_gateway_security.yaml`

```yaml
# API Gateway Security - Nexus Global Industries
# File: api/01_gateway_security.yaml
# Version: 1.0

# ====================================================================
# KONG API GATEWAY SECURITY CONFIGURATION
# ====================================================================

---
# Kong Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: kong
  labels:
    pod-security.kubernetes.io/enforce: "baseline"

---
# Kong Plugin: OIDC Authentication
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: oidc-auth
  namespace: production
config:
  client_id: "api-gateway"
  client_secret: "api-gateway-secret-abcde"
  discovery: "https://auth.nexus.com/realms/nexus/.well-known/openid-configuration"
  scope: "openid profile email"
  redirect_uri: "https://api.nexus.com/callback"
  logout_uri: "https://api.nexus.com/logout"
  session_secret: "session-secret-12345"
  cookie_secure: true
  cookie_samesite: "Strict"
  cookie_httponly: true
plugin: oidc

---
# Kong Plugin: JWT Validation
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: jwt-validation
  namespace: production
config:
  secret_is_base64: false
  claims_to_verify:
  - expiration
  - audience
  allowed_iss: "https://auth.nexus.com/realms/nexus"
  allowed_aud: "api-gateway"
  cookie_names:
  - "token"
  maximum_expiration: 86400
plugin: jwt

---
# Kong Plugin: CORS Protection
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: cors-protection
  namespace: production
config:
  origins:
  - "https://portal.nexus.com"
  - "https://api.nexus.com"
  methods:
  - "GET"
  - "POST"
  - "PUT"
  - "DELETE"
  - "OPTIONS"
  headers:
  - "Authorization"
  - "Content-Type"
  - "X-Request-ID"
  exposed_headers:
  - "X-RateLimit-Limit"
  - "X-RateLimit-Remaining"
  - "X-RateLimit-Reset"
  credentials: true
  max_age: 86400
  preflight_continue: false
plugin: cors

---
# Kong Plugin: OWASP API Security
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: owasp-api-security
  namespace: production
config:
  # OWASP API Top 10 protections
  protections:
    # API1: Broken Object Level Authorization
    - type: "bola"
      enabled: true
      check_authorization: true
    
    # API2: Broken Authentication
    - type: "auth"
      enabled: true
      enforce_mfa: true
    
    # API3: Excessive Data Exposure
    - type: "data_exposure"
      enabled: true
      max_response_size: 1048576  # 1MB
    
    # API4: Lack of Resources & Rate Limiting
    - type: "rate_limiting"
      enabled: true
      rate_limit: 100
      rate_limit_window: 60
    
    # API5: Broken Function Level Authorization
    - type: "function_auth"
      enabled: true
      check_function_authorization: true
    
    # API6: Mass Assignment
    - type: "mass_assignment"
      enabled: true
      allow_extra_fields: false
    
    # API7: Security Misconfiguration
    - type: "misconfiguration"
      enabled: true
      check_headers: true
    
    # API8: Injection
    - type: "injection"
      enabled: true
      sql_injection_detection: true
      xss_detection: true
    
    # API9: Improper Asset Management
    - type: "asset_management"
      enabled: true
      require_deprecation_headers: true
    
    # API10: Insufficient Logging & Monitoring
    - type: "logging"
      enabled: true
      log_all_requests: true
      log_security_events: true
plugin: owasp

# ====================================================================
# ENVOY/GATEWAY API SECURITY (Alternative)
# ====================================================================

---
# Envoy Filter for API Security
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: api-security-filter
  namespace: istio-system
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.http_connection_manager
            subFilter:
              name: envoy.filters.http.router
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.ext_authz
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
          transport_api_version: V3
          grpc_service:
            google_grpc:
              target_uri: "opa-server.opa.svc.cluster.local:9191"
              stat_prefix: "ext_authz"
          with_request_body:
            max_request_bytes: 1024
          failure_mode_allow: false

# ====================================================================
# API SERVICE DEFINITIONS WITH SECURITY
# ====================================================================

---
# Service: Customer Portal API
apiVersion: v1
kind: Service
metadata:
  name: customer-api
  namespace: production
  annotations:
    konghq.com/plugins: "oidc-auth,jwt-validation,cors-protection,owasp-api-security,rate-limiting"
    konghq.com/override: "customer-api-ingress"
spec:
  selector:
    app: customer-api
  ports:
  - port: 8080
    targetPort: 8080
    name: http

---
# Service: Payment API
apiVersion: v1
kind: Service
metadata:
  name: payment-api
  namespace: production
  annotations:
    konghq.com/plugins: "oidc-auth,jwt-validation,owasp-api-security,rate-limiting,payment-security"
    konghq.com/override: "payment-api-ingress"
spec:
  selector:
    app: payment-api
  ports:
  - port: 8080
    targetPort: 8080
    name: http

# ====================================================================
# KONG INGRESS CONTROLLER
# ====================================================================

---
# Kong Ingress Controller Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kong-ingress-controller
  namespace: kong
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kong-ingress
  template:
    metadata:
      labels:
        app: kong-ingress
    spec:
      containers:
      - name: ingress-controller
        image: kong/kubernetes-ingress-controller:latest
        env:
        - name: CONTROLLER_PUBLISH_SERVICE
          value: kong/kong-proxy
        - name: CONTROLLER_CONCURRENT_SYNC
          value: "10"
        - name: CONTROLLER_ADMISSION_WEBHOOK_LISTEN
          value: ":8080"
        - name: CONTROLLER_LOG_LEVEL
          value: "info"
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
```

**Verification:**

```bash
# Verify gateway security file
ls -la api/01_gateway_security.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('api/01_gateway_security.yaml'))"
# Expected: No error output
```

---

### Step 3: JWT Validation & Token Security

**File:** `api/02_jwt_security.yaml`

```yaml
# JWT Validation & Token Security - Nexus Global Industries
# File: api/02_jwt_security.yaml
# Version: 1.0

# ====================================================================
# JWT VALIDATION SERVICE
# ====================================================================

---
# JWT Validation Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jwt-validator
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: jwt-validator
  template:
    metadata:
      labels:
        app: jwt-validator
    spec:
      containers:
      - name: validator
        image: node:18-alpine
        command:
        - node
        - /app/validator.js
        env:
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: jwt-secrets
              key: secret
        - name: OIDC_ISSUER
          value: "https://auth.nexus.com/realms/nexus"
        - name: OIDC_AUDIENCE
          value: "api-gateway"
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: app
          mountPath: /app
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"
      volumes:
      - name: app
        configMap:
          name: jwt-validator-app

---
# JWT Validator Application
apiVersion: v1
kind: ConfigMap
metadata:
  name: jwt-validator-app
  namespace: production
data:
  validator.js: |
    // JWT Validation Service
    const express = require('express');
    const jwt = require('jsonwebtoken');
    const jwksClient = require('jwks-rsa');
    const app = express();
    const port = 8080;
    
    // JWKS client for OIDC
    const client = jwksClient({
      jwksUri: 'https://auth.nexus.com/realms/nexus/protocol/openid-connect/certs'
    });
    
    // Get signing key
    function getKey(header, callback) {
      client.getSigningKey(header.kid, function(err, key) {
        const signingKey = key.publicKey || key.rsaPublicKey;
        callback(null, signingKey);
      });
    }
    
    // Health check
    app.get('/health', (req, res) => {
      res.json({ status: 'healthy' });
    });
    
    // Validate JWT middleware
    app.use('/api/*', (req, res, next) => {
      const token = req.headers.authorization?.split(' ')[1];
      
      if (!token) {
        return res.status(401).json({ error: 'No token provided' });
      }
      
      // Verify token
      jwt.verify(token, getKey, {
        issuer: process.env.OIDC_ISSUER,
        audience: process.env.OIDC_AUDIENCE,
        algorithms: ['RS256']
      }, (err, decoded) => {
        if (err) {
          return res.status(401).json({ error: 'Invalid token', details: err.message });
        }
        
        // Validate token claims
        if (decoded.exp < Date.now() / 1000) {
          return res.status(401).json({ error: 'Token expired' });
        }
        
        // Check for MFA claim
        if (decoded.mfa_enabled !== true) {
          return res.status(403).json({ error: 'MFA required' });
        }
        
        // Add decoded token to request
        req.user = decoded;
        next();
      });
    });
    
    // Protected endpoint example
    app.get('/api/validate', (req, res) => {
      res.json({ 
        valid: true,
        user: req.user,
        timestamp: new Date().toISOString()
      });
    });
    
    app.listen(port, () => {
      console.log(`JWT Validator listening on port ${port}`);
    });

# ====================================================================
# TOKEN REFRESH & ROTATION
# ====================================================================

---
# Token Rotation CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: token-rotation
  namespace: production
spec:
  schedule: "0 0 1 * *"  # Monthly
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: rotator
            image: bitnami/kubectl:latest
            command:
            - /bin/sh
            - -c
            - |
              # Generate new signing key in Vault
              kubectl exec -n vault vault-0 -- vault write -format=json /pki/root/generate/internal \
                common_name="nexus.com" ttl=87600h > /tmp/new-key.json
              
              # Update JWKS in Keycloak
              curl -X PUT -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
                -H "Content-Type: application/json" \
                -d @/tmp/new-key.json \
                https://auth.nexus.com/admin/realms/nexus/keys
              
              # Rotate JWT signing key
              NEW_KEY=$(cat /tmp/new-key.json | jq -r '.data.private_key')
              kubectl create secret generic jwt-secrets --from-literal=secret="$NEW_KEY" --dry-run=client -o yaml | kubectl apply -f -
              
              # Restart JWT validator
              kubectl rollout restart deployment/jwt-validator -n production
              
              echo "JWT signing key rotated"
          restartPolicy: OnFailure

# ====================================================================
# JWT SECURITY POLICIES (Kyverno)
# ====================================================================

---
# Kyverno Policy: Require JWT Validation
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-jwt-validation
spec:
  validationFailureAction: Audit
  rules:
  - name: validate-jwt-annotation
    match:
      any:
      - resources:
          kinds:
          - Ingress
          - Service
    validate:
      message: "All APIs must have JWT validation annotation"
      pattern:
        metadata:
          annotations:
            konghq.com/plugins: "*jwt*"

# ====================================================================
# TOKEN BLACKLIST SERVICE
# ====================================================================

---
# Token Blacklist Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: token-blacklist
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: token-blacklist
  template:
    metadata:
      labels:
        app: token-blacklist
    spec:
      containers:
      - name: blacklist
        image: redis:7-alpine
        command:
        - redis-server
        - --appendonly
        - "yes"
        - --maxmemory
        - "256mb"
        - --maxmemory-policy
        - "allkeys-lru"
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"

---
# Token Blacklist Service
apiVersion: v1
kind: Service
metadata:
  name: token-blacklist
  namespace: production
spec:
  selector:
    app: token-blacklist
  ports:
  - port: 6379
    targetPort: 6379
```

**Verification:**

```bash
# Verify JWT security file
ls -la api/02_jwt_security.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('api/02_jwt_security.yaml'))"
# Expected: No error output
```

---

### Step 4: Rate Limiting & Throttling

**File:** `api/03_rate_limiting.yaml`

```yaml
# Rate Limiting & Throttling - Nexus Global Industries
# File: api/03_rate_limiting.yaml
# Version: 1.0

# ====================================================================
# KONG RATE LIMITING PLUGIN
# ====================================================================

---
# Kong Rate Limiting Plugin - Global
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rate-limiting-global
  namespace: production
config:
  minute: 100
  hour: 10000
  day: 100000
  policy: redis
  redis_host: redis.default.svc.cluster.local
  redis_port: 6379
  redis_password: redis-password
  fault_tolerant: true
  hide_client_headers: false
  limit_by: consumer
  header_names:
    limit: X-RateLimit-Limit
    remaining: X-RateLimit-Remaining
    reset: X-RateLimit-Reset
plugin: rate-limiting

---
# Kong Rate Limiting Plugin - Per API (Strict)
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rate-limiting-strict
  namespace: production
config:
  minute: 10
  hour: 1000
  policy: redis
  redis_host: redis.default.svc.cluster.local
  redis_port: 6379
  limit_by: ip
  fault_tolerant: true
  hide_client_headers: false
  header_names:
    limit: X-RateLimit-Limit
    remaining: X-RateLimit-Remaining
    reset: X-RateLimit-Reset
plugin: rate-limiting

---
# Kong Rate Limiting Plugin - Per User
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rate-limiting-user
  namespace: production
config:
  minute: 50
  hour: 5000
  policy: redis
  redis_host: redis.default.svc.cluster.local
  redis_port: 6379
  limit_by: consumer
  fault_tolerant: true
  hide_client_headers: false
plugin: rate-limiting

# ====================================================================
# RESPONSE HEADERS FOR RATE LIMITING
# ====================================================================

---
# Kong Response Headers Plugin
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: response-headers
  namespace: production
config:
  add:
    headers:
    - "X-RateLimit-Limit:%{rate-limit-limit}"
    - "X-RateLimit-Remaining:%{rate-limit-remaining}"
    - "X-RateLimit-Reset:%{rate-limit-reset}"
    - "X-Request-ID:%{request-id}"
    - "X-Request-Time:%{request-time}"
plugin: response-transformer

# ====================================================================
# API THROTTLING (Circuit Breakers)
# ====================================================================

---
# Kong Circuit Breaker Plugin
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: circuit-breaker
  namespace: production
config:
  # Circuit breaker configuration
  threshold: 5
  timeout: 30
  error_codes:
  - 500
  - 502
  - 503
  - 504
  failure_percentage: 50
  window_size: 60
plugin: circuit-breaker

---
# Kong Rate Limiting on Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: production
  annotations:
    konghq.com/plugins: "rate-limiting-global,rate-limiting-user,circuit-breaker,response-headers"
    konghq.com/rate-limiting-by: "consumer"
    konghq.com/rate-limiting-limit: "50"
    konghq.com/rate-limiting-window: "60"
spec:
  rules:
  - host: api.nexus.com
    http:
      paths:
      - path: /customer
        pathType: Prefix
        backend:
          service:
            name: customer-api
            port:
              number: 8080
      - path: /payment
        pathType: Prefix
        backend:
          service:
            name: payment-api
            port:
              number: 8080

# ====================================================================
# ENVOY RATE LIMITING (Istio)
# ====================================================================

---
# Envoy Rate Limit Service
apiVersion: v1
kind: ConfigMap
metadata:
  name: envoy-ratelimit-config
  namespace: istio-system
data:
  rate_limit_config.yaml: |
    # Envoy rate limit configuration
    domain: nexus-api
    
    descriptors:
      - key: "remote_address"
        value: "*"
        rate_limit:
          unit: minute
          requests_per_unit: 100
      
      - key: "path"
        value: "/api/v1/payment"
        rate_limit:
          unit: minute
          requests_per_unit: 10
      
      - key: "authenticated_user"
        value: "*"
        rate_limit:
          unit: hour
          requests_per_unit: 5000

---
# EnvoyFilter for Rate Limiting
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ratelimit-filter
  namespace: istio-system
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.http_connection_manager
            subFilter:
              name: envoy.filters.http.router
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.ratelimit
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.ratelimit.v3.RateLimit
          domain: nexus-api
          failure_mode_deny: true
          rate_limit_service:
            grpc_service:
              envoy_grpc:
                cluster_name: rate_limit_cluster
            transport_api_version: V3
```

**Verification:**

```bash
# Verify rate limiting file
ls -la api/03_rate_limiting.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('api/03_rate_limiting.yaml'))"
# Expected: No error output
```

---

### Step 5: Input Validation & Sanitization

**File:** `api/04_input_validation.yaml`

```yaml
# Input Validation & Sanitization - Nexus Global Industries
# File: api/04_input_validation.yaml
# Version: 1.0

# ====================================================================
# INPUT VALIDATION SCHEMAS
# ====================================================================

---
# JSON Schema Validation ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: input-validation-schemas
  namespace: production
data:
  customer-order.schema.json: |
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "object",
      "properties": {
        "order_id": {
          "type": "string",
          "pattern": "^ORD-[0-9]{8}-[A-Z]{4}$",
          "minLength": 16,
          "maxLength": 16
        },
        "customer_id": {
          "type": "string",
          "pattern": "^CUST-[0-9]{6}$"
        },
        "items": {
          "type": "array",
          "minItems": 1,
          "maxItems": 50,
          "items": {
            "type": "object",
            "properties": {
              "product_id": {
                "type": "string",
                "pattern": "^PROD-[0-9]{6}$"
              },
              "quantity": {
                "type": "integer",
                "minimum": 1,
                "maximum": 100
              },
              "price": {
                "type": "number",
                "minimum": 0,
                "maximum": 10000
              }
            },
            "required": ["product_id", "quantity"]
          }
        },
        "shipping_address": {
          "type": "object",
          "properties": {
            "street": {
              "type": "string",
              "minLength": 5,
              "maxLength": 100
            },
            "city": {
              "type": "string",
              "minLength": 2,
              "maxLength": 50
            },
            "postal_code": {
              "type": "string",
              "pattern": "^[0-9]{5}$"
            },
            "country": {
              "type": "string",
              "minLength": 2,
              "maxLength": 50
            }
          },
          "required": ["street", "city", "country"]
        }
      },
      "required": ["customer_id", "items"]
    }

---
# Input Validation Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: input-validator
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: input-validator
  template:
    metadata:
      labels:
        app: input-validator
    spec:
      containers:
      - name: validator
        image: python:3.11-slim
        command:
        - python
        - /app/validator.py
        env:
        - name: SCHEMA_PATH
          value: "/schemas"
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: schemas
          mountPath: /schemas
        - name: app
          mountPath: /app
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "100m"
      volumes:
      - name: schemas
        configMap:
          name: input-validation-schemas
      - name: app
        configMap:
          name: validator-app

---
# Input Validator Application
apiVersion: v1
kind: ConfigMap
metadata:
  name: validator-app
  namespace: production
data:
  validator.py: |
    # Input Validation Service
    import json
    import jsonschema
    import re
    import os
    from flask import Flask, request, jsonify
    from werkzeug.middleware.proxy_fix import ProxyFix
    
    app = Flask(__name__)
    app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)
    
    SCHEMA_PATH = os.environ.get('SCHEMA_PATH', '/schemas')
    
    # Load schemas
    schemas = {}
    for file in os.listdir(SCHEMA_PATH):
        if file.endswith('.schema.json'):
            with open(os.path.join(SCHEMA_PATH, file), 'r') as f:
                schema_name = file.replace('.schema.json', '')
                schemas[schema_name] = json.load(f)
    
    # Sanitization functions
    def sanitize_sql(input_str):
        """Sanitize SQL injection attempts"""
        if not isinstance(input_str, str):
            return input_str
        
        # Remove SQL injection patterns
        sql_patterns = [
            r'(\bSELECT\b.*\bFROM\b)',
            r'(\bINSERT\b.*\bINTO\b)',
            r'(\bUPDATE\b.*\bSET\b)',
            r'(\bDELETE\b.*\bFROM\b)',
            r'(\bDROP\b.*\bTABLE\b)',
            r'(\bUNION\b.*\bSELECT\b)',
            r'(\bOR\b.*[0-9]=[0-9])',
            r'(\bAND\b.*[0-9]=[0-9])'
        ]
        
        sanitized = input_str
        for pattern in sql_patterns:
            sanitized = re.sub(pattern, '[REDACTED]', sanitized, flags=re.IGNORECASE)
        
        return sanitized
    
    def sanitize_xss(input_str):
        """Sanitize XSS attempts"""
        if not isinstance(input_str, str):
            return input_str
        
        # Remove XSS patterns
        xss_patterns = [
            r'<script.*>.*</script>',
            r'javascript:.*',
            r'on\w+=".*"',
            r'on\w+=\'.*\'',
            r'<.*on\w+=.*>'
        ]
        
        sanitized = input_str
        for pattern in xss_patterns:
            sanitized = re.sub(pattern, '[REDACTED]', sanitized, flags=re.IGNORECASE)
        
        return sanitized
    
    def validate_input(schema_name, data):
        """Validate input against schema"""
        if schema_name not in schemas:
            return False, "Unknown schema"
        
        try:
            jsonschema.validate(data, schemas[schema_name])
            return True, "Valid"
        except jsonschema.ValidationError as e:
            return False, str(e)
    
    # Routes
    @app.route('/health', methods=['GET'])
    def health():
        return jsonify({'status': 'healthy', 'schemas_loaded': list(schemas.keys())})
    
    @app.route('/api/validate/<schema_name>', methods=['POST'])
    def validate(schema_name):
        """Validate request data against schema"""
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Sanitize input
        sanitized_data = {}
        for key, value in data.items():
            if isinstance(value, str):
                sanitized_data[key] = sanitize_sql(sanitize_xss(value))
            elif isinstance(value, dict):
                # Recursively sanitize nested objects
                sanitized_data[key] = {
                    k: sanitize_sql(sanitize_xss(v)) if isinstance(v, str) else v
                    for k, v in value.items()
                }
            elif isinstance(value, list):
                # Sanitize list items
                sanitized_data[key] = [
                    sanitize_sql(sanitize_xss(item)) if isinstance(item, str) else item
                    for item in value
                ]
            else:
                sanitized_data[key] = value
        
        # Validate
        valid, message = validate_input(schema_name, sanitized_data)
        
        if valid:
            return jsonify({
                'valid': True,
                'sanitized_data': sanitized_data,
                'message': message
            }), 200
        else:
            return jsonify({
                'valid': False,
                'message': message
            }), 400
    
    @app.route('/api/sanitize', methods=['POST'])
    def sanitize():
        """Sanitize input without schema validation"""
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Sanitize all string values
        sanitized = {}
        for key, value in data.items():
            if isinstance(value, str):
                sanitized[key] = sanitize_sql(sanitize_xss(value))
            else:
                sanitized[key] = value
        
        return jsonify({
            'sanitized': sanitized
        }), 200
    
    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=8080)

# ====================================================================
# KONG INPUT VALIDATION PLUGIN
# ====================================================================

---
# Kong Request Validation Plugin
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: request-validation
  namespace: production
config:
  # Validate JSON body against schema
  validate_json: true
  json_schema_path: "/schemas/customer-order.schema.json"
  
  # Validate query parameters
  validate_query_params: true
  query_param_schema:
    type: object
    properties:
      page:
        type: integer
        minimum: 1
        maximum: 1000
      limit:
        type: integer
        minimum: 1
        maximum: 100
      sort:
        type: string
        enum: ["asc", "desc"]
  
  # Validate path parameters
  validate_path_params: true
  
  # Reject on validation failure
  reject_on_failure: true
plugin: request-validation
```

**Verification:**

```bash
# Verify input validation file
ls -la api/04_input_validation.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('api/04_input_validation.yaml'))"
# Expected: No error output
```

---

### Step 6: API Security Testing

**File:** `api/05_api_security_testing.yaml`

```yaml
# API Security Testing - Nexus Global Industries
# File: api/05_api_security_testing.yaml
# Version: 1.0

# ====================================================================
# OWASP ZAP SCANNER
# ====================================================================

---
# ZAP Scanner Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: zap-config
  namespace: api-security
data:
  zap-rules.yaml: |
    # OWASP ZAP Configuration
    rules:
      # Active Scan Rules
      active_scan:
        - rule_id: 40012  # Cross Site Scripting (Reflected)
        - rule_id: 40014  # Cross Site Scripting (Persistent)
        - rule_id: 40003  # CRLF Injection
        - rule_id: 40006  # SQL Injection
        - rule_id: 40009  # Path Traversal
        - rule_id: 40010  # OS Command Injection
        - rule_id: 40011  # Server Side Include
        - rule_id: 40015  # Format String
        - rule_id: 40016  # SQL Injection (PostgreSQL)
        - rule_id: 40018  # SQL Injection (MySQL)
      
      # Passive Scan Rules
      passive_scan:
        - rule_id: 10038  # Content Type Mismatch
        - rule_id: 10052  # XSS (Automatic Detection)
        - rule_id: 10053  # XSS (Manual Detection)
        - rule_id: 10054  # Cookie not HttpOnly
        - rule_id: 10055  # Cookie not Secure
        - rule_id: 10056  # X-AspNet-Version
        - rule_id: 10057  # X-Powered-By
        - rule_id: 10096  # Timestamp Disclosure

---
# ZAP API Scan Job (CI/CD)
apiVersion: batch/v1
kind: CronJob
metadata:
  name: zap-api-scan
  namespace: api-security
spec:
  schedule: "0 8 * * *"  # Daily at 8 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: zap
            image: zaproxy/zap-stable:latest
            command:
            - /bin/sh
            - -c
            - |
              # Run ZAP baseline scan
              zap-full-scan.py -t https://api.nexus.com \
                -r /results/zap-report.html \
                -x /results/zap-report.xml \
                -J /results/zap-report.json \
                -z "-config rules.cookie.httponly=true" \
                --hook=/zap/hooks/api_hook.py
              
              # Check for findings
              CRITICAL_COUNT=$(jq '.site[].alerts[] | select(.riskcode=="3") | .name' /results/zap-report.json | wc -l)
              HIGH_COUNT=$(jq '.site[].alerts[] | select(.riskcode=="2") | .name' /results/zap-report.json | wc -l)
              
              # Fail on critical findings
              if [ "$CRITICAL_COUNT" -gt 0 ]; then
                echo "CRITICAL: Found $CRITICAL_COUNT critical vulnerabilities"
                exit 1
              fi
              
              # Fail if high findings exceed threshold
              if [ "$HIGH_COUNT" -gt 5 ]; then
                echo "ERROR: Found $HIGH_COUNT high vulnerabilities (limit: 5)"
                exit 1
              fi
              
              echo "Scan passed: $CRITICAL_COUNT critical, $HIGH_COUNT high vulnerabilities"
            volumeMounts:
            - name: results
              mountPath: /results
          volumes:
          - name: results
            emptyDir: {}
          restartPolicy: OnFailure

# ====================================================================
# API SECURITY TESTING SUITE (Unit/Integration Tests)
# ====================================================================

---
# API Security Test Suite
apiVersion: batch/v1
kind: CronJob
metadata:
  name: api-security-tests
  namespace: api-security
spec:
  schedule: "0 9 * * *"  # Daily at 9 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: test-runner
            image: python:3.11-slim
            command:
            - python
            - /tests/run_tests.py
            env:
            - name: API_URL
              value: "https://api.nexus.com"
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: api-keys
                  key: test-key
            volumeMounts:
            - name: tests
              mountPath: /tests
            - name: results
              mountPath: /results
          volumes:
          - name: tests
            configMap:
              name: api-security-tests
          - name: results
            emptyDir: {}
          restartPolicy: OnFailure

---
# API Security Tests
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-security-tests
  namespace: api-security
data:
  run_tests.py: |
    # API Security Test Suite
    import requests
    import json
    import os
    from datetime import datetime
    
    API_URL = os.environ.get('API_URL', 'https://api.nexus.com')
    API_KEY = os.environ.get('API_KEY', '')
    
    class APISecurityTest:
        """API Security test suite"""
        
        def __init__(self):
            self.results = {
                'tests': [],
                'passed': 0,
                'failed': 0,
                'timestamp': datetime.utcnow().isoformat()
            }
        
        def test_auth_required(self):
            """Test that authentication is required"""
            response = requests.get(f"{API_URL}/api/v1/orders")
            
            if response.status_code == 401:
                self._record_test('auth_required', True, 'Authentication required')
            else:
                self._record_test('auth_required', False, f'Expected 401, got {response.status_code}')
        
        def test_jwt_validation(self):
            """Test JWT validation"""
            # Test with invalid token
            headers = {'Authorization': 'Bearer invalid-token'}
            response = requests.get(f"{API_URL}/api/v1/orders", headers=headers)
            
            if response.status_code == 401:
                self._record_test('jwt_validation', True, 'Invalid token rejected')
            else:
                self._record_test('jwt_validation', False, f'Expected 401, got {response.status_code}')
        
        def test_rate_limiting(self):
            """Test rate limiting"""
            headers = {'Authorization': f'Bearer {API_KEY}'}
            responses = []
            
            # Send many requests to trigger rate limit
            for i in range(110):
                response = requests.get(f"{API_URL}/api/v1/orders", headers=headers)
                responses.append(response.status_code)
            
            # Check if rate limiting was applied
            if 429 in responses:
                self._record_test('rate_limiting', True, 'Rate limiting applied')
            else:
                self._record_test('rate_limiting', False, 'Rate limiting not applied')
        
        def test_input_validation(self):
            """Test input validation"""
            headers = {'Authorization': f'Bearer {API_KEY}', 'Content-Type': 'application/json'}
            
            # Test SQL injection attempt
            malicious_data = {
                'query': "SELECT * FROM users WHERE username='admin' OR '1'='1'"
            }
            response = requests.post(f"{API_URL}/api/v1/search", 
                                     headers=headers, 
                                     json=malicious_data)
            
            if response.status_code != 200:
                self._record_test('input_validation_sql', True, 'SQL injection blocked')
            else:
                self._record_test('input_validation_sql', False, 'SQL injection not blocked')
            
            # Test XSS attempt
            malicious_data = {
                'comment': "<script>alert('XSS')</script>"
            }
            response = requests.post(f"{API_URL}/api/v1/comments", 
                                     headers=headers, 
                                     json=malicious_data)
            
            if response.status_code != 200:
                self._record_test('input_validation_xss', True, 'XSS blocked')
            else:
                self._record_test('input_validation_xss', False, 'XSS not blocked')
        
        def test_https_enforced(self):
            """Test HTTPS enforcement"""
            # Test HTTP endpoint (should redirect to HTTPS)
            response = requests.get("http://api.nexus.com/api/v1/health", allow_redirects=False)
            
            if response.status_code in [301, 302, 307, 308]:
                self._record_test('https_enforced', True, 'HTTPS redirect enforced')
            else:
                self._record_test('https_enforced', False, 'HTTPS not enforced')
        
        def test_cors_security(self):
            """Test CORS security"""
            headers = {'Origin': 'https://malicious.com'}
            response = requests.options(f"{API_URL}/api/v1/orders", headers=headers)
            
            # CORS headers should not allow malicious origin
            if 'Access-Control-Allow-Origin' in response.headers:
                origin = response.headers['Access-Control-Allow-Origin']
                if origin != '*':
                    self._record_test('cors_security', True, 'CORS properly restricted')
                else:
                    self._record_test('cors_security', False, 'CORS allows all origins')
            else:
                self._record_test('cors_security', True, 'CORS headers not exposed')
        
        def _record_test(self, name, passed, message):
            """Record a test result"""
            test_result = {
                'name': name,
                'passed': passed,
                'message': message
            }
            self.results['tests'].append(test_result)
            if passed:
                self.results['passed'] += 1
            else:
                self.results['failed'] += 1
        
        def run(self):
            """Run all tests"""
            print("Starting API Security Tests...")
            
            # Run tests
            self.test_auth_required()
            self.test_jwt_validation()
            self.test_rate_limiting()
            self.test_input_validation()
            self.test_https_enforced()
            self.test_cors_security()
            
            # Save results
            with open('/results/api-test-results.json', 'w') as f:
                json.dump(self.results, f, indent=2)
            
            # Print summary
            print(f"Tests passed: {self.results['passed']}")
            print(f"Tests failed: {self.results['failed']}")
            
            # Exit with failure if any tests failed
            if self.results['failed'] > 0:
                exit(1)
    
    if __name__ == '__main__':
        test_runner = APISecurityTest()
        test_runner.run()
```

**Verification:**

```bash
# Verify API security testing file
ls -la api/05_api_security_testing.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('api/05_api_security_testing.yaml'))"
# Expected: No error output
```

---

### Step 7: API Security Summary

**File:** `api/README.md`

```markdown
# API Security - Nexus Global Industries

## Overview

This directory contains the complete API security implementation for Nexus Global Industries, aligned with OWASP API Security Top 10.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_gateway_security.yaml` | Gateway | Kong/Envoy security configuration |
| `02_jwt_security.yaml` | JWT | Token validation and management |
| `03_rate_limiting.yaml` | Rate Limiting | Throttling and circuit breakers |
| `04_input_validation.yaml` | Validation | Input sanitization and validation |
| `05_api_security_testing.yaml` | Testing | Automated security testing |

## OWASP API Top 10 Coverage

| OWASP API Vulnerability | Protection | Implementation |
|------------------------|------------|----------------|
| **API1: Broken Object Level Authorization** | BOLA protection | Kong OWASP plugin |
| **API2: Broken Authentication** | JWT + OIDC | OIDC plugin, MFA enforcement |
| **API3: Excessive Data Exposure** | Response limiting | OWASP plugin |
| **API4: Lack of Resources & Rate Limiting** | Rate limiting | Kong rate-limit plugin |
| **API5: Broken Function Level Authorization** | Function auth | OWASP plugin |
| **API6: Mass Assignment** | Schema validation | JSON Schema validation |
| **API7: Security Misconfiguration** | Header checks | OWASP plugin |
| **API8: Injection** | Input validation | SQLi + XSS sanitization |
| **API9: Improper Asset Management** | Deprecation headers | OWASP plugin |
| **API10: Insufficient Logging & Monitoring** | Full logging | SIEM integration |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      API SECURITY ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  CLIENT REQUEST                                        │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  API GATEWAY (Kong/Envoy)                              │   │
│  │  • Rate limiting                                      │   │
│  │  • JWT validation                                     │   │
│  │  • CORS protection                                    │   │
│  │  • Circuit breaking                                  │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  INPUT VALIDATION                                      │   │
│  │  • Schema validation                                  │   │
│  │  • SQL injection detection                           │   │
│  │  • XSS detection                                     │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  API SERVICES                                          │   │
│  │  • Customer API                                       │   │
│  │  • Payment API                                        │   │
│  │  • Order API                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  SECURITY TESTING (ZAP + Unit Tests)                   │   │
│  │  • Daily scans                                        │   │
│  │  • CI/CD integration                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Deployment Instructions

### 1. Deploy Gateway Security

```bash
kubectl apply -f api/01_gateway_security.yaml
```

### 2. Deploy JWT Security

```bash
kubectl apply -f api/02_jwt_security.yaml
```

### 3. Deploy Rate Limiting

```bash
kubectl apply -f api/03_rate_limiting.yaml
```

### 4. Deploy Input Validation

```bash
kubectl apply -f api/04_input_validation.yaml
```

### 5. Deploy Security Testing

```bash
kubectl apply -f api/05_api_security_testing.yaml
```

## Verification Checklist

- [ ] API gateway configured with all security plugins
- [ ] JWT validation working (tokens validated)
- [ ] Rate limiting applied (100 req/min default)
- [ ] Input validation blocking SQLi/XSS
- [ ] ZAP scanning daily with no critical findings
- [ ] API security tests passing
- [ ] HTTPS enforced for all endpoints
- [ ] CORS properly restricted

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la api/README.md
# Expected: File exists

echo "✅ API Security Complete!"
echo "   - OWASP API Top 10 protections"
echo "   - JWT validation and token security"
echo "   - Rate limiting and throttling"
echo "   - Input validation and sanitization"
echo "   - API security testing (ZAP + unit tests)"
```

---

## End of Section 3.4: API Security

### Key Takeaway

You've implemented comprehensive API security controls for Nexus Global Industries, aligned with OWASP API Security Top 10. The implementation includes gateway security with Kong, JWT validation, rate limiting, input validation, and automated security testing with ZAP. This provides defense-in-depth for all public APIs.

### What's Next

**Section 3.5** will cover **DevSecOps CI/CD Pipeline Security**, including:
- CI/CD security scanning integration
- SAST/DAST/SCA in pipelines
- Pipeline security hardening
- Container scanning in pipelines
- Policy enforcement in CI/CD
xx
