# Appendix E: Complete Operational Runbooks

## Overview

This appendix provides complete operational runbooks for the Enterprise Cybersecurity Program, including daily operations, incident response procedures, maintenance tasks, and troubleshooting guides. These runbooks are designed to be used by security operations teams for day-to-day operations.

---

## E.1: SOC Operations Runbook

### E.1.1: Daily SOC Operations

**File:** `runbooks/soc-daily-operations.md`

```markdown
# SOC Daily Operations Runbook

## 1. Overview

This runbook defines the daily operations procedures for the Security Operations Center (SOC). All SOC analysts should follow these procedures during their shifts.

## 2. Shift Handover Process

### 2.1 Pre-Shift Preparation (15 minutes before shift)

- [ ] Review shift schedule
- [ ] Review previous shift's handover notes
- [ ] Check system health dashboards
- [ ] Review active incidents
- [ ] Review pending alerts
- [ ] Check email and communication channels
- [ ] Review threat intelligence updates
- [ ] Check security tool status

### 2.2 Shift Handover Checklist

| Item | Details | Status |
|------|---------|--------|
| **Active Incidents** | List all active incidents with status | |
| **Pending Alerts** | Count and severity distribution | |
| **System Health** | All security tools operational | |
| **Maintenance** | Scheduled maintenance activities | |
| **Threat Intel** | New threat intelligence received | |
| **Tickets** | Outstanding tickets and status | |
| **Special** | Special events or situations | |

## 3. Tier 1 Operations (Triage)

### 3.1 Alert Triage Process

**Step 1: Alert Review** (0-5 minutes per alert)
1. Review alert details in SIEM
2. Check alert severity and priority
3. Identify source and target systems
4. Review user and system context
5. Check for duplicate alerts

**Step 2: Initial Classification** (2 minutes per alert)
1. Determine if alert is actionable
2. Categorize alert type:
   - Malware/Ransomware
   - Phishing
   - Unauthorized Access
   - Data Exfiltration
   - System Anomaly
   - Policy Violation
3. Assign initial priority:
   - Critical: Requires immediate investigation
   - High: Investigate within 15 minutes
   - Medium: Investigate within 1 hour
   - Low: Investigate within 4 hours

**Step 3: Initial Investigation** (10-15 minutes per alert)
1. Gather additional context:
   - Check user activity
   - Review system logs
   - Check threat intelligence
   - Verify source IP/domain
2. Determine if additional investigation needed
3. Escalate based on findings

**Step 4: Alert Resolution**
- False Positive: Close with justification
- Informational: Document and close
- Suspicious: Escalate to Tier 2
- Confirmed Incident: Escalate to Tier 2/IR Team

### 3.2 Common Alert Triage Guide

| Alert Type | Triage Action | Escalation |
|------------|---------------|------------|
| **Malware Detection** | Verify detection, check quarantine status | Tier 2 |
| **Phishing Email** | Review email, check attachments/links | Tier 2 |
| **Login Failure (Multiple)** | Verify user, check location/IP | Tier 2 |
| **Unusual Data Transfer** | Review data volume, destination | Tier 2 |
| **Privilege Escalation** | Check user permissions, audit log | Tier 2 |
| **DDoS Attack** | Verify traffic patterns | Tier 2 |

## 4. Tier 2 Operations (Investigation)

### 4.1 Incident Investigation Process

**Step 1: Deep Investigation** (30-60 minutes)
1. Collect all relevant logs:
   - System logs
   - Application logs
   - Network logs
   - Security logs
   - User logs

2. Perform timeline analysis
3. Identify root cause
4. Determine scope and impact
5. Document findings

**Step 2: Evidence Collection**
1. Collect and preserve evidence
2. Document collection process
3. Create hashes of evidence
4. Secure evidence storage

**Step 3: Containment Planning**
1. Identify containment strategy
2. Determine containment steps
3. Coordinate with IT Operations
4. Implement containment

**Step 4: Incident Reporting**
1. Create detailed incident report
2. Include:
   - Timeline
   - Affected systems
   - Root cause
   - Containment actions
   - Recommendations
3. Report to management

### 4.2 Investigation Checklist

| Phase | Task | Status |
|-------|------|--------|
| **Preparation** | Create investigation ticket | |
| | Assign investigator(s) | |
| | Gather initial evidence | |
| **Analysis** | Review logs | |
| | Timeline reconstruction | |
| | Identify root cause | |
| | Determine scope | |
| **Documentation** | Document findings | |
| | Capture evidence | |
| | Create report | |
| **Escalation** | Notify stakeholders | |
| | Escalate to IR Team | |

## 5. Threat Hunting

### 5.1 Daily Threat Hunting Activities

**Morning Hunt** (30 minutes)
- Review threat intelligence feeds
- Check for new IOCs
- Update detection rules
- Review failed detections

**Afternoon Hunt** (60 minutes)
- Conduct proactive hunting:
  1. Search for known adversary TTPs
  2. Review anomalous behavior
  3. Investigate unusual patterns
  4. Check for hidden threats

**End-of-Day Hunt** (30 minutes)
- Review hunting results
- Document findings
- Update hunting playbooks
- Plan next day's hunt

### 5.2 Threat Hunting Query Templates

**Suspicious Process Execution:**
```sql
SELECT timestamp, host, user, process, command_line
FROM logs
WHERE process IN ('powershell.exe', 'cmd.exe', 'wscript.exe')
AND command_line LIKE '%enc%'
ORDER BY timestamp DESC
```

**Unusual Network Connections:**
```sql
SELECT timestamp, host, dest_ip, dest_port, bytes
FROM network_logs
WHERE dest_port IN (445, 139, 3389, 22)
AND bytes > 1000000
ORDER BY timestamp DESC
```

**Data Exfiltration Patterns:**
```sql
SELECT timestamp, user, source_ip, dest_ip, bytes_sent
FROM firewall_logs
WHERE bytes_sent > 1000000
AND dest_ip NOT IN (trusted_ips)
ORDER BY timestamp DESC
```

## 6. SOC Shift Checklist

### 6.1 Morning Shift (6:00 AM - 2:00 PM)
- [ ] Review overnight incidents
- [ ] Check system health
- [ ] Process outstanding alerts
- [ ] Conduct morning threat hunt
- [ ] Review threat intelligence
- [ ] Update playbooks as needed
- [ ] Prepare handover notes

### 6.2 Afternoon Shift (2:00 PM - 10:00 PM)
- [ ] Review morning shift handover
- [ ] Process incoming alerts
- [ ] Conduct afternoon threat hunt
- [ ] Monitor for unusual activity
- [ ] Update incident tickets
- [ ] Prepare handover notes

### 6.3 Night Shift (10:00 PM - 6:00 AM)
- [ ] Review previous shift handover
- [ ] Process alerts
- [ ] Monitor for critical issues
- [ ] Escalate critical incidents
- [ ] Prepare handover notes

## 7. Communication Protocol

### 7.1 Internal Communication

| Event | Channel | Recipients |
|-------|---------|------------|
| Critical Alert | SMS/Phone | SOC Lead, CISO |
| High Alert | Slack/Teams | SOC Team |
| Medium Alert | Email | SOC Team |
| Low Alert | Ticket | SOC Team |

### 7.2 Escalation Protocol

| Severity | Time to Escalate | Escalate To |
|----------|------------------|-------------|
| Critical | < 5 minutes | SOC Lead → CISO |
| High | < 15 minutes | SOC Lead |
| Medium | < 1 hour | SOC Lead |
| Low | < 4 hours | Team Lead |

### 7.3 Notification Templates

**Critical Alert Notification:**
```
🚨 CRITICAL SECURITY ALERT
Time: [timestamp]
Source: [source]
Type: [alert_type]
Systems Affected: [systems]
Impact: [impact_description]
Immediate Action: [required_action]
Contact: [security_contact]
```

**Incident Escalation:**
```
⚠️ INCIDENT ESCALATION
Incident ID: [incident_id]
Severity: [severity]
Status: [status]
Findings: [summary]
Recommendations: [actions]
Next Steps: [plan]
```

## 8. Tools and Resources

### 8.1 SOC Tools
- SIEM: [Platform]
- EDR: [Platform]
- Threat Intelligence: [Platform]
- Ticketing: [Platform]
- Communication: [Platforms]
- Collaboration: [Platforms]

### 8.2 References
- Incident Response Playbooks
- SOC Playbooks
- Escalation Matrix
- Contact Lists
- System Architecture Diagrams
- Knowledge Base

## 9. Shift Log Template

### 9.1 Daily Shift Log

```yaml
# SOC Shift Log
date: YYYY-MM-DD
shift: morning/afternoon/night
analyst: [name]

