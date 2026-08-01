# Part 1: Foundations of Secure Architecture & Framework Integration
## Section 1.2: NIST CSF 2.0 Governance Implementation

## The Target: NIST CSF 2.0 Governance Framework

In this section, we'll build the complete **NIST Cybersecurity Framework (CSF) 2.0** governance structure for Nexus Global Industries. The CSF 2.0 provides a risk-based approach to managing cybersecurity risk, organized around six core functions:

1. **Govern** (NEW in 2.0) - Establish cybersecurity strategy, expectations, and oversight
2. **Identify** - Understand organizational assets, risks, and capabilities
3. **Protect** - Implement safeguards to ensure delivery of critical services
4. **Detect** - Identify the occurrence of a cybersecurity event
5. **Respond** - Take action regarding a detected cybersecurity incident
6. **Recover** - Restore capabilities and services impaired by an incident

**What specific file(s) are we building?**
- `nist_csf/01_governance_policies.yaml` - CSF 2.0 Governance policies as code
- `nist_csf/02_identify_assets.yaml` - Asset inventory and risk assessment
- `nist_csf/03_protect_controls.yaml` - Protective controls and safeguards
- `nist_csf/04_detect_capabilities.yaml` - Detection mechanisms and rules
- `nist_csf/05_respond_playbooks.yaml` - Response procedures and playbooks
- `nist_csf/06_recover_plans.yaml` - Recovery procedures and DR plans
- `nist_csf/07_csf_sabsa_mapping.csv` - Cross-mapping between CSF and SABSA

---

## The Concept: NIST CSF 2.0 in Plain English

Think of the NIST CSF like a **risk management playbook** for your entire organization:

**Govern (New):** "We need a coach who sets the game plan, defines winning conditions, and holds everyone accountable." This is executive oversight, strategy, and policy.

**Identify:** "What players do we have? What positions? What are their strengths and weaknesses?" This is understanding your assets, risks, and capabilities.

**Protect:** "We need helmets, pads, and proper training to prevent injuries during plays." This is implementing safeguards and controls.

**Detect:** "We need a referee and instant replay to catch when something goes wrong." This is monitoring and detection.

**Respond:** "When a player gets injured, we have an emergency protocol to get them care and stabilize the situation." This is incident response.

**Recover:** "After the game, we have physical therapy and recovery plans to get the player back on the field." This is restoring capabilities and learning from incidents.

The CSF 2.0's big addition is the **Govern** function, which recognizes that cybersecurity isn't just technical—it's a business and leadership responsibility.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the NIST CSF directory
cd ~/nexus_security_architecture
mkdir -p nist_csf

# Verify the structure
ls -la
# Expected: nist_csf directory appears
```

---

### Step 2: Govern Function - Cybersecurity Strategy and Oversight

The Govern function establishes the cybersecurity strategy, expectations, and oversight mechanisms. This is the "coach" of our CSF framework.

**File:** `nist_csf/01_governance_policies.yaml`

```yaml
# NIST CSF 2.0 - Governance Policies as Code
# Nexus Global Industries
# Version: 1.0

govern:
  # ================================================================
  # G1: Organizational Context (GV.OC)
  # ================================================================
  organizational_context:
    mission: >
      Revolutionize global manufacturing through AI-driven precision engineering
      while maintaining the highest standards of quality, safety, and security.
    vision: >
      To be the world's most trusted manufacturing and technology partner,
      securing intellectual property and customer trust through excellence.
    values:
      - "Security is every employee's responsibility"
      - "Transparency in all security matters"
      - "Continuous improvement through learning"
      - "Customer trust is earned through security"
    business_model: >
      Advanced manufacturing + technology services. 
      Revenue: $4.2B annual.
      Employees: 15,000 across 42 countries.
    regulatory_requirements:
      - "GDPR (EU General Data Protection Regulation)"
      - "NIST SP 800-171 (US Government contracts)"
      - "CCPA/CPRA (California Consumer Privacy Act)"
      - "PDPA (Singapore Personal Data Protection Act)"
      - "Local manufacturing regulations (various jurisdictions)"
      - "Export controls (US and international)"
    risk_appetite:
      high_acceptance:
        - "Business agility and innovation"
        - "Security transformation initiatives"
      low_acceptance:
        - "Loss of intellectual property"
        - "Personal data breaches"
        - "Safety incidents affecting OT systems"
        - "Operational outages (manufacturing downtime)"
      risk_tolerance:
        - "Financial impact: Up to $5M per incident (medium risk)"
        - "Regulatory fines: Avoided through compliance"
        - "Reputational impact: Proactively managed"
    threat_environment:
      known_threats:
        - actor_type: "Nation-state APTs"
          motivation: "IP theft, industrial espionage"
          recent_activity: "Active targeting of manufacturing sector"
        - actor_type: "Ransomware Gangs"
          motivation: "Financial extortion"
          recent_activity: "2024 European datacenter ransomware incident"
        - actor_type: "Competitors"
          motivation: "Competitive intelligence"
          recent_activity: "Known intellectual property theft attempts"
        - actor_type: "Insider Threats"
          motivation: "Financial, disgruntled employees"
          recent_activity: "Remote workforce security challenges"
        - actor_type: "Hacktivists"
          motivation: "Reputational damage"
          recent_activity: "Targeting environmental or geopolitical issues"

  # ================================================================
  # G2: Risk Management Strategy (GV.RM)
  # ================================================================
  risk_management_strategy:
    framework: "NIST CSF 2.0 + ISO 27001 + SABSA"
    risk_management_process:
      identify: >
        Identify risks through threat modeling, vulnerability assessments,
        and asset inventory. Use STRIDE, PASTA, and Attack Trees.
      assess: >
        Assess risks using likelihood and impact criteria.
        Quantitative scoring (0-100) with qualitative overlay.
      prioritize: >
        Prioritize based on business impact and risk appetite.
        Critical systems (OT, IP, PII) get highest priority.
      treat: >
        Treatment options: Accept, Avoid, Transfer, Mitigate.
        Document all decisions in risk register.
      monitor: >
        Continuous monitoring through security metrics, audits,
        and threat intelligence feeds.
    risk_management_roles:
      - role: "CISO"
        responsibility: "Overall risk management ownership"
      - role: "Security Architects"
        responsibility: "Risk assessment and mitigation design"
      - role: "Platform Teams"
        responsibility: "Implementation of risk controls"
      - role: "Auditors"
        responsibility: "Independent risk verification"
    risk_management_artifacts:
      - "Risk Register (maintained in Excel/GRC tool)"
      - "Risk Treatment Plans (for each identified risk)"
      - "Risk Acceptance Log (signed by CISO or Board)"
      - "Security Metrics Dashboard (real-time risk posture)"

  # ================================================================
  # G3: Roles, Responsibilities, and Authorities (GV.RR)
  # ================================================================
  roles_responsibilities:
    cybersecurity_team:
      - title: "Chief Information Security Officer (CISO)"
        responsibilities:
          - "Overall cybersecurity strategy and governance"
          - "Board reporting and executive engagement"
          - "Risk appetite enforcement"
        authority: "Full authority over cybersecurity budget and strategy"
        reporting_to: "CEO and Board"
      
      - title: "Lead Enterprise Security Architect"
        responsibilities:
          - "Security architecture design and framework alignment"
          - "SABSA, CSF, and ISO 27001 integration"
          - "Threat modeling and control mapping"
        authority: "Architecture decisions and framework selection"
        reporting_to: "CISO"
      
      - title: "Security Engineering Manager"
        responsibilities:
          - "Implementation and operation of security controls"
          - "Team management (25+ security engineers)"
          - "Security tooling and automation"
        authority: "Security tool selection and operations"
        reporting_to: "CISO"
      
      - title: "Detection Engineering Manager"
        responsibilities:
          - "Detection rules and threat hunting"
          - "SIEM operations and analytics"
          - "MITRE ATT&CK alignment"
        authority: "Detection strategy and rule approval"
        reporting_to: "CISO"
      
      - title: "Incident Response Manager"
        responsibilities:
          - "Incident response processes and playbooks"
          - "Security incident management"
          - "Post-mortem and lessons learned"
        authority: "Incident containment decisions during active incidents"
        reporting_to: "CISO"
      
      - title: "GRC Manager"
        responsibilities:
          - "Risk management, compliance, and governance"
          - "Audit facilitation and remediation"
          - "Policy management"
        authority: "Compliance and audit decisions"
        reporting_to: "CISO"

    business_roles:
      - title: "CEO"
        responsibility: "Overall business accountability for cybersecurity"
        authority: "Approves cybersecurity strategy and budget"
      
      - title: "CFO"
        responsibility: "Cybersecurity financial oversight"
        authority: "Approves budget and financial risk acceptance"
      
      - title: "COO"
        responsibility: "Operational cybersecurity risk management"
        authority: "Approves operational security decisions"
      
      - title: "GC (General Counsel)"
        responsibility: "Legal and regulatory compliance"
        authority: "Legal and regulatory decisions"
      
      - title: "Board of Directors"
        responsibility: "Oversight of cybersecurity governance"
        authority: "Appoints CISO, approves strategy"

  # ================================================================
  # G4: Policies, Processes, and Procedures (GV.PO)
  # ================================================================
  policies:
    - policy_name: "Information Security Policy"
      policy_id: "POL-001"
      version: "1.0"
      owner: "CISO"
      overview: >
        Establishes the overall information security program,
        defining security objectives, roles, and responsibilities.
      controls_required: "All employees, contractors, and systems"
      review_frequency: "Annual"
      last_review_date: "2026-08-02"
      approval: "CISO and CEO"
      implementation_as_code: true
      code_repository: "https://gitlab.nexus.com/security/policies"
      enforcement_mechanism: "OPA policies + Kyverno policies"
    
    - policy_name: "Data Protection Policy"
      policy_id: "POL-002"
      version: "1.0"
      owner: "GRC Manager"
      overview: >
        Defines data classification, handling, encryption,
        and privacy requirements for all data assets.
      controls_required: "All systems storing or processing data"
      review_frequency: "Annual"
      last_review_date: "2026-08-02"
      approval: "CISO and Board"
      implementation_as_code: true
      code_repository: "https://gitlab.nexus.com/security/policies"
      enforcement_mechanism: "AWS Macie + Azure Purview + DLP policies"
    
    - policy_name: "Identity and Access Management Policy"
      policy_id: "POL-003"
      version: "1.0"
      owner: "Lead Enterprise Security Architect"
      overview: >
        Defines IAM requirements including authentication,
        authorization, privileged access, and lifecycle management.
      controls_required: "All users, workloads, and resources"
      review_frequency: "Annual"
      last_review_date: "2026-08-02"
      approval: "CISO"
      implementation_as_code: true
      code_repository: "https://gitlab.nexus.com/security/policies"
      enforcement_mechanism: "Keycloak + OPA + Vault"
    
    - policy_name: "Network Security Policy"
      policy_id: "POL-004"
      version: "1.0"
      owner: "Lead Enterprise Security Architect"
      overview: >
        Defines network segmentation, encryption, and
        Zero Trust architecture requirements.
      controls_required: "All networks and network-connected systems"
      review_frequency: "Annual"
      last_review_date: "2026-08-02"
      approval: "CISO"
      implementation_as_code: true
      code_repository: "https://gitlab.nexus.com/security/policies"
      enforcement_mechanism: "Calico network policies + Istio + OpenZiti"
    
    - policy_name: "Application Security Policy"
      policy_id: "POL-005"
      version: "1.0"
      owner: "Lead Enterprise Security Architect"
      overview: >
        Defines secure development lifecycle requirements,
        including SAST, DAST, SCA, and API security.
      controls_required: "All applications and APIs"
      review_frequency: "Annual"
      last_review_date: "2026-08-02"
      approval: "CISO"
      implementation_as_code: true
      code_repository: "https://gitlab.nexus.com/security/policies"
      enforcement_mechanism: "Semgrep + ZAP + Snyk + Kong"
    
    - policy_name: "Incident Response Policy"
      policy_id: "POL-006"
      version: "1.0"
      owner: "Incident Response Manager"
      overview: >
        Defines incident response procedures, roles,
        and escalation paths for security incidents.
      controls_required: "All systems and personnel"
      review_frequency: "Quarterly"
      last_review_date: "2026-08-02"
      approval: "CISO"
      implementation_as_code: true
      code_repository: "https://gitlab.nexus.com/security/playbooks"
      enforcement_mechanism: "TheHive + Cortex + SOAR playbooks"
    
    - policy_name: "Business Continuity Policy"
      policy_id: "POL-007"
      version: "1.0"
      owner: "CISO"
      overview: >
        Defines business continuity requirements including
        RTO, RPO, backup, and disaster recovery standards.
      controls_required: "All critical systems"
      review_frequency: "Bi-annual"
      last_review_date: "2026-08-02"
      approval: "Board"
      implementation_as_code: true
      code_repository: "https://gitlab.nexus.com/security/policies"
      enforcement_mechanism: "AWS Backup + Azure Site Recovery + Terraform"

  # ================================================================
  # G5: Oversight (GV.OV)
  # ================================================================
  oversight:
    governance_committee:
      name: "Security Governance Committee (SGC)"
      chair: "CISO"
      members:
        - "CEO"
        - "CFO"
        - "COO"
        - "GC"
        - "Board Representative"
      frequency: "Quarterly"
      responsibilities:
        - "Approve cybersecurity strategy and budget"
        - "Oversee risk acceptance decisions"
        - "Review incident response performance"
        - "Ensure compliance with regulatory obligations"
        - "Review security metrics and KPIs"
    
    architecture_review_board:
      name: "Security Architecture Review Board (SARB)"
      chair: "Lead Enterprise Security Architect"
      members:
        - "Cloud Architects"
        - "DevSecOps Leads"
        - "Compliance Manager"
        - "Platform Engineering Manager"
      frequency: "Bi-weekly"
      responsibilities:
        - "Review and approve architecture changes"
        - "Conduct threat model reviews for new systems"
        - "Maintain SABSA framework and traceability matrix"
        - "Ensure alignment with standards and frameworks"
    
    audit_and_compliance:
      internal_audit:
        - "Quarterly internal audits by GRC team"
        - "Focus on policy compliance and control effectiveness"
      external_audit:
        - "Annual external audits (SOC 2, ISO 27001)"
        - "Penetration tests (annual, plus event-driven)"
        - "Regulatory audits (as required)"
      reporting:
        - "Quarterly security metrics dashboard to SGC"
        - "Annual security report to Board"
        - "Post-incident reports within 1 week"

  # ================================================================
  # G6: Cybersecurity Supply Chain Risk Management (GV.SC)
  # ================================================================
  supply_chain_risk_management:
    vendor_risk_assessment:
      process: >
        All vendors undergo risk assessment before contracting.
        Critical vendors: Annual re-assessment.
      criteria:
        - "Security posture (SOC 2, ISO 27001, etc.)"
        - "Data handling and privacy practices"
        - "Incident history"
        - "Financial stability"
        - "Geopolitical risk"
    
    third_party_management:
      software_supply_chain:
        - "SBOM required for all third-party software"
        - "Known vulnerability scanning (SCA) on all dependencies"
        - "No unapproved OSS libraries allowed in production"
      service_providers:
        - "Cloud providers: AWS, Azure (enterprise agreements)"
        - "SaaS providers: O365, Salesforce, Workday, Slack"
        - "Security vendors: CrowdStrike, Snyk, Qualys"
      monitoring:
        - "Continuous monitoring of vendor security posture"
        - "Automated alerts on vendor vulnerabilities"
        - "Security SLA enforcement and reporting"

  # ================================================================
  # G7: Security Awareness and Training (GV.AW)
  # ================================================================
  security_awareness:
    program_name: "Nexus Global Security Champions Program"
    training_tracks:
      - track_name: "General Awareness"
        audience: "All employees and contractors"
        frequency: "Annual (mandatory)"
        topics:
          - "Security principles and values"
          - "Phishing and social engineering recognition"
          - "Data handling and privacy"
          - "Reporting security incidents"
        format: "eLearning module + quiz"
        pass_mark: "80%"
    
      - track_name: "Role-Based Training"
        audience: "Developers and Engineers"
        frequency: "Bi-annual"
        topics:
          - "Secure coding (OWASP Top 10)"
          - "API security (OWASP API Top 10)"
          - "Cloud security (CIS benchmarks)"
          - "Container and Kubernetes security"
          - "SAST/DAST/SCA tools usage"
        format: "Workshop + hands-on labs"
        assessment: "Practical coding challenge"
    
      - track_name: "Executive Security Briefing"
        audience: "Executives and Board Members"
        frequency: "Quarterly"
        topics:
          - "Threat landscape update"
          - "Security metrics and performance"
          - "Risk overview and key decisions"
          - "Incident lessons learned"
        format: "In-person briefing + Q&A"
    
      - track_name: "Security Champion Program"
        audience: "Selected employees across departments"
        frequency: "Monthly (ongoing)"
        topics:
          - "Advanced security topics"
          - "Security tooling and automation"
          - "Threat hunting exercises"
          - "Purple team activities"
        format: "Monthly meetings + hands-on exercises"
        certification: "Internal security champion certification"
    
    phishing_simulation:
      frequency: "Monthly"
      targets: "All employees (random selection)"
      metrics:
        - "Phishing click rate target: < 5%"
        - "Phishing reporting rate target: > 80%"
      remediation:
        - "Immediate mandatory training for clickers"
        - "Departmental reporting for high-click-rate teams"

  # ================================================================
  # G8: Cybersecurity Feedback and Improvement (GV.FI)
  # ================================================================
  continuous_improvement:
    feedback_loops:
      - source: "Incident post-mortems"
        output: "Updated controls, playbooks, and detection rules"
        frequency: "Per incident"
      
      - source: "Penetration test findings"
        output: "Vulnerability remediation and architecture improvements"
        frequency: "Post-penetration test"
      
      - source: "Chaos engineering results"
        output: "Resilience improvements, better auto-recovery"
        frequency: "Monthly"
      
      - source: "Security metrics dashboard"
        output: "Strategy adjustments, resource allocation changes"
        frequency: "Quarterly"
      
      - source: "Employee feedback"
        output: "Usability improvements, better security experience"
        frequency: "Continuous (via feedback portal)"
    
    maturity_model:
      current_level: "Level 3 (Defined)"
      target_level: "Level 4 (Managed)"
      timeline: "18 months"
      criteria:
        - "Automated security controls across all environments"
        - "Quantitative risk measurement"
        - "Predictive threat intelligence"
        - "Self-healing security systems"
        - "Full chaos engineering adoption"
    
    budget_allocation:
      year: "2026"
      total_budget: "$45,000,000"
      allocation:
        - category: "Security Engineering"
          amount: "$15,000,000"
          percentage: 33
        - category: "Detection & Response"
          amount: "$12,000,000"
          percentage: 27
        - category: "GRC & Risk Management"
          amount: "$8,000,000"
          percentage: 18
        - category: "Security Training"
          amount: "$5,000,000"
          percentage: 11
        - category: "Security Research"
          amount: "$5,000,000"
          percentage: 11

