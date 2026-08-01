# Appendix K: Complete Security Playbooks & Runbooks
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Operational Response Reference

## Overview

This appendix provides complete security playbooks and runbooks for all major incident scenarios and operational procedures. Each playbook includes step-by-step instructions, roles, timelines, and verification steps.

---

## 1. Phishing Incident Playbook

**Playbook ID:** PB-PHISH-001
**Version:** 1.0
**Owner:** Incident Response Manager
**Severity:** MEDIUM-HIGH

---

### 1.1 Overview

This playbook defines the response process for phishing incidents, including suspicious emails, credential harvesting, and user compromise.

### 1.2 Triggers

- User reports suspicious email
- Email gateway flags malicious email
- SIEM detects credential compromise
- Security awareness report

### 1.3 Incident Classification

| Type | Description | Severity |
|------|-------------|----------|
| **Suspicious Email** | User reported, not confirmed | MEDIUM |
| **Malicious Email** | Confirmed phishing attempt | HIGH |
| **Compromised Credentials** | User credentials compromised | CRITICAL |
| **Data Exfiltration** | Phishing led to data loss | CRITICAL |

### 1.4 Response Process

#### Step 1: Alert Triage (0-5 minutes)

**Owner:** SOC Analyst

**Actions:**

```bash
# Review email details
kubectl logs -f deployment/email-gateway -n security | grep -i "phishing"

# Check SIEM for related alerts
curl -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"event.type": "phishing"}},
          {"range": {"@timestamp": {"gte": "now-1h"}}}
        ]
      }
    }
  }'

# Document initial findings
```

**Verification:**

- [ ] Email details collected (sender, recipient, subject, attachments)
- [ ] Related alerts identified
- [ ] Initial severity determined

#### Step 2: Email Analysis (5-15 minutes)

**Owner:** Detection Engineer

**Actions:**

```bash
# Extract email headers
curl -X GET https://email-gateway.nexus.com/api/v1/emails/{id}/headers

# Check attachments in sandbox
curl -X POST https://sandbox.nexus.com/api/analyze \
  -H "Content-Type: application/json" \
  -d '{"file_hash": "abc123def456"}'

# Check URLs for reputation
curl -X GET https://url-reputation.nexus.com/api/check?url=malicious.com

# Generate threat intelligence report
curl -X GET https://threat-intel.nexus.com/api/report/{hash}
```

**Verification:**

- [ ] Headers analyzed
- [ ] Attachments scanned (sandbox)
- [ ] URLs checked for reputation
- [ ] Threat intelligence report generated

#### Step 3: User Isolation (15-30 minutes)

**Owner:** Identity Engineer

**Actions:**

```bash
# Quarantine mailbox
curl -X POST https://email-gateway.nexus.com/api/v1/emails/quarantine \
  -H "Content-Type: application/json" \
  -d '{"user": "jdoe@nexus.com"}'

# Disable account in Keycloak
curl -X PUT https://auth.nexus.com/admin/realms/nexus/users/{id}/disable \
  -H "Authorization: Bearer $TOKEN"

# Reset password
curl -X PUT https://auth.nexus.com/admin/realms/nexus/users/{id}/reset-password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "password", "value": "TemporaryP@ssw0rd!", "temporary": true}'

# Revoke all sessions
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/logout \
  -H "Authorization: Bearer $TOKEN"
```

**Verification:**

- [ ] Mailbox quarantined
- [ ] Account disabled
- [ ] Password reset
- [ ] All sessions revoked

#### Step 4: Containment (30-60 minutes)

**Owner:** Security Engineer

**Actions:**

