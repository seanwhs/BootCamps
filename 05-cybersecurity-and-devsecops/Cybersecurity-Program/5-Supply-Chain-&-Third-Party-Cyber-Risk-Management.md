# Part 5: Supply Chain & Third-Party Cyber Risk Management

## Learning Objectives

By completing this tutorial, you will:

- Assess third-party cyber risks using comprehensive frameworks
- Strengthen supplier security requirements through contractual agreements
- Implement continuous monitoring of vendor exposure
- Improve software supply chain security with SBOM validation
- Build external attack surface management capabilities
- Establish vendor security scorecards and risk ratings
- Develop enforceable security SLAs and compliance requirements
- Manage fourth-party and extended supply chain risks

## Key Concepts & Frameworks

### The Supply Chain Security Challenge

Think of your supply chain like an ecosystem. Your organization is one organism, but you depend on thousands of others—vendors, suppliers, partners, and open-source components. A security weakness in any one of them can spread to you, like a disease spreading through an interconnected ecosystem.

**Key Threats:**
- **Software Supply Chain**: Compromised third-party libraries (e.g., Log4j, SolarWinds)
- **Hardware Supply Chain**: Counterfeit or tampered components
- **Service Providers**: Cloud providers, MSPs with access to your data
- **Fourth-Party Risk**: Your vendors' vendors
- **Data Breaches**: Vendor breaches exposing your data

### Core Frameworks We'll Use

**NIST SP 800-161 (Supply Chain Risk Management)**
- Cyber Supply Chain Risk Management (C-SCRM)
- Tiered risk assessment approach
- Continuous monitoring

**ISO 28000 (Supply Chain Security)**
- Security management systems
- Risk assessment methodology
- Security assurance

**NIST Secure Software Development Framework (SSDF)**
- Software Bill of Materials (SBOM)
- Vulnerability management
- Secure development practices

## Hands-On Implementation

### Step 1: Vendor Risk Assessment Framework

**The Target:** Create a comprehensive vendor risk assessment system with automated scoring and continuous monitoring.

**The Concept:** Vendor risk management is like a credit score for your business partners. You need to evaluate their security posture, assign a risk rating, and monitor them continuously. High-risk vendors need more scrutiny and stronger contractual requirements.

**File:** `05-supply-chain/scripts/vendor_risk_management.py`

