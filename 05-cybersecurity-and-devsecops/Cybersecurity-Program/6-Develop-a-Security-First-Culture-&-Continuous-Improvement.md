# Part 6: Develop a Security-First Culture & Continuous Improvement

## Learning Objectives

By completing this tutorial, you will:

- Build a security-first organizational culture through awareness programs
- Implement continuous security education and training
- Deploy phishing simulations and human risk management
- Develop insider threat awareness and blameless reporting cultures
- Establish security champions programs
- Create comprehensive cybersecurity Key Performance Indicators (KPIs) and Key Risk Indicators (KRIs)
- Build security scorecards and executive dashboards
- Implement capability maturity models for continuous improvement
- Establish a continuous improvement framework aligned with NIST CSF and CMMI

## Key Concepts & Frameworks

### The Security Culture Journey

Think of security culture like building a healthy lifestyle. It's not about one diet or exercise plan—it's about embedding healthy habits into daily life. Similarly, security culture is about making security part of how everyone works, thinks, and makes decisions.

**The Security Culture Maturity Model:**

```
Level 1: Compliance-Driven
   └── People follow rules because they have to
Level 2: Awareness-Driven
   └── People know about security risks
Level 3: Behavior-Driven
   └── People consistently practice secure behaviors
Level 4: Culture-Driven
   └── Security is part of the organizational DNA
Level 5: Resilient Culture
   └── Security is continuously improved and adapted
```

### Core Frameworks We'll Use

**NIST CSF 2.0 - Govern (GV)**
- GV.OC: Organizational culture and awareness
- GV.IP: Information security program strategy

**ISO/IEC 27001:2022**
- A.6.3: Information security awareness, education, and training
- A.7.2.2: Information security awareness
- A.7.2.3: Disciplinary process

**CMMI (Capability Maturity Model Integration)**
- Maturity Levels 1-5 for security program capability

## Hands-On Implementation

### Step 1: Security Awareness Program

**The Target:** Build a comprehensive security awareness program with training, phishing simulations, and engagement metrics.

**The Concept:** Security awareness is like teaching defensive driving—you don't just tell people to be safe, you practice scenarios, measure behavior, and continuously improve.

**File:** `06-culture-improvement/scripts/security_awareness.py`

