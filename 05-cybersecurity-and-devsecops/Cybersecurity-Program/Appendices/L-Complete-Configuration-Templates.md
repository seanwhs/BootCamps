# Appendix L: Complete Configuration Templates

## Overview

This appendix provides complete, production-ready configuration templates for all major security tools and platforms used in the Enterprise Cybersecurity Program. These templates are designed to be used as baselines for implementation and can be customized for specific organizational requirements.

---

## L.1: SIEM Configuration Templates

### L.1.1: Splunk Enterprise Security Configuration

**File:** `config-templates/splunk-es-config.conf`

```ini
# Splunk Enterprise Security Configuration
# Version: 9.2.0
# Environment: Production

# ============================================
# 1. GLOBAL SETTINGS
# ============================================

[general]
serverName = splunk-es-prod
site = site1
indexAndForward = false
sslVerifyServerCert = true
sslCommonNameToCheck = splunk-es-prod.company.com

# ============================================
# 2. INDEX CONFIGURATION
# ============================================

# Security Indexes
[default]
homePath = $SPLUNK_DB/$_index_name/db
coldPath = $SPLUNK_DB/$_index_name/colddb
thawedPath = $SPLUNK_DB/$_index_name/thaweddb
maxHotBuckets = 3
maxTotalDataSizeMB = 1024000

# Main Index
[volume:main]
path = $SPLUNK_DB/main
maxSize = 500000
maxVolumeDataSizeMB = 512000

# Security Index
[volume:security]
path = $SPLUNK_DB/security
maxSize = 1000000
maxVolumeDataSizeMB = 1024000

# Index Settings
[security]
homePath = volume:security/$_index_name/db
coldPath = volume:security/$_index_name/colddb
thawedPath = volume:security/$_index_name/thaweddb
maxHotBuckets = 3
frozenTimePeriodInSecs = 31536000  # 1 year
maxTotalDataSizeMB = 1024000

[firewall]
homePath = volume:security/$_index_name/db
coldPath = volume:security/$_index_name/colddb
thawedPath = volume:security/$_index_name/thaweddb
maxHotBuckets = 3
frozenTimePeriodInSecs = 31536000
maxTotalDataSizeMB = 512000

[cloudtrail]
homePath = volume:security/$_index_name/db
coldPath = volume:security/$_index_name/colddb
thawedPath = volume:security/$_index_name/thaweddb
maxHotBuckets = 3
frozenTimePeriodInSecs = 31536000
maxTotalDataSizeMB = 512000

[windows]
homePath = volume:security/$_index_name/db
coldPath = volume:security/$_index_name/colddb
thawedPath = volume:security/$_index_name/thaweddb
maxHotBuckets = 3
frozenTimePeriodInSecs = 31536000
maxTotalDataSizeMB = 1024000

[linux]
homePath = volume:security/$_index_name/db
coldPath = volume:security/$_index_name/colddb
thawedPath = volume:security/$_index_name/thaweddb
maxHotBuckets = 3
frozenTimePeriodInSecs = 31536000
maxTotalDataSizeMB = 512000

# ============================================
# 3. INPUT CONFIGURATION
# ============================================

[inputs.conf]

# Syslog Inputs
[tcp://514]
connection_host = dns
sourcetype = syslog
disabled = 0
index = main

[tcp://515]
connection_host = dns
sourcetype = firewall
disabled = 0
index = firewall

# Windows Event Logs
[WinEventLog://Application]
index = windows
sourcetype = WinEventLog:Application
disabled = 0

[WinEventLog://Security]
index = windows
sourcetype = WinEventLog:Security
disabled = 0

[WinEventLog://System]
index = windows
sourcetype = WinEventLog:System
disabled = 0

[WinEventLog://Windows PowerShell]
index = windows
sourcetype = WinEventLog:PowerShell
disabled = 0

# Linux System Logs
[monitor:///var/log/syslog]
index = linux
sourcetype = syslog
disabled = 0

[monitor:///var/log/auth.log]
index = linux
sourcetype = authlog
disabled = 0

[monitor:///var/log/secure]
index = linux
sourcetype = secure
disabled = 0

[monitor:///var/log/messages]
index = linux
sourcetype = linux_messages
disabled = 0

# Application Logs
[monitor:///var/log/applications/*.log]
index = application
sourcetype = app_log
disabled = 0

# Network Logs
[monitor:///var/log/network/*.log]
index = network
sourcetype = network_log
disabled = 0

# ============================================
# 4. OUTPUT CONFIGURATION
# ============================================

[outputs.conf]

[tcpout]
defaultGroup = primary_indexers
sendCookedData = true
indexAndForward = false

[tcpout:primary_indexers]
server = idx1.company.com:9997, idx2.company.com:9997, idx3.company.com:9997
sslVerifyServerCert = true
sslCommonNameToCheck = idx.company.com
maxQueueSize = 500MB
useACK = true

# ============================================
# 5. FIELD EXTRACTION
# ============================================

[props.conf]

[firewall]
INDEXED_EXTRACTIONS = firewall
KV_MODE = json
TIME_FORMAT = %Y-%m-%d %H:%M:%S
SHOULD_LINEMERGE = false
category = Firewall
description = Firewall Logs
pulldown_type = 1

[syslog]
INDEXED_EXTRACTIONS = syslog
KV_MODE = none
TIME_FORMAT = %b %d %H:%M:%S
SHOULD_LINEMERGE = false
category = System
description = Syslog

[WinEventLog:Security]
INDEXED_EXTRACTIONS = xml
KV_MODE = xml
TIME_FORMAT = %Y-%m-%d %H:%M:%S
SHOULD_LINEMERGE = false
category = Windows Security
description = Windows Security Logs

[aws:cloudtrail]
INDEXED_EXTRACTIONS = json
KV_MODE = json
TIME_FORMAT = %Y-%m-%d %H:%M:%S
SHOULD_LINEMERGE = false
category = AWS
description = AWS CloudTrail Logs

[aws:vpcflow]
INDEXED_EXTRACTIONS = csv
KV_MODE = none
TIME_FORMAT = %Y-%m-%d %H:%M:%S
SHOULD_LINEMERGE = false
category = AWS
description = AWS VPC Flow Logs

# ============================================
# 6. CORRELATION RULES
# ============================================

# Multiple Failed Logins
[rule:multiple_failed_logins]
search = 
  index=windows OR index=linux 
  sourcetype=WinEventLog:Security OR sourcetype=authlog 
  EventCode=4625 OR (sourcetype=authlog "Failed password")
  | stats count by user, src_ip, host
  | where count > 5
  | eval severity = "medium"
  | eval description = "Multiple failed login attempts: " + user + " from " + src_ip
  | eval action = "alert"
time_window = 300  # 5 minutes
trigger_count = 5
description = Multiple failed login attempts

# Privilege Escalation
[rule:privilege_escalation]
search = 
  index=windows 
  sourcetype=WinEventLog:Security 
  (EventCode=4672 OR EventCode=4673 OR EventCode=4768)
  | eval severity = "high"
  | eval description = "Privilege escalation detected: " + user
  | eval action = "alert"
time_window = 60
trigger_count = 1
description = Privilege escalation detection

# Malware Detection
[rule:malware_detection]
search = 
  index=edr 
  sourcetype=crowdstrike:alert 
  (event_type=malware OR event_type=ransomware)
  | eval severity = "critical"
  | eval description = "Malware detected on host: " + host
  | eval action = "alert"
time_window = 60
trigger_count = 1
description = Malware detection

# Data Exfiltration
[rule:data_exfiltration]
search = 
  index=firewall OR index=network 
  sourcetype=firewall OR sourcetype=network_log 
  bytes_out > 10000000
  | stats sum(bytes_out) as total_bytes by src_ip, dest_ip
  | where total_bytes > 50000000
  | eval severity = "high"
  | eval description = "Large data transfer detected: " + src_ip + " to " + dest_ip
  | eval action = "alert"
time_window = 3600
trigger_count = 1
description = Data exfiltration detection

# ============================================
# 7. ALERT CONFIGURATION
# ============================================

[alert:critical]
cron_schedule = *
alert_suppress = 30
alert_actions = email, webhook
alert_severity = critical

[alert:high]
cron_schedule = *
alert_suppress = 60
alert_actions = email, webhook
alert_severity = high

[alert:medium]
cron_schedule = *
alert_suppress = 120
alert_actions = email
alert_severity = medium

# ============================================
# 8. USER AND AUTHENTICATION
# ============================================

[authentication.conf]
authType = LDAP
authSettings = ldap_settings
allowEmptyUsername = false

[role:security_analyst]
capabilities = search, dashboard, alert_edit
importRoles = user
description = Security Analyst - SOC Team

[role:soc_manager]
capabilities = search, dashboard, alert_edit, admin_all_objects
importRoles = user
description = SOC Manager

[role:security_admin]
capabilities = admin_all_objects, change_own_password
importRoles = user
description = Security Administrator

# ============================================
# 9. DASHBOARD CONFIGURATION
# ============================================

[dashboard:security_overview]
title = Security Overview Dashboard
description = Overall security posture dashboard
refresh = 60
panels = 
  alerts_summary, threat_overview, top_attackers, 
  vulnerability_summary, compliance_status

[dashboard:soc_operations]
title = SOC Operations Dashboard
description = SOC team operations dashboard
refresh = 30
panels = 
  incident_queue, alert_volume, response_time, 
  open_incidents, escalation_status

[dashboard:executive]
title = Executive Security Dashboard
description = Executive-level security summary
refresh = 3600
panels = 
  security_rating, risk_trend, incident_summary, 
  compliance_score, kpi_summary
```