# End of Governance Policies
```

**Verification:**

```bash
# Verify governance policy file
ls -la nist_csf/01_governance_policies.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('nist_csf/01_governance_policies.yaml'))"
# Expected: No error output (YAML is valid)

# Count sections (should have 8 main sections)
grep -c "^  [A-Z]" nist_csf/01_governance_policies.yaml
# Expected: Shows 8 or more sections
```

---

### Step 3: Identify Function - Asset Inventory and Risk Assessment

The Identify function helps understand the organizational assets, risks, and capabilities. This is the "know thyself" of cybersecurity.

**File:** `nist_csf/02_identify_assets.yaml`

```yaml
# NIST CSF 2.0 - Identify Function
# Nexus Global Industries
# Version: 1.0

identify:
  # ================================================================
  # ID.AM: Asset Management
  # ================================================================
  asset_management:
    physical_assets:
      - asset_name: "Manufacturing Plants"
        quantity: 12
        locations:
          - "China"
          - "India"
          - "Germany"
          - "Mexico"
          - "United States"
          - "Singapore"
        criticality: "CRITICAL"
        asset_type: "OT/ICS"
        data_processed: "Manufacturing data, process control, quality data"
        regulatory_impact: "Safety regulations, export controls"
      
      - asset_name: "Data Centers (On-Premises)"
        quantity: 3
        locations:
          - "Singapore (HQ)"
          - "London"
          - "Austin"
        criticality: "HIGH"
        asset_type: "Infrastructure"
        data_processed: "Legacy systems, AD, internal services"
        regulatory_impact: "Local data protection laws"
      
      - asset_name: "Office Locations"
        quantity: 42
        locations: "Global (42 countries)"
        criticality: "MEDIUM"
        asset_type: "End-user computing"
        data_processed: "Employee data, communications"
        regulatory_impact: "GDPR, local privacy laws"

    digital_assets:
      - asset_name: "Cloud Infrastructure (AWS/Azure)"
        asset_type: "Cloud Platform"
        criticality: "CRITICAL"
        hosted_workloads: 500+
        data_processed: "All business critical data"
        regulatory_impact: "GDPR, NIST 800-171, CCPA"
        security_controls:
          - "AWS Organizations (multi-account strategy)"
          - "AWS Control Tower (landing zones)"
          - "Azure Landing Zones"
          - "CSPM: AWS Security Hub, Azure Security Center"
      
      - asset_name: "Kubernetes Clusters"
        asset_type: "Container Platform"
        criticality: "CRITICAL"
        quantity: 15
        workloads: 200+ microservices
        data_processed: "Application data, customer data"
        regulatory_impact: "GDPR, PII"
        security_controls:
          - "RBAC (least privilege)"
          - "Pod Security Standards (Restricted)"
          - "Kyverno admission control"
          - "Calico network policies"
          - "Istio service mesh (mTLS)"
      
      - asset_name: "Customer Portal (B2B)"
        asset_type: "Application"
        criticality: "CRITICAL"
        transactions: "50,000+/day"
        users: "5,000+ business customers"
        data_processed: "Orders, specifications, PII"
        regulatory_impact: "GDPR, CCPA"
        security_controls:
          - "OIDC authentication"
          - "RBAC/ABAC authorization"
          - "API gateway (rate limiting, JWT)"
          - "OWASP API Top 10 protections"
      
      - asset_name: "R&D Code Repositories"
        asset_type: "Intellectual Property"
        criticality: "CRITICAL"
        repositories: 1,200+
        data_processed: "Source code, AI/ML models, trade secrets"
        regulatory_impact: "Export controls, IP protection"
        security_controls:
          - "SCM security (branch protection)"
          - "SAST/SCA scanning"
          - "Secret scanning"
          - "Access controls (least privilege)"
          - "MFA required"
      
      - asset_name: "ERP and Financial Systems"
        asset_type: "Application"
        criticality: "HIGH"
        data_processed: "Financial data, payroll, procurement"
        regulatory_impact: "Financial regulations, SOX"
        security_controls:
          - "Segregation of duties"
          - "PAM for admin access"
          - "Immutable backups"
          - "Continuous monitoring"
      
      - asset_name: "Employee and HR Systems"
        asset_type: "Application"
        criticality: "HIGH"
        employees: 15,000
        data_processed: "PII, payroll, benefits, performance"
        regulatory_impact: "GDPR, PDPA, local privacy laws"
        security_controls:
          - "Data classification"
          - "Encryption at rest and in transit"
          - "Access controls (HR-specific)"
          - "Audit logging"

    data_assets:
      - asset_name: "Intellectual Property Data"
        criticality: "CRITICAL"
        classification: "RESTRICTED"
        data_types:
          - "AI/ML models and training data"
          - "Manufacturing process designs"
          - "Digital twin models"
          - "Customer manufacturing recipes"
        storage_locations:
          - "S3 buckets (encrypted, versioned)"
          - "Azure Blob (encrypted)"
          - "R&D Git repositories"
        protection_controls:
          - "Encryption at rest (AES-256)"
          - "Encryption in transit (TLS 1.3)"
          - "Access controls (ABAC)"
          - "DLP scanning"
          - "Immutable backups"
      
      - asset_name: "Customer Data"
        criticality: "CRITICAL"
        classification: "RESTRICTED"
        data_types:
          - "PII (names, emails, contact info)"
          - "Order and contract data"
          - "Billing and payment information"
        storage_locations:
          - "Application databases (encrypted)"
          - "Cloud storage (encrypted)"
        protection_controls:
          - "Encryption at rest (AES-256)"
          - "Encryption in transit (TLS 1.3)"
          - "Access controls (RBAC/ABAC)"
          - "Data minimization (retention limits)"
          - "GDPR compliance (right to erasure)"
      
      - asset_name: "Employee Data"
        criticality: "HIGH"
        classification: "CONFIDENTIAL"
        data_types:
          - "PII (names, DOB, addresses)"
          - "Payroll and benefits information"
          - "Performance and talent data"
        storage_locations:
          - "HR systems (encrypted)"
          - "Cloud storage (encrypted)"
        protection_controls:
          - "Encryption at rest (AES-256)"
          - "Access controls (HR-specific roles)"
          - "Audit logging"
          - "Data retention policies"

  # ================================================================
  # ID.RA: Risk Assessment
  # ================================================================
  risk_assessment:
    methodology: "NIST CSF 2.0 + ISO 31000"
    risk_tolerance:
      - category: "Confidentiality"
        tolerance: "LOW (IP and PII must be protected)"
      - category: "Integrity"
        tolerance: "LOW (data must be accurate)"
      - category: "Availability"
        tolerance: "MODERATE (RTO < 2 hours)"
      - category: "Safety"
        tolerance: "LOW (no compromise allowed)"
    
    risk_scoring:
      matrix:
        - likelihood: "Very Low"
          impact_values:
            low: 1
            medium: 2
            high: 3
            critical: 4
        - likelihood: "Low"
          impact_values:
            low: 2
            medium: 3
            high: 4
            critical: 5
        - likelihood: "Moderate"
          impact_values:
            low: 3
            medium: 4
            high: 5
            critical: 6
        - likelihood: "High"
          impact_values:
            low: 4
            medium: 5
            high: 6
            critical: 7
        - likelihood: "Very High"
          impact_values:
            low: 5
            medium: 6
            high: 7
            critical: 8
      risk_levels:
        - level: "LOW"
          score_range: [1, 3]
          action: "Monitor and review annually"
        - level: "MEDIUM"
          score_range: [4, 5]
          action: "Treat within 6 months"
        - level: "HIGH"
          score_range: [6, 7]
          action: "Treat within 90 days"
        - level: "CRITICAL"
          score_range: [8, 8]
          action: "Treat immediately (within 24 hours)"
    
    risk_register:
      - id: "RISK-001"
        title: "Ransomware Attack on Manufacturing Operations"
        description: "Ransomware encrypts OT/ICS systems causing production halt"
        asset_affected: "Manufacturing Plants (all 12)"
        threat_actor: "Ransomware Gangs"
        likelihood: "Moderate"
        impact: "Critical"
        score: 6
        risk_level: "HIGH"
        controls_planned:
          - "Micro-segmentation (OT isolated)"
          - "Immutable backups"
          - "Incident response playbooks"
          - "Chaos testing (ransomware simulation)"
        treatment: "Mitigate"
        owner: "Lead Enterprise Security Architect"
        due_date: "2026-09-30"
      
      - id: "RISK-002"
        title: "IP Theft from R&D Systems"
        description: "Nation-state APT exfiltrates AI/ML models and trade secrets"
        asset_affected: "R&D Code Repositories, ML Models"
        threat_actor: "Nation-state APTs"
        likelihood: "Moderate"
        impact: "Critical"
        score: 6
        risk_level: "HIGH"
        controls_planned:
          - "Zero Trust identity (continuous verification)"
          - "DLP for IP data"
          - "Encryption at rest and in transit"
          - "Audit logging and anomaly detection"
        treatment: "Mitigate"
        owner: "Lead Enterprise Security Architect"
        due_date: "2026-10-15"
      
      - id: "RISK-003"
        title: "Customer PII Data Breach"
        description: "Customer PII exposed through API vulnerability or misconfiguration"
        asset_affected: "Customer Portal, Application Databases"
        threat_actor: "External attackers, insiders"
        likelihood: "Moderate"
        impact: "High"
        score: 5
        risk_level: "MEDIUM"
        controls_planned:
          - "API security (OWASP Top 10)"
          - "Data encryption"
          - "Access controls (RBAC/ABAC)"
          - "DLP and audit logging"
        treatment: "Mitigate"
        owner: "Lead Enterprise Security Architect"
        due_date: "2026-08-30"
      
      - id: "RISK-004"
        title: "Supply Chain Compromise"
        description: "Third-party software or service vulnerability leads to breach"
        asset_affected: "All systems (via dependencies)"
        threat_actor: "Supply chain attackers"
        likelihood: "Low"
        impact: "High"
        score: 4
        risk_level: "MEDIUM"
        controls_planned:
          - "SBOM generation and verification"
          - "SCA scanning in CI/CD"
          - "Vendor risk assessments"
          - "Software supply chain policy"
        treatment: "Mitigate"
        owner: "Lead Enterprise Security Architect"
        due_date: "2026-11-15"
      
      - id: "RISK-005"
        title: "Insider Data Exfiltration"
        description: "Disgruntled or compromised employee exfiltrates data"
        asset_affected: "All data assets"
        threat_actor: "Insiders"
        likelihood: "Low"
        impact: "High"
        score: 4
        risk_level: "MEDIUM"
        controls_planned:
          - "DLP monitoring"
          - "Access controls (least privilege)"
          - "UEBA (user and entity behavior analytics)"
          - "Data classification and labeling"
        treatment: "Mitigate"
        owner: "Lead Enterprise Security Architect"
        due_date: "2026-12-15"

  # ================================================================
  # ID.BE: Business Environment
  # ================================================================
  business_environment:
    critical_services:
      - service_name: "Manufacturing Operations"
        dependency_on: "OT systems, PLC/SCADA, Power, Network"
        impact_of_downtime: "$2.4M/hour (estimates)"
        max_allowed_downtime: "2 hours"
      
      - service_name: "Customer Portal"
        dependency_on: "Application servers, Database, API gateways"
        impact_of_downtime: "$500K/hour (estimated lost revenue)"
        max_allowed_downtime: "4 hours"
      
      - service_name: "R&D Collaboration"
        dependency_on: "Code repositories, Dev environments, CI/CD"
        impact_of_downtime: "$200K/hour (lost productivity)"
        max_allowed_downtime: "8 hours"
      
      - service_name: "Financial Systems"
        dependency_on: "ERP, Payment gateways, Banking"
        impact_of_downtime: "$1M/hour (financial operations)"
        max_allowed_downtime: "4 hours"
    
    criticality_tiers:
      - tier: "TIER-0 (CRITICAL)"
        systems:
          - "Manufacturing OT systems"
          - "Customer portal"
          - "Payment processing"
          - "R&D IP repositories"
        RTO: "2 hours"
        RPO: "15 minutes"
      
      - tier: "TIER-1 (HIGH)"
        systems:
          - "ERP and financial"
          - "Employee HR systems"
          - "Internal collaboration"
        RTO: "4 hours"
        RPO: "1 hour"
      
      - tier: "TIER-2 (MEDIUM)"
        systems:
          - "Internal tooling"
          - "Non-critical applications"
          - "Development environments"
        RTO: "8 hours"
        RPO: "4 hours"
      
      - tier: "TIER-3 (LOW)"
        systems:
          - "Public-facing informational"
          - "Archival data"
          - "Non-sensitive systems"
        RTO: "24 hours"
        RPO: "24 hours"

  # ================================================================
  # ID.GV: Governance and Risk Management
  # ================================================================
  governance_risk:
    compliance_obligations:
      - standard: "GDPR"
        applicability: "Personal data of EU citizens"
        non_compliance_penalty: "Up to €20M or 4% annual global revenue"
        required_controls:
          - "Data protection by design and default"
          - "Data Subject Access Requests (DSARs)"
          - "Data breach notification within 72 hours"
          - "Data protection impact assessments"
        current_status: "Partially compliant (gap closure in progress)"
      
      - standard: "NIST SP 800-171"
        applicability: "Government contracts"
        non_compliance_penalty: "Contract loss, financial penalties"
        required_controls:
          - "Access control (NIST 800-53 controls)"
          - "Audit and accountability"
          - "Configuration management"
          - "System and communications protection"
          - "System and information integrity"
        current_status: "Compliant (with annual audits)"
      
      - standard: "ISO 27001"
        applicability: "Global operations"
        non_compliance_penalty: "Certification loss, reputational damage"
        required_controls:
          - "Annex A controls (114 controls)"
          - "ISMS implementation"
          - "Risk assessment and treatment"
          - "Statement of Applicability"
        current_status: "Certified (recertification in 12 months)"
      
      - standard: "SOC 2 (Type II)"
        applicability: "Customer trust requirements"
        non_compliance_penalty: "Customer loss, revenue impact"
        required_controls:
          - "Security (common criteria)"
          - "Availability"
          - "Processing integrity"
          - "Confidentiality"
          - "Privacy"
        current_status: "Certified (annual audit)"

  # ================================================================
  # ID.RA: Risk Assessment (continued - impact analysis)
  # ================================================================
  impact_analysis:
    confidentiality_impact:
      - type: "IP loss"
        consequence: "Competitive advantage lost, revenue impact"
        severity: "CRITICAL"
        example_scenario: "AI/ML models stolen"
      
      - type: "PII exposure"
        consequence: "Regulatory fines, reputational damage"
        severity: "HIGH"
        example_scenario: "Customer database breached"
      
      - type: "Financial data exposure"
        consequence: "Fraud, regulatory fines"
        severity: "HIGH"
        example_scenario: "Payment information compromised"
    
    integrity_impact:
      - type: "Manufacturing data corruption"
        consequence: "Product defects, safety incidents"
        severity: "CRITICAL"
        example_scenario: "OT system manipulated"
      
      - type: "Financial data manipulation"
        consequence: "Financial fraud, audit failures"
        severity: "HIGH"
        example_scenario: "Accounting records altered"
    
    availability_impact:
      - type: "Manufacturing downtime"
        consequence: "$2.4M/hour loss, customer impact"
        severity: "CRITICAL"
        example_scenario: "Ransomware encrypts OT"
      
      - type: "Customer portal outage"
        consequence: "Revenue loss, customer dissatisfaction"
        severity: "HIGH"
        example_scenario: "DDoS or technical failure"

  # ================================================================
  # ID.IM: Improvement
  # ================================================================
  improvement:
    maturity_assessment:
      domain: "Cybersecurity Maturity"
      current_level: 3
      target_level: 4
      timeline: "18 months"
      gaps:
        - area: "Zero Trust Implementation"
          gap: "Current implementation limited to proof-of-concept"
          remediation: "Full rollout across all workloads"
          priority: "HIGH"
          owner: "Lead Enterprise Security Architect"
        
        - area: "Automation in CI/CD Security"
          gap: "Limited automated scanning in pipelines"
          remediation: "Full SAST/DAST/SCA integration"
          priority: "HIGH"
          owner: "Lead Enterprise Security Architect"
        
        - area: "SOC Automation"
          gap: "Manual incident response processes"
          remediation: "SOAR implementation and playbooks"
          priority: "MEDIUM"
          owner: "Incident Response Manager"
        
        - area: "Chaos Engineering"
          gap: "Not yet implemented"
          remediation: "Complete chaos engineering program"
          priority: "MEDIUM"
          owner: "Lead Enterprise Security Architect"

