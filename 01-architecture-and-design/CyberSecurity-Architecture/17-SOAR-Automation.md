# Part 4: Detection Engineering, Security Operations & Operational Resilience
## Section 4.4: SOAR Automation

## The Target: Complete SOAR Automation for Nexus Global Industries

In this section, we'll implement a comprehensive SOAR (Security Orchestration, Automation, and Response) platform for Nexus Global Industries, including:

1. **Playbook Development** - Automated response workflows
2. **Alert Enrichment** - Automated threat intelligence enrichment
3. **Case Management** - Incident tracking and collaboration
4. **Automated Response Actions** - Containment and remediation
5. **Integration Hub** - Connecting security tools

**What specific file(s) are we building?**
- `soar/01_playbooks.yaml` - Automated response playbooks
- `soar/02_enrichment.yaml` - Threat intelligence enrichment
- `soar/03_case_management.yaml` - Case management configuration
- `soar/04_automated_actions.yaml` - Automated response actions
- `soar/05_integrations.yaml` - Tool integrations

---

## The Concept: SOAR in Plain English

Think of SOAR like **a smart home security system that automatically responds to threats**:

**Playbooks:** "If motion is detected at the front door, turn on the lights and send a notification." This is automated response workflows.

**Alert Enrichment:** "When an alarm triggers, check who the alarm company is, what type of sensor, and previous activity." This is adding context to alerts.

**Case Management:** "A logbook that tracks every incident, who responded, and what actions were taken." This is incident tracking.

**Automated Response Actions:** "When the smoke alarm goes off, automatically call the fire department and unlock all doors." This is automated containment.

**Integration Hub:** "The central panel that connects the door sensors, cameras, lights, and alarm system." This is tool integration.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the soar directory
cd ~/nexus_security_architecture
mkdir -p soar

# Verify the structure
ls -la
# Expected: soar directory appears
```

---

### Step 2: SOAR Playbooks

**File:** `soar/01_playbooks.yaml`

```yaml
# SOAR Playbooks - Nexus Global Industries
# File: soar/01_playbooks.yaml
# Version: 1.0

# ====================================================================
# PLAYBOOK 1: PHISHING RESPONSE
# ====================================================================

playbook_001:
  name: "Phishing Response Playbook"
  id: "SOAR-001"
  version: "1.0"
  owner: "Incident Response Manager"
  trigger: "Email security alert"
  severity: "MEDIUM"
  priority: 3
  
  steps:
    - step: 1
      name: "Alert Triage"
      action: |
        - Receive phishing alert from email gateway
        - Validate alert is a true positive
        - Extract sender, recipient, subject, and attachment details
      automation: "semi-automated"
      tools: ["Email Gateway API", "SIEM"]
      timeout: "5m"
    
    - step: 2
      name: "Email Analysis"
      action: |
        - Extract email headers
        - Check for malicious attachments (sandbox analysis)
        - Check for malicious URLs (URL reputation)
        - Generate threat intelligence report
      automation: "fully-automated"
      tools: ["Sandbox", "Threat Intelligence", "URL Reputation"]
      timeout: "10m"
    
    - step: 3
      name: "User Isolation"
      action: |
        - Quarantine affected mailbox
        - Disable compromised account if needed
        - Force password reset
        - Revoke active sessions
      automation: "fully-automated"
      tools: ["Active Directory", "Keycloak", "Email Gateway"]
      timeout: "5m"
    
    - step: 4
      name: "Containment"
      action: |
        - Remove malicious email from all mailboxes
        - Block sender domain in email gateway
        - Update threat intelligence feeds
        - Blacklist malicious URLs in proxy
      automation: "fully-automated"
      tools: ["Email Gateway", "Proxy", "Threat Intel Platform"]
      timeout: "10m"
    
    - step: 5
      name: "User Notification"
      action: |
        - Send notification to affected users
        - Provide phishing awareness tips
        - Offer additional training if needed
      automation: "semi-automated"
      tools: ["Communication Platform", "Training Platform"]
      timeout: "15m"
    
    - step: 6
      name: "Case Documentation"
      action: |
        - Create incident case
        - Document all actions taken
        - Update incident status
        - Close case
      automation: "fully-automated"
      tools: ["Case Management", "SIEM"]
      timeout: "5m"

# ====================================================================
# PLAYBOOK 2: RANSOMWARE DETECTION
# ====================================================================

