# Appendix G: Complete API Endpoints & Integration Reference
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - API & Integration Reference

## Overview

This appendix provides a complete reference for all API endpoints, integration points, and data flow patterns across the security architecture. Use this as a reference for integration development, troubleshooting, and operational monitoring.

---

## 1. Identity & Access Management APIs

### 1.1 Keycloak Identity Provider API

#### Authentication Endpoints

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/realms/{realm}/protocol/openid-connect/token` | POST | Get access token | Client credentials |
| `/realms/{realm}/protocol/openid-connect/auth` | GET | Authorization code flow | None |
| `/realms/{realm}/protocol/openid-connect/logout` | POST | Logout user | Bearer token |
| `/realms/{realm}/protocol/openid-connect/userinfo` | GET | Get user info | Bearer token |

#### Admin Endpoints

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/admin/realms/{realm}/users` | GET | List users | Bearer token |
| `/admin/realms/{realm}/users` | POST | Create user | Bearer token |
| `/admin/realms/{realm}/users/{id}` | PUT | Update user | Bearer token |
| `/admin/realms/{realm}/users/{id}` | DELETE | Delete user | Bearer token |
| `/admin/realms/{realm}/users/{id}/reset-password` | PUT | Reset password | Bearer token |
| `/admin/realms/{realm}/groups` | GET | List groups | Bearer token |
| `/admin/realms/{realm}/roles` | GET | List roles | Bearer token |

#### Example: Token Request

```bash
# Get access token
curl -X POST https://auth.nexus.com/realms/nexus/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=api-gateway" \
  -d "client_secret=api-gateway-secret-abcde" \
  -d "grant_type=password" \
  -d "username=jdoe" \
  -d "password=Nexus2026!Secure"

# Response
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "expires_in": 900,
  "refresh_expires_in": 1800,
  "refresh_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "id_token": "eyJhbGciOiJSUzI1NiIs...",
  "not-before-policy": 0,
  "session_state": "abcd-1234",
  "scope": "openid profile email"
}
```

### 1.2 SCIM Automation Service API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/scim/users` | POST | Create user | Bearer token |
| `/api/scim/users/{id}` | PUT | Update user | Bearer token |
| `/api/scim/users/{id}` | DELETE | Delete user | Bearer token |
| `/api/sync/hris` | POST | Trigger HRIS sync | Bearer token |
| `/api/users/{username}` | GET | Get user by username | Bearer token |

#### Example: SCIM User Creation

```bash
# Create user via SCIM
curl -X POST https://auth.nexus.com/admin/realms/nexus/scim/v2/Users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/scim+json" \
  -d '{
    "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
    "userName": "jdoe@nexus.com",
    "name": {
      "givenName": "John",
      "familyName": "Doe"
    },
    "emails": [
      {
        "value": "jdoe@nexus.com",
        "primary": true
      }
    ],
    "active": true,
    "groups": [
      {"display": "engineer"}
    ]
  }'
```

---

## 2. Zero Trust & Policy APIs

### 2.1 OPA Policy Engine API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/v1/data/{package}/{rule}` | POST | Evaluate policy | None (internal) |
| `/v1/policies` | GET | List policies | Bearer token |
| `/v1/policies/{policy}` | GET | Get policy | Bearer token |
| `/v1/policies/{policy}` | PUT | Update policy | Bearer token |
| `/health` | GET | Health check | None |

#### Example: Policy Evaluation

```bash
# Evaluate Zero Trust policy
curl -X POST http://opa-server:8181/v1/data/nexus/zero_trust/allow \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "user": {
        "authenticated": true,
        "mfa_enabled": true,
        "role": "admin"
      },
      "resource": {
        "classification": "restricted"
      },
      "device": {
        "posture": "compliant"
      }
    }
  }'

# Response
{
  "result": true
}
```

### 2.2 Continuous Verification Service API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/verify/{session_id}` | GET | Verify session | Bearer token |
| `/register` | POST | Register session | Bearer token |
| `/activity/{session_id}` | POST | Update activity | Bearer token |
| `/sessions` | GET | List active sessions | Bearer token |
| `/health` | GET | Health check | None |

#### Example: Session Verification

