# Appendix N: Complete Incident Response Reference

## Overview

This appendix provides comprehensive incident response reference material for the Enterprise Cybersecurity Program. It includes detailed playbooks, escalation procedures, communication templates, and forensic guidelines for responding to security incidents.

---

## N.1: Incident Response Playbooks

### N.1.1: Phishing Incident Response Playbook

**File:** `incident-response/playbooks/phishing-response.md`

```markdown
# Phishing Incident Response Playbook

## 1. Overview

### 1.1 Purpose
This playbook provides step-by-step guidance for responding to phishing incidents.

### 1.2 Activation Criteria
Activate this playbook when:
- Phishing email reported by user
- Phishing email detected by security tools
- User reports clicking on phishing link
- User reports submitting credentials
- Malware delivered via phishing detected

## 2. Response Phases

### Phase 1: Detection & Triage (0-15 minutes)

**Detection Sources:**
- User reports (phishing@company.com)
- Email security gateway alerts
- SIEM alerts
- EDR alerts from click/execution

**Triage Checklist:**

| Step | Action | Owner | Time |
|------|--------|-------|------|
| 1 | Confirm phishing email | SOC Analyst | 2 min |
| 2 | Identify affected users | SOC Analyst | 3 min |
| 3 | Determine email scope | SOC Analyst | 5 min |
| 4 | Check for malware delivery | SOC Analyst | 3 min |
| 5 | Notify Incident Response Lead | SOC Analyst | 2 min |

**Initial Assessment Questions:**
1. Has the email been opened?
2. Has the link been clicked?
3. Have credentials been submitted?
4. Has an attachment been opened?
5. Is malware detected?

### Phase 2: Containment (15-45 minutes)

**Step 1: Email Containment (10 minutes)**
1. Block sender email address
   ```powershell
   # Exchange Online PowerShell
   New-TransportRule -Name "Block Phishing Sender" -FromAddressContainsWords "phishing@malicious.com" -RejectMessageEnhancedStatusCode "5.7.1" -RejectMessageReasonText "Message blocked due to security policy"
   ```

2. Block malicious domain at firewall
   ```bash
   # Add to DNS sinkhole
   echo "127.0.0.1 malicious-domain.com" >> /etc/hosts
   # Add to firewall block list
   iptables -A FORWARD -d malicious-domain.com -j DROP
   ```

3. Quarantine email from all recipients
   ```powershell
   # Exchange Online PowerShell
   Search-Mailbox -Identity "target-user" -SearchQuery "subject:phishing subject" -DeleteContent
   ```

4. Block malicious URL in web proxy
   ```yaml
   # Proxy block configuration
   block_urls:
     - "malicious-domain.com/*"
     - "http://phishing-site.com/*"
   ```

**Step 2: User Containment (15 minutes)**
1. Identify all users who clicked
2. Force password reset for affected users
   ```powershell
   # Azure AD PowerShell
   Set-AzureADUserPassword -ObjectId "user@company.com" -Password "NewSecurePassword123!"
   Reset-AzureADUserPassword -ObjectId "user@company.com" -ForceChangePasswordNextLogin $true
   ```

3. Revoke all active sessions
   ```powershell
   # Azure AD PowerShell
   Revoke-AzureADUserAllRefreshToken -ObjectId "user@company.com"
   ```

4. Disable user account if compromised
   ```powershell
   # Active Directory PowerShell
   Disable-ADAccount -Identity "user@company.com"
   ```

5. Check for lateral movement

**Step 3: Endpoint Containment (15 minutes)**
1. Isolate affected endpoints
   ```yaml
   # EDR isolation command
   crowdstrike isolate -hostname workstation-001
   ```

2. Run full antivirus scan
3. Check for malware installation
4. Collect forensic evidence
5. Document all actions

### Phase 3: Investigation (45 minutes - 2 hours)

**Step 1: Email Analysis**
1. Extract email headers
   ```python
   import email
   from email import policy
   
   def parse_email_headers(email_file):
       with open(email_file, 'rb') as f:
           msg = email.message_from_binary_file(f, policy=policy.default)
       
       headers = {
           'from': msg.get('From'),
           'to': msg.get('To'),
           'subject': msg.get('Subject'),
           'date': msg.get('Date'),
           'message_id': msg.get('Message-ID'),
           'received': msg.get_all('Received'),
           'return_path': msg.get('Return-Path'),
           'authentication_results': msg.get('Authentication-Results')
       }
       return headers
   ```

2. Analyze email content
3. Check for spoofing indicators
4. Review DKIM/SPF/DMARC status

**Step 2: Link Analysis**
1. Extract malicious URLs
2. Check URL reputation
   ```python
   import requests
   import json
   
   def check_url_reputation(url):
       # VirusTotal API check
       api_key = "YOUR_API_KEY"
       headers = {"x-apikey": api_key}
       
       response = requests.post(
           "https://www.virustotal.com/api/v3/urls",
           headers=headers,
           data={"url": url}
       )
       
       if response.status_code == 200:
           return response.json()
       return None
   ```

3. Determine redirect chain
4. Identify hosting information
5. Document indicators

**Step 3: Credential Impact Assessment**
1. Check if credentials were submitted
2. Identify what accounts were impacted
3. Check for successful authentication
4. Review logins from suspicious IPs
5. Determine data accessed

**Step 4: Malware Analysis**
1. Check attachments for malware
2. Analyze downloaded files
3. Check for C2 communication
4. Review system changes
5. Identify persistence mechanisms

### Phase 4: Eradication (2-4 hours)

**Step 1: Credential Reset**
1. Reset all affected user passwords
   ```powershell
   # Reset all affected users
   $affectedUsers = Get-Content affected_users.txt
   foreach ($user in $affectedUsers) {
       $newPassword = Generate-SecurePassword
       Set-ADAccountPassword -Identity $user -NewPassword $newPassword
       Set-ADUser -Identity $user -ChangePasswordAtLogon $true
       Send-PasswordResetEmail -User $user -NewPassword $newPassword
   }
   ```

2. Reset MFA tokens
   ```powershell
   # Azure AD MFA reset
   Reset-AzureADUserMFA -ObjectId "user@company.com"
   ```

3. Revoke all sessions
4. Check for persistent access
5. Monitor for re-use

**Step 2: Endpoint Cleanup**
1. Remove malicious files
   ```bash
   # Linux endpoint cleanup
   rm -f /tmp/malware.sh
   rm -rf ~/.malware
   ```

2. Remove persistence mechanisms
   ```powershell
   # Windows persistence removal
   Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" | Remove-ItemProperty -Name "Malware"
   ```

3. Reset browser settings
4. Clear cookies and cache
5. Update security software

### Phase 5: Recovery (4-24 hours)

**Step 1: System Verification**
1. Run full security scan
2. Verify patches are current
3. Check security controls
4. Validate user access
5. Confirm no persistence

**Step 2: User Communication**
1. Notify affected users
2. Provide guidance on next steps
3. Offer additional training
4. Monitor for repeat behavior

**Step 3: Additional Training**
1. Provide phishing awareness training
2. Conduct targeted simulation
3. Reinforce reporting culture
4. Document lessons learned

### Phase 6: Lessons Learned (24-72 hours)

**Step 1: Post-Incident Review**
1. Conduct review meeting
2. Document findings
3. Identify improvements
4. Update playbook

**Step 2: Process Improvements**
1. Update detection rules
2. Enhance email filtering
3. Improve user training
4. Update reporting procedures

**Step 3: Documentation**
1. Final incident report
2. Update IOCs
3. Update playbook
4. Share lessons learned

## 3. Communication Templates

### 3.1 User Notification Template

```markdown
# Security Alert: Phishing Email Campaign

