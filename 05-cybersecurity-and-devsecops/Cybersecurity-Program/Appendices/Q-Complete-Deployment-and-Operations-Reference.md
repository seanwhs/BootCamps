# Appendix Q: Complete Deployment and Operations Reference

## Overview

This appendix provides comprehensive deployment and operations reference material for the Enterprise Cybersecurity Program. It includes deployment guides, operational procedures, maintenance schedules, and troubleshooting guides.

---

## Q.1: Deployment Guides

### Q.1.1: Security Tool Deployment Checklist

**File:** `deployment-operations/deployment-checklist.md`

```markdown
# Security Tool Deployment Checklist

## 1. Pre-Deployment Preparation

### 1.1 Planning Phase (2 Weeks Before)

- [ ] Define deployment scope
- [ ] Identify target systems
- [ ] Assess resource requirements
- [ ] Create deployment timeline
- [ ] Identify dependencies
- [ ] Establish success criteria

### 1.2 Preparation Phase (1 Week Before)

- [ ] Back up existing configurations
- [ ] Prepare deployment scripts
- [ ] Test in staging environment
- [ ] Verify prerequisites
- [ ] Plan rollback procedures
- [ ] Notify stakeholders

### 1.3 Environment Verification

```yaml
# Pre-deployment verification checks
verify:
  network:
    - connectivity
    - firewall rules
    - DNS resolution
    - load balancing
  systems:
    - OS version
    - available storage
    - memory capacity
    - CPU resources
  security:
    - access controls
    - certificates
    - authentication
    - encryption
```

## 2. Deployment Execution

### 2.1 Core Deployment Steps

| Step | Action | Time | Owner | Verification |
|------|--------|------|-------|--------------|
| 1 | Provision infrastructure | 2 hours | DevOps | System ready |
| 2 | Deploy application | 4 hours | Engineering | Application running |
| 3 | Configure settings | 2 hours | Security | Configuration applied |
| 4 | Integrate with existing systems | 4 hours | Integration | Integration working |
| 5 | Test functionality | 4 hours | QA | Tests passed |
| 6 | Migrate data | 4 hours | DBA | Data migrated |
| 7 | Enable production | 2 hours | Operations | Production ready |

### 2.2 Technical Implementation

**Infrastructure Provisioning:**

```hcl
# Terraform provisioning example
resource "aws_instance" "security_tool" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m5.large"
  
  root_block_device {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
  }
  
  vpc_security_group_ids = [
    aws_security_group.security_tool.id
  ]
  
  tags = {
    Name = "security-tool-01"
    Environment = "production"
    ManagedBy = "terraform"
  }
}
```

**Configuration Deployment:**

```yaml
# Ansible playbook example
- name: Deploy Security Tool Configuration
  hosts: security_tools
  become: yes
  
  tasks:
    - name: Create configuration directory
      file:
        path: /etc/security-tool
        state: directory
        owner: security
        group: security
        
    - name: Deploy main configuration
      template:
        src: templates/config.yaml.j2
        dest: /etc/security-tool/config.yaml
        owner: security
        group: security
        mode: '0644'
        
    - name: Deploy rules
      template:
        src: templates/rules.json.j2
        dest: /etc/security-tool/rules.json
        owner: security
        group: security
        mode: '0644'
        
    - name: Start service
      systemd:
        name: security-tool
        state: started
        enabled: yes
```

### 2.3 Verification Checks

**Functional Verification:**
- [ ] Service is running
- [ ] UI is accessible
- [ ] APIs are responding
- [ ] Logs are being generated
- [ ] Alerts are being sent
- [ ] Integrations are working

**Security Verification:**
- [ ] Access controls are working
- [ ] Authentication is enforced
- [ ] MFA is implemented
- [ ] Encryption is enabled
- [ ] Audit logging is active

**Performance Verification:**
- [ ] Response time within acceptable limits
- [ ] Resource usage within thresholds
- [ ] Throughput meets requirements
- [ ] Scalability verified

## 3. Post-Deployment

### 3.1 Documentation

- [ ] Update architecture diagrams
- [ ] Update configuration documents
- [ ] Update runbooks
- [ ] Update training materials
- [ ] Document lessons learned

### 3.2 Operations Handoff

- [ ] Provide training to operations team
- [ ] Create monitoring dashboards
- [ ] Set up alerts
- [ ] Document escalation procedures
- [ ] Transfer ownership

### 3.3 Validation

- [ ] Validate all requirements met
- [ ] Confirm success criteria achieved
- [ ] Monitor for issues
- [ ] Address any problems
- [ ] Sign off on deployment
```