# End of Identify Function
```

**Verification:**

```bash
# Verify identify file
ls -la nist_csf/02_identify_assets.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('nist_csf/02_identify_assets.yaml'))"
# Expected: No error output

# Check for risk register entries
grep -c "RISK-" nist_csf/02_identify_assets.yaml
# Expected: Shows 5 risk entries
```

---

### Step 4: Protect Function - Safeguards and Controls

The Protect function implements safeguards to ensure delivery of critical services. This is the "prevention" layer of our framework.

**File:** `nist_csf/03_protect_controls.yaml`

```yaml
# NIST CSF 2.0 - Protect Function
# Nexus Global Industries
# Version: 1.0

protect:
  # ================================================================
  # PR.AC: Access Control
  # ================================================================
  access_control:
    identity_management:
      idp: "Keycloak (OSS) / Azure AD"
      features:
        - "MFA: Required for all users (WebAuthn + TOTP)"
        - "Passwordless: Option for executives, R&D users"
        - "Federation: SAML 2.0, OIDC for all applications"
        - "SCIM 2.0: Automated JML (Joiner-Mover-Leaver)"
      JML_process:
        joiner:
          - "Workday triggers event"
          - "SCIM provisions account in Keycloak"
          - "Groups and roles assigned"
          - "MFA enrollment starts"
          - "Welcome email with instructions"
        mover:
          - "Workday updates event"
          - "SCIM updates account and roles"
          - "Access review triggered"
        leaver:
          - "Workday triggers event"
          - "SCIM disables account"
          - "Access revocation (all systems)"
          - "Data cleanup initiated"
    
    authorization:
      engine: "OPA (Open Policy Agent)"
      model: "ABAC + RBAC (hybrid)"
      policies:
        - policy_name: "user_access_policy"
          description: "Allows or denies access based on user attributes"
          example: >
            Allow if:
            - user.role == "admin" AND
            - user.mfa_enabled == true AND
            - user.device_posture == "compliant" AND
            - resource.classification <= user.clearance
        - policy_name: "context_aware_policy"
          description: "Risk-based access based on context"
          example: >
            Access granted with additional verification if:
            - user.geolocation != "home_country" OR
            - user.login_time != "working_hours" OR
            - user.behavior_anomaly_score > 70
        - policy_name: "least_privilege_policy"
          description: "Minimal permissions per role"
          example: >
            Applications access only necessary resources.
            Temporary credentials for privileged operations.
    
    privileged_access:
      solution: "HashiCorp Vault"
      features:
        - "JIT (Just-In-Time): Access requested and approved per session"
        - "JEA (Just-Enough-Administration): Minimum required permissions"
        - "Session recording: All admin sessions recorded"
        - "Credential rotation: Automatic (30-day interval)"
        - "Break-glass: Emergency access with approval and audit"
      workflows:
        - workflow_name: "Production Admin Access"
          steps:
            - "User requests access via Vault UI"
            - "Approval required (manager + security team)"
            - "Credentials dynamically generated"
            - "Session recorded (video/terminal log)"
            - "Time-bound access (15-minute max)"
            - "Auto-revocation after session ends"
            - "Audit log captured"

  # ================================================================
  # PR.AT: Awareness and Training
  # ================================================================
  awareness_training:
    program: "Nexus Global Security Champions"
    modules:
      - module_name: "Security Fundamentals"
        audience: "All employees"
        duration: "45 minutes"
        topics:
          - "Security principles (CIA triad)"
          - "Zero Trust concepts"
          - "Phishing and social engineering"
          - "Password hygiene and MFA"
          - "Incident reporting"
        frequency: "Annual"
        pass_mark: "80%"
      
      - module_name: "Secure Development"
        audience: "Developers and engineers"
        duration: "2 hours (hands-on lab)"
        topics:
          - "OWASP Top 10 vulnerabilities"
          - "Secure coding practices"
          - "OWASP API Top 10"
          - "SAST/DAST/SCA tool usage"
          - "Git security (branch protection, secrets)"
        frequency: "Bi-annual"
        assessment: "Practical coding challenge"
      
      - module_name: "Cloud Security"
        audience: "Cloud and platform engineers"
        duration: "1.5 hours (hands-on lab)"
        topics:
          - "CIS benchmarks (AWS, Azure)"
          - "Kubernetes security (CKS topics)"
          - "Container security (image scanning, SBOM)"
          - "Policy-as-Code (OPA, Kyverno)"
          - "Cloud IAM and access control"
        frequency: "Bi-annual"
        assessment: "Scenario-based challenge"
      
      - module_name: "Executive Security Briefing"
        audience: "Executives and Board"
        duration: "45 minutes"
        topics:
          - "Threat landscape update"
          - "Security metrics and KPIs"
          - "Risk overview and decisions"
          - "Incident case studies"
        frequency: "Quarterly"
        format: "In-person briefing"

  # ================================================================
  # PR.DS: Data Security
  # ================================================================
  data_security:
    data_classification:
      - classification: "RESTRICTED"
        description: "Highly sensitive data, severe impact if compromised"
        examples:
          - "IP (AI/ML models, trade secrets)"
          - "Customer PII"
          - "Manufacturing recipes"
        encryption_required:
          - "At rest: AES-256"
          - "In transit: TLS 1.3"
          - "In use: Confidential computing where available"
        access_controls: "ABAC (strict, need-to-know)"
        retention: "As required by regulation"
        deletion: "Secure deletion required"
      
      - classification: "CONFIDENTIAL"
        description: "Sensitive internal data, moderate impact if compromised"
        examples:
          - "Employee PII"
          - "Financial data"
          - "Business strategies"
        encryption_required:
          - "At rest: AES-256"
          - "In transit: TLS 1.3"
        access_controls: "RBAC (role-based)"
        retention: "7 years for financial data"
        deletion: "Secure deletion required"
      
      - classification: "INTERNAL"
        description: "Internal data, low impact if compromised"
        examples:
          - "Internal policies and procedures"
          - "Project documentation"
          - "Non-sensitive internal communications"
        encryption_required:
          - "At rest: AES-256 (or cloud-managed)"
          - "In transit: TLS 1.2+"
        access_controls: "RBAC (general internal)"
        retention: "5 years (default)"
        deletion: "Regular deletion"
      
      - classification: "PUBLIC"
        description: "Public information, negligible impact if compromised"
        examples:
          - "Public website content"
          - "Marketing materials"
          - "Public annual reports"
        encryption_required:
          - "At rest: Not required"
          - "In transit: TLS (best practice)"
        access_controls: "Unrestricted"
        retention: "Indefinite"
        deletion: "Standard deletion"
    
    encryption:
      at_rest:
        - "Storage: AWS S3 SSE-S3, Azure Storage Encryption"
        - "Databases: AWS RDS encryption, Azure SQL TDE"
        - "Kubernetes: Encryption in etcd, secrets encryption"
        - "Key management: HashiCorp Vault + Cloud KMS"
      in_transit:
        - "TLS 1.3 for all external communication"
        - "mTLS for internal service mesh (Istio)"
        - "IPsec for network segmentation where needed"
      key_rotation:
        - "Customer keys: 30-day rotation"
        - "Cloud-managed keys: Automatic (90-day default)"
        - "All keys: Rotation enforced by policy"
    
    data_loss_prevention:
      tools:
        - "AWS Macie (S3 data discovery)"
        - "Azure Purview (data classification)"
        - "Cloud DLP (endpoint and network)"
      monitoring:
        - "Sensitive data transfers to external sources"
        - "Unauthorized data exfiltration attempts"
        - "Unusual data access patterns"
      response:
        - "Alert security team immediately"
        - "Block suspected exfiltration attempts"
        - "Investigate and contain data loss"

  # ================================================================
  # PR.IP: Information Protection Processes and Procedures
  # ================================================================
  info_protection:
    security_baselines:
      cloud_baseline:
        standard: "CIS Benchmarks (AWS, Azure)"
        enforcement: "AWS Config + Azure Policy"
        exceptions: "Approved by SARB only"
        scanning: "Daily (CSPM)"
      
      kubernetes_baseline:
        standard: "CIS Kubernetes Benchmark"
        enforcement: "Kyverno admission control"
        exceptions: "Approved by SARB only"
        scanning: "Continuous (kube-bench)"
      
      container_baseline:
        standard: "NIST SP 800-190 (Container Security)"
        enforcement: "Image scanning + Admission control"
        exceptions: "Approved by SARB only"
        scanning: "CI/CD + Runtime"
    
    patch_management:
      process: "Automated patch management with manual verification for critical systems"
      critical_patches: "Within 24 hours of CVE publication"
      high_patches: "Within 7 days of CVE publication"
      medium_patches: "Within 30 days of CVE publication"
      low_patches: "Within 90 days of CVE publication"
      testing: "Dev/Staging environments before production"
      maintenance_windows: "Monthly for non-critical, as-needed for critical"
    
    vulnerability_management:
      tools:
        - "Qualys (continuous scanning)"
        - "AWS Inspector (host and container)"
        - "Snyk (dependency scanning)"
        - "Trivy (container scanning)"
      severity_scoring:
        - "CRITICAL: 9.0-10.0 CVSS"
        - "HIGH: 7.0-8.9 CVSS"
        - "MEDIUM: 4.0-6.9 CVSS"
        - "LOW: 0.1-3.9 CVSS"
      remediation_targets:
        - "CRITICAL: 24 hours"
        - "HIGH: 7 days"
        - "MEDIUM: 30 days"
        - "LOW: 90 days"
      exception_process: "Approved by SARB with compensating controls"

  # ================================================================
  # PR.MA: Maintenance
  # ================================================================
  maintenance:
    hardware_maintenance:
      - "Data centers: Monthly physical inspections"
      - "OT systems: Manufacturer maintenance schedules"
      - "Network devices: Quarterly firmware updates"
    
    software_maintenance:
      - "OS patches: Monthly maintenance windows"
      - "Application updates: Continuous (CI/CD)"
      - "Security tools: Automatic updates (canary deployment)"
    
    documentation_maintenance:
      - "Architecture documentation: Updated with every major change"
      - "Runbooks: Updated quarterly"
      - "Playbooks: Updated post-incident"

  # ================================================================
  # PR.ND: Network Security
  # ================================================================
  network_security:
    zero_trust:
      architecture: "NIST SP 800-207 compliant"
      components:
        - "PDP: OPA (centralized policy engine)"
        - "PEP: Istio sidecars, Kong Gateway, Calico network policies"
        - "PAP: Policy management portal"
        - "PIP: Identity, device, threat intelligence sources"
    
    segmentation:
      model: "Micro-segmentation (east-west) + Perimeter (north-south)"
      network_policies:
        - "Default-deny across all namespaces"
        - "Explicit allow for known good traffic"
        - "Least privilege egress policies"
        - "Isolation of environments (dev, stage, prod)"
      external_perimeter:
        - "AWS Security Groups, Azure Network Security Groups"
        - "WAF (AWS WAF, Azure WAF)"
        - "DDoS protection (AWS Shield, Azure DDoS Protection)"
    
    encryption:
      - "TLS 1.3 for all external traffic"
      - "mTLS for all internal service mesh traffic"
      - "IPsec for VPN connections"

  # ================================================================
  # PR.IR: Incident Response (Protect aspects)
  # ================================================================
  incident_response_protection:
    playbooks:
      - playbook_name: "Phishing Response"
        trigger: "User reports suspicious email or SIEM detects phishing"
        actions:
          - "Isolate user's mailbox"
          - "Extract and analyze email headers"
          - "Check for compromised credentials"
          - "Notify security team"
          - "Block sender"
          - "Update spam filters"
        roles: ["SOC Analyst", "Security Engineer", "IR Manager"]
      
      - playbook_name: "Ransomware Detection and Containment"
        trigger: "SIEM alert or user report"
        actions:
          - "Isolate affected network segments (Calico network policies)"
          - "Isolate affected endpoints"
          - "Capture forensic evidence"
          - "Identify ransomware variant"
          - "Restore from immutable backups"
          - "Investigate entry vector"
        roles: ["IR Manager", "Forensics Analyst", "Infrastructure Engineer"]
      
      - playbook_name: "Compromised Credential Remediation"
        trigger: "Anomaly detection (UEBA) or user report"
        actions:
          - "Force password reset"
          - "Revoke all sessions and tokens"
          - "Rotate API keys and secrets"
          - "Review access logs (recent activity)"
          - "Enable MFA (if not already)"
          - "Notify security team"
        roles: ["SOC Analyst", "IAM Engineer", "Security Engineer"]