## Incident Summary
Date: [Date]
Time: [Time]
Type: Phishing Email Campaign

## What Happened
We identified a phishing email campaign targeting our organization. The emails appeared to come from [Sender] and asked recipients to [Action].

## What We Are Doing
- Blocking the sender and malicious domains
- Reviewing affected accounts
- Enhancing email filtering rules
- Providing additional training

## What You Should Do
1. Do not click on suspicious links
2. Report suspicious emails to phishing@company.com
3. Verify sender addresses carefully
4. Enable MFA for all accounts

## Questions?
Contact the Security Team at security@company.com or call [Phone Number]

## Additional Resources
- [Link to phishing awareness training]
- [Link to phishing reporting guide]
```

### 3.2 Internal Communication Template

```markdown
# Phishing Incident Update

## Incident ID
[ID]

## Current Status
[Open/Investigating/Contained/Resolved]

## Summary
[Brief description of current situation]

## Impact
- Emails Sent: [Number]
- Users Clicked: [Number]
- Accounts Compromised: [Number]
- Systems Affected: [List]

## Response Actions
- Email Sender Blocked: [Yes/No]
- Domain Blocked: [Yes/No]
- Users Notified: [Yes/No]
- Passwords Reset: [Yes/No]
- Endpoints Scanned: [Yes/No]