# Summary
total_alerts: 0
critical_alerts: 0
high_alerts: 0
medium_alerts: 0
low_alerts: 0
incidents_opened: 0
incidents_closed: 0
incidents_escalated: 0

# Notable Events
notable_events:
  - time: HH:MM
    event: description
    action: action_taken

# Threats Hunted
threat_hunts:
  - query: description
    findings: results

# System Health
systems_healthy: true
issues: []

# Handover Notes
pending_actions: []
recommendations: []
```

---

## E.2: Incident Response Runbook

### E.2.1: Ransomware Response

**File:** `runbooks/incident-response-ransomware.md`

```markdown
# Ransomware Incident Response Runbook

## 1. Overview

This runbook provides step-by-step guidance for responding to ransomware incidents.

## 2. Activation Criteria

Activate this playbook when:
- Ransomware encryption confirmed
- Ransom note observed
- File extensions changed
- Files encrypted
- Systems showing signs of compromise

## 3. Phase 1: Detection & Triage (0-15 minutes)

### 3.1 Detection Signs

**Technical Indicators:**
- Unexpected file extensions (.encrypted, .lock, .crypt)
- Ransom notes (text files with payment instructions)
- Encryption activity alerts from EDR
- Unusual file system activity
- System performance degradation
- Disabled security tools

**User Reports:**
- Users reporting encrypted files
- Users reporting ransom notes
- Multiple system error reports
- Files with suspicious names

### 3.2 Initial Triage Checklist

| Step | Action | Owner | Time |
|------|--------|-------|------|
| 1 | Confirm ransomware activity | SOC Analyst | 2 min |
| 2 | Identify affected systems | SOC Analyst | 5 min |
| 3 | Determine encryption scope | SOC Analyst | 5 min |
| 4 | Assess business impact | SOC Analyst | 3 min |
| 5 | Notify Incident Response Lead | SOC Analyst | 2 min |
| 6 | Declare incident (if critical) | IR Lead | 3 min |