```python
#!/usr/bin/env python3
"""
Security Awareness Program Management

This module implements comprehensive security awareness including:
- Training management and delivery
- Phishing simulation campaigns
- Engagement metrics and tracking
- Behavioral analytics
- Program effectiveness measurement
"""

import json
import datetime
import hashlib
import secrets
from typing import Dict, List, Optional, Any, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum
import os
import random
import csv


class TrainingModule(Enum):
    """Security training modules."""
    SECURITY_BASICS = "security_basics"
    PHISHING_AWARENESS = "phishing_awareness"
    PASSWORD_SECURITY = "password_security"
    DATA_PROTECTION = "data_protection"
    SOCIAL_ENGINEERING = "social_engineering"
    INCIDENT_REPORTING = "incident_reporting"
    REMOTE_WORK = "remote_work_security"
    PHYSICAL_SECURITY = "physical_security"
    INSIDER_THREAT = "insider_threat"
    GDPR_COMPLIANCE = "gdpr_compliance"


class TrainingStatus(Enum):
    """Status of training completion."""
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    EXPIRED = "expired"
    FAILED = "failed"


class PhishingResult(Enum):
    """Results of phishing simulation."""
    CLICKED = "clicked"
    REPORTED = "reported"
    IGNORED = "ignored"
    SUBMITTED_DATA = "submitted_data"
    OPENED_ATTACHMENT = "opened_attachment"


@dataclass
class UserTraining:
    """
    User training record.
    
    Attributes:
        user_id: User identifier
        training_module: Training module
        status: Training status
        start_date: Training start date
        completion_date: Training completion date
        score: Assessment score
        attempts: Number of attempts
    """
    user_id: str
    training_module: str
    status: str = TrainingStatus.NOT_STARTED.value
    start_date: Optional[str] = None
    completion_date: Optional[str] = None
    score: int = 0
    attempts: int = 0
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "user_id": self.user_id,
            "training_module": self.training_module,
            "status": self.status,
            "start_date": self.start_date,
            "completion_date": self.completion_date,
            "score": self.score,
            "attempts": self.attempts
        }


@dataclass
class PhishingCampaign:
    """
    Phishing simulation campaign.
    
    Attributes:
        campaign_id: Unique identifier
        name: Campaign name
        description: Campaign description
        template: Phishing email template
        target_users: List of user IDs
        sent_date: When emails were sent
        results: Results by user
        metrics: Campaign metrics
        status: Campaign status
    """
    campaign_id: str
    name: str
    description: str
    template: Dict
    target_users: List[str]
    sent_date: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat())
    results: Dict[str, str] = field(default_factory=dict)
    metrics: Dict[str, Any] = field(default_factory=dict)
    status: str = "scheduled"
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "campaign_id": self.campaign_id,
            "name": self.name,
            "description": self.description,
            "template": self.template,
            "target_users": self.target_users,
            "sent_date": self.sent_date,
            "results": self.results,
            "metrics": self.metrics,
            "status": self.status
        }


class SecurityAwarenessProgram:
    """
    Security Awareness Program Management.
    
    This class handles training delivery, phishing simulations,
    engagement tracking, and program effectiveness measurement.
    """
    
    def __init__(self, data_dir: str = "./awareness_data"):
        """
        Initialize Security Awareness Program.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.user_training: Dict[str, List[UserTraining]] = {}
        self.phishing_campaigns: Dict[str, PhishingCampaign] = {}
        self.engagement_metrics: Dict[str, Any] = {}
        self.audit_log: List[Dict] = []
        
        self._load_data()
        self._init_default_training()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/training", exist_ok=True)
        os.makedirs(f"{self.data_dir}/phishing", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
        os.makedirs(f"{self.data_dir}/reports", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load training records
        training_dir = f"{self.data_dir}/training"
        if os.path.exists(training_dir):
            for filename in os.listdir(training_dir):
                if filename.endswith('.json'):
                    with open(f"{training_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        user_training = []
                        for training_data in data.get('training', []):
                            ut = UserTraining(
                                user_id=training_data['user_id'],
                                training_module=training_data['training_module'],
                                status=training_data.get('status', TrainingStatus.NOT_STARTED.value),
                                start_date=training_data.get('start_date'),
                                completion_date=training_data.get('completion_date'),
                                score=training_data.get('score', 0),
                                attempts=training_data.get('attempts', 0)
                            )
                            user_training.append(ut)
                        self.user_training[data['user_id']] = user_training
        
        # Load phishing campaigns
        phishing_dir = f"{self.data_dir}/phishing"
        if os.path.exists(phishing_dir):
            for filename in os.listdir(phishing_dir):
                if filename.endswith('.json'):
                    with open(f"{phishing_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        campaign = PhishingCampaign(
                            campaign_id=data['campaign_id'],
                            name=data['name'],
                            description=data['description'],
                            template=data['template'],
                            target_users=data['target_users'],
                            sent_date=data.get('sent_date', datetime.datetime.utcnow().isoformat()),
                            results=data.get('results', {}),
                            metrics=data.get('metrics', {}),
                            status=data.get('status', 'scheduled')
                        )
                        self.phishing_campaigns[campaign.campaign_id] = campaign
        
        # Load engagement metrics
        metrics_file = f"{self.data_dir}/metrics.json"
        if os.path.exists(metrics_file):
            with open(metrics_file, 'r') as f:
                self.engagement_metrics = json.load(f)
    
    def _save_training(self, user_id: str) -> None:
        """Save user training records."""
        if user_id in self.user_training:
            data = {
                "user_id": user_id,
                "training": [t.to_dict() for t in self.user_training[user_id]]
            }
            with open(f"{self.data_dir}/training/{user_id}.json", 'w') as f:
                json.dump(data, f, indent=2)
    
    def _save_campaign(self, campaign: PhishingCampaign) -> None:
        """Save phishing campaign."""
        with open(f"{self.data_dir}/phishing/{campaign.campaign_id}.json", 'w') as f:
            json.dump(campaign.to_dict(), f, indent=2)
    
    def _save_metrics(self) -> None:
        """Save engagement metrics."""
        with open(f"{self.data_dir}/metrics.json", 'w') as f:
            json.dump(self.engagement_metrics, f, indent=2)
    
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
    
    def _init_default_training(self) -> None:
        """Initialize default training modules."""
        # Default training modules are defined in TrainingModule enum
        pass
    
    def create_training_assignment(self, user_id: str, 
                                   training_module: str) -> UserTraining:
        """
        Assign training to a user.
        
        Args:
            user_id: User ID
            training_module: Training module
            
        Returns:
            Created UserTraining
        """
        if user_id not in self.user_training:
            self.user_training[user_id] = []
        
        # Check if already assigned
        existing = next((t for t in self.user_training[user_id] 
                        if t.training_module == training_module), None)
        if existing:
            return existing
        
        training = UserTraining(
            user_id=user_id,
            training_module=training_module,
            start_date=datetime.datetime.utcnow().isoformat()
        )
        
        self.user_training[user_id].append(training)
        self._save_training(user_id)
        self._log_audit("TRAINING_ASSIGNED", user_id, {"module": training_module})
        
        return training
    
    def complete_training(self, user_id: str, training_module: str, 
                          score: int) -> bool:
        """
        Mark training as completed.
        
        Args:
            user_id: User ID
            training_module: Training module
            score: Assessment score
            
        Returns:
            True if training marked complete
        """
        if user_id not in self.user_training:
            return False
        
        for training in self.user_training[user_id]:
            if training.training_module == training_module:
                training.status = TrainingStatus.COMPLETED.value
                training.completion_date = datetime.datetime.utcnow().isoformat()
                training.score = score
                training.attempts += 1
                
                self._save_training(user_id)
                self._log_audit("TRAINING_COMPLETED", user_id, {
                    "module": training_module,
                    "score": score
                })
                
                return True
        
        return False
    
    def get_training_status(self, user_id: str) -> Dict:
        """
        Get training status for a user.
        
        Args:
            user_id: User ID
            
        Returns:
            Training status summary
        """
        if user_id not in self.user_training:
            return {"user_id": user_id, "trainings": [], "completion_rate": 0}
        
        trainings = self.user_training[user_id]
        completed = sum(1 for t in trainings if t.status == TrainingStatus.COMPLETED.value)
        
        return {
            "user_id": user_id,
            "trainings": [t.to_dict() for t in trainings],
            "total": len(trainings),
            "completed": completed,
            "completion_rate": (completed / len(trainings) * 100) if trainings else 0
        }
    
    def create_phishing_campaign(self, name: str, description: str,
                                 template: Dict, target_users: List[str]) -> PhishingCampaign:
        """
        Create a phishing simulation campaign.
        
        Args:
            name: Campaign name
            description: Campaign description
            template: Email template
            target_users: List of user IDs
            
        Returns:
            Created PhishingCampaign
        """
        campaign_id = f"CAMP-{datetime.datetime.utcnow().strftime('%Y%m%d')}-{secrets.token_hex(4)}"
        
        campaign = PhishingCampaign(
            campaign_id=campaign_id,
            name=name,
            description=description,
            template=template,
            target_users=target_users
        )
        
        self.phishing_campaigns[campaign_id] = campaign
        self._save_campaign(campaign)
        self._log_audit("PHISHING_CAMPAIGN_CREATED", "system", {
            "campaign_id": campaign_id,
            "name": name,
            "target_users": len(target_users)
        })
        
        return campaign
    
    def simulate_phishing(self, campaign_id: str, user_id: str, 
                          action: str) -> bool:
        """
        Simulate user response to phishing email.
        
        Args:
            campaign_id: Campaign ID
            user_id: User ID
            action: User action (clicked, reported, ignored, etc.)
            
        Returns:
            True if simulation recorded
        """
        campaign = self.phishing_campaigns.get(campaign_id)
        if not campaign:
            return False
        
        if user_id not in campaign.target_users:
            return False
        
        if action not in [r.value for r in PhishingResult]:
            return False
        
        campaign.results[user_id] = action
        
        # Update metrics
        self._update_campaign_metrics(campaign)
        self._save_campaign(campaign)
        
        self._log_audit("PHISHING_SIMULATION", user_id, {
            "campaign_id": campaign_id,
            "action": action
        })
        
        return True
    
    def _update_campaign_metrics(self, campaign: PhishingCampaign) -> None:
        """
        Update campaign metrics based on results.
        
        Args:
            campaign: PhishingCampaign
        """
        total = len(campaign.target_users) if campaign.target_users else 1
        results = campaign.results
        
        # Count results
        clicked = sum(1 for r in results.values() if r == PhishingResult.CLICKED.value)
        reported = sum(1 for r in results.values() if r == PhishingResult.REPORTED.value)
        ignored = sum(1 for r in results.values() if r == PhishingResult.IGNORED.value)
        submitted = sum(1 for r in results.values() if r == PhishingResult.SUBMITTED_DATA.value)
        opened = sum(1 for r in results.values() if r == PhishingResult.OPENED_ATTACHMENT.value)
        
        responded = clicked + reported + submitted + opened
        
        campaign.metrics = {
            "total_recipients": len(campaign.target_users),
            "total_responded": responded,
            "clicked": clicked,
            "click_rate": (clicked / total * 100) if total > 0 else 0,
            "reported": reported,
            "report_rate": (reported / total * 100) if total > 0 else 0,
            "ignored": ignored,
            "submitted_data": submitted,
            "opened_attachments": opened,
            "response_rate": (responded / total * 100) if total > 0 else 0,
            "risk_score": self._calculate_risk_score(campaign)
        }
    
    def _calculate_risk_score(self, campaign: PhishingCampaign) -> float:
        """
        Calculate risk score for phishing campaign.
        
        Args:
            campaign: PhishingCampaign
            
        Returns:
            Risk score (0-100)
        """
        results = campaign.results
        if not results:
            return 0
        
        # Weight different actions
        weights = {
            PhishingResult.CLICKED.value: 10,
            PhishingResult.SUBMITTED_DATA.value: 20,
            PhishingResult.OPENED_ATTACHMENT.value: 15,
            PhishingResult.REPORTED.value: -5,  # Good behavior
            PhishingResult.IGNORED.value: 0
        }
        
        total_score = sum(weights.get(r, 0) for r in results.values())
        total_users = len(results) or 1
        
        # Normalize to 0-100
        raw_score = total_score / total_users
        normalized_score = min(100, max(0, raw_score))
        
        return normalized_score
    
    def generate_awareness_report(self) -> str:
        """
        Generate security awareness report.
        
        Returns:
            Markdown formatted report
        """
        # Calculate training metrics
        total_users = len(self.user_training)
        total_trainings = sum(len(trainings) for trainings in self.user_training.values())
        completed_trainings = sum(
            sum(1 for t in trainings if t.status == TrainingStatus.COMPLETED.value)
            for trainings in self.user_training.values()
        )
        
        # Calculate phishing metrics
        total_campaigns = len(self.phishing_campaigns)
        total_phishing_responses = sum(
            len(c.results) for c in self.phishing_campaigns.values()
        )
        
        # Get campaign stats
        campaign_stats = []
        for campaign in self.phishing_campaigns.values():
            if campaign.metrics:
                campaign_stats.append({
                    "name": campaign.name,
                    "click_rate": campaign.metrics.get('click_rate', 0),
                    "report_rate": campaign.metrics.get('report_rate', 0),
                    "risk_score": campaign.metrics.get('risk_score', 0)
                })
        
        report = f"""
# Security Awareness Program Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Users | {total_users} |
| Total Training Assignments | {total_trainings} |
| Training Completion Rate | {(completed_trainings/total_trainings*100) if total_trainings > 0 else 0:.1f}% |
| Phishing Campaigns | {total_campaigns} |
| Phishing Responses | {total_phishing_responses} |

## Training Completion

| Status | Count |
|--------|-------|
| Not Started | {sum(1 for trainings in self.user_training.values() for t in trainings if t.status == TrainingStatus.NOT_STARTED.value)} |
| In Progress | {sum(1 for trainings in self.user_training.values() for t in trainings if t.status == TrainingStatus.IN_PROGRESS.value)} |
| Completed | {completed_trainings} |
| Failed | {sum(1 for trainings in self.user_training.values() for t in trainings if t.status == TrainingStatus.FAILED.value)} |

## Phishing Campaign Results

| Campaign | Click Rate | Report Rate | Risk Score |
|----------|------------|-------------|------------|
"""
        
        for stat in campaign_stats[-5:]:  # Last 5 campaigns
            report += f"| {stat['name']} | {stat['click_rate']:.1f}% | {stat['report_rate']:.1f}% | {stat['risk_score']:.1f} |\n"
        
        if not campaign_stats:
            report += "| *No campaigns completed* | | | |\n"
        
        report += """
## Risk Score Trend

"""
        
        if campaign_stats:
            report += "```\n"
            for stat in campaign_stats[-10:]:
                bars = "█" * int(stat['risk_score'] / 5)
                report += f"{stat['name'][:20]:20} | {stat['risk_score']:5.1f} {bars}\n"
            report += "```\n"
        
        return report