---

## L.2: EDR/XDR Configuration Templates

### L.2.1: CrowdStrike Falcon Configuration

**File:** `config-templates/crowdstrike-config.yaml`

```yaml
# CrowdStrike Falcon Configuration
# Version: 7.5.0
# Environment: Production

# ============================================
# 1. GENERAL SETTINGS
# ============================================

customer_id: "CUSTOMER_ID"
base_url: "https://api.crowdstrike.com"
api_timeout: 30
api_retries: 3

# ============================================
# 2. PREVENTION POLICIES
# ============================================

prevention_policies:
  # Windows Production Policy
  windows_production:
    name: "Windows Production Policy"
    description: "Production Windows endpoints"
    severity: "High"
    enforcement: true
    endpoint_groups:
      - "Windows-Servers"
      - "Windows-Workstations"
    settings:
      malware_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Quarantine"
      exploit_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Block"
      ransomware_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Block"
        backup_protection: true
      behavioral_analysis:
        enabled: true
        prevention_level: "Aggressive"
        action: "Alert"
        machine_learning: true
      vulnerability_protection:
        enabled: true
        prevention_level: "High"
        action: "Block"
      web_protection:
        enabled: true
        prevention_level: "High"
        action: "Block"
        categories:
          - "malware"
          - "phishing"
          - "ransomware"

  # Linux Production Policy
  linux_production:
    name: "Linux Production Policy"
    description: "Production Linux endpoints"
    severity: "High"
    enforcement: true
    endpoint_groups:
      - "Linux-Servers"
    settings:
      malware_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Quarantine"
      exploit_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Block"
      ransomware_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Block"

  # MacOS Production Policy
  macos_production:
    name: "MacOS Production Policy"
    description: "Production MacOS endpoints"
    severity: "High"
    enforcement: true
    endpoint_groups:
      - "MacOS-Workstations"
    settings:
      malware_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Quarantine"
      exploit_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Block"

  # Mobile Devices Policy
  mobile_production:
    name: "Mobile Production Policy"
    description: "Production mobile devices"
    severity: "Medium"
    enforcement: true
    endpoint_groups:
      - "Mobile-Devices"
    settings:
      malware_protection:
        enabled: true
        prevention_level: "Standard"
        action: "Alert"
      web_protection:
        enabled: true
        prevention_level: "Standard"
        action: "Alert"

# ============================================
# 3. DETECTION POLICIES
# ============================================

detection_policies:
  production_detection:
    name: "Production Detection Policy"
    description: "Primary detection policy"
    enabled: true
    endpoint_groups:
      - "Production-Endpoints"
    detections:
      malware_detection:
        name: "Malware Detection"
        severity: "High"
        enabled: true
        action: "Alert"
      ransomware_detection:
        name: "Ransomware Detection"
        severity: "Critical"
        enabled: true
        action: "Alert"
      exploit_detection:
        name: "Exploit Detection"
        severity: "High"
        enabled: true
        action: "Alert"
      credential_theft:
        name: "Credential Theft"
        severity: "High"
        enabled: true
        action: "Alert"
      privilege_escalation:
        name: "Privilege Escalation"
        severity: "High"
        enabled: true
        action: "Alert"
      data_exfiltration:
        name: "Data Exfiltration"
        severity: "Critical"
        enabled: true
        action: "Alert"
      suspicious_network:
        name: "Suspicious Network"
        severity: "Medium"
        enabled: true
        action: "Alert"

# ============================================
# 4. RESPONSE ACTIONS
# ============================================

response_actions:
  # Critical Severity
  - name: "Isolate Critical Endpoint"
    enabled: true
    severity: "Critical"
    action: "isolate"
    notification: true
    approval: "auto"
    timeout: 60

  # High Severity
  - name: "Quarantine High Severity"
    enabled: true
    severity: "High"
    action: "quarantine"
    notification: true
    approval: "semi-auto"
    timeout: 120

  # Medium Severity
  - name: "Alert Medium Severity"
    enabled: true
    severity: "Medium"
    action: "alert"
    notification: true
    approval: "manual"
    timeout: 300

  # Ransomware Specific
  - name: "Ransomware Response"
    enabled: true
    detections:
      - "ransomware_detection"
    actions:
      - "isolate"
      - "quarantine"
      - "alert"
    notification: true
    approval: "auto"
    timeout: 30

# ============================================
# 5. EXCLUSIONS
# ============================================

exclusions:
  path_exclusions:
    - path: "C:\\Program Files\\\\*\\"
      type: "directory"
      reason: "Trusted application"
    - path: "C:\\Windows\\System32\\*\\"
      type: "directory"
      reason: "System files"
    - path: "/usr/local/bin/*"
      type: "directory"
      reason: "Trusted Linux binaries"

  process_exclusions:
    - process: "svchost.exe"
      reason: "Windows system process"
    - process: "systemd"
      reason: "Linux system process"
    - process: "launchd"
      reason: "MacOS system process"

  network_exclusions:
    - ip: "10.0.0.0/8"
      reason: "Internal network"
    - ip: "172.16.0.0/12"
      reason: "Internal network"
    - ip: "192.168.0.0/16"
      reason: "Internal network"

# ============================================
# 6. REPORTING
# ============================================

reporting:
  daily:
    - "Endpoint Health Report"
    - "Detection Summary Report"
    - "Incident Response Report"
  weekly:
    - "Threat Analysis Report"
    - "Response Effectiveness Report"
    - "Vulnerability Summary Report"
  monthly:
    - "Executive Security Report"
    - "Compliance Status Report"
    - "Program Effectiveness Report"

# ============================================
# 7. SIEM INTEGRATION
# ============================================

siem_integration:
  enabled: true
  platform: "splunk"
  forwarding:
    - "alerts"
    - "detections"
    - "incidents"
    - "events"
  frequency: "real-time"
  filter:
    severity: ["Critical", "High"]
```