playbook_002:
  name: "Ransomware Response Playbook"
  id: "SOAR-002"
  version: "1.0"
  owner: "Incident Response Manager"
  trigger: "Ransomware detection alert"
  severity: "CRITICAL"
  priority: 1
  
  steps:
    - step: 1
      name: "Alert Triage"
      action: |
        - Receive ransomware detection alert from XDR/SIEM
        - Validate alert is a true positive
        - Identify affected systems
      automation: "semi-automated"
      tools: ["XDR", "SIEM"]
      timeout: "5m"
    
    - step: 2
      name: "Network Isolation"
      action: |
        - Isolate affected network segments (Calico policies)
        - Block communication to C2 servers
        - Quarantine infected endpoints
      automation: "fully-automated"
      tools: ["Network Policy Engine", "Firewall", "XDR"]
      timeout: "2m"
    
    - step: 3
      name: "Credential Protection"
      action: |
        - Revoke compromised credentials
        - Force password reset for affected users
        - Rotate service account passwords
      automation: "fully-automated"
      tools: ["Keycloak", "Vault", "Active Directory"]
      timeout: "5m"
    
    - step: 4
      name: "Backup Recovery"
      action: |
        - Validate latest immutable backup
        - Initiate restore from immutable backups
        - Verify data integrity after restore
      automation: "semi-automated"
      tools: ["Backup System", "Storage", "Monitoring"]
      timeout: "30m"
    
    - step: 5
      name: "System Restoration"
      action: |
        - Reimage affected systems
        - Restore data from backups
        - Validate system functionality
      automation: "semi-automated"
      tools: ["Orchestration", "Monitoring"]
      timeout: "1h"
    
    - step: 6
      name: "Post-Incident Analysis"
      action: |
        - Conduct root cause analysis
        - Update detection rules
        - Improve response playbook
        - Report to leadership
      automation: "manual"
      tools: ["Case Management", "SIEM", "Analytics"]
      timeout: "4h"

# ====================================================================
# PLAYBOOK 3: COMPROMISED CREDENTIALS
# ====================================================================

playbook_003:
  name: "Compromised Credentials Playbook"
  id: "SOAR-003"
  version: "1.0"
  owner: "Incident Response Manager"
  trigger: "Credential compromise detection"
  severity: "HIGH"
  priority: 2
  
  steps:
    - step: 1
      name: "Alert Triage"
      action: |
        - Receive credential compromise alert
        - Identify affected user account
        - Determine scope of compromise
      automation: "semi-automated"
      tools: ["SIEM", "Identity", "XDR"]
      timeout: "5m"
    
    - step: 2
      name: "User Account Isolation"
      action: |
        - Disable user account
        - Revoke all active sessions
        - Reset MFA tokens
      automation: "fully-automated"
      tools: ["Keycloak", "Active Directory"]
      timeout: "2m"
    
    - step: 3
      name: "Credential Rotation"
      action: |
        - Force password reset
        - Rotate API keys
        - Revoke OAuth tokens
        - Update service account credentials
      automation: "fully-automated"
      tools: ["Keycloak", "Vault", "API Gateway"]
      timeout: "5m"
    
    - step: 4
      name: "Activity Review"
      action: |
        - Review recent user activity
        - Identify suspicious actions
        - Check for data access
        - Review all API calls
      automation: "semi-automated"
      tools: ["SIEM", "API Gateway", "Cloud Trail"]
      timeout: "15m"
    
    - step: 5
      name: "User Notification"
      action: |
        - Notify user of compromise
        - Provide guidance on secure password
        - MFA re-enrollment
      automation: "semi-automated"
      tools: ["Communication Platform"]
      timeout: "10m"
    
    - step: 6
      name: "Case Documentation"
      action: |
        - Update case with findings
        - Document actions taken
        - Recommend security improvements
      automation: "fully-automated"
      tools: ["Case Management"]
      timeout: "5m"

# ====================================================================
# PLAYBOOK 4: ZERO TRUST VIOLATION
# ====================================================================

playbook_004:
  name: "Zero Trust Violation Playbook"
  id: "SOAR-004"
  version: "1.0"
  owner: "Security Operations Lead"
  trigger: "Zero Trust verification failure"
  severity: "HIGH"
  priority: 2
  
  steps:
    - step: 1
      name: "Alert Triage"
      action: |
        - Receive Zero Trust violation alert
        - Identify affected session/user
        - Review violation reason
      automation: "semi-automated"
      tools: ["Zero Trust Service", "SIEM"]
      timeout: "5m"
    
    - step: 2
      name: "Session Termination"
      action: |
        - Terminate affected session
        - Revoke all tokens
        - Force re-authentication
      automation: "fully-automated"
      tools: ["Zero Trust Service", "Keycloak"]
      timeout: "2m"
    
    - step: 3
      name: "Device Posture Check"
      action: |
        - Verify device compliance
        - Check for updates
        - Validate security controls
      automation: "fully-automated"
      tools: ["XDR", "Device Management"]
      timeout: "5m"
    
    - step: 4
      name: "Risk Score Analysis"
      action: |
        - Calculate user risk score
        - Analyze behavior patterns
        - Determine risk level
      automation: "fully-automated"
      tools: ["Zero Trust Service", "Analytics"]
      timeout: "5m"
    
    - step: 5
      name: "Access Decision"
      action: |
        - Grant access if risk is low
        - Require step-up auth if medium
        - Deny access if high risk
      automation: "fully-automated"
      tools: ["Zero Trust Service", "OPA"]
      timeout: "2m"
    
    - step: 6
      name: "Case Documentation"
      action: |
        - Document violation details
        - Update case with resolution
        - Track trends
      automation: "fully-automated"
      tools: ["Case Management", "SIEM"]
      timeout: "5m"