### 3.3 Declaration Criteria

Declare a critical incident when:
- ✅ More than 5 systems affected
- ✅ Critical systems compromised
- ✅ Ransom note present
- ✅ Encryption activity confirmed
- ✅ Data exfiltration suspected

## 4. Phase 2: Containment (15-60 minutes)

### 4.1 Immediate Actions

**Step 1: Network Isolation (15 minutes)**
1. Disconnect affected systems from network
2. If physical, disconnect network cables
3. If virtual, disable network adapters
4. Block affected IPs at firewall
5. Segment affected network segments
6. Disable VPN access for affected users

**Step 2: Endpoint Containment (15 minutes)**
1. Use EDR to isolate endpoints
2. Put affected systems in quarantine
3. Block ransomware execution
4. Terminate suspicious processes
5. Block known ransomware domains

**Step 3: Protect Backups (10 minutes)**
1. Immediately disconnect backup systems
2. Ensure backups are off-network
3. Verify backup integrity
4. Take offline copy of backups
5. Isolate backup storage

**Step 4: Preserve Evidence (10 minutes)**
1. Capture memory of affected systems
2. Collect logs
3. Preserve network traffic
4. Take forensic images
5. Document everything

### 4.2 Containment Actions Table

| Action | Tool | Owner | Priority |
|--------|------|-------|----------|
| Network isolation | Firewall | IT Ops | 1 |
| Endpoint quarantine | EDR | Security | 1 |
| Backup protection | Backup | IT Ops | 1 |
| Process termination | EDR | Security | 2 |
| Evidence preservation | Forensic | Security | 2 |
| Domain blocking | DNS | Security | 3 |

## 5. Phase 3: Eradication (1-4 hours)

### 5.1 Root Cause Analysis

**Investigation Steps:**

1. **Identify Entry Point:**
   - Review email logs for phishing
   - Check for compromised credentials
   - Review firewall logs for remote access
   - Check for unpatched vulnerabilities
   - Review application logs

2. **Identify Affected Accounts:**
   - Review login activity
   - Check for credential theft
   - Review privileged account usage
   - Check for new accounts

3. **Identify Attack Timeline:**
   - When did initial compromise occur?
   - When was encryption triggered?
   - How long was attacker active?
   - What data was accessed?

### 5.2 Malware Removal

**Step 1: Scan and Quarantine:**
1. Run full antivirus scans
2. Use EDR to quarantine
3. Remove persistence mechanisms
4. Delete malicious files
5. Clean registry entries
6. Remove scheduled tasks

**Step 2: System Cleanup:**
1. Remove ransomware remnants
2. Disable malware services
3. Delete temporary files
4. Clear browser caches
5. Reset affected profiles

**Step 3: Credential Reset:**
1. Reset all user passwords
2. Rotate privileged accounts
3. Reset API keys
4. Reset application tokens
5. Implement MFA if not in place

## 6. Phase 4: Recovery (4-24 hours)

### 6.1 Restoration Planning

**Priority Order:**
1. Critical business systems
2. Customer-facing systems
3. Financial systems
4. Internal business systems
5. Support systems

### 6.2 Restoration Process

**Step 1: Backup Validation:**
1. Verify backup integrity
2. Check for hidden malware
3. Verify backup dates
4. Test backup restoration
5. Document backup status

**Step 2: System Restoration:**
1. Wipe affected systems
2. Reinstall OS
3. Apply security patches
4. Install security tools
5. Restore data from backups

**Step 3: Security Validation:**
1. Verify malware removal
2. Check for persistence
3. Test security controls
4. Verify logging
5. Check for vulnerabilities

**Step 4: Reconnection:**
1. Reconnect to network
2. Test system functionality
3. Monitor for anomalies
4. Gradually restore services
5. Validate business processes

### 6.3 Recovery Checklist

**Pre-Recovery Checks:**
- [ ] Ransomware removed from all systems
- [ ] Backups verified clean
- [ ] Credentials reset
- [ ] Security tools operational
- [ ] Network segmentation in place
- [ ] Monitoring active

**Recovery Steps:**
- [ ] Restore critical servers
- [ ] Restore business applications
- [ ] Restore end-user systems
- [ ] Validate data integrity
- [ ] Test business functionality
- [ ] Connect systems to network
- [ ] Activate monitoring
- [ ] Notify users

## 7. Phase 5: Lessons Learned (24-72 hours)

### 7.1 Post-Incident Activities

**Step 1: Conduct Review:**
1. Hold lessons learned session
2. Review timeline
3. Identify successes
4. Identify failures
5. Document findings

**Step 2: Identify Improvements:**
1. Update playbooks
2. Improve detection
3. Enhance controls
4. Address gaps
5. Prioritize fixes

**Step 3: Update Documentation:**
1. Update incident report
2. Add IOCs
3. Update playbook
4. Update architecture
5. Update risk register

### 7.2 Legal and Regulatory

**Notification Requirements:**

| Authority | Notification Required | Timeline |
|-----------|----------------------|----------|
| GDPR | If personal data involved | 72 hours |
| CCPA | If CA residents affected | Reasonable |
| HIPAA | If PHI involved | 60 days |
| PCI DSS | If card data involved | Immediate |
| SEC | If material impact | 4 days |

## 8. Communication Plan

