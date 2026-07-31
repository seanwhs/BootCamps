# Appendix AA: Complete Disaster Recovery Runbook

## Overview

This appendix provides a complete, production-ready disaster recovery runbook for the Enterprise Cybersecurity Program. It includes step-by-step recovery procedures, team responsibilities, communication protocols, and validation checklists.

---

## AA.1: Disaster Recovery Overview

### AA.1.1: DR Program Summary

**File:** `disaster-recovery/dr-overview.md`

```markdown
# Disaster Recovery Program Overview

## 1. Program Information

| Field | Value |
|-------|-------|
| Program Name | Enterprise Disaster Recovery |
| Program Owner | CISO |
| DR Coordinator | [Name] |
| Last Update | 2024-03-15 |
| Next Review | 2024-06-15 |
| Classification | Confidential |

## 2. Recovery Objectives

### 2.1 Recovery Time Objectives (RTO)

| Tier | Systems | RTO |
|------|---------|-----|
| Tier 0 | Critical Infrastructure | < 1 hour |
| Tier 1 | Business Critical | < 4 hours |
| Tier 2 | Business Important | < 8 hours |
| Tier 3 | Business Support | < 24 hours |
| Tier 4 | Non-Critical | < 72 hours |

### 2.2 Recovery Point Objectives (RPO)

| Tier | Systems | RPO |
|------|---------|-----|
| Tier 0 | Critical Infrastructure | < 5 minutes |
| Tier 1 | Business Critical | < 15 minutes |
| Tier 2 | Business Important | < 1 hour |
| Tier 3 | Business Support | < 4 hours |
| Tier 4 | Non-Critical | < 8 hours |

## 3. Disaster Declaration

### 3.1 Declaration Criteria

**Declare a Disaster When:**
- Critical systems unavailable > 30 minutes
- Data loss exceeds RPO
- Multiple systems affected
- Significant business impact
- Recovery expected > 4 hours
- Physical facility damage
- Major cyber incident

### 3.2 Declaration Process

1. **Detection:** Incident identified
2. **Assessment:** Impact evaluated
3. **Consultation:** DR Coordinator consulted
4. **Declaration:** Disaster declared by CISO/CEO
5. **Activation:** DR team activated
6. **Notification:** Stakeholders notified

## 4. DR Team Structure

### 4.1 DR Team Organization

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 DR TEAM ORGANIZATION                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              DR COMMAND CENTER                                      │    │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐ │    │
│  │  │  Incident Commander  │  DR Coordinator  │  Communications Lead                   │ │    │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              RECOVERY TEAMS                                         │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │    │
│  │  │  Infrastructure│  │  Application │  │  Data        │  │  Security    │              │    │
│  │  │  Recovery     │  │  Recovery    │  │  Recovery    │  │  Recovery    │              │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘              │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
│                                              │                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │
│  │                              SUPPORT TEAMS                                          │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │    │
│  │  │  Facilities  │  │  HR          │  │  Legal       │  │  Logistics   │              │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘              │    │
│  └─────────────────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 DR Team Roles

| Role | Name | Contact | Responsibility |
|------|------|---------|----------------|
| Incident Commander | [Name] | [Phone] | Overall coordination |
| DR Coordinator | [Name] | [Phone] | Recovery execution |
| Infrastructure Lead | [Name] | [Phone] | Infrastructure recovery |
| Application Lead | [Name] | [Phone] | Application recovery |
| Data Recovery Lead | [Name] | [Phone] | Data restoration |
| Security Lead | [Name] | [Phone] | Security validation |
| Communications Lead | [Name] | [Phone] | Stakeholder communication |
| Facilities Lead | [Name] | [Phone] | Physical facilities |
| Legal Lead | [Name] | [Phone] | Legal guidance |
| HR Lead | [Name] | [Phone] | Personnel management |
```

---

## AA.2: Recovery Procedures

### AA.2.1: Infrastructure Recovery

**File:** `disaster-recovery/infrastructure-recovery.md`