## Next Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Escalation
[Escalation contact information]
```

## 4. Tools and Resources

### 4.1 Detection Tools
- Email Security Gateway
- SIEM
- Threat Intelligence feeds
- Sandboxing (for attachments)

### 4.2 Investigation Tools
- URL reputation services
- Header analysis tools
- Log analysis tools
- Threat intelligence platforms

### 4.3 Containment Tools
- Email quarantine
- Firewall/DNS blocking
- EDR isolation
- Identity management

## 5. IOC Collection Template

```yaml
# Phishing Incident IOCs
incident_id: "PHISH-2024-001"
date: "2024-03-15"
type: "phishing"

indicators:
  email:
    - sender: "phishing@malicious.com"
    - subject: "URGENT: Security Alert"
    - message_id: "<12345@malicious.com>"
    - return_path: "bounce@malicious.com"
  
  urls:
    - "http://malicious-domain.com/login"
    - "https://phishing-site.com/verify"
  
  domains:
    - "malicious-domain.com"
    - "phishing-site.com"
  
  ips:
    - "192.168.1.100"
    - "10.0.0.50"
  
  hashes:
    md5: "d41d8cd98f00b204e9800998ecf8427e"
    sha256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  
  attachments:
    - "invoice_2024.pdf.exe"
    - "document_scan.zip"
```

---

## N.2: Ransomware Response Playbook

### N.2.1: Complete Ransomware Response

**File:** `incident-response/playbooks/ransomware-response.md`

```markdown
# Ransomware Incident Response Playbook

## 1. Overview

### 1.1 Purpose
This playbook provides step-by-step guidance for responding to ransomware incidents.

### 1.2 Activation Criteria
Activate this playbook when:
- Ransomware encryption confirmed
- Ransom note observed
- File extensions changed (.encrypted, .lock, .crypt)
- Systems showing signs of compromise
- EDR alert for ransomware
- User report of ransom demand

## 2. Response Phases

### Phase 1: Detection & Triage (0-15 minutes)

**Detection Signs:**
1. File extensions changed (to .encrypted, .crypt, etc.)
2. Ransom notes left in directories
3. Encryption activity alerts from EDR
4. Unusual file system activity
5. System performance degradation
6. Disabled security tools
7. User reports of encrypted files

**Initial Triage:**
1. Confirm ransomware activity
2. Identify affected systems
3. Determine encryption scope
4. Assess business impact
5. Declare incident

**Severity Declaration:**
Declare critical incident when:
- More than 5 systems affected
- Critical systems compromised
- Ransom note present
- Encryption activity confirmed
- Data exfiltration suspected

**Triage Checklist:**

| Step | Action | Owner | Time |
|------|--------|-------|------|
| 1 | Confirm ransomware | SOC Analyst | 2 min |
| 2 | Identify affected systems | SOC Analyst | 5 min |
| 3 | Determine encryption scope | SOC Analyst | 5 min |
| 4 | Assess business impact | SOC Analyst | 3 min |
| 5 | Notify Incident Response Lead | SOC Analyst | 2 min |
| 6 | Declare incident (if critical) | IR Lead | 3 min |

### Phase 2: Containment (15-60 minutes)

**Step 1: Network Isolation (15 minutes)**

1. **Isolate Affected Systems:**
   ```bash
   # Disconnect network interfaces
   ifconfig eth0 down
   # Or physically disconnect
   ```