```bash
# Remove malicious email from all mailboxes
curl -X POST https://email-gateway.nexus.com/api/v1/emails/remove \
  -H "Content-Type: application/json" \
  -d '{"message_id": "msg-12345"}'

# Block sender domain
curl -X POST https://email-gateway.nexus.com/api/v1/blocklist/domains \
  -H "Content-Type: application/json" \
  -d '{"domain": "malicious.com"}'

# Update threat intelligence
curl -X POST https://threat-intel.nexus.com/api/indicators \
  -H "Content-Type: application/json" \
  -d '{
    "type": "domain",
    "value": "malicious.com",
    "confidence": 95
  }'

# Block malicious URLs in proxy
curl -X POST https://proxy.nexus.com/api/blocklist/urls \
  -H "Content-Type: application/json" \
  -d '{"url": "https://malicious.com/phishing"}'
```

**Verification:**

- [ ] Malicious email removed
- [ ] Sender domain blocked
- [ ] Threat intelligence updated
- [ ] URLs blocked

#### Step 5: User Notification (60-90 minutes)

**Owner:** Communications Lead

**Actions:**

```bash
# Send notification to affected user
curl -X POST https://slack.nexus.com/api/chat.postMessage \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "@jdoe",
    "text": "Your account may have been compromised. Please contact Security immediately."
  }'

# Send team notification
curl -X POST https://slack.nexus.com/api/chat.postMessage \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "#security-alerts",
    "text": "🚨 Phishing Incident: User jdoe compromised. Response in progress."
  }'
```

**Verification:**

- [ ] User notified
- [ ] Team notified
- [ ] Manager informed

#### Step 6: Case Documentation (90-120 minutes)

**Owner:** Incident Response Manager

**Actions:**

```bash
# Create case in TheHive
curl -X POST https://thehive.nexus.com/api/case \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Phishing Incident - User jdoe",
    "description": "User account compromised via phishing",
    "severity": 3,
    "tags": ["phishing", "credential-theft"],
    "customFields": {
      "affected_user": "jdoe@nexus.com",
      "sender": "phisher@malicious.com"
    }
  }'

# Add findings
curl -X POST https://thehive.nexus.com/api/case/{id}/comment \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Initial findings: Email from malicious.com, attachment contains malware"
  }'
```

**Verification:**

- [ ] Case created
- [ ] All actions documented
- [ ] Case status updated
- [ ] Lessons learned captured

---

## 2. Ransomware Incident Playbook

**Playbook ID:** PB-RANSOM-001
**Version:** 1.0
**Owner:** Incident Response Manager
**Severity:** CRITICAL

---

### 2.1 Overview

This playbook defines the response process for ransomware incidents, including detection, containment, eradication, and recovery.

### 2.2 Triggers

- XDR detects ransomware activity
- User reports encrypted files
- SIEM detects suspicious file activity
- Chaos test reveals vulnerability

### 2.3 Response Process

#### Step 1: Alert Triage (0-5 minutes)

**Owner:** SOC Analyst

**Actions:**

```bash
# Check XDR alerts
curl -X GET https://crowdstrike.nexus.com/api/v1/detections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Review SIEM for related activity
curl -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"event.type": "ransomware"}},
          {"range": {"@timestamp": {"gte": "now-15m"}}}
        ]
      }
    }
  }'

# Identify affected systems
```

**Verification:**

- [ ] Alert verified as ransomware
- [ ] Affected systems identified
- [ ] Initial severity determined (CRITICAL)

#### Step 2: Network Isolation (5-15 minutes)

**Owner:** Network Engineer

**Actions:**

```bash
# Isolate network segments
kubectl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: isolate-infected
spec:
  selector: app == 'infected'
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
  egress:
  - action: Deny
EOF

# Isolate endpoints via XDR
curl -X POST https://crowdstrike.nexus.com/api/v1/hosts/{host_id}/isolate \
  -H "Authorization: Bearer $TOKEN"

# Block C2 traffic
curl -X POST https://firewall.nexus.com/api/blocklist/ips \
  -H "Content-Type: application/json" \
  -d '{"ips": ["192.168.1.100", "10.0.0.50"]}'
```

**Verification:**

- [ ] Network segments isolated
- [ ] Infected endpoints isolated
- [ ] C2 communication blocked