# End of Protect Function
```

**Verification:**

```bash
# Verify protect file
ls -la nist_csf/03_protect_controls.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('nist_csf/03_protect_controls.yaml'))"
# Expected: No error output

# Check for sections
grep -c "^  PR\." nist_csf/03_protect_controls.yaml
# Expected: Shows 6+ PR sections
```

---

### Step 5: Detect Function - Detection Capabilities

The Detect function identifies the occurrence of a cybersecurity event. This is the "eyes and ears" of our security architecture.

**File:** `nist_csf/04_detect_capabilities.yaml`

```yaml
# NIST CSF 2.0 - Detect Function
# Nexus Global Industries
# Version: 1.0

detect:
  # ================================================================
  # DE.AE: Anomalies and Events
  # ================================================================
  anomalies_events:
    sources:
      application_logs:
        description: "All application and microservice logs"
        tool: "Filebeat (ELK) + Application-specific"
        retention: "90 days (hot), 365 days (archive)"
        fields: ["timestamp", "user", "action", "resource", "result", "ip", "user_agent"]
      
      system_logs:
        description: "OS logs, kernel logs, audit logs"
        tool: "Filebeat, Winlogbeat (for Windows), syslog"
        retention: "90 days (hot), 180 days (warm)"
        fields: ["timestamp", "host", "process", "event_type", "user", "details"]
      
      security_logs:
        description: "Authentication, authorization, security events"
        tool: "Keycloak logs, Vault logs, AD logs"
        retention: "365 days (for compliance)"
        fields: ["timestamp", "user", "event_type", "result", "ip", "details"]
      
      cloud_logs:
        description: "AWS CloudTrail, Azure Monitor, GCP audit logs"
        tool: "S3 → ELK, Event Hub → ELK"
        retention: "90 days (hot), 365 days (archive)"
        fields: ["timestamp", "user", "service", "action", "resource", "ip", "result"]
      
      network_logs:
        description: "Calico flow logs, VPC Flow Logs, NSG flow logs"
        tool: "Calico → ELK, AWS VPC Flow → S3 → ELK"
        retention: "30 days (hot), 90 days (warm)"
        fields: ["timestamp", "src_ip", "dst_ip", "src_port", "dst_port", "protocol", "bytes"]
      
      endpoint_logs:
        description: "EDR/XDR telemetry"
        tool: "CrowdStrike, Microsoft Defender, Sentinel"
        retention: "90 days (SaaS managed)"
        fields: ["timestamp", "host", "process", "command", "user", "file", "registry"]
    
    analysis:
      real_time_analysis:
        - "Stream processing (Elasticsearch aggregations)"
        - "Alerts on patterns (Sigma rules)"
        - "Anomaly detection (ML-based)"
      historical_analysis:
        - "Elasticsearch queries (Kibana)"
        - "Threat hunting (Jupyter notebooks)"
        - "Forensic analysis (time-ordered events)"
      reporting:
        - "Daily: Automated reports on anomalies"
        - "Weekly: SOC summary report"
        - "Monthly: Threat hunting report"

  # ================================================================
  # DE.CM: Continuous Monitoring
  # ================================================================
  continuous_monitoring:
    endpoint_monitoring:
      tool: "CrowdStrike Falcon / Microsoft Defender"
      coverage: "100% of endpoints (servers, workstations)"
      features:
        - "Real-time malware detection"
        - "File and registry monitoring"
        - "Process and network monitoring"
        - "Vulnerability assessment"
        - "IAM and identity monitoring"
      alerting: "All suspicious activity in SIEM"
    
    network_monitoring:
      tool: "Calico + Istio telemetry + AWS VPC Flow"
      coverage: "All networks"
      features:
        - "Flow logs (100% coverage)"
        - "Intrusion detection (IDS/IPS in network policies)"
        - "Traffic volume anomalies (baseline detection)"
        - "DDoS detection (AWS Shield)"
      alerting: "Flow anomalies in SIEM"
    
    cloud_monitoring:
      tool: "AWS Security Hub, Azure Security Center"
      coverage: "All cloud accounts and subscriptions"
      features:
        - "CIS benchmark compliance"
        - "Configuration drift detection"
        - "Resource provisioning anomaly"
        - "IAM policy violations"
      alerting: "All compliance violations in SIEM"
    
    application_monitoring:
      tool: "Application logs + APM (Datadog, New Relic)"
      coverage: "All applications"
      features:
        - "Application errors and exceptions"
        - "API usage patterns"
        - "User behavior analytics"
        - "Authentication failures"
      alerting: "Application errors (> thresholds) in SIEM"
    
    kubernetes_monitoring:
      tool: "Kubernetes audit logs + Istio telemetry"
      coverage: "All K8s clusters"
      features:
        - "Pod lifecycle events"
        - "RBAC authorization attempts"
        - "Network policy violations"
        - "Container resource usage"
      alerting: "Security-relevant events in SIEM"

  # ================================================================
  # DE.DP: Detection Processes
  # ================================================================
  detection_processes:
    detection_engineering:
      framework: "MITRE ATT&CK"
      rule_development:
        process: >
          - "Identify new threats (threat intelligence)"
          - "Develop detection rule (Sigma format)"
          - "Test rule in development environment"
          - "Deploy to SIEM (Elasticsearch)"
          - "Monitor false positives"
          - "Tune rule (as needed)"
        frequency: "New rules every week (average 5 rules/month)"
      rule_examples:
        - rule_name: "Credential Dumping via LSASS"
          sigma_rule_id: "101"
          mitre_ttp: "T1003"
          description: "Detects LSASS memory access by suspicious processes"
        
        - rule_name: "Privilege Escalation via Sudo"
          sigma_rule_id: "102"
          mitre_ttp: "T1548"
          description: "Detects sudo attempts by non-privileged users"
        
        - rule_name: "Persistence via Cron Jobs"
          sigma_rule_id: "103"
          mitre_ttp: "T1053"
          description: "Detects addition of cron jobs by unexpected users"
    
    threat_hunting:
      schedule: "Monthly (structured hunt), Continuous (opportunistic)"
      methodology:
        - "Hypothesis-driven (based on threat intelligence)"
        - "MITRE ATT&CK mapping"
        - "Data-driven (SIEM queries, Jupyter notebooks)"
      focus_areas:
        - "C2 (Command and Control) detection"
        - "Lateral movement"
        - "Privilege escalation"
        - "Data exfiltration"
      tools:
        - "Kibana (SIEM queries)"
        - "Jupyter notebooks (custom analytics)"
        - "MITRE ATT&CK Navigator (mapping)"
      outcomes:
        - "New detection rules"
        - "Updated playbooks"
        - "Architecture improvements"

  # ================================================================
  # DE.AR: Anomaly Response
  # ================================================================
  anomaly_response:
    alerting:
      severity_levels:
        - level: "CRITICAL"
          description: "Confirmed, high-confidence malicious activity"
          response_time: "Immediate (within 5 minutes)"
          escalation: "IR Manager + CISO"
        
        - level: "HIGH"
          description: "Likely malicious activity, high confidence"
          response_time: "Within 15 minutes"
          escalation: "SOC Lead + Security Engineer"
        
        - level: "MEDIUM"
          description: "Possible malicious activity, medium confidence"
          response_time: "Within 1 hour"
          escalation: "SOC Analyst (triage)"
        
        - level: "LOW"
          description: "Unusual activity, low confidence"
          response_time: "Within 4 hours"
          escalation: "Security Engineer (investigation)"
      
      notification_channels:
        - "Slack (#security-alerts)"
        - "PagerDuty (critical and high only)"
        - "Jira (ticket creation)"
        - "Email (daily summary)"
    
    escalation_process:
      tier_1: "SOC Analyst (initial triage)"
      tier_2: "Detection Engineer (rule analysis)"
      tier_3: "Incident Responder (incident management)"
      tier_4: "IR Manager + CISO (escalation and comms)"
    
    false_positive_management:
      process: >
        - "Track false positives (ticketing system)"
        - "Analyze root cause (rule tuning, data quality)"
        - "Implement improvements (tune rule, improve telemetry)"
        - "Reduce false positive rate (target < 3%)"
        - "Review monthly in SOC meetings"

  # ================================================================
  # DE.DU: Detection of Unauthorized Activity
  # ================================================================
  unauthorized_activity:
    detection_techniques:
      - technique: "User Behavior Analytics (UBA)"
        tool: "SIEM-based (Elasticsearch ML)"
        description: "Baseline user behavior and detect deviations"
        examples:
          - "Unusual login times"
          - "Unusual data access patterns"
          - "Impossible travel (geolocation anomalies)"
      
      - technique: "Malware Detection"
        tool: "CrowdStrike Falcon, ELK (AV logs)"
        description: "Detect known malware and suspicious files"
        examples:
          - "Signature-based detection"
          - "Behavior-based detection (sandbox analysis)"
          - "File integrity monitoring"
      
      - technique: "Network Intrusion Detection"
        tool: "Calico (flow logs + anomaly detection)"
        description: "Detect network-based attacks"
        examples:
          - "Port scans"
          - "Brute-force attacks"
          - "Data exfiltration (large outbound transfers)"
      
      - technique: "Cloud Security Posture Monitoring"
        tool: "AWS Security Hub, Azure Security Center"
        description: "Detect misconfigurations and security issues"
        examples:
          - "Open S3 buckets"
          - "Publicly accessible databases"
          - "Overly permissive IAM policies"

  # ================================================================
  # DE.SR: Security Continuous Monitoring
  # ================================================================
  security_monitoring:
    monitoring_coverage:
      coverage_target: "100% of critical systems, 90% of all systems"
      monitoring_domains:
        - domain: "Endpoint"
          coverage: "100%"
          gaps: "Legacy OT endpoints (planned Q3 2026)"
        
        - domain: "Network"
          coverage: "100%"
          gaps: "None"
        
        - domain: "Cloud"
          coverage: "100%"
          gaps: "None"
        
        - domain: "Kubernetes"
          coverage: "100%"
          gaps: "Some legacy clusters (planned Q4 2026)"
        
        - domain: "Application"
          coverage: "85%"
          gaps: "Legacy applications (planned Q4 2026)"
    
    monitoring_tools:
      - tool: "ELK Stack (Elasticsearch, Logstash, Kibana)"
        purpose: "Centralized SIEM and analytics"
        coverage: "All logs"
      
      - tool: "CrowdStrike Falcon"
        purpose: "Endpoint security and XDR"
        coverage: "All endpoints"
      
      - tool: "AWS Security Hub"
        purpose: "Cloud security posture management (CSPM)"
        coverage: "All AWS accounts"
      
      - tool: "Azure Security Center"
        purpose: "Cloud security posture management (CSPM)"
        coverage: "All Azure subscriptions"
      
      - tool: "Kyverno"
        purpose: "Kubernetes policy enforcement monitoring"
        coverage: "All K8s clusters"
      
      - tool: "Istio Telemetry"
        purpose: "Service mesh observability"
        coverage: "All K8s clusters"

