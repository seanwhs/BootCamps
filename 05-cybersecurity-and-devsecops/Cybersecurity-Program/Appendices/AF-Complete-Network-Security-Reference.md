# Appendix AF: Complete Network Security Reference

## Overview

This appendix provides comprehensive network security reference material for the Enterprise Cybersecurity Program. It includes network segmentation, firewall configurations, intrusion detection/prevention, and secure network architecture patterns.

---

## AF.1: Network Security Architecture

### AF.1.1: Network Segmentation Framework

**File:** `network-security/network-segmentation.md`

```markdown
# Network Segmentation Framework

## 1. Overview

### 1.1 Segmentation Purpose
To divide the network into logical segments to limit lateral movement and contain breaches.

### 1.2 Segmentation Principles

1. **Least Privilege:** Only necessary traffic permitted
2. **Defense in Depth:** Multiple layers of segmentation
3. **Zero Trust:** Verify all traffic between segments
4. **Micro-segmentation:** Granular workload segmentation
5. **Dynamic:** Adapt to changing requirements

## 2. Segmentation Architecture

### 2.1 High-Level Segmentation

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                           NETWORK SEGMENTATION ARCHITECTURE                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              EXTERNAL SEGMENTS                                      │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                              │    │
│  │  │  DMZ         │  │  Internet    │  │  Cloud       │                              │    │
│  │  │  (Web, Email)│  │  (Public)    │  │  (AWS/Azure) │                              │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘                              │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              INTERNAL SEGMENTS                                      │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │    │
│  │  │  Corporate   │  │  Production  │  │  Development │  │  Management  │              │    │
│  │  │  (Users)     │  │  (Apps)      │  │  (Dev)       │  │  (IT)        │              │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘              │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              MICRO-SEGMENTS                                         │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │    │
│  │  │  Workload 1  │  │  Workload 2  │  │  Workload 3  │  │  Database   │              │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘              │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Segmentation Policies

```yaml
# Segmentation Policies
segmentation_policies:
  dmz_to_internet:
    allowed:
      - "HTTP/HTTPS"
      - "DNS"
      - "Email (SMTP)"
      - "VPN"
    denied: "All other traffic"
  
  dmz_to_corporate:
    allowed:
      - "Application traffic"
      - "Authentication"
      - "Monitoring"
    denied: "All other traffic"
  
  corporate_to_production:
    allowed:
      - "Application access"
      - "Database access"
      - "Authentication"
    denied: "All other traffic"
  
  production_to_database:
    allowed:
      - "Application database traffic"
      - "Administrative access"
    denied: "All other traffic"
  
  micro_segmentation:
    allowed:
      - "Application specific ports"
      - "Health checks"
      - "Monitoring"
    denied: "All other traffic"
```

## 3. Micro-Segmentation Implementation

### 3.1 Micro-Segmentation Configuration

```yaml
# Micro-Segmentation Configuration
micro_segmentation:
  platform: "Calico"
  cluster: "Production"
  
  policies:
    - name: "web-to-app"
      source: "web-tier"
      destination: "app-tier"
      ports: [8080, 8443]
      protocol: "TCP"
      action: "Allow"
    
    - name: "app-to-db"
      source: "app-tier"
      destination: "db-tier"
      ports: [5432, 3306]
      protocol: "TCP"
      action: "Allow"
    
    - name: "deny-all"
      source: "*"
      destination: "*"
      ports: "*"
      protocol: "*"
      action: "Deny"
```

---

## AF.2: Firewall Configuration

### AF.2.1: Firewall Standards

**File:** `network-security/firewall-standards.md`

```markdown
# Firewall Configuration Standards

## 1. Overview

### 1.1 Firewall Purpose
To control network traffic based on security policies and protect the network from unauthorized access.

### 1.2 Firewall Principles

1. **Default Deny:** Block all traffic unless explicitly allowed
2. **Least Privilege:** Allow only necessary traffic
3. **Defense in Depth:** Multiple firewall layers
4. **Principle of Least Access:** Minimize attack surface
5. **Regular Review:** Periodic rule review and optimization