```python
#!/usr/bin/env python3
"""
Vendor Risk Management System

This module implements comprehensive vendor risk assessment including:
- Vendor risk scoring and categorization
- Security questionnaire management
- Contractual security requirements
- Continuous monitoring
- Fourth-party risk management
"""

import json
import datetime
import hashlib
import secrets
import csv
from typing import Dict, List, Optional, Any, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum
import os
import re


class RiskCategory(Enum):
    """Vendor risk categories."""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    ACCEPTABLE = "acceptable"


class VendorStatus(Enum):
    """Vendor status in the program."""
    ONBOARDING = "onboarding"
    ACTIVE = "active"
    UNDER_REVIEW = "under_review"
    NON_COMPLIANT = "non_compliant"
    TERMINATED = "terminated"


class AssessmentType(Enum):
    """Types of security assessments."""
    QUESTIONNAIRE = "questionnaire"
    AUDIT = "audit"
    CERTIFICATION = "certification"
    PENETRATION_TEST = "penetration_test"
    SECURITY_SCORE = "security_score"


@dataclass
class Vendor:
    """
    Vendor entity.
    
    Attributes:
        vendor_id: Unique identifier
        name: Vendor name
        description: Vendor description
        category: Risk category
        status: Current status
        tier: Criticality tier (1-4, with 1 being most critical)
        url: Vendor website
        contact: Primary contact
        contract_start: Contract start date
        contract_end: Contract end date
        assessments: List of assessments
        risk_score: Overall risk score (0-100)
        issues: Open issues
        monitored_since: When monitoring started
    """
    vendor_id: str
    name: str
    description: str
    category: str = RiskCategory.MEDIUM.value
    status: str = VendorStatus.ONBOARDING.value
    tier: int = 3  # 1=Critical, 2=High, 3=Medium, 4=Low
    url: str = ""
    contact: str = ""
    contract_start: str = ""
    contract_end: str = ""
    assessments: List[Dict] = field(default_factory=list)
    risk_score: float = 50.0  # Default medium risk
    issues: List[Dict] = field(default_factory=list)
    monitored_since: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat())
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "vendor_id": self.vendor_id,
            "name": self.name,
            "description": self.description,
            "category": self.category,
            "status": self.status,
            "tier": self.tier,
            "url": self.url,
            "contact": self.contact,
            "contract_start": self.contract_start,
            "contract_end": self.contract_end,
            "assessments": self.assessments,
            "risk_score": self.risk_score,
            "issues": self.issues,
            "monitored_since": self.monitored_since,
            "attributes": self.attributes
        }


@dataclass
class SecurityRequirement:
    """
    Security requirement for vendors.
    
    Attributes:
        requirement_id: Unique identifier
        category: Requirement category
        description: Requirement description
        priority: Priority (critical, high, medium, low)
        evidence: Evidence requirement
        standard: Standard reference
        verification: Verification method
    """
    requirement_id: str
    category: str
    description: str
    priority: str = "medium"
    evidence: str = ""
    standard: str = ""
    verification: str = "documentation"
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "requirement_id": self.requirement_id,
            "category": self.category,
            "description": self.description,
            "priority": self.priority,
            "evidence": self.evidence,
            "standard": self.standard,
            "verification": self.verification
        }


class VendorRiskManager:
    """
    Vendor Risk Management System.
    
    This class handles vendor lifecycle, risk assessment,
    security requirements, and continuous monitoring.
    """
    
    def __init__(self, data_dir: str = "./vendor_data"):
        """
        Initialize Vendor Risk Manager.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.vendors: Dict[str, Vendor] = {}
        self.requirements: Dict[str, SecurityRequirement] = {}
        self.audit_log: List[Dict] = []
        
        self._load_data()
        self._load_default_requirements()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/vendors", exist_ok=True)
        os.makedirs(f"{self.data_dir}/requirements", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
        os.makedirs(f"{self.data_dir}/reports", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load vendors
        vendors_dir = f"{self.data_dir}/vendors"
        if os.path.exists(vendors_dir):
            for filename in os.listdir(vendors_dir):
                if filename.endswith('.json'):
                    with open(f"{vendors_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        vendor = Vendor(
                            vendor_id=data['vendor_id'],
                            name=data['name'],
                            description=data.get('description', ''),
                            category=data.get('category', RiskCategory.MEDIUM.value),
                            status=data.get('status', VendorStatus.ACTIVE.value),
                            tier=data.get('tier', 3),
                            url=data.get('url', ''),
                            contact=data.get('contact', ''),
                            contract_start=data.get('contract_start', ''),
                            contract_end=data.get('contract_end', ''),
                            assessments=data.get('assessments', []),
                            risk_score=data.get('risk_score', 50.0),
                            issues=data.get('issues', []),
                            monitored_since=data.get('monitored_since', datetime.datetime.utcnow().isoformat()),
                            attributes=data.get('attributes', {})
                        )
                        self.vendors[vendor.vendor_id] = vendor
        
        # Load requirements
        req_dir = f"{self.data_dir}/requirements"
        if os.path.exists(req_dir):
            for filename in os.listdir(req_dir):
                if filename.endswith('.json'):
                    with open(f"{req_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        req = SecurityRequirement(
                            requirement_id=data['requirement_id'],
                            category=data['category'],
                            description=data['description'],
                            priority=data.get('priority', 'medium'),
                            evidence=data.get('evidence', ''),
                            standard=data.get('standard', ''),
                            verification=data.get('verification', 'documentation')
                        )
                        self.requirements[req.requirement_id] = req
    
    def _load_default_requirements(self) -> None:
        """Load default security requirements."""
        if not self.requirements:
            default_requirements = [
                SecurityRequirement(
                    requirement_id="REQ-001",
                    category="Identity Security",
                    description="Multi-Factor Authentication (MFA) enabled for all administrative access",
                    priority="critical",
                    evidence="Documentation and policy",
                    standard="NIST SP 800-53 IA-2",
                    verification="Documentation review"
                ),
                SecurityRequirement(
                    requirement_id="REQ-002",
                    category="Data Protection",
                    description="Encryption at rest for all sensitive data",
                    priority="critical",
                    evidence="Encryption policy and implementation",
                    standard="NIST SP 800-53 SC-28",
                    verification="Audit verification"
                ),
                SecurityRequirement(
                    requirement_id="REQ-003",
                    category="Data Protection",
                    description="Encryption in transit for all sensitive communications",
                    priority="critical",
                    evidence="TLS/SSL certificate and policy",
                    standard="NIST SP 800-53 SC-8",
                    verification="Penetration testing"
                ),
                SecurityRequirement(
                    requirement_id="REQ-004",
                    category="Access Control",
                    description="Least privilege access control implemented",
                    priority="high",
                    evidence="Access control policy",
                    standard="NIST SP 800-53 AC-6",
                    verification="Documentation review"
                ),
                SecurityRequirement(
                    requirement_id="REQ-005",
                    category="Security Operations",
                    description="Security Information and Event Management (SIEM) in place",
                    priority="high",
                    evidence="SIEM deployment documentation",
                    standard="NIST SP 800-53 SI-4",
                    verification="Architecture review"
                ),
                SecurityRequirement(
                    requirement_id="REQ-006",
                    category="Incident Response",
                    description="Incident response plan documented and tested",
                    priority="critical",
                    evidence="Incident response plan and test results",
                    standard="NIST SP 800-61",
                    verification="Plan review and tabletop exercises"
                ),
                SecurityRequirement(
                    requirement_id="REQ-007",
                    category="Business Continuity",
                    description="Business continuity and disaster recovery plans in place",
                    priority="high",
                    evidence="BCP/DR documentation",
                    standard="NIST SP 800-34",
                    verification="Documentation review"
                ),
                SecurityRequirement(
                    requirement_id="REQ-008",
                    category="Vulnerability Management",
                    description="Regular vulnerability scanning and remediation",
                    priority="high",
                    evidence="Vulnerability management policy and reports",
                    standard="NIST SP 800-53 RA-5",
                    verification="Scan reports review"
                ),
                SecurityRequirement(
                    requirement_id="REQ-009",
                    category="Software Supply Chain",
                    description="Software Bill of Materials (SBOM) maintained",
                    priority="medium",
                    evidence="SBOM documentation",
                    standard="NIST SSDF",
                    verification="Documentation review"
                ),
                SecurityRequirement(
                    requirement_id="REQ-010",
                    category="Third-Party Security",
                    description="Fourth-party risk management program in place",
                    priority="medium",
                    evidence="Fourth-party assessment process",
                    standard="NIST SP 800-161",
                    verification="Process review"
                )
            ]
            
            for req in default_requirements:
                self.requirements[req.requirement_id] = req
                self._save_requirement(req)
    
    def _save_vendor(self, vendor: Vendor) -> None:
        """Save vendor to storage."""
        with open(f"{self.data_dir}/vendors/{vendor.vendor_id}.json", 'w') as f:
            json.dump(vendor.to_dict(), f, indent=2)
    
    def _save_requirement(self, req: SecurityRequirement) -> None:
        """Save requirement to storage."""
        with open(f"{self.data_dir}/requirements/{req.requirement_id}.json", 'w') as f:
            json.dump(req.to_dict(), f, indent=2)
    
    def _log_audit(self, action: str, user_id: str, details: Dict) -> None:
        """Log audit event."""
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "details": details
        }
        self.audit_log.append(log_entry)
        
        with open(f"{self.data_dir}/audit/audit.log", 'a') as f:
            f.write(json.dumps(log_entry) + "\n")
    
    def create_vendor(self, name: str, description: str, url: str = "",
                     contact: str = "", tier: int = 3) -> Vendor:
        """
        Create a new vendor.
        
        Args:
            name: Vendor name
            description: Vendor description
            url: Vendor website
            contact: Primary contact
            tier: Criticality tier (1-4)
            
        Returns:
            Created Vendor
        """
        vendor_id = hashlib.md5(
            f"{name}:{datetime.datetime.utcnow().isoformat()}".encode()
        ).hexdigest()[:12]
        
        vendor = Vendor(
            vendor_id=vendor_id,
            name=name,
            description=description,
            tier=tier,
            url=url,
            contact=contact
        )
        
        # Set category based on tier
        if tier == 1:
            vendor.category = RiskCategory.CRITICAL.value
        elif tier == 2:
            vendor.category = RiskCategory.HIGH.value
        elif tier == 3:
            vendor.category = RiskCategory.MEDIUM.value
        else:
            vendor.category = RiskCategory.LOW.value
        
        self.vendors[vendor_id] = vendor
        self._save_vendor(vendor)
        self._log_audit("VENDOR_CREATED", "system", {
            "vendor_id": vendor_id,
            "name": name,
            "tier": tier
        })
        
        return vendor
    
    def assess_vendor(self, vendor_id: str, assessment_data: Dict) -> Dict:
        """
        Assess a vendor against security requirements.
        
        Args:
            vendor_id: Vendor ID
            assessment_data: Assessment responses
            
        Returns:
            Assessment results
        """
        vendor = self.vendors.get(vendor_id)
        if not vendor:
            return {"error": "Vendor not found"}
        
        # Process assessment responses
        requirements_met = 0
        total_requirements = len(self.requirements)
        issues_found = []
        
        for req_id, req in self.requirements.items():
            response = assessment_data.get(req_id, {})
            status = response.get('status', 'not_assessed')
            evidence = response.get('evidence', '')
            notes = response.get('notes', '')
            
            if status == 'met':
                requirements_met += 1
            elif status == 'not_met':
                issues_found.append({
                    "requirement_id": req_id,
                    "description": req.description,
                    "priority": req.priority,
                    "evidence": evidence,
                    "notes": notes
                })
        
        # Calculate risk score
        # Higher score = better security (more requirements met)
        compliance_percentage = (requirements_met / total_requirements) * 100 if total_requirements > 0 else 0
        
        # Risk score is inverse of compliance (lower risk = higher compliance)
        risk_score = 100 - compliance_percentage
        
        # Adjust risk score for critical requirements
        critical_issues = [i for i in issues_found if i['priority'] == 'critical']
        if critical_issues:
            risk_score += len(critical_issues) * 10
        
        # Cap risk score at 100
        risk_score = min(100, risk_score)
        
        # Update vendor
        vendor.risk_score = risk_score
        vendor.issues = issues_found
        vendor.assessments.append({
            "type": AssessmentType.QUESTIONNAIRE.value,
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "results": {
                "requirements_met": requirements_met,
                "total_requirements": total_requirements,
                "compliance_percentage": compliance_percentage,
                "risk_score": risk_score
            },
            "assessment_data": assessment_data
        })
        
        # Update vendor category based on risk score
        if risk_score < 20:
            vendor.category = RiskCategory.ACCEPTABLE.value
        elif risk_score < 40:
            vendor.category = RiskCategory.LOW.value
        elif risk_score < 60:
            vendor.category = RiskCategory.MEDIUM.value
        elif risk_score < 80:
            vendor.category = RiskCategory.HIGH.value
        else:
            vendor.category = RiskCategory.CRITICAL.value
        
        self._save_vendor(vendor)
        
        self._log_audit("VENDOR_ASSESSED", "system", {
            "vendor_id": vendor_id,
            "risk_score": risk_score,
            "category": vendor.category,
            "issues": len(issues_found)
        })
        
        return {
            "vendor_id": vendor_id,
            "risk_score": risk_score,
            "category": vendor.category,
            "compliance_percentage": compliance_percentage,
            "requirements_met": requirements_met,
            "total_requirements": total_requirements,
            "critical_issues": len([i for i in issues_found if i['priority'] == 'critical']),
            "issues": issues_found
        }
    
    def generate_security_scorecard(self, vendor_id: str) -> Dict:
        """
        Generate a security scorecard for a vendor.
        
        Args:
            vendor_id: Vendor ID
            
        Returns:
            Security scorecard
        """
        vendor = self.vendors.get(vendor_id)
        if not vendor:
            return {"error": "Vendor not found"}
        
        scorecard = {
            "vendor_id": vendor.vendor_id,
            "name": vendor.name,
            "overall_risk": vendor.risk_score,
            "category": vendor.category,
            "tier": vendor.tier,
            "status": vendor.status,
            "total_issues": len(vendor.issues),
            "critical_issues": len([i for i in vendor.issues if i['priority'] == 'critical']),
            "assessments_count": len(vendor.assessments),
            "last_assessment": vendor.assessments[-1]['timestamp'] if vendor.assessments else None,
            "score_breakdown": {
                "identity_security": self._score_category(vendor, "Identity Security"),
                "data_protection": self._score_category(vendor, "Data Protection"),
                "access_control": self._score_category(vendor, "Access Control"),
                "security_operations": self._score_category(vendor, "Security Operations"),
                "incident_response": self._score_category(vendor, "Incident Response"),
                "business_continuity": self._score_category(vendor, "Business Continuity"),
                "vulnerability_management": self._score_category(vendor, "Vulnerability Management"),
                "software_supply_chain": self._score_category(vendor, "Software Supply Chain"),
                "third_party_security": self._score_category(vendor, "Third-Party Security")
            },
            "critical_issues_detail": [
                {
                    "requirement": i['description'],
                    "notes": i.get('notes', '')
                }
                for i in vendor.issues if i['priority'] == 'critical'
            ],
            "recommendations": self._generate_recommendations(vendor)
        }
        
        return scorecard
    
    def _score_category(self, vendor: Vendor, category: str) -> int:
        """
        Score a specific security category.
        
        Args:
            vendor: Vendor
            category: Category name
            
        Returns:
            Score (0-100)
        """
        # Find requirements in this category
        category_requirements = [
            req for req in self.requirements.values()
            if req.category == category
        ]
        
        if not category_requirements:
            return 0
        
        # Check which requirements are met
        met = 0
        for req in category_requirements:
            # Check if this requirement has an issue
            has_issue = any(
                i['requirement_id'] == req.requirement_id
                for i in vendor.issues
            )
            if not has_issue:
                met += 1
        
        return int((met / len(category_requirements)) * 100) if category_requirements else 0
    
    def _generate_recommendations(self, vendor: Vendor) -> List[str]:
        """
        Generate recommendations for a vendor.
        
        Args:
            vendor: Vendor
            
        Returns:
            List of recommendations
        """
        recommendations = []
        
        # Prioritize based on tier
        if vendor.tier <= 2:  # Critical or High
            recommendations.append("Priority vendor - implement enhanced monitoring")
        
        if vendor.risk_score > 70:
            recommendations.append("High risk vendor - require immediate remediation plan")
            recommendations.append("Consider risk acceptance approval")
        
        # Specific recommendations based on issues
        for issue in vendor.issues[:5]:  # Top 5 issues
            recommendations.append(f"Address: {issue['description']}")
        
        if len(vendor.issues) > 10:
            recommendations.append("Significant security gaps - consider offboarding")
        
        if vendor.assessments and len(vendor.assessments) == 0:
            recommendations.append("No assessments performed - schedule assessment")
        
        return recommendations
    
    def monitor_vendor(self, vendor_id: str) -> Dict:
        """
        Perform continuous monitoring of a vendor.
        
        Args:
            vendor_id: Vendor ID
            
        Returns:
            Monitoring results
        """
        vendor = self.vendors.get(vendor_id)
        if not vendor:
            return {"error": "Vendor not found"}
        
        # Simulate monitoring checks
        checks = {
            "breach_alert": False,  # Check if vendor has had a breach
            "security_score_change": 0,  # Change in security score
            "new_issues": 0,
            "compliance_verified": True
        }
        
        # Simulate detection of new issues
        import random
        if random.random() < 0.3:  # 30% chance of finding something
            new_issue = {
                "id": f"ISSUE-{datetime.datetime.utcnow().strftime('%Y%m%d')}-{secrets.token_hex(4)}",
                "description": f"New compliance gap detected: {random.choice(['Missing patch', 'Outdated certificate', 'Unverified vendor'])}",
                "severity": random.choice(['low', 'medium', 'high']),
                "timestamp": datetime.datetime.utcnow().isoformat()
            }
            vendor.issues.append(new_issue)
            checks['new_issues'] = 1
            checks['new_issue_detail'] = new_issue
        
        # Update risk score based on monitoring
        if vendor.issues:
            issue_penalty = min(20, len(vendor.issues) * 2)
            vendor.risk_score = min(100, vendor.risk_score + issue_penalty)
        
        # Save updates
        self._save_vendor(vendor)
        
        self._log_audit("VENDOR_MONITORED", "system", {
            "vendor_id": vendor_id,
            "new_issues": checks['new_issues']
        })
        
        return {
            "vendor_id": vendor_id,
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "status": vendor.status,
            "risk_score": vendor.risk_score,
            "checks": checks
        }
    
    def generate_contract_requirements(self, vendor_id: str) -> Dict:
        """
        Generate contractual security requirements for a vendor.
        
        Args:
            vendor_id: Vendor ID
            
        Returns:
            Contract requirements
        """
        vendor = self.vendors.get(vendor_id)
        if not vendor:
            return {"error": "Vendor not found"}
        
        # Determine required contract clauses based on tier and risk
        contract_clauses = {
            "base_requirements": [
                "Vendor agrees to comply with [Organization]'s Information Security Policy",
                "Vendor must maintain adequate security controls",
                "Vendor must notify within 24 hours of any security incident",
                "Vendor must provide annual security assessments",
                "Vendor must allow security audits upon request"
            ],
            "additional_requirements": [],
            "special_requirements": []
        }
        
        # Add requirements based on tier
        if vendor.tier <= 2:
            contract_clauses["additional_requirements"].extend([
                "MFA required for all administrative access",
                "Dedicated security personnel assigned",
                "Quarterly vulnerability scans",
                "SIEM integration with [Organization]"
            ])
        
        if vendor.tier == 1:
            contract_clauses["special_requirements"].extend([
                "Dedicated security incident response process",
                "Cybersecurity insurance ($5M minimum)",
                "Third-party penetration testing annually",
                "Full access to security logs",
                "SBOM submission quarterly"
            ])
        
        if vendor.risk_score > 70:
            contract_clauses["additional_requirements"].append(
                "Risk mitigation plan required and approved"
            )
        
        # Add data handling requirements
        if vendor.attributes.get('handles_sensitive_data', False):
            contract_clauses["additional_requirements"].extend([
                "Data encryption at rest required",
                "Data classification and handling procedures",
                "Data breach notification within 24 hours",
                "Data deletion upon contract termination"
            ])
        
        return {
            "vendor_id": vendor_id,
            "vendor_name": vendor.name,
            "tier": vendor.tier,
            "risk_category": vendor.category,
            "contract_clauses": contract_clauses,
            "effective_date": datetime.datetime.utcnow().isoformat(),
            "next_review": (datetime.datetime.utcnow() + datetime.timedelta(days=365)).isoformat()
        }
    
    def generate_risk_report(self) -> str:
        """
        Generate vendor risk report.
        
        Returns:
            Markdown formatted report
        """
        total_vendors = len(self.vendors)
        
        # Statistics
        by_category = {}
        by_status = {}
        by_tier = {}
        total_issues = 0
        critical_issues = 0
        
        for vendor in self.vendors.values():
            by_category[vendor.category] = by_category.get(vendor.category, 0) + 1
            by_status[vendor.status] = by_status.get(vendor.status, 0) + 1
            by_tier[vendor.tier] = by_tier.get(vendor.tier, 0) + 1
            total_issues += len(vendor.issues)
            critical_issues += len([i for i in vendor.issues if i['priority'] == 'critical'])
        
        # Average risk score
        avg_risk = sum(v.risk_score for v in self.vendors.values()) / total_vendors if total_vendors > 0 else 0
        
        report = f"""
# Vendor Risk Management Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Vendors | {total_vendors} |
| Average Risk Score | {avg_risk:.1f} |
| Total Open Issues | {total_issues} |
| Critical Issues | {critical_issues} |

## Vendor Risk Distribution

| Category | Count |
|----------|-------|
"""
        
        for category, count in sorted(by_category.items()):
            report += f"| {category} | {count} |\n"
        
        report += """
## Vendor Status

| Status | Count |
|--------|-------|
"""
        
        for status, count in sorted(by_status.items()):
            report += f"| {status} | {count} |\n"
        
        report += """
## Vendors by Tier

| Tier | Count |
|------|-------|
"""
        
        for tier, count in sorted(by_tier.items()):
            report += f"| {tier} | {count} |\n"
        
        report += """
## High-Risk Vendors

| Vendor | Risk Score | Tier | Issues |
|--------|------------|------|--------|
"""
        
        high_risk = [v for v in self.vendors.values() if v.risk_score > 70]
        for vendor in sorted(high_risk, key=lambda v: v.risk_score, reverse=True)[:10]:
            report += f"| {vendor.name} | {vendor.risk_score:.1f} | {vendor.tier} | {len(vendor.issues)} |\n"
        
        if not high_risk:
            report += "| *No high-risk vendors* | | | |\n"
        
        return report


def main():
    """CLI for vendor risk management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Vendor Risk Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Create vendor
    create_parser = subparsers.add_parser('create', help='Create vendor')
    create_parser.add_argument('--name', '-n', required=True, help='Vendor name')
    create_parser.add_argument('--description', '-d', required=True, help='Vendor description')
    create_parser.add_argument('--tier', '-t', type=int, default=3, help='Vendor tier (1-4)')
    create_parser.add_argument('--url', '-u', help='Vendor URL')
    create_parser.add_argument('--contact', '-c', help='Contact information')
    
    # Assess vendor
    assess_parser = subparsers.add_parser('assess', help='Assess vendor')
    assess_parser.add_argument('--vendor', '-v', required=True, help='Vendor ID')
    assess_parser.add_argument('--responses', '-r', help='Assessment responses JSON file')
    
    # Scorecard
    scorecard_parser = subparsers.add_parser('scorecard', help='Generate scorecard')
    scorecard_parser.add_argument('--vendor', '-v', required=True, help='Vendor ID')
    
    # Monitor
    monitor_parser = subparsers.add_parser('monitor', help='Monitor vendor')
    monitor_parser.add_argument('--vendor', '-v', required=True, help='Vendor ID')
    
    # Contract requirements
    contract_parser = subparsers.add_parser('contract', help='Generate contract requirements')
    contract_parser.add_argument('--vendor', '-v', required=True, help='Vendor ID')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    # List vendors
    list_parser = subparsers.add_parser('list', help='List vendors')
    
    args = parser.parse_args()
    
    manager = VendorRiskManager()
    
    if args.command == 'create':
        vendor = manager.create_vendor(
            args.name,
            args.description,
            args.url or '',
            args.contact or '',
            args.tier
        )
        print(f"✅ Vendor created: {vendor.vendor_id}")
        print(f"   Name: {vendor.name}")
        print(f"   Tier: {vendor.tier}")
        print(f"   Category: {vendor.category}")
    
    elif args.command == 'assess':
        if args.responses:
            with open(args.responses, 'r') as f:
                responses = json.load(f)
        else:
            # Interactive assessment
            responses = {}
            print("\nVendor Security Assessment")
            print("=" * 50)
            print("Enter status for each requirement (met/not_met/partial/not_assessed):")
            
            for req_id, req in manager.requirements.items():
                print(f"\n{req_id}: {req.description}")
                print(f"  Priority: {req.priority}")
                status = input("  Status: ").strip().lower()
                if status not in ['met', 'not_met', 'partial', 'not_assessed']:
                    status = 'not_assessed'
                
                responses[req_id] = {
                    'status': status,
                    'evidence': input("  Evidence: ").strip(),
                    'notes': input("  Notes: ").strip()
                }
        
        results = manager.assess_vendor(args.vendor, responses)
        if 'error' in results:
            print(f"❌ {results['error']}")
        else:
            print(f"✅ Assessment complete")
            print(f"   Risk Score: {results['risk_score']:.1f}")
            print(f"   Category: {results['category']}")
            print(f"   Compliance: {results['compliance_percentage']:.1f}%")
            print(f"   Issues: {len(results['issues'])}")
            if results['issues']:
                print("\n   Issues:")
                for issue in results['issues'][:5]:
                    print(f"     - {issue['description']} ({issue['priority']})")
    
    elif args.command == 'scorecard':
        scorecard = manager.generate_security_scorecard(args.vendor)
        if 'error' in scorecard:
            print(f"❌ {scorecard['error']}")
        else:
            print(f"\nSecurity Scorecard: {scorecard['name']}")
            print("=" * 60)
            print(f"Overall Risk: {scorecard['overall_risk']:.1f}")
            print(f"Category: {scorecard['category']}")
            print(f"Status: {scorecard['status']}")
            print(f"Total Issues: {scorecard['total_issues']}")
            print(f"Critical Issues: {scorecard['critical_issues']}")
            
            print("\nScore Breakdown:")
            for category, score in scorecard['score_breakdown'].items():
                print(f"  {category}: {score}%")
            
            if scorecard['recommendations']:
                print("\nRecommendations:")
                for rec in scorecard['recommendations']:
                    print(f"  - {rec}")
    
    elif args.command == 'monitor':
        results = manager.monitor_vendor(args.vendor)
        if 'error' in results:
            print(f"❌ {results['error']}")
        else:
            print(f"✅ Monitoring complete")
            print(f"   Vendor: {args.vendor}")
            print(f"   Risk Score: {results['risk_score']:.1f}")
            print(f"   Status: {results['status']}")
            if results['checks']['new_issues'] > 0:
                print(f"   ⚠️ New issues detected!")
                print(f"      {results['checks'].get('new_issue_detail', {}).get('description', '')}")
    
    elif args.command == 'contract':
        contract = manager.generate_contract_requirements(args.vendor)
        if 'error' in contract:
            print(f"❌ {contract['error']}")
        else:
            print(f"\nContract Requirements: {contract['vendor_name']}")
            print("=" * 60)
            print(f"Tier: {contract['tier']}")
            print(f"Risk Category: {contract['risk_category']}")
            
            print("\nBase Requirements:")
            for clause in contract['contract_clauses']['base_requirements']:
                print(f"  - {clause}")
            
            if contract['contract_clauses']['additional_requirements']:
                print("\nAdditional Requirements:")
                for clause in contract['contract_clauses']['additional_requirements']:
                    print(f"  - {clause}")
            
            if contract['contract_clauses']['special_requirements']:
                print("\nSpecial Requirements:")
                for clause in contract['contract_clauses']['special_requirements']:
                    print(f"  - {clause}")
    
    elif args.command == 'report':
        report = manager.generate_risk_report()
        print(report)
    
    elif args.command == 'list':
        print("\nVendors:")
        print("=" * 80)
        for vendor in sorted(manager.vendors.values(), key=lambda v: v.risk_score, reverse=True):
            status_icon = {
                VendorStatus.ONBOARDING.value: "🔵",
                VendorStatus.ACTIVE.value: "🟢",
                VendorStatus.UNDER_REVIEW.value: "🟠",
                VendorStatus.NON_COMPLIANT.value: "🔴",
                VendorStatus.TERMINATED.value: "⚪"
            }.get(vendor.status, "⚪")
            
            print(f"{status_icon} {vendor.vendor_id}: {vendor.name}")
            print(f"   Risk: {vendor.risk_score:.1f} | Tier: {vendor.tier} | Category: {vendor.category}")
            print(f"   Issues: {len(vendor.issues)} | Status: {vendor.status}")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

### Step 2: SBOM (Software Bill of Materials) Management

**The Target:** Create an SBOM management system for tracking and analyzing software dependencies.

**The Concept:** SBOM is like an ingredient list for your software. Just as food labels list ingredients, an SBOM lists all the components, libraries, and dependencies in your software. This is critical for identifying vulnerable components (like Log4j) that could compromise your entire system.

**File:** `05-supply-chain/scripts/sbom_manager.py`

```python
#!/usr/bin/env python3
"""
Software Bill of Materials (SBOM) Management System

This module implements SBOM management including:
- SBOM generation and validation
- Vulnerability scanning
- Dependency tracking
- Compliance reporting
- Lifecycle management
"""