```bash
# Register a session
curl -X POST https://verification.nexus.com/register \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "session-123",
    "user_id": "jdoe",
    "roles": ["admin"],
    "device_id": "device-456",
    "ip_address": "10.0.0.1",
    "geo_location": {
      "lat": 40.7128,
      "lon": -74.0060
    }
  }'

# Verify session
curl -X GET https://verification.nexus.com/verify/session-123 \
  -H "Authorization: Bearer $TOKEN"

# Response
{
  "verified": true,
  "risk_score": 15,
  "risk_level": "low",
  "checks": {
    "session_age_ok": true,
    "idle_time_ok": true,
    "encryption": true,
    "geo_ok": true,
    "behavior_ok": true
  }
}
```

---

## 3. Privileged Access Management APIs

### 3.1 HashiCorp Vault API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/v1/secret/data/{path}` | GET | Read secret | Vault token |
| `/v1/secret/data/{path}` | POST | Write secret | Vault token |
| `/v1/secret/data/{path}` | DELETE | Delete secret | Vault token |
| `/v1/auth/kubernetes/login` | POST | Kubernetes auth | Service account |
| `/v1/sys/health` | GET | Health check | None |
| `/v1/sys/seal` | PUT | Seal Vault | Vault token |
| `/v1/sys/unseal` | PUT | Unseal Vault | Unseal key |

#### Example: Dynamic Credentials

```bash
# Generate dynamic AWS credentials
curl -X POST https://vault.nexus.com:8200/v1/aws/creds/admin-role \
  -H "X-Vault-Token: $VAULT_TOKEN"

# Response
{
  "lease_id": "aws/creds/admin-role/abcd-1234",
  "lease_duration": 3600,
  "data": {
    "access_key": "AKIA...",
    "secret_key": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "security_token": "FwoGZXIv..."
  }
}
```

### 3.2 PAM Workflow API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/pam/request` | POST | Request JIT access | Bearer token |
| `/api/pam/approve/{request_id}` | POST | Approve request | Bearer token |
| `/api/pam/deny/{request_id}` | POST | Deny request | Bearer token |
| `/api/pam/terminate/{session_id}` | POST | Terminate session | Bearer token |
| `/api/pam/break-glass` | POST | Break-glass access | Bearer token |
| `/api/pam/status/{request_id}` | GET | Request status | Bearer token |

#### Example: JIT Access Request

```bash
# Request JIT access
curl -X POST https://pam.nexus.com/api/pam/request \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "jdoe",
    "user_email": "jdoe@nexus.com",
    "target_system": "aws:production",
    "access_level": "admin",
    "justification": "Database maintenance required",
    "requested_duration": 900
  }'

# Response
{
  "request_id": "JIT-20260802-1234-5678",
  "status": "pending",
  "created_at": "2026-08-02T12:00:00Z"
}
```

### 3.3 Break-Glass API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/break-glass/create` | POST | Create break-glass session | Bearer token |
| `/api/break-glass/revoke/{session_id}` | POST | Revoke session | Bearer token |
| `/api/break-glass/status/{session_id}` | GET | Session status | Bearer token |
| `/api/break-glass/log/{session_id}` | POST | Log action | Bearer token |

#### Example: Break-Glass Access

```bash
# Create break-glass session
curl -X POST https://breakglass.nexus.com/api/break-glass/create \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "jdoe",
    "justification": "Critical production outage - emergency access required"
  }'

# Response
{
  "session_id": "BG-20260802-1234",
  "status": "active",
  "created_at": "2026-08-02T12:00:00Z",
  "expires_at": "2026-08-02T12:30:00Z"
}
```

---

## 4. API Gateway Security APIs

### 4.1 Kong Admin API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/services` | GET | List services | Kong admin token |
| `/services` | POST | Create service | Kong admin token |
| `/routes` | GET | List routes | Kong admin token |
| `/routes` | POST | Create route | Kong admin token |
| `/plugins` | GET | List plugins | Kong admin token |
| `/plugins` | POST | Configure plugin | Kong admin token |

#### Example: Create API Service

```bash
# Create service
curl -X POST http://kong-admin:8001/services \
  -H "Content-Type: application/json" \
  -d '{
    "name": "customer-api",
    "url": "http://customer-api.production.svc.cluster.local:8080"
  }'

# Create route
curl -X POST http://kong-admin:8001/services/customer-api/routes \
  -H "Content-Type: application/json" \
  -d '{
    "paths": ["/api/v1/customers"],
    "strip_path": true
  }'
```

### 4.2 JWT Validation API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/validate` | GET | Validate JWT | Bearer token |
| `/health` | GET | Health check | None |

#### Example: JWT Validation