def main():
    """CLI for security awareness management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Security Awareness Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Assign training
    assign_parser = subparsers.add_parser('assign', help='Assign training')
    assign_parser.add_argument('--user', '-u', required=True, help='User ID')
    assign_parser.add_argument('--module', '-m', required=True, help='Training module')
    
    # Complete training
    complete_parser = subparsers.add_parser('complete', help='Complete training')
    complete_parser.add_argument('--user', '-u', required=True, help='User ID')
    complete_parser.add_argument('--module', '-m', required=True, help='Training module')
    complete_parser.add_argument('--score', '-s', type=int, default=80, help='Assessment score')
    
    # Training status
    status_parser = subparsers.add_parser('status', help='Get training status')
    status_parser.add_argument('--user', '-u', required=True, help='User ID')
    
    # Create phishing campaign
    campaign_parser = subparsers.add_parser('campaign', help='Create phishing campaign')
    campaign_parser.add_argument('--name', '-n', required=True, help='Campaign name')
    campaign_parser.add_argument('--description', '-d', required=True, help='Campaign description')
    campaign_parser.add_argument('--template', '-t', required=True, help='Template JSON')
    campaign_parser.add_argument('--users', '-u', nargs='+', required=True, help='Target users')
    
    # Simulate phishing
    simulate_parser = subparsers.add_parser('simulate', help='Simulate phishing response')
    simulate_parser.add_argument('--campaign', '-c', required=True, help='Campaign ID')
    simulate_parser.add_argument('--user', '-u', required=True, help='User ID')
    simulate_parser.add_argument('--action', '-a', required=True, help='User action')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    args = parser.parse_args()
    
    program = SecurityAwarenessProgram()
    
    if args.command == 'assign':
        training = program.create_training_assignment(args.user, args.module)
        print(f"✅ Training assigned to {args.user}")
        print(f"   Module: {args.module}")
        print(f"   Status: {training.status}")
    
    elif args.command == 'complete':
        if program.complete_training(args.user, args.module, args.score):
            print(f"✅ Training completed for {args.user}")
            print(f"   Module: {args.module}")
            print(f"   Score: {args.score}")
        else:
            print("❌ Training assignment not found")
    
    elif args.command == 'status':
        status = program.get_training_status(args.user)
        print(f"\nTraining Status for {status['user_id']}")
        print("=" * 50)
        print(f"Total: {status['total']}")
        print(f"Completed: {status['completed']}")
        print(f"Rate: {status['completion_rate']:.1f}%")
        
        if status['trainings']:
            print("\nDetails:")
            for training in status['trainings']:
                print(f"  {training['training_module']}: {training['status']}")
                if training.get('completion_date'):
                    print(f"    Completed: {training['completion_date'][:10]}")
                if training.get('score'):
                    print(f"    Score: {training['score']}%")
    
    elif args.command == 'campaign':
        try:
            template = json.loads(args.template)
        except json.JSONDecodeError:
            print("❌ Invalid template JSON")
            return
        
        campaign = program.create_phishing_campaign(
            args.name,
            args.description,
            template,
            args.users
        )
        print(f"✅ Phishing campaign created: {campaign.campaign_id}")
        print(f"   Name: {campaign.name}")
        print(f"   Target Users: {len(campaign.target_users)}")
    
    elif args.command == 'simulate':
        if program.simulate_phishing(args.campaign, args.user, args.action):
            print(f"✅ Simulation recorded for {args.user}")
            print(f"   Campaign: {args.campaign}")
            print(f"   Action: {args.action}")
        else:
            print("❌ Campaign or user not found")
    
    elif args.command == 'report':
        report = program.generate_awareness_report()
        print(report)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

### Step 2: Security Metrics, KPIs, and KRIs

**The Target:** Build comprehensive security metrics with KPIs, KRIs, and executive dashboards.

**The Concept:** Security metrics are like the dashboard in a car—they tell you speed (performance), fuel level (risk), and if anything's wrong (alerts). Good metrics help you make decisions and show progress.

**File:** `06-culture-improvement/scripts/security_metrics.py`

```python
#!/usr/bin/env python3
"""
Security Metrics, KPIs, and KRIs Management