# End of Detect Function
```

**Verification:**

```bash
# Verify detect file
ls -la nist_csf/04_detect_capabilities.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('nist_csf/04_detect_capabilities.yaml'))"
# Expected: No error output

# Check for detection rules
grep -c "rule_name:" nist_csf/04_detect_capabilities.yaml
# Expected: Shows 3+ detection rule examples
```

---

### Step 6: Respond Function - Response Procedures

The Respond function defines how to take action regarding a detected cybersecurity incident.

**File:** `nist_csf/05_respond_playbooks.yaml`

```yaml
# NIST CSF 2.0 - Respond Function
# Nexus Global Industries
# Version: 1.0

respond:
  # ================================================================
  # RS.RP: Response Planning
  # ================================================================
  response_planning:
    plan_name: "Cybersecurity Incident Response Plan (CSIRP)"
    version: "2.0"
    owner: "Incident Response Manager"
    last_updated: "2026-08-02"
    review_frequency: "Quarterly (tabletop exercises)"
    
    incident_types:
      - type: "Malware/Ransomware"
        examples:
          - "Ransomware encryption of files"
          - "Trojan/backdoor installation"
          - "Wiper malware"
        playbook: "playbook_ransomware.yaml"
      
      - type: "Data Breach"
        examples:
          - "PII exposure"
          - "IP theft"
          - "Customer data exfiltration"
        playbook: "playbook_data_breach.yaml"
      
      - type: "Unauthorized Access"
        examples:
          - "Compromised credentials"
          - "Insider misuse"
          - "Privilege abuse"
        playbook: "playbook_unauthorized_access.yaml"
      
      - type: "Denial of Service"
        examples:
          - "DDoS attack"
          - "System overload"
          - "Resource exhaustion"
        playbook: "playbook_dos.yaml"
      
      - type: "Supply Chain Compromise"
        examples:
          - "Third-party software vulnerability"
          - "Compromised vendor"
          - "OSS dependency backdoor"
        playbook: "playbook_supply_chain.yaml"
    
    roles_and_responsibilities:
      - role: "Incident Response Manager"
        responsibilities:
          - "Lead incident response"
          - "Coordinate actions"
          - "Communicate with leadership"
        authority: "Full authority during active incident"
      
      - role: "SOC Lead"
        responsibilities:
          - "Alert triage and initial analysis"
          - "Coordinate SOC team"
          - "Detection rule updates"
        authority: "Triage decisions (escalate if uncertain)"
      
      - role: "Forensics Analyst"
        responsibilities:
          - "Evidence collection"
          - "Root cause analysis"
          - "Preserve chain of custody"
        authority: "Forensic collection and analysis"
      
      - role: "Communications Lead"
        responsibilities:
          - "Internal communications"
          - "External communications (PR/legal)"
          - "Stakeholder updates"
        authority: "Communications strategy"
      
      - role: "Infrastructure Engineer"
        responsibilities:
          - "Network isolation"
          - "System restoration"
          - "Backup recovery"
        authority: "Technical containment actions"

  # ================================================================
  # RS.AN: Analysis
  # ================================================================
  analysis:
    triage_process:
      steps:
        - step: "Alert Verification"
          description: "Validate alert is a true positive"
          timeframe: "Within 5 minutes"
          tools: "SIEM, threat intelligence, logs"
        
        - step: "Initial Triage"
          description: "Determine severity (Critical/High/Medium/Low)"
          timeframe: "Within 10 minutes"
          criteria:
            - "Critical: Active breach, data loss ongoing"
            - "High: Likely breach, immediate action needed"
            - "Medium: Suspicious activity, investigation needed"
            - "Low: Potential issue, monitor and investigate"
        
        - step: "Evidence Collection"
          description: "Preserve relevant logs, artifacts, and telemetry"
          timeframe: "Within 30 minutes"
          tools: "SIEM, EDR, network captures"
        
        - step: "Root Cause Analysis"
          description: "Identify initial entry vector and compromised systems"
          timeframe: "Within 4 hours"
          tools: "Forensic tools, logs, threat hunting"
    
    impact_assessment:
      methodology: "Business impact analysis"
      criteria:
        - "Data affected (confidentiality, integrity)"
        - "Operations affected (availability)"
        - "Financial impact (downtime, remediation costs)"
        - "Regulatory impact (fines, notifications)"
        - "Reputational impact (trust, brand damage)"
      assessment_framework:
        - "Likelihood: 1-5 (Very Low to Very High)"
        - "Impact: 1-5 (Low to Critical)"
        - "Risk Score: Likelihood x Impact"
        - "Risk Level: Low (1-8), Medium (9-15), High (16-25)"

  # ================================================================
  # RS.MI: Mitigation
  # ================================================================
  mitigation:
    containment_strategies:
      - strategy: "Network Isolation"
        description: "Isolate affected systems from the network"
        implementation: "Calico network policies, firewalls"
        timing: "Immediate (within 5 minutes)"
      
      - strategy: "Credential Revocation"
        description: "Revoke compromised user and service credentials"
        implementation: "Keycloak (users), Vault (secrets), AWS IAM (roles)"
        timing: "Immediate (within 5 minutes)"
      
      - strategy: "Service Shutdown"
        description: "Shut down non-critical services to prevent spread"
        implementation: "Kubernetes scale-to-zero, cloud instances stop"
        timing: "Within 15 minutes"
      
      - strategy: "Application Isolation"
        description: "Isolate specific applications or microservices"
        implementation: "Istio traffic management, service mesh isolation"
        timing: "Within 15 minutes"
    
    eradication:
      steps:
        - "Remove malware (antivirus, manual cleaning)"
        - "Patch vulnerabilities (vendor patches, config changes)"
        - "Delete compromised data (secure deletion)"
        - "Reimage affected systems (clean install)"
        - "Apply security updates (all systems)"
      verification:
        - "Rescan systems (vulnerability scanning)"
        - "Validate integrity (file hashes, configuration checks)"
        - "Test functionality (service health checks)"
        - "Monitor for recurrence (SIEM rules)"

  # ================================================================
  # RS.IM: Improvement
  # ================================================================
  improvement:
    post_incident_review:
      process: "Conducted within 72 hours of incident containment"
      participants:
        - "Incident Response Manager (lead)"
        - "All incident responders involved"
        - "Relevant stakeholders (business owners, legal, PR)"
      agenda:
        - "What happened? (timeline)"
        - "What went well?"
        - "What went wrong?"
        - "What can be improved?"
        - "Action items and owners"
      artifacts:
        - "Post-mortem report"
        - "Updated playbooks"
        - "New detection rules"
        - "Architecture improvements"
    
    lessons_learned:
      timeframe: "Within 1 week of incident"
      actions:
        - "Update policies (if gaps identified)"
        - "Enhance controls (implementation)"
        - "Train teams (if skills gaps found)"
        - "Share findings (across organization)"
      tracking:
        - "All improvements tracked in Jira"
        - "Owners assigned for each action"
        - "Review in SOC meetings (weekly)"

  # ================================================================
  # RS.CO: Communications
  # ================================================================
  communications:
    internal_comms:
      strategy: "Keep stakeholders informed while minimizing panic"
      channels:
        - "Slack (incident channel)"
        - "Email (status updates)"
        - "All-hands (major incidents)"
      templates:
        - "Initial alert (within 15 minutes)"
        - "Status update (hourly or as needed)"
        - "Resolution notification"
        - "Post-incident summary"
    
    external_comms:
      strategy: "Coordinated with Legal, PR, and Leadership"
      regulatory_notifications:
        - "GDPR: 72 hours for data breaches"
        - "NIST: As per contract requirements"
        - "Local regulators: As per local laws"
      customer_notifications:
        - "If customer data affected"
        - "Under legal direction"
        - "Within regulatory timeframe"
      public_relations:
        - "Approved messaging only"
        - "Coordinated with PR team"
        - "No speculation or assumptions"

  # ================================================================
  # RS.MI: Mitigation (Detailed Playbook Example)
  # ================================================================
  detailed_playbooks:
    - playbook_name: "Ransomware Detection and Response"
      playbook_id: "PB-001"
      version: "1.0"
      steps:
        - step: "Alert Triage (SOC)"
          time: "T+0 minutes"
          actions:
            - "Verify ransomware alert from SIEM or user report"
            - "Check affected systems and scope"
          verification: "Alert confirmed true positive"
        
        - step: "Immediate Containment (Infrastructure Engineer)"
          time: "T+5 minutes"
          actions:
            - "Isolate affected network segments (Calico network policies)"
            - "Isolate affected endpoints (CrowdStrike containment)"
            - "Disable user accounts if compromised"
          verification: "Systems isolated from network"
        
        - step: "Forensic Analysis (Forensics Analyst)"
          time: "T+30 minutes"
          actions:
            - "Collect evidence (logs, memory dumps, file hashes)"
            - "Identify ransomware variant"
            - "Determine entry vector"
          verification: "Evidence collected and preserved"
        
        - step: "Eradication (Infrastructure Engineer)"
          time: "T+2 hours"
          actions:
            - "Restore from immutable backups (AWS S3 Object Lock)"
            - "Reimage affected systems"
            - "Patch vulnerabilities"
          verification: "Systems restored and functional"
        
        - step: "Recovery (Infrastructure Engineer)"
          time: "T+4 hours"
          actions:
            - "Bring restored systems online"
            - "Validate data integrity"
            - "Monitor for re-infection"
          verification: "Systems operational, no ransomware activity"
        
        - step: "Post-Incident (IR Manager)"
          time: "T+72 hours"
          actions:
            - "Conduct post-mortem"
            - "Update playbooks and detection rules"
            - "Report to leadership"
          verification: "Post-mortem complete, improvements identified"