2. **Block at Firewall:**
   ```bash
   # Block infected IPs
   iptables -A INPUT -s 192.168.1.100 -j DROP
   iptables -A OUTPUT -d 192.168.1.100 -j DROP
   ```

3. **Segment Network:**
   ```yaml
   # Network isolation configuration
   firewall:
     rules:
       - action: "deny"
         source: "Infected-Segment"
         destination: "Critical-Segment"
   ```

4. **Disable VPN Access:**
   ```bash
   # VPN ACL update
   vpn_acl:
     rule: "deny"
     user: "Infected-User"
     reason: "Ransomware containment"
   ```

5. **Isolate Backup Systems:**
   ```bash
   # Disconnect backup network
   ifconfig backup-interface down
   ```

**Step 2: Endpoint Containment (15 minutes)**

1. **Isolate Endpoints:**
   ```yaml
   # EDR isolation
   edr:
     action: "isolate"
     endpoints:
       - "workstation-001"
       - "server-001"
   ```

2. **Terminate Malicious Processes:**
   ```powershell
   # Windows process termination
   taskkill /IM malware.exe /F
   taskkill /IM ransomware.exe /F
   ```

3. **Stop Encryption Activity:**
   ```bash
   # Linux encryption process stop
   killall -9 ransomware
   killall -9 encrypt
   ```

4. **Block C2 Communication:**
   ```yaml
   # DNS sinkhole
   dns_sinkhole:
     - "ransomware-c2.com"
     - "malicious-c2.net"
   ```

**Step 3: Protect Backups (15 minutes)**

1. **Disconnect Backup Systems:**
   - Isolate backup infrastructure
   - Ensure backups are offline
   - Verify backup integrity
   - Take offline copy of backups

2. **Verify Immutable Backups:**
   - Check immutability status
   - Confirm WORM storage
   - Validate retention periods
   - Test restore viability

3. **Create New Backups:**
   - Backup unaffected systems
   - Create new immutable backup
   - Store offline
   - Test restore

**Step 4: Evidence Preservation (15 minutes)**

1. **Collect Forensic Data:**
   ```bash
   # Memory capture
   sudo dd if=/dev/mem of=/tmp/memory.dump bs=1M
   ```

2. **Preserve Logs:**
   ```bash
   # Collect system logs
   tar -czf logs.tar.gz /var/log/*
   ```

3. **Capture Network Traffic:**
   ```bash
   # Network capture
   tcpdump -i eth0 -w traffic.pcap
   ```

4. **Take Forensic Images:**
   ```bash
   # Disk imaging
   dd if=/dev/sda of=/tmp/disk_image.img bs=4M
   ```

### Phase 3: Investigation (1-4 hours)

**Step 1: Root Cause Analysis**

1. **Identify Entry Point:**
   - Review email logs for phishing
   - Check for compromised credentials
   - Review firewall logs
   - Check for RDP/SSH brute force
   - Review application logs
   - Check for unpatched vulnerabilities

2. **Identify Affected Accounts:**
   - Review login activity
   - Check for credential theft
   - Review privileged account usage
   - Check for new accounts
   - Review API key usage

3. **Identify Attack Timeline:**
   - When did initial compromise occur?
   - When was encryption triggered?
   - How long was attacker active?
   - What data was accessed?

**Step 2: Scope Assessment**

1. **Determine Affected Systems:**
   ```
   Affected Systems List:
   - [System 1]
   - [System 2]
   - [System 3]
   ```

2. **Determine Data Exposure:**
   - What data was encrypted?
   - What data was exfiltrated?
   - What data was compromised?
   - What data is at risk?

3. **Determine Business Impact:**
   - Business operations affected
   - Customer impact
   - Regulatory impact
   - Financial impact
   - Reputational impact

### Phase 4: Eradication (4-8 hours)

**Step 1: System Cleanup**

1. **Remove Malware:**
   - Run full antivirus scans
   - Use EDR to quarantine threats
   - Remove persistence mechanisms
   - Delete malicious files
   - Clean registry entries
   - Remove scheduled tasks

2. **System Hardening:**
   - Close unnecessary ports
   - Remove unnecessary services
   - Update security software
   - Apply latest patches
   - Implement additional controls