This module implements comprehensive security metrics including:
- Key Performance Indicators (KPIs)
- Key Risk Indicators (KRIs)
- Executive dashboards
- Trend analysis
- Maturity scoring
- Goal tracking
"""

import json
import datetime
import hashlib
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field
from enum import Enum
import os
import math


class MetricType(Enum):
    """Types of security metrics."""
    KPI = "kpi"  # Key Performance Indicator
    KRI = "kri"  # Key Risk Indicator
    KCI = "kci"  # Key Control Indicator
    KBI = "kbi"  # Key Behavior Indicator


class MetricStatus(Enum):
    """Status of a metric."""
    GREEN = "green"  # On track
    YELLOW = "yellow"  # At risk
    RED = "red"  # Off track
    UNKNOWN = "unknown"


@dataclass
class SecurityMetric:
    """
    Security metric definition.
    
    Attributes:
        metric_id: Unique identifier
        name: Metric name
        description: Metric description
        metric_type: Type of metric
        category: Metric category
        formula: Calculation formula
        target: Target value
        threshold_warning: Warning threshold
        threshold_critical: Critical threshold
        frequency: Measurement frequency
        owner: Metric owner
    """
    metric_id: str
    name: str
    description: str
    metric_type: str
    category: str
    formula: str
    target: float
    threshold_warning: float
    threshold_critical: float
    frequency: str = "monthly"
    owner: str = ""
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "metric_id": self.metric_id,
            "name": self.name,
            "description": self.description,
            "metric_type": self.metric_type,
            "category": self.category,
            "formula": self.formula,
            "target": self.target,
            "threshold_warning": self.threshold_warning,
            "threshold_critical": self.threshold_critical,
            "frequency": self.frequency,
            "owner": self.owner
        }


@dataclass
class MetricMeasurement:
    """
    Metric measurement record.
    
    Attributes:
        measurement_id: Unique identifier
        metric_id: Associated metric
        value: Measured value
        timestamp: Measurement timestamp
        status: Measurement status
        notes: Additional notes
    """
    measurement_id: str
    metric_id: str
    value: float
    timestamp: str
    status: str = MetricStatus.UNKNOWN.value
    notes: str = ""
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "measurement_id": self.measurement_id,
            "metric_id": self.metric_id,
            "value": self.value,
            "timestamp": self.timestamp,
            "status": self.status,
            "notes": self.notes
        }


class SecurityMetricsManager:
    """
    Security Metrics Management System.
    
    This class handles metric definition, data collection,
    dashboard generation, and trend analysis.
    """
    
    def __init__(self, data_dir: str = "./metrics_data"):
        """
        Initialize Security Metrics Manager.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.metrics: Dict[str, SecurityMetric] = {}
        self.measurements: Dict[str, List[MetricMeasurement]] = {}
        self.dashboards: Dict[str, Any] = {}
        
        self._load_data()
        self._init_default_metrics()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/metrics", exist_ok=True)
        os.makedirs(f"{self.data_dir}/measurements", exist_ok=True)
        os.makedirs(f"{self.data_dir}/dashboards", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load metrics
        metrics_dir = f"{self.data_dir}/metrics"
        if os.path.exists(metrics_dir):
            for filename in os.listdir(metrics_dir):
                if filename.endswith('.json'):
                    with open(f"{metrics_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        metric = SecurityMetric(
                            metric_id=data['metric_id'],
                            name=data['name'],
                            description=data['description'],
                            metric_type=data['metric_type'],
                            category=data['category'],
                            formula=data['formula'],
                            target=data['target'],
                            threshold_warning=data['threshold_warning'],
                            threshold_critical=data['threshold_critical'],
                            frequency=data.get('frequency', 'monthly'),
                            owner=data.get('owner', '')
                        )
                        self.metrics[metric.metric_id] = metric
        
        # Load measurements
        measurements_dir = f"{self.data_dir}/measurements"
        if os.path.exists(measurements_dir):
            for filename in os.listdir(measurements_dir):
                if filename.endswith('.json'):
                    with open(f"{measurements_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        measurements = []
                        for m_data in data.get('measurements', []):
                            m = MetricMeasurement(
                                measurement_id=m_data['measurement_id'],
                                metric_id=m_data['metric_id'],
                                value=m_data['value'],
                                timestamp=m_data['timestamp'],
                                status=m_data.get('status', MetricStatus.UNKNOWN.value),
                                notes=m_data.get('notes', '')
                            )
                            measurements.append(m)
                        self.measurements[data['metric_id']] = measurements
    
    def _init_default_metrics(self) -> None:
        """Initialize default security metrics."""
        default_metrics = [
            SecurityMetric(
                metric_id="KPI-001",
                name="MFA Adoption Rate",
                description="Percentage of users with MFA enabled",
                metric_type=MetricType.KPI.value,
                category="Identity",
                formula="(Users with MFA / Total Users) * 100",
                target=95.0,
                threshold_warning=80.0,
                threshold_critical=60.0,
                frequency="monthly",
                owner="IAM Team"
            ),
            SecurityMetric(
                metric_id="KPI-002",
                name="Patch Compliance Rate",
                description="Percentage of systems patched within SLA",
                metric_type=MetricType.KPI.value,
                category="Operations",
                formula="(Patched Systems / Total Systems) * 100",
                target=95.0,
                threshold_warning=80.0,
                threshold_critical=70.0,
                frequency="weekly",
                owner="IT Operations"
            ),
            SecurityMetric(
                metric_id="KRI-001",
                name="Mean Time to Detect (MTTD)",
                description="Average time to detect a security incident",
                metric_type=MetricType.KRI.value,
                category="Detection",
                formula="Sum(Detection Times) / Number of Incidents",
                target=4.0,  # Hours
                threshold_warning=8.0,
                threshold_critical=24.0,
                frequency="monthly",
                owner="SOC Team"
            ),
            SecurityMetric(
                metric_id="KRI-002",
                name="Mean Time to Respond (MTTR)",
                description="Average time to respond to security incidents",
                metric_type=MetricType.KRI.value,
                category="Response",
                formula="Sum(Response Times) / Number of Incidents",
                target=2.0,  # Hours
                threshold_warning=4.0,
                threshold_critical=8.0,
                frequency="monthly",
                owner="Incident Response"
            ),
            SecurityMetric(
                metric_id="KPI-003",
                name="Phishing Click Rate",
                description="Percentage of users clicking on phishing simulations",
                metric_type=MetricType.KPI.value,
                category="Awareness",
                formula="(Phishing Clickers / Total Users) * 100",
                target=5.0,
                threshold_warning=10.0,
                threshold_critical=20.0,
                frequency="monthly",
                owner="Security Awareness"
            ),
            SecurityMetric(
                metric_id="KRI-003",
                name="Open Vulnerabilities",
                description="Number of open critical vulnerabilities",
                metric_type=MetricType.KRI.value,
                category="Operations",
                formula="Count of Open Critical Vulnerabilities",
                target=0.0,
                threshold_warning=5.0,
                threshold_critical=10.0,
                frequency="weekly",
                owner="Vulnerability Management"
            ),
            SecurityMetric(
                metric_id="KPI-004",
                name="Security Training Completion",
                description="Percentage of required security training completed",
                metric_type=MetricType.KPI.value,
                category="Awareness",
                formula="(Completed Trainings / Required Trainings) * 100",
                target=100.0,
                threshold_warning=90.0,
                threshold_critical=80.0,
                frequency="monthly",
                owner="Security Awareness"
            ),
            SecurityMetric(
                metric_id="KRI-004",
                name="Third-Party Risk Score",
                description="Average risk score of third-party vendors",
                metric_type=MetricType.KRI.value,
                category="Supply Chain",
                formula="Average of Vendor Risk Scores",
                target=20.0,
                threshold_warning=40.0,
                threshold_critical=60.0,
                frequency="monthly",
                owner="Vendor Risk"
            ),
            SecurityMetric(
                metric_id="KPI-005",
                name="Recovery Time Objective (RTO) Compliance",
                description="Percentage of systems meeting RTO",
                metric_type=MetricType.KPI.value,
                category="Recovery",
                formula="(Systems Meeting RTO / Total Systems) * 100",
                target=95.0,
                threshold_warning=80.0,
                threshold_critical=70.0,
                frequency="quarterly",
                owner="BCP/DR"
            ),
            SecurityMetric(
                metric_id="KRI-005",
                name="Security Incident Frequency",
                description="Number of security incidents per month",
                metric_type=MetricType.KRI.value,
                category="Detection",
                formula="Count of Security Incidents",
                target=2.0,
                threshold_warning=5.0,
                threshold_critical=10.0,
                frequency="monthly",
                owner="SOC Team"
            )
        ]
        
        for metric in default_metrics:
            if metric.metric_id not in self.metrics:
                self.metrics[metric.metric_id] = metric
                self._save_metric(metric)
    
    def _save_metric(self, metric: SecurityMetric) -> None:
        """Save metric definition."""
        with open(f"{self.data_dir}/metrics/{metric.metric_id}.json", 'w') as f:
            json.dump(metric.to_dict(), f, indent=2)
    
    def _save_measurements(self, metric_id: str) -> None:
        """Save measurements for a metric."""
        if metric_id in self.measurements:
            data = {
                "metric_id": metric_id,
                "measurements": [m.to_dict() for m in self.measurements[metric_id]]
            }
            with open(f"{self.data_dir}/measurements/{metric_id}.json", 'w') as f:
                json.dump(data, f, indent=2)
    
    def add_measurement(self, metric_id: str, value: float, 
                        notes: str = "") -> Optional[MetricMeasurement]:
        """
        Add a new measurement for a metric.
        
        Args:
            metric_id: Metric ID
            value: Measured value
            notes: Optional notes
            
        Returns:
            Created MetricMeasurement or None
        """
        if metric_id not in self.metrics:
            return None
        
        measurement_id = f"MEAS-{datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{metric_id}"
        
        measurement = MetricMeasurement(
            measurement_id=measurement_id,
            metric_id=metric_id,
            value=value,
            timestamp=datetime.datetime.utcnow().isoformat(),
            notes=notes
        )
        
        # Determine status
        metric = self.metrics[metric_id]
        if value >= metric.target:
            measurement.status = MetricStatus.GREEN.value
        elif value >= metric.threshold_warning:
            measurement.status = MetricStatus.YELLOW.value
        elif value >= metric.threshold_critical:
            measurement.status = MetricStatus.RED.value
        else:
            measurement.status = MetricStatus.RED.value
        
        if metric_id not in self.measurements:
            self.measurements[metric_id] = []
        
        self.measurements[metric_id].append(measurement)
        self._save_measurements(metric_id)
        
        return measurement
    
    def generate_dashboard(self, metric_ids: List[str] = None) -> Dict:
        """
        Generate executive dashboard.
        
        Args:
            metric_ids: List of metric IDs to include
            
        Returns:
            Dashboard data
        """
        if not metric_ids:
            metric_ids = list(self.metrics.keys())
        
        dashboard = {
            "generated": datetime.datetime.utcnow().isoformat(),
            "metrics": [],
            "summary": {
                "total_metrics": len(metric_ids),
                "green": 0,
                "yellow": 0,
                "red": 0
            },
            "trends": {}
        }
        
        for metric_id in metric_ids:
            if metric_id not in self.metrics:
                continue
            
            metric = self.metrics[metric_id]
            measurements = self.measurements.get(metric_id, [])
            
            if not measurements:
                continue
            
            latest = measurements[-1]
            
            metric_data = {
                "metric_id": metric.metric_id,
                "name": metric.name,
                "metric_type": metric.metric_type,
                "category": metric.category,
                "value": latest.value,
                "target": metric.target,
                "status": latest.status,
                "timestamp": latest.timestamp,
                "notes": latest.notes
            }
            
            dashboard["metrics"].append(metric_data)
            
            # Update summary
            if latest.status == MetricStatus.GREEN.value:
                dashboard["summary"]["green"] += 1
            elif latest.status == MetricStatus.YELLOW.value:
                dashboard["summary"]["yellow"] += 1
            elif latest.status == MetricStatus.RED.value:
                dashboard["summary"]["red"] += 1
            
            # Calculate trend
            if len(measurements) > 1:
                trend = self._calculate_trend(measurements)
                dashboard["trends"][metric_id] = trend
        
        return dashboard
    
    def _calculate_trend(self, measurements: List[MetricMeasurement]) -> str:
        """
        Calculate trend direction.
        
        Args:
            measurements: List of measurements
            
        Returns:
            Trend direction (up, down, stable)
        """
        if len(measurements) < 3:
            return "stable"
        
        values = [m.value for m in measurements[-5:]]
        if len(values) < 2:
            return "stable"
        
        # Simple linear regression slope
        n = len(values)
        x = list(range(n))
        y = values
        
        mean_x = sum(x) / n
        mean_y = sum(y) / n
        
        numerator = sum((x[i] - mean_x) * (y[i] - mean_y) for i in range(n))
        denominator = sum((x[i] - mean_x) ** 2 for i in range(n))
        
        if denominator == 0:
            return "stable"
        
        slope = numerator / denominator
        
        if abs(slope) < 0.1 * (sum(y) / n):  # Less than 10% variance
            return "stable"
        elif slope > 0:
            return "up"
        else:
            return "down"
    
    def generate_maturity_score(self) -> Dict:
        """
        Generate security program maturity score.
        
        Returns:
            Maturity assessment
        """
        # Map metrics to maturity domains
        domains = {
            "Identity Management": ["KPI-001"],
            "Operations Security": ["KPI-002", "KRI-003"],
            "Detection": ["KRI-001", "KRI-005"],
            "Response": ["KRI-002"],
            "Awareness": ["KPI-003", "KPI-004"],
            "Supply Chain": ["KRI-004"],
            "Recovery": ["KPI-005"]
        }
        
        maturity = {
            "overall_score": 0,
            "domains": {},
            "level": 1,
            "level_name": "Initial",
            "next_level_targets": []
        }
        
        total_score = 0
        domain_count = 0
        
        for domain, metric_ids in domains.items():
            domain_score = 0
            metric_count = 0
            
            for metric_id in metric_ids:
                if metric_id in self.metrics:
                    measurements = self.measurements.get(metric_id, [])
                    if measurements:
                        latest = measurements[-1]
                        metric = self.metrics[metric_id]
                        
                        # Calculate score based on target and current value
                        if metric.target > 0:
                            score = min(100, (latest.value / metric.target) * 100)
                        else:
                            score = 100 if latest.value == 0 else max(0, 100 - latest.value)
                        
                        domain_score += score
                        metric_count += 1
            
            if metric_count > 0:
                domain_avg = domain_score / metric_count
                maturity["domains"][domain] = min(100, domain_avg)
                total_score += domain_avg
                domain_count += 1
        
        if domain_count > 0:
            maturity["overall_score"] = total_score / domain_count
        
        # Determine maturity level
        score = maturity["overall_score"]
        if score >= 90:
            maturity["level"] = 5
            maturity["level_name"] = "Optimizing"
        elif score >= 75:
            maturity["level"] = 4
            maturity["level_name"] = "Managed"
        elif score >= 60:
            maturity["level"] = 3
            maturity["level_name"] = "Defined"
        elif score >= 40:
            maturity["level"] = 2
            maturity["level_name"] = "Repeatable"
        else:
            maturity["level"] = 1
            maturity["level_name"] = "Initial"
        
        # Identify next level targets
        if maturity["level"] < 5:
            next_level = min(5, maturity["level"] + 1)
            next_score = next_level * 20  # Approximate scores for levels
            
            maturity["next_level_targets"] = [
                f"Achieve maturity level {next_level} ({next_score}+ overall score)",
                f"Improve lowest performing domain: {min(maturity['domains'], key=maturity['domains'].get)}",
                "Implement continuous improvement program"
            ]
        
        return maturity
    
    def generate_executive_summary(self) -> str:
        """
        Generate executive summary report.
        
        Returns:
            Markdown formatted report
        """
        dashboard = self.generate_dashboard()
        maturity = self.generate_maturity_score()
        
        report = f"""
# Executive Security Dashboard
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Program Health Summary

| Metric | Status |
|--------|--------|
| Overall Maturity | Level {maturity['level']}: {maturity['level_name']} |
| Maturity Score | {maturity['overall_score']:.1f}% |
| Green Metrics | {dashboard['summary']['green']} |
| Yellow Metrics | {dashboard['summary']['yellow']} |
| Red Metrics | {dashboard['summary']['red']} |

## Domain Maturity Scores

| Domain | Score |
|--------|-------|
"""
        
        for domain, score in sorted(maturity['domains'].items(), key=lambda x: x[1]):
            bar = "█" * int(score / 5)
            report += f"| {domain} | {score:.1f}% {bar} |\n"
        
        report += f"""
## Priority Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
"""
        
        # Show metrics with red/yellow status first
        priority_metrics = sorted(
            dashboard['metrics'],
            key=lambda m: 0 if m['status'] == 'red' else 1 if m['status'] == 'yellow' else 2
        )[:10]
        
        for metric in priority_metrics:
            status_icon = {
                'green': '🟢',
                'yellow': '🟡',
                'red': '🔴',
                'unknown': '⚪'
            }.get(metric['status'], '⚪')
            
            report += f"| {metric['name']} | {metric['value']:.1f} | {metric['target']:.1f} | {status_icon} {metric['status']} |\n"
        
        if maturity['next_level_targets']:
            report += f"""
## Improvement Targets

"""
            for target in maturity['next_level_targets']:
                report += f"- 📋 {target}\n"
        
        return report


def main():
    """CLI for security metrics management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Security Metrics Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # List metrics
    list_parser = subparsers.add_parser('list', help='List metrics')
    
    # Add measurement
    measure_parser = subparsers.add_parser('measure', help='Add measurement')
    measure_parser.add_argument('--metric', '-m', required=True, help='Metric ID')
    measure_parser.add_argument('--value', '-v', type=float, required=True, help='Value')
    measure_parser.add_argument('--notes', '-n', help='Notes')
    
    # Dashboard
    dashboard_parser = subparsers.add_parser('dashboard', help='Generate dashboard')
    dashboard_parser.add_argument('--metric', '-m', nargs='+', help='Metric IDs')
    
    # Executive summary
    summary_parser = subparsers.add_parser('summary', help='Generate executive summary')
    
    # Maturity
    maturity_parser = subparsers.add_parser('maturity', help='Generate maturity score')
    
    args = parser.parse_args()
    
    manager = SecurityMetricsManager()
    
    if args.command == 'list':
        print("\nSecurity Metrics:")
        print("=" * 80)
        for metric in manager.metrics.values():
            status = "Unknown"
            if metric.metric_id in manager.measurements and manager.measurements[metric.metric_id]:
                latest = manager.measurements[metric.metric_id][-1]
                status = latest.status
            
            status_icon = {
                'green': '🟢',
                'yellow': '🟡',
                'red': '🔴',
                'unknown': '⚪'
            }.get(status, '⚪')
            
            print(f"{status_icon} {metric.metric_id}: {metric.name}")
            print(f"   Type: {metric.metric_type} | Category: {metric.category}")
            print(f"   Target: {metric.target} | Frequency: {metric.frequency}")
    
    elif args.command == 'measure':
        measurement = manager.add_measurement(args.metric, args.value, args.notes or "")
        if measurement:
            print(f"✅ Measurement added for {args.metric}")
            print(f"   Value: {args.value}")
            print(f"   Status: {measurement.status}")
        else:
            print("❌ Metric not found")
    
    elif args.command == 'dashboard':
        dashboard = manager.generate_dashboard(args.metric)
        
        print("\n📊 Security Dashboard")
        print("=" * 80)
        print(f"Generated: {dashboard['generated'][:16]}")
        print(f"\nSummary: {dashboard['summary']['green']} 🟢 | {dashboard['summary']['yellow']} 🟡 | {dashboard['summary']['red']} 🔴")
        
        print("\nMetric | Value | Target | Status")
        print("-" * 60)
        
        for metric in sorted(dashboard['metrics'], key=lambda m: 0 if m['status'] == 'red' else 1 if m['status'] == 'yellow' else 2):
            status_icon = {
                'green': '🟢',
                'yellow': '🟡',
                'red': '🔴',
                'unknown': '⚪'
            }.get(metric['status'], '⚪')
            
            print(f"{metric['name'][:30]:30} | {metric['value']:6.1f} | {metric['target']:6.1f} | {status_icon} {metric['status']}")
    
    elif args.command == 'summary':
        summary = manager.generate_executive_summary()
        print(summary)
    
    elif args.command == 'maturity':
        maturity = manager.generate_maturity_score()
        
        print(f"\n📈 Security Program Maturity")
        print("=" * 60)
        print(f"Overall Score: {maturity['overall_score']:.1f}%")
        print(f"Maturity Level: {maturity['level']} - {maturity['level_name']}")
        
        print("\nDomain Scores:")
        for domain, score in sorted(maturity['domains'].items(), key=lambda x: x[1]):
            bar = "█" * int(score / 5)
            print(f"  {domain:25} | {score:5.1f}% {bar}")
        
        if maturity['next_level_targets']:
            print("\nNext Level Targets:")
            for target in maturity['next_level_targets']:
                print(f"  - {target}")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

### Step 3: Security Champions Program

**The Target:** Create a security champions program that embeds security advocates throughout the organization.

**The Concept:** Security champions are like safety officers in a factory—they're not part of the security team, but they're trained to spot risks and promote good practices in their teams.

**File:** `06-culture-improvement/scripts/security_champions.py`

```python
#!/usr/bin/env python3
"""
Security Champions Program Management

This module implements security champions program including:
- Champion recruitment and onboarding
- Training and certification
- Activities and engagement
- Metrics and recognition
- Community management
"""

import json
import datetime
import hashlib
import secrets
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field
from enum import Enum
import os


class ChampionLevel(Enum):
    """Security champion levels."""
    ASSOCIATE = "associate"
    PRACTITIONER = "practitioner"
    ADVOCATE = "advocate"
    LEADER = "leader"
    STRATEGIST = "strategist"


class ChampionStatus(Enum):
    """Champion status."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    ONBOARDING = "onboarding"
    ON_LEAVE = "on_leave"
    RETIRED = "retired"


@dataclass
class SecurityChampion:
    """
    Security champion record.
    
    Attributes:
        champion_id: Unique identifier
        user_id: User identifier
        name: Champion name
        email: Email address
        department: Department
        level: Champion level
        status: Current status
        joined_date: Date joined
        activities: List of activities
        certifications: List of certifications
        contributions: Contribution metrics
    """
    champion_id: str
    user_id: str
    name: str
    email: str
    department: str
    level: str = ChampionLevel.ASSOCIATE.value
    status: str = ChampionStatus.ACTIVE.value
    joined_date: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat())
    activities: List[Dict] = field(default_factory=list)
    certifications: List[str] = field(default_factory=list)
    contributions: Dict[str, int] = field(default_factory=dict)
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "champion_id": self.champion_id,
            "user_id": self.user_id,
            "name": self.name,
            "email": self.email,
            "department": self.department,
            "level": self.level,
            "status": self.status,
            "joined_date": self.joined_date,
            "activities": self.activities,
            "certifications": self.certifications,
            "contributions": self.contributions,
            "attributes": self.attributes
        }