# End of Respond Function
```

**Verification:**

```bash
# Verify respond file
ls -la nist_csf/05_respond_playbooks.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('nist_csf/05_respond_playbooks.yaml'))"
# Expected: No error output

# Check for playbooks
grep -c "playbook_name:" nist_csf/05_respond_playbooks.yaml
# Expected: Shows 6+ playbooks
```

---

### Step 7: Recover Function - Recovery Plans

The Recover function restores capabilities and services impaired by an incident.

**File:** `nist_csf/06_recover_plans.yaml`

```yaml
# NIST CSF 2.0 - Recover Function
# Nexus Global Industries
# Version: 1.0

recover:
  # ================================================================
  # RC.RP: Recovery Planning
  # ================================================================
  recovery_planning:
    plan_name: "Business Continuity and Disaster Recovery Plan (BCDR)"
    version: "2.0"
    owner: "Lead Enterprise Security Architect"
    last_updated: "2026-08-02"
    review_frequency: "Bi-annual (DR tests)"
    
    RTO_RPO_targets:
      tier_0_critical:
        description: "Business-critical systems (manufacturing, customer portal)"
        RTO: "2 hours"
        RPO: "15 minutes"
        systems: 
          - "Manufacturing OT systems"
          - "Customer portal"
          - "Payment processing"
          - "R&D IP repositories"
      
      tier_1_high:
        description: "High-impact systems (ERP, HR, collaboration)"
        RTO: "4 hours"
        RPO: "1 hour"
        systems:
          - "ERP and financial"
          - "Employee HR systems"
          - "Internal collaboration"
      
      tier_2_medium:
        description: "Medium-impact systems (internal tooling, non-critical)"
        RTO: "8 hours"
        RPO: "4 hours"
        systems:
          - "Internal tooling"
          - "Non-critical applications"
          - "Development environments"
      
      tier_3_low:
        description: "Low-impact systems (public-facing informational)"
        RTO: "24 hours"
        RPO: "24 hours"
        systems:
          - "Public-facing informational"
          - "Archival data"
          - "Non-sensitive systems"
    
    backup_strategy:
      frequency:
        - "Critical data: Continuous (via replication), hourly snapshots"
        - "High data: Hourly snapshots"
        - "Medium data: Daily snapshots"
        - "Low data: Weekly snapshots"
      
      retention:
        - "Critical data: 30 days (hot), 365 days (cold)"
        - "High data: 30 days (hot), 90 days (cold)"
        - "Medium data: 30 days (hot)"
        - "Low data: 30 days (hot)"
      
      locations:
        - "Primary: AWS S3 (hot storage)"
        - "Secondary: Azure Blob (replicated)"
        - "Tertiary: AWS S3 Glacier Deep Archive (air-gapped)"
      
      immutability:
        - "All critical backups: S3 Object Lock enabled (WORM)"
        - "Retention: 30-day minimum (configurable)"
        - "Legal hold: Immutable"

  # ================================================================
  # RC.IM: Improvements
  # ================================================================
  recovery_improvements:
    improvement_cycles:
      - cycle: "DR Testing"
        frequency: "Quarterly"
        scope: "Tier-0 and Tier-1 systems"
        methodology: "Tabletop exercises + Actual failover tests"
        success_criteria:
          - "RTO met (< 2 hours for Tier-0)"
          - "RPO met (< 15 minutes for Tier-0)"
          - "Data integrity verified"
          - "All systems functional"
      
      - cycle: "Chaos Testing"
        frequency: "Monthly (staging), Quarterly (production)"
        scope: "All critical systems"
        methodology: "Gremlin + Chaos Mesh"
        success_criteria:
          - "Auto-recovery (100% success)"
          - "RTO within targets"
          - "No data loss"
      
      - cycle: "Recovery Report"
        frequency: "Post-test (immediate)"
        owners: "Infrastructure Engineer + Lead Architect"
        actions:
          - "Identify failures (if any)"
          - "Improve runbooks and playbooks"
          - "Update architecture (if needed)"
    
    recovery_verification:
      process: "Post-recovery validation"
      checks:
        - "Data integrity: Checksum validation, application testing"
        - "Functionality: Smoke tests, health endpoints"
        - "Security: Policy enforcement, access controls verified"
        - "Performance: Response times, throughput within acceptable range"
      documentation: "Recovery report produced for every test"

  # ================================================================
  # RC.RI: Recovery Infrastructure
  # ================================================================
  recovery_infrastructure:
    multi_region:
      regions:
        - region: "AWS us-east-1 (primary)"
          purpose: "Primary production"
        - region: "AWS us-west-2 (secondary)"
          purpose: "Disaster recovery failover"
        - region: "Azure eastus (tertiary)"
          purpose: "Cross-cloud failover"
    
    disaster_recovery_architecture:
      active_active:
        - "Non-critical workloads: Active-Active (load balanced)"
        - "Database: Active-Passive (replicated)"
        - "Object storage: Replicated (cross-region)"
      failover_mechanism:
        - "DNS-based (Route 53, Azure Traffic Manager)"
        - "Health checks (automatic failover)"
        - "Manual override (for controlled failover)"
    
    immutable_backups:
      strategy: "WORM (Write-Once-Read-Many) protected"
      tools:
        - "AWS S3 Object Lock (compliance mode)"
        - "Azure Immutable Blob (legal hold)"
      retention:
        - "Minimum: 30 days (critical backups)"
        - "Maximum: 365 days (archived backups)"
      recovery_process:
        - "Request access (approved by 2 persons)"
        - "Retrieve from S3 Glacier Deep Archive (24-hour retrieval)"
        - "Restore to production environment"
        - "Validate data integrity"

  # ================================================================
  # RC.RC: Recovery Communications
  # ================================================================
  recovery_comms:
    internal_comms:
      strategy: "Keep all stakeholders informed of recovery progress"
      channels:
        - "Slack (recovery channel)"
        - "Email (status updates)"
        - "All-hands (major incidents, after recovery)"
      templates:
        - "Recovery initiated (within 10 minutes of DR activation)"
        - "Recovery progress update (every 30 minutes)"
        - "Recovery complete (notification)"
        - "Post-recovery review (72 hours later)"
    
    external_comms:
      strategy: "Transparent but controlled communication"
      customers:
        - "If customer services affected: Notification within 1 hour"
        - "If data breach: As per regulatory requirements"
        - "Status portal (public, accessible)"
      regulators:
        - "If breach: As per regulatory timeframe (e.g., 72 hours for GDPR)"
        - "If operational impact: As per local regulations"
      partners:
        - "If supply chain affected: Notification within 1 day"
        - "Collaborative recovery (where applicable)"

  # ================================================================
  # Detailed Recovery Plan Example
  # ================================================================
  detailed_plan:
    plan_name: "Recovery Plan for Tier-0 Systems (Manufacturing and Customer Portal)"
    plan_id: "RC-001"
    version: "1.0"
    
    scenario: "Major incident requiring failover to disaster recovery site"
    
    preparation:
      - "Ensure backups are current and verified"
      - "Verify DR infrastructure is ready"
      - "Test recovery playbooks in staging"
    
    steps:
      - step: "Declare Disaster"
        owner: "Incident Response Manager"
        timing: "Immediate (within 5 minutes of incident classification)"
        actions:
          - "Validate that RTO/RPO targets are at risk"
          - "Obtain approval from CISO"
          - "Initiate DR failover plan"
      
      - step: "Failover DNS"
        owner: "Infrastructure Engineer"
        timing: "Within 10 minutes of disaster declaration"
        actions:
          - "Update Route 53 records (AWS us-east-1 → us-west-2)"
          - "Flush DNS caches"
          - "Monitor DNS propagation"
      
      - step: "Activate Secondary Region"
        owner: "Infrastructure Engineer"
        timing: "Within 30 minutes of DNS failover"
        actions:
          - "Scale up Kubernetes clusters in us-west-2"
          - "Restore databases from recent backups"
          - "Apply configuration (Terraform, manifests)"
      
      - step: "Validate Recovery"
        owner: "Infrastructure Engineer + Application Engineer"
        timing: "Within 1 hour of DR activation"
        actions:
          - "Run smoke tests (health endpoints, critical APIs)"
          - "Validate data integrity (checksums, app validation)"
          - "Monitor application logs for errors"
      
      - step: "Resume Operations"
        owner: "All teams"
        timing: "Within 2 hours of DR activation (RTO target)"
        actions:
          - "Declare operations resumed"
          - "Monitor performance and stability"
          - "Begin post-recovery review"

    post_recovery:
      - "Conduct recovery review (within 72 hours)"
      - "Document lessons learned"
      - "Update recovery playbooks"
      - "Restore primary region (if permanent failure)"