## 2. Firewall Rule Standards

### 2.1 Rule Categories

```yaml
# Firewall Rule Categories
firewall_rules:
  inbound:
    - "DMZ services (HTTP/HTTPS)"
    - "Email services (SMTP)"
    - "VPN services"
    - "DNS services"
    - "Management access (IP restricted)"
  
  outbound:
    - "HTTP/HTTPS"
    - "DNS"
    - "NTP"
    - "Software updates"
    - "Email (SMTP)"
    - "Monitoring"
  
  internal:
    - "Application traffic"
    - "Database traffic"
    - "Authentication"
    - "Management"
    - "Backup"
    - "Monitoring"
  
  management:
    - "SSH (IP restricted)"
    - "HTTPS (IP restricted)"
    - "SNMP (IP restricted)"
    - "Syslog (IP restricted)"
```

### 2.2 Rule Template

```yaml
# Firewall Rule Template
rule:
  id: "FR-2024-001"
  name: "Allow HTTPS to Web Server"
  description: "Allow HTTPS traffic to web server"
  
  source:
    zone: "Internet"
    ip: "any"
    port: "any"
  
  destination:
    zone: "DMZ"
    ip: "192.168.1.100"
    port: "443"
  
  protocol: "TCP"
  action: "allow"
  
  logging:
    enabled: true
    severity: "info"
  
  approval:
    date: "2024-01-15"
    by: "Security Team"
    justification: "Web service access"
  
  review:
    date: "2024-06-15"
    next: "2024-12-15"
```

## 3. Firewall Rule Management

### 3.1 Rule Review Process

```yaml
# Rule Review Process
rule_review:
  frequency: "Quarterly"
  owner: "Network Security Team"
  
  process:
    - step: 1
      action: "Generate rule list"
      owner: "Firewall Administrator"
    
    - step: 2
      action: "Review each rule"
      owner: "Network Security Analyst"
    
    - step: 3
      action: "Validate business need"
      owner: "Application Owner"
    
    - step: 4
      action: "Remove unused rules"
      owner: "Firewall Administrator"
    
    - step: 5
      action: "Document changes"
      owner: "Network Security Analyst"
  
  removal_criteria:
    - "No traffic for 30 days"
    - "Application decommissioned"
    - "Rule no longer required"
    - "Superseded by other rules"
```

### 3.2 Change Management

```yaml
# Firewall Change Management
change_management:
  process:
    - "Request submission"
    - "Business justification"
    - "Security review"
    - "Risk assessment"
    - "Implementation"
    - "Verification"
  
  emergency_changes:
    - "Incident response"
    - "Critical vulnerability"
    - "Service outage"
    - "Security threat"
  
  documentation:
    - "Change ID"
    - "Request date"
    - "Requestor"
    - "Approver"
    - "Implementation date"
    - "Rule details"
    - "Verification result"
```

---

## AF.3: Intrusion Detection and Prevention

### AF.3.1: IDS/IPS Framework

**File:** `network-security/ids-ips.md`

```markdown
# Intrusion Detection and Prevention Framework

## 1. Overview

### 1.1 IDS/IPS Purpose
To detect and prevent network intrusions and attacks.

### 1.2 IDS vs IPS

| Feature | IDS | IPS |
|---------|-----|-----|
| Placement | Out-of-band | Inline |
| Action | Alert only | Alert and block |
| Impact | No traffic impact | Traffic impact |
| Response | Manual | Automated |
| Performance | Higher | Lower |

## 2. IDS/IPS Implementation

### 2.1 Deployment Architecture

```yaml
# IDS/IPS Deployment
ids_ips:
  sensors:
    - location: "Internet Gateway"
      type: "IPS"
      mode: "Inline"
      interfaces: ["eth0", "eth1"]
    
    - location: "Internal Segment"
      type: "IDS"
      mode: "Span port"
      interfaces: ["eth2"]
    
    - location: "Cloud"
      type: "IDS"
      mode: "Virtual"
      provider: "AWS"
  
  rulesets:
    - source: "Emerging Threats"
      updated: "Daily"
    
    - source: "Snort Community"
      updated: "Weekly"
    
    - source: "Custom Rules"
      updated: "As needed"