@dataclass
class ChampionActivity:
    """
    Champion activity record.
    
    Attributes:
        activity_id: Unique identifier
        champion_id: Champion identifier
        activity_type: Type of activity
        description: Activity description
        date: Activity date
        impact: Impact level (1-5)
        hours: Hours spent
    """
    activity_id: str
    champion_id: str
    activity_type: str
    description: str
    date: str
    impact: int = 3
    hours: float = 1.0
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "activity_id": self.activity_id,
            "champion_id": self.champion_id,
            "activity_type": self.activity_type,
            "description": self.description,
            "date": self.date,
            "impact": self.impact,
            "hours": self.hours
        }


class SecurityChampionsProgram:
    """
    Security Champions Program Management.
    
    This class handles champion recruitment, training, activities,
    and program measurement.
    """
    
    def __init__(self, data_dir: str = "./champions_data"):
        """
        Initialize Security Champions Program.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.champions: Dict[str, SecurityChampion] = {}
        self.activities: Dict[str, ChampionActivity] = {}
        self.audit_log: List[Dict] = []
        
        self._load_data()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/champions", exist_ok=True)
        os.makedirs(f"{self.data_dir}/activities", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load champions
        champions_dir = f"{self.data_dir}/champions"
        if os.path.exists(champions_dir):
            for filename in os.listdir(champions_dir):
                if filename.endswith('.json'):
                    with open(f"{champions_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        champion = SecurityChampion(
                            champion_id=data['champion_id'],
                            user_id=data['user_id'],
                            name=data['name'],
                            email=data['email'],
                            department=data['department'],
                            level=data.get('level', ChampionLevel.ASSOCIATE.value),
                            status=data.get('status', ChampionStatus.ACTIVE.value),
                            joined_date=data.get('joined_date', datetime.datetime.utcnow().isoformat()),
                            activities=data.get('activities', []),
                            certifications=data.get('certifications', []),
                            contributions=data.get('contributions', {}),
                            attributes=data.get('attributes', {})
                        )
                        self.champions[champion.champion_id] = champion
    
    def _save_champion(self, champion: SecurityChampion) -> None:
        """Save champion record."""
        with open(f"{self.data_dir}/champions/{champion.champion_id}.json", 'w') as f:
            json.dump(champion.to_dict(), f, indent=2)
    
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
    
    def recruit_champion(self, user_id: str, name: str, email: str, 
                         department: str) -> SecurityChampion:
        """
        Recruit a new security champion.
        
        Args:
            user_id: User identifier
            name: Champion name
            email: Email address
            department: Department
            
        Returns:
            Created SecurityChampion
        """
        champion_id = hashlib.md5(
            f"{user_id}:{datetime.datetime.utcnow().isoformat()}".encode()
        ).hexdigest()[:12]
        
        champion = SecurityChampion(
            champion_id=champion_id,
            user_id=user_id,
            name=name,
            email=email,
            department=department,
            status=ChampionStatus.ONBOARDING.value
        )
        
        self.champions[champion_id] = champion
        self._save_champion(champion)
        self._log_audit("CHAMPION_RECRUITED", user_id, {
            "champion_id": champion_id,
            "name": name,
            "department": department
        })
        
        return champion
    
    def record_activity(self, champion_id: str, activity_type: str,
                        description: str, impact: int = 3, 
                        hours: float = 1.0) -> Optional[ChampionActivity]:
        """
        Record a champion activity.
        
        Args:
            champion_id: Champion ID
            activity_type: Type of activity
            description: Activity description
            impact: Impact level
            hours: Hours spent
            
        Returns:
            Created ChampionActivity or None
        """
        if champion_id not in self.champions:
            return None
        
        champion = self.champions[champion_id]
        
        activity_id = f"ACT-{datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{secrets.token_hex(4)}"
        
        activity = ChampionActivity(
            activity_id=activity_id,
            champion_id=champion_id,
            activity_type=activity_type,
            description=description,
            date=datetime.datetime.utcnow().isoformat(),
            impact=impact,
            hours=hours
        )
        
        self.activities[activity_id] = activity
        
        # Add to champion activities
        champion.activities.append(activity.to_dict())
        
        # Update contributions
        if activity_type not in champion.contributions:
            champion.contributions[activity_type] = 0
        champion.contributions[activity_type] += 1
        
        self._save_champion(champion)
        self._log_audit("ACTIVITY_RECORDED", champion.user_id, {
            "activity_id": activity_id,
            "type": activity_type
        })
        
        return activity
    
    def advance_champion(self, champion_id: str) -> bool:
        """
        Advance a champion to the next level.
        
        Args:
            champion_id: Champion ID
            
        Returns:
            True if advanced
        """
        champion = self.champions.get(champion_id)
        if not champion:
            return False
        
        levels = [l.value for l in ChampionLevel]
        current_index = levels.index(champion.level)
        
        if current_index >= len(levels) - 1:
            return False  # Already at highest level
        
        champion.level = levels[current_index + 1]
        self._save_champion(champion)
        self._log_audit("CHAMPION_ADVANCED", champion.user_id, {
            "champion_id": champion_id,
            "new_level": champion.level
        })
        
        return True
    
    def get_champion_dashboard(self) -> Dict:
        """
        Generate champion program dashboard.
        
        Returns:
            Dashboard data
        """
        total_champions = len(self.champions)
        by_level = {}
        by_department = {}
        by_status = {}
        total_activities = len(self.activities)
        
        for champion in self.champions.values():
            by_level[champion.level] = by_level.get(champion.level, 0) + 1
            by_department[champion.department] = by_department.get(champion.department, 0) + 1
            by_status[champion.status] = by_status.get(champion.status, 0) + 1
        
        # Recent activities
        recent_activities = sorted(
            self.activities.values(),
            key=lambda a: a.date,
            reverse=True
        )[:10]
        
        return {
            "total_champions": total_champions,
            "by_level": by_level,
            "by_department": by_department,
            "by_status": by_status,
            "total_activities": total_activities,
            "recent_activities": [a.to_dict() for a in recent_activities],
            "program_age": (datetime.datetime.utcnow() - 
                           datetime.datetime.fromisoformat(
                               min((c.joined_date for c in self.champions.values()), 
                                   default=datetime.datetime.utcnow().isoformat())
                           )).days if self.champions else 0
        }
    
    def generate_champion_report(self) -> str:
        """
        Generate champion program report.
        
        Returns:
            Markdown formatted report
        """
        dashboard = self.get_champion_dashboard()
        
        report = f"""