### Q.1.2: Cloud Infrastructure Deployment Guide

**File:** `deployment-operations/cloud-deployment.md`

```markdown
# Cloud Infrastructure Deployment Guide

## 1. AWS Infrastructure Deployment

### 1.1 VPC Configuration

```hcl
# AWS VPC Configuration
resource "aws_vpc" "security_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "security-vpc"
    Environment = "production"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count             = 3
  vpc_id            = aws_vpc.security_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.security_vpc.cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "public-subnet-${count.index}"
    Environment = "production"
    Tier = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.security_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.security_vpc.cidr_block, 4, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-subnet-${count.index}"
    Environment = "production"
    Tier = "private"
  }
}
```

### 1.2 Security Groups

```hcl
# Security Group Configuration
resource "aws_security_group" "security_tool_sg" {
  name_prefix = "security-tool-"
  vpc_id      = aws_vpc.security_vpc.id
  
  # HTTPS access from ALB
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  # Health check from ALB
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  # SSH access from management
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "security-tool-sg"
    Environment = "production"
  }
}
```

## 2. Azure Infrastructure Deployment

### 2.1 Virtual Network Configuration

```hcl
# Azure VNet Configuration
resource "azurerm_virtual_network" "security_vnet" {
  name                = "security-vnet"
  resource_group_name = azurerm_resource_group.security.name
  location            = azurerm_resource_group.security.location
  address_space       = ["10.0.0.0/16"]
  
  tags = {
    Environment = "production"
  }
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
    db      = "10.0.3.0/24"
  }
  
  name                 = "${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.security.name
  virtual_network_name = azurerm_virtual_network.security_vnet.name
  address_prefixes     = [each.value]
}