```markdown
# Infrastructure Recovery Procedures

## 1. Network Recovery (0-60 minutes)

### 1.1 Network Infrastructure

**Step 1: Verify Network Hardware (10 minutes)**
1. Check router status
   ```bash
   show interfaces status
   show ip interface brief
   show running-config
   ```

2. Check switch status
   ```bash
   show interfaces status
   show spanning-tree
   show vlan brief
   ```

3. Check firewall status
   ```bash
   show system status
   show interface
   show security policies
   ```

**Step 2: Restore Network Configuration (20 minutes)**
1. Restore router configuration
   ```bash
   copy tftp://192.168.1.100/router-config running-config
   write memory
   ```

2. Restore switch configuration
   ```bash
   copy tftp://192.168.1.100/switch-config running-config
   write memory
   ```

3. Restore firewall configuration
   ```bash
   restore configuration from backup
   commit
   ```

**Step 3: Verify Network Connectivity (15 minutes)**
1. Test internal connectivity
   ```bash
   ping 10.0.0.1
   ping 10.0.1.1
   traceroute 10.0.2.1
   ```

2. Test external connectivity
   ```bash
   ping 8.8.8.8
   ping 1.1.1.1
   ```

3. Test DNS resolution
   ```bash
   nslookup company.com
   nslookup www.company.com
   ```

**Step 4: Restore VPN Access (15 minutes)**
1. Verify VPN gateway
2. Restore VPN configuration
3. Test VPN connections
4. Verify user access

### 1.2 Server Infrastructure (60-120 minutes)

**Step 1: Provision Servers (30 minutes)**
1. Provision physical/virtual servers
2. Install operating system
3. Apply security patches
4. Configure network settings

**Step 2: Restore Server Configuration (30 minutes)**
1. Install server applications
2. Restore configuration files
3. Apply security settings
4. Join domain (if applicable)

**Step 3: Restore Server Data (30 minutes)**
1. Verify data backups
2. Restore data from backups
3. Verify data integrity
4. Test data access

**Step 4: Validate Servers (30 minutes)**
1. Verify system functionality
2. Test application connectivity
3. Validate security controls
4. Document server status
```

### AA.2.2: Data Recovery Procedures

**File:** `disaster-recovery/data-recovery.md`

```markdown
# Data Recovery Procedures

## 1. Data Recovery Process

### 1.1 Backup Verification (0-30 minutes)

**Step 1: Verify Backup Availability (10 minutes)**
1. Check backup inventory
   ```bash
   veeam show backups
   veeam show inventory
   ```

2. Verify backup integrity
   ```bash
   veeam verify --backup-id <backup-id>
   ```

3. Check backup age
   ```bash
   veeam show --backup-id <backup-id> --detail
   ```

4. Validate backup encryption
   ```bash
   veeam validate --backup-id <backup-id> --encryption
   ```

**Step 2: Select Recovery Point (10 minutes)**
1. Identify recovery point based on RPO
2. Verify backup consistency
3. Check transaction logs
4. Document selected recovery point

**Step 3: Prepare Recovery Environment (10 minutes)**
1. Allocate recovery storage
2. Configure network access
3. Verify security controls
4. Document environment

### 1.2 Database Recovery (30-120 minutes)

**Step 1: SQL Server Recovery (30-60 minutes)**
```sql
-- Stop SQL Server
NET STOP MSSQLSERVER

-- Restore database from backup
RESTORE DATABASE [DatabaseName]
FROM DISK = 'D:\Backups\database_full.bak'
WITH REPLACE,
MOVE 'DataFile' TO 'D:\Data\Database.mdf',
MOVE 'LogFile' TO 'E:\Logs\Database_log.ldf'

-- Restore transaction logs
RESTORE LOG [DatabaseName]
FROM DISK = 'D:\Backups\database_log.trn'
WITH RECOVERY

-- Start SQL Server
NET START MSSQLSERVER

-- Verify database
DBCC CHECKDB([DatabaseName])
```

**Step 2: Oracle Recovery (30-60 minutes)**
```sql
-- Shutdown Oracle
SHUTDOWN IMMEDIATE;

-- Restore from backup
RESTORE DATABASE
FROM '/backup/oracle_full.dmp'
WITH RECOVERY;

-- Recover using archive logs
RECOVER DATABASE;

-- Open database
ALTER DATABASE OPEN;