### 8.1 Internal Communication

| Time | Audience | Channel | Message |
|------|----------|---------|---------|
| 0 min | SOC Team | Chat | Detection |
| 15 min | IR Lead | Phone | Declaration |
| 30 min | Security Team | Email | Details |
| 45 min | CISO | Phone | Executive |
| 2 hours | Executive Council | Meeting | Impact |
| 8 hours | CEO/Board | Briefing | Summary |

### 8.2 External Communication

| Stakeholder | Timing | Message |
|-------------|--------|---------|
| Legal Counsel | Immediate | Legal implications |
| Insurance | 24 hours | Claim notification |
| Customers | 48 hours | If data exposure |
| Regulators | 72 hours | If required |
| Media | As needed | Prepared statement |

## 9. Recovery Testing

### 9.1 Testing Schedule

| Test Type | Frequency | Scope |
|-----------|-----------|-------|
| Tabletop | Quarterly | Leadership |
| Technical | Monthly | IT Operations |
| Full Recovery | Annually | All systems |

### 9.2 Test Checklist

- [ ] Test backup restoration
- [ ] Validate RTO/RPO
- [ ] Test system functionality
- [ ] Verify security controls
- [ ] Test user access
- [ ] Validate monitoring
- [ ] Document test results
- [ ] Update playbooks

---

## E.3: SIEM Operations Runbook

### E.3.1: SIEM Daily Operations

**File:** `runbooks/siem-operations.md`

```markdown
# SIEM Operations Runbook

## 1. Overview

This runbook defines procedures for SIEM operations, including log management, correlation rule management, and alert tuning.

## 2. Daily Operations

### 2.1 Morning Checks

**Log Ingestion Health (6:00 AM - 7:00 AM)**
1. Check log ingestion volumes
2. Verify all log sources connected
3. Review log collection errors
4. Check for missing logs
5. Validate log timestamps

**System Health (7:00 AM - 7:30 AM)**
1. Check SIEM system health
2. Verify storage utilization (<80%)
3. Check index performance
4. Verify backup status
5. Check for errors

**Alert Review (7:30 AM - 8:00 AM)**
1. Review overnight alerts
2. Verify alert processing
3. Check alert volumes
4. Review high-priority alerts
5. Document notable alerts

### 2.2 Hourly Checks

**Every Hour:**
1. Quick system health check
2. Review critical alerts
3. Check ingestion rates
4. Monitor for anomalies

### 2.3 End of Day Checks (4:00 PM - 5:00 PM)

1. Review day's alerts
2. Check system capacity
3. Plan maintenance
4. Document issues
5. Prepare handover

## 3. Log Source Management

### 3.1 Adding New Log Sources

**Step 1: Pre-Integration Assessment**
1. Identify log source type
2. Determine log format
3. Assess data volume
4. Identify storage requirements
5. Plan retention policy

**Step 2: Integration**
1. Configure log source
2. Test log collection
3. Validate parsing
4. Normalize fields
5. Add to search indices

**Step 3: Validation**
1. Verify log ingestion
2. Test searches
3. Validate field extraction
4. Check for errors
5. Document configuration

### 3.2 Log Source Monitoring

**Checklist:**
- [ ] Log source online
- [ ] Logs being received
- [ ] No parsing errors
- [ ] Volume within thresholds
- [ ] Timestamps correct

## 4. Correlation Rule Management

### 4.1 Rule Lifecycle

**Phase 1: Development**
1. Identify detection requirement
2. Write correlation rule
3. Test with historical data
4. Validate accuracy
5. Tune rule

**Phase 2: Deployment**
1. Deploy to development environment
2. Test with live data
3. Validate results
4. Adjust as needed
5. Deploy to production

**Phase 3: Maintenance**
1. Monitor rule performance
2. Adjust thresholds
3. Update for new threats
4. Disable if ineffective
5. Document changes

### 4.2 Rule Testing Process

**Step 1: Test Data Preparation**
1. Identify test scenarios
2. Prepare test logs
3. Create expected alerts
4. Document test plan

**Step 2: Execution**
1. Run rule against test data
2. Compare results to expected
3. Identify discrepancies
4. Adjust rule as needed
5. Re-test

**Step 3: Validation**
1. Verify alert accuracy
2. Check for false positives
3. Validate alert details
4. Test with production data

### 4.3 Rule Tuning Guide

**High False Positive Rate:**
- Adjust thresholds
- Add exclusion conditions
- Narrow time windows
- Reduce sensitivity

**Low Detection Rate:**
- Broaden conditions
- Extend time windows
- Increase sensitivity
- Add additional rules

**Performance Issues:**
- Optimize queries
- Reduce data scope
- Use indexed fields
- Schedule during low load

## 5. Alert Management

### 5.1 Alert Triage

**Alert Lifecycle:**
1. Alert Generated
2. Initial Triage
3. Classification
4. Investigation
5. Resolution

**Triage Levels:**

| Level | Criteria | Action |
|-------|----------|--------|
| Critical | Business impact, data breach | Immediate action |
| High | Significant risk | Investigate within 15 min |
| Medium | Moderate risk | Investigate within 1 hour |
| Low | Minor risk | Investigate within 4 hours |

### 5.2 Alert Response Templates

**False Positive Response:**
1. Confirm false positive
2. Document reason
3. Close alert
4. Consider rule tuning

**Informational Alert:**
1. Review details
2. Document findings
3. Close alert

**Suspicious Activity:**
1. Gather more context
2. Investigate source/user
3. Check related alerts
4. Escalate if needed

**Confirmed Incident:**
1. Follow incident response playbook
2. Escalate immediately
3. Notify relevant teams
4. Document everything

## 6. Reporting

### 6.1 Daily Reports

**Report Contents:**
1. Alert summary
2. Top alert sources
3. Log ingestion volumes
4. System health status
5. Notable events

### 6.2 Weekly Reports

**Report Contents:**
1. Alert trends
2. Rule performance
3. Log source health
4. System capacity
5. Improvement recommendations

### 6.3 Monthly Reports

**Report Contents:**
1. Comprehensive metrics
2. Trend analysis
3. Capacity planning
4. Rule effectiveness
5. Threat landscape

## 7. SIEM Health Monitoring

### 7.1 Health Metrics

**System Metrics:**
- CPU utilization < 70%
- Memory usage < 80%
- Storage usage < 80%
- Indexing rate
- Search performance

**Log Metrics:**
- Ingestion rate
- Log source coverage
- Parsing success rate
- Data volume
- Retention compliance

### 7.2 Health Checks

**Check Schedule:**

| Check | Frequency | Action on Failure |
|-------|-----------|-------------------|
| System Health | Hourly | Restart service |
| Log Ingestion | Hourly | Reconnect source |
| Storage | Daily | Increase capacity |
| Backup | Daily | Investigate failure |
| Performance | Weekly | Optimize |

## 8. Troubleshooting

### 8.1 Common Issues

**Issue 1: Log Source Not Sending**

**Troubleshooting:**
1. Check network connectivity
2. Verify configuration
3. Check log source status
4. Review error logs
5. Restart log forwarding

**Issue 2: High System Load**

**Troubleshooting:**
1. Review current searches
2. Check for runaway queries
3. Review ingestion rate
4. Archive old data
5. Scale resources

**Issue 3: No Alerts**

**Troubleshooting:**
1. Verify rules enabled
2. Check log ingestion
3. Review rule conditions
4. Test rule manually
5. Check time windows

## 9. SIEM CLI Commands

### 9.1 Quick Reference

```bash
# Check system health
<siem> health check