# ====================================================================
# PLAYBOOK 5: API ABUSE DETECTION
# ====================================================================

playbook_005:
  name: "API Abuse Response Playbook"
  id: "SOAR-005"
  version: "1.0"
  owner: "Security Operations Lead"
  trigger: "API rate limit exceeded"
  severity: "MEDIUM"
  priority: 3
  
  steps:
    - step: 1
      name: "Alert Triage"
      action: |
        - Receive API abuse alert
        - Identify affected API
        - Review request patterns
      automation: "semi-automated"
      tools: ["API Gateway", "SIEM"]
      timeout: "5m"
    
    - step: 2
      name: "Rate Limit Adjustment"
      action: |
        - Apply stricter rate limiting
        - Implement throttling
        - Block malicious IPs
      automation: "fully-automated"
      tools: ["API Gateway", "WAF"]
      timeout: "2m"
    
    - step: 3
      name: "User/Token Analysis"
      action: |
        - Identify abusive user/token
        - Check for compromised credentials
        - Review access patterns
      automation: "fully-automated"
      tools: ["API Gateway", "Identity", "SIEM"]
      timeout: "10m"
    
    - step: 4
      name: "User Action"
      action: |
        - Block abusive user
        - Revoke suspicious tokens
        - Notify security team
      automation: "semi-automated"
      tools: ["API Gateway", "Identity"]
      timeout: "5m"
    
    - step: 5
      name: "Case Documentation"
      action: |
        - Document abuse details
        - Update case
        - Recommend improvements
      automation: "fully-automated"
      tools: ["Case Management"]
      timeout: "5m"
```

**Verification:**

```bash
# Verify playbooks file
ls -la soar/01_playbooks.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('soar/01_playbooks.yaml'))"
# Expected: No error output

# Count playbooks
grep -c "^playbook_" soar/01_playbooks.yaml
# Expected: Shows 5 playbooks
```

---

### Step 3: Alert Enrichment

**File:** `soar/02_enrichment.yaml`

```yaml
# Alert Enrichment - Nexus Global Industries
# File: soar/02_enrichment.yaml
# Version: 1.0

# ====================================================================
# ENRICHMENT SOURCES
# ====================================================================

enrichment_sources:
  - source: "threat_intel"
    name: "Threat Intelligence Platform"
    description: "VirusTotal, AlienVault OTX, etc."
    api:
      url: "https://api.virustotal.com/v3"
      key: "${VIRUSTOTAL_API_KEY}"
    enrichment_fields:
      - "malware_family"
      - "confidence_score"
      - "first_seen"
      - "last_seen"
      - "reputation"
  
  - source: "geoip"
    name: "GeoIP Lookup"
    description: "Geolocation of IP addresses"
    api:
      url: "https://geoip.nexus.com/api"
      key: "${GEOIP_API_KEY}"
    enrichment_fields:
      - "country"
      - "city"
      - "region"
      - "coordinates"
  
  - source: "whois"
    name: "WHOIS Lookup"
    description: "Domain ownership information"
    api:
      url: "https://whois.nexus.com/api"
    enrichment_fields:
      - "registrar"
      - "owner"
      - "creation_date"
      - "expiry_date"
  
  - source: "url_reputation"
    name: "URL Reputation"
    description: "URL threat intelligence"
    api:
      url: "https://url-reputation.nexus.com/api"
    enrichment_fields:
      - "risk_score"
      - "category"
      - "is_malicious"
      - "is_phishing"

# ====================================================================
# ENRICHMENT WORKFLOWS
# ====================================================================

enrichment_workflows:
  - workflow_name: "IP Enrichment"
    trigger: "Alert contains IP address"
    steps:
      - source: "threat_intel"
        input: "source_ip"
        output: "threat_intel_ip"
      
      - source: "geoip"
        input: "source_ip"
        output: "geoip_ip"
      
      - source: "whois"
        input: "source_ip"
        output: "whois_ip"
    
    enrichment_data:
      - "ip_reputation"
      - "ip_geolocation"
      - "ip_whois"
      - "ip_malware_family"
  
  - workflow_name: "URL Enrichment"
    trigger: "Alert contains URL"
    steps:
      - source: "url_reputation"
        input: "url"
        output: "url_rep"
      
      - source: "threat_intel"
        input: "url"
        output: "url_threat"
    
    enrichment_data:
      - "url_risk_score"
      - "url_category"
      - "url_is_malicious"
  
  - workflow_name: "Email Enrichment"
    trigger: "Alert contains email"
    steps:
      - source: "threat_intel"
        input: "email"
        output: "email_threat"
    
    enrichment_data:
      - "email_reputation"
      - "email_domain"
  
  - workflow_name: "Alert Context"
    trigger: "New alert received"
    steps:
      - source: "context"
        input: "alert"
        output: "alert_context"
    
    enrichment_data:
      - "similar_alerts"
      - "alert_frequency"
      - "historical_actions"