# Security Champions Program Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Champions | {dashboard['total_champions']} |
| Total Activities | {dashboard['total_activities']} |
| Program Age | {dashboard['program_age']} days |

## Champions by Level

| Level | Count |
|-------|-------|
"""
        
        for level, count in sorted(dashboard['by_level'].items()):
            report += f"| {level} | {count} |\n"
        
        report += """
## Champions by Department

| Department | Count |
|------------|-------|
"""
        
        for dept, count in sorted(dashboard['by_department'].items(), key=lambda x: x[1], reverse=True)[:10]:
            report += f"| {dept} | {count} |\n"
        
        report += """
## Recent Activities

| Date | Champion | Type | Description |
|------|----------|------|-------------|
"""
        
        for activity in dashboard['recent_activities']:
            champion = self.champions.get(activity['champion_id'])
            champion_name = champion.name if champion else "Unknown"
            report += f"| {activity['date'][:10]} | {champion_name} | {activity['activity_type']} | {activity['description'][:40]}... |\n"
        
        return report


def main():
    """CLI for security champions program."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Security Champions Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Recruit champion
    recruit_parser = subparsers.add_parser('recruit', help='Recruit champion')
    recruit_parser.add_argument('--user', '-u', required=True, help='User ID')
    recruit_parser.add_argument('--name', '-n', required=True, help='Champion name')
    recruit_parser.add_argument('--email', '-e', required=True, help='Email address')
    recruit_parser.add_argument('--department', '-d', required=True, help='Department')
    
    # Record activity
    activity_parser = subparsers.add_parser('activity', help='Record activity')
    activity_parser.add_argument('--champion', '-c', required=True, help='Champion ID')
    activity_parser.add_argument('--type', '-t', required=True, help='Activity type')
    activity_parser.add_argument('--description', '-d', required=True, help='Activity description')
    activity_parser.add_argument('--impact', '-i', type=int, default=3, help='Impact (1-5)')
    activity_parser.add_argument('--hours', '-h', type=float, default=1.0, help='Hours spent')
    
    # Advance champion
    advance_parser = subparsers.add_parser('advance', help='Advance champion')
    advance_parser.add_argument('--champion', '-c', required=True, help='Champion ID')
    
    # Dashboard
    dashboard_parser = subparsers.add_parser('dashboard', help='Show dashboard')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    args = parser.parse_args()
    
    program = SecurityChampionsProgram()
    
    if args.command == 'recruit':
        champion = program.recruit_champion(args.user, args.name, args.email, args.department)
        print(f"✅ Champion recruited: {champion.champion_id}")
        print(f"   Name: {champion.name}")
        print(f"   Department: {champion.department}")
        print(f"   Status: {champion.status}")
    
    elif args.command == 'activity':
        activity = program.record_activity(
            args.champion,
            args.type,
            args.description,
            args.impact,
            args.hours
        )
        if activity:
            print(f"✅ Activity recorded: {activity.activity_id}")
            print(f"   Type: {activity.activity_type}")
            print(f"   Impact: {activity.impact}")
            print(f"   Hours: {activity.hours}")
        else:
            print("❌ Champion not found")
    
    elif args.command == 'advance':
        if program.advance_champion(args.champion):
            print(f"✅ Champion advanced: {args.champion}")
            champion = program.champions.get(args.champion)
            print(f"   New Level: {champion.level if champion else 'Unknown'}")
        else:
            print("❌ Champion not found or already at highest level")
    
    elif args.command == 'dashboard':
        dashboard = program.get_champion_dashboard()
        print("\n📊 Security Champions Dashboard")
        print("=" * 60)
        print(f"Total Champions: {dashboard['total_champions']}")
        print(f"Total Activities: {dashboard['total_activities']}")
        print(f"Program Age: {dashboard['program_age']} days")
        
        print("\nLevel Distribution:")
        for level, count in sorted(dashboard['by_level'].items()):
            print(f"  {level}: {count}")
    
    elif args.command == 'report':
        report = program.generate_champion_report()
        print(report)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