import json
import datetime
import hashlib
from typing import Dict, List, Optional, Any, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum
import os
import re
import csv


class SBOMFormat(Enum):
    """Supported SBOM formats."""
    SPDX = "spdx"
    CYCLONEDX = "cyclonedx"
    SWID = "swid"


class ComponentStatus(Enum):
    """Status of a software component."""
    ACTIVE = "active"
    DEPRECATED = "deprecated"
    END_OF_LIFE = "end_of_life"
    VULNERABLE = "vulnerable"
    REMOVED = "removed"


@dataclass
class SoftwareComponent:
    """
    Software component in SBOM.
    
    Attributes:
        component_id: Unique identifier
        name: Component name
        version: Component version
        vendor: Component vendor
        description: Component description
        status: Current status
        vulnerabilities: List of vulnerabilities
        licenses: List of licenses
        dependencies: List of dependency IDs
        purl: Package URL
        cpe: Common Platform Enumeration
        checksum: Component checksum
        metadata: Additional metadata
    """
    component_id: str
    name: str
    version: str
    vendor: str
    description: str = ""
    status: str = ComponentStatus.ACTIVE.value
    vulnerabilities: List[Dict] = field(default_factory=list)
    licenses: List[str] = field(default_factory=list)
    dependencies: List[str] = field(default_factory=list)
    purl: str = ""
    cpe: str = ""
    checksum: str = ""
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "component_id": self.component_id,
            "name": self.name,
            "version": self.version,
            "vendor": self.vendor,
            "description": self.description,
            "status": self.status,
            "vulnerabilities": self.vulnerabilities,
            "licenses": self.licenses,
            "dependencies": self.dependencies,
            "purl": self.purl,
            "cpe": self.cpe,
            "checksum": self.checksum,
            "metadata": self.metadata
        }