# ====================================================================
# ENRICHMENT LOGIC
# ====================================================================

enrichment_logic:
  - rule_id: "ENRICH-001"
    name: "Malicious IP Detection"
    condition: "enrichment.threat_intel.reputation < 0"
    action: |
      Add tag: "malicious_ip"
      Set severity to: "HIGH"
      Add comment: "IP has negative reputation"
  
  - rule_id: "ENRICH-002"
    name: "Anomalous Geolocation"
    condition: "enrichment.geoip.country != user_home_country"
    action: |
      Add tag: "geo_anomaly"
      Increase risk score by 20
      Add comment: "Login from unusual location"
  
  - rule_id: "ENRICH-003"
    name: "Phishing URL Detection"
    condition: "enrichment.url_reputation.is_phishing == true"
    action: |
      Add tag: "phishing"
      Set severity to: "CRITICAL"
      Add comment: "Known phishing URL detected"
  
  - rule_id: "ENRICH-004"
    name: "Compromised Email Domain"
    condition: "enrichment.threat_intel.email_domain == 'malicious'"
    action: |
      Add tag: "malicious_domain"
      Set severity to: "HIGH"
      Add comment: "Email from known malicious domain"

# ====================================================================
# ENRICHMENT SERVICE CONFIGURATION
# ====================================================================

enrichment_service:
  name: "SOAR Enrichment Service"
  version: "1.0"
  
  settings:
    max_threads: 10
    timeout: 30
    retry_count: 3
    cache_ttl: 3600  # seconds
  
  logging:
    level: "INFO"
    destination: "SIEM"
  
  performance:
    max_concurrent: 20
    queue_size: 1000
    batch_size: 50
```

**Verification:**

```bash
# Verify enrichment file
ls -la soar/02_enrichment.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('soar/02_enrichment.yaml'))"
# Expected: No error output
```

---

### Step 4: Case Management

**File:** `soar/03_case_management.yaml`

```yaml
# Case Management - Nexus Global Industries
# File: soar/03_case_management.yaml
# Version: 1.0

# ====================================================================
# CASE FIELDS
# ====================================================================

case_fields:
  - field: "case_id"
    type: "string"
    required: true
    description: "Unique case identifier"
  
  - field: "title"
    type: "string"
    required: true
    description: "Case title"
  
  - field: "description"
    type: "string"
    required: true
    description: "Detailed case description"
  
  - field: "severity"
    type: "enum"
    required: true
    options: ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
    description: "Case severity"
  
  - field: "priority"
    type: "enum"
    required: true
    options: ["P1", "P2", "P3", "P4", "P5"]
    description: "Case priority"
  
  - field: "status"
    type: "enum"
    required: true
    options: ["OPEN", "IN_PROGRESS", "ON_HOLD", "RESOLVED", "CLOSED"]
    description: "Case status"
  
  - field: "assignee"
    type: "string"
    required: false
    description: "Assigned to user"
  
  - field: "created_at"
    type: "datetime"
    required: true
    description: "Case creation timestamp"
  
  - field: "updated_at"
    type: "datetime"
    required: true
    description: "Last updated timestamp"
  
  - field: "resolved_at"
    type: "datetime"
    required: false
    description: "Resolution timestamp"
  
  - field: "playbook_id"
    type: "string"
    required: false
    description: "Associated playbook"
  
  - field: "mitre_tactics"
    type: "array"
    required: false
    description: "MITRE ATT&CK tactics"
  
  - field: "affected_assets"
    type: "array"
    required: false
    description: "Affected assets"
  
  - field: "indicators"
    type: "array"
    required: false
    description: "Indicators of compromise"
  
  - field: "comments"
    type: "array"
    required: false
    description: "Case comments"

# ====================================================================
# CASE WORKFLOW
# ====================================================================

case_workflow:
  states:
    - name: "NEW"
      description: "Case just created"
      actions: ["ASSIGN", "INVESTIGATE"]
    
    - name: "INVESTIGATION"
      description: "Case under investigation"
      actions: ["ESCALATE", "RESOLVE", "ON_HOLD"]
    
    - name: "ON_HOLD"
      description: "Case waiting for information"
      actions: ["RESUME", "RESOLVE"]
    
    - name: "ESCALATED"
      description: "Case escalated to management"
      actions: ["INVESTIGATE", "RESOLVE"]
    
    - name: "RESOLVED"
      description: "Case resolved"
      actions: ["CLOSE", "REOPEN"]
    
    - name: "CLOSED"
      description: "Case closed"
      actions: ["REOPEN"]