# List log sources
<siem> log-sources list

# Verify log ingestion
<siem> logs verify --source <source>

# Run test query
<siem> search "index=* earliest=-10m"

# Check rule status
<siem> rules list --status active

# Test correlation rule
<siem> rules test --rule-id <id>

# Restart log forwarding
<siem> log-sources restart --source <source>

# Archive old data
<siem> archive --data 90d --target <location>

# Run report
<siem> report generate --type daily
```

### 9.2 Support Escalation

| Issue Level | Response | Escalate To |
|-------------|----------|-------------|
| Level 1 | Standard troubleshooting | SIEM Team |
| Level 2 | Advanced troubleshooting | Vendor Support |
| Level 3 | Emergency response | Vendor Escalation |

---

## E.4: BCP/DR Runbook

### E.4.1: Disaster Recovery Runbook

**File:** `runbooks/disaster-recovery.md`

```markdown
# Disaster Recovery Runbook

## 1. Overview

This runbook provides procedures for disaster recovery of critical systems and data.

## 2. Pre-Recovery Preparation

### 2.1 Recovery Team Activation

| Role | Responsibilities | Contact |
|------|------------------|---------|
| Incident Commander | Overall coordination | [Contact] |
| Recovery Lead | Technical recovery | [Contact] |
| Data Restore Lead | Backup restoration | [Contact] |
| Security Lead | Security validation | [Contact] |
| Communication Lead | Stakeholder updates | [Contact] |

### 2.2 Initial Assessment Checklist

- [ ] Identify affected systems
- [ ] Determine incident scope
- [ ] Assess business impact
- [ ] Declare disaster (if needed)
- [ ] Activate recovery team
- [ ] Establish command center
- [ ] Begin recovery process

### 2.3 Disaster Declaration Criteria

Declare a disaster when:
- Critical systems unavailable > 4 hours
- Data loss > RPO threshold
- Multiple systems affected
- Significant business impact
- Recovery expected > 8 hours

## 3. Recovery Process

### 3.1 Phase 1: Assessment (0-30 minutes)

**Step 1: Damage Assessment**
1. Identify affected systems
2. Determine data loss extent
3. Assess hardware damage
4. Check network infrastructure
5. Evaluate security impact

**Step 2: Recovery Planning**
1. Determine recovery strategy
2. Identify required resources
3. Sequence recovery tasks
4. Establish priorities
5. Estimate recovery time

**Step 3: Team Briefing**
1. Brief recovery team
2. Assign responsibilities
3. Establish communication
4. Provide updates to stakeholders

### 3.2 Phase 2: Infrastructure Recovery (30 minutes - 2 hours)

**Step 1: Network Recovery**
1. Restore network configuration
2. Verify connectivity
3. Establish VPN/Remote access
4. Test network services
5. Document network status

**Step 2: Compute Recovery**
1. Provision replacement hardware
2. Restore from configuration
3. Install OS and patches
4. Install security tools
5. Validate systems

**Step 3: Storage Recovery**
1. Restore storage infrastructure
2. Verify storage connectivity
3. Configure storage policies
4. Test storage performance
5. Document storage status