**Step 2: Credential Reset**

1. **Reset All Passwords:**
   - All affected users
   - All privileged accounts
   - All service accounts
   - All API keys
   - All application tokens

2. **Reset MFA:**
   - Reconfigure MFA
   - Generate new backup codes
   - Disable old MFA methods
   - Verify MFA enrollment

3. **Revoke Sessions:**
   - Revoke all active sessions
   - Terminate active connections
   - Force re-authentication
   - Monitor for anomalies

**Step 3: Vulnerability Remediation**

1. **Patch Exploited Vulnerabilities**
2. **Remove Unauthorized Accounts**
3. **Fix Security Misconfigurations**
4. **Implement Additional Controls**
5. **Update Security Policies**

### Phase 5: Recovery (4-24 hours)

**Step 1: Restoration Strategy**

1. **Prioritize Systems:**
   - Critical business systems
   - Customer-facing systems
   - Financial systems
   - Internal business systems
   - Support systems

2. **Restore Order:**
   - Identify restore priority
   - Define recovery sequence
   - Establish dependencies
   - Plan rollback procedures

**Step 2: Data Restoration**

1. **Validate Backups:**
   ```bash
   # Backup integrity check
   veeam validate --backup-id "backup-2024-03-15"
   ```

2. **Restore from Immutable Backups:**
   ```bash
   # Immutable backup restore
   veeam restore --backup-id "immutable-backup-001" --target "prod-server-01"
   ```

3. **Verify Data Integrity:**
   ```bash
   # Data validation
   rsync -av --checksum restored/ original/ 
   diff -r restored/ original/
   ```

4. **Validate Business Functions:**
   - Test application functionality
   - Verify data accuracy
   - Validate business processes
   - Test user access

**Step 3: System Recovery**

1. **Wipe Affected Systems**
2. **Reinstall Operating Systems**
3. **Apply Security Patches**
4. **Install Security Software**
5. **Restore from Clean Backups**

**Step 4: Operational Recovery**

1. **Gradual Reconnection:**
   - Reconnect to network
   - Test system functionality
   - Monitor for anomalies
   - Gradually restore services

2. **User Access Restoration:**
   - Restore user accounts
   - Validate access controls
   - Test user authentication
   - Verify permissions

3. **Monitoring Activation:**
   - Enable security monitoring
   - Configure logging
   - Activate alerting
   - Monitor for threats

### Phase 6: Lessons Learned (24-72 hours)

**Step 1: Post-Incident Review**

1. **Conduct Review Session:**
   - Identify what worked well
   - Identify what failed
   - Document lessons learned
   - Create improvement plan

2. **Update Playbooks:**
   - Update procedures
   - Enhance detection
   - Improve response
   - Address gaps

**Step 2: Regulatory and Legal**

1. **Determine Notification Requirements:**
   - GDPR (72 hours)
   - CCPA (reasonable)
   - HIPAA (60 days)
   - PCI DSS (immediate)

2. **Notify Regulatory Authorities:**
   - Prepare notification letter
   - Submit to relevant authorities
   - Document compliance
   - Maintain records

3. **Legal Consultation:**
   - Consult with legal counsel
   - Review liability
   - Prepare for litigation
   - Preserve evidence

## 3. Communication Templates

### 3.1 Executive Notification Template

```markdown
# Ransomware Incident Executive Brief

## Incident Summary
- Date: [Date]
- Time: [Time]
- Severity: [Critical/High]
- Systems Affected: [Count]
- Business Impact: [Impact Description]

## Current Status
- Detection: [Time]
- Containment: [Time]
- Investigation: [Status]
- Recovery: [Status]

## Key Metrics
- Systems Affected: [Count]
- Data Encrypted: [Amount]
- Business Disruption: [Description]
- Estimated Recovery Time: [Hours]

## Response Actions
- [Action 1]
- [Action 2]
- [Action 3]

## Next Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Contact Information
- Incident Commander: [Name, Phone]
- CISO: [Name, Phone]
- Crisis Team: [Name, Phone]
```

---

## N.3: Forensic Collection Procedures

### N.3.1: Evidence Collection Guide