@dataclass
class SBOM:
    """
    Software Bill of Materials.
    
    Attributes:
        sbom_id: Unique identifier
        name: SBOM name
        version: SBOM version
        format: SBOM format
        created: Creation timestamp
        updated: Last update timestamp
        components: List of components
        relationships: Component relationships
        metadata: Additional metadata
    """
    sbom_id: str
    name: str
    version: str
    format: str = SBOMFormat.SPDX.value
    created: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat())
    updated: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat())
    components: List[SoftwareComponent] = field(default_factory=list)
    relationships: List[Dict] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "sbom_id": self.sbom_id,
            "name": self.name,
            "version": self.version,
            "format": self.format,
            "created": self.created,
            "updated": self.updated,
            "components": [c.to_dict() for c in self.components],
            "relationships": self.relationships,
            "metadata": self.metadata
        }


class SBOMManager:
    """
    SBOM Management System.
    
    This class handles SBOM generation, validation, vulnerability
    scanning, and compliance reporting.
    """
    
    def __init__(self, data_dir: str = "./sbom_data"):
        """
        Initialize SBOM Manager.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.sboms: Dict[str, SBOM] = {}
        self.vulnerability_db: Dict[str, List[Dict]] = {}
        self.audit_log: List[Dict] = []
        
        self._load_data()
        self._load_vulnerability_db()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/sboms", exist_ok=True)
        os.makedirs(f"{self.data_dir}/vulnerabilities", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load SBOMs
        sbom_dir = f"{self.data_dir}/sboms"
        if os.path.exists(sbom_dir):
            for filename in os.listdir(sbom_dir):
                if filename.endswith('.json'):
                    with open(f"{sbom_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        components = []
                        for comp_data in data.get('components', []):
                            comp = SoftwareComponent(
                                component_id=comp_data['component_id'],
                                name=comp_data['name'],
                                version=comp_data['version'],
                                vendor=comp_data['vendor'],
                                description=comp_data.get('description', ''),
                                status=comp_data.get('status', ComponentStatus.ACTIVE.value),
                                vulnerabilities=comp_data.get('vulnerabilities', []),
                                licenses=comp_data.get('licenses', []),
                                dependencies=comp_data.get('dependencies', []),
                                purl=comp_data.get('purl', ''),
                                cpe=comp_data.get('cpe', ''),
                                checksum=comp_data.get('checksum', ''),
                                metadata=comp_data.get('metadata', {})
                            )
                            components.append(comp)
                        
                        sbom = SBOM(
                            sbom_id=data['sbom_id'],
                            name=data['name'],
                            version=data['version'],
                            format=data.get('format', SBOMFormat.SPDX.value),
                            created=data.get('created', datetime.datetime.utcnow().isoformat()),
                            updated=data.get('updated', datetime.datetime.utcnow().isoformat()),
                            components=components,
                            relationships=data.get('relationships', []),
                            metadata=data.get('metadata', {})
                        )
                        self.sboms[sbom.sbom_id] = sbom
    
    def _load_vulnerability_db(self) -> None:
        """Load vulnerability database."""
        # Sample vulnerability database (in production, this would be a feed from NVD, etc.)
        self.vulnerability_db = {
            "log4j-core": [
                {
                    "cve_id": "CVE-2021-44228",
                    "description": "Apache Log4j2 JNDI features do not protect against attacker controlled JNDI lookup patterns",
                    "cvss_score": 10.0,
                    "affected_versions": ["2.0-2.14.1"],
                    "fixed_version": "2.15.0",
                    "published": "2021-12-10"
                }
            ],
            "spring-boot": [
                {
                    "cve_id": "CVE-2022-22965",
                    "description": "Spring Framework RCE via Data Binding on JDK 9+",
                    "cvss_score": 9.8,
                    "affected_versions": ["5.3.0-5.3.17", "5.2.0-5.2.19"],
                    "fixed_version": "5.3.18",
                    "published": "2022-03-31"
                }
            ],
            "openssl": [
                {
                    "cve_id": "CVE-2022-0778",
                    "description": "Infinite loop in BN_mod_sqrt() reachable when parsing certificates",
                    "cvss_score": 7.5,
                    "affected_versions": ["1.0.2-1.0.2zc", "1.1.1-1.1.1n"],
                    "fixed_version": "1.1.1o",
                    "published": "2022-03-15"
                }
            ],
            "tomcat": [
                {
                    "cve_id": "CVE-2022-23181",
                    "description": "Apache Tomcat Path traversal vulnerability",
                    "cvss_score": 6.8,
                    "affected_versions": ["9.0.0-9.0.56", "8.5.0-8.5.72"],
                    "fixed_version": "9.0.57",
                    "published": "2022-02-07"
                }
            ]
        }
    
    def _log_audit(self, action: str, user_id: str, details: Dict) -> None:
        """Log audit event."""
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "details": details
        }
        self.audit_log.append(log_entry)
        
        with open(f"{self.data_dir}/audit/audit.log", 'a') as f:
            f.write(json.dumps(log_entry) + "\n")
    
    def create_sbom(self, name: str, version: str, format: str = SBOMFormat.SPDX.value) -> SBOM:
        """
        Create a new SBOM.
        
        Args:
            name: SBOM name
            version: SBOM version
            format: SBOM format
            
        Returns:
            Created SBOM
        """
        sbom_id = hashlib.md5(
            f"{name}:{version}:{datetime.datetime.utcnow().isoformat()}".encode()
        ).hexdigest()[:12]
        
        sbom = SBOM(
            sbom_id=sbom_id,
            name=name,
            version=version,
            format=format
        )
        
        self.sboms[sbom_id] = sbom
        self._save_sbom(sbom)
        self._log_audit("SBOM_CREATED", "system", {
            "sbom_id": sbom_id,
            "name": name,
            "version": version
        })
        
        return sbom
    
    def _save_sbom(self, sbom: SBOM) -> None:
        """Save SBOM to storage."""
        with open(f"{self.data_dir}/sboms/{sbom.sbom_id}.json", 'w') as f:
            json.dump(sbom.to_dict(), f, indent=2)
    
    def add_component(self, sbom_id: str, name: str, version: str, vendor: str,
                     description: str = "", licenses: List[str] = None,
                     dependencies: List[str] = None) -> Optional[SoftwareComponent]:
        """
        Add a component to an SBOM.
        
        Args:
            sbom_id: SBOM ID
            name: Component name
            version: Component version
            vendor: Component vendor
            description: Component description
            licenses: List of licenses
            dependencies: List of dependency IDs
            
        Returns:
            Created SoftwareComponent or None
        """
        sbom = self.sboms.get(sbom_id)
        if not sbom:
            return None
        
        component_id = hashlib.md5(
            f"{name}:{version}:{vendor}".encode()
        ).hexdigest()[:12]
        
        component = SoftwareComponent(
            component_id=component_id,
            name=name,
            version=version,
            vendor=vendor,
            description=description,
            licenses=licenses or [],
            dependencies=dependencies or []
        )
        
        # Check if component already exists
        existing = next((c for c in sbom.components if c.component_id == component_id), None)
        if existing:
            # Update existing
            existing.version = version
            existing.licenses = licenses or existing.licenses
            existing.dependencies = dependencies or existing.dependencies
        else:
            sbom.components.append(component)
        
        # Update SBOM
        sbom.updated = datetime.datetime.utcnow().isoformat()
        self._save_sbom(sbom)
        
        self._log_audit("COMPONENT_ADDED", "system", {
            "sbom_id": sbom_id,
            "component_id": component_id,
            "name": name,
            "version": version
        })
        
        return component
    
    def scan_vulnerabilities(self, sbom_id: str) -> Dict:
        """
        Scan SBOM for vulnerabilities.
        
        Args:
            sbom_id: SBOM ID
            
        Returns:
            Scan results
        """
        sbom = self.sboms.get(sbom_id)
        if not sbom:
            return {"error": "SBOM not found"}
        
        vulnerabilities_found = []
        total_components = len(sbom.components)
        vulnerable_components = 0
        
        for component in sbom.components:
            # Check if component has known vulnerabilities
            if component.name in self.vulnerability_db:
                for vuln in self.vulnerability_db[component.name]:
                    # Check if version is affected
                    for affected_range in vuln['affected_versions']:
                        if self._version_matches(component.version, affected_range):
                            vuln_info = vuln.copy()
                            vuln_info['component'] = component.name
                            vuln_info['component_version'] = component.version
                            vulnerabilities_found.append(vuln_info)
                            component.vulnerabilities.append(vuln_info)
                            vulnerable_components += 1
                            break
        
        # Update SBOM
        sbom.updated = datetime.datetime.utcnow().isoformat()
        self._save_sbom(sbom)
        
        return {
            "sbom_id": sbom_id,
            "total_components": total_components,
            "vulnerable_components": vulnerable_components,
            "total_vulnerabilities": len(vulnerabilities_found),
            "vulnerabilities": vulnerabilities_found,
            "scan_timestamp": datetime.datetime.utcnow().isoformat()
        }
    
    def _version_matches(self, version: str, version_range: str) -> bool:
        """
        Check if a version matches a version range.
        
        Args:
            version: Version string
            version_range: Version range (e.g., "2.0-2.14.1")
            
        Returns:
            True if version matches range
        """
        # Simple version comparison (in production, use semantic versioning)
        try:
            # Split range
            if '-' in version_range:
                start_ver, end_ver = version_range.split('-')
                
                # Parse versions as tuple of integers
                def parse_version(v):
                    return tuple(int(x) for x in v.split('.'))
                
                start_tuple = parse_version(start_ver)
                end_tuple = parse_version(end_ver)
                version_tuple = parse_version(version)
                
                return start_tuple <= version_tuple <= end_tuple
            else:
                return version == version_range
        except (ValueError, AttributeError):
            # If parsing fails, do simple string match
            return version in version_range
    
    def generate_sbom_report(self, sbom_id: str) -> str:
        """
        Generate SBOM report.
        
        Args:
            sbom_id: SBOM ID
            
        Returns:
            Markdown formatted report
        """
        sbom = self.sboms.get(sbom_id)
        if not sbom:
            return "SBOM not found"
        
        # Scan for vulnerabilities if not already scanned
        if not any(c.vulnerabilities for c in sbom.components):
            self.scan_vulnerabilities(sbom_id)
        
        report = f"""