#### Step 3: Credential Protection (15-30 minutes)

**Owner:** Identity Engineer

**Actions:**

```bash
# Revoke compromised credentials
curl -X PUT https://vault.nexus.com/v1/auth/kubernetes/revoke \
  -H "X-Vault-Token: $VAULT_TOKEN"

# Force password reset
curl -X PUT https://auth.nexus.com/admin/realms/nexus/users/{id}/reset-password \
  -H "Authorization: Bearer $TOKEN"

# Rotate service account passwords
curl -X POST https://vault.nexus.com/v1/secret/rotate \
  -H "X-Vault-Token: $VAULT_TOKEN"
```

**Verification:**

- [ ] Compromised credentials revoked
- [ ] User passwords reset
- [ ] Service account credentials rotated

#### Step 4: Backup Recovery (30-120 minutes)

**Owner:** SRE

**Actions:**

```bash
# Validate latest backup
aws s3api head-object --bucket nexus-critical-backups --key backup-$(date +%Y%m%d).zip

# Initiate restore from immutable backup
aws s3api restore-object --bucket nexus-critical-backups --key backup-$(date +%Y%m%d).zip \
  --restore-request '{"Days":1,"GlacierJobParameters":{"Tier":"Standard"}}'

# Verify data integrity
sha256sum backup-$(date +%Y%m%d).zip
# Expected: matches stored checksum

# Restore to recovery environment
kubectl apply -f restore-config.yaml
```

**Verification:**

- [ ] Latest backup validated
- [ ] Restore initiated
- [ ] Data integrity verified
- [ ] Recovery environment prepared

#### Step 5: System Restoration (120-240 minutes)

**Owner:** SRE

**Actions:**

```bash
# Reimage affected systems
curl -X POST https://orchestration.nexus.com/api/reimage \
  -H "Content-Type: application/json" \
  -d '{"hosts": ["host-1", "host-2"]}'

# Restore data from backups
curl -X POST https://orchestration.nexus.com/api/restore \
  -H "Content-Type: application/json" \
  -d '{"backup_id": "backup-20260802"}'

# Validate system functionality
curl -X GET https://orchestration.nexus.com/api/validate \
  -H "Content-Type: application/json"
```

**Verification:**

- [ ] Systems reimaged
- [ ] Data restored
- [ ] Systems validated and functional

#### Step 6: Post-Incident Analysis (Within 72 hours)

**Owner:** Incident Response Manager

**Actions:**

```bash
# Create post-mortem report
cat > post-mortem.md <<EOF
# Ransomware Incident Post-Mortem
## Date: $(date +%Y-%m-%d)

### Incident Summary
- Detection Time: $(date)
- Containment Time: $(date -d "15 minutes")
- Resolution Time: $(date -d "4 hours")

### Root Cause
[Root cause analysis]

### Lessons Learned
- Lesson 1
- Lesson 2

### Recommendations
- Recommendation 1
- Recommendation 2
EOF

# Update playbook
git add playbook_ransomware.yaml
git commit -m "Update ransomware playbook based on incident"
git push
```

**Verification:**

- [ ] Post-mortem complete
- [ ] Detection rules updated
- [ ] Playbook updated
- [ ] Report delivered to leadership

---

## 3. Compromised Credentials Playbook

**Playbook ID:** PB-CRED-001
**Version:** 1.0
**Owner:** Incident Response Manager
**Severity:** HIGH

---

### 3.1 Response Process

#### Step 1: Alert Triage (0-5 minutes)

**Owner:** SOC Analyst

**Actions:**

```bash
# Review credential compromise alerts
curl -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"event.type": "credential_compromise"}},
          {"range": {"@timestamp": {"gte": "now-1h"}}}
        ]
      }
    }
  }'

# Identify affected user
```

#### Step 2: Account Isolation (5-10 minutes)

**Owner:** Identity Engineer

**Actions:**