### 3.3 Phase 3: Data Recovery (2-8 hours)

**Step 1: Backup Validation**
1. Verify backup integrity
2. Check backup timestamps
3. Validate backup completeness
4. Test restore viability
5. Document backup status

**Step 2: Data Restoration**
1. Identify data to restore
2. Select restore points
3. Begin data restoration
4. Monitor restore progress
5. Verify data integrity

**Step 3: Data Validation**
1. Verify data completeness
2. Check data integrity
3. Validate application compatibility
4. Test data access
5. Document validation results

### 3.4 Phase 4: Application Recovery (4-24 hours)

**Step 1: Core Applications**
1. Restore application servers
2. Install application software
3. Configure applications
4. Restore application data
5. Test application functionality

**Step 2: Business Applications**
1. Restore business application
2. Configure application settings
3. Restore business data
4. Test business processes
5. Validate functionality

**Step 3: User Access**
1. Restore user accounts
2. Configure access controls
3. Test user authentication
4. Validate permissions
5. Document access status

### 3.5 Phase 5: Validation and Cutover (8-24 hours)

**Step 1: Technical Validation**
1. System functionality tests
2. Performance verification
3. Security validation
4. Integration testing
5. Documentation review

**Step 2: Business Validation**
1. Business process testing
2. User acceptance testing
3. Transaction validation
4. Reporting verification
5. Stakeholder approval

**Step 3: Production Cutover**
1. Switch to recovered systems
2. Monitor performance
3. Validate transactions
4. Notify stakeholders
5. Begin monitoring

## 4. Recovery Checklists

### 4.1 Critical Systems Recovery

**System: [System Name]**

| Phase | Task | Status | Owner | Time |
|-------|------|--------|-------|------|
| 1 | Assess damage | | | |
| 2 | Provision infrastructure | | | |
| 3 | Restore from backup | | | |
| 4 | Validate recovery | | | |
| 5 | Switch to production | | | |

### 4.2 Data Recovery

**Data Type: [Data Type]**

| Phase | Task | Status | Owner | Time |
|-------|------|--------|-------|------|
| 1 | Identify data to recover | | | |
| 2 | Select restore point | | | |
| 3 | Begin data restoration | | | |
| 4 | Validate data integrity | | | |
| 5 | Complete restoration | | | |

### 4.3 Security Validation Checklist

- [ ] Antivirus/EDR functioning
- [ ] Security patches applied
- [ ] Firewall rules configured
- [ ] Access controls enabled
- [ ] MFA working
- [ ] Logging active
- [ ] Monitoring operational
- [ ] Incident response ready

## 5. Business Continuity

### 5.1 Temporary Operations

**During Recovery:**
1. Establish temporary office space
2. Set up contingency systems
3. Implement manual procedures
4. Assign temporary roles
5. Document temporary processes

**Communication:**
1. Internal communication plan
2. Customer communication plan
3. Partner communication plan
4. Regulatory communication
5. Media communication plan

### 5.2 Manual Procedures

| Process | Manual Alternative | Person Responsible |
|---------|-------------------|-------------------|
| Order Processing | Paper forms | Department Lead |
| Customer Support | Phone/Email | Support Manager |
| Financial Operations | Spreadsheets | Finance Lead |
| HR/Payroll | Manual timesheets | HR Manager |

## 6. Post-Recovery Activities

### 6.1 Lessons Learned

1. Hold lessons learned session
2. Document findings
3. Identify improvements
4. Update DR plan
5. Schedule improvements

### 6.2 Plan Updates

1. Update recovery procedures
2. Update contact lists
3. Update system inventory
4. Update dependencies
5. Update playbooks

### 6.3 Testing Schedule

| Test Type | Frequency | Next Test |
|-----------|-----------|-----------|
| Tabletop | Quarterly | |
| Technical DR | Monthly | |
| Full DR | Annually | |

## 7. Communication Templates

### 7.1 Disaster Declaration

```
📢 DISASTER DECLARATION
Date: [Date]
Time: [Time]
Type: [Disaster Type]
Scope: [Affected Systems]
Impact: [Business Impact]
Recovery Plan: [Plan Name]
Command Center: [Location/Contact]
```

### 7.2 Recovery Status Update

```
🔄 RECOVERY UPDATE # [Number]
Date: [Date]
Time: [Time]
Phase: [Current Phase]
Progress: [Progress Percentage]
Completed: [Completed Tasks]
In Progress: [Current Tasks]
Issues: [Issues/Concerns]
Next Update: [Time]
```

### 7.3 Recovery Completion

```
✅ RECOVERY COMPLETE
Date: [Date]
Time: [Time]
Systems Recovered: [Count]
Data Restored: [Amount]
Services Restored: [List]
Status: [Operational Status]
Next Steps: [Actions Required]
```

---

## E.5: Vendor Management Runbook

### E.5.1: Vendor Risk Management

**File:** `runbooks/vendor-management.md`

