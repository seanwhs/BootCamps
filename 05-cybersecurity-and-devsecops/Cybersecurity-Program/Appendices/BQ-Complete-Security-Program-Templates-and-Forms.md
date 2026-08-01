# Appendix BQ: Complete Security Program Templates and Forms

## Overview

This appendix provides a complete collection of templates and forms for the Enterprise Cybersecurity Program. It includes administrative forms, operational forms, and program management templates.

---

## BQ.1: Administrative Forms

### BQ.1.1: Personnel Forms

**File:** `templates-forms/personnel-forms.md`

```markdown
# Personnel Security Forms

## 1. Access Request Form

### 1.1 Template

```markdown
# Access Request Form

## Request Information

| Field | Value |
|-------|-------|
| Request ID | [ID] |
| Request Date | [Date] |
| Requestor | [Name] |
| Department | [Department] |
| Manager | [Name] |

## Employee Information

| Field | Value |
|-------|-------|
| Employee Name | [Name] |
| Employee ID | [ID] |
| Job Title | [Title] |
| Start Date | [Date] |
| Department | [Department] |
| Location | [Location] |

## Access Request

| Requested Access | Justification | Required By | Duration |
|------------------|---------------|-------------|----------|
| [Access 1] | [Justification] | [Date] | [Duration] |
| [Access 2] | [Justification] | [Date] | [Duration] |

## Approvals

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Manager | | | |
| Security | | | |
| IT | | | |

## Notes

[Additional notes]
```

## 2. Termination Checklist

### 2.1 Template

```markdown
# Employee Termination Checklist

## Employee Information

| Field | Value |
|-------|-------|
| Employee Name | [Name] |
| Employee ID | [ID] |
| Department | [Department] |
| Termination Date | [Date] |
| Manager | [Name] |

## Access Revocation

- [ ] Account disabled
- [ ] Email access removed
- [ ] VPN access revoked
- [ ] MFA disabled
- [ ] All sessions terminated
- [ ] Application access terminated
- [ ] Group memberships removed

## Asset Recovery

- [ ] Laptop returned
- [ ] Mobile device returned
- [ ] Badge returned
- [ ] Keys returned
- [ ] Access cards returned

## Data Handling

- [ ] Data transferred
- [ ] Data archived
- [ ] Data securely deleted

## Completion

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Manager | | | |
| IT | | | |
| Security | | | |
| HR | | | |
```

---

## BQ.2: Operational Forms

### BQ.2.1: Security Forms

**File:** `templates-forms/operational-forms.md`

```markdown
# Operational Security Forms

## 1. Incident Report Form

### 1.1 Template

```markdown
# Security Incident Report

## Incident Information

| Field | Value |
|-------|-------|
| Incident ID | [ID] |
| Date | [Date] |
| Time | [Time] |
| Reported By | [Name] |
| Severity | [Critical/High/Medium/Low] |
| Status | [Open/Investigating/Contained/Resolved] |

## Incident Description

**Summary:**
[Summary]

**Details:**
[Details]

**Impact:**
- Systems Affected: [Systems]
- Users Affected: [Count]
- Data Affected: [Data Types]

## Response Actions

### Actions Taken

| Action | Owner | Time | Status |
|--------|-------|------|--------|
| [Action] | [Name] | [Time] | [Status] |

### Containment

| Action | Owner | Time | Status |
|--------|-------|------|--------|
| [Action] | [Name] | [Time] | [Status] |

### Recovery

| Action | Owner | Time | Status |
|--------|-------|------|--------|
| [Action] | [Name] | [Time] | [Status] |

## Root Cause Analysis

**Root Cause:**
[Root cause]

**Contributing Factors:**
1. [Factor 1]
2. [Factor 2]

## Lessons Learned

**What Worked:**
1. [Item 1]
2. [Item 2]

**What Needs Improvement:**
1. [Item 1]
2. [Item 2]

**Recommendations:**
1. [Recommendation 1]
2. [Recommendation 2]

## Approvals

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Incident Handler | | | |
| SOC Manager | | | |
| CISO | | | |
```

## 2. Vulnerability Report Form

### 2.1 Template