## Verification

### Verification 1: Test Security Awareness Program

```bash
cd 06-culture-improvement/scripts

# Assign training to users
python3 security_awareness.py assign --user user001 --module security_basics
python3 security_awareness.py assign --user user001 --module phishing_awareness
python3 security_awareness.py assign --user user002 --module security_basics

# Complete training
python3 security_awareness.py complete --user user001 --module security_basics --score 85
python3 security_awareness.py complete --user user001 --module phishing_awareness --score 90

# Check training status
python3 security_awareness.py status --user user001

# Create phishing campaign
python3 security_awareness.py campaign \
    --name "Quarterly Phishing Test" \
    --description "Q1 2024 phishing simulation" \
    --template '{"subject": "Important Security Update", "from": "security@company.com", "body": "Please review the attached security bulletin"}' \
    --users user001 user002 user003

# Simulate phishing responses
python3 security_awareness.py simulate --campaign CAMP-20240315-1234 --user user001 --action reported
python3 security_awareness.py simulate --campaign CAMP-20240315-1234 --user user002 --action clicked
python3 security_awareness.py simulate --campaign CAMP-20240315-1234 --user user003 --action ignored

# Generate report
python3 security_awareness.py report
```

### Verification 2: Test Security Metrics

```bash
# List available metrics
python3 security_metrics.py list

# Add measurements
python3 security_metrics.py measure --metric KPI-001 --value 92.5 --notes "MFA adoption increased"
python3 security_metrics.py measure --metric KPI-002 --value 94.0 --notes "Patch compliance stable"
python3 security_metrics.py measure --metric KRI-001 --value 3.5 --notes "Improved detection time"
python3 security_metrics.py measure --metric KRI-002 --value 1.8 --notes "Faster response time"
python3 security_metrics.py measure --metric KPI-003 --value 4.2 --notes "Good phishing awareness"
python3 security_metrics.py measure --metric KRI-003 --value 3.0 --notes "Vulnerabilities being addressed"

# Generate dashboard
python3 security_metrics.py dashboard

# Generate maturity score
python3 security_metrics.py maturity

# Generate executive summary
python3 security_metrics.py summary
```

### Verification 3: Test Security Champions Program

```bash
# Recruit champions
python3 security_champions.py recruit \
    --user user001 --name "John Doe" --email "john.doe@company.com" --department "Engineering"

python3 security_champions.py recruit \
    --user user002 --name "Jane Smith" --email "jane.smith@company.com" --department "Product"

python3 security_champions.py recruit \
    --user user003 --name "Bob Johnson" --email "bob.johnson@company.com" --department "Operations"

# Record activities
python3 security_champions.py activity \
    --champion <champion-id> --type "training" \
    --description "Conducted security training for engineering team" \
    --impact 4 --hours 2

python3 security_champions.py activity \
    --champion <champion-id> --type "review" \
    --description "Reviewed security requirements for new product feature" \
    --impact 3 --hours 1.5

# Advance champion
python3 security_champions.py advance --champion <champion-id>

# Generate report
python3 security_champions.py report
```

### Verification 4: End-to-End Integration Test

**File:** `06-culture-improvement/scripts/integration_test.py`