# ====================================================================
# CASE SLA POLICIES
# ====================================================================

sla_policies:
  - severity: "CRITICAL"
    response_time: "15m"
    resolution_time: "4h"
    escalation_time: "1h"
    escalation_to: "CISO"
  
  - severity: "HIGH"
    response_time: "30m"
    resolution_time: "8h"
    escalation_time: "4h"
    escalation_to: "IR Manager"
  
  - severity: "MEDIUM"
    response_time: "1h"
    resolution_time: "24h"
    escalation_time: "8h"
    escalation_to: "Security Lead"
  
  - severity: "LOW"
    response_time: "4h"
    resolution_time: "48h"
    escalation_time: "24h"
    escalation_to: "Security Analyst"

# ====================================================================
# CASE AUTOMATION
# ====================================================================

case_automation:
  - rule: "AUTO-CASE-001"
    trigger: "New alert received"
    actions:
      - Create case with alert details
      - Set severity based on alert
      - Assign to appropriate team
      - Start enrichment workflow
  
  - rule: "AUTO-CASE-002"
    trigger: "Case severity updated to CRITICAL"
    actions:
      - Notify incident response team
      - Page on-call engineer
      - Create Slack channel
      - Schedule war room meeting
  
  - rule: "AUTO-CASE-003"
    trigger: "Case status changed to RESOLVED"
    actions:
      - Send resolution summary
      - Update knowledge base
      - Archive case data
      - Close case
  
  - rule: "AUTO-CASE-004"
    trigger: "SLA breach detected"
    actions:
      - Escalate to management
      - Send breach notification
      - Create SLA breach record
      - Review for improvement

# ====================================================================
# CASE TEMPLATES
# ====================================================================

case_templates:
  - name: "Phishing Incident"
    description: "Template for phishing incidents"
    fields:
      - "affected_users"
      - "email_subject"
      - "sender_domain"
      - "malicious_urls"
      - "attachment_hashes"
    actions:
      - "quarantine_mailbox"
      - "block_sender"
      - "reset_password"
  
  - name: "Ransomware Incident"
    description: "Template for ransomware incidents"
    fields:
      - "affected_systems"
      - "encryption_type"
      - "ransomware_family"
      - "ransomware_wallet"
      - "files_affected"
    actions:
      - "isolate_network"
      - "revoke_credentials"
      - "restore_backups"
      - "contain_threat"
  
  - name: "Data Breach"
    description: "Template for data breach incidents"
    fields:
      - "data_type"
      - "affected_records"
      - "exfiltration_method"
      - "affected_users"
      - "regulatory_impact"
    actions:
      - "contain_breach"
      - "notify_authorities"
      - "notify_affected"
      - "conduct_forensics"
  
  - name: "Zero Trust Violation"
    description: "Template for Zero Trust violations"
    fields:
      - "user_name"
      - "device_id"
      - "violation_reason"
      - "risk_score"
      - "action_taken"
    actions:
      - "terminate_session"
      - "step_up_auth"
      - "update_risk_score"
```

**Verification:**

```bash
# Verify case management file
ls -la soar/03_case_management.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('soar/03_case_management.yaml'))"
# Expected: No error output
```

---

### Step 5: Automated Response Actions

**File:** `soar/04_automated_actions.yaml`

```yaml
# Automated Response Actions - Nexus Global Industries
# File: soar/04_automated_actions.yaml
# Version: 1.0

# ====================================================================
# ACTION DEFINITIONS
# ====================================================================