```

## 3. IDS/IPS Configuration

### 3.1 Configuration Parameters

```yaml
# IDS/IPS Configuration
configuration:
  engine: "Suricata"
  version: "7.0.0"
  
  detection:
    protocols:
      - "TCP"
      - "UDP"
      - "ICMP"
      - "HTTP"
      - "DNS"
      - "TLS"
      - "SSH"
    
    rules:
      - category: "Malware"
        enabled: true
        severity: "High"
      
      - category: "Exploit"
        enabled: true
        severity: "High"
      
      - category: "DoS"
        enabled: true
        severity: "Medium"
      
      - category: "Policy"
        enabled: true
        severity: "Medium"
  
  alerts:
    critical:
      action: "Block and Alert"
      notification: ["SMS", "Email"]
    
    high:
      action: "Alert"
      notification: ["Email", "Slack"]
    
    medium:
      action: "Alert"
      notification: ["Email"]
    
    low:
      action: "Log"
      notification: []
```

### 3.2 Rule Customization

```yaml
# Custom IDS/IPS Rules
custom_rules:
  - name: "Detect SQL Injection"
    rule: |
      alert tcp $HOME_NET any -> $EXTERNAL_NET $HTTP_PORTS
      (msg:"SQL Injection Attempt";
       flow:to_server,established;
       content:"SELECT|20|";
       http_uri;
       classtype:web-application-attack;
       sid:1000001;
       rev:1;)
  
  - name: "Detect RDP Brute Force"
    rule: |
      alert tcp any any -> $HOME_NET 3389
      (msg:"RDP Brute Force Attempt";
       flow:to_server,established;
       threshold:type both, track by_src, count 5, seconds 60;
       classtype:attempted-recon;
       sid:1000002;
       rev:1;)
```

---

## AF.4: Secure Network Architecture

### AF.4.1: Secure Architecture Patterns

**File:** `network-security/secure-architecture.md`

```markdown
# Secure Network Architecture Patterns

## 1. Architecture Patterns

### 1.1 Pattern 1: Three-Tier Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                           THREE-TIER SECURE ARCHITECTURE                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              PRESENTATION LAYER                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Web servers                                                                  │ │    │
│  │  │  • Load balancers                                                               │ │    │
│  │  │  • WAF                                                                          │ │    │
│  │  │  • CDN                                                                          │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              APPLICATION LAYER                                      │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Application servers                                                         │ │    │
│  │  │  • API gateways                                                                 │ │    │
│  │  │  • Authentication                                                               │ │    │
│  │  │  • Authorization                                                                │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│                                              ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              DATA LAYER                                             │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  • Database servers                                                            │ │    │
│  │  │  • Data warehouse                                                               │ │    │
│  │  │  • Backup systems                                                               │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Pattern 2: Zero Trust Network Access

```yaml
# Zero Trust Network Access Pattern
ztna_pattern:
  components:
    identity_provider:
      - "Azure AD"
      - "Okta"
      - "Ping"
    
    access_proxy:
      - "Zscaler ZPA"
      - "Cloudflare Access"
      - "Akamai EAA"
    
    policy_engine:
      - "Conditional access policies"
      - "Risk based access"
      - "Device compliance"
    
    monitoring:
      - "Access logging"
      - "User behavior"
      - "Threat detection"
```

---

This concludes Appendix AF: Complete Network Security Reference. This comprehensive reference provides the network segmentation framework, firewall configuration standards, IDS/IPS implementation, and secure network architecture patterns needed to secure the network as part of the Enterprise Cybersecurity Program.