```markdown
# Vendor Management Runbook

## 1. Overview

This runbook provides procedures for vendor risk management and third-party security.

## 2. Vendor Onboarding

### 2.1 Pre-Engagement Phase

**Step 1: Classification**
- Determine vendor tier (1-4)
- Assess criticality
- Identify data access
- Determine contract scope

**Step 2: Security Assessment**
1. Send security questionnaire
2. Review responses
3. Request certifications (SOC 2, ISO 27001)
4. Review security policies
5. Conduct risk assessment

**Step 3: Risk Scoring**

| Risk Score | Category | Action |
|------------|----------|--------|
| 0-20 | Low | Standard onboarding |
| 21-40 | Medium | Enhanced monitoring |
| 41-60 | High | Mitigation plan required |
| 61-100 | Critical | Immediate remediation required |

### 2.2 Onboarding Checklist

- [ ] Vendor registered
- [ ] Risk assessment completed
- [ ] Contract review complete
- [ ] Security requirements included
- [ ] Access controls configured
- [ ] MFA enabled
- [ ] SLA defined
- [ ] Monitoring configured

### 2.3 Contract Security Clauses

**Mandatory Clauses:**
1. Security policy compliance
2. Data protection requirements
3. Incident response obligations (24-hour notification)
4. Access control requirements (MFA, least privilege)
5. Audit rights
6. Data breach notification
7. Data destruction upon termination
8. Subcontractor management

## 3. Continuous Monitoring

### 3.1 Monitoring Schedule

| Vendor Tier | Assessment Frequency | Monitoring Frequency |
|-------------|---------------------|---------------------|
| Tier 1 | Quarterly | Real-time |
| Tier 2 | Bi-annually | Weekly |
| Tier 3 | Annually | Monthly |
| Tier 4 | Annually | Quarterly |

### 3.2 Monitoring Activities

**Weekly:**
- Check security rating changes
- Monitor access logs
- Review failed access attempts
- Check for new vulnerabilities

**Monthly:**
- Review vendor security scorecards
- Check for security incidents
- Verify compliance status
- Review performance metrics

**Quarterly:**
- Conduct risk review
- Update risk score
- Review contract compliance
- Conduct quarterly meeting

## 4. Vendor Assessment Process

### 4.1 Assessment Types

**Initial Assessment:**
- Complete security questionnaire
- Review certifications
- Verify security controls
- Assess risk posture
- Determine risk level

**Annual Assessment:**
- Review security changes
- Verify continued compliance
- Assess new risks
- Update risk score
- Review performance

**Incident-Driven Assessment:**
- Triggered by vendor incidents
- Immediate assessment
- Impact analysis
- Remediation review
- Contract review

### 4.2 Assessment Template

```yaml
Vendor Assessment Report:
  vendor_name: [Vendor Name]
  assessment_date: [Date]
  assessor: [Name]
  
  risk_score: [Score]
  risk_category: [Category]
  
  security_compliance:
    - is_iso_27001_certified: [true/false]
    - is_soc2_compliant: [true/false]
    - has_incident_response_plan: [true/false]
    - has_business_continuity_plan: [true/false]
    - uses_encryption: [true/false]
    - uses_mfa: [true/false]
  
  issues:
    - id: [Issue ID]
      description: [Description]
      severity: [Critical/High/Medium/Low]
      status: [Open/In Progress/Resolved]
      remediation_date: [Date]
  
  recommendations:
    - [Recommendation]
    - [Recommendation]
  
  next_assessment: [Date]
```

## 5. Incident Response (Vendor)

### 5.1 Vendor Incident Notification

**Vendor Obligations:**
1. Notify within 24 hours
2. Provide initial impact assessment
3. Share incident details
4. Regular status updates
5. Post-incident review

**Notification Template:**
```
🚨 VENDOR SECURITY INCIDENT
Vendor: [Vendor Name]
Incident Date: [Date]
Incident Type: [Type]
Impact: [Impact Description]
Status: [Current Status]
Contact: [Vendor Contact]
Next Update: [Time]
```

### 5.2 Vendor Incident Response

**Step 1: Assessment**
1. Validate incident details
2. Assess business impact
3. Determine data exposure
4. Evaluate regulatory impact

**Step 2: Response**
1. Initiate incident response plan
2. Coordinate with vendor
3. Implement containment
4. Notify stakeholders
5. Legal consultation

**Step 3: Recovery**
1. Monitor vendor recovery
2. Verify data security
3. Validate controls
4. Document lessons
5. Update risk assessment

## 6. Vendor Offboarding

### 6.1 Offboarding Process

**Phase 1: Pre-Notification**
1. Identify contract termination
2. Review obligations
3. Plan data transition
4. Identify alternative vendor

**Phase 2: Notification**
1. Provide formal notice
2. Set termination date
3. Define transition period
4. Identify key contacts

**Phase 3: Transition**
1. Transfer data securely
2. Validate data transfer
3. Test system transition
4. Validate functionality

**Phase 4: Decommission**
1. Revoke all access
2. Return or destroy data
3. Obtain destruction certification
4. Conduct final review

### 6.2 Offboarding Checklist

- [ ] Contract termination notice
- [ ] Access termination confirmed
- [ ] Data transfer complete
- [ ] Data destruction certified
- [ ] Final payment made
- [ ] Final security review
- [ ] Records updated
- [ ] Vendor removed from registry

## 7. Reporting

### 7.1 Monthly Vendor Report

**Report Contents:**
1. Vendor summary
2. Risk scores
3. Assessment status
4. Open issues
5. Incidents

### 7.2 Quarterly Vendor Report

**Report Contents:**
1. Detailed vendor analysis
2. Risk trends
3. Compliance status
4. Performance metrics
5. Improvement recommendations

### 7.3 Annual Vendor Report

**Report Contents:**
1. Comprehensive review
2. Program effectiveness
3. Risk reduction metrics
4. Recommendations
5. Next year's plan

---

## E.6: Security Awareness Runbook

### E.6.1: Security Awareness Program Operations

**File:** `runbooks/security-awareness.md`

```markdown
# Security Awareness Program Runbook