actions:
  - action_id: "ACTION-001"
    name: "Quarantine Mailbox"
    description: "Quarantine a user's mailbox"
    tool: "Email Gateway"
    parameters:
      - name: "user_email"
        type: "string"
        required: true
      - name: "quarantine_reason"
        type: "string"
        required: false
    execution:
      timeout: "30s"
      retries: 2
    validation:
      - Check: "Mailbox is quarantined"
        method: "API call"
  
  - action_id: "ACTION-002"
    name: "Disable Account"
    description: "Disable a user account"
    tool: "Identity Provider"
    parameters:
      - name: "username"
        type: "string"
        required: true
      - name: "disable_reason"
        type: "string"
        required: false
    execution:
      timeout: "20s"
      retries: 2
    validation:
      - Check: "Account is disabled"
        method: "API call"
  
  - action_id: "ACTION-003"
    name: "Reset Password"
    description: "Force password reset"
    tool: "Identity Provider"
    parameters:
      - name: "username"
        type: "string"
        required: true
      - name: "force_reset"
        type: "boolean"
        required: false
        default: true
    execution:
      timeout: "20s"
      retries: 2
    validation:
      - Check: "Password is reset"
        method: "API call"
  
  - action_id: "ACTION-004"
    name: "Revoke Sessions"
    description: "Revoke all active sessions"
    tool: "Identity Provider"
    parameters:
      - name: "username"
        type: "string"
        required: true
    execution:
      timeout: "20s"
      retries: 2
    validation:
      - Check: "Sessions are revoked"
        method: "API call"
  
  - action_id: "ACTION-005"
    name: "Block IP"
    description: "Block an IP address"
    tool: "Network Policy Engine"
    parameters:
      - name: "ip_address"
        type: "string"
        required: true
      - name: "block_reason"
        type: "string"
        required: false
    execution:
      timeout: "30s"
      retries: 2
    validation:
      - Check: "IP is blocked"
        method: "Network check"
  
  - action_id: "ACTION-006"
    name: "Isolate Endpoint"
    description: "Isolate an endpoint from the network"
    tool: "XDR"
    parameters:
      - name: "device_id"
        type: "string"
        required: true
    execution:
      timeout: "1m"
      retries: 2
    validation:
      - Check: "Endpoint is isolated"
        method: "API call"
  
  - action_id: "ACTION-007"
    name: "Rotate Credentials"
    description: "Rotate credentials in Vault"
    tool: "Vault"
    parameters:
      - name: "secret_path"
        type: "string"
        required: true
      - name: "secret_key"
        type: "string"
        required: true
    execution:
      timeout: "1m"
      retries: 3
    validation:
      - Check: "Credentials rotated"
        method: "API call"
  
  - action_id: "ACTION-008"
    name: "Create Alert"
    description: "Create an alert in SIEM"
    tool: "SIEM"
    parameters:
      - name: "alert_title"
        type: "string"
        required: true
      - name: "severity"
        type: "string"
        required: true
        options: ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
      - name: "details"
        type: "object"
        required: false
    execution:
      timeout: "20s"
      retries: 2
    validation:
      - Check: "Alert created"
        method: "SIEM query"
  
  - action_id: "ACTION-009"
    name: "Send Notification"
    description: "Send notification via Slack/Email"
    tool: "Communication"
    parameters:
      - name: "channel"
        type: "string"
        required: true
        options: ["slack", "email", "pagerduty"]
      - name: "message"
        type: "string"
        required: true
      - name: "recipients"
        type: "array"
        required: false
    execution:
      timeout: "20s"
      retries: 2

# ====================================================================
# ACTION WORKFLOWS
# ====================================================================

action_workflows:
  - workflow_id: "WF-001"
    name: "Compromised Account Response"
    description: "Complete response workflow for compromised accounts"
    steps:
      - action: "ACTION-002"  # Disable Account
        order: 1
      - action: "ACTION-003"  # Reset Password
        order: 2
      - action: "ACTION-004"  # Revoke Sessions
        order: 3
      - action: "ACTION-008"  # Create Alert
        order: 4
        parameters:
          severity: "HIGH"
      - action: "ACTION-009"  # Send Notification
        order: 5
        parameters:
          channel: "slack"
  
  - workflow_id: "WF-002"
    name: "Malicious IP Blocking"
    steps:
      - action: "ACTION-005"  # Block IP
        order: 1
      - action: "ACTION-008"  # Create Alert
        order: 2
        parameters:
          severity: "MEDIUM"
  
  - workflow_id: "WF-003"
    name: "Endpoint Isolation"
    steps:
      - action: "ACTION-006"  # Isolate Endpoint
        order: 1
      - action: "ACTION-008"  # Create Alert
        order: 2
        parameters:
          severity: "HIGH"
      - action: "ACTION-009"  # Send Notification
        order: 3
        parameters:
          channel: "pagerduty"
  
  - workflow_id: "WF-004"
    name: "Ransomware Response"
    steps:
      - action: "ACTION-006"  # Isolate Endpoint
        order: 1
      - action: "ACTION-005"  # Block IP
        order: 2
      - action: "ACTION-004"  # Revoke Sessions
        order: 3
      - action: "ACTION-007"  # Rotate Credentials
        order: 4
      - action: "ACTION-008"  # Create Alert
        order: 5
        parameters:
          severity: "CRITICAL"
      - action: "ACTION-009"  # Send Notification
        order: 6
        parameters:
          channel: "pagerduty"

# ====================================================================
# ACTION VALIDATION
# ====================================================================

action_validation:
  - check: "Pre-Validation"
    description: "Validate action can be performed"
    steps:
      - "Check tool connectivity"
      - "Verify permissions"
      - "Validate parameters"
  
  - check: "Post-Validation"
    description: "Verify action was successful"
    steps:
      - "Query tool for confirmation"
      - "Check expected state"
      - "Log results"
  
  - check: "Rollback Validation"
    description: "Validate rollback capability"
    steps:
      - "Identify rollback procedure"
      - "Test rollback in non-production"
      - "Document rollback process"