---

## L.3: IAM Configuration Templates

### L.3.1: Azure AD Configuration

**File:** `config-templates/azuread-config.yaml`

```yaml
# Azure AD Configuration
# Version: Entra ID
# Environment: Production

# ============================================
# 1. TENANT SETTINGS
# ============================================

tenant:
  id: "TENANT_ID"
  name: "Company-Entra-ID"
  domain: "company.onmicrosoft.com"
  country: "US"
  language: "en-us"

# ============================================
# 2. AUTHENTICATION METHODS
# ============================================

authentication_methods:
  enabled:
    - "passwordless"
    - "mfa"
    - "sms"
    - "voice"
    - "totp"
    - "authenticator"

  passwordless:
    enabled: true
    methods:
      - "FIDO2"
      - "Microsoft Authenticator"
    discovery: true

  mfa:
    enabled: true
    methods:
      - "TOTP"
      - "SMS"
      - "Voice"
      - "Microsoft Authenticator"
    registration:
      enabled: true
      grace_period: 30
    enforcement:
      privileged: true
      all_users: true

# ============================================
# 3. PASSWORD POLICIES
# ============================================

password_policy:
  length_min: 16
  complexity: "3_of_4"
  history: 24
  age: 90
  lockout:
    threshold: 5
    duration: 15
  change:
    required: true
    notification: 14

# ============================================
# 4. CONDITIONAL ACCESS POLICIES
# ============================================

conditional_access_policies:
  - name: "Block Legacy Authentication"
    enabled: true
    priority: 1
    conditions:
      - "Client == Legacy"
      - "App == All Apps"
    actions:
      - "block"
    exceptions:
      - "BreakGlassUsers"

  - name: "MFA Required for Privileged"
    enabled: true
    priority: 2
    conditions:
      - "Role == Admin"
      - "App == All Apps"
    actions:
      - "require_mfa"

  - name: "MFA Required for External"
    enabled: true
    priority: 3
    conditions:
      - "UserType == Guest"
      - "App == All Apps"
    actions:
      - "require_mfa"

  - name: "Location-Based Access"
    enabled: true
    priority: 4
    conditions:
      - "Location != Trusted"
      - "App == All Apps"
    actions:
      - "require_mfa"
      - "block_unmanaged"

  - name: "Block High-Risk Users"
    enabled: true
    priority: 5
    conditions:
      - "Risk == High"
      - "App == All Apps"
    actions:
      - "block"

# ============================================
# 5. ROLE-BASED ACCESS CONTROL
# ============================================

roles:
  - name: "Global Administrator"
    type: "built-in"
    users: 3
    privileged: true

  - name: "Security Administrator"
    type: "built-in"
    users: 10
    privileged: true

  - name: "Conditional Access Administrator"
    type: "built-in"
    users: 5
    privileged: true

  - name: "User Administrator"
    type: "built-in"
    users: 15
    privileged: false

  - name: "Security Operator"
    type: "built-in"
    users: 20
    privileged: false

  - name: "Application Administrator"
    type: "built-in"
    users: 10
    privileged: false

  - name: "Application Developer"
    type: "built-in"
    users: 50
    privileged: false

  - name: "BreakGlass"
    type: "custom"
    users: 2
    privileged: true
    properties:
      - "Emergency"
      - "Critical"

# ============================================
# 6. APPLICATION INTEGRATION
# ============================================

applications:
  - name: "SAP"
    type: "Enterprise"
    sso: "SAML"
    users: 1000
    provisioning: true

  - name: "Salesforce"
    type: "Enterprise"
    sso: "SAML"
    users: 500
    provisioning: true

  - name: "Microsoft 365"
    type: "Cloud"
    sso: "Native"
    users: 10000
    provisioning: true

  - name: "Workday"
    type: "Enterprise"
    sso: "SAML"
    users: 200
    provisioning: true

  - name: "Confluence"
    type: "Enterprise"
    sso: "SAML"
    users: 500
    provisioning: false

  - name: "Jira"
    type: "Enterprise"
    sso: "SAML"
    users: 500
    provisioning: false

  - name: "GitHub"
    type: "Enterprise"
    sso: "SAML"
    users: 200
    provisioning: false

# ============================================
# 7. USER PROVISIONING
# ============================================

provisioning:
  source: "Workday"
  method: "SCIM"
  frequency: "Real-time"
  attributes:
    mapping:
      - name: "firstName"
        source: "givenName"
      - name: "lastName"
        source: "familyName"
      - name: "email"
        source: "mail"
      - name: "department"
        source: "department"
      - name: "title"
        source: "title"
      - name: "manager"
        source: "manager"

  lifecycle:
    onboarding:
      enabled: true
      delay: 0
    offboarding:
      enabled: true
      delay: 24
    changes:
      enabled: true
      delay: 0

# ============================================
# 8. ACCESS REVIEWS
# ============================================

access_reviews:
  - name: "User Access"
    frequency: "Quarterly"
    reviewers: "Manager"
    duration: 30
    auto_review: true

  - name: "Privileged Access"
    frequency: "Monthly"
    reviewers: "Security Team"
    duration: 14
    auto_review: false

  - name: "Application Access"
    frequency: "Quarterly"
    reviewers: "Application Owner"
    duration: 30
    auto_review: false

  - name: "Vendor Access"
    frequency: "Monthly"
    reviewers: "Procurement"
    duration: 14
    auto_review: false

# ============================================
# 9. LOGGING AND MONITORING
# ============================================

logging:
  enabled: true
  retention: 90
  categories:
    - "audit"
    - "sign-in"
    - "provisioning"
    - "risk"
    - "security"

monitoring:
  enabled: true
  alerts:
    - "Unusual Sign-ins"
    - "Impossible Travel"
    - "Risky Users"
    - "Privileged Role Changes"
    - "Failed MFA"

# ============================================
# 10. BACKUP AND RECOVERY
# ============================================

backup:
  configuration:
    enabled: true
    frequency: "Daily"
    retention: 30
  directory:
    enabled: true
    frequency: "Daily"
    retention: 7
  users:
    enabled: true
    frequency: "Daily"
    retention: 7
```