```bash
# Validate JWT
curl -X GET https://jwt-validator.nexus.com/api/validate \
  -H "Authorization: Bearer $JWT_TOKEN"

# Response
{
  "valid": true,
  "user": {
    "email": "jdoe@nexus.com",
    "roles": ["admin"],
    "mfa_enabled": true
  },
  "timestamp": "2026-08-02T12:00:00Z"
}
```

### 4.3 Input Validation API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/validate/{schema_name}` | POST | Validate input against schema | Bearer token |
| `/api/sanitize` | POST | Sanitize input | Bearer token |
| `/health` | GET | Health check | None |

#### Example: Input Validation

```bash
# Validate input
curl -X POST https://input-validator.nexus.com/api/validate/customer-order \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": "CUST-123456",
    "items": [
      {
        "product_id": "PROD-001",
        "quantity": 2,
        "price": 99.99
      }
    ]
  }'

# Response
{
  "valid": true,
  "sanitized_data": {
    "customer_id": "CUST-123456",
    "items": [
      {
        "product_id": "PROD-001",
        "quantity": 2,
        "price": 99.99
      }
    ]
  },
  "message": "Valid"
}
```

---

## 5. SIEM & Detection APIs

### 5.1 Elasticsearch API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/{index}/_search` | POST | Search logs | Basic auth |
| `/{index}/_doc` | POST | Index document | Basic auth |
| `/_cluster/health` | GET | Cluster health | Basic auth |
| `/_cat/indices` | GET | List indices | Basic auth |

#### Example: Search Security Logs

```bash
# Search for critical security events
curl -k -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          { "match": { "event.severity": "CRITICAL" } }
        ],
        "filter": [
          { "range": { "@timestamp": { "gte": "now-24h" } } }
        ]
      }
    },
    "sort": [
      { "@timestamp": "desc" }
    ],
    "size": 100
  }'
```

### 5.2 Detection Rules API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/rules` | GET | List detection rules | Bearer token |
| `/api/rules/{rule_id}` | GET | Get rule | Bearer token |
| `/api/rules` | POST | Create rule | Bearer token |
| `/api/rules/{rule_id}` | PUT | Update rule | Bearer token |
| `/api/rules/{rule_id}` | DELETE | Delete rule | Bearer token |
| `/api/rules/test` | POST | Test rule | Bearer token |

#### Example: Create Detection Rule

```bash
# Create Sigma rule
curl -X POST https://detection.nexus.com/api/rules \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Credential Dumping Detection",
    "id": "rule-001",
    "status": "production",
    "description": "Detects credential dumping via LSASS access",
    "tags": ["attack.t1003"],
    "logsource": {
      "product": "windows",
      "service": "security"
    },
    "detection": {
      "selection": {
        "EventID": 4688,
        "CommandLine": ["*lsass*", "*procdump*"]
      }
    },
    "level": "high"
  }'
```

### 5.3 Logstash API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/_node/pipelines` | GET | List pipelines | None |
| `/_node/stats` | GET | Pipeline stats | None |
| `/` | GET | Health check | None |

#### Example: Log Ingestion

```bash
# Send log to Logstash
curl -X POST http://logstash:5044 \
  -H "Content-Type: application/json" \
  -d '{
    "@timestamp": "2026-08-02T12:00:00Z",
    "event": {
      "type": "login",
      "severity": "HIGH",
      "source": "keycloak"
    },
    "user": "jdoe",
    "source_ip": "10.0.0.1",
    "message": "Failed login attempt"
  }'
```

---

## 6. SOAR Automation APIs

### 6.1 Playbook API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/playbooks` | GET | List playbooks | Bearer token |
| `/api/playbooks/{id}` | GET | Get playbook | Bearer token |
| `/api/playbooks/{id}/run` | POST | Run playbook | Bearer token |
| `/api/playbooks/{id}/status` | GET | Playbook status | Bearer token |

#### Example: Run Playbook

```bash
# Run phishing response playbook
curl -X POST https://soar.nexus.com/api/playbooks/SOAR-001/run \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "trigger": "email_security_alert",
    "parameters": {
      "sender": "phisher@malicious.com",
      "recipient": "jdoe@nexus.com",
      "subject": "Suspicious login attempt"
    }
  }'
```

### 6.2 Case Management API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/cases` | GET | List cases | Bearer token |
| `/api/cases` | POST | Create case | Bearer token |
| `/api/cases/{id}` | GET | Get case | Bearer token |
| `/api/cases/{id}` | PUT | Update case | Bearer token |
| `/api/cases/{id}/comment` | POST | Add comment | Bearer token |
| `/api/cases/{id}/close` | POST | Close case | Bearer token |