# End of Recover Function
```

**Verification:**

```bash
# Verify recover file
ls -la nist_csf/06_recover_plans.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('nist_csf/06_recover_plans.yaml'))"
# Expected: No error output

# Check for RTO/RPO targets
grep -c "RTO:" nist_csf/06_recover_plans.yaml
# Expected: Shows 4 RTO targets (tiers 0-3)
```

---

### Step 8: CSF-SABSA Cross-Mapping

The CSF-SABSA cross-mapping connects the NIST CSF functions to the SABSA layers, showing how they complement each other.

**File:** `nist_csf/07_csf_sabsa_mapping.csv`

```csv
"NIST CSF Function","NIST CSF Category","SABSA Layer","SABSA Element","Implementation Artifact"
"GOVERN","GV.OC (Organizational Context)","Contextual","Business Requirements","sabsa_framework/01_contextual_architecture.md"
"GOVERN","GV.RM (Risk Management Strategy)","Contextual","Risk Environment","sabsa_framework/01_contextual_architecture.md"
"GOVERN","GV.RR (Roles & Responsibilities)","Operational","Governance","sabsa_framework/06_operational_architecture.md"
"GOVERN","GV.PO (Policies & Procedures)","Operational","Policy Management","sabsa_framework/06_operational_architecture.md"
"GOVERN","GV.OV (Oversight)","Operational","Security Governance Committee","sabsa_framework/06_operational_architecture.md"
"GOVERN","GV.SC (Supply Chain Risk Management)","Logical","Third-party Management","sabsa_framework/03_logical_architecture.csv"
"GOVERN","GV.AW (Awareness & Training)","Operational","Security Training","sabsa_framework/06_operational_architecture.md"
"GOVERN","GV.FI (Feedback & Improvement)","Operational","Continuous Improvement","sabsa_framework/06_operational_architecture.md"
"IDENTIFY","ID.AM (Asset Management)","Conceptual","Asset Inventory","sabsa_framework/02_conceptual_architecture.md"
"IDENTIFY","ID.RA (Risk Assessment)","Contextual","Risk Assessment","sabsa_framework/01_contextual_architecture.md"
"IDENTIFY","ID.BE (Business Environment)","Contextual","Business Drivers","sabsa_framework/01_contextual_architecture.md"
"IDENTIFY","ID.GV (Governance & Risk)","Operational","Risk Management","sabsa_framework/06_operational_architecture.md"
"IDENTIFY","ID.IM (Improvement)","Operational","Maturity Assessment","sabsa_framework/06_operational_architecture.md"
"PROTECT","PR.AC (Access Control)","Logical","Identity & Access Management","sabsa_framework/03_logical_architecture.csv"
"PROTECT","PR.AT (Awareness & Training)","Operational","Security Training","sabsa_framework/06_operational_architecture.md"
"PROTECT","PR.DS (Data Security)","Logical","Data Protection","sabsa_framework/03_logical_architecture.md"
"PROTECT","PR.IP (Information Protection)","Logical","Information Protection Processes","sabsa_framework/03_logical_architecture.md"
"PROTECT","PR.MA (Maintenance)","Operational","Patch & Vulnerability Management","sabsa_framework/06_operational_architecture.md"
"PROTECT","PR.ND (Network Security)","Logical","Network Segmentation","sabsa_framework/03_logical_architecture.md"
"PROTECT","PR.IR (Incident Response)","Operational","IR Playbooks","sabsa_framework/06_operational_architecture.md"
"DETECT","DE.AE (Anomalies & Events)","Logical","Anomaly Detection","sabsa_framework/03_logical_architecture.md"
"DETECT","DE.CM (Continuous Monitoring)","Physical","Monitoring Tools","sabsa_framework/04_physical_architecture.md"
"DETECT","DE.DP (Detection Processes)","Operational","Detection Engineering","sabsa_framework/06_operational_architecture.md"
"DETECT","DE.AR (Anomaly Response)","Operational","Alerting & Escalation","sabsa_framework/06_operational_architecture.md"
"DETECT","DE.DU (Detection Unauthorized)","Logical","UBA & Malware Detection","sabsa_framework/03_logical_architecture.md"
"DETECT","DE.SR (Security Monitoring)","Physical","Monitoring Tools","sabsa_framework/04_physical_architecture.md"
"RESPOND","RS.RP (Response Planning)","Operational","IR Planning","sabsa_framework/06_operational_architecture.md"
"RESPOND","RS.AN (Analysis)","Operational","Forensics & Triage","sabsa_framework/06_operational_architecture.md"
"RESPOND","RS.MI (Mitigation)","Operational","Containment & Eradication","sabsa_framework/06_operational_architecture.md"
"RESPOND","RS.IM (Improvement)","Operational","Post-Incident Review","sabsa_framework/06_operational_architecture.md"
"RESPOND","RS.CO (Communications)","Operational","Crisis Communications","sabsa_framework/06_operational_architecture.md"
"RECOVER","RC.RP (Recovery Planning)","Operational","BCDR Planning","sabsa_framework/06_operational_architecture.md"
"RECOVER","RC.IM (Improvements)","Operational","DR Testing & Improvement","sabsa_framework/06_operational_architecture.md"
"RECOVER","RC.RI (Recovery Infrastructure)","Physical","DR Infrastructure","sabsa_framework/04_physical_architecture.md"
"RECOVER","RC.RC (Recovery Communications)","Operational","Recovery Communications","sabsa_framework/06_operational_architecture.md"
```

**Verification:**

```bash
# Verify CSF-SABSA mapping file
ls -la nist_csf/07_csf_sabsa_mapping.csv
# Expected: File exists