```bash
# Disable account
curl -X PUT https://auth.nexus.com/admin/realms/nexus/users/{id}/disable \
  -H "Authorization: Bearer $TOKEN"

# Revoke sessions
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/logout \
  -H "Authorization: Bearer $TOKEN"

# Reset MFA tokens
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/reset-mfa \
  -H "Authorization: Bearer $TOKEN"
```

#### Step 3: Credential Rotation (10-20 minutes)

**Owner:** Identity Engineer

**Actions:**

```bash
# Reset password
curl -X PUT https://auth.nexus.com/admin/realms/nexus/users/{id}/reset-password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "password", "value": "TemporaryP@ssw0rd!", "temporary": true}'

# Rotate API keys
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/rotate-keys \
  -H "Authorization: Bearer $TOKEN"

# Revoke OAuth tokens
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/revoke-tokens \
  -H "Authorization: Bearer $TOKEN"
```

#### Step 4: Activity Review (20-60 minutes)

**Owner:** Detection Engineer

**Actions:**

```bash
# Review recent activity
curl -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"user": "jdoe"}},
          {"range": {"@timestamp": {"gte": "now-24h"}}}
        ]
      }
    }
  }'

# Check for suspicious actions
# Review all API calls
# Check for data access
```

#### Step 5: User Notification (60-90 minutes)

**Owner:** Communications Lead

**Actions:**

```bash
# Notify user
curl -X POST https://slack.nexus.com/api/chat.postMessage \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "@jdoe",
    "text": "Your account has been compromised. Please change your password and re-enroll in MFA."
  }'
```

---

## 4. Zero Trust Violation Playbook

**Playbook ID:** PB-ZT-001
**Version:** 1.0
**Owner:** Security Operations Lead
**Severity:** HIGH

---

### 4.1 Response Process

#### Step 1: Alert Triage (0-5 minutes)

**Owner:** SOC Analyst

**Actions:**

```bash
# Review Zero Trust violation
curl -X GET https://verification.nexus.com/api/violations/{id} \
  -H "Authorization: Bearer $TOKEN"

# Review user risk score
curl -X GET https://verification.nexus.com/api/users/{id}/risk \
  -H "Authorization: Bearer $TOKEN"
```

#### Step 2: Session Termination (5-10 minutes)

**Owner:** Identity Engineer

**Actions:**

```bash
# Terminate session
curl -X POST https://verification.nexus.com/api/terminate/{session_id} \
  -H "Authorization: Bearer $TOKEN"

# Revoke tokens
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/revoke-tokens \
  -H "Authorization: Bearer $TOKEN"

# Force re-authentication
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/force-auth \
  -H "Authorization: Bearer $TOKEN"
```

#### Step 3: Device Posture Check (10-20 minutes)

**Owner:** Security Engineer

**Actions:**

```bash
# Check device compliance
curl -X GET https://crowdstrike.nexus.com/api/v1/devices/{device_id} \
  -H "Authorization: Bearer $TOKEN"

# Validate security controls
```

#### Step 4: Risk Score Analysis (20-30 minutes)

**Owner:** Detection Engineer

**Actions:**

```bash
# Analyze risk factors
curl -X GET https://verification.nexus.com/api/risk/{user_id} \
  -H "Authorization: Bearer $TOKEN"

# Determine risk level
```

#### Step 5: Access Decision (30-45 minutes)

**Owner:** Security Operations Lead

**Actions:**

```bash
# Grant access if risk is low
# Require step-up if risk is medium
# Deny access if risk is high
```

---

## 5. API Abuse Playbook

**Playbook ID:** PB-API-001
**Version:** 1.0
**Owner:** Security Operations Lead
**Severity:** MEDIUM

---

### 5.1 Response Process

#### Step 1: Alert Triage (0-5 minutes)

**Owner:** SOC Analyst

**Actions:**

```bash
# Review API abuse alert
curl -X GET https://kong-admin:8001/api/rate-limit/status \
  -H "Authorization: Bearer $TOKEN"

# Identify affected API and user
```