**File:** `incident-response/forensics/evidence-collection.md`

```markdown
# Evidence Collection Guide

## 1. Overview

### 1.1 Purpose
To establish consistent procedures for the collection, preservation, and documentation of digital evidence during security incidents.

### 1.2 Principles
1. **Preservation:** Maintain the integrity of evidence
2. **Continuity:** Document chain of custody
3. **Admissibility:** Ensure evidence is admissible in court
4. **Completeness:** Collect all relevant evidence
5. **Documentation:** Document everything

## 2. Collection Procedures

### 2.1 Live System Collection

**Memory Collection:**

```bash
# Linux memory capture
sudo dd if=/dev/mem of=/tmp/memory.dump bs=1M

# Windows memory capture (FTK Imager)
FTKImager.exe /memory /o:/tmp/memory.dump

# MacOS memory capture
sudo osxpmem -o /tmp/memory.dump
```

**Process Information:**

```bash
# Windows process list
tasklist /v > process_list.txt
wmic process list full > process_full.txt

# Linux process list
ps auxf > processes.txt
lsof -i > network_connections.txt
```

**Network Information:**

```bash
# Windows network connections
netstat -anob > network_connections.txt
ipconfig /all > network_config.txt

# Linux network connections
netstat -tulpn > network_connections.txt
ss -tulpn > sockets.txt
```

**System Information:**

```bash
# Windows system info
systeminfo > system_info.txt
wmic qfe list > patches.txt
Get-WinEvent -LogName Security -MaxEvents 1000 > security_events.txt

# Linux system info
uname -a > system_info.txt
cat /etc/os-release > os_info.txt
dpkg -l > installed_packages.txt
```

### 2.2 File System Collection

**Create Disk Image:**

```bash
# Linux disk imaging
dd if=/dev/sda of=/tmp/disk_image.img bs=4M conv=noerror,sync

# Windows disk imaging (FTK Imager)
FTKImager.exe /image /source:\\.\PHYSICALDRIVE0 /dest:/tmp/disk_image.E01
```

**Collect Specific Files:**

```bash
# Windows system files
copy C:\Windows\System32\config\SYSTEM /tmp/SYSTEM
copy C:\Windows\System32\config\SAM /tmp/SAM
copy C:\Windows\System32\config\SECURITY /tmp/SECURITY