# SBOM Report: {sbom.name} v{sbom.version}
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## SBOM Information

| Property | Value |
|----------|-------|
| SBOM ID | {sbom.sbom_id} |
| Name | {sbom.name} |
| Version | {sbom.version} |
| Format | {sbom.format} |
| Created | {sbom.created[:16]} |
| Updated | {sbom.updated[:16]} |
| Components | {len(sbom.components)} |

## Component Summary

| Type | Count |
|------|-------|
| Total Components | {len(sbom.components)} |
| Vulnerable Components | {len([c for c in sbom.components if c.vulnerabilities])} |
| Unique Vendors | {len(set(c.vendor for c in sbom.components))} |

## Vulnerabilities

| Component | Version | CVE ID | CVSS Score | Severity |
|-----------|---------|--------|------------|----------|
"""
        
        vulnerabilities_found = []
        for component in sbom.components:
            for vuln in component.vulnerabilities:
                vulnerabilities_found.append((component, vuln))
        
        if vulnerabilities_found:
            for component, vuln in sorted(vulnerabilities_found, key=lambda x: x[1]['cvss_score'], reverse=True):
                severity = "CRITICAL" if vuln['cvss_score'] >= 9.0 else "HIGH" if vuln['cvss_score'] >= 7.0 else "MEDIUM"
                report += f"| {component.name} | {component.version} | {vuln['cve_id']} | {vuln['cvss_score']} | {severity} |\n"
        else:
            report += "| *No vulnerabilities found* | | | | |\n"
        
        # Component dependencies
        report += """