---

## L.4: Network Security Configuration Templates

### L.4.1: Firewall Configuration Template

**File:** `config-templates/firewall-config.conf`

```bash
# Firewall Configuration Template
# Platform: pfSense/OPNsense
# Version: 2.7.0

# ============================================
# 1. INTERFACE CONFIGURATION
# ============================================

# WAN Interface
set int 1 name WAN
set int 1 ip 203.0.113.1/24
set int 1 gateway 203.0.113.254

# LAN Interface
set int 2 name LAN
set int 2 ip 10.0.0.1/16

# DMZ Interface
set int 3 name DMZ
set int 3 ip 10.0.100.1/24

# Management Interface
set int 4 name MGMT
set int 4 ip 10.0.200.1/24

# ============================================
# 2. DEFAULT POLICIES
# ============================================

# Default Deny
set policy default deny

# LAN to Internet
set policy allow src LAN dst ANY service ANY log

# DMZ to Internet
set policy allow src DMZ dst ANY service HTTP,HTTPS,DNS log

# LAN to DMZ
set policy allow src LAN dst DMZ service ANY log

# WAN to DMZ
set policy deny src WAN dst DMZ service ANY log

# Management Access
set policy allow src MGMT dst ANY service SSH,HTTPS log

# ============================================
# 3. ACL RULES
# ============================================

# Rule 1: Allow Established Connections
set acl rule 1 action allow
set acl rule 1 src any
set acl rule 1 dst any
set acl rule 1 proto tcp
set acl rule 1 state established
set acl rule 1 description "Allow Established"

# Rule 2: Allow ICMP
set acl rule 2 action allow
set acl rule 2 src any
set acl rule 2 dst any
set acl rule 2 proto icmp
set acl rule 2 description "Allow ICMP"

# Rule 3: Allow HTTPS from Any
set acl rule 3 action allow
set acl rule 3 src any
set acl rule 3 dst any
set acl rule 3 proto tcp
set acl rule 3 dport 443
set acl rule 3 description "Allow HTTPS"

# Rule 4: Allow HTTP from Any
set acl rule 4 action allow
set acl rule 4 src any
set acl rule 4 dst any
set acl rule 4 proto tcp
set acl rule 4 dport 80
set acl rule 4 description "Allow HTTP"

# Rule 5: Allow DNS
set acl rule 5 action allow
set acl rule 5 src any
set acl rule 5 dst DNS
set acl rule 5 proto udp
set acl rule 5 dport 53
set acl rule 5 description "Allow DNS"

# Rule 6: Allow SSH from Management
set acl rule 6 action allow
set acl rule 6 src MGMT
set acl rule 6 dst any
set acl rule 6 proto tcp
set acl rule 6 dport 22
set acl rule 6 description "Allow SSH from MGMT"

# Rule 7: Allow VPN
set acl rule 7 action allow
set acl rule 7 src any
set acl rule 7 dst VPN
set acl rule 7 proto udp
set acl rule 7 dport 1194
set acl rule 7 description "Allow VPN"

# Rule 8: Allow SMTP (Outbound)
set acl rule 8 action allow
set acl rule 8 src LAN
set acl rule 8 dst MAIL
set acl rule 8 proto tcp
set acl rule 8 dport 25,587
set acl rule 8 description "Allow SMTP"

# Rule 9: Allow IMAPS/POP3S
set acl rule 9 action allow
set acl rule 9 src LAN
set acl rule 9 dst MAIL
set acl rule 9 proto tcp
set acl rule 9 dport 993,995
set acl rule 9 description "Allow IMAPS/POP3S"

# Rule 10: Block All Others
set acl rule 10 action deny
set acl rule 10 src any
set acl rule 10 dst any
set acl rule 10 proto any
set acl rule 10 description "Default Deny"
set acl rule 10 log yes

# ============================================
# 4. NAT RULES
# ============================================

# NAT for Outbound
set nat rule 1 action masquerade
set nat rule 1 src LAN
set nat rule 1 dst ANY
set nat rule 1 description "Masquerade LAN"

# Port Forward: HTTPS
set nat rule 2 action dnat
set nat rule 2 src any
set nat rule 2 dst WAN
set nat rule 2 proto tcp
set nat rule 2 dport 443
set nat rule 2 target 10.0.0.100:443
set nat rule 2 description "Port Forward HTTPS"

# Port Forward: SSH
set nat rule 3 action dnat
set nat rule 3 src MGMT
set nat rule 3 dst WAN
set nat rule 3 proto tcp
set nat rule 3 dport 22
set nat rule 3 target 10.0.0.101:22
set nat rule 3 description "Port Forward SSH"

# ============================================
# 5. VPN CONFIGURATION
# ============================================

# OpenVPN Server
set vpn type openvpn
set vpn mode server
set vpn protocol udp
set vpn port 1194
set vpn network 10.0.99.0/24
set vpn dns 10.0.0.2
set vpn compression yes
set vpn auth type cert
set vpn encryption AES-256-CBC
set vpn hash SHA-256
set vpn client config default
set vpn routes push 10.0.0.0/16
set vpn routes push 10.0.100.0/24

# VPN Client Access
set vpn client allow src VPN dst LAN any
set vpn client allow src VPN dst DMZ any
set vpn client deny src VPN dst ANY

# ============================================
# 6. IPS/IDS CONFIGURATION
# ============================================

# Suricata Configuration
set ids enabled yes
set ids ruleset emerging-threats
set ids mode inline
set ids interface LAN
set ids interface WAN
set ids interface DMZ

# Enable Rules
set ids rule 1 sid 2013501 action alert
set ids rule 2 sid 2013502 action alert
set ids rule 3 sid 2013503 action alert

# ============================================
# 7. LOGGING AND MONITORING
# ============================================

# Enable Logging
set log enabled yes
set log level info
set log syslog server 10.0.0.3:514
set log facility local1
set log format JSON

# Enable Firewall Logging
set log firewall enabled yes
set log firewall deny yes
set log firewall allow no

# ============================================
# 8. HIGH AVAILABILITY
# ============================================

# CARP Configuration
set ha enabled yes
set ha mode carp
set ha peer 203.0.113.2
set ha password SECURE_PASSWORD
set ha interface WAN
set ha vhid 1
set ha advbase 1
set ha advskew 100

# Synchronization
set ha sync enabled yes
set ha sync config yes
set ha sync state yes
set ha sync filter

# ============================================
# 9. MANAGEMENT ACCESS
# ============================================

# Web Interface
set management web enabled yes
set management web ssl yes
set management web port 443
set management web allow 10.0.0.0/16
set management web allow 10.0.200.0/24

# SSH
set management ssh enabled yes
set management ssh allow 10.0.0.0/16
set management ssh allow 10.0.200.0/24

# API
set management api enabled yes
set management api https yes
set management api port 8443
set management api allow 10.0.0.0/16
```