# ====================================================================
# ACTION LOGGING
# ====================================================================

action_logging:
  log_fields:
    - "action_id"
    - "action_name"
    - "timestamp"
    - "user"
    - "parameters"
    - "result"
    - "duration"
    - "error"
  
  destinations:
    - "SIEM"
    - "Case Management"
    - "Audit Log"
  
  retention: "365d"
```

**Verification:**

```bash
# Verify automated actions file
ls -la soar/04_automated_actions.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('soar/04_automated_actions.yaml'))"
# Expected: No error output
```

---

### Step 6: SOAR Integrations

**File:** `soar/05_integrations.yaml`

```yaml
# SOAR Integrations - Nexus Global Industries
# File: soar/05_integrations.yaml
# Version: 1.0

# ====================================================================
# INTEGRATION DEFINITIONS
# ====================================================================

integrations:
  - name: "SIEM"
    type: "elasticsearch"
    description: "Elasticsearch SIEM integration"
    connection:
      host: "https://elasticsearch:9200"
      authentication:
        username: "${ES_USER}"
        password: "${ES_PASSWORD}"
    capabilities:
      - "query_logs"
      - "create_alert"
      - "update_alert"
      - "search_events"
    actions:
      - "create_alert"
      - "update_alert_status"
      - "add_comment"
  
  - name: "Identity Provider"
    type: "keycloak"
    description: "Keycloak identity provider integration"
    connection:
      host: "https://auth.nexus.com"
      realm: "nexus"
      client_id: "soar-client"
      client_secret: "${KEYCLOAK_SECRET}"
    capabilities:
      - "disable_user"
      - "reset_password"
      - "revoke_sessions"
      - "get_user"
    actions:
      - "disable_account"
      - "force_password_reset"
      - "revoke_user_sessions"
  
  - name: "Vault"
    type: "vault"
    description: "HashiCorp Vault secrets integration"
    connection:
      host: "https://vault.nexus.com:8200"
      token: "${VAULT_TOKEN}"
    capabilities:
      - "read_secret"
      - "write_secret"
      - "rotate_credentials"
    actions:
      - "rotate_credential"
      - "read_secret"
  
  - name: "XDR"
    type: "crowdstrike"
    description: "CrowdStrike Falcon XDR integration"
    connection:
      client_id: "${CROWDSTRIKE_CLIENT_ID}"
      client_secret: "${CROWDSTRIKE_CLIENT_SECRET}"
    capabilities:
      - "get_detections"
      - "isolate_host"
      - "get_events"
    actions:
      - "isolate_endpoint"
      - "get_device_details"
  
  - name: "Email Gateway"
    type: "email_security"
    description: "Email security gateway integration"
    connection:
      host: "https://email-gateway.nexus.com"
      api_key: "${EMAIL_API_KEY}"
    capabilities:
      - "quarantine_mailbox"
      - "block_sender"
      - "remove_message"
    actions:
      - "quarantine_email"
      - "block_sender_domain"
  
  - name: "Network Policy"
    type: "calico"
    description: "Calico network policy integration"
    connection:
      host: "https://kubernetes.default.svc"
      token: "${K8S_TOKEN}"
    capabilities:
      - "block_ip"
      - "create_policy"
      - "delete_policy"
    actions:
      - "block_ip_address"
      - "isolate_network_segment"
  
  - name: "Communication"
    type: "slack"
    description: "Slack communication integration"
    connection:
      webhook_url: "${SLACK_WEBHOOK_URL}"
      token: "${SLACK_TOKEN}"
    capabilities:
      - "send_message"
      - "create_channel"
    actions:
      - "send_slack_notification"
      - "create_incident_channel"
  
  - name: "Case Management"
    type: "thehive"
    description: "TheHive case management integration"
    connection:
      host: "https://thehive.nexus.com"
      api_key: "${THEHIVE_API_KEY}"
    capabilities:
      - "create_case"
      - "update_case"
      - "add_comment"
    actions:
      - "create_case"
      - "update_case_status"
      - "add_case_comment"

# ====================================================================
# INTEGRATION HEALTH CHECK
# ====================================================================

health_checks:
  - integration: "SIEM"
    check: "ping"
    interval: "60s"
    timeout: "10s"
    failure_action: "alert"
  
  - integration: "Identity Provider"
    check: "token"
    interval: "60s"
    timeout: "10s"
    failure_action: "retry"
  
  - integration: "Vault"
    check: "status"
    interval: "60s"
    timeout: "10s"
    failure_action: "alert"
  
  - integration: "XDR"
    check: "ping"
    interval: "120s"
    timeout: "15s"
    failure_action: "retry"

# ====================================================================
# INTEGRATION ERROR HANDLING
# ====================================================================