```python
#!/usr/bin/env python3
"""
Integration test for security culture and continuous improvement.
"""

import json
import datetime
import sys
import os
import time

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from security_awareness import SecurityAwarenessProgram
from security_metrics import SecurityMetricsManager
from security_champions import SecurityChampionsProgram


def run_integration_test():
    """Run end-to-end integration test."""
    print("🚀 Starting Security Culture Integration Test")
    print("=" * 60)
    
    # Initialize all programs
    print("\n1. Initializing security programs...")
    awareness = SecurityAwarenessProgram("./test_awareness_data")
    metrics = SecurityMetricsManager("./test_metrics_data")
    champions = SecurityChampionsProgram("./test_champions_data")
    
    # Create test users
    test_users = ["user001", "user002", "user003", "user004", "user005"]
    
    # 2. Security Awareness
    print("\n2. Testing Security Awareness...")
    
    # Assign training
    print("   Assigning training...")
    for user in test_users:
        for module in ["security_basics", "phishing_awareness", "data_protection"]:
            awareness.create_training_assignment(user, module)
    
    # Complete training (simulate some completions)
    print("   Completing training...")
    completions = [
        ("user001", "security_basics", 85),
        ("user001", "phishing_awareness", 90),
        ("user002", "security_basics", 78),
        ("user002", "data_protection", 82),
        ("user003", "security_basics", 92),
        ("user003", "phishing_awareness", 88),
    ]
    
    for user, module, score in completions:
        awareness.complete_training(user, module, score)
        print(f"   ✅ {user} completed {module}")
    
    # Phishing campaign
    print("\n3. Running phishing campaign...")
    campaign = awareness.create_phishing_campaign(
        name="Integration Test Phishing Campaign",
        description="Testing phishing simulation",
        template={"subject": "Security Alert", "body": "Please verify your credentials"},
        target_users=test_users
    )
    print(f"   📧 Campaign created: {campaign.campaign_id}")
    
    # Simulate responses
    responses = [
        ("user001", "reported"),
        ("user002", "clicked"),
        ("user003", "reported"),
        ("user004", "ignored"),
        ("user005", "clicked")
    ]
    
    for user, action in responses:
        awareness.simulate_phishing(campaign.campaign_id, user, action)
        print(f"   📊 {user}: {action}")
    
    # 4. Security Metrics
    print("\n4. Measuring Security Metrics...")
    
    # Add measurements
    measurements = [
        ("KPI-001", 92.5, "MFA adoption rate"),
        ("KPI-002", 94.0, "Patch compliance"),
        ("KRI-001", 3.5, "MTTD improvement"),
        ("KRI-002", 1.8, "MTTR improvement"),
        ("KPI-003", 4.2, "Phishing awareness"),
        ("KRI-003", 3.0, "Vulnerabilities being addressed"),
        ("KPI-004", 85.0, "Training completion rate"),
        ("KRI-004", 25.0, "Vendor risk score"),
        ("KPI-005", 92.0, "RTO compliance"),
        ("KRI-005", 3.0, "Security incidents this month")
    ]
    
    for metric_id, value, note in measurements:
        metrics.add_measurement(metric_id, value, note)
        print(f"   📈 {metric_id}: {value} ({note})")
    
    # 5. Security Champions
    print("\n5. Testing Security Champions...")
    
    # Recruit champions
    champion_data = [
        ("user001", "John Doe", "john@company.com", "Engineering"),
        ("user002", "Jane Smith", "jane@company.com", "Product"),
        ("user003", "Bob Johnson", "bob@company.com", "Operations")
    ]
    
    for user, name, email, dept in champion_data:
        champion = champions.recruit_champion(user, name, email, dept)
        print(f"   🏆 Recruited: {name} from {dept}")
    
    # Record activities
    activities = [
        ("champion-id-1", "training", "Conducted team security training", 4, 2.0),
        ("champion-id-2", "review", "Security reviewed product design", 3, 1.5),
        ("champion-id-1", "workshop", "Hosted security workshop", 5, 3.0),
        ("champion-id-3", "audit", "Performed security assessment", 4, 2.5)
    ]
    
    # Need to get actual champion IDs
    champion_ids = list(champions.champions.keys())
    for i, (champ_id, activity_type, desc, impact, hours) in enumerate(activities):
        if i < len(champion_ids):
            champ_id = champion_ids[i]
            champions.record_activity(champ_id, activity_type, desc, impact, hours)
            print(f"   📝 Recorded: {activity_type} by {champion_ids[i]}")
    
    # 6. Generate Reports
    print("\n6. Generating Reports...")
    
    # Awareness report
    awareness_report = awareness.generate_awareness_report()
    with open("./test_awareness_report.md", 'w') as f:
        f.write(awareness_report)
    print("   📊 Awareness report generated")
    
    # Metrics report
    metrics_report = metrics.generate_executive_summary()
    with open("./test_metrics_report.md", 'w') as f:
        f.write(metrics_report)
    print("   📊 Metrics report generated")
    
    # Champions report
    champions_report = champions.generate_champion_report()
    with open("./test_champions_report.md", 'w') as f:
        f.write(champions_report)
    print("   📊 Champions report generated")
    
    # 7. Maturity Assessment
    print("\n7. Assessing Program Maturity...")
    maturity = metrics.generate_maturity_score()
    print(f"   📈 Overall Maturity: Level {maturity['level']} - {maturity['level_name']}")
    print(f"   Score: {maturity['overall_score']:.1f}%")
    
    print("\n   Domain Scores:")
    for domain, score in sorted(maturity['domains'].items(), key=lambda x: x[1]):
        print(f"      {domain}: {score:.1f}%")
    
    # 8. Clean up
    print("\n8. Cleaning up...")
    import shutil
    for test_dir in ["./test_awareness_data", "./test_metrics_data", "./test_champions_data"]:
        if os.path.exists(test_dir):
            shutil.rmtree(test_dir)
            print(f"   🧹 Cleaned up: {test_dir}")
    
    print("\n" + "=" * 60)
    print("✅ Security Culture Integration Test Complete!")
    print("\nSummary:")
    print(f"   - Training completions: {len(completions)}")
    print(f"   - Phishing campaign responses: {len(responses)}")
    print(f"   - Metrics measured: {len(measurements)}")
    print(f"   - Champions recruited: {len(champion_data)}")
    print(f"   - Champion activities: {len(activities)}")
    print(f"   - Maturity Level: {maturity['level']} - {maturity['level_name']}")
    print("   - All components integrated successfully!")


if __name__ == "__main__":
    run_integration_test()
```

**Run the integration test:**
```bash
cd 06-culture-improvement/scripts
python3 integration_test.py
```

## Key Takeaways

### What You Built

1. **Security Awareness Program**: Complete training management and phishing simulations
2. **Security Metrics System**: Comprehensive KPIs, KRIs, and dashboards
3. **Security Champions Program**: Community-based security advocacy
4. **Maturity Assessment**: Continuous improvement framework

### Framework Mapping

| Component | NIST CSF | ISO 27001 | CMMI |
|-----------|----------|-----------|------|
| Awareness | GV.OC | A.6.3, A.7.2.2 | Level 3 |
| Metrics | GV.IP | A.9.2 | Level 4 |
| Champions | GV.OC | A.5.1 | Level 3 |
| Maturity | Continuous Improvement | A.5.1 | Level 5 |

### The Complete Enterprise Cybersecurity Program

You've now built a comprehensive enterprise cybersecurity program across six parts:

| Part | Focus | Key Components |
|------|-------|----------------|
| **Part 1** | Governance | RACI, Risk Framework, Strategy |
| **Part 2** | Assets & Identity | Discovery, Classification, ZTA |
| **Part 3** | Controls | IAM, EDR, Encryption, Segmentation |
| **Part 4** | Detection & Response | SIEM, Playbooks, BCP/DR |
| **Part 5** | Supply Chain | Vendor Risk, SBOM |
| **Part 6** | Culture & Improvement | Awareness, Metrics, Champions |

### The Journey Forward

Your cybersecurity program is now:

- **Governed**: Clear accountability and decision-making
- **Risk-Aware**: Comprehensive risk management
- **Visible**: Complete asset and data visibility
- **Protected**: Foundational security controls
- **Detecting**: Real-time monitoring and alerting
- **Responding**: Incident response capabilities
- **Resilient**: Business continuity and recovery
- **Secure by Supply Chain**: Vendor and SBOM management
- **Culturally Strong**: Security-first culture
- **Continuously Improving**: Metrics-driven maturity

### Next Steps for Your Organization

1. **Implement**: Deploy the systems and processes you've built
2. **Measure**: Track your KPIs and KRIs
3. **Improve**: Use the maturity model to target improvements
4. **Scale**: Adapt for your organization's size and complexity
5. **Sustain**: Build ongoing processes for continuous improvement

---

**Final Thoughts**

This series has taken you from governance to culture, from strategy to implementation, from discovery to continuous improvement. You now have the knowledge and tools to build, operate, and mature a world-class cybersecurity program for a multinational enterprise.

The key to success is remembering that cybersecurity is not a destination—it's a journey. Threats evolve, technology changes, and your program must adapt. But with the frameworks, architectures, and tools you've built, you have a solid foundation for protecting your organization against the cyber threats of today and tomorrow.

**You've built an entire enterprise cybersecurity program from the ground up. Now go protect your organization!**