---

## L.5: Backup and Recovery Configuration Templates

### L.5.1: Veeam Backup Configuration

**File:** `config-templates/veeam-config.yaml`

```yaml
# Veeam Backup & Replication Configuration
# Version: 12.0
# Environment: Production

# ============================================
# 1. GENERAL SETTINGS
# ============================================

general:
  server_name: "veeam-backup-prod"
  domain: "company.local"
  timezone: "UTC"
  license_file: "veeam.lic"

# ============================================
# 2. BACKUP INFRASTRUCTURE
# ============================================

backup_servers:
  - name: "Backup Server 1"
    role: "primary"
    ip: "10.0.0.100"
    storage: "/backups"
    capacity: "50TB"
  - name: "Backup Server 2"
    role: "secondary"
    ip: "10.0.1.100"
    storage: "/backups"
    capacity: "50TB"

repositories:
  - name: "Production Backup Repository"
    type: "Deduplicating"
    location: "/backups/production"
    capacity: "30TB"
    dedup_ratio: "3:1"
    compression: "Optimal"
    encryption: true
    encryption_method: "AES-256"

  - name: "Archive Repository"
    type: "Simple"
    location: "/backups/archive"
    capacity: "20TB"
    encryption: true

  - name: "Cloud Repository"
    type: "AWS S3"
    location: "s3://company-backups"
    region: "us-east-1"
    encryption: true
    immutability: true
    immutability_days: 30

# ============================================
# 3. BACKUP JOBS
# ============================================

backup_jobs:
  # Critical Servers
  - name: "Critical Server Backup"
    enabled: true
    schedule: "Daily at 22:00"
    type: "Full"
    retention: "30 days"
    targets:
      - "Exchange"
      - "SQL Server"
      - "Active Directory"
    repository: "Production Backup Repository"
    encryption: true
    pre_job_script: "/scripts/backup_pre_check.sh"
    post_job_script: "/scripts/backup_post_check.sh"

  # Database Servers
  - name: "Database Backup"
    enabled: true
    schedule: "Hourly"
    type: "Incremental"
    retention: "7 days"
    targets:
      - "Production Databases"
    repository: "Production Backup Repository"
    encryption: true
    pre_job_script: "/scripts/db_backup_pre.sh"

  # File Servers
  - name: "File Server Backup"
    enabled: true
    schedule: "Daily at 23:00"
    type: "Full"
    retention: "90 days"
    targets:
      - "File Servers"
    repository: "Archive Repository"
    encryption: true

  # Cloud Backup
  - name: "Cloud Backup"
    enabled: true
    schedule: "Daily at 02:00"
    type: "Full"
    retention: "365 days"
    targets:
      - "Critical Data"
    repository: "Cloud Repository"
    encryption: true
    immutability: true

# ============================================
# 4. REPLICATION JOBS
# ============================================

replication_jobs:
  - name: "Critical VM Replication"
    enabled: true
    schedule: "Every 4 hours"
    source: "Production"
    target: "DR Site"
    retention: "7 days"
    compression: true

  - name: "Offsite Replication"
    enabled: true
    schedule: "Daily"
    source: "Production"
    target: "Cloud"
    retention: "30 days"
    compression: true

# ============================================
# 5. RESTORE POINT POLICY
# ============================================

restore_points:
  daily:
    retention: 30
    target: "Production Repository"
  weekly:
    retention: 12
    target: "Archive Repository"
  monthly:
    retention: 12
    target: "Cloud Repository"
  yearly:
    retention: 7
    target: "Cloud Repository"

# ============================================
# 6. SURETAPES
# ============================================

suretapes:
  - name: "Weekly SureTape"
    enabled: true
    frequency: "Weekly"
    backup_job: "Critical Server Backup"
    repository: "Production Backup Repository"
    virtual_lab: "Veeam Lab"
    timeframe: "4 hours"

# ============================================
# 7. NOTIFICATIONS
# ============================================

notifications:
  smtp:
    server: "smtp.company.com"
    port: 587
    use_tls: true
    from: "backup@company.com"
    to:
      - "security@company.com"
      - "it-ops@company.com"
  
  alert_rules:
    - event: "Backup Failed"
      severity: "Critical"
      notifications: ["Email", "SMS"]
    - event: "Backup Completed"
      severity: "Info"
      notifications: []
    - event: "Repository Low Space"
      severity: "Warning"
      notifications: ["Email"]

# ============================================
# 8. REPORTING
# ============================================

reporting:
  - name: "Daily Backup Summary"
    frequency: "Daily"
    format: "PDF"
    send_to: "management"
  
  - name: "Weekly Backup Status"
    frequency: "Weekly"
    format: "HTML"
    send_to: "it-ops"

  - name: "Monthly Backup Report"
    frequency: "Monthly"
    format: "PDF"
    send_to: "executive"
```

---

This concludes Appendix L: Complete Configuration Templates. These production-ready templates provide the baseline configurations needed to implement and operate the Enterprise Cybersecurity Program's security tools and platforms.
