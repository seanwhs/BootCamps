# Appendix AO: Complete Security Tool Configuration Reference

## Overview

This appendix provides comprehensive security tool configuration reference material for the Enterprise Cybersecurity Program. It includes detailed configuration templates for all major security tools, integration configurations, and operational runbooks.

---

## AO.1: Security Tool Configuration Index

### AO.1.1: Master Configuration Index

**File:** `tool-configuration/master-index.md`

```markdown
# Security Tool Configuration Master Index

## 1. Configuration Categories

### 1.1 Tool Categories

```yaml
# Tool Configuration Categories
tool_categories:
  siem:
    - "Splunk Enterprise Security"
    - "Elastic Stack"
    - "Microsoft Sentinel"
  
  edr:
    - "CrowdStrike Falcon"
    - "SentinelOne"
    - "Microsoft Defender"
  
  iam:
    - "Azure AD"
    - "Okta"
    - "Active Directory"
  
  pam:
    - "CyberArk"
    - "BeyondTrust"
    - "Thycotic"
  
  network:
    - "Palo Alto Firewalls"
    - "Cisco Firewalls"
    - "Fortinet Firewalls"
  
  cloud:
    - "AWS Security Hub"
    - "Azure Security Center"
    - "GCP Security Command Center"
  
  endpoint:
    - "CrowdStrike Falcon"
    - "Microsoft Defender"
    - "McAfee ePO"
```

---

## AO.2: SIEM Configurations

### AO.2.1: Splunk ES Configuration

**File:** `tool-configuration/splunk-es-config.yaml`

```yaml
# Splunk Enterprise Security Configuration
# Version: 9.2.0
# Environment: Production

# ============================================
# 1. GLOBAL SETTINGS
# ============================================

general:
  serverName: "splunk-es-prod"
  site: "site1"
  indexAndForward: false
  sslVerifyServerCert: true
  sslCommonNameToCheck: "splunk-es-prod.company.com"

# ============================================
# 2. INDEX CONFIGURATION
# ============================================

indexes:
  security:
    homePath: "volume:security/$_index_name/db"
    coldPath: "volume:security/$_index_name/colddb"
    thawedPath: "volume:security/$_index_name/thaweddb"
    maxHotBuckets: 3
    frozenTimePeriodInSecs: 31536000
    maxTotalDataSizeMB: 1024000
  
  firewall:
    homePath: "volume:security/$_index_name/db"
    coldPath: "volume:security/$_index_name/colddb"
    thawedPath: "volume:security/$_index_name/thaweddb"
    maxHotBuckets: 3
    frozenTimePeriodInSecs: 31536000
    maxTotalDataSizeMB: 512000
  
  windows:
    homePath: "volume:security/$_index_name/db"
    coldPath: "volume:security/$_index_name/colddb"
    thawedPath: "volume:security/$_index_name/thaweddb"
    maxHotBuckets: 3
    frozenTimePeriodInSecs: 31536000
    maxTotalDataSizeMB: 1024000

# ============================================
# 3. INPUT CONFIGURATION
# ============================================

inputs:
  syslog:
    - port: 514
      sourcetype: "syslog"
      index: "main"
      disabled: false
  
  windows:
    - source: "WinEventLog://Security"
      index: "windows"
      sourcetype: "WinEventLog:Security"
      disabled: false
    
    - source: "WinEventLog://Application"
      index: "windows"
      sourcetype: "WinEventLog:Application"
      disabled: false
    
    - source: "WinEventLog://System"
      index: "windows"
      sourcetype: "WinEventLog:System"
      disabled: false

# ============================================
# 4. CORRELATION RULES
# ============================================

correlation_rules:
  multiple_failed_logins:
    name: "Multiple Failed Login Attempts"
    search: |
      index=windows OR index=linux 
      sourcetype=WinEventLog:Security OR sourcetype=authlog 
      EventCode=4625 OR (sourcetype=authlog "Failed password")
      | stats count by user, src_ip, host
      | where count > 5
      | eval severity = "medium"
      | eval description = "Multiple failed login attempts: " + user + " from " + src_ip
    time_window: 300
    trigger_count: 5
    severity: "medium"
    action: "alert"
  
  privilege_escalation:
    name: "Privilege Escalation"
    search: |
      index=windows 
      sourcetype=WinEventLog:Security 
      (EventCode=4672 OR EventCode=4673 OR EventCode=4768)
      | eval severity = "high"
      | eval description = "Privilege escalation detected: " + user
    time_window: 60
    trigger_count: 1
    severity: "high"
    action: "alert"
  
  malware_detection:
    name: "Malware Detection"
    search: |
      index=edr 
      sourcetype=crowdstrike:alert 
      (event_type=malware OR event_type=ransomware)
      | eval severity = "critical"
      | eval description = "Malware detected on host: " + host
    time_window: 60
    trigger_count: 1
    severity: "critical"
    action: "alert"