## Component Dependencies

| Component | Version | Dependencies |
|-----------|---------|--------------|
"""
        
        for component in sbom.components:
            deps = []
            for dep_id in component.dependencies:
                dep = next((c for c in sbom.components if c.component_id == dep_id), None)
                if dep:
                    deps.append(f"{dep.name} v{dep.version}")
            report += f"| {component.name} | {component.version} | {', '.join(deps) if deps else 'None'} |\n"
        
        return report
    
    def compare_sboms(self, sbom1_id: str, sbom2_id: str) -> Dict:
        """
        Compare two SBOMs and identify differences.
        
        Args:
            sbom1_id: First SBOM ID
            sbom2_id: Second SBOM ID
            
        Returns:
            Comparison results
        """
        sbom1 = self.sboms.get(sbom1_id)
        sbom2 = self.sboms.get(sbom2_id)
        
        if not sbom1 or not sbom2:
            return {"error": "One or both SBOMs not found"}
        
        components1 = {c.component_id: c for c in sbom1.components}
        components2 = {c.component_id: c for c in sbom2.components}
        
        added = []
        removed = []
        version_changed = []
        
        # Find additions
        for comp_id, comp in components2.items():
            if comp_id not in components1:
                added.append(comp)
        
        # Find removals
        for comp_id, comp in components1.items():
            if comp_id not in components2:
                removed.append(comp)
        
        # Find version changes
        for comp_id, comp1 in components1.items():
            if comp_id in components2:
                comp2 = components2[comp_id]
                if comp1.version != comp2.version:
                    version_changed.append({
                        "name": comp1.name,
                        "old_version": comp1.version,
                        "new_version": comp2.version
                    })
        
        return {
            "sbom1": sbom1.name,
            "sbom2": sbom2.name,
            "components_added": len(added),
            "components_removed": len(removed),
            "components_version_changed": len(version_changed),
            "added": [c.to_dict() for c in added],
            "removed": [c.to_dict() for c in removed],
            "version_changed": version_changed
        }


def main():
    """CLI for SBOM management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='SBOM Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Create SBOM
    create_parser = subparsers.add_parser('create', help='Create SBOM')
    create_parser.add_argument('--name', '-n', required=True, help='SBOM name')
    create_parser.add_argument('--version', '-v', required=True, help='SBOM version')
    
    # Add component
    add_parser = subparsers.add_parser('add', help='Add component')
    add_parser.add_argument('--sbom', '-s', required=True, help='SBOM ID')
    add_parser.add_argument('--name', '-n', required=True, help='Component name')
    add_parser.add_argument('--version', '-v', required=True, help='Component version')
    add_parser.add_argument('--vendor', '-r', required=True, help='Component vendor')
    add_parser.add_argument('--description', '-d', help='Component description')
    add_parser.add_argument('--licenses', '-l', nargs='+', help='Component licenses')
    add_parser.add_argument('--dependencies', '-p', nargs='+', help='Dependency IDs')
    
    # Scan vulnerabilities
    scan_parser = subparsers.add_parser('scan', help='Scan for vulnerabilities')
    scan_parser.add_argument('--sbom', '-s', required=True, help='SBOM ID')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate SBOM report')
    report_parser.add_argument('--sbom', '-s', required=True, help='SBOM ID')
    report_parser.add_argument('--output', '-o', help='Output file')
    
    # Compare
    compare_parser = subparsers.add_parser('compare', help='Compare SBOMs')
    compare_parser.add_argument('--sbom1', '-a', required=True, help='First SBOM ID')
    compare_parser.add_argument('--sbom2', '-b', required=True, help='Second SBOM ID')
    
    # List
    list_parser = subparsers.add_parser('list', help='List SBOMs')
    
    args = parser.parse_args()
    
    manager = SBOMManager()
    
    if args.command == 'create':
        sbom = manager.create_sbom(args.name, args.version)
        print(f"✅ SBOM created: {sbom.sbom_id}")
        print(f"   Name: {sbom.name}")
        print(f"   Version: {sbom.version}")
    
    elif args.command == 'add':
        component = manager.add_component(
            args.sbom,
            args.name,
            args.version,
            args.vendor,
            args.description or '',
            args.licenses,
            args.dependencies
        )
        if component:
            print(f"✅ Component added: {component.component_id}")
            print(f"   Name: {component.name}")
            print(f"   Version: {component.version}")
        else:
            print("❌ SBOM not found")
    
    elif args.command == 'scan':
        results = manager.scan_vulnerabilities(args.sbom)
        if 'error' in results:
            print(f"❌ {results['error']}")
        else:
            print(f"✅ Vulnerability scan complete")
            print(f"   Total Components: {results['total_components']}")
            print(f"   Vulnerable Components: {results['vulnerable_components']}")
            print(f"   Total Vulnerabilities: {results['total_vulnerabilities']}")
            
            if results['vulnerabilities']:
                print("\n   Vulnerabilities:")
                for vuln in results['vulnerabilities'][:10]:
                    print(f"     - {vuln['cve_id']}: {vuln['component']} v{vuln['component_version']} (CVSS: {vuln['cvss_score']})")
    
    elif args.command == 'report':
        report = manager.generate_sbom_report(args.sbom)
        if args.output:
            with open(args.output, 'w') as f:
                f.write(report)
            print(f"✅ Report saved to {args.output}")
        else:
            print(report)
    
    elif args.command == 'compare':
        results = manager.compare_sboms(args.sbom1, args.sbom2)
        if 'error' in results:
            print(f"❌ {results['error']}")
        else:
            print(f"\nSBOM Comparison: {results['sbom1']} vs {results['sbom2']}")
            print("=" * 60)
            print(f"Components Added: {results['components_added']}")
            print(f"Components Removed: {results['components_removed']}")
            print(f"Versions Changed: {results['components_version_changed']}")
            
            if results['version_changed']:
                print("\nVersion Changes:")
                for change in results['version_changed']:
                    print(f"  {change['name']}: {change['old_version']} -> {change['new_version']}")
    
    elif args.command == 'list':
        print("\nSBOMs:")
        print("=" * 60)
        for sbom in manager.sboms.values():
            print(f"{sbom.sbom_id}: {sbom.name} v{sbom.version}")
            print(f"  Components: {len(sbom.components)} | Created: {sbom.created[:16]}")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