-- Verify database
SELECT * FROM v$database;
```

**Step 3: Application Data Recovery (30-60 minutes)**
```bash
# Restore application files
cp -r /backup/app-data/* /var/app/data/

# Set permissions
chown -R appuser:appgroup /var/app/data
chmod -R 755 /var/app/data

# Restore configuration
cp /backup/app-config/* /etc/app/

# Verify data
ls -la /var/app/data/
```

### 1.3 File System Recovery (60-120 minutes)

**Step 1: File Server Recovery (30-60 minutes)**
```bash
# Mount backup storage
mount -t nfs backup-server:/backup /mnt/backup

# Verify backup availability
ls -la /mnt/backup/files/

# Restore files
rsync -av /mnt/backup/files/ /var/files/

# Verify restoration
find /var/files/ -type f | wc -l
du -sh /var/files/
```

**Step 2: Share Restoration (30-60 minutes)**
```bash
# Restore network shares
exportfs -a

# Restore share permissions
setfacl --restore=/backup/acls

# Verify shares
showmount -e localhost

# Test access
mount -t nfs localhost:/export /mnt/test
ls -la /mnt/test
```

### 1.4 Cloud Data Recovery (60-120 minutes)

**Step 1: AWS S3 Recovery (30-60 minutes)**
```bash
# Restore from S3 bucket
aws s3 sync s3://backup-bucket/restore/ /var/data/restore

# Verify restoration
aws s3 ls s3://backup-bucket/restore/
du -sh /var/data/restore

# Validate data
md5sum /var/data/restore/* > checksums.txt
```

**Step 2: Azure Blob Recovery (30-60 minutes)**
```bash
# Restore from Azure Storage
azcopy copy "https://storageaccount.blob.core.windows.net/backup/*" "/var/data/restore"

# Verify restoration
ls -la /var/data/restore/

# Validate data
find /var/data/restore/ -type f -exec md5sum {} \;
```

---

## AA.3: Application Recovery

### AA.3.1: Critical Application Recovery

**File:** `disaster-recovery/application-recovery.md`

```markdown
# Application Recovery Procedures

## 1. Tier 0 Applications

### 1.1 ERP Recovery (2-4 hours)

**Step 1: Prepare Environment (30 minutes)**
1. Verify hardware/VM availability
2. Check OS and patches
3. Configure network settings
4. Set up storage
5. Configure backups

**Step 2: Install Application (60 minutes)**
1. Install application software
2. Apply application patches
3. Configure application settings
4. Configure application environment

**Step 3: Restore Data (60 minutes)**
1. Restore application database
2. Restore application files
3. Verify data integrity
4. Apply transaction logs

**Step 4: Validate Application (30 minutes)**
1. Start application services
2. Test core functionality
3. Verify user access
4. Validate integrations

**Recovery Checklist:**
- [ ] Application installed
- [ ] Database restored
- [ ] Configuration applied
- [ ] Security controls active
- [ ] User access verified
- [ ] Functionality validated

### 1.2 CRM Recovery (2-4 hours)

**Step 1: Environment Setup (30 minutes)**
1. Verify server availability
2. Configure network
3. Set up storage
4. Check backups

**Step 2: Application Restore (60 minutes)**
1. Install application
2. Apply patches
3. Restore configuration
4. Set up application

**Step 3: Data Restoration (60 minutes)**
1. Restore database
2. Restore application files
3. Verify data integrity
4. Validate data

**Step 4: Validation (30 minutes)**
1. Start application
2. Test functionality
3. Verify user access
4. Check integrations

## 2. Tier 1 Applications

### 2.1 Email Recovery (2-4 hours)

**Step 1: Email Server Setup (30 minutes)**
1. Provision email server
2. Install Exchange/Mail Server
3. Apply security patches
4. Configure network

**Step 2: Mailbox Restoration (60-120 minutes)**
1. Restore mail databases
2. Restore mailboxes
3. Verify mailbox data
4. Set up mail routing

**Step 3: Client Access (30 minutes)**
1. Configure Outlook
2. Configure mobile access
3. Test email functionality
4. Verify calendar

### 2.2 Collaboration Recovery (1-2 hours)

**Step 1: Team Collaboration Setup (30 minutes)**
1. Provision servers
2. Install software
3. Configure application
4. Set up services

**Step 2: Data Restoration (30-60 minutes)**
1. Restore team sites
2. Restore documents
3. Restore configurations
4. Verify data

**Step 3: Validation (30 minutes)**
1. Test collaboration
2. Verify document access
3. Check user permissions
4. Validate sharing
```

---

## AA.4: Validation and Handover

### AA.4.1: Recovery Validation

**File:** `disaster-recovery/recovery-validation.md`

```markdown
# Recovery Validation Procedures

## 1. Validation Checklist

### 1.1 Infrastructure Validation

```yaml
# Infrastructure Validation
infrastructure_validation:
  network:
    - internal_connectivity: true
    - external_connectivity: true
    - firewall_rules: true
    - vpn_access: true
    - dns_resolution: true
  
  servers:
    - os_functional: true
    - security_patches: true
    - services_running: true
    - storage_available: true
    - backup_system: true
  
  cloud:
    - cloud_connectivity: true
    - cloud_services: true
    - cloud_monitoring: true
    - cloud_security: true
```

### 1.2 Application Validation

```yaml
# Application Validation
application_validation:
  erp:
    - application_running: true
    - data_integrity: true
    - user_access: true
    - functionality: true
    - integrations: true
  
  crm:
    - application_running: true
    - data_integrity: true
    - user_access: true
    - functionality: true
  
  email:
    - mail_flow: true
    - mailbox_access: true
    - calendar_function: true
    - mobile_access: true
  
  collaboration:
    - document_access: true
    - sharing_function: true
    - user_permissions: true
    - application_function: true
```

### 1.3 Security Validation

```yaml
# Security Validation
security_validation:
  controls:
    - authentication_working: true
    - authorization_working: true
    - mfa_enabled: true
    - encryption_working: true
    - logging_active: true
    - monitoring_active: true
  
  compliance:
    - gdpr_compliance: true
    - ccpa_compliance: true
    - hipaa_compliance: true
    - pci_compliance: true
  
  response:
    - incident_response: true
    - alerting_active: true
    - reporting_functional: true
    - escalation_working: true
```

## 2. Handover Process

### 2.1 Handover Checklist

```yaml
# Handover Checklist
handover:
  documentation:
    - recovery_complete: true
    - validation_complete: true
    - issues_documented: true
    - lessons_learned: true
  
  transition:
    - operations_review: true
    - team_briefing: true
    - status_update: true
    - future_actions: true
  
  governance:
    - management_approval: true
    - stakeholders_notified: true
    - regulatory_reporting: true
    - incident_closed: true
```

### 2.2 Status Report Template

```markdown
# Recovery Status Report

## Incident Information

| Field | Value |
|-------|-------|
| Incident ID | [ID] |
| Incident Date | [Date] |
| Incident Type | [Type] |
| Recovery Status | [Status] |

## Recovery Summary

| System | Status | RTO Met | RPO Met |
|--------|--------|---------|---------|
| Network | Operational | ✅ | N/A |
| Servers | Operational | ✅ | ✅ |
| Applications | Operational | ✅ | ✅ |
| Data | Restored | ✅ | ✅ |
| Security | Operational | ✅ | N/A |

## Outstanding Issues

| Issue | Severity | Owner | Resolution |
|-------|----------|-------|------------|
| [Issue] | [Severity] | [Owner] | [Resolution] |

## Next Steps

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Approvals

| Role | Name | Date |
|------|------|------|
| Incident Commander | [Name] | [Date] |
| DR Coordinator | [Name] | [Date] |
| CISO | [Name] | [Date] |
```

---

## AA.5: Communication Templates

### AA.5.1: DR Communication Templates

**File:** `disaster-recovery/communication-templates.md`

```markdown
# Disaster Recovery Communication Templates

## 1. Disaster Declaration

```markdown
# DISASTER DECLARATION

## Declaration Information
- **Date:** [Date]
- **Time:** [Time]
- **Declared By:** [Name]
- **Reason:** [Reason]

## Impact
- **Systems Affected:** [Systems]
- **Data Lost:** [Amount]
- **Business Impact:** [Impact]
- **Estimated Recovery:** [Time]

## Response Actions
1. [Action 1]
2. [Action 2]
3. [Action 3]

## Contact Information
- **Incident Commander:** [Name, Phone]
- **DR Coordinator:** [Name, Phone]
- **CISO:** [Name, Phone]

## Next Update
[Time]
```

## 2. Recovery Status Update

```markdown
# RECOVERY STATUS UPDATE

## Current Status
- **Phase:** [Phase]
- **Progress:** [% Complete]
- **Estimated Completion:** [Time]

## Completed Actions
1. [Action 1]
2. [Action 2]
3. [Action 3]

## In Progress Actions
1. [Action 1]
2. [Action 2]
3. [Action 3]

## Pending Actions
1. [Action 1]
2. [Action 2]
3. [Action 3]

## Issues/Blockers
1. [Issue 1]
2. [Issue 2]

## Next Update
[Time]
```

## 3. Recovery Complete

```markdown
# RECOVERY COMPLETE

## Completion Information
- **Date:** [Date]
- **Time:** [Time]
- **Duration:** [Hours]
- **Recovery Status:** Complete

## Systems Recovered
- **Critical Systems:** [Count]
- **Applications:** [Count]
- **Data:** [Amount]

## Outstanding Issues
1. [Issue 1]
2. [Issue 2]

## Next Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Post-Recovery Actions
1. [Action 1]
2. [Action 2]
3. [Action 3]
```

---

This concludes Appendix AA: Complete Disaster Recovery Runbook. This comprehensive reference provides the step-by-step recovery procedures, team responsibilities, validation checklists, and communication templates needed to effectively recover from disasters as part of the Enterprise Cybersecurity Program.