#### Step 2: Rate Limit Adjustment (5-10 minutes)

**Owner:** Security Engineer

**Actions:**

```bash
# Apply stricter rate limits
curl -X PATCH https://kong-admin:8001/plugins/{plugin_id} \
  -H "Content-Type: application/json" \
  -d '{"config": {"minute": 10}}'

# Block malicious IPs
curl -X POST https://kong-admin:8001/blocklist/ips \
  -H "Content-Type: application/json" \
  -d '{"ip": "10.0.0.100"}'
```

#### Step 3: User Analysis (10-20 minutes)

**Owner:** Detection Engineer

**Actions:**

```bash
# Identify abusive user
curl -X GET "https://elasticsearch:9200/api-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"status_code": 429}},
          {"range": {"@timestamp": {"gte": "now-1h"}}}
        ]
      }
    },
    "aggs": {
      "by_user": {
        "terms": {"field": "user_id", "size": 10}
      }
    }
  }'
```

#### Step 4: User Action (20-30 minutes)

**Owner:** Security Engineer

**Actions:**

```bash
# Block abusive user
curl -X POST https://kong-admin:8001/blocklist/users \
  -H "Content-Type: application/json" \
  -d '{"user_id": "abusive_user"}'

# Revoke tokens
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/revoke-tokens \
  -H "Authorization: Bearer $TOKEN"
```

---

## 6. Runbooks: Quick Reference

### 6.1 System Health Checks

```bash
# Check Kubernetes cluster
kubectl get nodes
kubectl get pods -A
kubectl top nodes
kubectl top pods -A

# Check Istio status
istioctl analyze
kubectl get pods -n istio-system

# Check Keycloak
curl -k https://auth.nexus.com/health/live

# Check OPA
curl http://opa-server:8181/health

# Check Vault
curl -k https://vault.nexus.com:8200/v1/sys/health

# Check Elasticsearch
curl -k https://elasticsearch:9200/_cluster/health

# Check Kong
curl http://kong-admin:8001/status
```

### 6.2 Security Tool Commands

```bash
# Check security logs
kubectl logs -f deployment/security-logger -n security

# Check SIEM alerts
curl -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{"query": {"match": {"event.severity": "CRITICAL"}}}'

# Check XDR detections
curl -X GET https://crowdstrike.nexus.com/api/v1/detections \
  -H "Authorization: Bearer $TOKEN"

# Check Falco rules
kubectl get configmap falco-rules -n falco -o yaml
```

### 6.3 Emergency Escalation

| Contact | Method | Response Time |
|---------|--------|---------------|
| **CISO** | Mobile, PagerDuty | 5 minutes |
| **Security Team** | PagerDuty, Slack | 10 minutes |
| **IT Operations** | PagerDuty | 15 minutes |
| **Legal Counsel** | Phone | 30 minutes |
| **PR Team** | Phone | 60 minutes |
| **CEO/Board** | Phone, Email | 60 minutes |

### 6.4 Incident Reporting Template

```markdown
# Incident Report
## Incident ID: [IR-XXX]
## Date: YYYY-MM-DD

### Summary
- **Incident Type:** [Type]
- **Severity:** [Critical/High/Medium/Low]
- **Status:** [Open/Contained/Resolved/Closed]
- **Affected Systems:** [List]

### Timeline
| Time | Event | Action |
|------|-------|--------|
| | | |

### Impact
- **Business Impact:** [Description]
- **Data Impact:** [Description]
- **Users Affected:** [Count]

### Root Cause
[Root cause analysis]

### Actions Taken
- Action 1
- Action 2

### Lessons Learned
- Lesson 1
- Lesson 2

### Recommendations
- Recommendation 1
- Recommendation 2
```

---

**Document Owner**: Incident Response Manager  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX K]**

This appendix provides complete playbooks and runbooks for all major incident scenarios. These documents should be reviewed regularly and updated based on lessons learned from incidents and drills.