#### Example: Create Incident Case

```bash
# Create security case
curl -X POST https://soar.nexus.com/api/cases \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Phishing Incident - User jdoe",
    "description": "User reported suspicious email",
    "severity": "HIGH",
    "priority": "P2",
    "assignee": "security-team",
    "playbook_id": "SOAR-001",
    "indicators": [
      "phisher@malicious.com",
      "https://malicious.com/phishing"
    ]
  }'
```

### 6.3 Enrichment API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/enrich/ip/{ip}` | GET | Enrich IP address | Bearer token |
| `/api/enrich/url/{url}` | GET | Enrich URL | Bearer token |
| `/api/enrich/domain/{domain}` | GET | Enrich domain | Bearer token |
| `/api/enrich/email/{email}` | GET | Enrich email | Bearer token |

#### Example: IP Enrichment

```bash
# Enrich IP address
curl -X GET https://soar.nexus.com/api/enrich/ip/10.0.0.1 \
  -H "Authorization: Bearer $TOKEN"

# Response
{
  "ip": "10.0.0.1",
  "threat_intel": {
    "reputation": -20,
    "malware_family": "none",
    "confidence_score": 85
  },
  "geoip": {
    "country": "US",
    "city": "New York",
    "coordinates": {
      "lat": 40.7128,
      "lon": -74.0060
    }
  },
  "whois": {
    "registrar": "private",
    "owner": "Nexus Global"
  }
}
```

---

## 7. Chaos Engineering APIs

### 7.1 Chaos Test API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/chaos/run/{test_id}` | POST | Run chaos test | Bearer token |
| `/api/chaos/status/{test_id}` | GET | Test status | Bearer token |
| `/api/chaos/results` | GET | All results | Bearer token |
| `/health` | GET | Health check | None |

#### Example: Run Chaos Test

```bash
# Run Kubernetes node failure test
curl -X POST https://chaos.nexus.com/api/chaos/run/CHAOS-001 \
  -H "Authorization: Bearer $TOKEN"

# Response
{
  "test_id": "CHAOS-001",
  "status": "running",
  "start_time": "2026-08-02T12:00:00Z"
}

# Check status
curl -X GET https://chaos.nexus.com/api/chaos/status/CHAOS-001 \
  -H "Authorization: Bearer $TOKEN"

# Response
{
  "test_id": "CHAOS-001",
  "status": "completed",
  "passed": true,
  "metrics": {
    "mttd": 45,
    "mttr": 192,
    "recovery_rate": 100
  }
}
```

---

## 8. Business Continuity APIs

### 8.1 Backup Validation API

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/api/backup/validate` | POST | Validate backup | Bearer token |
| `/api/backup/status` | GET | Backup status | Bearer token |
| `/api/backup/restore` | POST | Restore backup | Bearer token |

#### Example: Validate Backup

```bash
# Validate critical backup
curl -X POST https://bcr.nexus.com/api/backup/validate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "system": "Customer Portal",
    "tier": "0",
    "backup_location": "aws:s3://nexus-critical-backups"
  }'

# Response
{
  "system": "Customer Portal",
  "valid": true,
  "last_backup": "2026-08-02T11:30:00Z",
  "age_seconds": 1800,
  "checksum": "abc123def456",
  "status": "HEALTHY"
}
```

---

## 9. Integration Data Flow Patterns

### 9.1 Authentication Flow

```
┌──────────┐    1. Login Request    ┌──────────┐    2. Token Request   ┌──────────┐
│  Client  │ ──────────────────────▶│  Kong    │ ────────────────────▶│ Keycloak │
│          │     (Credentials)       │ Gateway  │                       │  (IdP)   │
└──────────┘                        └──────────┘                       └──────────┘
       ▲                                  │                                  │
       │                                  │ 3. Validate JWT                   │
       │                                  ▼                                  │
       │                              ┌──────────┐                           │
       │                              │   OPA    │ ◀─────────────────────────┘
       │                              │   PDP    │    4. Policy Evaluation
       │                              └──────────┘
       │                                  │
       │       6. Access Granted          │ 5. PEP Enforces
       └──────────────────────────────────┘
```

### 9.2 Detection & Response Flow

```
┌──────────┐   1. Logs Collected   ┌──────────┐   2. Process & Index   ┌──────────────┐
│  Sources │ ────────────────────▶│ Logstash │ ──────────────────────▶│  Elasticsearch│
│  (Apps)  │                       │          │                        │   (SIEM)     │
└──────────┘                       └──────────┘                        └──────────────┘
                                                                              │
                                                                              │ 3. Rule Evaluation
                                                                              ▼