# Linux system files
cp /etc/passwd /tmp/passwd
cp /etc/shadow /tmp/shadow
cp /var/log/* /tmp/logs/
```

### 2.3 Log Collection

**Windows Event Logs:**
```powershell
# Export security logs
wevtutil epl Security /tmp/Security.evtx
wevtutil epl System /tmp/System.evtx
wevtutil epl Application /tmp/Application.evtx

# Convert to CSV
wevtutil qe /tmp/Security.evtx /f:Text /rd:true /c:1000 > /tmp/security_logs.txt
```

**Linux Logs:**
```bash
# Collect all logs
tar -czf /tmp/logs.tar.gz /var/log/*

# Audit logs
cp /var/log/audit/audit.log /tmp/audit.log
```

### 2.4 Malware Collection

**Collect Suspicious Files:**

```bash
# Copy suspicious files
cp /tmp/suspicious.exe /tmp/malware/
cp /tmp/ransomware.exe /tmp/malware/
cp /tmp/ransom_note.txt /tmp/malware/
```

**Collect Indicators:**

```yaml
# Malware indicators
indicators:
  files:
    - name: "suspicious.exe"
      path: "/tmp/suspicious.exe"
      hash_sha256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      hash_md5: "d41d8cd98f00b204e9800998ecf8427e"
      size: 1024000
      created: "2024-03-15 10:00:00"
      modified: "2024-03-15 10:00:00"
  
  network:
    - c2_domain: "malicious-c2.com"
    - c2_ip: "192.168.1.100"
    - c2_port: 4444
  
  registry:
    - key: "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
      value: "Malware"
      data: "C:\malware.exe"
```

## 3. Chain of Custody

### 3.1 Chain of Custody Form

```markdown
# Chain of Custody

## Evidence Information

| Field | Value |
|-------|-------|
| Evidence ID | EVID-2024-001 |
| Evidence Type | [Type] |
| Description | [Description] |
| Collection Date | [Date] |
| Collection Time | [Time] |
| Collection Method | [Method] |
| Hash (SHA-256) | [Hash] |

## Chain of Custody Log

| # | Date | Time | Handled By | Received By | Location | Purpose |
|---|------|------|------------|-------------|----------|---------|
| 1 | [Date] | [Time] | [Name] | [Name] | [Location] | Collection |
| 2 | [Date] | [Time] | [Name] | [Name] | [Location] | Storage |
| 3 | [Date] | [Time] | [Name] | [Name] | [Location] | Analysis |

## Notes
[Any additional notes]
```

### 3.2 Evidence Logging

**Required Information:**
1. Evidence ID
2. Description
3. Collection date/time
4. Collection method
5. Collection personnel
6. Location collected from
7. Condition of evidence
8. Hash values
9. Chain of custody
10. Storage location

---

## N.4: Incident Classification Matrix

### N.4.1: Severity Classification

**File:** `incident-response/incident-classification.md`

```markdown
# Incident Classification Matrix

## 1. Severity Levels

### 1.1 Critical (P1)

**Definition:** Incidents that cause or have the potential to cause severe business disruption, data breach, or significant financial loss.

**Criteria:**
- Multiple critical systems affected
- Significant data breach
- Active threat propagation
- Severe business impact
- Regulatory notification required
- Executive attention required

**Response:**
- Immediate response
- Full incident team
- Executive notification
- Board notification
- Regulatory notification

**Examples:**
- Ransomware on critical systems
- Major data breach
- Critical system compromise
- Active exploitation

### 1.2 High (P2)

**Definition:** Incidents that cause significant business disruption or data exposure but are contained.

**Criteria:**
- Single critical system affected
- Moderate data exposure
- Contained threat
- Moderate business impact
- Potential regulatory impact

**Response:**
- Urgent response
- Incident team
- Executive update
- Regulatory preparation

**Examples:**
- Phishing with credential theft
- Malware on non-critical systems
- Internal threat
- Vulnerability exploit

### 1.3 Medium (P3)

**Definition:** Incidents that cause limited business impact and are easily contained.

**Criteria:**
- Non-critical systems affected
- Limited data exposure
- Easily contained
- Minimal business impact
- No regulatory impact

**Response:**
- Standard response
- Technical team
- Management notification

**Examples:**
- Phishing (no credential theft)
- Non-critical malware
- Policy violations
- Misconfigured systems

### 1.4 Low (P4)

**Definition:** Incidents with minimal or no business impact that are quickly resolved.

**Criteria:**
- Single system affected
- No data exposure
- No business impact
- Easily resolved

**Response:**
- Routine response
- Standard procedures
- Logging and monitoring

**Examples:**
- Suspicious email (reported)
- Attempted attack (blocked)
- Single failed login attempts
- Minor policy violations

## 2. Escalation Matrix

| Severity | Escalate To | Timeframe | Method |
|----------|-------------|-----------|--------|
| Critical | CISO, CEO | < 15 minutes | SMS/Call |
| High | Security Director | < 30 minutes | SMS/Call |
| Medium | Security Manager | < 1 hour | Email/SMS |
| Low | Team Lead | < 4 hours | Email |

## 3. Incident Response Timeline

| Activity | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| Detection | Immediate | Immediate | < 30 min | < 4 hours |
| Triage | < 15 min | < 30 min | < 1 hour | < 4 hours |
| Containment | < 60 min | < 4 hours | < 24 hours | < 72 hours |
| Investigation | < 4 hours | < 8 hours | < 24 hours | < 72 hours |
| Eradication | < 8 hours | < 24 hours | < 72 hours | < 1 week |
| Recovery | < 24 hours | < 72 hours | < 1 week | < 2 weeks |
| Lessons Learned | < 72 hours | < 1 week | < 2 weeks | < 1 month |
```

---

This concludes Appendix N: Complete Incident Response Reference. This comprehensive reference provides the playbooks, procedures, and templates needed to effectively respond to security incidents as part of the Enterprise Cybersecurity Program.