error_handling:
  - error: "connection_timeout"
    action: "retry_with_backoff"
    max_retries: 3
    backoff: "exponential"
  
  - error: "authentication_failed"
    action: "refresh_token"
    max_retries: 2
  
  - error: "rate_limited"
    action: "wait_and_retry"
    wait_time: "60s"
    max_retries: 3
  
  - error: "invalid_params"
    action: "log_and_abort"
    notify: true

# ====================================================================
# INTEGRATION LOGGING
# ====================================================================

integration_logging:
  log_fields:
    - "integration_name"
    - "action_name"
    - "timestamp"
    - "duration"
    - "status"
    - "error"
  
  destinations:
    - "SIEM"
    - "Audit Log"
  
  retention: "90d"
```

**Verification:**

```bash
# Verify integrations file
ls -la soar/05_integrations.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('soar/05_integrations.yaml'))"
# Expected: No error output
```

---

### Step 7: SOAR Summary

**File:** `soar/README.md`

```markdown
# SOAR Automation - Nexus Global Industries

## Overview

This directory contains the complete SOAR (Security Orchestration, Automation, and Response) implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_playbooks.yaml` | Playbooks | Automated response playbooks |
| `02_enrichment.yaml` | Enrichment | Threat intelligence enrichment |
| `03_case_management.yaml` | Cases | Case management configuration |
| `04_automated_actions.yaml` | Actions | Automated response actions |
| `05_integrations.yaml` | Integrations | Tool integrations |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         SOAR ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  ALERT INGESTION                                      │   │
│  │  • SIEM alerts                                       │   │
│  │  • XDR detections                                   │   │
│  │  • Email alerts                                     │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  ENRICHMENT                                           │   │
│  │  • Threat intelligence                               │   │
│  │  • GeoIP                                             │   │
│  │  • WHOIS                                             │   │
│  │  • URL reputation                                   │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  CASE MANAGEMENT                                      │   │
│  │  • Case creation                                     │   │
│  │  • Assignment                                        │   │
│  │  • SLA tracking                                      │   │
│  │  • Collaboration                                     │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  PLAYBOOKS & AUTOMATION                               │   │
│  │  • 5 playbooks                                       │   │
│  │  • 9 automated actions                              │   │
│  │  • 4 workflows                                      │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  RESPONSE ACTIONS                                     │   │
│  │  • Account management                                │   │
│  │  • Network isolation                                 │   │
│  │  • Email quarantine                                  │   │
│  │  • Credential rotation                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Description |
|---------|-------------|
| **Playbooks** | 5 automated response playbooks |
| **Enrichment** | 4 enrichment sources |
| **Actions** | 9 automated response actions |
| **Integrations** | 8 tool integrations |
| **Cases** | Complete case management |
| **SLA** | SLA tracking and enforcement |

## Deployment Instructions

### 1. Deploy SOAR Service

```bash
kubectl apply -f soar/01_playbooks.yaml
kubectl apply -f soar/02_enrichment.yaml
kubectl apply -f soar/03_case_management.yaml
kubectl apply -f soar/04_automated_actions.yaml
kubectl apply -f soar/05_integrations.yaml
```

### 2. Configure Integrations

Set environment variables for integrations:
- `ES_USER`, `ES_PASSWORD`
- `KEYCLOAK_SECRET`
- `VAULT_TOKEN`
- `CROWDSTRIKE_CLIENT_ID`, `CROWDSTRIKE_CLIENT_SECRET`
- `SLACK_WEBHOOK_URL`
- `THEHIVE_API_KEY`

### 3. Test Playbooks

Run test playbooks to validate automation:

```bash
python3 test_soar_playbooks.py
```

## Verification Checklist

- [ ] Playbooks deployed
- [ ] Enrichment configured
- [ ] Case management working
- [ ] Automated actions tested
- [ ] Integrations connected
- [ ] SLA policies enforced
- [ ] Alerts triggering playbooks
- [ ] Response actions executing

---

**Maintained By**: Incident Response Manager  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la soar/README.md
# Expected: File exists

echo "✅ SOAR Automation Complete!"
echo "   - 5 automated response playbooks"
echo "   - 4 enrichment sources"
echo "   - 9 automated response actions"
echo "   - 8 tool integrations"
echo "   - Complete case management"
```

---

## End of Section 4.4: SOAR Automation

### Key Takeaway

You've implemented a comprehensive SOAR automation platform for Nexus Global Industries, including 5 automated response playbooks, 4 enrichment sources, 9 automated response actions, 8 tool integrations, and complete case management with SLA enforcement. This provides automated, orchestrated security response capabilities.

### What's Next

**Section 4.5** will cover **Chaos Engineering**, including:
- Failure domain testing
- Security chaos experiments
- Resilience validation
- MTTD/MTTR measurement
- Chaos test automation