┌──────────┐   5. Enrich & Alert   ┌──────────┐   4. Detection Hit   ┌──────────────┐
│   SOAR   │ ◀────────────────────│  TheHive │ ◀────────────────────│  Detection   │
│          │                       │  (Cases) │                      │   Engine     │
└──────────┘                       └──────────┘                      └──────────────┘
       │                                │                                   │
       │ 6. Execute Playbook            │ 7. Notify Team                    │
       ▼                                ▼                                   │
┌──────────┐                       ┌──────────┐                            │
│  Actions │                       │  Slack   │                            │
│  (Tools) │                       │  Alert   │                            │
└──────────┘                       └──────────┘                            │
```

### 9.3 Zero Trust Access Flow

```
┌──────────┐   1. Access Request   ┌──────────┐   2. Get Context   ┌──────────────┐
│   User   │ ────────────────────▶│    PEP   │ ───────────────────▶│     PIP      │
│          │                       │ (Istio) │                     │  (Context)   │
└──────────┘                       └──────────┘                     └──────────────┘
       ▲                                │                                 │
       │                                │ 3. Policy Evaluation             │
       │                                ▼                                 │
       │                            ┌──────────┐ ◀───────────────────────┘
       │                            │   PDP    │
       │                            │  (OPA)   │
       │                            └──────────┘
       │                                │
       │       5. Access Denied        │ 4. Decision (Allow/Deny)
       │       or Granted              ▼
       │                            ┌──────────┐
       └────────────────────────────│  Action  │
                                    │  (Allow/ │
                                    │  Deny)   │
                                    └──────────┘
```

---

## 10. API Error Codes Reference

### 10.1 Common Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| 400 | Bad Request | Check request format and parameters |
| 401 | Unauthorized | Verify authentication credentials |
| 403 | Forbidden | Check permissions and policies |
| 404 | Not Found | Verify endpoint and resource IDs |
| 429 | Rate Limited | Reduce request frequency |
| 500 | Internal Error | Check server logs and connectivity |
| 503 | Service Unavailable | Verify service health and dependencies |

### 10.2 Specific Error Responses

```json
// Authentication Error
{
  "error": "authentication_failed",
  "message": "Invalid credentials provided",
  "code": "AUTH-001",
  "timestamp": "2026-08-02T12:00:00Z"
}

// Policy Violation
{
  "error": "access_denied",
  "message": "User does not have required permissions",
  "code": "POLICY-001",
  "details": {
    "user": "jdoe",
    "role": "engineer",
    "required_clearance": "restricted"
  },
  "timestamp": "2026-08-02T12:00:00Z"
}

// Rate Limit Exceeded
{
  "error": "rate_limit_exceeded",
  "message": "Too many requests, rate limit exceeded",
  "code": "RATE-001",
  "details": {
    "limit": 100,
    "window": "1 minute",
    "retry_after": 30
  },
  "timestamp": "2026-08-02T12:00:00Z"
}
```

---

## 11. Integration Testing Commands

### 11.1 Test Authentication

```bash
# Test OIDC authentication
curl -X POST https://auth.nexus.com/realms/nexus/protocol/openid-connect/token \
  -d "client_id=test-client" \
  -d "client_secret=test-secret" \
  -d "grant_type=client_credentials"
```

### 11.2 Test API Security

```bash
# Test JWT validation
curl -X GET https://api.nexus.com/api/secure \
  -H "Authorization: Bearer $TOKEN"

# Test rate limiting
for i in {1..110}; do
  curl -s -o /dev/null -w "%{http_code}\n" https://api.nexus.com/api/test
done
```

### 11.3 Test Policy Evaluation

```bash
# Test OPA policy
curl -X POST http://opa-server:8181/v1/data/nexus/zero_trust/allow \
  -d '{"input": {...}}'
```

### 11.4 Test SIEM Integration

```bash
# Send test log
curl -X POST http://logstash:5044 \
  -H "Content-Type: application/json" \
  -d '{"test": "log", "source": "integration-test"}'

# Verify log in Elasticsearch
curl -k -X GET "https://elasticsearch:9200/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{"query": {"match": {"source": "integration-test"}}}'
```

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX G]**

This appendix provides a complete API reference for all security components. Use these endpoints for integration development, testing, and operational monitoring of the security architecture.