## 1. Overview

This runbook defines the operations for the security awareness program, including training delivery, phishing simulations, and engagement metrics.

## 2. Training Operations

### 2.1 Training Schedule

| Training Type | Frequency | Audience |
|---------------|-----------|----------|
| New Hire | Upon hire | All new employees |
| Annual Refresher | Annually | All employees |
| Specialized | Quarterly | Targeted groups |
| Executive | Annually | Leadership |
| Developer | Monthly | Engineering |

### 2.2 Training Deployment

**Step 1: Preparation**
1. Schedule training
2. Notify participants
3. Prepare materials
4. Set up tracking

**Step 2: Execution**
1. Deploy training
2. Monitor completion
3. Send reminders
4. Track progress

**Step 3: Follow-up**
1. Review completions
2. Identify non-compliance
3. Escalate to managers
4. Report to leadership

### 2.3 Training Completion Monitoring

**Targets:**
- New Hire: 5 days
- Annual: 60 days
- Specialized: 30 days
- Executive: 90 days

**Escalation:**
- 15 days overdue: Notification to user
- 30 days overdue: Notification to manager
- 45 days overdue: Notification to HR

## 3. Phishing Simulation Program

### 3.1 Simulation Schedule

| Frequency | Type | Target | Complexity |
|-----------|------|--------|------------|
| Monthly | Standard | All employees | Basic |
| Quarterly | Advanced | All employees | Medium |
| Annual | Targeted | High-risk groups | Advanced |

### 3.2 Campaign Creation Process

**Step 1: Planning**
1. Determine campaign objectives
2. Select target audience
3. Design phishing template
4. Define success metrics

**Step 2: Template Design**
1. Create realistic phishing email
2. Include typical phishing elements
3. Add tracking mechanisms
4. Test template functionality

**Step 3: Campaign Execution**
1. Schedule campaign
2. Deploy emails
3. Monitor engagement
4. Track clicks/reports

**Step 4: Analysis**
1. Calculate click rate
2. Identify vulnerable users
3. Review report rate
4. Generate campaign report

### 3.3 Phishing Template Examples

**Standard Template:**
```
Subject: [SUBJECT]
From: [SENDER]

[Body text with urgency/action required]

[Link/attachment to click]
```

**Advanced Template:**
```
Subject: [SUBJECT - with personalization]
From: [SENDER - legitimate-looking]

[Body text - contextualized]

[Link/attachment with tracking]
```

### 3.4 Response Protocol

**User Clicked:**
1. Provide immediate training
2. Provide context
3. Offer additional resources
4. Track behavior

**User Reported:**
1. Acknowledge report
2. Provide positive reinforcement
3. Track report rates
4. Include in metrics

## 4. Engagement Activities

### 4.1 Monthly Activities

- Email newsletter
- Security tip of the week
- Phishing simulation
- Monthly metrics report

### 4.2 Quarterly Activities

- Town hall presentation
- Security awareness day
- Advanced phishing simulation
- Quarterly metrics report

### 4.3 Annual Activities

- Security awareness month
- Full training cycle
- Program effectiveness review
- Annual metrics report

## 5. Metrics and Reporting

### 5.1 Key Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Training Completion | 100% | Training completions |
| Phishing Click Rate | < 5% | Clicks / Total users |
| Phishing Report Rate | > 10% | Reports / Total users |
| Incident Reporting | > 95% | Reported incidents |
| Knowledge Retention | > 80% | Assessment scores |

### 5.2 Reporting Schedule

| Report Type | Frequency | Audience |
|-------------|-----------|----------|
| Training Completion | Monthly | Security Team |
| Phishing Metrics | Quarterly | Executive Council |
| Program Effectiveness | Annually | Board Committee |

### 5.3 Report Templates

**Monthly Training Report:**
```yaml
Training Report:
  month: [Month]
  
  new_hires:
    total: [Number]
    completed: [Number]
    completion_rate: [Percentage]
  
  annual_training:
    total: [Number]
    completed: [Number]
    completion_rate: [Percentage]
  
  specialized_training:
    total: [Number]
    completed: [Number]
    completion_rate: [Percentage]
  
  overdue_training:
    count: [Number]
    list: [User List]
```

## 6. Champion Program

### 6.1 Champion Recruitment

**Targets:**
- 5% of total employees
- 1 per business unit
- Minimum 1 per department

**Recruitment Process:**
1. Identify candidates
2. Invite to program
3. Provide training
4. Assign activities
5. Track engagement

### 6.2 Champion Activities

**Monthly:**
1. Security briefings
2. Team education
3. Awareness promotion
4. Feedback to security team

**Quarterly:**
1. Champion meetings
2. Advanced training
3. Program reviews
4. Recognition events

---

This concludes Appendix E: Complete Operational Runbooks. These runbooks provide the day-to-day operational procedures for running the Enterprise Cybersecurity Program, ensuring consistent and effective security operations.