## Verification

### Verification 1: Test Vendor Risk Management

```bash
cd 05-supply-chain/scripts

# Create vendors with different tiers
python3 vendor_risk_management.py create \
    --name "Critical Cloud Provider" \
    --description "Primary cloud infrastructure provider" \
    --tier 1 \
    --url "https://cloudprovider.com" \
    --contact "security@cloudprovider.com"

python3 vendor_risk_management.py create \
    --name "SaaS Application Vendor" \
    --description "Enterprise SaaS provider" \
    --tier 2 \
    --url "https://saasvendor.com" \
    --contact "security@saasvendor.com"

python3 vendor_risk_management.py create \
    --name "Generic Software Vendor" \
    --description "Basic software vendor" \
    --tier 3 \
    --url "https://softwarevendor.com"

python3 vendor_risk_management.py create \
    --name "Low Risk Vendor" \
    --description "Low risk vendor" \
    --tier 4 \
    --url "https://lowriskvendor.com"

# List vendors
python3 vendor_risk_management.py list

# Assess a vendor with sample responses
python3 vendor_risk_management.py assess --vendor <vendor-id>

# Generate scorecard
python3 vendor_risk_management.py scorecard --vendor <vendor-id>

# Monitor vendor
python3 vendor_risk_management.py monitor --vendor <vendor-id>

# Generate contract requirements
python3 vendor_risk_management.py contract --vendor <vendor-id>

# Generate report
python3 vendor_risk_management.py report
```

### Verification 2: Test SBOM Management