```markdown
# Vulnerability Report

## Vulnerability Information

| Field | Value |
|-------|-------|
| Vulnerability ID | [ID] |
| Scanner | [Scanner] |
| CVSS Score | [Score] |
| Severity | [Critical/High/Medium/Low] |
| Status | [Open/In Progress/Resolved] |
| Discovery Date | [Date] |

## Affected Asset

| Field | Value |
|-------|-------|
| Asset ID | [ID] |
| Name | [Name] |
| Type | [Type] |
| Owner | [Name] |

## Vulnerability Description

**Description:**
[Description]

**Impact:**
[Impact]

**Recommendation:**
[Recommendation]

## Remediation

| Field | Value |
|-------|-------|
| Remediation Plan | [Plan] |
| Owner | [Name] |
| Target Date | [Date] |
| Status | [Status] |

## History

| Date | Action | Owner |
|------|--------|-------|
| [Date] | [Action] | [Name] |
| [Date] | [Action] | [Name] |
```

---

## BQ.3: Program Management Templates

### BQ.3.1: Management Forms

**File:** `templates-forms/management-forms.md`

```markdown
# Program Management Forms

## 1. Project Charter Template

### 1.1 Template

```markdown
# Project Charter

## 1. Project Overview

| Field | Value |
|-------|-------|
| Project Name | [Name] |
| Project ID | [ID] |
| Sponsor | [Name] |
| Project Manager | [Name] |
| Start Date | [Date] |
| End Date | [Date] |

## 2. Business Case

### 2.1 Problem Statement
[Description]

### 2.2 Objectives
1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

### 2.3 Benefits
1. [Benefit 1]
2. [Benefit 2]
3. [Benefit 3]

## 3. Scope

### 3.1 In Scope
1. [Item 1]
2. [Item 2]
3. [Item 3]

### 3.2 Out of Scope
1. [Item 1]
2. [Item 2]
3. [Item 3]

### 3.3 Deliverables
1. [Deliverable 1]
2. [Deliverable 2]
3. [Deliverable 3]

## 4. Timeline

| Phase | Duration | Start | End | Milestones |
|-------|----------|-------|-----|------------|
| Phase 1 | [Duration] | [Date] | [Date] | [Milestones] |
| Phase 2 | [Duration] | [Date] | [Date] | [Milestones] |

## 5. Budget

| Category | Amount |
|----------|--------|
| Personnel | $[Amount] |
| Tools | $[Amount] |
| Services | $[Amount] |
| Training | $[Amount] |
| Total | $[Amount] |

## 6. Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| [Risk 1] | [Impact] | [%] | [Mitigation] |
| [Risk 2] | [Impact] | [%] | [Mitigation] |

## 7. Approvals

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Sponsor | | | |
| Project Manager | | | |
| CISO | | | |
```

## 2. Status Report Template

### 2.1 Template

```markdown
# Project Status Report

## 1. Executive Summary

| Field | Value |
|-------|-------|
| Project Name | [Name] |
| Reporting Period | [Start - End] |
| Report Date | [Date] |
| Project Manager | [Name] |
| Overall Status | [Green/Yellow/Red] |

## 2. Progress Summary

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Schedule | [%] | [%] | [Status] |
| Budget | [%] | [%] | [Status] |
| Scope | [%] | [%] | [Status] |
| Quality | [Score] | [Score] | [Status] |

## 3. Status by Workstream

| Workstream | Progress | Status | Issues |
|------------|----------|--------|--------|
| [Stream 1] | [%] | [Status] | [Issues] |
| [Stream 2] | [%] | [Status] | [Issues] |

## 4. Risks and Issues

### 4.1 Risks

| Risk | Impact | Probability | Mitigation | Status |
|------|--------|-------------|------------|--------|
| [Risk] | [Impact] | [%] | [Mitigation] | [Status] |

### 4.2 Issues

| Issue | Impact | Resolution | Status |
|-------|--------|------------|--------|
| [Issue] | [Impact] | [Resolution] | [Status] |

## 5. Next Steps

1. [Step 1]
2. [Step 2]
3. [Step 3]

## 6. Approvals

| Role | Name | Date |
|------|------|------|
| Project Manager | | |
| Sponsor | | |
```

---

This concludes Appendix BQ: Complete Security Program Templates and Forms. This comprehensive reference provides the administrative forms, operational forms, and program management templates needed to support the Enterprise Cybersecurity Program.