# Count mapping entries (should have 35+ rows)
wc -l nist_csf/07_csf_sabsa_mapping.csv
# Expected: Shows 35+ lines (including header)
```

---

### Step 9: CSF Implementation Summary

**File:** `nist_csf/README.md`

```markdown
# Nexus Global Industries - NIST CSF 2.0 Implementation

## Overview

This directory contains the complete NIST Cybersecurity Framework (CSF) 2.0 implementation for Nexus Global Industries. The CSF 2.0 provides a risk-based approach to managing cybersecurity risk, organized around six core functions.

## Directory Structure

| File | CSF Function | Description |
|------|--------------|-------------|
| `01_governance_policies.yaml` | Govern (GV) | Cybersecurity strategy, oversight, and policies |
| `02_identify_assets.yaml` | Identify (ID) | Asset inventory, risk assessment, business context |
| `03_protect_controls.yaml` | Protect (PR) | Safeguards, access control, data security |
| `04_detect_capabilities.yaml` | Detect (DE) | Monitoring, detection engineering, threat hunting |
| `05_respond_playbooks.yaml` | Respond (RS) | Incident response, playbooks, mitigation |
| `06_recover_plans.yaml` | Recover (RC) | Recovery planning, DR, BCDR |
| `07_csf_sabsa_mapping.csv` | All | Cross-mapping between CSF and SABSA |

## CSF 2.0 Functions Overview

### Govern (GV)
- Organizational context, risk management strategy
- Roles, responsibilities, and authorities
- Policies, processes, and procedures
- Oversight and governance
- Supply chain risk management
- Awareness and training
- Feedback and continuous improvement

### Identify (ID)
- Asset management (physical, digital, data)
- Risk assessment and register
- Business environment and critical services
- Governance and risk management
- Impact analysis and improvement

### Protect (PR)
- Access control (identity, authorization, PAM)
- Awareness and training
- Data security (classification, encryption, DLP)
- Information protection processes and procedures
- Maintenance
- Network security (Zero Trust, segmentation)

### Detect (DE)
- Anomalies and events (logging, analysis)
- Continuous monitoring (endpoint, network, cloud)
- Detection processes (engineering, threat hunting)
- Anomaly response (alerting, escalation)
- Detection of unauthorized activity
- Security continuous monitoring

### Respond (RS)
- Response planning (CSIRP)
- Analysis (triage, forensics, impact assessment)
- Mitigation (containment, eradication)
- Improvement (post-incident review)
- Communications (internal, external)

### Recover (RC)
- Recovery planning (BCDR)
- Improvements (DR testing, chaos testing)
- Recovery infrastructure (multi-region, immutable backups)
- Recovery communications

## CSF Maturity Status

| Function | Current Maturity | Target Maturity | Gap |
|----------|------------------|-----------------|-----|
| Govern | Level 3 (Defined) | Level 4 (Managed) | Improved metrics and oversight |
| Identify | Level 3 (Defined) | Level 4 (Managed) | Automated risk assessment |
| Protect | Level 3 (Defined) | Level 4 (Managed) | Full Zero Trust implementation |
| Detect | Level 2 (Repeatable) | Level 4 (Managed) | SOAR automation, ML-based detection |
| Respond | Level 2 (Repeatable) | Level 4 (Managed) | Automated playbooks, faster MTTR |
| Recover | Level 3 (Defined) | Level 4 (Managed) | Full chaos engineering adoption |

## Traceability

All CSF controls trace directly to:

1. **SABSA Framework**: See `07_csf_sabsa_mapping.csv` for cross-mapping
2. **ISO 27001**: Controls mapped to Annex A controls (see ISO 27001 ISMS)
3. **Regulatory Requirements**: GDPR, NIST 800-171, CCPA, etc.

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-08-02 | Lead Enterprise Security Architect | Initial creation |

## Review Status

| Function | Reviewed By | Date | Status |
|----------|-------------|------|--------|
| Govern | SARB | 2026-08-02 | Approved |
| Identify | SARB | 2026-08-02 | Approved |
| Protect | SARB | 2026-08-02 | Approved |
| Detect | SARB | 2026-08-02 | Approved |
| Respond | SARB | 2026-08-02 | Approved |
| Recover | SARB | 2026-08-02 | Approved |

---

**Maintained By**: Lead Enterprise Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Final Verification:**

```bash
# List all NIST CSF files
ls -la nist_csf/
# Expected: All 8 files present

# Count total files
ls -1 nist_csf/ | wc -l
# Expected: 8 files

# Validate all YAML files
for file in nist_csf/*.yaml; do
    echo "Validating $file"
    python3 -c "import yaml; yaml.safe_load(open('$file'))" && echo "✅ Valid" || echo "❌ Invalid"
done
# Expected: All YAML files valid

# Check mapping file
head -n 5 nist_csf/07_csf_sabsa_mapping.csv
# Expected: Shows header and first 4 mapping rows

# Verify README exists
cat nist_csf/README.md | grep "NIST CSF 2.0 Implementation"
# Expected: Shows README header

echo "✅ NIST CSF 2.0 Implementation Complete!"
echo "   - All 6 functions documented"
echo "   - 7 artifact files created"
echo "   - CSF-SABSA cross-mapping complete"
echo "   - README.md for reference"
```

---

**[GENERATED: Part 1, Section 1.2 - NIST CSF 2.0 Governance]**

**[COMPLETED: NIST CSF 2.0 Framework for Nexus Global Industries]**
- ✅ Govern Function - Organizational context, policies, oversight
- ✅ Identify Function - Asset inventory, risk assessment, business environment
- ✅ Protect Function - Access control, data security, network security
- ✅ Detect Function - Anomalies, monitoring, detection engineering
- ✅ Respond Function - Playbooks, analysis, mitigation
- ✅ Recover Function - Recovery planning, DR, BCDR
- ✅ CSF-SABSA Cross-Mapping - Complete traceability
- ✅ README.md - Framework documentation

---

## End of Section 1.2: NIST CSF 2.0 Governance

### Key Takeaway

You've implemented the complete NIST CSF 2.0 governance framework for Nexus Global Industries. The CSF 2.0's new Govern function provides the executive oversight and strategic direction that previous versions lacked. Combined with the SABSA framework from Section 1.1, you now have a comprehensive, integrated approach to security architecture and governance.

### What's Next

In **Section 1.3**, we'll implement the **ISO/IEC 27001 Information Security Management System (ISMS)**, including:
- Risk assessment methodology and treatment
- Statement of Applicability (SoA)
- Annex A control mapping
- Integration with SABSA and CSF

The implementation continues with complete documentation, control mapping, and verification steps.