```bash
# Create SBOM
python3 sbom_manager.py create --name "Enterprise Application" --version "1.0.0"

# Add components
python3 sbom_manager.py add --sbom <sbom-id> \
    --name "log4j-core" --version "2.14.1" --vendor "Apache" \
    --licenses "Apache-2.0"

python3 sbom_manager.py add --sbom <sbom-id> \
    --name "spring-boot" --version "2.6.7" --vendor "Pivotal" \
    --licenses "Apache-2.0" \
    --dependencies "component-id-1"

python3 sbom_manager.py add --sbom <sbom-id> \
    --name "openssl" --version "1.1.1n" --vendor "OpenSSL" \
    --licenses "OpenSSL"

# Scan for vulnerabilities
python3 sbom_manager.py scan --sbom <sbom-id>

# Generate report
python3 sbom_manager.py report --sbom <sbom-id> --output ../reports/sbom-report.md

# Create second SBOM for comparison
python3 sbom_manager.py create --name "Enterprise Application" --version "2.0.0"
python3 sbom_manager.py add --sbom <sbom2-id> \
    --name "log4j-core" --version "2.17.1" --vendor "Apache" \
    --licenses "Apache-2.0"

# Compare SBOMs
python3 sbom_manager.py compare --sbom1 <sbom-id> --sbom2 <sbom2-id>
```

### Verification 3: Integration Test

**File:** `05-supply-chain/scripts/integration_test.py`

```python
#!/usr/bin/env python3
"""
Integration test for supply chain security components.
"""

import json
import datetime
import time
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from vendor_risk_management import VendorRiskManager
from sbom_manager import SBOMManager


def run_integration_test():
    """Run end-to-end integration test."""
    print("🚀 Starting Supply Chain Security Integration Test")
    print("=" * 60)
    
    # Initialize managers
    print("\n1. Initializing components...")
    vendor_manager = VendorRiskManager("./test_vendor_data")
    sbom_manager = SBOMManager("./test_sbom_data")
    
    # Vendor Risk Management
    print("\n2. Testing Vendor Risk Management...")
    
    # Create vendors
    vendors = []
    tiers = [1, 2, 3, 4]
    names = ["Critical Vendor", "High Risk Vendor", "Medium Risk Vendor", "Low Risk Vendor"]
    
    for i, (tier, name) in enumerate(zip(tiers, names)):
        vendor = vendor_manager.create_vendor(
            name=name,
            description=f"Test vendor - Tier {tier}",
            tier=tier
        )
        vendors.append(vendor)
        print(f"   ✅ Created: {vendor.name} (Tier {tier})")
    
    # Assess vendors
    print("\n3. Assessing vendors...")
    for vendor in vendors:
        # Generate assessment responses
        responses = {}
        for req_id, req in vendor_manager.requirements.items():
            # Simulate some vendors passing, some failing
            import random
            status = random.choice(['met', 'not_met', 'partial'])
            if vendor.tier <= 2:  # Critical vendors should have fewer issues
                status = random.choice(['met', 'met', 'met', 'partial'])
            
            responses[req_id] = {
                'status': status,
                'evidence': f"Evidence for {req_id}",
                'notes': f"Notes for {req_id}"
            }
        
        results = vendor_manager.assess_vendor(vendor.vendor_id, responses)
        print(f"   📊 {vendor.name}: Risk Score {results['risk_score']:.1f} - {results['category']}")
    
    # Monitor vendors
    print("\n4. Monitoring vendors...")
    for vendor in vendors:
        results = vendor_manager.monitor_vendor(vendor.vendor_id)
        print(f"   📡 {vendor.name}: Status {results['status']}, Score {results['risk_score']:.1f}")
    
    # SBOM Management
    print("\n5. Testing SBOM Management...")
    
    # Create SBOM
    sbom = sbom_manager.create_sbom("Integration Test App", "1.0.0")
    print(f"   ✅ SBOM created: {sbom.sbom_id}")
    
    # Add components with known vulnerabilities
    components = [
        {"name": "log4j-core", "version": "2.14.1", "vendor": "Apache"},
        {"name": "spring-boot", "version": "2.6.7", "vendor": "Pivotal"},
        {"name": "tomcat", "version": "9.0.56", "vendor": "Apache"},
        {"name": "openssl", "version": "1.1.1n", "vendor": "OpenSSL"}
    ]
    
    for comp in components:
        component = sbom_manager.add_component(
            sbom.sbom_id,
            comp['name'],
            comp['version'],
            comp['vendor']
        )
        print(f"   📦 Added: {comp['name']} v{comp['version']}")
    
    # Scan vulnerabilities
    print("\n6. Scanning for vulnerabilities...")
    results = sbom_manager.scan_vulnerabilities(sbom.sbom_id)
    print(f"   🔍 Scan complete:")
    print(f"      Total Components: {results['total_components']}")
    print(f"      Vulnerable Components: {results['vulnerable_components']}")
    print(f"      Total Vulnerabilities: {results['total_vulnerabilities']}")
    
    if results['vulnerabilities']:
        print("\n   Found vulnerabilities:")
        for vuln in results['vulnerabilities'][:5]:
            print(f"     - CVE-{vuln['cve_id']}: {vuln['component']} v{vuln['component_version']}")
    
    # Generate reports
    print("\n7. Generating reports...")
    
    # Vendor report
    vendor_report = vendor_manager.generate_risk_report()
    with open("./test_vendor_report.md", 'w') as f:
        f.write(vendor_report)
    print("   📊 Vendor report generated")
    
    # SBOM report
    sbom_report = sbom_manager.generate_sbom_report(sbom.sbom_id)
    with open("./test_sbom_report.md", 'w') as f:
        f.write(sbom_report)
    print("   📊 SBOM report generated")
    
    # Clean up
    print("\n8. Cleaning up...")
    import shutil
    for test_dir in ["./test_vendor_data", "./test_sbom_data"]:
        if os.path.exists(test_dir):
            shutil.rmtree(test_dir)
            print(f"   🧹 Cleaned up: {test_dir}")
    
    print("\n" + "=" * 60)
    print("✅ Supply Chain Security Integration Test Complete!")
    print("\nSummary:")
    print(f"   - Vendors managed: {len(vendors)}")
    print(f"   - Vendor risk scores: {', '.join([f'{v.name}: {v.risk_score:.1f}' for v in vendors])}")
    print(f"   - SBOM components: {len(sbom.components)}")
    print(f"   - Vulnerabilities found: {results.get('total_vulnerabilities', 0)}")


if __name__ == "__main__":
    run_integration_test()
```

**Run the integration test:**
```bash
cd 05-supply-chain/scripts
python3 integration_test.py
```

## Key Takeaways

### What You Built

1. **Vendor Risk Management**: Complete vendor lifecycle management with risk scoring
2. **Security Requirements**: Comprehensive vendor security requirements framework
3. **SBOM Management**: Software composition analysis with vulnerability scanning
4. **Contractual Security**: Automated contract requirement generation
5. **Continuous Monitoring**: Ongoing vendor monitoring and risk updates

### Framework Mapping

| Component | NIST SP 800-161 | ISO 28000 | SSDF |
|-----------|-----------------|-----------|------|
| Vendor Assessment | C-SCRM Tiered Approach | Risk Assessment | PW.8 |
| SBOM | Software Supply Chain | Security Assurance | PW.1.1 |
| Contractual Requirements | Acquisition Strategy | Security Requirements | N/A |
| Monitoring | Continuous Monitoring | Security Monitoring | N/A |
| Fourth-Party Risk | Extended Supply Chain | Extended Enterprise | N/A |

### Key Capabilities

- **Risk Assessment**: Comprehensive vendor security evaluation
- **SBOM Validation**: Dependency tracking and vulnerability scanning
- **Continuous Monitoring**: Real-time vendor risk updates
- **Contractual Security**: Enforceable security requirements
- **Fourth-Party Risk**: Extended supply chain visibility

### What's Next

In **Part 6**, we'll build security culture and continuous improvement:
- Security awareness programs and training
- Phishing simulations and human risk management
- Security champions programs
- Cybersecurity KPIs and KRIs
- Scorecards and dashboards
- Capability maturity models
- Continuous improvement framework