# Network Security Groups
resource "azurerm_network_security_group" "security_nsg" {
  name                = "security-nsg"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  
  security_rule {
    name                       = "HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}
```

## 3. GCP Infrastructure Deployment

### 3.1 VPC Configuration

```hcl
# GCP VPC Configuration
resource "google_compute_network" "security_vpc" {
  name                    = "security-vpc"
  auto_create_subnetworks = false
  routing_mode           = "GLOBAL"
}

# Subnets
resource "google_compute_subnetwork" "subnets" {
  for_each = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
  
  name          = "${each.key}-subnet"
  ip_cidr_range = each.value
  region        = var.region
  network       = google_compute_network.security_vpc.id
  private_ip_google_access = true
}

# Firewall Rules
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = google_compute_network.security_vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}
```

## 4. Kubernetes Deployment

### 4.1 Namespace and Resources

```yaml
# Kubernetes Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: security
  labels:
    name: security
    environment: production

---
# Resource Quotas
apiVersion: v1
kind: ResourceQuota
metadata:
  name: security-quota
  namespace: security
spec:
  hard:
    requests.cpu: "8"
    requests.memory: "16Gi"
    limits.cpu: "16"
    limits.memory: "32Gi"
    persistentvolumeclaims: "10"
    pods: "20"

---
# Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: security-network-policy
  namespace: security
spec:
  podSelector:
    matchLabels:
      app: security-tool
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress
    ports:
    - protocol: TCP
      port: 443
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
    ports:
    - protocol: TCP
      port: 5432
```

### 4.2 Service Deployment

```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: security-tool
  namespace: security
spec:
  replicas: 3
  selector:
    matchLabels:
      app: security-tool
  template:
    metadata:
      labels:
        app: security-tool
    spec:
      containers:
      - name: security-tool
        image: security-tool:latest
        ports:
        - containerPort: 443
        - containerPort: 8080
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1"
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        - name: LOG_LEVEL
          value: "info"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 5

---
# Service
apiVersion: v1
kind: Service
metadata:
  name: security-tool-service
  namespace: security
spec:
  selector:
    app: security-tool
  ports:
  - name: https
    port: 443
    targetPort: 443
  - name: health
    port: 8080
    targetPort: 8080

---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: security-tool-ingress
  namespace: security
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - security.company.com
    secretName: security-tls
  rules:
  - host: security.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: security-tool-service
            port:
              number: 443
```

---

## Q.2: Operational Procedures

### Q.2.1: Daily Operations Runbook

**File:** `deployment-operations/daily-operations.md`

```markdown
# Daily Operations Runbook

## 1. Morning Checks (6:00 AM - 8:00 AM)

### 1.1 System Health Checks

**SIEM Health (6:00 AM - 6:30 AM):**
```bash
# Check SIEM health
# These commands should be adapted for your SIEM platform
# Examples are for Splunk, modify for your environment

# Check indexer health
splunk show cluster-status

# Check search head health
splunk show search-status

# Check license usage
splunk show license-usage

# Check forwarder status
splunk list forward-server
```

**EDR Health (6:30 AM - 7:00 AM):**
```yaml
# EDR health check
edr:
  check:
    - "Agent status: All endpoints online"
    - "Detection queue: Empty"
    - "Policy sync: Completed"
    - "Threat intelligence: Updated"
    - "Storage: Below 80%"
```

**IAM Health (7:00 AM - 7:30 AM):**
```powershell
# Azure AD health check
# Check sign-in logs for anomalies
Get-AzureADAuditSignInLogs -Filter "createdDateTime ge 2024-03-15T00:00:00Z" |
    Where-Object {$_.status.errorCode -ne 0} |
    Group-Object errorCode

# Check for risky users
Get-AzureADUserRisk -RiskState "atRisk"

# Check privileged role usage
Get-AzureADDirectoryRole | ForEach-Object {
    Get-AzureADDirectoryRoleMember -ObjectId $_.ObjectId
}
```

### 1.2 Alert Review (7:30 AM - 8:00 AM)

**Alert Review Checklist:**
- [ ] Review critical alerts from overnight
- [ ] Investigate high priority alerts
- [ ] Acknowledge open alerts
- [ ] Update incident tickets
- [ ] Escalate as needed

**Alert Triage Process:**
1. Review alert details
2. Determine severity
3. Investigate if needed
4. Document findings
5. Take appropriate action

## 2. Hourly Checks

### 2.1 Monitoring Dashboard Review

**Check Every Hour:**
- [ ] Critical alerts
- [ ] System health
- [ ] Log ingestion
- [ ] Endpoint status
- [ ] Authentication attempts

### 2.2 Review Triggers

| Metric | Trigger | Action |
|--------|---------|--------|
| Log Volume | >20% variance | Investigate log source |
| Endpoint Offline | >5% offline | Investigate connectivity |
| Failed Logins | >10/minute | Investigate potential attack |
| System Load | >80% CPU/Memory | Investigate root cause |

## 3. End of Day Operations (4:00 PM - 6:00 PM)

### 3.1 Daily Summary

**Generate Daily Report:**
1. Alert summary
2. Incident status
3. System health
4. Key metrics
5. Notable events

### 3.2 Handover Preparation

**Handover Documentation:**
```yaml
# Daily Handover Template
shift_handover:
  date: 2024-03-15
  from: Day Shift
  to: Night Shift
  
  active_incidents:
    - id: INC-2024-001
      status: Investigating
      summary: "Multiple failed logins"
      owner: Analyst_1
    
    - id: INC-2024-002
      status: Contained
      summary: "Malware detected on workstation"
      owner: Analyst_2
  
  pending_alerts:
    - id: ALERT-2024-001
      severity: Medium
      action: "Review in morning"
    
    - id: ALERT-2024-002
      severity: High
      action: "Monitor overnight"
  
  system_health:
    - status: "All systems operational"
    - issues: []
  
  overnight_actions:
    - "Monitor critical alerts"
    - "Review overnight log anomalies"
    - "Escalate any critical incidents"
```

## 4. Weekly Operations

### 4.1 Weekly Maintenance (Sunday 2:00 AM - 6:00 AM)

**Maintenance Tasks:**

```yaml
# Weekly Maintenance Tasks
maintenance_schedule:
  - task: "System Updates"
    duration: "2 hours"
    description: "Apply security patches"
    validation: "System health check"
  
  - task: "Database Maintenance"
    duration: "1 hour"
    description: "Index maintenance, cleanup"
    validation: "Database health check"
  
  - task: "Backup Verification"
    duration: "1 hour"
    description: "Validate backup integrity"
    validation: "Restore test"
  
  - task: "Log Rotation"
    duration: "30 minutes"
    description: "Archive and rotate logs"
    validation: "Log size check"
  
  - task: "Report Generation"
    duration: "30 minutes"
    description: "Generate weekly reports"
    validation: "Reports delivered"
```

### 4.2 Weekly Review Meeting (Monday 10:00 AM)

**Agenda Items:**
1. Weekly metrics review
2. Incident analysis
3. Vulnerability findings
4. Compliance status
5. Improvement actions

## 5. Monthly Operations

### 5.1 Monthly Maintenance (First Sunday)

```yaml
# Monthly Maintenance Tasks
monthly_maintenance:
  - task: "Full System Audit"
    duration: "4 hours"
    description: "Comprehensive system audit"
    validation: "Audit report generated"
  
  - task: "Security Policy Review"
    duration: "2 hours"
    description: "Review and update policies"
    validation: "Policy updates approved"
  
  - task: "Access Review"
    duration: "2 hours"
    description: "Review user access"
    validation: "Access review report"
  
  - task: "Disaster Recovery Test"
    duration: "4 hours"
    description: "Test recovery procedures"
    validation: "Recovery verified"
```

### 5.2 Monthly Reports

**Report Template:**
```markdown
# Monthly Security Operations Report

## Executive Summary
[High-level overview]

## Key Metrics
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Incidents | 12 | <10 | ⚠️ |
| MTTR | 2.5 hours | <4 hours | ✅ |
| MTTD | 1.2 hours | <2 hours | ✅ |
| Open Vulnerabilities | 45 | <50 | ✅ |

## Incident Analysis
[Detailed incident breakdown]

## Vulnerability Status
[Vulnerability summary]

## Compliance Status
[Compliance update]

## Recommendations
[Improvement recommendations]
```

---

## Q.3: Maintenance Procedures

### Q.3.1: Patching Schedule

**File:** `deployment-operations/patching-schedule.md`

```markdown
# Patching Schedule

## 1. Patch Types

| Patch Type | Frequency | Impact | Priority |
|------------|-----------|--------|----------|
| Critical Security | Emergency | High | P0 |
| Important Security | Weekly | Medium | P1 |
| Moderate | Monthly | Low | P2 |
| Feature Updates | Quarterly | Low | P3 |

## 2. Schedule

### 2.1 Weekly Patch Window

**Day:** Sunday
**Time:** 2:00 AM - 6:00 AM EST
**Duration:** 4 hours

**Schedule:**
```yaml
weekly_patch_schedule:
  - system: "Critical Servers"
    window: "2:00 AM - 4:00 AM"
    owner: "IT Operations"
    validation: "Post-patch health check"
  
  - system: "Security Systems"
    window: "3:00 AM - 5:00 AM"
    owner: "Security Team"
    validation: "Security controls validation"
  
  - system: "Applications"
    window: "4:00 AM - 6:00 AM"
    owner: "Application Team"
    validation: "Application functionality check"
```

### 2.2 Emergency Patch Process

**Trigger: Critical vulnerability with active exploitation**

**Process:**
1. Assess vulnerability
2. Identify affected systems
3. Develop patch plan
4. Obtain approval
5. Deploy patch
6. Validate resolution

## 3. Patching Procedure

### 3.1 Pre-Patch Preparation

```yaml
# Pre-patch checklist
pre_patch:
  - backup_all_systems: true
  - verify_backups: true
  - notify_stakeholders: true
  - prepare_rollback: true
  - test_environment: true
  - maintain_comms: true
```

### 3.2 Patch Execution

```bash
# Linux patching
# Update package list
sudo apt update

# Apply security updates only
sudo apt upgrade --only-upgrade -y

# Reboot if needed
if [ -f /var/run/reboot-required ]; then
    sudo reboot
fi

# Windows patching
# Install Windows Updates
Install-WindowsUpdate -AcceptAll -AutoReboot

# Apply critical updates
Get-WindowsUpdate -Category "Critical" -Install -AcceptAll
```

### 3.3 Post-Patch Validation

```yaml
# Post-patch validation
post_patch:
  - check_services: "All services running"
  - verify_functionality: "Critical functions working"
  - check_security: "Security controls active"
  - monitor_performance: "Performance within baseline"
  - validate_backups: "Backup verification"
```

## 4. Rollback Plan

### 4.1 Rollback Triggers

- Critical function failure
- Security vulnerability introduced
- Performance degradation >20%
- Data corruption
- Critical system instability

### 4.2 Rollback Procedure

```bash
# Linux rollback
# Revert to previous kernel
sudo apt install linux-image-$(uname -r)-old

# Revert package updates
sudo apt install package-name=previous-version

# Windows rollback
# System Restore
Rstrui.exe /restore

# Uninstall updates
wusa /uninstall /kb:KB1234567
```

---

## Q.4: Troubleshooting Guides

### Q.4.1: Common Issues and Solutions

**File:** `deployment-operations/troubleshooting-guide.md`

```markdown
# Troubleshooting Guide

## 1. Connectivity Issues

### 1.1 Network Connectivity

**Symptoms:**
- Cannot reach security tools
- Failed API calls
- Timeout errors

**Troubleshooting Steps:**

1. Check network connectivity:
```bash
# Ping test
ping -c 4 10.0.0.50

# Check DNS resolution
nslookup security.company.com

# Check routing
traceroute 10.0.0.50
```

2. Check firewall rules:
```bash
# List iptables rules
sudo iptables -L -n -v

# Check specific port
sudo iptables -L -n -v | grep 443
```

3. Check port availability:
```bash
# Check listening ports
sudo netstat -tulpn | grep 443

# Check port connectivity
telnet 10.0.0.50 443
```

### 1.2 VPN Connectivity

**Symptoms:**
- Cannot connect to VPN
- Dropped connections
- Authentication failures

**Troubleshooting Steps:**

```bash
# Check VPN service
systemctl status openvpn

# Check VPN logs
tail -f /var/log/openvpn.log

# Check VPN status
ifconfig tun0
```

## 2. Performance Issues

### 2.1 Slow System Performance

**Symptoms:**
- High response time
- Timeout errors
- Resource exhaustion

**Troubleshooting Steps:**

1. Check system resources:
```bash
# CPU usage
top -b -n 1 | head -20

# Memory usage
free -h

# Disk usage
df -h

# I/O wait
iostat -x 1 5
```

2. Check process list:
```bash
# List processes by CPU
ps aux --sort=-%cpu | head -10

# List processes by memory
ps aux --sort=-%mem | head -10
```

3. Check logs:
```bash
# System logs
journalctl -f

# Application logs
tail -f /var/log/security-tool/app.log
```

### 2.2 Database Performance

**Symptoms:**
- Slow queries
- Connection pool exhaustion
- Lock timeouts

**Troubleshooting Steps:**

```sql
-- Check connections
SELECT state, count(*) 
FROM pg_stat_activity 
GROUP BY state;

-- Check locks
SELECT * FROM pg_locks 
WHERE NOT granted;

-- Check query performance
SELECT 
    query,
    mean_exec_time,
    calls,
    stddev_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

## 3. Integration Issues

### 3.1 API Connectivity

**Symptoms:**
- API calls failing
- Authentication errors
- Timeout errors

**Troubleshooting Steps:**

```bash
# Test API endpoint
curl -X GET https://security.company.com/api/v1/health

# Check API authentication
curl -X GET https://security.company.com/api/v1/auth \
    -H "Authorization: Bearer ${TOKEN}"

# Check API rate limits
curl -X GET https://security.company.com/api/v1/rate-limit
```

### 3.2 Log Ingestion Issues

**Symptoms:**
- Missing logs
- Delayed ingestion
- Parsing errors

**Troubleshooting Steps:**

```bash
# Check log source connectivity
telnet log-source.company.com 514

# Check forwarder status
splunk list forward-server

# Check log parsing
cat /var/log/test.log | splunk add
```

## 4. Security Alerts

### 4.1 False Positives

**Symptoms:**
- Excessive alerts
- Alert fatigue

**Troubleshooting Steps:**
1. Review alert details
2. Verify alert conditions
3. Check context
4. Adjust rule if needed

**Tuning Process:**

```yaml
# Alert tuning workflow
tuning:
  - identify_false_positive: true
  - analyze_alert_pattern: true
  - adjust_threshold: true
  - add_exclusions: true
  - test_new_rule: true
  - deploy_update: true
  - monitor_results: true
```

### 4.2 Alert Storms

**Symptoms:**
- Multiple alerts in short time
- System overload
- Missed critical alerts

**Troubleshooting Steps:**

1. Stop alert generation
2. Investigate root cause
3. Correlate events
4. Identify pattern
5. Implement solution

## 5. Service Failures

### 5.1 Service Unavailable

**Troubleshooting Steps:**

```bash
# Check service status
systemctl status security-tool

# Check service logs
journalctl -u security-tool -f

# Check port binding
netstat -tulpn | grep security-tool

# Check SELinux/AppArmor
sudo ausearch -m avc -ts recent
```

### 5.2 Storage Issues

**Symptoms:**
- Disk full
- Slow performance
- Corruption

**Troubleshooting Steps:**

```bash
# Check disk usage
df -h

# Find large files
find / -type f -size +1G -exec ls -lh {} \;

# Check file system
fsck -N /dev/sda1
```

---

This concludes Appendix Q: Complete Deployment and Operations Reference. This comprehensive reference provides the deployment guides, operational procedures, maintenance schedules, and troubleshooting guides needed to successfully deploy and operate the Enterprise Cybersecurity Program.