# ============================================
# 5. ALERT CONFIGURATION
# ============================================

alerts:
  critical:
    cron_schedule: "*"
    alert_suppress: 30
    alert_actions: ["email", "webhook"]
    alert_severity: "critical"
  
  high:
    cron_schedule: "*"
    alert_suppress: 60
    alert_actions: ["email", "webhook"]
    alert_severity: "high"
  
  medium:
    cron_schedule: "*"
    alert_suppress: 120
    alert_actions: ["email"]
    alert_severity: "medium"

# ============================================
# 6. USER ROLES
# ============================================

roles:
  security_analyst:
    capabilities: ["search", "dashboard", "alert_edit"]
    importRoles: ["user"]
  
  soc_manager:
    capabilities: ["search", "dashboard", "alert_edit", "admin_all_objects"]
    importRoles: ["user"]
  
  security_admin:
    capabilities: ["admin_all_objects", "change_own_password"]
    importRoles: ["user"]
```

---

## AO.3: EDR/XDR Configurations

### AO.3.1: CrowdStrike Falcon Configuration

**File:** `tool-configuration/crowdstrike-config.yaml`

```yaml
# CrowdStrike Falcon Configuration
# Version: 7.5.0
# Environment: Production

# ============================================
# 1. GENERAL SETTINGS
# ============================================

general:
  customer_id: "CUSTOMER_ID"
  base_url: "https://api.crowdstrike.com"
  api_timeout: 30
  api_retries: 3

# ============================================
# 2. PREVENTION POLICIES
# ============================================

prevention_policies:
  windows_production:
    name: "Windows Production Policy"
    description: "Production Windows endpoints"
    severity: "High"
    enforcement: true
    endpoint_groups: ["Windows-Servers", "Windows-Workstations"]
    
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
      
      vulnerability_protection:
        enabled: true
        prevention_level: "High"
        action: "Block"
      
      web_protection:
        enabled: true
        prevention_level: "High"
        action: "Block"

  linux_production:
    name: "Linux Production Policy"
    description: "Production Linux endpoints"
    severity: "High"
    enforcement: true
    endpoint_groups: ["Linux-Servers"]
    
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

  macos_production:
    name: "MacOS Production Policy"
    description: "Production MacOS endpoints"
    severity: "High"
    enforcement: true
    endpoint_groups: ["MacOS-Workstations"]
    
    settings:
      malware_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Quarantine"
      
      exploit_protection:
        enabled: true
        prevention_level: "Aggressive"
        action: "Block"

# ============================================
# 3. DETECTION POLICIES
# ============================================

detection_policies:
  production_detection:
    name: "Production Detection Policy"
    description: "Primary detection policy"
    enabled: true
    endpoint_groups: ["Production-Endpoints"]
    
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

# ============================================
# 4. RESPONSE ACTIONS
# ============================================

response_actions:
  - name: "Isolate Critical Endpoint"
    enabled: true
    severity: "Critical"
    action: "isolate"
    notification: true
    approval: "auto"
    timeout: 60
  
  - name: "Quarantine High Severity"
    enabled: true
    severity: "High"
    action: "quarantine"
    notification: true
    approval: "semi-auto"
    timeout: 120
  
  - name: "Alert Medium Severity"
    enabled: true
    severity: "Medium"
    action: "alert"
    notification: true
    approval: "manual"
    timeout: 300

# ============================================
# 5. EXCLUSIONS
# ============================================

exclusions:
  path_exclusions:
    - path: "C:\\Program Files\\*\\"
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
```

---

## AO.4: IAM Configurations

### AO.4.1: Azure AD Configuration

**File:** `tool-configuration/azuread-config.yaml`

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

# ============================================
# 6. LOGGING AND MONITORING
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
```

---

This concludes Appendix AO: Complete Security Tool Configuration Reference. This comprehensive reference provides the configuration templates needed to deploy and operate security tools as part of the Enterprise Cybersecurity Program.
